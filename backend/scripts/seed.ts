/**
 * Seeds the mock persona into the local Postgres database.
 *
 *   npm run migrate       # once, against an empty database
 *   npm run emulators     # in another terminal — Auth only
 *   npm run seed
 *   npm run token         # signs in as the seeded persona
 *
 * The persona is Marisa Chissano, taken from lib/data/mock/mock_data.dart so
 * the seeded account reads as the same person the Flutter build demonstrates:
 * three weeks in, mid-cycle on Praxis, running a brand relaunch.
 *
 * Local only. The script refuses to run unless the Auth emulator is
 * configured and `NODE_ENV` is not production, because it writes fabricated
 * data and must never touch a live account or a live database.
 *
 * Re-seeding clears this user's data first — one `delete from users`, which
 * cascades — so a removed goal does not linger. The shared `exercises`
 * library is upserted rather than deleted, since it is not the user's data.
 *
 * The account is keyed to TEST_USER_EMAIL, so `npm run token` returns a token
 * for the uid seeded here and /v1/me returns the persona rather than an empty
 * profile.
 */

import { config as loadDotenv } from 'dotenv';

loadDotenv();

if (!process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    [
      '',
      'Refusing to seed: FIREBASE_AUTH_EMULATOR_HOST is not set.',
      'This script writes fabricated data and must never touch a real',
      'project. Start the Auth emulator with `npm run emulators`, then use',
      '`npm run seed`, which sets the host.',
      '',
    ].join('\n'),
  );
  process.exit(1);
}

if (process.env.NODE_ENV === 'production') {
  console.error('\nRefusing to seed with NODE_ENV=production.\n');
  process.exit(1);
}

const { closeDatabase, initDatabase, query, withTransaction } = await import(
  '../src/config/database.js'
);
const { auth } = await import('../src/config/firebase.js');
const { TRIAL_DAYS } = await import('../src/models/subscription.model.js');

const rawEmail = process.env.TEST_USER_EMAIL;
const rawPassword = process.env.TEST_USER_PASSWORD;

if (!rawEmail || !rawPassword) {
  console.error('\nTEST_USER_EMAIL and TEST_USER_PASSWORD must be set in .env.\n');
  process.exit(1);
}

// Re-declared as plain strings: narrowing from the check above does not reach
// inside the function bodies below, and both are read from them.
const email: string = rawEmail;
const password: string = rawPassword;

// --- Dates, relative to today so the persona never looks stale -------------

const startOfToday = new Date();
startOfToday.setHours(0, 0, 0, 0);

const daysAgo = (days: number): Date =>
  new Date(startOfToday.getTime() - days * 86_400_000);

const daysAhead = (days: number): Date =>
  new Date(startOfToday.getTime() + days * 86_400_000);

const hoursAgo = (hours: number): Date => new Date(Date.now() - hours * 3_600_000);

/** A `date` column takes `YYYY-MM-DD`, in UTC. Never a Date — see the note in
 *  config/database.ts about local-midnight parsing shifting the day. */
const dateOnly = (value: Date): string => value.toISOString().slice(0, 10);

/**
 * Finds or creates the persona's Auth account.
 *
 * Reuses an existing account rather than recreating it, so the uid is stable
 * across runs and a re-seed refreshes data under the same account instead of
 * stranding the previous one.
 */
async function resolveUid(): Promise<{ uid: string; created: boolean }> {
  try {
    const existing = await auth.getUserByEmail(email);
    return { uid: existing.uid, created: false };
  } catch {
    const created = await auth.createUser({
      email,
      password,
      displayName: 'Marisa Chissano',
      emailVerified: true,
    });
    return { uid: created.uid, created: true };
  }
}

/**
 * The persona's data.
 *
 * Bilingual columns carry both languages. Content the person or the coach
 * wrote — goal titles, chat messages, session summaries — is one column, in
 * the language it was written, which is how those tables are shaped.
 */
