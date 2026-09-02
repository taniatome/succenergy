# Succenergy AI Coach — Backend

The API behind the Succenergy AI Coach app. TypeScript and Express on Cloud
Run, Firestore for application data, Firebase Auth for authentication, and
Google Secret Manager for every secret.

Built and verified against the **Firebase Local Emulator Suite**. Billing is
now attached to the GCP project and Firestore exists in **`nam5`** (US
multi-region), so nothing about the project blocks a deploy any more — but
**nothing has been deployed**. The machine this was built on has no `gcloud`
CLI and no working Docker daemon, and the Firebase account signed in on it has
read-only access to the project. See
[Deploying to Cloud Run](#deploying-to-cloud-run) for the exact sequence, the
confirmed region, and the IAM roles needed to run it.

---

## Contents

- [Quick start](#quick-start)
- [Running the emulators](#running-the-emulators)
- [Running the server](#running-the-server)
- [Getting a token for curl](#getting-a-token-for-curl)
- [Seeding the test persona](#seeding-the-test-persona)
- [Endpoints](#endpoints)
- [Environment variables](#environment-variables)
- [The layer rule](#the-layer-rule)
- [Project structure](#project-structure)
- [Firestore data model](#firestore-data-model)
- [Field naming: where this differs from the brief](#field-naming-where-this-differs-from-the-brief)
- [Enum wire values](#enum-wire-values)
- [Firestore rules and indexes](#firestore-rules-and-indexes)
- [Secrets](#secrets)
- [Security decisions](#security-decisions)
- [Docker](#docker)
- [Deploying to Cloud Run](#deploying-to-cloud-run)
- [What is not built yet](#what-is-not-built-yet)

---

## Quick start

You need **Node 22+**, **Java 11+** (the Firestore emulator is a Java process)
and **Docker** only if you want to build the image.

```bash
cd backend
npm install
cp .env.example .env      # then fill it in — see Environment variables
```

Then, in **two terminals**:

```bash
# Terminal 1 — the emulators. Leave this running.
npm run emulators

# Terminal 2 — the API
npm run dev
```

Check it:

```bash
curl http://127.0.0.1:8787/v1/health
curl http://127.0.0.1:8787/v1/health/ready
```

`/v1/health/ready` round-trips a Firestore read, so a 200 there means the
emulators and the API found each other.

### Scripts

| Script | What it does |
| --- | --- |
| `npm run dev` | API with reload, reading `.env` |
| `npm run dev:emulated` | Same, but forces both emulator hosts regardless of `.env` |
| `npm run emulators` | Auth + Firestore emulators and the emulator UI |
| `npm run seed` | Writes the test persona into the Firestore emulator |
| `npm run token` | Prints a Firebase ID token for the test user |
| `npm run build` | Compiles TypeScript to `dist/` |
| `npm start` | Runs the compiled output (what the container does) |
| `npm run lint` | ESLint, type-aware, zero warnings tolerated |
| `npm run typecheck` | `tsc --noEmit` over `src/` and `scripts/` |

---

## Running the emulators

**`npm run emulators` must be running in a second terminal for local
development.** Nothing that touches Firestore or Auth works without it.

| Emulator | Address |
| --- | --- |
| Firestore | `127.0.0.1:8080` |
| Auth | `127.0.0.1:9099` |
| Emulator UI | http://127.0.0.1:4000 |

Ports are pinned in `firebase.json` so the npm scripts, the seed script and
the token script can all assume the same addresses.

The emulator UI at :4000 is the fastest way to see what the API wrote — the
Firestore tab shows documents and subcollections, and the Auth tab shows
accounts.

Emulator data is **in memory** and gone when you stop it. Re-run `npm run
seed` after a restart.

> The local API runs on **8787**, not 8080 — the Firestore emulator holds 8080.
> Cloud Run injects its own `PORT`, so this only matters locally.

---

## Running the server

`npm run dev` uses `tsx watch` and reloads on save.

Boot fails immediately, before the server listens, if the environment is
wrong. `src/config/env.ts` validates everything with Zod at import time and
prints the offending **variable names** — never their values, which may be
credentials:

```
Invalid environment configuration. The server will not start.
  - GCP_PROJECT_ID: GCP_PROJECT_ID is required
  - FIREBASE_PROJECT_ID: FIREBASE_PROJECT_ID is required

Copy backend/.env.example to backend/.env and fill in the values.
```

Two guards beyond presence:

- **The two emulator hosts must be set together.** Half-emulated is the worst
  configuration available — one half of the app reading local data while the
  other authenticates against production.
- **Neither may be set when `NODE_ENV=production`.**

---

## Getting a token for curl

Auth itself — register, log in, reset password — happens **client-side** via
the Firebase Auth SDK. This backend verifies tokens; it does not issue them.
So to exercise an authenticated endpoint before the Flutter side is wired up,
mint a token against the Auth emulator:

```bash
npm run token
```

It prints the token on stdout and everything else on stderr, so you can
capture just the token:

```bash
TOKEN=$(npm run --silent token)
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8787/v1/me
```

On an account that has never had a profile written, that returns
`404 profile_not_found` — `GET /v1/me` does not create anything. Either run
`npm run seed` first, or create the document explicitly:

```bash
curl -X POST http://127.0.0.1:8787/v1/me -H "Authorization: Bearer $TOKEN"
```

The script signs in as `TEST_USER_EMAIL` and creates that account only if it
does not already exist, so re-running it will not reset the account and
strand data seeded under it. Tokens last an hour.

It refuses to run unless `FIREBASE_AUTH_EMULATOR_HOST` is set — it will not
mint a token against a real project.

> The Auth emulator ignores the Web API key entirely, so no real key is needed
> and none is stored. The placeholder string in `scripts/get_test_token.ts` is
> not a credential.

---

## Seeding the test persona

```bash
npm run seed
```

Writes **Marisa Chissano**, the persona from
`lib/data/mock/mock_data.dart`, so the seeded account reads as the same person
the Flutter build demonstrates rather than as unrelated sample rows: three
weeks in, mid-cycle on Praxis, running a brand relaunch, bilingual throughout.

It writes 8 subcollections, ~32 documents and 6 chat messages nested two
levels deep, plus 2 documents in the shared `exercises/` library. Counts in
its report are read back from Firestore, not tallied by the script, so what it
prints is what is actually stored.

The account is keyed to `TEST_USER_EMAIL`, so `npm run token` returns a token
for the seeded uid and `GET /v1/me` returns the persona rather than an empty
profile.

Re-seeding clears what the previous run left first, so a removed goal does not
linger. Like the token script, it refuses to run outside the emulators.

---

## Endpoints

All under `/v1`. Every response is `{ "data": ... }`; every failure is
`{ "error": { "code", "message", "details?", "requestId" } }`.

### Public

| Method | Path | Notes |
| --- | --- | --- |
| `GET` | `/v1/health` | Liveness. Answers from process state alone, so a slow Firestore minute does not get a healthy instance restarted. |
| `GET` | `/v1/health/ready` | Readiness. Round-trips a Firestore read; 503 when it cannot. |

### Authenticated

Send `Authorization: Bearer <Firebase ID token>`.

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `/v1/me` | **First contact.** Creates the user document for the token's uid (201; 200 if it already exists) |
| `GET` | `/v1/me` | Current profile. Read only — `404 profile_not_found` if there is no document yet |
| `PATCH` | `/v1/me` | Update profile fields |
| `DELETE` | `/v1/me` | Delete the account and all data |
| `POST` | `/v1/me/onboarding` | Save the onboarding response (201) |
| `GET` | `/v1/me/onboarding` | Retrieve the onboarding response |

There is deliberately no `/v1/users/:uid`. A caller only ever addresses
themselves and the uid comes from the verified token, not the path, so one
account cannot ask for another's data.

#### `POST /v1/me` creates on first contact

Registration happens client-side against Firebase Auth, so the first
authenticated request is the first this backend hears of an account. `POST`
is how that account gets a document. What registration collected goes in the
**request body**, all of it optional — the verified token alone is enough to
create a profile:

| Field | Type |
| --- | --- |
| `name` | string, 1–80 chars |
| `preferredLanguage` | `en` \| `pt` |
| `activity` | `student_minorities` \| `professional` |
| `dateOfBirth` | ISO 8601 date-time with offset |
| `countryCode` | ISO 3166-1 alpha-2, upper-cased on the way in |
| `acceptedTerms` | boolean |
| `confirmedInfoTrue` | boolean |

Unknown keys are rejected with 422, the same as `PATCH`. `email` is not
accepted: it comes from the verified token, so a client cannot claim an
address it has not proven it owns.

```bash
curl -X POST http://127.0.0.1:8787/v1/me   -H "Authorization: Bearer $TOKEN"   -H "Content-Type: application/json"   -d '{
    "name":              "Ana Marques",
    "preferredLanguage": "pt",
    "activity":          "professional",
    "dateOfBirth":       "1994-03-11T00:00:00Z",
    "countryCode":       "MZ",
    "acceptedTerms":     true,
    "confirmedInfoTrue": true
  }'
```

**201** with the created profile. **200** with the existing profile if the
document is already there — not a 409, and not a second write. The client may
retry a call whose response it never saw, and a retry has to be harmless.

A new account starts on **Purpose**, cycle day 1, streak 0, with the default
coaching preferences (`direct` / `daily` / reminders on).

##### Why a body, and why not `GET`

Registration details used to ride along on `GET /v1/me` as query parameters.
Two things were wrong with that.

**Cloud Run logs the full request URL, query string included.** That happens
at the platform layer, in the request log, outside this application's control
— `request_logger.ts` redaction cannot reach it. Date of birth, name and
country would have been written to Cloud Logging on every first-contact
request, against the brief's *"do not expose private user information through
logs, public APIs or debug output"*. Request bodies are not logged, so a body
satisfies it.

**A `GET` that creates a resource is neither safe nor idempotent.** Retries,
prefetches and intermediaries all assume a `GET` has no side effects, and a
dropped connection followed by a retry could race on document creation.

#### `GET /v1/me` is a pure read

No query parameters, no writes. A uid with no document is:

```json
{ "error": { "code": "profile_not_found", "message": "...", "requestId": "..." } }
```

with status **404**, so the client knows to call `POST /v1/me` rather than
having to infer it from a bare 404.

#### The client flow

Written down here because the app and the API have to agree on it:

- **After sign-up** — register with Firebase Auth, then `POST /v1/me` with the
  registration fields, then `GET /v1/me` from that point on.
- **On app start with an existing session** — `GET /v1/me`. If it returns
  `404 profile_not_found`, `POST /v1/me` to recover and continue. That covers
  an account that signed up but never reached the `POST`, and an account whose
  data was deleted server-side.

#### `PATCH /v1/me` — what is patchable

Accepted: `name`, `preferredLanguage`, `activity`, `dateOfBirth`,
`countryCode`, and `coachingPreferences.{tone,rhythm,remindersEnabled}`.
Unknown keys are rejected with 422 rather than ignored.

Deliberately **not** patchable, and rejected if sent:

| Field | Why |
| --- | --- |
| `email` | Firebase Auth's to change, not ours |
| subscription state | Only verified provider webhooks may write it |
| `cycleDay`, `dayStreak`, `currentPrinciple` | Derived from recorded activity — a client cannot award itself a streak |

Coaching preferences may be patched individually. Sending only `tone` leaves
`rhythm` and `remindersEnabled` intact, because the update writes dotted field
paths rather than replacing the nested map.

#### `DELETE /v1/me` cascades

```json
{ "data": { "deleted": true, "documentsDeleted": 39 } }
```

Firestore does **not** cascade: deleting a document leaves its subcollections
in place, still readable by direct path and invisible to a collection listing.
So the delete walks every subcollection explicitly — including the `messages`
nested under each session — and removes the Firebase Auth record last.

Order matters. Firestore is swept first, because that is where the coaching
memory lives and it is the part that must not survive. If the sweep fails the
Auth record is untouched, so the user can still authenticate and retry. If the
Auth deletion fails after the data is gone, the response is
`500 partial_deletion` rather than success — an Auth record with no data
behind it would let the next request create a fresh empty profile and look
like the delete never ran.

The Auth record's removal revokes outstanding tokens, so a token minted before
the delete is rejected immediately rather than at its natural expiry.

#### `POST /v1/me/onboarding`

All seven answers in one call — the assessment is submitted whole from the
summary screen, so a partial write would leave a profile the coach cannot
reason about.

```bash
curl -X POST http://127.0.0.1:8787/v1/me/onboarding \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ambition":         { "en": "...", "pt": "..." },
    "focusAreaKeys":    ["onboarding.option.career", "onboarding.option.confidence"],
    "challenge":        { "en": "...", "pt": "..." },
    "priorityKeys":     ["onboarding.option.visibility", "onboarding.option.focus", "onboarding.option.team"],
    "mainGoals":        { "en": "...", "pt": "..." },
    "motivationBalance": 0.35,
    "successVision":    { "en": "...", "pt": "..." }
  }'
```

`completedAt` is stamped by the server, and only once the answers satisfy the
same completeness rule `OnboardingResponse.isComplete` uses in Dart — so a
partial submission cannot mark a profile finished. The response carries a
derived `isComplete`.

`focusAreaKeys` and `priorityKeys` are **localisation keys**, not display text;
the schema rejects anything with whitespace or punctuation, because that means
a client is sending the wrong thing.

---

## Environment variables

Copy `.env.example` to `.env`. `.env` is git-ignored and must never be
committed.

| Variable | Required | Notes |
| --- | --- | --- |
| `NODE_ENV` | no | `development` \| `test` \| `production`. Default `development`. |
| `PORT` | no | Default `8080`. Locally use `8787` — 8080 is the Firestore emulator's. Cloud Run injects this. |
| `GCP_PROJECT_ID` | **yes** | `succenergy-ai-coach` |
| `FIREBASE_PROJECT_ID` | **yes** | `succenergy-ai-coach` |
| `CORS_ALLOWED_ORIGINS` | no | Comma-separated. Empty means no browser origin is allowed. |
| `LOG_LEVEL` | no | `fatal`…`trace`, or `silent`. Default `info`. |
| `FIRESTORE_EMULATOR_HOST` | no | Set to `127.0.0.1:8080` locally. **Must be absent in production.** |
| `FIREBASE_AUTH_EMULATOR_HOST` | no | Set to `127.0.0.1:9099` locally. **Must be absent in production.** |
| `TEST_USER_EMAIL` | no | Emulator-only test account for the scripts |
| `TEST_USER_PASSWORD` | no | Emulator-only. Never a real user's password. |

A working local `.env`:

```
NODE_ENV=development
PORT=8787
GCP_PROJECT_ID=succenergy-ai-coach
FIREBASE_PROJECT_ID=succenergy-ai-coach
CORS_ALLOWED_ORIGINS=http://localhost:5173
LOG_LEVEL=debug
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
TEST_USER_EMAIL=test.user@example.com
TEST_USER_PASSWORD=emulator-only-password
```

`CORS_ALLOWED_ORIGINS` exists for the browser-based admin console. The mobile
app is a native client, sends no `Origin`, and is unaffected by CORS entirely.

### How credentials are resolved

`src/config/firebase.ts` is the **only** file that knows whether we are
emulated. Nothing below the config layer branches on environment.

- **Both emulator hosts set** → the Admin SDK routes to the emulators on its
  own and accepts any project id with no credentials, so it initialises with
  the project id alone.
- **Neither set** → Application Default Credentials: the attached service
  account on Cloud Run, and `gcloud auth application-default login` locally.

---

## The layer rule

```
routes → controllers → services → repositories → Firestore
```

Enforced, not aspirational:

- **Controllers never touch Firestore.** Every handler in
  `controllers/user.controller.ts` is parse → delegate → respond. Anything
  longer is logic that belongs a layer down.
- **Services never import Express types.** `services/user.service.ts` takes
  validated input and returns response shapes. It knows nothing about
  requests, headers or status codes beyond the `ApiError`s it throws.
- **Repositories are the only place Firestore appears.** Nothing above
  `repositories/` imports from `firebase-admin/firestore`, so the database can
  be swapped, batched or mocked without a layer above knowing.

A quick check that the rule still holds:

```bash
# Should return nothing.
grep -rl "firebase-admin/firestore" src/controllers src/services src/routes
grep -rlE "from 'express'" src/services src/repositories
```

> `services/user.service.ts` imports `Timestamp` from `firebase-admin/firestore`
> to stamp times. That is a value type, not a database handle — no query, read
> or write happens outside `repositories/`.

Validation sits at the edge: schemas parse in the controller, so no layer below
has to defend against a missing or mistyped field.

---

## Project structure

```
backend/
├── src/
│   ├── index.ts                 Bootstrap, graceful shutdown
│   ├── app.ts                   Express assembly, middleware order
│   ├── config/
│   │   ├── env.ts               Zod env schema, fails fast on boot
│   │   ├── firebase.ts          Admin SDK init, emulator-aware
│   │   ├── logger.ts            pino, Cloud Logging severities
│   │   ├── secrets.ts           Secret Manager accessor, cached
│   │   └── version.ts           K_REVISION, or the package version
│   ├── middleware/
│   │   ├── auth.ts              Verifies ID token, attaches req.user
│   │   ├── admin.ts             Requires admin claim, runs after auth
│   │   ├── error_handler.ts     Central handling, no stack traces out
│   │   ├── not_found.ts
│   │   └── request_logger.ts    pino-http with PII stripped
│   ├── routes/                  index (versioned), health, user
│   ├── controllers/             HTTP layer only
│   ├── services/                Business logic
│   ├── repositories/            The only layer touching Firestore
│   ├── models/                  One file per collection
│   ├── schemas/                 Zod request validation
│   └── utils/                   api_error, async_handler, timestamps
├── scripts/                     seed_firestore, get_test_token
├── firebase.json                Emulator config
├── firestore.rules              Deny-all
├── firestore.indexes.json
└── Dockerfile
```

Three files exist beyond the structure in the brief, each one concern:

- `config/logger.ts` — the pino instance, so `request_logger.ts` configures
  request logging rather than also constructing the logger.
- `config/version.ts` — resolves the running version from `K_REVISION`.
- `models/locale.model.ts` and `models/localized_text.model.ts` — the `{en, pt}`
  bilingual type and its resolver, imported by every model with bilingual
  content.
- `utils/timestamps.ts` — Firestore `Timestamp` ↔ ISO 8601, in one place so no
  layer has to remember which side of the boundary it is on.

---

## Firestore data model

```
users/{uid}
  name, email, preferredLanguage, activity,
  dateOfBirth, countryCode,
  acceptedTerms, confirmedInfoTrue,
  currentPrinciple, cycleDay, dayStreak,
  coachingPreferences { tone, rhythm, remindersEnabled },
  createdAt, updatedAt

users/{uid}/onboarding/response
  ambition, focusAreaKeys[], challenge, priorityKeys[],
  mainGoals, motivationBalance, successVision, completedAt, updatedAt

users/{uid}/goals/{goalId}
  title, why, principle, targetDate,
  milestones[{ id, title, dueDate, reachedAt }],
  actions[{ id, goalId, title, isDone, isToday }],
  completedAt, createdAt, updatedAt

users/{uid}/exerciseResponses/{responseId}
  exerciseId, principle, stepResponses{}, reflection,
  suggestedAction, completedAt

users/{uid}/sessions/{sessionId}
  startedAt, endedAt, summary, principle, messageCount
  └── messages/{messageId}
        author, text, sentAt

users/{uid}/notifications/{notificationId}
  type, title, body, isRead, receivedAt

users/{uid}/subscription/current
  tier, status, trialStartedAt, trialEndsAt,
  currentPeriodEnd, provider, providerCustomerId, updatedAt

users/{uid}/progressSnapshots/{YYYY-MM-DD}
  date, goalCompletion, actionsCompleted, exercisesCompleted

users/{uid}/purposeAnswers/{promptId}
  answer, updatedAt

exercises/{exerciseId}                    Shared, admin-managed
  principle, title, summary, durationMinutes,
  steps[{ id, type, prompt, help, options, scaleLowLabel, scaleHighLabel, saveAs? }],
  closingReflectionPrompt, suggestedAction, isActive, order
```

Shape decisions worth knowing:

- **Bilingual content is an `{en, pt}` map**, never a resolved string. The app
  requests by locale rather than the backend guessing which language a reader
  wants.
- **Milestones and actions are embedded arrays** on the goal, because the Dart
  `Goal` carries them as lists and every screen showing one already has the
  goal loaded.
- **Chat messages are a subcollection**, because a long conversation would
  outgrow Firestore's 1 MiB document limit and the coach appends one message
  at a time.
- **Derived state is derived, not stored.** Goal status comes from
  `completedAt`; session `durationMinutes` from the two timestamps. The pair
  can never disagree.
- **Progress snapshots are keyed by calendar date**, so a day can only be
  recorded once and a date range reads as a key range with no index.
- `exerciseResponses` holds **one document per completed run**, not one per
  answered step: a session is reviewed as a whole, so it should be one read.

### Adding a subcollection

`USER_SUBCOLLECTIONS` in `repositories/user.repository.ts` is what the
cascading delete walks. **A new per-user subcollection must be added there**,
or it will be orphaned when an account is deleted. The delete also lists what
is actually present, so an unlisted collection is still reached — but do not
rely on that, because the list is what documents the intent.

---

## Field naming: where this differs from the brief

The brief said to match `lib/data/models/` field names exactly so the API and
app agree without a translation layer, and its own Firestore block then used
different names for some fields the Flutter side already has. **The Flutter
model wins** on those, since matching it was the stated reason for reading it.

| Brief | Used here | Source |
| --- | --- | --- |
| `displayName` | `name` | `User.name` |
| `country` | `countryCode` | `User.countryCode` |
| `cycleStage` | `cycleDay` | `User.cycleDay` |
| `coachingPreferences.reminders` | `coachingPreferences.remindersEnabled` | `User.remindersEnabled` |
| `focusAreas[]` | `focusAreaKeys[]` | `OnboardingResponse.focusAreaKeys` |
| `priorities[]` | `priorityKeys[]` | `OnboardingResponse.priorityKeys` |
| `whyItMatters` | `why` | `Goal.why` |
| `intro` (exercise) | `summary` | `Exercise.summary` |
| `suggestedNextAction` | `suggestedAction` | `Exercise.suggestedAction` |
| `stepId`, `inputType` | `id`, `type` | `ExerciseStep.id`, `.type` |
| `role`, `content` (message) | `author`, `text` | `ChatMessage.author`, `.text` |
| `createdAt` (notification) | `receivedAt` | `AppNotification.receivedAt` |

Kept from the brief because the Flutter side has no equivalent:
`preferredLanguage`, `acceptedTerms`, `confirmedInfoTrue`, `createdAt` /
`updatedAt`, `endedAt`, `closingReflectionPrompt`, `isActive`, `order`,
`saveAs`, and the whole `subscription/current` document.

Also kept from the Flutter models but absent from the brief: `dayStreak`,
`durationMinutes` on exercises, and `help` / `options` / `scaleLowLabel` /
`scaleHighLabel` on exercise steps — exercise sessions are driven entirely
from step data, with no content hardcoded in a widget, so those are needed.

Two fields the brief lists as stored are **derived** instead:
`isCompleted` on a goal (from `completedAt`) and `messageCount` semantics.
`isCompleted` is returned by the API but never stored.

`User.joinedAt` in Dart maps to `createdAt` in Firestore; the API returns it as
`joinedAt`.

---

## Enum wire values

Dart enums are camelCase; the wire format is **snake_case**, following the
`student_minorities` value the brief specifies. Single-word values are
unchanged.

| Enum | Values |
| --- | --- |
| `Principle` | `purpose` `passion` `planning` `praxis` `persistence` `progress` `perfection` |
| `UserActivity` | `student_minorities` `professional` |
| `CoachingTone` | `direct` `warm` `challenging` |
| `CheckInRhythm` | `daily` `every_other_day` `weekly` |
| `MessageAuthor` | `coach` `user` |
| `ExerciseStepType` | `free_text` `single_choice` `scale` |
| `NotificationType` | `goal_nudge` `principle_of_day` `reengagement` `exercise_reminder` `milestone` |
| `SubscriptionTier` | `trial` `student` `professional` |
| `SubscriptionStatus` | `none` `trialing` `active` `past_due` `canceled` `expired` |
| `GoalStatus` | `active` `completed` (derived, read-only) |

`models/principle.model.ts` is the single source of truth for the cycle — its
order, `nextPrinciple`, and the localisation keys. Every other model imports
the type from there rather than restating the list.

---

## Firestore rules and indexes

### Rules: deny-all

`firestore.rules` denies every read and write at every depth. The app never
touches Firestore directly — it goes through this API, which uses the Admin
SDK and therefore bypasses rules entirely — so denying everything costs
nothing and closes the whole surface. No client SDK, no leaked config, and no
future screen that "just reads one collection" can reach user data without
passing an endpoint that verifies a token first.

It also keeps the API as the single enforcement point for the admin
restriction, instead of that check living in two places and eventually
disagreeing.

Verified against the emulator's client REST API, which is the path a Firebase
client SDK takes: unauthenticated reads, authenticated reads of the caller's
**own** document, reads of nested chat messages, writes, and collection lists
are all `403 PERMISSION_DENIED`, while the same data comes back `200` through
`GET /v1/me`.

If a client-side read is ever genuinely needed, add a narrow rule for that one
path with an explicit `request.auth.uid == uid` condition. Do not relax the
default.

### Indexes

Firestore indexes every single field automatically, so `firestore.indexes.json`
carries only composite and array cases. Today's two endpoints read by document
path and need none of them — they are declared now because an index must exist
before the query that needs it runs, and the goals, sessions, notifications,
exercises, progress and admin passes land next.

Per-user subcollections use `COLLECTION_GROUP` scope: the collection id is the
same under every uid, so a group index covers both the scoped query the API
makes and the cross-user reporting the admin console needs, without a second
index.

`fieldOverrides` switches indexing **off** for content that is never queried or
ordered by — the free-text onboarding answers, chat message bodies, embedded
milestone and action arrays, exercise step definitions, and exercise
responses. That saves an index write per field on every save, and more
importantly keeps the user's own words out of the index, which is a second
copy of the data that account deletion would otherwise have to reach.

The file is kept to the strict schema with no comment keys, because
`firebase deploy --only firestore:indexes` validates it and that deploy cannot
be run here to prove extra keys are tolerated.

Deploy them with:

```bash
npx firebase deploy --only firestore:rules,firestore:indexes --project succenergy-ai-coach
```

This needs billing enabled — see below.

---

## Secrets

Every secret lives in **Google Secret Manager** and is referenced by name.
Nothing is in code, nothing is committed, and no secret is ever logged.

`src/config/secrets.ts` resolves secrets by name with a process-lifetime
cache. The registry is **deliberately empty** — no external API is called yet.
The Claude key, the embeddings key and the Stripe keys become one line each in
`SECRET_NAMES` when those passes land, and nothing else changes:

```ts
export const SECRET_NAMES = {
  ANTHROPIC_API_KEY: 'anthropic-api-key',
} as const satisfies Record<string, string>;
```

```ts
const key = await getSecret('ANTHROPIC_API_KEY');
```

Under the emulators only, a value may be supplied as a `SECRET_<KEY>`
environment variable so development does not need Secret Manager access. In
production the value comes from Secret Manager or the request fails.

Cloud Run's service account needs `roles/secretmanager.secretAccessor` on each
secret. Rotation takes effect on the next cold start; `clearSecretCache()`
exists if it ever has to happen without a redeploy.

---

## Security decisions

Notes on the client's checklist, and why each is where it is.

**No secrets in the app, none committed.** All external calls — Claude, Stripe
— will be proxied through this backend, never client-side.
`.gitignore` excludes `.env`, every `*serviceAccount*.json` /
`*service-account*.json` pattern, `*.pem`, `*.p12` and
`application_default_credentials.json`.

**Authentication on every non-public endpoint.** `requireAuth` is applied to
the `/me` router itself, not to individual routes, so a route added later
cannot be left public by omission. Only the two health routes are public.

`checkRevoked` is on when verifying tokens, which is what makes account
deletion and account disabling take effect immediately rather than at the
token's natural expiry. The verified caller attached to the request is
deliberately narrow — uid, admin flag, email, verified flag — rather than the
whole decoded token, so nothing else from it can reach a log line.

**Admin restricted to authorised accounts.** `requireAdmin` requires a custom
claim set out of band with the Admin SDK. No endpoint grants it, so a
compromised client cannot escalate. Its refusal message does not distinguish
"not an admin" from "no such thing", because whether an account is an
administrator is not something an unauthorised caller gets to learn.

**No private user information in logs.** `request_logger.ts` **replaces**
pino-http's serialisers outright rather than redacting fields out of them, so a
future pino-http release cannot introduce a field that leaks by default. What
is logged is method, route path, status, duration, request id and uid. Not
logged: headers (Authorization included), query strings, request bodies, email
addresses, names, or anything the user typed. A uid is an opaque identifier
needed to trace a problem to an account; none of the rest is.

A `redact` list is configured on top of that as a second layer, and the boot
time env validation prints variable **names** only.

**No stack traces to clients.** `error_handler.ts` is the only place a failure
is shaped. An unrecognised error becomes a bare 500 rather than forwarding its
message — a message reaches a caller only when we chose it by throwing an
`ApiError`. Zod failures return the field path and the rule that failed, never
the rejected value. Errors are sent `Cache-Control: no-store`, so an
intermediary cannot cache a 401 and lock a user out.

**HTTPS everywhere in production.** Cloud Run serves HTTPS; the app also
redirects plain HTTP with 308 and sets HSTS when `NODE_ENV=production`, which
covers a custom domain or future proxy forwarding plain HTTP. `trust proxy` is
set so `X-Forwarded-Proto` is read correctly and the redirect cannot loop.

**User data deletable on request, coaching memory included.** See
[`DELETE /v1/me` cascades](#delete-v1me-cascades). Verified with 38 documents
across 8 subcollections, including messages nested two levels down: after the
delete, direct-path probes for all of them return nothing, `listCollections`
reports zero, the Auth record is gone, and the shared `exercises/` library —
which is not the user's data — is intact.

---

## Docker

Multi-stage, non-root, production dependencies only.

> **The image build has still not been verified.** Re-checked on this pass:
> Docker Desktop is installed, but launching it registers no daemon — the
> `com.docker.service` helper is not installed, there is no `docker-desktop`
> WSL distro, and `docker info` cannot reach `npipe:////./pipe/docker_engine`.
> First-run setup needs an interactive elevated session that a non-interactive
> pass cannot provide, so `docker build` again had no daemon to talk to.
>
> What the container *executes* was verified by running it directly: the
> compiled `dist/` on production-only dependencies with
> `NODE_ENV=production`, serving `/v1/health`, enforcing auth, and emitting the
> production security headers. That covers the usual container failures — a
> devDependency needed at runtime, a wrong entrypoint, ESM resolution in
> compiled output. The unverified part is the image layering itself.
>
> **Run `docker build -t succenergy-api:local .` on a machine with a working
> daemon before the first deploy.**

```bash
docker build -t succenergy-api:local .
```

Run it against the emulators. On Linux add `--add-host` or use
`--network host`; on macOS and Windows `host.docker.internal` resolves to the
host:

```bash
docker run --rm -p 8080:8080 \
  -e NODE_ENV=development \
  -e GCP_PROJECT_ID=succenergy-ai-coach \
  -e FIREBASE_PROJECT_ID=succenergy-ai-coach \
  -e FIRESTORE_EMULATOR_HOST=host.docker.internal:8080 \
  -e FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:9099 \
  succenergy-api:local

curl http://127.0.0.1:8080/v1/health
```

Without the emulator variables the container needs Application Default
Credentials, which it will not have locally — `/v1/health` still answers,
`/v1/health/ready` will not.

Image notes:

- `npm ci`, not `npm install`, so a build cannot silently pick up a version
  other than the lockfile's.
- Dependencies install in their own stage, so a source-only change does not
  reinstall the tree.
- `dumb-init` as PID 1 reaps zombies and forwards signals, so the `SIGTERM`
  Cloud Run sends actually reaches Node and the graceful shutdown runs.
- Runs as the image's unprivileged `node` user, with ownership set on copy
  rather than a later `chown` that would duplicate the tree in a layer.
- Listens on `process.env.PORT`. `ENV PORT=8080` matches Cloud Run's default
  so `-p 8080:8080` works without passing it.
- `.dockerignore` keeps `.env`, `node_modules`, `dist`, `.git`, the emulator
  config and the scripts out of the build context.

---

## Deploying to Cloud Run

**Status: not deployed.** Billing is attached and Firestore exists, so nothing
about the project blocks this any more. What blocks it is the machine this pass
ran on:

| Requirement | State here |
| --- | --- |
| `gcloud` CLI | **Not installed.** No Cloud SDK anywhere on the machine, and no Application Default Credentials to authenticate one with. |
| Docker daemon | **Not available.** Docker Desktop is installed but its privileged helper service is not registered and no `docker-desktop` WSL distro exists, so the daemon cannot be provisioned without an interactive elevated session. |
| Firebase CLI | Installed and signed in, but the signed-in account has **read-only access** to the project. It can read the Firestore database's metadata; it cannot write rules. |

One thing did come out of it: the deploy **region is now confirmed** rather
than guessed, read off the live database through the Firebase CLI. Everything
else below still has to be run by someone with the tooling and the IAM to do
it.

### What the signed-in account can and cannot do

`npx firebase login:list` reports an account that can list the project and
read `projects/succenergy-ai-coach/databases/(default)`. It cannot deploy:

```
$ npx firebase deploy --only firestore:rules,firestore:indexes --project succenergy-ai-coach
Error: Request to https://firebaserules.googleapis.com/v1/projects/succenergy-ai-coach:test
had HTTP Error: 403, The caller does not have permission
```

`PERMISSION_DENIED`, not `SERVICE_DISABLED` — so this is an IAM grant that
is missing, not an API that needs enabling. Whoever runs the deploy needs, on
`succenergy-ai-coach`:

| Role | For |
| --- | --- |
| `roles/firebaserules.admin` | deploying `firestore.rules` |
| `roles/datastore.indexAdmin` | deploying `firestore.indexes.json` |
| `roles/run.admin` | `gcloud run deploy` |
| `roles/artifactregistry.admin` | creating the image repository |
| `roles/cloudbuild.builds.editor` | `gcloud builds submit` |
| `roles/iam.serviceAccountAdmin` + `roles/resourcemanager.projectIamAdmin` | creating `succenergy-api` and binding `roles/datastore.user` to it |
| `roles/iam.serviceAccountUser` on `succenergy-api` | letting Cloud Run run as it |

Project `roles/owner` covers all of these and is what the client's own account
will already have.

### The region: `us-central1`

Read off the live database rather than chosen:

```bash
npx firebase firestore:databases:get '(default)' --project succenergy-ai-coach
# Type      FIRESTORE_NATIVE
# Location  nam5
```

`nam5` is the **United States multi-region**, which is what the client asked
for. Cloud Run cannot be deployed to a multi-region, so it goes to
**`us-central1`** — one of `nam5`'s two constituent regions and the
conventional pairing. Every request in this service reads Firestore, so
co-location matters: a European Cloud Run against `nam5` Firestore would add a
transatlantic round trip to all of them for no benefit.

`europe-west1` appeared as a placeholder in earlier revisions of this file.
It is gone.

### The sequence

`REGION` is set once at the top so there is one place to change it.

```bash
export PROJECT=succenergy-ai-coach
export REGION=us-central1
export IMAGE=$REGION-docker.pkg.dev/$PROJECT/succenergy/api:$(git rev-parse --short HEAD)

# 0. Confirm Firestore's location has not moved, before anything is created
gcloud firestore databases describe --database='(default)' --project $PROJECT

# 1. Enable the APIs
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  firestore.googleapis.com \
  secretmanager.googleapis.com \
  --project $PROJECT

# 2. Artifact Registry repository, once
gcloud artifacts repositories create succenergy \
  --repository-format=docker --location=$REGION \
  --project $PROJECT

# 3. A dedicated runtime service account, not the default compute one
gcloud iam service-accounts create succenergy-api \
  --display-name "Succenergy API runtime" --project $PROJECT

gcloud projects add-iam-policy-binding $PROJECT \
  --member serviceAccount:succenergy-api@$PROJECT.iam.gserviceaccount.com \
  --role roles/datastore.user

# Grant secretAccessor per secret as each one is added, never project-wide.

# 4. Verify the image builds locally before spending a remote build on it
docker build -t succenergy-api:local .

# 5. Build and push
gcloud builds submit --tag $IMAGE --project $PROJECT

# 6. Deploy
gcloud run deploy succenergy-api \
  --image $IMAGE \
  --region $REGION \
  --platform managed \
  --service-account succenergy-api@$PROJECT.iam.gserviceaccount.com \
  --set-env-vars NODE_ENV=production,GCP_PROJECT_ID=$PROJECT,FIREBASE_PROJECT_ID=$PROJECT,LOG_LEVEL=info \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 10 \
  --project $PROJECT
```

The Firestore `databases create` step that used to be step 2 is gone: the
database already exists, and running it again would fail rather than be a
harmless no-op.

### Rules and indexes

**Not deployed** — attempted and refused with the 403 above.

```bash
npx firebase deploy --only firestore:rules,firestore:indexes --project succenergy-ai-coach
```

Worth running **first**, before the service. It is independent of Cloud Run
— rules and indexes are database configuration, not application deployment
— and the rules are [deny-all](#rules-deny-all), so running them first
locks the database down before anything is reachable rather than after.

Until they are deployed the project carries whatever default rules Firestore
was created with. That is not currently a data-exposure risk, because there is
no client SDK pointed at this project and no data in it beyond what the
emulator holds locally, but it should not stay that way once the app is live.
Note that `firebase deploy` compiles `firestore.rules` even for an
`--only firestore:indexes` run, so the two cannot be separated to get the
indexes in without rules permission.

### Checking the service once it is up

```bash
SERVICE=$(gcloud run services describe succenergy-api --region $REGION \
  --project $PROJECT --format 'value(status.url)')

curl -i $SERVICE/v1/health            # 200
curl -i $SERVICE/v1/health/ready      # 200, proves the runtime SA reaches Firestore
curl -i $SERVICE/v1/me                # 401, no token
curl -sI $SERVICE/v1/health | grep -i strict-transport-security
curl -sI http://${SERVICE#https://}/v1/health   # 308 to https
```

`/v1/health/ready` is the one that matters most: it round-trips a Firestore
read, so a 200 confirms `roles/datastore.user` on `succenergy-api` actually
works. A 503 there means the binding did not take.

Then confirm in Cloud Logging that request log lines carry no email addresses,
names, tokens or user content:

```bash
gcloud logging read \
  'resource.type="cloud_run_revision" AND resource.labels.service_name="succenergy-api"' \
  --limit 50 --project $PROJECT
```

**Authenticated verification waits for the Flutter side.** A real ID token has
to come from the app's own sign-in against the production Auth instance. Do
**not** create a test user in production Auth to get one — `401` on a
tokenless request is sufficient proof the middleware is active, and a real
account in the client's live user list is not worth a curl.

### Notes for whoever runs this

- **Do not set `FIRESTORE_EMULATOR_HOST` or `FIREBASE_AUTH_EMULATOR_HOST` on
  the service.** Boot refuses to start if either is set with
  `NODE_ENV=production`, which is deliberate — a production instance quietly
  talking to an emulator is worse than one that will not start.
- `--allow-unauthenticated` is correct here: the service is public at the
  network level and enforces Firebase ID tokens itself. Cloud Run IAM would
  reject mobile clients, which have no Google identity.
- **Not** the default compute service account. It carries `roles/editor`
  across the project; `succenergy-api` carries `roles/datastore.user` and
  nothing else.
- Secrets go in as `--set-secrets`, not `--set-env-vars`, once `SECRET_NAMES`
  has entries. `--set-env-vars` puts the value in the service's own
  configuration, readable by anyone with Cloud Run view access.
- `--min-instances 0` scales to zero and accepts cold starts. Raise to 1 if
  first-request latency matters more than idle cost.

---

## What is not built yet

Out of scope for this pass, listed so nobody looks for them:

Claude integration, RAG, Supabase/pgvector, embeddings, the RevenueCat SDK
and its webhook, push notifications, and the goals, exercises, progress and
admin endpoints.
Email sending. The Flutter app still runs entirely on its mock repositories —
swapping them for this API starts next.

Auth flows — register, log in, password reset — are client-side by design and
are not coming here. This backend verifies tokens; it does not issue them.
