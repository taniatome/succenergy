-- 20260903120000_initial_schema.sql
--
-- Application schema for the Succenergy AI Coach API.
--
-- Conventions, applied throughout:
--
--   * snake_case columns. The repository layer maps them to the camelCase the
--     Flutter models use, in one place per entity.
--   * `on delete cascade` from every child back to `users`. Account deletion
--     is `delete from users where id = $1` and the database removes the rest.
--   * Derived state is not stored. A goal's completion comes from
--     `completed_at`; a session's duration from its two timestamps.
--   * `updated_at` is maintained by a trigger, never by application code, so
--     it cannot be forgotten at a call site.
--   * Bilingual *library* content — the shared, admin-managed exercises — is
--     stored as paired `_en` / `_pt` columns rather than jsonb, so it stays
--     legible and editable in Supabase's table view. Content a person or the
--     coach writes is stored in one column, in the language it was written.
--   * Row level security is enabled on every table with no policies. The
--     backend connects as the service role and bypasses RLS; anything else
--     — the anon key, the authenticated key, a future dashboard — reads
--     nothing.
--
-- Enum-valued columns carry check constraints mirroring the TypeScript
-- unions in `src/models/`. They are the database-side twin of the Zod
-- schemas: the API rejects bad input, and the table rejects a bad hand-edit.

-- ---------------------------------------------------------------------------
-- updated_at trigger
-- ---------------------------------------------------------------------------

create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------------

create table if not exists users (
  id                  text primary key,          -- Firebase Auth uid
  email               text not null,
  name                text,
  preferred_language  text not null default 'en',
  activity            text,
  date_of_birth       date,
  country_code        char(2),
  accepted_terms      boolean not null default false,
  confirmed_info_true boolean not null default false,

  -- Where the person sits in the seven-principle cycle.
  current_principle   text not null default 'purpose',
  cycle_day           integer not null default 1,
  day_streak          integer not null default 0,

  -- Coaching preferences, flat rather than jsonb: three scalar settings that
  -- are read and written individually, and a PATCH of one must not disturb
  -- the other two.
  tone                text not null default 'direct',
  rhythm              text not null default 'daily',
  reminders_enabled   boolean not null default true,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),

  constraint users_preferred_language_check
    check (preferred_language in ('en', 'pt')),
  constraint users_activity_check
    check (activity is null or activity in ('student_minorities', 'professional')),
  constraint users_current_principle_check
    check (current_principle in ('purpose', 'passion', 'planning', 'praxis',
                                 'persistence', 'progress', 'perfection')),
  constraint users_tone_check
    check (tone in ('direct', 'warm', 'challenging')),
  constraint users_rhythm_check
    check (rhythm in ('daily', 'every_other_day', 'weekly')),
  constraint users_cycle_day_check check (cycle_day >= 1),
  constraint users_day_streak_check check (day_streak >= 0)
);

create or replace trigger users_set_updated_at
  before update on users
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- onboarding_responses — one per user
-- ---------------------------------------------------------------------------
--
-- The seven answers from the pre-registration quiz (Q1-Q3) and the
-- post-registration assessment (Q4-Q7). Free-text answers are paired columns
-- because the app writes the person's own words into both languages verbatim
-- and reads back by locale.
--
-- `focus_area_keys` and `priority_keys` are localisation keys, not display
-- text — the app resolves them.

create table if not exists onboarding_responses (
  user_id             text primary key references users(id) on delete cascade,

  ambition_en         text,
  ambition_pt         text,
  challenge_en        text,
  challenge_pt        text,
  main_goals_en       text,
  main_goals_pt       text,
  success_vision_en   text,
  success_vision_pt   text,

  focus_area_keys     text[] not null default '{}',
  priority_keys       text[] not null default '{}',

  -- Q6: inner drive (0) to the people they carry (1).
  motivation_balance  real,

  -- Null while the assessment is still partial. Server-stamped, never taken
  -- from the client.
  completed_at        timestamptz,
  updated_at          timestamptz not null default now(),

  constraint onboarding_motivation_balance_check
    check (motivation_balance is null
           or (motivation_balance >= 0 and motivation_balance <= 1))
);

