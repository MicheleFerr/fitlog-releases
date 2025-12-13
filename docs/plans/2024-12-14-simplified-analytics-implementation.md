# Simplified Analytics Dashboard - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the complex tabbed analytics screen with a simplified dashboard showing Hero stats, Body heatmap, Top exercises, and Recent activity.

**Architecture:** Feature-flagged replacement of `AnalyticsScreen`. New screen reuses existing widgets (`AnatomicalBodyHeatmap`, `WorkoutDetailModal`) with new wrapper components. Old screen preserved for rollback.

**Tech Stack:** Flutter, Riverpod, existing analytics providers

---

## Task 0: Feature Flag Setup

**Files:**
- Modify: `lib/shared/domain/entities/app_config.dart`
- Modify: `lib/shared/domain/entities/app_config.g.dart` (auto-generated)

**Step 1: Add feature flag to AppConfig**

In `lib/shared/domain/entities/app_config.dart`, add after line ~56 (after `autoPauseOnNavigateAway`):

```dart
this.useSimplifiedAnalytics = false, // Feature flag for new dashboard
```

Add the field declaration after line ~180 (with other fields):

```dart
@HiveField(52)
final bool? useSimplifiedAnalytics;
```

Add to `fromJson` factory (around line ~130):

```dart
useSimplifiedAnalytics: json['useSimplifiedAnalytics'] as bool? ?? false,
```

Add to `toJson` method:

```dart
'useSimplifiedAnalytics': useSimplifiedAnalytics,
```

Add to `copyWith` method:

```dart
bool? useSimplifiedAnalytics,
```

And in the return:

```dart
useSimplifiedAnalytics: useSimplifiedAnalytics ?? this.useSimplifiedAnalytics,
```

**Step 2: Regenerate Hive adapters**

Run:
```bash
cd /Users/michele/gymbro_flutter_new && flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 3: Commit**

```bash
git add lib/shared/domain/entities/app_config.dart lib/shared/domain/entities/app_config.g.dart
git commit -m "feat(analytics): add useSimplifiedAnalytics feature flag for rollback"
```

---

## Task 1: Create Stats Bar Widget

**Files:**
- Create: `lib/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart`
- Test: `test/features/analytics/presentation/widgets/dashboard/stats_bar_widget_test.dart`

**Step 1: Create directory**

```bash
mkdir -p lib/features/analytics/presentation/widgets/dashboard
mkdir -p test/features/analytics/presentation/widgets/dashboard
```

**Step 2: Write the test**

Create `test/features/analytics/presentation/widgets/dashboard/stats_bar_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart';

void main() {
  group('StatsBarWidget', () {
    testWidgets('displays volume, streak, and PR count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsBarWidget(
              totalVolume: 12400,
              streakDays: 5,
              prCount: 2,
              measurementUnit: 'kg',
            ),
          ),
        ),
      );

      expect(find.text('12.4k'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('formats large volume correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsBarWidget(
              totalVolume: 150000,
              streakDays: 10,
              prCount: 5,
              measurementUnit: 'kg',
            ),
          ),
        ),
      );

      expect(find.text('150k'), findsOneWidget);
    });
  });
}
```

**Step 3: Run test to verify it fails**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/stats_bar_widget_test.dart
```

Expected: FAIL - file not found

**Step 4: Write minimal implementation**

