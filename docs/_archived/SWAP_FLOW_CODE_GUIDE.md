# SWAP FLOW - CODE IMPLEMENTATION GUIDE

## FILES TO MODIFY vs CREATE

### TO MODIFY (6 files)
1. `lib/features/routine/domain/entities/flexible_routine.dart` - Add fields to ScheduledDay
2. `lib/features/routine/application/services/routine_auto_completion_service.dart` - Enhance logic
3. `lib/features/routine/presentation/providers/flexible_routine_notifier.dart` - Add swapDays method
4. `lib/features/routine/domain/repositories/flexible_routine_repository.dart` - Add interface
5. `lib/features/routine/data/repositories/firebase_flexible_routine_repository.dart` - Implement swap
6. `lib/features/workout/presentation/providers/workout_provider.dart` - Handle swap result

### TO CREATE (3 files)
1. `lib/features/routine/domain/entities/day_swap_metadata.dart` - NEW entity (Freezed)
2. `lib/features/routine/application/services/routine_swap_service.dart` - NEW service
3. `lib/features/routine/presentation/widgets/dialogs/swap_opportunity_dialog.dart` - NEW widget

---

## 1. UPDATE: flexible_routine.dart

### BEFORE (Lines 134-180)
```dart
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,
    required DayStatus status,
    String? templateId,
    String? workoutId,
    String? skipReason,
    DateTime? originalDate,
    String? notes,
  }) = _ScheduledDay;
```

### AFTER (Add these 2 lines)
```dart
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,
    required DayStatus status,
    String? templateId,
    String? workoutId,
    String? skipReason,
    DateTime? originalDate,
    String? notes,
    
    /// 🔄 Swap tracking: If this day was swapped with another date
    DateTime? swappedWithDate,
    
    /// 🔄 Swap metadata: Details about the swap operation
    DaySwapMetadata? swapMetadata,
  }) = _ScheduledDay;

  factory ScheduledDay.fromJson(Map<String, dynamic> json) =>
      _$ScheduledDayFromJson(json);
```

**Impact:** Need to run `dart run build_runner build` after adding fields

---

## 2. CREATE: day_swap_metadata.dart

**Location:** `lib/features/routine/domain/entities/day_swap_metadata.dart`

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: routine_swap_flow
/// 🔧 Type: entity
///
/// Tracks metadata about workout day swaps for analytics and auditing
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_swap_metadata.freezed.dart';
part 'day_swap_metadata.g.dart';

/// Metadata about a day swap operation
@freezed
class DaySwapMetadata with _$DaySwapMetadata {
  const factory DaySwapMetadata({
    /// ISO date string of original scheduled day (YYYY-MM-DD)
    required String originalDay,
    
    /// ISO date string of the day workout was actually completed (YYYY-MM-DD)
    required String swappedDay,
    
    /// Template ID that was swapped
    required String templateId,
    
    /// When the swap occurred
    required DateTime swappedAt,
    
    /// Why the swap was initiated
    /// E.g., "mismatch_detection", "user_choice", "recovery"
    String? reason,
    
    /// User ID who initiated the swap (for multi-user scenarios)
    String? userId,
  }) = _DaySwapMetadata;

  factory DaySwapMetadata.fromJson(Map<String, dynamic> json) =>
      _$DaySwapMetadataFromJson(json);

  /// Create swap metadata from today's swap
  factory DaySwapMetadata.create({
    required String originalDay,
    required String swappedDay,
    required String templateId,
    String? reason,
    String? userId,
  }) {
    return DaySwapMetadata(
      originalDay: originalDay,
      swappedDay: swappedDay,
      templateId: templateId,
      swappedAt: DateTime.now(),
      reason: reason,
      userId: userId,
    );
  }
}
```

---

## 3. CREATE: routine_swap_service.dart

**Location:** `lib/features/routine/application/services/routine_swap_service.dart`

```dart
/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/application
/// 🎯 Feature: routine_swap_flow
/// 🔧 Type: service
///
/// Service for detecting and executing workout day swaps
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_repository_provider.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/day_swap_metadata.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Opportunity to swap a workout day
class SwapOpportunity {
  final String templateId;
  final DateTime completedDate;          // When user completed it
  final List<DateTime> originalScheduledDates;  // Where it's scheduled
  final DateTime recommendedSwapTarget;  // Best candidate date

