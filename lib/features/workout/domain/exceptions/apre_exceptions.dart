/// Custom exceptions for APRE (Auto-Regulated Progressive Resistance Exercise) system.
///
/// These exceptions provide clear, specific error messages for common APRE calculation
/// and configuration issues.
library;

/// Exception thrown when no historical data is available for APRE calculations.
///
/// This occurs when:
/// - User is configuring APRE for the first time on an exercise
/// - Historical sets have been cleared/deleted
/// - Exercise has never been performed before
///
/// **Resolution**: Prompt user to manually input their 1RM or perform a test set.
class APRENoHistoryException implements Exception {
  /// Creates an [APRENoHistoryException] with the given [message].
  const APRENoHistoryException(this.message);

  /// Descriptive message explaining the lack of historical data.
  final String message;

  @override
  String toString() => 'APRENoHistoryException: $message';
}

/// Exception thrown when cached APRE calculations are too old to be reliable.
///
/// This occurs when:
/// - Cached 1RM calculation is older than 7 days (default threshold)
/// - User's strength has likely changed significantly
/// - Data freshness is critical for accurate weight progression
///
/// **Resolution**: Recalculate 1RM using recent historical data.
class APREStaleDataException implements Exception {
  /// Creates an [APREStaleDataException] with the given [message].
  const APREStaleDataException(this.message);

  /// Descriptive message explaining why the data is considered stale.
  final String message;

  @override
  String toString() => 'APREStaleDataException: $message';
}

/// Exception thrown when attempting to change APRE protocol during an active workout.
///
/// This occurs when:
/// - User tries to change protocol (3/6/10) mid-workout
/// - Workout has started but not finished
/// - Would cause inconsistent set structure
///
/// **Resolution**: Finish current workout first, then change protocol for next session.
class APREWorkoutInProgressException implements Exception {
  /// Creates an [APREWorkoutInProgressException] with the given [message].
  const APREWorkoutInProgressException(this.message);

  /// Descriptive message explaining why protocol change is blocked.
  final String message;

  @override
  String toString() => 'APREWorkoutInProgressException: $message';
}

/// Exception thrown when an invalid APRE protocol number is provided.
///
/// This occurs when:
/// - Protocol number is not one of the valid values: 3, 6, or 10
/// - User input or configuration contains invalid protocol
/// - Data corruption or migration issue
///
/// **Valid Protocols**:
/// - **Protocol 3**: 3 sets + 1 AMRAP (max reps)
/// - **Protocol 6**: 6 sets + 1 AMRAP (max reps)
/// - **Protocol 10**: 10 sets + 1 AMRAP (max reps)
///
/// **Resolution**: Validate protocol input and use one of the valid values.
class APREInvalidProtocolException implements Exception {
  /// Creates an [APREInvalidProtocolException] with the given [message].
  const APREInvalidProtocolException(this.message);

  /// Descriptive message explaining which protocol is invalid and valid options.
  final String message;

  @override
  String toString() => 'APREInvalidProtocolException: $message';
}
