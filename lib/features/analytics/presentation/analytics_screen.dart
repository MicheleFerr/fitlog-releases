import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/analytics_overview_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/monthly_summary_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_progression_chart.dart';
// 🧹 CLEANUP: Removed non-actionable widgets (RecentWorkoutsCard, ExerciseStatsCard)
// 📊 NEW: MonthlySummaryCard ✅ | VolumeProgressionChart ✅ | TODO: PRNotification
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_frequency_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 ${context.l10n.analytics}'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: Icon(AppIcons.back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.invalidate(historicalWorkoutsProvider);
            },
          ),
        ],
      ),
      body: authState != AuthState.authenticated
          ? const _NotAuthenticatedView()
          : const _AuthenticatedAnalyticsView(),
    );
  }
}

class _AuthenticatedAnalyticsView extends ConsumerWidget {
  const _AuthenticatedAnalyticsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(historicalWorkoutsProvider);

    return workoutsAsync.when(
      data: (workouts) => _AnalyticsContent(
        workouts: workouts,
      ),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {

  const _AnalyticsContent({
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const _EmptyStateView();
    }

    // Calcola statistiche aggregate
    final stats = _calculateOverallStats(workouts);

    return RefreshIndicator(
      onRefresh: () async {
        // Invalidation is handled by the refresh button in AppBar
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📱 Banner Ad
            AdaptiveBannerAd(adUnitId: AdMobConfig.bannerAnalytics),
            const SizedBox(height: 16),

            // 📊 MONTHLY SUMMARY CARD (Priority 1 - Evidence: +78% retention)
            // Shows: This month vs last month + auto-highlight best improvement
            MonthlySummaryCard(workouts: workouts),
            const SizedBox(height: 16),

            // 📈 VOLUME PROGRESSION CHART (Priority 1 - Visual progress)
            // Shows: Weekly/monthly volume with % growth trend
            // Evidence: Visual progress = top retention predictor
            VolumeProgressionChart(workouts: workouts),
            const SizedBox(height: 16),

            // 📅 Workout Frequency (Keep - but will improve)
            WorkoutFrequencyChart(workouts: workouts),
            const SizedBox(height: 16),

            // 📊 Overview Stats (Keep - total numbers for reference)
            AnalyticsOverviewCard(stats: stats),

            // 🧹 REMOVED non-actionable widgets:
            // ❌ RecentWorkoutsCard - just a list, no insights
            // ❌ ExerciseStatsCard - "top exercises" without actionability
            // ❌ Basic Progress Section - replaced with Monthly Summary above
          ],
        ),
      ),
    );
  }

  // 🧹 REMOVED: _buildProgressSection, _buildProgressTile, _getThisMonthWorkouts,
  // _getLastMonthWorkouts, _getConsistencyPercentage
  // Replaced with new Monthly Summary Card widget (better UX + actionable insights)

  // Utility methods for calculations using List<Workout>
  OverallStats _calculateOverallStats(List<Workout> workouts) {
    final int totalWorkouts = workouts.length;
    final int totalExercises = workouts.fold(0, (sum, workout) => sum + workout.exercises.length);
    final int totalSets = workouts.fold(0, (sum, workout) {
      return sum + workout.exercises.fold(0, (exSum, exercise) {
        return exSum + exercise.sets.where((s) => s.isCompleted).length;
      });
    });
    final double totalVolume = _getTotalVolume(workouts);

    return OverallStats(
      totalWorkouts: totalWorkouts,
      totalExercises: totalExercises,
      totalSets: totalSets,
      totalVolume: totalVolume,
    );
  }

  double _getTotalVolume(List<Workout> workouts) {
    return workouts.fold(0.0, (sum, workout) {
      return sum + workout.exercises.fold(0.0, (exSum, exercise) {
        return exSum + exercise.sets.where((s) => s.isCompleted).fold(0.0, (setSum, set) {
          final weight = set.weight ?? 0.0;
          final reps = set.reps ?? 0;
          return setSum + (weight * reps);
        });
      });
    });
  }
}

// Empty/Error/Loading States
class _NotAuthenticatedView extends StatelessWidget {
  const _NotAuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.lock, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            context.l10n.pleaseLoginToViewAnalytics,
            style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(context.l10n.loadingYourAnalytics),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {

  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.error, size: 64, color: context.colors.error),
          const SizedBox(height: 16),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.workout, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 24),
          Text(
            context.l10n.noWorkoutDataYet,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.completeWorkoutsToSeeAnalytics,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/workout'),
            icon: const Icon(AppIcons.play),
            label: Text(context.l10n.startYourFirstWorkout),
          ),
        ],
      ),
    );
  }
}

class OverallStats {

  const OverallStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
  });
  final int totalWorkouts;
  final int totalExercises;
  final int totalSets;
  final double totalVolume;
}
