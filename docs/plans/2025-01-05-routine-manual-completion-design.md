# Routine Manual Completion with Workout Selector - Design Document

**Date**: 2025-01-05
**Feature**: Routine Center - Manual Day Completion
**Status**: Design Complete - Ready for Implementation
**Author**: Claude Code (with Michele)

---

## 📋 Problem Statement

### Current Behavior
When a user completes a workout but the system's auto-completion doesn't recognize it (e.g., due to template name mismatch like "giorno a" vs "Giorno A"), the user cannot manually link that workout to the routine day.

**Current limitation**:
- User taps a scheduled day in routine → Opens `DayDetailSheet`
- User taps "Complete" button → Calls `completeDayManual()` (no `workoutId`)
- Day is marked completed BUT **not linked** to any workout in history
- No way to retroactively link a workout to a routine day

### User Pain Point
> "Ho fatto il workout ma il sistema non l'ha riconosciuto. Ora voglio completare manualmente il giorno della routine collegandolo a quel workout specifico."

---

## 🎯 Solution Overview

**Add workout selector when manually completing a routine day**:
1. User taps "Complete" button on a scheduled day
2. App shows `WorkoutSelectorSheet` with recent workouts (last 7 days)
3. User selects specific workout → Day completed with `workoutId` link
4. Fallback: "Complete without workout" option (current behavior)

**Benefits**:
- ✅ User can manually link workouts to routine days
- ✅ Fixes template mismatch issues retroactively
- ✅ Preserves existing manual completion option
- ✅ Intuitive UX: one tap to select workout

---

## 🏗️ Architecture & Components

### New Components

#### 1. `WorkoutSelectorSheet` Widget
**File**: `lib/features/routine/presentation/widgets/workout_selector_sheet.dart`

**Purpose**: Bottom sheet displaying recent workouts for selection

**Props**:
```dart
class WorkoutSelectorSheet extends ConsumerWidget {
  final FlexibleRoutine routine;
  final DateTime date;
  final String? templateId; // For highlighting matches
  final Future<void> Function(String workoutId) onWorkoutSelected;
  final Future<void> Function() onCompleteWithoutWorkout;
}
```

**Structure**:
```
DraggableScrollableSheet (70% height)
├─ Handle bar (drag indicator)
├─ Header: "Complete Day with Workout"
├─ Subtitle: "Select a workout to link to [date]"
├─ Divider
├─ WorkoutList (ScrollView)
│  └─ recentWorkoutsProvider(7 days)
│      └─ ListView.builder
│          └─ WorkoutSelectorCard
│              ├─ Leading: Workout icon
│              ├─ Title: Workout name
│              ├─ Subtitle: Date, time, duration, exercises
│              ├─ Trailing: Match badge (if template matches)
│              └─ onTap: onWorkoutSelected(workout.id)
├─ Divider
└─ TextButton: "Complete without workout"
```

---

#### 2. `WorkoutSelectorCard` Widget
**File**: `lib/features/routine/presentation/widgets/workout_selector_card.dart`

**Purpose**: Display individual workout with metadata and match indicator

**Visual Design**:
```
┌─────────────────────────────────────────┐
│ 🏋️ Giorno A              [✅ Match]     │
│ Today 14:30 • 45min • 8 exercises       │
└─────────────────────────────────────────┘
```

**Props**:
```dart
class WorkoutSelectorCard extends StatelessWidget {
  final Workout workout;
  final bool isTemplateMatch;
  final bool isAlreadyLinked;
  final DateTime? linkedDate;
  final VoidCallback onTap;
}
```

**Match Logic**:
- `isTemplateMatch = workout.name.toLowerCase() == templateId?.toLowerCase()`
- If true → Show "✅ Match" badge + highlight with primary color border
- If already linked → Show "⚠️ Linked to [date]" badge

**Tap Behavior**:
- Haptic feedback (`HapticFeedback.mediumImpact()`)
- If not template match → Show confirmation dialog
- Then call `onTap()` callback

---

#### 3. `recentWorkoutsProvider` Provider
**File**: `lib/features/workout/presentation/providers/workout_provider.dart`

**Purpose**: Fetch workouts from last N days

