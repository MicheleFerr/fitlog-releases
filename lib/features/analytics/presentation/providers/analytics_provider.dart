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
import 'package:gymbro_flutter_new/features/analytics/domain/services/analytics_calculation_service.dart';
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
final workoutSyncStatusProvider = NotifierProvider<WorkoutSyncNotifier, WorkoutSyncStatus>(
  WorkoutSyncNotifier.new,
);

/// Notifier for managing sync status
class WorkoutSyncNotifier extends Notifier<WorkoutSyncStatus> {
  @override
  WorkoutSyncStatus build() {
    return WorkoutSyncStatus.idle();
  }

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
      state = WorkoutSyncStatus.idle();
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
    // RIVERPOD FIX: Defer state modification to avoid "modifying other providers during build" error
    // Schedule setChecking() for next microtask to ensure provider initialization completes first
    // ignore: unawaited_futures
    Future.microtask(() {
      if (ref.state.hasValue || ref.state.isLoading) {
        syncNotifier.setChecking();
      }
    });

    // Set up progress callback for sync
    if (analyticsRepo is WorkoutAnalyticsRepositoryImpl) {
      analyticsRepo.setSyncProgressCallback((current, total) {
        // Progress callbacks happen during async operation, so they're safe
        syncNotifier.setSyncing(current, total);
      });
    }

    // Fetch completed workouts for analytics (this will trigger sync if needed)
    final workouts = await analyticsRepo.getHistoricalWorkouts(user.uid, limit: 100);

    // Mark as completed (happens after async operation, so it's safe)
    syncNotifier.setCompleted();

