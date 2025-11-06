/// Custom exception for missed workout recovery operations
///
/// Provides structured error information for recovery failures with retry logic support.
/// Distinguishes between retryable errors (network, temporary) and fatal errors (permission).
///
/// Example:
/// ```dart
/// try {
///   await performRecovery(workoutId);
/// } on RecoveryException catch (e) {
///   if (e.shouldRetry) {
///     // Queue for retry with exponential backoff
///   } else {
///     // Show permanent error to user
///   }
/// }
/// ```
class RecoveryException implements Exception {
  /// Constructor for recovery exception with optional underlying cause
  RecoveryException({
    required this.code,
    required this.message,
    this.shouldRetry = false,
    this.originalException,
  }) : timestamp = DateTime.now();

  /// Machine-readable error code
  ///
  /// Common codes:
  /// - "permission-denied" - User lacks permission
  /// - "network-error" - Network connectivity issue
  /// - "timeout" - Operation timed out
  /// - "conflict" - Concurrent modification conflict
  /// - "not-found" - Routine/workout not found
  /// - "invalid-state" - Recovery invalid for current routine state
  final String code;

  /// Human-readable error message
  ///
  /// Suitable for displaying to users (may be localized in UI layer)
  final String message;

  /// Whether this error should trigger automatic retry
  ///
  /// True for: network errors, timeouts, temporary failures
  /// False for: permission denied, not found, invalid state
  final bool shouldRetry;

  /// Optional underlying exception that caused this
  ///
  /// Useful for debugging and logging
  final Exception? originalException;

  /// Timestamp when error occurred
  final DateTime timestamp;

  @override
  String toString() =>
      'RecoveryException($code): $message${shouldRetry ? ' [RETRYABLE]' : ''}';
}
