import { purposeRepository } from '../repositories/purpose.repository.js';
import type {
  PurposeAnswerRecord,
  PurposeRepository,
} from '../repositories/purpose.repository.js';
import type { LocalizedText } from '../models/localized_text.model.js';
import type { Caller } from './caller.js';

/** One answer as the API sends it. */
export interface PurposeAnswerResult {
  promptId: string;
  answer: LocalizedText;
  updatedAt: string;
}

function toResult(record: PurposeAnswerRecord): PurposeAnswerResult {
  return {
    promptId: record.promptId,
    answer: record.answer,
    updatedAt: record.updatedAt.toISOString(),
  };
}

/**
 * The Purpose section's standing prompts.
 *
 * A list rather than an object keyed by prompt id: the ids are localisation
 * keys containing dots, and a JSON object keyed by them is awkward to type on
 * both sides. The app builds its own map from this.
 */
export class PurposeService {
  private readonly answers: PurposeRepository;

  constructor(answers: PurposeRepository = purposeRepository) {
    this.answers = answers;
  }

  async list(caller: Caller): Promise<PurposeAnswerResult[]> {
    const records = await this.answers.list(caller.uid);
    return records.map(toResult);
  }

  async save(
    caller: Caller,
    promptId: string,
    answer: string,
  ): Promise<PurposeAnswerResult> {
    const saved = await this.answers.upsert(caller.uid, promptId, answer);
    return toResult(saved);
  }
}

export const purposeService = new PurposeService();
