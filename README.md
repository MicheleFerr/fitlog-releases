# FitLog Pro - Fitness Tracking App

Flutter fitness app with workout tracking, exercise database, Live Activities, and analytics.

**Status**: Beta Testing (1 user) | **Platform**: iOS + Android

---

## Quick Start

```bash
flutter pub get
flutter gen-l10n
flutter run
```

**Project rules**: [`CLAUDE.md`](./CLAUDE.md) (required reading before any change)
**Documentation**: [`docs/INDEX.md`](./docs/INDEX.md)

---

## Architecture

**Stack**: Flutter 3.38 | Riverpod 3.x | Hive (local) + Firestore (cloud) | Firebase Auth

**Pattern**: Clean Architecture per feature

```
lib/features/{name}/
├── domain/        # Entities, repository interfaces, services
├── data/          # Repository impl, datasources, models
└── presentation/  # Screens, widgets, providers
```

**38 features**: workout, analytics, ai_coach, exercise_database, onboarding, settings, health_sync, templates, timer, and more.

---

## iOS Native

```
ios/
├── Runner/
│   ├── Managers/              # 25 Swift files (audio, timer, notifications)
│   ├── LiveActivityHandler.swift  # Platform channel entry point
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── FitLogWatch Watch App/     # watchOS companion
├── GymBroTimerWidget/         # Live Activities widget extension (10 Swift files)
└── Runner.xcodeproj/
```

---

## Key Features

- Workout tracking with real-time timer
- 1,567 curated exercises (EN/IT)
- iOS Live Activities (lock screen timer)
- Background timer with audio completion
- Workout analytics and insights
- AI Coach with smart suggestions
- Hybrid storage (Hive local-first + Firestore cloud sync)
- Dark/Light theme, English/Italian

---

## Development

```bash
flutter analyze                 # Check errors
flutter test                    # Run tests
flutter gen-l10n                # Regenerate translations
.claude/scripts/performance-check.sh lib/features/<feature>/  # Performance anti-patterns
```

**Code quality** enforced by pre-commit hooks. See [`CLAUDE.md`](./CLAUDE.md) for all rules.

---

## Security & Privacy

- Firestore security rules for data isolation
- Firebase Auth with Sign in with Apple
- [`legal/PRIVACY_POLICY.md`](./legal/PRIVACY_POLICY.md) | [`legal/TERMS_OF_SERVICE.md`](./legal/TERMS_OF_SERVICE.md)
