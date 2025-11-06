# Workout Selector Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable users to manually complete routine days by selecting which workout to link, fixing template mismatch issues retroactively.

**Architecture:** Add WorkoutSelectorSheet bottom sheet that appears when user taps "Complete" on a scheduled day. Sheet displays recent workouts (last 7 days) with template match indicators. User selects workout → day completed with workoutId link. Fallback: "Complete without workout" option.

**Tech Stack:** Flutter, Riverpod (FutureProvider.family), Firebase Analytics, Material 3 design system

---

## Task 1: Create recentWorkoutsProvider

**Files:**
- Modify: `lib/features/workout/presentation/providers/workout_provider.dart` (add provider)
- Test: `test/features/workout/presentation/providers/workout_provider_test.dart`

### Step 1: Write the failing test

```dart
// test/features/workout/presentation/providers/workout_provider_test.dart

// Add to existing file after other tests
group('recentWorkoutsProvider', () {
  test('returns workouts from last N days', () async {
    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    // Setup: Mock repository with 5 workouts
    final now = DateTime.now();
    final workouts = [
      createMockWorkout(id: '1', name: 'Workout 1', startTime: now),
      createMockWorkout(id: '2', name: 'Workout 2', startTime: now.subtract(Duration(days: 2))),
      createMockWorkout(id: '3', name: 'Workout 3', startTime: now.subtract(Duration(days: 5))),
      createMockWorkout(id: '4', name: 'Workout 4', startTime: now.subtract(Duration(days: 8))), // Outside 7 days
      createMockWorkout(id: '5', name: 'Workout 5', startTime: now.subtract(Duration(days: 10))), // Outside 7 days
    ];

    when(mockRepository.getWorkouts(limit: 50))
        .thenAnswer((_) async => Right(workouts));

    // Act: Fetch last 7 days
    final result = await container.read(recentWorkoutsProvider(7).future);

    // Assert: Only workouts within 7 days
    expect(result.length, 3);
    expect(result[0].id, '1');
    expect(result[1].id, '2');
    expect(result[2].id, '3');
  });

  test('filters out workouts without startTime', () async {
    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    final now = DateTime.now();
    final workouts = [
      createMockWorkout(id: '1', name: 'With time', startTime: now),
      createMockWorkout(id: '2', name: 'Without time', startTime: null),
    ];

    when(mockRepository.getWorkouts(limit: 50))
        .thenAnswer((_) async => Right(workouts));

    final result = await container.read(recentWorkoutsProvider(7).future);

    expect(result.length, 1);
    expect(result[0].id, '1');
  });

  test('throws exception on repository failure', () async {
    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    when(mockRepository.getWorkouts(limit: 50))
        .thenAnswer((_) async => Left(FirestoreFailure(message: 'Network error')));

    expect(
      () => container.read(recentWorkoutsProvider(7).future),
      throwsA(isA<Exception>()),
    );
  });
});

// Helper function (add at bottom of file)
Workout createMockWorkout({
  required String id,
  required String name,
  DateTime? startTime,
}) {
  return Workout(
    id: id,
    userId: 'test-user',
    name: name,
    startTime: startTime,
    endTime: startTime?.add(Duration(minutes: 45)),
    exercises: [],
    totalDuration: Duration(minutes: 45),
    notes: null,
    templateId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
```

### Step 2: Run test to verify it fails

```bash
flutter test test/features/workout/presentation/providers/workout_provider_test.dart
```

**Expected Output**:
```
FAIL - recentWorkoutsProvider is not defined
Error: Undefined name 'recentWorkoutsProvider'
```

### Step 3: Write minimal implementation

```dart
// lib/features/workout/presentation/providers/workout_provider.dart

// Add this provider at the bottom of the file, after existing providers

/// Provider for fetching workouts from the last N days
///
/// Usage: ref.watch(recentWorkoutsProvider(7)) → Last 7 days
///
/// Returns: List<Workout> filtered by:
/// - startTime is not null
/// - startTime is after cutoff date (now - N days)
///
/// Throws: Exception if repository fetch fails
final recentWorkoutsProvider = FutureProvider.family<List<Workout>, int>(
  (ref, days) async {
    final repository = ref.watch(workoutRepositoryProvider);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final result = await repository.getWorkouts(limit: 50);

    return result.fold(
      (failure) => throw Exception('Failed to load workouts: ${failure.message}'),
      (workouts) => workouts.where((w) =>
        w.startTime != null &&
        w.startTime!.isAfter(cutoffDate)
      ).toList(),
    );
  },
);
```

### Step 4: Run test to verify it passes

```bash
flutter test test/features/workout/presentation/providers/workout_provider_test.dart --name "recentWorkoutsProvider"
```

**Expected Output**:
```
✓ recentWorkoutsProvider returns workouts from last N days
✓ recentWorkoutsProvider filters out workouts without startTime
✓ recentWorkoutsProvider throws exception on repository failure

All tests passed!
```

### Step 5: Verify flutter analyze passes

```bash
flutter analyze lib/features/workout/presentation/providers/workout_provider.dart
```

