import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_recent_exercises.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';

/// Provider for GetRecentExercises use case
final getRecentExercisesProvider = Provider<GetRecentExercises>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetRecentExercises(repository);
});

/// Provider for recent exercise names (most recent 10)
///
/// Returns list of unique exercise names from recent workouts
/// Automatically refreshes when workout data changes
final recentExercisesProvider = FutureProvider<List<String>>((ref) async {
  final usecase = ref.watch(getRecentExercisesProvider);
  return usecase.execute(limit: 10);
});
