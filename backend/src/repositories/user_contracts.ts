import type { QueryResult, QueryResultRow } from 'pg';

import type { OnboardingResponseDocument } from '../models/onboarding_response.model.js';
import type { SubscriptionDocument } from '../models/subscription.model.js';
import type { UserDocument } from '../models/user.model.js';

/**
 * What the user repository returns, and the one thing it takes.
 *
 * Separated from the queries so a service can import the shape it consumes
 * without pulling in the file that holds the SQL.
 */

/** The joined profile read: the user and the two rows that hang off them. */
export interface UserProfile {
  user: UserDocument;
  onboarding: OnboardingResponseDocument | null;
  subscription: SubscriptionDocument | null;
}

/** A write's result: the row as it now stands, and the subscription beside it. */
export interface UserWriteResult {
  user: UserDocument;
  subscription: SubscriptionDocument | null;
}

/**
 * Anything a parameterised query can be run against.
 *
 * The pool and a transaction client differ in type but not in the one method
 * a read needs, so a helper that must work inside and outside a transaction
 * takes this rather than being written twice.
 */
export interface Queryable {
  query<T extends QueryResultRow>(
    text: string,
    values: readonly unknown[],
  ): Promise<QueryResult<T>>;
}
