import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

// Search query state provider
final exerciseSearchQueryProvider = createStateProvider<String>('');

// Selected category filter provider
final exerciseCategoryFilterProvider = createStateProvider<ExerciseCategory?>(
  null,
);

// Selected muscle group filter provider
final exerciseMuscleGroupFilterProvider = createStateProvider<String?>(null);

// Exercise search results provider
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final exerciseSearchResultsProvider =
    StreamProvider.autoDispose<List<ExerciseTemplate>>((ref) {
      final repository = ref.watch(exerciseRepositoryProvider);
      final query = ref.watch(exerciseSearchQueryProvider);
      final categoryFilter = ref.watch(exerciseCategoryFilterProvider);
      final muscleGroupFilter = ref.watch(exerciseMuscleGroupFilterProvider);

      // If muscle group filter is set, prioritize it
      if (muscleGroupFilter != null) {
        return repository.getAllExercises().map((exercises) {
          return exercises.where((exercise) {
            final matchesMuscleGroup = exercise.muscleGroups.contains(
              muscleGroupFilter,
            );
            final matchesCategory =
                categoryFilter == null || exercise.category == categoryFilter;
            final matchesQuery =
                query.isEmpty ||
                exercise.name.toLowerCase().contains(query.toLowerCase()) ||
                exercise.description.toLowerCase().contains(
                  query.toLowerCase(),
                );

            return matchesMuscleGroup && matchesCategory && matchesQuery;
          }).toList();
        });
      }

      // If category filter is set
      if (categoryFilter != null) {
        return repository.getExercisesByCategory(categoryFilter).map((
          exercises,
        ) {
          if (query.isEmpty) return exercises;

          return exercises.where((exercise) {
            return exercise.name.toLowerCase().contains(query.toLowerCase()) ||
                exercise.description.toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
        });
      }

      // Default: search all exercises
      return repository.searchExercises(query);
    });

// Popular exercises provider (cached)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final popularExercisesProvider =
    StreamProvider.autoDispose<List<ExerciseTemplate>>((ref) {
      final repository = ref.watch(exerciseRepositoryProvider);

      // Return popular exercises from each category
      return repository.getAllExercises().map((exercises) {
        final popularExercises = <ExerciseTemplate>[];

        // Get 3 exercises from each category
        for (final category in ExerciseCategory.values) {
          final categoryExercises = exercises
              .where((ex) => ex.category == category)
              .take(3)
              .toList();
          popularExercises.addAll(categoryExercises);
        }

        return popularExercises;
      });
    });

// Muscle groups provider
final muscleGroupsProvider = Provider<List<String>>((ref) {
  return [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Biceps',
    'Triceps',
    'Legs',
    'Quadriceps',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Core',
    'Abs',
    'Cardio',
  ];
});

// Exercise search service provider
final exerciseSearchServiceProvider = Provider<ExerciseSearchService>((ref) {
  final locale = ref.watch(localeProvider);
  final service = ExerciseSearchService();
  service.loadExercises(locale); // Preload exercises with correct locale
  return service;
});

// Improved search results provider using the search service
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final improvedExerciseSearchProvider =
    FutureProvider.autoDispose<List<ExerciseTemplate>>((ref) async {
      final searchService = ref.watch(exerciseSearchServiceProvider);
      final query = ref.watch(exerciseSearchQueryProvider);
      final locale = ref.watch(localeProvider);

      // The searchExercises method now handles loading internally with correct locale
      return await searchService.searchExercises(query, locale);
    });

// Exercise search state notifier for complex filtering
final exerciseSearchStateProvider =
    NotifierProvider<ExerciseSearchNotifier, ExerciseSearchState>(
      ExerciseSearchNotifier.new,
    );

class ExerciseSearchState {
  const ExerciseSearchState({
    this.query = '',
    this.categoryFilter,
    this.muscleGroupFilter,
    this.equipmentFilter = const [],
    this.showFavorites = false,
  });
  final String query;
  final ExerciseCategory? categoryFilter;
  final String? muscleGroupFilter;
  final List<String> equipmentFilter;
  final bool showFavorites;

  ExerciseSearchState copyWith({
    String? query,
    ExerciseCategory? categoryFilter,
    String? muscleGroupFilter,
    List<String>? equipmentFilter,
    bool? showFavorites,
  }) {
    return ExerciseSearchState(
      query: query ?? this.query,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      muscleGroupFilter: muscleGroupFilter ?? this.muscleGroupFilter,
      equipmentFilter: equipmentFilter ?? this.equipmentFilter,
      showFavorites: showFavorites ?? this.showFavorites,
    );
  }
}

class ExerciseSearchNotifier extends Notifier<ExerciseSearchState> {
  @override
  ExerciseSearchState build() => const ExerciseSearchState();

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateCategoryFilter(ExerciseCategory? category) {
    state = state.copyWith(categoryFilter: category);
  }

  void updateMuscleGroupFilter(String? muscleGroup) {
    state = state.copyWith(muscleGroupFilter: muscleGroup);
  }

  void toggleEquipmentFilter(String equipment) {
    final currentFilters = List<String>.from(state.equipmentFilter);
    if (currentFilters.contains(equipment)) {
      currentFilters.remove(equipment);
    } else {
      currentFilters.add(equipment);
    }
    state = state.copyWith(equipmentFilter: currentFilters);
  }

  void toggleShowFavorites() {
    state = state.copyWith(showFavorites: !state.showFavorites);
  }

  void clearFilters() {
    state = const ExerciseSearchState();
  }
}
