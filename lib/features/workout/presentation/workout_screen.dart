import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../shared/presentation/widgets/premium_action_button.dart';
import '../../../shared/presentation/widgets/draggable_action_button.dart';
import '../../../shared/presentation/widgets/draggable_tutorial_overlay.dart';
import '../domain/entities/workout.dart';
import '../domain/entities/exercise.dart';
import '../domain/entities/workout_template.dart' as wt;
import 'providers/workout_provider.dart';
import 'providers/workout_template_provider.dart';
import 'widgets/add_exercise_modal.dart';
import 'widgets/workout_header.dart';
import 'widgets/exercise_list_item.dart';
import 'widgets/workout_customization_modal.dart';
import 'screens/workout_templates_screen.dart';
import 'screens/edit_template_screen.dart';
import '../../timer/presentation/widgets/tier1_minimal_timer_overlay.dart';
import '../../timer/presentation/providers/unified_timer_extensions.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🏗️ WorkoutScreen.build called');
    
    final currentWorkout = ref.watch(currentWorkoutProvider);
    print('🏗️ Current workout: ${currentWorkout?.name}, exercises: ${currentWorkout?.exercises.length}');
    
    // Add error boundary for debugging
    try {
      final scaffold = PopScope(
        canPop: false, // Prevent default back navigation
        onPopInvoked: (didPop) {
          if (!didPop) {
            _handleBackNavigation(context, ref);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(currentWorkout?.name ?? 'GymBro TrackLog'),
            leading: currentWorkout != null && currentWorkout.isActive
                ? IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () => _handleBackNavigation(context, ref),
                    tooltip: 'Back to Home (Keep Workout Active)',
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.goNamed('home'),
                    tooltip: 'Back to Home',
                  ),
            actions: [
            if (currentWorkout != null && currentWorkout.isActive)
              IconButton(
                onPressed: () => _completeWorkout(context, ref),
                icon: const Icon(Icons.check_circle),
                tooltip: 'Complete Workout',
              ),
            IconButton(
              onPressed: () => _showSettingsMenu(context, ref),
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Stack(
          children: [
            currentWorkout == null 
                ? _buildWelcomeView(context, ref)
                : _buildWorkoutView(context, ref, currentWorkout),
            // Timer Overlay
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
      
      // Wrap con il button draggabile e tutorial
      return DraggableTutorialOverlay(
        tutorialKey: 'workout_fab',
        child: Stack(
          children: [
            scaffold,
            DraggableActionButton(
            onPressed: currentWorkout != null
                ? () => _showAddExercise(context, ref)
                : () => _startNewWorkout(context, ref),
            icon: currentWorkout != null ? Icons.add : Icons.play_arrow,
            label: currentWorkout != null
                ? AppLocalizations.of(context)!.addExercise
                : AppLocalizations.of(context)!.startWorkout,
            positionKey: 'workout_screen_fab',
            additionalOptions: currentWorkout != null ? [
              DraggableActionOption(
                icon: Icons.timer,
                label: 'Timer Riposo',
                onTap: () {
                  // Mostra timer riposo manuale
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const SizedBox(
                      height: 400,
                      child: Center(
                        child: Text('Timer Riposo'),
                      ),
                    ),
                  );
                },
                color: Colors.orange,
              ),
              DraggableActionOption(
                icon: Icons.save,
                label: 'Salva come Template',
                onTap: () {
                  // Salva workout corrente come template
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funzione salva template in arrivo!'),
                    ),
                  );
                },
                color: Colors.blue,
              ),
            ] : [
              DraggableActionOption(
                icon: Icons.assignment,
                label: 'Template',
                onTap: () => _navigateToTemplates(context),
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
    } catch (e, stack) {
      print('❌ Error building WorkoutScreen: $e');
      print('Stack: $stack');
      
      // Return error widget instead of black screen
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('An error occurred while loading the workout'),
              const SizedBox(height: 8),
              Text('Error: $e', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed('home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildQuickStartList(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Quick Workout (sempre presente)
        _QuickStartCard(
          icon: Icons.schedule,
          title: AppLocalizations.of(context)!.quickWorkout,
          subtitle: AppLocalizations.of(context)!.quickWorkoutSubtitle,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => _startNewWorkout(context, ref),
        ),
        const SizedBox(height: 12),
        
        // I tuoi Template (se ce ne sono)
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
                    const SizedBox(height: 4),
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
                    
                    // Mostra primi 3 template personalizzati
                    Column(
                      children: customTemplates.take(3).map((template) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TemplateQuickStartCard(
                            template: template,
                            onTap: () => _startWorkoutFromTemplate(context, ref, template),
                            onEdit: () => _editTemplateFromQuickStart(context, template),
                            onDelete: () => _deleteTemplateFromQuickStart(context, ref, template),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
        
        // Template popolari
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.popularTemplates,
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
        
        // Template da provider
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
                      child: _TemplateQuickStartCard(
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

  Widget _buildFallbackTemplates(BuildContext context, WidgetRef ref) {
    // Template di fallback hardcoded (come prima)
    return Column(
      children: [
        _QuickStartCard(
          icon: Icons.fitness_center,
          title: AppLocalizations.of(context)!.upperBody,
          subtitle: AppLocalizations.of(context)!.upperBodySubtitle,
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => _startTemplateWorkout(context, ref, 'Upper Body'),
        ),
        const SizedBox(height: 12),
        _QuickStartCard(
          icon: Icons.directions_run,
          title: AppLocalizations.of(context)!.lowerBody,
          subtitle: AppLocalizations.of(context)!.lowerBodySubtitle,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => _startTemplateWorkout(context, ref, 'Lower Body'),
        ),
        const SizedBox(height: 12),
        _QuickStartCard(
          icon: Icons.timer,
          title: AppLocalizations.of(context)!.hiitTraining,
          subtitle: AppLocalizations.of(context)!.hiitTrainingSubtitle,
          color: Theme.of(context).colorScheme.error,
          onTap: () => _startTemplateWorkout(context, ref, 'HIIT'),
        ),
      ],
    );
  }

  void _navigateToTemplates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkoutTemplatesScreen(),
      ),
    );
  }

  void _startWorkoutFromTemplate(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) async {
    try {
      // Incrementa contatore utilizzo
      await ref.read(workoutTemplateNotifierProvider.notifier).incrementUsage(template.id);
      
      // Crea workout dal template
      final workoutNotifier = ref.read(currentWorkoutProvider.notifier);
      workoutNotifier.createWorkout(template.name);
      workoutNotifier.startWorkout();
      
      // Aggiungi esercizi dal template
      final exercises = template.toWorkoutExercises();
      for (final exercise in exercises) {
        workoutNotifier.addExercise(exercise);
      }
      
      // Mostra messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout "${template.name}" avviato!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'avvio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.read(currentWorkoutProvider);
    
    if (currentWorkout != null && currentWorkout.isActive) {
      // Show dialog to confirm navigation while keeping workout active
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Keep Workout Active?'),
          content: const Text(
            'Do you want to go back to Home and keep your workout running in the background?\n\n'
            'You can return to continue your workout anytime.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                // Pause workout and go to home
                ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                Navigator.pop(context);
                context.goNamed('home');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.pause_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Workout paused - Continue anytime from Home'),
                        ),
                      ],
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Resume',
                      textColor: Colors.white,
                      onPressed: () {
                        ref.read(currentWorkoutProvider.notifier).resumeWorkout();
                        context.goNamed('workout');
                      },
                    ),
                  ),
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );
    } else {
      // No active workout, just go back
      context.goNamed('home');
    }
  }

  Widget _buildWelcomeView(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
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
                          color: Theme.of(context).primaryColor,
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions Section
            Text(
              AppLocalizations.of(context)!.quickStart,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick Start e Template
            Expanded(
              child: _buildQuickStartList(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutView(BuildContext context, WidgetRef ref, Workout workout) {
    return SafeArea(
      child: Column(
        children: [
          // Workout Header with stats
          WorkoutHeader(workout: workout),
          
          // Exercise List
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
                          onSetUpdate: (updatedSet) => _updateExerciseSet(ref, exercise.id, updatedSet),
                          onSetToggleComplete: (updatedSet) => _updateExerciseSet(ref, exercise.id, updatedSet),
                          onExerciseUpdate: (updatedExercise) => _updateExercise(ref, updatedExercise),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExerciseList(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noExercisesYet,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tapToAddExercise,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
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
            if (name.isNotEmpty) {
              ref.read(currentWorkoutProvider.notifier).createWorkout(name);
              ref.read(currentWorkoutProvider.notifier).startWorkout();
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
              ref.read(currentWorkoutProvider.notifier).createWorkout('Quick Workout');
              ref.read(currentWorkoutProvider.notifier).startWorkout();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.start),
          ),
        ],
      ),
    );
  }

  void _startTemplateWorkout(BuildContext context, WidgetRef ref, String templateName) {
    ref.read(currentWorkoutProvider.notifier).createWorkout(templateName);
    ref.read(currentWorkoutProvider.notifier).startWorkout();
    
    // Add template exercises based on template name
    // This is simplified - in a real app you'd have proper templates
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

  void _showAddExercise(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddExerciseModal(),
    );
  }

  void _editExercise(BuildContext context, WidgetRef ref, Exercise exercise) {
    // TODO: Implement exercise editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercise editing coming soon!')),
    );
  }

  void _deleteExercise(WidgetRef ref, String exerciseId) {
    ref.read(currentWorkoutProvider.notifier).removeExercise(exerciseId);
  }

  void _updateExerciseSet(WidgetRef ref, String exerciseId, ExerciseSet updatedSet) {
    ref.read(currentWorkoutProvider.notifier).updateExerciseSet(exerciseId, updatedSet);
  }

  void _updateExercise(WidgetRef ref, Exercise updatedExercise) {
    print('🎯 _updateExercise called in WorkoutScreen');
    print('🎯 Exercise to update: ${updatedExercise.name}');
    print('🎯 Rest time: ${updatedExercise.restTime}');
    
    try {
      ref.read(currentWorkoutProvider.notifier).updateExerciseOnly(updatedExercise);
      print('✅ Exercise update completed');
    } catch (e, stack) {
      print('❌ Error in _updateExercise: $e');
      print('Stack: $stack');
    }
  }

  void _completeWorkout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Workout'),
        content: const Text('Are you sure you want to complete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(currentWorkoutProvider.notifier).completeWorkout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Workout completed! Great job!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Clear workout after a delay to show completion
              Future.delayed(const Duration(seconds: 2), () {
                ref.read(currentWorkoutProvider.notifier).clearWorkout();
              });
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          if (ref.watch(currentWorkoutProvider) != null) ...[
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Salva come Template'),
              subtitle: const Text('Salva su Firebase per riutilizzarlo'),
              onTap: () {
                Navigator.pop(context);
                _SaveTemplateHelper.showSaveAsTemplateDialog(context, ref);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('Pause Workout'),
              onTap: () {
                ref.read(currentWorkoutProvider.notifier).pauseWorkout();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop, color: Colors.red),
              title: const Text('End Workout'),
              onTap: () {
                Navigator.pop(context);
                _completeWorkout(context, ref);
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Personalizza Workout'),
            subtitle: const Text('RPE, Timer, e altro'),
            onTap: () {
              Navigator.pop(context);
              WorkoutCustomizationModal.show(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context);
              context.go('/login');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _editTemplateFromQuickStart(BuildContext context, wt.WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTemplateScreen(template: template),
      ),
    );
  }

  void _deleteTemplateFromQuickStart(BuildContext context, WidgetRef ref, wt.WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sei sicuro di voler eliminare "${template.name}"?'),
            const SizedBox(height: 8),
            Text(
              'Questa azione non può essere annullata.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
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
                      content: Text('Template "${template.name}" eliminato'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card speciale per template nei Quick Start
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icona template
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
              
              // Info template
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
                    
                    // Statistiche mini
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
              
              // Freccia
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
    // Haptic feedback per il long press
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Titolo
            Row(
              children: [
                Icon(
                  template.isCustom ? Icons.person : Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Opzioni menu
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Avvia Workout'),
              subtitle: const Text('Inizia subito l\'allenamento'),
              onTap: () {
                Navigator.of(context).pop();
                onTap();
              },
            ),
            
            if (onEdit != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: const Text('Modifica Template'),
                subtitle: const Text('Aggiungi o rimuovi esercizi'),
                onTap: () {
                  Navigator.of(context).pop();
                  onEdit!();
                },
              ),
            
            if (onDelete != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Elimina Template'),
                subtitle: const Text('Rimuovi definitivamente'),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete!();
                },
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

}

// Helper class for template saving
class _SaveTemplateHelper {
  static void showSaveAsTemplateDialog(BuildContext context, WidgetRef ref) async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout == null) return;

    // Import the provider (assuming it's available)
    // Check user quota
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    
    int usedTemplates = 0;
    int maxTemplates = 10;
    
    if (userDoc.exists) {
      final data = userDoc.data()!;
      final quotaData = data['templateQuota'] as Map<String, dynamic>?;
      if (quotaData != null) {
        usedTemplates = quotaData['usedPrivateTemplates'] ?? 0;
        maxTemplates = quotaData['maxPrivateTemplates'] ?? 10;
      }
    }
    
    // Check if quota exceeded
    if (usedTemplates >= maxTemplates) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limite Template Raggiunto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Hai raggiunto il limite di $maxTemplates template privati.'),
              const SizedBox(height: 8),
              const Text(
                'Elimina un template esistente o passa a Premium per avere più spazio.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to premium screen
              },
              child: const Text('Upgrade'),
            ),
          ],
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: currentWorkout.name);
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('Salva come Template'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: usedTemplates >= maxTemplates - 2
                    ? Colors.orange.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$usedTemplates/$maxTemplates',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: usedTemplates >= maxTemplates - 2
                      ? Colors.orange
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show warning if close to limit
              if (maxTemplates - usedTemplates <= 2 && maxTemplates - usedTemplates > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Solo ${maxTemplates - usedTemplates} template rimanenti nel piano Free',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Template',
                  hintText: 'Es: Push Day, Upper Body...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  hintText: 'Descrivi brevemente questo workout...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Il template verrà salvato su Firebase e sarà disponibile su tutti i tuoi dispositivi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inserisci un nome per il template'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              try {
                // Mostra loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Salvataggio su Firebase...'),
                      ],
                    ),
                    duration: Duration(seconds: 30),
                  ),
                );
                
                // Crea e salva il template
                await ref.read(workoutTemplateNotifierProvider.notifier)
                    .createTemplateFromWorkout(
                      name: name,
                      description: description.isEmpty ? 'Template personalizzato' : description,
                      exercises: currentWorkout.exercises,
                      tags: [], // Potremmo aggiungere tags in futuro
                    );
                
                // Rimuovi loading e mostra successo
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text('Template "$name" salvato con successo!'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    action: SnackBarAction(
                      label: 'Visualizza',
                      textColor: Colors.white,
                      onPressed: () {
                        // Navigate to templates screen
                        context.push('/templates');
                      },
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).clearSnackBars();
                
                // Check if it's a quota error
                final errorMessage = e.toString();
                final isQuotaError = errorMessage.contains('quota exceeded');
                
                if (isQuotaError) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Limite Raggiunto'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(errorMessage.replaceAll('Exception: ', '')),
                          const SizedBox(height: 8),
                          const Text(
                            'Elimina template esistenti o passa a Premium.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // TODO: Navigate to premium
                          },
                          child: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore nel salvataggio: ${errorMessage.replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Salva su Firebase'),
          ),
        ],
      ),
    );
  }
}