```dart
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

**Usage**: `ref.watch(recentWorkoutsProvider(7))` → Last 7 days

---

### Modified Components

#### `DayDetailSheet` Changes
**File**: `lib/features/routine/presentation/widgets/day_detail_sheet.dart`

**Modified Method**: `_completeDay()`

**BEFORE** (current):
```dart
Future<void> _completeDay(BuildContext context) async {
  final confirmed = await ModalService.showConfirmDialog(
    context,
    title: 'Complete Day',
    message: 'Mark this day as completed without starting a workout?',
    confirmText: 'Complete',
  );

  if (!confirmed || !context.mounted) return;

  final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
  final success = await notifier.completeDayManual(
    routineId: widget.routine.id,
    date: widget.date,
  );

  if (context.mounted) {
    if (success) {
      Navigator.pop(context);
      SnackBarService.showSuccess(context, 'Day marked as completed');
    } else {
      SnackBarService.showError(context, 'Failed to complete day');
    }
  }
}
```

**AFTER** (new):
```dart
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
            SnackBarService.showSuccess(context, 'Day completed with workout!');

            // Optional analytics
            WorkoutEventTracker.trackRoutineDayCompleted(
              routineId: widget.routine.id,
              date: widget.date,
              method: 'manual_with_workout',
              workoutId: workoutId,
            );
          } else {
            SnackBarService.showError(context, 'Failed to complete day');
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
            SnackBarService.showSuccess(context, 'Day completed manually');

            // Optional analytics
            WorkoutEventTracker.trackRoutineDayCompleted(
              routineId: widget.routine.id,
              date: widget.date,
              method: 'manual_without_workout',
            );
          } else {
            SnackBarService.showError(context, 'Failed to complete day');
          }
        }
      },
    ),
  );
}
```

**Import Added**:
```dart
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_sheet.dart';
```

---

## 🔄 User Flow

### Happy Path: Complete with Workout Match

```
1. User opens Routine Center
   ↓
2. User taps active routine card → RoutineDetailScreen
   ↓
3. User taps scheduled day (e.g., Monday not completed yet)
   ↓
4. DayDetailSheet opens showing day info
   ↓
5. User taps "Complete" button
   ↓
6. WorkoutSelectorSheet opens (70% screen height)
   ├─ Shows header: "Complete Day with Workout"
   ├─ Shows subtitle: "Select workout to link to Monday, Jan 5"
   ├─ Shows workout list (last 7 days):
   │  ├─ Giorno A - Today 14:30 • 45min • 8 ex [✅ Match]
   │  ├─ Giorno B - Yesterday 18:00 • 50min • 6 ex
   │  └─ Giorno C - 3 days ago • 42min • 7 ex
   └─ Shows fallback: "Complete without workout"
   ↓
7. User taps "Giorno A" workout card
   ↓
8. Haptic feedback + brief checkmark animation
   ↓
9. App calls: notifier.completeDayWorkout(routineId, date, workoutId)
   ↓
10. Both sheets close (selector + day detail)
    ↓
11. Success SnackBar: "Day completed with workout!"
    ↓
12. Routine updated: Monday shows ✓ completed with workout link
```

---

### Alternative Path: Complete without Workout

```
5. User taps "Complete" button
   ↓
6. WorkoutSelectorSheet opens
   ↓
7. User scrolls to bottom
   ↓
8. User taps "Complete without workout" button
   ↓
9. App calls: notifier.completeDayManual(routineId, date)
   ↓
10. Both sheets close
    ↓
11. Success SnackBar: "Day completed manually"
    ↓
12. Routine updated: Monday shows ✓ completed (no workout link)
```

---

### Edge Case: No Recent Workouts

```
6. WorkoutSelectorSheet opens
   ↓
7. recentWorkoutsProvider returns empty list
   ↓
8. Sheet shows empty state:
   ├─ Icon: Dumbbell (grey)
   ├─ Title: "No recent workouts found"
   ├─ Subtitle: "Complete this day without linking a workout"
   └─ Button: "Complete Day"
   ↓
