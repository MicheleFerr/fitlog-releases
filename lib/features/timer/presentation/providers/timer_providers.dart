/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: timer
/// 🔧 Type: provider stubs
///
/// Stub providers for timer-related functionality
/// TODO: Implement full functionality
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// LIVE ACTIVITY PROVIDERS
// ============================================================================

/// Provider for live activity service (stub)
final liveActivityProvider = Provider<LiveActivityService>((ref) {
  throw UnimplementedError('LiveActivityService not yet implemented');
});

/// Stub service class
class LiveActivityService {
  Future<void> confirmRPEAndCompleteSet({
    required String activityId,
    required int actualReps,
    required int rpe,
    String? notes,
  }) async {
    // TODO: Implement live activity RPE confirmation
  }

  Future<String?> showRPEInterface({
    required String exerciseName,
    required int targetReps,
    required double weight,
    required int currentSet,
    required int totalSets,
    required String workoutName,
  }) async {
    // TODO: Implement live activity RPE interface
    return 'test_activity_id';
  }

  void setupRPECallbacks({
    required Function(int actualReps, int rpe, String? notes) onRPEConfirmed,
    required Function() onRPECancelled,
    required Function(int newReps) onRepsModified,
  }) {
    // TODO: Implement RPE callbacks
  }
}

// ============================================================================
// SET TRACKING PROVIDERS
// ============================================================================

/// Provider for tracking if a set is currently active
final isTrackingSetProvider = StateProvider<bool>((ref) => false);

/// Provider for current set metrics
final currentSetMetricsProvider = StateProvider<SetMetrics?>((ref) => null);

/// Provider for coaching when to stop the set
final shouldStopSetProvider = StateProvider<bool>((ref) => false);

/// Provider for current coaching tip
final currentCoachingTipProvider = StateProvider<String?>((ref) => null);

/// Provider for set fatigue index
final setFatigueIndexProvider = StateProvider<double>((ref) => 0.0);

/// Provider for set velocity drop percentage
final setVelocityDropProvider = StateProvider<double>((ref) => 0.0);

/// Provider for tier-1 set tracking state
final tier1SetTrackingProvider = NotifierProvider<Tier1SetTrackingNotifier, Tier1SetTrackingState>(Tier1SetTrackingNotifier.new);

// ============================================================================
// MODELS
// ============================================================================

/// Metrics for a single set being tracked
class SetMetrics {

  const SetMetrics({
    required this.repCount,
    required this.velocity,
    required this.fatigue,
    required this.startTime,
  });
  final int repCount;
  final double velocity;
  final double fatigue;
  final DateTime startTime;

  // TODO: Add proper implementation for these getters
  String get phase => 'active'; // Placeholder
  int get currentRep => repCount;
  int get elapsedMs => DateTime.now().difference(startTime).inMilliseconds;
  double get currentVelocityMps => velocity;
  double get averageVelocityMps => velocity;
  double get velocityDropPercent => 0.0;
}

/// State for tier-1 set tracking
class Tier1SetTrackingState {

  const Tier1SetTrackingState({
    this.isTracking = false,
    this.metrics,
    this.coachingTip,
  });
  final bool isTracking;
  final SetMetrics? metrics;
  final String? coachingTip;

  Tier1SetTrackingState copyWith({
    bool? isTracking,
    SetMetrics? metrics,
    String? coachingTip,
  }) {
    return Tier1SetTrackingState(
      isTracking: isTracking ?? this.isTracking,
      metrics: metrics ?? this.metrics,
      coachingTip: coachingTip ?? this.coachingTip,
    );
  }
}

/// Notifier for tier-1 set tracking
class Tier1SetTrackingNotifier extends Notifier<Tier1SetTrackingState> {
  @override
  Tier1SetTrackingState build() => const Tier1SetTrackingState();

  void startTracking() {
    state = state.copyWith(
      isTracking: true,
      metrics: SetMetrics(
        repCount: 0,
        velocity: 0.0,
        fatigue: 0.0,
        startTime: DateTime.now(),
      ),
    );
  }

  void stopTracking() {
    state = const Tier1SetTrackingState();
  }

  void updateMetrics(SetMetrics metrics) {
    state = state.copyWith(metrics: metrics);
  }
}
