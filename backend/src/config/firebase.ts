import { applicationDefault, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import type { App } from 'firebase-admin/app';
import type { Auth } from 'firebase-admin/auth';

import { env, isEmulated } from './env.js';

/**
 * Firebase Admin, for authentication only.
 *
 * Firebase's role in this service is now token verification and, later, FCM.
 * Application data lives in Postgres — see `config/database.ts`.
 *
 * When FIREBASE_AUTH_EMULATOR_HOST is set the Admin SDK routes to the
 * emulator on its own and accepts any project id with no credentials, so
 * initialising with the project id alone is enough.
 *
 * When it is absent we use Application Default Credentials: the attached
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

export const auth: Auth = getAuth(app);

export { app as firebaseApp };
