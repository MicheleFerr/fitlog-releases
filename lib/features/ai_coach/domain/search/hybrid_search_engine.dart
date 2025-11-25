/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/search
/// 🎯 Feature: ai_coach
/// 🔧 Type: search_engine
///
/// Hybrid Search Engine - Combines BM25 keyword search with vector embeddings
///
/// **Features**:
/// - RRF (Reciprocal Rank Fusion) for result merging
/// - Configurable weights for BM25 vs embeddings
/// - Handles semantic queries (embeddings) AND factual queries (BM25)
/// - Recency boosting for both search types
/// - Deduplication of results
/// - Target: 88-92% precision (vs 65-75% pure BM25)
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/bm25_search.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/embeddings/embedding_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/storage/in_memory_vector_store.dart';

/// Hybrid search engine combining BM25 and vector embeddings
class HybridSearchEngine { // RRF constant (standard value)

  HybridSearchEngine({
    required this.bm25Engine,
    required this.embeddingService,
    required this.vectorStore,
    this.bm25Weight = 0.4,
    this.embeddingWeight = 0.6,
  });
  final BM25SearchEngine bm25Engine;
  final EmbeddingService embeddingService;
  final InMemoryVectorStore vectorStore;

  // Configuration
  double bm25Weight = 0.4; // 40% weight to BM25 (keyword matching)
  double embeddingWeight = 0.6; // 60% weight to embeddings (semantic)
  final double rrfK = 60.0;

  /// Perform hybrid search combining BM25 and vector search
  Future<List<HybridSearchResult>> search({
    required String query,
    required String userId,
    int limit = 10,
    double minScore = 0.3,
    List<String>? documentTypes,
    bool applyRecencyBoost = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Step 1: BM25 keyword search
      final bm25Results = bm25Engine.search(
        query,
        limit: limit * 2, // Get more candidates for fusion
        minScore: minScore * 0.5, // Lower threshold for candidates
      );

      if (kDebugMode) {
        debugPrint('🔍 [HybridSearch] BM25 results: ${bm25Results.length}');
      }

      // Step 2: Vector embedding search
      final queryEmbedding = await embeddingService.embed(query);
      final vectorResults = await vectorStore.searchBySimilarity(
        queryEmbedding: queryEmbedding.toList(),
        userId: userId,
        limit: limit * 2,
        minSimilarity: minScore * 0.5,
        documentTypes: documentTypes,
        applyRecencyBoost: applyRecencyBoost,
      );

      if (kDebugMode) {
        debugPrint('🔍 [HybridSearch] Vector results: ${vectorResults.length}');
      }

      // Step 3: Apply RRF (Reciprocal Rank Fusion)
      final fusedResults = _applyRRF(
        bm25Results: bm25Results,
        vectorResults: vectorResults,
      );

      // Step 4: Sort by fused score and limit
      fusedResults.sort((a, b) => b.fusedScore.compareTo(a.fusedScore));
      final topResults = fusedResults.take(limit).toList();

      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('🔍 [HybridSearch] Search completed:');
        debugPrint('   BM25 candidates: ${bm25Results.length}');
        debugPrint('   Vector candidates: ${vectorResults.length}');
        debugPrint('   Fused results: ${fusedResults.length}');
        debugPrint('   Top ${topResults.length} returned');
        debugPrint('   Time: ${stopwatch.elapsedMilliseconds}ms');
        if (topResults.isNotEmpty) {
          debugPrint('   Top score: ${topResults.first.fusedScore.toStringAsFixed(3)}');
          debugPrint('   (BM25: ${topResults.first.bm25Score.toStringAsFixed(3)}, '
              'Vector: ${topResults.first.vectorScore.toStringAsFixed(3)})');
        }
      }

      return topResults;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔍 [HybridSearch] Search failed: $e');
      }
      rethrow;
    }
  }

  /// Apply Reciprocal Rank Fusion (RRF) to merge results
  List<HybridSearchResult> _applyRRF({
    required List<SearchResult> bm25Results,
    required List<VectorSearchResult> vectorResults,
  }) {
    // Map document ID -> hybrid result
    final Map<String, HybridSearchResult> resultMap = {};

    // Process BM25 results
    for (int rank = 0; rank < bm25Results.length; rank++) {
      final result = bm25Results[rank];
      final docId = result.document.id;

      // RRF score: 1 / (k + rank)
      final rrfScore = 1.0 / (rrfK + rank + 1);
      final weightedScore = rrfScore * bm25Weight;

      resultMap[docId] = HybridSearchResult(
        documentId: docId,
        content: result.document.content,
        bm25Score: result.normalizedScore,
        vectorScore: 0.0, // Will be updated if found in vector results
        bm25RRF: weightedScore,
        vectorRRF: 0.0,
        fusedScore: weightedScore,
        bm25Rank: rank + 1,
        vectorRank: null,
        timestamp: result.document.timestamp,
      );
    }

    // Process vector results
    for (int rank = 0; rank < vectorResults.length; rank++) {
      final result = vectorResults[rank];
      final docId = result.embedding.documentId;

      // RRF score
      final rrfScore = 1.0 / (rrfK + rank + 1);
      final weightedScore = rrfScore * embeddingWeight;

      if (resultMap.containsKey(docId)) {
        // Document found in both searches - update scores
        final existing = resultMap[docId]!;
        resultMap[docId] = HybridSearchResult(
          documentId: docId,
          content: existing.content,
          bm25Score: existing.bm25Score,
          vectorScore: result.similarity,
          bm25RRF: existing.bm25RRF,
          vectorRRF: weightedScore,
          fusedScore: existing.fusedScore + weightedScore,
          bm25Rank: existing.bm25Rank,
          vectorRank: rank + 1,
          timestamp: result.embedding.timestamp,
        );
      } else {
        // Document only in vector search
        resultMap[docId] = HybridSearchResult(
          documentId: docId,
          content: result.embedding.content,
          bm25Score: 0.0,
          vectorScore: result.similarity,
          bm25RRF: 0.0,
          vectorRRF: weightedScore,
          fusedScore: weightedScore,
          bm25Rank: null,
          vectorRank: rank + 1,
          timestamp: result.embedding.timestamp,
        );
      }
    }

    return resultMap.values.toList();
  }

  /// Adjust search weights based on query characteristics
  void adjustWeightsForQuery(String query) {
    // Heuristic: Queries with specific terms favor BM25
    // Semantic/vague queries favor embeddings

    final lowerQuery = query.toLowerCase();

    // Factual/specific queries - favor BM25
    final factualKeywords = [
      'pr', 'personal record', 'max', 'weight', 'kg', 'lbs',
      'reps', 'sets', 'volume', 'total', 'how much', 'how many',
    ];

    final hasFactualKeyword = factualKeywords.any((kw) => lowerQuery.contains(kw));

    if (hasFactualKeyword) {
      // Favor BM25 for factual queries
      bm25Weight = 0.6;
      embeddingWeight = 0.4;

      if (kDebugMode) {
        debugPrint('🔍 [HybridSearch] Adjusted weights for factual query: '
            'BM25=$bm25Weight, Embedding=$embeddingWeight');
      }
    } else {
      // Favor embeddings for semantic queries
      bm25Weight = 0.4;
      embeddingWeight = 0.6;

      if (kDebugMode) {
        debugPrint('🔍 [HybridSearch] Adjusted weights for semantic query: '
            'BM25=$bm25Weight, Embedding=$embeddingWeight');
      }
    }
  }

  /// Get search statistics
  Map<String, dynamic> getStatistics() {
    return {
      'bm25DocumentCount': bm25Engine.documents.length,
      'bm25Weight': bm25Weight,
      'embeddingWeight': embeddingWeight,
      'rrfConstant': rrfK,
    };
  }
}

