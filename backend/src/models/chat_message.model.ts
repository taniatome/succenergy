import type { LocalizedText } from './localized_text.model.js';

/**
 * Table `chat_messages`, one row per message, keyed to `coaching_sessions`
 * with `on delete cascade`.
 *
 * There is no `message_count` on the session: it is `count(*)` over this
 * table, and a stored copy is one more thing that can drift.
 */

/** Who wrote a message. Dart: MessageAuthor. */
export const MESSAGE_AUTHORS = ['coach', 'user'] as const;
export type MessageAuthor = (typeof MESSAGE_AUTHORS)[number];

export interface ChatMessageDocument {
  author: MessageAuthor;

  /** Locale map, matching Dart `ChatMessage.text`. */
  text: LocalizedText;

  sentAt: Date;
}

export interface ChatMessageResult {
  id: string;
  author: MessageAuthor;
  text: LocalizedText;
  sentAt: string;

  /** Derived, mirroring Dart `ChatMessage.isCoach`. */
  isCoach: boolean;
}
