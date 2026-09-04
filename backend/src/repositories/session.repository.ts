import { query } from '../config/database.js';
import type { MessageAuthor } from '../models/chat_message.model.js';
import type { LocalizedText } from '../models/localized_text.model.js';
import type { Principle } from '../models/principle.model.js';
import { RowNotFoundError } from './errors.js';
import { countOf, localizedOwn } from './row_mappers.js';

interface SessionRow {
  id: string;
  started_at: Date;
  ended_at: Date | null;
  summary: string | null;
  principle: string | null;
  message_count?: string;
}

interface MessageRow {
  id: string;
  author: string;
  text: string;
  sent_at: Date;
}

/** A session as the repository returns it. */
export interface SessionRecord {
  id: string;
  startedAt: Date;
  endedAt: Date | null;
  summary: LocalizedText;
  principle: Principle | null;
  messageCount: number;
}

/** One message in a transcript. */
export interface MessageRecord {
  id: string;
  author: MessageAuthor;
  text: LocalizedText;
  sentAt: Date;
}

function toSessionRecord(row: SessionRow): SessionRecord {
  return {
    id: row.id,
    startedAt: row.started_at,
    endedAt: row.ended_at,
    summary: localizedOwn(row.summary),
    principle: row.principle === null ? null : (row.principle as Principle),
    messageCount: countOf(row.message_count),
  };
}

function toMessageRecord(row: MessageRow): MessageRecord {
  return {
    id: row.id,
    author: row.author as MessageAuthor,
    text: localizedOwn(row.text),
    sentAt: row.sent_at,
  };
}

/**
 * The `coaching_sessions` and `chat_messages` tables.
 *
 * The data layer for the AI Coach, built now so the Claude pass only has to
 * add the call that generates a reply. Nothing here knows what a coach
 * message contains — a stub reply and a real one are the same insert.
 *
 * `message_count` is counted rather than stored, so it cannot drift from the
 * transcript it describes.
 */
export class SessionRepository {
  /** Sessions newest first, with their message counts but not their messages. */
  async list(uid: string): Promise<SessionRecord[]> {
    const { rows } = await query<SessionRow>(
      `select s.id, s.started_at, s.ended_at, s.summary, s.principle,
              (select count(*) from chat_messages m where m.session_id = s.id)
                as message_count
         from coaching_sessions s
        where s.user_id = $1
        order by s.started_at desc`,
      [uid],
    );
    return rows.map(toSessionRecord);
  }

  async find(uid: string, sessionId: string): Promise<SessionRecord | null> {
    const { rows } = await query<SessionRow>(
      `select s.id, s.started_at, s.ended_at, s.summary, s.principle,
              (select count(*) from chat_messages m where m.session_id = s.id)
                as message_count
         from coaching_sessions s
        where s.id = $1 and s.user_id = $2`,
      [sessionId, uid],
    );

    const row = rows[0];
    return row ? toSessionRecord(row) : null;
  }

  /**
   * The session still open, if there is one.
   *
   * The app has one conversation at a time, so opening the coach resumes the
   * unfinished session rather than starting a third alongside two others.
   */
  async findOpen(uid: string): Promise<SessionRecord | null> {
    const { rows } = await query<SessionRow>(
      `select s.id, s.started_at, s.ended_at, s.summary, s.principle,
              (select count(*) from chat_messages m where m.session_id = s.id)
                as message_count
         from coaching_sessions s
        where s.user_id = $1 and s.ended_at is null
        order by s.started_at desc
        limit 1`,
      [uid],
    );

    const row = rows[0];
    return row ? toSessionRecord(row) : null;
  }

  async create(uid: string, principle: Principle | null): Promise<SessionRecord> {
    const { rows } = await query<SessionRow>(
      `insert into coaching_sessions (user_id, principle)
       values ($1, $2)
       returning id, started_at, ended_at, summary, principle`,
      [uid, principle],
    );

    const row = rows[0];
    if (!row) {
      throw new RowNotFoundError('coaching_session', 'inserted');
    }
    return toSessionRecord(row);
  }

  /**
   * Closes a session.
   *
   * `ended_at` is only ever set once: the `is null` in the `where` makes a
   * repeated end a no-op rather than moving the timestamp, which would make
   * the derived duration grow every time the call was retried.
   */
  async end(
    uid: string,
    sessionId: string,
    summary: string | null,
  ): Promise<SessionRecord> {
    const { rowCount } = await query(
      `update coaching_sessions
          set ended_at = now(), summary = coalesce($1, summary)
        where id = $2 and user_id = $3 and ended_at is null`,
      [summary, sessionId, uid],
    );

    if (rowCount === 0) {
      const existing = await this.find(uid, sessionId);
      if (!existing) {
        throw new RowNotFoundError('coaching_session', sessionId);
      }
      return existing;
    }

    return this.require(uid, sessionId);
  }

  async require(uid: string, sessionId: string): Promise<SessionRecord> {
    const found = await this.find(uid, sessionId);
    if (!found) {
      throw new RowNotFoundError('coaching_session', sessionId);
    }
    return found;
  }

  // --- Messages -----------------------------------------------------------

  /**
   * A transcript, oldest first. Ownership comes from the join, not the id:
   * `chat_messages` has no `user_id`, so the session it belongs to supplies it.
   */
  async messages(uid: string, sessionId: string): Promise<MessageRecord[]> {
    const { rows } = await query<MessageRow>(
      `select m.id, m.author, m.text, m.sent_at
         from chat_messages m
         join coaching_sessions s on s.id = m.session_id
        where m.session_id = $1 and s.user_id = $2
        order by m.sent_at`,
      [sessionId, uid],
    );
    return rows.map(toMessageRecord);
  }

  async addMessage(
    uid: string,
    sessionId: string,
    author: MessageAuthor,
    text: string,
  ): Promise<MessageRecord> {
    const { rows } = await query<MessageRow>(
      `insert into chat_messages (session_id, author, text)
       select $1, $2, $3
        where exists (
          select 1 from coaching_sessions s
           where s.id = $1 and s.user_id = $4
        )
       returning id, author, text, sent_at`,
      [sessionId, author, text, uid],
    );

    const row = rows[0];
    if (!row) {
      throw new RowNotFoundError('coaching_session', sessionId);
    }
    return toMessageRecord(row);
  }
}

export const sessionRepository = new SessionRepository();
