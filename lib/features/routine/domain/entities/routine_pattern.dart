/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: entity
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE PATTERN ENTITY - Workout scheduling patterns
///
/// This entity provides:
/// - Pattern sequences (e.g., "A, B, rest, C, A, rest, B")
/// - Pattern types (repeating, fixed, custom)
/// - Schedule generation from patterns
/// - Flexible pattern manipulation
///
/// Dependencies:
/// - Freezed: Code generation
/// - JSON serialization
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart'; // For ScheduledDay

part 'routine_pattern.freezed.dart';
part 'routine_pattern.g.dart';

/// Enum for pattern types
enum PatternType {
  /// Pattern repeats indefinitely (A, B, C, A, B, C, ...)
  repeating,

  /// Pattern is fixed for specific dates (no repetition)
  fixed,

  /// Custom pattern with user-defined logic
  custom,
}

/// Extension methods for PatternType
extension PatternTypeExtension on PatternType {
  /// Get display name for UI
  String get displayName {
    switch (this) {
      case PatternType.repeating:
        return 'Repeating';
      case PatternType.fixed:
        return 'Fixed';
      case PatternType.custom:
        return 'Custom';
    }
  }

  /// Get description for UI
  String get description {
    switch (this) {
      case PatternType.repeating:
        return 'Pattern repeats cyclically';
      case PatternType.fixed:
        return 'Pattern runs once without repetition';
      case PatternType.custom:
        return 'Custom scheduling logic';
    }
  }
}

/// 🎯 ROUTINE PATTERN ENTITY
///
/// Represents a workout scheduling pattern.
/// Defines the sequence of workouts and rest days that will be
/// applied to a routine period.
///
/// Example patterns:
/// - Push/Pull/Legs: ["push-id", "pull-id", "rest", "legs-id"]
/// - Upper/Lower: ["upper-id", "lower-id", "rest", "upper-id", "lower-id"]
/// - Bro Split: ["chest-id", "back-id", "shoulders-id", "arms-id", "legs-id", "rest", "rest"]
@freezed
class RoutinePattern with _$RoutinePattern {
  const factory RoutinePattern({
    // === PATTERN INFO ===
    @Default('') String name,
    @Default('') String description,

    // === PATTERN SEQUENCE ===
    /// Sequence of template IDs or "rest" keyword
    /// Example: ["template-push-id", "template-pull-id", "rest", "template-legs-id"]
    required List<String> sequence,

    // === PATTERN TYPE ===
    @Default(PatternType.repeating) PatternType type,

    // === PATTERN SETTINGS ===
    /// How many times to repeat (only for fixed type)
    @Default(1) int repetitions,

    /// Start from specific day of week (0 = Monday, 6 = Sunday)
    int? startWeekday,
  }) = _RoutinePattern;

  factory RoutinePattern.fromJson(Map<String, dynamic> json) =>
      _$RoutinePatternFromJson(json);

  /// Factory for creating an empty pattern
  factory RoutinePattern.empty() {
    return const RoutinePattern(
      sequence: [],
    );
  }

  /// Factory for creating a repeating pattern
  factory RoutinePattern.repeating({
    required String name,
    required List<String> sequence,
    String? description,
  }) {
    return RoutinePattern(
      name: name,
      description: description ?? '',
      sequence: sequence,
      type: PatternType.repeating,
    );
  }

  /// Factory for creating a fixed pattern
  factory RoutinePattern.fixed({
    required String name,
    required List<String> sequence,
    int repetitions = 1,
    String? description,
  }) {
    return RoutinePattern(
      name: name,
      description: description ?? '',
      sequence: sequence,
      type: PatternType.fixed,
      repetitions: repetitions,
    );
  }
}

/// Extension methods for RoutinePattern
extension RoutinePatternExtensions on RoutinePattern {
  /// Keyword used to represent rest days in the sequence
  static const String restKeyword = 'rest';

  /// Get cycle length (total days in one pattern cycle)
  int get cycleLength => sequence.length;

  /// Check if pattern is empty
  bool get isEmpty => sequence.isEmpty;

  /// Check if pattern has any workout days
  bool get hasWorkoutDays => sequence.any((item) => item != restKeyword);

  /// Get count of workout days in one cycle
  int get workoutDaysPerCycle =>
      sequence.where((item) => item != restKeyword).length;

  /// Get count of rest days in one cycle
  int get restDaysPerCycle =>
      sequence.where((item) => item == restKeyword).length;

