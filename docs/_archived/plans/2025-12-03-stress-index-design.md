# Stress Index Algorithm - Design Document

**Date**: 2025-12-03
**Status**: Ready for Implementation
**Based on**: RTS/Mike Tuchscherer methodology + WHOOP patterns

---

## Executive Summary

Implement a **Full System Stress Index** that provides:
1. **Post-Workout Insights** (retrospective) - Stress breakdown after completing workout
2. **Recovery Guidance** (proactive) - Muscle-level recovery status for next workout

---

## Design Decisions (from Brainstorming)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | Full System | Both retrospective + proactive |
| Missing RPE | Dual Calculation | Primary (RPE) + Fallback (weight-only) with confidence |
| Scale | Logarithmic 0-100 | Like WHOOP, higher scores harder to achieve |
| UI Pattern | Progressive Disclosure | Compact card + tap for muscle details |
| Muscle Mapping | Use `focus` field | Existing data with static abbreviation lookup |

---

## 1. Constants & Configuration

```dart
/// Stress Index Constants (RTS-based)
class StressIndexConstants {
  StressIndexConstants._();

  // === RPE TO INTENSITY CONVERSION ===
  // Based on Helms et al. (2018) and Zourdos et al. (2016)
  static const Map<int, double> rpeToIntensity = {
    5: 0.50,   // Very Easy
    6: 0.60,   // Easy
    7: 0.70,   // Moderate
    8: 0.80,   // Hard
    9: 0.90,   // Very Hard
    10: 1.00,  // Maximum
  };

  // === MOVEMENT TYPE STRESS MULTIPLIERS ===
  // From existing MovementType enum
  static const Map<String, double> movementTypeMultipliers = {
    'compoundHeavy': 1.5,    // Deadlifts, Squats
    'compoundMedium': 1.2,   // Bench, Rows
    'isolationHeavy': 1.0,   // Curls with heavy weight
    'isolationLight': 0.8,   // Cable work, machines
    'bodyweight': 0.9,       // Pull-ups, dips
    'cardio': 0.5,           // Conditioning work
  };

  // === LOGARITHMIC SCALE PARAMETERS ===
  // For converting raw score to 0-100 logarithmic scale
  static const double logScaleBase = 10.0;
  static const double logScaleMax = 100.0;
  static const double rawScoreForMax100 = 500.0; // Raw score that maps to 100

  // === RECOVERY TIME (hours) BY MUSCLE GROUP ===
  static const Map<String, int> muscleRecoveryHours = {
    'QUAD': 72,    // Large muscle, compound movements
    'GLUT': 72,    // Large muscle, compound movements
    'FEMOR': 72,   // Hamstrings
    'LAT': 72,     // Large back muscles
    'PETT': 72,    // Chest
    'DELT': 48,    // Shoulders
    'TRAP': 48,    // Trapezius
    'BICI': 48,    // Biceps
    'TRIC': 48,    // Triceps
    'CORE': 48,    // Core/Abs
    'AVA': 48,     // Forearms
    'POLP': 48,    // Calves
    'ADD': 48,     // Adductors
    'ADDO': 48,    // Adductors (alternative)
    'LOMBAR': 72,  // Lower back
  };

  // === CONFIDENCE THRESHOLDS ===
  static const double highConfidenceThreshold = 0.80;  // 80%+ sets have RPE
  static const double mediumConfidenceThreshold = 0.50; // 50-80% sets have RPE
  // Below 50% = low confidence, show fallback
}
```

---

## 2. Muscle Abbreviation Mapping

