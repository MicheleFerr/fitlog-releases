/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service interface
///
/// Service interface for exercise fuzzy search
///
/// This abstraction enables:
/// - Swapping search implementations (isolate-based, cloud-based, hybrid)
/// - Easy testing with mock services
/// - Configuration-driven search behavior
/// - Analytics integration hooks
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/models/search_config.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';

/// Service interface for exercise fuzzy search
///
/// Provides ML-enhanced fuzzy search with:
/// - Configurable thresholds and parameters
/// - User personalization (boost frequently used exercises)
/// - Category context awareness
/// - Analytics tracking
/// - Performance optimization (persistent isolate, batch processing)
///
/// Example implementations:
/// - `MLExerciseSearchService` - Local ML-enhanced search with persistent isolate
/// - `CloudExerciseSearchService` - Server-side search with caching
/// - `HybridExerciseSearchService` - Local-first with cloud fallback
/// - `MockExerciseSearchService` - For testing
///
/// Example usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final searchService = ref.watch(exerciseSearchServiceProvider);
///
///     final results = await searchService.searchExercises(
///       exercises: exercises,
///       query: 'squat',
///       userId: 'user_123',
///       config: SearchConfig.autocomplete,
///     );
///   }
/// }
/// ```
abstract class IExerciseSearchService {
  /// Initialize service (e.g., spawn persistent isolate, warm up ML models)
  ///
  /// Call this once at app startup for best performance
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   // Initialize search service
  ///   final searchService = MLExerciseSearchService(...);
  ///   await searchService.initialize();
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize();

  /// Search exercises with ML-enhanced fuzzy matching
  ///
  /// Combines:
  /// - Fuzzy string matching (Levenshtein + Jaro-Winkler)
  /// - User personalization boost (frequently used exercises rank higher)
  /// - Category context boost (exercises matching workout category rank higher)
  ///
  /// [exercises] - Full list of exercises to search
  /// [query] - User's search query
  /// [userId] - Current user ID (for personalization). Optional but recommended.
  /// [currentCategory] - Current workout category (for context boost). Optional.
  /// [config] - Search configuration (thresholds, limits, weights). Defaults to balanced settings.
  ///
  /// Returns: List of matching exercises sorted by relevance (highest score first)
  ///
  /// Example:
  /// ```dart
  /// final results = await searchService.searchExercises(
  ///   exercises: allExercises,
  ///   query: 'bench press',
  ///   userId: 'user_123',
  ///   currentCategory: 'Chest',
  ///   config: SearchConfig.autocomplete,
  /// );
  ///
  /// // Results are sorted by score
  /// for (final result in results) {
  ///   print('${result.exercise.nome}: ${result.scorePercentage}');
  /// }
  /// ```
  Future<List<ExerciseFuzzyResult>> searchExercises({
    required List<Exercise> exercises,
    required String query,
    String? userId,
    String? currentCategory,
    SearchConfig? config,
  });

  /// Find the single best match (for auto-correction)
  ///
  /// Useful for:
  /// - Auto-filling exercise name on selection
  /// - Correcting typos automatically
  /// - Smart defaults in forms
  ///
  /// [exercises] - Full list of exercises to search
  /// [query] - User's search query
  /// [minScore] - Minimum score to consider valid (0.0-1.0). Default: 0.70
  ///
  /// Returns: Best matching exercise or null if no match above minScore
  ///
  /// Example:
  /// ```dart
  /// final bestMatch = await searchService.findBestMatch(
  ///   exercises: allExercises,
  ///   query: 'sqat', // Typo
  ///   minScore: 0.70,
  /// );
  ///
  /// if (bestMatch != null) {
  ///   print('Did you mean: ${bestMatch.exercise.nome}?');
  /// }
  /// ```
  Future<ExerciseFuzzyResult?> findBestMatch({
    required List<Exercise> exercises,
    required String query,
    double minScore = 0.70,
  });

  /// Stream search results as they become available (for large datasets)
  ///
  /// Useful when:
  /// - Searching 1000+ exercises
  /// - Want to show results progressively (better UX)
  /// - Avoid blocking UI thread
  ///
  /// Results are streamed in batches as they're computed
  ///
  /// [exercises] - Full list of exercises to search
  /// [query] - User's search query
  /// [userId] - Current user ID (for personalization)
  /// [currentCategory] - Current workout category (for context boost)
  /// [config] - Search configuration
  ///
  /// Returns: Stream of matching exercises (highest scores first)
  ///
  /// Example:
  /// ```dart
  /// final stream = searchService.searchExercisesStream(
  ///   exercises: allExercises,
  ///   query: 'press',
  ///   userId: 'user_123',
  /// );
  ///
  /// await for (final result in stream) {
  ///   // Update UI progressively as results arrive
  ///   setState(() {
  ///     _results.add(result);
  ///   });
  /// }
  /// ```
  Stream<ExerciseFuzzyResult> searchExercisesStream({
    required List<Exercise> exercises,
    required String query,
    String? userId,
    String? currentCategory,
    SearchConfig? config,
  });

  /// Get search suggestions (autocomplete)
  ///
  /// Optimized for autocomplete dropdowns:
  /// - Limits results to top 10
  /// - Higher thresholds (quality over quantity)
  /// - Debounced in calling code
  ///
  /// This is a convenience method that calls `searchExercises` with autocomplete config
  ///
  /// [exercises] - Full list of exercises
  /// [query] - Partial query from user input
  /// [userId] - Current user ID (for personalization)
  /// [currentCategory] - Current workout category
  ///
  /// Returns: Top 10 matching exercises for autocomplete dropdown
  ///
  /// Example:
  /// ```dart
  /// // In autocomplete widget (with debouncing)
  /// Timer? _debounce;
  ///
  /// void _onSearchChanged(String query) {
  ///   _debounce?.cancel();
  ///   _debounce = Timer(Duration(milliseconds: 400), () async {
  ///     final suggestions = await searchService.getSuggestions(
  ///       exercises: allExercises,
  ///       query: query,
  ///       userId: userId,
  ///     );
  ///     setState(() => _suggestions = suggestions);
  ///   });
  /// }
  /// ```
  Future<List<ExerciseFuzzyResult>> getSuggestions({
    required List<Exercise> exercises,
    required String query,
    String? userId,
    String? currentCategory,
  });

  /// Dispose service resources (close isolates, cancel streams, etc.)
  ///
  /// Call this when shutting down the app or disposing the service provider
  ///
  /// Example:
  /// ```dart
  /// final searchServiceProvider = Provider<IExerciseSearchService>((ref) {
  ///   final service = MLExerciseSearchService(...);
  ///   ref.onDispose(() => service.dispose());
  ///   return service;
  /// });
  /// ```
  Future<void> dispose();
}