9. User taps button → completeDayManual()
```

---

## 🎨 Visual Design & UI Polish

### Color Scheme

**Match highlight**:
- Background: `context.colors.primaryContainer`
- Border: `context.colors.primary` (2px solid)
- Badge: Green background with green border

**Normal workout card**:
- Background: `context.colors.surfaceVariant`
- Border: Transparent

**Warning (already linked)**:
- Badge: Orange background with orange border

### Typography

- **Header**: `context.textTheme.titleLarge` (22sp, bold)
- **Subtitle**: `context.textTheme.bodyMedium` (14sp, medium emphasis)
- **Workout name**: `context.textTheme.titleMedium` (16sp, semibold)
- **Metadata**: `context.textTheme.bodySmall` (12sp, low emphasis)

### Spacing

- **Horizontal padding**: 20px (consistent with DayDetailSheet)
- **Vertical padding**: 16px
- **Card spacing**: 12px between cards
- **Section spacing**: 24px between sections

### Animations

**1. Sheet entrance**:
- Slide up with spring animation (300ms)
- Backdrop fade-in

**2. Card tap**:
- Haptic feedback (`HapticFeedback.mediumImpact()`)
- Scale down to 0.98 (150ms)
- Brief checkmark animation before dismiss

**3. Loading state**:
- Skeleton loader with shimmer effect
- 5 placeholder cards

**4. Empty state**:
- Fade-in icon + text (500ms)

---

## 🚨 Edge Cases & Error Handling

### 1. No Recent Workouts (Empty List)

**Behavior**: Show empty state with fallback action

```dart
Widget _buildEmptyState(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.fitness_center,
          size: 64,
          color: context.colors.secondary.withValues(alpha: 0.5),
        ),
        SizedBox(height: 16),
        Text(
          'No recent workouts found',
          style: context.textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Text(
          'Complete this day without linking a workout',
          style: context.textTheme.bodySmall.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: onCompleteWithoutWorkout,
          child: Text('Complete Day'),
        ),
      ],
    ),
  );
}
```

---

### 2. Template Mismatch Confirmation

**Scenario**: User selects workout that doesn't match day's template

**Behavior**: Show confirmation dialog before completing

```dart
if (!isTemplateMatch && templateId != null) {
  final confirmed = await ModalService.showConfirmDialog(
    context,
    title: 'Template Mismatch',
    message: 'This day expects "$templateId" but you selected "${workout.name}". '
             'Complete anyway?',
    confirmText: 'Yes, Complete',
    cancelText: 'Go Back',
  );

  if (!confirmed) return; // User canceled
}

// Proceed with completion
await onWorkoutSelected(workout.id);
```

---

### 3. Workout Already Linked to Another Day

**Scenario**: Workout is already used for another routine day

**Behavior**: Show warning badge but allow selection (valid use case: recovery)

```dart
// Check if workout is already linked
bool isAlreadyLinked(Workout workout) {
  return routine.schedule.values.any((day) =>
    day.workoutId == workout.id && day.date != this.date
  );
}

// Get linked date
DateTime? getLinkedDate(Workout workout) {
  return routine.schedule.values
    .firstWhere((day) => day.workoutId == workout.id, orElse: null)
    ?.date;
}

// Show badge in card
if (isAlreadyLinked) {
  Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange),
    ),
    child: Row(
      children: [
        Icon(Icons.warning, size: 14, color: Colors.orange),
        SizedBox(width: 4),
        Text(
          'Linked to ${DateFormat('MMM d').format(linkedDate!)}',
          style: TextStyle(fontSize: 12, color: Colors.orange),
        ),
      ],
    ),
  ),
}
```

**Note**: We allow this because it's a valid scenario (e.g., user wants to mark same workout for recovery day).

---

### 4. Network/Offline Errors

**Scenario A**: Workout fetch fails

```dart
// In WorkoutSelectorSheet
workoutsAsync.when(
  data: (workouts) => _buildWorkoutList(workouts),
  loading: () => _buildLoadingState(),
  error: (error, stack) => _buildErrorState(error),
);

