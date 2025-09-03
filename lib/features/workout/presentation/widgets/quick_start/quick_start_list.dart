/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: workout
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: iOS/Android/Universal
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import '../providers/workout_provider.dart';
import '../providers/workout_template_provider.dart';
import '../../domain/entities/workout_template.dart' as wt;
import '../screens/workout_templates_screen.dart';
import '../screens/edit_template_screen.dart';
import '../template_cards/template_quick_start_card.dart';
import 'quick_start_card.dart';

class QuickStartList extends ConsumerWidget {
  const QuickStartList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _buildQuickWorkoutCard(context, ref),
        const SizedBox(height: 12),
        _buildCustomTemplatesSection(context, ref),
        _buildPopularTemplatesSection(context, ref),
      ],
    );
  }

  Widget _buildQuickWorkoutCard(BuildContext context, WidgetRef ref) {
    return QuickStartCard(
      icon: Icons.schedule,
      title: AppLocalizations.of(context)!.quickWorkout,
      subtitle: AppLocalizations.of(context)!.quickWorkoutSubtitle,
      color: Theme.of(context).colorScheme.primary,
      onTap: () => _startNewWorkout(context, ref),
    );
  }

  Widget _buildCustomTemplatesSection(BuildContext context, WidgetRef ref) {
    return Consumer(
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
                const SizedBox(height: 4),
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context)!.yourTemplates,
                  Icons.person,
                  onSeeAll: () => _navigateToTemplates(context),
                ),
                const SizedBox(height: 8),
                ...customTemplates.take(3).map((template) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TemplateQuickStartCard(
                      template: template,
                      onTap: () => _startWorkoutFromTemplate(context, ref, template),
                      onEdit: () => _editTemplateFromQuickStart(context, template),
                      onDelete: () => _deleteTemplateFromQuickStart(context, ref, template),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPopularTemplatesSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 4),
        _buildSectionHeader(
          context,
          AppLocalizations.of(context)!.popularTemplates,
          null,
          onSeeAll: () => _navigateToTemplates(context),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, child) {
            final popularTemplatesAsync = ref.watch(popularTemplatesProvider);
            
            return popularTemplatesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildFallbackTemplates(context, ref),
              data: (templates) {
                if (templates.isEmpty) {
                  return _buildFallbackTemplates(context, ref);
                }
                
                return Column(
                  children: templates.take(4).map((template) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TemplateQuickStartCard(
                        template: template,
                        onTap: () => _startWorkoutFromTemplate(context, ref, template),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData? icon, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
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
    );
  }

  Widget _buildFallbackTemplates(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        QuickStartCard(
          icon: Icons.fitness_center,
          title: AppLocalizations.of(context)!.upperBody,
          subtitle: AppLocalizations.of(context)!.upperBodySubtitle,
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => _startTemplateWorkout(context, ref, 'Upper Body'),
        ),
        const SizedBox(height: 12),
        QuickStartCard(
          icon: Icons.directions_run,
          title: AppLocalizations.of(context)!.lowerBody,
          subtitle: AppLocalizations.of(context)!.lowerBodySubtitle,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => _startTemplateWorkout(context, ref, 'Lower Body'),
        ),
        const SizedBox(height: 12),
        QuickStartCard(
          icon: Icons.timer,
          title: AppLocalizations.of(context)!.hiitTraining,
          subtitle: AppLocalizations.of(context)!.hiitTrainingSubtitle,
          color: Theme.of(context).colorScheme.error,
          onTap: () => _startTemplateWorkout(context, ref, 'HIIT'),
        ),
      ],
    );
  }

  // Action methods
  void _navigateToTemplates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkoutTemplatesScreen(),
      ),
    );
  }

  void _startNewWorkout(BuildContext context, WidgetRef ref) {
    // Implementation will be in the main screen
    // This is just for demonstration - in practice this would be a callback
    ref.read(currentWorkoutProvider.notifier).createWorkout('Quick Workout');
    ref.read(currentWorkoutProvider.notifier).startWorkout();
  }

  void _startWorkoutFromTemplate(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) async {
    try {
      await ref.read(workoutTemplateNotifierProvider.notifier).incrementUsage(template.id);
      
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);
      workoutNotifier.startWorkout();
      
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.workoutStartedFromTemplate(template.name)),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorStartingWorkout(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _startTemplateWorkout(BuildContext context, WidgetRef ref, String templateName) {
    ref.read(currentWorkoutProvider.notifier).createWorkout(templateName);
    ref.read(currentWorkoutProvider.notifier).startWorkout();
    
    if (templateName == 'Upper Body') {
      _addTemplateExercises(ref, [
        ('Panca Piana', ExerciseCategory.chest),
        ('Trazioni', ExerciseCategory.back),
        ('Shoulder Press', ExerciseCategory.shoulders),
      ]);
    }
  }

  void _addTemplateExercises(WidgetRef ref, List<(String, ExerciseCategory)> exercises) {
    for (final (name, category) in exercises) {
      final exercise = Exercise(
        name: name,
        type: ExerciseType.single,
        category: category,
        sets: [
          ExerciseSet(setNumber: 1, weight: 0, reps: 10),
          ExerciseSet(setNumber: 2, weight: 0, reps: 10),
          ExerciseSet(setNumber: 3, weight: 0, reps: 10),
        ],
      );
      ref.read(currentWorkoutProvider.notifier).addExercise(exercise);
    }
  }

  void _editTemplateFromQuickStart(BuildContext context, wt.WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(template: template),
      ),
    );
  }

  void _deleteTemplateFromQuickStart(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) {
    // Implementation similar to original - showing confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTemplate),
        content: Text(AppLocalizations.of(context)!.confirmDeleteTemplate(template.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(workoutTemplateNotifierProvider.notifier)
                    .deleteTemplate(template.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.templateDeleted(template.name)),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.errorDeleting(e.toString())),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}