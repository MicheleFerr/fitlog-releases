import 'package:hive_ce_flutter/hive_flutter.dart';

part 'tutorial_state.g.dart';

/// Simplified tutorial state for the contextual onboarding system.
///
/// Replaces the complex OnboardingState with a streamlined approach:
/// - No upfront onboarding
/// - Just-in-time contextual tutorials
/// - Behavior-triggered + proactive hints
///
/// Migration from OnboardingState is handled by TutorialMigrationService.
///
/// Note: Uses List<String> internally for Hive compatibility,
/// but provides Set-like helper methods.
@HiveType(typeId: 60) // Unique typeId, not conflicting with existing ones
class TutorialState {
  const TutorialState({
    this.seenTutorialsList = const [],
    this.dismissedHintsList = const [],
    this.lastDismissTimeList = const [],
    this.totalWorkouts = 0,
    this.firstWorkoutDate,
    this.tutorialsEnabled = true,
  });

  // ============ FACTORY & COPYWIDTH ============

  /// Create initial empty state.
  factory TutorialState.initial() => const TutorialState();

  /// Create from Set/Map for convenience (converts to Lists internally).
  factory TutorialState.fromSets({
    Set<String> seenTutorials = const {},
    Set<String> dismissedHints = const {},
    Map<String, DateTime> lastDismissTime = const {},
    int totalWorkouts = 0,
    DateTime? firstWorkoutDate,
    bool tutorialsEnabled = true,
  }) {
    return TutorialState(
      seenTutorialsList: seenTutorials.toList(),
      dismissedHintsList: dismissedHints.toList(),
      lastDismissTimeList: lastDismissTime.entries
          .map((e) => '${e.key}:${e.value.toIso8601String()}')
          .toList(),
      totalWorkouts: totalWorkouts,
      firstWorkoutDate: firstWorkoutDate,
      tutorialsEnabled: tutorialsEnabled,
    );
  }

  factory TutorialState.fromJson(Map<String, dynamic> json) {
    return TutorialState(
      seenTutorialsList: List<String>.from(json['seenTutorials'] ?? []),
      dismissedHintsList: List<String>.from(json['dismissedHints'] ?? []),
      lastDismissTimeList: List<String>.from(json['lastDismissTime'] ?? []),
      totalWorkouts: json['totalWorkouts'] ?? 0,
      firstWorkoutDate: json['firstWorkoutDate'] != null
          ? DateTime.parse(json['firstWorkoutDate'] as String)
          : null,
      tutorialsEnabled: json['tutorialsEnabled'] ?? true,
    );
  }

  /// List of tutorial IDs that have been shown to the user.
  /// Examples: 'logging_set', 'rest_timer', 'analytics_intro'
  /// Use [seenTutorials] getter for Set-like access.
  @HiveField(0)
  final List<String> seenTutorialsList;

  /// List of proactive hint IDs that user explicitly dismissed.
  /// These respect a 24h cooldown before showing again.
  /// Use [dismissedHints] getter for Set-like access.
  @HiveField(1)
  final List<String> dismissedHintsList;

  /// List of "hintId:timestamp" strings for cooldown calculation.
  /// Format: "hint_id:2024-01-15T10:30:00.000Z"
  /// Use [lastDismissTime] getter for Map-like access.
  @HiveField(2)
  final List<String> lastDismissTimeList;

  /// Total number of completed workouts.
  /// Used for progressive tutorial triggers (e.g., analytics after 3 workouts).
  @HiveField(3)
  final int totalWorkouts;

  /// Date of first completed workout.
  /// Used for time-based tutorial triggers.
  @HiveField(4)
  final DateTime? firstWorkoutDate;

  /// Whether contextual tutorials are enabled globally.
  /// User can toggle this in Settings to disable all tutorial popups.
  @HiveField(5)
  final bool tutorialsEnabled;

  // ============ CONVENIENCE GETTERS (Set/Map access) ============

  /// Get seen tutorials as a Set for O(1) lookup.
  Set<String> get seenTutorials => seenTutorialsList.toSet();

  /// Get dismissed hints as a Set for O(1) lookup.
  Set<String> get dismissedHints => dismissedHintsList.toSet();

