import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/workout_analytics_repository_impl.dart';

import 'package:flutter/foundation.dart';

// =============================================================================
// SYNC STATE MANAGEMENT
// =============================================================================

/// Sync state enum
enum SyncState {
  idle,       // No sync in progress
  checking,   // Checking if sync needed
  syncing,    // Syncing workouts
  completed,  // Sync completed successfully
  error,      // Sync failed
}

/// Workout sync status
class WorkoutSyncStatus {

  const WorkoutSyncStatus({
    required this.state,
    this.currentCount = 0,
    this.totalCount = 0,
    this.errorMessage,
  });

  factory WorkoutSyncStatus.idle() {
    return const WorkoutSyncStatus(state: SyncState.idle);
  }

  factory WorkoutSyncStatus.checking() {
    return const WorkoutSyncStatus(state: SyncState.checking);
  }

  factory WorkoutSyncStatus.syncing(int current, int total) {
    return WorkoutSyncStatus(
      state: SyncState.syncing,
      currentCount: current,
      totalCount: total,
    );
  }

  factory WorkoutSyncStatus.completed() {
    return const WorkoutSyncStatus(state: SyncState.completed);
  }

  factory WorkoutSyncStatus.error(String message) {
    return WorkoutSyncStatus(
      state: SyncState.error,
      errorMessage: message,
    );
  }
  final SyncState state;
  final int currentCount;
  final int totalCount;
  final String? errorMessage;

  double get progress => totalCount > 0 ? currentCount / totalCount : 0.0;

  bool get isActive => state == SyncState.checking || state == SyncState.syncing;

  WorkoutSyncStatus copyWith({
    SyncState? state,
    int? currentCount,
    int? totalCount,
    String? errorMessage,
  }) {
    return WorkoutSyncStatus(
      state: state ?? this.state,
      currentCount: currentCount ?? this.currentCount,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider for workout sync status
final workoutSyncStatusProvider = StateNotifierProvider<WorkoutSyncNotifier, WorkoutSyncStatus>((ref) {
  return WorkoutSyncNotifier();
});

/// Notifier for managing sync status
class WorkoutSyncNotifier extends StateNotifier<WorkoutSyncStatus> {
  WorkoutSyncNotifier() : super(WorkoutSyncStatus.idle());

  void setChecking() {
    state = WorkoutSyncStatus.checking();
  }

  void setSyncing(int current, int total) {
    state = WorkoutSyncStatus.syncing(current, total);
  }

  void setCompleted() {
    state = WorkoutSyncStatus.completed();
    // Reset to idle after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        state = WorkoutSyncStatus.idle();
      }
    });
  }

  void setError(String message) {
    state = WorkoutSyncStatus.error(message);
  }

  void reset() {
    state = WorkoutSyncStatus.idle();
  }
}

/// Provider for historical workouts with sync status tracking
final historicalWorkoutsProvider = FutureProvider.autoDispose<List<Workout>>((ref) async {
  final user = ref.watch(firebaseUserProvider).value;

  if (user == null) {
    return [];
  }

  final analyticsRepo = ref.watch(workoutAnalyticsRepositoryProvider);
  final syncNotifier = ref.read(workoutSyncStatusProvider.notifier);

  try {
    // Set checking state
    syncNotifier.setChecking();

    // Set up progress callback for sync
    if (analyticsRepo is WorkoutAnalyticsRepositoryImpl) {
      analyticsRepo.setSyncProgressCallback((current, total) {
        syncNotifier.setSyncing(current, total);
      });
    }

    // Fetch completed workouts for analytics (this will trigger sync if needed)
    final workouts = await analyticsRepo.getHistoricalWorkouts(user.uid, limit: 100);

    // Mark as completed
    syncNotifier.setCompleted();

    return workouts;
  } catch (e) {
    syncNotifier.setError(e.toString());
    rethrow;
  }
});


/// State for analytics data
class AnalyticsState {

  AnalyticsState({
    this.activities = const [],
    this.personalRecords = const [],
    this.recentPRs = const [],
    this.insights = const [],
    required this.volumeProgression,
    this.exerciseTrends = const {},
    required this.muscleBalance,
    this.isLoading = false,
    this.error,
  });

