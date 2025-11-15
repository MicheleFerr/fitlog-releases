/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: entity
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE ENTITY - Advanced multi-period workout scheduling
///
/// This entity provides:
/// - Multi-period routines (weekly, monthly, bimonthly, semester, custom)
/// - Pattern-based scheduling (A, B, rest, C pattern repetition)
/// - Skip & recovery tracking
/// - Advanced analytics (adherence rate, skip rate, streaks)
/// - Firebase sync compatibility
///
/// Dependencies:
/// - Freezed: Code generation
/// - JSON serialization
/// - UUID: Unique identifiers
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pattern.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/skip_tracker.dart';

part 'flexible_routine.freezed.dart';
part 'flexible_routine.g.dart';

/// Enum for routine types (period duration)
enum RoutineType {
  /// Weekly routine (7 days cycle)
  weekly,

  /// Monthly routine (30 days)
  monthly,

  /// Bimonthly routine (60 days)
  bimonthly,

  /// Semester routine (180 days)
  semester,

  /// Custom period (user-defined dates)
  custom,
}

/// Extension methods for RoutineType
extension RoutineTypeExtension on RoutineType {
  /// Get display name for UI
  String get displayName {
    switch (this) {
      case RoutineType.weekly:
        return 'Weekly';
      case RoutineType.monthly:
        return 'Monthly';
      case RoutineType.bimonthly:
        return 'Bimonthly';
      case RoutineType.semester:
        return 'Semester';
      case RoutineType.custom:
        return 'Custom';
    }
  }

  /// Get default duration in days
  int get defaultDays {
    switch (this) {
      case RoutineType.weekly:
        return 7;
      case RoutineType.monthly:
        return 30;
      case RoutineType.bimonthly:
        return 60;
      case RoutineType.semester:
        return 180;
      case RoutineType.custom:
        return 0; // User defines
    }
  }
}

/// Status for individual scheduled days
enum DayStatus {
  /// Workout is scheduled but not done yet
  scheduled,

  /// Workout was completed successfully
  completed,

  /// Workout was skipped
  skipped,

  /// Skipped workout was recovered on another day
  recovered,

  /// Rest day (no workout scheduled)
  rest,
}

/// Extension methods for DayStatus
extension DayStatusExtension on DayStatus {
  /// Get icon for UI display
  String get icon {
    switch (this) {
      case DayStatus.scheduled:
        return '⊙';
      case DayStatus.completed:
        return '✓';
      case DayStatus.skipped:
        return '✗';
      case DayStatus.recovered:
        return '↻';
      case DayStatus.rest:
        return '-';
    }
  }

  /// Check if day is actionable (not completed or rest)
  bool get isActionable {
    return this == DayStatus.scheduled || this == DayStatus.skipped;
  }

  /// Check if day counts toward completion
  bool get countsAsCompleted {
    return this == DayStatus.completed || this == DayStatus.recovered;
  }
}

/// Represents a single scheduled day in the routine
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

  /// Factory for creating a scheduled workout day
  factory ScheduledDay.scheduled({
    required DateTime date,
    required String templateId,
  }) {
    return ScheduledDay(
      date: date,
      status: DayStatus.scheduled,
      templateId: templateId,
    );
  }

  /// Factory for creating a rest day
  factory ScheduledDay.rest({
    required DateTime date,
  }) {
    return ScheduledDay(
      date: date,
      status: DayStatus.rest,
    );
  }
}

/// Extension methods for ScheduledDay
extension ScheduledDayExtensions on ScheduledDay {
  /// Check if this is a rest day
  bool get isRestDay => status == DayStatus.rest || templateId == null;

  /// Check if this day can be recovered
  bool get canBeRecovered => status == DayStatus.skipped;

  /// Check if this is a recovery day
  bool get isRecoveryDay => originalDate != null;

  /// Mark day as completed
  ScheduledDay complete(String workoutId) {
    return copyWith(
      status: DayStatus.completed,
      workoutId: workoutId,
    );
  }

