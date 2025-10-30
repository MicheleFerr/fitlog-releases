import 'dart:async';
import 'package:flutter/foundation.dart';

/// Rate Limiter for API Calls
///
/// OWASP Mobile Security: M1 - Improper Platform Usage
///
/// Implements client-side rate limiting using Token Bucket algorithm to:
/// - Prevent API abuse and DoS attacks
/// - Control Firebase API costs
/// - Enforce fair usage policies
/// - Provide graceful degradation under load
///
/// SECURITY BENEFITS:
/// - ✅ Prevents brute force attacks (e.g., login attempts)
/// - ✅ Stops data scraping and mass queries
/// - ✅ Controls API costs (Firebase pricing per operation)
/// - ✅ Improves user experience with backoff
///
/// USAGE:
/// ```dart
/// final limiter = RateLimiter(
///   maxTokens: 10,
///   refillRate: Duration(seconds: 1),
/// );
///
/// // Check if operation is allowed
/// if (await limiter.tryConsume()) {
///   // Perform API call
///   await firestore.collection('workouts').get();
/// } else {
///   // Rate limit exceeded - show error
///   showError('Too many requests. Please wait.');
/// }
/// ```
///
/// ALGORITHM: Token Bucket
/// - Bucket starts with `maxTokens` tokens
/// - Each API call consumes 1 token
/// - Tokens refill at `refillRate` (e.g., 1 token/second)
/// - If no tokens available, request is denied
///
/// WHY CLIENT-SIDE RATE LIMITING?
/// While server-side rate limiting is essential, client-side limiting:
/// - Provides immediate user feedback (no round-trip to server)
/// - Reduces server load (fewer rejected requests)
/// - Improves UX (graceful degradation vs hard errors)
/// - Controls Firebase costs before they happen
class RateLimiter {

  /// Create rate limiter
  ///
  /// Example presets:
  /// - **Strict**: maxTokens: 5, refillRate: Duration(seconds: 10)
  ///   → 5 requests burst, then 1 every 10 seconds
  ///
  /// - **Moderate**: maxTokens: 10, refillRate: Duration(seconds: 1)
  ///   → 10 requests burst, then 1 per second
  ///
  /// - **Lenient**: maxTokens: 30, refillRate: Duration(milliseconds: 500)
  ///   → 30 requests burst, then 2 per second
  RateLimiter({
    required this.maxTokens,
    required this.refillRate,
    this.tokensPerRefill = 1,
  })  : _currentTokens = maxTokens,
        _lastRefill = DateTime.now() {
    _startRefillTimer();

    if (kDebugMode) {
      debugPrint('⏱️ RateLimiter initialized:');
      debugPrint('   Max tokens: $maxTokens');
      debugPrint('   Refill rate: ${refillRate.inMilliseconds}ms');
      debugPrint('   Tokens per refill: $tokensPerRefill');
    }
  }
  /// Maximum tokens in bucket
  final int maxTokens;

  /// Token refill duration
  final Duration refillRate;

  /// Tokens per refill
  final int tokensPerRefill;

  /// Current tokens available
  int _currentTokens;

  /// Last refill timestamp
  DateTime _lastRefill;

  /// Request queue for delayed operations
  final List<Completer<bool>> _queue = [];

  /// Timer for automatic refills
  Timer? _refillTimer;