create or replace trigger onboarding_responses_set_updated_at
  before update on onboarding_responses
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- goals
-- ---------------------------------------------------------------------------

create table if not exists goals (
  id           text primary key default gen_random_uuid()::text,
  user_id      text not null references users(id) on delete cascade,
  title        text not null,

  -- Why the goal matters. Dart `Goal.why`.
  why          text,

  principle    text not null,
  target_date  date,

  -- Null while the goal is active. The single source of completion: there is
  -- deliberately no `is_completed` column for it to disagree with.
  completed_at timestamptz,

  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint goals_principle_check
    check (principle in ('purpose', 'passion', 'planning', 'praxis',
                         'persistence', 'progress', 'perfection'))
);

create or replace trigger goals_set_updated_at
  before update on goals
  for each row execute function set_updated_at();

-- Every goal list is "this user's goals, open or done", so the filter column
-- rides along in the index rather than being a second lookup.
create index if not exists goals_user_completed_idx
  on goals (user_id, completed_at);

-- ---------------------------------------------------------------------------
-- milestones and action_items
-- ---------------------------------------------------------------------------
--
-- Real tables, not arrays embedded on the goal. They were embedded under
-- Firestore because joins were awkward there. They are not here, and a
-- milestone being its own row means it can be updated without rewriting the
-- goal.

create table if not exists milestones (
  id         text primary key default gen_random_uuid()::text,
  goal_id    text not null references goals(id) on delete cascade,
  title      text not null,
  due_date   date,

  -- Null while the milestone is still ahead of the person.
  reached_at timestamptz,

  position   integer not null default 0
);

create index if not exists milestones_goal_position_idx
  on milestones (goal_id, position);

create table if not exists action_items (
  id       text primary key default gen_random_uuid()::text,
  goal_id  text not null references goals(id) on delete cascade,
  title    text not null,
  is_done  boolean not null default false,

  -- The one action the Dashboard surfaces for today.
  is_today boolean not null default false,

  position integer not null default 0
);

create index if not exists action_items_goal_position_idx
  on action_items (goal_id, position);

-- ---------------------------------------------------------------------------
-- exercises — the shared, admin-managed library
-- ---------------------------------------------------------------------------
--
-- Not per-user, so no `user_id` and no cascade: what a particular person
-- answered lives in `exercise_responses`. `position` rather than `order`,
-- which is a reserved word.

create table if not exists exercises (
  id                            text primary key default gen_random_uuid()::text,
  principle                     text not null,
  title_en                      text,
  title_pt                      text,
  summary_en                    text,
  summary_pt                    text,
  duration_minutes              integer not null default 0,
  closing_reflection_prompt_en  text,
  closing_reflection_prompt_pt  text,
  suggested_action_en           text,
  suggested_action_pt           text,

  -- Withdrawn exercises are hidden from the library without being deleted,
  -- so responses to them keep their context.
  is_active                     boolean not null default true,

  position                      integer not null default 0,

  constraint exercises_principle_check
    check (principle in ('purpose', 'passion', 'planning', 'praxis',
                         'persistence', 'progress', 'perfection'))
);

create index if not exists exercises_principle_position_idx
  on exercises (principle, position)
  where is_active;

