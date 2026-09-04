import type { Request, Response } from 'express';

import {
  createExerciseSchema,
  directoryQuerySchema,
  reorderSchema,
  updateExerciseSchema,
} from '../schemas/admin.schema.js';
import { broadcastSchema } from '../schemas/notification.schema.js';
import { adminService } from '../services/admin.service.js';
import { notificationRepository } from '../repositories/notification.repository.js';

/** HTTP layer only. Every route reaching here is already behind requireAdmin. */

/** GET /v1/admin/users */
export async function listUsers(req: Request, res: Response): Promise<void> {
  const request = directoryQuerySchema.parse(req.query);
  const page = await adminService.listUsers(request);
  res.json({ data: page.users, meta: { nextCursor: page.nextCursor } });
}

/** GET /v1/admin/users/:uid */
export async function getUser(req: Request, res: Response): Promise<void> {
  const user = await adminService.getUser(req.params.uid ?? '');
  res.json({ data: user });
}

/** DELETE /v1/admin/users/:uid */
export async function deleteUser(req: Request, res: Response): Promise<void> {
  const result = await adminService.deleteUser(req.params.uid ?? '');
  res.json({ data: { deleted: true, documentsDeleted: result.documentsDeleted } });
}

/** GET /v1/admin/exercises */
export async function listExercises(_req: Request, res: Response): Promise<void> {
  const exercises = await adminService.listExercises();
  res.json({ data: exercises });
}

/** POST /v1/admin/exercises */
export async function createExercise(req: Request, res: Response): Promise<void> {
  const input = createExerciseSchema.parse(req.body);
  const exercise = await adminService.createExercise(input);
  res.status(201).json({ data: exercise });
}

/** PATCH /v1/admin/exercises/:exerciseId */
export async function updateExercise(req: Request, res: Response): Promise<void> {
  const input = updateExerciseSchema.parse(req.body);
  const exercise = await adminService.updateExercise(
    req.params.exerciseId ?? '',
    input,
  );
  res.json({ data: exercise });
}

/**
 * DELETE /v1/admin/exercises/:exerciseId
 *
 * A withdrawal, not a deletion: past responses reference the exercise id with
 * no foreign key precisely so history survives.
 */
export async function deleteExercise(req: Request, res: Response): Promise<void> {
  const exercise = await adminService.deactivateExercise(
    req.params.exerciseId ?? '',
  );
  res.json({ data: exercise });
}

/** PATCH /v1/admin/exercises/:exerciseId/reorder */
export async function reorderExercise(req: Request, res: Response): Promise<void> {
  const { position } = reorderSchema.parse(req.body);
  const exercise = await adminService.reorderExercise(
    req.params.exerciseId ?? '',
    position,
  );
  res.json({ data: exercise });
}

/** GET /v1/admin/stats */
export async function getStats(_req: Request, res: Response): Promise<void> {
  const stats = await adminService.stats();
  res.json({ data: stats });
}

/** POST /v1/admin/notifications */
export async function broadcast(req: Request, res: Response): Promise<void> {
  const input = broadcastSchema.parse(req.body);
  const queued = await notificationRepository.broadcast(input.audience, {
    type: input.type,
    title: input.title,
    body: input.body,
  });
  res.status(201).json({ data: { queued } });
}