async function seedUser(uid: string): Promise<void> {
  await withTransaction(async (client) => {
    // One statement, and the cascade removes goals, milestones, actions,
    // responses, sessions, messages, notifications, snapshots, purpose
    // answers, the subscription and the onboarding row with it.
    //
    // Matched on the email as well as the uid, because the uid is only stable
    // while the Auth emulator keeps its accounts. It is started without an
    // import/export directory, so a restart empties it, `resolveUid` stops
    // finding the persona and mints a *new* uid. A delete scoped to that new
    // uid then clears nothing, and the next insert collides with the previous
    // run's rows — the persona's ids (`goal-relaunch`, `ms-relaunch-1`, …) are
    // fixed strings so the seeded data is readable, which makes them global
    // primary keys rather than per-account ones. The email is what the persona
    // is actually keyed to, so a row carrying it *is* the previous run's
    // account, whatever uid it was written under.
    await client.query('delete from users where id = $1 or email = $2', [uid, email]);

    // --- The person --------------------------------------------------------

    await client.query(
      `insert into users (
         id, email, name, preferred_language, activity, date_of_birth,
         country_code, accepted_terms, confirmed_info_true, current_principle,
         cycle_day, day_streak, tone, rhythm, reminders_enabled,
         notification_preferences, created_at, updated_at
       ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,
                 $15, $16::jsonb, $17, $18)`,
      [
        uid,
        email,
        'Marisa Chissano',
        'en',
        'professional',
        '1991-04-17',
        'MZ',
        true,
        true,
        'praxis',
        19,
        12,
        'direct',
        'daily',
        true,
        // The per-type switches, with re-engagement off — the mock persona
        // had it off too, and a seed where every switch matches the master
        // would prove nothing about the merge the PATCH does.
        JSON.stringify({
          'notifications.pref.goalNudges': true,
          'notifications.pref.principleOfDay': true,
          'notifications.pref.reengagement': false,
          'notifications.pref.exerciseReminders': true,
          'notifications.pref.quietHours': true,
        }),
        daysAgo(21),
        hoursAgo(3),
      ],
    );

    // --- Onboarding --------------------------------------------------------

    await client.query(
      `insert into onboarding_responses (
         user_id, ambition_en, ambition_pt, challenge_en, challenge_pt,
         main_goals_en, main_goals_pt, success_vision_en, success_vision_pt,
         focus_area_keys, priority_keys, motivation_balance,
         completed_at, updated_at
       ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
      [
        uid,
        'Run the Q4 relaunch myself, well enough that nobody has to check my work, and be given a team after it.',
        'Conduzir eu própria o relançamento do Q4, bem o suficiente para ninguém ter de rever o meu trabalho, e receber uma equipa depois disso.',
        'I plan carefully and then hesitate before showing anything. The delay looks like thoroughness. It is not.',
        'Planeio com cuidado e depois hesito antes de mostrar seja o que for. O atraso parece rigor. Não é.',
        'Lead the relaunch end to end. Speak at the Leadership Forum in November. Stop losing my mornings.',
        'Liderar o relançamento do início ao fim. Falar no Fórum de Liderança em novembro. Parar de perder as minhas manhãs.',
        'A Tuesday where the hard work happens before ten, the relaunch is on track without me holding it together, and I said the thing in the room instead of writing it down afterwards.',
        'Uma terça-feira em que o trabalho difícil acontece antes das dez, o relançamento avança sem eu ter de o segurar, e em que disse a coisa na sala em vez de a escrever depois.',
        ['onboarding.option.career', 'onboarding.option.confidence'],
        [
          'onboarding.option.visibility',
          'onboarding.option.focus',
          'onboarding.option.team',
        ],
        0.35,
        daysAgo(20),
        daysAgo(20),
      ],
    );

    // --- Goals, with milestones and actions as real rows -------------------

    await client.query(
      `insert into goals (id, user_id, title, why, principle, target_date,
                          completed_at, created_at, updated_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        'goal-relaunch',
        uid,
        'Lead the Q4 brand relaunch end to end',
        'If I run this one well, the leadership conversation stops being hypothetical.',
        'praxis',
        dateOnly(daysAhead(34)),
        null,
        daysAgo(19),
        daysAgo(2),
      ],
    );

    await client.query(
      `insert into goals (id, user_id, title, why, principle, target_date,
                          completed_at, created_at, updated_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        'goal-forum',
        uid,
        'Speak at the November Leadership Forum',
        'Saying it in a room is the part I keep avoiding.',
        'passion',
        dateOnly(daysAhead(61)),
        null,
        daysAgo(14),
        daysAgo(5),
      ],
    );

    const milestones: [string, string, string, string, Date | null, number][] = [
      [
        'ms-relaunch-1',
        'goal-relaunch',
        'Positioning brief signed off',
        dateOnly(daysAgo(16)),
        daysAgo(15),
        0,
      ],
      [
        'ms-relaunch-2',
        'goal-relaunch',
        'Creative route chosen with the agency',
        dateOnly(daysAgo(9)),
        daysAgo(8),
        1,
      ],
      [
        'ms-relaunch-3',
        'goal-relaunch',
        'Budget approved by finance',
        dateOnly(daysAgo(3)),
        daysAgo(2),
        2,
      ],
      [
        'ms-relaunch-4',
        'goal-relaunch',
        'Internal preview delivered to the leadership team',
        dateOnly(daysAhead(12)),
        null,
        3,
      ],
      ['ms-forum-1', 'goal-forum', 'Abstract submitted', dateOnly(daysAgo(5)), daysAgo(6), 0],
      ['ms-forum-2', 'goal-forum', 'Talk outlined', dateOnly(daysAhead(20)), null, 1],
    ];

    for (const [id, goalId, title, dueDate, reachedAt, position] of milestones) {
      await client.query(
        `insert into milestones (id, goal_id, title, due_date, reached_at, position)
         values ($1, $2, $3, $4, $5, $6)`,
        [id, goalId, title, dueDate, reachedAt, position],
      );
    }

    const actions: [string, string, string, boolean, boolean, number][] = [
      [
        'act-relaunch-1',
        'goal-relaunch',
        'Send the revised launch timeline to Aleixo for sign-off',
        false,
        true,
        0,
      ],
      [
        'act-relaunch-2',
        'goal-relaunch',
        'Write the one-page story the sales team can repeat',
        true,
        false,
        1,
      ],
      [
        'act-relaunch-3',
        'goal-relaunch',
        'Cut the preview deck from twenty-two slides to nine',
        true,
        false,
        2,
      ],
      [
        'act-forum-1',
        'goal-forum',
        'Draft the opening ninety seconds and read it aloud once',
        false,
        false,
        0,
      ],
    ];

    for (const [id, goalId, title, isDone, isToday, position] of actions) {
      await client.query(
        `insert into action_items (id, goal_id, title, is_done, is_today, position)
         values ($1, $2, $3, $4, $5, $6)`,
        [id, goalId, title, isDone, isToday, position],
      );
    }

    // --- Exercise responses ------------------------------------------------

    await client.query(
      `insert into exercise_responses (id, user_id, exercise_id, principle,
                                       step_responses, reflection,
                                       suggested_action, completed_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        'resp-sentence-test',
        uid,
        'ex-sentence-test',
        'purpose',
        JSON.stringify({
          'st-1':
            'I make complicated work understandable so that other people can act on it.',
          'st-2': 'Mine',
          'st-3':
            'I name the thing a room is circling around, and then I make it possible to do.',
        }),
        'The second version is the one I would actually say out loud.',
        'Say your sentence out loud to one person this week',
        daysAgo(16),
      ],
    );

    // --- Sessions and their messages ---------------------------------------

    await client.query(
      `insert into coaching_sessions (id, user_id, started_at, ended_at,
                                      summary, principle)
       values ($1, $2, $3, $4, $5, $6)`,
      [
        'ses-1',
        uid,
        daysAgo(5),
        new Date(daysAgo(5).getTime() + 18 * 60_000),
        'Where the relaunch actually stands, once the optimism was removed.',
        'praxis',
      ],
    );

    const firstSessionMessages: [string, string, string][] = [
      [
        'ses1-m1',
        'coach',
        'Give me the relaunch status as you would give it to someone who cannot help you.',
      ],
      [
        'ses1-m2',
        'user',
        'Positioning done, creative route chosen, budget still with finance.',
      ],
      [
        'ses1-m3',
        'coach',
        'Two of those are yours and one is not. Which of the two have you stopped moving while you wait for finance?',
      ],
      [
        'ses1-m4',
        'user',
        'The preview deck. I have been calling it blocked when it is not.',
      ],
    ];

    for (const [index, [id, author, text]] of firstSessionMessages.entries()) {
      await client.query(
        `insert into chat_messages (id, session_id, author, text, sent_at)
         values ($1, $2, $3, $4, $5)`,
        [id, 'ses-1', author, text, new Date(daysAgo(5).getTime() + index * 90_000)],
      );
    }

    await client.query(
      `insert into coaching_sessions (id, user_id, started_at, ended_at,
                                      summary, principle)
       values ($1, $2, $3, $4, $5, $6)`,
      [
        'ses-2',
        uid,
        daysAgo(2),
        new Date(daysAgo(2).getTime() + 11 * 60_000),
        'What the hesitation before showing work is actually protecting.',
        'praxis',
      ],
    );

    const secondSessionMessages: [string, string, string, Date][] = [
      [
        'ses2-m1',
        'coach',
        'You said the delay looks like thoroughness. What does it cost?',
        daysAgo(2),
      ],
      [
        'ses2-m2',
        'user',
        'Two days per decision, and the decision is rarely different.',
        new Date(daysAgo(2).getTime() + 120_000),
      ],
    ];

    for (const [id, author, text, sentAt] of secondSessionMessages) {
      await client.query(
        `insert into chat_messages (id, session_id, author, text, sent_at)
         values ($1, $2, $3, $4, $5)`,
        [id, 'ses-2', author, text, sentAt],
      );
    }

    // --- Notifications -----------------------------------------------------

    const notifications: [string, string, string, string, boolean, Date][] = [
      [
        'not-1',
        'goal_nudge',
        'The timeline is still unsent',
        'Sending it to Aleixo has been today’s action for two days. Praxis is contact, not readiness.',
        false,
        hoursAgo(5),
      ],
      [
        'not-2',
        'principle_of_day',
        'Praxis',
        'A plan that has not met reality is still a draft. Show one unfinished thing to one person today.',
        true,
        hoursAgo(9),
      ],
    ];

    for (const [id, type, title, body, isRead, receivedAt] of notifications) {
      await client.query(
        `insert into notifications (id, user_id, type, title, body, is_read,
                                    received_at)
         values ($1, $2, $3, $4, $5, $6, $7)`,
        [id, uid, type, title, body, isRead, receivedAt],
      );
    }

    // --- Subscription ------------------------------------------------------

    await client.query(
      `insert into subscriptions (user_id, tier, status, store,
                                  revenue_cat_app_user_id, entitlement_id,
                                  trial_started_at, trial_ends_at,
                                  current_period_end, updated_at)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        uid,
        'professional',
        'active',
        'play_store',
        uid,
        'coach_full',
        daysAgo(21),
        daysAgo(21 - TRIAL_DAYS),
        daysAhead(9),
        daysAgo(14),
      ],
    );

    // --- Progress snapshots, one row per calendar day ----------------------

    for (let offset = 20; offset >= 0; offset -= 1) {
      const active = offset % 7 !== 3;

      await client.query(
        `insert into progress_snapshots (user_id, date, goal_completion,
                                         actions_completed, exercises_completed)
         values ($1, $2, $3, $4, $5)`,
        [
          uid,
          dateOnly(daysAgo(offset)),
          Math.min(1, 0.25 + (20 - offset) * 0.03),
          active ? (offset % 3) + 1 : 0,
          offset % 5 === 0 ? 1 : 0,
        ],
      );
    }

    // --- Purpose answers ---------------------------------------------------

    const purposeAnswers: [string, string, Date][] = [
      [
        'talents',
        'I can hear what a group is circling around and say it in one sentence. People relax when the thing is finally named.',
        daysAgo(11),
      ],
      [
        'values',
        'I will not take credit that belongs to someone on my team, even when it would move me forward faster.',
        daysAgo(9),
      ],
    ];

    for (const [promptId, answer, updatedAt] of purposeAnswers) {
      await client.query(
        `insert into purpose_answers (user_id, prompt_id, answer, updated_at)
         values ($1, $2, $3, $4)`,
        [uid, promptId, answer, updatedAt],
      );
    }
  });
}

/**
 * The shared exercise library.
 *
 * Not the user's data, so it is upserted rather than cleared: a re-seed
 * refreshes the two exercises without disturbing anything an admin added.
 * Bilingual here, in paired columns, because this is the admin-managed
 * content the client edits in Supabase's table view.
 */
async function seedExercises(): Promise<void> {
  await withTransaction(async (client) => {
    const exercises: [
      string,
      string,
      string,
      string,
      string,
      string,
      number,
      string,
      string,
      string,
      string,
      number,
    ][] = [
      [
        'ex-sentence-test',
        'purpose',
        'The Sentence Test',
        'O Teste da Frase',
        'Reduce what you are doing to one sentence you would defend.',
        'Reduza o que anda a fazer a uma frase que defenderia.',
        8,
        'Which version would you say out loud?',
        'Qual das versões diria em voz alta?',
        'Say your sentence out loud to one person this week',
        'Diga a sua frase em voz alta a uma pessoa esta semana',
        1,
      ],
      [
        'ex-not-trade',
        'purpose',
        'What You Would Not Trade',
        'O Que Não Trocaria',
        'Find the line you will not cross, before you are asked to.',
        'Encontre o limite que não ultrapassa, antes de lho pedirem.',
        6,
        'Where is the line, in your own words?',
        'Onde está o limite, nas suas palavras?',
        'Write the line down where you will see it on a hard week',
        'Escreva o limite onde o verá numa semana difícil',
        2,
      ],
    ];

    for (const row of exercises) {
      await client.query(
        `insert into exercises (
           id, principle, title_en, title_pt, summary_en, summary_pt,
           duration_minutes, closing_reflection_prompt_en,
           closing_reflection_prompt_pt, suggested_action_en,
           suggested_action_pt, is_active, position
         ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, true, $12)
         on conflict (id) do update set
           principle                    = excluded.principle,
           title_en                     = excluded.title_en,
           title_pt                     = excluded.title_pt,
           summary_en                   = excluded.summary_en,
           summary_pt                   = excluded.summary_pt,
           duration_minutes             = excluded.duration_minutes,
           closing_reflection_prompt_en = excluded.closing_reflection_prompt_en,
           closing_reflection_prompt_pt = excluded.closing_reflection_prompt_pt,
           suggested_action_en          = excluded.suggested_action_en,
           suggested_action_pt          = excluded.suggested_action_pt,
           is_active                    = excluded.is_active,
           position                     = excluded.position`,
        row,
      );
    }

    // Replaced wholesale rather than upserted: a step removed from an
    // exercise must disappear, and the cascade already covers the delete.
    await client.query('delete from exercise_steps where exercise_id = any($1)', [
      ['ex-sentence-test', 'ex-not-trade'],
    ]);

    const steps: [
      string,
      string,
      number,
      string,
      string,
      string,
      string,
      string,
      string,
      string | null,
      string | null,
      string | null,
      string | null,
    ][] = [
      [
        'st-sentence-1',
        'ex-sentence-test',
        0,
        'free_text',
        'Why are you doing the work you are doing right now?',
        'Porque está a fazer o trabalho que faz neste momento?',
        'One sentence. If it needs a comma, it needs cutting.',
        'Uma frase. Se precisa de vírgula, precisa de corte.',
        '[]',
        null,
        null,
        null,
        null,
      ],
      [
        'st-sentence-2',
        'ex-sentence-test',
        1,
        'single_choice',
        'Read it back. Whose sentence is it?',
        'Releia. De quem é a frase?',
        'Answer before you decide what the right answer is.',
        'Responda antes de decidir qual é a resposta certa.',
        JSON.stringify([
          { en: 'Mine', pt: 'Minha' },
          { en: 'Someone I admire', pt: 'De alguém que admiro' },
          { en: 'My employer', pt: 'Da minha entidade patronal' },
          { en: 'I am not sure yet', pt: 'Ainda não tenho a certeza' },
        ]),
        null,
        null,
        null,
        null,
      ],
      [
        'st-sentence-3',
        'ex-sentence-test',
        2,
        'free_text',
        'Rewrite it so it could only have come from you.',
        'Reescreva-a para que só pudesse ter vindo de si.',
        'Keep the part that would embarrass you slightly.',
        'Mantenha a parte que o embaraçaria ligeiramente.',
        '[]',
        null,
        null,
        null,
        null,
      ],
      [
        'st-trade-1',
        'ex-not-trade',
        0,
        'free_text',
        'Name a result you want badly.',
        'Nomeie um resultado que deseja muito.',
        'The one you would not say in a meeting.',
        'Aquele que não diria numa reunião.',
        '[]',
        null,
        null,
        null,
        null,
      ],
      [
        'st-trade-2',
        'ex-not-trade',
        1,
        'scale',
        'How much of yourself would you trade for it?',
        'Quanto de si trocaria por isso?',
        'Answer honestly, then look at it.',
        'Responda com honestidade, depois olhe.',
        '[]',
        'Nothing',
        'Nada',
        'Anything',
        'Tudo',
      ],
    ];

    for (const step of steps) {
      await client.query(
        `insert into exercise_steps (
           id, exercise_id, position, type, prompt_en, prompt_pt,
           help_en, help_pt, options,
           scale_low_label_en, scale_low_label_pt,
           scale_high_label_en, scale_high_label_pt
         ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9::jsonb, $10, $11, $12, $13)`,
        step,
      );
    }
  });
}

/** Counted back from the database, so the report is what is actually stored. */
async function report(uid: string): Promise<Record<string, number>> {
  const { rows } = await query<Record<string, string>>(
    `select
       (select count(*) from onboarding_responses where user_id = $1) as onboarding,
       (select count(*) from goals where user_id = $1)                as goals,
       (select count(*) from milestones m join goals g on g.id = m.goal_id
          where g.user_id = $1)                                       as milestones,
       (select count(*) from action_items a join goals g on g.id = a.goal_id
          where g.user_id = $1)                                       as action_items,
       (select count(*) from exercise_responses where user_id = $1)   as exercise_responses,
       (select count(*) from coaching_sessions where user_id = $1)    as coaching_sessions,
       (select count(*) from chat_messages c
          join coaching_sessions cs on cs.id = c.session_id
          where cs.user_id = $1)                                      as chat_messages,
       (select count(*) from purpose_answers where user_id = $1)      as purpose_answers,
       (select count(*) from notifications where user_id = $1)        as notifications,
       (select count(*) from subscriptions where user_id = $1)        as subscriptions,
       (select count(*) from progress_snapshots where user_id = $1)   as progress_snapshots,
       (select count(*) from exercises)                               as exercises,
       (select count(*) from exercise_steps)                          as exercise_steps`,
    [uid],
  );

  const counts = rows[0] ?? {};
  return Object.fromEntries(
    Object.entries(counts).map(([name, value]) => [name, Number(value)]),
  );
}

async function seed(): Promise<void> {
  await initDatabase();

  const { uid, created } = await resolveUid();

  await seedUser(uid);
  await seedExercises();

  const counts = await report(uid);

  console.log(
    [
      '',
      created ? 'Created the persona account.' : 'Reseeded the existing persona account.',
      `  uid:   ${uid}`,
      `  email: ${email}`,
      '',
      'Rows:',
      ...Object.entries(counts).map(([name, count]) => `  ${name}: ${String(count)}`),
      '',
      'Get a token for this account with: npm run token',
      '',
    ].join('\n'),
  );

  noteLibrarySource(counts.exercises ?? 0);
}

/**
 * Says where the exercise library comes from.
 *
 * It starts empty in production — the content is the client's, entered
 * through the admin console — so a developer who has only ever seen the
 * seeded database should know the rows in front of them are a local fixture
 * and not a shipped library.
 */
function noteLibrarySource(exercises: number): void {
  const lines =
    exercises === 0
      ? [
          'The exercise library is empty.',
          'That is the production starting state: content is entered through',
          'the admin console at /v1/admin/exercises. The app shows its empty',
          'state rather than failing.',
        ]
      : [
          `The exercise library holds ${String(exercises)} seeded exercises.`,
          'These are a local fixture. In production the table starts empty',
          'and is filled through the admin console at /v1/admin/exercises.',
        ];

  for (const line of [...lines, '']) {
    console.log(line);
  }
}

try {
  await seed();
  await closeDatabase();
  process.exit(0);
} catch (error) {
  console.error('\nSeeding failed:', error instanceof Error ? error.message : error, '\n');
  await closeDatabase().catch(() => undefined);
  process.exit(1);
}
