import { Router } from 'express';

import {
  deleteNotification,
  getPreferences,
  listNotifications,
  markAllRead,
  markRead,
  updatePreferences,
} from '../controllers/notification.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/** `/v1/me/notifications` — the caller's inbox. */
export const notificationRouter = Router();

notificationRouter.use(requireAuth);

notificationRouter.get('/', asyncHandler(listNotifications));

// Before `/:notificationId/read`, so the literal segment is not captured as
// an id by the parameterised route below it.
notificationRouter.patch('/read-all', asyncHandler(markAllRead));

notificationRouter.patch('/:notificationId/read', asyncHandler(markRead));
notificationRouter.delete('/:notificationId', asyncHandler(deleteNotification));

/** `/v1/me/notification-preferences` — how and whether they are delivered. */
export const notificationPreferenceRouter = Router();

notificationPreferenceRouter.use(requireAuth);

notificationPreferenceRouter.get('/', asyncHandler(getPreferences));
notificationPreferenceRouter.patch('/', asyncHandler(updatePreferences));
