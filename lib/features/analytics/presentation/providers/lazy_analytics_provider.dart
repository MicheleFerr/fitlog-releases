import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/insights_engine.dart';
import 'package:flutter/foundation.dart';

/// Loading phase for progressive data loading
enum LoadingPhase {
  initial,      // Last 30 days
  extended,     // Last 3 months  
  full,         // Last year
  complete,     // All data
}

/// State for lazy loaded analytics
class LazyAnalyticsState {
  
  LazyAnalyticsState({
    this.activities = const [],
    this.personalRecords = const [],
    this.recentPRs = const [],
    this.insights = const [],
    required this.volumeProgression,
    this.exerciseTrends = const {},
    required this.muscleBalance,
    this.currentPhase = LoadingPhase.initial,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.error,
    this.lastFetchDate,
  });
  
  factory LazyAnalyticsState.initial() {
    return LazyAnalyticsState(
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
  final LoadingPhase currentPhase;
  final bool isLoadingMore;
  final bool hasMoreData;
  final String? error;
  final DateTime? lastFetchDate;
  
  LazyAnalyticsState copyWith({
    List<ExerciseActivity>? activities,
    List<PersonalRecord>? personalRecords,
    List<PersonalRecord>? recentPRs,
    List<TrainingInsight>? insights,
    VolumeProgression? volumeProgression,
    Map<String, TrendAnalysis>? exerciseTrends,
    MuscleGroupBalance? muscleBalance,
    LoadingPhase? currentPhase,
    bool? isLoadingMore,
    bool? hasMoreData,
    String? error,
    DateTime? lastFetchDate,
  }) {
    return LazyAnalyticsState(
      activities: activities ?? this.activities,
      personalRecords: personalRecords ?? this.personalRecords,
      recentPRs: recentPRs ?? this.recentPRs,
      insights: insights ?? this.insights,
      volumeProgression: volumeProgression ?? this.volumeProgression,
      exerciseTrends: exerciseTrends ?? this.exerciseTrends,
      muscleBalance: muscleBalance ?? this.muscleBalance,
      currentPhase: currentPhase ?? this.currentPhase,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      error: error ?? this.error,
      lastFetchDate: lastFetchDate ?? this.lastFetchDate,
    );
  }
}

/// Lazy loading analytics notifier
class LazyAnalyticsNotifier extends StateNotifier<LazyAnalyticsState> {
  
  LazyAnalyticsNotifier({
    required HybridExerciseActivityRepository activityRepository,
    required PRTracker prTracker,
    String? userId,
  })  : _activityRepository = activityRepository,
        _prTracker = prTracker,
        _userId = userId,
        super(LazyAnalyticsState.initial()) {
    if (_userId != null) {
      loadInitialData();
    }
  }
  final HybridExerciseActivityRepository _activityRepository;
  final PRTracker _prTracker;
  final String? _userId;
  
  // Date ranges for progressive loading
  static const Map<LoadingPhase, Duration> _phaseRanges = {
    LoadingPhase.initial: Duration(days: 30),
    LoadingPhase.extended: Duration(days: 90),
    LoadingPhase.full: Duration(days: 365),
    LoadingPhase.complete: Duration(days: 3650), // 10 years
  };
  
  /// Load initial data (last 30 days)
  Future<void> loadInitialData() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoadingMore: true, error: null);
    
    try {
      debugPrint('📊 LazyAnalytics: Loading initial data (last 30 days)');
      
      final now = DateTime.now();
      final startDate = now.subtract(_phaseRanges[LoadingPhase.initial]!);
      
      // Load only recent activities
      final activities = await _activityRepository.getUserActivitiesInDateRange(
        userEmail: _userId,
        startDate: startDate,
        endDate: now,
      );
      
      debugPrint('📊 LazyAnalytics: Loaded ${activities.length} activities from last 30 days');
      
      // Load personal records (lightweight)
      final personalRecords = await _prTracker.getUserPRs(_userId);
      final recentPRs = await _prTracker.getRecentPRs(_userId);
      
      // Calculate analytics for loaded data
      final volumeProgression = VolumeCalculator.calculateProgression(activities);
      final muscleBalance = InsightsEngine.analyzeMuscleBalance(activities);
      
      // Generate insights
      final insights = InsightsEngine.generateInsights(
        activities: activities,
        recentPRs: recentPRs,
        userId: _userId,
      );
      
      // Calculate trends for top exercises (limit to top 5)
      final exerciseTrends = await _calculateLimitedExerciseTrends(activities, limit: 5);
      
      state = state.copyWith(
        activities: activities,
        personalRecords: personalRecords,
        recentPRs: recentPRs,
        insights: insights,
        volumeProgression: volumeProgression,
        exerciseTrends: exerciseTrends,
        muscleBalance: muscleBalance,
        currentPhase: LoadingPhase.initial,
        isLoadingMore: false,
        hasMoreData: true,
        lastFetchDate: startDate,
      );
    } catch (e) {
      debugPrint('❌ LazyAnalytics: Error loading initial data: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
  
  /// Load more data when user scrolls
  Future<void> loadMoreData() async {
    if (_userId == null || state.isLoadingMore || !state.hasMoreData) return;
    
    state = state.copyWith(isLoadingMore: true, error: null);
    
    try {
      // Determine next phase
      final nextPhase = _getNextPhase(state.currentPhase);
      if (nextPhase == null) {
        state = state.copyWith(isLoadingMore: false, hasMoreData: false);
        return;
      }
      
      debugPrint('📊 LazyAnalytics: Loading more data - Phase: $nextPhase');
      
      final now = DateTime.now();
      final startDate = now.subtract(_phaseRanges[nextPhase]!);
      final endDate = state.lastFetchDate ?? now;
      
      // Load additional activities
      final newActivities = await _activityRepository.getUserActivitiesInDateRange(
        userEmail: _userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      debugPrint('📊 LazyAnalytics: Loaded ${newActivities.length} additional activities');
      
      // Merge with existing activities
      final allActivities = [...state.activities, ...newActivities];
      
      // Recalculate analytics with all data
      final volumeProgression = VolumeCalculator.calculateProgression(allActivities);
      final muscleBalance = InsightsEngine.analyzeMuscleBalance(allActivities);
      
      // Update insights
      final insights = InsightsEngine.generateInsights(
        activities: allActivities,
        recentPRs: state.recentPRs,
        userId: _userId,
      );
      
      // Update trends (still limited to top exercises)
      final exerciseTrends = await _calculateLimitedExerciseTrends(allActivities, limit: 10);
      
      state = state.copyWith(
        activities: allActivities,
        insights: insights,
        volumeProgression: volumeProgression,
        exerciseTrends: exerciseTrends,
        muscleBalance: muscleBalance,
        currentPhase: nextPhase,
        isLoadingMore: false,
        hasMoreData: nextPhase != LoadingPhase.complete,
        lastFetchDate: startDate,
      );
      
    } catch (e) {
      debugPrint('❌ LazyAnalytics: Error loading more data: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
  
  /// Get next loading phase
  LoadingPhase? _getNextPhase(LoadingPhase current) {
    switch (current) {
      case LoadingPhase.initial:
        return LoadingPhase.extended;
      case LoadingPhase.extended:
        return LoadingPhase.full;
      case LoadingPhase.full:
        return LoadingPhase.complete;
      case LoadingPhase.complete:
        return null;
    }
  }
  
  /// Calculate trends for limited number of exercises
  Future<Map<String, TrendAnalysis>> _calculateLimitedExerciseTrends(
    List<ExerciseActivity> activities,
    {int limit = 5}
  ) async {
    // Group activities by exercise
    final exerciseGroups = <String, List<ExerciseActivity>>{};
    for (final activity in activities) {
      exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
    }
    
    // Sort by frequency and take top N
    final topExercises = exerciseGroups.entries
        .toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length))
        ..take(limit);
    
    // Calculate trends for top exercises only
    final trends = <String, TrendAnalysis>{};
    for (final entry in topExercises) {
      trends[entry.key] = TrendAnalyzer.analyzeVolumeTrend(
        entry.value,
        AnalysisPeriod.month,
      );
    }
    
    return trends;
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    state = LazyAnalyticsState.initial();
    await loadInitialData();
  }
  
  /// Check if should load more based on scroll position
  bool shouldLoadMore(double scrollPercentage) {
    // Load more when user scrolls past 80% of content
    return scrollPercentage > 0.8 && 
           !state.isLoadingMore && 
           state.hasMoreData;
  }
  
  /// Get loading message based on phase
  String get loadingMessage {
    switch (state.currentPhase) {
      case LoadingPhase.initial:
        return 'Loading last 3 months...';
      case LoadingPhase.extended:
        return 'Loading last year...';
      case LoadingPhase.full:
        return 'Loading all history...';
      case LoadingPhase.complete:
        return 'All data loaded';
    }
  }
}

/// Provider for lazy loaded analytics
final lazyAnalyticsProvider = StateNotifierProvider<LazyAnalyticsNotifier, LazyAnalyticsState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  final repository = ref.watch(exerciseActivityRepositoryProvider);

  return LazyAnalyticsNotifier(
    activityRepository: repository as HybridExerciseActivityRepository,
    prTracker: PRTracker(),
    userId: currentUser?.email,
  );
});

/// Provider to check if more data can be loaded
final canLoadMoreAnalyticsProvider = Provider<bool>((ref) {
  final state = ref.watch(lazyAnalyticsProvider);
  return state.hasMoreData && !state.isLoadingMore;
});

/// Provider for loading state
final isLoadingMoreAnalyticsProvider = Provider<bool>((ref) {
  return ref.watch(lazyAnalyticsProvider.select((state) => state.isLoadingMore));
});

/// Provider for current loading phase
final currentLoadingPhaseProvider = Provider<LoadingPhase>((ref) {
  return ref.watch(lazyAnalyticsProvider.select((state) => state.currentPhase));
});

/// Provider for analytics activities count
final analyticsActivitiesCountProvider = Provider<int>((ref) {
  return ref.watch(lazyAnalyticsProvider.select((state) => state.activities.length));
});