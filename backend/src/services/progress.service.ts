import type { MilestoneResult } from '../models/milestone.model.js';
import { PRINCIPLES, PRINCIPLE_COUNT } from '../models/principle.model.js';
import type { Principle } from '../models/principle.model.js';
import { ACTIVITY_WINDOW_DAYS } from '../models/progress_snapshot.model.js';
import type { ProgressSnapshotResult } from '../models/progress_snapshot.model.js';
import { exerciseResponseRepository } from '../repositories/exercise_response.repository.js';
import type { ExerciseResponseRepository } from '../repositories/exercise_response.repository.js';
import { progressRepository } from '../repositories/progress.repository.js';
import type {
  ProgressRepository,
  SnapshotRecord,
} from '../repositories/progress.repository.js';
import { userRepository } from '../repositories/user.repository.js';
import type { UserRepository } from '../repositories/user.repository.js';
import { ApiError } from '../utils/api_error.js';
import type { Caller } from './caller.js';
import { toMilestoneResult } from './goal_mappers.js';

/** Everything the Progress screen charts, in one payload. */
export interface ProgressResult {
  /** Share of this account's goals that are closed, 0 to 1. */
  goalCompletion: number;

  actionsCompleted: number;
  exercisesCompleted: number;
  sessionsCompleted: number;
  activeGoals: number;
  completedGoals: number;

  currentPrinciple: Principle;
  cycleDay: number;
  dayStreak: number;

  /** Share of the seven principles practised at least once, 0 to 1. */
  cycleCompletion: number;

  /** Completed exercises per principle. Every principle is present, at zero. */
  principleBreakdown: Record<Principle, number>;

  /** Milestones reached across every goal, most recent first. */
  reachedMilestones: MilestoneResult[];

  /** Recorded days, oldest first. */
  snapshots: ProgressSnapshotResult[];

  /** The four counters above the charts, keyed as the app reads them. */
  headline: Record<string, number>;
}

/** Days of snapshot history the Progress charts draw. */
const HISTORY_DAYS = 30;

/** Milestones the achievements list shows. */
const MILESTONE_LIMIT = 20;

function toSnapshotResult(record: SnapshotRecord): ProgressSnapshotResult {
  return {
    date: record.date.toISOString().slice(0, 10),
    goalCompletion: record.goalCompletion,
    actionsCompleted: record.actionsCompleted,
    exercisesCompleted: record.exercisesCompleted,
    wasActive: record.actionsCompleted > 0 || record.exercisesCompleted > 0,
  };
}

/**
 * The Progress screen's numbers.
 *
 * **Nothing here is a constant.** Every figure is counted from the rows that
 * produced it, so completing a goal or finishing an exercise changes it on
 * the next read. The mock this replaces returned static numbers that never
 * moved however much the user did, which made the whole screen decorative.
 */
export class ProgressService {
  private readonly progress: ProgressRepository;
  private readonly responses: ExerciseResponseRepository;
  private readonly users: UserRepository;

  constructor(
    progress: ProgressRepository = progressRepository,
    responses: ExerciseResponseRepository = exerciseResponseRepository,
    users: UserRepository = userRepository,
  ) {
    this.progress = progress;
    this.responses = responses;
    this.users = users;
  }

  async summary(caller: Caller): Promise<ProgressResult> {
    const [profile, totals, breakdown, practised, milestones, snapshots] =
      await Promise.all([
        this.users.findProfile(caller.uid),
        this.progress.totals(caller.uid),
        this.responses.countByPrinciple(caller.uid),
        this.progress.practisedPrinciples(caller.uid),
        this.progress.reachedMilestones(caller.uid, MILESTONE_LIMIT),
        this.progress.history(caller.uid, HISTORY_DAYS),
      ]);

    if (!profile) {
      throw ApiError.notFound('User profile not found');
    }

    const goalCompletion =
      totals.totalGoals === 0 ? 0 : totals.completedGoals / totals.totalGoals;

    return {
      goalCompletion,
      actionsCompleted: totals.actionsCompleted,
      exercisesCompleted: totals.exercisesCompleted,
      sessionsCompleted: totals.sessionsCompleted,
      activeGoals: totals.activeGoals,
      completedGoals: totals.completedGoals,

      currentPrinciple: profile.user.currentPrinciple,
      cycleDay: profile.user.cycleDay,
      dayStreak: profile.user.dayStreak,

      cycleCompletion: practised / PRINCIPLE_COUNT,
      principleBreakdown: ProgressService.fullBreakdown(breakdown),
      reachedMilestones: milestones.map(toMilestoneResult),
      snapshots: snapshots.map(toSnapshotResult),

      headline: {
        // A percentage, because the tile renders it as one.
        completionRate: Math.round(goalCompletion * 100),
        streak: profile.user.dayStreak,
        sessions: totals.sessionsCompleted,
        actions: totals.actionsCompleted,
      },
    };
  }

  /**
   * Every principle, including the ones with no practice yet.
   *
   * The chart draws seven bars whatever the data says, so a principle with no
   * responses has to arrive as zero rather than be missing — otherwise the
   * client fills the gap and the two disagree about what "no practice" looks
   * like.
   */
  private static fullBreakdown(
    counted: Record<string, number>,
  ): Record<Principle, number> {
    const breakdown = {} as Record<Principle, number>;
    for (const principle of PRINCIPLES) {
      breakdown[principle] = counted[principle] ?? 0;
    }
    return breakdown;
  }

  /**
   * Records today's snapshot from what the account actually shows right now.
   *
   * The figures are read here rather than accepted from the client, for the
   * same reason the principle of an exercise response is: a snapshot is the
   * server's record of a day, and a client that could write it could write
   * anything into the charts.
   */
  async recordSnapshot(caller: Caller): Promise<ProgressSnapshotResult> {
    const [totals, activity] = await Promise.all([
      this.progress.totals(caller.uid),
      this.progress.todayActivity(caller.uid),
    ]);

    const recorded = await this.progress.recordToday(caller.uid, {
      goalCompletion:
        totals.totalGoals === 0 ? 0 : totals.completedGoals / totals.totalGoals,
      actionsCompleted: activity.actionsDone,
      exercisesCompleted: activity.exercisesToday,
    });

    return toSnapshotResult(recorded);
  }

  /** The window the activity grid draws, for callers that need the length. */
  static get activityWindowDays(): number {
    return ACTIVITY_WINDOW_DAYS;
  }
}

export const progressService = new ProgressService();
