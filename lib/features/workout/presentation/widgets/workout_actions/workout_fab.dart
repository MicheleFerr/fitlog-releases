// COMMENTED OUT: Timer functionality moved to HeaderRestTimer
// The FAB was replaced with an integrated header timer for better UX
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
// import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
// import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
// import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_exercise_modal.dart';
// import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_customization_modal_v3.dart';
// import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
// import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
// import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
// import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
//
// /// Floating Action Button modulare per WorkoutScreen
// /// Gestisce le azioni principali: start workout, add exercise, timer
// class WorkoutFAB extends ConsumerWidget {
//   const WorkoutFAB({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Performance optimization: use .select() for specific properties
//     final hasWorkout = ref.watch(
//       currentWorkoutProvider.select((w) => w != null),
//     );
//
//     return DraggableActionButton(
//       onPressed: hasWorkout
//           ? () => _showAddExercise(context, ref)
//           : () => _startNewWorkout(context, ref),
//       icon: hasWorkout ? AppIcons.add : AppIcons.play,
//       label: hasWorkout
//           ? AppLocalizations.of(context).addExercise
//           : AppLocalizations.of(context).startWorkout,
//       positionKey: 'workout_screen_fab',
//       additionalOptions: hasWorkout
//           ? [
//               DraggableActionOption(
//                 icon: AppIcons.timer,
//                 label: 'Rest Timer', // Simplified for now
//                 onTap: () => _startRestTimer(context, ref),
//               ),
//             ]
//           : null,
//     );
//   }
//
//   void _showAddExercise(BuildContext context, WidgetRef ref) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const AddExerciseModal(),
//     );
//   }
//
//   void _startNewWorkout(BuildContext context, WidgetRef ref) {
//     // Show workout customization modal
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const WorkoutCustomizationModalV3(),
//     ).then((workoutName) {
//       if (workoutName != null && workoutName is String) {
//         // Simplified - just use existing workout start method
//         ref.read(currentWorkoutProvider.notifier).startWorkout();
//       }
//     });
//   }
//
//   void _startRestTimer(BuildContext context, WidgetRef ref) {
//     // Get the timer sound preference from app config
//     final config = ref.read(appConfigProvider);
//
//     // Start rest timer functionality using UNIFIED SYSTEM ONLY
//     ref.read(unifiedTimerProvider.notifier).startTimer(
//       durationSeconds: 90,
//       type: TimerType.rest,
//       exerciseName: 'Rest Timer', // Simplified for now
//       customSound: config.timerSound, // Pass the user's sound preference
//     );
//
//     // Show snackbar feedback
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Rest timer started!'), // Simplified for now
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