```dart
/// Maps focus field abbreviations to standardized muscle names
class MuscleAbbreviationMapper {
  MuscleAbbreviationMapper._();

  static const Map<String, MuscleInfo> abbreviationMap = {
    'TRIC': MuscleInfo('Triceps', 'triceps', MuscleGroup.arms),
    'BICI': MuscleInfo('Biceps', 'biceps', MuscleGroup.arms),
    'BIC': MuscleInfo('Biceps', 'biceps', MuscleGroup.arms), // Typo variant
    'TRAP': MuscleInfo('Trapezius', 'trapezius', MuscleGroup.back),
    'LAT': MuscleInfo('Latissimus', 'lats', MuscleGroup.back),
    'CORE': MuscleInfo('Core', 'core', MuscleGroup.core),
    'PETT': MuscleInfo('Pectorals', 'chest', MuscleGroup.chest),
    'DELT': MuscleInfo('Deltoids', 'shoulders', MuscleGroup.shoulders),
    'GLUT': MuscleInfo('Glutes', 'glutes', MuscleGroup.legs),
    'POLP': MuscleInfo('Calves', 'calves', MuscleGroup.legs),
    'AVA': MuscleInfo('Forearms', 'forearms', MuscleGroup.arms),
    'FEMOR': MuscleInfo('Hamstrings', 'hamstrings', MuscleGroup.legs),
    'QUAD': MuscleInfo('Quadriceps', 'quads', MuscleGroup.legs),
    'ADDO': MuscleInfo('Adductors', 'adductors', MuscleGroup.legs),
    'ADD': MuscleInfo('Adductors', 'adductors', MuscleGroup.legs),
    'LOMBAR': MuscleInfo('Lower Back', 'lower_back', MuscleGroup.back),
  };

  /// Parse focus field (e.g., "BICI, TRIC") into list of muscles
  static List<MuscleInfo> parseFocusField(String? focus) {
    if (focus == null || focus.isEmpty || focus == 'null') {
      return [];
    }

    return focus
        .split(',')
        .map((s) => s.trim().toUpperCase())
        .where((s) => abbreviationMap.containsKey(s))
        .map((s) => abbreviationMap[s]!)
        .toList();
  }
}

class MuscleInfo {
  const MuscleInfo(this.displayName, this.id, this.group);

  final String displayName;
  final String id;
  final MuscleGroup group;
}
```

---

## 3. Entity: StressIndexResult (Freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stress_index_result.freezed.dart';
part 'stress_index_result.g.dart';

@freezed
class StressIndexResult with _$StressIndexResult {
  const factory StressIndexResult({
    /// Primary stress score (0-100, logarithmic)
    required double primaryScore,

    /// Fallback score (weight-only, when RPE missing)
    required double fallbackScore,

    /// Confidence level (0.0 - 1.0)
    required double confidence,

    /// Breakdown by muscle group
    required Map<String, MuscleStressData> muscleBreakdown,

    /// Total sets analyzed
    required int totalSets,

    /// Sets with RPE data
    required int setsWithRpe,

    /// Workout ID this belongs to
    required String workoutId,

    /// Calculation timestamp
    required DateTime calculatedAt,

    /// Raw score before logarithmic conversion
    required double rawScore,
  }) = _StressIndexResult;

  factory StressIndexResult.fromJson(Map<String, dynamic> json) =>
      _$StressIndexResultFromJson(json);
}

@freezed
class MuscleStressData with _$MuscleStressData {
  const factory MuscleStressData({
    required String muscleId,
    required String displayName,
    required double stressScore,
    required int setsCount,
    required double totalVolume,
    required double avgRpe,
    required int recoveryHours,
    required DateTime? estimatedRecovery,
  }) = _MuscleStressData;

  factory MuscleStressData.fromJson(Map<String, dynamic> json) =>
      _$MuscleStressDataFromJson(json);
}

@freezed
class MuscleRecoveryStatus with _$MuscleRecoveryStatus {
  const factory MuscleRecoveryStatus({
    required String muscleId,
    required String displayName,
    required double recoveryPercentage,
    required DateTime lastWorked,
    required double lastStressScore,
    required RecoveryState state,
  }) = _MuscleRecoveryStatus;

  factory MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) =>
      _$MuscleRecoveryStatusFromJson(json);
}

enum RecoveryState {
  fullyRecovered,   // 100%
  almostReady,      // 75-99%
  recovering,       // 50-74%
  fatigued,         // 25-49%
  exhausted,        // 0-24%
}
```

---

## 4. Calculator Service (Static)

```dart
/// Stress Index Calculator
///
/// Follows VolumeCalculator pattern: static utility class, no state.
///
/// Formula (RTS-based):
///   SetStress = weight × reps × RPE_intensity × movementMultiplier
///   WorkoutStress = sum(SetStress) → logarithmic scale
class StressIndexCalculator {
  StressIndexCalculator._();