  /// Get template ID for a specific day index within the pattern
  /// Returns null for rest days
  String? getTemplateForIndex(int index) {
    if (sequence.isEmpty) return null;

    final normalizedIndex = index % cycleLength;
    final item = sequence[normalizedIndex];

    return item == restKeyword ? null : item;
  }

  /// Get template ID for a specific date
  /// Calculates the index based on date offset from start date
  String? getTemplateForDate(DateTime date, DateTime startDate) {
    final dayOffset = date.difference(startDate).inDays;
    return getTemplateForIndex(dayOffset);
  }

  /// Get the next workout date from a given date
  DateTime? getNextWorkoutDate(DateTime from, DateTime startDate, DateTime endDate) {
    DateTime current = from;

    // Search up to cycle length + 7 days to handle edge cases
    final maxSearch = cycleLength + 7;

    for (int i = 0; i < maxSearch; i++) {
      current = current.add(const Duration(days: 1));

      if (current.isAfter(endDate)) return null;

      final template = getTemplateForDate(current, startDate);
      if (template != null) return current;
    }

    return null;
  }

  /// Generate full schedule for a date range
  List<ScheduledDay> generateSchedule(DateTime startDate, DateTime endDate) {
    final schedule = <ScheduledDay>[];

    if (sequence.isEmpty) return schedule;

    DateTime current = startDate;
    int dayIndex = 0;

    while (current.isBefore(endDate.add(const Duration(days: 1)))) {
      final templateId = _getTemplateForDayIndex(dayIndex);

      final scheduledDay = templateId == null
          ? ScheduledDay.rest(date: current)
          : ScheduledDay.scheduled(date: current, templateId: templateId);

      schedule.add(scheduledDay);

      current = current.add(const Duration(days: 1));
      dayIndex++;

      // For fixed patterns, stop after repetitions are complete
      if (type == PatternType.fixed && dayIndex >= (cycleLength * repetitions)) {
        // Fill remaining days with rest
        while (current.isBefore(endDate.add(const Duration(days: 1)))) {
          schedule.add(ScheduledDay.rest(date: current));
          current = current.add(const Duration(days: 1));
        }
        break;
      }
    }

    return schedule;
  }

  /// Internal method to get template for day index
  String? _getTemplateForDayIndex(int index) {
    if (sequence.isEmpty) return null;

    final normalizedIndex = type == PatternType.repeating
        ? index % cycleLength
        : index.clamp(0, (cycleLength * repetitions) - 1);

    if (normalizedIndex >= sequence.length * repetitions) return null;

    final sequenceIndex = normalizedIndex % cycleLength;
    final item = sequence[sequenceIndex];

    return item == restKeyword ? null : item;
  }

  /// Add a template to the sequence
  RoutinePattern addTemplate(String templateId) {
    final newSequence = List<String>.from(sequence)..add(templateId);
    return copyWith(sequence: newSequence);
  }

  /// Add a rest day to the sequence
  RoutinePattern addRestDay() {
    final newSequence = List<String>.from(sequence)..add(restKeyword);
    return copyWith(sequence: newSequence);
  }

  /// Remove item from sequence at index
  RoutinePattern removeAt(int index) {
    if (index < 0 || index >= sequence.length) return this;

    final newSequence = List<String>.from(sequence)..removeAt(index);
    return copyWith(sequence: newSequence);
  }

  /// Reorder items in sequence
  RoutinePattern reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= sequence.length ||
        newIndex < 0 ||
        newIndex >= sequence.length) {
      return this;
    }

    final newSequence = List<String>.from(sequence);
    final item = newSequence.removeAt(oldIndex);
    newSequence.insert(newIndex, item);

    return copyWith(sequence: newSequence);
  }

  /// Replace template at index
  RoutinePattern replaceAt(int index, String templateId) {
    if (index < 0 || index >= sequence.length) return this;

    final newSequence = List<String>.from(sequence);
    newSequence[index] = templateId;

    return copyWith(sequence: newSequence);
  }

  /// Validate pattern (check for empty sequence, etc.)
  bool get isValid {
    return sequence.isNotEmpty && hasWorkoutDays;
  }

  /// Get human-readable preview of pattern
  String get preview {
    if (sequence.isEmpty) return 'Empty pattern';

    final preview = sequence
        .take(7) // Show first 7 days
        .map((item) => item == restKeyword ? 'Rest' : 'Workout')
        .join(' → ');

    final suffix = sequence.length > 7 ? ' ...' : '';
    return preview + suffix;
  }

  /// Get pattern summary for display
  String get summary {
    final workouts = workoutDaysPerCycle;
    final rests = restDaysPerCycle;
    final total = cycleLength;

    return '$workouts workout${workouts != 1 ? 's' : ''}, $rests rest day${rests != 1 ? 's' : ''} per $total-day cycle';
  }

  /// Copy pattern with modifications
  RoutinePattern copyWith({
    String? name,
    String? description,
    List<String>? sequence,
    PatternType? type,
    int? repetitions,
    int? startWeekday,
  }) {
    return RoutinePattern(
      name: name ?? this.name,
      description: description ?? this.description,
      sequence: sequence ?? this.sequence,
      type: type ?? this.type,
      repetitions: repetitions ?? this.repetitions,
      startWeekday: startWeekday ?? this.startWeekday,
    );
  }
}