  /// Get last dismiss times as a Map for convenient access.
  Map<String, DateTime> get lastDismissTime {
    final map = <String, DateTime>{};
    for (final entry in lastDismissTimeList) {
      final parts = entry.split(':');
      if (parts.length >= 2) {
        final key = parts[0];
        final timestamp = parts.sublist(1).join(':'); // Handle ISO8601 colons
        try {
          map[key] = DateTime.parse(timestamp);
        } catch (_) {
          // Skip invalid entries
        }
      }
    }
    return map;
  }

  // ============ HELPER METHODS ============

  /// Check if a tutorial has been seen.
  bool hasSeen(String tutorialId) => seenTutorialsList.contains(tutorialId);

  /// Check if a hint can be shown (respects 24h cooldown after dismiss).
  bool canShowHint(String hintId) {
    if (!dismissedHintsList.contains(hintId)) return true;
    final lastDismiss = lastDismissTime[hintId];
    if (lastDismiss == null) return true;
    return DateTime.now().difference(lastDismiss).inHours >= 24;
  }

  /// Check if user is a "new user" (less than 3 workouts).
  bool get isNewUser => totalWorkouts < 3;

  /// Check if user has completed at least one workout.
  bool get hasCompletedFirstWorkout => totalWorkouts > 0;

  /// Create a copy with updated fields.
  /// Accepts both List and Set types for convenience.
  TutorialState copyWith({
    List<String>? seenTutorialsList,
    Set<String>? seenTutorials,
    List<String>? dismissedHintsList,
    Set<String>? dismissedHints,
    List<String>? lastDismissTimeList,
    Map<String, DateTime>? lastDismissTime,
    int? totalWorkouts,
    DateTime? firstWorkoutDate,
    bool? tutorialsEnabled,
  }) {
    // Handle seenTutorials - prefer List, fallback to Set conversion
    List<String> newSeenList = this.seenTutorialsList;
    if (seenTutorialsList != null) {
      newSeenList = seenTutorialsList;
    } else if (seenTutorials != null) {
      newSeenList = seenTutorials.toList();
    }

    // Handle dismissedHints - prefer List, fallback to Set conversion
    List<String> newDismissedList = this.dismissedHintsList;
    if (dismissedHintsList != null) {
      newDismissedList = dismissedHintsList;
    } else if (dismissedHints != null) {
      newDismissedList = dismissedHints.toList();
    }

    // Handle lastDismissTime - prefer List, fallback to Map conversion
    List<String> newTimeList = this.lastDismissTimeList;
    if (lastDismissTimeList != null) {
      newTimeList = lastDismissTimeList;
    } else if (lastDismissTime != null) {
      newTimeList = lastDismissTime.entries
          .map((e) => '${e.key}:${e.value.toIso8601String()}')
          .toList();
    }

    return TutorialState(
      seenTutorialsList: newSeenList,
      dismissedHintsList: newDismissedList,
      lastDismissTimeList: newTimeList,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      firstWorkoutDate: firstWorkoutDate ?? this.firstWorkoutDate,
      tutorialsEnabled: tutorialsEnabled ?? this.tutorialsEnabled,
    );
  }

  // ============ SERIALIZATION ============

  Map<String, dynamic> toJson() {
    return {
      'seenTutorials': seenTutorialsList,
      'dismissedHints': dismissedHintsList,
      'lastDismissTime': lastDismissTimeList,
      'totalWorkouts': totalWorkouts,
      'firstWorkoutDate': firstWorkoutDate?.toIso8601String(),
      'tutorialsEnabled': tutorialsEnabled,
    };
  }

  // ============ EQUALITY & TOSTRING ============

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorialState &&
        _listEquals(other.seenTutorialsList, seenTutorialsList) &&
        _listEquals(other.dismissedHintsList, dismissedHintsList) &&
        other.totalWorkouts == totalWorkouts &&
        other.firstWorkoutDate == firstWorkoutDate;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      seenTutorialsList.length,
      dismissedHintsList.length,
      totalWorkouts,
      firstWorkoutDate,
    );
  }

  @override
  String toString() {
    return 'TutorialState{seen: ${seenTutorialsList.length}, dismissed: ${dismissedHintsList.length}, workouts: $totalWorkouts}';
  }
}