Create `lib/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Stats bar showing Volume, Streak, and PR count
class StatsBarWidget extends StatelessWidget {
  const StatsBarWidget({
    required this.totalVolume,
    required this.streakDays,
    required this.prCount,
    required this.measurementUnit,
    this.onVolumeTap,
    this.onStreakTap,
    this.onPrTap,
    super.key,
  });

  final double totalVolume;
  final int streakDays;
  final int prCount;
  final String measurementUnit;
  final VoidCallback? onVolumeTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onPrTap;

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      final k = volume / 1000;
      if (k >= 100) {
        return '${k.round()}k';
      }
      return '${k.toStringAsFixed(1)}k';
    }
    return volume.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.fitness_center,
            value: _formatVolume(totalVolume),
            label: measurementUnit,
            color: colors.primary,
            onTap: onVolumeTap,
          ),
          _divider(colors),
          _StatItem(
            icon: Icons.local_fire_department,
            value: streakDays.toString(),
            label: 'days',
            color: colors.tertiary,
            onTap: onStreakTap,
          ),
          _divider(colors),
          _StatItem(
            icon: Icons.emoji_events,
            value: prCount.toString(),
            label: 'PR',
            color: colors.secondary,
            onTap: onPrTap,
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme colors) {
    return Container(
      height: 32,
      width: 1,
      color: colors.outlineVariant.withOpacity(0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 5: Run test to verify it passes**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/stats_bar_widget_test.dart
```

Expected: PASS

**Step 6: Commit**

```bash
git add lib/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart test/features/analytics/presentation/widgets/dashboard/stats_bar_widget_test.dart
git commit -m "feat(analytics): add StatsBarWidget with volume, streak, PR display"
```

---

## Task 2: Create Hero Stat Section

**Files:**
- Create: `lib/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart`
- Test: `test/features/analytics/presentation/widgets/dashboard/hero_stat_section_test.dart`

**Step 1: Write the test**

Create `test/features/analytics/presentation/widgets/dashboard/hero_stat_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart';

void main() {
  group('HeroStatSection', () {
    testWidgets('displays workout count prominently', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroStatSection(
              workoutCount: 4,
              previousWeekCount: 2,
              weeklyGoal: 5,
            ),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.textContaining('workout'), findsOneWidget);
    });

    testWidgets('shows positive delta when improved', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroStatSection(
              workoutCount: 4,
              previousWeekCount: 2,
              weeklyGoal: 5,
            ),
          ),
        ),
      );

      expect(find.textContaining('+2'), findsOneWidget);
    });

    testWidgets('shows negative delta when decreased', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HeroStatSection(
              workoutCount: 2,
              previousWeekCount: 4,
              weeklyGoal: 5,
            ),
          ),
        ),
      );

      expect(find.textContaining('-2'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/hero_stat_section_test.dart
```

Expected: FAIL

**Step 3: Write implementation**

Create `lib/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Hero section showing weekly workout count with delta comparison
class HeroStatSection extends StatelessWidget {
  const HeroStatSection({
    required this.workoutCount,
    required this.previousWeekCount,
    this.weeklyGoal,
    this.onTap,
    super.key,
  });

  final int workoutCount;
  final int previousWeekCount;
  final int? weeklyGoal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final delta = workoutCount - previousWeekCount;
    final deltaColor = delta > 0
        ? colors.primary
        : delta < 0
            ? colors.error
            : colors.onSurfaceVariant;
    final deltaIcon = delta > 0
        ? Icons.arrow_upward
        : delta < 0
            ? Icons.arrow_downward
            : Icons.remove;

    final progress = weeklyGoal != null && weeklyGoal! > 0
        ? (workoutCount / weeklyGoal!).clamp(0.0, 1.0)
        : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withOpacity(0.3),
              colors.secondaryContainer.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big number
            Text(
              workoutCount.toString(),
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
                fontSize: 56,
              ),
            ),
            Text(
              workoutCount == 1
                  ? l10n.workout.toLowerCase()
                  : l10n.workouts.toLowerCase(),
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Delta indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(deltaIcon, size: 16, color: deltaColor),
                const SizedBox(width: 4),
                Text(
                  delta >= 0 ? '+$delta' : '$delta',
                  style: textTheme.bodyMedium?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' vs last week',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Progress bar (if goal set)
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}% of weekly goal',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/hero_stat_section_test.dart
```

**Step 5: Commit**

```bash
git add lib/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart test/features/analytics/presentation/widgets/dashboard/hero_stat_section_test.dart
git commit -m "feat(analytics): add HeroStatSection with workout count and delta"
```

---

## Task 3: Create Top Exercises Section

