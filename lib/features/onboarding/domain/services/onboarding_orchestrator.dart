/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/onboarding/domain/services
/// Feature: Onboarding Orchestrator
/// Type: Service
///
/// Central manager for all onboarding tours.
/// Ensures only one tour runs at a time and manages priority.
///
/// Best Practices 2025:
/// - Progressive disclosure: show features when needed
/// - Just-in-time learning: contextual tutorials
/// - One action per screen: reduce cognitive load
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Priority levels for tours
enum TourPriority {
  /// P0 - Critical: blocks core functionality if not understood
  critical,

  /// P1 - Important: core features users need
  important,

  /// P2 - Useful: enhances experience
  useful,

  /// P3 - Optional: power user features
  optional,
}

/// Available tour types in the app
enum TourType {
  homeTour,
  workoutTutorial,
  exerciseSearchTutorial,
  analyticsTour,
  timerTour,
  templateTutorial,
  advancedTechniquesTutorial,
  healthIntegrationTour,
  customExerciseTutorial,
}

/// Learning phases for progressive disclosure (P0-4 fix)
enum LearningPhase {
  /// Day 0: Core fundamentals only (≤5 steps total)
  core,

  /// Day 1-3: Essential features as discovered
  discovery,

  /// Day 4+: Advanced features based on usage
  advanced,

  /// Power user: All features unlocked
  expert,
}

/// Configuration for each tour type
class TourConfig {
  const TourConfig({
    required this.type,
    required this.priority,
    required this.prefsKey,
    this.minWorkoutsRequired = 0,
    this.requiresData = false,
    this.phase = LearningPhase.discovery,
    this.stepCount = 5,
    this.cooldownMinutes = 30,
  });

  final TourType type;
  final TourPriority priority;
  final String prefsKey;
  final int minWorkoutsRequired;
  final bool requiresData;

  /// P0-4: Phase when this tour becomes available
  final LearningPhase phase;

  /// P0-4: Number of steps in this tour (for session limiting)
  final int stepCount;

  /// P0-4: Minimum minutes between tours of same priority
  final int cooldownMinutes;

  /// P0-4: Tour configs with phase-based progressive disclosure
  /// - Core phase (Day 0): Only essential tutorials, max 10 steps total
  /// - Discovery phase (Day 1-3): Features as user discovers them
  /// - Advanced phase (Day 4+): Power user features
  static const Map<TourType, TourConfig> configs = {
    // CORE PHASE: Day 0 essentials (max 10 steps combined)
    TourType.homeTour: TourConfig(
      type: TourType.homeTour,
      priority: TourPriority.important,
      prefsKey: 'home_tour_completed',
      phase: LearningPhase.core,
      stepCount: 5, // Reduced from 10 (P0-1)
      cooldownMinutes: 0, // Show immediately
    ),
    TourType.workoutTutorial: TourConfig(
      type: TourType.workoutTutorial,
      priority: TourPriority.critical,
      prefsKey: 'workout_tutorial_completed',
      phase: LearningPhase.core,
      stepCount: 5, // Core workout steps only
      cooldownMinutes: 0,
    ),

    // DISCOVERY PHASE: Day 1-3 (show as user discovers features)
    TourType.exerciseSearchTutorial: TourConfig(
      type: TourType.exerciseSearchTutorial,
      priority: TourPriority.important,
      prefsKey: 'exercise_search_tutorial_completed',
      phase: LearningPhase.discovery,
      stepCount: 4,
      cooldownMinutes: 30, // Wait 30min between tours
    ),
    TourType.timerTour: TourConfig(
      type: TourType.timerTour,
      priority: TourPriority.useful,
      prefsKey: 'timer_tour_completed',
      phase: LearningPhase.discovery,
      stepCount: 3,
      cooldownMinutes: 60,
    ),
    TourType.templateTutorial: TourConfig(
      type: TourType.templateTutorial,
      priority: TourPriority.useful,
      prefsKey: 'template_tutorial_completed',
      phase: LearningPhase.discovery,
      stepCount: 4,
      cooldownMinutes: 60,
    ),

    // ADVANCED PHASE: Day 4+ (after user has experience)
    TourType.analyticsTour: TourConfig(
      type: TourType.analyticsTour,
      priority: TourPriority.useful,
      prefsKey: 'analytics_tour_completed',
      phase: LearningPhase.advanced,
      minWorkoutsRequired: 3,
      requiresData: true,
      stepCount: 5,
      cooldownMinutes: 120,
    ),
    TourType.advancedTechniquesTutorial: TourConfig(
      type: TourType.advancedTechniquesTutorial,
      priority: TourPriority.optional,
      prefsKey: 'advanced_techniques_tutorial_completed',
      phase: LearningPhase.advanced,
      minWorkoutsRequired: 5,
      stepCount: 6,
      cooldownMinutes: 180,
    ),

    // CORE PHASE: HealthKit after first workout (P1-2 fix)
    TourType.healthIntegrationTour: TourConfig(
      type: TourType.healthIntegrationTour,
      priority: TourPriority.high,
      prefsKey: 'health_integration_tour_completed',
      phase: LearningPhase.core,
      minWorkoutsRequired: 1,  // Shows after first workout
      stepCount: 1,  // Single prompt dialog
      cooldownMinutes: 0,  // No cooldown - show immediately
    ),
    TourType.customExerciseTutorial: TourConfig(
      type: TourType.customExerciseTutorial,
      priority: TourPriority.optional,
      prefsKey: 'custom_exercise_tutorial_completed',
      phase: LearningPhase.expert,
      stepCount: 5,
      cooldownMinutes: 240,
    ),
  };
}

