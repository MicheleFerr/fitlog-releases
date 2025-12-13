import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/user_exercise_preferences_repository.dart';

/// Provider for the user exercise preferences repository
final userExercisePreferencesRepositoryProvider = Provider<UserExercisePreferencesRepository>((ref) {
  return UserExercisePreferencesRepository(ref.watch(hiveBoxManagerProvider));
});

/// Provider for form cues of a specific exercise
///
/// Usage:
/// ```dart
/// final formCues = ref.watch(formCuesProvider((exerciseId: 'ex123', exerciseName: 'Bench Press')));
/// ```
final formCuesProvider = FutureProvider.autoDispose.family<String?, ({String? exerciseId, String exerciseName})>(
  (ref, params) async {
    final repository = ref.watch(userExercisePreferencesRepositoryProvider);
    return await repository.getFormCues(params.exerciseId, params.exerciseName);
  },
);

/// Provider to check if exercise has form cues
///
/// Usage:
/// ```dart
/// final hasFormCues = ref.watch(hasFormCuesProvider((exerciseId: 'ex123', exerciseName: 'Bench Press')));
/// ```
final hasFormCuesProvider = FutureProvider.autoDispose.family<bool, ({String? exerciseId, String exerciseName})>(
  (ref, params) async {
    final repository = ref.watch(userExercisePreferencesRepositoryProvider);
    return await repository.hasFormCues(params.exerciseId, params.exerciseName);
  },
);