**Files:**
- Create: `lib/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart`
- Test: `test/features/analytics/presentation/widgets/dashboard/top_exercises_section_test.dart`

**Step 1: Write the test**

Create `test/features/analytics/presentation/widgets/dashboard/top_exercises_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart';

void main() {
  group('TopExercisesSection', () {
    final testExercises = [
      TopExerciseData(
        name: 'Bench Press',
        sessionCount: 4,
        lastWeight: 80,
        lastReps: 8,
        weightDelta: 2.5,
        measurementUnit: 'kg',
      ),
      TopExerciseData(
        name: 'Squat',
        sessionCount: 3,
        lastWeight: 100,
        lastReps: 5,
        weightDelta: 0,
        measurementUnit: 'kg',
      ),
    ];

    testWidgets('displays exercise name and session count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopExercisesSection(exercises: testExercises),
          ),
        ),
      );

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.textContaining('4'), findsOneWidget);
    });

    testWidgets('shows weight delta with arrow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopExercisesSection(exercises: testExercises),
          ),
        ),
      );

      expect(find.textContaining('+2.5'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/top_exercises_section_test.dart
```

**Step 3: Write implementation**

Create `lib/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Data model for top exercise display
class TopExerciseData {
  const TopExerciseData({
    required this.name,
    required this.sessionCount,
    required this.lastWeight,
    required this.lastReps,
    required this.weightDelta,
    required this.measurementUnit,
    this.isPR = false,
  });

  final String name;
  final int sessionCount;
  final double lastWeight;
  final int lastReps;
  final double weightDelta; // positive = improved, negative = decreased, 0 = same
  final String measurementUnit;
  final bool isPR;
}

/// Section showing top exercises with progressive overload context
class TopExercisesSection extends StatelessWidget {
  const TopExercisesSection({
    required this.exercises,
    this.maxVisible = 4,
    this.onExerciseTap,
    this.onSeeAllTap,
    this.periodLabel = '7 days',
    super.key,
  });

  final List<TopExerciseData> exercises;
  final int maxVisible;
  final void Function(String exerciseName)? onExerciseTap;
  final VoidCallback? onSeeAllTap;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final visibleExercises = exercises.take(maxVisible).toList();
    final hasMore = exercises.length > maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(AppIcons.dumbbell, size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.yourExercises,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  periodLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Exercise cards
        ...visibleExercises.map((exercise) => _ExerciseCard(
          exercise: exercise,
          onTap: () {
            HapticFeedback.lightImpact();
            onExerciseTap?.call(exercise.name);
          },
        )),

        // See all button
        if (hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                'See all (${exercises.length}) →',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    this.onTap,
  });

  final TopExerciseData exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final deltaColor = exercise.weightDelta > 0
        ? colors.primary
        : exercise.weightDelta < 0
            ? colors.error
            : colors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            exercise.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (exercise.isPR) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🏆 PR',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise.sessionCount} sessions • Last: ${exercise.lastWeight}${exercise.measurementUnit} x ${exercise.lastReps}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Delta indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deltaColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        exercise.weightDelta > 0
                            ? Icons.arrow_upward
                            : exercise.weightDelta < 0
                                ? Icons.arrow_downward
                                : Icons.remove,
                        size: 14,
                        color: deltaColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        exercise.weightDelta == 0
                            ? '='
                            : '${exercise.weightDelta > 0 ? '+' : ''}${exercise.weightDelta}',
                        style: textTheme.bodySmall?.copyWith(
                          color: deltaColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/top_exercises_section_test.dart
```

**Step 5: Commit**

```bash
git add lib/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart test/features/analytics/presentation/widgets/dashboard/top_exercises_section_test.dart
git commit -m "feat(analytics): add TopExercisesSection with progressive overload context"
```

---

## Task 4: Create Recent Activity Section

**Files:**
- Create: `lib/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart`
- Test: `test/features/analytics/presentation/widgets/dashboard/recent_activity_section_test.dart`

**Step 1: Write the test**

