import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../workout/presentation/providers/workout_provider.dart';
import '../../workout/domain/entities/workout.dart';
import 'widgets/customizable_workout_card.dart';
import '../../../shared/presentation/widgets/draggable_action_button.dart';
import '../../../shared/presentation/widgets/draggable_tutorial_overlay.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('GymBro TrackLog'),
        actions: [
          IconButton(
            onPressed: () => _showSettingsMenu(context, ref),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active workout banner (if any)
              if (currentWorkout != null) ...[
                _buildActiveWorkoutBanner(context, ref, currentWorkout),
                const SizedBox(height: 24),
              ],
              
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
                            AppLocalizations.of(context)!.welcomeToGymBro,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.homeWelcomeDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              Text(
                AppLocalizations.of(context)!.quickActions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Action Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    const CustomizableWorkoutCard(),
                    _QuickActionCard(
                      icon: Icons.history,
                      title: AppLocalizations.of(context)!.history,
                      subtitle: AppLocalizations.of(context)!.viewPastWorkouts,
                      color: Theme.of(context).colorScheme.secondary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.historyFeatureComingSoon)),
                        );
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.analytics,
                      title: AppLocalizations.of(context)!.analytics,
                      subtitle: AppLocalizations.of(context)!.trackProgress,
                      color: Theme.of(context).colorScheme.tertiary,
                      onTap: () => context.goNamed('analytics'),
                    ),
                    _QuickActionCard(
                      icon: Icons.assignment,
                      title: AppLocalizations.of(context)!.templates,
                      subtitle: AppLocalizations.of(context)!.workoutRoutines,
                      color: Colors.purple.shade600,
                      onTap: () => context.goNamed('workout-templates'),
                    ),
                    _QuickActionCard(
                      icon: Icons.settings,
                      title: AppLocalizations.of(context)!.settings,
                      subtitle: AppLocalizations.of(context)!.customizeApp,
                      color: Colors.grey.shade600,
                      onTap: () => context.goNamed('settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Wrap con il button draggabile e tutorial
    return DraggableTutorialOverlay(
      tutorialKey: 'home_fab',
      child: Stack(
        children: [
          scaffold,
          DraggableActionButton(
            onPressed: currentWorkout != null
                ? () => context.goNamed('workout')
                : () => context.goNamed('workout'),
            icon: currentWorkout != null ? Icons.play_circle : Icons.fitness_center,
            label: currentWorkout != null
                ? AppLocalizations.of(context)!.continueButton
                : AppLocalizations.of(context)!.startWorkout,
            positionKey: 'home_screen_fab',
            backgroundColor: currentWorkout != null 
                ? Theme.of(context).colorScheme.primary
                : null,
            additionalOptions: [
              DraggableActionOption(
                icon: Icons.assignment,
                label: AppLocalizations.of(context)!.templates,
                onTap: () => context.goNamed('workout-templates'),
                color: Colors.purple,
              ),
              DraggableActionOption(
                icon: Icons.analytics,
                label: AppLocalizations.of(context)!.analytics,
                onTap: () => context.goNamed('analytics'),
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutBanner(BuildContext context, WidgetRef ref, Workout workout) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  workout.isActive ? Icons.play_circle : Icons.pause_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.isActive ? AppLocalizations.of(context)!.activeWorkout : AppLocalizations.of(context)!.pausedWorkout,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        workout.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      // Resume workout if paused, then navigate
                      if (!workout.isActive) {
                        ref.read(currentWorkoutProvider.notifier).resumeWorkout();
                      }
                      context.goNamed('workout');
                    },
                    child: Text(workout.isActive ? AppLocalizations.of(context)!.continueButton : AppLocalizations.of(context)!.resume),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showEndWorkoutDialog(context, ref),
                  child: Text(AppLocalizations.of(context)!.end),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEndWorkoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.endWorkout),
        content: Text(AppLocalizations.of(context)!.endWorkoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(currentWorkoutProvider.notifier).completeWorkout();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.workoutCompleted),
                  backgroundColor: Colors.green,
                ),
              );
              // Clear workout after a delay
              Future.delayed(const Duration(seconds: 1), () {
                ref.read(currentWorkoutProvider.notifier).clearWorkout();
              });
            },
            child: Text(AppLocalizations.of(context)!.endWorkout),
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.appSettings),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.signOut),
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
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}