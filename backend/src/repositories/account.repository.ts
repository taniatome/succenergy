import { withTransaction } from '../config/database.js';
import { countOf } from './row_mappers.js';

/** Every table a user's own data can be in, for the deletion audit count. */
const USER_DATA_COUNT_SQL = `
  select
    (select count(*) from onboarding_responses where user_id = $1)
  + (select count(*) from goals where user_id = $1)
  + (select count(*) from milestones m
       join goals g on g.id = m.goal_id where g.user_id = $1)
  + (select count(*) from action_items a
       join goals g on g.id = a.goal_id where g.user_id = $1)
  + (select count(*) from exercise_responses where user_id = $1)
  + (select count(*) from coaching_sessions where user_id = $1)
  + (select count(*) from chat_messages c
       join coaching_sessions cs on cs.id = c.session_id where cs.user_id = $1)
  + (select count(*) from purpose_answers where user_id = $1)
  + (select count(*) from notifications where user_id = $1)
  + (select count(*) from subscriptions where user_id = $1)
  + (select count(*) from progress_snapshots where user_id = $1)
  as dependent_rows`;

/**
 * Account deletion, which touches every table a person's data can be in.
 *
 * Its own repository because it belongs to no single entity: the count spans
 * eleven tables and the delete relies on all of them cascading from `users`.
 */
export class AccountRepository {
  /**
   * Deletes the account and everything belonging to it.
   *
   * One statement. Every child table references `users(id)` with
   * `on delete cascade`, so the database removes goals, milestones, actions,
   * exercise responses, sessions, chat messages, purpose answers,
   * notifications, the subscription, the onboarding response and the progress
   * snapshots without this code naming any of them.
   *
   * The dependent rows are counted first, in the same transaction, so the
   * response can say how much was removed — an auditable number that reveals
   * nothing about what the rows contained.
   */
  async deleteAllData(uid: string): Promise<{ documentsDeleted: number }> {
    return withTransaction(async (client) => {
      const counted = await client.query<{ dependent_rows: string }>(
        USER_DATA_COUNT_SQL,
        [uid],
      );

      const dependentRows = countOf(counted.rows[0]?.dependent_rows);
      const deleted = await client.query('delete from users where id = $1', [uid]);

      return { documentsDeleted: (deleted.rowCount ?? 0) + dependentRows };
    });
  }
}

export const accountRepository = new AccountRepository();
