import { query } from '../config/database.js';
import { countOf } from './row_mappers.js';

/** One row of the admin user directory. */
export interface DirectoryEntry {
  id: string;
  email: string;
  name: string;
  countryCode: string | null;
  activity: string | null;
  currentPrinciple: string;
  dayStreak: number;
  subscriptionTier: string | null;
  subscriptionStatus: string | null;
  joinedAt: Date;

  /** Most recent thing this account did, or null if it has done nothing. */
  lastSeenAt: Date | null;
}

/** Platform-level counters for the console. */
export interface PlatformStats {
  users: number;
  activeSubscriptions: number;
  trialSubscriptions: number;
  sessions: number;
  goals: number;
  exercisesCompleted: number;
  activeExercises: number;
}

interface DirectoryRow {
  id: string;
  email: string;
  name: string | null;
  country_code: string | null;
  activity: string | null;
  current_principle: string;
  day_streak: number;
  sub_tier: string | null;
  sub_status: string | null;
  created_at: Date;
  last_seen_at: Date | null;
}

/** Plain function rather than a static method: it is handed to `map`. */
function toEntry(row: DirectoryRow): DirectoryEntry {
  return {
    id: row.id,
    email: row.email,
    name: row.name ?? '',
    countryCode: row.country_code,
    activity: row.activity,
    currentPrinciple: row.current_principle,
    dayStreak: row.day_streak,
    subscriptionTier: row.sub_tier,
    subscriptionStatus: row.sub_status,
    joinedAt: row.created_at,
    lastSeenAt: row.last_seen_at,
  };
}

/**
 * Reads across every account, for the management console.
 *
 * The only repository whose statements are not scoped to one uid, which is
 * exactly why every route above it is behind `requireAdmin`. Nothing here is
 * reachable without the custom claim.
 */
export class AdminRepository {
  /**
   * A page of the directory, newest accounts first.
   *
   * Keyset pagination on `(created_at, id)` rather than `offset`: an offset
   * page shifts under you as accounts are created, so the console would show
   * a duplicate or skip a row while someone was reading it. The id breaks
   * ties, so the order is total and the cursor is unambiguous.
   *
   * `last_seen_at` is the latest of the three things an account does, which
   * is what the console's "Seen" column means. Counted per row rather than
   * stored, so nothing has to remember to touch a column on every write.
   */
  async listUsers(options: {
    limit: number;
    before?: { createdAt: Date; id: string };
  }): Promise<DirectoryEntry[]> {
    const activity = `
      greatest(
        (select max(er.completed_at) from exercise_responses er
          where er.user_id = u.id),
        (select max(cs.started_at) from coaching_sessions cs
          where cs.user_id = u.id),
        (select max(g.updated_at) from goals g where g.user_id = u.id)
      ) as last_seen_at`;

    const columns = `
      u.id, u.email, u.name, u.country_code, u.activity, u.current_principle,
      u.day_streak, u.created_at,
      s.tier as sub_tier, s.status as sub_status,
      ${activity}`;

    const { rows } =
      options.before === undefined
        ? await query<DirectoryRow>(
            `select ${columns}
               from users u
               left join subscriptions s on s.user_id = u.id
              order by u.created_at desc, u.id desc
              limit $1`,
            [options.limit],
          )
        : await query<DirectoryRow>(
            `select ${columns}
               from users u
               left join subscriptions s on s.user_id = u.id
              where (u.created_at, u.id) < ($2, $3)
              order by u.created_at desc, u.id desc
              limit $1`,
            [options.limit, options.before.createdAt, options.before.id],
          );

    return rows.map(toEntry);
  }

  async findUser(uid: string): Promise<DirectoryEntry | null> {
    const { rows } = await query<DirectoryRow>(
      `select u.id, u.email, u.name, u.country_code, u.activity,
              u.current_principle, u.day_streak, u.created_at,
              s.tier as sub_tier, s.status as sub_status,
              null::timestamptz as last_seen_at
         from users u
         left join subscriptions s on s.user_id = u.id
        where u.id = $1`,
      [uid],
    );

    const row = rows[0];
    return row ? toEntry(row) : null;
  }

  /** Platform counters, in one statement for the same reason as progress. */
  async stats(): Promise<PlatformStats> {
    const { rows } = await query<Record<string, string>>(
      `select
         (select count(*) from users) as users,
         (select count(*) from subscriptions
           where status in ('active', 'trialing')) as active_subscriptions,
         (select count(*) from subscriptions
           where status = 'trialing') as trial_subscriptions,
         (select count(*) from coaching_sessions) as sessions,
         (select count(*) from goals) as goals,
         (select count(*) from exercise_responses) as exercises_completed,
         (select count(*) from exercises where is_active) as active_exercises`,
    );

    const row = rows[0] ?? {};

    return {
      users: countOf(row.users),
      activeSubscriptions: countOf(row.active_subscriptions),
      trialSubscriptions: countOf(row.trial_subscriptions),
      sessions: countOf(row.sessions),
      goals: countOf(row.goals),
      exercisesCompleted: countOf(row.exercises_completed),
      activeExercises: countOf(row.active_exercises),
    };
  }

  /** True when the library holds nothing active, which the seed reports. */
  async isLibraryEmpty(): Promise<boolean> {
    const { rows } = await query<{ total: string }>(
      'select count(*) as total from exercises',
    );
    return countOf(rows[0]?.total) === 0;
  }
}

export const adminRepository = new AdminRepository();