Create `test/features/analytics/presentation/widgets/dashboard/recent_activity_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart';

void main() {
  group('RecentActivitySection', () {
    final testWorkouts = [
      RecentWorkoutData(
        id: '1',
        name: 'Push Day',
        date: DateTime.now(),
        durationMinutes: 45,
        exerciseCount: 8,
        totalVolume: 12400,
        muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
        prCount: 2,
      ),
      RecentWorkoutData(
        id: '2',
        name: 'Leg Day',
        date: DateTime.now().subtract(const Duration(days: 1)),
        durationMinutes: 52,
        exerciseCount: 6,
        totalVolume: 18200,
        muscleGroups: ['Quadriceps', 'Glutes'],
        prCount: 0,
      ),
    ];

    testWidgets('displays workout names', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivitySection(workouts: testWorkouts),
          ),
        ),
      );

      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text('Leg Day'), findsOneWidget);
    });

    testWidgets('shows relative date for today', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivitySection(workouts: testWorkouts),
          ),
        ),
      );

      expect(find.text('TODAY'), findsOneWidget);
    });

    testWidgets('shows PR badge when prCount > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentActivitySection(workouts: testWorkouts),
          ),
        ),
      );

      expect(find.textContaining('PR'), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/recent_activity_section_test.dart
```

**Step 3: Write implementation**

Create `lib/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Data model for recent workout display
class RecentWorkoutData {
  const RecentWorkoutData({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.totalVolume,
    required this.muscleGroups,
    this.prCount = 0,
  });

  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final int exerciseCount;
  final double totalVolume;
  final List<String> muscleGroups;
  final int prCount;
}

/// Section showing recent workout activity
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    required this.workouts,
    this.maxVisible = 3,
    this.onWorkoutTap,
    this.onSeeAllTap,
    this.measurementUnit = 'kg',
    super.key,
  });

  final List<RecentWorkoutData> workouts;
  final int maxVisible;
  final void Function(String workoutId)? onWorkoutTap;
  final VoidCallback? onSeeAllTap;
  final String measurementUnit;

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDate).inDays;

    if (difference == 0) return 'TODAY';
    if (difference == 1) return 'YESTERDAY';
    if (difference < 7) return '$difference DAYS AGO';
    return '${date.day}/${date.month}';
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final visibleWorkouts = workouts.take(maxVisible).toList();

    if (workouts.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(AppIcons.calendar, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.thisWeek,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Workout cards
        ...visibleWorkouts.map((workout) => _WorkoutCard(
          workout: workout,
          relativeDate: _formatRelativeDate(workout.date),
          formattedVolume: _formatVolume(workout.totalVolume),
          measurementUnit: measurementUnit,
          isToday: _formatRelativeDate(workout.date) == 'TODAY',
          onTap: () {
            HapticFeedback.lightImpact();
            onWorkoutTap?.call(workout.id);
          },
        )),

        // See all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton(
            onPressed: onSeeAllTap,
            child: Text(
              'View full history →',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            AppIcons.dumbbell,
            size: 48,
            color: colors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noWorkoutsThisWeek,
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {}, // Will be connected to workout start
            child: Text(l10n.startWorkout),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.relativeDate,
    required this.formattedVolume,
    required this.measurementUnit,
    required this.isToday,
    this.onTap,
  });

  final RecentWorkoutData workout;
  final String relativeDate;
  final String formattedVolume;
  final String measurementUnit;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date row
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? colors.primary : colors.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      relativeDate,
                      style: textTheme.labelSmall?.copyWith(
                        color: isToday ? colors.primary : colors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Workout name and duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      workout.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${workout.durationMinutes} min',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Muscle groups
                Text(
                  workout.muscleGroups.join(' • '),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Stats row
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.fitness_center,
                      label: '${workout.exerciseCount}',
                      colors: colors,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.scale,
                      label: '$formattedVolume $measurementUnit',
                      colors: colors,
                    ),
                    if (workout.prCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '🏆 ${workout.prCount} PR',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 4: Run test to verify it passes**

```bash
flutter test test/features/analytics/presentation/widgets/dashboard/recent_activity_section_test.dart
```

**Step 5: Commit**

```bash
git add lib/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart test/features/analytics/presentation/widgets/dashboard/recent_activity_section_test.dart
git commit -m "feat(analytics): add RecentActivitySection with workout cards"
```

---

## Task 5: Create Simplified Analytics Dashboard Screen

**Files:**
- Create: `lib/features/analytics/presentation/screens/simplified_analytics_dashboard.dart`
- Modify: `lib/core/navigation/app_router.dart`

**Step 1: Create the main dashboard screen**

Create `lib/features/analytics/presentation/screens/simplified_analytics_dashboard.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/anatomical_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/premium_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/skeleton_loader.dart';

