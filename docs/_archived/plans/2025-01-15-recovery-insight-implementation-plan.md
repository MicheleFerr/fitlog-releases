# Recovery Insight Widget - Implementation Plan

**Design Doc**: [2025-01-15-recovery-insight-widget-design.md](./2025-01-15-recovery-insight-widget-design.md)
**Status**: Ready for Implementation

---

## Pre-Implementation Checklist

- [x] Design approved
- [x] Scientific basis researched
- [x] UI/UX best practices applied
- [ ] Implementation started

---

## Phase 1: Data Layer - HealthKit Sleep Integration

### Task 1.1: Verify HealthKitDatasource Updates ✅ DONE
**File**: `lib/features/ai_coach/data/datasources/healthkit_datasource.dart`

Already completed:
- Added `SLEEP_ASLEEP`, `SLEEP_IN_BED` to `supportedTypes`
- Added READ permissions for sleep types
- Added `getSleepLastNight()` method
- Added `getTimeInBedLastNight()` method
- Added `getSleepThisWeek()` method
- Added `getSleepAnalytics()` method with scientific thresholds

### Task 1.2: Add Sleep to health_remote_datasource.dart
**File**: `lib/features/health_sync/data/datasources/health_remote_datasource.dart`

Add interface and implementation:
```dart
/// Fetches sleep data from health platform.
Future<List<SleepRecord>> fetchSleep({
  required DateTime startDate,
  required DateTime endDate,
});
```

### Task 1.3: Create SleepRecord Entity
**File**: `lib/features/recovery_insight/domain/entities/sleep_record.dart`

```dart
@freezed
class SleepRecord with _$SleepRecord {
  const factory SleepRecord({
    required DateTime date,
    required Duration asleepDuration,
    required Duration inBedDuration,
    required double efficiency, // asleep / inBed * 100
    required SleepQuality quality,
    String? source,
  }) = _SleepRecord;
}

enum SleepQuality { critical, suboptimal, optimal, excessive }
```

---

## Phase 2: Domain Layer - Correlation Service

### Task 2.1: Create SleepWorkoutCorrelationService
**File**: `lib/features/recovery_insight/domain/services/sleep_workout_correlation_service.dart`

```dart
class SleepWorkoutCorrelationService {
  /// Calculate recovery score based on sleep + workout history
  ///
  /// Formula: BaseScore × SleepModifier × ConsecutivePenalty
  RecoveryInsight calculateRecovery({
    required List<SleepRecord> sleepHistory,
    required List<Workout> workoutHistory,
  });

  /// Calculate correlation between sleep and workout performance
  ///
  /// Returns: { '>7h': +8%, '<6h': -15%, ... }
  SleepWorkoutCorrelation calculateCorrelation({
    required List<SleepRecord> sleepHistory,
    required List<Workout> workoutHistory,
    int days = 30,
  });

  /// Get personalized recommendation based on current state
  String getRecommendation(RecoveryInsight insight, AppLocalizations l10n);
}
```

### Task 2.2: Create RecoveryInsight Entity
**File**: `lib/features/recovery_insight/domain/entities/recovery_insight.dart`

```dart
@freezed
class RecoveryInsight with _$RecoveryInsight {
  const factory RecoveryInsight({
    required int score, // 0-100
    required RecoveryCategory category,
    required String recommendation,
    required Duration lastNightSleep,
    required double weeklyAverage, // hours
    required int consecutiveBadNights,
    required int streakDays,
    SleepWorkoutCorrelation? correlation, // Pro only
  }) = _RecoveryInsight;
}

enum RecoveryCategory {
  optimal,   // 85-100
  good,      // 70-84
  moderate,  // 55-69
  low,       // 40-54
  critical,  // 0-39
}
```

### Task 2.3: Create SleepWorkoutCorrelation Entity
**File**: `lib/features/recovery_insight/domain/entities/sleep_workout_correlation.dart`

```dart
@freezed
class SleepWorkoutCorrelation with _$SleepWorkoutCorrelation {
  const factory SleepWorkoutCorrelation({
    required double volumeChangeAbove7h, // e.g., +8%
    required double volumeChangeBelow6h, // e.g., -15%
    required int sampleSize,
    required bool isSignificant, // >10 data points
  }) = _SleepWorkoutCorrelation;
}
```

---

## Phase 3: Presentation Layer - Provider

### Task 3.1: Create RecoveryInsightProvider
**File**: `lib/features/recovery_insight/presentation/providers/recovery_insight_provider.dart`

