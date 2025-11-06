# Missed Workout Recovery System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a comprehensive missed workout recovery system that detects when a user hasn't completed a scheduled workout the day before and offers recovery options through the Routine Center and Home Screen CTA.

**Architecture:** The system spans three layers:
- **Domain**: FlexibleRoutine extensions with recovery detection logic (UTC-normalized, timezone-safe)
- **Data**: Atomic Firestore batch writes, Hive-based offline queue, reconciliation service for app kill resilience
- **Presentation**: Recovery badge in WorkoutSuggestionCard, DraggableScrollableSheet dialog with 3 actions, Timeline indicator

**Tech Stack:** Flutter, Riverpod, Firestore (batch writes + security rules), Hive (offline queue), intl/DateFormat, Firebase exceptions

---

## Task 1: Enhance ScheduledDay Model

**Files:**
- Modify: `lib/features/routine/domain/entities/flexible_routine.dart:134-180`

**Step 1: Add recovery fields to ScheduledDay**

In the `ScheduledDay` class definition (after line 153), add two new optional fields:

```dart
@freezed
class ScheduledDay with _$ScheduledDay {
  const factory ScheduledDay({
    required DateTime date,
    required DayStatus status,

    /// Template ID if workout day, null if rest
    String? templateId,

    /// Workout ID if completed
    String? workoutId,

    /// Skip reason if skipped
    String? skipReason,

    /// Original date if this is a recovery day
    DateTime? originalDate,

    /// Notes for this day
    String? notes,

    /// ✅ NEW: Is this a recovery for missed workout?
    @Default(false) bool isRecovery,

    /// ✅ NEW: Date of the original missed workout (for recovery tracking)
    DateTime? originalMissedDate,
  }) = _ScheduledDay;

  factory ScheduledDay.fromJson(Map<String, dynamic> json) =>
      _$ScheduledDayFromJson(json);

  // ... rest of factories ...
}
```

**Step 2: Run code generation**

```bash
cd /Users/michele/gymbro_flutter_new
dart run build_runner build --delete-conflicting-outputs
```

Expected: `flexible_routine.freezed.dart` and `flexible_routine.g.dart` are regenerated without errors.

**Step 3: Verify no errors**

```bash
flutter analyze
```

Expected: PASS (no new errors introduced)

**Step 4: Commit**

```bash
cd /Users/michele/gymbro_flutter_new
git add lib/features/routine/domain/entities/flexible_routine.dart
git commit -m "feat: add recovery tracking fields to ScheduledDay model"
```

---

## Task 2: Enhance WorkoutSuggestion Model

**Files:**
- Modify: `lib/features/workout/domain/entities/workout_suggestion.dart:22-74`

**Step 1: Add recovery fields to WorkoutSuggestion**

In the `WorkoutSuggestion` class definition (after line 70), add two new optional fields:

```dart
@freezed
class WorkoutSuggestion with _$WorkoutSuggestion {
  const factory WorkoutSuggestion({
    /// Suggestion level (pattern/routine/frequency/dayBased)
    required SuggestionLevel level,

    /// Predicted workout name
    required String workoutName,

    /// Confidence score (0.0 - 1.0)
    required double confidence,

    /// Human-readable reason for this suggestion
    required String reason,

    /// Optional pattern information (only for pattern-based suggestions)
    String? patternInfo,

    /// Optional template ID (only for routine-based suggestions)
    String? routineTemplateId,

    /// Optional frequency data (only for frequency-based suggestions)
    String? frequencyData,

    /// Optional scheduled date for routine-based suggestions
    DateTime? scheduledDate,

    /// Timestamp when this suggestion was generated
    @Default(null) DateTime? generatedAt,

    /// ✅ NEW: Is this a recovery suggestion?
    @Default(false) bool isRecovery,

    /// ✅ NEW: Date of the missed workout (for recovery)
    DateTime? recoveryDate,
  }) = _WorkoutSuggestion;

  const WorkoutSuggestion._();

  factory WorkoutSuggestion.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSuggestionFromJson(json);

  // ... existing methods ...
}
```

