/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/storage
/// 🎯 Feature: ai_coach
/// 🔧 Type: storage
///
/// In-Memory Vector Store - Simple in-memory implementation for embeddings
///
/// **Purpose**: Provides vector storage without external dependencies
/// **Status**: Phase 1 - Basic implementation (no persistence)
///
/// **Features**:
/// - In-memory embedding storage
/// - User-scoped isolation
/// - Cosine similarity search
/// - GDPR-compliant deletion
library;

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Stored embedding entity (in-memory)
class StoredEmbedding {

  StoredEmbedding({
    required this.documentId,
    required this.userId,
    required this.documentType,
    required this.content,
    required this.embedding,
    this.boost = 1.0,
    DateTime? timestamp,
    this.lastAccessedAt,
    this.expiresAt,
  })  : id = '${userId}_${documentId}_${DateTime.now().millisecondsSinceEpoch}',
        timestamp = timestamp ?? DateTime.now();
  final String id;
  final String documentId;
  final String userId;
  final String documentType;
  final String content;
  final List<double> embedding;
  final double boost;
  final DateTime timestamp;
  final DateTime? lastAccessedAt;
  final DateTime? expiresAt;

  /// Copy with updated fields
  StoredEmbedding copyWith({
    String? documentId,
    String? userId,
    String? documentType,
    String? content,
    List<double>? embedding,
    double? boost,
    DateTime? timestamp,
    DateTime? lastAccessedAt,
    DateTime? expiresAt,
  }) {
    return StoredEmbedding(
      documentId: documentId ?? this.documentId,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      content: content ?? this.content,
      embedding: embedding ?? this.embedding,
      boost: boost ?? this.boost,
      timestamp: timestamp ?? this.timestamp,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// In-memory vector store (replaces ObjectBox)
class InMemoryVectorStore {
  /// In-memory storage (user ID → list of embeddings)
  final Map<String, List<StoredEmbedding>> _storage = {};

  /// Store embedding
  Future<void> storeEmbedding(StoredEmbedding embedding) async {
    final userId = embedding.userId;
    _storage.putIfAbsent(userId, () => []).add(embedding);

    if (kDebugMode) {
      debugPrint('📦 [VectorStore] Stored embedding: ${embedding.documentId} (user: ${userId.substring(0, 8.clamp(0, userId.length))}...)');
    }
  }

  /// Similarity search (cosine similarity) - legacy method
  Future<List<StoredEmbedding>> similaritySearch({
    required String userId,
    required List<double> queryEmbedding,
    required int limit,
    String? documentType,
    double minSimilarity = 0.0,
  }) async {
    final userEmbeddings = _storage[userId] ?? [];

    // Filter by document type if specified
    var candidates = userEmbeddings;
    if (documentType != null) {
      candidates = candidates.where((e) => e.documentType == documentType).toList();
    }

    // Compute cosine similarity for each candidate
    final results = candidates.map((embedding) {
      final similarity = _cosineSimilarity(queryEmbedding, embedding.embedding);
      return _ScoredEmbedding(embedding, similarity);
    }).where((result) => result.score >= minSimilarity).toList();

    // Sort by similarity descending
    results.sort((a, b) => b.score.compareTo(a.score));

    // Return top N results
    final topResults = results.take(limit).map((r) => r.embedding).toList();

    if (kDebugMode) {
      debugPrint('🔍 [VectorStore] Similarity search: ${topResults.length} results (limit: $limit)');
    }

    return topResults;
  }

  /// Search by similarity with full result metadata (for hybrid search)
  Future<List<VectorSearchResult>> searchBySimilarity({
    required List<double> queryEmbedding,
    required String userId,
    required int limit,
    double minSimilarity = 0.0,
    List<String>? documentTypes,
    bool applyRecencyBoost = true,
  }) async {
    final userEmbeddings = _storage[userId] ?? [];

    // Filter by document types if specified
    var candidates = userEmbeddings;
    if (documentTypes != null && documentTypes.isNotEmpty) {
      candidates = candidates.where((e) => documentTypes.contains(e.documentType)).toList();
    }

    // Compute cosine similarity for each candidate
    final results = candidates.map((embedding) {
      var similarity = _cosineSimilarity(queryEmbedding, embedding.embedding);

      // Apply recency boost if enabled
      if (applyRecencyBoost) {
        final ageInDays = DateTime.now().difference(embedding.timestamp).inDays;
        final recencyBoost = 1.0 / (1.0 + (ageInDays / 30.0)); // Decay over 30 days
        similarity *= (0.8 + 0.2 * recencyBoost); // 80% base + 20% recency
      }

      // Apply document boost
      similarity *= embedding.boost;

      return VectorSearchResult(
        embedding: embedding,
        similarity: similarity,
      );
    }).where((result) => result.similarity >= minSimilarity).toList();

    // Sort by similarity descending
    results.sort((a, b) => b.similarity.compareTo(a.similarity));

    // Return top N results
    final topResults = results.take(limit).toList();

    if (kDebugMode) {
      debugPrint('🔍 [VectorStore] searchBySimilarity: ${topResults.length} results (limit: $limit, recency: $applyRecencyBoost)');
    }

    return topResults;
  }

  /// Cosine similarity between two vectors
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final denominator = math.sqrt(normA) * math.sqrt(normB);
    if (denominator == 0) return 0.0;

    return dotProduct / denominator;
  }

  /// Get embedding by document ID
  Future<StoredEmbedding?> getEmbedding({
    required String documentId,
    required String userId,
  }) async {
    final userEmbeddings = _storage[userId] ?? [];
    try {
      return userEmbeddings.firstWhere((e) => e.documentId == documentId);
    } catch (_) {
      return null;
    }
  }

  /// Update embedding
  Future<void> updateEmbedding(StoredEmbedding embedding) async {
    final userId = embedding.userId;
    final userEmbeddings = _storage[userId];

    if (userEmbeddings == null) return;

    final index = userEmbeddings.indexWhere((e) => e.documentId == embedding.documentId);
    if (index != -1) {
      userEmbeddings[index] = embedding;
    }
  }

  /// Delete embedding
  Future<void> deleteEmbedding({
    required String documentId,
    required String userId,
  }) async {
    final userEmbeddings = _storage[userId];
    if (userEmbeddings == null) return;

    userEmbeddings.removeWhere((e) => e.documentId == documentId);

    if (kDebugMode) {
      debugPrint('🗑️ [VectorStore] Deleted embedding: $documentId (user: ${userId.substring(0, 8.clamp(0, userId.length))}...)');
    }
  }

  /// Delete all embeddings for user (GDPR compliance)
  Future<void> deleteUserEmbeddings(String userId) async {
    _storage.remove(userId);

    if (kDebugMode) {
      debugPrint('🗑️ [VectorStore] Deleted all embeddings for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
    }
  }

  /// Get embedding count for user
  Future<int> getEmbeddingCount(String userId) async {
    return _storage[userId]?.length ?? 0;
  }

  /// Get embeddings by type
  Future<List<StoredEmbedding>> getEmbeddingsByType({
    required String userId,
    required String documentType,
    int? limit,
  }) async {
    final userEmbeddings = _storage[userId] ?? [];
    final filtered = userEmbeddings.where((e) => e.documentType == documentType);

    if (limit != null) {
      return filtered.take(limit).toList();
    }

    return filtered.toList();
  }

  /// Delete old embeddings (older than cutoff date)
  Future<int> deleteOldEmbeddings({
    required String userId,
    required DateTime cutoffDate,
  }) async {
    final userEmbeddings = _storage[userId];
    if (userEmbeddings == null) return 0;

    final initialCount = userEmbeddings.length;
    userEmbeddings.removeWhere((e) => e.timestamp.isBefore(cutoffDate));
    final deletedCount = initialCount - userEmbeddings.length;

    if (kDebugMode && deletedCount > 0) {
      debugPrint('🗑️ [VectorStore] Deleted $deletedCount old embeddings (user: ${userId.substring(0, 8.clamp(0, userId.length))}...)');
    }

    return deletedCount;
  }

  /// Get recent embeddings
  Future<List<StoredEmbedding>> getRecentEmbeddings({
    required String userId,
    required DateTime since,
    int? limit,
  }) async {
    final userEmbeddings = _storage[userId] ?? [];
    final recent = userEmbeddings.where((e) => e.timestamp.isAfter(since)).toList();

    // Sort by timestamp descending
    recent.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null) {
      return recent.take(limit).toList();
    }

    return recent;
  }

  /// Get embeddings by type and date range
  Future<List<StoredEmbedding>> getEmbeddingsByTypeAndDateRange({
    required String userId,
    required String documentType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userEmbeddings = _storage[userId] ?? [];
    return userEmbeddings
        .where((e) =>
            e.documentType == documentType &&
            e.timestamp.isAfter(startDate) &&
            e.timestamp.isBefore(endDate))
        .toList();
  }

  /// Clear all data (for testing)
  Future<void> clearAll() async {
    _storage.clear();

    if (kDebugMode) {
      debugPrint('🗑️ [VectorStore] Cleared all data');
    }
  }

  /// Get statistics for user's embeddings
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    final userEmbeddings = _storage[userId] ?? [];

    // Count by document type
    final typeCount = <String, int>{};
    for (final embedding in userEmbeddings) {
      typeCount[embedding.documentType] = (typeCount[embedding.documentType] ?? 0) + 1;
    }

    // Get date range
    DateTime? oldestDate;
    DateTime? newestDate;
    if (userEmbeddings.isNotEmpty) {
      oldestDate = userEmbeddings.map((e) => e.timestamp).reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      newestDate = userEmbeddings.map((e) => e.timestamp).reduce(
        (a, b) => a.isAfter(b) ? a : b,
      );
    }

    return {
      'totalCount': userEmbeddings.length,
      'byType': typeCount,
      'oldestTimestamp': oldestDate?.toIso8601String(),
      'newestTimestamp': newestDate?.toIso8601String(),
      'dimensionality': userEmbeddings.isNotEmpty ? userEmbeddings.first.embedding.length : 0,
    };
  }

  /// Store multiple embeddings in batch
  Future<void> storeEmbeddingsBatch(List<StoredEmbedding> embeddings) async {
    for (final embedding in embeddings) {
      await storeEmbedding(embedding);
    }

    if (kDebugMode) {
      debugPrint('📦 [VectorStore] Batch stored ${embeddings.length} embeddings');
    }
  }
}

/// Vector search result with similarity score
class VectorSearchResult {

  VectorSearchResult({
    required this.embedding,
    required this.similarity,
  });
  final StoredEmbedding embedding;
  final double similarity;
}

/// Helper class for scored embeddings
class _ScoredEmbedding {

  _ScoredEmbedding(this.embedding, this.score);
  final StoredEmbedding embedding;
  final double score;
}
