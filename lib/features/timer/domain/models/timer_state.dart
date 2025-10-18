/// Simple timer state model for audio module compatibility
/// Acts as an adapter between RestTimer and TimerAudioModule
class TimerState {

  const TimerState({
    required this.remainingSeconds,
    required this.totalDurationSeconds,
    required this.isRunning,
    required this.isPaused,
    this.exerciseName,
    this.currentSet,
    this.totalSets,
    this.workoutId,
    this.startTime,
  });
  final int remainingSeconds;
  final int totalDurationSeconds;
  final bool isRunning;
  final bool isPaused;
  final String? exerciseName;
  final int? currentSet;
  final int? totalSets;
  final String? workoutId;
  final DateTime? startTime;

  TimerState copyWith({
    int? remainingSeconds,
    int? totalDurationSeconds,
    bool? isRunning,
    bool? isPaused,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    String? workoutId,
    DateTime? startTime,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      exerciseName: exerciseName ?? this.exerciseName,
      currentSet: currentSet ?? this.currentSet,
      totalSets: totalSets ?? this.totalSets,
      workoutId: workoutId ?? this.workoutId,
      startTime: startTime ?? this.startTime,
    );
  }
}