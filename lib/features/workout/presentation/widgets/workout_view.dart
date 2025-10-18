import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_header.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/empty_states/empty_exercise_list.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

/// Vista principale quando c'è un workout attivo
/// Mostra header, lista esercizi e stati vuoti
class WorkoutView extends ConsumerWidget {

  const WorkoutView({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Performance: watch only exercises count
    final exercisesCount = ref.watch(
      currentWorkoutProvider.select((w) => w?.exercises.length ?? 0),
    );

    return Column(
      children: [
        // Header con informazioni workout
        WorkoutHeader(workout: workout),
        
        // Lista esercizi o stato vuoto
        Expanded(
          child: exercisesCount == 0
              ? const EmptyExerciseList()
              : _buildExerciseList(context, ref),
        ),
      ],
    );
  }

  Widget _buildExerciseList(BuildContext context, WidgetRef ref) {
    // Performance: use selector for exercise IDs only
    final exerciseIds = ref.watch(
      currentWorkoutProvider.select(
        (w) => w?.exercises.map((e) => e.id).toList() ?? [],
      ),
    );

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 100, // Space for FAB
      ),
      itemCount: exerciseIds.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ExerciseListItem(
            key: ValueKey(exerciseIds[index]),
            exerciseId: exerciseIds[index],
            exerciseIndex: index,
          ),
        );
      },
    );
  }
}