  /// Calculate stress index for a completed workout
  static StressIndexResult calculate(Workout workout) {
    final muscleStress = <String, _MuscleAccumulator>{};
    int totalSets = 0;
    int setsWithRpe = 0;
    double rawScoreWithRpe = 0.0;
    double rawScoreWithoutRpe = 0.0;

    for (final exercise in workout.exercises) {
      // Get muscles from focus field
      final muscles = MuscleAbbreviationMapper.parseFocusField(
        exercise.focusField, // Need to access this from exercise definition
      );

      // Get movement multiplier
      final movementMultiplier = _getMovementMultiplier(exercise.movementType);

      for (final set in exercise.sets) {
        if (!set.isCompleted || set.isWarmup) continue;

        final weight = set.weight ?? 0.0;
        final reps = set.actualReps ?? set.reps ?? 0;

        if (weight <= 0 || reps <= 0) continue;

        totalSets++;

        // Calculate stress with RPE if available
        final rpe = set.rpe;
        final intensity = rpe != null
            ? StressIndexConstants.rpeToIntensity[rpe.round()] ?? 0.7
            : 0.7; // Default intensity for fallback

        final setStressWithRpe = weight * reps * intensity * movementMultiplier;
        final setStressWithoutRpe = weight * reps * 0.7 * movementMultiplier;

        if (rpe != null) {
          setsWithRpe++;
          rawScoreWithRpe += setStressWithRpe;
        }
        rawScoreWithoutRpe += setStressWithoutRpe;

        // Distribute to muscles
        for (final muscle in muscles) {
          muscleStress.putIfAbsent(
            muscle.id,
            () => _MuscleAccumulator(muscle.displayName),
          );
          muscleStress[muscle.id]!.add(
            stress: setStressWithRpe,
            volume: weight * reps,
            rpe: rpe,
          );
        }
      }
    }

    // Calculate confidence
    final confidence = totalSets > 0 ? setsWithRpe / totalSets : 0.0;

    // Use weighted combination based on confidence
    final rawScore = confidence >= StressIndexConstants.mediumConfidenceThreshold
        ? rawScoreWithRpe + (rawScoreWithoutRpe - rawScoreWithRpe) * (1 - confidence)
        : rawScoreWithoutRpe;

    // Convert to logarithmic 0-100 scale
    final primaryScore = _toLogarithmicScale(rawScoreWithRpe);
    final fallbackScore = _toLogarithmicScale(rawScoreWithoutRpe);

    // Build muscle breakdown
    final muscleBreakdown = <String, MuscleStressData>{};
    for (final entry in muscleStress.entries) {
      final acc = entry.value;
      final recoveryHours = StressIndexConstants.muscleRecoveryHours[entry.key.toUpperCase()] ?? 48;

      muscleBreakdown[entry.key] = MuscleStressData(
        muscleId: entry.key,
        displayName: acc.displayName,
        stressScore: _toLogarithmicScale(acc.totalStress),
        setsCount: acc.setCount,
        totalVolume: acc.totalVolume,
        avgRpe: acc.avgRpe,
        recoveryHours: recoveryHours,
        estimatedRecovery: DateTime.now().add(Duration(hours: recoveryHours)),
      );
    }

    return StressIndexResult(
      primaryScore: primaryScore,
      fallbackScore: fallbackScore,
      confidence: confidence,
      muscleBreakdown: muscleBreakdown,
      totalSets: totalSets,
      setsWithRpe: setsWithRpe,
      workoutId: workout.id,
      calculatedAt: DateTime.now(),
      rawScore: rawScore,
    );
  }

  /// Convert raw score to logarithmic 0-100 scale
  static double _toLogarithmicScale(double rawScore) {
    if (rawScore <= 0) return 0.0;

    // log10(rawScore + 1) / log10(maxRaw + 1) * 100
    final logScore = log(rawScore + 1) / log(StressIndexConstants.rawScoreForMax100 + 1);
    return (logScore * 100).clamp(0.0, 100.0);
  }

  /// Get movement type multiplier
  static double _getMovementMultiplier(MovementType? type) {
    if (type == null) return 1.0;
    return type.stressMultiplier;
  }

  /// Calculate current recovery status for all muscles
  static Map<String, MuscleRecoveryStatus> calculateRecoveryStatus(
    List<StressIndexResult> recentWorkouts,
  ) {
    final recoveryMap = <String, MuscleRecoveryStatus>{};
    final now = DateTime.now();

    // Aggregate last stress per muscle
    final lastMuscleWork = <String, (DateTime, double, String)>{};

    for (final workout in recentWorkouts) {
      for (final entry in workout.muscleBreakdown.entries) {
        final existing = lastMuscleWork[entry.key];
        if (existing == null || workout.calculatedAt.isAfter(existing.$1)) {
          lastMuscleWork[entry.key] = (
            workout.calculatedAt,
            entry.value.stressScore,
            entry.value.displayName,
          );
        }
      }
    }

    // Calculate recovery percentage
    for (final entry in lastMuscleWork.entries) {
      final (lastWorked, lastStress, displayName) = entry.value;
      final recoveryHours = StressIndexConstants.muscleRecoveryHours[entry.key.toUpperCase()] ?? 48;

      final hoursSinceWork = now.difference(lastWorked).inHours;
      final recoveryPercentage = (hoursSinceWork / recoveryHours * 100).clamp(0.0, 100.0);

      final state = switch (recoveryPercentage) {
        >= 100 => RecoveryState.fullyRecovered,
        >= 75 => RecoveryState.almostReady,
        >= 50 => RecoveryState.recovering,
        >= 25 => RecoveryState.fatigued,
        _ => RecoveryState.exhausted,
      };

      recoveryMap[entry.key] = MuscleRecoveryStatus(
        muscleId: entry.key,
        displayName: displayName,
        recoveryPercentage: recoveryPercentage,
        lastWorked: lastWorked,
        lastStressScore: lastStress,
        state: state,
      );
    }

    return recoveryMap;
  }
}

