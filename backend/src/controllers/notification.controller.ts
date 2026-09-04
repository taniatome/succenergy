import type { Request, Response } from 'express';

import { updatePreferencesSchema } from '../schemas/notification.schema.js';
import { notificationService } from '../services/notification.service.js';
import { callerFrom } from './user.controller.js';

/** GET /v1/me/notifications */
export async function listNotifications(
  req: Request,
  res: Response,
): Promise<void> {
  const caller = callerFrom(req);
  const [items, unread] = await Promise.all([
    notificationService.list(caller),
    notificationService.unreadCount(caller),
  ]);
  res.json({ data: items, meta: { unread } });
}

/** PATCH /v1/me/notifications/read-all */
export async function markAllRead(req: Request, res: Response): Promise<void> {
  const changed = await notificationService.markAllRead(callerFrom(req));
  res.json({ data: { marked: changed } });
}

/** PATCH /v1/me/notifications/:notificationId/read */
export async function markRead(req: Request, res: Response): Promise<void> {
  await notificationService.markRead(
    callerFrom(req),
    req.params.notificationId ?? '',
  );
  res.json({ data: { isRead: true } });
}

/** DELETE /v1/me/notifications/:notificationId */
export async function deleteNotification(
  req: Request,
  res: Response,
): Promise<void> {
  await notificationService.remove(
    callerFrom(req),
    req.params.notificationId ?? '',
  );
  res.json({ data: { deleted: true } });
}

/** GET /v1/me/notification-preferences */
export async function getPreferences(req: Request, res: Response): Promise<void> {
  const preferences = await notificationService.getPreferences(callerFrom(req));
  res.json({ data: preferences });
}

/** PATCH /v1/me/notification-preferences */
export async function updatePreferences(
  req: Request,
  res: Response,
): Promise<void> {
  const input = updatePreferencesSchema.parse(req.body);
  const preferences = await notificationService.updatePreferences(
    callerFrom(req),
    input,
  );
  res.json({ data: preferences });
}
