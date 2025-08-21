import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../workout/data/repositories/exercise_activity_repository.dart';
import '../../workout/domain/entities/exercise_activity.dart';
import '../../workout/presentation/providers/workout_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'widgets/analytics_overview_card.dart';
import 'widgets/recent_workouts_card.dart';
import 'widgets/exercise_stats_card.dart';
import 'widgets/workout_frequency_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firebaseUser = ref.watch(firebaseUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Analytics'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh by rebuilding providers
              ref.invalidate(userActivitiesProvider);
            },
          ),
        ],
      ),
      body: authState != AuthState.authenticated
          ? const _NotAuthenticatedView()
          : firebaseUser.when(
              data: (user) => user?.email == null
                  ? const _NoEmailView()
                  : _AuthenticatedAnalyticsView(userEmail: user!.email!),
              loading: () => const _LoadingView(),
              error: (error, _) => _ErrorView(error: error.toString()),
            ),
    );
  }
}

class _AuthenticatedAnalyticsView extends ConsumerWidget {
  final String userEmail;

  const _AuthenticatedAnalyticsView({required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(userActivitiesProvider(userEmail));

    return activitiesAsync.when(
      data: (activities) => _AnalyticsContent(
        activities: activities,
        userEmail: userEmail,
      ),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final List<ExerciseActivity> activities;
  final String userEmail;

  const _AnalyticsContent({
    required this.activities,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const _EmptyStateView();
    }

    // Calcola statistiche aggregate
    final stats = _calculateOverallStats(activities);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic handled by provider invalidation
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            AnalyticsOverviewCard(stats: stats),
            const SizedBox(height: 16),

            // Workout Frequency Chart
            WorkoutFrequencyChart(activities: activities),
            const SizedBox(height: 16),

            // Recent Workouts
            RecentWorkoutsCard(activities: activities.take(5).toList()),
            const SizedBox(height: 16),

            // Top Exercises Stats
            ExerciseStatsCard(
              activities: activities,
              userEmail: userEmail,
            ),
            const SizedBox(height: 16),

            // Progress Section
            _buildProgressSection(context, activities),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, List<ExerciseActivity> activities) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
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
              '${_getThisMonthWorkouts(activities)} workouts',
              _getThisMonthWorkouts(activities) > _getLastMonthWorkouts(activities)
                  ? Icons.trending_up
                  : Icons.trending_down,
              _getThisMonthWorkouts(activities) > _getLastMonthWorkouts(activities)
                  ? Colors.green
                  : Colors.red,
            ),
            
            _buildProgressTile(
              context,
              '💪 Total Volume',
              '${_getTotalVolume(activities).toStringAsFixed(0)} kg',
              Icons.fitness_center,
              Theme.of(context).colorScheme.secondary,
            ),
            
            _buildProgressTile(
              context,
              '🎯 Consistency',
              '${_getConsistencyPercentage(activities)}% this month',
              Icons.calendar_today,
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
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

  // Utility methods for calculations
  OverallStats _calculateOverallStats(List<ExerciseActivity> activities) {
    int totalWorkouts = activities.map((a) => a.schedaName).toSet().length;
    int totalExercises = activities.length;
    int totalSets = activities.fold(0, (sum, activity) => sum + activity.sets.length);
    double totalVolume = activities.fold(0.0, (sum, activity) {
      return sum + activity.sets.fold(0.0, (setSum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      });
    });

    return OverallStats(
      totalWorkouts: totalWorkouts,
      totalExercises: totalExercises,
      totalSets: totalSets,
      totalVolume: totalVolume,
    );
  }

  int _getThisMonthWorkouts(List<ExerciseActivity> activities) {
    final now = DateTime.now();
    return activities.where((activity) {
      return activity.createdAt.year == now.year &&
             activity.createdAt.month == now.month;
    }).map((a) => a.schedaName).toSet().length;
  }

  int _getLastMonthWorkouts(List<ExerciseActivity> activities) {
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    return activities.where((activity) {
      return activity.createdAt.year == lastMonth.year &&
             activity.createdAt.month == lastMonth.month;
    }).map((a) => a.schedaName).toSet().length;
  }

  double _getTotalVolume(List<ExerciseActivity> activities) {
    return activities.fold(0.0, (sum, activity) {
      return sum + activity.sets.fold(0.0, (setSum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      });
    });
  }

  int _getConsistencyPercentage(List<ExerciseActivity> activities) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final workoutDays = activities.where((activity) {
      return activity.createdAt.year == now.year &&
             activity.createdAt.month == now.month;
    }).map((a) => a.createdAt.day).toSet().length;
    
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
          Icon(Icons.lock, size: 64, color: Colors.grey),
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

class _NoEmailView extends StatelessWidget {
  const _NoEmailView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.email_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Email not available for analytics',
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
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
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
          const Icon(Icons.fitness_center, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'No workout data yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Complete some workouts to see your\nanalytics and progress!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/workout'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Your First Workout'),
          ),
        ],
      ),
    );
  }
}

// Provider for user activities
final userActivitiesProvider = FutureProvider.family<List<ExerciseActivity>, String>((ref, userEmail) async {
  final repository = ref.read(exerciseActivityRepositoryProvider);
  return repository.getUserActivities(userEmail: userEmail, limit: 100);
});

// Data classes
class OverallStats {
  final int totalWorkouts;
  final int totalExercises;
  final int totalSets;
  final double totalVolume;

  OverallStats({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
  });
}