class _MuscleAccumulator {
  _MuscleAccumulator(this.displayName);

  final String displayName;
  double totalStress = 0.0;
  double totalVolume = 0.0;
  double totalRpe = 0.0;
  int setCount = 0;
  int rpeCount = 0;

  void add({required double stress, required double volume, double? rpe}) {
    totalStress += stress;
    totalVolume += volume;
    setCount++;
    if (rpe != null) {
      totalRpe += rpe;
      rpeCount++;
    }
  }

  double get avgRpe => rpeCount > 0 ? totalRpe / rpeCount : 0.0;
}
```

---

## 5. Integration Points

### 5.1 WorkoutProvider Hook

```dart
// In workout_provider.dart, after workout completion:

Future<void> _saveCompletedWorkout(Workout workout) async {
  // ... existing save logic ...

  // Calculate and save stress index
  final stressResult = StressIndexCalculator.calculate(workout);
  await _stressIndexRepository.save(stressResult);

  // Update muscle recovery cache
  state = state.copyWith(
    latestStressIndex: stressResult,
  );
}
```

### 5.2 Repository Extension

```dart
abstract class StressIndexRepository {
  Future<void> save(StressIndexResult result);
  Future<StressIndexResult?> getForWorkout(String workoutId);
  Future<List<StressIndexResult>> getRecent({int days = 7});
  Stream<List<StressIndexResult>> watchRecent({int days = 7});
}
```

### 5.3 Provider

```dart
@riverpod
class StressIndexNotifier extends _$StressIndexNotifier {
  @override
  Future<StressIndexState> build() async {
    final recentWorkouts = await ref.watch(
      recentStressIndexResultsProvider.future,
    );

    return StressIndexState(
      latestResult: recentWorkouts.firstOrNull,
      muscleRecovery: StressIndexCalculator.calculateRecoveryStatus(recentWorkouts),
      history: recentWorkouts,
    );
  }
}
```

---

## 6. UI Component

### 6.1 Compact Card (Primary View)

```dart
class StressIndexCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stressState = ref.watch(stressIndexNotifierProvider);

    return stressState.when(
      data: (state) => _buildCard(context, state),
      loading: () => const LoadingIndicator(),
      error: (e, _) => _buildErrorCard(context, e),
    );
  }

  Widget _buildCard(BuildContext context, StressIndexState state) {
    final result = state.latestResult;
    if (result == null) return const SizedBox.shrink();

    final score = result.primaryScore;
    final color = _getScoreColor(score);

    return GestureDetector(
      onTap: () => _showDetailModal(context, state),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.stressIndex,
                    style: context.textTheme.titleMedium,
                  ),
                  _buildConfidenceBadge(result.confidence),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildScoreCircle(score, color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getScoreLabel(score),
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getScoreDescription(score),
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.chevronRight,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
              if (result.confidence < StressIndexConstants.highConfidenceThreshold) ...[
                const SizedBox(height: 8),
                _buildRpeHint(context, result),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score < 30) return Colors.green;
    if (score < 60) return Colors.amber;
    if (score < 80) return Colors.orange;
    return Colors.red;
  }
}
```

### 6.2 Detail Modal (Tap to Expand)

```dart
class StressIndexDetailModal extends StatelessWidget {
  const StressIndexDetailModal({required this.state});

  final StressIndexState state;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildMuscleRecoveryGrid(context),
              const SizedBox(height: 24),
              _buildBreakdownChart(context),
              if (state.latestResult != null) ...[
                const SizedBox(height: 24),
                _buildConfidenceExplanation(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMuscleRecoveryGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.muscleRecovery,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.muscleRecovery.entries.map((entry) {
            return _MuscleRecoveryChip(status: entry.value);
          }).toList(),
        ),
      ],
    );
  }
}