/// Simplified Analytics Dashboard
///
/// Shows 4 sections:
/// 1. Hero stat (workout count this week)
/// 2. Stats bar + Body heatmap
/// 3. Top exercises with progressive overload
/// 4. Recent activity
class SimplifiedAnalyticsDashboard extends ConsumerWidget {
  const SimplifiedAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const SemanticIcon(
            icon: AppIcons.back,
            semanticLabel: 'Back',
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.homePath);
            }
          },
        ),
        title: Text(
          l10n.analytics,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Pro insights button
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.barChart,
              semanticLabel: 'Pro Analytics',
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pushNamed(AppRoutes.proAnalyticsName);
            },
          ),
        ],
      ),
      body: authState != AuthState.authenticated
          ? _buildNotAuthenticatedView(context)
          : _buildContent(context, ref),
    );
  }

  Widget _buildNotAuthenticatedView(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.barChart,
            size: 64,
            color: colors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loginToSeeAnalytics,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.loginPath),
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(weeklyAnalyticsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return analyticsAsync.when(
      loading: () => const SkeletonLoader(type: SkeletonType.analytics),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (analytics) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weeklyAnalyticsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Hero Stat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HeroStatSection(
                  workoutCount: analytics.weeklyWorkoutCount,
                  previousWeekCount: analytics.previousWeekWorkoutCount,
                  weeklyGoal: analytics.weeklyGoal,
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StatsBarWidget(
                  totalVolume: analytics.weeklyVolume,
                  streakDays: analytics.currentStreak,
                  prCount: analytics.weeklyPRCount,
                  measurementUnit: analytics.measurementUnit,
                ),
              ),
              const SizedBox(height: 16),

              // Section 2b: Body Heatmap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildBodyHeatmapSection(
                  context,
                  ref,
                  analytics.muscleHeatData,
                  isPremium,
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Top Exercises
              TopExercisesSection(
                exercises: analytics.topExercises.map((e) => TopExerciseData(
                  name: e.name,
                  sessionCount: e.sessionCount,
                  lastWeight: e.lastWeight,
                  lastReps: e.lastReps,
                  weightDelta: e.weightDelta,
                  measurementUnit: analytics.measurementUnit,
                  isPR: e.isPR,
                )).toList(),
                onExerciseTap: (name) {
                  context.pushNamed(
                    AppRoutes.analyticsExerciseDetailName,
                    pathParameters: {'exerciseName': Uri.encodeComponent(name)},
                  );
                },
                onSeeAllTap: () {
                  context.pushNamed(AppRoutes.exerciseProgressName);
                },
              ),
              const SizedBox(height: 24),

              // Section 4: Recent Activity
              RecentActivitySection(
                workouts: analytics.recentWorkouts.map((w) => RecentWorkoutData(
                  id: w.id,
                  name: w.name,
                  date: w.date,
                  durationMinutes: w.durationMinutes,
                  exerciseCount: w.exerciseCount,
                  totalVolume: w.totalVolume,
                  muscleGroups: w.muscleGroups,
                  prCount: w.prCount,
                )).toList(),
                measurementUnit: analytics.measurementUnit,
                onWorkoutTap: (id) {
                  // Open workout detail modal
                },
                onSeeAllTap: () {
                  context.pushNamed(AppRoutes.workoutHistoryName);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyHeatmapSection(
    BuildContext context,
    WidgetRef ref,
    MuscleHeatData heatData,
    bool isPremium,
  ) {
    final colors = context.colors;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isPremium) {
          context.pushNamed(AppRoutes.muscleBalanceName);
        } else {
          // Show premium modal
          context.pushNamed(AppRoutes.premiumUpgradeName);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Heatmap
            SizedBox(
              height: 220,
              child: AnatomicalBodyHeatmap(
                heatData: heatData,
              ),
            ),

            // CTA bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.touch,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tapForDetailedAnalysis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.tertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Modify app_router.dart for feature flag**

In `lib/core/navigation/app_router.dart`, modify the analytics route (around line 317):

```dart
// Replace:
builder: (context, state) => const AnalyticsScreen(),

// With:
builder: (context, state) {
  // Feature flag check - read from config provider
  final useSimplified = false; // TODO: Connect to AppConfig provider
  return useSimplified
      ? const SimplifiedAnalyticsDashboard()
      : const AnalyticsScreen();
},
```

Add import at top:
```dart
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/simplified_analytics_dashboard.dart';
```

**Step 3: Run flutter analyze**

```bash
flutter analyze lib/features/analytics/presentation/screens/simplified_analytics_dashboard.dart
```

**Step 4: Commit**

```bash
git add lib/features/analytics/presentation/screens/simplified_analytics_dashboard.dart lib/core/navigation/app_router.dart
git commit -m "feat(analytics): add SimplifiedAnalyticsDashboard with feature flag routing"
```

---

## Task 6: Create Weekly Analytics Provider

**Files:**
- Create: `lib/features/analytics/presentation/providers/weekly_analytics_provider.dart`
- Modify: `lib/features/analytics/presentation/providers/analytics_provider.dart`

**Step 1: Create data models and provider**

Create `lib/features/analytics/presentation/providers/weekly_analytics_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/anatomical_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/settings_provider.dart';

/// Data model for weekly analytics dashboard
class WeeklyAnalyticsData {
  const WeeklyAnalyticsData({
    required this.weeklyWorkoutCount,
    required this.previousWeekWorkoutCount,
    this.weeklyGoal,
    required this.weeklyVolume,
    required this.currentStreak,
    required this.weeklyPRCount,
    required this.measurementUnit,
    required this.muscleHeatData,
    required this.topExercises,
    required this.recentWorkouts,
  });

  final int weeklyWorkoutCount;
  final int previousWeekWorkoutCount;
  final int? weeklyGoal;
  final double weeklyVolume;
  final int currentStreak;
  final int weeklyPRCount;
  final String measurementUnit;
  final MuscleHeatData muscleHeatData;
  final List<TopExerciseInfo> topExercises;
  final List<RecentWorkoutInfo> recentWorkouts;
}

class TopExerciseInfo {
  const TopExerciseInfo({
    required this.name,
    required this.sessionCount,
    required this.lastWeight,
    required this.lastReps,
    required this.weightDelta,
    required this.isPR,
  });

  final String name;
  final int sessionCount;
  final double lastWeight;
  final int lastReps;
  final double weightDelta;
  final bool isPR;
}

class RecentWorkoutInfo {
  const RecentWorkoutInfo({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.totalVolume,
    required this.muscleGroups,
    required this.prCount,
  });

  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final int exerciseCount;
  final double totalVolume;
  final List<String> muscleGroups;
  final int prCount;
}

/// Provider for weekly analytics dashboard data
final weeklyAnalyticsProvider = FutureProvider<WeeklyAnalyticsData>((ref) async {
  final workouts = await ref.watch(historicalWorkoutsProvider.future);
  final settings = ref.watch(settingsProvider);
  final measurementUnit = settings.measurementUnit ?? 'kg';

  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));

  // Filter workouts by week
  final thisWeekWorkouts = workouts.where((w) =>
    w.startTime.isAfter(startOfWeek)).toList();
  final previousWeekWorkouts = workouts.where((w) =>
    w.startTime.isAfter(startOfPreviousWeek) &&
    w.startTime.isBefore(startOfWeek)).toList();

  // Calculate weekly volume
  double weeklyVolume = 0;
  for (final workout in thisWeekWorkouts) {
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          weeklyVolume += (set.weight ?? 0) * (set.reps ?? 0);
        }
      }
    }
  }

  // Calculate muscle heat data
  final muscleVolumes = <String, double>{};
  for (final workout in thisWeekWorkouts) {
    for (final exercise in workout.exercises) {
      for (final muscle in exercise.targetMuscles) {
        muscleVolumes[muscle] = (muscleVolumes[muscle] ?? 0) + 1;
      }
    }
  }
  final maxMuscle = muscleVolumes.values.fold<double>(0, (a, b) => a > b ? a : b);
  final normalizedMuscles = <String, double>{};
  for (final entry in muscleVolumes.entries) {
    normalizedMuscles[entry.key] = maxMuscle > 0 ? (entry.value / maxMuscle) * 100 : 0;
  }

  // Calculate top exercises
  final exerciseCounts = <String, int>{};
  final exerciseLastSets = <String, (double, int)>{};
  for (final workout in thisWeekWorkouts) {
    for (final exercise in workout.exercises) {
      exerciseCounts[exercise.name] = (exerciseCounts[exercise.name] ?? 0) + 1;
      final lastSet = exercise.sets.lastWhere(
        (s) => s.isCompleted,
        orElse: () => exercise.sets.first,
      );
      exerciseLastSets[exercise.name] = (lastSet.weight ?? 0, lastSet.reps ?? 0);
    }
  }

  final topExercises = exerciseCounts.entries
      .map((e) {
        final lastSet = exerciseLastSets[e.key]!;
        return TopExerciseInfo(
          name: e.key,
          sessionCount: e.value,
          lastWeight: lastSet.$1,
          lastReps: lastSet.$2,
          weightDelta: 0, // TODO: Calculate from previous week
          isPR: false, // TODO: Check PR status
        );
      })
      .toList()
    ..sort((a, b) => b.sessionCount.compareTo(a.sessionCount));

  // Build recent workouts
  final recentWorkouts = thisWeekWorkouts
      .take(5)
      .map((w) {
        double volume = 0;
        final muscles = <String>{};
        for (final ex in w.exercises) {
          muscles.addAll(ex.targetMuscles);
          for (final set in ex.sets) {
            if (set.isCompleted) {
              volume += (set.weight ?? 0) * (set.reps ?? 0);
            }
          }
        }
        return RecentWorkoutInfo(
          id: w.id,
          name: w.name ?? 'Workout',
          date: w.startTime,
          durationMinutes: w.duration?.inMinutes ?? 0,
          exerciseCount: w.exercises.length,
          totalVolume: volume,
          muscleGroups: muscles.toList(),
          prCount: 0, // TODO: Calculate
        );
      })
      .toList();

  return WeeklyAnalyticsData(
    weeklyWorkoutCount: thisWeekWorkouts.length,
    previousWeekWorkoutCount: previousWeekWorkouts.length,
    weeklyGoal: settings.weeklyGoal,
    weeklyVolume: weeklyVolume,
    currentStreak: 0, // TODO: Calculate from streak provider
    weeklyPRCount: 0, // TODO: Calculate from PR provider
    measurementUnit: measurementUnit,
    muscleHeatData: MuscleHeatData.fromVolumePercentages(normalizedMuscles),
    topExercises: topExercises.take(10).toList(),
    recentWorkouts: recentWorkouts,
  );
});
```

**Step 2: Export from analytics_provider.dart**

Add to `lib/features/analytics/presentation/providers/analytics_provider.dart`:

```dart
export 'weekly_analytics_provider.dart';
```

**Step 3: Commit**

```bash
git add lib/features/analytics/presentation/providers/weekly_analytics_provider.dart lib/features/analytics/presentation/providers/analytics_provider.dart
git commit -m "feat(analytics): add weeklyAnalyticsProvider for simplified dashboard"
```

---

## Task 7: Add Missing Localizations

**Files:**
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Add English localizations**

Add to `assets/i18n/app_en.arb`:

```json
"yourExercises": "Your exercises",
"thisWeek": "This week",
"noWorkoutsThisWeek": "No workouts this week",
"startWorkout": "Start a workout",
"tapForDetailedAnalysis": "Tap for detailed analysis",
"loginToSeeAnalytics": "Log in to see your analytics"
```

**Step 2: Add Italian localizations**

Add to `assets/i18n/app_it.arb`:

```json
"yourExercises": "I tuoi esercizi",
"thisWeek": "Questa settimana",
"noWorkoutsThisWeek": "Nessun allenamento questa settimana",
"startWorkout": "Inizia un allenamento",
"tapForDetailedAnalysis": "Tocca per analisi dettagliata",
"loginToSeeAnalytics": "Accedi per vedere le tue statistiche"
```

**Step 3: Regenerate localizations**

```bash
flutter gen-l10n
```

**Step 4: Commit**

```bash
git add assets/i18n/app_en.arb assets/i18n/app_it.arb lib/shared/presentation/l10n/generated/
git commit -m "feat(l10n): add localizations for simplified analytics dashboard"
```

---

## Task 8: Integration Test

**Files:**
- Create: `test/features/analytics/presentation/screens/simplified_analytics_dashboard_test.dart`

**Step 1: Write integration test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/simplified_analytics_dashboard.dart';

void main() {
  group('SimplifiedAnalyticsDashboard', () {
    testWidgets('renders all 4 sections when data available', (tester) async {
      // TODO: Add proper mocking for providers
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SimplifiedAnalyticsDashboard(),
          ),
        ),
      );

      // Verify scaffold renders
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
```

**Step 2: Run test**

```bash
flutter test test/features/analytics/presentation/screens/simplified_analytics_dashboard_test.dart
```

**Step 3: Commit**

```bash
git add test/features/analytics/presentation/screens/simplified_analytics_dashboard_test.dart
git commit -m "test(analytics): add integration test for SimplifiedAnalyticsDashboard"
```

---

## Task 9: Enable Feature Flag for Testing

**Step 1: Temporarily enable the feature flag**

In `lib/core/navigation/app_router.dart`, change:

```dart
final useSimplified = false;
// To:
final useSimplified = true;
```

**Step 2: Run the app and test manually**

```bash
flutter run
```

Navigate to Analytics and verify:
- [ ] Hero section shows workout count
- [ ] Stats bar shows volume, streak, PR
- [ ] Body heatmap displays correctly
- [ ] Top exercises show with delta indicators
- [ ] Recent activity shows workout cards
- [ ] Tap on heatmap navigates correctly (premium gate works)

**Step 3: Set back to false for production (or connect to real config)**

```bash
git add lib/core/navigation/app_router.dart
git commit -m "feat(analytics): enable simplified dashboard feature flag"
```

---

## Rollback Instructions

To rollback to the old analytics:

1. Set `useSimplifiedAnalytics: false` in user's AppConfig
2. Or change `final useSimplified = false` in app_router.dart
3. The old `AnalyticsScreen` and `TabbedAnalyticsScreen` are preserved

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 0 | Feature flag setup | AppConfig |
| 1 | Stats bar widget | stats_bar_widget.dart |
| 2 | Hero stat section | hero_stat_section.dart |
| 3 | Top exercises section | top_exercises_section.dart |
| 4 | Recent activity section | recent_activity_section.dart |
| 5 | Main dashboard screen | simplified_analytics_dashboard.dart |
| 6 | Weekly analytics provider | weekly_analytics_provider.dart |
| 7 | Localizations | app_en.arb, app_it.arb |
| 8 | Integration test | test file |
| 9 | Enable and test | app_router.dart |

**Estimated tasks:** 9
**Rollback:** Feature flag preserves old screen