  /// Try to consume a token
  ///
  /// Returns true if token was consumed (operation allowed)
  /// Returns false if no tokens available (rate limit exceeded)
  Future<bool> tryConsume({int tokens = 1}) async {
    _refillTokens();

    if (_currentTokens >= tokens) {
      _currentTokens -= tokens;

      if (kDebugMode) {
        debugPrint('✅ Rate limit: consumed $tokens token(s), $_currentTokens remaining');
      }

      return true;
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Rate limit exceeded: $_currentTokens tokens available, $tokens needed');
      }

      return false;
    }
  }

  /// Wait for tokens to become available
  ///
  /// Blocks until enough tokens are available, then consumes them.
  /// Use this for operations that MUST complete eventually.
  ///
  /// Example:
  /// ```dart
  /// await limiter.waitAndConsume(); // Waits if no tokens
  /// await performCriticalOperation();
  /// ```
  Future<void> waitAndConsume({int tokens = 1}) async {
    while (true) {
      if (await tryConsume(tokens: tokens)) {
        return;
      }

      // Wait for next refill
      await Future.delayed(refillRate);
    }
  }

  /// Consume token with exponential backoff
  ///
  /// Retries with increasing delays if rate limit is exceeded.
  /// Useful for non-critical operations that can tolerate delays.
  ///
  /// Example:
  /// ```dart
  /// final success = await limiter.consumeWithBackoff(
  ///   maxAttempts: 3,
  /// );
  /// if (success) {
  ///   await performOperation();
  /// } else {
  ///   showError('Service temporarily unavailable');
  /// }
  /// ```
  Future<bool> consumeWithBackoff({
    int tokens = 1,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      if (await tryConsume(tokens: tokens)) {
        return true;
      }

      if (attempt < maxAttempts - 1) {
        // Exponential backoff: 1s, 2s, 4s, 8s...
        final delay = initialDelay * (1 << attempt);

        if (kDebugMode) {
          debugPrint('⏳ Rate limit: backing off for ${delay.inSeconds}s (attempt ${attempt + 1}/$maxAttempts)');
        }

        await Future.delayed(delay);
      }
    }

    if (kDebugMode) {
      debugPrint('❌ Rate limit: max attempts ($maxAttempts) exceeded');
    }

    return false;
  }

  /// Refill tokens based on time elapsed
  void _refillTokens() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);

    if (elapsed >= refillRate) {
      final refills = elapsed.inMilliseconds ~/ refillRate.inMilliseconds;
      final tokensToAdd = refills * tokensPerRefill;

      _currentTokens = (_currentTokens + tokensToAdd).clamp(0, maxTokens);
      _lastRefill = now;

      if (kDebugMode && tokensToAdd > 0) {
        debugPrint('🔄 Rate limit: refilled $tokensToAdd token(s), $_currentTokens total');
      }
    }
  }

  /// Start automatic token refill timer
  void _startRefillTimer() {
    _refillTimer?.cancel();

    _refillTimer = Timer.periodic(refillRate, (_) {
      _refillTokens();
    });
  }

  /// Get current token count
  int get availableTokens {
    _refillTokens();
    return _currentTokens;
  }

  /// Get time until next token refill
  Duration get timeUntilRefill {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);
    final remaining = refillRate - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if tokens are available without consuming
  bool get hasTokens {
    _refillTokens();
    return _currentTokens > 0;
  }

  /// Get current fill percentage (0.0 to 1.0)
  double get fillPercentage {
    _refillTokens();
    return _currentTokens / maxTokens;
  }

  /// Reset rate limiter (refill to max)
  void reset() {
    _currentTokens = maxTokens;
    _lastRefill = DateTime.now();

    if (kDebugMode) {
      debugPrint('🔄 Rate limiter reset');
    }
  }

  /// Dispose rate limiter
  void dispose() {
    _refillTimer?.cancel();
    _refillTimer = null;

    if (kDebugMode) {
      debugPrint('⏱️ RateLimiter disposed');
    }
  }
}

/// Predefined Rate Limit Presets
class RateLimitPresets {
  /// Strict rate limiting
  /// Use for: Authentication, password resets, sensitive operations
  static RateLimiter strict() => RateLimiter(
        maxTokens: 5,
        refillRate: const Duration(seconds: 10),
      );

  /// Moderate rate limiting
  /// Use for: Normal API calls, queries, data fetching
  static RateLimiter moderate() => RateLimiter(
        maxTokens: 10,
        refillRate: const Duration(seconds: 1),
      );

  /// Lenient rate limiting
  /// Use for: Search queries, autocomplete, frequent operations
  static RateLimiter lenient() => RateLimiter(
        maxTokens: 30,
        refillRate: const Duration(milliseconds: 500),
        tokensPerRefill: 1,
      );