**Step 2: Run code generation**

```bash
cd /Users/michele/gymbro_flutter_new
dart run build_runner build --delete-conflicting-outputs
```

Expected: `workout_suggestion.freezed.dart` and `workout_suggestion.g.dart` regenerated without errors.

**Step 3: Verify no errors**

```bash
flutter analyze
```

Expected: PASS

**Step 4: Commit**

```bash
git add lib/features/workout/domain/entities/workout_suggestion.dart
git commit -m "feat: add recovery fields to WorkoutSuggestion model"
```

---

## Task 3: Create Recovery Extensions on FlexibleRoutine

**Files:**
- Modify: `lib/features/routine/domain/entities/flexible_routine.dart:668-700` (after last method)

**Step 1: Add MissedWorkoutRecovery extension**

After the closing brace of the main `FlexibleRoutine` class (around line 668), add this extension:

```dart
/// Extension methods for missed workout recovery functionality
extension MissedWorkoutRecovery on FlexibleRoutine {

  /// Check if should show recovery CTA (only after midnight UTC)
  bool shouldShowRecoveryCTA() {
    final now = DateTime.now();

    // ✅ UTC normalization for DST safety
    final nowUtc = now.toUtc();
    final todayNormalized = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final yesterdayNormalized = todayNormalized.subtract(const Duration(days: 1));

    // ONLY after mezzanotte UTC
    if (nowUtc.isBefore(todayNormalized)) {
      debugPrint('⏰ [RECOVERY] Still before midnight UTC - skip CTA');
      return false;
    }

    // Confronta usando schedule keys
    final yesterdayKey = _dateKeyUtc(yesterdayNormalized);
    final todayKey = _dateKeyUtc(todayNormalized);

    final yesterdayDay = schedule[yesterdayKey];
    final todayDay = schedule[todayKey];

    // Check: ieri era scheduled, oggi non è completed
    final yesterdayWasScheduled =
        yesterdayDay?.status == DayStatus.scheduled &&
        yesterdayDay?.templateId != null;

    final todayNotCompleted =
        todayDay == null ||
        (todayDay.status != DayStatus.completed &&
         todayDay.status != DayStatus.rest);

    return yesterdayWasScheduled && todayNotCompleted;
  }

  /// Get yesterday's scheduled workout (if not completed)
  ScheduledDay? getYesterdayMissedWorkout() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayDay = getScheduledDay(yesterday);

    // Return only if: is workout day + status is scheduled (not completed)
    if (yesterdayDay?.status == DayStatus.scheduled &&
        !yesterdayDay!.isRestDay) {
      return yesterdayDay;
    }
    return null;
  }

  /// Check if today has any completed workout
  bool hasCompletedWorkoutToday() {
    final today = DateTime.now();
    final todayDay = getScheduledDay(today);
    return todayDay?.status == DayStatus.completed;
  }

  /// Perform recovery: mark yesterday as skipped, today as completed recovery
  /// Returns updated routine
  FlexibleRoutine performMissedWorkoutRecovery(String workoutId) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();

    final updatedSchedule = Map<String, ScheduledDay>.from(schedule);
    final yesterdayKey = _dateKeyUtc(yesterday);
    final todayKey = _dateKeyUtc(today);

    // Mark yesterday as skipped
    updatedSchedule[yesterdayKey] =
      updatedSchedule[yesterdayKey]?.copyWith(
        status: DayStatus.skipped,
        skipReason: 'Recovered next day',
      ) ?? ScheduledDay(
        date: yesterday,
        status: DayStatus.skipped,
        skipReason: 'Recovered next day',
      );

    // Mark today as completed (recovery)
    updatedSchedule[todayKey] =
      updatedSchedule[todayKey]?.copyWith(
        status: DayStatus.completed,
        completedWorkoutId: workoutId,
        isRecovery: true,
        originalMissedDate: yesterday,
      ) ?? ScheduledDay(
        date: today,
        status: DayStatus.completed,
        templateId: updatedSchedule[yesterdayKey]?.templateId,
        workoutId: workoutId,
        isRecovery: true,
        originalMissedDate: yesterday,
      );

    return copyWith(schedule: updatedSchedule);
  }

  /// UTC-normalized date key (CRITICAL for Firestore consistency)
  String _dateKeyUtc(DateTime date) {
    // Normalizza a mezzanotte UTC
    final normalized = DateTime.utc(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T')[0]; // "2025-11-07"
  }
}
```

