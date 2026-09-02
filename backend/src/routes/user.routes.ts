import { Router } from 'express';

import {
  createMe,
  deleteMe,
  getMe,
  getOnboarding,
  saveOnboarding,
  updateMe,
} from '../controllers/user.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/**
 * `/v1/me` — the authenticated user's own record.
 *
 * requireAuth is applied to the router rather than to each route, so a route
 * added later cannot be left public by omission. Every handler is wrapped in
 * asyncHandler so a rejected promise reaches the error middleware instead of
 * hanging the request.
 *
 * There is no `/v1/users/:uid`: a caller only ever addresses themselves, and
 * the uid comes from the verified token rather than the path, so one account
 * cannot ask for another's data.
 *
 * `POST /` is the only route here that creates the user document. `GET /` is a
 * pure read, so a retry or a prefetch cannot have a side effect.
 */
export const userRouter = Router();

userRouter.use(requireAuth);

userRouter.get('/', asyncHandler(getMe));
userRouter.post('/', asyncHandler(createMe));
userRouter.patch('/', asyncHandler(updateMe));
userRouter.delete('/', asyncHandler(deleteMe));

userRouter.get('/onboarding', asyncHandler(getOnboarding));
userRouter.post('/onboarding', asyncHandler(saveOnboarding));
