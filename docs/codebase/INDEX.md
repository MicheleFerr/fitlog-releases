# FitLog Pro - Codebase Complete Map

> **Generated**: 2024-12-16 | **Files**: 1390 Dart files | **Features**: 38

---

## Quick Navigation

| Section | Description |
|---------|-------------|
| [Architecture](#architecture-overview) | Data flow, patterns, dependencies |
| [Core](#core-modules) | Infrastructure (15 modules) |
| [Shared](#shared-modules) | Cross-cutting concerns (125+ components) |
| [Features](#features) | Feature modules (38 features) |
| [iOS Native](ios/README.md) | Swift layer (30+ files) - Live Activities, Watch, Audio |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         APP LAYER                           │
│  main.dart → app.dart → MaterialApp.router                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      NAVIGATION LAYER                        │
│  GoRouter + StatefulShellRoute (3 branches)                 │
│  Home | Workout | Profile                                   │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   PRESENTATION  │ │     DOMAIN      │ │      DATA       │
│   (Riverpod)    │ │   (Entities)    │ │  (Repositories) │
│   Providers     │ │   Interfaces    │ │  DataSources    │
│   Screens       │ │   Services      │ │  Models         │
│   Widgets       │ │   Use Cases     │ │  Hive/Firestore │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Key Patterns

| Pattern | Description | Usage |
|---------|-------------|-------|
| **Clean Architecture** | Domain/Data/Presentation separation | Every feature |
| **Hybrid Repository** | Hive (local) + Firestore (cloud) | BaseHybridRepository |
| **Either Pattern** | `Either<Failure, T>` for errors | All repositories |
| **Freezed Entities** | Immutable with JSON serialization | All domain entities |
| **Riverpod** | State management + DI | All providers |
| **Cache-First** | Local cache → server fallback | FirestoreCacheFirstMixin |

### Storage Architecture

```
FREE Users:
  App → Hive (Local Only)

PREMIUM Users:
  App → Hive (Local) ←→ Firestore (Cloud Sync)
         └──── SyncQueue ────┘
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Backend | Firebase (Firestore, Auth, Functions, Analytics) |
| Local Storage | Hive (encrypted) |
| Code Generation | Freezed, JSON Serializable |
| Navigation | GoRouter |

---

## Core Modules

**Location**: `lib/core/`

| Module | Purpose | Key Classes |
|--------|---------|-------------|
| [analytics](core/README.md#analytics) | Event tracking | `AnalyticsEvents`, `WorkoutEventTracker` |
| [auth](core/README.md#auth) | Admin roles, RBAC | `AdminRoleHelper`, `adminStatusProvider` |
| [cache](core/README.md#cache) | User-scoped cache keys | `UserCacheKeyManager` |
| [config](core/README.md#config) | Environment, Firebase | `EnvironmentConfig`, `FirebaseConfig` |
| [data](core/README.md#data) | Hive, repositories | `BaseHybridRepository`, `HiveBoxManagerEnhanced` |
| [domain](core/README.md#domain) | Core entities | `UserTier` (XP system) |
| [errors](core/README.md#errors) | Error handling | `ErrorHandler`, `ErrorScreen` |
| [extensions](core/README.md#extensions) | Dart extensions | Context, String, List extensions |
| [navigation](core/README.md#navigation) | GoRouter config | `appRouterProvider`, routes |
| [performance](core/README.md#performance) | Optimization | `PerformanceOptimizer` |
| [providers](core/README.md#providers) | Global providers | Analytics, Firebase, Tier |
| [security](core/README.md#security) | Encryption, App Check | `HiveEncryptionManager` |
| [services](core/README.md#services) | Core services | `IAnalyticsService`, `RateLimitHandler` |
| [ui](core/README.md#ui) | Animations | Animation definitions |
| [utils](core/README.md#utils) | Utilities | `AppLogger`, memory detection |

---

## Shared Modules

**Location**: `lib/shared/`

| Module | Purpose | Key Components |
|--------|---------|----------------|
| [config](shared/README.md#config) | Feature flags | `FeatureFlags` |
| [constants](shared/README.md#constants) | Firestore schema | `FirestoreCollections`, `FirestoreFields` |
| [data](shared/README.md#data) | Datasources, mixins | `FirestoreCacheFirstMixin`, services |
| [domain](shared/README.md#domain) | Failures, security | `Failure`, `Either`, `RateLimiter` |
| [presentation](shared/README.md#presentation) | Theme, widgets | `AppIcons`, `AppTheme`, components |
| [providers](shared/README.md#providers) | SharedPreferences | Provider setup |
| [services](shared/README.md#services) | Privacy analytics | GDPR-safe analytics |
| [utils](shared/README.md#utils) | Safe parsing | Type-safe converters |

### Critical Imports

```dart
// Theme & Colors
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
// → context.colors.primary, context.l10n.title, context.textTheme

// Icons
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
// → AppIcons.workout, AppIcons.timer, etc.

// Loading
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
// → LoadingIndicator() (NOT CircularProgressIndicator)

// Snackbar
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
// → SnackBarService.showSuccess(context, message)
```

---

## Features

**Location**: `lib/features/`

### Core Features (Daily Use)

| Feature | Description | Complexity | Docs |
|---------|-------------|------------|------|
| **workout** | Real-time workout tracking | High | [→](features/workout.md) |
| **exercise_database** | Exercise catalog + search | High | [→](features/exercise_database.md) |
| **timer** | Rest timer + Live Activities | High | [→](features/timer.md) |
| **history** | Workout history | Medium | [→](features/history.md) |
| **analytics** | Statistics & charts | Medium | [→](features/analytics.md) |
| **workout_templates** | Template management | Medium | [→](features/workout_templates.md) |

### User Features

| Feature | Description | Docs |
|---------|-------------|------|
| **home** | Dashboard + XP system | [→](features/home.md) |
| **auth** | Firebase authentication | [→](features/auth.md) |
| **settings** | App preferences | [→](features/settings.md) |
| **profile** | User profile + streaks | [→](features/profile.md) |
| **custom_exercises** | User-created exercises | [→](features/custom_exercises.md) |
| **onboarding** | First-run experience | [→](features/onboarding.md) |

### Advanced Features

| Feature | Description | Docs |
|---------|-------------|------|
| **ai_coach** | AI coaching + health sync | [→](features/ai_coach.md) |
| **recovery_insight** | Recovery scoring | [→](features/recovery_insight.md) |
| **smart_training** | AI suggestions | [→](features/smart_training.md) |
| **stress_index** | Training stress (RTS) | [→](features/stress_index.md) |
| **strength_standards** | Reference weights | [→](features/strength_standards.md) |
| **progression** | Progressive overload | [→](features/progression.md) |

### Supporting Features

| Feature | Description | Docs |
|---------|-------------|------|
| **notifications** | Local notifications | [→](features/notifications.md) |
| **scheduling** | Workout scheduling | [→](features/scheduling.md) |
| **streak** | Consistency tracking | [→](features/streak.md) |
| **progress** | Quick stats | [→](features/progress.md) |
| **premium** | IAP management | [→](features/premium.md) |
| **body_measurements** | GDPR-compliant tracking | [→](features/body_measurements.md) |
| **health_sync** | HealthKit/Health Connect | [→](features/health_sync.md) |

### Community & Admin

| Feature | Description | Docs |
|---------|-------------|------|
| **community** | User contributions | [→](features/community.md) |
| **admin** | Admin dashboard | [→](features/admin.md) |
| **feedback** | User feedback | [→](features/feedback.md) |
| **help_center** | FAQ system | [→](features/help_center.md) |

### Utility Features

| Feature | Description | Docs |
|---------|-------------|------|
| **debug** | Debug tools | [→](features/debug.md) |
| **import** | CSV/JSON import | [→](features/import.md) |
| **migration** | Data migration | [→](features/migration.md) |
| **exercise** | Exercise provider | [→](features/exercise.md) |
| **exercise_analytics** | Per-exercise stats | [→](features/exercise_analytics.md) |

---

## Feature Dependencies

```
                    ┌─────────────┐
                    │   workout   │ ◄── Core feature
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  timer   │    │ history  │    │analytics │
    └──────────┘    └──────────┘    └──────────┘
           │               │               │
           └───────────────┼───────────────┘
                           ▼
                    ┌─────────────┐
                    │    home     │ ◄── Dashboard
                    └─────────────┘

exercise_database ──► workout ──► workout_templates
        │                              │
        └──────► custom_exercises ◄────┘

auth ──► all features (user context)
         │
         └──► premium (IAP verification)
              │
              └──► tier-gated features
```

---

## XP & Tier System

| Tier | XP Required | Templates | Cloud Sync | Pro Analytics |
|------|-------------|-----------|------------|---------------|
| Starter | 0 | 4 | No | No |
| Bronze | 500 | 5 | No | No |
| Silver | 2000 | 5 | No | No |
| Gold | 5000 | 6 | No | No |
| Platinum | 15000 | 7 | Yes | Yes |

**XP Sources**: Workouts, streaks, achievements, daily login

---

## iOS Integration

### Live Activities (Timer)

```
ios/Runner/
├── LiveActivityTimer/           # Live Activity Widget
│   └── LiveActivityTimerLiveActivity.swift
├── BackgroundTaskManager/       # Background tasks
└── AudioSessionManager/         # Audio session
```

### Platform Channels

```dart
const channel = MethodChannel('com.gymbro/live_activity');
await channel.invokeMethod('startActivity', {...});
```

---

## Firebase Structure

```
Firestore:
├── users/{userId}/
│   ├── profile
│   ├── settings
│   ├── workouts/
│   ├── templates/
│   └── customExercises/
│
├── exercises/              # Global catalog
├── community/              # Contributions
└── feedback/               # User feedback
```

---

## Development Quick Reference

### Commands

```bash
flutter gen-l10n           # Regenerate translations
flutter analyze            # Check errors
flutter test               # Run tests
./scripts/checkpoint.sh    # Auto-commit checkpoint
```

### Critical Rules

```dart
// CORRECT
AppIcons.add               // Icons
context.l10n.title         // Text
context.colors.primary     // Colors
LoadingIndicator()         // Loading
SnackBarService.showSuccess() // Snackbar

// WRONG
Icons.add                  // ❌
'Hardcoded text'           // ❌
Colors.blue                // ❌
CircularProgressIndicator()// ❌
ScaffoldMessenger          // ❌
```

### iOS Build Compliance

```dart
Text(context.l10n.title)        // ✅
const Text(context.l10n.title)  // ❌ iOS build error!
```

---

## File Statistics

| Category | Count |
|----------|-------|
| Total Dart files | 1390 |
| Features | 38 |
| Domain entities | 286 |
| Data repositories | 56 |
| Presentation providers | 140+ |
| Core modules | 15 |
| Shared components | 125+ |

---

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed patterns and data flow
- [core/README.md](core/README.md) - Core modules documentation
- [shared/README.md](shared/README.md) - Shared modules documentation
- [features/](features/) - Individual feature documentation
