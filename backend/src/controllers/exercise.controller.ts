import type { Request, Response } from 'express';

import { submitExerciseSchema } from '../schemas/exercise.schema.js';
import { exerciseService } from '../services/exercise.service.js';
import { callerFrom } from './user.controller.js';

/** HTTP layer only: parse, delegate, respond. */

/** GET /v1/exercises */
export async function listExercises(_req: Request, res: Response): Promise<void> {
  const exercises = await exerciseService.listLibrary();
  res.json({ data: exercises });
}

/** GET /v1/exercises/:exerciseId */
export async function getExercise(req: Request, res: Response): Promise<void> {
  const exercise = await exerciseService.getExercise(
    req.params.exerciseId ?? '',
  );
  res.json({ data: exercise });
}

/**
 * GET /v1/me/exercise-responses
 *
 * `?exerciseId=` narrows the list to one exercise's history, which is what
 * the library card's "you have done this before" needs.
 */
export async function listResponses(req: Request, res: Response): Promise<void> {
  const filter = req.query.exerciseId;
  const responses = await exerciseService.listResponses(
    callerFrom(req),
    typeof filter === 'string' && filter !== '' ? filter : undefined,
  );
  res.json({ data: responses });
}

/** GET /v1/me/exercise-responses/:responseId */
export async function getResponse(req: Request, res: Response): Promise<void> {
  const response = await exerciseService.getResponse(
    callerFrom(req),
    req.params.responseId ?? '',
  );
  res.json({ data: response });
}

/** POST /v1/me/exercise-responses */
export async function submitExercise(req: Request, res: Response): Promise<void> {
  const input = submitExerciseSchema.parse(req.body);
  const response = await exerciseService.submit(callerFrom(req), input);
  res.status(201).json({ data: response });
}
