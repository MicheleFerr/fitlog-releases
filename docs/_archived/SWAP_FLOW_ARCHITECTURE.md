# SWAP FLOW ANALYSIS - Complete Architecture

## 1. CURRENT AUTO-COMPLETION FLOW (Existing Architecture)

### Entry Point: workout_provider.dart (Lines 609-663)
```dart
// Step 7 in _saveCompletedWorkoutToFirestore()
// Auto-complete routine day if applicable
try {
  final didAutoComplete = await _autoCompleteRoutineDay(workout, context);
  if (didAutoComplete) {
    debugPrint('✅ [Routine] Auto-completed routine day');
  }
} catch (routineError) {
  debugPrint('⚠️ [Routine] Failed to auto-complete day: $routineError');
  // Non-critical - workout is already saved
}
```

### Method: _autoCompleteRoutineDay (workout_provider.dart, Lines 643-663)
```dart
Future<bool> _autoCompleteRoutineDay(Workout workout, BuildContext? context) async {
  final autoCompletionService = ref.read(routineAutoCompletionServiceProvider);

  final result = await autoCompletionService.tryAutoCompleteRoutineDay(
    completedWorkout: workout,
    context: context,
  );

  // If multiple candidate dates found, show UI for user selection
  // (For now, we skip this case - will implement UI in next task)
  if (result.candidateDates != null && result.candidateDates!.isNotEmpty) {
    if (kDebugMode) {
      debugPrint('ℹ️ [WorkoutProvider] Multiple candidate dates found, but UI selection not yet implemented');
      debugPrint('   Candidates: ${result.candidateDates}');
    }
    // TODO: Show DaySelectionBottomSheet for user to pick date
    return false;
  }

  return result.completed;
}
```

### Service: RoutineAutoCompletionService (Lines 100-184)

**Core Logic: tryAutoCompleteRoutineDay()**
1. Gets active routine (line 106)
2. Checks if workout has templateId (line 122)
3. Finds candidate days with _findCandidateDays() (line 131)
4. Single match → auto-complete (line 145)
5. Multiple matches → return candidates (line 175)

**Key Finding Logic: _findCandidateDays() (Lines 239-270)**
```dart
List<DateTime> _findCandidateDays({
  required FlexibleRoutine routine,
  required String templateId,
  DateTime? completedAt,
}) {
  final targetDate = completedAt ?? DateTime.now();
  final candidates = <DateTime>[];

  // Check all scheduled days in the routine
  for (final scheduledDay in routine.schedule.values) {
    // Must match template
    if (scheduledDay.templateId != templateId) continue;

    // Must be actionable (not already completed or rest day)
    if (!scheduledDay.status.isActionable) continue;

    // Must be within ±7 days of workout completion (configurable window)
    final daysDifference = scheduledDay.date.difference(targetDate).inDays.abs();
    if (daysDifference > 7) continue;

    candidates.add(scheduledDay.date);
  }

  // Sort by proximity to target date
  candidates.sort((a, b) {
    final diffA = a.difference(targetDate).inDays.abs();
    final diffB = b.difference(targetDate).inDays.abs();
    return diffA.compareTo(diffB);
  });

  return candidates;
}
```

---

## 2. SWAP FLOW ENHANCEMENT (Proposed)

### What is a SWAP?
User completes Workout on **Day A** but Routine schedule has it on **Day B**
- Day A: No workout scheduled (or different template)
- Day B: Has the same template
- User wants to "swap" them

### Flow Diagram
```
User completes Template X on Monday
        ↓
[Find candidates for Template X]
        ↓
        Single candidate (March 15)?
            ↓ YES
        [Auto-complete March 15]
            ↓ NO
        Multiple candidates?
            ↓ YES
            ↓ Show UI Dialog
            ├─ Option 1: "Use March 15" (auto-complete)
            ├─ Option 2: "Swap with another day"
            │   └─ Show calendar picker
            │       ├─ Let user select target date
            │       └─ Confirm swap operation
            └─ Option 3: "Cancel"
            ↓ NO
        [Silently skip]
```

---

## 3. DATA STRUCTURES NEEDED

### ScheduledDay Enhancement (flexible_routine.dart, Lines 134-180)
**Current Structure:**
```dart
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,
    required DayStatus status,
    String? templateId,
    String? workoutId,
    String? skipReason,
    DateTime? originalDate,  // Recovery tracking
    String? notes,
  }) = _ScheduledDay;
}
```

