/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/screens
 * 🎯 Feature: workout
 * 🔧 Type: screen
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: iOS/Android/Universal
 * 
 * Dependencies:
 * - Riverpod: Clean Architecture providers
 * - Domain use cases only (no Firebase direct)
 * - AppLocalizations for i18n
 * - Material 3 theme
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/draggable_tutorial_overlay.dart';

// Domain entities
import '../../domain/entities/workout.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_template.dart' as wt;

// Clean Architecture providers
import '../providers/workout_provider_clean.dart';
import '../providers/workout_dependency_injection.dart';

// UI Components (reused from original)
import '../widgets/add_exercise_modal.dart';
import '../widgets/workout_header.dart';
import '../widgets/exercise_list_item.dart';
import '../widgets/workout_customization_modal.dart';
import '../widgets/zen_mode_settings_dialog.dart';
import '../providers/zen_mode_provider.dart';
import '../providers/workout_template_provider.dart';

// Timer components
import 'package:gymbro_flutter_new/features/timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_extensions.dart';

/// Clean Architecture WorkoutScreen using domain use cases
class WorkoutScreenClean extends ConsumerWidget {
  const WorkoutScreenClean({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch clean workout state with proper error handling
    final workoutState = ref.watch(currentWorkoutProviderClean);
    final zenState = ref.watch(zenModeProvider);

    // Handle errors with user-friendly messages
    if (workoutState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, workoutState.error!);
        ref.read(currentWorkoutProviderClean.notifier).clearError();
      });
    }

    try {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _handleBackNavigation(context, ref, workoutState);
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context, ref, workoutState, zenState),
          body: Stack(
            children: [
              // Main content with loading overlay
              _buildMainContent(context, ref, workoutState),
              
              // CRITICAL FIX: Loading overlay PRIMA del timer (layer inferiore)
              if (workoutState.isLoading || workoutState.isSaving)
                _buildLoadingOverlay(context, workoutState),
              
              // Tier-1 Timer Overlay (layer superiore - sempre accessibile)
              Consumer(
                builder: (context, ref, child) {
                  final shouldShow = ref.watch(shouldShowTier1TimerProvider);
                  return shouldShow ? const Tier1MinimalTimerOverlay() : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );

    } catch (e, stack) {
      // Error boundary for unexpected crashes
      return _buildErrorView(context, e.toString());
    }
  }

  /// Build app bar with proper state handling
  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    WorkoutState workoutState,
    ZenModeState zenState,
  ) {
    return AppBar(
      title: Row(
        children: [
          // Zen mode indicator
          if (zenState.isEnabled) ...[
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
          
          // Workout title
          Expanded(
            child: Text(
              workoutState.workout?.name ?? AppLocalizations.of(context)!.gymBroTrackLog,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      
      // Dynamic leading button
      leading: workoutState.hasWorkout && workoutState.isActive
          ? IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _handleBackNavigation(context, ref, workoutState),
              tooltip: AppLocalizations.of(context)!.backToHome,
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.goNamed('home'),
              tooltip: AppLocalizations.of(context)!.backToHome,
            ),
            
      // Actions
      actions: [
        // Complete workout button
        if (workoutState.hasWorkout && workoutState.isActive)
          IconButton(
            onPressed: workoutState.isLoading
                ? null
                : () => _completeWorkout(context, ref),
            icon: const Icon(Icons.check_circle),
            tooltip: AppLocalizations.of(context)!.completeWorkout,
          ),
          
        // Settings menu
        IconButton(
          onPressed: () => _showSettingsMenu(context, ref, workoutState),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  /// Build main content based on state
  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    WorkoutState workoutState,
  ) {
    if (workoutState.hasWorkout) {
      return _buildWorkoutView(context, ref, workoutState.workout!);
    } else {
      return _buildWelcomeView(context, ref);
    }
  }

  /// Build workout view with exercises
  Widget _buildWorkoutView(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Workout header with stats
          WorkoutHeader(workout: workout),
          
          // Exercise list or empty state
          Expanded(
            child: workout.exercises.isEmpty
                ? _buildEmptyExerciseList(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExerciseListItem(
                          exercise: exercise,
                          onTap: () => _editExercise(context, ref, exercise),
                          onDelete: () => _deleteExercise(ref, exercise.id),
                          onSetUpdate: (updatedSet) => _updateExerciseSet(
                            ref, exercise.id, updatedSet),
                          onSetToggleComplete: (updatedSet) => _updateExerciseSet(
                            ref, exercise.id, updatedSet),
                          onExerciseUpdate: (updatedExercise) => _updateExercise(
                            ref, updatedExercise),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build welcome view for new users
  Widget _buildWelcomeView(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.welcome,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.welcomeDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick start section
            Text(
              AppLocalizations.of(context)!.quickStart,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick start options
            Expanded(
              child: _buildQuickStartList(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick start options
  Widget _buildQuickStartList(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Quick workout option
        _QuickStartCard(
          icon: Icons.schedule,
          title: AppLocalizations.of(context)!.quickWorkout,
          subtitle: AppLocalizations.of(context)!.quickWorkoutSubtitle,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => _startNewWorkout(context, ref),
        ),
        const SizedBox(height: 12),
        
        // Custom templates section
        Consumer(
          builder: (context, ref, child) {
            final customTemplatesAsync = ref.watch(customWorkoutTemplatesProvider);
            
            return customTemplatesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (customTemplates) {
                if (customTemplates.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  children: [
                    // Section header
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.yourTemplates,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _navigateToTemplates(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context)!.seeAll),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Template cards
                    ...customTemplates.take(3).map((template) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TemplateQuickStartCard(
                        template: template,
                        onTap: () => _startWorkoutFromTemplate(context, ref, template),
                        onEdit: () => _editTemplate(context, template),
                        onDelete: () => _deleteTemplate(context, ref, template),
                      ),
                    )),
                    
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Build empty exercise list placeholder
  Widget _buildEmptyExerciseList(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noExercisesYet,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapToAddExercise,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading overlay - Modified to not interfere with timer
  Widget _buildLoadingOverlay(BuildContext context, WorkoutState workoutState) {
    return Positioned.fill(
      bottom: 90, // CRITICAL FIX: Leave space for timer (90px from bottom)
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    workoutState.isSaving
                        ? AppLocalizations.of(context)!.savingWorkout
                        : AppLocalizations.of(context)!.loading,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.error),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.unexpectedError,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.goNamed('home'),
                child: Text(AppLocalizations.of(context)!.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Action handlers using clean architecture

  void _handleBackNavigation(
    BuildContext context,
    WidgetRef ref,
    WorkoutState workoutState,
  ) {
    if (workoutState.hasWorkout && workoutState.isActive) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.keepWorkoutActive),
          content: Text(AppLocalizations.of(context)!.keepWorkoutActiveDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton.tonal(
              onPressed: () {
                ref.read(currentWorkoutProviderClean.notifier).pauseWorkout();
                Navigator.pop(context);
                context.goNamed('home');
                
                _showWorkoutPausedSnackBar(context, ref);
              },
              child: Text(AppLocalizations.of(context)!.goToHome),
            ),
          ],
        ),
      );
    } else {
      context.goNamed('home');
    }
  }

  void _startNewWorkout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newWorkout),
        content: TextField(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.workoutName,
            hintText: AppLocalizations.of(context)!.workoutNameHint,
          ),
          onSubmitted: (name) {
            if (name.trim().isNotEmpty) {
              final notifier = ref.read(currentWorkoutProviderClean.notifier);
              notifier.createWorkout(name.trim());
              notifier.startWorkout();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final notifier = ref.read(currentWorkoutProviderClean.notifier);
              notifier.createWorkout('Quick Workout');
              notifier.startWorkout();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.start),
          ),
        ],
      ),
    );
  }

  void _startWorkoutFromTemplate(
    BuildContext context,
    WidgetRef ref,
    wt.WorkoutTemplate template,
  ) async {
    try {
      // Increment usage count
      await ref.read(workoutTemplateNotifierProvider.notifier)
          .incrementUsage(template.id);
      
      // Start workout from template
      await ref.read(currentWorkoutProviderClean.notifier)
          .startFromTemplate(template);
      
      // Show success message
      _showSuccessSnackBar(
        context, 
        AppLocalizations.of(context)!.workoutStartedFromTemplate(template.name),
      );
      
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to start workout: $e');
    }
  }

  void _completeWorkout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.completeWorkout),
        content: Text(AppLocalizations.of(context)!.completeWorkoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(currentWorkoutProviderClean.notifier).completeWorkout();
            },
            child: Text(AppLocalizations.of(context)!.complete),
          ),
        ],
      ),
    );
  }

  void _updateExerciseSet(WidgetRef ref, String exerciseId, ExerciseSet updatedSet) {
    ref.read(currentWorkoutProviderClean.notifier)
        .updateExerciseSet(exerciseId, updatedSet);
  }

  void _updateExercise(WidgetRef ref, Exercise updatedExercise) {
    ref.read(currentWorkoutProviderClean.notifier)
        .updateExerciseOnly(updatedExercise);
  }

  void _deleteExercise(WidgetRef ref, String exerciseId) {
    ref.read(currentWorkoutProviderClean.notifier).removeExercise(exerciseId);
  }

  /// Helper methods for UI

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.ok,
          textColor: Theme.of(context).colorScheme.onTertiary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showWorkoutPausedSnackBar(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.pause_circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(AppLocalizations.of(context)!.workoutPaused),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.resume,
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () {
            ref.read(currentWorkoutProviderClean.notifier).resumeWorkout();
            context.goNamed('workout');
          },
        ),
      ),
    );
  }

  // Placeholder methods for missing functionality
  void _showSettingsMenu(BuildContext context, WidgetRef ref, WorkoutState workoutState) {
    // Implementation similar to original but using clean providers
  }

  void _editExercise(BuildContext context, WidgetRef ref, Exercise exercise) {
    // Implementation for exercise editing
  }

  void _navigateToTemplates(BuildContext context) {
    // Navigation to templates screen
  }

  void _editTemplate(BuildContext context, wt.WorkoutTemplate template) {
    // Template editing
  }

  void _deleteTemplate(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) {
    // Template deletion
  }
}

/// Reusable quick start card component
class _QuickStartCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickStartCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Template quick start card component
class _TemplateQuickStartCard extends StatelessWidget {
  final wt.WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TemplateQuickStartCard({
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: template.isCustom ? () => _showContextMenu(context) : null,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Template icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: template.isCustom
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  template.isCustom ? Icons.person : Icons.star,
                  color: template.isCustom
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Template info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Template stats
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.exercises.length}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.estimatedDuration}min',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (template.usageCount > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${template.usageCount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Menu options would go here
            // Implementation similar to original
          ],
        ),
      ),
    );
  }
}

/// Timer recovery FAB component (placeholder)
class TimerRecoveryFAB extends StatelessWidget {
  const TimerRecoveryFAB({super.key});

  @override
  Widget build(BuildContext context) {
    // Implementation for timer recovery FAB
    return const SizedBox.shrink();
  }
}