  SwapOpportunity({
    required this.templateId,
    required this.completedDate,
    required this.originalScheduledDates,
    required this.recommendedSwapTarget,
  });

  @override
  String toString() {
    return 'SwapOpportunity('
        'template: $templateId, '
        'completed: $completedDate, '
        'scheduled: $originalScheduledDates, '
        'recommended: $recommendedSwapTarget'
        ')';
  }
}

/// Service for detecting and executing workout day swaps
class RoutineSwapService {
  RoutineSwapService(this._ref);

  final Ref _ref;

  FlexibleRoutineRepository get _repository =>
      _ref.read(flexibleRoutineRepositoryProvider);

  /// Detect if a swap opportunity exists
  /// 
  /// Returns SwapOpportunity if:
  /// - Multiple candidate dates found for template
  /// - Today's schedule doesn't match the completed template
  /// 
  /// Returns null if:
  /// - Only single candidate (auto-complete sufficient)
  /// - Today matches the template (no swap needed)
  Future<SwapOpportunity?> detectSwapOpportunity({
    required Workout completedWorkout,
    required FlexibleRoutine activeRoutine,
  }) async {
    try {
      final templateId = completedWorkout.templateId;
      if (templateId == null || templateId.isEmpty) {
        return null;
      }

      // Find candidates for this template
      final candidates = _findCandidateDays(
        routine: activeRoutine,
        templateId: templateId,
        completedAt: completedWorkout.endTime,
      );

      if (candidates.isEmpty) {
        if (kDebugMode) {
          debugPrint('ℹ️ [SwapService] No candidate days found for template $templateId');
        }
        return null;
      }

      // Single candidate - no swap needed
      if (candidates.length == 1) {
        if (kDebugMode) {
          debugPrint('ℹ️ [SwapService] Only 1 candidate, no swap needed');
        }
        return null;
      }

      // Multiple candidates - check for mismatch
      final today = DateTime.now();
      final todayKey = _dateToString(today);
      final todayScheduledDay = activeRoutine.schedule[todayKey];

      // Is today a rest day or different template?
      final isTodayMismatch = 
          todayScheduledDay?.templateId != templateId ||
          todayScheduledDay?.status != DayStatus.scheduled;

      if (!isTodayMismatch) {
        // Today matches template, no swap opportunity
        if (kDebugMode) {
          debugPrint('ℹ️ [SwapService] Today matches template, no swap opportunity');
        }
        return null;
      }

      // SWAP OPPORTUNITY DETECTED!
      final recommended = _findBestSwapTarget(candidates, today);

      if (kDebugMode) {
        debugPrint('✅ [SwapService] Swap opportunity detected!');
        debugPrint('   Template: $templateId');
        debugPrint('   Completed today: $today');
        debugPrint('   Scheduled dates: $candidates');
        debugPrint('   Recommended target: $recommended');
      }

      return SwapOpportunity(
        templateId: templateId,
        completedDate: today,
        originalScheduledDates: candidates,
        recommendedSwapTarget: recommended,
      );

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SwapService] Error detecting swap: $e');
        debugPrint('📍 [SwapService] Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Execute a swap operation
  /// 
  /// Updates both days atomically:
  /// - toDate: marked as completed with swap metadata
  /// - fromDate: marked as skipped with swap reference
  Future<void> executeSwap({
    required String routineId,
    required DateTime fromDate,    // Where user completed it
    required DateTime toDate,      // Where it's scheduled
    required String templateId,
    BuildContext? context,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 [SwapService] Executing swap...');
        debugPrint('   From (completed): ${_formatDate(fromDate)}');
        debugPrint('   To (scheduled): ${_formatDate(toDate)}');
      }

      // 1. Get routine
      final routine = await _repository.getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found: $routineId');
      }

      // 2. Get both days
      final fromKey = _dateToString(fromDate);
      final toKey = _dateToString(toDate);
      
      final fromDay = routine.getScheduledDay(fromDate);
      final toDay = routine.getScheduledDay(toDate);

      if (fromDay == null || toDay == null) {
        throw Exception('Days not found in schedule');
      }

      // 3. Create swap metadata
      final swapMetadata = DaySwapMetadata.create(
        originalDay: toKey,
        swappedDay: fromKey,
        templateId: templateId,
        reason: 'mismatch_detection',
        userId: routine.userId,
      );

      // 4. Update both days atomically
      final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);

      // Mark target day (toDate) as completed
      // This is where the template IS scheduled
      updatedSchedule[toKey] = toDay.copyWith(
        status: DayStatus.completed,
        workoutId: fromDay.workoutId,  // Use workout from completed date
        swappedWithDate: fromDate,
        swapMetadata: swapMetadata,
      );

      // Mark source day (fromDate) as skipped
      // This is where the user actually completed it
      updatedSchedule[fromKey] = fromDay.copyWith(
        status: DayStatus.skipped,
        skipReason: 'Swapped to ${_formatDate(toDate)} (${toDay.templateId})',
        swappedWithDate: toDate,
        swapMetadata: swapMetadata,
      );

      // 5. Update routine
      final updatedRoutine = routine.copyWith(
        schedule: updatedSchedule,
        completedDays: routine.completedDays + 1,
        updatedAt: DateTime.now(),
        isSyncPending: true,
      );

      await _repository.updateRoutine(updatedRoutine);

      if (kDebugMode) {
        debugPrint('✅ [SwapService] Swap executed successfully');
      }

      // 6. Show success feedback
      if (context != null && context.mounted) {
        SnackBarService.showSuccess(
          context,
          'Workout swapped to ${_formatDate(toDate)} ✓',
          duration: const Duration(seconds: 3),
        );
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SwapService] Swap execution failed: $e');
        debugPrint('📍 [SwapService] Stack trace: $stackTrace');
      }

