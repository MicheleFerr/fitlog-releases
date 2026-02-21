import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/analytics_overview_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/animated_search_icon.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/sync_progress_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/skeleton_loader.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class TabbedAnalyticsScreen extends ConsumerWidget {
  const TabbedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
        leading: IconButton(
          icon: const SemanticIcon(icon: AppIcons.back, semanticLabel: 'Back'),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.homePath);
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
          // Button to access detailed exercise analysis
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.barChart,
              semanticLabel: 'Detailed Analysis',
            ),
            tooltip: l10n.detailedAnalysis,
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pushNamed(AppRoutes.exerciseProgressName);
            },
          ),
          if (authState == AuthState.authenticated)
            AnimatedSearchIcon(
              onPressed: () async {
                // TODO: Re-implement search with the new data model
              },
              showInitialAnimation: true,
            ),
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: 'Refresh',
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(historicalWorkoutsProvider);
            },
          ),
        ],
      ),
      body: authState != AuthState.authenticated
          ? _buildNotAuthenticatedView(context)
          : _buildContent(context, ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(historicalWorkoutsProvider);
    final syncStatus = ref.watch(workoutSyncStatusProvider);

    // Show sync overlay if syncing
    if (syncStatus.isActive) {
      return const SyncProgressOverlay();
    }

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return _buildEmptyState(context);
        }

        return AnalyticsOverviewTab(workouts: workouts);
      },
      loading: () => _buildLoadingSkeleton(),
      error: (error, _) => _buildErrorView(context, ref, error.toString()),
    );
  }

  Widget _buildNotAuthenticatedView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.lockOutline,
              semanticLabel: 'Lock outline',
              size: AppIconSize.medium,
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
              onPressed: () => context.push(AppRoutes.loginPath),
              child: Text(l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: 'Error',
              size: AppIconSize.medium,
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
              icon: const SemanticIcon(
                icon: AppIcons.refresh,
                semanticLabel: 'Refresh',
              ),
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
        TabBarBottomPadding(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return EnhancedEmptyState(
      type: EmptyStateType.motivational,
      icon: AppIcons.workout,
      title: l10n.noWorkoutsYet,
      description: l10n.startYourFirstWorkoutDesc,
      motivationalQuote: l10n.fitnessQuoteEmptyState,
      proTip: l10n.proTipFirstWorkout,
      primaryActionLabel: l10n.startWorkout,
      primaryActionIcon: AppIcons.add,
      onPrimaryAction: () => context.push(AppRoutes.workoutPath),
    );
  }
}
