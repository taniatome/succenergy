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
