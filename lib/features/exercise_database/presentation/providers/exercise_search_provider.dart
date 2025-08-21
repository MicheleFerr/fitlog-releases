import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../workout/domain/entities/exercise.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../domain/entities/exercise_template.dart';

// Search query state provider
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

// Selected category filter provider
final exerciseCategoryFilterProvider = StateProvider<ExerciseCategory?>((ref) => null);

// Selected muscle group filter provider
final exerciseMuscleGroupFilterProvider = StateProvider<String?>((ref) => null);

// Exercise search results provider
final exerciseSearchResultsProvider = StreamProvider<List<ExerciseTemplate>>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final categoryFilter = ref.watch(exerciseCategoryFilterProvider);
  final muscleGroupFilter = ref.watch(exerciseMuscleGroupFilterProvider);

  // If muscle group filter is set, prioritize it
  if (muscleGroupFilter != null) {
    return repository.getAllExercises().map((exercises) {
      return exercises.where((exercise) {
        final matchesMuscleGroup = exercise.muscleGroups.contains(muscleGroupFilter);
        final matchesCategory = categoryFilter == null || exercise.category == categoryFilter;
        final matchesQuery = query.isEmpty || 
            exercise.name.toLowerCase().contains(query.toLowerCase()) ||
            exercise.description.toLowerCase().contains(query.toLowerCase());
        
        return matchesMuscleGroup && matchesCategory && matchesQuery;
      }).toList();
    });
  }

  // If category filter is set
  if (categoryFilter != null) {
    return repository.getExercisesByCategory(categoryFilter).map((exercises) {
      if (query.isEmpty) return exercises;
      
      return exercises.where((exercise) {
        return exercise.name.toLowerCase().contains(query.toLowerCase()) ||
               exercise.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Default: search all exercises
  return repository.searchExercises(query);
});

// Popular exercises provider (cached)
final popularExercisesProvider = StreamProvider<List<ExerciseTemplate>>((ref) {
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

// Exercise search state notifier for complex filtering
final exerciseSearchStateProvider = StateNotifierProvider<ExerciseSearchNotifier, ExerciseSearchState>((ref) {
  return ExerciseSearchNotifier(ref);
});

class ExerciseSearchState {
  final String query;
  final ExerciseCategory? categoryFilter;
  final String? muscleGroupFilter;
  final List<String> equipmentFilter;
  final bool showFavorites;

  const ExerciseSearchState({
    this.query = '',
    this.categoryFilter,
    this.muscleGroupFilter,
    this.equipmentFilter = const [],
    this.showFavorites = false,
  });

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

class ExerciseSearchNotifier extends StateNotifier<ExerciseSearchState> {
  ExerciseSearchNotifier(this.ref) : super(const ExerciseSearchState());

  final Ref ref;

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