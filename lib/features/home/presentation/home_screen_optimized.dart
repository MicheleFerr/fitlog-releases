import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/notification_hub.dart';
// import 'package:gymbro_flutter_new/features/community/presentation/widgets/community_pulse_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/enhanced_workout_banner.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/smart_workout_cta.dart';
// import 'package:gymbro_flutter_new/features/home/presentation/widgets/progress_dashboard.dart'; // Widget rimosso
import 'package:gymbro_flutter_new/features/home/presentation/widgets/secondary_actions.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/dynamic_greeting.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_update_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_feedback_screen.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/widgets/stale_profile_banner.dart';

/// Optimized homepage that consolidates the best features from both implementations
/// while ensuring full compliance with localization and theming standards
class HomeScreenOptimized extends ConsumerStatefulWidget {
  const HomeScreenOptimized({super.key});

  @override
  ConsumerState<HomeScreenOptimized> createState() => _HomeScreenOptimizedState();
}

class _HomeScreenOptimizedState extends ConsumerState<HomeScreenOptimized> {
  @override
  void initState() {
    super.initState();

    // Start exercise update check with 30-second delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseUpdateProvider.notifier).checkForUpdatesOnAppStart(context);

      // Check if user should see onboarding with additional safety checks
      final shouldShow = ref.read(shouldShowOnboardingProvider);
      final onboardingState = ref.read(onboardingStateProvider);

      // Debug state for troubleshooting
      if (kDebugMode) {
        ref.read(onboardingStateProvider.notifier).debugOnboardingState();
      }

      // Only navigate if really necessary - never seen AND not completed
      if (shouldShow && !onboardingState.hasSeenGlobalOnboarding && !onboardingState.isCompleted) {
        // Small delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            debugPrint('🚀 Navigating to onboarding - first time user');
            context.goNamed('onboarding');
          }
        });
      } else if (shouldShow) {
        // This shouldn't happen with our new logic, but log it for debugging
        debugPrint('⚠️ shouldShow is true but onboarding conditions not met - investigating');
        debugPrint('hasSeenGlobal: ${onboardingState.hasSeenGlobalOnboarding}, isCompleted: ${onboardingState.isCompleted}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with proper theming
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const FlexibleSpaceBar(
                title: DynamicGreeting(),
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            actions: const [NotificationHub(), SizedBox(width: 16)],
          ),

          // Main content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active workout banner (enhanced)
                if (currentWorkout != null) ...[
                  EnhancedWorkoutBanner(workout: currentWorkout),
                  const SizedBox(height: 24),
                ],

                // Stale profile banner (if profile is 30+ days old)
                const StaleProfileBanner(),

                // Removed gamification features for MVP

                // AI Coach Insights Card
                const AICoachCard(),
                const SizedBox(height: 24),

                // Primary CTA - Smart workout starter
                const SmartWorkoutCTA(),
                const SizedBox(height: 24),

                // Routine Center Card (Flexible Multi-Period Routines)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.goNamed('routine');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.event_note,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.routineCenter,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.routineCenterDescription,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Community card - navigate to community hub
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/community');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.community,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Secondary Actions Grid
                const SecondaryActions(),
                const SizedBox(height: 24),

                // Admin panel (only visible for admin users)
                Consumer(
                  builder: (context, ref, child) {
                    final isAdmin = ref.watch(isAdminCachedProvider);

                    if (!isAdmin) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Admin Panel',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Exercise Feedback Card
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ExerciseFeedbackScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple.shade700,
                                      Colors.deepPurple.shade900,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.flag_circle,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '🔧 Exercise Feedback',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Segnalazioni e bug utenti',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Reset Onboarding Button
                          FilledButton.tonal(
                            onPressed: () {
                              ref.read(onboardingStateProvider.notifier).resetOnboarding();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Onboarding reset completato'),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                            ),
                            child: const Text('Reset Onboarding'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),

      // Floating Action Button for emergency quick start
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: PremiumActionButton(
          onPressed: () => context.goNamed('workout'),
          icon: Icons.add,
          label: l10n.quickStart,
        ),
      ),
    );
  }
}
