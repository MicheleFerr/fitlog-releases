/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/managers
/// 🎯 Feature: ai_coach
/// 🔧 Type: manager
///
/// Knowledge Base Manager - Cached BM25 search with automatic indexing
///
/// **Features**:
/// - Lazy initialization of search engine
/// - Automatic re-indexing on data changes
/// - Caching of search results
/// - Background indexing for performance
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/bm25_search.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/hybrid_search_engine.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/search/query_expander.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/embeddings/embedding_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/context/conversation_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/indexers/workout_knowledge_indexer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/generators/enhanced_response_generator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/storage/in_memory_vector_store.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/intent_detector.dart';
import 'package:collection/collection.dart';

/// Manages the knowledge base for AI Coach with hybrid search
class KnowledgeBaseManager {

  KnowledgeBaseManager({
    required this.workoutRepository,
    required this.analyticsRepository,
    required this.vectorStore,
    required this.embeddingService,
  }) {
    _bm25Engine = BM25SearchEngine();
    _hybridEngine = HybridSearchEngine(
      bm25Engine: _bm25Engine,
      embeddingService: embeddingService,
      vectorStore: vectorStore,
    );
    _indexer = WorkoutKnowledgeIndexer(searchEngine: _bm25Engine);
    _queryExpander = QueryExpander();
    _responseGenerator = EnhancedResponseGenerator();
    _conversationContext = ConversationContext();
  }
  final WorkoutRepository workoutRepository;
  final AnalyticsRepository analyticsRepository;
  final InMemoryVectorStore vectorStore;
  final EmbeddingService embeddingService;

  // Core components
  late final BM25SearchEngine _bm25Engine;
  late final HybridSearchEngine _hybridEngine;
  late final WorkoutKnowledgeIndexer _indexer;
  late final QueryExpander _queryExpander;
  late final EnhancedResponseGenerator _responseGenerator;
  late final ConversationContext _conversationContext;

