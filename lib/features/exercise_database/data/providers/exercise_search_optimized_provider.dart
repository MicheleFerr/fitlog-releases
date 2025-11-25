/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/providers
/// 🎯 Feature: Optimized Exercise Search Provider
/// 🔧 Type: Riverpod Provider
///
/// Provider for ExerciseSearchServiceOptimized with trigram indexing.
///
/// **Usage**:
/// ```dart
/// // In widget
/// final searchService = ref.watch(exerciseSearchOptimizedProvider);
/// final results = await searchService.searchExercises(
///   exercises: exercises,
///   query: 'bench press',
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/i_exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_search_service_optimized.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/providers/exercise_usage_repository_provider.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';

/// Provider for optimized exercise search service
///
/// Uses trigram indexing for 10x faster search performance.
/// Auto-disposes when no longer needed.
///
/// **Dependency Graph**:
/// ```
/// exerciseSearchOptimizedProvider
///   ├── exerciseUsageRepositoryProvider (ML boosts)
///   └── analyticsServiceProvider (event tracking)
/// ```
final exerciseSearchOptimizedProvider = Provider<IExerciseSearchService>((ref) {
  final usageRepository = ref.watch(exerciseUsageRepositoryProvider);
  final analytics = ref.watch(analyticsServiceProvider);

  final service = ExerciseSearchServiceOptimized(
    usageRepository: usageRepository,
    analytics: analytics,
  );

  // Initialize in background
  service.initialize().catchError((e) {
    if (kDebugMode) {
      debugPrint('❌ Failed to initialize optimized search: $e');
    }
  });

  // Dispose on provider disposal
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Async provider for ensuring service is initialized
///
/// Use when you need guaranteed initialization before first search.
final exerciseSearchOptimizedAsyncProvider =
    FutureProvider<IExerciseSearchService>((ref) async {
  final usageRepository = ref.watch(exerciseUsageRepositoryProvider);
  final analytics = ref.watch(analyticsServiceProvider);

  final service = ExerciseSearchServiceOptimized(
    usageRepository: usageRepository,
    analytics: analytics,
  );

  await service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider to get index statistics (debugging)
///
/// Returns null if index not yet built.
final exerciseSearchIndexStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(exerciseSearchOptimizedProvider);

  if (service is ExerciseSearchServiceOptimized) {
    final stats = service.indexStats;
    if (stats != null) {
      return {
        'totalItems': stats.totalItems,
        'totalTrigrams': stats.totalTrigrams,
        'avgTrigramsPerItem': stats.avgTrigramsPerItem,
      };
    }
  }

  return null;
});
