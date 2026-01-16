/// Firestore Timeout Mixin
///
/// Provides standardized timeout handling for Firestore operations.
/// Use this mixin to ensure consistent timeout behavior across all repositories.
///
/// ## Usage
/// ```dart
/// class MyRepository with FirestoreTimeoutMixin {
///   Future<DocumentSnapshot> getDoc(String id) async {
///     return withTimeout(
///       () => firestore.collection('items').doc(id).get(),
///       operation: 'getDoc',
///     );
///   }
/// }
/// ```
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mixin providing standardized timeout handling for Firestore operations
mixin FirestoreTimeoutMixin {
  /// Default timeout duration for Firestore operations
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Short timeout for simple operations (single doc read/write)
  static const Duration shortTimeout = Duration(seconds: 5);

  /// Long timeout for complex operations (queries, batch writes)
  static const Duration longTimeout = Duration(seconds: 30);

  /// Execute a Firestore operation with timeout
  ///
  /// [operation] - The async operation to execute
  /// [timeout] - Timeout duration (default: 10 seconds)
  /// [operationName] - Name for debugging/logging
  ///
  /// Throws [TimeoutException] if operation exceeds timeout
  Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 10),
    String? operationName,
  }) async {
    try {
      return await operation().timeout(
        timeout,
        onTimeout: () {
          final name = operationName ?? 'Firestore operation';
          throw TimeoutException(
            '$name timed out after ${timeout.inSeconds}s',
            timeout,
          );
        },
      );
    } on TimeoutException {
      rethrow;
    }
  }

  /// Execute a Firestore operation with default timeout (10s)
  Future<T> withDefaultTimeout<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) {
    return withTimeout(
      operation,
      timeout: defaultTimeout,
      operationName: operationName,
    );
  }

  /// Execute a Firestore operation with short timeout (5s)
  ///
  /// Use for simple operations like single document reads
  Future<T> withShortTimeout<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) {
    return withTimeout(
      operation,
      timeout: shortTimeout,
      operationName: operationName,
    );
  }

  /// Execute a Firestore operation with long timeout (30s)
  ///
  /// Use for complex operations like queries with multiple where clauses
  Future<T> withLongTimeout<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) {
    return withTimeout(
      operation,
      timeout: longTimeout,
      operationName: operationName,
    );
  }

  /// Execute a Firestore operation with retries
  ///
  /// [operation] - The async operation to execute
  /// [maxRetries] - Maximum number of retry attempts (default: 3)
  /// [retryDelay] - Delay between retries (default: 1 second)
  /// [timeout] - Timeout for each attempt
  /// [operationName] - Name for debugging/logging
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 10),
    String? operationName,
  }) async {
    int attempts = 0;
    Object? lastError;

    while (attempts < maxRetries) {
      try {
        return await withTimeout(
          operation,
          timeout: timeout,
          operationName: operationName,
        );
      } on TimeoutException catch (e) {
        lastError = e;
        attempts++;

        if (kDebugMode) {
          debugPrint(
            '⏱️ [Timeout] ${operationName ?? "Operation"} '
            'attempt $attempts/$maxRetries failed: $e',
          );
        }

        if (attempts < maxRetries) {
          await Future.delayed(retryDelay * attempts);
        }
      }
    }

    throw lastError ?? TimeoutException(
      '${operationName ?? "Operation"} failed after $maxRetries attempts',
    );
  }

  /// Check if an exception is a timeout exception
  bool isTimeoutException(Object error) {
    return error is TimeoutException;
  }
}