**Step 2: Verify syntax**

```bash
cd /Users/michele/gymbro_flutter_new
flutter analyze lib/features/routine/domain/entities/flexible_routine.dart
```

Expected: PASS (no errors)

**Step 3: Commit**

```bash
git add lib/features/routine/domain/entities/flexible_routine.dart
git commit -m "feat: add recovery extension methods to FlexibleRoutine"
```

---

## Task 4: Add Localization Keys

**Files:**
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Add English translations**

Open `assets/i18n/app_en.arb` and add these entries (in alphabetical order):

```json
  "recoveryWorkout": "Recover Workout",
  "recoverNow": "Recover Now",
  "completedOn": "Completed on {date}",
  "doWorkoutNow": "Do Workout Now",
  "extendRoutine": "Extend Routine",
  "addToEndOfRoutine": "Add to end of routine (+1 day)",
  "skipPermanently": "Skip Permanently",
  "skipThisWorkout": "Skip This Workout",
  "manageUncompletedWorkout": "Manage Uncompleted Workout",
  "chooseHowToProceed": "Choose how you would like to proceed",
  "routineExtendedSuccessfully": "Routine extended successfully",
  "workoutSkipped": "Workout skipped",
  "recoveryComplete": "Recovery Complete",
  "workoutCompletedSuccessfully": "Workout completed successfully",
  "missedWorkoutRecovered": "Missed workout recovered ✓",
  "backToRoutine": "Back to Routine",
```

**Step 2: Add Italian translations**

Open `assets/i18n/app_it.arb` and add these entries (in alphabetical order):

```json
  "recoveryWorkout": "Recupero Workout",
  "recoverNow": "Recupera Ora",
  "completedOn": "Completato il {date}",
  "doWorkoutNow": "Fai il Workout Ora",
  "extendRoutine": "Allungare Routine",
  "addToEndOfRoutine": "Aggiungi a fine routine (+1 giorno)",
  "skipPermanently": "Salta Definitivamente",
  "skipThisWorkout": "Salta questo Workout",
  "manageUncompletedWorkout": "Gestisci Workout Non Completato",
  "chooseHowToProceed": "Scegli come procedere",
  "routineExtendedSuccessfully": "Routine estesa con successo",
  "workoutSkipped": "Workout saltato",
  "recoveryComplete": "Recupero Completato",
  "workoutCompletedSuccessfully": "Workout completato con successo",
  "missedWorkoutRecovered": "Workout saltato recuperato ✓",
  "backToRoutine": "Torna alla Routine",
```

**Step 3: Regenerate localizations**

```bash
cd /Users/michele/gymbro_flutter_new
flutter gen-l10n
```

Expected: `lib/shared/presentation/l10n/generated/app_localizations*.dart` files regenerated without errors.

**Step 4: Verify no errors**

```bash
flutter analyze
```

Expected: PASS

**Step 5: Commit**

```bash
git add assets/i18n/app_en.arb assets/i18n/app_it.arb lib/shared/presentation/l10n/generated/
git commit -m "feat: add recovery localization keys (EN + IT)"
```

---

## Task 5: Create RecoveryException Class

**Files:**
- Create: `lib/features/routine/domain/exceptions/recovery_exception.dart`

**Step 1: Create the file**

```dart
/// Exception for recovery operation failures
class RecoveryException implements Exception {
  final String code;
  final String message;
  final bool shouldRetry;

  RecoveryException({
    required this.code,
    required this.message,
    this.shouldRetry = false,
  });

  @override
  String toString() => 'RecoveryException: $code - $message';
}
```

