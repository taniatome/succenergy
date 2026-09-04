import type { ChatMessageResult } from '../models/chat_message.model.js';
import {
  sessionDurationMinutes,
  type CoachingSessionResult,
} from '../models/coaching_session.model.js';
import { RowNotFoundError } from '../repositories/errors.js';
import { sessionRepository } from '../repositories/session.repository.js';
import type {
  MessageRecord,
  SessionRecord,
  SessionRepository,
} from '../repositories/session.repository.js';
import { userRepository } from '../repositories/user.repository.js';
import type { UserRepository } from '../repositories/user.repository.js';
import type {
  AddMessageInput,
  EndSessionInput,
  StartSessionInput,
} from '../schemas/session.schema.js';
import { ApiError } from '../utils/api_error.js';
import { toIso, type Caller } from './caller.js';

function toMessageResult(record: MessageRecord): ChatMessageResult {
  return {
    id: record.id,
    author: record.author,
    text: record.text,
    sentAt: record.sentAt.toISOString(),
    isCoach: record.author === 'coach',
  };
}

function toSessionResult(
  record: SessionRecord,
  messages?: MessageRecord[],
): CoachingSessionResult {
  const result: CoachingSessionResult = {
    id: record.id,
    startedAt: record.startedAt.toISOString(),
    endedAt: toIso(record.endedAt),
    summary: record.summary,
    principle: record.principle ?? 'purpose',
    messageCount: record.messageCount,
    durationMinutes: sessionDurationMinutes(record.startedAt, record.endedAt),
  };

  if (messages !== undefined) {
    result.messages = messages.map(toMessageResult);
  }
  return result;
}

/**
 * Coaching sessions and their transcripts.
 *
 * The data layer for the AI Coach. A coach message is stored here exactly as
 * a user message is, so the Claude pass adds the call that produces the text
 * and changes nothing about this shape — that is the point of building it now.
 *
 * There is deliberately no reply generated here. An endpoint that returned a
 * canned coach message would have to be found and removed later; one that
 * stores what it is given is already correct.
 */
export class SessionService {
  private readonly sessions: SessionRepository;
  private readonly users: UserRepository;

  constructor(
    sessions: SessionRepository = sessionRepository,
    users: UserRepository = userRepository,
  ) {
    this.sessions = sessions;
    this.users = users;
  }

  async list(caller: Caller): Promise<CoachingSessionResult[]> {
    const records = await this.sessions.list(caller.uid);
    return records.map((record) => toSessionResult(record));
  }

  /** Session detail, transcript included — that is what "detail" means here. */
  async get(caller: Caller, sessionId: string): Promise<CoachingSessionResult> {
    const record = await this.sessions.find(caller.uid, sessionId);
    if (!record) {
      throw ApiError.notFound('Session not found');
    }
    const messages = await this.sessions.messages(caller.uid, sessionId);
    return toSessionResult(record, messages);
  }

  /**
   * Opens a session, or resumes the one already open.
   *
   * The app has one conversation at a time, so a second POST while a session
   * is unfinished returns that session rather than leaving an empty one
   * behind every time the coach screen is opened.
   *
   * The principle defaults to where the person currently sits in the cycle,
   * read from their profile rather than sent by the client — it is the same
   * fact the Dashboard shows and it should not be able to disagree.
   */
  async start(
    caller: Caller,
    input: StartSessionInput = {},
  ): Promise<{ session: CoachingSessionResult; created: boolean }> {
    const open = await this.sessions.findOpen(caller.uid);
    if (open) {
      const messages = await this.sessions.messages(caller.uid, open.id);
      return { session: toSessionResult(open, messages), created: false };
    }

    const principle =
      input.principle ??
      (await this.users.findProfile(caller.uid))?.user.currentPrinciple ??
      null;

    const created = await this.sessions.create(caller.uid, principle);
    return { session: toSessionResult(created, []), created: true };
  }

  async end(
    caller: Caller,
    sessionId: string,
    input: EndSessionInput,
  ): Promise<CoachingSessionResult> {
    return this.guard(async () => {
      const ended = await this.sessions.end(
        caller.uid,
        sessionId,
        input.summary ?? null,
      );
      return toSessionResult(ended);
    });
  }

  async messages(caller: Caller, sessionId: string): Promise<ChatMessageResult[]> {
    // The session read proves ownership before the transcript is returned, so
    // an unknown id 404s rather than answering with an empty conversation.
    await this.guard(() => this.sessions.require(caller.uid, sessionId));
    const records = await this.sessions.messages(caller.uid, sessionId);
    return records.map(toMessageResult);
  }

  /**
   * Appends a message.
   *
   * Stores what it is given, from either author. The Claude pass will call
   * this twice per turn — once for the person, once for the reply it
   * generates — without this endpoint changing.
   */
  async addMessage(
    caller: Caller,
    sessionId: string,
    input: AddMessageInput,
  ): Promise<ChatMessageResult> {
    return this.guard(async () => {
      const stored = await this.sessions.addMessage(
        caller.uid,
        sessionId,
        input.author,
        input.text,
      );
      return toMessageResult(stored);
    });
  }

  private async guard<T>(run: () => Promise<T>): Promise<T> {
    try {
      return await run();
    } catch (cause) {
      if (cause instanceof RowNotFoundError) {
        throw ApiError.notFound('Session not found');
      }
      throw cause;
    }
  }
}

export const sessionService = new SessionService();
