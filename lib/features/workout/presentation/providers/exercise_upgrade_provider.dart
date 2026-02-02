/// Exercise Upgrade Provider
///
/// Provides access to exercise upgrade operations for counting
/// and updating exercises across workouts and templates.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_upgrade_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';

/// Provider for exercise upgrade service
final exerciseUpgradeServiceProvider = Provider<ExerciseUpgradeService>((ref) {
  ref.keepAlive(); // FIX: previene ricreazione service
  final historyRepository = ref.watch(workoutHistoryRepositoryProvider);
  final templateRepository = ref.watch(templateRepositoryProvider);

  return ExerciseUpgradeService(
    historyRepository: historyRepository,
    templateRepository: templateRepository,
  );
});

/// Provider to get affected items count for an exercise
///
/// Use this to show how many workouts/templates will be affected
/// when upgrading an exercise.
final affectedItemsCountProvider = FutureProvider.autoDispose
    .family<AffectedItemsCount, String>((ref, exerciseName) async {
      final service = ref.watch(exerciseUpgradeServiceProvider);
      return service.countAffectedItems(exerciseName);
    });
