import { applicationDefault, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import type { App } from 'firebase-admin/app';
import type { Auth } from 'firebase-admin/auth';
import type { Firestore } from 'firebase-admin/firestore';

import { env, isEmulated } from './env.js';

/**
 * The one place in the codebase that knows whether we are emulated.
 *
 * When FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST are set the
 * Admin SDK routes to the emulators on its own and accepts any project id
 * with no credentials, so initialising with the project id alone is enough.
 *
 * When they are absent we use Application Default Credentials: the attached
 * service account on Cloud Run, and `gcloud auth application-default login`
 * locally. Nothing below this file branches on environment.
 */
function createApp(): App {
  const existing = getApps()[0];
  if (existing) {
    return existing;
  }

  if (isEmulated) {
    return initializeApp({ projectId: env.FIREBASE_PROJECT_ID });
  }

  return initializeApp({
    credential: applicationDefault(),
    projectId: env.FIREBASE_PROJECT_ID,
  });
}

const app = createApp();

export const firestore: Firestore = getFirestore(app);
export const auth: Auth = getAuth(app);

// Undefined properties are dropped rather than throwing, so a PATCH that
// omits a field does not have to be pruned by hand at every call site.
firestore.settings({ ignoreUndefinedProperties: true });

export { app as firebaseApp };

/**
 * Round-trips a single read so /v1/health/ready can report Firestore
 * connectivity rather than guessing from process state.
 */
export async function checkFirestoreConnectivity(): Promise<void> {
  await firestore.collection('_health').doc('probe').get();
}
