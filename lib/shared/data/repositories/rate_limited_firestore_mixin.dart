import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/domain/security/rate_limiter.dart';

/// Mixin for adding rate limiting to Firestore operations
///
/// Usage:
/// ```dart
/// class MyRepository with RateLimitedFirestoreMixin {
///   Future<void> fetchData() async {
///     await withRateLimit(
///       operation: 'fetch_data',
///       action: () async {
///         return await firestore.collection('data').get();
///       },
///     );
///   }
/// }
/// ```
mixin RateLimitedFirestoreMixin {
  /// Rate limiter manager for Firestore operations
  static final RateLimiterManager _rateLimiter = _createRateLimiter();

  /// Create rate limiter with configured endpoints
  static RateLimiterManager _createRateLimiter() {
    final manager = RateLimiterManager();

    // Configure rate limits for different operations
    manager.registerEndpoint(
      'firestore_read',
      RateLimitPresets.firebaseOptimized(),
    );

    manager.registerEndpoint(
      'firestore_write',
      RateLimitPresets.moderate(),
    );

    manager.registerEndpoint(
      'firestore_delete',
      RateLimitPresets.moderate(),
    );

    manager.registerEndpoint(
      'firestore_query',
      RateLimitPresets.firebaseOptimized(),
    );

    manager.registerEndpoint(
      'firestore_batch',
      RateLimitPresets.moderate(),
    );

    if (kDebugMode) {
      debugPrint('⏱️ Firestore rate limiter initialized');
    }

    return manager;
  }

  /// Execute Firestore read with rate limiting
  Future<T> rateLimitedRead<T>(
    Future<T> Function() action, {
    String? customEndpoint,
  }) async {
    return await withRateLimit(
      operation: customEndpoint ?? 'firestore_read',
      action: action,
    );
  }

  /// Execute Firestore write with rate limiting
  Future<T> rateLimitedWrite<T>(
    Future<T> Function() action, {
    String? customEndpoint,
  }) async {
    return await withRateLimit(
      operation: customEndpoint ?? 'firestore_write',
      action: action,
    );
  }

  /// Execute Firestore delete with rate limiting
  Future<T> rateLimitedDelete<T>(
    Future<T> Function() action, {
    String? customEndpoint,
  }) async {
    return await withRateLimit(
      operation: customEndpoint ?? 'firestore_delete',
      action: action,
    );
  }

  /// Execute Firestore query with rate limiting
  Future<T> rateLimitedQuery<T>(
    Future<T> Function() action, {
    String? customEndpoint,
  }) async {
    return await withRateLimit(
      operation: customEndpoint ?? 'firestore_query',
      action: action,
    );
  }

  /// Execute Firestore batch operation with rate limiting
  Future<T> rateLimitedBatch<T>(
    Future<T> Function() action, {
    String? customEndpoint,
  }) async {
    return await withRateLimit(
      operation: customEndpoint ?? 'firestore_batch',
      action: action,
    );
  }

  /// Generic rate-limited operation
  Future<T> withRateLimit<T>({
    required String operation,
    required Future<T> Function() action,
    int maxRetries = 3,
  }) async {
    // Try to consume token with exponential backoff
    final success = await _rateLimiter.consumeWithBackoff(
      operation,
      maxAttempts: maxRetries,
    );

    if (!success) {
      if (kDebugMode) {
        debugPrint('❌ Rate limit exceeded for $operation after $maxRetries attempts');
      }

      throw RateLimitExceededException(
        'Rate limit exceeded for $operation. Please wait and try again.',
        operation: operation,
      );
    }

    // Execute operation
    try {
      return await action();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firestore operation failed: $operation - $e');
      }
      rethrow;
    }
  }

  /// Get available tokens for an operation
  int availableTokens(String operation) {
    return _rateLimiter.availableTokens(operation);
  }

  /// Check if operation has tokens available
  bool hasTokensFor(String operation) {
    return _rateLimiter.hasTokens(operation);
  }

  /// Reset rate limiter (useful for testing)
  static void resetRateLimiter() {
    _rateLimiter.resetAll();
  }

  /// Dispose rate limiter
  static void disposeRateLimiter() {
    _rateLimiter.dispose();
  }
}

