/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: provider
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod: StateNotifierProvider, StreamProvider
/// - workout/presentation/providers: workoutProvider
/// - analytics/domain: UseCases, Repository, Entities
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/workout_analytics_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/calculate_workout_metrics_usecase.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/detect_personal_records_usecase.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/compare_workouts_usecase.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_cache_service.dart';

// =============================================================================
// PROVIDERS SETUP
// =============================================================================

/// Hive cache box for workout metrics
final workoutMetricsCacheProvider = Provider<Box<Map>>((ref) {
  // Open box if not already open
  if (!Hive.isBoxOpen('workoutMetrics')) {
    throw StateError(
      'workoutMetrics box not opened. Call Hive.openBox<Map>(\'workoutMetrics\') first.',
    );
  }
  return Hive.box<Map>('workoutMetrics');
});

/// Analytics cache service provider (singleton with keepAlive)
///
/// Uses keepAlive() to maintain cache across widget rebuilds,
/// preventing repeated initialization and cache loss.
final analyticsCacheServiceProvider = Provider<AnalyticsCacheService>((ref) {
  // Keep alive to prevent cache loss on widget disposal
  ref.keepAlive();

  final boxManager = ref.watch(hiveBoxManagerProvider);
  final cacheService = AnalyticsCacheService(boxManager);

  // Initialize cache service with error handling
  cacheService.initialize().catchError((e, stack) {
    if (kDebugMode) {
      debugPrint('[AnalyticsCacheService] Failed to initialize: $e\n$stack');
    }
  });

  // Dispose on provider disposal (app termination)
  ref.onDispose(() {
    cacheService.dispose();
  });

  return cacheService;
});

/// Workout Analytics Repository Provider
final workoutAnalyticsRepositoryProvider = Provider<WorkoutAnalyticsRepository>(
  (ref) {
    final hiveDataSource = ref.watch(hiveWorkoutDataSourceProvider);

    // Get the metrics cache box
    final Box<Map> cache;
    if (Hive.isBoxOpen('workoutMetrics')) {
      cache = Hive.box<Map>('workoutMetrics');
    } else {
      throw StateError(
        'workoutMetrics box must be opened before using analytics',
      );
    }

    // Get HiveBoxManagerEnhanced
    final boxManager = ref.watch(hiveBoxManagerProvider);

    // Get analytics cache service
    final cacheService = ref.watch(analyticsCacheServiceProvider);

    // Pass cache, boxManager, and cacheService to repository
    final repository = WorkoutAnalyticsRepositoryImpl(
      metricsCache: cache,
      boxManager: boxManager,
      hiveWorkoutDataSource: hiveDataSource,
      cacheService: cacheService,
    );

    // Dispose repository on provider disposal
    ref.onDispose(() {
      repository.dispose();
    });

    return repository;
  },
);

/// Calculate Workout Metrics Use Case Provider
final calculateWorkoutMetricsUseCaseProvider =
    Provider<CalculateWorkoutMetricsUseCase>((ref) {
      return CalculateWorkoutMetricsUseCase();
    });

/// Detect Personal Records Use Case Provider
final detectPersonalRecordsUseCaseProvider =
    Provider<DetectPersonalRecordsUseCase>((ref) {
      final prTracker = PRTracker();
      return DetectPersonalRecordsUseCase(prTracker);
    });

/// Compare Workouts Use Case Provider
final compareWorkoutsUseCaseProvider = Provider<CompareWorkoutsUseCase>((ref) {
  return CompareWorkoutsUseCase();
});

// =============================================================================
// MAIN ANALYTICS PROVIDER
// =============================================================================

/// Main workout analytics state provider
final workoutAnalyticsProvider =
    NotifierProvider<WorkoutAnalyticsNotifier, WorkoutAnalyticsState>(
      WorkoutAnalyticsNotifier.new,
    );

/// Workout analytics state
class WorkoutAnalyticsState {
  const WorkoutAnalyticsState({
    this.currentMetrics,
    this.currentPRs = const [],
    this.comparison,
    this.prPredictions = const [],
    this.isCalculating = false,
    this.error,
    required this.lastUpdated,
  });
  final WorkoutMetrics? currentMetrics;
  final List<PersonalRecordAchieved> currentPRs;
  final WorkoutComparison? comparison;
  final List<PRPrediction> prPredictions;
  final bool isCalculating;
  final String? error;
  final DateTime lastUpdated;

