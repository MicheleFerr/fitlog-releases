# FitLog Pro - Architecture Overview

> **Last Updated**: 2024-12-16

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x |
| **State Management** | Riverpod |
| **Backend** | Firebase (Firestore, Auth, Functions) |
| **Local Storage** | Hive |
| **Code Generation** | Freezed, JSON Serializable |
| **Architecture** | Clean Architecture |

---

## Project Structure

```
lib/
├── core/                 # App-wide infrastructure
│   ├── providers/        # Global providers
│   ├── services/         # Core services
│   └── config/           # Configuration
│
├── features/             # Feature modules (Clean Architecture)
│   ├── workout/          # ⭐ Core: Workout tracking
│   ├── exercise_database/# ⭐ Exercise catalog
│   ├── timer/            # ⭐ Timer + Live Activities
│   ├── history/          # Workout history
│   ├── analytics/        # Statistics & charts
│   ├── workout_templates/# Workout templates
│   ├── custom_exercises/ # User custom exercises
│   ├── home/             # Home screen
│   ├── auth/             # Authentication
│   ├── settings/         # App settings
│   └── ... (26 more)
│
└── shared/               # Shared across features
    ├── domain/           # Shared entities, repositories
    ├── data/             # Shared data sources
    └── presentation/     # Shared widgets
```

---

## Clean Architecture per Feature

Ogni feature segue questa struttura:

```
lib/features/{feature_name}/
├── domain/           # Business Logic Layer
│   ├── entities/     # Business objects (Freezed)
│   ├── repositories/ # Repository interfaces
│   └── services/     # Domain services
│
├── data/             # Data Layer
│   ├── models/       # Data transfer objects
│   ├── repositories/ # Repository implementations
│   ├── datasources/  # Remote/Local data sources
│   └── services/     # Data services
│
└── presentation/     # UI Layer
    ├── providers/    # Riverpod providers
    ├── screens/      # Full screens
    └── widgets/      # Reusable widgets
```

---

## Key Features (36 totali)

### Core Features (usate quotidianamente)

| Feature | Descrizione | Complessità |
|---------|-------------|-------------|
| `workout/` | Tracking workout in tempo reale | Alta |
| `exercise_database/` | Catalogo esercizi + search | Alta |
| `timer/` | Timer + iOS Live Activities | Alta |
| `history/` | Storico workout | Media |
| `analytics/` | Statistiche e grafici | Media |
| `workout_templates/` | Template personalizzabili | Media |

### Supporting Features

| Feature | Descrizione |
|---------|-------------|
| `home/` | Home screen e dashboard |
| `auth/` | Firebase Authentication |
| `settings/` | Impostazioni app |
| `profile/` | Profilo utente |
| `custom_exercises/` | Esercizi creati dall'utente |
| `onboarding/` | Flusso primo avvio |

### Advanced Features (in sviluppo/beta)

| Feature | Descrizione |
|---------|-------------|
| `ai_coach/` | AI coaching suggestions |
| `health_sync/` | Apple Health integration |
| `premium/` | Feature premium |
| `community/` | Social features |

---

## Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Screen    │────▶│  Provider   │────▶│ Repository  │
│   (Widget)  │◀────│  (Riverpod) │◀────│ (Interface) │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │ DataSource  │
                                        │ (Firestore/ │
                                        │   Hive)     │
                                        └─────────────┘
```

---

## State Management (Riverpod)

### Pattern Standard

```dart
// 1. Repository Provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return HybridExerciseRepository(ref);
});

// 2. State Provider (per UI state)
final selectedExerciseProvider = StateProvider<Exercise?>((ref) => null);

// 3. Async Provider (per data fetching)
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getAll();
});

// 4. Notifier (per logica complessa)
final workoutNotifierProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>(...);
```

---

## iOS Integration

### Live Activities (Timer)

```
ios/Runner/
├── LiveActivityTimer/       # Live Activity Widget
│   └── LiveActivityTimerLiveActivity.swift
├── BackgroundTaskManager/   # Background task handling
└── AudioSessionManager/     # Audio session for background
```

### Platform Channels

```dart
// Flutter → iOS
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
│   ├── workouts/           # Workout history
│   ├── templates/          # User templates
│   └── customExercises/    # Custom exercises
│
└── exercises/              # Global exercise catalog
```

---

## Key Decisions (ADR)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | Riverpod | Type-safe, testable, flexible |
| Local Storage | Hive | Fast, no SQL overhead |
| Entities | Freezed | Immutable, copyWith, JSON |
| Architecture | Clean | Testable, maintainable |
| Backend | Firebase | Quick to deploy, real-time |

Dettagli: [ADR/](../ADR/)

---

## Development Rules

Vedi [DEVELOPMENT_RULES.md](../DEVELOPMENT_RULES.md) per:
- Convenzioni naming
- Pattern obbligatori
- Pre-commit checks
- iOS build compliance