/// State for the onboarding orchestrator
class OnboardingOrchestratorState {
  const OnboardingOrchestratorState({
    required this.completedTours,
    required this.activeTour,
    required this.queuedTours,
    required this.isFirstLaunch,
    required this.totalWorkouts,
    this.currentPhase = LearningPhase.core,
    this.sessionStepsShown = 0,
    this.lastTourCompletionTime,
    this.firstLaunchDate,
  });

  /// Set of completed tour types
  final Set<TourType> completedTours;

  /// Currently active tour (null if none)
  final TourType? activeTour;

  /// Queue of tours waiting to be shown
  final List<TourType> queuedTours;

  /// Whether this is user's first app launch
  final bool isFirstLaunch;

  /// Total workouts completed (for conditional tours)
  final int totalWorkouts;

  /// P0-4: Current learning phase based on time since first launch
  final LearningPhase currentPhase;

  /// P0-4: Steps shown in current session (max 10 per session)
  final int sessionStepsShown;

  /// P0-4: Last tour completion timestamp (for cooldown)
  final DateTime? lastTourCompletionTime;

  /// P0-4: Date of first app launch (for phase calculation)
  final DateTime? firstLaunchDate;

  /// P0-4: Maximum steps allowed per session to prevent cognitive overload
  static const int maxStepsPerSession = 10;

  bool get hasActiveTour => activeTour != null;

  bool isTourCompleted(TourType type) => completedTours.contains(type);

  /// P0-4: Check if session step limit has been reached
  bool get hasReachedSessionLimit => sessionStepsShown >= maxStepsPerSession;

  /// P0-4: Calculate current learning phase based on days since first launch
  LearningPhase calculateCurrentPhase() {
    if (firstLaunchDate == null) return LearningPhase.core;

    final daysSinceFirstLaunch =
        DateTime.now().difference(firstLaunchDate!).inDays;

    if (daysSinceFirstLaunch == 0) return LearningPhase.core;
    if (daysSinceFirstLaunch <= 3) return LearningPhase.discovery;
    if (daysSinceFirstLaunch <= 7) return LearningPhase.advanced;
    return LearningPhase.expert;
  }

  bool canShowTour(TourType type) {
    if (isTourCompleted(type)) return false;
    if (hasActiveTour) return false;

    final config = TourConfig.configs[type];
    if (config == null) return false;

    // Check minimum workouts requirement
    if (config.minWorkoutsRequired > 0 &&
        totalWorkouts < config.minWorkoutsRequired) {
      return false;
    }

    // P0-4: Check learning phase requirement
    final requiredPhase = config.phase;
    final actualPhase = calculateCurrentPhase();
    if (requiredPhase.index > actualPhase.index) {
      return false; // Tour not unlocked yet
    }

    // P0-4: Check session step limit
    if (hasReachedSessionLimit) {
      return false;
    }

    // P0-4: Check cooldown (except for core tours)
    if (config.cooldownMinutes > 0 && lastTourCompletionTime != null) {
      final minutesSinceLastTour =
          DateTime.now().difference(lastTourCompletionTime!).inMinutes;
      if (minutesSinceLastTour < config.cooldownMinutes) {
        return false;
      }
    }

    return true;
  }