  /// Custom Firebase optimized
  /// Balances between user experience and Firebase costs
  /// - Allows 20 operations burst (e.g., initial app load)
  /// - Refills 2 tokens per second (120 per minute)
  /// - Suitable for Firestore reads/writes
  static RateLimiter firebaseOptimized() => RateLimiter(
        maxTokens: 20,
        refillRate: const Duration(milliseconds: 500),
        tokensPerRefill: 1,
      );

  /// Authentication specific
  /// Prevents brute force attacks
  /// - Only 3 attempts burst
  /// - Refills 1 token per 30 seconds
  /// - Maximum 6 attempts per 3 minutes
  static RateLimiter authentication() => RateLimiter(
        maxTokens: 3,
        refillRate: const Duration(seconds: 30),
      );

  /// Search/Autocomplete
  /// High-frequency operations with minimal impact
  /// - 50 requests burst (for rapid typing)
  /// - Refills 5 tokens per second
  /// - Allows smooth UX without spam
  static RateLimiter search() => RateLimiter(
        maxTokens: 50,
        refillRate: const Duration(milliseconds: 200),
        tokensPerRefill: 1,
      );
}

/// Rate Limiter Manager
///
/// Manages multiple rate limiters for different endpoints
///
/// Example:
/// ```dart
/// final manager = RateLimiterManager();
/// manager.registerEndpoint('login', RateLimitPresets.authentication());
/// manager.registerEndpoint('search', RateLimitPresets.search());
///
/// // Use specific limiter
/// if (await manager.tryConsume('login')) {
///   await performLogin();
/// }
/// ```
class RateLimiterManager {
  final Map<String, RateLimiter> _limiters = {};

  /// Register rate limiter for endpoint
  void registerEndpoint(String endpoint, RateLimiter limiter) {
    _limiters[endpoint] = limiter;

    if (kDebugMode) {
      debugPrint('⏱️ Registered rate limiter for endpoint: $endpoint');
    }
  }

  /// Try to consume token for endpoint
  Future<bool> tryConsume(String endpoint, {int tokens = 1}) async {
    final limiter = _limiters[endpoint];

    if (limiter == null) {
      if (kDebugMode) {
        debugPrint('⚠️ No rate limiter for endpoint: $endpoint');
      }
      return true; // Allow if no limiter configured
    }

    return await limiter.tryConsume(tokens: tokens);
  }

  /// Wait and consume for endpoint
  Future<void> waitAndConsume(String endpoint, {int tokens = 1}) async {
    final limiter = _limiters[endpoint];

    if (limiter == null) {
      if (kDebugMode) {
        debugPrint('⚠️ No rate limiter for endpoint: $endpoint');
      }
      return;
    }

    await limiter.waitAndConsume(tokens: tokens);
  }

  /// Consume with backoff for endpoint
  Future<bool> consumeWithBackoff(
    String endpoint, {
    int tokens = 1,
    int maxAttempts = 3,
  }) async {
    final limiter = _limiters[endpoint];

    if (limiter == null) {
      if (kDebugMode) {
        debugPrint('⚠️ No rate limiter for endpoint: $endpoint');
      }
      return true;
    }

    return await limiter.consumeWithBackoff(
      tokens: tokens,
      maxAttempts: maxAttempts,
    );
  }

  /// Get limiter for endpoint
  RateLimiter? getLimiter(String endpoint) => _limiters[endpoint];

  /// Check if endpoint has tokens available
  bool hasTokens(String endpoint) {
    final limiter = _limiters[endpoint];
    return limiter?.hasTokens ?? true;
  }

  /// Get available tokens for endpoint
  int availableTokens(String endpoint) {
    final limiter = _limiters[endpoint];
    return limiter?.availableTokens ?? 0;
  }

  /// Reset all rate limiters
  void resetAll() {
    for (final limiter in _limiters.values) {
      limiter.reset();
    }

    if (kDebugMode) {
      debugPrint('🔄 All rate limiters reset');
    }
  }

  /// Dispose all rate limiters
  void dispose() {
    for (final limiter in _limiters.values) {
      limiter.dispose();
    }
    _limiters.clear();

    if (kDebugMode) {
      debugPrint('⏱️ RateLimiterManager disposed');
    }
  }
}