  // Caching
  final Map<String, CachedSearchResult> _searchCache = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);

  // State
  bool _isInitialized = false;
  bool _isIndexing = false;
  DateTime? _lastIndexTime;
  String? _currentUserId;
  int _workoutCount = 0;

  // Performance tracking
  final Map<String, Duration> _performanceMetrics = {};

  /// Initialize the knowledge base for a user
  Future<void> initialize(String userId) async {
    if (_isInitialized && _currentUserId == userId) {
      // Already initialized for this user
      return;
    }

    _currentUserId = userId;

    // Index user's workout data
    await _indexWorkouts(userId);

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('🧠 [KnowledgeBase] Initialized for user: $userId');
      debugPrint('   Indexed workouts: $_workoutCount');
      debugPrint('   BM25 documents: ${_bm25Engine.documents.length}');

      final vectorStats = await vectorStore.getStatistics(userId);
      debugPrint('   Vector embeddings: ${vectorStats['totalEmbeddings']}');
    }
  }

  /// Search the knowledge base with query expansion
  Future<EnhancedSearchResponse> search({
    required String query,
    required UserIntent intent,
    String? userId,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Ensure initialized
    if (!_isInitialized || userId != _currentUserId) {
      await initialize(userId ?? _currentUserId!);
    }

    // Check cache
    final cacheKey = '${query}_$intent';
    final cached = _searchCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      if (kDebugMode) {
        debugPrint('🧠 [KnowledgeBase] Cache hit for: $query');
      }
      return cached.response;
    }

    // Enrich query with conversation context (resolve elliptical references)
    final enrichedQuery = _conversationContext.enrichQueryWithContext(query);

    if (kDebugMode && enrichedQuery != query) {
      debugPrint('🧠 [KnowledgeBase] Context enrichment:');
      debugPrint('   Original: $query');
      debugPrint('   Enriched: $enrichedQuery');
      debugPrint('   Context: ${_conversationContext.getMentionedEntitiesAsHints()}');
    }

    // Expand query
    final expandedQuery = _queryExpander.expandQuery(enrichedQuery);

    // Update conversation context with expanded query
    _conversationContext.updateLastExpandedQuery(expandedQuery);

    if (kDebugMode) {
      debugPrint('🧠 [KnowledgeBase] Query expansion:');
      debugPrint('   Original: $enrichedQuery');
      debugPrint('   Expanded: ${expandedQuery.expanded}');
      debugPrint('   Intents: ${expandedQuery.intents}');
    }

    // Adjust hybrid search weights based on query type
    _hybridEngine.adjustWeightsForQuery(query);

    // Search with hybrid engine (BM25 + embeddings)
    final hybridResults = await _hybridEngine.search(
      query: expandedQuery.expanded,
      userId: userId ?? _currentUserId!,
      limit: 10,
      minScore: 0.3,
      applyRecencyBoost: true,
    );

    // Convert hybrid results to SearchResult format for response generator
    final searchResults = hybridResults.map((hybrid) {
      return SearchResult(
        document: BM25Document(
          id: hybrid.documentId,
          content: hybrid.content,
          timestamp: hybrid.timestamp,
        ),
        score: hybrid.fusedScore * 100, // Convert to BM25 score range
        matchedTerms: {}, // Empty for hybrid results
      );
    }).toList();

    // Generate response
    final response = _responseGenerator.generateResponse(
      query: expandedQuery,
      searchResults: searchResults,
      intent: intent,
    );

    // Generate metadata
    final metadata = _responseGenerator.generateMetadata(
      searchResults: searchResults,
      query: expandedQuery,
    );

    // Create response object
    final enhancedResponse = EnhancedSearchResponse(
      query: query,
      expandedQuery: expandedQuery,
      searchResults: searchResults,
      response: response,
      metadata: metadata,
      intent: intent,
      confidence: _calculateConfidence(searchResults),
      processingTime: stopwatch.elapsed,
    );

    // Cache result
    _searchCache[cacheKey] = CachedSearchResult(
      response: enhancedResponse,
      timestamp: DateTime.now(),
    );

    // Track performance
    _performanceMetrics[query] = stopwatch.elapsed;

    stopwatch.stop();

    if (kDebugMode) {
      debugPrint('🧠 [KnowledgeBase] Search completed:');
      debugPrint('   Results: ${searchResults.length}');
      debugPrint('   Top score: ${searchResults.firstOrNull?.score.toStringAsFixed(2)}');
      debugPrint('   Confidence: ${enhancedResponse.confidence}');
      debugPrint('   Time: ${stopwatch.elapsedMilliseconds}ms');
    }

    return enhancedResponse;
  }

  /// Re-index workouts if data has changed
  Future<void> refreshIndex(String userId) async {
    if (_isIndexing) return; // Prevent concurrent indexing

    _isIndexing = true;

    try {
      await _indexWorkouts(userId);

      // Clear search cache after re-indexing
      _searchCache.clear();

      if (kDebugMode) {
        debugPrint('🧠 [KnowledgeBase] Index refreshed');
      }
    } finally {
      _isIndexing = false;
    }
  }

  /// Check if re-indexing is needed
  bool needsReindex() {
    if (!_isInitialized) return true;
    if (_lastIndexTime == null) return true;

    // Re-index if older than 10 minutes
    final age = DateTime.now().difference(_lastIndexTime!);
    return age.inMinutes > 10;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _searchCache.clear();
    _bm25Engine.clear();
    _conversationContext.clear();

    // Clear user embeddings if we have a current user
    if (_currentUserId != null) {
      await vectorStore.deleteUserEmbeddings(_currentUserId!);
    }

    _isInitialized = false;
    _lastIndexTime = null;
    _workoutCount = 0;

    if (kDebugMode) {
      debugPrint('🧠 [KnowledgeBase] Cache cleared (including conversation context)');
    }
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final avgSearchTime = _performanceMetrics.values.isEmpty
        ? Duration.zero
        : _performanceMetrics.values.reduce((a, b) => a + b) ~/
            _performanceMetrics.length;

    // Get vector store statistics
    Map<String, dynamic> vectorStats = {};
    if (_currentUserId != null) {
      vectorStats = await vectorStore.getStatistics(_currentUserId!);
    }

    // Get hybrid search statistics
    final hybridStats = _hybridEngine.getStatistics();

    return {
      'isInitialized': _isInitialized,
      'bm25DocumentsIndexed': _bm25Engine.documents.length,
      'vectorEmbeddingsIndexed': vectorStats['totalEmbeddings'] ?? 0,
      'workoutsIndexed': _workoutCount,
      'cacheSize': _searchCache.length,
      'avgSearchTime': avgSearchTime.inMilliseconds,
      'lastIndexTime': _lastIndexTime?.toIso8601String(),
      'hybridWeights': {
        'bm25': hybridStats['bm25Weight'],
        'embedding': hybridStats['embeddingWeight'],
      },
      'vectorStats': vectorStats,
    };
  }

  /// Add message to conversation context
  void addMessageToContext(AIMessage message) {
    _conversationContext.addMessage(message);
  }

  /// Get conversation context summary
  Map<String, dynamic> getConversationContextSummary() {
    return _conversationContext.getContextSummary();
  }

  /// Get suggested follow-up questions from context
  List<String> getContextualFollowUps() {
    return _conversationContext.getSuggestedFollowUps();
  }

  /// Export conversation for debugging
  String exportConversation() {
    return _conversationContext.exportConversation();
  }

  /// Get suggested queries based on user's data
  List<String> getSuggestedQueries() {
    if (!_isInitialized) return [];

    final suggestions = <String>[];

    // Add workout-based suggestions
    if (_workoutCount > 0) {
      suggestions.add('What\'s my squat PR?');
      suggestions.add('Show my progress this month');
      suggestions.add('Total volume this week');
    }

    // Add time-based suggestions
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      suggestions.add('What should I train today?');
    } else if (hour < 18) {
      suggestions.add('How was yesterday\'s workout?');
    } else {
      suggestions.add('Am I recovered for tomorrow?');
    }

    return suggestions;
  }

  // === Private Methods ===

  /// Index all workout data
  Future<void> _indexWorkouts(String userId) async {
    final stopwatch = Stopwatch()..start();

    // Get user's workouts
    final workoutsResult = await workoutRepository.getWorkouts();

    await workoutsResult.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint('🧠 [KnowledgeBase] Failed to load workouts: ${failure.message}');
        }
      },
      (workouts) async {
        _workoutCount = workouts.length;

        // Index workouts in BM25
        await _indexer.indexWorkouts(workouts);

        // Add knowledge snippets
        final snippets = _indexer.createKnowledgeSnippets(
          userId: userId,
          workouts: workouts,
        );
        _bm25Engine.addDocuments(snippets);

        // Generate and store embeddings for vector search
        await _indexEmbeddings(userId, workouts);

        // Try to index analytics (optional)
        await _indexAnalytics(userId);

        _lastIndexTime = DateTime.now();
      },
    );

    stopwatch.stop();

    if (kDebugMode) {
      debugPrint('🧠 [KnowledgeBase] Indexing completed in ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// Generate and store embeddings for vector search
  Future<void> _indexEmbeddings(String userId, List<dynamic> workouts) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Get all BM25 documents
      final documents = _bm25Engine.documents;

      if (documents.isEmpty) {
        if (kDebugMode) {
          debugPrint('🧠 [KnowledgeBase] No documents to embed');
        }
        return;
      }

      // Generate embeddings for all documents
      final storedEmbeddings = <StoredEmbedding>[];

      for (final doc in documents) {
        // Generate embedding
        final embedding = await embeddingService.embed(doc.content);

        // Determine document type from ID
        String documentType = 'unknown';
        if (doc.id.startsWith('workout_')) {
          documentType = 'workout';
        } else if (doc.id.startsWith('exercise_')) {
          documentType = 'exercise';
        } else if (doc.id.startsWith('history_')) {
          documentType = 'history';
        } else if (doc.id.startsWith('snippet_')) {
          documentType = 'snippet';
        } else if (doc.id.startsWith('superset_')) {
          documentType = 'superset';
        }

        storedEmbeddings.add(StoredEmbedding(
          documentId: doc.id,
          userId: userId,
          documentType: documentType,
          content: doc.content,
          embedding: embedding.toList(),
          timestamp: doc.timestamp ?? DateTime.now(),
          boost: doc.boost ?? 1.0,
        ));
      }

      // Store embeddings in batch (much faster)
      await vectorStore.storeEmbeddingsBatch(storedEmbeddings);

      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('🧠 [KnowledgeBase] Embeddings indexed:');
        debugPrint('   Count: ${storedEmbeddings.length}');
        debugPrint('   Time: ${stopwatch.elapsedMilliseconds}ms');
        debugPrint('   Avg: ${stopwatch.elapsedMilliseconds / storedEmbeddings.length}ms per embedding');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🧠 [KnowledgeBase] Embedding indexing error: $e');
      }
      // Don't fail entire indexing if embeddings fail
    }
  }

  /// Index analytics data
  Future<void> _indexAnalytics(String userId) async {
    try {
      // Get exercise history stream for analytics
      final historyStream = analyticsRepository.getExerciseHistory(userId);

      // Listen to the first emission only
      await historyStream.first.then((result) {
        result.fold(
          (failure) {
            // Analytics indexing is optional, don't fail
            if (kDebugMode) {
              debugPrint('🧠 [KnowledgeBase] Analytics not available');
            }
          },
          (exerciseHistories) {
            // Index exercise history data
            _indexer.indexExerciseHistories(exerciseHistories);
            if (kDebugMode) {
              debugPrint('🧠 [KnowledgeBase] Indexed ${exerciseHistories.length} exercise histories');
            }
          },
        );
      });
    } catch (e) {
      // Analytics is optional enhancement
      if (kDebugMode) {
        debugPrint('🧠 [KnowledgeBase] Analytics indexing error: $e');
      }
    }
  }

  /// Calculate confidence score from search results
  double _calculateConfidence(List<SearchResult> results) {
    if (results.isEmpty) return 0.0;

    final topScore = results.first.normalizedScore;

    if (topScore > 0.8) return 1.0; // High confidence
    if (topScore > 0.5) return 0.7; // Medium confidence
    if (topScore > 0.3) return 0.4; // Low confidence

    return 0.2; // Very low confidence
  }
}

/// Enhanced search response with metadata
class EnhancedSearchResponse {

  const EnhancedSearchResponse({
    required this.query,
    required this.expandedQuery,
    required this.searchResults,
    required this.response,
    required this.metadata,
    required this.intent,
    required this.confidence,
    required this.processingTime,
  });
  final String query;
  final ExpandedQuery expandedQuery;
  final List<SearchResult> searchResults;
  final String response;
  final Map<String, dynamic> metadata;
  final UserIntent intent;
  final double confidence;
  final Duration processingTime;

  /// Check if response is high quality
  // Lowered threshold for testing (was 0.7)
  bool get isHighQuality => confidence > 0.3 && searchResults.isNotEmpty;

  /// Get performance category
  String get performanceCategory {
    if (processingTime.inMilliseconds < 100) return 'fast';
    if (processingTime.inMilliseconds < 200) return 'normal';
    return 'slow';
  }
}

/// Cached search result with expiry
class CachedSearchResult {

  const CachedSearchResult({
    required this.response,
    required this.timestamp,
  });
  final EnhancedSearchResponse response;
  final DateTime timestamp;

  bool get isExpired {
    return DateTime.now().difference(timestamp).inMinutes > 5;
  }
}