  WorkoutAnalyticsState copyWith({
    WorkoutMetrics? currentMetrics,
    List<PersonalRecordAchieved>? currentPRs,
    WorkoutComparison? comparison,
    List<PRPrediction>? prPredictions,
    bool? isCalculating,
    String? error,
    DateTime? lastUpdated,
  }) {
    return WorkoutAnalyticsState(
      currentMetrics: currentMetrics ?? this.currentMetrics,
      currentPRs: currentPRs ?? this.currentPRs,
      comparison: comparison ?? this.comparison,
      prPredictions: prPredictions ?? this.prPredictions,
      isCalculating: isCalculating ?? this.isCalculating,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if there are new PRs since last check
  bool get hasNewPRs => currentPRs.isNotEmpty;

  /// Get total PR count
  int get totalPRs => currentPRs.length;

  /// Get significant PRs only (>2.5% improvement)
  List<PersonalRecordAchieved> get significantPRs =>
      currentPRs.where((pr) => pr.isSignificant).toList();

  /// Check if workout shows improvement
  bool get showsImprovement => comparison?.isImprovement == true || hasNewPRs;

  /// Get workout quality rating (A+ to F)
  String get qualityRating {
    final score = currentMetrics?.qualityScore ?? 0;
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'B+';
    if (score >= 75) return 'B';
    if (score >= 70) return 'C+';
    if (score >= 65) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

/// Workout analytics state notifier
class WorkoutAnalyticsNotifier extends Notifier<WorkoutAnalyticsState> {
  Timer? _updateTimer;
  WorkoutMetrics? _lastMetrics;

  @override
  WorkoutAnalyticsState build() {
    _initializeAnalytics();

    // Handle disposal
    ref.onDispose(() {
      _stopPeriodicUpdates();
    });

    return WorkoutAnalyticsState(lastUpdated: DateTime.now());
  }

  void _initializeAnalytics() {
    // Listen to workout changes and update analytics
    ref.listen(currentWorkoutProvider, (previous, next) {
      if (next != null) {
        _updateAnalytics(next);
      } else {
        _clearAnalytics();
      }
    });

    // Start periodic updates for active workouts
    _startPeriodicUpdates();
  }

  /// Update analytics for current workout
  Future<void> _updateAnalytics(Workout workout) async {
    if (state.isCalculating) return;

    state = state.copyWith(isCalculating: true, error: null);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = state.copyWith(
          isCalculating: false,
          error: 'User not authenticated',
        );
        return;
      }

      final calculateUseCase = ref.read(calculateWorkoutMetricsUseCaseProvider);
      final detectPRsUseCase = ref.read(detectPersonalRecordsUseCaseProvider);
      final compareUseCase = ref.read(compareWorkoutsUseCaseProvider);
      final repository = ref.read(workoutAnalyticsRepositoryProvider);

      // Calculate current metrics (with incremental optimization)
      final metrics = calculateUseCase.executeIncremental(
        workout,
        _lastMetrics,
      );

      // Detect potential PRs
      final potentialPRs = await detectPRsUseCase.execute(userId, workout);

      // Get comparison with historical workouts (cached for performance)
      WorkoutComparison? comparison;
      if (_shouldUpdateComparison()) {
        final historicalWorkouts = await repository.getHistoricalWorkouts(
          userId,
          limit: 20,
        );
        comparison = compareUseCase.execute(workout, historicalWorkouts);
      }

      // Get PR predictions for upcoming sets
      final prPredictions = <PRPrediction>[];
      for (final exercise in workout.exercises) {
        final predictions = await detectPRsUseCase.getPRPredictions(
          userId,
          exercise,
        );
        prPredictions.addAll(predictions);
      }

      // Cache metrics for performance
      await repository.cacheWorkoutMetrics(metrics);

      // Update state
      state = state.copyWith(
        currentMetrics: metrics,
        currentPRs: potentialPRs,
        comparison: comparison ?? state.comparison,
        prPredictions: prPredictions,
        isCalculating: false,
        lastUpdated: DateTime.now(),
      );

      _lastMetrics = metrics;

      // Notify repository of update for real-time streams
      if (repository is WorkoutAnalyticsRepositoryImpl) {
        repository.notifyWorkoutUpdate(metrics);
      }
    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        error: 'Error updating analytics: $e',
      );
    }
  }

  /// Force refresh analytics
  Future<void> refreshAnalytics() async {
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout != null) {
      _lastMetrics = null; // Force full recalculation
      await _updateAnalytics(currentWorkout);
    }
  }

