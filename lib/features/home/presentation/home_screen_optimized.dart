import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/notification_hub.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
// import 'package:gymbro_flutter_new/features/community/presentation/widgets/community_pulse_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/enhanced_workout_banner.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/smart_workout_cta.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/widgets/streak_counter_widget.dart';
// import 'package:gymbro_flutter_new/features/home/presentation/widgets/progress_dashboard.dart'; // Widget rimosso
import 'package:gymbro_flutter_new/features/home/presentation/widgets/secondary_actions.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/dynamic_greeting.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/exercise_update_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/onboarding_state_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_feedback_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/mixins/tour_target_keys_mixin.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/onboarding_tour_overlay_enhanced.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/onboarding_tour_manager.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/workout_templates_screen.dart';

/// Optimized homepage that consolidates the best features from both implementations
/// while ensuring full compliance with localization and theming standards
class HomeScreenOptimized extends ConsumerStatefulWidget {
  const HomeScreenOptimized({super.key});

  @override
  ConsumerState<HomeScreenOptimized> createState() => _HomeScreenOptimizedState();
}

class _HomeScreenOptimizedState extends ConsumerState<HomeScreenOptimized>
    with TourTargetKeysMixin {
  /// Enhanced tour manager for advanced positioning
  late final OnboardingTourManager _tourManager;

  @override
  void initState() {
    super.initState();

    // Initialize tour manager with target keys and completion callback
    _tourManager = OnboardingTourManager(
      tourTargetKeys,
      onTourCompleted: () {
        // Save tour completion to persistent storage
        ref.read(onboardingStateProvider.notifier).completeOnboarding();
        // Also mark overlay as seen for backward compatibility
        ref.read(onboardingStateProvider.notifier).markOverlaySeen('homeTour');
        debugPrint('✅ [TOUR] Tour completion saved to storage');
      },
    );

    // Start exercise update check with 30-second delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseUpdateProvider.notifier).checkForUpdatesOnAppStart(context);

      // Debug state for troubleshooting
      if (kDebugMode) {
        ref.read(onboardingStateProvider.notifier).debugOnboardingState();
      }

      // 🎯 AUTO-START TOUR: If user is beginner and hasn't seen global onboarding
      final onboardingState = ref.read(onboardingStateProvider);
      if (onboardingState.isBeginner && !onboardingState.hasSeenGlobalOnboarding) {
        debugPrint('🎯 [TOUR] Auto-starting ENHANCED tour for beginner user');
        // Delay to ensure UI is fully rendered
        Future.delayed(const Duration(milliseconds: 800), () async {
          if (mounted && context.mounted) {
            // Validate tour setup before starting
            final missingSteps = _tourManager.validateTourSetup();
            if (missingSteps.isEmpty) {
              await _tourManager.startTour(context);
            } else {
              debugPrint('⚠️ [TOUR] Cannot start - missing target keys: $missingSteps');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose tour manager
    _tourManager.dispose();
    super.dispose();
  }

  /// Shows a dialog informing the user that the Community feature is coming soon
  void _showCommunityComingSoonDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              AppIcons.people,
              color: Theme.of(context).colorScheme.primary,
              size: AppIconSize.large,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.communityComingSoonTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.communityComingSoonDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.construction,
                    color: Theme.of(context).colorScheme.primary,
                    size: AppIconSize.small,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🚀 ${l10n.comingSoon}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.close,
              style: context.textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final l10n = AppLocalizations.of(context);

    // Note: FAB step removed from tour (was obscured by bottom sheet)

    return Stack(
      children: [
          // Main scaffold content
          Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        key: const PageStorageKey('home_screen_scroll'),
        slivers: [
          // Premium App Bar with proper theming
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: DecoratedBox(
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
            actions: [NotificationHub(key: notificationHubKey), const SizedBox(width: 16)],
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

                // 🔥 STREAK COUNTER (P0 Feature - +35-40% retention evidence)
                const StreakCounterWidget(),
                const SizedBox(height: 24),

                // DISABLED: Stale profile banner
                // Reason: GDPR compliance - medical questionnaire data
                // Date: 2025-01-21
                // const StaleProfileBanner(),

                // Removed gamification features for MVP

                // Debug: Before AICoachCard
                if (kDebugMode) ...[
                  Builder(builder: (context) {
                    debugPrint('🏠 [HomeScreen] ✅ Before AICoachCard (line 243)');
                    return const SizedBox.shrink();
                  }),
                ],

                // AI Coach Insights Card
                AICoachCard(key: aiCoachCardKey),
                SizedBox(height: 24),

                const SizedBox(height: 20),

                // Primary CTA - Smart workout starter
                SmartWorkoutCTA(key: smartWorkoutCardKey),
                SizedBox(height: 24),

                // Routine Center Card (Flexible Multi-Period Routines)
                Material(
                  key: routineCenterCardKey,
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
                              AppIcons.eventNote,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
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
                                SizedBox(height: 4),
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
                            AppIcons.forwardIos,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Community card - Coming Soon dialog
                Material(
                  key: communityCardKey,
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showCommunityComingSoonDialog(context);
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
                            AppIcons.people,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.community,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  l10n.comingSoon,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.info,
                            size: AppIconSize.small,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Secondary Actions Grid
                SecondaryActions(
                  analyticsKey: analyticsCardKey,
                  historyKey: historyCardKey,
                ),
                SizedBox(height: 24),

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
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.admin,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                context.l10n.adminPanel,
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
                                      AppIcons.flagCircle,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '🔧 Exercise Feedback',
                                            style: context.textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.l10n.userReportsAndBugs,
                                            style: context.textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      AppIcons.forwardIos,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Reset Onboarding Button
                          FilledButton.tonal(
                            onPressed: () {
                              ref.read(onboardingStateProvider.notifier).resetOnboarding();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.l10n.onboardingResetComplete),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                            ),
                            child: Text(context.l10n.resetOnboarding),
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
      floatingActionButton: kDebugMode
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Debug: Reset Onboarding Button
                FloatingActionButton.small(
                  heroTag: 'resetOnboarding',
                  backgroundColor: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    await ref.read(onboardingStateProvider.notifier).resetOnboarding();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔄 Onboarding reset! Riavvia l\'app per vedere Quick Start'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: Icon(AppIcons.refresh, size: AppIconSize.small),
                ),
                SizedBox(height: 8),
                // Regular Quick Start
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PremiumActionButton(
                    key: quickStartFabKey,
                    onPressed: () {
                      WorkoutAnalytics.trackEvent('fab_tapped', properties: {
                        'timestamp': DateTime.now().toIso8601String(),
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WorkoutTemplatesScreen(),
                        ),
                      );
                    },
                    icon: AppIcons.add,
                    label: l10n.sessioneLibera,
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PremiumActionButton(
                key: quickStartFabKey,
                onPressed: () {
                  WorkoutAnalytics.trackEvent('fab_tapped', properties: {
                    'timestamp': DateTime.now().toIso8601String(),
                  });
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorkoutTemplatesScreen(),
                    ),
                  );
                },
                icon: AppIcons.add,
                label: l10n.sessioneLibera,
              ),
            ),
          ), // End of Scaffold

          // 🎯 ENHANCED ONBOARDING TOUR OVERLAY
          // Shows dynamic spotlight with auto-centering + bottom sheet
          // Uses OnboardingTourManager for advanced positioning
          OnboardingTourOverlayEnhanced(manager: _tourManager),
        ],
      ); // End of Stack
  }
}
