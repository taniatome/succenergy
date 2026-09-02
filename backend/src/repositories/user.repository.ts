import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import type {
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  Firestore,
  UpdateData,
} from 'firebase-admin/firestore';

import { firestore } from '../config/firebase.js';
import type { OnboardingResponseDocument } from '../models/onboarding_response.model.js';
import { INITIAL_SUBSCRIPTION } from '../models/subscription.model.js';
import type { SubscriptionDocument } from '../models/subscription.model.js';
import type { UserDocument } from '../models/user.model.js';

/**
 * The only layer that touches Firestore.
 *
 * Nothing above this file imports from firebase-admin/firestore, so the
 * database can be swapped, batched or mocked without a service or controller
 * knowing. Reads return documents as stored — Timestamps and all — and the
 * service maps them for the wire.
 */

/** Collection and document names, in one place so a typo is a compile error. */
export const USERS_COLLECTION = 'users';

/**
 * Subcollections that belong to a user.
 *
 * The cascading delete walks this list, so a subcollection added in a later
 * pass must be added here too. It is a floor rather than the whole story:
 * the delete also lists what is actually present, so a collection written by
 * an older version of the code is still reached.
 */
export const USER_SUBCOLLECTIONS = [
  'onboarding',
  'goals',
  'exerciseResponses',
  'sessions',
  'notifications',
  'subscription',
  'progressSnapshots',
  'purposeAnswers',
  'coachingMemory',
] as const;

export const ONBOARDING_COLLECTION = 'onboarding';
export const ONBOARDING_DOCUMENT = 'response';
export const SUBSCRIPTION_COLLECTION = 'subscription';
export const SUBSCRIPTION_DOCUMENT = 'current';

/** Firestore rejects batches over 500 writes. */
const BATCH_LIMIT = 400;

/** Documents pulled per page while walking a subcollection to delete it. */
const DELETE_PAGE_SIZE = 200;

/** Raised when a uid has no user document. Mapped to a 404 by the service. */
export class UserNotFoundError extends Error {
  readonly uid: string;

  constructor(uid: string) {
    super('User document not found');
    this.name = 'UserNotFoundError';
    this.uid = uid;
  }
}

export class UserRepository {
  private readonly db: Firestore;

  constructor(db: Firestore = firestore) {
    this.db = db;
  }

  private userRef(uid: string): DocumentReference {
    return this.db.collection(USERS_COLLECTION).doc(uid);
  }

  async findById(uid: string): Promise<UserDocument | null> {
    const snapshot = await this.userRef(uid).get();
    return snapshot.exists ? (snapshot.data() as UserDocument) : null;
  }

  /**
   * Creates the user document, and the subscription document alongside it, in
   * one atomic write.
   *
   * `create` rather than `set`: two requests arriving together for the same
   * unknown uid must not have the second overwrite the first, and a failed
   * create is a signal the caller can act on rather than silent data loss.
   */
  async create(uid: string, document: UserDocument): Promise<void> {
    const batch = this.db.batch();

    batch.create(this.userRef(uid), document);

    const subscription: SubscriptionDocument = {
      ...INITIAL_SUBSCRIPTION,
      updatedAt: document.createdAt,
    };
    batch.create(
      this.userRef(uid).collection(SUBSCRIPTION_COLLECTION).doc(SUBSCRIPTION_DOCUMENT),
      subscription,
    );

    await batch.commit();
  }

  /**
   * Applies a partial update and returns the document as it now stands.
   *
   * A transaction rather than an update followed by a read: without one, a
   * concurrent write landing between the two would appear in the response as
   * though this call had made it.
   */
  async update(uid: string, patch: UpdateData<UserDocument>): Promise<UserDocument> {
    const ref = this.userRef(uid);

    return this.db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw new UserNotFoundError(uid);
      }

      transaction.update(ref, {
        ...patch,
        updatedAt: FieldValue.serverTimestamp(),
      } as UpdateData<UserDocument>);