```dart
/// Provider for recovery insight data
final recoveryInsightProvider = FutureProvider.autoDispose<RecoveryInsight>((ref) async {
  final healthKitDatasource = ref.watch(healthKitDatasourceProvider);
  final workoutHistory = await ref.watch(workoutHistoryProvider.future);
  final correlationService = ref.watch(sleepWorkoutCorrelationServiceProvider);

  // Get sleep data
  final sleepAnalytics = await healthKitDatasource.getSleepAnalytics(days: 7);

  // Calculate recovery
  return correlationService.calculateRecovery(
    sleepHistory: sleepAnalytics,
    workoutHistory: workoutHistory,
  );
});

/// Provider for sleep-workout correlation (Pro only)
final sleepCorrelationProvider = FutureProvider.autoDispose<SleepWorkoutCorrelation?>((ref) async {
  final isPro = ref.watch(isPremiumProvider);
  if (!isPro) return null;

  // ... fetch and calculate
});
```

---

## Phase 4: Presentation Layer - Widgets

### Task 4.1: Create RecoveryInsightCard
**File**: `lib/features/recovery_insight/presentation/widgets/recovery_insight_card.dart`

Compact card for home screen:
- Score number (large)
- Progress dots (5)
- One-line recommendation
- Sleep hours + streak

### Task 4.2: Create RecoveryInsightSheet
**File**: `lib/features/recovery_insight/presentation/widgets/recovery_insight_sheet.dart`

Bottom sheet with:
- Circular progress with score
- Weekly sleep chart
- Correlation analysis (Pro)
- Scientific basis footer

### Task 4.3: Create WeeklySleepChart
**File**: `lib/features/recovery_insight/presentation/widgets/weekly_sleep_chart.dart`

Bar chart showing:
- 7 days of sleep
- Color coded by quality
- Average line
- Optimal range indicator

---

## Phase 5: Integration

### Task 5.1: Add to Home Customization
**File**: `lib/features/home/domain/models/home_widget_config.dart`

Add new widget type:
```dart
enum HomeWidgetType {
  // ... existing
  recoveryInsight,
}
```

### Task 5.2: Register in Widget Factory
**File**: `lib/features/home/presentation/widgets/home_widget_factory.dart`

```dart
case HomeWidgetType.recoveryInsight:
  return const RecoveryInsightCard();
```

### Task 5.3: Add Localizations
**Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`

```json
{
  "recoveryInsight": "Recovery Insight",
  "recoveryOptimal": "Excellent recovery! Ready for intense workout",
  "recoveryGood": "Good recovery. Ready for normal workout",
  "recoveryModerate": "Moderate recovery. Consider lighter workout",
  "recoveryLow": "Recovery in progress. Prioritize rest today",
  "recoveryCritical": "Body recovering. Rest day recommended",
  "sleepCorrelationTitle": "Sleep-Workout Correlation",
  "sleepAbove7h": "Nights >7h",
  "sleepBelow6h": "Nights <6h",
  "basedOnScience": "Based on scientific research"
}
```

---

## Phase 6: Testing

### Task 6.1: Unit Tests
**File**: `test/features/recovery_insight/domain/services/sleep_workout_correlation_service_test.dart`

Test cases:
- Score calculation with various sleep patterns
- Consecutive bad nights penalty
- Correlation calculation accuracy
- Edge cases (no data, single day)

### Task 6.2: Widget Tests
**File**: `test/features/recovery_insight/presentation/widgets/recovery_insight_card_test.dart`

Test cases:
- Renders all score categories correctly
- Handles loading state
- Handles error state
- Pro/Free tier visibility

---

## Execution Order

```
1. Task 1.3: Create SleepRecord entity
2. Task 1.2: Add fetchSleep to health_remote_datasource
3. Task 2.2: Create RecoveryInsight entity
4. Task 2.3: Create SleepWorkoutCorrelation entity
5. Task 2.1: Create SleepWorkoutCorrelationService
6. Task 3.1: Create RecoveryInsightProvider
7. Task 4.3: Create WeeklySleepChart
8. Task 4.1: Create RecoveryInsightCard
9. Task 4.2: Create RecoveryInsightSheet
10. Task 5.3: Add localizations
11. Task 5.1: Add to home widget config
12. Task 5.2: Register in widget factory
13. Task 6.1: Unit tests
14. Task 6.2: Widget tests
```

---

## Estimated Time

| Phase | Tasks | Time |
|-------|-------|------|
| Phase 1 | Data Layer | ~1h (mostly done) |
| Phase 2 | Domain Layer | ~2h |
| Phase 3 | Provider | ~1h |
| Phase 4 | Widgets | ~3h |
| Phase 5 | Integration | ~1h |
| Phase 6 | Testing | ~2h |
| **Total** | | **~10h** |

---

## Notes

- HealthKit sleep methods already added to `healthkit_datasource.dart`
- Use existing `home_widget_factory.dart` pattern for consistency
- Follow existing `freezed` entity pattern
- Dark mode colors essential (sleep = night usage)
