/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: workout
 * 🔧 Type: screen (PERFORMANCE OPTIMIZED)
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive  
 * 📱 Platform: iOS/Android/Universal
 * 
 * Dependencies:
 * - Riverpod: Family providers + selective watching
 * - Firebase: Workout persistence
 * - GoRouter: Navigation
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../../shared/presentation/widgets/premium_action_button.dart';
import '../../../../shared/presentation/widgets/draggable_action_button.dart';
import '../../../../shared/presentation/widgets/draggable_tutorial_overlay.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/exercise.dart';
import '../domain/entities/workout_template.dart' as wt;
import 'providers/workout_provider.dart';
import 'providers/workout_template_provider.dart';
import 'widgets/add_exercise_modal.dart';
import 'widgets/exercise_list_item_optimized.dart';
import '../../../timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import '../../../timer/presentation/providers/unified_timer_provider.dart';
import '../../../timer/presentation/providers/unified_timer_extensions.dart';
import 'providers/zen_mode_provider.dart';
import 'widgets/zen_mode_settings_dialog.dart';

// 🚀 PERFORMANCE OPTIMIZED WORKOUT SCREEN
class OptimizedWorkoutScreen extends ConsumerWidget {
  const OptimizedWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Stack(
        children: [
          // Main content with selective providers
          _WorkoutContent(),
          // Tier-1 Timer Overlay
          Consumer(
            builder: (context, ref, child) {
              final shouldShow = ref.watch(shouldShowTier1TimerProvider);
              return shouldShow ? const Tier1MinimalTimerOverlay() : const SizedBox.shrink();
            },
          ),
          // FAB with draggable functionality
          _OptimizedFAB(),
        ],
      ),
    );
  }
}

// 📱 WORKOUT CONTENT - Separated for better performance
class _WorkoutContent extends ConsumerWidget {
  const _WorkoutContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 SELECTIVE WATCHING - Only essential workout state
    final hasWorkout = ref.watch(currentWorkoutProvider.select((w) => w != null));
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackNavigation(context, ref);
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context, ref),
        body: hasWorkout 
          ? const _ActiveWorkoutView()
          : const _WelcomeView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const _WorkoutTitle(),
      leading: const _BackButton(),
      actions: const [
        _WorkoutActions(),
      ],
    );
  }
}

// 🏷️ WORKOUT TITLE - Only rebuilds when name changes
class _WorkoutTitle extends ConsumerWidget {
  const _WorkoutTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 ZEN MODE STATUS
    final zenIsEnabled = ref.watch(zenModeProvider.select((z) => z.isEnabled));
    final zenHideTutorials = ref.watch(zenModeProvider.select((z) => z.config.hideTutorials));
    
    // 🎯 WORKOUT NAME - Only name changes trigger rebuild
    final workoutName = ref.watch(workoutNameProvider);
    
    return Row(
      children: [
        if (zenIsEnabled) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'ZEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            workoutName ?? 'GymBro TrackLog',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ⬅️ BACK BUTTON - Conditional based on workout state
class _BackButton extends ConsumerWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutIsActive = ref.watch(workoutIsActiveProvider);
    
    return IconButton(
      icon: Icon(workoutIsActive ? Icons.home : Icons.arrow_back),
      onPressed: () => workoutIsActive 
        ? _handleBackNavigation(context, ref)
        : context.goNamed('home'),
      tooltip: workoutIsActive 
        ? AppLocalizations.of(context)!.backToHomeKeepWorkout
        : AppLocalizations.of(context)!.backToHome,
    );
  }
}

// ⚙️ WORKOUT ACTIONS - Menu and completion
class _WorkoutActions extends ConsumerWidget {
  const _WorkoutActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutIsActive = ref.watch(workoutIsActiveProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (workoutIsActive)
          IconButton(
            onPressed: () => _completeWorkout(context, ref),
            icon: const Icon(Icons.check_circle),
            tooltip: AppLocalizations.of(context)!.completeWorkout,
          ),
        IconButton(
          onPressed: () => _showSettingsMenu(context, ref),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}

// 🏠 WELCOME VIEW - Shown when no active workout
class _WelcomeView extends ConsumerWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.welcomeToWorkout,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.startWorkoutDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const _QuickStartOptions(),
        ],
      ),
    );
  }
}

