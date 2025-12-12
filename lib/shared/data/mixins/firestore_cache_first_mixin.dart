/// Mixin that provides cache-first query patterns for Firestore
///
/// This follows Flutter/Firebase best practices for 2025:
/// - Read from cache first (instant response)
/// - Fallback to server if cache miss
/// - Reduces Firestore read costs
/// - Improves offline UX
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Mixin providing cache-first Firestore query patterns
mixin FirestoreCacheFirstMixin {

  /// Get a document with cache-first strategy
  ///
  /// 1. Try cache first (instant)
  /// 2. If cache miss or stale, fetch from server
  /// 3. Returns null if document doesn't exist
  Future<DocumentSnapshot<Map<String, dynamic>>?> getCacheFirst(
    DocumentReference<Map<String, dynamic>> docRef, {
    bool forceServer = false,
  }) async {
    if (forceServer) {
      return _getFromServer(docRef);
    }

    try {
      // Try cache first
      final cachedDoc = await docRef.get(const GetOptions(source: Source.cache));

      if (cachedDoc.exists) {
        if (kDebugMode) {
          debugPrint('📦 Cache hit: ${docRef.path}');
        }
        return cachedDoc;
      }
    } catch (e) {
      // Cache miss - fall through to server
      if (kDebugMode) {
        debugPrint('📦 Cache miss: ${docRef.path}');
      }
    }

    // Fallback to server
    return _getFromServer(docRef);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getFromServer(
    DocumentReference<Map<String, dynamic>> docRef,
  ) async {
    try {
      final serverDoc = await docRef.get(const GetOptions(source: Source.server));
      if (kDebugMode) {
        debugPrint('🌐 Server fetch: ${docRef.path}');
      }
      return serverDoc.exists ? serverDoc : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Server fetch failed: ${docRef.path} - $e');
      }
      return null;
    }
  }

  /// Query with cache-first strategy
  ///
  /// 1. Try cache first
  /// 2. If empty or error, fetch from server
  Future<QuerySnapshot<Map<String, dynamic>>> queryCacheFirst(
    Query<Map<String, dynamic>> query, {
    bool forceServer = false,
  }) async {
    if (forceServer) {
      return query.get(const GetOptions(source: Source.server));
    }

    try {
      // Try cache first
      final cachedResult = await query.get(const GetOptions(source: Source.cache));

      if (cachedResult.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('📦 Query cache hit: ${cachedResult.docs.length} docs');
        }
        return cachedResult;
      }
    } catch (e) {
      // Cache miss
      if (kDebugMode) {
        debugPrint('📦 Query cache miss');
      }
    }

    // Fallback to server
    if (kDebugMode) {
      debugPrint('🌐 Query server fetch');
    }
    return query.get(const GetOptions(source: Source.server));
  }

  /// Get with timeout and cache fallback
  ///
  /// Tries server with timeout, falls back to cache if timeout
  Future<DocumentSnapshot<Map<String, dynamic>>?> getWithCacheFallback(
    DocumentReference<Map<String, dynamic>> docRef, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // Try server with timeout
      final serverDoc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(timeout);
      return serverDoc.exists ? serverDoc : null;
    } catch (e) {
      // Timeout or error - try cache
      if (kDebugMode) {
        debugPrint('⏱️ Server timeout, trying cache: ${docRef.path}');
      }
      try {
        final cachedDoc = await docRef.get(const GetOptions(source: Source.cache));
        return cachedDoc.exists ? cachedDoc : null;
      } catch (_) {
        return null;
      }
    }
  }
}
