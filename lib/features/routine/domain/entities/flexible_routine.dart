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
  int _getExpectedCompletedDays(int elapsedDays) {
    final scheduledDays = schedule.values
        .where((day) =>
            !day.isRestDay &&
            day.date.isBefore(DateTime.now()) &&
            day.date.isAfter(startDate.subtract(const Duration(days: 1))))
        .length;
    return scheduledDays;
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
  FlexibleRoutine completeDay(DateTime date, String workoutId) {
    final key = _dateKey(date);
    final day = schedule[key];
    if (day == null) return this;

    final updatedDay = day.complete(workoutId);
    final newSchedule = Map<String, ScheduledDay>.from(schedule);
    newSchedule[key] = updatedDay;

    return copyWith(
      schedule: newSchedule,
      completedDays: completedDays + 1,
      lastWorkoutDate: date,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Mark a day as skipped
  FlexibleRoutine skipDay(DateTime date, String? reason) {
    final key = _dateKey(date);
    final day = schedule[key];
    if (day == null) return this;

    final updatedDay = day.skip(reason);
    final newSchedule = Map<String, ScheduledDay>.from(schedule);
    newSchedule[key] = updatedDay;

    // Update skip tracker
    final newSkipTracker = skipTracker.addSkip(date, reason);

    return copyWith(
      schedule: newSchedule,
      skipTracker: newSkipTracker,
      updatedAt: DateTime.now(),
      isSyncPending: true,
    );
  }

  /// Recover a skipped day on another date
  FlexibleRoutine recoverDay(DateTime originalDate, DateTime recoveryDate) {
    final originalKey = _dateKey(originalDate);
    final recoveryKey = _dateKey(recoveryDate);

    final originalDay = schedule[originalKey];
    if (originalDay == null || !originalDay.canBeRecovered) return this;

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

  /// Get today's workout if scheduled, null otherwise
  ScheduledDay? getTodayWorkout() {
    final today = DateTime.now();
    final todayScheduled = getScheduledDay(today);

    if (todayScheduled == null || todayScheduled.isRestDay) {
      return null;
    }

    return todayScheduled;
  }

  /// Convert date to string key for map
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse date from string key
  static DateTime _parseKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
