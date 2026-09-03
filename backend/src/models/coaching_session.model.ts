import type { ChatMessageResult } from './chat_message.model.js';
import type { LocalizedText } from './localized_text.model.js';
import type { Principle } from './principle.model.js';

/**
 * Table `coaching_sessions`.
 *
 * A conversation with the coach, as listed on Coaching History. Duration is
 * derived from the two timestamps rather than stored, so it cannot drift, and
 * `messageCount` is counted from `chat_messages` rather than kept on the row.
 */
export interface CoachingSessionDocument {
  startedAt: Date;

  /** Null while the conversation is still open. */
  endedAt: Date | null;

  /** The one-line summary shown in the list. */
  summary: LocalizedText;

  principle: Principle;
  messageCount: number;
}

export interface CoachingSessionResult {
  id: string;
  startedAt: string;
  endedAt: string | null;
  summary: LocalizedText;
  principle: Principle;
  messageCount: number;

  /** Derived from startedAt and endedAt. Dart `durationMinutes`. */
  durationMinutes: number;

  /** Present on session detail, absent from the list. */
  messages?: ChatMessageResult[];
}

export function sessionDurationMinutes(
  startedAt: Date,
  endedAt: Date | null,
): number {
  if (endedAt === null) {
    return 0;
  }
  const elapsedMs = endedAt.getTime() - startedAt.getTime();
  return Math.max(0, Math.round(elapsedMs / 60_000));
}