**Proposed Addition for Swap Tracking:**
```dart
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,
    required DayStatus status,
    String? templateId,
    String? workoutId,
    String? skipReason,
    DateTime? originalDate,  // Recovery tracking
    String? notes,
    
    // 🔄 NEW: Swap tracking
    DateTime? swappedWithDate,    // If this day was swapped with another
    DaySwapMetadata? swapMetadata,  // Swap details
  }) = _ScheduledDay;
}
```

### New Entity: DaySwapMetadata (NEW FILE)
```dart
@freezed
class DaySwapMetadata with _$DaySwapMetadata {
  const factory DaySwapMetadata({
    required String originalDay,    // ISO date of original day
    required String swappedDay,     // ISO date of swapped day
    required String templateId,     // Template that was swapped
    required DateTime swappedAt,    // When swap occurred
    String? reason,                 // Why swap was done (optional)
    String? userId,                 // Who initiated swap (for analytics)
  }) = _DaySwapMetadata;

  factory DaySwapMetadata.fromJson(Map<String, dynamic> json) =>
      _$DaySwapMetadataFromJson(json);
}
```

---

## 4. NEW SERVICE: RoutineSwapService

**Location:** `lib/features/routine/application/services/routine_swap_service.dart`

### Purpose
Detect swap opportunities and execute atomic swap operations

### Key Methods

#### 1. detectSwapOpportunity()
```dart
Future<SwapOpportunity?> detectSwapOpportunity({
  required Workout completedWorkout,
  required FlexibleRoutine activeRoutine,
}) async {
  // 1. Get completed workout template
  final templateId = completedWorkout.templateId;
  if (templateId == null) return null;

  // 2. Find candidates (multiple days with same template)
  final candidates = _findCandidateDays(
    routine: activeRoutine,
    templateId: templateId,
    completedAt: completedWorkout.endTime,
  );

  if (candidates.length <= 1) return null; // No swap needed

  // 3. Detect mismatch with today's schedule
  final today = DateTime.now();
  final todayScheduledDay = activeRoutine.getScheduledDay(today);

  // Is today a rest day or different template?
  if (todayScheduledDay?.templateId != templateId || 
      todayScheduledDay?.status != DayStatus.scheduled) {
    
    // User completed Template X, but today isn't Template X
    // This is a swap opportunity!
    return SwapOpportunity(
      templateId: templateId,
      completedDate: today,
      originalScheduledDates: candidates,
      recommendedSwapTarget: _findBestSwapTarget(candidates, today),
    );
  }

  return null;
}
```

#### 2. executeSwap()
```dart
Future<void> executeSwap({
  required String routineId,
  required DateTime fromDate,    // Where user completed it
  required DateTime toDate,      // Where it's scheduled
  required String templateId,
  BuildContext? context,
}) async {
  try {
    // 1. Get routine
    final routine = await _repository.getRoutineById(routineId);
    if (routine == null) throw Exception('Routine not found');

    // 2. Get days
    final fromDay = routine.getScheduledDay(fromDate);
    final toDay = routine.getScheduledDay(toDate);

    if (fromDay == null || toDay == null) {
      throw Exception('Days not found');
    }

    // 3. Create swap metadata
    final swapMetadata = DaySwapMetadata(
      originalDay: _dateToString(toDate),
      swappedDay: _dateToString(fromDate),
      templateId: templateId,
      swappedAt: DateTime.now(),
      userId: _getCurrentUserId(),
    );

    // 4. Update both days atomically
    final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);
    
    // Mark target day as completed (where workout was done)
    updatedSchedule[_dateToString(toDate)] = toDay.copyWith(
      workoutId: fromDay.workoutId,
      status: DayStatus.completed,
      swappedWithDate: fromDate,
      swapMetadata: swapMetadata,
    );

    // Mark swap source day appropriately
    // Could be: rest, skipped, or keep as scheduled
    updatedSchedule[_dateToString(fromDate)] = fromDay.copyWith(
      status: DayStatus.skipped,
      skipReason: 'Swapped to ${_formatDate(toDate)}',
      swappedWithDate: toDate,
      swapMetadata: swapMetadata,
    );

    // 5. Save updated routine
    final updatedRoutine = routine.copyWith(
      schedule: updatedSchedule,
      completedDays: routine.completedDays + 1,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );

    await _repository.updateRoutine(updatedRoutine);

    // 6. Show success feedback
    if (context != null) {
      SnackBarService.showSuccess(
        context,
        'Workout swapped to ${_formatDate(toDate)} ✓',
      );
    }

  } catch (e) {
    if (context != null) {
      SnackBarService.showError(context, 'Swap failed: $e');
    }
    rethrow;
  }
}
```

