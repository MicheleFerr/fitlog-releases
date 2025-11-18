import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/home_state.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/performance_logger.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

class HomeStateNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  final PerformanceLogger _logger;
  Timer? _refreshTimer;

  HomeStateNotifier({
    required Ref ref,
    required PerformanceLogger logger,
  })  : _ref = ref,
        _logger = logger,
        super(HomeState(
          greeting: '',
          workoutSection: WorkoutSection.empty(),
          aiCoachSection: AICoachSection.empty(),
          streakSection: StreakSection.empty(),
        ));

  Future<void> loadInitialData() async {
    state = state.copyWith(loadingPhase: LoadingPhase.loadingCritical);

    // Phase 1: Critical data (must show immediately)
    await _loadCriticalData();

    // Phase 2: Secondary data (nice to have quickly)
    await _loadSecondaryData();

    // Phase 3: Optional data (can load in background)
    _loadOptionalData(); // Fire and forget

    state = state.copyWith(loadingPhase: LoadingPhase.complete);
  }

  Future<void> _loadCriticalData() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Load greeting and active workout in parallel
      final results = await Future.wait([
        _loadGreeting(),
        _loadWorkoutBanner(),
      ]);

      state = state.copyWith(
        greeting: results[0] as String,
        workoutSection: results[1] as WorkoutSection,
        loadingPhase: LoadingPhase.loadingSecondary,
        sectionLoadTimes: {
          ...state.sectionLoadTimes,
          'critical': stopwatch.elapsed,
        },
      );

      _logger.logDataFetch('critical_data', stopwatch.elapsed, 100);
    } catch (e) {
      _handleError(e, 'critical');
    }
  }

  Future<void> _loadSecondaryData() async {
    final stopwatch = Stopwatch()..start();

    try {
      final results = await Future.wait([
        _loadAICoach(),
        _loadStreak(),
      ]);

      state = state.copyWith(
        aiCoachSection: results[0] as AICoachSection,
        streakSection: results[1] as StreakSection,
        loadingPhase: LoadingPhase.loadingOptional,
        sectionLoadTimes: {
          ...state.sectionLoadTimes,
          'secondary': stopwatch.elapsed,
        },
      );

      _logger.logDataFetch('secondary_data', stopwatch.elapsed, 150);
    } catch (e) {
      _handleError(e, 'secondary');
    }
  }

  void _loadOptionalData() {
    // Optional data loads in background
    // This would include things like recommendations, tips, etc.
    // For now, we just mark as complete
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        state = state.copyWith(
          loadingPhase: LoadingPhase.complete,
          lastRefresh: DateTime.now(),
        );
      }
    });
  }

  Future<String> _loadGreeting() async {
    final userAsync = _ref.read(currentUserProvider);
    final user = userAsync.value;
    final hour = DateTime.now().hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return '$greeting, ${user.displayName}';
    }
    return greeting;
  }

  Future<WorkoutSection> _loadWorkoutBanner() async {
    final workout = _ref.read(currentWorkoutProvider);

    if (workout == null) {
      return WorkoutSection.empty();
    }

    // Calculate progress
    final totalExercises = workout.exercises.length;
    final completedExercises = workout.exercises.where((e) => e.isCompleted).length;
    final progress = totalExercises > 0 ? completedExercises / totalExercises : 0.0;

    return WorkoutSection(
      hasActiveWorkout: true,
      workoutName: workout.name,
      progress: progress,
      exercisesCompleted: completedExercises,
      totalExercises: totalExercises,
    );
  }

  Future<AICoachSection> _loadAICoach() async {
    // Simulate AI coach data loading
    await Future.delayed(const Duration(milliseconds: 100));

    return const AICoachSection(
      message: 'Ready to crush your workout?',
      suggestion: 'Try increasing your bench press by 5lbs today',
    );
  }

  Future<StreakSection> _loadStreak() async {
    // Simulate streak data loading
    await Future.delayed(const Duration(milliseconds: 100));

    return const StreakSection(
      currentStreak: 7,
      bestStreak: 14,
      lastWorkoutDate: null,
    );
  }

  void _handleError(Object error, String section) {
    state = state.copyWith(
      hasError: true,
      errorMessage: 'Failed to load $section: $error',
      loadingPhase: LoadingPhase.error,
    );

    _logger.logDataFetch('${section}_error', Duration.zero, 0);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