      if (context != null && context.mounted) {
        SnackBarService.showError(
          context,
          'Swap failed: $e',
          duration: const Duration(seconds: 4),
        );
      }

      rethrow;
    }
  }

  /// Find candidate days where this template is scheduled
  List<DateTime> _findCandidateDays({
    required FlexibleRoutine routine,
    required String templateId,
    DateTime? completedAt,
  }) {
    final targetDate = completedAt ?? DateTime.now();
    final candidates = <DateTime>[];

    for (final scheduledDay in routine.schedule.values) {
      // Must match template
      if (scheduledDay.templateId != templateId) continue;

      // Must be actionable
      if (!scheduledDay.status.isActionable) continue;

      // Must be within ±7 days
      final daysDifference = scheduledDay.date.difference(targetDate).inDays.abs();
      if (daysDifference > 7) continue;

      candidates.add(scheduledDay.date);
    }

    // Sort by proximity
    candidates.sort((a, b) {
      final diffA = a.difference(targetDate).inDays.abs();
      final diffB = b.difference(targetDate).inDays.abs();
      return diffA.compareTo(diffB);
    });

    return candidates;
  }

  /// Find best swap target from candidates
  DateTime _findBestSwapTarget(List<DateTime> candidates, DateTime fromDate) {
    if (candidates.isEmpty) throw Exception('No candidates available');

    // Simple strategy: closest date
    candidates.sort((a, b) {
      final diffA = a.difference(fromDate).inDays.abs();
      final diffB = b.difference(fromDate).inDays.abs();
      if (diffA != diffB) return diffA.compareTo(diffB);
      // If same distance, prefer future dates
      return a.isAfter(b) ? -1 : 1;
    });

    return candidates.first;
  }

  /// Format date for UI display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';

    return '${_weekdayName(date.weekday)} ${date.day} ${_monthName(date.month)}';
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _weekdayName(int weekday) {
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names.length > weekday ? names[weekday] : '';
  }

  String _monthName(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names.length > month ? names[month] : '';
  }
}