Widget _buildErrorState(Object error) {
  return Padding(
    padding: EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off, size: 64, color: context.colors.error),
        SizedBox(height: 16),
        Text(
          'Failed to load workouts',
          style: context.textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Text(
          error.toString(),
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // Retry fetch
            ref.invalidate(recentWorkoutsProvider(7));
          },
          icon: Icon(Icons.refresh),
          label: Text('Retry'),
        ),
        SizedBox(height: 12),
        TextButton(
          onPressed: onCompleteWithoutWorkout,
          child: Text('Complete without workout'),
        ),
      ],
    ),
  );
}
```

**Scenario B**: Complete operation fails

```dart
try {
  await notifier.completeDayWorkout(routineId, date, workoutId);
} catch (e) {
  if (context.mounted) {
    SnackBarService.showError(
      context,
      'Failed to complete day: ${e.toString()}',
    );
    // Keep modal open (don't dismiss)
  }
}
```

---

### 5. Workout Deleted/Corrupted

**Scenario**: Workout ID exists in list but no longer in Firestore

**Behavior**: Catch `WorkoutNotFoundException` and show specific error

```dart
try {
  await notifier.completeDayWorkout(routineId, date, workoutId);
} catch (e) {
  if (e is WorkoutNotFoundException) {
    if (context.mounted) {
      SnackBarService.showError(
        context,
        'Workout no longer exists. Try completing without workout.',
      );
    }
  } else {
    if (context.mounted) {
      SnackBarService.showError(context, 'Error: ${e.toString()}');
    }
  }
}
```

---

## 🧪 Testing Strategy

### Unit Tests

**File**: `test/features/routine/presentation/widgets/workout_selector_sheet_test.dart`

```dart
void main() {
  group('WorkoutSelectorSheet', () {
    testWidgets('shows workout list when data loaded', (tester) async {
      // Arrange: Mock provider with 3 workouts
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => [
            mockWorkout1,
            mockWorkout2,
            mockWorkout3,
          ]),
        ],
      );

      // Act: Pump widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutSelectorSheet(...),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Finds 3 workout cards
      expect(find.byType(WorkoutSelectorCard), findsNWidgets(3));
    });

    testWidgets('shows empty state when no workouts', (tester) async {
      // Arrange: Mock empty list
      final container = ProviderContainer(
        overrides: [
          recentWorkoutsProvider(7).overrideWith((_) async => []),
        ],
      );

      // Act
      await tester.pumpWidget(...);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No recent workouts found'), findsOneWidget);
      expect(find.text('Complete Day'), findsOneWidget);
    });

    testWidgets('highlights template match with badge', (tester) async {
      // Test match badge appears for matching workout
    });

    testWidgets('calls onWorkoutSelected when card tapped', (tester) async {
      // Test callback invoked with correct workoutId
    });

    testWidgets('shows confirmation for template mismatch', (tester) async {
      // Test dialog appears when non-matching workout selected
    });
  });
}
```

---

### Widget Tests

**File**: `test/features/routine/presentation/widgets/day_detail_sheet_test.dart`

```dart
testWidgets('Complete button opens WorkoutSelectorSheet', (tester) async {
  // Arrange: Scheduled day
  final dayInfo = ScheduledDay(
    date: DateTime.now(),
    status: DayStatus.scheduled,
    templateId: 'giorno-a',
  );

  // Act: Tap Complete button
  await tester.tap(find.text('Complete'));
  await tester.pumpAndSettle();

  // Assert: WorkoutSelectorSheet is visible
  expect(find.byType(WorkoutSelectorSheet), findsOneWidget);
  expect(find.text('Complete Day with Workout'), findsOneWidget);
});
```

---

### Integration Tests (Patrol)

**File**: `integration_test/tests/routine_manual_completion_test.dart`

```dart
void main() {
  patrolTest('Complete routine day with workout selection', ($) async {
    // Setup: User with active routine and recent workouts
    await $.pumpWidgetAndSettle(MyApp());

    // Navigate to Routine Center
    await $(RoutineCenterScreen).tap();
    await $.pumpAndSettle();

    // Tap active routine
    await $('Winter Arc').tap();
    await $.pumpAndSettle();

    // Tap scheduled day
    await $.tap(find.byType(CalendarView).first);
    await $.pumpAndSettle();

    // Verify DayDetailSheet opened
    expect($(DayDetailSheet), findsOneWidget);

    // Tap Complete button
    await $('Complete').tap();
    await $.pumpAndSettle();

    // Verify WorkoutSelectorSheet opened
    expect($(WorkoutSelectorSheet), findsOneWidget);
    expect($('Complete Day with Workout'), findsOneWidget);

    // Select first workout
    await $(WorkoutSelectorCard).first.tap();
    await $.pumpAndSettle();

    // Verify success
    expect($('Day completed with workout!'), findsOneWidget);

    // Verify routine updated
    // ... check Firestore or provider state
  });

  patrolTest('Complete day without workout (fallback)', ($) async {
    // Test fallback path
  });
}
```

---

## 📊 Analytics Tracking

Track manual completion events for insights:

```dart
class WorkoutEventTracker {
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
}
```

**Metrics to monitor**:
- % of manual completions with workout vs without
- Most common template mismatches
- Time to complete action (UX performance)

---

## 🚀 Implementation Plan

### Phase 1: Core Widget (1-2 hours)

1. Create `WorkoutSelectorSheet` widget
   - Basic structure with DraggableScrollableSheet
   - Header, subtitle, divider
   - Empty state placeholder

2. Create `WorkoutSelectorCard` widget
   - Layout with icon, title, subtitle, badge
   - Tap handling with haptic
   - Match badge logic

3. Create `recentWorkoutsProvider`
   - Filter workouts by date range
   - Sort by date (newest first)

**Verification**: Can open empty selector sheet

---

### Phase 2: Integration (1 hour)

1. Modify `DayDetailSheet._completeDay()`
   - Replace confirm dialog with sheet
   - Wire up callbacks
   - Handle navigation

2. Test basic flow
   - Open sheet → See empty state
   - Tap fallback → Complete without workout

**Verification**: Can complete day via fallback path

---

### Phase 3: Workout List & Selection (2 hours)

1. Implement workout list rendering
   - AsyncValue states (loading/data/error)
   - ListView with WorkoutSelectorCard items
   - Match detection logic

2. Handle workout selection
   - Template match confirmation
   - Call completeDayWorkout()
   - Success/error handling

**Verification**: Can select workout and complete day with link

---

### Phase 4: Polish & Edge Cases (1-2 hours)

1. Add animations
   - Sheet entrance/exit
   - Card tap feedback
   - Success checkmark

2. Handle edge cases
   - Empty state
   - Error state with retry
   - Already linked warning
   - Template mismatch dialog

3. Add loading states
   - Skeleton loader

**Verification**: All edge cases handled gracefully

---

### Phase 5: Testing (1-2 hours)

1. Write unit tests for widgets
2. Write integration test for happy path
3. Manual QA on device

**Verification**: All tests passing

---

**Total Estimate**: 6-9 hours

---

## 🎯 Success Criteria

✅ User can manually complete a routine day by selecting a specific workout
✅ Workout selector shows recent workouts (last 7 days)
✅ Template matches are highlighted with badge
✅ Fallback option to complete without workout exists
✅ All edge cases handled (empty, error, mismatch)
✅ Smooth animations and haptic feedback
✅ Tests pass (unit + integration)
✅ No regressions in existing completion flow

---

## 📝 Follow-up Ideas (Future Enhancements)

**Not in scope for initial implementation**:

1. **Extended date range**: Allow user to select workout from last 30 days (currently 7)
2. **Search/filter**: If user has many workouts, add search bar
3. **Bulk completion**: Complete multiple days at once with same workout
4. **Smart suggestions**: Use ML to suggest most likely workout based on pattern
5. **Undo action**: Allow reverting completion within 5 seconds

---

## 📚 Related Documentation

- [Routine Center System Report](../UX_FLOWS/routine_center/ROUTINE_CENTER_SYSTEM_REPORT.md)
- [Flexible Routine Entity](../../lib/features/routine/domain/entities/flexible_routine.dart)
- [Routine Auto-Completion Service](../../lib/features/routine/application/services/routine_auto_completion_service.dart)
- [Design Guidelines](../DESIGN_GUIDELINES.md)

---

**Document Status**: ✅ Complete - Ready for Implementation
**Next Steps**: Use `superpowers:writing-plans` to create detailed implementation plan