    return workouts;
  } catch (e) {
    // Error handling happens after async operation, so it's safe
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

/// Analytics state notifier (THIN PROVIDER PATTERN)
///
/// **Design Philosophy**: Provider is THIN - only state management
/// **Business Logic**: Delegated to AnalyticsCalculationService
///
/// **Responsibilities**:
/// - Load data from repositories
/// - Update state
/// - Coordinate between services
/// - Handle errors
///
/// **NOT Responsible For**:
/// - Calculations (→ AnalyticsCalculationService)
/// - Volume logic (→ VolumeCalculator)
/// - Trend analysis (→ TrendAnalyzer)
/// - PR tracking (→ PRTracker)
class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    final userId = _getUserId();
    if (userId != null) {
      loadAnalytics();
    }
    return AnalyticsState.initial();
  }

  HybridExerciseActivityRepository get _activityRepository => ref.read(hybridExerciseActivityRepositoryProvider);
  PRTracker get _prTracker => PRTracker();
  AnalyticsCalculationService get _calculationService => ref.read(analyticsCalculationServiceProvider);
  String? get _userId => _getUserId();

  String? _getUserId() {
    return ref.watch(firebaseUserProvider).valueOrNull?.email;
  }

  /// Load all analytics data
  Future<void> loadAnalytics({bool forceRefresh = false}) async {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load activities with increased limit to ensure we capture recent workouts
      // Use forceRefresh to bypass any caching in the repository
      final activities = await _activityRepository.getUserActivities(
        userEmail: userId,
        limit: 100, // SYNC FIX: Increased from 50 to capture recent workouts
      );

      // DEBUG: Log activity count for troubleshooting
      if (kDebugMode) {
        debugPrint('📊 Analytics: Loaded ${activities.length} activities for user $userId');
      }

      // Load personal records
      final personalRecords = await _prTracker.getUserPRs(userId);
      final recentPRs = await _prTracker.getRecentPRs(userId);

      // Calculate analytics
      final volumeProgression = VolumeCalculator.calculateProgression(activities);
      final muscleBalance = InsightsEngine.analyzeMuscleBalance(activities);

      // Generate insights
      final insights = InsightsEngine.generateInsights(
        activities: activities,
        recentPRs: recentPRs,
        userId: userId,
      );

      // Calculate trends for top exercises (delegated to service)
      final exerciseTrends = await _calculationService.calculateExerciseTrends(activities);

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
    final userId = _userId;
    if (userId == null) return [];

    try {
      final newPRs = await _prTracker.checkAndUpdatePRs(activity);

      if (newPRs.isNotEmpty) {
        // Reload PRs to update state
        final personalRecords = await _prTracker.getUserPRs(userId);
        final recentPRs = await _prTracker.getRecentPRs(userId);
        
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

  /// Get volume data for specific period (delegated to service)
  Map<DateTime, double> getVolumeByPeriod(AnalysisPeriod period) {
    return _calculationService.getVolumeByPeriod(state.activities, period);
  }

  /// Get 1RM progression for an exercise (delegated to service)
  Map<DateTime, double> get1RMProgression(String exerciseId) {
    return _calculationService.get1RMProgression(state.activities, exerciseId);
  }

  /// Get workout frequency stats (delegated to service)
  Map<String, dynamic> getFrequencyStats() {
    return _calculationService.getFrequencyStats(state.activities);
  }

  /// Get exercise-specific stats (delegated to service)
  Map<String, dynamic> getExerciseStats(String exerciseId) {
    return _calculationService.getExerciseStats(state.activities, exerciseId);
  }

  // NOTE: All calculation logic moved to AnalyticsCalculationService
  // This notifier is now THIN - only state management
}

/// Calculation service provider (singleton)
final analyticsCalculationServiceProvider = Provider<AnalyticsCalculationService>((ref) {
  return AnalyticsCalculationService();
});

/// Main analytics provider (THIN PROVIDER PATTERN)
final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(
  AnalyticsNotifier.new,
);

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

// ============================================================================
// MEMOIZED PROVIDERS (from memoized_analytics_provider.dart)
// ============================================================================

/// Memoized analytics stats
class AnalyticsStats {
  const AnalyticsStats({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.currentStreak,
    required this.consistency,
    required this.volumeTrend,
    required this.workoutTrend,
  });

  final int totalWorkouts;
  final double totalVolume;
  final int currentStreak;
  final int consistency;
  final double volumeTrend;
  final double workoutTrend;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsStats &&
          runtimeType == other.runtimeType &&
          totalWorkouts == other.totalWorkouts &&
          totalVolume == other.totalVolume &&
          currentStreak == other.currentStreak &&
          consistency == other.consistency &&
          volumeTrend == other.volumeTrend &&
          workoutTrend == other.workoutTrend;

  @override
  int get hashCode =>
      totalWorkouts.hashCode ^
      totalVolume.hashCode ^
      currentStreak.hashCode ^
      consistency.hashCode ^
      volumeTrend.hashCode ^
      workoutTrend.hashCode;
}

/// Time period for filtering
enum TimePeriod { week, month, year, all }

/// Provider for global memoized stats
final globalAnalyticsStatsProvider = Provider<AnalyticsStats>((ref) {
  final state = ref.watch(analyticsProvider);
  final calculationService = ref.read(analyticsCalculationServiceProvider);

  final totalWorkouts = state.activities.length;
  final totalVolume = VolumeCalculator.calculateTotalVolume(
    state.activities.expand((a) => a.sets).toList(),
  );
  final currentStreak = calculationService.calculateCurrentStreak(state.activities);

  // Consistency (last 30 days)
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final last30DaysWorkouts = state.activities
      .where((a) => a.createdAt.isAfter(thirtyDaysAgo))
      .toList();

  final uniqueDays = last30DaysWorkouts
      .map((a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day))
      .toSet();
  final consistency = (uniqueDays.length / 30 * 100).round();

  return AnalyticsStats(
    totalWorkouts: totalWorkouts,
    totalVolume: totalVolume,
    currentStreak: currentStreak,
    consistency: consistency,
    volumeTrend: 0,
    workoutTrend: 0,
  );
});