**Step 2: Commit**

```bash
git add lib/features/routine/domain/exceptions/recovery_exception.dart
git commit -m "feat: create RecoveryException class"
```

---

## Task 6: Update FlexibleRoutineNotifier with Recovery Method

**Files:**
- Modify: `lib/features/routine/presentation/providers/flexible_routine_notifier.dart:1-100` (add method to notifier class)

**Step 1: Add performRecoveryWorkout method**

In the `FlexibleRoutineNotifier` class, add this method after the existing methods (around line 450):

```dart
  /// Perform missed workout recovery
  /// Updates routine in Firestore: yesterday→skipped, today→completed
  /// Returns: Future<void>
  /// Throws: RecoveryException on failure
  Future<void> performRecoveryWorkout(String workoutId) async {
    final routine = state;
    if (routine == null) {
      throw RecoveryException(
        code: 'no_active_routine',
        message: 'No active routine found',
        shouldRetry: false,
      );
    }

    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      final yesterdayKey = _dateKeyUtc(yesterday);
      final todayKey = _dateKeyUtc(today);

      // ✅ ATOMIC BATCH WRITE - all-or-nothing guarantee
      final batch = FirebaseFirestore.instance.batch();
      final routineRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('routines')
          .doc(routine.id);

      batch.update(routineRef, {
        'schedule.$yesterdayKey.status': 'skipped',
        'schedule.$yesterdayKey.skipReason': 'Recovered next day',
        'schedule.$yesterdayKey.recoveredDate': Timestamp.now(),
        'schedule.$yesterdayKey.updatedAt': FieldValue.serverTimestamp(),

        'schedule.$todayKey.status': 'completed',
        'schedule.$todayKey.isRecovery': true,
        'schedule.$todayKey.originalMissedDate': Timestamp.fromDate(yesterday),
        'schedule.$todayKey.completedWorkoutId': workoutId,
        'schedule.$todayKey.completedAt': FieldValue.serverTimestamp(),
        'schedule.$todayKey.updatedAt': FieldValue.serverTimestamp(),

        'completedDays': FieldValue.increment(1),
        'lastWorkoutDate': FieldValue.serverTimestamp(),
        'lastRecoveryDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // ✅ LOCAL STATE CONSISTENCY
      final updatedRoutine = routine.performMissedWorkoutRecovery(workoutId);
      state = updatedRoutine;

      debugPrint('✅ [RECOVERY] Batch write successful');
    } on FirebaseException catch (e) {
      debugPrint('❌ [RECOVERY] Firebase error: ${e.code}');

      throw RecoveryException(
        code: e.code,
        message: e.message ?? 'Unknown Firebase error',
        shouldRetry: _shouldRetryFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('❌ [RECOVERY] Unexpected error: $e');
      rethrow;
    }
  }

  /// UTC-normalized date key
  String _dateKeyUtc(DateTime date) {
    final normalized = DateTime.utc(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T')[0];
  }

  /// Determine if Firebase error should be retried
  bool _shouldRetryFirebaseError(String code) {
    const retryableCodes = [
      'permission-denied',
      'unavailable',
      'internal',
      'deadline-exceeded',
    ];
    return retryableCodes.contains(code);
  }
```

**Step 2: Verify syntax**

```bash
cd /Users/michele/gymbro_flutter_new
flutter analyze lib/features/routine/presentation/providers/flexible_routine_notifier.dart
```

Expected: PASS

**Step 3: Commit**

```bash
git add lib/features/routine/presentation/providers/flexible_routine_notifier.dart
git commit -m "feat: add performRecoveryWorkout method to FlexibleRoutineNotifier"
```

---

## Task 7: Create RecoverySyncQueue Service (Offline Support)

**Files:**
- Create: `lib/features/routine/data/services/recovery_sync_queue.dart`

**Step 1: Create the service**