**Expected Output**: `No issues found!`

### Step 6: Commit

```bash
git add lib/features/workout/presentation/providers/workout_provider.dart test/features/workout/presentation/providers/workout_provider_test.dart
git commit -m "feat(routine): add recentWorkoutsProvider for last N days

- Add FutureProvider.family for flexible day range
- Filter workouts by startTime > cutoff date
- Handle repository failures with exception
- Add comprehensive unit tests (3 test cases)

Part of workout selector feature for manual routine completion."
```

---

## Task 2: Create WorkoutSelectorCard widget

**Files:**
- Create: `lib/features/routine/presentation/widgets/workout_selector_card.dart`
- Test: `test/features/routine/presentation/widgets/workout_selector_card_test.dart`

### Step 1: Write the failing test

```dart
// test/features/routine/presentation/widgets/workout_selector_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

void main() {
  group('WorkoutSelectorCard', () {
    final mockWorkout = Workout(
      id: 'workout-1',
      userId: 'user-1',
      name: 'Giorno A',
      startTime: DateTime(2025, 1, 5, 14, 30),
      endTime: DateTime(2025, 1, 5, 15, 15),
      exercises: List.filled(8, null), // 8 exercises
      totalDuration: Duration(minutes: 45),
      notes: null,
      templateId: 'giorno-a',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('displays workout name and metadata', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSelectorCard(
              workout: mockWorkout,
              isTemplateMatch: false,
              isAlreadyLinked: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Giorno A'), findsOneWidget);
      expect(find.textContaining('45min'), findsOneWidget);
      expect(find.textContaining('8 exercises'), findsOneWidget);
    });

    testWidgets('shows match badge when isTemplateMatch is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSelectorCard(
              workout: mockWorkout,
              isTemplateMatch: true,
              isAlreadyLinked: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Match'), findsOneWidget);
      // Check for green badge styling
      final badgeFinder = find.ancestor(
        of: find.text('Match'),
        matching: find.byType(Container),
      );
      expect(badgeFinder, findsOneWidget);
    });

    testWidgets('shows linked warning when isAlreadyLinked is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSelectorCard(
              workout: mockWorkout,
              isTemplateMatch: false,
              isAlreadyLinked: true,
              linkedDate: DateTime(2025, 1, 3),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Linked to'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSelectorCard(
              workout: mockWorkout,
              isTemplateMatch: false,
              isAlreadyLinked: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WorkoutSelectorCard));
      expect(tapped, true);
    });

    testWidgets('applies highlight styling when isTemplateMatch is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkoutSelectorCard(
              workout: mockWorkout,
              isTemplateMatch: true,
              isAlreadyLinked: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the card Container
      final cardContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Giorno A'),
          matching: find.byType(Container),
        ).first,
      );

      // Verify decoration has border
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
```

### Step 2: Run test to verify it fails

```bash
flutter test test/features/routine/presentation/widgets/workout_selector_card_test.dart
```

**Expected Output**:
```
FAIL - WorkoutSelectorCard not defined
Error: lib/features/routine/presentation/widgets/workout_selector_card.dart doesn't exist
```

### Step 3: Write minimal implementation