/// Hybrid search result with scores from both methods
class HybridSearchResult {

  const HybridSearchResult({
    required this.documentId,
    required this.content,
    required this.bm25Score,
    required this.vectorScore,
    required this.bm25RRF,
    required this.vectorRRF,
    required this.fusedScore,
    this.bm25Rank,
    this.vectorRank,
    this.timestamp,
  });
  final String documentId;
  final String content;

  // Raw scores
  final double bm25Score;
  final double vectorScore;

  // RRF scores (weighted)
  final double bm25RRF;
  final double vectorRRF;

  // Fused score (sum of RRF scores)
  final double fusedScore;

  // Rankings
  final int? bm25Rank;
  final int? vectorRank;

  // Metadata
  final DateTime? timestamp;

  /// Check if document was found in both searches
  bool get isInBothSearches => bm25Rank != null && vectorRank != null;

  /// Get source of result
  String get source {
    if (isInBothSearches) return 'both';
    if (bm25Rank != null) return 'bm25';
    if (vectorRank != null) return 'vector';
    return 'unknown';
  }

  /// Get confidence score (0-1)
  double get confidence {
    // Higher confidence if found in both searches
    if (isInBothSearches) {
      return 0.9 + (fusedScore * 0.1).clamp(0.0, 0.1);
    }

    // Medium confidence for single source
    return 0.6 + (fusedScore * 0.3).clamp(0.0, 0.3);
  }

  @override
  String toString() {
    return 'HybridSearchResult('
        'documentId: $documentId, '
        'fusedScore: ${fusedScore.toStringAsFixed(3)}, '
        'bm25: ${bm25Score.toStringAsFixed(3)} (rank: $bm25Rank), '
        'vector: ${vectorScore.toStringAsFixed(3)} (rank: $vectorRank), '
        'source: $source, '
        'confidence: ${confidence.toStringAsFixed(2)}'
        ')';
  }
}
