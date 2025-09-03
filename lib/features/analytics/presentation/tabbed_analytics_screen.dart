import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_overview_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_progress_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_insights_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/animated_search_icon.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_history_search_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/analytics_screen.dart' show userActivitiesProvider, isPremiumProvider;
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
        HapticFeedback.lightImpact();
      }
    });
    
    // SYNC FIX: Refresh analytics data when screen is loaded
    // This ensures we show the latest data if user just completed a workout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsRefreshProvider)();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final firebaseUser = ref.watch(firebaseUserProvider);
    final theme = Theme.of(context);

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
              'Analytics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Track your fitness journey',
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
                final activitiesAsync = ref.read(userActivitiesProvider(
                  ref.read(firebaseUserProvider).valueOrNull?.email ?? '',
                ));
                
                if (activitiesAsync.hasValue) {
                  await ExerciseHistorySearchModal.show(
                    context,
                    activitiesAsync.value!,
                  );
                }
              },
              showInitialAnimation: true,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(userActivitiesProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall,
              tabs: const [
                Tab(
                  height: 46,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard_outlined, size: 20),
                      SizedBox(height: 4),
                      Text('Overview'),
                    ],
                  ),
                ),
                Tab(
                  height: 46,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_outlined, size: 20),
                      SizedBox(height: 4),
                      Text('Progress'),
                    ],
                  ),
                ),
                Tab(
                  height: 46,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.insights_outlined, size: 20),
                      SizedBox(height: 4),
                      Text('Insights'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: authState != AuthState.authenticated
          ? _buildNotAuthenticatedView()
          : firebaseUser.when(
              data: (user) => user?.email == null
                  ? _buildNoEmailView()
                  : _buildTabContent(user!.email!),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorView(error.toString()),
            ),
    );
  }
  
  Widget _buildTabContent(String userEmail) {
    final activitiesAsync = ref.watch(userActivitiesProvider(userEmail));
    final isPremium = ref.watch(isPremiumProvider).value ?? false;
    
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return _buildEmptyState();
        }
        
        return TabBarView(
          controller: _tabController,
          children: [
            AnalyticsOverviewTab(activities: activities),
            AnalyticsProgressTab(activities: activities, isPremium: isPremium),
            AnalyticsInsightsTab(activities: activities, isPremium: isPremium),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorView(error.toString()),
    );
  }
  
  Widget _buildNotAuthenticatedView() {
    final theme = Theme.of(context);
    
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
              'Sign in to view analytics',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Track your workouts and monitor your progress',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoEmailView() {
    final theme = Theme.of(context);
    
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
              'Account Error',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load user data. Please sign out and sign in again.',
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
              'Error loading analytics',
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
              onPressed: () => ref.invalidate(userActivitiesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No workouts yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Start your first workout to see analytics',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/workout'),
              icon: const Icon(Icons.add),
              label: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }
}