  /// Mark day as skipped
  ScheduledDay skip(String? reason) {
    return copyWith(
      status: DayStatus.skipped,
      skipReason: reason,
    );
  }

  /// Mark day as recovered
  ScheduledDay recover(DateTime originalDate) {
    return copyWith(
      status: DayStatus.recovered,
      originalDate: originalDate,
    );
  }
}

/// Recovery settings for the routine
@freezed
class RecoverySettings with _$RecoverySettings {
  const factory RecoverySettings({
    /// Allow automatic recovery suggestions
    @Default(true) bool suggestRecovery,

    /// Allow recovery on rest days
    @Default(true) bool allowRecoveryOnRestDays,

    /// Maximum days to suggest recovery for
    @Default(7) int maxRecoveryDays,

    /// Notify user about skipped workouts
    @Default(true) bool notifyOnSkip,
  }) = _RecoverySettings;

  factory RecoverySettings.fromJson(Map<String, dynamic> json) =>
      _$RecoverySettingsFromJson(json);

  /// Default recovery settings
  factory RecoverySettings.defaultSettings() {
    return const RecoverySettings();
  }
}

/// 🎯 FLEXIBLE ROUTINE ENTITY
///
/// Represents a multi-period workout routine with advanced scheduling.
/// Extends the concept of WeeklyRoutine to support longer periods and
/// flexible patterns beyond simple week cycles.
///
/// Example structure:
/// ```dart
/// FlexibleRoutine(
///   id: 'routine-123',
///   userId: 'user-456',
///   name: 'My 3-Month PPL',
///   type: RoutineType.monthly,
///   startDate: DateTime(2025, 1, 1),
///   endDate: DateTime(2025, 3, 31),
///   pattern: RoutinePattern(
///     sequence: ['push-id', 'pull-id', 'rest', 'legs-id'],
///     type: PatternType.repeating,
///   ),
///   schedule: {
///     DateTime(2025, 1, 1): ScheduledDay(...),
///     DateTime(2025, 1, 2): ScheduledDay(...),
///   },
/// )
/// ```
@freezed
class FlexibleRoutine with _$FlexibleRoutine {
  const factory FlexibleRoutine({
    // === CORE IDENTIFIER ===
    required String id,
    required String userId,

    // === BASIC INFO ===
    @Default('My Routine') String name,
    @Default('') String description,

    // === ROUTINE PERIOD ===
    required RoutineType type,
    required DateTime startDate,
    required DateTime endDate,

    // === PATTERN & SCHEDULING ===
    required RoutinePattern pattern,

    /// Map of date → scheduled day details
    required Map<String, ScheduledDay> schedule, // String key for JSON serialization

    // === SKIP & RECOVERY TRACKING ===
    required SkipTracker skipTracker,
    required RecoverySettings recoverySettings,

    // === ROUTINE STATE ===
    @Default(true) bool isActive, // Is this the current active routine
    @Default(false) bool isArchived, // Archived routines
    @Default(false) bool isCompleted, // Routine period ended

    // === METADATA ===
    required DateTime createdAt,
    DateTime? updatedAt,

    // === STATISTICS ===
    @Default(0) int totalWorkoutDays, // Total scheduled workouts in period
    @Default(0) int completedDays, // Days completed
    DateTime? lastWorkoutDate, // Last time user completed a workout

    // === SYNC FLAGS ===
    @Default(false) bool isSyncPending, // Needs sync to Firebase
  }) = _FlexibleRoutine;

  /// Factory for JSON deserialization
  factory FlexibleRoutine.fromJson(Map<String, dynamic> json) =>
      _$FlexibleRoutineFromJson(json);

  /// Factory for creating a new empty routine
  factory FlexibleRoutine.empty({
    required String userId,
    required RoutineType type,
    required DateTime startDate,
    required DateTime endDate,
    String? name,
  }) {
    return FlexibleRoutine(
      id: const Uuid().v4(),
      userId: userId,
      name: name ?? 'My Routine',
      type: type,
      startDate: startDate,
      endDate: endDate,
      pattern: RoutinePattern.empty(),
      schedule: {},
      skipTracker: SkipTracker.empty(),
      recoverySettings: RecoverySettings.defaultSettings(),
      createdAt: DateTime.now(),
      totalWorkoutDays: 0,
    );
  }

