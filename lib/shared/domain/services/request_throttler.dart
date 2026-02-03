/**
 * 🔐 SECURITY: Client-Side Request Throttling
 *
 * Prevents excessive API calls and complements server-side rate limiting.
 *
 * **Features**:
 * - Debouncing: Delay execution until quiet period (search, input)
 * - Throttling: Limit execution frequency (scroll, analytics)
 * - Retry-After handling: Respect server rate limit headers
 * - Memory efficient: Auto-cleanup of expired throttles
 *
 * **Usage**:
 * ```dart
 * // Debounce search input (500ms delay)
 * final searchDebouncer = Debouncer(duration: Duration(milliseconds: 500));
 * searchDebouncer.run(() => performSearch(query));
 *
 * // Throttle analytics events (1 per second max)
 * final analyticsThrottler = Throttler(duration: Duration(seconds: 1));
 * analyticsThrottler.run(() => trackEvent(event));
 *
 * // Handle server rate limit (resource-exhausted error)
 * final rateLimitHandler = RateLimitHandler();
 * await rateLimitHandler.executeWithRetry(
 *   () => callCloudFunction(),
 *   onRateLimited: (retryAfter) => showSnackBar('Too many requests'),
 * );
 * ```
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/utils/app_logger.dart';

// ========================================
// 1. DEBOUNCER - Delay Until Quiet Period
// ========================================

/// Debounces function calls - waits for quiet period before executing
///
/// **Use Cases**:
/// - Search input (wait for user to stop typing)
/// - Auto-save (wait for user to finish editing)
/// - Validation (wait before showing errors)
///
/// **Example**:
/// ```dart
/// final searchDebouncer = Debouncer(duration: Duration(milliseconds: 500));
///
/// void onSearchChanged(String query) {
///   searchDebouncer.run(() {
///     performSearch(query); // Only called after 500ms of no changes
///   });
/// }
/// ```
class Debouncer {
  Debouncer({
    required this.duration,
    this.onError,
  });

  final Duration duration;
  final void Function(Object error, StackTrace stackTrace)? onError;

  Timer? _timer;

  /// Schedule action to run after quiet period
  ///
  /// Cancels any pending action from previous calls
  void run(VoidCallback action) {
    // Cancel previous timer if exists
    _timer?.cancel();

    // Create new timer
    _timer = Timer(duration, () {
      try {
        action();
      } catch (e, stackTrace) {
        AppLogger.error('Error during execution: $e', tag: 'Debouncer', error: e, stackTrace: stackTrace);
        onError?.call(e, stackTrace);
      }
    });
  }

  /// Cancel pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if action is pending
  bool get isActive => _timer?.isActive ?? false;

  /// Cleanup resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

// ========================================
// 2. THROTTLER - Limit Execution Frequency
// ========================================

/// Throttles function calls - limits execution to once per time window
///
/// **Use Cases**:
/// - Scroll events (limit analytics tracking)
/// - Button clicks (prevent double-submit)
/// - API calls (limit request frequency)
///
/// **Difference from Debouncer**:
/// - Debouncer: Waits for quiet period (delays execution)
/// - Throttler: Guarantees execution (but limits frequency)
///
/// **Example**:
/// ```dart
/// final scrollThrottler = Throttler(duration: Duration(seconds: 1));
///
/// void onScroll(ScrollNotification notification) {
///   scrollThrottler.run(() {
///     trackScrollEvent(); // Called max once per second
///   });
/// }
/// ```
class Throttler {
  Throttler({
    required this.duration,
    this.leading = true,
    this.trailing = false,
    this.onError,
  });

  final Duration duration;

  /// Execute on leading edge (immediate first call)
  final bool leading;

  /// Execute on trailing edge (after window ends)
  final bool trailing;

  final void Function(Object error, StackTrace stackTrace)? onError;

  DateTime? _lastExecution;
  Timer? _trailingTimer;
  VoidCallback? _pendingAction;

  /// Execute action (throttled)
  ///
  /// **Behavior**:
  /// - First call: Executes immediately if `leading = true`
  /// - Subsequent calls within window: Ignored or queued for trailing
  /// - After window: Executes next call immediately
  void run(VoidCallback action) {
    final now = DateTime.now();

    // Check if we're within throttle window
    final isThrottled = _lastExecution != null &&
        now.difference(_lastExecution!) < duration;

    if (!isThrottled) {
      // Execute immediately (leading edge)
      if (leading) {
        _executeAction(action);
        _lastExecution = now;
      }

      // Cancel any pending trailing execution
      _trailingTimer?.cancel();
      _trailingTimer = null;
      _pendingAction = null;
    } else {
      // Within throttle window
      if (trailing) {
        // Queue for trailing edge execution
        _pendingAction = action;

        // Schedule trailing execution if not already scheduled
        _trailingTimer ??= Timer(
          duration - now.difference(_lastExecution!),
          () {
            if (_pendingAction != null) {
              _executeAction(_pendingAction!);
              _lastExecution = DateTime.now();
              _pendingAction = null;
            }
          },
        );
      }
      // else: Drop this call (ignored)
    }
  }

  void _executeAction(VoidCallback action) {
    try {
      action();
    } catch (e, stackTrace) {
      AppLogger.error('Error during execution: $e', tag: 'Throttler', error: e, stackTrace: stackTrace);
      onError?.call(e, stackTrace);
    }
  }

  /// Reset throttle state (allow immediate next execution)
  void reset() {
    _lastExecution = null;
    _trailingTimer?.cancel();
    _trailingTimer = null;
    _pendingAction = null;
  }

  /// Check if currently throttled
  bool get isThrottled {
    if (_lastExecution == null) return false;
    return DateTime.now().difference(_lastExecution!) < duration;
  }

  /// Cleanup resources
  void dispose() {
    _trailingTimer?.cancel();
    _trailingTimer = null;
    _pendingAction = null;
  }
}

// ========================================
// 3. RATE LIMIT HANDLER - Server Integration
// ========================================

/// Handles server-side rate limiting errors (resource-exhausted)
///
/// **Use Cases**:
/// - Cloud Function calls
/// - API requests to rate-limited endpoints
/// - Automatic retry after server-specified delay
///
/// **Example**:
/// ```dart
/// final handler = RateLimitHandler();
///
/// try {
///   await handler.executeWithRetry(
///     () => functions.httpsCallable('setAdminRole').call(data),
///     onRateLimited: (retryAfter) {
///       SnackBarService.showWarning(
///         context,
///         'Too many requests. Retry in $retryAfter seconds',
///       );
///     },
///   );
/// } catch (e) {
///   // Handle other errors
/// }
/// ```
class RateLimitHandler {
  RateLimitHandler({
    this.maxRetries = 2,
    this.retryMultiplier = 1.5,
  });

  /// Maximum number of automatic retries
  final int maxRetries;

  /// Multiplier for retry delay (exponential backoff)
  final double retryMultiplier;

  /// Execute function with automatic retry on rate limit
  ///
  /// Returns result on success, throws on final failure
  Future<T> executeWithRetry<T>(
    Future<T> Function() action, {
    void Function(int retryAfter)? onRateLimited,
    Duration? maxDelay,
  }) async {
    int retryCount = 0;

    while (true) {
      try {
        return await action();
      } catch (e) {
        // Check if this is a rate limit error
        final retryAfter = _extractRetryAfter(e);

        if (retryAfter == null || retryCount >= maxRetries) {
          // Not a rate limit error or max retries exceeded
          rethrow;
        }

        // Calculate retry delay (with exponential backoff)
        var delay = Duration(seconds: retryAfter);
        if (retryCount > 0) {
          delay = Duration(
            seconds: (retryAfter * (retryMultiplier * retryCount)).ceil(),
          );
        }

        // Apply max delay cap if specified
        if (maxDelay != null && delay > maxDelay) {
          delay = maxDelay;
        }

        // Notify caller about rate limit
        onRateLimited?.call(delay.inSeconds);

        AppLogger.warning(
          'Rate limited. Retry #${retryCount + 1} in ${delay.inSeconds}s',
          tag: 'RateLimitHandler',
        );

        // Wait before retry
        await Future.delayed(delay);

        retryCount++;
      }
    }
  }

  /// Extract retry-after value from error
  ///
  /// Supports:
  /// - Firebase HttpsError with retryAfter in details
  /// - HTTP 429 responses with Retry-After header
  int? _extractRetryAfter(Object error) {
    // Firebase Functions error format:
    // HttpsError(code: 'resource-exhausted', details: {'retryAfter': 30})
    if (error.toString().contains('resource-exhausted')) {
      // Try to extract retryAfter from error message
      final match = RegExp(r'Retry after (\d+) seconds').firstMatch(
        error.toString(),
      );
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }

      // Default retry after 30 seconds if format unknown
      return 30;
    }

    // HTTP 429 status code (Too Many Requests)
    if (error.toString().contains('429') ||
        error.toString().contains('Too Many Requests')) {
      // Try to extract Retry-After header value
      final match = RegExp(r'retry[- ]?after[:\s]+(\d+)', caseSensitive: false)
          .firstMatch(error.toString());
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }

      // Default retry after 60 seconds for 429
      return 60;
    }

    return null;
  }
}

// ========================================
// 4. REQUEST QUEUE - Advanced Throttling
// ========================================

/// Queue with configurable rate limiting (max requests per time window)
///
/// **Use Cases**:
/// - Batch API calls (e.g., sync 100 workouts)
/// - Controlled parallelism (max 5 concurrent requests)
/// - Fair resource sharing (FIFO queue)
///
/// **Example**:
/// ```dart
/// final queue = RequestQueue(
///   maxConcurrent: 5,
///   maxPerMinute: 30,
/// );
///
/// for (final workout in workouts) {
///   queue.enqueue(() => syncWorkout(workout));
/// }
///
/// await queue.waitUntilEmpty();
/// ```
class RequestQueue {
  RequestQueue({
    this.maxConcurrent = 3,
    this.maxPerMinute,
  });

  /// Maximum concurrent requests
  final int maxConcurrent;

  /// Maximum requests per minute (null = unlimited)
  final int? maxPerMinute;

  final List<Future<void> Function()> _queue = [];
  final List<DateTime> _timestamps = [];
  int _active = 0;
  bool _disposed = false;

  /// Add request to queue
  Future<T> enqueue<T>(Future<T> Function() action) async {
    if (_disposed) {
      throw StateError('RequestQueue disposed');
    }

    final completer = Completer<T>();

    _queue.add(() async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
      }
    });

    unawaited(_processQueue());

    return completer.future;
  }

  Future<void> _processQueue() async {
    // Check if we can start more requests
    while (_queue.isNotEmpty &&
        _active < maxConcurrent &&
        !_isRateLimited()) {
      final action = _queue.removeAt(0);
      _active++;
      _timestamps.add(DateTime.now());

      // Execute request (don't await - run concurrently)
      unawaited(
        action().whenComplete(() {
          _active--;
          unawaited(_processQueue()); // Process next in queue
        }),
      );
    }

    // Clean up old timestamps (older than 1 minute)
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    _timestamps.removeWhere((ts) => ts.isBefore(oneMinuteAgo));
  }

  bool _isRateLimited() {
    if (maxPerMinute == null) return false;

    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    final recentRequests = _timestamps.where((ts) => ts.isAfter(oneMinuteAgo));

    return recentRequests.length >= maxPerMinute!;
  }

  /// Wait until all queued requests complete
  Future<void> waitUntilEmpty() async {
    while (_queue.isNotEmpty || _active > 0) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Number of pending requests in queue
  int get pendingCount => _queue.length;

  /// Number of currently active requests
  int get activeCount => _active;

  /// Clear queue (does not cancel active requests)
  void clear() {
    _queue.clear();
  }

  /// Cleanup resources
  void dispose() {
    _disposed = true;
    _queue.clear();
    _timestamps.clear();
  }
}
