import type { Timestamp } from 'firebase-admin/firestore';

import type { LocalizedText } from './localized_text.model.js';

/**
 * `users/{uid}/notifications/{notificationId}`
 *
 * The notification inbox. Bodies are stored in both languages because a
 * notification written when the user read English is still in the inbox
 * after they switch to Portuguese.
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
  receivedAt: Timestamp;

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
