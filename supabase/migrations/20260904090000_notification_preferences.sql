-- 20260904090000_notification_preferences.sql
--
-- Per-type notification preferences.
--
-- ## Why this column exists
--
-- The app's Notifications screen shows five switches — goal nudges, the
-- principle of the day, re-engagement, exercise reminders and quiet hours —
-- keyed by localisation key. The initial schema gave the user row two
-- settings: `reminders_enabled`, a master switch, and `rhythm`, how often the
-- coach checks in. Neither can hold five independent booleans.
--
-- Without somewhere to put them, four of those five switches would move and
-- forget, which is worse than not offering them: a person who turns
-- re-engagement off and finds it on again next launch has been lied to by the
-- interface.
--
-- ## Why jsonb rather than five columns
--
-- The set is product copy, not schema. Adding or renaming a notification type
-- is a change to the localisation table and the switch list, and it should not
-- also be a migration. The keys are never queried individually — the column is
-- read whole with the profile and written whole by the preferences PATCH — so
-- there is nothing to index and no reason to spread it across columns.
--
-- `not null default '{}'` rather than nullable: an account that has never
-- opened the screen has an empty map, and the API fills absent keys with the
-- type's default. A reader never has to distinguish "no preferences" from
-- "preferences that happen to be empty".

alter table users
  add column if not exists notification_preferences jsonb not null
    default '{}'::jsonb;

comment on column users.notification_preferences is
  'Localisation key to whether that notification type is switched on. Absent '
  'keys take the type''s default; the master switch is reminders_enabled.';