  OnboardingOrchestratorState copyWith({
    Set<TourType>? completedTours,
    TourType? activeTour,
    bool clearActiveTour = false,
    List<TourType>? queuedTours,
    bool? isFirstLaunch,
    int? totalWorkouts,
    LearningPhase? currentPhase,
    int? sessionStepsShown,
    DateTime? lastTourCompletionTime,
    bool clearLastTourTime = false,
    DateTime? firstLaunchDate,
  }) {
    return OnboardingOrchestratorState(
      completedTours: completedTours ?? this.completedTours,
      activeTour: clearActiveTour ? null : (activeTour ?? this.activeTour),
      queuedTours: queuedTours ?? this.queuedTours,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      currentPhase: currentPhase ?? this.currentPhase,
      sessionStepsShown: sessionStepsShown ?? this.sessionStepsShown,
      lastTourCompletionTime: clearLastTourTime
          ? null
          : (lastTourCompletionTime ?? this.lastTourCompletionTime),
      firstLaunchDate: firstLaunchDate ?? this.firstLaunchDate,
    );
  }
}

/// Central orchestrator for all onboarding tours
class OnboardingOrchestrator
    extends StateNotifier<OnboardingOrchestratorState> {
  OnboardingOrchestrator()
      : super(const OnboardingOrchestratorState(
          completedTours: {},
          activeTour: null,
          queuedTours: [],
          isFirstLaunch: true,
          totalWorkouts: 0,
        )) {
    _loadState();
  }

  static const String _firstLaunchKey = 'onboarding_first_launch';
  static const String _workoutCountKey = 'onboarding_workout_count';
  static const String _firstLaunchDateKey = 'onboarding_first_launch_date';

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load first launch status
      final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

      // Load workout count
      final workoutCount = prefs.getInt(_workoutCountKey) ?? 0;

      // P0-4: Load first launch date for phase calculation
      DateTime? firstLaunchDate;
      final firstLaunchDateStr = prefs.getString(_firstLaunchDateKey);
      if (firstLaunchDateStr != null) {
        firstLaunchDate = DateTime.tryParse(firstLaunchDateStr);
      }

      // Load completion status for each tour
      final completedTours = <TourType>{};
      for (final config in TourConfig.configs.values) {
        if (prefs.getBool(config.prefsKey) ?? false) {
          completedTours.add(config.type);
        }
      }

      state = state.copyWith(
        isFirstLaunch: isFirstLaunch,
        totalWorkouts: workoutCount,
        completedTours: completedTours,
        firstLaunchDate: firstLaunchDate,
      );

      // Mark as not first launch for next time
      if (isFirstLaunch) {
        await prefs.setBool(_firstLaunchKey, false);
        // P0-4: Save first launch date for phase calculation
        final now = DateTime.now();
        await prefs.setString(_firstLaunchDateKey, now.toIso8601String());
        state = state.copyWith(firstLaunchDate: now);
      }

      debugPrint('📊 [OnboardingOrchestrator] Current phase: ${state.calculateCurrentPhase()}');
    } catch (e) {
      debugPrint('⚠️ [OnboardingOrchestrator] Failed to load state: $e');
    }
  }

  /// Update workout count (call when workout completes)
  Future<void> incrementWorkoutCount() async {
    final newCount = state.totalWorkouts + 1;
    state = state.copyWith(totalWorkouts: newCount);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_workoutCountKey, newCount);
    } catch (e) {
      debugPrint('⚠️ [OnboardingOrchestrator] Failed to save workout count: $e');
    }
  }

  /// Request to start a tour
  /// Returns true if tour can start, false if blocked
  bool requestTour(TourType type) {
    if (!state.canShowTour(type)) {
      debugPrint('ℹ️ [OnboardingOrchestrator] Tour $type blocked');
      return false;
    }

    // Check priority - higher priority tours can interrupt queue
    if (state.hasActiveTour) {
      final activeConfig = TourConfig.configs[state.activeTour];
      final requestedConfig = TourConfig.configs[type];

      if (activeConfig != null &&
          requestedConfig != null &&
          requestedConfig.priority.index < activeConfig.priority.index) {
        // Higher priority - queue the active one and show this
        _queueTour(state.activeTour!);
        state = state.copyWith(activeTour: type);
        return true;
      } else {
        // Lower or equal priority - queue this one
        _queueTour(type);
        return false;
      }
    }

    state = state.copyWith(activeTour: type);
    debugPrint('✅ [OnboardingOrchestrator] Starting tour: $type');
    return true;
  }

  void _queueTour(TourType type) {
    if (!state.queuedTours.contains(type)) {
      final newQueue = [...state.queuedTours, type];
      // Sort by priority
      newQueue.sort((a, b) {
        final configA = TourConfig.configs[a];
        final configB = TourConfig.configs[b];
        return (configA?.priority.index ?? 99)
            .compareTo(configB?.priority.index ?? 99);
      });
      state = state.copyWith(queuedTours: newQueue);
    }
  }

  /// Mark a tour as completed
  Future<void> completeTour(TourType type) async {
    final newCompleted = {...state.completedTours, type};
    final config = TourConfig.configs[type];

    // P0-4: Update session step count
    final tourSteps = config?.stepCount ?? 5;
    final newSessionSteps = state.sessionStepsShown + tourSteps;

    state = state.copyWith(
      completedTours: newCompleted,
      clearActiveTour: state.activeTour == type,
      sessionStepsShown: newSessionSteps,
      lastTourCompletionTime: DateTime.now(),
    );

    // Save to prefs
    try {
      if (config != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(config.prefsKey, true);
      }
    } catch (e) {
      debugPrint('⚠️ [OnboardingOrchestrator] Failed to save completion: $e');
    }

    debugPrint('✅ [OnboardingOrchestrator] Tour completed: $type '
        '(session steps: $newSessionSteps/${OnboardingOrchestratorState.maxStepsPerSession})');

    // Process queue
    _processQueue();
  }

  /// Mark a tour as skipped (treated same as completed)
  Future<void> skipTour(TourType type) async {
    await completeTour(type);
    debugPrint('⏭️ [OnboardingOrchestrator] Tour skipped: $type');
  }

  /// Cancel active tour without completing
  void cancelTour() {
    if (state.activeTour != null) {
      debugPrint('❌ [OnboardingOrchestrator] Tour cancelled: ${state.activeTour}');
      state = state.copyWith(clearActiveTour: true);
    }
  }

  void _processQueue() {
    if (state.queuedTours.isEmpty || state.hasActiveTour) return;

    final nextTour = state.queuedTours.first;
    if (state.canShowTour(nextTour)) {
      final newQueue = state.queuedTours.sublist(1);
      state = state.copyWith(
        activeTour: nextTour,
        queuedTours: newQueue,
      );
      debugPrint('📋 [OnboardingOrchestrator] Processing queue: $nextTour');
    }
  }

  /// P0-4: Reset session step counter (call on app restart or after long pause)
  void resetSessionSteps() {
    state = state.copyWith(sessionStepsShown: 0);
    debugPrint('🔄 [OnboardingOrchestrator] Session steps reset');
  }

  /// Reset all tours (for testing)
  Future<void> resetAllTours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final config in TourConfig.configs.values) {
        await prefs.remove(config.prefsKey);
      }
      await prefs.setBool(_firstLaunchKey, true);
      await prefs.setInt(_workoutCountKey, 0);
      await prefs.remove(_firstLaunchDateKey);
    } catch (e) {
      debugPrint('⚠️ [OnboardingOrchestrator] Failed to reset: $e');
    }

    state = const OnboardingOrchestratorState(
      completedTours: {},
      activeTour: null,
      queuedTours: [],
      isFirstLaunch: true,
      totalWorkouts: 0,
    );

    debugPrint('🔄 [OnboardingOrchestrator] All tours reset');
  }

  /// Check if a specific tour should auto-start
  bool shouldAutoStart(TourType type, {bool hasRequiredData = true}) {
    if (!state.canShowTour(type)) return false;

    final config = TourConfig.configs[type];
    if (config == null) return false;

    // Check data requirement
    if (config.requiresData && !hasRequiredData) return false;

    return true;
  }
}

/// Provider for the onboarding orchestrator
final onboardingOrchestratorProvider =
    StateNotifierProvider<OnboardingOrchestrator, OnboardingOrchestratorState>(
  (ref) => OnboardingOrchestrator(),
);

/// Provider to check if a specific tour should be shown
final shouldShowTourProvider =
    Provider.family<bool, TourType>((ref, tourType) {
  final orchestrator = ref.watch(onboardingOrchestratorProvider);
  return orchestrator.canShowTour(tourType);
});

/// Provider to check if any tour is currently active
final hasActiveTourProvider = Provider<bool>((ref) {
  return ref.watch(onboardingOrchestratorProvider).hasActiveTour;
});

/// Provider for the currently active tour
final activeTourProvider = Provider<TourType?>((ref) {
  return ref.watch(onboardingOrchestratorProvider).activeTour;
});

/// P0-4: Provider for current learning phase
final currentLearningPhaseProvider = Provider<LearningPhase>((ref) {
  return ref.watch(onboardingOrchestratorProvider).calculateCurrentPhase();
});

/// P0-4: Provider to check if session step limit reached
final hasReachedSessionLimitProvider = Provider<bool>((ref) {
  return ref.watch(onboardingOrchestratorProvider).hasReachedSessionLimit;
});