create table if not exists exercise_steps (
  id                   text primary key default gen_random_uuid()::text,
  exercise_id          text not null references exercises(id) on delete cascade,
  position             integer not null default 0,
  type                 text not null,
  prompt_en            text,
  prompt_pt            text,
  help_en              text,
  help_pt              text,

  -- Choices for a single_choice step: a variable-length list of `{en, pt}`
  -- objects, never queried by inner key, so jsonb rather than a fourth table.
  options              jsonb not null default '[]'::jsonb,

  scale_low_label_en   text,
  scale_low_label_pt   text,
  scale_high_label_en  text,
  scale_high_label_pt  text,

  -- Optional key this step's answer is filed under in a response. Defaults to
  -- the step id when absent.
  save_as              text,

  constraint exercise_steps_type_check
    check (type in ('free_text', 'single_choice', 'scale'))
);

create index if not exists exercise_steps_exercise_position_idx
  on exercise_steps (exercise_id, position);

-- ---------------------------------------------------------------------------
-- exercise_responses
-- ---------------------------------------------------------------------------
--
-- One row per completed run, not one per answered step: a session is reviewed
-- as a whole, so it should be one read.
--
-- `exercise_id` carries no foreign key on purpose. A response is history and
-- must survive the exercise being deleted from the library; a cascade would
-- erase what the person actually did.

create table if not exists exercise_responses (
  id               text primary key default gen_random_uuid()::text,
  user_id          text not null references users(id) on delete cascade,
  exercise_id      text not null,

  -- Denormalised from the exercise so progress can group without a join.
  principle        text not null,

  -- Step id (or its `save_as`) to the answer given. Genuinely variable shape,
  -- never queried by inner key.
  step_responses   jsonb not null default '{}'::jsonb,

  -- The closing reflection, in the person's own words.
  reflection       text,

  -- The action the session offered, captured as shown so a later wording
  -- change to the exercise does not rewrite history.
  suggested_action text,

  completed_at     timestamptz not null default now(),

  constraint exercise_responses_principle_check
    check (principle in ('purpose', 'passion', 'planning', 'praxis',
                         'persistence', 'progress', 'perfection'))
);

create index if not exists exercise_responses_user_completed_idx
  on exercise_responses (user_id, completed_at desc);

-- ---------------------------------------------------------------------------
-- coaching_sessions and chat_messages
-- ---------------------------------------------------------------------------

create table if not exists coaching_sessions (
  id         text primary key default gen_random_uuid()::text,
  user_id    text not null references users(id) on delete cascade,
  started_at timestamptz not null default now(),

  -- Null while the conversation is still open.
  ended_at   timestamptz,

  -- The one-line summary shown in the history list.
  summary    text,

  principle  text,

  constraint coaching_sessions_principle_check
    check (principle is null
           or principle in ('purpose', 'passion', 'planning', 'praxis',
                            'persistence', 'progress', 'perfection'))
);

create index if not exists coaching_sessions_user_started_idx
  on coaching_sessions (user_id, started_at desc);

-- No `message_count` column: it is `count(*)` over this table, and a stored
-- copy is one more thing that can drift.
create table if not exists chat_messages (
  id         text primary key default gen_random_uuid()::text,
  session_id text not null references coaching_sessions(id) on delete cascade,
  author     text not null,
  text       text not null,
  sent_at    timestamptz not null default now(),

  constraint chat_messages_author_check check (author in ('coach', 'user'))
);

-- A transcript is always read in order, so the sort key is in the index.
create index if not exists chat_messages_session_sent_idx
  on chat_messages (session_id, sent_at);

-- ---------------------------------------------------------------------------
-- purpose_answers
-- ---------------------------------------------------------------------------
--
-- The Purpose section's standing prompts. Keyed by prompt so a person can
-- only have one answer per prompt, and re-answering is an upsert.

create table if not exists purpose_answers (
  user_id    text not null references users(id) on delete cascade,
  prompt_id  text not null,
  answer     text,
  updated_at timestamptz not null default now(),

  primary key (user_id, prompt_id)
);

create or replace trigger purpose_answers_set_updated_at
  before update on purpose_answers
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- notifications
-- ---------------------------------------------------------------------------