/// Predefined workout frequency patterns
class RoutinePatterns {
  /// 1 Workout + 1 Rest (repeating)
  static RoutinePattern get oneWorkoutOneRest => RoutinePattern.repeating(
        name: '1 Workout + 1 Rest',
        description: '1 training day followed by 1 rest day',
        sequence: [
          'Workout 1',
          'rest',
        ],
      );

  /// 2 Workouts + 1 Rest (repeating)
  static RoutinePattern get twoWorkoutsOneRest => RoutinePattern.repeating(
        name: '2 Workouts + 1 Rest',
        description: '2 training days followed by 1 rest day',
        sequence: [
          'Workout 1',
          'Workout 2',
          'rest',
        ],
      );

  /// 3 Workouts + 1 Rest (repeating)
  static RoutinePattern get threeWorkoutsOneRest => RoutinePattern.repeating(
        name: '3 Workouts + 1 Rest',
        description: '3 training days followed by 1 rest day',
        sequence: [
          'Workout 1',
          'Workout 2',
          'Workout 3',
          'rest',
        ],
      );

  /// 4 Workouts + 1 Rest (repeating)
  static RoutinePattern get fourWorkoutsOneRest => RoutinePattern.repeating(
        name: '4 Workouts + 1 Rest',
        description: '4 training days followed by 1 rest day',
        sequence: [
          'Workout 1',
          'Workout 2',
          'Workout 3',
          'Workout 4',
          'rest',
        ],
      );

  /// 5 Workouts + 2 Rest (repeating)
  static RoutinePattern get fiveWorkoutsTwoRest => RoutinePattern.repeating(
        name: '5 Workouts + 2 Rest',
        description: '5 training days followed by 2 rest days',
        sequence: [
          'Workout 1',
          'Workout 2',
          'Workout 3',
          'Workout 4',
          'Workout 5',
          'rest',
          'rest',
        ],
      );

  /// 6 Workouts + 1 Rest (repeating)
  static RoutinePattern get sixWorkoutsOneRest => RoutinePattern.repeating(
        name: '6 Workouts + 1 Rest',
        description: '6 training days followed by 1 rest day',
        sequence: [
          'Workout 1',
          'Workout 2',
          'Workout 3',
          'Workout 4',
          'Workout 5',
          'Workout 6',
          'rest',
        ],
      );

  /// 3 Workouts + 2 Rest (repeating)
  static RoutinePattern get threeWorkoutsTwoRest => RoutinePattern.repeating(
        name: '3 Workouts + 2 Rest',
        description: '3 training days with 2 rest days per week',
        sequence: [
          'Workout 1',
          'rest',
          'Workout 2',
          'rest',
          'Workout 3',
          'rest',
          'rest',
        ],
      );

  /// 4 Workouts + 3 Rest (repeating)
  static RoutinePattern get fourWorkoutsThreeRest => RoutinePattern.repeating(
        name: '4 Workouts + 3 Rest',
        description: '4 training days with 3 rest days per week',
        sequence: [
          'Workout 1',
          'Workout 2',
          'rest',
          'Workout 3',
          'Workout 4',
          'rest',
          'rest',
        ],
      );

  /// Get all predefined patterns
  static List<RoutinePattern> get allPatterns => [
        oneWorkoutOneRest,
        twoWorkoutsOneRest,
        threeWorkoutsOneRest,
        threeWorkoutsTwoRest,
        fourWorkoutsOneRest,
        fourWorkoutsThreeRest,
        fiveWorkoutsTwoRest,
        sixWorkoutsOneRest,
      ];
}