```dart
// lib/features/routine/presentation/widgets/workout_selector_card.dart

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: routine_center
/// 🔧 Type: widget
/// 🌍 Localization: YES
/// 🎨 Theme: YES
/// 📱 Platform: Universal
///
/// WORKOUT SELECTOR CARD - Display individual workout for selection
///
/// Visual Design:
/// ┌─────────────────────────────────────────┐
/// │ 🏋️ Giorno A              [✅ Match]     │
/// │ Today 14:30 • 45min • 8 exercises       │
/// └─────────────────────────────────────────┘
///
/// Features:
/// - Template match badge (green)
/// - Already linked warning (orange)
/// - Haptic feedback on tap
/// - Highlight styling for matches

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

class WorkoutSelectorCard extends StatelessWidget {
  const WorkoutSelectorCard({
    super.key,
    required this.workout,
    required this.isTemplateMatch,
    required this.isAlreadyLinked,
    this.linkedDate,
    required this.onTap,
  });

  final Workout workout;
  final bool isTemplateMatch;
  final bool isAlreadyLinked;
  final DateTime? linkedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isTemplateMatch
              ? context.colors.primaryContainer
              : context.colors.surfaceContainerHighest,
          border: isTemplateMatch
              ? Border.all(color: context.colors.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading: Workout icon
            Icon(
              AppIcons.workout,
              size: AppIconSize.large,
              color: context.colors.primary,
            ),
            const SizedBox(width: 16),

            // Content: Name + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name ?? 'Unnamed Workout',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildMetadataText(context),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing: Badge (match or linked warning)
            if (isTemplateMatch) _buildMatchBadge(context),
            if (isAlreadyLinked) _buildLinkedBadge(context),
          ],
        ),
      ),
    );
  }

  String _buildMetadataText(BuildContext context) {
    final parts = <String>[];

    // Date/time
    if (workout.startTime != null) {
      final now = DateTime.now();
      final workoutDate = workout.startTime!;
      final difference = now.difference(workoutDate).inDays;

      if (difference == 0) {
        parts.add('${context.l10n.today} ${DateFormat.Hm(context.currentLocale.languageCode).format(workoutDate)}');
      } else if (difference == 1) {
        parts.add('${context.l10n.yesterday} ${DateFormat.Hm(context.currentLocale.languageCode).format(workoutDate)}');
      } else {
        parts.add('${difference} ${context.l10n.daysAgo}');
      }
    }

    // Duration
    if (workout.totalDuration != null) {
      parts.add('${workout.totalDuration!.inMinutes}min');
    }

    // Exercise count
    final exerciseCount = workout.exercises.length;
    parts.add('$exerciseCount ${exerciseCount == 1 ? context.l10n.exercise : context.l10n.exercises}');

    return parts.join(' • ');
  }

  Widget _buildMatchBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.successContainer,
        border: Border.all(color: context.colors.success),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.checkCircle,
            size: AppIconSize.small,
            color: context.colors.success,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.match,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.warningContainer,
        border: Border.all(color: context.colors.warning),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.warning,
            size: AppIconSize.small,
            color: context.colors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '${context.l10n.linkedTo} ${linkedDate != null ? DateFormat.MMMd(context.currentLocale.languageCode).format(linkedDate!) : ''}',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Add missing localization keys

```bash
# Check if keys exist
grep "match" assets/i18n/app_en.arb
grep "linkedTo" assets/i18n/app_en.arb
grep "daysAgo" assets/i18n/app_en.arb
```

If missing, add to `assets/i18n/app_en.arb`:
```json
"match": "Match",
"linkedTo": "Linked to",
"daysAgo": "days ago"
```

And to `assets/i18n/app_it.arb`:
```json
"match": "Corrispondenza",
"linkedTo": "Collegato a",
"daysAgo": "giorni fa"
```

Then regenerate:
```bash
flutter gen-l10n
```

### Step 5: Run test to verify it passes

```bash
flutter test test/features/routine/presentation/widgets/workout_selector_card_test.dart
```

**Expected Output**:
```
✓ displays workout name and metadata
✓ shows match badge when isTemplateMatch is true
✓ shows linked warning when isAlreadyLinked is true
✓ calls onTap when card is tapped
✓ applies highlight styling when isTemplateMatch is true

