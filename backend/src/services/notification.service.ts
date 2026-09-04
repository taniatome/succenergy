import type { NotificationResult } from '../models/notification.model.js';
import { RowNotFoundError } from '../repositories/errors.js';
import { notificationPreferenceRepository } from '../repositories/notification_preference.repository.js';
import type { NotificationPreferenceRepository } from '../repositories/notification_preference.repository.js';
import { notificationRepository } from '../repositories/notification.repository.js';
import type {
  NotificationRecord,
  NotificationRepository,
} from '../repositories/notification.repository.js';
import type { UpdatePreferencesInput } from '../schemas/notification.schema.js';
import { ApiError } from '../utils/api_error.js';
import type { Caller } from './caller.js';
import { userService } from './user.service.js';
import type { UserService } from './user.service.js';

/** The delivery settings as the API sends them. */
export interface PreferenceResult {
  remindersEnabled: boolean;
  rhythm: string;
  types: Record<string, boolean>;
}

function toResult(record: NotificationRecord): NotificationResult {
  return {
    id: record.id,
    type: record.type,
    title: record.title,
    body: record.body,
    receivedAt: record.receivedAt.toISOString(),
    isRead: record.isRead,
  };
}

/**
 * The notification inbox and the preferences behind it.
 *
 * The master switch and the check-in rhythm are ordinary profile fields, so
 * changing them here goes through the user service's own patch rather than a
 * second write path — one place owns a profile column. Only the per-type map
 * is this service's to write.
 */
export class NotificationService {
  private readonly inbox: NotificationRepository;
  private readonly preferences: NotificationPreferenceRepository;
  private readonly profiles: UserService;

  constructor(
    inbox: NotificationRepository = notificationRepository,
    preferences: NotificationPreferenceRepository = notificationPreferenceRepository,
    profiles: UserService = userService,
  ) {
    this.inbox = inbox;
    this.preferences = preferences;
    this.profiles = profiles;
  }

  // --- Inbox --------------------------------------------------------------

  async list(caller: Caller): Promise<NotificationResult[]> {
    const records = await this.inbox.list(caller.uid);
    return records.map(toResult);
  }

  async markRead(caller: Caller, notificationId: string): Promise<void> {
    await this.guard('Notification not found', () =>
      this.inbox.markRead(caller.uid, notificationId),
    );
  }

  /** Answers with how many were still unread, so the badge can be trusted. */
  async markAllRead(caller: Caller): Promise<number> {
    return this.inbox.markAllRead(caller.uid);
  }

  async remove(caller: Caller, notificationId: string): Promise<void> {
    await this.guard('Notification not found', () =>
      this.inbox.remove(caller.uid, notificationId),
    );
  }

  async unreadCount(caller: Caller): Promise<number> {
    return this.inbox.unreadCount(caller.uid);
  }

  // --- Preferences --------------------------------------------------------

  async getPreferences(caller: Caller): Promise<PreferenceResult> {
    const record = await this.guard('User profile not found', () =>
      this.preferences.find(caller.uid),
    );
    return record;
  }

  /**
   * Applies a preference patch.
   *
   * The two profile fields go through the user service; the per-type map is
   * merged rather than replaced, so a client that only renders three of the
   * five switches cannot clear the two it has never heard of.
   */
  async updatePreferences(
    caller: Caller,
    input: UpdatePreferencesInput,
  ): Promise<PreferenceResult> {
    const profileFields: Record<string, unknown> = {};

    if (input.remindersEnabled !== undefined) {
      profileFields.remindersEnabled = input.remindersEnabled;
    }
    if (input.rhythm !== undefined) {
      profileFields.rhythm = input.rhythm;
    }

    if (Object.keys(profileFields).length > 0) {
      await this.profiles.updateProfile(caller, {
        coachingPreferences: profileFields,
      });
    }

    if (input.types !== undefined && Object.keys(input.types).length > 0) {
      await this.guard('User profile not found', () =>
        this.preferences.mergeTypes(caller.uid, input.types ?? {}),
      );
    }

    return this.getPreferences(caller);
  }

  private async guard<T>(message: string, run: () => Promise<T>): Promise<T> {
    try {
      return await run();
    } catch (cause) {
      if (cause instanceof RowNotFoundError) {
        throw ApiError.notFound(message);
      }
      throw cause;
    }
  }
}

export const notificationService = new NotificationService();
