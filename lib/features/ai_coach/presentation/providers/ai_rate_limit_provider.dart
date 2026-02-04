/// AI Rate Limit Provider
///
/// Manages rate limiting for AI Coach messages using token bucket algorithm.
/// Free tier: 20 messages per day.
///
/// **Layer**: Presentation - Provider
/// **Feature**: AI Coach
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/rate_limit_result.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_rate_limit_provider.g.dart';

/// Rate limit provider
@riverpod
class AIRateLimit extends _$AIRateLimit {
  static const int _dailyLimit = 999999; // No practical limit (single-user testing)
  static const String _boxName = 'ai_rate_limit';

  late Box<dynamic> _box;
  String? _userId;

  @override
  Future<RateLimitResult> build() async {
    // IMPORTANT: Prevent re-initialization and keep rate limit state
    // across navigation (matches design requirement line 595)
    ref.keepAlive();

    // Get current user
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (user == null) {
      return RateLimitResult.blocked(
        message: 'Devi effettuare il login per usare AI Coach.',
      );
    }

    _userId = user.uid;

    // Open Hive box for persistence
    _box = await Hive.openBox(_boxName);

    return _checkLimit();
  }

  /// Check current rate limit status
  RateLimitResult _checkLimit() {
    if (_userId == null) {
      return RateLimitResult.blocked(message: 'Login required');
    }

    final key = 'usage_$_userId';
    final resetKey = 'reset_$_userId';

    // Get stored data
    final usage = _box.get(key, defaultValue: 0) as int;
    final resetTimeMs = _box.get(resetKey, defaultValue: 0) as int;
    final resetTime = DateTime.fromMillisecondsSinceEpoch(resetTimeMs);

    // Check if reset time passed
    final now = DateTime.now();
    if (now.isAfter(resetTime)) {
      // Reset counter
      _box.put(key, 0);
      _box.put(resetKey, _getNextResetTime().millisecondsSinceEpoch);
      return RateLimitResult.allowed();
    }

    // Check limits
    final remaining = _dailyLimit - usage;

    if (remaining <= 0) {
      return RateLimitResult.blocked(
        message:
            'Limite giornaliero raggiunto ($_dailyLimit messaggi/giorno).\n'
            'Reset alle ${_formatTime(resetTime)}.',
      );
    } else if (remaining <= 2) {
      // 95% quota - critical warning
      return RateLimitResult.throttled(
        message: '⚠️ Solo $remaining messaggi rimasti oggi!',
        waitSeconds: 0,
      );
    } else if (remaining <= 4) {
      // 80% quota - warning
      return RateLimitResult.throttled(
        message: 'ℹ️ Hai $remaining messaggi rimasti oggi.',
        waitSeconds: 0,
      );
    }

    return RateLimitResult.allowed();
  }

  /// Increment usage counter
  Future<void> incrementUsage() async {
    if (_userId == null) return;

    final key = 'usage_$_userId';
    final resetKey = 'reset_$_userId';

    final usage = _box.get(key, defaultValue: 0) as int;
    await _box.put(key, usage + 1);

    // Set reset time if not exists
    if (!_box.containsKey(resetKey)) {
      await _box.put(resetKey, _getNextResetTime().millisecondsSinceEpoch);
    }

    // Update state
    state = AsyncValue.data(_checkLimit());
  }

  /// Get next reset time (tomorrow at midnight)
  DateTime _getNextResetTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  /// Format time for user display
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Get current usage count (for UI)
  int getCurrentUsage() {
    if (_userId == null) return 0;
    return _box.get('usage_$_userId', defaultValue: 0) as int;
  }

  /// Get remaining messages (for UI)
  int getRemainingMessages() {
    return _dailyLimit - getCurrentUsage();
  }
}
