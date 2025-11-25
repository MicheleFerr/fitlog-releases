/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: Riverpod provider
///
/// Riverpod provider for IExerciseSearchService
///
/// This provider enables Dependency Injection for the search service,
/// automatically wiring up dependencies:
/// - IExerciseUsageRepository (for ML boosts)
/// - IAnalyticsService (for tracking)
/// - ExerciseFuzzySearchIsolate (for fuzzy matching)
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/i_exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/ml_exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/providers/exercise_usage_repository_provider.dart';
// Analytics provider from SSOT - core/providers/analytics_provider.dart
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';

/// Provider for IExerciseSearchService
///
/// Automatically wires up dependencies via Riverpod:
/// ```
/// exerciseSearchServiceProvider
///   ├── watches exerciseUsageRepositoryProvider
///   └── watches analyticsServiceProvider
/// ```
///
/// Example usage in widgets:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final searchService = ref.watch(exerciseSearchServiceProvider);
///
///     // Use service
///     final results = await searchService.searchExercises(
///       exercises: exercises,
///       query: query,
///       userId: userId,
///       config: SearchConfig.autocomplete,
///     );
///   }
/// }
/// ```
///
/// Example override in tests:
/// ```dart
/// testWidgets('should use mock search service', (tester) async {
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: [
///         exerciseSearchServiceProvider.overrideWithValue(mockService),
///       ],
///       child: MyApp(),
///     ),
///   );
/// });
/// ```
final exerciseSearchServiceProvider = Provider<IExerciseSearchService>((ref) {
  // Get dependencies from other providers
  final usageRepository = ref.watch(exerciseUsageRepositoryProvider);
  final analytics = ref.watch(analyticsServiceProvider);

  // Create service with injected dependencies
  final service = MLExerciseSearchService(
    usageRepository: usageRepository,
    analytics: analytics,
  );

  // Initialize service asynchronously
  // Note: This runs in background, service will throw if used before init completes
  service.initialize().catchError((e) {
    // Log error but don't crash app
    if (kDebugMode) {
      debugPrint('❌ Failed to initialize search service: $e');
    }
  });

  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Async provider variant for ensuring service is initialized
///
/// Use this when you need to ensure the service is fully initialized
/// before using it (e.g., in app startup logic)
///
/// Most cases should use the synchronous `exerciseSearchServiceProvider`
/// which initializes in background
///
/// Example usage:
/// ```dart
/// final serviceAsync = ref.watch(exerciseSearchServiceAsyncProvider);
///
/// serviceAsync.when(
///   data: (service) => // Use fully initialized service,
///   loading: () => LoadingIndicator(),
///   error: (e, s) => ErrorWidget(e),
/// );
/// ```
final exerciseSearchServiceAsyncProvider =
    FutureProvider<IExerciseSearchService>((ref) async {
  // Get dependencies
  final usageRepository = ref.watch(exerciseUsageRepositoryProvider);
  final analytics = ref.watch(analyticsServiceProvider);

  // Create service
  final service = MLExerciseSearchService(
    usageRepository: usageRepository,
    analytics: analytics,
  );

  // Initialize service (await completion)
  await service.initialize();

  // Dispose on provider disposal
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for checking if search service is initialized
///
/// Useful for app startup logic to ensure search is ready
final isSearchServiceInitializedProvider = StateProvider<bool>((ref) => false);