      // The write has not committed yet, so the snapshot above is pre-update.
      // Merging locally avoids a second round trip for a value we already
      // know; the returned updatedAt is this instant rather than the exact
      // server timestamp, which is close enough for a response body.
      const current = snapshot.data() as UserDocument;
      return {
        ...current,
        ...(patch as Partial<UserDocument>),
        updatedAt: Timestamp.now(),
      };
    });
  }

  // --- Onboarding ---------------------------------------------------------

  private onboardingRef(uid: string): DocumentReference {
    return this.userRef(uid).collection(ONBOARDING_COLLECTION).doc(ONBOARDING_DOCUMENT);
  }

  async findOnboarding(uid: string): Promise<OnboardingResponseDocument | null> {
    const snapshot: DocumentSnapshot = await this.onboardingRef(uid).get();
    return snapshot.exists ? (snapshot.data() as OnboardingResponseDocument) : null;
  }

  /**
   * Writes the onboarding response, replacing any previous one.
   *
   * The assessment is submitted whole from the summary screen and is editable
   * afterwards from Profile, so a full replace is the correct semantic — a
   * merge would leave a removed focus area in place.
   */
  async saveOnboarding(uid: string, document: OnboardingResponseDocument): Promise<void> {
    await this.onboardingRef(uid).set(document);
  }

  // --- Deletion -----------------------------------------------------------

  /**
   * Deletes the user document and everything beneath it.
   *
   * Firestore does not cascade: deleting a document leaves its subcollections
   * in place, reachable by direct path and invisible to a collection listing.
   * So every subcollection is walked explicitly, including the nested
   * messages under each session, and the user document is deleted last — if
   * the process dies partway the account still resolves and the delete can be
   * retried, rather than leaving unreachable orphans behind.
   *
   * Returns how many documents were removed, which makes the operation
   * auditable without logging anything that was in them.
   */
  async deleteAllData(uid: string): Promise<{ documentsDeleted: number }> {
    const userRef = this.userRef(uid);
    let documentsDeleted = 0;

    // The declared list plus whatever is actually present, so a collection
    // written by an older version of the code is not left behind.
    const present = await userRef.listCollections();
    const names = new Set<string>([
      ...USER_SUBCOLLECTIONS,
      ...present.map((collection) => collection.id),
    ]);

    for (const name of names) {
      documentsDeleted += await this.deleteCollection(userRef.collection(name));
    }

    await userRef.delete();
    documentsDeleted += 1;

    return { documentsDeleted };
  }

  /**
   * Deletes a collection page by page, descending into each document's own
   * subcollections first.
   *
   * Paged rather than read whole: a user with a long coaching history would
   * otherwise be held in memory in full, and the batch limit has to be
   * respected either way.
   */
  private async deleteCollection(collection: CollectionReference): Promise<number> {
    let deleted = 0;

    for (;;) {
      const snapshot = await collection.limit(DELETE_PAGE_SIZE).get();
      if (snapshot.empty) {
        return deleted;
      }

      // Depth first: a document's children must go before the document
      // itself, or deleting the parent strands them.
      for (const doc of snapshot.docs) {
        const children = await doc.ref.listCollections();
        for (const child of children) {
          deleted += await this.deleteCollection(child);
        }
      }

      let batch = this.db.batch();
      let queued = 0;

      for (const doc of snapshot.docs) {
        batch.delete(doc.ref);
        queued += 1;

        if (queued === BATCH_LIMIT) {
          await batch.commit();
          deleted += queued;
          batch = this.db.batch();
          queued = 0;
        }
      }

      if (queued > 0) {
        await batch.commit();
        deleted += queued;
      }

      // A short page means the collection is exhausted; another query would
      // only confirm what this one already showed.
      if (snapshot.size < DELETE_PAGE_SIZE) {
        return deleted;
      }
    }
  }
}

export const userRepository = new UserRepository();