  factory AnalyticsState.initial() {
    return AnalyticsState(
      volumeProgression: const VolumeProgression(
        weeklyChange: 0,
        monthlyChange: 0,
        currentWeekVolume: 0,
        currentMonthVolume: 0,
      ),
      muscleBalance: MuscleGroupBalance(
        volumeDistribution: {},
        idealDistribution: {},
        imbalanceScores: {},
      ),
    );
  }
  final List<ExerciseActivity> activities;
  final List<PersonalRecord> personalRecords;
  final List<PersonalRecord> recentPRs;
  final List<TrainingInsight> insights;
  final VolumeProgression volumeProgression;
  final Map<String, TrendAnalysis> exerciseTrends;
  final MuscleGroupBalance muscleBalance;
  final bool isLoading;
  final String? error;

  AnalyticsState copyWith({
    List<ExerciseActivity>? activities,
    List<PersonalRecord>? personalRecords,
    List<PersonalRecord>? recentPRs,
    List<TrainingInsight>? insights,
    VolumeProgression? volumeProgression,
    Map<String, TrendAnalysis>? exerciseTrends,
    MuscleGroupBalance? muscleBalance,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      activities: activities ?? this.activities,
      personalRecords: personalRecords ?? this.personalRecords,
      recentPRs: recentPRs ?? this.recentPRs,
      insights: insights ?? this.insights,
      volumeProgression: volumeProgression ?? this.volumeProgression,
      exerciseTrends: exerciseTrends ?? this.exerciseTrends,
      muscleBalance: muscleBalance ?? this.muscleBalance,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Analytics state notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {

  AnalyticsNotifier({
    required HybridExerciseActivityRepository activityRepository,
    required PRTracker prTracker,
    String? userId,
  })  : _activityRepository = activityRepository,
        _prTracker = prTracker,
        _userId = userId,
        super(AnalyticsState.initial()) {
    if (_userId != null) {
      loadAnalytics();
    }
  }
  final HybridExerciseActivityRepository _activityRepository;
  final PRTracker _prTracker;
  final String? _userId;

  /// Load all analytics data
  Future<void> loadAnalytics({bool forceRefresh = false}) async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load activities with increased limit to ensure we capture recent workouts
      // Use forceRefresh to bypass any caching in the repository
      final activities = await _activityRepository.getUserActivities(
        userEmail: _userId,
        limit: 100, // SYNC FIX: Increased from 50 to capture recent workouts
      );

      // DEBUG: Log activity count for troubleshooting
      if (kDebugMode) {
        debugPrint('📊 Analytics: Loaded ${activities.length} activities for user $_userId');
      }
      
      // Load personal records
      final personalRecords = await _prTracker.getUserPRs(_userId);
      final recentPRs = await _prTracker.getRecentPRs(_userId);

      // Calculate analytics
      final volumeProgression = VolumeCalculator.calculateProgression(activities);
      final muscleBalance = InsightsEngine.analyzeMuscleBalance(activities);
      
      // Generate insights
      final insights = InsightsEngine.generateInsights(
        activities: activities,
        recentPRs: recentPRs,
        userId: _userId,
      );

      // Calculate trends for top exercises
      final exerciseTrends = await _calculateExerciseTrends(activities);

      state = state.copyWith(
        activities: activities,
        personalRecords: personalRecords,
        recentPRs: recentPRs,
        insights: insights,
        volumeProgression: volumeProgression,
        exerciseTrends: exerciseTrends,
        muscleBalance: muscleBalance,
        isLoading: false,
      );
      
      if (kDebugMode) {
        debugPrint('✅ Analytics: Updated state with ${activities.length} activities');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics: Error loading data: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh analytics data
  Future<void> refresh() async {
    await loadAnalytics(forceRefresh: true);
  }
  
  /// Refresh analytics after workout completion
  /// This ensures the analytics screen shows the latest data
  Future<void> refreshAfterWorkoutCompletion() async {
    if (kDebugMode) {
      debugPrint('🔄 Analytics: Refreshing after workout completion...');
    }
    await loadAnalytics(forceRefresh: true);
  }

  /// Check for new PRs after workout completion
  Future<List<PersonalRecord>> checkForNewPRs(ExerciseActivity activity) async {
    try {
      final newPRs = await _prTracker.checkAndUpdatePRs(activity);
      
      if (newPRs.isNotEmpty) {
        // Reload PRs to update state
        final personalRecords = await _prTracker.getUserPRs(_userId!);
        final recentPRs = await _prTracker.getRecentPRs(_userId);
        
        state = state.copyWith(
          personalRecords: personalRecords,
          recentPRs: recentPRs,
        );
      }
      
      return newPRs;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking for PRs: $e');
      }
      return [];
    }
  }

  /// Get volume data for specific period
  Map<DateTime, double> getVolumeByPeriod(AnalysisPeriod period) {
    final volumeData = <DateTime, double>{};
    
    for (final activity in state.activities) {
      DateTime periodKey;
      
      switch (period) {
        case AnalysisPeriod.week:
          final weekStart = _getWeekStart(activity.createdAt);
          periodKey = weekStart;
        case AnalysisPeriod.month:
          periodKey = DateTime(activity.createdAt.year, activity.createdAt.month);
        case AnalysisPeriod.quarter:
          final quarter = ((activity.createdAt.month - 1) ~/ 3) + 1;
          periodKey = DateTime(activity.createdAt.year, (quarter - 1) * 3 + 1);
        case AnalysisPeriod.year:
          periodKey = DateTime(activity.createdAt.year);
      }
      
      final volume = VolumeCalculator.calculateTotalVolume(activity.sets);
      volumeData[periodKey] = (volumeData[periodKey] ?? 0) + volume;
    }
    
    return volumeData;
  }

  /// Get 1RM progression for an exercise
  Map<DateTime, double> get1RMProgression(String exerciseId) {
    final progression = <DateTime, double>{};
    
    final exerciseActivities = state.activities
        .where((a) => a.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    for (final activity in exerciseActivities) {
      double max1RM = 0;
      
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;
        
        if (weight > 0 && reps > 0) {
          final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
          if (estimated1RM > max1RM) {
            max1RM = estimated1RM;
          }
        }
      }
      
      if (max1RM > 0) {
        progression[activity.createdAt] = max1RM;
      }
    }
    
    return progression;
  }

  /// Get workout frequency stats
  Map<String, dynamic> getFrequencyStats() {
    final stats = <String, dynamic>{};
    
    // Last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentActivities = state.activities
        .where((a) => a.createdAt.isAfter(thirtyDaysAgo))
        .toList();
    
    // Unique workout days
    final workoutDays = recentActivities
        .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
        .toSet();
    
    stats['daysInLast30'] = workoutDays.length;
    stats['avgPerWeek'] = (workoutDays.length / 4.3).round();
    
    // Day distribution
    final dayDistribution = <int, int>{};
    for (final activity in recentActivities) {
      final dayOfWeek = activity.createdAt.weekday;
      dayDistribution[dayOfWeek] = (dayDistribution[dayOfWeek] ?? 0) + 1;
    }
    stats['dayDistribution'] = dayDistribution;
    
    // Current streak
    stats['currentStreak'] = _calculateCurrentStreak();
    
    return stats;
  }

  /// Get exercise-specific stats
  Map<String, dynamic> getExerciseStats(String exerciseId) {
    final exerciseActivities = state.activities
        .where((a) => a.exerciseId == exerciseId)
        .toList();
    
    if (exerciseActivities.isEmpty) {
      return {};
    }
    
    final stats = <String, dynamic>{};
    
    // Volume stats
    final volumeStats = VolumeCalculator.getVolumeStats(exerciseActivities);
    stats['volumeStats'] = volumeStats;
    
    // Best performance
    double maxWeight = 0;
    int maxReps = 0;
    double max1RM = 0;
    
    for (final activity in exerciseActivities) {
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;
        
        if (weight > maxWeight) maxWeight = weight;
        if (reps > maxReps) maxReps = reps;
        
        if (weight > 0 && reps > 0) {
          final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
          if (estimated1RM > max1RM) max1RM = estimated1RM;
        }
      }
    }
    
    stats['maxWeight'] = maxWeight;
    stats['maxReps'] = maxReps;
    stats['estimated1RM'] = max1RM;
    
    // Trend
    final trend = TrendAnalyzer.analyzeStrengthTrend(state.activities, exerciseId);
    stats['trend'] = trend;
    
    // Plateau detection
    final plateau = TrendAnalyzer.detectPlateau(state.activities, exerciseId);
    stats['plateau'] = plateau;
    
    return stats;
  }

  // Private helper methods
  
  Future<Map<String, TrendAnalysis>> _calculateExerciseTrends(
    List<ExerciseActivity> activities,
  ) async {
    final trends = <String, TrendAnalysis>{};
    
    // Get top 5 exercises
    final exerciseCounts = <String, int>{};
    for (final activity in activities) {
      exerciseCounts[activity.exerciseId] = 
          (exerciseCounts[activity.exerciseId] ?? 0) + 1;
    }
    
    final topExercises = exerciseCounts.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final exercise in topExercises.take(5)) {
      trends[exercise.key] = TrendAnalyzer.analyzeStrengthTrend(
        activities,
        exercise.key,
      );
    }
    
    return trends;
  }

  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  int _calculateCurrentStreak() {
    if (state.activities.isEmpty) return 0;
    
    final sortedActivities = state.activities.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final uniqueDates = sortedActivities
        .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (uniqueDates.isEmpty) return 0;
    
    // Check if last workout was today or yesterday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (uniqueDates.first != today && uniqueDates.first != yesterday) {
      return 0;
    }
    
    int streak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i - 1].difference(uniqueDates[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
}

/// Main analytics provider
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final user = ref.watch(firebaseUserProvider).valueOrNull;
  final activityRepository = ref.read(hybridExerciseActivityRepositoryProvider);
  final prTracker = PRTracker();
  
  return AnalyticsNotifier(
    activityRepository: activityRepository,
    prTracker: prTracker,
    userId: user?.email,
  );
});

