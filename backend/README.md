# Succenergy AI Coach — Backend

The API behind the Succenergy AI Coach app. TypeScript and Express on Cloud
Run, **Postgres (Supabase)** for application data and the RAG vector store,
Firebase Auth for authentication, and Google Secret Manager for every secret.

**Deployed:** https://succenergy-api-4612920383.us-east1.run.app

Firestore is gone. Supabase Postgres is the single database — application
tables and, from migration 002, the embeddings the coach will retrieve from.
Firebase's remaining job is verifying ID tokens, and later FCM.

---

## Contents

- [Quick start](#quick-start)
- [Local development: getting a database](#local-development-getting-a-database)
- [Migrations](#migrations)
- [Running the Auth emulator](#running-the-auth-emulator)
- [Running the server](#running-the-server)
- [Getting a token for curl](#getting-a-token-for-curl)
- [Seeding the test persona](#seeding-the-test-persona)
- [Endpoints](#endpoints)
- [Environment variables](#environment-variables)
- [The layer rule](#the-layer-rule)
- [Project structure](#project-structure)
- [Data model](#data-model)
- [Field naming: where this differs from the brief](#field-naming-where-this-differs-from-the-brief)
- [Enum wire values](#enum-wire-values)
- [Row level security](#row-level-security)
- [Secrets](#secrets)
- [Security decisions](#security-decisions)
- [Docker](#docker)
- [Deploying to Cloud Run](#deploying-to-cloud-run)
- [What is not built yet](#what-is-not-built-yet)

---

## Quick start

You need **Node 22+**, a **Postgres database** (see below) and **Docker** only
if you want to build the image. Java is no longer needed — that was the
Firestore emulator.

```bash
cd backend
npm install
cp .env.example .env      # then fill it in — see Environment variables
npm run migrate           # create the schema
```

Then, in **two terminals**:

```bash
# Terminal 1 — the Auth emulator. Leave this running.
npm run emulators

# Terminal 2 — the API
npm run dev
```

Check it:

```bash
curl http://127.0.0.1:8787/v1/health
curl http://127.0.0.1:8787/v1/health/ready
```

`/v1/health/ready` round-trips `select 1`, so a 200 there means the API found
the database.

### Scripts

| Script | What it does |
| --- | --- |
| `npm run dev` | API with reload, reading `.env` |
| `npm run dev:emulated` | Same, but forces the Auth emulator host regardless of `.env` |
| `npm run emulators` | Firebase Auth emulator and the emulator UI |
| `npm run migrate` | Applies pending SQL migrations. Safe to re-run. |
| `npm run seed` | Writes the test persona into the database |
| `npm run token` | Prints a Firebase ID token for the test user |
| `npm run build` | Compiles TypeScript to `dist/` |
| `npm start` | Runs the compiled output (what the container does) |
| `npm run lint` | ESLint, type-aware, zero warnings tolerated |
| `npm run typecheck` | `tsc --noEmit` over `src/` and `scripts/` |

---

## Local development: getting a database

Two options. Both need **pgvector** for migration 002 — the extension the RAG
table's `vector(1024)` column depends on.

### Option A — a personal free Supabase project

Closest to production, and pgvector is available on every Supabase project.

1. Create a free project at supabase.com. It is *yours*, not the client's —
   never point local development at the client's database.
2. Project Settings → Database → Connection string → **Transaction pooler**
   (port 6543).
3. Put it in `.env` as `DATABASE_URL`.
4. Database → Extensions → enable `vector`. Migration 002 also declares it,
   but the dashboard toggle is the reliable path on a fresh project.

### Option B — Docker

Use the **`pgvector/pgvector`** image rather than plain `postgres`; the
official Postgres image does not ship the extension, and migration 002 stops
at `create extension vector` without it.

```bash
docker run -d --name succenergy-pg \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=succenergy \
  -p 5432:5432 \
  pgvector/pgvector:pg16
```

```
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/succenergy?sslmode=disable
```

`?sslmode=disable` is required here: a local Postgres container has no
certificate and refuses the SSL handshake, while TLS is on by default because
the connection that matters is the one to Supabase.

Then `npm run migrate`.

---

## Migrations

Plain numbered SQL files in `backend/migrations/`, applied by
`scripts/migrate.ts`.

```bash
npm run migrate
```

| File | What it creates |
| --- | --- |
| `001_initial_schema.sql` | Every application table, its indexes, the `updated_at` trigger, and RLS |
| `002_rag_embeddings.sql` | `knowledge_chunks` and the pgvector extension. Empty — the knowledge base has not arrived. |

**No migration framework.** The client has Supabase connected to a GitHub repo
and has not yet said whether migrations should run through that integration.
Plain SQL works either way — through the integration, through this script, or
pasted into Supabase's SQL editor — and stays readable to someone who wants to
see what the schema is, which the client has asked for.

How the script behaves:

- Applied filenames go into `schema_migrations` with a checksum. An applied
  file is skipped, so **re-running does nothing**.
- Each migration runs in its own transaction along with the row that records
  it. A migration that fails partway leaves the database exactly as it was and
  is **not** marked applied — so fixing the cause and re-running is the whole
  recovery procedure.
- A transaction-scoped advisory lock serialises concurrent runs. Transaction
  scoped rather than session scoped, because Supabase's transaction pooler
  does not keep a session across statements.
- **Editing an applied migration is refused.** Two databases would silently
  end up with different schemas. Add a new numbered file instead.

### Adding a table

Add a new numbered file. Three things a new per-user table needs:

1. `user_id text not null references users(id) on delete cascade` — this is
   what keeps account deletion a single statement.
2. An index on `user_id`, plus whatever it is filtered or sorted by.
3. `alter table <name> enable row level security;` with **no policy**.

There is no list to remember to update. Under Firestore there was
(`USER_SUBCOLLECTIONS`), and forgetting it orphaned data on delete.

---

## Running the Auth emulator

**`npm run emulators` must be running in a second terminal for local
development.** Token verification does not work without it.

| Emulator | Address |
| --- | --- |
| Auth | `127.0.0.1:9099` |
| Emulator UI | http://127.0.0.1:4000 |

There is no Firestore emulator any more, and Postgres has no emulator — it is
simply a different `DATABASE_URL`. That also means **local data survives
restarting the emulator**, which Firestore's in-memory emulator did not: no
re-seed after every restart.

> The local API runs on **8787**. Cloud Run injects its own `PORT`.

---

## Running the server

`npm run dev` uses `tsx watch` and reloads on save.

Boot fails immediately, before the server listens, in two cases.

**A bad environment.** `src/config/env.ts` validates everything with Zod at
import time and prints the offending **variable names** — never their values,
which may be credentials:

```
Invalid environment configuration. The server will not start.
  - DATABASE_URL: DATABASE_URL is required outside production

Copy backend/.env.example to backend/.env and fill in the values.
```

**An unreachable database.** `src/config/database.ts` connects and runs
`select 1` before `app.listen`, in the same names-not-values style:

```
Cannot reach the database. The server will not start.
  - the host, port, user or password in the connection string is wrong,
    the database is down, or this network cannot reach it
  - Supabase: use the transaction pooler string on port 6543, not the
    direct connection, which is IPv6-only
  - reported: connect ECONNREFUSED 127.0.0.1:5432
```

A service that starts without its database serves 500s until someone notices.
Failing here means a bad Cloud Run revision never goes healthy and the
previous one keeps serving.

Two further environment guards:

- **`DATABASE_URL` must be absent when `NODE_ENV=production`**, where the
  connection string comes from Secret Manager instead. Setting it would put a
  database credential into the Cloud Run service configuration, readable by
  anyone with view access.
- **`FIREBASE_AUTH_EMULATOR_HOST` must be absent in production.** A production
  instance quietly authenticating against an emulator is worse than one that
  will not start.

---

## Getting a token for curl

Auth itself — register, log in, reset password — happens **client-side** via
the Firebase Auth SDK. This backend verifies tokens; it does not issue them.
So to exercise an authenticated endpoint, mint a token against the Auth
emulator:

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
`npm run seed` first, or create the row explicitly:

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

Writes **Marisa Chissano**, the persona from `lib/data/mock/mock_data.dart`,
so the seeded account reads as the same person the Flutter build demonstrates
rather than as unrelated sample rows: three weeks in, mid-cycle on Praxis,
running a brand relaunch, bilingual throughout.

49 rows across twelve tables, plus 2 exercises and 5 exercise steps in the
shared library. Counts in its report are read back from the database, not
tallied by the script, so what it prints is what is actually stored.

The account is keyed to `TEST_USER_EMAIL`, so `npm run token` returns a token
for the seeded uid and `GET /v1/me` returns the persona rather than an empty
profile.

Re-seeding clears the user's data first — one `delete from users`, and the
cascade does the rest — so a removed goal does not linger. The shared
`exercises` library is **upserted** rather than cleared, because it is not the
user's data. Like the token script, it refuses to run without the Auth
emulator, or with `NODE_ENV=production`.

---

## Endpoints

All under `/v1`. Every response is `{ "data": ... }`; every failure is
`{ "error": { "code", "message", "details?", "requestId" } }`.

### Public

| Method | Path | Notes |
| --- | --- | --- |
| `GET` | `/v1/health` | Liveness. Answers from process state alone, so a slow database minute does not get a healthy instance restarted. |
| `GET` | `/v1/health/ready` | Readiness. Round-trips `select 1` against Postgres; 503 when it cannot. |

### Authenticated

Send `Authorization: Bearer <Firebase ID token>`.

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `/v1/me` | **First contact.** Creates the user row for the token's uid (201; 200 if it already exists) |
| `GET` | `/v1/me` | Current profile. Read only — `404 profile_not_found` if there is no row yet |
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
row is already there — not a 409, and not a second write. The client may
retry a call whose response it never saw, and a retry has to be harmless.

The insert is `on conflict (id) do nothing returning *`, so this is **atomic**
rather than optimistic. Two first requests for the same unknown uid are
decided once, by the database; the one that did not insert reads the winning
row inside the same transaction. Under Firestore this was a create that could
fail, followed by a hopeful re-read.

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

No query parameters, no writes. One query: the user row and the onboarding and
subscription rows that hang off it come back through two left joins rather
than three round trips. A uid with no row is:

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
`rhythm` and `remindersEnabled` intact: they are three separate columns, and
the `SET` clause only names the ones actually sent. Under Firestore this
needed dotted field paths built in the service, because a nested map was
otherwise replaced wholesale — that workaround is gone.

#### `DELETE /v1/me` cascades

```json
{ "data": { "deleted": true, "documentsDeleted": 49 } }
```

```sql
delete from users where id = $1;
```

That is the whole thing. Every child table references `users(id)` with
`on delete cascade`, so goals, milestones, action items, exercise responses,
coaching sessions, chat messages, purpose answers, notifications, the
subscription, the onboarding response and the progress snapshots go with it —
and the application code names none of them. This is the single biggest gain
over Firestore, which does not cascade at all: deleting a document there left
its subcollections in place, readable by direct path and invisible to a
collection listing, so the delete had to walk every one of them by hand from a
list that a new subcollection had to be remembered into.

`documentsDeleted` keeps its name for contract compatibility and now counts
rows. The dependent rows are counted in the same transaction, immediately
before the delete, so the number is accurate and reveals nothing about what
the rows contained.

Order still matters. The database first, because that is where the coaching
memory lives and it is the part that must not survive. If the delete fails the
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
| `PORT` | no | Default `8080`. Locally use `8787`. Cloud Run injects this. |
| `DATABASE_URL` | **outside production** | Postgres connection string. **Must be absent in production**, where it comes from Secret Manager. |
| `GCP_PROJECT_ID` | **yes** | `succenergy-ai-coach` |
| `FIREBASE_PROJECT_ID` | **yes** | `succenergy-ai-coach` |
| `CORS_ALLOWED_ORIGINS` | no | Comma-separated. Empty means no browser origin is allowed. |
| `LOG_LEVEL` | no | `fatal`…`trace`, or `silent`. Default `info`. |
| `FIREBASE_AUTH_EMULATOR_HOST` | no | Set to `127.0.0.1:9099` locally. **Must be absent in production.** |
| `TEST_USER_EMAIL` | no | Emulator-only test account for the scripts |
| `TEST_USER_PASSWORD` | no | Emulator-only. Never a real user's password. |

A working local `.env`:

```
NODE_ENV=development
PORT=8787
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/succenergy?sslmode=disable
GCP_PROJECT_ID=succenergy-ai-coach
FIREBASE_PROJECT_ID=succenergy-ai-coach
CORS_ALLOWED_ORIGINS=http://localhost:5173
LOG_LEVEL=debug
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
TEST_USER_EMAIL=test.user@example.com
TEST_USER_PASSWORD=emulator-only-password
```

`CORS_ALLOWED_ORIGINS` exists for the browser-based admin console. The mobile
app is a native client, sends no `Origin`, and is unaffected by CORS entirely.

### How credentials are resolved

**The database.** `src/config/database.ts` is the only file that constructs a
pool, and the only one that knows where the connection string came from.

- **Production** → Secret Manager, by the name registered in
  `SECRET_NAMES.DATABASE_URL`. Not an environment variable, because the Cloud
  Run service configuration is readable by anyone with view access on the
  service.
- **Everywhere else** → `DATABASE_URL`.

Pool settings worth knowing, all in that one file:

| Setting | Value | Why |
| --- | --- | --- |
| `max` | **5** | Cloud Run runs many instances against a Supabase pool that is **15 connections** on this compute tier. A large per-instance pool exhausts the server pool as soon as a few instances are warm. |
| Connection string | **transaction pooler, port 6543** | Cloud Run scales to zero and reconnects constantly, which is what the transaction pooler is for. The direct connection is also **IPv6-only**, and Cloud Run egresses over IPv4 — it cannot reach it at all. |
| `ssl` | `{ rejectUnauthorized: false }` | Supabase's pooler presents a certificate signed by an internal CA that is not in Node's trust store. The connection is still encrypted. `?sslmode=disable` in the string turns TLS off, for a local container that has no certificate. |

**Firebase.** `src/config/firebase.ts` is the only file that knows whether
Auth is emulated.

- **`FIREBASE_AUTH_EMULATOR_HOST` set** → the Admin SDK routes to the emulator
  on its own and accepts any project id with no credentials.
- **Absent** → Application Default Credentials: the attached service account
  on Cloud Run, and `gcloud auth application-default login` locally.

---

## The layer rule

```
routes → controllers → services → repositories → Postgres
```

Enforced, not aspirational:

- **Controllers never touch the database.** Every handler in
  `controllers/user.controller.ts` is parse → delegate → respond. Anything
  longer is logic that belongs a layer down.
- **Services never import Express types.** `services/user.service.ts` takes
  validated input and returns response shapes. It knows nothing about
  requests, headers or status codes beyond the `ApiError`s it throws.
- **Repositories are the only place SQL appears.** Nothing above
  `repositories/` imports `pg` or `config/database.js`, so the database can be
  swapped or mocked without a layer above knowing.

A quick check that the rule still holds:

```bash
# Should return nothing.
grep -rlE "from 'pg'|config/database" src/controllers src/services
grep -rlE "from 'express'" src/services src/repositories
```

> `routes/health.routes.ts` imports `checkDatabaseConnectivity` from
> `config/database.js`. That is a liveness probe, not a query — readiness has
> to know whether the dependency answers, and it is the same exception the
> Firestore version had.

### What the migration fixed rather than moved

The Firestore version leaked two database concerns upward. Both are gone
rather than translated:

- `services/user.service.ts` imported `Timestamp` from
  `firebase-admin/firestore` to stamp times, and `utils/timestamps.ts` existed
  only to convert it. Postgres returns `Date`, so both are deleted.
- The service built **dotted Firestore field paths**
  (`coachingPreferences.tone`) so that patching one preference did not replace
  the nested map. That was Firestore's document model showing through a
  service method. The service now hands down a plain nested patch and the
  repository flattens it to three columns.

Validation still sits at the edge: schemas parse in the controller, so no
layer below has to defend against a missing or mistyped field.

---

## Project structure

```
backend/
├── src/
│   ├── index.ts                 Bootstrap, DB connect, graceful shutdown
│   ├── app.ts                   Express assembly, middleware order
│   ├── config/
│   │   ├── env.ts               Zod env schema, fails fast on boot
│   │   ├── database.ts          The only pool. Query, transaction, drain.
│   │   ├── firebase.ts          Admin SDK init for Auth only
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
│   ├── repositories/            The only layer writing SQL
│   ├── models/                  One file per table
│   ├── schemas/                 Zod request validation
│   └── utils/                   api_error, async_handler
├── migrations/
│   ├── 001_initial_schema.sql
│   └── 002_rag_embeddings.sql
├── scripts/                     migrate, seed, get_test_token
├── firebase.json                Auth emulator config
└── Dockerfile
```

Files beyond the structure in the brief, each one concern:

- `config/database.ts` — the pool, the query helpers, and the shutdown drain.
- `config/logger.ts` — the pino instance, so `request_logger.ts` configures
  request logging rather than also constructing the logger.
- `config/version.ts` — resolves the running version from `K_REVISION`.
- `models/locale.model.ts` and `models/localized_text.model.ts` — the `{en, pt}`
  bilingual type and its resolver, imported by every model with bilingual
  content.

`utils/timestamps.ts` is gone: it existed only to convert Firestore
`Timestamp`s, and Postgres returns `Date`.

---

## Data model

Fourteen application tables plus `knowledge_chunks`. `snake_case` in Postgres,
mapped to the camelCase the Flutter models use in **one place per entity** in
the repository layer.

```
users                        id (Firebase uid), email, name, preferred_language,
                             activity, date_of_birth, country_code,
                             accepted_terms, confirmed_info_true,
                             current_principle, cycle_day, day_streak,
                             tone, rhythm, reminders_enabled,
                             created_at, updated_at

onboarding_responses         user_id PK → users
                             ambition_en/pt, challenge_en/pt,
                             main_goals_en/pt, success_vision_en/pt,
                             focus_area_keys[], priority_keys[],
                             motivation_balance, completed_at, updated_at

goals                        id, user_id → users, title, why, principle,
                             target_date, completed_at, created_at, updated_at
  milestones                 id, goal_id → goals, title, due_date, reached_at, position
  action_items               id, goal_id → goals, title, is_done, is_today, position

exercises                    id, principle, title_en/pt, summary_en/pt,
                             duration_minutes, closing_reflection_prompt_en/pt,
                             suggested_action_en/pt, is_active, position
  exercise_steps             id, exercise_id → exercises, position, type,
                             prompt_en/pt, help_en/pt, options jsonb,
                             scale_low_label_en/pt, scale_high_label_en/pt, save_as

exercise_responses           id, user_id → users, exercise_id, principle,
                             step_responses jsonb, reflection, suggested_action,
                             completed_at

coaching_sessions            id, user_id → users, started_at, ended_at,
                             summary, principle
  chat_messages              id, session_id → coaching_sessions, author, text, sent_at

purpose_answers              (user_id → users, prompt_id) PK, answer, updated_at
notifications                id, user_id → users, type, title, body, is_read, received_at
subscriptions                user_id PK → users, tier, status, store,
                             revenue_cat_app_user_id, entitlement_id,
                             trial_started_at, trial_ends_at,
                             current_period_end, updated_at
progress_snapshots           (user_id → users, date) PK, goal_completion,
                             actions_completed, exercises_completed

knowledge_chunks             chunk_id, source, content, embedding vector(1024),
                             language, principle, content_type, source_type,
                             proprietary, created_at
```

Every arrow is `on delete cascade`.

### Shape decisions worth knowing

- **Cascades everywhere.** Account deletion is one statement. This is the
  single biggest structural gain over Firestore, which does not cascade and
  required the delete to walk a hand-maintained list of subcollections.
- **Milestones and action items are real tables.** They were embedded arrays
  on the goal because Firestore made joins awkward. Postgres does not, and a
  milestone as its own row can be updated without rewriting the goal.
- **Bilingual *library* content is paired `_en` / `_pt` columns**, not jsonb.
  The client wants to read and edit exercises in Supabase's table view, where
  paired columns are legible and jsonb is not.
- **Content a person or the coach writes is one column**, in the language it
  was written: goal titles, chat messages, session summaries, purpose answers.
  Under Firestore these were `{en, pt}` maps holding the *same string twice*,
  because `asTyped` duplicated whatever the user typed — the second copy never
  carried information. The API still returns a locale map for them, built by
  the repository, so the Flutter models are unaffected. See the note below.
- **`step_responses` and `options` stay jsonb.** Genuinely variable shape,
  never queried by inner key.
- **Derived state stays derived.** No `is_completed` on a goal — it comes from
  `completed_at`. No `message_count` on a session — it is `count(*)`.
- **`updated_at` is maintained by a trigger**, not by application code, so a
  future call site cannot forget it.
- **Check constraints mirror the TypeScript unions.** The API rejects bad
  input via Zod; the table rejects a bad hand-edit in the Supabase dashboard.
- Indexes on every foreign key used for lookup, plus `goals(user_id,
  completed_at)`, `notifications(user_id, is_read)` and `chat_messages(
  session_id, sent_at)`.

### One divergence to settle in the next pass

`goals.title`, `goals.why`, `chat_messages.text`, `coaching_sessions.summary`,
`notifications.title` / `body`, `purpose_answers.answer` and
`exercise_responses.suggested_action` are **single columns**, as specified.
The corresponding Dart models (`Goal.title`, `ChatMessage.text`, …) are
`Map<String, String>`.

No repository reads those tables yet, so nothing is broken today. When the
goals and coaching passes land, the repository should map one column to
`{ en: value, pt: value }` on the way out — which is exactly what the Dart
`asTyped` helper already does — rather than the columns being widened. The
alternative is a paired column per field, and that only earns its place for
content someone actually maintains in two languages, which this is not.

### `date` columns and time zones

`date_of_birth`, `target_date`, `due_date` and `progress_snapshots.date` are
`date`, not `timestamptz`. node-postgres would parse those into a JS `Date` at
**local** midnight, which serialises a birthday a day early anywhere east of
UTC. `config/database.ts` disables that parser, and the repository converts
explicitly in UTC. Verified on a UTC+5 machine: `1991-04-17` comes back as
`1991-04-17T00:00:00.000Z`.

---

## Field naming: where this differs from the brief

The brief said to match `lib/data/models/` field names exactly so the API and
app agree without a translation layer, and its own data-model block then used
different names for some fields the Flutter side already has. **The Flutter
model wins** on those, since matching it was the stated reason for reading it.

Columns are `snake_case`; the names in the "Used here" column below are the
camelCase side, which is what the API speaks and what the repository maps to.

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

`User.joinedAt` in Dart maps to the `created_at` column; the API returns it as
`joinedAt`.

Two column names differ from the model field for reasons that are Postgres's,
not the brief's, and the repository maps them:

| Column | Model field | Why |
| --- | --- | --- |
| `exercises.position`, `exercise_steps.position`, `milestones.position`, `action_items.position` | `order` | `order` is a reserved word in SQL. |
| `subscriptions.store` | `provider` | The column is `null` until a real purchase happens; the models carry `'none'` for that state. The mapping is one line in `toSubscriptionDocument`. |

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

## Row level security

**RLS is enabled on every table, with no permissive policies anywhere.** This
is what the deny-all `firestore.rules` becomes, and it closes strictly more.

The backend connects as the **service role**, which bypasses RLS, so nothing
in the application changes. What this closes is every other route in: the
Supabase `anon` key, the `authenticated` key, a key that leaks out of a
future admin console, or someone wiring a dashboard straight at the database.
Each of those reads **zero rows from every table**.

Supabase grants `anon` and `authenticated` broad table privileges by default,
so the grants alone are not protection — RLS is what makes them useless.

`knowledge_chunks` matters most of all. It holds proprietary coaching material
that is server-side only and must never be client-reachable, and the client
asked specifically to verify the vector store is not publicly readable. It
gets the same treatment as everything else: RLS on, no policies.

### Verified

Both roles were recreated locally with the broad grants Supabase gives them
(`grant select, insert, update, delete on all tables in schema public`), and
then queried while the service role could see the same rows — so a zero is
RLS, not an empty table:

| Role | Rows visible | Writes |
| --- | --- | --- |
| `anon` | 0 from all 15 tables | refused on all 15 |
| `authenticated` | 0 from all 15 tables | refused on all 15 |
| service role | all rows | permitted |

`schema_migrations` is included: it is created by `scripts/migrate.ts` rather
than by a migration, and the script enables RLS on it for the same reason.

If a direct client read is ever genuinely needed, add **one narrow policy for
that one table**, with an explicit condition. Do not relax the default.

### Indexes

Real indexes now, declared in migration 001 next to the tables they serve,
rather than a separate `firestore.indexes.json` that had to be deployed
independently and could not be tested locally. Postgres does not index every
field automatically the way Firestore did, so each one is deliberate:

| Index | Serves |
| --- | --- |
| `goals (user_id, completed_at)` | "this user's goals, open or done" — the filter rides along rather than being a second lookup |
| `notifications (user_id, is_read)` | the unread badge |
| `chat_messages (session_id, sent_at)` | a transcript is always read in order |
| `milestones (goal_id, position)`, `action_items (goal_id, position)` | goal detail |
| `exercise_steps (exercise_id, position)` | an exercise session |
| `exercises (principle, position) where is_active` | the library, which never lists withdrawn exercises |
| `exercise_responses (user_id, completed_at desc)` | history |
| `coaching_sessions (user_id, started_at desc)` | coaching history |
| `knowledge_chunks (principle)`, `(content_type)` | retrieval filtered before the vector search, per the system prompt spec |
| `knowledge_chunks` ivfflat on `embedding` | cosine similarity |

`progress_snapshots` and `purpose_answers` need no extra index: their
composite primary keys already lead with `user_id`.

> **The ivfflat index will need rebuilding after ingestion.** ivfflat clusters
> the rows that exist when it is built. Built against an empty table it is
> meaningless, and it stays meaningless as rows arrive. After the first
> ingestion run: `reindex index knowledge_chunks_embedding_idx`, with `lists`
> sized to roughly rows/1000. This is noted in the migration too.

---

## Secrets

Every secret lives in **Google Secret Manager** and is referenced by name.
Nothing is in code, nothing is committed, and no secret is ever logged.

`src/config/secrets.ts` resolves secrets by name with a process-lifetime
cache. One entry is registered:

```ts
export const SECRET_NAMES = {
  DATABASE_URL: 'supabase-database-url',
} as const satisfies Record<string, string>;
```

> ### ⚠ Confirm the secret name before the production deploy
>
> `supabase-database-url` is a **placeholder**. The client is adding the
> connection string to Secret Manager; if she names the entry anything else,
> change that one string in `config/secrets.ts` to match.
>
> It must hold the **transaction pooler** string, port 6543 — not the direct
> connection, which is IPv6-only and unreachable from Cloud Run.
>
> A wrong name fails the boot with a clear message rather than running
> degraded, but it fails the *deploy*. Confirm it first.

The Claude key, the embeddings key and the RevenueCat webhook secret become
one line each when those passes land, and nothing else changes:

```ts
const key = await getSecret('ANTHROPIC_API_KEY');
```

Under the emulators only, a value may be supplied as a `SECRET_<KEY>`
environment variable so development does not need Secret Manager access. In
production the value comes from Secret Manager or the request fails.

Cloud Run's service account needs `roles/secretmanager.secretAccessor` on each
secret — granted **per secret**, never project-wide. Rotation takes effect on
the next cold start; `clearSecretCache()` exists if it ever has to happen
without a redeploy.

The database connection string is in Secret Manager rather than in
`--set-env-vars` for the same reason as everything else here: an environment
variable on a Cloud Run service is readable by anyone with view access on the
service, and this one is a database credential.

---

## Security decisions

Notes on the client's checklist, and why each is where it is.

**No secrets in the app, none committed.** All external calls — Claude, the
embeddings provider, RevenueCat — are proxied through this backend, never
client-side. **The app never talks to Postgres**: it has no Supabase client,
no anon key, and RLS would deny it if it did.
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

**No SQL built by concatenation.** Every value reaches Postgres as a `$n`
parameter. The one statement built dynamically — the profile patch — takes its
column names from a fixed map in `user.repository.ts` and its values from
placeholders, so a field name a client sends can never become SQL.

**User data deletable on request, coaching memory included.** See
[`DELETE /v1/me` cascades](#delete-v1me-cascades). Verified against the
seeded persona: 49 rows across twelve tables before, `documentsDeleted: 49`
reported, 0 rows in every one of those tables after, the Auth record gone, and
the shared `exercises` library — which is not the user's data — intact.

**The database is not publicly reachable.** See
[Row level security](#row-level-security): RLS on every table with no
policies, verified with both Supabase roles holding full table grants.

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

Run it against a local database and the Auth emulator. On Linux add
`--add-host` or use `--network host`; on macOS and Windows
`host.docker.internal` resolves to the host:

```bash
docker run --rm -p 8080:8080 \
  -e NODE_ENV=development \
  -e GCP_PROJECT_ID=succenergy-ai-coach \
  -e FIREBASE_PROJECT_ID=succenergy-ai-coach \
  -e DATABASE_URL='postgresql://postgres:postgres@host.docker.internal:5432/succenergy?sslmode=disable' \
  -e FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:9099 \
  succenergy-api:local

curl http://127.0.0.1:8080/v1/health
```

`DATABASE_URL` is not optional here: the container **will not start** without
a reachable database, by design. If the two containers are on the same Docker
network, use the Postgres container's name as the host instead of
`host.docker.internal`.

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
  config and the scripts out of the build context. **The `migrations/`
  directory is excluded too** — migrations are applied deliberately, from a
  machine with the connection string, not by a container starting up. A
  service that migrates on boot migrates once per instance and races itself.

---

## Deploying to Cloud Run

**The service is deployed:**
https://succenergy-api-4612920383.us-east1.run.app — region **`us-east1`**.

Earlier revisions of this file planned `us-central1`, chosen to sit inside
Firestore's `nam5` multi-region. That reason is gone with Firestore. What
matters now is proximity to the **Supabase project's** region, so
co-location should be checked against wherever the client's Supabase project
lives rather than inherited from the old plan.

> **This pass did not deploy anything.** The Postgres cutover was built and
> verified locally; the running revision still serves the Firestore build until
> someone with the tooling redeploys. This machine has no `gcloud` CLI and no
> Docker daemon — see [What could not be done](#what-is-not-built-yet). The
> steps below are what that redeploy needs.

### Before the redeploy

Four things, in order. The first two are the client's; nothing works without
them.

1. **Add the connection string to Secret Manager.** The **transaction pooler**
   string, port 6543. Then confirm the entry's name matches
   `SECRET_NAMES.DATABASE_URL` in `config/secrets.ts`, currently the
   placeholder `supabase-database-url`.
2. **Enable `pgvector`** on the Supabase project, if it is not already —
   Database → Extensions → `vector`.
3. **Run the migrations** against the Supabase database, from a machine that
   has the connection string:
   ```bash
   DATABASE_URL='<transaction pooler string>' npm run migrate
   ```
   Worth running **first**, before the service, exactly as the deny-all
   Firestore rules were: it only ever locks things down, since migration 001
   ends by enabling RLS on every table.
4. **Verify RLS took**, with the project's anon key, before any real data
   exists. It should read nothing from any table.

### IAM

The deploying account needs, on `succenergy-ai-coach`:

| Role | For |
| --- | --- |
| `roles/run.admin` | `gcloud run deploy` |
| `roles/artifactregistry.admin` | the image repository |
| `roles/cloudbuild.builds.editor` | `gcloud builds submit` |
| `roles/iam.serviceAccountAdmin` + `roles/resourcemanager.projectIamAdmin` | creating `succenergy-api` and binding to it |
| `roles/iam.serviceAccountUser` on `succenergy-api` | letting Cloud Run run as it |
| `roles/secretmanager.admin` (or `secretVersionAdder`) | creating the connection string secret |

Project `roles/owner` covers all of these.

`roles/firebaserules.admin` and `roles/datastore.indexAdmin` are **no longer
needed** — there are no Firestore rules or indexes to deploy. Neither is
`roles/datastore.user` on the runtime service account: it reaches Postgres
with a connection string, not with a Google identity. What it does need is
`roles/secretmanager.secretAccessor` **on the connection string secret
specifically**.

### The sequence

```bash
export PROJECT=succenergy-ai-coach
export REGION=us-east1
export IMAGE=$REGION-docker.pkg.dev/$PROJECT/succenergy/api:$(git rev-parse --short HEAD)

# 1. Enable the APIs. Firestore's is gone; Secret Manager's is now load-bearing.
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  --project $PROJECT

# 2. Artifact Registry repository, once
gcloud artifacts repositories create succenergy \
  --repository-format=docker --location=$REGION \
  --project $PROJECT

# 3. A dedicated runtime service account, not the default compute one
gcloud iam service-accounts create succenergy-api \
  --display-name "Succenergy API runtime" --project $PROJECT

# 4. Access to the connection string, per secret — never project-wide
gcloud secrets add-iam-policy-binding supabase-database-url \
  --member serviceAccount:succenergy-api@$PROJECT.iam.gserviceaccount.com \
  --role roles/secretmanager.secretAccessor \
  --project $PROJECT

# 5. Verify the image builds locally before spending a remote build on it
docker build -t succenergy-api:local .

# 6. Build and push
gcloud builds submit --tag $IMAGE --project $PROJECT

# 7. Deploy. Note what is NOT here: DATABASE_URL. The connection string comes
#    from Secret Manager, and boot refuses to start if the variable is set
#    with NODE_ENV=production.
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

> **`--max-instances 10` and the pool are related.** Each instance opens up to
> **5** connections and Supabase's pool on this compute tier is **15**. Ten
> instances all warm would want fifty. In practice they are rarely all warm
> and the transaction pooler multiplexes, but **raising `--max-instances` or
> `max` in `config/database.ts` without checking the Supabase pool size is how
> this service starts failing under load.** If instances need to scale higher,
> raise the Supabase compute tier first.

### Checking the service once it is up

```bash
SERVICE=$(gcloud run services describe succenergy-api --region $REGION \
  --project $PROJECT --format 'value(status.url)')

curl -i $SERVICE/v1/health            # 200
curl -i $SERVICE/v1/health/ready      # 200, proves the runtime SA reached the secret AND Postgres
curl -i $SERVICE/v1/me                # 401, no token
curl -sI $SERVICE/v1/health | grep -i strict-transport-security
curl -sI http://${SERVICE#https://}/v1/health   # 308 to https
```

`/v1/health/ready` is the one that matters most, and it now proves two things
at once: the runtime service account could read the connection string from
Secret Manager, and it could reach Supabase over IPv4. A 503 means one of
those failed — the boot logs say which, by name.

If the **revision never goes healthy at all**, that is the fail-fast working:
the database was unreachable and the service refused to start rather than
serving 500s. The previous revision keeps serving. Check the revision logs for
`Cannot reach the database`.

Then confirm in Cloud Logging that request log lines carry no email addresses,
names, tokens, connection strings or user content:

```bash
gcloud logging read \
  'resource.type="cloud_run_revision" AND resource.labels.service_name="succenergy-api"' \
  --limit 50 --project $PROJECT
```

**Authenticated verification waits for the Flutter side.** A real ID token has
to come from the app's own sign-in against the production Auth instance. Do
**not** create a test user in production Auth to get one — `401` on a
tokenless request is sufficient proof the middleware is active.

### Notes for whoever runs this

- **Do not set `DATABASE_URL` on the service.** Boot refuses to start if it is
  set with `NODE_ENV=production`, which is deliberate: an environment variable
  on a Cloud Run service is readable by anyone with view access, and this one
  is a database credential.
- **Do not set `FIREBASE_AUTH_EMULATOR_HOST`** either, for the same
  refuses-to-start reason.
- **Use the transaction pooler string, port 6543.** The direct connection is
  IPv6-only; Cloud Run egresses over IPv4 and simply cannot reach it. This is
  the single most likely cause of a failed first deploy.
- **Not** the default compute service account. It carries `roles/editor`
  across the project.
- `--allow-unauthenticated` is correct: the service is public at the network
  level and enforces Firebase ID tokens itself. Cloud Run IAM would reject
  mobile clients, which have no Google identity.
- `--min-instances 0` scales to zero and accepts cold starts. A cold start now
  includes a Secret Manager read and a Postgres connect; raise to 1 if
  first-request latency matters more than idle cost.

---

## What is not built yet

Out of scope for this pass, listed so nobody looks for them:

**On top of this schema, next:** the goals, exercises, progress, purpose,
notifications and admin endpoints. The tables are there and the cascades are
correct; what is missing is the repositories, services and routes above them.

**RAG.** `knowledge_chunks` exists and is empty. No ingestion, no embedding
calls, no retrieval. The client's knowledge base has not arrived. When it
does, ingestion is a script run against an existing table rather than a schema
change — and the ivfflat index needs rebuilding once rows are in it.

**Claude integration.** Nothing calls the API yet.

**RevenueCat.** The `subscriptions` table is written once, at account
creation, with the default trial state. The SDK, the webhook and the
entitlement gating are a later pass and cannot be built until the app is in
both stores.

**Push notifications.** The `notifications` table exists; FCM does not.

Email sending. The Flutter app still runs entirely on its mock repositories —
swapping them for this API starts next.

Auth flows — register, log in, password reset — are client-side by design and
are not coming here. This backend verifies tokens; it does not issue them.

### Not done in this pass, and why

- **The redeploy.** The Postgres cutover is built, migrated and verified
  locally, but nothing was deployed: this machine has no `gcloud` CLI and no
  working Docker daemon. **The live service is still running the Firestore
  build.** See [Deploying to Cloud Run](#deploying-to-cloud-run) for the exact
  sequence and the two prerequisites that are the client's.
- **Migration 002 has never been applied end to end.** The local Postgres
  available here has no pgvector, so `create extension vector` stops it —
  correctly, and the transaction rolls back cleanly. Everything in the file
  *except* the extension and the ivfflat index was verified by substitution
  in a throwaway database. It should apply cleanly on Supabase, where the
  extension exists, but that is an expectation and not a verified fact.
- **The Docker image build is still unverified**, third pass in a row, same
  cause: no daemon on this machine.
