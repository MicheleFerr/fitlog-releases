import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
import '../../providers/workout_provider.dart';
import '../../providers/zen_mode_provider.dart';
import '../add_exercise_modal.dart';
import '../workout_customization_modal.dart';

/// Floating Action Button modulare per WorkoutScreen
/// Gestisce le azioni principali: start workout, add exercise, timer
class WorkoutFAB extends ConsumerWidget {
  const WorkoutFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Performance optimization: use .select() for specific properties
    final hasWorkout = ref.watch(
      currentWorkoutProvider.select((w) => w != null),
    );
    final isWorkoutActive = ref.watch(
      currentWorkoutProvider.select((w) => w?.isActive ?? false),
    );

    return DraggableActionButton(
      onPressed: hasWorkout
          ? () => _showAddExercise(context, ref)
          : () => _startNewWorkout(context, ref),
      icon: hasWorkout ? Icons.add : Icons.play_arrow,
      label: hasWorkout
          ? AppLocalizations.of(context)!.addExercise
          : AppLocalizations.of(context)!.startWorkout,
      positionKey: 'workout_screen_fab',
      additionalOptions: hasWorkout
          ? [
              DraggableActionOption(
                icon: Icons.timer,
                label: AppLocalizations.of(context)!.restTimer,
                onTap: () => _startRestTimer(context, ref),
              ),
            ]
          : null,
    );
  }

  void _showAddExercise(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExerciseModal(),
    );
  }

  void _startNewWorkout(BuildContext context, WidgetRef ref) {
    // Show workout customization modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorkoutCustomizationModal(),
    ).then((workoutName) {
      if (workoutName != null && workoutName is String) {
        ref.read(currentWorkoutProvider.notifier).startNewWorkout(
              name: workoutName,
            );
      }
    });
  }

  void _startRestTimer(BuildContext context, WidgetRef ref) {
    // Start rest timer functionality
    ref.read(timerProvider.notifier).startTimer(
          duration: const Duration(seconds: 90),
          type: TimerType.rest,
        );
    
    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.restTimerStarted),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Timer provider placeholder - should be imported from timer feature
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.initial());

  void startTimer({
    required Duration duration,
    required TimerType type,
  }) {
    // Timer implementation
  }
}

class TimerState {
  const TimerState();
  factory TimerState.initial() => const TimerState();
}

enum TimerType { rest, workout }