  /// Factory for creating a new routine with pattern
  ///
  /// NOTE: New routines are created as INACTIVE by default.
  /// User must manually activate them from Routine Center to avoid
  /// having multiple active routines at the same time.
  factory FlexibleRoutine.create({
    required String userId,
    required String name,
    required RoutineType type,
    required DateTime startDate,
    required DateTime endDate,
    required RoutinePattern pattern,
    String? description,
  }) {
    return FlexibleRoutine(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description ?? '',
      type: type,
      startDate: startDate,
      endDate: endDate,
      pattern: pattern,
      schedule: {},
      skipTracker: SkipTracker.empty(),
      recoverySettings: RecoverySettings.defaultSettings(),
      createdAt: DateTime.now(),
      totalWorkoutDays: 0,
      isActive: false, // ⚠️ Created as INACTIVE - user must activate manually
    );
  }
}

/// Extension methods for FlexibleRoutine
extension FlexibleRoutineExtensions on FlexibleRoutine {
  /// Get total duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalWorkoutDays == 0) return 0.0;
    return (completedDays / totalWorkoutDays).clamp(0.0, 1.0);
  }

  /// Get adherence rate (completed / scheduled) %
  double get adherenceRate {
    final elapsed = DateTime.now().difference(startDate).inDays + 1;
    final expectedCompleted = _getExpectedCompletedDays(elapsed);
    if (expectedCompleted == 0) return 0.0;
    return (completedDays / expectedCompleted * 100).clamp(0.0, 100.0);
  }

  /// Calculate expected completed days based on elapsed time
  /// ✅ FIX Bug #22: Normalize dates to midnight for correct comparison
  /// ✅ FIX Bug #25: Simplify date logic (>= startDate, < today)
  int _getExpectedCompletedDays(int elapsedDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    final scheduledDays = schedule.values
        .where((day) {
          if (day.isRestDay) return false;

          final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
          // ✅ FIX Bug #25: Clearer logic - day must be >= start AND < today
          return !dayDate.isBefore(start) && dayDate.isBefore(today);
        })
        .length;
    return scheduledDays;
  }

  /// 🆕 PUBLIC: Get workout days due up to today
  ///
  /// Returns count of workout days (not rest days) that were scheduled
  /// from start date until today (inclusive).
  ///
  /// Used for count-based recovery logic:
  /// - If completedDays < workoutsDueUpToToday → behind schedule
  /// - If completedDays >= workoutsDueUpToToday → on track or ahead
  ///
  /// Example:
  /// - Start date: Day 1
  /// - Today: Day 4
  /// - Schedule: W, W, R, W (2 workouts in first 3 days, 1 workout on day 4)
  /// - workoutsDueUpToToday = 3
  int get workoutsDueUpToToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return schedule.values
        .where((day) {
          // Only workout days (not rest)
          if (day.isRestDay) return false;

          // Only days up to today (past or today)
          final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
          return !dayDate.isAfter(today);
        })
        .length;
  }

  /// 🆕 PUBLIC: Get workouts behind schedule (count-based logic)
  ///
  /// Returns how many workouts the user is behind schedule.
  /// Uses count-based comparison, NOT date-based:
  /// - workoutsDue = number of workout days scheduled up to today
  /// - workoutsCompleted = number of workout days actually completed
  /// - behind = max(0, workoutsDue - workoutsCompleted)
  ///
  /// This logic correctly handles:
  /// - Workouts done on different days than scheduled
  /// - Multiple workouts done in one day
  /// - Skip + recovery in same week
  ///
  /// Example:
  /// - 4 days passed, 2 workouts due (day 4 and day 6)
  /// - User completed 2 workouts (day 4 and day 7)
  /// - workoutsBehind = max(0, 2 - 2) = 0 ✅ (on track!)
  ///
  /// Old logic would show:
  /// - 1 day to recover (because day 6 has status=skipped) ❌ WRONG
  int get workoutsBehindSchedule {
    final due = workoutsDueUpToToday;
    final completed = completedDays;
    return (due - completed).clamp(0, 9999);
  }

  /// Get skip rate percentage
  double get skipRate {
    return skipTracker.skipRate;
  }

  /// Check if routine is currently active period
  bool get isInActivePeriod {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Get scheduled day for a specific date
  ScheduledDay? getScheduledDay(DateTime date) {
    final key = _dateKey(date);
    return schedule[key];
  }

  /// Get day info for a specific date (alias for getScheduledDay)
  ScheduledDay? getDayInfo(DateTime date) {
    return getScheduledDay(date);
  }

  /// Get all skipped days that can be recovered
  List<ScheduledDay> get recoverableDays {
    return schedule.values
        .where((day) => day.canBeRecovered)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get next scheduled workout date
  DateTime? get nextWorkoutDate {
    final now = DateTime.now();
    final upcomingDays = schedule.values
        .where((day) =>
            !day.isRestDay &&
            day.status == DayStatus.scheduled &&
            day.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return upcomingDays.isNotEmpty ? upcomingDays.first.date : null;
  }

  /// Get next scheduled workout template ID
  String? get nextWorkoutTemplateId {
    final next = nextWorkoutDate;
    if (next == null) return null;
    return getScheduledDay(next)?.templateId;
  }

  /// Get current streak (consecutive completed days)
  int get currentStreak {
    int streak = 0;
    final sortedDays = schedule.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final day in sortedDays) {
      if (day.isRestDay) continue;
      if (day.status.countsAsCompleted) {
        streak++;
      } else if (day.date.isBefore(DateTime.now())) {
        break; // Streak broken
      }
    }

    return streak;
  }

  /// Mark a day as completed
  /// ✅ FIX Bug #18: Check if already completed (idempotency)
  FlexibleRoutine completeDay(DateTime date, String workoutId) {
    final key = _dateKey(date);
    final day = schedule[key];
    if (day == null) return this;

    // ✅ FIX Bug #18: Check if already completed - don't increment twice
    final alreadyCompleted = day.status.countsAsCompleted;

    final updatedDay = day.complete(workoutId);
    final newSchedule = Map<String, ScheduledDay>.from(schedule);
    newSchedule[key] = updatedDay;

    return copyWith(
      schedule: newSchedule,
      // ✅ FIX Bug #18: Only increment if not already completed
      completedDays: alreadyCompleted ? completedDays : completedDays + 1,
      lastWorkoutDate: date,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Mark a day as skipped
  /// ✅ FIX Bug #24: Check if already skipped (idempotency)
  FlexibleRoutine skipDay(DateTime date, String? reason) {
    final key = _dateKey(date);
    final day = schedule[key];
    if (day == null) return this;

    // ✅ FIX Bug #24: Check if already skipped - don't add to tracker twice
    final alreadySkipped = day.status == DayStatus.skipped;

    final updatedDay = day.skip(reason);
    final newSchedule = Map<String, ScheduledDay>.from(schedule);
    newSchedule[key] = updatedDay;

    // Update skip tracker only if not already skipped
    final newSkipTracker = alreadySkipped
        ? skipTracker
        : skipTracker.addSkip(date, reason);

    return copyWith(
      schedule: newSchedule,
      skipTracker: newSkipTracker,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Recover a skipped day on another date
  /// ✅ FIX Bug #19: Increment completedDays (recovered counts as completed)
  FlexibleRoutine recoverDay(DateTime originalDate, DateTime recoveryDate) {
    final originalKey = _dateKey(originalDate);
    final recoveryKey = _dateKey(recoveryDate);

    final originalDay = schedule[originalKey];
    if (originalDay == null || !originalDay.canBeRecovered) return this;

    // Check if recovery day is already completed
    final recoveryDay = schedule[recoveryKey];
    final recoveryAlreadyCompleted = recoveryDay?.status.countsAsCompleted ?? false;

    // Mark recovery date
    final recoveredDay = ScheduledDay.scheduled(
      date: recoveryDate,
      templateId: originalDay.templateId!,
    ).recover(originalDate);

    final newSchedule = Map<String, ScheduledDay>.from(schedule);
    newSchedule[recoveryKey] = recoveredDay;

    // Update skip tracker
    final newSkipTracker = skipTracker.addRecovery(originalDate, recoveryDate);

    return copyWith(
      schedule: newSchedule,
      skipTracker: newSkipTracker,
      // ✅ FIX Bug #19: Increment completedDays (recovered = completed)
      completedDays: recoveryAlreadyCompleted ? completedDays : completedDays + 1,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Generate schedule from pattern for the entire routine period
  FlexibleRoutine generateSchedule() {
    final days = pattern.generateSchedule(startDate, endDate);
    final scheduleMap = <String, ScheduledDay>{};

    int workoutCount = 0;
    for (final day in days) {
      scheduleMap[_dateKey(day.date)] = day;
      if (!day.isRestDay) workoutCount++;
    }

    return copyWith(
      schedule: scheduleMap,
      totalWorkoutDays: workoutCount,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Archive the routine
  FlexibleRoutine archive() {
    return copyWith(
      isArchived: true,
      isActive: false,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Activate the routine
  FlexibleRoutine activate() {
    return copyWith(
      isActive: true,
      isArchived: false,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Mark routine as completed (period ended)
  FlexibleRoutine complete() {
    return copyWith(
      isCompleted: true,
      isActive: false,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Get summary string for display
  String get summary {
    final progress = (progressPercentage * 100).toInt();
    final adherence = adherenceRate.toInt();
    return 'Progress: $progress% • Adherence: $adherence% • Skips: ${skipTracker.totalSkips}';
  }

  /// Check if today is a programmed workout day (more semantic than "isActiveToday")
  bool hasProgrammedWorkoutToday() {
    if (!isActive) return false;

    final today = DateTime.now();
    final todayScheduled = getScheduledDay(today);

    return todayScheduled != null &&
           !todayScheduled.isRestDay &&
           todayScheduled.status == DayStatus.scheduled;
  }

  /// Check if there's any uncompleted workout in the routine (not just today)
  bool hasUncompletedWorkout() {
    if (!isActive) return false;
    return getNextUncompletedWorkout() != null;
  }

  /// Get today's workout if scheduled, null otherwise
  ScheduledDay? getTodayWorkout() {
    final today = DateTime.now();
    final todayScheduled = getScheduledDay(today);

    if (todayScheduled == null || todayScheduled.isRestDay) {
      return null;
    }

    return todayScheduled;
  }

  /// Get next uncompleted workout starting from today
  /// Returns the first scheduled workout that is not completed, with correct template cycling
  ScheduledDay? getNextUncompletedWorkout() {
    final today = DateTime.now();

    // Calculate dynamic scan limit based on routine endDate
    // Cap at 90 days for performance (long semester routines)
    final daysToEnd = endDate.difference(today).inDays;
    final maxDays = daysToEnd.clamp(0, 90);

    // If we have a repeating pattern, we need to determine the next template in the cycle
    if (pattern.type == PatternType.repeating && pattern.sequence.isNotEmpty) {
      // Find the last completed workout to determine where we are in the cycle
      String? lastCompletedTemplate;

      // Search backwards from today to find the last completed workout
      for (int i = 0; i <= 30; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final day = getScheduledDay(checkDate);

        if (day != null && !day.isRestDay && day.status == DayStatus.completed) {
          lastCompletedTemplate = day.templateId;
          break;
        }
      }

      // If we found a last completed workout, determine the next template in the cycle
      if (lastCompletedTemplate != null) {
        // Get workout templates only (exclude rest days)
        final workoutTemplates = pattern.sequence
            .where((item) => item != RoutinePatternExtensions.restKeyword)
            .toList();

        if (workoutTemplates.isNotEmpty) {
          // Find the index of the last completed template
          final lastIndex = workoutTemplates.indexOf(lastCompletedTemplate);

          if (lastIndex != -1) {
            // Calculate the next template index (cycle back to 0 if at the end)
            final nextIndex = (lastIndex + 1) % workoutTemplates.length;
            final nextTemplateId = workoutTemplates[nextIndex];

            // Now find the next scheduled day and update its template
            for (int i = 0; i < maxDays; i++) {
              final checkDate = today.add(Duration(days: i));
              final scheduledDay = getScheduledDay(checkDate);

              // Find next non-rest, non-completed day
              if (scheduledDay != null &&
                  !scheduledDay.isRestDay &&
                  scheduledDay.status != DayStatus.completed) {

                // Return with the correct template from the cycle
                return ScheduledDay(
                  date: scheduledDay.date,
                  templateId: nextTemplateId,
                  status: scheduledDay.status,
                  workoutId: scheduledDay.workoutId,
                  skipReason: scheduledDay.skipReason,
                  originalDate: scheduledDay.originalDate,
                  notes: scheduledDay.notes,
                  isRecovery: scheduledDay.isRecovery,
                  originalMissedDate: scheduledDay.originalMissedDate,
                );
              }
            }
          }
        }
      }
    }

    // Fallback to the original logic for non-repeating patterns or if cycle detection fails
    for (int i = 0; i < maxDays; i++) {
      final checkDate = today.add(Duration(days: i));
      final scheduledDay = getScheduledDay(checkDate);

      // Skip if null or rest day
      if (scheduledDay == null || scheduledDay.isRestDay) {
        continue;
      }

      // Return first workout that is not completed
      if (scheduledDay.status != DayStatus.completed) {
        return scheduledDay;
      }
    }

    return null; // No uncompleted workout found in scan period
  }

  /// Get the name of the next workout in the rotation
  ///
  /// This is the SINGLE SOURCE OF TRUTH for workout rotation logic.
  ///
  /// Logic:
  /// 1. Find last completed workout in history (30-day window)
  /// 2. Calculate next index in sequence with rotation
  /// 3. Map template ID → template name via availableTemplates
  ///
  /// Returns null if:
  /// - Pattern is not repeating
  /// - No matching template found
  /// - Sequence is empty
  String? getNextWorkoutName({
    required List<dynamic> availableTemplates, // CustomWorkoutTemplate objects
  }) {
    // Pattern must be repeating
    if (pattern.type != PatternType.repeating || pattern.sequence.isEmpty) {
      return null;
    }

    final today = DateTime.now();
    String? lastCompletedTemplateId;

    // 1. Find last completed workout (30-day window)
    for (int i = 0; i <= 30; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final day = getScheduledDay(checkDate);

      if (day != null &&
          !day.isRestDay &&
          day.status == DayStatus.completed) {
        lastCompletedTemplateId = day.templateId;
        break;
      }
    }

    // 2. Calculate next index with rotation
    final workoutTemplates = pattern.sequence
        .where((item) => item != RoutinePatternExtensions.restKeyword)
        .toList();

    if (workoutTemplates.isEmpty) {
      return null;
    }

    String nextTemplateId;
    if (lastCompletedTemplateId != null) {
      final lastIndex = workoutTemplates.indexOf(lastCompletedTemplateId);
      if (lastIndex == -1) {
        // Fallback: start from beginning
        nextTemplateId = workoutTemplates.first;
      } else {
        // Rotate: (lastIndex + 1) % length
        final nextIndex = (lastIndex + 1) % workoutTemplates.length;
        nextTemplateId = workoutTemplates[nextIndex];
      }
    } else {
      // No history: start from first workout
      nextTemplateId = workoutTemplates.first;
    }

    // 3. Map template ID → name
    for (final template in availableTemplates) {
      try {
        // Safely access ID property
        String? templateId;
        if (template is Map) {
          templateId = template['id']?.toString();
        } else {
          try {
            templateId = (template as dynamic).id?.toString();
          } catch (_) {
            continue;
          }
        }

        // Check if this is the template we're looking for
        if (templateId == nextTemplateId) {
          // Extract name safely
          if (template is Map) {
            return template['name']?.toString();
          } else {
            try {
              return (template as dynamic).name?.toString();
            } catch (_) {
              return 'Workout';
            }
          }
        }
      } catch (e) {
        continue;
      }
    }

    // Template not found - return null to trigger fallback
    return null;
  }

  /// Convert date to string key for map
  /// ✅ FIX Bug #17: Unified date key format (always normalized to midnight)
  String _dateKey(DateTime date) {
    // Normalizza a mezzanotte per consistency
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  // ✅ NEW: Missed Workout Recovery Methods

  /// Check if should show recovery CTA
  /// Returns true if: yesterday had scheduled workout, and today has no completed workout
  /// ✅ FIX Bug #21: Simplified timezone logic (no more UTC conversions)
  bool shouldShowRecoveryCTA() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final yesterdayKey = _dateKey(yesterday);
    final todayKey = _dateKey(today);

    final yesterdayDay = schedule[yesterdayKey];
    final todayDay = schedule[todayKey];

    // Yesterday must have been scheduled (not rest, not completed)
    final yesterdayWasScheduled =
        yesterdayDay?.status == DayStatus.scheduled &&
        yesterdayDay?.templateId != null;

    // Today must not be completed yet
    final todayNotCompleted = todayDay == null ||
        (todayDay.status != DayStatus.completed &&
            todayDay.status != DayStatus.rest);

    return yesterdayWasScheduled && todayNotCompleted;
  }

  /// Get yesterday's missed workout (if any)
  /// ✅ FIX Bug #21: Use unified _dateKey instead of _dateKeyUtc
  ScheduledDay? getYesterdayMissedWorkout() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final yesterdayKey = _dateKey(yesterday);

    final yesterdayDay = schedule[yesterdayKey];
    if (yesterdayDay?.status == DayStatus.scheduled &&
        yesterdayDay?.templateId != null) {
      return yesterdayDay;
    }
    return null;
  }

  /// Check if a workout was completed today
  /// ✅ FIX Bug #21: Use unified _dateKey instead of _dateKeyUtc
  bool hasCompletedWorkoutToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = _dateKey(today);
    final todayDay = schedule[todayKey];
    return todayDay?.status == DayStatus.completed;
  }

  /// Apply missed workout recovery: skip yesterday, mark today as completed recovery
  /// ✅ FIX Bug #20: Check if today already completed (idempotency)
  /// ✅ FIX Bug #21: Use unified _dateKey instead of _dateKeyUtc
  FlexibleRoutine performMissedWorkoutRecovery(String workoutId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final yesterdayKey = _dateKey(yesterday);
    final todayKey = _dateKey(today);

    final updatedSchedule = Map<String, ScheduledDay>.from(schedule);

    // ✅ FIX Bug #20: Check idempotency - if today already completed, don't increment again
    final todayDay = updatedSchedule[todayKey];
    final alreadyCompleted = todayDay?.status == DayStatus.completed;

    // Update yesterday: mark as skipped
    if (updatedSchedule.containsKey(yesterdayKey)) {
      final yesterdayDay = updatedSchedule[yesterdayKey]!;
      updatedSchedule[yesterdayKey] = yesterdayDay.copyWith(
        status: DayStatus.skipped,
        skipReason: 'Recovered next day',
      );
    }

    // Update today: mark as completed recovery
    final todayScheduledDay = updatedSchedule[todayKey] ??
        ScheduledDay(
          date: today,
          status: DayStatus.completed,
        );

    updatedSchedule[todayKey] = todayScheduledDay.copyWith(
      status: DayStatus.completed,
      workoutId: workoutId,
      isRecovery: true,
      originalMissedDate: yesterday,
    );

    // Return updated routine
    return copyWith(
      schedule: updatedSchedule,
      // ✅ FIX Bug #20: Only increment if not already completed
      completedDays: alreadyCompleted ? completedDays : completedDays + 1,
      lastWorkoutDate: today,
    );
  }
}