// 🚀 QUICK START OPTIONS
class _QuickStartOptions extends ConsumerWidget {
  const _QuickStartOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _startNewWorkout(context, ref),
          icon: const Icon(Icons.play_arrow),
          label: Text(AppLocalizations.of(context)!.startEmptyWorkout),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _navigateToTemplates(context),
          icon: const Icon(Icons.assignment),
          label: Text(AppLocalizations.of(context)!.useTemplate),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }
}

// 🏋️‍♂️ ACTIVE WORKOUT VIEW - Optimized exercise list
class _ActiveWorkoutView extends ConsumerWidget {
  const _ActiveWorkoutView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Workout stats header
        const _WorkoutStatsHeader(),
        // Exercise list - highly optimized
        const Expanded(
          child: _OptimizedExerciseList(),
        ),
      ],
    );
  }
}

// 📊 WORKOUT STATS HEADER - Memoized stats
class _WorkoutStatsHeader extends ConsumerWidget {
  const _WorkoutStatsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 SELECTIVE STATS - Only rebuild when stats change
    final totalSets = ref.watch(workoutTotalSetsProvider);
    final completedSets = ref.watch(workoutCompletedSetsProvider);
    final progress = ref.watch(workoutProgressProvider);
    final exerciseCount = ref.watch(workoutExerciseCountProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.fitness_center,
                label: AppLocalizations.of(context)!.exercises,
                value: exerciseCount.toString(),
                color: Theme.of(context).colorScheme.primary,
              ),
              _StatItem(
                icon: Icons.format_list_numbered,
                label: AppLocalizations.of(context)!.totalSets,
                value: totalSets.toString(),
                color: Theme.of(context).colorScheme.secondary,
              ),
              _StatItem(
                icon: Icons.check_circle,
                label: AppLocalizations.of(context)!.completed,
                value: completedSets.toString(),
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.progress,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 📈 STAT ITEM - Reusable stat display
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

// 📋 OPTIMIZED EXERCISE LIST - Family provider based
class _OptimizedExerciseList extends ConsumerWidget {
  const _OptimizedExerciseList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 SELECTIVE WATCHING - Only exercise IDs list
    final exerciseIds = ref.watch(exerciseOrderProvider);
    
    if (exerciseIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noExercisesYet,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tapPlusToAddExercise,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 100), // Space for FAB
      itemCount: exerciseIds.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(currentWorkoutProvider.notifier).reorderExercises(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final exerciseId = exerciseIds[index];
        
        return OptimizedExerciseListItem(
          key: ValueKey(exerciseId),
          exerciseId: exerciseId,
          onTap: () => _editExercise(context, ref, exerciseId),
          onDelete: () => _deleteExercise(context, ref, exerciseId),
          onSetUpdate: (set) => _updateSet(ref, exerciseId, set),
          onSetToggleComplete: (set) => _toggleSetComplete(ref, exerciseId, set),
          onExerciseUpdate: (exercise) => _updateExercise(ref, exercise),
        );
      },
    );
  }
}

// 🎯 OPTIMIZED FAB - Draggable with context-aware options
class _OptimizedFAB extends ConsumerWidget {
  const _OptimizedFAB();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 SELECTIVE WATCHING - Only what affects FAB
    final hasWorkout = ref.watch(currentWorkoutProvider.select((w) => w != null));
    final zenIsEnabled = ref.watch(zenModeProvider.select((z) => z.isEnabled));
    final zenHideTutorials = ref.watch(zenModeProvider.select((z) => z.config.hideTutorials));
    
    final showTutorials = !zenIsEnabled || !zenHideTutorials;
    
