# Succenergy AI Coach

Flutter front end for **Succenergy AI Coach by Dr. Leadership Tânia Tomé**, built on
the Succenergy® methodology and its Seven Principles:

> Purpose → Passion → Planning → Praxis → Persistence → Progress → Perfection

This build is **front end only, on mock data**. There is no Firebase, no Claude API
and no payment SDK. Every screen is reachable and populated with one coherent
persona so the visual direction can be reviewed as a working product.

## Running it

```bash
flutter pub get
flutter run
```

```bash
flutter analyze   # expected: no issues
flutter test      # journey and smoke tests
```

The demo opens on the splash sequence and continues to Welcome. Any well-formed
input signs you in; the access code for the management console is `SUCC-ADMIN`.

## How it is put together

```
lib/
├── main.dart          The only file that names a repository implementation
├── app/               Root widget, router, route constants
├── core/
│   ├── theme/         Colours, type scale, spacing, glow, ThemeData
│   ├── motion/        Durations, curves, page transitions
│   ├── constants/     Asset paths and non-visual constants
│   ├── localization/  EN/PT copy, active locale, context.tr(...)
│   └── widgets/       Shared brand-carrying components, including CycleRing
├── data/
│   ├── models/        One model per file
│   ├── repositories/  Abstract interfaces only
│   └── mock/          The persona dataset and in-memory implementations
└── features/          One folder per feature: screen, provider, widgets/
```

State is `provider`; navigation is `go_router`.

### Swapping the mock layer for a real backend

Widgets only ever import the interfaces in `data/repositories/`. To move to a
live backend, add implementations under `data/` and change the eight `create:`
lines in `main.dart`. No widget changes are required.

## Brand rules encoded in the code

- The seven palette tokens live once in `core/theme/app_colors.dart`. There are no
  hex literals and no `Colors.*` constants anywhere else in `lib/`.
- Gold means Succenergy, achievement and primary action. AI Blue means the AI
  Coach and nothing else. No element carries both.
- Poppins carries the whole app, including the letterspaced caps of the
  "AI COACH" register, which is held apart by tracking and weight rather than by
  a second typeface. It is bundled in `assets/google_fonts/` and runtime
  fetching is disabled, so the app never falls back to a system face.
- Only `core/widgets/branding/succenergy_logo.dart` and
  `succenergy_wordmark.dart` touch the supplied artwork. The mark is rendered
  from vector with no tint, filter or opacity; glow is always a layer behind it.
- The wordmark PNG has a navy panel baked into it, so it is placed only on
  `navyDeep` and rendered full-bleed, which keeps that panel from reading as a
  box. A transparent-background export would remove the constraint entirely.

## Known gaps in this build

- Payment, authentication and AI responses are simulated. Coach replies come from
  a fixed set written in the coaching voice and matched to what you type.
- `design_reference/` is not bundled and is never displayed; it is the visual
  reference the Welcome screen was built against.
