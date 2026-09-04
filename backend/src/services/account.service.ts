import { auth } from '../config/firebase.js';
import { logger } from '../config/logger.js';
import { accountRepository } from '../repositories/account.repository.js';
import type { AccountRepository } from '../repositories/account.repository.js';
import { ApiError } from '../utils/api_error.js';
import type { Caller } from './caller.js';

/**
 * Account deletion — the one operation that spans both Firebase Auth and the
 * database, which is why it is not on the user service.
 */
export class AccountService {
  private readonly accounts: AccountRepository;

  constructor(accounts: AccountRepository = accountRepository) {
    this.accounts = accounts;
  }

  /**
   * Deletes the account and everything belonging to it.
   *
   * Order is deliberate. The database first, because that is where the
   * coaching memory the client's checklist names lives and it is the part
   * that must not survive; the Auth record second, which revokes every
   * outstanding token and makes the deletion take effect immediately rather
   * than at the next token expiry.
   *
   * If the delete fails, the Auth record is left alone so the user can still
   * authenticate and retry. If the Auth deletion fails after the data is
   * gone, that is reported as a partial failure rather than a success: an
   * Auth record with no data behind it would let the next request create a
   * fresh empty profile and look like the delete had not run.
   */
  async deleteAccount(caller: Caller): Promise<{ documentsDeleted: number }> {
    let result: { documentsDeleted: number };

    try {
      result = await this.accounts.deleteAllData(caller.uid);
    } catch (cause) {
      logger.error({ uid: caller.uid, err: cause }, 'Failed to delete user data');
      throw ApiError.internal('Could not delete account data', cause);
    }

    try {
      await auth.deleteUser(caller.uid);
    } catch (cause) {
      logger.error(
        { uid: caller.uid, err: cause },
        'User data deleted but auth record remains',
      );
      throw new ApiError(
        500,
        'partial_deletion',
        'Account data was deleted but the sign-in record could not be removed. Please retry.',
        { cause },
      );
    }

    logger.info(
      { uid: caller.uid, documentsDeleted: result.documentsDeleted },
      'Deleted account and all data',
    );

    return result;
  }
}

export const accountService = new AccountService();
