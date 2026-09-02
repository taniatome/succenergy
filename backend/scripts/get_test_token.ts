/**
 * Prints a Firebase ID token for the test user, so authenticated endpoints
 * can be exercised with curl before the Flutter side is wired up.
 *
 *   npm run token
 *   TOKEN=$(npm run --silent token)
 *   curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8787/v1/me
 *
 * An account with no profile document yet answers 404 profile_not_found there;
 * `curl -X POST .../v1/me` with the same token creates one.
 *
 * Emulator only, and it refuses to run otherwise. The Auth emulator's REST
 * endpoints accept any string as the Web API key, so no real key is needed
 * and none is stored — the placeholder below is not a credential.
 *
 * Credentials come from TEST_USER_EMAIL and TEST_USER_PASSWORD in .env, whose
 * names alone are in .env.example.
 */

import { config as loadDotenv } from 'dotenv';

loadDotenv();

/** Not a credential: the Auth emulator ignores the key entirely. */
const EMULATOR_API_KEY = 'any-string-works-against-the-emulator';

function fail(message: string): never {
  console.error(`\n${message}\n`);
  process.exit(1);
}

const rawAuthHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const rawProjectId = process.env.FIREBASE_PROJECT_ID ?? process.env.GCP_PROJECT_ID;
const rawEmail = process.env.TEST_USER_EMAIL;
const rawPassword = process.env.TEST_USER_PASSWORD;

if (!rawAuthHost) {
  fail(
    [
      'FIREBASE_AUTH_EMULATOR_HOST is not set.',
      '',
      'This script only ever talks to the Auth emulator — it will not mint a',
      'token against a real project. Start the emulators with',
      '`npm run emulators`, then set FIREBASE_AUTH_EMULATOR_HOST in .env.',
    ].join('\n'),
  );
}

if (!rawProjectId) {
  fail('FIREBASE_PROJECT_ID is not set. Copy .env.example to .env and fill it in.');
}

if (!rawEmail || !rawPassword) {
  fail(
    [
      'TEST_USER_EMAIL and TEST_USER_PASSWORD must both be set in .env.',
      '',
      'These are emulator-only credentials for a throwaway account. Never put',
      'a real user password here.',
    ].join('\n'),
  );
}

// Re-declared as plain strings after the guards above: narrowing from an
// outer-scope check does not reach inside a function body, and every one of
// these is read from one.
const authHost: string = rawAuthHost;
const projectId: string = rawProjectId;
const email: string = rawEmail;
const password: string = rawPassword;

/** The emulator's Identity Toolkit endpoints, keyed off the emulator host. */
const identityBase = `http://${authHost}/identitytoolkit.googleapis.com/v1`;

interface IdentityToolkitResponse {
  idToken?: string;
  localId?: string;
  error?: { message?: string };
}

async function callIdentityToolkit(
  path: string,
  body: Record<string, unknown>,
): Promise<IdentityToolkitResponse> {
  const response = await fetch(`${identityBase}/${path}?key=${EMULATOR_API_KEY}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      // The emulator scopes accounts by project; without this the request
      // lands in a different project's user pool than the API reads from.
      'X-Firebase-AuthUser-Project': projectId,
    },
    body: JSON.stringify({ ...body, returnSecureToken: true }),
  });

  const payload = (await response.json()) as IdentityToolkitResponse;

  if (!response.ok) {
    const reason = payload.error?.message ?? `HTTP ${response.status}`;
    throw new Error(reason);
  }

  return payload;
}

/**
 * Signs in, creating the account first if it is not there.
 *
 * Sign-in first rather than create-then-sign-in, so re-running the script on
 * an existing emulator does not reset the account and orphan its data.
 */
async function getIdToken(): Promise<{ idToken: string; uid: string; created: boolean }> {
  try {
    const signedIn = await callIdentityToolkit('accounts:signInWithPassword', {
      email,
      password,
    });
    if (signedIn.idToken && signedIn.localId) {
      return { idToken: signedIn.idToken, uid: signedIn.localId, created: false };
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    const unknownAccount =
      message.includes('EMAIL_NOT_FOUND') ||
      message.includes('INVALID_LOGIN_CREDENTIALS') ||
      message.includes('USER_NOT_FOUND');

    if (!unknownAccount) {
      throw error;
    }
  }

  const created = await callIdentityToolkit('accounts:signUp', { email, password });
  if (!created.idToken || !created.localId) {
    throw new Error('Emulator returned no token for the newly created account');
  }

  return { idToken: created.idToken, uid: created.localId, created: true };
}

try {
  const { idToken, uid, created } = await getIdToken();

  // The token goes to stdout on its own so `$(npm run --silent token)` works;
  // everything a human needs goes to stderr and stays out of the capture.
  console.error(
    [
      '',
      created ? 'Created test account in the Auth emulator.' : 'Signed in test account.',
      `  uid:     ${uid}`,
      `  project: ${projectId}`,
      `  expires: 1 hour`,
      '',
      'Try it:',
      `  curl -H "Authorization: Bearer <token>" http://127.0.0.1:8787/v1/me`,
      '',
    ].join('\n'),
  );

  console.log(idToken);
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  fail(
    [
      `Could not get a token from the Auth emulator: ${message}`,
      '',
      `Is it running? Expected at http://${authHost}`,
      'Start it with: npm run emulators',
    ].join('\n'),
  );
}
