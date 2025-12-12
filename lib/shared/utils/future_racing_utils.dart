/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/utils
/// Feature: Async Timeout Patterns
/// Type: Utility
///
/// Timeout utilities for Firebase operations with cache fallback.
///
/// **Pattern**: Standard .timeout(onTimeout:) pattern (recommended by Dart/Flutter community)
/// Useful for:
/// - Firestore operations with timeout
/// - Cache-first with server fallback
/// - Offline-first UX
///
/// **Best Practice**: Use .timeout() instead of Future.any() for simplicity.
/// Source: https://api.flutter.dev/flutter/dart-async/Future/timeout.html
///
/// **Usage**:
/// ```dart
/// final data = await FirestoreTimeout.cacheAside<Workout>(
///   cacheGet: _hive.get('workout_123'),
///   serverFetch: _firestore.doc('workouts/123').get(),
///   cacheSet: (workout) => _hive.put('workout_123', workout),
/// );
/// ```
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Firestore-specific timeout utilities
///
/// Optimized patterns for common Firebase + Hive scenarios in FitLog Pro.
///
/// **Why not Future.any()?**
/// - .timeout(onTimeout:) is the standard Dart pattern (official docs)
/// - More readable for team members
/// - Sequential fallback is easier to reason about
/// - Performance difference is negligible (<1ms)
class FirestoreTimeout {
  FirestoreTimeout._();

  /// Cache-aside pattern with timeout
  ///
  /// **Pattern**: Server-first with cache fallback on timeout
  ///
  /// 1. Check cache (instant)
  /// 2. If cache miss, fetch from Firestore with timeout
  /// 3. Update cache in background (fire-and-forget)
  ///
  /// **Parameters**:
  /// - cacheGet: Cache lookup Future (Hive)
  /// - serverFetch: Firestore fetch Future
  /// - cacheSet: Cache update callback (background)
  /// - timeout: Max wait time for Firestore (default: 5s)
  ///
  /// **Returns**: Cache value if exists, else Firestore value
  ///
  /// **Example**:
  /// ```dart
  /// final workout = await FirestoreTimeout.cacheAside<Workout>(
  ///   cacheGet: _hive.get('workout_123'),
  ///   serverFetch: _firestore.doc('workouts/123').get(),
  ///   cacheSet: (workout) => _hive.put('workout_123', workout),
  ///   timeout: Duration(seconds: 5),
  /// );
  /// ```
  static Future<T> cacheAside<T>({
    required Future<T?> cacheGet,
    required Future<T> serverFetch,
    required Future<void> Function(T value) cacheSet,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // Try cache first (should be instant)
      final cached = await cacheGet.timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => null, // Cache miss
      );

      if (cached != null) {
        if (kDebugMode) {
          debugPrint('📦 [FirestoreTimeout] Cache hit');
        }
        return cached;
      }
    } catch (_) {
      // Cache error - fall through to server
      if (kDebugMode) {
        debugPrint('📦 [FirestoreTimeout] Cache miss or error');
      }
    }

    // Cache miss - fetch from Firestore with timeout
    try {
      final serverValue = await serverFetch.timeout(timeout);

      // Update cache in background (fire-and-forget)
      unawaited(
        cacheSet(serverValue).catchError((e) {
          if (kDebugMode) {
            debugPrint('⚠️ [FirestoreTimeout] Cache update failed: $e');
          }
        }),
      );

      if (kDebugMode) {
        debugPrint('🌐 [FirestoreTimeout] Server fetch successful');
      }

      return serverValue;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('⏱️ [FirestoreTimeout] Server timeout after ${timeout.inSeconds}s: $e');
      }
      rethrow;
    }
  }

  /// Server-first with cache fallback on timeout
  ///
  /// **Pattern**: Try Firestore with timeout, fallback to stale cache if timeout
  ///
  /// Use when you prefer fresh data but tolerate stale cache on slow network.
  ///
  /// **Parameters**:
  /// - serverFetch: Firestore fetch Future
  /// - cacheFallback: Cache lookup Future (used on timeout)
  /// - timeout: Max wait time for Firestore (default: 5s)
  ///
  /// **Returns**: Fresh Firestore data, or stale cache if timeout
  ///
  /// **Example**:
  /// ```dart
  /// final templates = await FirestoreTimeout.serverWithCacheFallback(
  ///   serverFetch: _firestore.collection('templates').get(),
  ///   cacheFallback: _hive.get('templates_cache'),
  ///   timeout: Duration(seconds: 3),
  /// );
  /// ```
  static Future<T> serverWithCacheFallback<T>({
    required Future<T> serverFetch,
    required Future<T> cacheFallback,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final serverValue = await serverFetch.timeout(timeout);

      if (kDebugMode) {
        debugPrint('🌐 [FirestoreTimeout] Server fetch successful');
      }

      return serverValue;
    } on TimeoutException catch (_) {
      // Timeout - use stale cache
      if (kDebugMode) {
        debugPrint('⏱️ [FirestoreTimeout] Server timeout, using cache fallback');
      }

      return cacheFallback;
    }
  }

  /// Simple timeout wrapper
  ///
  /// **Pattern**: Add timeout to any Future operation
  ///
  /// **Parameters**:
  /// - operation: Future to execute with timeout
  /// - timeout: Max wait time (default: 5s)
  /// - onTimeout: Optional callback on timeout (returns fallback value)
  ///
  /// **Returns**: Operation result or onTimeout value
  ///
  /// **Example**:
  /// ```dart
  /// final data = await FirestoreTimeout.withTimeout(
  ///   operation: _firestore.collection('data').get(),
  ///   timeout: Duration(seconds: 3),
  ///   onTimeout: () => <Data>[],  // Empty list fallback
  /// );
  /// ```
  static Future<T> withTimeout<T>({
    required Future<T> operation,
    Duration timeout = const Duration(seconds: 5),
    T Function()? onTimeout,
  }) async {
    try {
      return await operation.timeout(
        timeout,
        onTimeout: onTimeout,
      );
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('⏱️ [FirestoreTimeout] Operation timeout after ${timeout.inSeconds}s: $e');
      }
      rethrow;
    }
  }
}

/// Extension for convenient timeout syntax
extension FutureTimeoutExtension<T> on Future<T> {
  /// Timeout with Firestore-optimized defaults
  ///
  /// **Usage**:
  /// ```dart
  /// final data = await _firestore.collection('data').get().withFirestoreTimeout();
  /// ```
  Future<T> withFirestoreTimeout({
    Duration timeout = const Duration(seconds: 5),
    T Function()? onTimeout,
  }) {
    return FirestoreTimeout.withTimeout(
      operation: this,
      timeout: timeout,
      onTimeout: onTimeout,
    );
  }
}