/// Provider for RoutineSwapService
final routineSwapServiceProvider = Provider<RoutineSwapService>((ref) {
  return RoutineSwapService(ref);
});
```

---

## 4. UPDATE: routine_auto_completion_service.dart

### ADD to RoutineAutoCompletionResult class (after line 77)

```dart
  /// Create result for swap opportunity detected
  factory RoutineAutoCompletionResult.swapDetected(SwapOpportunity swap) {
    return RoutineAutoCompletionResult(
      completed: false,
      reason: 'Swap opportunity detected',
      candidateDates: null,
      swapOpportunity: swap,
    );
  }
```

### ADD to RoutineAutoCompletionResult fields (line 44-48)

```dart
class RoutineAutoCompletionResult {
  final bool completed;
  final String? reason;
  final List<DateTime>? candidateDates;
  final SwapOpportunity? swapOpportunity;  // NEW FIELD
```

### ADD import at top

```dart
import 'package:gymbro_flutter_new/features/routine/application/services/routine_swap_service.dart';
```

### MODIFY tryAutoCompleteRoutineDay (around line 168, before the "multiple matches" section)

```dart
      // 5. Multiple matches → check for swap opportunity
      if (kDebugMode) {
        debugPrint('ℹ️ [RoutineAutoCompletion] Multiple candidate days found: $candidateDays');
      }

      // NEW: Try to detect swap opportunity
      if (context != null) {
        final swapService = _ref.read(routineSwapServiceProvider);
        final swapOp = await swapService.detectSwapOpportunity(
          completedWorkout: completedWorkout,
          activeRoutine: activeRoutine,
        );

        if (swapOp != null) {
          // Return swap opportunity for UI handling
          return RoutineAutoCompletionResult.swapDetected(swapOp);
        }
      }

      // Fall back to candidate selection if no swap opportunity
      return RoutineAutoCompletionResult.needsUserSelection(candidateDays);
```

---

## 5. UPDATE: workout_provider.dart

### MODIFY _autoCompleteRoutineDay (lines 643-663)

Replace entire method with:

```dart
  /// Auto-complete routine day if workout matches scheduled template
  ///
  /// Handles three scenarios:
  /// 1. Single match → Auto-complete immediately
  /// 2. Swap opportunity → Show dialog for user confirmation
  /// 3. Multiple matches → Show day picker (existing behavior)
  Future<bool> _autoCompleteRoutineDay(Workout workout, BuildContext? context) async {
    final autoCompletionService = ref.read(routineAutoCompletionServiceProvider);

    final result = await autoCompletionService.tryAutoCompleteRoutineDay(
      completedWorkout: workout,
      context: context,
    );

    // Case 1: Single auto-completion
    if (result.completed) {
      return true;
    }

    // Case 2: Swap opportunity detected
    if (result.swapOpportunity != null && context != null && context.mounted) {
      await _showSwapDialog(context, result.swapOpportunity!, workout);
      return false; // Swap dialog handles the completion
    }

    // Case 3: Multiple candidates (no swap)
    if (result.candidateDates != null && result.candidateDates!.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ [WorkoutProvider] Multiple candidate dates found');
        debugPrint('   Candidates: ${result.candidateDates}');
      }
      // TODO: Show DaySelectionBottomSheet for user to pick date
      return false;
    }

    return result.completed;
  }

  /// Show swap opportunity dialog
  Future<void> _showSwapDialog(
    BuildContext context,
    SwapOpportunity swapOp,
    Workout workout,
  ) async {
    try {
      final activeRoutine = ref.read(activeFlexibleRoutineProvider).whenData(
        (routine) => routine,
      );

      // TODO: Show custom SwapOpportunityDialog
      // For now, use generic confirm dialog
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.swapWorkoutDay),
          content: Text(
            'You completed ${workout.name} today.\n'
            'But it\'s scheduled for ${_formatSwapDate(swapOp.recommendedSwapTarget)}.\n'
            'Swap it there?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.swapIt),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Execute swap
        final swapService = ref.read(routineSwapServiceProvider);
        final routine = await activeRoutine;
        
        if (routine != null) {
          await swapService.executeSwap(
            routineId: routine.id,
            fromDate: DateTime.now(),
            toDate: swapOp.recommendedSwapTarget,
            templateId: swapOp.templateId,
            context: context,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Swap dialog error: $e');
      }
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'Swap failed: $e',
        );
      }
    }
  }

  String _formatSwapDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';

    return '${_swapWeekday(date.weekday)} ${date.day}';
  }

  String _swapWeekday(int weekday) {
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names.length > weekday ? names[weekday] : '';
  }