create table if not exists notifications (
  id          text primary key default gen_random_uuid()::text,
  user_id     text not null references users(id) on delete cascade,
  type        text not null,
  title       text,
  body        text,
  is_read     boolean not null default false,
  received_at timestamptz not null default now(),

  constraint notifications_type_check
    check (type in ('goal_nudge', 'principle_of_day', 'reengagement',
                    'exercise_reminder', 'milestone'))
);

-- The inbox badge is "how many unread", so the flag is in the index.
create index if not exists notifications_user_unread_idx
  on notifications (user_id, is_read);

-- ---------------------------------------------------------------------------
-- subscriptions — one per user
-- ---------------------------------------------------------------------------
--
-- Written only by this backend from verified RevenueCat webhooks, never by
-- the client. Purchases go through native Apple and Google in-app purchase
-- with RevenueCat in front of them; there is no Stripe.
--
-- `store` is null until a real purchase happens, and the repository maps that
-- to the `'none'` the models use.

create table if not exists subscriptions (
  user_id                 text primary key references users(id) on delete cascade,
  tier                    text not null default 'trial',
  status                  text not null default 'none',

  -- Which store the purchase originated from — the fact that actually differs
  -- per account. RevenueCat sits in front of both and would be the same value
  -- on every row.
  store                   text,

  -- RevenueCat's app user id. Set to the Firebase uid when the SDK is wired
  -- up, so the two systems agree without a mapping table.
  revenue_cat_app_user_id text,

  -- The entitlement that grants access, e.g. `coach_full`. Access is gated on
  -- this rather than on tier: it is what RevenueCat reports as active, and it
  -- stays stable while products and prices change per store.
  entitlement_id          text,

  trial_started_at        timestamptz,
  trial_ends_at           timestamptz,
  current_period_end      timestamptz,
  updated_at              timestamptz not null default now(),

  constraint subscriptions_tier_check
    check (tier in ('trial', 'student', 'professional')),
  constraint subscriptions_status_check
    check (status in ('none', 'trialing', 'active', 'past_due', 'canceled',
                      'expired')),
  constraint subscriptions_store_check
    check (store is null or store in ('app_store', 'play_store'))
);

create or replace trigger subscriptions_set_updated_at
  before update on subscriptions
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- progress_snapshots
-- ---------------------------------------------------------------------------
--
-- One row per person per calendar day, so a day can only be recorded once and
-- a date range is a primary key range with no extra index.

create table if not exists progress_snapshots (
  user_id             text not null references users(id) on delete cascade,
  date                date not null,

  -- Average completion across active goals on this date, 0 to 1.
  goal_completion     real not null default 0,

  actions_completed   integer not null default 0,
  exercises_completed integer not null default 0,

  primary key (user_id, date),

  constraint progress_snapshots_goal_completion_check
    check (goal_completion >= 0 and goal_completion <= 1)
);

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------
--
-- Enabled everywhere, with no permissive policies anywhere. This is the
-- deny-all `firestore.rules` that Postgres replaces.
--
-- The backend connects as the service role, which bypasses RLS, so nothing
-- above changes. What this closes is every other way in: the Supabase anon
-- key, the authenticated key, a leaked key, or a future dashboard wired
-- straight to the database. Each of them reads zero rows from every table
-- below.
--
-- If a direct client read is ever genuinely needed, add one narrow policy for
-- that one table with an explicit condition. Do not relax the default.

alter table users               enable row level security;
alter table onboarding_responses enable row level security;
alter table goals               enable row level security;
alter table milestones          enable row level security;
alter table action_items        enable row level security;
alter table exercises           enable row level security;
alter table exercise_steps      enable row level security;
alter table exercise_responses  enable row level security;
alter table coaching_sessions   enable row level security;
alter table chat_messages       enable row level security;
alter table purpose_answers     enable row level security;
alter table notifications       enable row level security;
alter table subscriptions       enable row level security;
alter table progress_snapshots  enable row level security;