### Data Classes
```dart
class SwapOpportunity {
  final String templateId;
  final DateTime completedDate;
  final List<DateTime> originalScheduledDates;  // Where Template X is scheduled
  final DateTime recommendedSwapTarget;         // Best candidate

  SwapOpportunity({
    required this.templateId,
    required this.completedDate,
    required this.originalScheduledDates,
    required this.recommendedSwapTarget,
  });
}
```

---

## 5. INTEGRATION POINTS

### Point A: RoutineAutoCompletionService Enhancement
**File:** `routine_auto_completion_service.dart`
**Current:** Lines 100-184

**Add new method:**
```dart
/// Check if swap is beneficial
/// Returns swap opportunity if detected
Future<SwapOpportunity?> detectSwapOpportunity({
  required Workout completedWorkout,
  required FlexibleRoutine activeRoutine,
}) async {
  final swapService = ref.read(routineSwapServiceProvider);
  return swapService.detectSwapOpportunity(
    completedWorkout: completedWorkout,
    activeRoutine: activeRoutine,
  );
}
```

**Modify tryAutoCompleteRoutineDay():**
```dart
Future<RoutineAutoCompletionResult> tryAutoCompleteRoutineDay({
  required Workout completedWorkout,
  BuildContext? context,
}) async {
  // ... existing code (lines 104-142) ...

  // NEW SECTION: Check for swap opportunity
  if (candidateDays.length > 1) {
    // Multi-day match detected
    final swapOp = await detectSwapOpportunity(
      completedWorkout: completedWorkout,
      activeRoutine: activeRoutine,
    );

    if (swapOp != null) {
      // Return SWAP opportunity instead of plain candidates
      return RoutineAutoCompletionResult.swapDetected(swapOp);
    }
  }

  // ... rest of existing code ...
}
```

**Update Result class:**
```dart
class RoutineAutoCompletionResult {
  // Existing fields...
  final SwapOpportunity? swapOpportunity;  // NEW

  // New factory
  factory RoutineAutoCompletionResult.swapDetected(SwapOpportunity swap) {
    return RoutineAutoCompletionResult(
      completed: false,
      reason: 'Swap opportunity detected',
      swapOpportunity: swap,
    );
  }
}
```

### Point B: workout_provider.dart Enhancement
**File:** `workout_provider.dart`
**Current:** Lines 643-663

**Enhanced _autoCompleteRoutineDay():**
```dart
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
    _showSwapDialog(context, result.swapOpportunity!, workout);
    return false; // Don't return completion yet - wait for user choice
  }

  // Case 3: Multiple candidates (no swap needed)
  if (result.candidateDates != null && result.candidateDates!.isNotEmpty) {
    _showDaySelectionSheet(context, result.candidateDates!, workout);
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
  // Dialog will show:
  // "You completed Template X on [today]"
  // "But it's scheduled for [recommendedDate]"
  // Options:
  // 1. "Use Recommended Date" (auto-swap)
  // 2. "Choose Another Date" (calendar picker)
  // 3. "Cancel"

  final result = await ModalService.showConfirmDialog(
    context,
    title: 'Swap Workout Day?',
    message: 'You completed ${workout.name} today.\n'
        'But it\'s scheduled for ${_formatDate(swapOp.recommendedSwapTarget)}.\n'
        'Swap it there?',
  );

  if (result) {
    // Execute swap
    final swapService = ref.read(routineSwapServiceProvider);
    await swapService.executeSwap(
      routineId: activeRoutine.id,
      fromDate: DateTime.now(),  // Where user completed it
      toDate: swapOp.recommendedSwapTarget,  // Where it's scheduled
      templateId: swapOp.templateId,
      context: context,
    );
  }
}
```

---

## 6. FIRESTORE TRANSACTION STRUCTURE

