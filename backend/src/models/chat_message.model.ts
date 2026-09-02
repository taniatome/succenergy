import type { Timestamp } from 'firebase-admin/firestore';

import type { LocalizedText } from './localized_text.model.js';

/**
 * `users/{uid}/sessions/{sessionId}/messages/{messageId}`
 *
 * A subcollection rather than an array on the session, because a long
 * conversation would outgrow the 1 MiB document limit and because the coach
 * appends one message at a time.
 */

/** Who wrote a message. Dart: MessageAuthor. */
export const MESSAGE_AUTHORS = ['coach', 'user'] as const;
export type MessageAuthor = (typeof MESSAGE_AUTHORS)[number];

export interface ChatMessageDocument {
  author: MessageAuthor;

  /** Locale map, matching Dart `ChatMessage.text`. */
  text: LocalizedText;

  sentAt: Timestamp;
}

export interface ChatMessageResult {
  id: string;
  author: MessageAuthor;
  text: LocalizedText;
  sentAt: string;

  /** Derived, mirroring Dart `ChatMessage.isCoach`. */
  isCoach: boolean;
}
