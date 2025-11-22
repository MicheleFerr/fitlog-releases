import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/notification_hub.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/enhanced_workout_banner.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/ai_coach_card.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/smart_workout_cta.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/widgets/streak_counter_widget.dart';
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
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_providers.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/memory_monitor.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/cache_warm_tracker.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Performance-optimized homepage that maintains IDENTICAL UI to HomeScreenOptimized
/// Uses MVVM pattern with lazy loading for <3s cold start while preserving all existing widgets
class HomeScreenPerformance extends ConsumerStatefulWidget {
  const HomeScreenPerformance({super.key});

  @override
  ConsumerState<HomeScreenPerformance> createState() =>
      _HomeScreenPerformanceState();
}

class _HomeScreenPerformanceState extends ConsumerState<HomeScreenPerformance>
    with TourTargetKeysMixin {
  /// Enhanced tour manager for advanced positioning (preserved from original)
  late final OnboardingTourManager _tourManager;
  final _visibleSections = <String>{};

  @override
  void initState() {
    super.initState();

    // Initialize tour manager with target keys and completion callback
    // PRESERVED EXACTLY from HomeScreenOptimized
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
    // PRESERVED EXACTLY from HomeScreenOptimized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start performance monitoring
      final memoryMonitor = ref.read(memoryMonitorProvider);
      final cacheTracker = ref.read(cacheWarmTrackerProvider);

      memoryMonitor.startMonitoring();
      cacheTracker.startSession();

      // Record initial snapshot
      memoryMonitor.recordSnapshot('homepage_init');

      ref
          .read(exerciseUpdateProvider.notifier)
          .checkForUpdatesOnAppStart(context);

      // Debug state for troubleshooting
      if (kDebugMode) {
        ref.read(onboardingStateProvider.notifier).debugOnboardingState();
      }

      // Initialize data loading with new state management and track performance
      _loadInitialData().then((_) {
        memoryMonitor.recordSnapshot('homepage_loaded');

        // Generate reports in debug mode
        if (kDebugMode) {
          final memoryReport = memoryMonitor.generateReport();
          final cacheReport = cacheTracker.generateReport();

          debugPrint('📊 [PERFORMANCE] Memory Report: $memoryReport');
          debugPrint('📊 [PERFORMANCE] Cache Report: $cacheReport');

          // Log to Firebase Analytics or Crashlytics in production
          // FirebaseAnalytics.instance.logEvent(...)
        }
      });

      // AUTO-START TOUR: If user is beginner and hasn't seen global onboarding
      // PRESERVED EXACTLY from HomeScreenOptimized
      final onboardingState = ref.read(onboardingStateProvider);
      if (onboardingState.isBeginner &&
          !onboardingState.hasSeenGlobalOnboarding) {
        debugPrint(
            '🎯 [TOUR] Auto-starting ENHANCED tour for beginner user');
        // Delay to ensure UI is fully rendered
        Future.delayed(const Duration(milliseconds: 800), () async {
          if (mounted && context.mounted) {
            // Validate tour setup before starting
            final missingSteps = _tourManager.validateTourSetup();
            if (missingSteps.isEmpty) {
              await _tourManager.startTour(context);
            } else {
              debugPrint(
                  '⚠️ [TOUR] Cannot start - missing target keys: $missingSteps');
            }
          }
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(homeStateProvider.notifier);
    await notifier.loadInitialData();
  }

  @override
  void dispose() {
    // Dispose tour manager
    _tourManager.dispose();
    super.dispose();
  }

  /// Shows a dialog informing the user that the Community feature is coming soon
  /// PRESERVED EXACTLY from HomeScreenOptimized
  void _showCommunityComingSoonDialog(BuildContext context) {
    final l10n = context.l10n;

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
              color: context.colors.primary,
              size: AppIconSize.large,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.communityComingSoonTitle,
                style: context.textTheme.titleLarge?.copyWith(
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
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.construction,
                    color: context.colors.primary,
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🚀 ${l10n.comingSoon}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onPrimaryContainer,
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
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a skeleton loading card while data is loading
  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final loadingPhase = ref.watch(loadingPhaseProvider);
    final l10n = context.l10n;

    return Stack(
      children: [
        // Main scaffold content
        Scaffold(
          backgroundColor: context.colors.surface,
          body: CustomScrollView(
            key: const PageStorageKey('home_screen_scroll'),
            slivers: [
              // Premium App Bar with proper theming
              // PRESERVED EXACTLY from HomeScreenOptimized
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
                        context.colors.primary.withValues(alpha: 0.1),
                        context.colors.secondary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: const FlexibleSpaceBar(
                    title: DynamicGreeting(),
                    titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),
                actions: [
                  NotificationHub(key: notificationHubKey),
                  const SizedBox(width: 16)
                ],
              ),

              // Main content with progressive loading
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Active workout banner (enhanced)
                    // PRESERVED EXACTLY from HomeScreenOptimized
                    if (currentWorkout != null) ...[
                      EnhancedWorkoutBanner(workout: currentWorkout),
                      const SizedBox(height: 24),
                    ],

                    // STREAK COUNTER (P0 Feature - +35-40% retention evidence)
                    // PRESERVED EXACTLY from HomeScreenOptimized
                    const StreakCounterWidget(),
                    const SizedBox(height: 24),

                    // Debug: Before AICoachCard
                    if (kDebugMode) ...[
                      Builder(builder: (context) {
                        debugPrint(
                            '🏠 [HomeScreen] ✅ Before AICoachCard (line 243)');
                        return const SizedBox.shrink();
                      }),
                    ],

                    // AI Coach Insights Card with lazy loading
                    // Show skeleton or actual widget based on loading phase
                    if (loadingPhase.index >= LoadingPhase.loadingSecondary.index) ...[
                      VisibilityDetector(
                        key: const Key('ai_coach_section'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction > 0.1) {
                            _visibleSections.add('ai_coach');
                          }
                        },
                        child: AICoachCard(key: aiCoachCardKey),
                      ),
                    ] else
                      _buildSkeletonCard(height: 120),
                    const SizedBox(height: 24),

                    const SizedBox(height: 20),

                    // Primary CTA - Smart workout starter
                    // PRESERVED EXACTLY from HomeScreenOptimized
                    SmartWorkoutCTA(key: smartWorkoutCardKey),
                    const SizedBox(height: 24),

                    // Routine Center Card (Flexible Multi-Period Routines)
                    // PRESERVED EXACTLY from HomeScreenOptimized
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
                                context.colors.primary.withValues(alpha: 0.15),
                                context.colors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  context.colors.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  AppIcons.eventNote,
                                  color: context.colors.onPrimary,
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
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                        color: context.colors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.routineCenterDescription,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                        color: context.colors.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Community card - Coming Soon dialog
                    // PRESERVED EXACTLY from HomeScreenOptimized
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
                            color: context.colors.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.people,
                                color: context.colors.onPrimaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.community,
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                        color:
                                            context.colors.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.comingSoon,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                        color: context.colors.onPrimaryContainer
                                            .withValues(alpha: 0.7),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                AppIcons.info,
                                size: AppIconSize.small,
                                color: context.colors.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Secondary Actions Grid
                    // PRESERVED EXACTLY from HomeScreenOptimized
                    SecondaryActions(
                      analyticsKey: analyticsCardKey,
                      historyKey: historyCardKey,
                    ),
                    const SizedBox(height: 24),

                    // Admin panel (only visible for admin users)
                    // PRESERVED EXACTLY from HomeScreenOptimized
                    Consumer(
                      builder: (context, ref, child) {
                        final isAdmin = ref.watch(isAdminCachedProvider);

                        if (!isAdmin) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  context.colors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    AppIcons.admin,
                                    color: context.colors.onErrorContainer,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.adminPanel,
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      color: context.colors.onErrorContainer,
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
                                        builder: (_) =>
                                            const ExerciseFeedbackScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple[700]!,
                                          Colors.deepPurple[900]!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          AppIcons.flagCircle,
                                          color: context.colors.surface,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '🔧 Exercise Feedback',
                                                style: context
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: context.colors.surface,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                context
                                                    .l10n.userReportsAndBugs,
                                                style: context
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: context.colors.surface
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          AppIcons.forwardIos,
                                          color: context.colors.surface,
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
                                  ref
                                      .read(onboardingStateProvider.notifier)
                                      .resetOnboarding();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          context.l10n.onboardingResetComplete),
                                      backgroundColor: context.colors.primary,
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: context.colors.error,
                                  foregroundColor: context.colors.onError,
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
          // PRESERVED EXACTLY from HomeScreenOptimized
          floatingActionButton: kDebugMode
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Debug: Reset Onboarding Button
                    FloatingActionButton.small(
                      heroTag: 'resetOnboarding',
                      backgroundColor: context.colors.error,
                      onPressed: () async {
                        await ref
                            .read(onboardingStateProvider.notifier)
                            .resetOnboarding();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '🔄 Onboarding reset! Riavvia l\'app per vedere Quick Start'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Icon(AppIcons.refresh, size: AppIconSize.small),
                    ),
                    const SizedBox(height: 8),
                    // Regular Quick Start
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PremiumActionButton(
                        key: quickStartFabKey,
                        onPressed: () {
                          WorkoutAnalytics.trackEvent('fab_tapped',
                              properties: {
                                'timestamp': DateTime.now().toIso8601String(),
                              });
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WorkoutTemplatesScreen(),
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

        // ENHANCED ONBOARDING TOUR OVERLAY
        // Shows dynamic spotlight with auto-centering + bottom sheet
        // Uses OnboardingTourManager for advanced positioning
        // PRESERVED EXACTLY from HomeScreenOptimized
        OnboardingTourOverlayEnhanced(manager: _tourManager),
      ],
    ); // End of Stack
  }
}