/// Provider for volume chart data
// MEMORY FIX: Added autoDispose to free chart data when not displayed
final volumeChartDataProvider = Provider.autoDispose<Map<DateTime, double>>((ref) {
  final state = ref.watch(analyticsProvider);
  return VolumeCalculator.calculateDailyVolume(state.activities);
});

/// Global refresh trigger for analytics data
/// This can be called from anywhere in the app to refresh analytics
final analyticsRefreshProvider = Provider<void Function()>((ref) {
  return () {
    if (kDebugMode) {
      debugPrint('🔄 Global analytics refresh triggered');
    }
    ref.read(analyticsProvider.notifier).refreshAfterWorkoutCompletion();
    
    // Also invalidate exercise history providers to ensure fresh data
    ref.invalidate(recentWeightsWithDetailsProvider);
    ref.invalidate(exerciseHistoryProvider);
    ref.invalidate(exerciseHistoryGroupedProvider);
    ref.invalidate(exerciseStatsProvider);
  };
});

/// Provider for PR timeline
final prTimelineProvider = Provider.family<List<PersonalRecord>, String>((ref, exerciseId) {
  final state = ref.watch(analyticsProvider);
  return state.personalRecords
      .where((pr) => pr.exerciseId == exerciseId)
      .toList()
    ..sort((a, b) => a.achievedAt.compareTo(b.achievedAt));
});

/// Provider for exercise list
final exerciseListProvider = Provider<List<({String id, String name, int count})>>((ref) {
  final state = ref.watch(analyticsProvider);
  
  final exerciseMap = <String, ({String name, int count})>{};
  
  for (final activity in state.activities) {
    if (!exerciseMap.containsKey(activity.exerciseId)) {
      exerciseMap[activity.exerciseId] = (
        name: activity.exerciseName,
        count: 0,
      );
    }
    
    exerciseMap[activity.exerciseId] = (
      name: exerciseMap[activity.exerciseId]!.name,
      count: exerciseMap[activity.exerciseId]!.count + 1,
    );
  }
  
  return exerciseMap.entries
      .map((e) => (id: e.key, name: e.value.name, count: e.value.count))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));
});

/// Provider for workout recommendations
final workoutRecommendationsProvider = Provider<List<String>>((ref) {
  final state = ref.watch(analyticsProvider);
  
  // Return insights recommendations
  return state.insights
      .take(5)
      .map((insight) => insight.recommendation)
      .toList();
});