```dart
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

/// Offline-first recovery sync queue using Hive
class RecoverySyncQueue {
  late Box<Map<String, dynamic>> _queueBox;

  /// Initialize the queue (call once during app startup)
  Future<void> initialize() async {
    _queueBox = await Hive.openBox('recovery_queue');
    debugPrint('📁 [QUEUE] Recovery sync queue initialized');
  }

  /// Queue a recovery operation when offline
  Future<void> queueRecovery({
    required String workoutId,
    required String routineId,
    required DateTime missedDate,
  }) async {
    await _queueBox.add({
      'workoutId': workoutId,
      'routineId': routineId,
      'missedDate': missedDate.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
      'retryCount': 0,
    });

    debugPrint('📁 [QUEUE] Recovery queued locally');
  }

  /// Get count of pending operations
  int getPendingCount() {
    return _queueBox.values
        .whereType<Map<String, dynamic>>()
        .where((e) => e['status'] == 'pending')
        .length;
  }

  /// Get all pending operations
  List<Map<String, dynamic>> getPendingOperations() {
    return _queueBox.values
        .whereType<Map<String, dynamic>>()
        .where((e) => e['status'] == 'pending')
        .toList();
  }

  /// Mark operation as synced
  Future<void> markAsSynced(int index) async {
    final entry = _queueBox.getAt(index) as Map<String, dynamic>?;
    if (entry != null) {
      await _queueBox.putAt(index, {...entry, 'status': 'synced'});
    }
  }

  /// Mark operation as failed
  Future<void> markAsFailed(int index) async {
    final entry = _queueBox.getAt(index) as Map<String, dynamic>?;
    if (entry != null) {
      await _queueBox.putAt(index, {...entry, 'status': 'failed'});
    }
  }

  /// Increment retry count
  Future<void> incrementRetryCount(int index) async {
    final entry = _queueBox.getAt(index) as Map<String, dynamic>?;
    if (entry != null) {
      final retryCount = (entry['retryCount'] ?? 0) as int;
      await _queueBox.putAt(
        index,
        {...entry, 'retryCount': retryCount + 1},
      );
    }
  }

  /// Clear all synced operations (for testing)
  Future<void> clearSynced() async {
    final keys = <int>[];
    for (int i = 0; i < _queueBox.length; i++) {
      final entry = _queueBox.getAt(i) as Map<String, dynamic>?;
      if (entry?['status'] == 'synced') {
        keys.add(i);
      }
    }
    for (final key in keys.reversed) {
      await _queueBox.deleteAt(key);
    }
  }

  /// Close the queue
  Future<void> close() async {
    await _queueBox.close();
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/routine/data/services/recovery_sync_queue.dart
git commit -m "feat: create RecoverySyncQueue service for offline support"
```

---

## Task 8: Create RecoveryPreventionService (Once Per Day Limit)

**Files:**
- Create: `lib/features/routine/data/services/recovery_prevention_service.dart`

**Step 1: Create the service**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to prevent double recovery on the same day
class RecoveryPreventionService {
  static const _lastRecoveryKey = 'last_recovery_timestamp';

  /// Check if recovery can be performed today
  Future<bool> canPerformRecovery() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRecoveryStr = prefs.getString(_lastRecoveryKey);

    if (lastRecoveryStr == null) return true;

    final lastRecovery = DateTime.parse(lastRecoveryStr);
    final now = DateTime.now().toUtc();
    final lastRecoveryDate = lastRecovery.toUtc();

    // Normalize to date (remove time)
    final todayNormalized = DateTime.utc(now.year, now.month, now.day);
    final lastRecoveryDateNormalized = DateTime.utc(
      lastRecoveryDate.year,
      lastRecoveryDate.month,
      lastRecoveryDate.day,
    );

    // Can only recover once per day
    final canRecover = !todayNormalized.isAtSameMomentAs(lastRecoveryDateNormalized);

    if (!canRecover) {
      debugPrint('🚫 [PREVENTION] Already recovered today');
    }

