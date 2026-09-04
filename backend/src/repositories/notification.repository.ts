import { query } from '../config/database.js';
import type { LocalizedText } from '../models/localized_text.model.js';
import type { NotificationType } from '../models/notification.model.js';
import { RowNotFoundError } from './errors.js';
import { localizedOwn } from './row_mappers.js';

interface NotificationRow {
  id: string;
  type: string;
  title: string | null;
  body: string | null;
  is_read: boolean;
  received_at: Date;
}

/** A notification as the repository returns it. */
export interface NotificationRecord {
  id: string;
  type: NotificationType;
  title: LocalizedText;
  body: LocalizedText;
  isRead: boolean;
  receivedAt: Date;
}

/** What a queued notification carries. Written by the admin console. */
export interface NotificationInput {
  type: NotificationType;
  title: string;
  body: string;
}

const NOTIFICATION_COLUMNS = 'id, type, title, body, is_read, received_at';

function toRecord(row: NotificationRow): NotificationRecord {
  return {
    id: row.id,
    type: row.type as NotificationType,
    title: localizedOwn(row.title),
    body: localizedOwn(row.body),
    isRead: row.is_read,
    receivedAt: row.received_at,
  };
}

/**
 * The `notifications` table — the inbox.
 *
 * Per-user, so every statement carries the uid: a notification id from a URL
 * is never enough to read or change one.
 */
export class NotificationRepository {
  /**
   * The inbox: unread first, then read, each group newest first.
   *
   * Ordered in the database rather than the client, because "unread first"
   * is what the screen shows and sorting it twice is how the two drift.
   */
  async list(uid: string): Promise<NotificationRecord[]> {
    const { rows } = await query<NotificationRow>(
      `select ${NOTIFICATION_COLUMNS} from notifications
        where user_id = $1
        order by is_read, received_at desc`,
      [uid],
    );
    return rows.map(toRecord);
  }

  async markRead(uid: string, notificationId: string): Promise<void> {
    const { rowCount } = await query(
      'update notifications set is_read = true where id = $1 and user_id = $2',
      [notificationId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('notification', notificationId);
    }
  }

  /** Returns how many were still unread, so the caller can report it. */
  async markAllRead(uid: string): Promise<number> {
    const { rowCount } = await query(
      'update notifications set is_read = true where user_id = $1 and not is_read',
      [uid],
    );
    return rowCount ?? 0;
  }

  async remove(uid: string, notificationId: string): Promise<void> {
    const { rowCount } = await query(
      'delete from notifications where id = $1 and user_id = $2',
      [notificationId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('notification', notificationId);
    }
  }

  async unreadCount(uid: string): Promise<number> {
    const { rows } = await query<{ total: string }>(
      'select count(*) as total from notifications where user_id = $1 and not is_read',
      [uid],
    );
    return Number(rows[0]?.total ?? '0');
  }

  /**
   * Queues one notification per account in the audience.
   *
   * `insert … select` rather than a loop: the audience is a set of rows the
   * database already has, so it fans out in one statement and either every
   * recipient gets it or none does.
   *
   * `audience` is a fixed set of names, not a fragment of SQL — the branch
   * below chooses between whole statements, so nothing a caller sends is ever
   * concatenated into one.
   */
  async broadcast(
    audience: 'all' | 'trial' | 'paying',
    input: NotificationInput,
  ): Promise<number> {
    const values = [input.type, input.title, input.body];

    if (audience === 'all') {
      const { rowCount } = await query(
        `insert into notifications (user_id, type, title, body)
         select u.id, $1, $2, $3 from users u`,
        values,
      );
      return rowCount ?? 0;
    }

    const status =
      audience === 'trial'
        ? ['none', 'trialing']
        : ['active', 'trialing', 'past_due'];

    const { rowCount } = await query(
      `insert into notifications (user_id, type, title, body)
       select u.id, $1, $2, $3
         from users u
         join subscriptions s on s.user_id = u.id
        where s.status = any($4::text[])`,
      [...values, status],
    );
    return rowCount ?? 0;
  }
}

export const notificationRepository = new NotificationRepository();
