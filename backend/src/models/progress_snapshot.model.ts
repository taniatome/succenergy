import type { Timestamp } from 'firebase-admin/firestore';

/**
 * `users/{uid}/progressSnapshots/{yyyy-mm-dd}`
 *
 * One day of recorded activity, used by the Progress charts. The document id
 * is the calendar date so a day can only be recorded once and a date range
 * reads as a key range with no index.
 */
export interface ProgressSnapshotDocument {
  date: Timestamp;

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
