# Features Documentation

> **Location**: `lib/features/` | **Total Features**: 38

---

## Table of Contents

### Core Features
1. [Workout](#1-workout) - Real-time tracking
2. [Exercise Database](#2-exercise-database) - Exercise catalog
3. [Timer](#3-timer) - Rest timer + Live Activities
4. [History](#4-history) - Workout history
5. [Analytics](#5-analytics) - Statistics & charts
6. [Workout Templates](#6-workout-templates) - Template management

### User Features
7. [Home](#7-home) - Dashboard + XP system
8. [Auth](#8-auth) - Authentication
9. [Settings](#9-settings) - Preferences
10. [Profile](#10-profile) - User profile
11. [Custom Exercises](#11-custom-exercises) - User exercises
12. [Onboarding](#12-onboarding) - First-run experience

### Advanced Features
13. [AI Coach](#13-ai-coach) - AI coaching
14. [Recovery Insight](#14-recovery-insight) - Recovery scoring
15. [Smart Training](#15-smart-training) - AI suggestions
16. [Stress Index](#16-stress-index) - Training stress
17. [Strength Standards](#17-strength-standards) - Reference weights
18. [Progression](#18-progression) - Progressive overload

### Supporting Features
19. [Notifications](#19-notifications) - Local notifications
20. [Scheduling](#20-scheduling) - Workout scheduling
21. [Streak](#21-streak) - Consistency tracking
22. [Progress](#22-progress) - Quick stats
23. [Premium](#23-premium) - IAP management
24. [Body Measurements](#24-body-measurements) - GDPR tracking
25. [Health Sync](#25-health-sync) - HealthKit/Health Connect

### Community & Admin
26. [Community](#26-community) - User contributions
27. [Admin](#27-admin) - Admin dashboard
28. [Feedback](#28-feedback) - User feedback
29. [Help Center](#29-help-center) - FAQ system

### Utility Features
30. [Debug](#30-debug) - Debug tools
31. [Import](#31-import) - Data import
32. [Migration](#32-migration) - Data migration
33. [Exercise](#33-exercise) - Exercise provider
34. [Exercise Analytics](#34-exercise-analytics) - Per-exercise stats

---

## 1. Workout

**Purpose**: Core workout management - creating, executing, tracking, and analyzing workout sessions.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `Workout` | Main workout container with exercises, timing, status |
| `Exercise` | Single exercise with sets (single/superset/drop) |
| `ExerciseSet` | Individual set (weight, reps, RPE) |
| `WorkoutDraft` | Unsaved workout in progress |
| `WorkoutSuggestion` | AI-generated suggestions |

| Service | Description |
|---------|-------------|
| `WorkoutTimeCalculator` | Duration calculations |
| `WarmupCalculatorService` | Automatic warmup suggestions |
| `RPEAutoregulationService` | RPE-based adjustments |
| `PatternDetectionService` | Movement pattern recognition |

### Data Layer

| Repository | Description |
|------------|-------------|
| `HybridWorkoutRepositoryImpl` | Main implementation (Firestore + Hive) |
| `WorkoutTemplateRepository` | Template persistence |
| `WorkoutDraftRepository` | Draft management |

| Service | Description |
|---------|-------------|
| `WorkoutSessionLAService` | Live Activity integration |
| `WorkoutSyncService` | Cloud sync |

### Presentation Layer
- **40+ providers** for state management
- Workout execution screens
- Exercise selection dialogs
- Template management UI

### Key Dependencies
- `exercise_database`, `timer`, `analytics`, `history`

### Special Patterns
- Hybrid Firestore + Hive for offline-first
- Live Activity integration (iOS)
- Advanced template system with progressive overload

---

## 2. Exercise Database

**Purpose**: Comprehensive exercise catalog with fuzzy search, usage tracking, and patch system.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `ExerciseDefinition` | Exercise catalog entry (name, muscles, equipment) |
| `ExercisePatch` | Version control for updates |
| `ExerciseCountingMode` | Weighted/reps/time modes |

| Service | Description |
|---------|-------------|
| `ExerciseSearchService` | Full-text + fuzzy search |
| `ExerciseFuzzyMatcher` | Fuzzy matching algorithm |
| `TrigramIndex` | Fast trigram-based indexing |

### Data Layer

| Repository | Description |
|------------|-------------|
| `HybridExerciseRepository` | Hive + JSON hybrid |
| `ExercisePatchRepositoryImpl` | Patch handling |
| `HiveExerciseUsageRepository` | Usage tracking |

### Special Patterns
- **Hybrid JSON + Hive**: Load from JSON, cache in Hive, sync with Cloud
- **Fuzzy Search**: Trigram indexing + fuzzy matching in isolates
- **Patch System**: Version-controlled exercise updates

---

## 3. Timer

**Purpose**: Rest timer system with RPE tracking, performance analytics, and iOS Live Activity.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `RestTimer` | Main timer with start/pause/complete |
| `SetExecutionTiming` | Set timing and performance data |
| `TimerConfig` | Timer configuration |

| Service | Description |
|---------|-------------|
| `FatigueAnalyzerService` | Detect fatigue indicators |
| `VelocityAnalyzerService` | Movement velocity analysis |
| `SetAnalyticsEngine` | Set performance analytics |

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `UnifiedTimerProvider` | Unified timer interface |
| `TimerUIStateProvider` | UI state management |

### Special Patterns
- **RPE Input**: Awaiting RPE state for post-set feedback
- **Live Activity**: iOS lock screen support
- **Velocity Tracking**: Movement speed analysis

---

## 4. History

**Purpose**: Workout history viewing, editing, and detailed analysis.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `WorkoutHistoryDetail` | Complete workout with exercises |
| `ExerciseHistoryDetail` | Exercise with sets |
| `SetHistoryDetail` | Individual set with TUT |

### Presentation Layer

| Widget | Description |
|--------|-------------|
| `WorkoutHistoryEditorEnhanced` | Edit history modal |
| `WorkoutDetailModal` | Workout detail view |

### Special Patterns
- Modal editing via bottom sheet
- TUT (Time Under Tension) millisecond precision

---

## 5. Analytics

**Purpose**: Comprehensive workout analytics, insights, achievements, and personal records.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `AnalyticsActivity` | Workout activity record |
| `UserFitnessProfile` | User fitness level |
| `ProgressiveOverloadData` | Progressive overload tracking |

| Use Case | Description |
|----------|-------------|
| `DetectPersonalRecordsUsecase` | PR detection |
| `CheckAndUnlockAchievementsUsecase` | Achievement checking |
| `CalculateWorkoutMetricsUsecase` | Metric calculation |

| Service | Description |
|---------|-------------|
| `TransparentPredictor` | Explainable ML predictions |
| `MuscleVolumeClassifier` | Volume categorization |
| `TrendAnalyzer` | Trend detection |

### Data Layer

| Repository | Description |
|------------|-------------|
| `AnalyticsRepositoryImpl` | Main implementation |
| `AchievementRepositoryImpl` | Achievement persistence |
| `PRCelebrationRepositoryImpl` | PR celebration |

### Special Patterns
- **Transparent Predictions**: Explainable ML with visible reasoning
- **Dual Repository**: Online/offline with sync
- **Achievement System**: Unlock badges/milestones

---

## 6. Workout Templates

**Purpose**: Community/public workout template sharing with import/export.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `CommunityWorkoutTemplate` | Shareable template |
| `TemplateReview` | Template reviews |
| `BatchImportError` | Import error tracking |

| Service | Description |
|---------|-------------|
| `TemplateExportService` | Export workflows |
| `BatchImportService` | Batch import processing |
| `PercentageConversionService` | 1RM % to weight |

### Presentation Layer

| Widget | Description |
|--------|-------------|
| `TemplateCard` | Template display card |
| `TemplateQuotaIndicator` | Quota display |

### Special Patterns
- **Batch Import**: Process multiple templates at once
- **Percentage Conversion**: 1RM-based load conversion
- **Template Quota**: Tier-based limits (free: 4, premium: 20)

---

## 7. Home

**Purpose**: Dashboard with personalized insights, XP/level system, daily bonuses.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `HomeWidgetConfig` | Widget configuration |
| `LevelSystem` | XP/level progression |
| `InsightFeedback` | User feedback on insights |

| Service | Description |
|---------|-------------|
| `AiCoachService` | AI coaching logic |
| `AIVolumeCalculator` | AI volume predictions |
| `ExerciseReplacementService` | Exercise substitution |

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `UserXPProvider` | XP state |
| `DailyLoginProvider` | Daily login tracking |
| `HomeCustomizationProvider` | Widget customization |

### Special Patterns
- **XP/Level System**: Gamification with progression
- **Daily Bonuses**: Retention mechanics
- **Widget Customization**: Configurable dashboard

---

## 8. Auth

**Purpose**: User authentication, profile management, account tier tracking.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `UserProfile` | User profile information |
| `UserProfileConsolidated` | Unified user view |
| `AccountTier` | Tier enum (free, premium, pro) |

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `AuthProvider` | Auth state management |
| `ConsolidatedUserProvider` | Unified user data |

### Special Patterns
- **Consolidated User View**: Firebase Auth + Firestore fusion
- **Tier-Based Features**: Premium/Pro-only functionality

---

## 9. Settings

**Purpose**: User preferences, appearance settings, cloud sync configuration.

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `CloudSyncProvider` | Cloud sync settings |

| Screen | Description |
|--------|-------------|
| `SettingsScreen` | Main settings |
| `LegalDocumentsScreen` | Legal docs |
| `TimerSoundSelector` | Audio selection |

---

## 10. Profile

**Purpose**: User profile display, goal management, streak tracking.

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `UserGoalsProvider` | Goal state management |

| Screen | Description |
|--------|-------------|
| `ProfileHubScreen` | Profile overview |
| `StreakCalendarScreen` | Streak calendar |

| Widget | Description |
|--------|-------------|
| `WeeklyStatsBottomSheet` | Weekly stats |
| `LevelInfoModal` | Level information |

---

## 11. Custom Exercises

**Purpose**: User-created exercise variants with tier-based limits.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `CustomExercise` | User-created exercise |

| Service | Description |
|---------|-------------|
| `CustomExerciseLimitService` | Tier-based limits |

### Presentation Layer

| Widget | Description |
|--------|-------------|
| `PatternSelector` | Movement pattern picker |
| `MuscleChipSelector` | Muscle group selector |
| `CustomExerciseFormSheet` | Creation form |

### Special Patterns
- **Tier-Based Limits**: Free users limited, premium unlimited
- **Base Exercise Variants**: Can extend existing exercises

---

## 12. Onboarding

**Purpose**: Multi-stage user onboarding with contextual tutorials.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `OnboardingState` | Onboarding progress |
| `UserGoal` | User goal selection |
| `OnboardingTourStep` | Tour step |

| Service | Description |
|---------|-------------|
| `OnboardingTourManager` | Tour orchestration |
| `TriggerEngine` | Context-aware activation |

### Presentation Layer

| Screen | Description |
|--------|-------------|
| `GoalSelectionScreen` | Goal picker |
| `LanguageSelectionScreen` | Language picker |
| `QuickStartScreen` | Quick start flow |

### Special Patterns
- **Trigger Engine**: Context-aware tour activation
- **Multi-Stage**: Goal → Language → Quick Start

---

## 13. AI Coach

**Purpose**: Multi-layered AI coaching with OpenAI, health sync, recovery insights.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `AiMessage` | Chat messages |
| `AiInsight` | AI-generated insights |
| `RecoveryTier` | Recovery levels |
| `StreakData` | Streak tracking |

| Service | Description |
|---------|-------------|
| `InsightRuleEngine` | Rule-based insights |
| `HrvBaselineService` | HRV baseline calculation |
| `TsbCalculationService` | Training Stress Balance |

| Search | Description |
|--------|-------------|
| `BM25Search` | Term frequency search |
| `HybridSearchEngine` | Vector + keyword combined |

### Data Layer

| Datasource | Description |
|------------|-------------|
| `ChatbotDatasource` | OpenAI API |
| `HiveChatLocalDatasource` | Local conversation cache |

### Special Patterns
- **Streaming responses**: OpenAI streaming with token-level emission
- **Hybrid search**: BM25 + vector similarity
- **Tier-based unlocking**: Basic → Intermediate → Advanced
- **Conversation tree**: Browser-like navigation through history

---

## 14. Recovery Insight

**Purpose**: Recovery readiness calculation from sleep data + workout history.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `RecoveryInsight` | Score (0-100), category, recommendation |
| `SleepRecord` | Sleep data from HealthKit |
| `SleepWorkoutCorrelation` | Sleep impact on performance |

| Service | Description |
|---------|-------------|
| `SleepWorkoutCorrelationService` | Main calculation |

### Formula
```
FinalScore = BaseScore × SleepModifier × ConsecutivePenalty

SleepModifiers:
  <6h  → ×0.70
  6-7h → ×0.85
  7-9h → ×1.00
  >9h  → ×0.95

ConsecutivePenalty:
  2 bad nights → ×0.95
  3+ bad nights → ×0.90
```

### Categories
- 85-100: Optimal
- 70-84: Good
- 55-69: Moderate
- 40-54: Low
- 0-39: Critical

---

## 15. Smart Training

**Purpose**: Real-time AI-powered training suggestions.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `SmartSuggestion` | Suggestion with priority, confidence |
| `SuggestionAction` | Possible user actions |
| `SuggestionContext` | Current workout context |

| Service | Description |
|---------|-------------|
| `SmartSuggestionsEngine` | Main suggestion generator |
| `ProgressiveOverloadEngine` | Overload calculations |
| `PlateauBreakerService` | Plateau-breaking strategies |
| `DeloadDetectionService` | Deload recommendations |

### Suggestion Types
- Weight increase
- Volume adjustment
- Rest time optimization
- Form correction
- Deload recommendation
- Plateau breaker
- Recovery advice
- Progress celebration

---

## 16. Stress Index

**Purpose**: Training stress calculation using RTS methodology.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `StressIndexResult` | Primary score, fallback score, confidence |
| `MuscleStressData` | Per-muscle stress (0-100) |
| `MuscleRecoveryStatus` | Recovery percentage (0-150%) |

| Service | Description |
|---------|-------------|
| `StressIndexCalculator` | Main calculator |

### Formula
```
SetStress = weight × reps × RPE_intensity × movementMultiplier

RPE to Intensity:
  RPE 10 → 1.0
  RPE 9  → 0.9
  RPE 8  → 0.8
  ...
  RPE 6  → 0.5

Movement Multipliers:
  Compound → 1.0-1.2
  Isolation → 0.8-1.0
  Cable → 0.9

Final Score = log(rawScore) / log(maxRaw) × 100
```

### Recovery States
- 100%+: Fully Recovered
- 75-99%: Almost Ready
- 50-74%: Recovering
- 25-49%: Fatigued
- <25%: Exhausted

---

## 17. Strength Standards

**Purpose**: Reference strength standards by bodyweight and experience level.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `StrengthStandard` | 1RM tables by bodyweight |
| `ExperienceLevel` | untrained/novice/intermediate/advanced/elite |
| `UserFitnessQuestionnaire` | User fitness profile |

| Service | Description |
|---------|-------------|
| `AdaptiveLearningService` | Learn from user feedback |
| `WeightSuggestionService` | Suggest working weights |

### Special Patterns
- **Data sources**: ExRx.net primary, estimated fallback
- **1RM Calculation**: Interpolation between bodyweights
- **Working weight**: 70% of 1RM for hypertrophy

---

## 18. Progression

**Purpose**: Deterministic progressive overload suggestions (no AI).

### Domain Layer

| Entity | Description |
|--------|-------------|
| `ProgressionSuggestion` | Suggested weight, target reps, reason |
| `ProgressionConfidence` | low/medium/high based on data quality |

### Confidence Levels
- High: 3+ weeks consistent data
- Medium: 1-2 weeks or mixed patterns
- Low: Insufficient data

---

## 19. Notifications

**Purpose**: Local notification system for user retention.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `NotificationType` | workoutForgotten, inactivity, insight* |
| `NotificationConfig` | Global cooldown, quiet hours |
| `NotificationRecord` | Delivery record |

### Anti-Spam Rules
- Max ignores per type → stop sending
- 7-day cooldown before same message
- Quiet hours: 22:00-08:00

### Inactivity Sequence
Day 3 → Day 7 → Day 14 → STOP

---

## 20. Scheduling

**Purpose**: Scheduled workouts with reminders and Live Activity.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `ScheduledWorkout` | Template + date + reminder |
| `Status` | pending/due/completed/skipped/missed |

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `schedulingProvider` | Scheduling state |
| `todaysScheduledWorkoutsProvider` | Today's workouts |

### Special Patterns
- Live Activity starts 2 hours before workout
- Missed detection on app launch

---

## 21. Streak

**Purpose**: Workout streaks and consistency scores.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `WorkoutStreak` | Current/longest streak, total days |
| `ConsistencyScore` | Score (0-100), grade (A-F) |

### Calculation
- Groups unique workout dates
- Counts consecutive days from today backwards
- Consistency = actual vs target frequency

---

## 22. Progress

**Purpose**: Aggregated workout metrics for home screen.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `ProgressData` | Volume, PRs, streaks, frequency |
| `QuickStats` | Formatted display data |

### Providers
- `completedWorkoutsCountProvider`: From LOCAL Hive
- `currentStreakProvider`: From LOCAL Hive
- `weeklyFrequencyProvider`: From LOCAL Hive

---

## 23. Premium

**Purpose**: In-app purchase management.

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `premiumUpgradeProvider` | Purchase state |
| `isPurchasingProvider` | Loading state |
| `availableProductsProvider` | Product list |

### Flow
pending → purchased/restored → verify → complete

---

## 24. Body Measurements

**Purpose**: GDPR-compliant body measurement tracking with encryption.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `Measurement` | Body measurement |
| `EncryptedMeasurement` | Encrypted storage format |
| `UserConsent` | GDPR consent tracking |

| Service | Description |
|---------|-------------|
| `AuditLoggerService` | GDPR audit trails |
| `DataExportService` | User data export |
| `DataDeletionService` | Soft/hard deletion |

### Special Patterns
- **GDPR-first**: Consent verification on every operation
- **Soft-delete**: 30 days before permanent removal
- **Encryption at rest**: All measurements encrypted
- **Audit logging**: All access logged

---

## 25. Health Sync

**Purpose**: Bidirectional sync with HealthKit/Health Connect.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `HealthDataType` | workout, bodyWeight, etc. |
| `HealthPermissionStatus` | Permission state |
| `HealthSyncStatus` | Sync state with retry info |

### Special Patterns
- **Platform abstraction**: Single interface for iOS/Android
- **Permission gating**: Runtime checks before data access
- **Exponential backoff**: Retry failures (1h, 4h, 24h)
- **Conflict resolution**: Newest timestamp wins

---

## 26. Community

**Purpose**: Community engagement for exercise contributions.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `CommunityContribution` | Corrections, tips, variants |
| `UserContributionStats` | Contributor ranking/badges |
| `ContributorBadge` | Achievement badges |

### Gamification
- Points for submissions, approvals, votes
- Tiers: Rookie → Contributor → Expert → Master → Legend → Mythic
- Trust scoring (0-100)

---

## 27. Admin

**Purpose**: Administrative dashboard for monitoring and management.

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `AdminAnalyticsSyncProvider` | Analytics sync |
| `ExerciseReviewProvider` | Exercise review workflow |
| `CommunityCorrectionsProvider` | Community moderation |

| Screen | Description |
|--------|-------------|
| `AdminDashboardScreen` | Main admin hub |
| `DatabaseManagerScreen` | Database management |
| `SyncDashboardScreen` | Sync status monitoring |

### Special Patterns
- **Dual-tier caching**: Memory + SharedPreferences
- **Memoization**: Exercise statistics cached

---

## 28. Feedback

**Purpose**: Unified user feedback collection.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `UserFeedback` | User feedback submission |
| `FeedbackStatus` | new/reviewed/resolved/dismissed |

### Presentation Layer

| Screen | Description |
|--------|-------------|
| `UserFeedbackHistoryScreen` | User's submissions |
| `UnifiedFeedbackAdminDashboardScreen` | Admin management |

---

## 29. Help Center

**Purpose**: User help and FAQ system.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `FAQCategory` | Category with icon and title |
| `FAQItem` | Question/answer pair |

### Categories
- App Usage
- Workouts
- Progress
- Settings

---

## 30. Debug

**Purpose**: Development and testing utilities.

### Presentation Layer

| Screen | Description |
|--------|-------------|
| `DebugLogsScreen` | Persistent logs viewer |
| `ModalShowcaseScreen` | Component demo |

### Features
- Auto-refresh logs (2-second intervals)
- Tag filtering ([KEEP-ALIVE], [COMPLETION])

---

## 31. Import

**Purpose**: Import workout data from third-party apps (Strong, Hevy).

### Domain Layer

| Entity | Description |
|--------|-------------|
| `ImportParseResult` | Parsed CSV with mappings |
| `ParsedWorkout` | Workout from CSV |
| `ExerciseMatch` | Fuzzy match suggestion |

### Workflow
Parse → Map → Confirm → Import

### Special Patterns
- **Fuzzy matching**: Automatic exercise name mapping
- **Manual override**: User can adjust mappings
- **Graceful degradation**: Unmapped imported as-is

---

## 32. Migration

**Purpose**: Data migration from legacy structures.

### Domain Layer

| Entity | Description |
|--------|-------------|
| `MigrationOptions` | Config (time window, batch size, dry-run) |
| `MigrationResult` | Outcome (counts, errors) |

### Special Patterns
- **Preview mode**: Dry-run without persisting
- **Grouping algorithm**: Clusters by scheda name + time window
- **Backup creation**: Automatic backup before migration

---

## 33. Exercise

**Purpose**: Exercise provider optimization.

### Presentation Layer

| Provider | Description |
|----------|-------------|
| `OptimizedExerciseProvider` | Caching layer |

### Special Patterns
- Lazy initialization
- Memoization

---

## 34. Exercise Analytics

**Purpose**: Detailed exercise-by-exercise performance analytics.

### Presentation Layer

| Screen | Description |
|--------|-------------|
| `ExerciseAnalyticsScreen` | Per-exercise stats |

### Displays
- Statistics overview (total exercises, volume, sessions)
- Exercise cards with trend indicators
- Mini-stats: max weight, total volume, avg RPE

---

## Architecture Summary

### Common Patterns Across All Features

1. **Clean Architecture**: Domain/Data/Presentation separation
2. **Riverpod**: State management with auto-dispose
3. **Freezed**: Immutable entities with JSON serialization
4. **Either Pattern**: `Either<Failure, T>` for errors
5. **Hybrid Storage**: Hive (local) + Firestore (cloud sync)

### File Statistics

| Category | Count |
|----------|-------|
| Domain entities | 286 |
| Data repositories | 56 |
| Presentation providers | 140+ |

---

## See Also

- [INDEX.md](../INDEX.md) - Codebase navigation
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Architecture patterns
- [core/README.md](../core/README.md) - Core modules
- [shared/README.md](../shared/README.md) - Shared modules
