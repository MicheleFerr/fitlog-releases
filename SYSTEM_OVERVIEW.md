# FitLog Pro - System Overview

> **Helicopter View** - Everything you need to know in 5 minutes
> Last updated: 2025-12-13

---

## What is FitLog Pro?

A **fitness tracking app** built with Flutter that helps users:
- Log workouts with exercises, sets, reps, and weights
- Track progress with analytics and charts
- Follow workout routines and templates
- Get AI-powered training insights

---

## Quick Stats

| Metric | Value |
|--------|-------|
| **Features** | 25+ modules |
| **Lines of Dart** | ~150,000 |
| **Platforms** | iOS, Android |
| **Architecture** | Clean Architecture + Riverpod |
| **Storage** | Hive (local) + Firebase (cloud) |
| **Status** | Testing phase (1 user) |

---

## Core User Flows

### 1. Workout Session (Primary Flow)
```
[Home] → [Start Workout] → [Add Exercise] → [Log Sets] → [Complete]
              ↓                   ↓              ↓
         Timer starts      Search 800+      Track weight,
         Live Activity     exercises        reps, RPE
```

### 2. Progress Tracking
```
[Analytics Tab] → [View Progress] → [Exercise Detail]
       ↓                ↓                  ↓
   Overview        Charts/PRs         History
   Insights        Trends             Records
```

### 3. Template/Routine
```
[Templates] → [Select/Create] → [Start from Template]
                  ↓
            Pre-filled exercises
            with suggested weights
```

---

## Feature Modules

| Category | Features | Status |
|----------|----------|--------|
| **Core** | Workout, Timer, Exercise DB, Templates | Production |
| **Analytics** | Progress, PRs, Charts, Insights | Production |
| **User** | Auth, Profile, Settings, Premium | Production |
| **AI** | AI Coach, Recommendations | Beta |
| **Social** | Community, Contributions | Beta |
| **Health** | HealthKit, Health Connect | Production |
| **Admin** | Database Manager, Feedback Review | Internal |

---

## Technology Stack

```
┌─────────────────────────────────────────┐
│              Flutter 3.x                 │
│         (Cross-platform UI)             │
├─────────────────────────────────────────┤
│ State: Riverpod 2.6 │ Nav: GoRouter 17  │
├─────────────────────────────────────────┤
│ Local: Hive CE     │ Cloud: Firebase    │
│ (Always active)    │ (Premium only)     │
├─────────────────────────────────────────┤
│ iOS: Swift (Live Activities, Audio)     │
│ Android: Kotlin (Background service)    │
└─────────────────────────────────────────┘
```

### Key Dependencies

| Purpose | Package | Version |
|---------|---------|---------|
| State Management | `flutter_riverpod` | 2.6.1 |
| Local Storage | `hive_ce_flutter` | 2.1.0 |
| Cloud | `firebase_*` | Latest |
| Navigation | `go_router` | 17.0.0 |
| Entities | `freezed` | Latest |
| Health | `health` | 13.2.1 |

---

## Data Architecture

### Storage Strategy
```
Free Users:  [App] → [Hive Local] → Done (offline-first)
Premium:     [App] → [Hive Local] → [Sync Queue] → [Firebase]
```

### Key Data Entities

| Entity | Storage | Sync | Description |
|--------|---------|------|-------------|
| `Workout` | Hive | Premium | Workout sessions with exercises |
| `Exercise` | JSON + Hive | Premium | Exercise database (800+) |
| `Template` | Hive | Premium | Saved workout templates |
| `UserProfile` | Hive | Premium | User preferences, goals |
| `Achievement` | Hive | Premium | Unlocked achievements |
| `AnalyticsSet` | Hive | Premium | Set-level analytics data |

---

## Critical Paths to Understand

### 1. Workout Persistence
```dart
User completes workout
    → WorkoutProvider.save()
    → HybridWorkoutRepository.save()
    → Hive.put() (immediate)
    → SyncQueue.add() (if premium)
    → Firebase.set() (async)
```

### 2. Exercise Search
```dart
User types in search
    → ExerciseSearchProvider.search()
    → TrigramIndex.search() (fuzzy match)
    → Filter by muscle/equipment
    → Return sorted results
```

### 3. Timer + Live Activity (iOS)
```dart
User starts timer
    → TimerProvider.start()
    → AudioSession.configure() (background audio)
    → LiveActivityBridge.start() (Swift)
    → Update every second (Flutter → Swift)
```

---

## Where to Find Things

| Looking for... | Location |
|----------------|----------|
| Entry point | `lib/main.dart` |
| App shell | `lib/core/navigation/main_shell.dart` |
| Routes | `lib/core/navigation/app_routes.dart` |
| A feature | `lib/features/{feature_name}/` |
| Shared widgets | `lib/shared/presentation/widgets/` |
| Theme/colors | `lib/shared/presentation/theme/` |
| Translations | `assets/i18n/app_{lang}.arb` |
| iOS native | `ios/Runner/` |
| Tests | `test/`, `integration_test/` |

---

## Communication Patterns

### Providers (State Management)
```dart
// Read data
ref.watch(workoutsProvider);

// Trigger action
ref.read(workoutProvider.notifier).save(workout);

// One-time read
ref.read(settingsProvider);
```

### Cross-Feature Communication
```
Feature A  →  Shared Provider  ←  Feature B
              (or Event Bus)
```

### Native Communication (iOS)
```
Flutter ←→ MethodChannel ←→ Swift
```

---

## Testing Strategy

| Type | Location | Coverage |
|------|----------|----------|
| Unit | `test/` | Domain logic |
| Widget | `test/` | UI components |
| Integration | `integration_test/` | Full flows |
| E2E | Patrol | Critical paths |

---

## Development Rules (Quick Reference)

| Rule | Do | Don't |
|------|-----|-------|
| Icons | `AppIcons.*` | `Icons.*` |
| Text | `context.l10n.*` | `'Hardcoded'` |
| Colors | `context.colors.*` | `Colors.blue` |
| Loading | `LoadingIndicator()` | `CircularProgressIndicator()` |

See [CLAUDE.md](CLAUDE.md) for complete rules.

---

## Risk Areas

| Area | Risk | Mitigation |
|------|------|------------|
| Timer + iOS | Complex native bridge | Extensive KB docs |
| Sync conflicts | Data loss | Cloud-wins strategy |
| Exercise patches | Version conflicts | Conflict detector |
| Large workouts | Performance | Lazy loading |

---

## Quick Links

| Document | Purpose |
|----------|---------|
| [CLAUDE.md](CLAUDE.md) | Development rules |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System diagrams |
| [docs/ADR/](docs/ADR/) | Architectural decisions |
| [docs/NAVIGATION/INDEX.md](docs/NAVIGATION/INDEX.md) | Full documentation |

---

## Getting Started

1. **Read this file** (5 min)
2. **Read [CLAUDE.md](CLAUDE.md)** (15 min) - Development rules
3. **Explore [ARCHITECTURE.md](ARCHITECTURE.md)** (10 min) - Diagrams
4. **Find your feature** in `lib/features/`
5. **Check feature docs** in `docs/`

---

*This document gives you the helicopter view. Dive into specific docs when you need details.*
