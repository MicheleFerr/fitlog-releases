/// Rate Limit Result Entity
///
/// Result of a rate limit check for AI Coach messages.
/// Used by token bucket rate limiter to enforce 20 messages/day limit.
///
/// **Layer**: Domain - Entity
/// **Feature**: AI Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_result.freezed.dart';

/// Rate limit check status
enum RateLimitStatus {
  /// Request allowed - within rate limit
  allowed,

  /// Request throttled - approaching limit (warning)
  throttled,

  /// Request blocked - rate limit exceeded
  blocked,
}

/// Result of rate limit check
@freezed
class RateLimitResult with _$RateLimitResult {
  const factory RateLimitResult({
    required RateLimitStatus status,
    required String message,
    @Default(0) int waitSeconds,
  }) = _RateLimitResult;

  const RateLimitResult._();

  /// Whether the request is allowed
  bool get isAllowed => status == RateLimitStatus.allowed;

  /// Whether the request is throttled (warning)
  bool get isThrottled => status == RateLimitStatus.throttled;

  /// Whether the request is blocked
  bool get isBlocked => status == RateLimitStatus.blocked;

  /// Factory for allowed request
  factory RateLimitResult.allowed() => const RateLimitResult(
        status: RateLimitStatus.allowed,
        message: '',
      );

  /// Factory for blocked request
  factory RateLimitResult.blocked({required String message}) => RateLimitResult(
        status: RateLimitStatus.blocked,
        message: message,
      );

  /// Factory for throttled request (warning)
  factory RateLimitResult.throttled({
    required String message,
    required int waitSeconds,
  }) =>
      RateLimitResult(
        status: RateLimitStatus.throttled,
        message: message,
        waitSeconds: waitSeconds,
      );
}