    final fabButton = DraggableActionButton(
      onPressed: hasWorkout
          ? () => _showAddExercise(context, ref)
          : () => _startNewWorkout(context, ref),
      icon: hasWorkout ? Icons.add : Icons.play_arrow,
      label: hasWorkout
          ? AppLocalizations.of(context)!.addExercise
          : AppLocalizations.of(context)!.startWorkout,
      positionKey: 'workout_screen_fab',
      additionalOptions: hasWorkout ? [
        DraggableActionOption(
          icon: Icons.timer,
          label: AppLocalizations.of(context)!.restTimer,
          onTap: () => _showRestTimer(context),
          color: Theme.of(context).colorScheme.secondary,
        ),
        DraggableActionOption(
          icon: Icons.save,
          label: AppLocalizations.of(context)!.saveAsTemplate,
          onTap: () => _saveAsTemplate(context, ref),
          color: Theme.of(context).colorScheme.primary,
        ),
      ] : [
        DraggableActionOption(
          icon: Icons.assignment,
          label: AppLocalizations.of(context)!.templates,
          onTap: () => _navigateToTemplates(context),
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ],
    );

    return showTutorials
        ? DraggableTutorialOverlay(
            tutorialKey: 'workout_fab',
            child: fabButton,
          )
        : fabButton;
  }
}

// 🛠️ HELPER FUNCTIONS

void _handleBackNavigation(BuildContext context, WidgetRef ref) {
  final workoutIsActive = ref.read(workoutIsActiveProvider);
  
  if (workoutIsActive) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.leaveWorkout),
        content: Text(AppLocalizations.of(context)!.leaveWorkoutDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.goNamed('home');
            },
            child: Text(AppLocalizations.of(context)!.leave),
          ),
        ],
      ),
    );
  } else {
    context.goNamed('home');
  }
}

void _completeWorkout(BuildContext context, WidgetRef ref) {
  HapticFeedback.heavyImpact();
  ref.read(currentWorkoutProvider.notifier).completeWorkout();
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.celebration,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.workoutCompleted),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _showSettingsMenu(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const ZenModeSettingsDialog(),
  );
}

void _startNewWorkout(BuildContext context, WidgetRef ref) {
  HapticFeedback.mediumImpact();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.startNewWorkout),
      content: TextField(
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.workoutNameHint,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (name) {
          Navigator.of(context).pop();
          ref.read(currentWorkoutProvider.notifier).createWorkout(
            name.isNotEmpty ? name : 'Workout ${DateTime.now().day}/${DateTime.now().month}',
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(currentWorkoutProvider.notifier).createWorkout(
              'Workout ${DateTime.now().day}/${DateTime.now().month}',
            );
          },
          child: Text(AppLocalizations.of(context)!.start),
        ),
      ],
    ),
  );
}

void _showAddExercise(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const AddExerciseModal(),
  );
}

void _navigateToTemplates(BuildContext context) {
  context.goNamed('workout_templates');
}

void _editExercise(BuildContext context, WidgetRef ref, String exerciseId) {
  // Implementation for editing exercise
}

void _deleteExercise(BuildContext context, WidgetRef ref, String exerciseId) {
  HapticFeedback.lightImpact();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteExercise),
      content: Text(AppLocalizations.of(context)!.deleteExerciseDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(currentWorkoutProvider.notifier).removeExerciseById(exerciseId);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    ),
  );
}

void _updateSet(WidgetRef ref, String exerciseId, ExerciseSet set) {
  ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, set);
}

void _toggleSetComplete(WidgetRef ref, String exerciseId, ExerciseSet set) {
  HapticFeedback.lightImpact();
  ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, set);
}

void _updateExercise(WidgetRef ref, Exercise exercise) {
  ref.read(currentWorkoutProvider.notifier).updateExerciseOnly(exercise);
}

void _showRestTimer(BuildContext context) {
  // Implementation for rest timer
}

void _saveAsTemplate(BuildContext context, WidgetRef ref) {
  // Implementation for saving as template
}