class _MuscleRecoveryChip extends StatelessWidget {
  const _MuscleRecoveryChip({required this.status});

  final MuscleRecoveryStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.state) {
      RecoveryState.fullyRecovered => Colors.green,
      RecoveryState.almostReady => Colors.lightGreen,
      RecoveryState.recovering => Colors.amber,
      RecoveryState.fatigued => Colors.orange,
      RecoveryState.exhausted => Colors.red,
    };

    return Chip(
      label: Text('${status.displayName} ${status.recoveryPercentage.toInt()}%'),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }
}
```

---

## 7. Localization Keys

```arb
// app_en.arb
"stressIndex": "Training Stress",
"stressIndexDescription": "Measures workout intensity based on volume, weight, and RPE",
"muscleRecovery": "Muscle Recovery Status",
"lowConfidenceHint": "Log RPE for more accurate insights",
"stressLevelLight": "Light Session",
"stressLevelModerate": "Moderate Session",
"stressLevelHard": "Hard Session",
"stressLevelVeryHard": "Very Hard Session",
"fullyRecovered": "Fully Recovered",
"almostReady": "Almost Ready",
"recovering": "Recovering",
"fatigued": "Fatigued",
"exhausted": "Needs Rest"
```

---

## 8. File Structure

```
lib/features/stress_index/
├── domain/
│   ├── entities/
│   │   ├── stress_index_result.dart
│   │   ├── stress_index_result.freezed.dart
│   │   ├── stress_index_result.g.dart
│   │   ├── muscle_stress_data.dart
│   │   └── muscle_recovery_status.dart
│   ├── services/
│   │   └── stress_index_calculator.dart
│   └── constants/
│       └── stress_index_constants.dart
├── data/
│   ├── repositories/
│   │   └── stress_index_repository_impl.dart
│   └── mappers/
│       └── muscle_abbreviation_mapper.dart
└── presentation/
    ├── providers/
    │   └── stress_index_provider.dart
    └── widgets/
        ├── stress_index_card.dart
        └── stress_index_detail_modal.dart
```

---

## 9. Testing Strategy

```dart
// Unit tests for calculator
group('StressIndexCalculator', () {
  test('should calculate correct stress for simple workout', () {
    final workout = _createTestWorkout(
      sets: [
        (weight: 100, reps: 10, rpe: 8),
        (weight: 100, reps: 8, rpe: 9),
      ],
    );

    final result = StressIndexCalculator.calculate(workout);

    expect(result.confidence, 1.0);
    expect(result.primaryScore, greaterThan(0));
    expect(result.primaryScore, lessThanOrEqualTo(100));
  });

  test('should handle missing RPE with fallback', () {
    final workout = _createTestWorkout(
      sets: [
        (weight: 100, reps: 10, rpe: null),
        (weight: 100, reps: 8, rpe: 8),
      ],
    );

    final result = StressIndexCalculator.calculate(workout);

    expect(result.confidence, 0.5);
    expect(result.fallbackScore, greaterThan(0));
  });

  test('should use logarithmic scale', () {
    final lightWorkout = _createTestWorkout(totalVolume: 1000);
    final heavyWorkout = _createTestWorkout(totalVolume: 10000);

    final lightResult = StressIndexCalculator.calculate(lightWorkout);
    final heavyResult = StressIndexCalculator.calculate(heavyWorkout);

    // 10x volume should NOT result in 10x stress score (logarithmic)
    expect(heavyResult.primaryScore / lightResult.primaryScore, lessThan(5));
  });
});
```

---

## 10. Implementation Checklist

- [ ] Create feature folder structure
- [ ] Implement constants file
- [ ] Implement muscle abbreviation mapper
- [ ] Create freezed entities (run build_runner)
- [ ] Implement StressIndexCalculator
- [ ] Create repository interface + implementation
- [ ] Create Riverpod providers
- [ ] Build StressIndexCard widget
- [ ] Build StressIndexDetailModal
- [ ] Add localization keys (EN + IT)
- [ ] Integrate with WorkoutProvider
- [ ] Write unit tests
- [ ] Test UI in light/dark mode
- [ ] Manual testing with real workouts

---

## References

- Helms et al. (2018): RPE-Based Training Load Monitoring
- Zourdos et al. (2016): Novel Resistance Training-Specific RPE Scale
- WHOOP Recovery Algorithm documentation
- Juggernaut AI readiness check-in patterns