```

### ADD imports at top

```dart
import 'package:gymbro_flutter_new/features/routine/application/services/routine_swap_service.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
```

---

## 6. UPDATE: flexible_routine_repository.dart

### ADD method signature (after recoverDay method, around line 105)

```dart
  /// Swap two days in the routine
  /// Atomically updates both days with swap metadata
  Future<void> swapDays({
    required String routineId,
    required DateTime fromDate,
    required DateTime toDate,
    required String templateId,
  });
```

---

## 7. UPDATE: firebase_flexible_routine_repository.dart

### ADD import

```dart
import 'package:gymbro_flutter_new/features/routine/domain/entities/day_swap_metadata.dart';
```

### ADD method implementation (after recoverDay implementation, around line 358)

```dart
  @override
  Future<void> swapDays({
    required String routineId,
    required DateTime fromDate,
    required DateTime toDate,
    required String templateId,
  }) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found: $routineId');
      }

      // Get both days
      final fromDay = routine.getScheduledDay(fromDate);
      final toDay = routine.getScheduledDay(toDate);

      if (fromDay == null || toDay == null) {
        throw Exception('Days not found in schedule');
      }

      // Create swap metadata
      final swapMetadata = DaySwapMetadata.create(
        originalDay: _dateToString(toDate),
        swappedDay: _dateToString(fromDate),
        templateId: templateId,
        reason: 'mismatch_detection',
        userId: routine.userId,
      );

      // Update both days
      final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);

      updatedSchedule[_dateToString(toDate)] = toDay.copyWith(
        status: DayStatus.completed,
        workoutId: fromDay.workoutId,
        swappedWithDate: fromDate,
        swapMetadata: swapMetadata,
      );

      updatedSchedule[_dateToString(fromDate)] = fromDay.copyWith(
        status: DayStatus.skipped,
        skipReason: 'Swapped to ${_dateToString(toDate)}',
        swappedWithDate: toDate,
        swapMetadata: swapMetadata,
      );

      // Update routine
      final updatedRoutine = routine.copyWith(
        schedule: updatedSchedule,
        completedDays: routine.completedDays + 1,
        updatedAt: DateTime.now(),
        isSyncPending: true,
      );

      await updateRoutine(updatedRoutine);

    } catch (e) {
      throw _handleError(e, 'swapDays');
    }
  }
```

---

## SEQUENCE OF IMPLEMENTATION

1. **Start:** Create `day_swap_metadata.dart` (new Freezed entity)
2. **Build:** Run `dart run build_runner build`
3. **Update:** `flexible_routine.dart` - Add fields to ScheduledDay
4. **Build:** Run `dart run build_runner build` again
5. **Create:** `routine_swap_service.dart` (new service)
6. **Update:** `routine_auto_completion_service.dart` (add swap detection)
7. **Update:** `workout_provider.dart` (handle swap results)
8. **Update:** Repository files (add swap method)
9. **Test:** Unit + widget tests
10. **Polish:** Create SwapOpportunityDialog widget (custom UI)

---

## TESTING STRATEGY

### Unit Tests
```dart
// test/features/routine/application/services/routine_swap_service_test.dart
test('detectSwapOpportunity returns null for single candidate') async {
  // ...
}

test('detectSwapOpportunity detects mismatch for multiple candidates') async {
  // ...
}

test('executeSwap updates both days atomically') async {
  // ...
}
```

### Widget Tests
```dart
// test/features/routine/presentation/widgets/dialogs/swap_opportunity_dialog_test.dart
testWidgets('SwapOpportunityDialog shows options', (tester) async {
  // ...
});
```

