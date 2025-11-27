import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_execution_timing.freezed.dart';
part 'set_execution_timing.g.dart';

/// TIER-1 Set Execution Timing Entity
/// Tracks precise timing data for individual sets with millisecond accuracy
@freezed
abstract class SetExecutionTiming with _$SetExecutionTiming {
  const factory SetExecutionTiming({
    required String id,
    required String exerciseId,
    required String workoutId,
    required int setNumber,
    
    // Timing precision data (milliseconds)
    required int executionTimeMs,
    required DateTime startTime,
    required DateTime endTime,
    
    // Performance metrics
    @Default(0) int reps,
    double? weight,
    @Default(0) int rpe, // Rate of Perceived Exertion
    
    // Advanced timing analysis
    @Default([]) List<int> repTimingsMs, // Individual rep timings
    @Default([]) List<double> velocityMps, // Velocity per rep (m/s)
    @Default([]) List<int> pauseTimingsMs, // Pauses between reps
    
    // Quality indicators
    @Default(0.0) double formScore, // 0-100 based on video analysis
    @Default(0.0) double consistencyScore, // 0-100 based on rep variation
    @Default(0.0) double fatigueIndex, // 0-100 calculated fatigue
    
    // Environmental data
    DateTime? restStartedAt,
    int? restDurationMs,
    @Default(0.0) double heartRateBpm,
    @Default(0.0) double ambientTemperatureC,
    
    // Synchronization
    required DateTime createdAt,
    DateTime? uploadedAt,
    @Default(false) bool synced,
    
    // Metadata
    Map<String, dynamic>? metadata,
  }) = _SetExecutionTiming;
  
  factory SetExecutionTiming.fromJson(Map<String, dynamic> json) =>
      _$SetExecutionTimingFromJson(json);
}

/// Set Timing Configuration for different training types
@freezed
abstract class SetTimingConfig with _$SetTimingConfig {
  const factory SetTimingConfig({
    required TimingMode mode,
    
    // Precision settings
    @Default(10) int samplingRateHz,
    @Default(true) bool trackVelocity,
    @Default(true) bool trackPauses,
    @Default(false) bool trackHeartRate,
    
    // Analysis thresholds
    @Default(2000) int maxSetDurationMs,
    @Default(100) int minRepDurationMs,
    @Default(5000) int maxRepDurationMs,
    
    // Quality thresholds
    @Default(20.0) double maxVelocityVariationPercent,
    @Default(1000) int maxPauseBetweenRepsMs,
    
    // Auto-detection settings
    @Default(true) bool autoStartDetection,
    @Default(true) bool autoEndDetection,
    @Default(500) int motionThresholdMs,
  }) = _$$SetTimingConfigImpl;

  factory SetTimingConfig.fromJson(Map<String, dynamic> json) =>
      _$SetTimingConfigFromJson(json);
}

/// Timing modes for different exercise types
enum TimingMode {
  precision,    // Maximum accuracy, all sensors
  performance,  // Focus on velocity/power metrics
  endurance,    // Focus on consistency/fatigue
  rehabilitation, // Focus on form/control
}

/// Set execution phases for detailed tracking
enum SetPhase {
  preparation,  // Getting into position
  execution,    // Performing reps
  completion,   // Set finished
  rest,         // Rest period
}

/// Real-time set metrics for live feedback
@freezed
abstract class LiveSetMetrics with _$LiveSetMetrics {
  const factory LiveSetMetrics({
    required String setId,
    required SetPhase phase,
    
    // Current timing
    required int elapsedMs,
    required int currentRep,
    
    // Live velocity data
    @Default(0.0) double currentVelocityMps,
    @Default(0.0) double averageVelocityMps,
    @Default(0.0) double velocityDropPercent,
    
    // Form feedback
    @Default(0.0) double currentFormScore,
    @Default(0.0) double consistencyScore,
    
    // Fatigue indicators
    @Default(0.0) double fatigueIndex,
    @Default(false) bool shouldStopSet,
    
    // Recommendations
    String? coachingTip,
    double? suggestedWeight,
    int? suggestedReps,

    required DateTime timestamp,
  }) = _$$LiveSetMetricsImpl;

  factory LiveSetMetrics.fromJson(Map<String, dynamic> json) =>
      _$LiveSetMetricsFromJson(json);
}