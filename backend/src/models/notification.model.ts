import type { LocalizedText } from './localized_text.model.js';

/**
 * Table `notifications`.
 *
 * The notification inbox.
 */

/** The kinds of notification sent, each with its own icon treatment. */
export const NOTIFICATION_TYPES = [
  'goal_nudge',
  'principle_of_day',
  'reengagement',
  'exercise_reminder',
  'milestone',
] as const;

export type NotificationType = (typeof NOTIFICATION_TYPES)[number];

export interface NotificationDocument {
  type: NotificationType;
  title: LocalizedText;
  body: LocalizedText;

  /** Dart `AppNotification.receivedAt`. */
  receivedAt: Date;

  isRead: boolean;
}

export interface NotificationResult {
  id: string;
  type: NotificationType;
  title: LocalizedText;
  body: LocalizedText;
  receivedAt: string;
  isRead: boolean;
}