  /// Clear analytics when workout ends
  void _clearAnalytics() {
    _stopPeriodicUpdates();
    state = WorkoutAnalyticsState(lastUpdated: DateTime.now());
    _lastMetrics = null;
  }

  /// Start periodic updates for active workouts
  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final currentWorkout = ref.read(currentWorkoutProvider);
      if (currentWorkout?.isActive == true) {
        _updateAnalytics(currentWorkout!);
      }
    });
  }

  /// Stop periodic updates
  void _stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Check if comparison should be updated (to avoid excessive API calls)
  bool _shouldUpdateComparison() {
    final lastUpdate = state.lastUpdated;
    final now = DateTime.now();
    return now.difference(lastUpdate).inMinutes >=
        5; // Update every 5 minutes max
  }
}

// =============================================================================
// SPECIFIC ANALYTICS PROVIDERS
// =============================================================================

/// Current workout volume (optimized selector)
final currentWorkoutVolumeProvider = Provider<double>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select(
      (state) => state.currentMetrics?.totalVolume ?? 0,
    ),
  );
});

/// Current workout completion percentage
final workoutCompletionProvider = Provider<double>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select(
      (state) => state.currentMetrics?.completionPercentage ?? 0,
    ),
  );
});

/// Current workout quality score
final workoutQualityProvider = Provider<double>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select(
      (state) => state.currentMetrics?.qualityScore ?? 0,
    ),
  );
});

/// Current PRs achieved
final currentPRsProvider = Provider<List<PersonalRecordAchieved>>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select((state) => state.currentPRs),
  );
});

/// Workout comparison data
final workoutComparisonProvider = Provider<WorkoutComparison?>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select((state) => state.comparison),
  );
});

/// PR predictions for current workout
final prPredictionsProvider = Provider<List<PRPrediction>>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select((state) => state.prPredictions),
  );
});

// =============================================================================
// HISTORICAL ANALYTICS PROVIDERS
// =============================================================================

/// Historical workout statistics
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final workoutStatsProvider = FutureProvider.autoDispose<WorkoutAnalyticsStats>((
  ref,
) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) throw Exception('User not authenticated');

  final repository = ref.watch(workoutAnalyticsRepositoryProvider);
  return await repository.getAnalyticsStats(userId);
});

/// Recent PRs (last 30 days)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final recentPRsProvider = FutureProvider.autoDispose<List<PersonalRecord>>((
  ref,
) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final prTracker = PRTracker();
  return await prTracker.getRecentPRs(userId);
});

/// Workout analytics stream for real-time updates
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final workoutAnalyticsStreamProvider = StreamProvider.autoDispose
    .family<WorkoutAnalyticsUpdate, String>((ref, workoutId) {
      final repository = ref.watch(workoutAnalyticsRepositoryProvider);
      return repository.watchWorkoutUpdates(workoutId);
    });

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

/// Check if analytics are loading
final analyticsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select((state) => state.isCalculating),
  );
});

/// Get analytics error message
final analyticsErrorProvider = Provider<String?>((ref) {
  return ref.watch(workoutAnalyticsProvider.select((state) => state.error));
});

/// Check if workout shows improvement over previous
final workoutImprovementProvider = Provider<bool>((ref) {
  return ref.watch(
    workoutAnalyticsProvider.select((state) => state.showsImprovement),
  );
});

/// Get formatted workout summary for sharing
final workoutSummaryProvider = Provider<String>((ref) {
  final metrics = ref.watch(
    workoutAnalyticsProvider.select((state) => state.currentMetrics),
  );

  if (metrics == null) return '';

  return '''
Workout Summary:
• Volume: ${metrics.formattedVolume}
• Duration: ${metrics.formattedDuration}
• Density: ${metrics.formattedDensity}
• Quality Score: ${metrics.qualityScore.toStringAsFixed(0)}/100
''';
});
