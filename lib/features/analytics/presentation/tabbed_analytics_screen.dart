import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_overview_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_progress_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_insights_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_routine_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_premium_tab.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_provider_v2.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/animated_search_icon.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/sync_progress_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/skeleton_loader.dart';

class TabbedAnalyticsScreen extends ConsumerStatefulWidget {
  const TabbedAnalyticsScreen({super.key});

  @override
  ConsumerState<TabbedAnalyticsScreen> createState() => _TabbedAnalyticsScreenState();
}

class _TabbedAnalyticsScreenState extends ConsumerState<TabbedAnalyticsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
        HapticFeedback.lightImpact();
      }
    });
    
    // Cache-first strategy: Don't invalidate on every screen load
    // Data will be fetched from Hive cache first, then Firebase if cache is empty
    // Real-time updates are handled by Firestore listeners
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.analytics,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.trackYourFitnessJourney,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (authState == AuthState.authenticated)
            AnimatedSearchIcon(
              onPressed: () async {
                // TODO: Re-implement search with the new data model
                // final workouts = ref.read(historicalWorkoutsProvider).valueOrNull ?? [];
                // await ExerciseHistorySearchModal.show(context, workouts);
              },
              showInitialAnimation: true,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(historicalWorkoutsProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(
                  height: 52,
                  icon: Icon(Icons.dashboard_outlined, size: 24),
                ),
                Tab(
                  height: 52,
                  icon: Icon(Icons.trending_up_outlined, size: 24),
                ),
                Tab(
                  height: 52,
                  icon: Icon(Icons.insights_outlined, size: 24),
                ),
                Tab(
                  height: 52,
                  icon: Icon(Icons.calendar_month_outlined, size: 24),
                ),
                Tab(
                  height: 52,
                  icon: Icon(Icons.auto_awesome_outlined, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      body: authState != AuthState.authenticated
          ? _buildNotAuthenticatedView()
          : _buildTabContent(),
    );
  }
  
  Widget _buildTabContent() {
    final workoutsAsync = ref.watch(historicalWorkoutsProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final syncStatus = ref.watch(workoutSyncStatusProvider);

    // Show sync overlay if syncing
    if (syncStatus.isActive) {
      return const SyncProgressOverlay();
    }

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return _buildEmptyState();
        }

        return TabBarView(
          controller: _tabController,
          children: [
            AnalyticsOverviewTab(workouts: workouts),
            AnalyticsProgressTab(workouts: workouts, isPremium: isPremium),
            AnalyticsInsightsTab(workouts: workouts, isPremium: isPremium),
            const AnalyticsRoutineTab(),
            AnalyticsPremiumTab(workouts: workouts, isPremium: isPremium),
          ],
        );
      },
      loading: () => _buildLoadingSkeleton(),
      error: (error, _) => _buildErrorView(error.toString()),
    );
  }
  
  Widget _buildNotAuthenticatedView() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.signInToViewAnalytics,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.trackYourWorkoutsAndMonitorProgress,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoEmailView() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.accountError,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.unableToLoadUserData,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorView(String error) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingAnalytics,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(historicalWorkoutsProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // Hero card skeleton
        HeroCardSkeleton(),
        SizedBox(height: 16),

        // Stats grid skeleton
        MetricGridSkeleton(itemCount: 4),
        SizedBox(height: 20),

        // Recent workouts skeleton
        WorkoutListSkeleton(itemCount: 3),
        SizedBox(height: 20),

        // Chart skeleton
        ChartSkeleton(height: 200, showLegend: true),
      ],
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return EnhancedEmptyState(
      type: EmptyStateType.motivational,
      icon: Icons.fitness_center,
      title: l10n.noWorkoutsYet,
      description: l10n.startYourFirstWorkoutDesc,
      motivationalQuote: l10n.fitnessQuoteEmptyState,
      proTip: l10n.proTipFirstWorkout,
      primaryActionLabel: l10n.startWorkout,
      primaryActionIcon: Icons.add,
      onPrimaryAction: () => context.push('/workout'),
    );
  }
}