All tests passed!
```

### Step 6: Verify flutter analyze passes

```bash
flutter analyze lib/features/routine/presentation/widgets/workout_selector_card.dart
```

**Expected Output**: `No issues found!`

### Step 7: Commit

```bash
git add lib/features/routine/presentation/widgets/workout_selector_card.dart test/features/routine/presentation/widgets/workout_selector_card_test.dart assets/i18n/*.arb lib/shared/presentation/l10n/generated/*
git commit -m "feat(routine): add WorkoutSelectorCard widget

- Display workout with name, metadata (date, duration, exercise count)
- Show green 'Match' badge for template matches
- Show orange 'Linked to' warning for already-linked workouts
- Haptic feedback on tap
- Highlight styling with primary color border for matches
- Localized date formatting (Today/Yesterday/X days ago)
- Add l10n keys: match, linkedTo, daysAgo (EN + IT)

Part of workout selector feature for manual routine completion."
```

---

## Task 3: Create WorkoutSelectorSheet widget

**Files:**
- Create: `lib/features/routine/presentation/widgets/workout_selector_sheet.dart`
- Test: `test/features/routine/presentation/widgets/workout_selector_sheet_test.dart`

### Step 1: Write the failing test

```dart
// test/features/routine/presentation/widgets/workout_selector_sheet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_sheet.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

void main() {
  group('WorkoutSelectorSheet', () {
    final mockRoutine = FlexibleRoutine(
      id: 'routine-1',
      userId: 'user-1',
      name: 'Winter Arc',
      schedule: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockWorkouts = [
      Workout(
        id: 'workout-1',
        userId: 'user-1',
        name: 'Giorno A',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(minutes: 45)),
        exercises: [],
        totalDuration: Duration(minutes: 45),
        notes: null,
        templateId: 'giorno-a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Workout(
        id: 'workout-2',
        userId: 'user-1',
        name: 'Giorno B',
        startTime: DateTime.now().subtract(Duration(days: 1)),
        endTime: DateTime.now().subtract(Duration(days: 1)).add(Duration(minutes: 50)),
        exercises: [],
        totalDuration: Duration(minutes: 50),
        notes: null,
        templateId: 'giorno-b',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('shows workout list when data loaded', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Complete Day with Workout'), findsOneWidget);

      // Verify workout cards
      expect(find.byType(WorkoutSelectorCard), findsNWidgets(2));
    });

    testWidgets('shows empty state when no workouts', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => []),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No recent workouts found'), findsOneWidget);
      expect(find.text('Complete Day'), findsOneWidget);
    });

    testWidgets('highlights template match', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a', // Matches first workout
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all WorkoutSelectorCard widgets
      final cards = tester.widgetList<WorkoutSelectorCard>(
        find.byType(WorkoutSelectorCard),
      ).toList();

      // First card should be a match
      expect(cards[0].isTemplateMatch, true);
      // Second card should not be a match
      expect(cards[1].isTemplateMatch, false);
    });

    testWidgets('calls onWorkoutSelected when card tapped', (tester) async {
      String? selectedWorkoutId;

      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (workoutId) async {
                  selectedWorkoutId = workoutId;
                },
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap first workout card
      await tester.tap(find.byType(WorkoutSelectorCard).first);
      await tester.pumpAndSettle();

      expect(selectedWorkoutId, 'workout-1');
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith(
            (_) => Future.delayed(Duration(seconds: 5), () => mockWorkouts),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state on fetch failure', (tester) async {
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith(
            (_) => Future.error(Exception('Network error')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load workouts'), findsOneWidget);
    });

    testWidgets('shows fallback button', (tester) async {
      bool completedWithoutWorkout = false;

      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => mockWorkouts),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(
                routine: mockRoutine,
                date: DateTime(2025, 1, 5),
                templateId: 'giorno-a',
                onWorkoutSelected: (_) async {},
                onCompleteWithoutWorkout: () async {
                  completedWithoutWorkout = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap fallback button
      await tester.tap(find.text('Complete without workout'));
      await tester.pumpAndSettle();

      expect(completedWithoutWorkout, true);
    });
  });
}
```

### Step 2: Run test to verify it fails

```bash
flutter test test/features/routine/presentation/widgets/workout_selector_sheet_test.dart
```

**Expected Output**:
```
FAIL - WorkoutSelectorSheet not defined
Error: lib/features/routine/presentation/widgets/workout_selector_sheet.dart doesn't exist
```

### Step 3: Write minimal implementation

```dart
// lib/features/routine/presentation/widgets/workout_selector_sheet.dart

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: routine_center
/// 🔧 Type: widget
/// 🌍 Localization: YES
/// 🎨 Theme: YES
/// 📱 Platform: Universal
///
/// WORKOUT SELECTOR SHEET - Bottom sheet for manual routine day completion
///
/// Structure:
/// DraggableScrollableSheet (70% height)
/// ├─ Handle bar (drag indicator)
/// ├─ Header: "Complete Day with Workout"
/// ├─ Subtitle: "Select a workout to link to [date]"
/// ├─ Divider
/// ├─ WorkoutList (ScrollView)
/// │  └─ recentWorkoutsProvider(7 days)
/// │      └─ ListView.builder → WorkoutSelectorCard
/// ├─ Divider
/// └─ TextButton: "Complete without workout"
///
/// Features:
/// - Fetch recent workouts (last 7 days)
/// - Highlight template matches
/// - Empty state handling
/// - Loading indicator
/// - Error state handling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class WorkoutSelectorSheet extends ConsumerWidget {
  const WorkoutSelectorSheet({
    super.key,
    required this.routine,
    required this.date,
    this.templateId,
    required this.onWorkoutSelected,
    required this.onCompleteWithoutWorkout,
  });

  final FlexibleRoutine routine;
  final DateTime date;
  final String? templateId;
  final Future<void> Function(String workoutId) onWorkoutSelected;
  final Future<void> Function() onCompleteWithoutWorkout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.completeDayWithWorkout,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${context.l10n.selectWorkoutToLinkTo} ${DateFormat.yMMMd(context.currentLocale.languageCode).format(date)}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: context.colors.outlineVariant),

              // Workout list
              Expanded(
                child: _buildWorkoutList(context, ref, scrollController),
              ),

              // Fallback button
              Divider(height: 1, color: context.colors.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => onCompleteWithoutWorkout(),
                  child: Text(context.l10n.completeWithoutWorkout),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutList(
    BuildContext context,
    WidgetRef ref,
    ScrollController scrollController,
  ) {
    final workoutsAsync = ref.watch(recentWorkoutsProvider(7));

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final isMatch = _isTemplateMatch(workout.templateId);
            final isLinked = false; // TODO: Check if already linked

            return WorkoutSelectorCard(
              workout: workout,
              isTemplateMatch: isMatch,
              isAlreadyLinked: isLinked,
              onTap: () => onWorkoutSelected(workout.id),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  bool _isTemplateMatch(String? workoutTemplateId) {
    if (templateId == null || workoutTemplateId == null) return false;
    return workoutTemplateId.toLowerCase() == templateId.toLowerCase();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.workout,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noRecentWorkoutsFound,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.completeDayWithoutWorkout,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => onCompleteWithoutWorkout(),
              child: Text(context.l10n.completeDay),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: AppIconSize.xxlarge,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.failedToLoadWorkouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 4: Add missing localization keys

Add to `assets/i18n/app_en.arb`:
```json
"completeDayWithWorkout": "Complete Day with Workout",
"selectWorkoutToLinkTo": "Select workout to link to",
"completeWithoutWorkout": "Complete without workout",
"noRecentWorkoutsFound": "No recent workouts found",
"completeDayWithoutWorkout": "Complete this day without linking a workout",
"completeDay": "Complete Day",
"failedToLoadWorkouts": "Failed to load workouts"
```

Add to `assets/i18n/app_it.arb`:
```json
"completeDayWithWorkout": "Completa Giorno con Workout",
"selectWorkoutToLinkTo": "Seleziona workout da collegare a",
"completeWithoutWorkout": "Completa senza workout",
"noRecentWorkoutsFound": "Nessun workout recente trovato",
"completeDayWithoutWorkout": "Completa questo giorno senza collegare un workout",
"completeDay": "Completa Giorno",
"failedToLoadWorkouts": "Impossibile caricare i workout"
```

Regenerate:
```bash
flutter gen-l10n
```

### Step 5: Run test to verify it passes

```bash
flutter test test/features/routine/presentation/widgets/workout_selector_sheet_test.dart
```

**Expected Output**:
```
✓ shows workout list when data loaded
✓ shows empty state when no workouts
✓ highlights template match
✓ calls onWorkoutSelected when card tapped
✓ shows loading indicator while fetching
✓ shows error state on fetch failure
✓ shows fallback button

All tests passed!
```

### Step 6: Verify flutter analyze passes

```bash
flutter analyze lib/features/routine/presentation/widgets/workout_selector_sheet.dart
```

**Expected Output**: `No issues found!`

### Step 7: Commit

```bash
git add lib/features/routine/presentation/widgets/workout_selector_sheet.dart test/features/routine/presentation/widgets/workout_selector_sheet_test.dart assets/i18n/*.arb lib/shared/presentation/l10n/generated/*
git commit -m "feat(routine): add WorkoutSelectorSheet bottom sheet

- DraggableScrollableSheet with 70% initial height
- Fetch last 7 days workouts via recentWorkoutsProvider
- Display workouts with WorkoutSelectorCard
- Highlight template matches (case-insensitive)
- Empty state with 'Complete Day' fallback
- Loading indicator while fetching
- Error state with error message display
- Fallback 'Complete without workout' button
- Localized date formatting in subtitle
- Add 7 l10n keys (EN + IT)

Part of workout selector feature for manual routine completion."
```

---

## Task 4: Integrate WorkoutSelectorSheet into DayDetailSheet

**Files:**
- Modify: `lib/features/routine/presentation/widgets/day_detail_sheet.dart`
- Test: `test/features/routine/presentation/widgets/day_detail_sheet_test.dart`

### Step 1: Write the failing test

```dart
// test/features/routine/presentation/widgets/day_detail_sheet_test.dart

// Add to existing test file
testWidgets('Complete button opens WorkoutSelectorSheet', (tester) async {
  final mockRoutine = FlexibleRoutine(
    id: 'routine-1',
    userId: 'user-1',
    name: 'Winter Arc',
    schedule: {
      DateTime(2025, 1, 5): ScheduledDay(
        date: DateTime(2025, 1, 5),
        status: DayStatus.scheduled,
        templateId: 'giorno-a',
      ),
    },
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final container = ProviderContainer(
    overrides: [
      flexibleRoutineNotifierProvider.overrideWith(
        () => MockFlexibleRoutineNotifier(),
      ),
      recentWorkoutsProvider(7).overrideWith((_) async => []),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: DayDetailSheet(
            routine: mockRoutine,
            date: DateTime(2025, 1, 5),
            dayInfo: mockRoutine.schedule[DateTime(2025, 1, 5)]!,
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Find and tap Complete button
  final completeButton = find.text('Complete');
  expect(completeButton, findsOneWidget);

  await tester.tap(completeButton);
  await tester.pumpAndSettle();

  // Verify WorkoutSelectorSheet is visible
  expect(find.byType(WorkoutSelectorSheet), findsOneWidget);
  expect(find.text('Complete Day with Workout'), findsOneWidget);
});

testWidgets('WorkoutSelectorSheet completion with workout calls completeDayWorkout', (tester) async {
  // Test that selecting a workout calls the correct notifier method
  bool calledCompleteDayWorkout = false;
  String? capturedWorkoutId;

  final mockNotifier = MockFlexibleRoutineNotifier();
  when(mockNotifier.completeDayWorkout(
    routineId: anyNamed('routineId'),
    date: anyNamed('date'),
    workoutId: anyNamed('workoutId'),
  )).thenAnswer((invocation) async {
    calledCompleteDayWorkout = true;
    capturedWorkoutId = invocation.namedArguments[#workoutId] as String;
    return true;
  });

  final mockRoutine = FlexibleRoutine(
    id: 'routine-1',
    userId: 'user-1',
    name: 'Winter Arc',
    schedule: {
      DateTime(2025, 1, 5): ScheduledDay(
        date: DateTime(2025, 1, 5),
        status: DayStatus.scheduled,
        templateId: 'giorno-a',
      ),
    },
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final mockWorkout = Workout(
    id: 'workout-1',
    userId: 'user-1',
    name: 'Giorno A',
    startTime: DateTime.now(),
    endTime: DateTime.now().add(Duration(minutes: 45)),
    exercises: [],
    totalDuration: Duration(minutes: 45),
    notes: null,
    templateId: 'giorno-a',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final container = ProviderContainer(
    overrides: [
      flexibleRoutineNotifierProvider.overrideWith(() => mockNotifier),
      recentWorkoutsProvider(7).overrideWith((_) async => [mockWorkout]),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: DayDetailSheet(
            routine: mockRoutine,
            date: DateTime(2025, 1, 5),
            dayInfo: mockRoutine.schedule[DateTime(2025, 1, 5)]!,
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // Tap Complete button
  await tester.tap(find.text('Complete'));
  await tester.pumpAndSettle();

  // Verify sheet opened
  expect(find.byType(WorkoutSelectorSheet), findsOneWidget);

  // Tap first workout card
  await tester.tap(find.byType(WorkoutSelectorCard).first);
  await tester.pumpAndSettle();

  // Verify completeDayWorkout was called
  expect(calledCompleteDayWorkout, true);
  expect(capturedWorkoutId, 'workout-1');

  // Verify success snackbar
  expect(find.text('Day completed with workout!'), findsOneWidget);
});
```

### Step 2: Run test to verify it fails

```bash
flutter test test/features/routine/presentation/widgets/day_detail_sheet_test.dart --name "Complete button"
```

**Expected Output**:
```
FAIL - Expected WorkoutSelectorSheet to open, but found confirm dialog instead
```

### Step 3: Modify DayDetailSheet._completeDay() method

```dart
// lib/features/routine/presentation/widgets/day_detail_sheet.dart

// Add import at top
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_sheet.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/workout_event_tracker.dart';

// REPLACE the existing _completeDay() method (around line 872-895)
// OLD method has confirm dialog, NEW method shows WorkoutSelectorSheet

Future<void> _completeDay(BuildContext context) async {
  // Show workout selector sheet
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WorkoutSelectorSheet(
      routine: widget.routine,
      date: widget.date,
      templateId: widget.dayInfo.templateId,

      // Callback: Complete with workout
      onWorkoutSelected: (workoutId) async {
        final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
        final success = await notifier.completeDayWorkout(
          routineId: widget.routine.id,
          date: widget.date,
          workoutId: workoutId,
        );

        if (context.mounted) {
          if (success) {
            Navigator.pop(context); // Close selector
            Navigator.pop(context); // Close day detail
            SnackBarService.showSuccess(
              context,
              context.l10n.dayCompletedWithWorkout,
            );

            // Analytics
            WorkoutEventTracker.trackRoutineDayCompleted(
              routineId: widget.routine.id,
              date: widget.date,
              method: 'manual_with_workout',
              workoutId: workoutId,
            );
          } else {
            SnackBarService.showError(
              context,
              context.l10n.failedToCompleteDay,
            );
          }
        }
      },

      // Callback: Complete without workout (fallback)
      onCompleteWithoutWorkout: () async {
        final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
        final success = await notifier.completeDayManual(
          routineId: widget.routine.id,
          date: widget.date,
        );

        if (context.mounted) {
          if (success) {
            Navigator.pop(context); // Close selector
            Navigator.pop(context); // Close day detail
            SnackBarService.showSuccess(
              context,
              context.l10n.dayCompletedManually,
            );

            // Analytics
            WorkoutEventTracker.trackRoutineDayCompleted(
              routineId: widget.routine.id,
              date: widget.date,
              method: 'manual_without_workout',
            );
          } else {
            SnackBarService.showError(
              context,
              context.l10n.failedToCompleteDay,
            );
          }
        }
      },
    ),
  );
}
```

### Step 4: Add missing localization keys

Add to `assets/i18n/app_en.arb`:
```json
"dayCompletedWithWorkout": "Day completed with workout!",
"dayCompletedManually": "Day completed manually",
"failedToCompleteDay": "Failed to complete day"
```

Add to `assets/i18n/app_it.arb`:
```json
"dayCompletedWithWorkout": "Giorno completato con workout!",
"dayCompletedManually": "Giorno completato manualmente",
"failedToCompleteDay": "Impossibile completare il giorno"
```

Regenerate:
```bash
flutter gen-l10n
```

### Step 5: Add trackRoutineDayCompleted to WorkoutEventTracker

Check if method exists:
```bash
grep "trackRoutineDayCompleted" lib/core/analytics/trackers/workout_event_tracker.dart
```

If not found, add to `lib/core/analytics/trackers/workout_event_tracker.dart`:

```dart
/// Track manual routine day completion
static void trackRoutineDayCompleted({
  required String routineId,
  required DateTime date,
  required String method, // 'manual_with_workout' | 'manual_without_workout'
  String? workoutId,
}) {
  FirebaseAnalytics.instance.logEvent(
    name: 'routine_day_completed',
    parameters: {
      'routine_id': routineId,
      'date': date.toIso8601String(),
      'completion_method': method,
      'workout_id': workoutId ?? 'none',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

### Step 6: Run test to verify it passes

```bash
flutter test test/features/routine/presentation/widgets/day_detail_sheet_test.dart --name "Complete button"
```

**Expected Output**:
```
✓ Complete button opens WorkoutSelectorSheet
✓ WorkoutSelectorSheet completion with workout calls completeDayWorkout

All tests passed!
```

### Step 7: Verify flutter analyze passes

```bash
flutter analyze lib/features/routine/presentation/widgets/day_detail_sheet.dart
flutter analyze lib/core/analytics/trackers/workout_event_tracker.dart
```

**Expected Output**: `No issues found!`

### Step 8: Commit

```bash
git add lib/features/routine/presentation/widgets/day_detail_sheet.dart lib/core/analytics/trackers/workout_event_tracker.dart assets/i18n/*.arb lib/shared/presentation/l10n/generated/* test/features/routine/presentation/widgets/day_detail_sheet_test.dart
git commit -m "feat(routine): integrate WorkoutSelectorSheet into day completion

- Replace confirm dialog with WorkoutSelectorSheet
- onWorkoutSelected → completeDayWorkout(workoutId)
- onCompleteWithoutWorkout → completeDayManual()
- Close both sheets on success
- Show success SnackBar with context-specific message
- Track completion method in Firebase Analytics
- Add trackRoutineDayCompleted analytics method
- Add 3 l10n keys (EN + IT)
- Add widget tests for integration

Completes workout selector feature for manual routine completion."
```

---

## Task 5: Manual Testing & Verification

**No automated tests for this task - manual verification required**

### Step 1: Run the app in debug mode

```bash
flutter run --debug
```

### Step 2: Navigate to Routine Center

1. Open app
2. Tap bottom nav bar → Routine Center
3. Verify active routine is visible

### Step 3: Test Happy Path - Complete with Workout Match

1. Tap active routine card
2. Tap a scheduled day (status: scheduled)
3. Verify DayDetailSheet opens
4. Tap "Complete" button
5. ✅ **Verify**: WorkoutSelectorSheet opens (70% height)
6. ✅ **Verify**: Header shows "Complete Day with Workout"
7. ✅ **Verify**: Subtitle shows selected date
8. ✅ **Verify**: Recent workouts list appears (if any recent workouts exist)
9. ✅ **Verify**: Template match has green "Match" badge
10. Tap a workout card with "Match" badge
11. ✅ **Verify**: Haptic feedback occurs
12. ✅ **Verify**: Both sheets close
13. ✅ **Verify**: Success SnackBar: "Day completed with workout!"
14. ✅ **Verify**: Routine calendar updates (day shows ✓ completed)

### Step 4: Test Empty State

1. Navigate to routine day selection
2. Complete a day when no workouts exist (or set device date to far future)
3. ✅ **Verify**: Empty state appears with:
   - Grey dumbbell icon
   - "No recent workouts found" title
   - "Complete this day without linking a workout" subtitle
   - "Complete Day" button
4. Tap "Complete Day" button
5. ✅ **Verify**: Day completes without workout link
6. ✅ **Verify**: Success SnackBar: "Day completed manually"

### Step 5: Test Fallback - Complete Without Workout

1. Navigate to routine day selection
2. Tap "Complete" button
3. WorkoutSelectorSheet opens with workouts
4. Scroll to bottom
5. Tap "Complete without workout" button
6. ✅ **Verify**: Both sheets close
7. ✅ **Verify**: Success SnackBar: "Day completed manually"
8. ✅ **Verify**: Day marked completed (no workout link)

### Step 6: Test Template Mismatch

1. Complete a workout with template "Giorno A"
2. Navigate to routine day scheduled for "Giorno B"
3. Tap "Complete" → WorkoutSelectorSheet opens
4. ✅ **Verify**: "Giorno A" workout does NOT have "Match" badge
5. ✅ **Verify**: "Giorno B" workout (if exists) HAS "Match" badge
6. Tap "Giorno A" (non-matching workout)
7. ✅ **Verify**: Completion works (no confirmation dialog needed for MVP)

### Step 7: Test Dark Mode

1. Go to Settings → Theme
2. Switch to Dark mode
3. Repeat Step 3 (Happy Path)
4. ✅ **Verify**: All UI elements readable and properly styled in dark theme

### Step 8: Test Italian Localization

1. Go to Settings → Language
2. Switch to Italian
3. Repeat Step 3 (Happy Path)
4. ✅ **Verify**: All text is in Italian:
   - "Completa Giorno con Workout"
   - "Seleziona workout da collegare a"
   - "Completa senza workout"
   - "Giorno completato con workout!"

### Step 9: Check Firebase Analytics

1. Complete a day with workout
2. Open Firebase Console → Analytics → Events
3. ✅ **Verify**: Event `routine_day_completed` logged with:
   - `routine_id`: correct routine ID
   - `date`: selected date ISO string
   - `completion_method`: "manual_with_workout"
   - `workout_id`: selected workout ID
4. Complete a day without workout
5. ✅ **Verify**: Same event with `completion_method`: "manual_without_workout"

### Step 10: Check Edge Cases

**Error State (Simulate Network Failure)**:
1. Turn off WiFi/Cellular
2. Try opening WorkoutSelectorSheet
3. ✅ **Verify**: Error state appears:
   - Red error icon
   - "Failed to load workouts" title
   - Error message text

**Loading State**:
1. Add artificial delay to recentWorkoutsProvider (in dev only)
2. Tap "Complete" button
3. ✅ **Verify**: LoadingIndicator appears while fetching

### Step 11: Record Manual Test Results

Create file: `test/manual/workout_selector_manual_test_results.md`

```markdown
# Workout Selector Manual Test Results

**Date**: 2025-01-05
**Tester**: [Your Name]
**Device**: [iPhone 14 Pro / Pixel 8 / etc]
**OS Version**: [iOS 17.2 / Android 14 / etc]

## Test Results

| Test Case | Result | Notes |
|-----------|--------|-------|
| Happy Path - Match | ✅ Pass | Badge shows, completion works |
| Empty State | ✅ Pass | Proper fallback UI |
| Complete Without Workout | ✅ Pass | Fallback works |
| Template Mismatch | ✅ Pass | No match badge for wrong template |
| Dark Mode | ✅ Pass | All UI readable |
| Italian Localization | ✅ Pass | All text translated |
| Firebase Analytics | ✅ Pass | Events logged correctly |
| Error State | ✅ Pass | Error UI shown on network failure |
| Loading State | ✅ Pass | LoadingIndicator appears |

## Issues Found
- [List any issues discovered]

## Screenshots
- [Attach screenshots if needed]
```

### Step 12: Commit manual test results

```bash
git add test/manual/workout_selector_manual_test_results.md
git commit -m "docs(routine): add manual test results for workout selector

Verified:
- Happy path with template match
- Empty state fallback
- Complete without workout fallback
- Template mismatch handling
- Dark mode styling
- Italian localization
- Firebase Analytics tracking
- Error state handling
- Loading state UI

All test cases passed on [device/OS]."
```

---

## Post-Implementation Checklist

After all tasks complete, verify the following:

- [ ] ✅ `flutter analyze` passes with 0 errors on all modified files
- [ ] ✅ All unit tests pass: `flutter test`
- [ ] ✅ No hardcoded strings (all use `context.l10n.*`)
- [ ] ✅ No hardcoded colors (all use `context.colors.*`)
- [ ] ✅ No hardcoded icon sizes (all use `AppIconSize.*`)
- [ ] ✅ Dark mode tested and works correctly
- [ ] ✅ Italian localization tested and works correctly
- [ ] ✅ Firebase Analytics events verified in Firebase Console
- [ ] ✅ All manual test cases passed
- [ ] ✅ Git history clean with descriptive commit messages

---

## Summary

**5 Tasks Completed**:
1. ✅ Created `recentWorkoutsProvider` with 3 unit tests
2. ✅ Created `WorkoutSelectorCard` widget with 5 widget tests
3. ✅ Created `WorkoutSelectorSheet` bottom sheet with 7 widget tests
4. ✅ Integrated into `DayDetailSheet` with 2 integration tests
5. ✅ Manual testing & verification (11 test scenarios)

**Total Time Estimate**: 6-9 hours

**Files Created** (3):
- `lib/features/routine/presentation/widgets/workout_selector_sheet.dart`
- `lib/features/routine/presentation/widgets/workout_selector_card.dart`
- `test/manual/workout_selector_manual_test_results.md`

**Files Modified** (3):
- `lib/features/workout/presentation/providers/workout_provider.dart` (added provider)
- `lib/features/routine/presentation/widgets/day_detail_sheet.dart` (replaced _completeDay)
- `lib/core/analytics/trackers/workout_event_tracker.dart` (added tracking method)

**Localization Keys Added** (13 total):
- EN: match, linkedTo, daysAgo, completeDayWithWorkout, selectWorkoutToLinkTo, completeWithoutWorkout, noRecentWorkoutsFound, completeDayWithoutWorkout, completeDay, failedToLoadWorkouts, dayCompletedWithWorkout, dayCompletedManually, failedToCompleteDay
- IT: [Italian translations for all above keys]

**Tests Added** (17 total):
- 3 unit tests (recentWorkoutsProvider)
- 5 widget tests (WorkoutSelectorCard)
- 7 widget tests (WorkoutSelectorSheet)
- 2 integration tests (DayDetailSheet)

**Commits**: 5 (one per task)

---

## Next Steps

After completing this plan:

1. Merge feature branch to main
2. Test on production-like data
3. Monitor Firebase Analytics for usage patterns
4. Iterate based on user feedback

**Future Enhancements** (Not in this plan):
- Show confirmation dialog for template mismatch
- Check if workout already linked to another day (show warning badge)
- Support "Start Workout" from selector (pre-fill template)
- Add "Recent Templates" filter toggle
- Cache recent workouts locally for offline use