/// Exception thrown when rate limit is exceeded
class RateLimitExceededException implements Exception {

  RateLimitExceededException(this.message, {required this.operation});
  final String message;
  final String operation;

  @override
  String toString() => 'RateLimitExceededException($operation): $message';
}

/// Helper methods for common Firestore operations with rate limiting
extension RateLimitedFirestore on FirebaseFirestore {
  /// Get document with rate limiting
  Future<DocumentSnapshot<Map<String, dynamic>>> getRateLimited(
    String collectionPath,
    String docId, {
    int maxRetries = 3,
  }) async {
    final limiter = RateLimiterManager()
      ..registerEndpoint('firestore_read', RateLimitPresets.firebaseOptimized());

    final success = await limiter.consumeWithBackoff(
      'firestore_read',
      maxAttempts: maxRetries,
    );

    if (!success) {
      throw RateLimitExceededException(
        'Rate limit exceeded',
        operation: 'get_document',
      );
    }

    return await collection(collectionPath).doc(docId).get();
  }

  /// Query collection with rate limiting
  Future<QuerySnapshot<Map<String, dynamic>>> queryRateLimited(
    String collectionPath, {
    List<QueryFilter>? filters,
    int maxRetries = 3,
  }) async {
    final limiter = RateLimiterManager()
      ..registerEndpoint('firestore_query', RateLimitPresets.firebaseOptimized());

    final success = await limiter.consumeWithBackoff(
      'firestore_query',
      maxAttempts: maxRetries,
    );

    if (!success) {
      throw RateLimitExceededException(
        'Rate limit exceeded',
        operation: 'query_collection',
      );
    }

    Query<Map<String, dynamic>> query = collection(collectionPath);

    if (filters != null) {
      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }
    }

    return await query.get();
  }

  /// Set document with rate limiting
  Future<void> setRateLimited(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    int maxRetries = 3,
  }) async {
    final limiter = RateLimiterManager()
      ..registerEndpoint('firestore_write', RateLimitPresets.moderate());

    final success = await limiter.consumeWithBackoff(
      'firestore_write',
      maxAttempts: maxRetries,
    );

    if (!success) {
      throw RateLimitExceededException(
        'Rate limit exceeded',
        operation: 'set_document',
      );
    }

    await collection(collectionPath).doc(docId).set(data);
  }

  /// Update document with rate limiting
  Future<void> updateRateLimited(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    int maxRetries = 3,
  }) async {
    final limiter = RateLimiterManager()
      ..registerEndpoint('firestore_write', RateLimitPresets.moderate());

    final success = await limiter.consumeWithBackoff(
      'firestore_write',
      maxAttempts: maxRetries,
    );

    if (!success) {
      throw RateLimitExceededException(
        'Rate limit exceeded',
        operation: 'update_document',
      );
    }

    await collection(collectionPath).doc(docId).update(data);
  }

  /// Delete document with rate limiting
  Future<void> deleteRateLimited(
    String collectionPath,
    String docId, {
    int maxRetries = 3,
  }) async {
    final limiter = RateLimiterManager()
      ..registerEndpoint('firestore_delete', RateLimitPresets.moderate());

    final success = await limiter.consumeWithBackoff(
      'firestore_delete',
      maxAttempts: maxRetries,
    );

    if (!success) {
      throw RateLimitExceededException(
        'Rate limit exceeded',
        operation: 'delete_document',
      );
    }

    await collection(collectionPath).doc(docId).delete();
  }
}

/// Query filter for Firestore queries
class QueryFilter {

  QueryFilter(this.field, this.value);
  final String field;
  final dynamic value;
}