### Atomic Swap Update
```dart
// In firebase_flexible_routine_repository.dart
Future<void> swapDays({
  required String routineId,
  required DateTime fromDate,
  required DateTime toDate,
  required String templateId,
}) async {
  final firestore = FirebaseFirestore.instance;
  
  await firestore.runTransaction((transaction) async {
    final routineRef = firestore.collection('routines').doc(routineId);
    final routineDoc = await transaction.get(routineRef);

    if (!routineDoc.exists) throw Exception('Routine not found');

    final routine = FlexibleRoutine.fromJson(
      routineDoc.data() as Map<String, dynamic>,
    );

    // 1. Get both days
    final fromKey = _dateToString(fromDate);
    final toKey = _dateToString(toDate);
    
    final fromDay = routine.schedule[fromKey];
    final toDay = routine.schedule[toKey];

    if (fromDay == null || toDay == null) {
      throw Exception('Days not found');
    }

    // 2. Create swap metadata
    final swapMetadata = {
      'originalDay': toKey,
      'swappedDay': fromKey,
      'templateId': templateId,
      'swappedAt': FieldValue.serverTimestamp(),
    };

    // 3. Update both days
    final updatedSchedule = {...routine.schedule};
    
    updatedSchedule[toKey] = {
      ...toDay.toJson(),
      'status': 'completed',
      'swappedWithDate': fromDate.toIso8601String(),
      'swapMetadata': swapMetadata,
    };

    updatedSchedule[fromKey] = {
      ...fromDay.toJson(),
      'status': 'skipped',
      'skipReason': 'Swapped to ${toKey}',
      'swappedWithDate': toDate.toIso8601String(),
      'swapMetadata': swapMetadata,
    };

    // 4. Atomic update
    transaction.update(routineRef, {
      'schedule': updatedSchedule,
      'completedDays': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
}
```

---

## 7. IMPLEMENTATION CHECKLIST

### Phase 1: Data Model (Freezed entities)
- [ ] Add `swappedWithDate` field to ScheduledDay
- [ ] Add `swapMetadata` field to ScheduledDay
- [ ] Create DaySwapMetadata entity
- [ ] Run `dart run build_runner build`
- [ ] Update JSON serialization

### Phase 2: Service Layer
- [ ] Create RoutineSwapService
  - [ ] `detectSwapOpportunity()`
  - [ ] `executeSwap()`
  - [ ] `_findBestSwapTarget()`
- [ ] Add provider: `routineSwapServiceProvider`

### Phase 3: Business Logic Enhancement
- [ ] Update RoutineAutoCompletionService
  - [ ] Add `detectSwapOpportunity()` method
  - [ ] Modify `tryAutoCompleteRoutineDay()` result
  - [ ] Update RoutineAutoCompletionResult class
- [ ] Update RoutineAutoCompletionResult
  - [ ] Add `swapOpportunity` field
  - [ ] Add `swapDetected()` factory

### Phase 4: UI Layer
- [ ] Create SwapOpportunityDialog widget
- [ ] Update workout_provider.dart
  - [ ] Modify `_autoCompleteRoutineDay()`
  - [ ] Add `_showSwapDialog()`
  - [ ] Add `_showDaySelectionSheet()`
- [ ] Update FlexibleRoutineNotifier
  - [ ] Add `swapDays()` method

### Phase 5: Firestore Layer
- [ ] Update FlexibleRoutineRepository interface
  - [ ] Add `swapDays()` method signature
- [ ] Update FirebaseFlexibleRoutineRepository
  - [ ] Implement `swapDays()` with transaction
  - [ ] Handle error cases

### Phase 6: Testing & Polish
- [ ] Unit tests for swap detection
- [ ] Unit tests for swap execution
- [ ] Widget tests for swap dialog
- [ ] Integration tests with Firestore
- [ ] Analytics tracking for swaps

---

## 8. PSEUDOCODE: Complete Flow

