import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/analytics_overview_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/recent_workouts_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_stats_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_frequency_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/adaptive_banner_ad.dart';
import 'package:gymbro_flutter_new/core/config/admob_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Analytics'),
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

            // Overview Cards
            AnalyticsOverviewCard(stats: stats),
            const SizedBox(height: 16),

            // Workout Frequency Chart
            WorkoutFrequencyChart(workouts: workouts),
            const SizedBox(height: 16),

            // Recent Workouts
            RecentWorkoutsCard(workouts: workouts.take(5).toList()),
            const SizedBox(height: 16),

            // Top Exercises Stats
            ExerciseStatsCard(workouts: workouts),
            const SizedBox(height: 16),

            // Progress Section
            _buildProgressSection(context, workouts),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, List<Workout> workouts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.trendUp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Progress Tracking',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Monthly progress
            _buildProgressTile(
              context,
              '📅 This Month',
              '${_getThisMonthWorkouts(workouts)} workouts',
              _getThisMonthWorkouts(workouts) > _getLastMonthWorkouts(workouts)
                  ? AppIcons.trendUp
                  : AppIcons.trendDown,
              _getThisMonthWorkouts(workouts) > _getLastMonthWorkouts(workouts)
                  ? Colors.green
                  : Colors.red,
            ),
            
            _buildProgressTile(
              context,
              '💪 Total Volume',
              '${_getTotalVolume(workouts).toStringAsFixed(0)} kg',
              AppIcons.workout,
              Theme.of(context).colorScheme.secondary,
            ),
            
            _buildProgressTile(
              context,
              '🎯 Consistency',
              '${_getConsistencyPercentage(workouts)}% this month',
              AppIcons.calendar,
              Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  int _getThisMonthWorkouts(List<Workout> workouts) {
    final now = DateTime.now();
    return workouts.where((workout) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      return workoutDate.year == now.year && workoutDate.month == now.month;
    }).length;
  }

  int _getLastMonthWorkouts(List<Workout> workouts) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);
    return workouts.where((workout) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      return workoutDate.year == lastMonth.year && workoutDate.month == lastMonth.month;
    }).length;
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

  int _getConsistencyPercentage(List<Workout> workouts) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final workoutDays = workouts.where((workout) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      return workoutDate.year == now.year && workoutDate.month == now.month;
    }).map((w) => (w.endTime ?? w.createdAt).day).toSet().length;
    
    if (daysInMonth == 0) return 0;
    return ((workoutDays / daysInMonth) * 100).round();
  }
}

// Empty/Error/Loading States
class _NotAuthenticatedView extends StatelessWidget {
  const _NotAuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Please log in to view your analytics',
            style: TextStyle(fontSize: 18, color: Colors.grey),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your analytics...'),
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
          Icon(AppIcons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error loading analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
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
          Icon(AppIcons.workout, size: 80, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'No workout data yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Complete some workouts to see your\nanalytics and progress!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/workout'),
            icon: const Icon(AppIcons.play),
            label: const Text('Start Your First Workout'),
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
