# Succenergy AI Coach — Frontend Audit

**Date:** 2026-08-29
**Method:** every file under `lib/` opened and read. No file judged complete on filename or plan.
**Scope of this pass:** verification and reporting only. Nothing was fixed.

**Headline:** the build is substantially more complete and more disciplined than a typical scaffold — 151 Dart files, 16,891 lines, `flutter analyze` clean, zero hardcoded UI strings, zero raw hex colours outside the token file, zero emoji, zero `print`/`TODO`/`FIXME`. But **five finished screens are unreachable by navigation**, **Goals cannot be edited or deleted**, and **AI Blue leaks into every text field in the app**. Details below.

---

## PART 1 — SCREEN INVENTORY

| # | Screen | File | Status | What is actually there |
|---|--------|------|--------|------------------------|
| 1 | Splash / Launch | [splash_screen.dart](lib/features/splash/splash_screen.dart) | **COMPLETE** | Four-stage interval animation (bloom → symbol → wordmark → rule), routes on `AuthRepository.isLoggedIn` at [:66](lib/features/splash/splash_screen.dart#L66) |
| 2 | Welcome | [welcome_screen.dart](lib/features/welcome/welcome_screen.dart) | **COMPLETE** | Logo, wordmark, five-span tagline, Tânia Tomé attribution, "Start your Journey" CTA, log-in link, custom Earth-glow painter behind |
| 3 | Language Selection | [language_selection_screen.dart](lib/features/language_selection/language_selection_screen.dart) | **COMPLETE** | EN/PT cards, `locale.setLocale()` applies app-wide instantly on tap ([:79](lib/features/language_selection/language_selection_screen.dart#L79)) |
| 4 | Registration / Login | [register_screen.dart](lib/features/auth/register_screen.dart), [login_screen.dart](lib/features/auth/login_screen.dart), [forgot_password_screen.dart](lib/features/auth/forgot_password_screen.dart) | **COMPLETE** | Per-field validation with localised errors ([register_screen.dart:65-80](lib/features/auth/register_screen.dart#L65-L80)), busy state, shared `AuthScaffold` |
| 5 | Onboarding / Assessment | [onboarding_screen.dart](lib/features/onboarding/onboarding_screen.dart) + [onboarding_provider.dart](lib/features/onboarding/onboarding_provider.dart) | **COMPLETE** | 7 questions + summary step, progress bar, per-step `canAdvance` gating, `save()` persists to `UserRepository` |
| 6 | Profile | [profile_screen.dart](lib/features/profile/profile_screen.dart) | **PARTIAL** | Editable name/email, tone, rhythm, reminders + onboarding answers echoed back — but only **5 of 7** answers are shown (see Part 2) |
| 7 | Home / Dashboard | [dashboard_screen.dart](lib/features/dashboard/dashboard_screen.dart) | **COMPLETE** | Greeting, Cycle Ring, quick stats, today's action, active goal, coach entry, quick-access row — all staggered |
| 8 | Purpose | [purpose_screen.dart](lib/features/purpose/purpose_screen.dart) + [purpose_provider.dart](lib/features/purpose/purpose_provider.dart) | **COMPLETE** | Interactive prompt cards, answers saved through `savePurposeAnswer()`, re-editable. Not static text |
| 9 | Goals | [goals_screen.dart](lib/features/goals/goals_screen.dart) | **PARTIAL** | Active/completed tabs, create sheet, principle categorisation — **no edit, no delete** (see Part 2) |
| 10 | Goal Detail / Action Plan | [goal_detail_screen.dart](lib/features/goals/goal_detail_screen.dart) | **COMPLETE** | Title, why-it-matters, milestone timeline, checkable actions, progress, coach hand-off |
| 11 | Exercises | [exercises_screen.dart](lib/features/exercises/exercises_screen.dart) | **COMPLETE** | 9 exercises, principle filter row, all seven principles represented |
| 12 | Exercise Session | [exercise_session_screen.dart](lib/features/exercises/exercise_session_screen.dart) | **PARTIAL** | Step-by-step, all three input types, suggested action → goal. **Closing reflection is collected then discarded** (see Part 2) |
| 13 | AI Coach | [ai_coach_screen.dart](lib/features/ai_coach/ai_coach_screen.dart) | **COMPLETE** | 12-message seeded conversation, keyword-matched replies, thinking indicator, suggestion chips, ambient drift backdrop |
| 14 | Coaching History | [coaching_history_screen.dart](lib/features/coaching_history/coaching_history_screen.dart), [session_detail_screen.dart](lib/features/coaching_history/session_detail_screen.dart) | **COMPLETE** | Session rows with summaries → full transcript view |
| 15 | Progress | [progress_screen.dart](lib/features/progress/progress_screen.dart) | **COMPLETE** | Stat tiles, cycle summary, three custom-painted charts, milestone achievements. Charts are static-sourced (see Part 2) |
| 16 | Notifications / Reminders | [notifications_screen.dart](lib/features/notifications/notifications_screen.dart) | **COMPLETE** | Inbox / preferences tabs, mark-all-read, per-type switches |
| 17 | Subscription / Plans | [subscription_screen.dart](lib/features/subscription/subscription_screen.dart) | **COMPLETE** | $0 / $9.99 monthly / $79.99 annual with $39.89 saving flag, recommended badge, comparison table |
| 18 | Settings | [settings_screen.dart](lib/features/settings/settings_screen.dart) | **COMPLETE (UNREACHABLE)** | Language, notifications, profile, password, biometric, plan, help, admin, logout, delete — all wired. No screen links to it |
| 19 | Help / About | [help_about_screen.dart](lib/features/help_about/help_about_screen.dart) | **PARTIAL (UNREACHABLE)** | Logo, wordmark, about, Tânia Tomé attribution, 6 FAQ accordions, contact — Terms and Privacy are dead buttons |
| 20 | Admin / Management | [admin_gate_screen.dart](lib/features/admin/admin_gate_screen.dart), [admin_dashboard_screen.dart](lib/features/admin/admin_dashboard_screen.dart) | **PARTIAL (UNREACHABLE)** | Code gate (`SUCC-ADMIN`), user directory with search, content library, notification composer, stat strip. Visual distinction is weak |

### Reachability from Splash without editing code

**15 of 20 reachable.** The traversable graph:

```
Splash → Welcome → Language → Register → Onboarding → Dashboard
Dashboard → { Goals → Goal Detail, Exercises → Exercise Session,
              AI Coach → Coaching History → Session Detail,
              Progress, Purpose, Notifications, Profile }
Welcome → Login → Forgot Password
```

**Unreachable (5 screens, all finished):**

| Screen | Route | Why orphaned |
|--------|-------|--------------|
| Settings | `/settings` | Nothing calls `context.go/push(Routes.settings)` except [admin_dashboard_screen.dart:107](lib/features/admin/admin_dashboard_screen.dart#L107)'s back button — which is itself only reachable *from* Settings. A closed loop with no entrance. |
| Subscription | `/subscription` | Only entry is [settings_screen.dart:177](lib/features/settings/settings_screen.dart#L177) |
| Help / About | `/help` | Only entry is [settings_screen.dart:190](lib/features/settings/settings_screen.dart#L190) |
| Admin Gate | `/admin` | Only entry is [settings_screen.dart:194](lib/features/settings/settings_screen.dart#L194) |
| Admin Console | `/admin/console` | Only entry is the gate above |

The bottom nav has 5 tabs (Home, Goals, Coach, Exercises, Progress); the Dashboard quick-access row has 4 (Goals, Exercises, Purpose, Progress); [greeting_header.dart](lib/features/dashboard/widgets/greeting_header.dart) exposes notifications and profile. **None of them is a gear icon.** This is a one-line fix but it currently hides a quarter of the app.

---

## PART 2 — FUNCTIONAL VERIFICATION

### Navigation

| Check | Verdict | Evidence |
|-------|---------|----------|
| Full journey clickable end to end | **NO** | Splash→…→Progress works. **Subscription and Settings cannot be reached at all.** The chain breaks after Progress. |
| Routes in one file, referenced by constants | **YES** | [routes.dart](lib/app/routes.dart) holds every path; [router.dart](lib/app/router.dart) is the only route table. Grep for raw path literals outside these two files returns nothing. |
| Custom page transitions | **YES** | [page_transitions.dart](lib/core/motion/page_transitions.dart) — `fadeThrough` (fade + 1.02 scale) and `riseOver`. Every `GoRoute` uses `pageBuilder`; no route falls back to `MaterialPage`. |

### Localization

| Check | Verdict | Evidence |
|-------|---------|----------|
| Every user-facing string through the EN/PT map | **YES** | `grep -rE "Text\(\s*'"` across `lib/` returns **zero** hits. 401 keys in EN, 401 in PT, **sets identical, nothing missing either way**. |
| Hardcoded English in widget files | **4, all deliberate** | Field *hints* only, and all are persona values: [forgot_password_screen.dart:76](lib/features/auth/forgot_password_screen.dart#L76), [login_screen.dart:91](lib/features/auth/login_screen.dart#L91), [register_screen.dart:97](lib/features/auth/register_screen.dart#L97) and [:105](lib/features/auth/register_screen.dart#L105) — `Marisa Chissano` / `marisa.chissano@lumeconsult.co.mz`. Not English prose, but they don't localise. |
| Language switch updates whole app immediately | **YES** | `LocaleProvider` is a `ChangeNotifier` above `MaterialApp` ([app.dart:23](lib/app/app.dart#L23)); `context.tr` reads it via `watch`, so every subscriber rebuilds. |
| Real Portuguese or machine translation | **Real, native-quality European Portuguese** | Idiom, not gloss. Three examples: <br>• `settings` → **"Definições"** (PT-PT), not the Brazilian "Configurações" <br>• `welcome.login` → **"Já tenho conta"** — the natural elision, not a literal "Eu já tenho uma conta" <br>• [mock_coach_repository.dart:150](lib/data/mock/repositories/mock_coach_repository.dart#L150) → *"energia em baixo é informação e não falhanço… Reponha o de amanhã às 07:30 e julgue-o na quinta, não hoje."* — "falhanço", "reponha", clitic "julgue-o". No machine produces that. |
| Succenergy / Praxis / principle names untranslated | **YES** | All seven principle keys hold identical values in both maps. 26 keys total are intentionally identical: the 7 principles, `Succenergy AI Coach`, `Praxis`, `AI COACH`, `Email`, `min`, the author's name. Verified by diffing the two maps. |

**One PT typo:** [mock_data.dart:1296](lib/data/mock/mock_data.dart#L1296) — *"O relançamento e a razão"* should be *"é a razão"*.

### Onboarding

**All 7 present.** As implemented, in order:

| # | Question (EN) | Input | Required |
|---|---------------|-------|----------|
| 1 | What do you want to achieve? | free text | yes |
| 2 | Which area of your life needs the most energy? | multi-select, max 2 | yes |
| 3 | What is challenging you right now? | free text | yes |
| 4 | What are your priorities? | multi-select, max 3 | yes |
| 5 | What are your main goals? | free text | yes |
| 6 | What motivates you? (Inner drive ↔ People I carry) | scale | **no** — `canAdvance` returns `true` unconditionally at [onboarding_provider.dart:72](lib/features/onboarding/onboarding_provider.dart#L72) |
| 7 | What does success look like for you? | free text | yes |

**Do answers persist to Profile?** **PARTIAL — YES for 5 of 7.** `save()` writes the whole `OnboardingResponse` to `MockUserRepository._response` ([:45-48](lib/data/mock/repositories/mock_user_repository.dart#L45-L48)), and Profile reads it back. But [coaching_profile_section.dart](lib/features/profile/widgets/coaching_profile_section.dart) renders only *ambition, focus areas, challenge, priorities, success vision*. **Q5 (`mainGoals`) and Q6 (`motivationBalance`) are saved and never shown.** A client who types a main goal in onboarding will not find it on Profile.

### Seven Principles

| Check | Verdict | Evidence |
|-------|---------|----------|
| Defined once as a single source of truth | **YES** | [principle.dart](lib/data/models/principle.dart) — a 7-value enum with `position`, `labelKey`, `descriptionKey`, `next`. |
| Goals, Exercises, Progress all reference it | **YES** | 15 files import `models/principle.dart`, including [goals_provider.dart](lib/features/goals/goals_provider.dart), [exercises_provider.dart](lib/features/exercises/exercises_provider.dart), [progress_screen.dart](lib/features/progress/progress_screen.dart), [principle_bars_painter.dart](lib/features/progress/widgets/principle_bars_painter.dart). No duplicated principle-name string lists anywhere. |

### Cycle Ring

| Check | Verdict | Evidence |
|-------|---------|----------|
| Real `CustomPainter` | **YES** | [cycle_ring_painter.dart](lib/core/widgets/cycle_ring/cycle_ring_painter.dart), 146 lines, 5° gaps, arithmetic arc layout |
| Shows position in cycle | **YES** | `activeIndex` + `completedCount`; Dashboard passes `user.currentPrinciple.index` |
| Animates arcs on load | **YES** | `_draw` controller, 900 ms, per-segment reveal at [painter:53](lib/core/widgets/cycle_ring/cycle_ring_painter.dart#L53) |
| Pulses active segment | **YES** | Second controller `_pulse.repeat(reverse: true)` on `AppCurves.ambient` |
| Used on Dashboard and Progress | **YES — and Purpose** | [dashboard_screen.dart:140](lib/features/dashboard/dashboard_screen.dart#L140), [cycle_summary_card.dart:30](lib/features/progress/widgets/cycle_summary_card.dart#L30), [purpose_screen.dart:135](lib/features/purpose/purpose_screen.dart#L135) |

### AI Coach

| Check | Verdict | Evidence |
|-------|---------|----------|
| Multi-turn mock conversation | **YES** | 12 seeded messages (7 coach / 5 user) at [mock_data.dart:1184](lib/data/mock/mock_data.dart#L1184). Live replies are keyword-matched across 4 intents + a 4-entry rotating fallback, EN and PT ([mock_coach_repository.dart:80-115](lib/data/mock/repositories/mock_coach_repository.dart#L80-L115)) |
| References the user's actual goal by name | **YES** | "the Q4 relaunch", "one email to Aleixo", "the internal preview, twelve days out" — all match `goal-relaunch` and its milestones |
| Thinking indicator with staggered animation | **YES** | [thinking_indicator.dart](lib/features/ai_coach/widgets/thinking_indicator.dart) — 3 AI-Blue dots on one 1200 ms repeating controller, phase-offset per dot |
| Copy avoids AI-assistant tells | **YES** | No "As an AI", no "I'd be happy to", no bullets, no exclamation marks anywhere in the coach corpus. Two quotes: |

> "Stuck usually means the next step is too large to begin. On the Q4 relaunch the next step is one email to Aleixo. What is the ten-minute version of it you would send before lunch?" — [mock_coach_repository.dart:134](lib/data/mock/repositories/mock_coach_repository.dart#L134)

> "Three weeks in you have closed one goal and reached seven milestones. You are in Praxis and holding there. The pattern is that you finish the work and then wait before showing it. What changes if showing it counts as finishing?" — [mock_coach_repository.dart:155](lib/data/mock/repositories/mock_coach_repository.dart#L155)

This is the strongest writing in the build.

### Exercise Session

| Check | Verdict | Evidence |
|-------|---------|----------|
| Data-driven from `Exercise` model | **YES** | [session_step_view.dart](lib/features/exercises/widgets/session_step_view.dart) switches on `step.type`; no exercise content in any widget |
| All three input types | **YES** | `freeText` ×17, `singleChoice` ×4, `scale` ×4 across the 9 exercises |

**Defect:** the closing reflection is **discarded**. `_reflection` is declared at [exercise_session_screen.dart:36](lib/features/exercises/exercise_session_screen.dart#L36), rendered at [:201](lib/features/exercises/exercise_session_screen.dart#L201) — and the `completeExercise` call at [:90-101](lib/features/exercises/exercise_session_screen.dart#L90-L101) iterates `exercise.steps` only. Whatever the user writes in the reflection box is thrown away on Finish.

### Mock data coherence

**Persona is consistent and genuinely good.** Marisa Chissano, `lumeconsult.co.mz`, Maputo-plausible names throughout (Aleixo Muianga, Helena Sitoe, Nuno Bragança, Dália Fernandes).

The `goal-relaunch` thread traced across screens:

| Surface | Appears? | Evidence |
|---------|----------|----------|
| Dashboard active-goal card | **YES** | `p.leadGoal` → "Lead the Q4 brand relaunch end to end" |
| Goals list | **YES** | Same object, 4 goals / 16 milestones / 14 actions |
| AI Coach, by name | **YES** | Named in the seeded conversation and in 3 of 4 keyword replies |
| Progress | **PARTIAL** | Milestones *are* derived from the same goals ([mock_progress_repository.dart:26-29](lib/data/mock/repositories/mock_progress_repository.dart#L26-L29)) — but from the **static** `MockData.goals`, not the live `MockGoalsRepository._goals`. Checking a milestone on Goal Detail does not move Progress. `headlineStats` and `practiceByPrinciple` are hardcoded literals ([mock_data.dart:1646-1662](lib/data/mock/mock_data.dart#L1646-L1662)) and never respond to anything the user does. |
| Notifications | **YES** | "Sending it to Aleixo has been today's action for two days" |

**Placeholder text found: none.** Full-repo case-insensitive scan for `lorem ipsum`, `goal 1`, `item 2`, `user@example.com`, `test user`, `john doe`, `placeholder`, `dummy` returns **zero real hits** — the only matches are the Portuguese words "Todos" / "todo o" and "metodologia".

---

## PART 3 — BRAND COMPLIANCE

### Colour

**Hex literals outside `app_colors.dart`: ZERO.** `grep -rn "0xFF" lib/ --exclude=app_colors.dart` returns nothing.

**Bare `Colors.*` Material constants: ZERO.** Every match in the codebase is `AppColors.*`.

**Token accuracy — all seven exact:**

| Token | Required | In [app_colors.dart](lib/core/theme/app_colors.dart) | ✓ |
|-------|----------|------|---|
| Gold | `#D4AF37` | `Color(0xFFD4AF37)` L15 | ✓ |
| AI Blue | `#00E5FF` | `Color(0xFF00E5FF)` L18 | ✓ |
| Deep Navy | `#0A1628` | `Color(0xFF0A1628)` L21 | ✓ |
| Navy Elevated | `#111E33` | `Color(0xFF111E33)` L24 | ✓ |
| Navy Deep | `#060D1A` | `Color(0xFF060D1A)` L27 | ✓ |
| Text Primary | `#F5F7FA` | `Color(0xFFF5F7FA)` L30 | ✓ |
| Text Secondary | `#8A94A6` | `Color(0xFF8A94A6)` L33 | ✓ |

Two beyond the seven: `error #D4483C` (L36) and `transparent` (L39), plus five derived opacity getters. The error hue is an eighth brand colour that was not in the spec — defensible, but it is a new value.

**Gold and AI Blue on the same component — 3 findings:**

1. **[message_bubble.dart:66,78](lib/features/ai_coach/widgets/message_bubble.dart#L66-L78)** — inside the AI Coach, coach bubbles carry `blueHairline`, user bubbles carry `gold.withValues(0.10)` + `goldHairline`. The message list shows both accents side by side.
2. **[transcript_bubble.dart:33,44](lib/features/coaching_history/widgets/transcript_bubble.dart#L33-L44)** — identical pattern in the history transcript.
3. **[app_bottom_nav.dart:63-65](lib/core/widgets/app_bottom_nav.dart#L63-L65)** — one nav bar, four gold tabs and one AI-Blue tab.

All three are deliberate speaker/section coding rather than accident, and each is documented in its file's header comment. But they do violate the letter of "the two never accent the same element", so the client should be told they were conscious calls, not slips.

**AI Blue used where it is not AI-related — 2 findings:**

1. **[app_text_field.dart:106](lib/core/widgets/inputs/app_text_field.dart#L106) + [app_theme.dart:138,142](lib/core/theme/app_theme.dart#L138)** — `cursorColor: AppColors.aiBlue` and the global focused-input border are AI Blue. **Every text field in the app** — the registration name field, the goal-creation sheet, the profile email field — glows AI Blue on focus. This is the clearest breach of "AI Blue means artificial intelligence and nothing else" and it is the one worth fixing.
2. **[earth_glow_painter.dart:62-134](lib/features/welcome/widgets/earth_glow_painter.dart#L62-L134)** — the Welcome screen's Earth atmosphere is AI Blue. Arguably traceable to the approved reference artwork; flagging for a decision, not as an error.

**Gold used inside the AI Coach interface: YES** — the user bubble, per finding 1 above. Nothing else in `features/ai_coach/` uses gold.

### Typography

| Check | Verdict | Evidence |
|-------|---------|----------|
| Exo 2 primary | **YES** | 12 of 18 styles in [app_typography.dart](lib/core/theme/app_typography.dart) are `_exo(...)`, covering every display, headline, title, body, caption and label |
| Orbitron only for small-caps accents, eyebrows, metric labels, AI Coach title | **YES** | Exactly 6 Orbitron styles: `eyebrow` (10 px), `metricLabel` (9 px), `metricValue` (24 px), `metricValueSmall` (18 px), `aiTitle` (17 px), `principleBadge` (9 px). All letterspaced, all label/numeric register |
| Orbitron on body or paragraph text | **NONE FOUND** | No Orbitron style is applied to any multi-sentence string |
| Anywhere a default font would render | **NONE FOUND** | `textTheme` is fully populated — all 15 Material slots mapped ([app_theme.dart:75-91](lib/core/theme/app_theme.dart#L75-L91)). Zero raw `TextStyle(` constructions outside `app_typography.dart`. Zero `GoogleFonts` calls outside it. `allowRuntimeFetching = false` with both faces bundled in `assets/google_fonts/`, so no network fallback either |

### Assets

| Check | Verdict | Evidence |
|-------|---------|----------|
| Only the two branding widgets touch the assets | **YES** | `AssetPaths.logoSymbolSvg` referenced once ([succenergy_logo.dart:53](lib/core/widgets/branding/succenergy_logo.dart#L53)), `AssetPaths.logoWordmark` once ([succenergy_wordmark.dart:40](lib/core/widgets/branding/succenergy_wordmark.dart#L40)). No other file names an `assets/branding` path |
| SVG via `SvgPicture.asset`, never `Image.asset` | **YES** | The SVG symbol uses `SvgPicture.asset`. The one `Image.asset` in the codebase is the wordmark, which is a **PNG** — correct, not a violation |
| Wordmark only on `#0A1628` / `#060D1A` | **YES — all 3 placements** | [splash_screen.dart:145](lib/features/splash/splash_screen.dart#L145) on `navyDeep`; [welcome_screen.dart:109](lib/features/welcome/welcome_screen.dart#L109) on `navyDeep`; [help_about_screen.dart:62](lib/features/help_about/help_about_screen.dart#L62) on `navyDeep`. All three use `fullBleed: true`, so the baked-in panel runs past the viewport edges |
| Tint / ColorFilter / blend mode / opacity on logo or wordmark | **NONE** | Zero `ColorFilter` or `BlendMode` in the entire repo. The gold bloom is a sibling layer behind the mark ([succenergy_logo.dart:31-51](lib/core/widgets/branding/succenergy_logo.dart#L31-L51)), never a filter on it. `Opacity` is applied to the splash *wrapper* during entrance animation only |
| Any additional logo/icon-mark/brand illustration created | **NO new brand mark.** Two decorative painters exist — [earth_glow_painter.dart](lib/features/welcome/widgets/earth_glow_painter.dart) (planet horizon) and [cycle_ring_painter.dart](lib/core/widgets/cycle_ring/cycle_ring_painter.dart) (the seven-principle ring). Neither is a logo or an alternative Succenergy mark |

**Loose end:** `assets/design_reference/welcome_screen_reference.png` is on disk but **not declared** in `pubspec.yaml` and not referenced in code. Harmless, but it is an unshipped stray file.

### Emojis

**ZERO.** Byte-level scan of all 151 Dart files for 3- and 4-byte UTF-8 sequences (the emoji and dingbat planes) returns exactly one hit — [mock_data.dart:1532](lib/data/mock/mock_data.dart#L1532), which is `U+2019`, a typographic right single quote in *"today's action"*. Correct punctuation, not an emoji.

### Depth treatment

**Zero black or default-colour `BoxShadow`.** All seven `BoxShadow` constructions in the repo live in [app_shadows.dart](lib/core/theme/app_shadows.dart), and every one names a token:

| Shadow | Colour |
|--------|--------|
| `elevation` | `navyDeep @ 0.55` (recessed navy, not black) |
| `goldGlow` / `goldGlowStrong` | `gold @ 0.16 / 0.34` |
| `blueGlow` / `blueGlowStrong` | `aiBlue @ 0.16 / 0.32` |
| `logoBloom` | `gold @ 0.22` |
| `errorGlow` | `error @ 0.24` |

No widget file constructs its own shadow. This is exactly the specified treatment.

---

## PART 4 — STRUCTURE

### `lib/` tree

```
lib/
├── main.dart                       # the only file naming a repository implementation
├── app/            app.dart · router.dart · routes.dart
├── core/
│   ├── constants/  app_constants.dart · asset_paths.dart
│   ├── localization/ app_strings.dart · locale_provider.dart · string_extensions.dart
│   ├── motion/     app_curves.dart · app_durations.dart · page_transitions.dart
│   ├── theme/      app_colors.dart · app_shadows.dart · app_spacing.dart
│   │               app_theme.dart · app_typography.dart
│   └── widgets/    animated_reveal · app_bottom_nav · empty_state · principle_badge
│                   progress_indicators · screen_background · section_eyebrow
│                   branding/{succenergy_logo, succenergy_wordmark}
│                   buttons/{primary, secondary, text_link}
│                   cards/{glow_card, gradient_border_card}
│                   cycle_ring/{cycle_ring, cycle_ring_painter}
│                   inputs/{app_switch, app_text_field, preference_choice_row, scale_input}
├── data/
│   ├── models/     14 files (principle, goal, milestone, action_item, exercise,
│   │               exercise_step, exercise_response, chat_message, coaching_session,
│   │               onboarding_response, app_notification, progress_snapshot,
│   │               subscription_plan, user)
│   ├── repositories/ 8 abstract interfaces
│   └── mock/       mock_data.dart + repositories/ (8 implementations)
└── features/       18 folders — admin · ai_coach · auth · coaching_history · dashboard
                    exercises · goals · help_about · language_selection · notifications
                    onboarding · profile · progress · purpose · settings · splash
                    subscription · welcome
```

151 Dart files, 16,891 lines.

### Files over 250 lines

| Lines | File | Assessment |
|-------|------|-----------|
| 1,793 | [mock_data.dart](lib/data/mock/mock_data.dart) | Pure bilingual content, no logic. Acceptable — though it is the single largest file by 2× and would be easier to maintain split by domain |
| 978 | [app_strings.dart](lib/core/localization/app_strings.dart) | 802 key/value pairs. Acceptable for the same reason |
| 286 | [router.dart](lib/app/router.dart) | The full route table. Appropriate |
| 265 | [app_theme.dart](lib/core/theme/app_theme.dart) | 14 extracted `_xxxTheme()` factories. Appropriate |

**No screen or widget file exceeds 250 lines.** Largest is [profile_screen.dart](lib/features/profile/profile_screen.dart) at 247.

### `build()` methods over 60 lines

7 of ~150. All are declarative widget trees with no logic:

| Lines | Location |
|-------|----------|
| 84 | [language_selection_screen.dart:26](lib/features/language_selection/language_selection_screen.dart#L26) |
| 78 | [scale_input.dart:31](lib/core/widgets/inputs/scale_input.dart#L31) |
| 73 | [goal_card.dart:23](lib/features/goals/widgets/goal_card.dart#L23) |
| 71 | [onboarding_summary.dart:20](lib/features/onboarding/widgets/onboarding_summary.dart#L20) |
| 71 | [admin_gate_screen.dart:48](lib/features/admin/admin_gate_screen.dart#L48) |
| 70 | [exercise_card.dart:20](lib/features/exercises/widgets/exercise_card.dart#L20) |
| 64 | [onboarding_screen.dart:29](lib/features/onboarding/onboarding_screen.dart#L29) |

The larger screens all delegate to `_sections()` / `_groups()` helpers instead — a pattern applied consistently.

### Cross-feature imports

**NONE.** `grep -rn "import '../../features/" lib/features` returns zero. No feature reaches into another.

### Catch-all files

**NONE.** `lib/core/constants/` holds exactly two files, both narrow: [app_constants.dart](lib/core/constants/app_constants.dart) (10 named values, each documented) and [asset_paths.dart](lib/core/constants/asset_paths.dart) (2 paths). No `utils.dart`, `helpers.dart` or `common.dart` anywhere.

### Feature folder shape

**Consistent across all 18.** Every folder is `<feature>_screen.dart` + optional `<feature>_provider.dart` + optional `widgets/`. Nothing else appears at feature root.

Six features carry a provider (ai_coach, dashboard, exercises, goals, onboarding, purpose). The rest use local `setState` — a defensible call for read-mostly screens, though **progress**, **profile**, **settings** and **admin** each hand-roll `initState` + `addPostFrameCallback` + `_load()` + `mounted` guards, duplicating the same ~15 lines four times.

### Widget files importing `data/mock/`

**NONE.** `grep -rn "data/mock" lib/features lib/core` returns zero. Widgets see interfaces only.

### Mock repositories bound in exactly one place

**YES.** All eight `Provider<XRepository>(create: (_) => MockX())` bindings are in [main.dart:45-58](lib/main.dart#L45-L58). No mock class name appears anywhere else outside `data/mock/`.

### `flutter analyze`

```
Analyzing succenergy_ai_coach...
No issues found! (ran in 16.4s)
```

Clean, against `flutter_lints ^5.0.0`.

### `print(` / `TODO` / `FIXME` / commented-out code

**All zero.** `grep -rn "print(\|debugPrint(\|// TODO\|// FIXME\|TODO:\|FIXME:" lib` returns nothing, as does a scan for commented-out call expressions.

**Dead callbacks — 2:** [help_about_screen.dart:167](lib/features/help_about/help_about_screen.dart#L167) and [:171](lib/features/help_about/help_about_screen.dart#L171). Terms of use and Privacy policy are `onPressed: () {}`. They render as live links and do nothing.

**Dead flag — 1:** `AuthRepository.needsOnboarding` is set by `register()`/`logIn()` ([mock_auth_repository.dart:38](lib/data/mock/repositories/mock_auth_repository.dart#L38)) and **never read by anything**. The router does not consult it; Splash checks only `isLoggedIn`.

---

## PART 5 — MOTION

| Motion | Implemented | Where |
|--------|-------------|-------|
| Splash logo bloom sequence | **YES** | [splash_screen.dart:33-36](lib/features/splash/splash_screen.dart#L33-L36) — 4 overlapping `Interval`s on one controller: bloom (0–0.55), symbol (0.06–0.46), wordmark (0.32–0.66), rule (0.58–0.84) |
| Custom page transitions | **YES** | [page_transitions.dart](lib/core/motion/page_transitions.dart) — `fadeThrough` and `riseOver`. No route uses `MaterialPage` |
| Dashboard staggered entry | **YES** | [dashboard_screen.dart:84-133](lib/features/dashboard/dashboard_screen.dart#L84-L133) — 7 `AnimatedReveal` indices, `AppDurations.stagger` apart. Same pattern on 11 other screens |
| Cycle Ring arc draw-in + active pulse | **YES** | Two controllers in [cycle_ring.dart:41-48](lib/core/widgets/cycle_ring/cycle_ring.dart#L41-L48) |
| AI Coach message entry + thinking indicator | **YES** | [ai_coach_screen.dart:189-197](lib/features/ai_coach/ai_coach_screen.dart#L189-L197) — a `_revealed` id set means each message animates exactly once and never re-animates on scroll. Plus [thinking_indicator.dart](lib/features/ai_coach/widgets/thinking_indicator.dart) and the ambient drift backdrop |
| Button press scale + glow | **YES** | [primary_button.dart](lib/core/widgets/buttons/primary_button.dart), [secondary_button.dart](lib/core/widgets/buttons/secondary_button.dart), [glow_card.dart](lib/core/widgets/cards/glow_card.dart), [gradient_border_card.dart](lib/core/widgets/cards/gradient_border_card.dart) — all swap to `*GlowStrong` on press |
| Exercise session horizontal step transitions | **YES** | [exercise_session_screen.dart:174-224](lib/features/exercises/exercise_session_screen.dart#L174-L224) — `AnimatedSwitcher` + direction-aware `SlideTransition` (`_forward ? 0.18 : -0.18`), so Back slides the other way |
| Goal completion moment | **NO** | Nothing exists. `GoalsProvider` has no way to complete a goal at all — see Part 6. The only related motion is the `AnimatedContainer` checkbox on [action_item_tile.dart:36](lib/features/goals/widgets/action_item_tile.dart#L36) |
| `MediaQuery.disableAnimations` respected | **YES, in 13 files** | page_transitions · animated_reveal · primary_button · secondary_button · glow_card · gradient_border_card · cycle_ring · progress_indicators · ambient_drift · thinking_indicator · chart_frame · splash_screen · welcome_screen. **Gap:** the `AnimatedSwitcher` in the exercise session does not check it |

---

## PART 6 — HONEST ASSESSMENT

### 1. Genuinely implemented vs. scaffolded

**Roughly 88% genuinely implemented, 12% gap — and the gaps are concentrated, not spread thin.**

Nothing here is a stub. There is no screen that renders a title and a "coming soon". Every one of the 20 screens has real content, real interactions and real bilingual copy behind it. The infrastructure — colour tokens, type scale, shadow system, motion primitives, route table, repository interfaces — is stronger than the brief required and is the reason the screens are as consistent as they are.

What is missing is specific:
- Goals edit and delete (**absent from the repository interface entirely**, not just the UI)
- Five screens with no navigation entrance
- Exercise reflection not persisted
- Progress charts fed by hardcoded literals rather than live state
- Two onboarding answers saved but never displayed

Call it **90% by screen count, 85% by required behaviour.**

### 2. Screens that would embarrass me right now

**Three, in order:**

1. **Settings — because the client cannot open it.** They will tap the Dashboard, tap the nav bar, tap the avatar, and conclude there is no Settings screen. The one screen most reviewers check first is the one with no door. Subscription, Help and Admin are behind the same locked door, so the pricing table the client specifically asked for is also invisible.

2. **Goals — because "create, edit, delete" was the requirement and two of the three are missing.** There is no long-press, no swipe, no overflow menu, no edit sheet. Worse, there is no way to *complete* a goal: `Goal.isCompleted` is real, `goals.tab.completed` renders a real tab, but the only completed goal in the app is one that was seeded that way in mock data. A reviewer who creates a goal to test the flow will find they cannot finish it, change it or remove it.

3. **Help / About — because the Terms and Privacy links are live-looking and inert.** Two dead buttons on the screen whose entire job is establishing legitimacy and Tânia Tomé's attribution.

Honourable mention: **Progress**, where the charts are handsome and completely inert. Check off every action on every goal and the completion rate stays at 62%.

### 3. Where it still reads as "Flutter with brand colours applied"

Mostly it doesn't — the motion vocabulary, the coloured-glow elevation and the Orbitron/Exo 2 split do real work. Four places where the seams show:

- **The AI Blue focus ring on every input.** A registration form whose name field glows electric cyan is Material's focus affordance wearing a brand colour, not a considered decision. It also spends the app's scarcest signal — "this is the AI" — on a password field.
- **The bottom nav is a `Row` of `Icon` + `Text`** ([app_bottom_nav.dart:50-56](lib/core/widgets/app_bottom_nav.dart#L50-L56)) with an `AnimatedContainer` colour swap. It is the most-seen chrome in the app and the least designed thing in it — no indicator, no lift, no motion on the active tab, while the Cycle Ring two hundred pixels above it runs two synchronised controllers.
- **Material `Icons.*` throughout.** `Icons.flag_outlined`, `Icons.bolt_outlined`, `Icons.donut_large_outlined`, `Icons.auto_awesome_outlined`. Standard Material Symbols on a bespoke navy-and-gold surface, and `auto_awesome` (the sparkle) is the single most generic "AI" glyph in software.
- **`CircularProgressIndicator` as the loading state on seven screens.** A themed Material spinner. The app has a `progress_indicators.dart` with custom work in it and a Cycle Ring that draws itself in — but the first thing shown on Progress, Profile, Settings, Subscription, History, Admin and the exercise session is a stock ring.

### 4. Five highest-impact fixes before showing the client

| # | Fix | Effort | Why |
|---|-----|--------|-----|
| 1 | **Add a Settings entrance** — a gear in `GreetingHeader` beside the notification bell | ~5 lines | Unlocks Settings, Subscription, Help/About and both Admin screens in one change. Five finished screens, currently invisible. Nothing else on this list comes close on return |
| 2 | **Goals edit + delete + complete** — `updateGoal`, `deleteGoal`, `setGoalCompleted` on the repository, then swipe-to-delete and an edit sheet | ~half a day | Closes the only explicit requirement that is flatly unmet, and unlocks the goal-completion moment from Part 5 |
| 3 | **Move the AI Blue focus ring and cursor to Gold** ([app_theme.dart:138,142](lib/core/theme/app_theme.dart#L138), [app_text_field.dart:106](lib/core/widgets/inputs/app_text_field.dart#L106)) — keep blue only for the coach input bar | ~15 min | The one brand rule broken app-wide rather than locally |
| 4 | **Persist the exercise reflection** ([exercise_session_screen.dart:90-101](lib/features/exercises/exercise_session_screen.dart#L90-L101)) and **show `mainGoals` + `motivationBalance` on Profile** ([coaching_profile_section.dart](lib/features/profile/widgets/coaching_profile_section.dart)) | ~1 hour | Two places where the app asks the user to type something and silently drops it. The worst kind of demo bug, because the client will type in exactly those boxes |
| 5 | **Derive Progress from live repository state** — have `MockProgressRepository` read the goals repository, and compute `headlineStats` instead of hardcoding | ~2 hours | Makes the charts respond to the reviewer. Right now Progress is a picture of progress |

Quick wins alongside: wire or remove the two dead legal links; fix `"O relançamento e a razão"` → `"é a razão"`; give the bottom nav an active indicator.

### 5. What I could not implement, skipped, or approximated

Stated plainly:

- **Goals edit and delete were never built.** Not deferred behind a flag, not stubbed — the methods do not exist on `GoalsRepository`. This is the one place where the delivered scope is narrower than the brief and it was not flagged at the time.
- **Five screens were built and never linked.** Settings was written complete, and the navigation entry point to it was never added. The bug is that `admin_dashboard_screen.dart` has a back button *to* Settings, which made the route look wired when it was not.
- **Progress is approximated.** `headlineStats`, `practiceByPrinciple` and `cycleCompletion` are hand-authored constants chosen to look right against the persona, not values computed from the goals and exercises the user can actually touch. Milestones are the exception — those are genuinely derived, but from the static seed rather than the live store.
- **The exercise closing reflection is a UI element with no destination.** It was built to spec visually and the save path was not connected.
- **`needsOnboarding` is dead code.** Auth tracks it; nothing reads it. Splash routes purely on `isLoggedIn`, which starts `false`, so the "auto-routing based on auth state" in requirement 1 only ever exercises one branch.
- **The error colour `#D4483C` is an eighth token** not in the seven-colour brief. It was added because destructive confirmation needed a hue and no listed token could carry it. Reasonable, but it was a decision made unilaterally.
- **Admin's "visually distinct" is weak.** It swaps the background to `navyDeep` and sets the title in Orbitron `textSecondary` — the same cards, spacing and palette as the rest of the app. A reviewer would not immediately register it as a different surface.
- **`MediaQuery.disableAnimations` is honoured in 13 places but not in the exercise session's `AnimatedSwitcher`** — an inconsistency, not a design decision.

Everything else asked for in the brief is present and working.

---

# Post-Fix Pass

**Date:** 2026-08-29
**Scope:** the seven items in the fix brief. Nothing outside them was changed except where a constraint forced it — each of those is listed under *Deviations*.

`flutter analyze`: **clean**. `flutter test`: **4/4 passing**.

---

## What changed, file by file

### 1. Settings entrance

| File | Change |
|------|--------|
| [greeting_header.dart](lib/features/dashboard/widgets/greeting_header.dart) | Added a third `_iconAction` for settings, using the existing helper — same 40px circle, same `AppSpacing.xs` gap, same press treatment. New `onSettings` callback. |
| [dashboard_screen.dart](lib/features/dashboard/dashboard_screen.dart) | Wired `onSettings: () => context.push(Routes.settings)`. |

### 2. Goals — edit, delete, complete

| File | Change |
|------|--------|
| [goal.dart](lib/data/models/goal.dart) | `copyWith` extended to `title`, `why`, `principle`, `targetDate`, plus `clearCompletedAt` so a goal can be reopened (mirrors `Milestone.copyWith`). |
| [goals_repository.dart](lib/data/repositories/goals_repository.dart) | Added `updateGoal`, `deleteGoal`, `setGoalCompleted`. |
| [mock_goals_repository.dart](lib/data/mock/repositories/mock_goals_repository.dart) | Implemented all three against the existing in-memory list. |
| [goals_provider.dart](lib/features/goals/goals_provider.dart) | Added `edit`, `delete`, `setCompleted`, each reloading and notifying like the existing methods. `edit` mirrors user text into both locales, as `create` already did. |
| [goal_sheet.dart](lib/features/goals/widgets/goal_sheet.dart) | **New** (replaces `create_goal_sheet.dart`). Takes an optional `Goal`; pre-fills and retitles when editing. Renamed because a sheet that also edits should not be called `CreateGoalSheet`. |
| [goal_overflow_menu.dart](lib/features/goals/widgets/goal_overflow_menu.dart) | **New.** The shared edit/delete menu. Delete takes `AppColors.error`. |
| [goal_actions.dart](lib/features/goals/widgets/goal_actions.dart) | **New.** The sheet and dialog plumbing, so the list and the detail screen open the same sheet and the same confirmation. |
| [goal_completion_bloom.dart](lib/features/goals/widgets/goal_completion_bloom.dart) | **New.** The completion moment. |
| [goal_detail_header.dart](lib/features/goals/widgets/goal_detail_header.dart) | **New.** Extracted from the detail screen to keep it under 250 lines; wraps the ring in the bloom. |
| [goal_card.dart](lib/features/goals/widgets/goal_card.dart) | Overflow affordance in the header row; `build()` split into `_header`/`_progress`/`_nextMilestone`. |
| [goals_screen.dart](lib/features/goals/goals_screen.dart) | Create/edit/delete wired through `GoalActions`; deletion confirms, then reports via snackbar. |
| [goal_detail_screen.dart](lib/features/goals/goal_detail_screen.dart) | Overflow menu in the app bar; "Mark complete" / "Reopen this goal" control; header extracted. Deleting pops back to the list. |
| [destructive_confirm_dialog.dart](lib/core/widgets/destructive_confirm_dialog.dart) | **Moved** from `features/settings/widgets/`. Goals needed it, and importing across features is forbidden. Settings' import updated; the dialog itself is unchanged apart from its doc comment. |
| [app_theme.dart](lib/core/theme/app_theme.dart) | Added `popupMenuTheme` so the overflow menu is a brand surface, not a Material default — the same treatment `dialogTheme` and `bottomSheetTheme` already get. |
| [app_durations.dart](lib/core/motion/app_durations.dart) | Added `goalCompletion` (720ms). |

**The completion moment.** A gold wave expands from behind the progress ring and fades, while the ring itself carries `goldGlowStrong` through the peak and settles back to `goldGlow`; the ring fills to 1 and stays there. 720ms on `AppCurves.celebrate` — a curve that already existed, unused, named for exactly this. It plays on the false-to-true edge only, overflows its bounds so nothing below shifts, and skips straight to the settled state under reduced motion. No confetti, no particles.

### 3. Input focus signal moved to Gold

| File | Change |
|------|--------|
| [app_theme.dart](lib/core/theme/app_theme.dart) | `focusedBorder` and `floatingLabelStyle` → Gold. |
| [app_text_field.dart](lib/core/widgets/inputs/app_text_field.dart) | `cursorColor` → Gold; focus bloom `blueGlow` → `goldGlow`; header comment corrected. |

`coach_input_bar.dart` needed no change — it already declares its own borders, cursor and glow locally, so it stays AI Blue. `earth_glow_painter.dart` untouched.

### 4. Input no longer discarded

| File | Change |
|------|--------|
| [exercise_response.dart](lib/data/models/exercise_response.dart) | Added `reflectionStepId`, a reserved id so the reflection cannot collide with a real step. |
| [exercise_session_screen.dart](lib/features/exercises/exercise_session_screen.dart) | The reflection is now written into the saved responses on Finish; `_load` calls `loadResponses` and restores previous answers *and* the reflection, so reopening a completed exercise reviews what was written. |
| [session_transition.dart](lib/features/exercises/widgets/session_transition.dart) | **New.** Extracted step transition (see *Deviations*). |
| [scale_input.dart](lib/core/widgets/inputs/scale_input.dart) | `onChanged` made optional; null renders the same scale read-only. `build()` split to get under 60 lines. |
| [coaching_profile_section.dart](lib/features/profile/widgets/coaching_profile_section.dart) | Answers 5 and 6 added. Motivation renders on the same `ScaleInput` the question used, between its own pole labels — not a number. |
| [onboarding_provider.dart](lib/features/onboarding/onboarding_provider.dart) | Q6 now requires an answer. Tracked with `_motivationSet` rather than inspecting the value, because the draft starts mid-track. |
| [journey_test.dart](test/journey_test.dart) | The onboarding walk-through now places the motivation scale. See *Deviations*. |

### 5. Custom icon marks

[app_icon.dart](lib/core/widgets/icons/app_icon.dart) and [app_icon_painter.dart](lib/core/widgets/icons/app_icon_painter.dart) — **new**. Eight marks on a 24-unit grid, stroke scaling with size, single-colour via a required `color`:

| Mark | Used for | Drawing |
|------|----------|---------|
| `cycle` | Home | Ring broken at the top with the active position in the gap — the Cycle Ring at icon size |
| `target` | Goals | Concentric rings closing on a centre |
| `signal` | AI Coach | A point with two arcs opening away from it |
| `steps` | Exercises | A three-tread ascent |
| `rise` | Progress | A rise across a baseline, resolving on a node |
| `chime` | Notifications | Arc, base and clapper |
| `sliders` | Settings | Two rules, handles set differently |
| `person` | Profile | Circle and arc |

Applied to the five nav destinations ([router.dart](lib/app/router.dart)), all three header affordances, and the coach entry card. `Icons.auto_awesome_outlined` — the generic AI sparkle — no longer represents the coach anywhere in the chrome.

I rendered the full set to a PNG at 24px and 48px and looked at it before accepting it. All eight read at 24px.

### 6. Bottom navigation

[app_bottom_nav.dart](lib/core/widgets/app_bottom_nav.dart) rewritten. Same five tabs, same order, same routes. Now: an indicator rule that **slides** between positions via `AnimatedAlign` and takes the arriving tab's accent; the active mark lifts 8% and blooms in `goldGlow`/`blueGlow`; the label gains weight and letterspacing through `AnimatedDefaultTextStyle`. Coach stays AI Blue, the other four gold. All durations collapse to zero under reduced motion.

### 7. Branded loading indicator

[app_loader.dart](lib/core/widgets/app_loader.dart) — **new.** Seven segments in a ring with a highlight travelling around them, echoing the Cycle Ring's segment count and gaps. Replaced `CircularProgressIndicator` in all **14** screen-level loading states; the coach's own wait uses `useAiAccent: true`. Under reduced motion it holds at a settled weight rather than freezing mid-turn. Added `AppDurations.loaderTurn`.

---

## Verification

| # | Check | Result |
|---|-------|--------|
| 1 | `flutter analyze` | **Clean**, whole project |
| 2 | Settings, Subscription, Help/About, Admin Gate, Admin Console reachable | **Yes** — Dashboard header → Settings → all four. Verified by tracing every `context.go`/`push` call: the only previously-missing edge was into `Routes.settings`, now present at [dashboard_screen.dart:94](lib/features/dashboard/dashboard_screen.dart#L94) |
| 3 | Create → edit → complete → reopen → delete a goal | **Yes** — verified by a temporary test driving `GoalsProvider` against `MockGoalsRepository`: id and `createdAt` survive the edit, the goal moves between the Active and Completed lists, `progress` reads 1.0 when closed, reopening actually clears `completedAt`, and delete removes it. Passed, then removed |
| 4 | No AI Blue cursor or focused border outside `features/ai_coach/` | **Yes** — the only `cursorColor`/`focusedBorder` outside the coach are both `AppColors.gold` |
| 5 | Exercise reflection retrievable | **Yes** — same temporary test: written through `completeExercise`, read back through `loadResponses` under `reflectionStepId` |
| 6 | All seven onboarding answers on Profile | **Yes** by construction — `coaching_profile_section.dart` now renders all seven fields of `OnboardingResponse` |
| 7 | EN/PT key sets identical | **Yes** — 412 keys each, zero missing either direction. 11 keys added per language |
| 8 | No new hex literals, `Colors.*`, emoji, or non-glow `BoxShadow` | **Yes** — hex only in `app_colors.dart`; zero bare `Colors.*`; the only non-ASCII in `lib/` are em-dashes and one curly apostrophe; every `BoxShadow(` in the project is still inside `app_shadows.dart` |
| 9 | Touched files ≤250 lines, `build()` ≤60 | **Yes for widget and screen files.** Two exceptions, both pre-existing — see below. The five remaining over-60 `build()`s are all in files I did not touch; `scale_input.dart` came off that list |

The existing suite (`journey_test.dart`, `widget_test.dart`) passes 4/4, including "layout holds at the narrowest supported width" — which confirms the third header affordance does not break the 360px layout.

---

## Deviations, and things I could not do as specified

Stated plainly.

1. **`AppShadows.focusGlow` does not exist.** The fix brief said it was "already gold-based" — that came from my own audit, where I mislabelled `logoBloom` as `focusGlow` in the shadow table. There is no `focusGlow`. I used `AppShadows.goldGlow`, the exact gold counterpart of the `blueGlow` the field used before (same alpha, blur and spread), so the border and bloom now match. **I have corrected that row in Part 3 above.**

2. **The loader is in `app_loader.dart`, not `progress_indicators.dart`.** The brief asked for it in `progress_indicators.dart`; putting it there took that file to 284 lines, breaking the 250-line rule. The two constraints conflict and the line limit is the harder one. It sits in the same folder, and `progress_indicators.dart` points at it.

3. **I edited `test/journey_test.dart`.** Making Q6 mandatory broke "splash through onboarding into the dashboard" — the test's loop handled text and chip steps but not the scale, so it stalled at Q6 forever. The test encoded the old auto-advance behaviour. I added a branch that places the scale. Without this the suite would be red.

4. **`session_transition.dart` was extracted, and I gave it reduced-motion handling it did not have.** Persisting the reflection took `exercise_session_screen.dart` to 270 lines, so the `AnimatedSwitcher` had to come out. My audit had flagged that this transition ignored `MediaQuery.disableAnimations`; since it became a new widget, and the brief requires new animations to honour it, I added the check. This is a behaviour change outside the seven items — one line, and it removes a known inconsistency, but it is a change you did not ask for.

5. **Two files I touched are still over 250 lines: `router.dart` (287) and `app_theme.dart` (277).** Both were already over before this pass (286 and 265); I added one line to the router and twelve for `popupMenuTheme`. Splitting either is explicitly out of scope.

6. **I gave Profile a custom mark too.** The brief listed the notification and settings affordances. The three sit in one row as identical circles, and leaving one Material while its neighbours were custom-drawn read as a mistake. Say the word and I will revert that one.

7. **Goals still has no target-date control.** The sheet does not let you set or change a target date; creating a goal still hardcodes today + 60 days, and editing preserves whatever date the goal had. The brief's bullets for item 2 were edit, delete and complete, so I treated the date as out of scope — but "edit" is not fully honest until a goal's target date can be changed. Flagging it rather than quietly widening the work.

8. **`primary_button.dart` still uses `CircularProgressIndicator`.** That is the small busy spinner *inside* a button, which takes the button's foreground colour; `AppLoader` only offers gold or AI Blue, so on a gold button it would be invisible. Every screen-level spinner was replaced. This one is a different control and I left it.

9. **I have not driven the app by hand.** Checks 3 and 5 were verified by a temporary test against the repositories and provider, not by tapping through a running build; checks 2 and 6 were verified by reading the wiring. The custom icons I did render and inspect visually. The completion bloom, the sliding nav indicator and the loader's motion have **not** been watched running — they are correct by construction and analyze/tests are clean, but nobody has looked at them move.

10. **The onboarding closing summary still shows five of seven answers.** `onboarding_summary.dart` has the same gap Profile had. The brief named `coaching_profile_section.dart` only, so I fixed that one. The two new keys are in place if you want the summary brought in line.

11. **Out-of-scope items were left alone, as instructed** — `MockProgressRepository` still reads static seed data, Admin's visual distinction is unchanged, `mock_data.dart` and `app_strings.dart` were not split, the four hand-rolled `initState`/`_load` screens were not refactored, and the dead Terms/Privacy links and the PT typo at `mock_data.dart:1296` are still there.

---

# CLIENT FEEDBACK ROUND 1

**Date:** 2026-09-01
**Scope:** the ten items in the round-1 revision brief. Frontend only, still on mock data. No backend, no payment SDK, no audio, no Firebase.
**State:** `flutter analyze` clean. `flutter test` 7/7 green (was 4/4; three tests added, two rewritten for the new flow). Debug APK builds.

**New flow, end to end:**

```
Splash → Welcome → Language → Quiz (3 questions) → Register → Trial → Welcome moment → Onboarding (4 questions) → Dashboard
```

---

## Part 1 — What changed, file by file

### Item 1 — Registration: date of birth, country, activity, two consents, email placeholder

| File | Change |
|---|---|
| [register_screen.dart](lib/features/auth/register_screen.dart) | Rewritten. Holds date of birth, country code, activity and both consent flags; validates all seven fields; registers with the new signature and continues to `Routes.trial`. 220 lines, `build()` 9 |
| [widgets/register_identity_fields.dart](lib/features/auth/widgets/register_identity_fields.dart) | **New.** The three non-typed fields (date of birth, country, activity) and the sheets they open |
| [widgets/selector_field.dart](lib/features/auth/widgets/selector_field.dart) | **New.** A field that opens a sheet instead of taking typing — same eyebrow, fill, radius and hairline as `AppTextField`, so it reads as a form field |
| [widgets/dob_picker_sheet.dart](lib/features/auth/widgets/dob_picker_sheet.dart) | **New.** Three-wheel date picker on the navy sheet. Not `showDatePicker`. Years offered run from 16 to 100 years ago, so the picker cannot express an under-16 date; the form still checks the age |
| [widgets/dob_wheel.dart](lib/features/auth/widgets/dob_wheel.dart) | **New.** One wheel column: selected row held in a gold band, app type throughout. Month names come from the active locale through `intl`, not from 12 more string keys |
| [widgets/country_picker_sheet.dart](lib/features/auth/widgets/country_picker_sheet.dart) | **New.** Full country list, filtered as you type, matched against **both** language names so "Moza" finds Moçambique in Portuguese |
| [widgets/activity_selector.dart](lib/features/auth/widgets/activity_selector.dart) | **New.** Student \| Minorities / Professional, on the existing `PreferenceChoiceRow` |
| [widgets/consent_block.dart](lib/features/auth/widgets/consent_block.dart) | **New.** Two separate checkboxes and the shared error line |
| [core/widgets/inputs/app_checkbox.dart](lib/core/widgets/inputs/app_checkbox.dart) | **New.** Drawn checkbox — gold fill, resting bloom, tick on the same 24-unit grid as the icon marks. Whole row is the target |
| [data/models/country.dart](lib/data/models/country.dart) | **New.** `Country(code, en, pt)` |
| [data/mock/country_data.dart](lib/data/mock/country_data.dart) | **New.** 196 countries with Portuguese names, sorted at read time against the active language |
| [data/models/user.dart](lib/data/models/user.dart) | `UserActivity` enum, plus `activity`, `dateOfBirth`, `countryCode` and a `monthlyTier` getter |
| [data/repositories/auth_repository.dart](lib/data/repositories/auth_repository.dart) | `register(...)` now takes date of birth, country and activity; added `hasActiveSubscription` and `startTrial()` |
| [login_screen.dart](lib/features/auth/login_screen.dart), [forgot_password_screen.dart](lib/features/auth/forgot_password_screen.dart) | Email hint now `taniatome@succenergy.com`, read from `auth.hint.email` instead of a literal in the widget |

### Item 2 — Sign-in button weight

| File | Change |
|---|---|
| [welcome_screen.dart](lib/features/welcome/welcome_screen.dart) | "I already have an account" is a full-width `SecondaryButton` directly under the primary. The primary is now the gold-filled `PrimaryButton` — see deviation 1 |
| [core/widgets/buttons/primary_button.dart](lib/core/widgets/buttons/primary_button.dart) | Optional `emphasis`: one word of the label at heavier weight, so the CTA keeps its stressed word on a gold fill |
| [core/widgets/buttons/secondary_button.dart](lib/core/widgets/buttons/secondary_button.dart) | Height 56 → 54, so the pair is exactly the same size |

### Item 3 — Pre-registration quiz (split 7 → 3 + 4)

| File | Change |
|---|---|
| [features/quiz/quiz_provider.dart](lib/features/quiz/quiz_provider.dart) | **New.** Holds the three answers, writes them through `UserRepository.saveQuizAnswers` |
| [features/quiz/quiz_screen.dart](lib/features/quiz/quiz_screen.dart) | **New.** Same treatment as onboarding: progress rule, one question per screen, `AnimatedSwitcher` between steps. Reuses the existing question widgets and the existing `onboarding.q1–q3` copy, so nothing was re-translated |
| [core/widgets/questions/](lib/core/widgets/questions/) | **Moved** (git-tracked renames) — `free_text_question.dart`, `multi_select_question.dart`, `scale_question.dart` and `onboarding_progress_bar.dart` → `question_progress_bar.dart`. They are now shared by two features, and a cross-feature import would have broken the layering rule |
| [onboarding_provider.dart](lib/features/onboarding/onboarding_provider.dart) | Four questions (priorities, main goals, motivation, success). Reads the three quiz answers into the draft on construction so the closing summary shows the whole assessment, and merges them again on `save()` so a slow first read can never write three empty fields over them |
| [onboarding_screen.dart](lib/features/onboarding/onboarding_screen.dart) | Four steps, explicit key mapping (`q4`–`q7`), progress out of 4 |
| [app/routes.dart](lib/app/routes.dart), [app/router.dart](lib/app/router.dart) | `Routes.quiz` with its provider |
| [language_selection_screen.dart](lib/features/language_selection/language_selection_screen.dart) | Confirm now opens the quiz, not registration. `build()` split so it stays under 60 lines |

### Item 4 — Three more options on the life-area question

`onboarding.option.procrastination`, `onboarding.option.stress`, `onboarding.option.balancedLife` in both languages, added to `QuizProvider.focusAreaOptions` (ten options now). Maximum of two selections unchanged.

### Item 5 — Trial screen (UI only)

| File | Change |
|---|---|
| [features/trial/trial_screen.dart](lib/features/trial/trial_screen.dart) | **New.** $1 for 7 days, one monthly rate, what the trial opens, CTA, small print. The CTA calls `AuthRepository.startTrial()` — a flag, no SDK, no network |
| [features/trial/widgets/trial_offer_card.dart](lib/features/trial/widgets/trial_offer_card.dart) | **New.** Gradient-border offer card. Shows **only** the rate the registered activity puts the user on |
| [features/trial/widgets/trial_unlock_list.dart](lib/features/trial/widgets/trial_unlock_list.dart) | **New.** Five lines, gold nodes rather than tick glyphs |
| [app/subscription_gate.dart](lib/app/subscription_gate.dart) | **New.** The router's `redirect`. Signed in without the flag → every gated path resolves to `Routes.trial`, onboarding included. One check, in one place; no screen asks |
| [mock_auth_repository.dart](lib/data/mock/repositories/mock_auth_repository.dart) | Registration leaves the flag false; `startTrial()` sets it; log-out and delete clear it. A returning **log-in** sets it true, so the demo persona still opens on the Dashboard |
| [app/shell_frame.dart](lib/app/shell_frame.dart) | **New.** `_ShellFrame` moved out of `router.dart` — see deviation 7 |

### Item 6 — Post-payment welcome moment

| File | Change |
|---|---|
| [features/trial/trial_welcome_screen.dart](lib/features/trial/trial_welcome_screen.dart) | **New.** The client's exact line over a gold bloom, one way on. Reached once, from the trial action |
| [features/trial/widgets/welcome_bloom.dart](lib/features/trial/widgets/welcome_bloom.dart) | **New.** The goal-completion gesture reused: one ring of light expands from behind the mark and settles, ~720ms on the celebrate curve. Reduced motion goes straight to the settled state |

Copy, both languages:
- EN "Congratulations, you are on the path to becoming a Succenergy winner."
- PT "Parabéns, está no caminho para se tornar um vencedor Succenergy."

### Item 7 — Subscription pricing

| File | Change |
|---|---|
| [data/models/subscription_plan.dart](lib/data/models/subscription_plan.dart) | `SubscriptionTier` is now `{ trial, student, professional }`. `annualSaving` and `isPremium` removed |
| [mock_data.dart](lib/data/mock/mock_data.dart) | Three plans: $1 / 7 days, $11 / month, $33 / month. Prices read from `AppConstants`. Added `lockedFeatureValueKeys` and `includedFeatureValueKeys` |
| [widgets/plan_card.dart](lib/features/subscription/widgets/plan_card.dart) | `highlighted` replaces the data-level `isRecommended`: the tier matching the registered activity is the one card with the gradient edge and the filled action. Saving flag gone |
| [subscription_screen.dart](lib/features/subscription/subscription_screen.dart) | Reads the activity from the account and highlights that tier |
| [widgets/feature_comparison_table.dart](lib/features/subscription/widgets/feature_comparison_table.dart) | Same rows, same treatment; the two columns are now LOCKED / INCLUDED instead of Free / Premium — see deviation 4 |
| [widgets/admin_user_row.dart](lib/features/admin/widgets/admin_user_row.dart), [settings_screen.dart](lib/features/settings/settings_screen.dart) | Tier labels follow the new three |

### Item 8 — Kebab menu and new Settings items

| File | Change |
|---|---|
| [core/widgets/icons/app_icon.dart](lib/core/widgets/icons/app_icon.dart), [app_icon_painter.dart](lib/core/widgets/icons/app_icon_painter.dart) | Two new marks on the same 24-unit grid: `kebab` (three dots, vertical) and `chevronDown` (used by the selector fields) |
| [widgets/greeting_header.dart](lib/features/dashboard/widgets/greeting_header.dart) | The settings affordance is the kebab. Vertical dots — the header row is three circles side by side and a horizontal kebab would have read as an ellipsis in a line of them |
| [features/settings/widgets/succenergy_links_group.dart](lib/features/settings/widgets/succenergy_links_group.dart) | **New.** Recharge with Succenergy (in-app), Succenergy Library, Book Tânia Tomé, Connect with Us (expands in place to Instagram / Facebook / LinkedIn / YouTube). External rows carry "Opens in your browser" |
| [features/recharge/recharge_screen.dart](lib/features/recharge/recharge_screen.dart) | **New.** Placeholder screen, says plainly that it is being prepared |
| [core/services/external_links.dart](lib/core/services/external_links.dart) | **New.** The one `url_launcher` call in the project. A destination that cannot be opened returns false rather than throwing |
| [app_constants.dart](lib/core/constants/app_constants.dart) | Six URLs, every one named `placeholder…` and marked as unconfirmed in the comment |
| [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml), [Info.plist](ios/Runner/Info.plist) | `<queries>` for `https` on Android 11+, `LSApplicationQueriesSchemes` on iOS — without these the links silently do nothing |

### Item 9 — Welcome logo and background

| File | Change |
|---|---|
| [welcome_screen.dart](lib/features/welcome/welcome_screen.dart) | Restructured: the brand block (symbol, lockup, tagline, authorship) is centred in the space above the actions via `SliverFillRemaining`, and scrolls only when the screen is too short. The actions sit above the curve, clearing it by the same fraction the painter uses, so they can never sit on the horizon at any screen size |
| [widgets/starfield_painter.dart](lib/features/welcome/widgets/starfield_painter.dart) | **New.** 110 deterministic points above the horizon, dimming as they approach it, every ninth held brighter and larger. No twinkle |
| [widgets/earth_glow_painter.dart](lib/features/welcome/widgets/earth_glow_painter.dart) | Rewritten in five passes: a four-stop body gradient, a wide outer haze, a tighter halo, the hard rim, and a **light wrap clipped inside the circle** so the glow fades along the curve rather than across a straight edge. The peak carries two blooms (off-white core, blue spill) plus the beam. `horizonFraction` is now public, which is what the screen reads to clear the curve |
| Ambient drift | A 18-second controller slides the sunrise a fraction of the screen width and breathes its intensity. Stopped entirely under reduced motion |

### Item 10 — Notification permission

| File | Change |
|---|---|
| [core/services/notification_permission.dart](lib/core/services/notification_permission.dart) | **New.** One-shot request, outcome recorded, safe on a platform with no plugin behind it |
| [onboarding_screen.dart](lib/features/onboarding/onboarding_screen.dart) | Fires on "Enter the app" — first entry after onboarding. Not awaited: the system dialog sits over the Dashboard on its own |
| [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) | `POST_NOTIFICATIONS`, without which nothing appears on Android 13+ |

### Supporting changes

| File | Change |
|---|---|
| [core/localization/app_strings.dart](lib/core/localization/app_strings.dart) | **62 keys added, 8 removed** per language: 412 → **466 each**, sets identical. Removed: the three old plan names, `perYear`, `saving`, the three old admin plan labels |
| [core/localization/string_extensions.dart](lib/core/localization/string_extensions.dart) | Added `context.trRead` — see deviation 9, this fixes a real crash |
| [core/constants/app_constants.dart](lib/core/constants/app_constants.dart) | `quizQuestionCount` 3, `onboardingQuestionCount` 7 → 4, `minimumAgeYears`, `maxAgeYears`, the four prices, the six placeholder URLs |
| [user_repository.dart](lib/data/repositories/user_repository.dart) + mock | `saveQuizAnswers(...)`, which merges the three answers into the stored assessment |
| [pubspec.yaml](pubspec.yaml) | `url_launcher ^6.3.2`, `permission_handler ^11.3.1` — see deviation 10 |
| [test/journey_test.dart](test/journey_test.dart) | Rewritten for the new flow, plus three new tests |
| [test/widget_test.dart](test/widget_test.dart) | Reduced motion (the Welcome drift is continuous now and the tree would never settle) and a rich-text finder for the CTA |

---

## Part 2 — Checks

| # | Check | Result |
|---|---|---|
| 1 | `flutter analyze` | **Clean**, whole project |
| 2 | Full flow cold-start | **Yes** — driven end to end by `splash through quiz, trial and onboarding into the dashboard`: Welcome → Language → Quiz ×3 → Register (both sheets, both checkboxes) → Trial → welcome moment → Onboarding ×4 → summary → Dashboard |
| 3 | All seven answers survive the split | **Yes** — `the quiz answers reach the closing summary` asserts the three quiz answers appear on the closing summary beside the four just given. Profile renders all seven fields of `OnboardingResponse` and the store holds all seven after both writes |
| 4 | Registration blocks until both boxes are ticked | **Yes** — the test submits with them unticked, asserts the error, then ticks both and submits. See deviation 5 for why it is an error rather than a disabled button |
| 5 | $11 for Student \| Minorities, $33 for Professional | **Yes, both ways** — the professional path asserts `$33`, the student path asserts `$11` **and** that `$33` appears nowhere |
| 6 | Subscription screen on the new model | **Yes** — three tiers, no annual, no saving flag, gradient edge on the activity's tier |
| 7 | Authenticated + no flag cannot reach the Dashboard | **Yes** — `the dashboard is closed until the trial is taken` registers, then drives the real router to `/dashboard`, `/coach` and `/progress` and asserts the trial screen each time |
| 8 | Settings via the kebab; four new items; links | **Partly by test** — `the kebab menu opens Settings and the Succenergy links` taps the kebab mark, asserts all four items, expands Connect with Us and routes into Recharge. That a browser actually opens is **not** verified — see deviation 11 |
| 9 | EN/PT key sets identical | **Yes** — 466 each, zero missing either direction, zero duplicates |
| 10 | No new hex, `Colors.*`, emoji or non-glow shadow | **Yes** — zero hex outside `app_colors.dart`, zero `Colors.*`, every `BoxShadow(` still inside `app_shadows.dart`, and the only non-ASCII in `lib/` is em-dashes, Portuguese accents and the `·` separator (checked by codepoint) |
| 11 | Touched files ≤250 lines, `build()` ≤60 | **Yes for every new file** and for everything I touched except three pre-existing exceptions — see deviation 7 |
| 12 | Android debug build | **Builds** after pinning `permission_handler` — see deviation 10 |
| 13 | Looked at | Welcome (390×844 and 360×720), Trial and the welcome moment were **rendered to PNG and inspected**. That is how the button/horizon overlap in deviation 3 was found and fixed |

---

## Part 3 — Deviations, and what I could not do as specified

Stated plainly.

1. **The Welcome CTA is now gold-filled, which changes the approved artwork.** The brief says "the primary stays gold-filled". It was not gold-filled — it was the glowing outlined button from the reference artwork, and both actions outlined would have left no hierarchy. I followed the brief: the CTA is a filled `PrimaryButton`, sign-in is the outlined `SecondaryButton`. Consequence: the stressed word "Journey" can no longer be gold on a gold fill, so it now carries a heavier weight in navy instead. If you want the artwork treatment back, it is a two-line swap in `welcome_screen.dart`.

2. **"Exo 2" is not in this project.** The brief asked for the date picker to be themed in Exo 2. The type system has been Poppins since the earlier pass (`app_typography.dart`); there is no Exo 2 anywhere in the build. The picker uses the app's own scale.

3. **`design_reference/welcome_screen_reference.png` is not in the repository.** The background was deepened against the brief's description and the existing painter, not against the image. If the file exists on your side, send it — the atmosphere is tuned by a handful of alpha values and is quick to adjust.

4. **The comparison table's columns are now LOCKED / INCLUDED.** The brief said to keep the comparison rows, but under the new model the trial and both monthly rates include exactly the same thing, so a trial-versus-monthly table would have been two identical columns. The left column now describes what an account reaches *before* the trial — which is the honest comparison and reuses the existing copy unchanged.

5. **Registration blocks with an error, not a disabled button.** Tapping "Create account" with either box unticked shows "Tick both boxes before you continue." under the checkboxes and does not register. A disabled button would have hidden the reason. Say the word if you want the button greyed out as well.

6. **The welcome moment sits between the trial and onboarding, not on the Dashboard.** Item 6 says it "dismisses to the Dashboard"; the flow in the brief's verification list puts it directly after the trial. I followed the flow: it dismisses into the four onboarding questions, which land on the Dashboard. Moving it to a first-entry Dashboard overlay is a route change plus one flag.

7. **Three files remain over 250 lines and three `build()`s over 60.** `router.dart` is 281 — but it was **301 before this pass**: the shell widget and the gate moved out, so it is twenty lines shorter than I found it. `app_strings.dart` (1,149) and `mock_data.dart` (1,766) were explicitly out of scope to split. The three long `build()`s are in `admin_gate_screen.dart`, `exercise_card.dart` and `onboarding_summary.dart` — none of which I touched.

8. **Country names live in `country_data.dart`, not `app_strings.dart`.** Both languages are there, so nothing is untranslated, but 196 rows × 2 would have doubled the string file and buried the written copy. The brief's rule is that no *widget* holds display text; no widget does.

9. **I fixed a real crash on the way through.** Every validator resolved its error message with `context.tr`, which is a `watch`, from inside a tap handler — provider asserts on that. Any validation failure on register, log in or forgot-password would have thrown. It never showed up because the happy path never resolves an error string; my consent error hit it on the first run. Added `context.trRead` (read-based) and used it in the three validators. This is a fix you did not ask for, in files you did ask me to change.

10. **`permission_handler` is pinned to 11.3.1, not the latest.** Version 13 pulls an Android module that requires Kotlin 2.3 and `compileSdk 37`; this project is on Kotlin 1.8.22, AGP 8.7 and Flutter 3.29's SDK 35, so the Gradle script failed to compile. Raising the toolchain is a build-system change, not a frontend one, so I pinned the plugin instead and confirmed the debug APK builds. Worth revisiting when the project moves to a newer Flutter.

11. **The native prompt and the external links have not been seen working.** No device was involved: `POST_NOTIFICATIONS` and the `https` query are in the manifest and the request fires at the right moment, but nobody has watched the dialog appear, and a widget test cannot open a browser. Both need five minutes on a real phone.

12. **The trial and Plans screens read the activity from the auth repository**, while the Dashboard and Profile read the user repository's persona. That split already existed; it now matters for pricing, because after a **log-in** (rather than a registration) the persona's activity — Professional — is what drives the highlighted tier. One store, later, when the backend lands.

13. **`SecondaryButton` is 2px shorter everywhere.** Height 56 → 54 so the Welcome pair matches exactly. It affects every secondary button in the app.

14. **The wordmark's baked-in navy panel is slightly more visible than before.** The artwork has a solid panel behind it, and against a starfield its top and bottom edges hide stars. A transparent PNG or an SVG of the lockup would remove it — worth asking the design side for.

15. **The onboarding closing summary still shows five of seven answers** (main goals and motivation are missing). Same gap flagged last round; the split did not change it, and the two keys are already in place if you want it brought in line.

16. **Out of scope, untouched, as instructed:** no audio, no payment SDK, no quiz landing page, no backend or Firebase, `MockProgressRepository` still reads seed data, and neither `mock_data.dart` nor `app_strings.dart` was split.

---

# Backend Deploy Pass

Three tasks: move first-contact registration off query parameters, deploy to
Cloud Run, and correct the subscription schema for RevenueCat. Two are done.
The deploy is not, and could not be from this machine — [what could not be
done](#what-could-not-be-done) says exactly why.

`npm run build`, `npm run lint` and `npm run typecheck` are all clean.

---

## Task 1 — First-contact registration moved to `POST /v1/me`

`GET /v1/me` accepted `name`, `preferredLanguage`, `activity`, `dateOfBirth`,
`countryCode`, `acceptedTerms` and `confirmedInfoTrue` as **query parameters**
and created the user document when the uid was unknown. Two problems, both
real:

- **Cloud Run writes the full request URL to its platform request log, query
  string included.** That happens below the application, so
  `request_logger.ts` redaction cannot reach it — name, date of birth and
  country would have gone into Cloud Logging on every first-contact request.
  Against the brief's *"do not expose private user information through logs,
  public APIs or debug output."* Request bodies are not logged.
- **A `GET` that creates a resource is neither safe nor idempotent.** Retries,
  prefetches and intermediaries all assume a `GET` has no side effects.

| File | Change |
| --- | --- |
| [backend/src/schemas/user.schema.ts](backend/src/schemas/user.schema.ts) | `bootstrapProfileSchema` → `createProfileSchema`, parsed from the body. `acceptedTerms` / `confirmedInfoTrue` are now `boolean` rather than `literal(true)`, so a recorded refusal is a valid request rather than a malformed one. `.strict()`, so unknown keys are 422 as with `PATCH`. |
| [backend/src/services/user.service.ts](backend/src/services/user.service.ts) | `getOrCreateProfile` split into `getProfile` (read only, throws `profile_not_found`) and `createProfile` (returns `{ profile, created }`). The create-race re-read is kept. |
| [backend/src/controllers/user.controller.ts](backend/src/controllers/user.controller.ts) | `getMe` no longer touches `req.query`. New `createMe`: 201 on creation, 200 when the document is already there. |
| [backend/src/routes/user.routes.ts](backend/src/routes/user.routes.ts) | `POST /` added under the same `requireAuth`. |

Defaults on creation are unchanged: Purpose, cycle day 1, streak 0,
`direct` / `daily` / reminders on. `email` still comes from the verified token
and is rejected if sent in the body.

`POST /v1/me/onboarding` still creates the parent user document if it is
missing. That is not the `GET` behaviour coming back in another door — it is
the subcollection needing its parent, and it means a submitted assessment is
not lost to a client that skipped `POST /v1/me`.

### Verified against the emulators

Ten cases, run end to end against the Auth and Firestore emulators with a
token minted for a throwaway uid that had no document:

| # | Case | Result |
| --- | --- | --- |
| 1 | `GET /v1/me`, unknown uid | **404** `profile_not_found` |
| 2 | `GET /v1/me?name=…&countryCode=…&dateOfBirth=…` | **404** — the old query parameters create nothing and are silently ignored |
| 3 | `POST` with `email` in the body | **422**, `Unrecognized key(s) in object: 'email'` |
| 4 | `POST` with `preferredLanguage: "fr"` | **422**, names the field |
| 5 | `POST` with the full valid body | **201**, profile returned, `countryCode: "mz"` upper-cased to `MZ` |
| 6 | `POST` again with a different `name` | **200**, original document unchanged — the retry did not overwrite |
| 7 | `GET /v1/me` after that | **200** with the profile |
| 8 | `POST` with no body at all, fresh uid | **201** with every default filled in |
| 9 | `POST` with no `Authorization` header | **401** `unauthorized` |
| 10 | `users/{uid}/subscription/current` after creation | Present, carrying `revenueCatAppUserId` and `entitlementId`, no `providerCustomerId` |

`npm run seed` was re-run afterwards and still writes its 8 subcollections and
~32 documents.

### The contract the Flutter side builds against

Written into [backend/README.md](backend/README.md) so it is not just in a
commit message:

- **After sign-up** — Firebase Auth, then `POST /v1/me` with the registration
  fields, then `GET /v1/me` from then on.
- **On app start with an existing session** — `GET /v1/me`; on
  `404 profile_not_found`, `POST /v1/me` to recover and carry on.

Nothing in the Flutter app was touched.

---

## Task 3 — Subscription schema follows RevenueCat

[backend/src/models/subscription.model.ts](backend/src/models/subscription.model.ts):

| Was | Now |
| --- | --- |
| `provider: 'none' \| 'stripe' \| 'revenuecat'` | `provider: 'none' \| 'app_store' \| 'play_store'` — the originating store, since RevenueCat sits in front of both and would be the same value on every row |
| `providerCustomerId` | `revenueCatAppUserId` |
| — | `entitlementId` added; this is what the gating will read |

`SUBSCRIPTION_PROVIDERS` is now `SUBSCRIPTION_STORES`, `SubscriptionProvider`
is `SubscriptionStore`, and `INITIAL_SUBSCRIPTION`, `SubscriptionResult` and
the seed script follow. The two commented Stripe placeholders in
`SECRET_NAMES` became one commented `REVENUECAT_WEBHOOK_SECRET`.

Nothing writes these fields yet. The purchase flow is a later pass and cannot
be built until the app is in both stores.

---

## Task 2 — Cloud Run deploy: **not done**

> **Superseded.** The deploy did happen afterwards, by someone with the
> tooling: revision `succenergy-api-00002-ltn` is live at
> https://succenergy-api-4612920383.us-east1.run.app, in **`us-east1`**, not
> the `us-central1` this section plans. The rest of this section is left as
> the record of what was true when it was written. See
> [Postgres Migration Pass](#postgres-migration-pass) for the current state.

One useful thing came out of it. The region is now **confirmed rather than
guessed**, read off the live database:

```
$ npx firebase firestore:databases:get '(default)' --project succenergy-ai-coach
Type      FIRESTORE_NATIVE
Location  nam5
```

`nam5` is the **United States multi-region**. Cloud Run cannot target a
multi-region, so the service belongs in **`us-central1`** — one of `nam5`'s
two constituent regions. The `europe-west1` placeholder is gone from the
README, replaced by a `REGION` variable set once at the top of the sequence.

Nothing was deployed. Three separate blockers, each sufficient on its own:

| Blocker | Detail |
| --- | --- |
| **No `gcloud` CLI** | No Cloud SDK on the machine — not in `PATH`, not in either `Program Files`, not under `%LOCALAPPDATA%`. No `%APPDATA%\gcloud`, so no Application Default Credentials either. Installing it would not have helped: `gcloud auth login` needs an interactive browser sign-in that a non-interactive pass cannot complete. |
| **No Docker daemon** | Docker Desktop is installed and was launched. It registered no daemon: `com.docker.service` is not installed as a Windows service, no `docker-desktop` WSL distro exists, and `docker info` cannot reach `npipe:////./pipe/docker_engine`. Same finding as the previous pass, re-checked rather than assumed. First-run setup needs an interactive elevated session. |
| **The Firebase account is read-only on the project** | `npx firebase login:list` shows a signed-in account that can list `succenergy-ai-coach` and read its Firestore metadata. `firebase deploy --only firestore:rules,firestore:indexes` returns `403, The caller does not have permission` from `firebaserules.googleapis.com`. `PERMISSION_DENIED`, not `SERVICE_DISABLED` — a missing IAM grant, not a disabled API. |

So `firestore:rules` and `firestore:indexes` are **also not deployed**. Note
that `firebase deploy` compiles `firestore.rules` even for an
`--only firestore:indexes` run, so the two cannot be separated to get the
indexes in without rules permission.

The image build was **not** verified, and the warning in the README's Docker
section stays in place — reworded to say it was re-checked on this pass rather
than left reading as a stale note. What the container *executes* was verified
on the previous pass by running the compiled output directly; the unverified
part is still the image layering.

None of the six live-service checks were run, because there is no live
service: health 200, ready 200, `/v1/me` 401 without a token, HSTS and the
production headers, the 308 from plain HTTP, and the Cloud Logging PII sweep
all wait on the deploy. The 401-without-token behaviour *was* confirmed
locally (case 9 above); the rest are properties of the deployed environment
and cannot be checked anywhere else.

### What is ready for whoever runs it

[backend/README.md](backend/README.md) has been rewritten from "pending" to a
runnable sequence with the confirmed region, in the order specified: enable
APIs, create the Artifact Registry repository, create the dedicated
`succenergy-api` service account with `roles/datastore.user` and nothing else,
verify the local Docker build, build and push, deploy. The `firestore
databases create` step is gone — the database already exists and re-running it
would fail rather than no-op.

It also now lists the IAM roles the deploying account needs, since that turned
out to be the binding constraint: `firebaserules.admin`,
`datastore.indexAdmin`, `run.admin`, `artifactregistry.admin`,
`cloudbuild.builds.editor`, `iam.serviceAccountAdmin` +
`resourcemanager.projectIamAdmin`, and `iam.serviceAccountUser` on the runtime
service account. Project `roles/owner` covers all of them.

The decisions carried forward unchanged: no default compute service account,
no project-wide `secretAccessor` (per secret, when each is first used),
`--allow-unauthenticated` because the service enforces Firebase ID tokens
itself and Cloud Run IAM would reject mobile clients that have no Google
identity, and `NODE_ENV=production` with neither emulator host variable set —
which boot refuses to start without anyway.

---

## What could not be done

Stated plainly.

1. **The Cloud Run deploy did not happen.** No `gcloud`, no Docker daemon, and
   the one authenticated CLI on the machine has read-only project access. Any
   one of those would have stopped it. This needs to be run by someone with
   the Cloud SDK installed, signed in as an account with the roles listed
   above — realistically the client's own owner account, or a fresh account
   granted them.

2. **`firestore.rules` and `firestore.indexes.json` are not deployed either.**
   Same 403. Until they are, the project carries whatever default rules
   Firestore was created with. That is not currently a data-exposure risk —
   no client SDK points at this project and there is no data in it — but the
   deny-all rules should go in **before** the app is live, and before the
   service, since they only ever lock things down.

3. **The Docker image build is still unverified.** Second pass in a row, same
   cause. `gcloud builds submit` would surface a broken Dockerfile as a failed
   remote build, which is recoverable but wastes a cycle, so it is worth
   running `docker build -t succenergy-api:local .` once on a machine with a
   working daemon first.

4. **None of the live-service verification was possible.** Listed above. The
   authenticated half of it was already out of scope for this pass — it needs
   a real ID token from the Flutter side, and no test user should be created
   in the production Auth instance to fake one.

5. **`acceptedTerms` and `confirmedInfoTrue` accept `false`.** The old schema
   used `z.literal(true)`, which would have rejected a request carrying an
   unticked box. The task specified `boolean`, and a recorded refusal is more
   useful than a 422, so `false` is now valid and stored. Nothing yet gates on
   these being true — that is a product decision, and the endpoint records
   rather than enforces.

6. **`POST /v1/me` returns 200, not 409, on a repeat.** The task specified
   this, and it is right, but it is worth being explicit that it means the
   endpoint is **not** a way to detect "was this account already registered" —
   a client cannot distinguish "I just created it" from "it was already there"
   except by the status code, and should not branch on that for anything more
   than logging.

---

# Postgres Migration Pass

> **Partly superseded.** Migrations moved to `supabase/migrations/` with
> timestamped filenames, and the tracking table changed, once the client
> confirmed the Supabase GitHub integration applies them. Paths and tracking
> details below are the record of what was true at the time. See
> [Migrations Follow-Up](#migrations-follow-up).

Firestore is out. Supabase Postgres is now the single database for both
application data and the RAG vector store. Firebase Auth stays, for token
verification and later FCM.

`npm run build`, `npm run lint` and `npm run typecheck` are all clean.

Everything was built and verified against a **real Postgres 18.4** running
locally, on a machine at **UTC+5** — which turned out to matter, see
[the date-column bug](#the-one-real-bug-this-found). What could not be
verified is listed plainly in [What could not be done](#what-could-not-be-done-1);
the short version is that the local Postgres has no pgvector, and nothing was
deployed.

---

## What changed, file by file

### New

| File | What it is |
| --- | --- |
| [backend/migrations/001_initial_schema.sql](backend/migrations/001_initial_schema.sql) | Fourteen application tables, their indexes, the `updated_at` trigger, check constraints mirroring the TypeScript unions, and RLS on everything |
| [backend/migrations/002_rag_embeddings.sql](backend/migrations/002_rag_embeddings.sql) | `knowledge_chunks`, pgvector, the ivfflat index, RLS. Created empty. |
| [backend/scripts/migrate.ts](backend/scripts/migrate.ts) | Applies pending migrations in filename order, tracks them in `schema_migrations`, safe to re-run |
| [backend/src/config/database.ts](backend/src/config/database.ts) | The only file that constructs a pool. Connection string resolution, `query`, `withTransaction`, the readiness probe, the shutdown drain. |
| [backend/scripts/seed.ts](backend/scripts/seed.ts) | Replaces `seed_firestore.ts`. Same Marisa Chissano persona, SQL inserts. |

### Rewritten

| File | Change |
| --- | --- |
| [backend/src/repositories/user.repository.ts](backend/src/repositories/user.repository.ts) | Postgres. Joined profile read, atomic create, allow-listed patch, one-statement delete. |
| [backend/src/config/firebase.ts](backend/src/config/firebase.ts) | Auth only. Firestore handle and connectivity probe gone. |
| [backend/src/config/env.ts](backend/src/config/env.ts) | `DATABASE_URL` in, `FIRESTORE_EMULATOR_HOST` out. New guards, below. |
| [backend/src/config/secrets.ts](backend/src/config/secrets.ts) | `SECRET_NAMES.DATABASE_URL` registered, with the confirm-before-deploy warning |
| [backend/src/routes/health.routes.ts](backend/src/routes/health.routes.ts) | `/ready` runs `select 1`; the check is reported as `database` rather than `firestore` |
| [backend/src/index.ts](backend/src/index.ts) | `await initDatabase()` before `app.listen`; SIGTERM drains the pool after the HTTP server closes |
| [backend/README.md](backend/README.md) | Data model, environment, local setup, security and deploy sections rewritten |
| [backend/.env.example](backend/.env.example), [backend/package.json](backend/package.json), [backend/firebase.json](backend/firebase.json), [backend/.dockerignore](backend/.dockerignore) | `DATABASE_URL`, `npm run migrate`, Auth emulator only, `migrations/` excluded from the image |

### Deleted

`firestore.rules`, `firestore.indexes.json`, `src/utils/timestamps.ts`,
`scripts/seed_firestore.ts`, and the Firestore emulator block in
`firebase.json`.

### Models

The ten model files that imported `Timestamp` from `firebase-admin/firestore`
now use native `Date`. Nothing else about them changed — field names, enum
values and the `{en, pt}` bilingual type are all as they were. Doc comments
that named Firestore paths now name tables.

---

## The layer rule held, with two exceptions that were the point

The brief said everything above `repositories/` should survive unchanged, and
that if a service or controller needed editing then the separation was not as
clean as claimed.

**Controllers, routes, schemas, middleware and error handling: not touched.**
Not one line. The endpoint contract is byte-identical.

**The service was edited**, in three places, and each one is a database
concern moving *down* rather than a new one moving up:

1. **It imported `Timestamp` from `firebase-admin/firestore`** to stamp times,
   with `utils/timestamps.ts` existing solely to convert it. The previous
   README defended this as "a value type, not a database handle". It was still
   the database's type in a service. Now: `new Date()`, and the util file is
   deleted.

2. **It built dotted Firestore field paths.** `updateProfile` wrote
   `patch['coachingPreferences.tone'] = …` because Firestore replaces a nested
   map wholesale, so patching one preference would have dropped the other two.
   That is Firestore's document model showing through a service method. The
   service now passes a plain nested patch; the repository flattens it to
   three columns. There is also a related hack gone — the service used to
   *rebuild* the preferences object on the response because the repository
   merged dotted keys literally. `update … returning *` makes that unnecessary.

3. **`createProfile` was a read, then a create, then a hopeful re-read** on
   failure, because two first requests for the same unknown uid could race and
   Firestore had no atomic way to settle it. It is now one call:
   `insert … on conflict (id) do nothing returning *`, and the repository
   reads the winning row inside the same transaction when the insert lost.
   The brief asked for this explicitly.

Verified after the fact:

```
$ grep -rlE "from 'pg'|config/database" src/controllers src/services
(nothing)
$ grep -rlE "from 'express'" src/services src/repositories
(nothing)
```

`routes/health.routes.ts` imports `checkDatabaseConnectivity` from
`config/database.js`. That is a liveness probe, not a query, and it is the
same exception the Firestore version had.

---

## What Postgres actually bought

Not a list of features — the four things that are concretely better in this
codebase than they were last week.

**Account deletion is one statement.**

```sql
delete from users where id = $1;
```

Every child table cascades. The Firestore version was 90 lines: a
`USER_SUBCOLLECTIONS` constant that a new subcollection had to be remembered
into, a paged walk, a depth-first descent into `sessions/{id}/messages`, and
batch-size arithmetic. The README even had a section warning that forgetting
to update the list would orphan data. That whole class of mistake is gone —
the constraint is declared once, at the table, and the database enforces it.

**A profile read is one query instead of three.** Users, onboarding and
subscription came from three documents in three places; they now come back
through two left joins.

**Creation is atomic instead of optimistic.** Covered above.

**Milestones and action items are rows.** They were embedded arrays because
Firestore made joins awkward. A milestone can now be updated without
rewriting its goal.

One more that is easy to miss: **local data survives a restart.** The
Firestore emulator held everything in memory, so `npm run seed` was needed
after every restart. Postgres is a database.

---

## The one real bug this found

`date_of_birth` is a `date` column. node-postgres parses `date` into a JS
`Date` at **local** midnight. On this machine — UTC+5 — `1991-04-17` would
have come back as a Date at 05:00 local, and `.toISOString()` on it produces
`1991-04-16T19:00:00.000Z`. **A date of birth silently a day early**, on every
machine east of UTC, and correct on a UTC CI box, which is the worst kind.

`config/database.ts` disables the parser for that type and keeps the wire
value verbatim; the repository converts explicitly in UTC, in one place, in
both directions. Verified on the UTC+5 machine:

```
"dateOfBirth": "1991-04-17T00:00:00.000Z"
```

The same rule applies to `target_date`, `due_date` and
`progress_snapshots.date`, and the seed script uses it too.

---

## Two decisions worth flagging

### Bilingual columns: paired for library content, single for written content

The brief says bilingual content should be paired `_en` / `_pt` columns rather
than jsonb, because the client wants to read and edit it in Supabase's table
view. Its own column list then gives `exercises.title_en/pt` and
`onboarding_responses.ambition_en/pt` as pairs, but `goals.title`,
`chat_messages.text`, `coaching_sessions.summary`, `notifications.title/body`,
`purpose_answers.answer` and `exercise_responses.suggested_action` as single
columns.

I followed the column list exactly, because it is coherent: **library content
that an admin maintains in two languages is paired; content a person or the
coach writes is one column, in the language it was written.** Under Firestore
those single-language fields were `{en, pt}` maps holding the *same string
twice*, because the Dart `asTyped` helper duplicates whatever the user types.
The second copy never carried information.

**This diverges from the Flutter models**, which type those fields as
`Map<String, String>`. Nothing is broken today — no repository reads those
tables in this pass. When the goals and coaching passes land, the repository
should map one column to `{ en: value, pt: value }` on the way out, which is
what `asTyped` already does on the Dart side. I did **not** change the
TypeScript models to `string`, because the wire format the app expects is
still a locale map and changing them would be a contract change for endpoints
that do not exist yet. It is written into the README under
"One divergence to settle in the next pass" so it is not discovered by
surprise.

### `documentsDeleted` keeps its name

`DELETE /v1/me` still answers `{ "deleted": true, "documentsDeleted": 49 }`.
There are no documents any more, but the endpoint contract was to stay exactly
as it is, and renaming a response field would break a client for cosmetics.
It counts rows now. The dependent rows are counted in the same transaction
immediately before the delete, so the number is accurate.

---

## Verification

Against a real Postgres 18.4 on port 55432, the Firebase Auth emulator, and
the API on 8787.

### 1. Build, lint, typecheck

All three clean.

### 2. Migrations

Dropped and recreated the database, then ran `npm run migrate` three times.

| Run | Result |
| --- | --- |
| 1, empty database | `001_initial_schema.sql` applied in 208ms. `002` failed at `create extension vector` and **rolled back**. |
| 2 | `001` skipped — already recorded. `002` retried, failed identically, rolled back. |
| 3 | Identical to run 2. |

After the failed `002`: `schema_migrations` holds only `001`, the database has
15 tables, and `to_regclass('public.knowledge_chunks')` is null. The rollback
was complete — a failed migration leaves nothing behind and is not marked
applied, so fixing the cause and re-running is the whole recovery procedure.

The checksum guard was tested by appending a comment to an applied migration:

```
Migration failed: These migrations were edited after being applied:
  - 001_initial_schema.sql
```

Restoring the file cleared it.

**Migration 002 has never been applied end to end** — see
[What could not be done](#what-could-not-be-done-1).

### 3. Schema

| Check | Result |
| --- | --- |
| Tables created | 14 application tables + `schema_migrations` |
| Foreign keys | 12, **every one `on delete cascade`** (`confdeltype = 'c'`) |
| RLS enabled | all 15 tables |
| Policies | **0**, on all 15 |
| `updated_at` triggers | `users`, `onboarding_responses`, `goals`, `purpose_answers`, `subscriptions` |

### 4. Seed

`npm run seed` writes 49 rows across twelve tables, plus 2 exercises and 5
exercise steps in the shared library. Run twice: identical counts, no
duplicates. Counts are read back from the database, not tallied by the script.

### 5. Endpoints — 40 assertions, 40 passed

| Group | Cases |
| --- | --- |
| Health | `/v1/health` 200; `/v1/health/ready` 200 reporting `database: ok` |
| Auth | no token → 401; junk token → 401 |
| Seeded persona | `GET /v1/me` 200 with the persona; `dateOfBirth` `1991-04-17T00:00:00.000Z`; `GET /v1/me/onboarding` 200, `isComplete: true`, `motivationBalance: 0.35` |
| First contact | `GET` on a fresh uid → **404 `profile_not_found`**; `POST` → **201** with `countryCode` `mz` upper-cased to `MZ` and defaults Purpose / day 1 / streak 0 / direct-daily-reminders-on; `POST` again with a different name → **200**, `name` and `joinedAt` **unchanged**, no duplicate row; `email` in the body → 422; `preferredLanguage: "fr"` → 422 |
| PATCH | Set `rhythm: weekly` and `remindersEnabled: false`, then patched **`tone` alone** → tone changed, **rhythm and remindersEnabled survived**, name untouched; unknown key → 422 |
| Onboarding | All seven answers round-trip; `completedAt` server-stamped; `isComplete` derived; **UTF-8 byte-exact** through Postgres (Portuguese accents checked by comparing the request body to the response); re-submitting with a different `focusAreaKeys` **replaces** rather than merges, so a removed focus area is gone |

### 6. Deletion cascade — counted across every table

| Table | Before | After |
| --- | --- | --- |
| users | 1 | 0 |
| onboarding_responses | 1 | 0 |
| goals | 2 | 0 |
| milestones | 6 | 0 |
| action_items | 4 | 0 |
| exercise_responses | 1 | 0 |
| coaching_sessions | 2 | 0 |
| chat_messages | 6 | 0 |
| purpose_answers | 2 | 0 |
| notifications | 2 | 0 |
| subscriptions | 1 | 0 |
| progress_snapshots | 21 | 0 |
| **total** | **49** | **0** |
| `exercises` / `exercise_steps` (shared, not the user's) | 2 / 5 | **2 / 5** |

The response reported `documentsDeleted: 49`. The Firebase Auth record was
removed — the account no longer appears in the emulator — and the token minted
before the delete now returns **401**, which is `checkRevoked` doing its job.

### 7. Readiness and fail-fast

| Case | Result |
| --- | --- |
| `/v1/health/ready`, database up | **200**, `database: ok` |
| `/v1/health`, database **down** | **200** — liveness is process state, so Cloud Run does not restart a healthy instance over a slow database minute |
| `/v1/health/ready`, database **down** | **503**, `database: unreachable` |
| Database back up | **200** again, no restart needed — the pool reconnects |
| Boot with the database down | Exits before listening: `Cannot reach the database. The server will not start.` with the pooler hint and `connect ECONNREFUSED`. **No connection string in the output.** |

### 8. Row level security — the check the client asked for

Both Supabase roles were recreated locally **with the broad grants Supabase
gives them by default** (`grant select, insert, update, delete on all tables
in schema public`), so RLS is the only thing in the way. Rows were present
throughout, and the service role could see them — so a zero is RLS, not an
empty table.

| Role | Rows visible | Writes |
| --- | --- | --- |
| `anon` | **0** from all 15 tables | refused on all 15 |
| `authenticated` | **0** from all 15 tables | refused on all 15 |
| service role | all rows | permitted |

`knowledge_chunks` gets the same treatment; its RLS was verified in the
throwaway database where the rest of migration 002 was applied.

### 9. No SQL built by concatenation

Every interpolation in a SQL string was inspected. There are six, all in
`user.repository.ts`, and none of them carries a value:

- `USER_COLUMNS`, `ONBOARDING_ALIASED_COLUMNS`, `SUBSCRIPTION_ALIASED_COLUMNS`
  — string constants defined in the file.
- `USER_PATCH_COLUMNS[key]` — a column name from a fixed map, where `key` is a
  typed union, so a field name a client sends cannot become SQL.
- `$${String(values.length)}` — a placeholder *number*.

Every value goes in as `$n`. No credentials in code; `.env` is git-ignored and
nothing was committed that holds one.

### 10. Logs

35 log lines from the full run, swept for `example.com`, `Marisa`,
`Chissano`, `Ana Marques`, `Bearer`, `eyJ`, `password`, `postgresql:`, the
database port, Portuguese answer text, both dates of birth, `authorization`
and `cookie`. **All absent.**

The complete set of field names that appear anywhere in the logs:

```
code documentsDeleted environment isComplete level maxPoolClients message
method mode path port req reqId requestId res responseTime service severity
status statusCode time uid version
```

Method, route path, status, duration, request id, uid, and operational
metadata. Nothing a user typed, no email, no token, no connection string.

### 11. Shutdown

Windows has no real SIGTERM, so the handler was invoked directly with
`process.emit('SIGTERM')` against the real entrypoint — the same code path the
OS takes. With five connections checked out:

```
connections held before shutdown: 5
"signal":"SIGTERM","message":"Shutting down"
"message":"Shutdown complete"
```

`pg_stat_activity` afterwards: **0** connections with
`application_name = 'succenergy-api'`. The pool drains rather than leaving
connections for Supabase's pooler to time out, which matters when the
server-side pool is fifteen wide.

---

## What could not be done

Stated plainly.

1. **Migration 002 has never been applied end to end.** The local Postgres
   available on this machine has no pgvector, so `create extension vector`
   stops it. That is the correct failure and the transaction rolls back
   cleanly — verified three times — but it means the file has not run in full
   anywhere.

   Everything in 002 **except** the extension and the ivfflat index *was*
   verified, by applying the file to a throwaway database with exactly two
   substitutions (`vector(1024)` → `text`, ivfflat → btree) and nothing else
   changed: all ten columns, both check constraints, the `principle` and
   `content_type` indexes, and RLS on with zero policies. The two unverified
   statements are standard pgvector and should apply on Supabase, where the
   extension exists — but that is an expectation, not a fact, and it should be
   the first thing checked when the migrations are run there.

2. **Nothing was deployed, and the live service still runs the Firestore
   build.** Checked rather than assumed: revision `succenergy-api-00002-ltn`
   at https://succenergy-api-4612920383.us-east1.run.app answers
   `/v1/health/ready` with `checks.firestore`, `environment: production`. So
   **the API in production is reading Firestore and this repository is not** —
   they are out of step until someone redeploys.

   Same three blockers as the previous two passes, re-checked: no `gcloud`
   CLI on the machine, no Docker daemon (Docker Desktop installed, no
   registered service, `docker info` cannot reach the pipe), and the
   signed-in Firebase account is read-only on the project.

   Two of the prerequisites are the client's, not a tooling problem:
   **the connection string has to be in Secret Manager** and **pgvector has to
   be enabled** on the Supabase project. The README's deploy section lists
   both, in order, ahead of the deploy itself.

3. **The secret name is a placeholder.** `SECRET_NAMES.DATABASE_URL` is
   `'supabase-database-url'`. The client is adding the entry; if she names it
   anything else, that one string has to change. A wrong name fails the boot
   with a clear message rather than running degraded — but it fails the
   *deploy*, so it is worth confirming first. The constant carries the warning
   in a comment and the README repeats it.

4. **`--max-instances 10` and `max: 5` are in tension with a 15-connection
   Supabase pool.** Ten warm instances would want fifty connections. In
   practice they are rarely all warm and the transaction pooler multiplexes,
   so this is fine as configured — but **raising either number without raising
   the Supabase compute tier is how this service starts failing under load.**
   Noted in the README next to the deploy command rather than left as a
   surprise.

5. **The ivfflat index is meaningless until it is rebuilt.** ivfflat clusters
   the rows that exist when it is created; built against an empty table it
   stays useless as rows arrive. After the first ingestion run:
   `reindex index knowledge_chunks_embedding_idx`, with `lists` sized to
   roughly rows/1000. This is in a comment in the migration and in the README,
   because it is exactly the kind of thing that gets forgotten and then shows
   up as "retrieval is slow".

6. **The Docker image build is still unverified** — third pass in a row, same
   missing daemon. `migrations/` was added to `.dockerignore` this pass, which
   changes the build context, so it is worth a `docker build` on a machine
   with a daemon before the redeploy.

7. **Bilingual single-column fields diverge from the Flutter models.**
   Covered above under [Two decisions worth flagging](#two-decisions-worth-flagging).
   No endpoint is affected in this pass; the goals and coaching passes have to
   settle it.

8. **RLS was verified against a local Postgres, not against Supabase.** The
   local check recreated the `anon` and `authenticated` roles with Supabase's
   default grants, which is a faithful reproduction of the mechanism — RLS on,
   no policies, grants present but useless. It is not the same as pointing the
   client's real anon key at the client's real project. **Re-run that check
   once the migrations are applied on Supabase**, before any real data is in
   there. It is the client's explicit request, and it is one query.

---

# Migrations Follow-Up

The client confirmed migrations run through **Supabase's GitHub integration**.
That changes where the files live and, more importantly, who owns applying
them.

`npm run build`, `npm run lint` and `npm run typecheck` are all clean.

## The move

| Was | Now |
| --- | --- |
| `backend/migrations/001_initial_schema.sql` | `supabase/migrations/20260903120000_initial_schema.sql` |
| `backend/migrations/002_rag_embeddings.sql` | `supabase/migrations/20260903120100_rag_embeddings.sql` |

Both moved with `git mv`, so the history follows. The SQL is unchanged except
for the two things below; the initial schema's only edit is its first line, a
comment that echoed the old filename. Verified: everything below that line is
byte-identical to what was committed.

The path and the naming are both load-bearing. The integration reads
`supabase/migrations/` and nowhere else, and takes each migration's *version*
from the leading digits of the filename. `backend/migrations/001_*.sql` was
invisible to it on both counts — it would never have been applied, and nothing
would have said so.

`loadMigrations` now rejects a file that is not `<digits>_<name>.sql` rather
than quietly including it, for the same reason: the integration would skip it
silently, so the local runner should not be the more permissive of the two.

## 1. Two trackers that could not see each other

The real hazard, and the one worth spelling out.

The integration records applied migrations in
`supabase_migrations.schema_migrations`, keyed by version. `migrate.ts` had
its own `public.schema_migrations`. Neither could see the other, so a
migration applied by one would be **re-applied by the other** — `create table`
run twice, and for anything not written idempotently, a failed deploy or a
half-built schema.

Documenting that as a caveat would not have fixed it. So there is now **one
tracker**, and it is Supabase's:

- `migrate.ts` reads applied versions from
  `supabase_migrations.schema_migrations` and writes to it in the same format
  the CLI does — `version` from the timestamp prefix, `name` from the rest.
- `statements` is left null. It is the CLI's own record of how it split the
  file and nothing reads it back.
- It does **not** `alter` that table. On a real project the table is
  Supabase's and already exists; the script reads
  `information_schema.columns` and adapts to the columns that are there. It
  creates the table in the CLI's full shape only when bootstrapping an empty
  database, so a database started locally is one the integration can later
  write to.
- Checksums moved to a sibling table, `supabase_migrations.local_checksums`,
  and are now **advisory**: a migration the integration applied has no
  checksum row and is not second-guessed. Only what the local runner applied
  is guarded against being edited.

Neither table gets RLS, and that is deliberate rather than an omission: the
`supabase_migrations` schema is not one of the schemas PostgREST exposes, so
an anon or authenticated key cannot reach it through the API at all. The
previous pass enabled RLS on `public.schema_migrations` because it *was* in an
exposed schema. That table is no longer created.

**Ownership is now stated in three places** — the module docstring, the README
under [Migrations](backend/README.md), and the deploy prerequisites, which
previously told the reader to run `npm run migrate` against Supabase by hand
and now says to push and let the integration apply it.

And it is enforced, not just documented: `migrate.ts` refuses under
`NODE_ENV=production` and prints the host it is about to migrate before
writing anything. That guard sits **above** the import of
`config/database.js`, because that module pulls in `config/env.js`, which
validates at import time and calls `process.exit` — a static import had the
script refused for the wrong reason, with a message about environment
variables rather than about which tool owns production migrations. It uses a
dynamic import for the same reason `scripts/seed.ts` does.

## 2. `vector` is in a different schema on Supabase

Correct, and it would have broken. Supabase pre-installs pgvector into
`extensions`, not `public`, so the unqualified `vector(1024)` in the table
definition would not have resolved.

The fix is a search path rather than a hard qualification:

```sql
set search_path = public, extensions;
create extension if not exists vector;
```

`extensions.vector(1024)` was the other option and it is more explicit, but it
would have **broken the local Docker path**, where `create extension` puts the
type in `public` and there is no `extensions` schema at all. Naming both
schemas resolves in either database, and a schema that does not exist is
ignored on the search path rather than being an error.

`set` rather than `set local`: `set local` is silently ignored with a warning
outside a transaction block, and whether the integration wraps each file in
one is exactly the assumption being avoided.

### This was tested, and the fix is load-bearing

No pgvector build exists for the Postgres on this machine, so the extension
itself still cannot be installed. But the *schema-resolution* problem — the
thing the change is for — was tested directly, by creating a `vector` type
with typmod support in an `extensions` schema, laid out as Supabase lays it
out, and running the real migration file with only the two statements that
need pgvector's C code substituted:

| Database | `vector` type in | File | Result |
| --- | --- | --- | --- |
| `sp_with_fix` | `extensions` | as committed | **applied** — `embedding` is `vector(1024)` |
| `sp_without_fix` | `extensions` | `set search_path` line removed | **failed** — `type "vector" does not exist` |
| `sp_public` | `public` | as committed | **applied** — `embedding` is `vector(1024)` |

So the fix does something, it is the thing that makes it work, and it does not
break the local case. The typmod survives, which was the other thing worth
checking — `vector(1024)` parses as a parameterised type, not just a name.

## Verification

Everything from the previous pass re-run after the move.

| Check | Result |
| --- | --- |
| `npm run build` / `lint` / `typecheck` | clean |
| Migrate on an empty database | initial schema applied in 324ms; RAG migration failed at `create extension vector` and rolled back |
| Migrate again | initial schema skipped; nothing re-applied |
| Tracking table | `supabase_migrations.schema_migrations` holds `20260903120000 / initial_schema`; `public.schema_migrations` is **not created** |
| Checksums | `supabase_migrations.local_checksums`, 64-char SHA-256, one row |
| **Integration's rows are respected** | Inserted `20260903120100` directly, as the integration would. `npm run migrate` then reports "Database is up to date. 2 migration(s) already applied." and does **not** attempt it. |
| Edit guard, migration the runner applied | refuses, names the file |
| Edit guard, migration the "integration" applied | **does not** complain — advisory only, as intended |
| `NODE_ENV=production` | refuses, with the message about the integration owning production |
| `npm run seed` | 49 rows across twelve tables, plus the shared library |
| Endpoint suite | **40 assertions, 40 passed** |
| Delete cascade | 49 rows before, `documentsDeleted: 49`, 0 after, shared library intact |
| RLS | `anon` and `authenticated` see 0 rows and cannot write, all 15 tables; service role sees the data |

## What could not be done

1. **The RAG migration still has not run against a real Supabase instance.**
   The schema-resolution risk is now tested and closed, but
   `create extension vector` and the ivfflat index have never executed for
   real, anywhere — there is no pgvector build available here. They should be
   the first thing checked when the integration applies this.

2. **There is no `supabase/config.toml`.** Only the migrations were moved,
   which is what was asked. The GitHub integration is normally configured
   against a repository that has been through `supabase init`, and depending
   on how the client set the integration up it may expect that file and the
   project ref in it. **Worth confirming the first push actually applies both
   migrations** rather than assuming silence means success — the
   `select version, name from supabase_migrations.schema_migrations` in the
   README's deploy prerequisites is there for exactly that. I did not
   fabricate a config file with a guessed project ref.

3. **Still not deployed**, and the live service still runs the Firestore
   build. Unchanged from the previous pass; same missing `gcloud` and Docker
   daemon.

---

# CLIENT FEEDBACK ROUND 2

**Date:** 2026-09-04
**Scope:** the ten items in the round-2 revision brief. Frontend only, still on mock data. No backend, no API calls, no payment SDK, no audio.
**State:** `flutter analyze` clean. `flutter test` 7/7 green. EN and PT key sets identical at 468 keys each.

**The decision this pass turns on:** the seven-day trial now opens the **Purpose** exercises alone. The other six principles are what a monthly subscription opens. That is what makes the client's two remarks — "Locked and Included are Inversed" and "Exercise Library Free Trial only one Purpose" — describe the same defect, and it is what the rest of item 1 and all of item 2 follow from.

---

## Part 1 — What changed, file by file

### Item 1 — Subscription: the locked / included inversion

Two separate faults, both real.

**Fault A — the tier was read from a seed, not from the account.** `MockSubscriptionRepository` initialised `_tier` from `MockData.user.tier`, which is `professional`. So an account that had just registered and taken the trial opened Plans and was told its current plan was Professional at $33 a month, while the Student card beside it carried "YOUR TIER". Settings showed the same wrong plan.

**Fault B — the two columns held each other's values.** Every plan shared `includedFeatureValueKeys`, so the trial was described as including all seven principles, while the limited values ("Purpose and Passion", "Five messages a week") sat in a `lockedFeatureValueKeys` column describing a pre-trial state the router's paywall makes unreachable. Under the trial scope above, the limited exercise value is what the trial **includes** and the full value is what stays **locked** — exactly the client's sentence, "the description of Locked is where Included needs to be".

| File | Change |
|---|---|
| [mock_subscription_repository.dart](lib/data/mock/repositories/mock_subscription_repository.dart) | Takes the `AuthRepository`. `loadCurrentTier()` returns the account's own tier, falling back to a plan chosen on the Plans screen. No seed |
| [subscription_repository.dart](lib/data/repositories/subscription_repository.dart) | Added a synchronous `currentTier` getter, for the library, which has to decide on every build |
| [subscription_plan.dart](lib/data/models/subscription_plan.dart) | New `SubscriptionEntitlements` extension: `opensWholeLibrary` and `opens(Principle)`. The one place the trial's scope is written down |
| [mock_data.dart](lib/data/mock/mock_data.dart) | `lockedFeatureValueKeys` replaced by `trialFeatureValueKeys`. The trial plan points at it; both monthly plans keep `includedFeatureValueKeys` |
| [feature_comparison_table.dart](lib/features/subscription/widgets/feature_comparison_table.dart) | Rewritten, tier-aware. INCLUDED comes first and gold, holding what the tier the user is on actually gives. LOCKED comes second and holds only what differs. On either monthly rate nothing differs, so the table collapses to one column rather than printing an empty one |
| [subscription_screen.dart](lib/features/subscription/subscription_screen.dart) | Passes the current tier and both value maps; holds the loader until the tier has arrived |
| [main.dart](lib/main.dart), [test/](test/) | Repository construction updated for the new signature |

Walked on all three tiers and rendered to PNG:

| Tier | Card marked current | Table title | Exercise library row |
|---|---|---|---|
| 7-day trial | 7-day trial, "YOUR PLAN" | What a subscription opens | Included: **Purpose only** · Locked: All seven principles |
| Student \| Minorities | Student, "YOUR TIER" | Included in your plan | Included: All seven principles |
| Professional | Professional, "YOUR TIER" | Included in your plan | Included: All seven principles |

### Item 2 — Free-tier exercise library scope

Gating, not hiding. Every exercise still loads and still renders; the locked ones say so and go to Plans instead of into a session.

| File | Change |
|---|---|
| [exercises_provider.dart](lib/features/exercises/exercises_provider.dart) | Takes the `SubscriptionRepository`. `isUnlocked(Principle)` and `hasLockedPrinciples` read the tier on every call, so a plan chosen on Plans takes effect on the way back |
| [exercise_card.dart](lib/features/exercises/widgets/exercise_card.dart) | New `isLocked`. Title drops to secondary, the duration is replaced by a lock and "Locked", and the footer reads "Open with a subscription" in gold |
| [principle_selector.dart](lib/features/exercises/widgets/principle_selector.dart) | Locked principles keep their pill and carry a small lock glyph. The row still teaches the whole seven-principle sequence |
| [exercises_screen.dart](lib/features/exercises/exercises_screen.dart) | Passes the locked state; a tap on a locked card pushes Plans and refreshes on return. The header line becomes "Your trial opens Purpose. A subscription opens the other six principles." while anything is locked |
| [router.dart](lib/app/router.dart) | `ExercisesProvider` now gets the subscription repository |

### Item 3 — Trial billing copy

The client's sentence verbatim, with the rate from the activity chosen at registration. `trial.smallPrint` is gone.

| File | Change |
|---|---|
| [app_strings.dart](lib/core/localization/app_strings.dart) | New `trial.billing.student` and `trial.billing.professional`, EN and PT. `{price}` is still substituted from `AppConstants`, so the figure lives in one place |
| [trial_screen.dart](lib/features/trial/trial_screen.dart) | Picks the key from the activity. Left-aligned rather than centred: it is now a paragraph, not a one-line note |

### Item 4 — Onboarding intro copy

`auth.register.subtitle` was "Seven questions and your coach will know how to work with you." It is now the client's exact line, in both languages. No structural change: seven is still three before registration and four after. **See the naming flag in Part 3.**

### Item 5 — Email placeholder and persona leakage

The email hint was already `taniatome@succenergy.com` — the brief's description of it as `marisa.chissano@lumeconsult.co.mz` was out of date. The **name** hint was `Tânia Tomé`, which is still a persona name, so it is now neutral: "Your full name" / "O seu nome completo".

Grepped `lib/`, `ios/` and `android/` for the old persona: the only remaining occurrences are in [mock_data.dart](lib/data/mock/mock_data.dart), which is seeded demo data rendering on Profile and the Dashboard as intended. No widget holds a hardcoded persona value. **See Part 3** — this is almost certainly what the client is reading as "the account".

### Item 6 — Privacy Policy, and no dead callbacks

| File | Change |
|---|---|
| [app_constants.dart](lib/core/constants/app_constants.dart) | `placeholderTermsUrl` and `placeholderPrivacyUrl`, in the existing placeholder block. **Neither is a confirmed destination** |
| [settings_screen.dart](lib/features/settings/settings_screen.dart) | Terms and conditions, then Privacy policy, in the About group beside Help and about. Both open through `ExternalLinks` and are marked "Opens in your browser" |
| [help_about_screen.dart](lib/features/help_about/help_about_screen.dart) | The two `onPressed: () {}` links now open the same two constants |

`grep -rn "() {}" lib/` returns only `setState(() {})` rebuild triggers. No dead callback remains anywhere in the app.

### Item 7 — App name on the home screen

`android:label` and `CFBundleDisplayName` are both **`Succenergy`**. See Part 3 for why this is not the two-line name the client asked for.

### Item 8 — Welcome screen space background

[earth_glow_painter.dart](lib/features/welcome/widgets/earth_glow_painter.dart) rewritten against [welcome_screen_reference.png](assets/design_reference/welcome_screen_reference.png), with the bloom extracted to [horizon_bloom.dart](lib/features/welcome/widgets/horizon_bloom.dart) to keep both files short.

What was wrong, and what replaced it:

| Was | Now |
|---|---|
| The body's radial gradient ran *lighter* deep inside and darkest at the rim, so only a 10%-of-radius sliver was ever visible — a band, not a sphere | Body filled near-black, then lit by two passes clipped inside the circle and centred on one point on the rim. It falls to black as it turns away |
| Two `drawArc` haze passes at flat alpha across the whole upper semicircle — glow spread evenly along the arc | A `SweepGradient` rim shader concentrating at the light. The halo passes fall away fast; the hard 1.8px line keeps a floor of 0.30 so the edge stays legible to both frame edges |
| Nothing above the horizon but stars | A wide, low haze pass centred on the light, painted before the body |
| A symmetric two-circle flare at the apex | One bloom: an asymmetric blue spill scaled 1.45 × 0.68 and pushed past the light, a tight off-white core, a pinpoint, and four rays — the long one along the rim, a shaft up, two shorter diagonals |
| 90 evenly scattered gold points | 16 deterministic clusters of 9, fading as they approach the rim where the atmosphere would wash them out |

The light sits **on** the curve, not above it: `_lightOn()` solves for the point on the circle at the drifted x, which is what stops the bloom reading as a lamp hung over the horizon. Drift holds at 0 under reduced motion, leaving the light on the peak and still.

`StarfieldPainter` was **not** changed — 110 deterministic points, every ninth brighter, no twinkling, already what the brief asks for.

Rendered to PNG at 390×844 and 360×720 and inspected; the tuning above was driven by those renders, not by reading the code.

### Item 9 — Transparent wordmark

| File | Change |
|---|---|
| `assets/branding/succenergy_logo_wordmark_transparent.png` | Added. 3375×804 RGBA; verified by decoding the IDAT — background alpha 0, glow preserved as semi-transparent pixels |
| `assets/branding/succenergy_logo_wordmark.png` | **Deleted.** Nothing referenced it |
| [asset_paths.dart](lib/core/constants/asset_paths.dart) | Points at the transparent file. Still the only path constant for the lockup |
| [succenergy_wordmark.dart](lib/core/widgets/branding/succenergy_wordmark.dart) | **`fullBleed` removed.** The widget is now a plain width-sized image, default 260 — measured to clear the horizontal screen padding at the 360px minimum layout. Still the only file referencing the asset |
| [welcome_screen.dart](lib/features/welcome/welcome_screen.dart), [splash_screen.dart](lib/features/splash/splash_screen.dart), [help_about_screen.dart](lib/features/help_about/help_about_screen.dart) | Call sites updated. Help/About centres it at 220; the other two take the default |

A first attempt clamped the width with a `LayoutBuilder`, which threw `LayoutBuilder does not support returning intrinsic dimensions` inside the Welcome screen's `SliverFillRemaining`. Replaced with a plain `SizedBox`; the default width already fits the narrowest supported layout.

Confirmed by render on Welcome and Help/About: no panel, no seam.

### Item 10 — App icon

`flutter_launcher_icons` was already configured against `assets/branding/succenergy_app_icon.png` with `#0A1628` as the adaptive background. Re-ran `dart run flutter_launcher_icons` and verified the output:

- Five Android mipmaps, five `drawable-*/ic_launcher_foreground.png`, `mipmap-anydpi-v26/ic_launcher.xml` with a 16% inset, and `values/colors.xml`.
- 22 files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`, including `Icon-App-1024x1024@1x.png`, with `remove_alpha_ios: true`.
- All regenerated byte-identically to what was committed — the "S" symbol was already correctly installed on both platforms. `git status` reports no change to any icon file, which is the proof rather than the absence of one.

See Part 3 for why this is the symbol alone rather than the two-line icon the client asked for.

---

## Part 2 — Verification

| # | Check | Result |
|---|---|---|
| 1 | `flutter analyze` | **Clean.** No issues found |
| 2 | Subscription screen on every tier | **Yes** — walked and rendered on trial, Student and Professional; the table above records what each reads |
| 3 | Trial tier: Purpose available, six locked | **Yes** — rendered. Purpose cards open; Passion onward carry the lock, "Open with a subscription", and lock glyphs on their pills. On a monthly tier the whole library opens and the locks are gone |
| 4 | Trial screen rate and copy, both registration types | **Yes** — rendered both. Professional shows $33 and the Professional sentence; Student shows $11 and the Students & Minorities sentence, and only that rate |
| 5 | No old persona in any field hint | **Yes** — `grep` over `lib/`, `ios/`, `android/`. Remaining hits are seeded mock data only |
| 6 | Privacy Policy in Settings; no dead callbacks | **Yes** — rendered. `grep -rn "() {}" lib/` returns only `setState` rebuilds |
| 7 | Launcher name and icon | **Yes** — `android:label="Succenergy"`, `CFBundleDisplayName` `Succenergy`; icon set regenerated and verified on both platforms |
| 8 | Welcome background reads as a lit planet | **Yes** — rendered at two sizes and inspected |
| 9 | Wordmark shows no panel; `fullBleed` gone; old PNG removed | **Yes** — rendered on Welcome and Help/About. `grep` finds no `fullBleed` and no reference to the old file; only `succenergy_wordmark.dart` names the asset |
| 10 | EN and PT key sets identical | **Yes** — 468 keys each, no key in one map and not the other, no duplicates |
| 11 | No new hex literals, `Colors.*`, emojis or non-glow shadows | **Yes** — over every touched file: no `0x`-literal colours, no bare `Colors.`, no `BoxShadow(`, no pictographs |
| 12 | No touched file over 250 lines, no `build()` over 60 | **Yes** — largest touched file is `settings_screen.dart` at 244; `earth_glow_painter.dart` 242, `horizon_bloom.dart` 120. Longest touched `build()` is 41 |
| — | `flutter test` | **7/7 green.** Two harnesses updated for the repository signature |

Two things still exceed the limits, **both untouched by this pass and both from the first commit**: `app_bottom_nav.dart` at 542 lines, and 71-line `build()` methods in `onboarding_summary.dart` and `admin_gate_screen.dart`. The earlier audit's claim that no `build()` exceeds 60 was too generous. Not fixed here — outside this round's scope, and worth a separate pass.

---

## Part 3 — Deviations, and the item still needing the client's decision

### 1. The coach name — this one needs the client to settle it

The copy in item 4 says **"AI Succenergy Coach"**. The client's locked system prompt says the coach is **"Succenergy AI Coach"** and states it must not deviate. Same words, different order.

The client's wording is used exactly as given, in item 3's billing sentence and item 4's registration subtitle, in both languages. But the app is now inconsistent with itself: `common.appName`, the Help/About body, the FAQ and the pubspec description all say "Succenergy AI Coach", and the store listing will too. One of the two has to give. Nothing has been guessed either way.

Where the name appears, for whoever settles it: the system prompt, the two copy strings changed this pass, `common.appName`, `help.about.body`, the `pubspec.yaml` description, and the eventual store listing.

### 2. The launcher name is `Succenergy`, not two lines

The client asked for "Succenergy" with "AI COACH" above it. Neither iOS nor Android supports a multi-line launcher label — both render one line and truncate at roughly 11–12 characters, so "Succenergy AI Coach" would show as "Succenergy A…". `Succenergy` is 10 characters, fits whole, and reads as the brand.

### 3. The app icon is the "S" symbol, not two lines of text

Three reasons: at actual home-screen size (~60×60pt) two lines of text are illegible, and Apple's Human Interface Guidelines advise against text in icons for that reason; the app name already appears beneath the icon, so text in the icon repeats it; and producing a new two-line icon would mean creating brand artwork, which the agreement reserves to the client's designer.

### 4. The transparent wordmark is correct for the app, not for print

It is a format conversion of the client's own asset — same shapes, same colours, background alpha derived from luminance so the glow survives as semi-transparent pixels rather than being clipped by a hard threshold. It composites correctly on any dark surface. It is **not** a substitute for a designer-produced transparent master: the lettering is additive light on near-black and will wash out on a white page. **The client should still ask her designer for a marketing-grade transparent version.**

### 5. The symbol above the wordmark still has a panel — and it is not the wordmark's

Worth flagging, because it may be part of what the client saw. On Welcome, Splash and Help/About, `SuccenergyLogo` renders `assets/branding/succenergy_app_icon.svg`, which has a **rounded-rectangle navy panel with a gold border baked into the artwork** — correct for an app icon, but on those screens it reads as a visible rectangle around the "S". The approved reference artwork shows the "S" free-standing with no panel.

This was not touched: it is brand artwork, and removing the panel means a panel-free "S" from the client's designer, not an edit here. If the "blue rectangle" the client reported was this rather than the wordmark, that is the asset to ask for.

### 6. The scope is enforced at the trial, because there is no browsable free tier

The brief describes the restriction as applying to a "free tier". The router's paywall ([subscription_gate.dart](lib/app/subscription_gate.dart), unchanged) sends any signed-in account without the trial flag straight to the paywall, so a genuinely free account can never reach the library. Implementing the scope there would have shipped code nothing could ever run.

It is enforced on the **trial** instead, per the client's own words ("Exercise Library Free Trial only one Purpose"), which is both reachable and observable. If the client actually wants a browsable free tier below the trial, that is a router change and a fourth tier, and it should be asked for explicitly.

### 7. The trial is limited in the library only

The client named the exercise library and nothing else. The trial therefore still opens the coach without a message limit, full coach memory, unlimited goals, adaptive personalisation and full analytics — the comparison table prints those under INCLUDED with nothing beside them under LOCKED. If she intends the trial to be limited on other dimensions too, the maps are one place: `trialFeatureValueKeys` in [mock_data.dart](lib/data/mock/mock_data.dart).

### 8. `trial.unlock.exercises` was rewritten

It said "Every exercise across the seven principles", which is no longer true. It now says "The Purpose exercises, to open the cycle" / "Os exercícios de Purpose, para abrir o ciclo". `trial.subtitle` lost its claim that the exercises open with the trial, for the same reason.

---

# Endpoints + Repository Swap Pass

The backend gained endpoints for every remaining feature, and five of the six
mock repositories in the app were replaced with clients for them. The AI
Coach's reply generation is the one thing still running on the device, and it
is isolated in a single file for the Claude pass to delete.

## Part 1 — What changed

### Backend

Every feature area got its own router, controller, service and repository. The
layer rule held throughout: no SQL above a repository, no Express type below a
controller, no `pg` import outside `repositories/`, and every value in every
statement is an `$n` placeholder.

| Area | Routes | Notes |
| --- | --- | --- |
| Goals | 15 under `/v1/me/goals` | Goal, milestones, action plan |
| Exercises | 2 under `/v1/exercises`, 3 under `/v1/me/exercise-responses` | Library shared, answers per-user |
| Purpose | 2 under `/v1/me/purpose` | Upsert per prompt |
| Progress | 2 under `/v1/me/progress` | Everything derived |
| Notifications | 4 inbox, 2 preferences | |
| Sessions | 6 under `/v1/me/sessions` | Data layer for the AI pass |
| Admin | 10 under `/v1/admin` | Behind `requireAdmin` |

Three rules were applied everywhere and are worth stating once:

**Ownership is never inferred from a path parameter.** Every statement carries
the uid from the verified token alongside the id from the URL. `milestones`,
`action_items` and `chat_messages` have no `user_id` of their own, so those
writes prove ownership with an `exists` against their parent. A guessed id
matches no row and 404s — and a resource that belongs to someone else and one
that does not exist give the same answer on purpose, because the difference
would confirm that an id is real.

**A dynamic SET clause is built in exactly one place.** `patch_builder.ts`
takes an allow-list of field-to-column names and returns a clause of `$n`
placeholders. A field a client invents cannot reach the SQL because it is not
a key of the map.

**What the client says about itself is not trusted where the database already
knows.** The principle an exercise response is filed under and the action it
captured are read from the exercise row, not the request. A progress snapshot's
figures are counted server-side and its date comes from `current_date`. A
session's principle comes from the profile.

### Flutter

| Repository | Backing | Widget files touched |
| --- | --- | --- |
| `GoalsRepository` | `/v1/me/goals` | none |
| `ExercisesRepository` | `/v1/exercises`, `/v1/me/exercise-responses` | none |
| `UserRepository` (incl. Purpose) | `/v1/me`, `/v1/me/purpose`, `/v1/admin/*` | none |
| `ProgressRepository` | `/v1/me/progress` | none |
| `NotificationsRepository` | `/v1/me/notifications` | none |
| `CoachRepository` | `/v1/me/sessions` | none |

**No widget file was modified by any swap.** The interfaces were already the
right shape, which is the thing that was being tested.

## Part 2 — Findings

### 1. The prompt's fix for the subscription mapper would have been a layer violation

The instruction was to read `row.sub_tier`, `row.sub_status` and the rest in
`user.service.ts`. A service cannot see rows — that is the layer rule this same
pass insists on, and the repository was already returning a mapped
`SubscriptionDocument` that the service's response mapper was dropping on the
floor. The fix maps that document instead. Same result, no inversion.

`isActive` is derived in the service from the same rule the API uses
everywhere, so the app never has to know which statuses count as open. It is
explicitly `null` when an account has none, never an omitted key, because the
launch gate has to tell "no subscription" from "not fetched".

### 2. The health check needed no work

`/v1/health/ready` already round-trips `select 1` through
`checkDatabaseConnectivity`. Nothing in `src/` mentions Firestore except
comments recording that it is gone.

### 3. Poppins is the app's type system, not something the auth pass introduced

The instruction assumed the auth pass had broken type consistency by
introducing Poppins where the rest of the app uses Exo 2 and Orbitron. It had
not. `grep -r Poppins lib/` returns two files: `app_typography.dart`, which is
the single source of type for every screen, and one comment in `main.dart`.
Both predate the auth work — they are in the **first commit** — and the five
bundled font files in `assets/google_fonts/` are Poppins.

`app_typography.dart` also records the decision explicitly: Orbitron was
*replaced*, and the letterspaced-caps register that used to be Orbitron is now
Poppins held apart by tracking and weight.

Every auth screen resolves its type through `AppTypography`, so they already
use exactly the same system as the rest of the app. **No change was made.**
Switching to Exo 2 and Orbitron would not be fixing an inconsistency in the
auth screens — it would be a brand change across all twenty-odd screens,
needing new font files and reversing a documented decision. If the client does
want that, it is its own pass and it should be asked for as one.

### 4. Five notification switches, two columns — a migration was added

The Notifications screen shows five switches keyed by localisation key. The
user row had `reminders_enabled`, a master switch, and `rhythm`. Neither can
hold five independent booleans, so four of the five would have moved and
forgotten — worse than not offering them, because a person who turns
re-engagement off and finds it on next launch has been lied to by the
interface.

`supabase/migrations/20260904090000_notification_preferences.sql` adds
`users.notification_preferences jsonb not null default '{}'`. jsonb rather than
five columns because the set is product copy, not schema: adding a
notification type should be a change to the localisation table and the switch
list, not a migration, and the keys are never queried individually.

The two profile fields still go through the user service's own patch, as
instructed — one place owns a profile column. Only the map is written by the
notification service, and it is merged with `||` rather than replaced, so a
client that renders three of the five switches cannot clear the two it has
never heard of.

### 5. There is no `PurposeRepository` in the app

The swap list named one. The Purpose prompts live on `UserRepository`, beside
the profile, because they are answers *about* the person rather than a feature
with a repository of its own. The unit that had to be swapped was therefore
that whole interface, which is what the commit did — profile, assessment,
Purpose answers and the two console reads together.

### 6. Two files were already over the 250-line limit

`user.repository.ts` (617) and `user.service.ts` (357) both broke the rule
before this pass and both had to be touched, so they were split along the seams
they already had: onboarding and account deletion into their own service and
repository, row shapes and column lists into `user_rows.ts`, the repository's
public shapes into `user_contracts.ts`, and the date, locale and count
conversions every new repository needed into `row_mappers.ts`. Nothing in
`backend/src/` is over 250 lines now.

`lib/app/router.dart` was in the same position on the Flutter side and was
split into `route_builders.ts` and `auth_routes.dart` during the auth pass's
verification.

### 7. The Dart models had no JSON layer

Nothing under `lib/data/models/` had `fromJson`. Rather than adding wire
concerns to the models, the mapping lives in `lib/data/implementations/*_mapper.dart`
beside the repositories that use it, following the precedent
`user_profile_mapper.dart` set in the auth pass. `Json` in `json_reader.dart`
is the only place in the app that knows the wire is JSON.

A field that is missing, null or the wrong type takes a defined fallback rather
than throwing. An app that will not open because one optional string arrived as
a number is worse than one showing an empty title.

### 8. The Dart and API shapes disagree in three places, resolved in the mappers

- **Exercise responses.** The API stores one row per completed run with the
  answers as a map; the Dart model is one `ExerciseResponse` per step. A read
  fans a session out, a submission collapses it back.
- **Derived goal fields.** The API sends `status`, `isCompleted`, `progress`
  and `actionsDone`; the Dart model computes all four. The mapper ignores the
  wire values, because two sources would be two answers that can disagree.
- **Exercise completion.** `Exercise.completedAt` is per-account and the
  library is shared, so it is merged in from the caller's own responses.

### 9. The reflection bug is fixed at the only level that could fix it

The mock collected the closing reflection and discarded it. It now has its own
column, out of `step_responses` because it is not one of the exercise's
declared steps, and the backend is the record of it. The mapper lifts it out of
the per-step list on submit and puts it back under the reserved step id on
read.

### 10. Progress has no constants left

Every figure is a count or an average over the rows that produced it. Two
choices worth naming: cycle completion is *distinct principles practised* over
seven, not exercises completed — ten exercises on Praxis is one principle
closed, and counting responses would have shown the cycle finished twice over
without the person leaving it. And the principle breakdown returns all seven
including zeros, so the chart draws seven bars without the client filling gaps
and the two disagreeing about what no practice looks like.

### 11. Providers had no error state, which a live backend makes a hang

Before this pass an exception from a provider's `load()` became an unhandled
async error with no screen attached: the loader would spin forever. `RequestGuard`
holds the loading flag and the failure and clears the flag in a `finally`, so a
provider cannot forget it. `RequestFailure` classifies whatever was thrown into
four cases with a localisation key each, so no widget branches on an exception
type and no message the server wrote is ever shown.

## Part 3 — What was skipped, and what is left

### Not done, and flagged rather than half-done

**Per-screen error rendering.** The providers now hold a typed failure and stop
loading, so nothing hangs and nothing crashes — but the screens read `loading`
and fall back to their existing `EmptyState`, which means a failure currently
degrades to "there is nothing here" rather than saying what went wrong.
Rendering `failure.messageKey` with the retry, per screen, is the next piece
and it is the one part of Part 4 that necessarily touches widget files.

**Every runtime verification step.** Nothing in the verify list that needs a
running backend was executed. `npm run build`, `npm run lint`, `npm run
typecheck` and `flutter analyze` are clean and the seven widget tests pass, but
the endpoint behaviour — create/get/update/complete/delete with cascade, the
library submitting with the reflection persisted, progress numbers moving,
sessions round-tripping, admin returning 403 without the claim — has not been
exercised against Postgres. Two things block it:

1. **The Firebase client config is still missing.** There is no
   `google-services.json`, no `GoogleService-Info.plist` and no
   `firebase_options.dart`. The app catches the init failure and reports
   sign-in as unavailable rather than crashing, but no device build can
   authenticate, so no endpoint can be reached from the app.
2. The local backend and dev Supabase were not started in this session.

The migration is also unapplied — `npm run migrate` has to run before the
notification preferences column exists.

### Deliberately unchanged

**The AI Coach's reply.** Lifted out of the mock unchanged into
`coach_reply_stub.dart` — one file, one job, named so it is obvious what to
delete. The conversation, the transcript and the session history are real and
persisted, which the mock never was; only the text of the reply is still
generated on the device. The Claude pass replaces one call and removes that
file, and nothing about the endpoints, the models or the repository's shape
changes when it does.

**The subscription repository.** Still mock. It reads the tier off the
signed-in account, and the real source is RevenueCat webhooks, which is a later
pass.

**Out of scope as instructed:** Claude API, RAG, embeddings, FCM, RevenueCat,
Stripe, and any deploy to Cloud Run.

### Layer violations found

One, and it was in the instruction rather than the code: the suggested
subscription mapper reached into row shapes from a service. Resolved by mapping
the document the repository already returns. Nothing else in the existing
codebase broke the layer rule — the boundaries the earlier passes drew held
under seven new feature areas without needing a shortcut.
