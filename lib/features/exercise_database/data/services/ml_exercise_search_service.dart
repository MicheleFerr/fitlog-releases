/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service implementation
///
/// ML-enhanced exercise search service implementation
///
/// This service provides:
/// - Fuzzy string matching with persistent isolate
/// - ML-based personalization (user boost, category boost)
/// - Configurable search parameters
/// - Analytics tracking hooks
/// - Performance optimization (batch processing, caching)
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/models/search_config.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/repositories/i_exercise_usage_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/i_exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_search_isolate.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/shared/domain/services/i_analytics_service.dart';

/// ML-enhanced fuzzy search service implementation
///
/// Architecture:
/// ```
/// MLExerciseSearchService
///   ├── IExerciseUsageRepository (DI) → User boost data
///   ├── IAnalyticsService (DI) → Event tracking
///   └── ExerciseFuzzySearchIsolate → Fuzzy matching
/// ```
///
/// Example usage:
/// ```dart
/// final service = MLExerciseSearchService(
///   usageRepository: HiveExerciseUsageRepository(box),
///   analytics: FirebaseAnalyticsService(),
/// );
///
/// await service.initialize();
///
/// final results = await service.searchExercises(
///   exercises: allExercises,
///   query: 'bench press',
///   userId: 'user_123',
///   config: SearchConfig.autocomplete,
/// );
/// ```
class MLExerciseSearchService implements IExerciseSearchService {

  /// Create ML search service with dependencies
  ///
  /// [usageRepository] - Repository for exercise usage tracking (required)
  /// [analytics] - Analytics service for event tracking (required)
  /// [isolateService] - Optional custom isolate service (defaults to singleton)
  MLExerciseSearchService({
    required IExerciseUsageRepository usageRepository,
    required IAnalyticsService analytics,
    ExerciseFuzzySearchIsolate? isolateService,
  })  : _usageRepository = usageRepository,
        _analytics = analytics,
        _isolateService = isolateService ?? ExerciseFuzzySearchIsolate();
  /// Repository for ML user boost data (injected)
  final IExerciseUsageRepository _usageRepository;

  /// Analytics service for tracking (injected)
  final IAnalyticsService _analytics;

  /// Persistent isolate service for fuzzy search
  final ExerciseFuzzySearchIsolate _isolateService;

  /// Flag to track initialization state
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('⚠️ MLExerciseSearchService already initialized');
      }
      return;
    }

    try {
      // Initialize persistent isolate
      await _isolateService.initialize();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ MLExerciseSearchService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ MLExerciseSearchService initialization error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<ExerciseFuzzyResult>> searchExercises({
    required List<Exercise> exercises,
    required String query,
    String? userId,
    String? currentCategory,
    SearchConfig? config,
  }) async {
    _ensureInitialized();

    // Use provided config or default
    final effectiveConfig = config ?? const SearchConfig();

    // Validate configuration
    try {
      effectiveConfig.validate();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Invalid SearchConfig: $e');
      }
      // Fall back to default config
      return searchExercises(
        exercises: exercises,
        query: query,
        userId: userId,
        currentCategory: currentCategory,
        config: const SearchConfig(),
      );
    }

    // Track search start
    await _analytics.trackSearch(
      query: query,
      resultsCount: 0, // Will update later
      userBoostEnabled: effectiveConfig.enableUserBoost,
      categoryBoostEnabled: effectiveConfig.enableCategoryBoost,
    );

    try {
      // OPTIMIZATION 1: Pre-calculate ALL user boosts in BATCH
      final Map<String, double> userBoosts = {};

      if (effectiveConfig.enableUserBoost && userId != null) {
        final exerciseIds = exercises.map((e) => e.id).toList();

        // Use injected repository for batch boosts
        userBoosts.addAll(await _usageRepository.getBatchBoosts(exerciseIds));

        if (kDebugMode) {
          debugPrint('✅ Batch pre-calculated ${userBoosts.length} user boosts (via repository)');
        }
      }

      // OPTIMIZATION 2: Use persistent isolate for fuzzy search
      final isolateResults = await _isolateService.search(
        query: query,
        exercises: exercises,
        userBoosts: userBoosts,
        currentCategory:
            effectiveConfig.enableCategoryBoost ? currentCategory : null,
        strictThreshold: effectiveConfig.strictThreshold,
        typeThreshold: effectiveConfig.typeThreshold,
        maxResults: effectiveConfig.maxResults,
      );

      // Convert isolate results to domain model
      final results = isolateResults
          .map((r) => ExerciseFuzzyResult(
                exercise: r.exercise,
                score: r.score,
                matchedText: r.matchedText,
                wasAutoCorrected: r.wasAutoCorrected,
              ))
          .toList();

      // Track search completion with result count
      await _analytics.logEvent('exercise_search_completed', parameters: {
        'query': query,
        'results_count': results.length,
        'user_boost_enabled': effectiveConfig.enableUserBoost,
        'category_boost_enabled': effectiveConfig.enableCategoryBoost,
        'has_ml_weights': effectiveConfig.mlWeights != null,
      });

      return results;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Search error: $e');
      }

      // Track search error
      await _analytics.logEvent('exercise_search_error', parameters: {
        'query': query,
        'error': e.toString(),
      });

      return [];
    }
  }

  @override
  Future<ExerciseFuzzyResult?> findBestMatch({
    required List<Exercise> exercises,
    required String query,
    double minScore = 0.70,
  }) async {
    _ensureInitialized();

    // Search with limit 1
    final results = await searchExercises(
      exercises: exercises,
      query: query,
      config: const SearchConfig(maxResults: 1),
    );

    // Return best match if score is above threshold
    if (results.isEmpty || results.first.score < minScore) {
      return null;
    }

    return results.first;
  }

  @override
  Stream<ExerciseFuzzyResult> searchExercisesStream({
    required List<Exercise> exercises,
    required String query,
    String? userId,
    String? currentCategory,
    SearchConfig? config,
  }) async* {
    _ensureInitialized();

    // For now, execute search and stream results in batches
    // Future optimization: Implement true streaming in isolate
    final results = await searchExercises(
      exercises: exercises,
      query: query,
      userId: userId,
      currentCategory: currentCategory,
      config: config,
    );

    // Stream results in batches of 10
    const batchSize = 10;
    for (var i = 0; i < results.length; i += batchSize) {
      final batch = results.skip(i).take(batchSize);
      for (final result in batch) {
        yield result;
      }
      // Small delay between batches to avoid blocking UI
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  @override
  Future<List<ExerciseFuzzyResult>> getSuggestions({
    required List<Exercise> exercises,
    required String query,
    String? userId,
    String? currentCategory,
  }) async {
    _ensureInitialized();

    // Use autocomplete config (optimized for dropdowns)
    return searchExercises(
      exercises: exercises,
      query: query,
      userId: userId,
      currentCategory: currentCategory,
      config: SearchConfig.autocomplete,
    );
  }

  @override
  Future<void> dispose() async {
    try {
      await _isolateService.dispose();
      _isInitialized = false;

      if (kDebugMode) {
        debugPrint('🔒 MLExerciseSearchService disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing service: $e');
      }
    }
  }

  /// Ensure service is initialized before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'MLExerciseSearchService not initialized. Call initialize() first.',
      );
    }
  }
}
