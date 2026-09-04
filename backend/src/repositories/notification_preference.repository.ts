import { query } from '../config/database.js';
import type { CheckInRhythm } from '../models/user.model.js';
import { RowNotFoundError } from './errors.js';

/** The delivery settings behind the inbox, as stored on the user row. */
export interface NotificationPreferenceRecord {
  /** The master switch. */
  remindersEnabled: boolean;

  rhythm: CheckInRhythm;

  /** Localisation key to whether that notification type is switched on. */
  types: Record<string, boolean>;
}

interface PreferenceRow {
  reminders_enabled: boolean;
  rhythm: string;
  notification_preferences: unknown;
}

/** The jsonb column, keeping only boolean entries. */
function toTypes(value: unknown): Record<string, boolean> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    return {};
  }
  const out: Record<string, boolean> = {};
  for (const [key, enabled] of Object.entries(value)) {
    if (typeof enabled === 'boolean') {
      out[key] = enabled;
    }
  }
  return out;
}

/**
 * The per-type switches, which live in `users.notification_preferences`.
 *
 * The master switch and the check-in rhythm are ordinary user columns and are
 * written through the user repository's patch, so the one place that owns a
 * profile column stays the one place. Only the jsonb map is written here.
 */
export class NotificationPreferenceRepository {
  async find(uid: string): Promise<NotificationPreferenceRecord> {
    const { rows } = await query<PreferenceRow>(
      `select reminders_enabled, rhythm, notification_preferences
         from users where id = $1`,
      [uid],
    );

    const row = rows[0];
    if (!row) {
      throw new RowNotFoundError('user', uid);
    }

    return {
      remindersEnabled: row.reminders_enabled,
      rhythm: row.rhythm as CheckInRhythm,
      types: toTypes(row.notification_preferences),
    };
  }

  /**
   * Merges the supplied keys into the stored map, leaving the rest alone.
   *
   * `||` on jsonb is a shallow merge, which is exactly right for a flat map
   * of booleans: turning one switch off must not clear the other four, and
   * writing the whole map from a client that only knows about the switches
   * its version renders would do precisely that.
   */
  async mergeTypes(
    uid: string,
    types: Record<string, boolean>,
  ): Promise<void> {
    const { rowCount } = await query(
      `update users
          set notification_preferences = notification_preferences || $1::jsonb
        where id = $2`,
      [JSON.stringify(types), uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('user', uid);
    }
  }
}

export const notificationPreferenceRepository =
  new NotificationPreferenceRepository();
