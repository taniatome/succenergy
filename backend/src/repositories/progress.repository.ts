import { query } from '../config/database.js';
import type { MilestoneEntry } from '../models/milestone.model.js';
import type { ProgressSnapshotDocument } from '../models/progress_snapshot.model.js';
import { toMilestoneEntry } from './goal_rows.js';
import type { MilestoneRow } from './goal_rows.js';
import { countOf, fromDateColumn } from './row_mappers.js';

/** The counts the Progress screen is built from, all read from real rows. */
export interface ProgressTotals {
  totalGoals: number;
  completedGoals: number;
  activeGoals: number;
  actionsCompleted: number;
  exercisesCompleted: number;
  sessionsCompleted: number;
  milestonesReached: number;
}

/** One day's recorded activity. */
export interface SnapshotRecord extends ProgressSnapshotDocument {
  date: Date;
}

interface SnapshotRow {
  date: string;
  goal_completion: number;
  actions_completed: number;
  exercises_completed: number;
}

/**
 * Everything the Progress screen charts, counted rather than stored.
 *
 * Nothing here returns a constant. Each figure is a `count` or an `avg` over
 * the rows that produced it, so completing a goal or finishing an exercise
 * moves the number on the next read — which is the whole difference between
 * this and the mock it replaces.
 */
export class ProgressRepository {
  /**
   * The headline counts, in one round trip.
   *
   * Seven scalar subqueries in a single statement rather than seven
   * statements: they are independent, they are all keyed on the same uid, and
   * a Progress screen that opens is one read.
   */
  async totals(uid: string): Promise<ProgressTotals> {
    const { rows } = await query<Record<string, string>>(
      `select
         (select count(*) from goals where user_id = $1) as total_goals,
         (select count(*) from goals
            where user_id = $1 and completed_at is not null) as completed_goals,
         (select count(*) from goals
            where user_id = $1 and completed_at is null) as active_goals,
         (select count(*) from action_items a
            join goals g on g.id = a.goal_id
           where g.user_id = $1 and a.is_done) as actions_completed,
         (select count(*) from exercise_responses
            where user_id = $1) as exercises_completed,
         (select count(*) from coaching_sessions
            where user_id = $1 and ended_at is not null) as sessions_completed,
         (select count(*) from milestones m
            join goals g on g.id = m.goal_id
           where g.user_id = $1 and m.reached_at is not null) as milestones_reached`,
      [uid],
    );

    const row = rows[0] ?? {};

    return {
      totalGoals: countOf(row.total_goals),
      completedGoals: countOf(row.completed_goals),
      activeGoals: countOf(row.active_goals),
      actionsCompleted: countOf(row.actions_completed),
      exercisesCompleted: countOf(row.exercises_completed),
      sessionsCompleted: countOf(row.sessions_completed),
      milestonesReached: countOf(row.milestones_reached),
    };
  }

  /** Recorded days, oldest first, over the last `days` calendar days. */
  async history(uid: string, days: number): Promise<SnapshotRecord[]> {
    const { rows } = await query<SnapshotRow>(
      `select date, goal_completion, actions_completed, exercises_completed
         from progress_snapshots
        where user_id = $1 and date > current_date - $2::integer
        order by date`,
      [uid, days],
    );

    return rows.map((row) => ({
      date: fromDateColumn(row.date) ?? new Date(0),
      goalCompletion: row.goal_completion,
      actionsCompleted: row.actions_completed,
      exercisesCompleted: row.exercises_completed,
    }));
  }

  /** Milestones reached across every goal, most recent first. */
  async reachedMilestones(uid: string, limit: number): Promise<MilestoneEntry[]> {
    const { rows } = await query<MilestoneRow>(
      `select m.id, m.goal_id, m.title, m.due_date, m.reached_at, m.position
         from milestones m
         join goals g on g.id = m.goal_id
        where g.user_id = $1 and m.reached_at is not null
        order by m.reached_at desc
        limit $2`,
      [uid, limit],
    );

    return rows.map(toMilestoneEntry);
  }

  /**
   * The distinct principles this account has completed an exercise in.
   *
   * The cycle is closed one principle at a time, so "how far round" is how
   * many of the seven have been practised — not how many exercises were done,
   * which would pass 100% on a single principle.
   */
  async practisedPrinciples(uid: string): Promise<number> {
    const { rows } = await query<{ total: string }>(
      `select count(distinct principle) as total from exercise_responses
        where user_id = $1`,
      [uid],
    );
    return countOf(rows[0]?.total);
  }

  /**
   * Records today's snapshot, replacing any already written for today.
   *
   * The date comes from the database rather than the request, so a device
   * with a wrong clock or a different timezone cannot write a day that has
   * not happened, and the primary key keeps one row per person per day.
   */
  async recordToday(
    uid: string,
    snapshot: Omit<ProgressSnapshotDocument, 'date'>,
  ): Promise<SnapshotRecord> {
    const { rows } = await query<SnapshotRow>(
      `insert into progress_snapshots (
         user_id, date, goal_completion, actions_completed, exercises_completed
       )
       values ($1, current_date, $2, $3, $4)
       on conflict (user_id, date) do update set
         goal_completion     = excluded.goal_completion,
         actions_completed   = excluded.actions_completed,
         exercises_completed = excluded.exercises_completed
       returning date, goal_completion, actions_completed, exercises_completed`,
      [
        uid,
        snapshot.goalCompletion,
        snapshot.actionsCompleted,
        snapshot.exercisesCompleted,
      ],
    );

    const row = rows[0];
    return {
      date: fromDateColumn(row?.date ?? null) ?? new Date(),
      goalCompletion: row?.goal_completion ?? snapshot.goalCompletion,
      actionsCompleted: row?.actions_completed ?? snapshot.actionsCompleted,
      exercisesCompleted: row?.exercises_completed ?? snapshot.exercisesCompleted,
    };
  }

  /** Actions completed and exercises finished today, for the snapshot. */
  async todayActivity(
    uid: string,
  ): Promise<{ exercisesToday: number; actionsDone: number }> {
    const { rows } = await query<Record<string, string>>(
      `select
         (select count(*) from exercise_responses
           where user_id = $1
             and completed_at >= current_date) as exercises_today,
         (select count(*) from action_items a
            join goals g on g.id = a.goal_id
           where g.user_id = $1 and a.is_done) as actions_done`,
      [uid],
    );

    const row = rows[0] ?? {};
    return {
      exercisesToday: countOf(row.exercises_today),
      actionsDone: countOf(row.actions_done),
    };
  }
}

export const progressRepository = new ProgressRepository();