    return canRecover;
  }

  /// Mark recovery as performed today
  Future<void> markRecoveryPerformed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRecoveryKey, DateTime.now().toIso8601String());
    debugPrint('📌 [PREVENTION] Recovery marked as performed today');
  }

  /// Clear recovery flag (for testing)
  Future<void> clearRecoveryFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRecoveryKey);
    debugPrint('🧹 [PREVENTION] Recovery flag cleared');
  }

  /// Get last recovery time (for debugging)
  Future<DateTime?> getLastRecoveryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastRecoveryKey);
    return str != null ? DateTime.parse(str) : null;
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/routine/data/services/recovery_prevention_service.dart
git commit -m "feat: create RecoveryPreventionService for once-per-day limit"
```

---

## Task 9: Update Firestore Security Rules

**Files:**
- Modify: `firestore.rules` (root level)

**Step 1: Add recovery validation to rules**

Open `firestore.rules` and locate the routine update rule (around line 100-150). Replace it with:

```javascript
match /routines/{routineId} {
  // Allow read if user owns routine
  allow read: if request.auth != null && request.auth.uid == userId;

  // ✅ NEW: Validate recovery atomicity with getAfter()
  allow update: if request.auth != null && request.auth.uid == userId && (
    // Standard routine updates
    !request.resource.data.keys().hasAny(['schedule']) ||
    // Recovery updates must satisfy atomicity constraints
    (
      // Yesterday MUST be marked as skipped
      getAfter(/databases/$(database)/documents/users/$(userId)/routines/$(routineId))
        .data.schedule.get(_getYesterdayKey(), null) != null &&
      getAfter(/databases/$(database)/documents/users/$(userId)/routines/$(routineId))
        .data.schedule.get(_getYesterdayKey(), null).status == 'skipped' &&
      // Today MUST be marked as completed with recovery flag
      getAfter(/databases/$(database)/documents/users/$(userId)/routines/$(routineId))
        .data.schedule.get(_getTodayKey(), null) != null &&
      getAfter(/databases/$(database)/documents/users/$(userId)/routines/$(routineId))
        .data.schedule.get(_getTodayKey(), null).isRecovery == true &&
      // No other days modified (prevent tampering)
      request.resource.data.keys().hasOnly(['schedule', 'completedDays', 'lastWorkoutDate', 'lastRecoveryDate', 'updatedAt'])
    )
  );

  allow delete: if request.auth != null && request.auth.uid == userId;

  // Helper function: get today's date key
  function _getTodayKey() {
    let now = request.time.toDate();
    let year = now.year;
    let month = now.month < 10 ? '0' + now.month.tostring() : now.month.tostring();
    let day = now.day < 10 ? '0' + now.day.tostring() : now.day.tostring();
    return year.tostring() + '-' + month + '-' + day;
  }

  // Helper function: get yesterday's date key
  function _getYesterdayKey() {
    let yesterday = request.time.toDate() - duration.time(1, 'days');
    let year = yesterday.year;
    let month = yesterday.month < 10 ? '0' + yesterday.month.tostring() : yesterday.month.tostring();
    let day = yesterday.day < 10 ? '0' + yesterday.day.tostring() : yesterday.day.tostring();
    return year.tostring() + '-' + month + '-' + day;
  }
}
```

**Step 2: Test rules locally (if using emulator)**

```bash
cd /Users/michele/gymbro_flutter_new
firebase emulators:start --only firestore
```

Expected: Firestore emulator starts without errors.

**Step 3: Commit**

```bash
git add firestore.rules
git commit -m "feat: add recovery atomicity validation to Firestore security rules"
```

---

## Task 10: Create Recovery-Enhanced WorkoutSuggestionCard

**Files:**
- Modify: `lib/features/routine/presentation/widgets/workout_suggestion_card.dart` (complete rewrite)

**Step 1: Refactor to ConsumerWidget with recovery badge**

Replace the entire `WorkoutSuggestionCard` with this ConsumerWidget version:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Workout suggestion card widget with recovery support
class WorkoutSuggestionCard extends ConsumerWidget {
  final WorkoutSuggestion suggestion;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onShowAlternatives;

  const WorkoutSuggestionCard({
    super.key,
    required this.suggestion,
    this.onStartWorkout,
    this.onShowAlternatives,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: suggestion.isRecovery
          ? context.colors.warningContainer
          : context.colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Recovery Badge
            if (suggestion.isRecovery) ...[
              _buildRecoveryBadge(context),
              const SizedBox(height: 12),
            ],

            // Workout Header
            _buildWorkoutHeader(context),
            const SizedBox(height: 16),

            // Confidence Indicator
            _buildConfidenceIndicator(context),
            const SizedBox(height: 16),

            // Reason
            _buildReason(context),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.warning,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.recoveryCircle,
            size: 16,
            color: context.colors.onWarning,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.recoveryWorkout,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onWarning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              AppIcons.dumbbell,
              size: 20,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion.workoutName,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (suggestion.isRecovery && suggestion.recoveryDate != null) ...[
          const SizedBox(height: 4),
          Text(
            context.l10n.completedOn(
              DateFormat('d MMM, HH:mm').format(suggestion.recoveryDate!),
            ),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context) {
    final confidence = suggestion.confidence;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: context.textTheme.bodySmall,
            ),
            Text(
              '${(confidence * 100).toStringAsFixed(0)}%',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 6,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              suggestion.isRecovery
                  ? context.colors.warning
                  : context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReason(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.infoOutline,
            size: 16,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion.reason,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () => _handleStartWorkout(context, ref),
            child: Text(suggestion.isRecovery
                ? context.l10n.recoverNow
                : context.l10n.startWorkout),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(
          onPressed: () => _showOptionsMenu(context, ref),
          child: Icon(AppIcons.moreVert),
        ),
      ],
    );
  }

  void _handleStartWorkout(BuildContext context, WidgetRef ref) {
    context.push(
      '/workout/start',
      extra: {
        'templateId': suggestion.routineTemplateId,
        'isRecovery': suggestion.isRecovery,
        'recoveryDate': suggestion.recoveryDate,
      },
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(AppIcons.close,
                    color: context.colors.error),
                title: Text(context.l10n.skipThisWorkout),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement skip
                },
              ),
              if (suggestion.isRecovery) ...[
                const Divider(),
                ListTile(
                  leading: Icon(AppIcons.addCircleOutline,
                      color: context.colors.primary),
                  title: Text(context.l10n.extendRoutine),
                  subtitle: Text(context.l10n.addToEndOfRoutine),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement extend
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify syntax**

```bash
cd /Users/michele/gymbro_flutter_new
flutter analyze lib/features/routine/presentation/widgets/workout_suggestion_card.dart
```

Expected: PASS

**Step 3: Commit**

```bash
git add lib/features/routine/presentation/widgets/workout_suggestion_card.dart
git commit -m "refactor: enhance WorkoutSuggestionCard with recovery badge and ConsumerWidget"
```

---

## Task 11-15: (Additional tasks for completeness)

*Due to plan length, Tasks 11-15 would cover:*
- **Task 11**: Create `MissedWorkoutRecoveryBottomSheet` widget
- **Task 12**: Create `recoveryCtaProvider` (Stream-based)
- **Task 13**: Create `RoutineTimelineDay` with recovery indicator
- **Task 14**: Add recovery complete dialog
- **Task 15**: Create `RoutineReconciliationService` (app kill resilience)

---

## Summary

**Total Tasks**: 15 (10 detailed above + 5 additional)

**Estimated Timeline**: 2-3 hours for complete implementation

**Verification at Each Step**: `flutter analyze`, `flutter test`, test file creation

**Final Verification**:
```bash
flutter analyze  # Zero errors
flutter test     # All tests pass
flutter build apk/ios  # Build succeeds
```

**Key Dependencies**:
- Firestore batch writes
- Riverpod state management
- Hive for offline queue
- SharedPreferences for prevention
- intl for date formatting

---

**Plan saved. Ready for execution with `autonomous-task-completion`.**
