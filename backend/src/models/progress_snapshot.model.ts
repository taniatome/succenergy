/**
 * Table `progress_snapshots`, primary key `(user_id, date)`.
 *
 * One day of recorded activity, used by the Progress charts. The calendar
 * date is half the primary key, so a day can only be recorded once and a date
 * range is a key range with no extra index.
 */
export interface ProgressSnapshotDocument {
  date: Date;

  /** Average completion across active goals on this date, 0 to 1. */
  goalCompletion: number;

  actionsCompleted: number;
  exercisesCompleted: number;
}

export interface ProgressSnapshotResult {
  /** Calendar date, `YYYY-MM-DD`, which is also the document id. */
  date: string;

  goalCompletion: number;
  actionsCompleted: number;
  exercisesCompleted: number;

  /** Derived, mirroring Dart `ProgressSnapshot.wasActive`. */
  wasActive: boolean;
}

/** Days of activity rendered by the progress streak view. */
export const ACTIVITY_WINDOW_DAYS = 21;