```
USER SCENARIO: Completed Leg Day on Monday, but scheduled for Friday

┌─ Workout Completion Flow
│
├─ 1. User completes "Leg Day" workout on Monday
│     workout.templateId = "leg-day-123"
│     workout.endTime = Monday 6pm
│
├─ 2. Call _autoCompleteRoutineDay(workout, context)
│     
│     ├─ Call RoutineAutoCompletionService.tryAutoCompleteRoutineDay()
│     │
│     ├─ A. Get active routine
│     │     activeRoutine = "PPL 12-week"
│     │
│     ├─ B. Call _findCandidateDays(routine, "leg-day-123", Monday)
│     │     Loop through schedule:
│     │     - Monday: rest day ✗
│     │     - Tuesday: push-day ✗
│     │     - Wednesday: pull-day ✗
│     │     - Thursday: rest day ✗
│     │     - Friday: leg-day ✓
│     │     - Saturday: leg-day (next week) ✓
│     │
│     │     returns: [Friday, Saturday]
│     │
│     ├─ C. Multiple candidates found (length = 2)
│     │     
│     │     ├─ NEW: Call detectSwapOpportunity()
│     │     │   
│     │     │   Today = Monday (doesn't match "leg-day")
│     │     │   Recommended target = Friday (closest)
│     │     │
│     │     │   returns: SwapOpportunity(
│     │     │     templateId: "leg-day-123",
│     │     │     completedDate: Monday,
│     │     │     originalScheduledDates: [Friday, Saturday],
│     │     │     recommendedSwapTarget: Friday,
│     │     │   )
│     │     │
│     │     └─ Return RoutineAutoCompletionResult.swapDetected(swapOp)
│     │
│     └─ Return from tryAutoCompleteRoutineDay()
│
├─ 3. Back in workout_provider._autoCompleteRoutineDay()
│     Check result.swapOpportunity != null → TRUE
│     
│     ├─ Call _showSwapDialog(context, swapOp, workout)
│     │
│     └─ Dialog shows:
│         ┌─────────────────────────────────┐
│         │  Swap Workout Day?              │
│         ├─────────────────────────────────┤
│         │ You completed "Leg Day" today   │
│         │ But it's scheduled for Friday   │
│         │ Swap it there?                  │
│         ├─────────────────────────────────┤
│         │ [Use Friday] [Choose Date] [No] │
│         └─────────────────────────────────┘
│
├─ 4. User taps "Use Friday"
│     
│     ├─ Call RoutineSwapService.executeSwap(
│     │   routineId: "routine-456",
│     │   fromDate: Monday,
│     │   toDate: Friday,
│     │   templateId: "leg-day-123",
│     │   context: context,
│     │ )
│     │
│     └─ Inside executeSwap():
│         
│         ├─ Get routine from DB
│         ├─ Get both days from schedule
│         │   Monday ScheduledDay: {status: scheduled, templateId: null}
│         │   Friday ScheduledDay: {status: scheduled, templateId: "leg-day-123"}
│         │
│         ├─ Create swapMetadata = {
│         │   originalDay: "2025-03-21", (Friday)
│         │   swappedDay: "2025-03-17", (Monday)
│         │   templateId: "leg-day-123",
│         │   swappedAt: now,
│         │ }
│         │
│         ├─ Update Friday: {
│         │   status: completed,
│         │   workoutId: "workout-789",
│         │   swappedWithDate: Monday,
│         │   swapMetadata: {...},
│         │ }
│         │
│         ├─ Update Monday: {
│         │   status: skipped,
│         │   skipReason: "Swapped to Friday",
│         │   swappedWithDate: Friday,
│         │   swapMetadata: {...},
│         │ }
│         │
│         ├─ Update routine (Firebase transaction)
│         │   completedDays++
│         │   isSyncPending = true
│         │
│         └─ Show success toast
│             "Workout swapped to Friday ✓"
│
└─ 5. Success!
     Friday is now marked complete
     Monday is now marked skipped
     Both days have swap tracking metadata
```

---

## 9. CRITICAL IMPLEMENTATION NOTES

### Note 1: Preserve Existing Auto-Completion
The SWAP FLOW is an ENHANCEMENT, not a replacement:
- Single candidate → Auto-complete (existing behavior)
- Multiple candidates + swap detected → Show dialog (new behavior)
- Multiple candidates + no swap → Show day picker (existing TODO)

### Note 2: BuildContext Requirement
Swap dialog requires BuildContext for UI. If context is null:
```dart
// If no context available, don't show swap - just use first candidate
if (context == null) {
  // Fall back to auto-completing first candidate
  return RoutineAutoCompletionResult.success(candidates.first);
}
```

### Note 3: Firestore Atomicity
Must use transaction for swap to maintain data integrity:
- Two days updated together
- Both days get metadata
- Atomic increment of completedDays

### Note 4: SkipTracker Integration
May need to update SkipTracker when marking Monday as "skipped due to swap":
```dart
final newSkipTracker = skipTracker.addSkip(
  Monday,
  'Swapped to Friday - leg-day completed',
);
```

### Note 5: Analytics Tracking
Track swap operations:
```dart
final analytics = ref.read(analyticsServiceProvider);
analytics.trackEvent('workout_day_swapped', {
  'template_id': templateId,
  'from_date': Monday.toIso8601String(),
  'to_date': Friday.toIso8601String(),
  'swap_reason': 'mismatch_detection',
});
```

---

## 10. FUTURE ENHANCEMENTS

1. **User Preferences**: Let users control swap behavior
   - Always auto-swap
   - Always ask
   - Never swap (skip silently)

2. **Smart Swap Scheduling**: Suggest best target date based on:
   - Recovery time needed
   - Upcoming rest days
   - User's typical workout pattern

3. **Swap History**: Show past swaps for user analytics

4. **Batch Swap Recovery**: Recover multiple skipped days at once

5. **Swap Notifications**: Notify user of detected mismatches

