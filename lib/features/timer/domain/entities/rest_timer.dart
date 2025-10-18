import 'package:uuid/uuid.dart';

enum TimerStatus {
  idle,
  running,
  paused,
  completed,
  awaitingRPE, // ✅ Nuovo stato per RPE
}

enum TimerType {
  rest,
  workout,
  warmup,
  cooldown,
}

class RestTimer {  // When the timer completed

  RestTimer({
    String? id,
    this.type = TimerType.rest,
    required this.totalDurationSeconds,
    int? remainingSeconds,
    this.status = TimerStatus.idle,
    this.startTime,
    this.endTime,
    this.exerciseName,
    this.currentSet,
    this.totalSets,
    this.workoutId,
    this.audioAlreadyPlayed = false,
    this.completionTime,
  }) : 
    id = id ?? const Uuid().v4(),
    remainingSeconds = remainingSeconds ?? totalDurationSeconds;

  factory RestTimer.fromJson(Map<String, dynamic> json) {
    return RestTimer(
      id: json['id'],
      type: TimerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TimerType.rest,
      ),
      totalDurationSeconds: json['totalDurationSeconds'],
      remainingSeconds: json['remainingSeconds'],
      status: TimerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TimerStatus.idle,
      ),
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : null,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : null,
      exerciseName: json['exerciseName'],
      currentSet: json['currentSet'],
      totalSets: json['totalSets'],
      workoutId: json['workoutId'],
      audioAlreadyPlayed: json['audioAlreadyPlayed'] ?? false,
      completionTime: json['completionTime'] != null
          ? DateTime.parse(json['completionTime'])
          : null,
    );
  }
  final String id;
  final TimerType type;
  final int totalDurationSeconds;
  final int remainingSeconds;
  final TimerStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? exerciseName;
  final int? currentSet;
  final int? totalSets;
  final String? workoutId;
  final bool audioAlreadyPlayed;  // Flag to track if audio was already played
  final DateTime? completionTime;

  /// Progress from 0.0 to 1.0
  double get progress {
    if (totalDurationSeconds == 0) return 1.0;
    return (totalDurationSeconds - remainingSeconds) / totalDurationSeconds;
  }

  /// Elapsed time in seconds
  int get elapsedSeconds => totalDurationSeconds - remainingSeconds;

  /// Duration elapsed as Duration object
  Duration get elapsedDuration => Duration(seconds: elapsedSeconds);

  /// Remaining time as Duration object
  Duration get remainingDuration => Duration(seconds: remainingSeconds);

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if timer is active (running or paused)
  bool get isActive => status == TimerStatus.running || status == TimerStatus.paused;

  /// Check if timer is complete
  bool get isCompleted => status == TimerStatus.completed || remainingSeconds <= 0;

  /// Check if timer is running
  bool get isRunning => status == TimerStatus.running;

  /// Check if timer is paused
  bool get isPaused => status == TimerStatus.paused;

  /// Check if timer is awaiting RPE input
  bool get isAwaitingRPE => status == TimerStatus.awaitingRPE;

  RestTimer copyWith({
    TimerType? type,
    int? totalDurationSeconds,
    int? remainingSeconds,
    TimerStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    String? workoutId,
    bool? audioAlreadyPlayed,
    DateTime? completionTime,
  }) {
    return RestTimer(
      id: id,
      type: type ?? this.type,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseName: exerciseName ?? this.exerciseName,
      currentSet: currentSet ?? this.currentSet,
      totalSets: totalSets ?? this.totalSets,
      workoutId: workoutId ?? this.workoutId,
      audioAlreadyPlayed: audioAlreadyPlayed ?? this.audioAlreadyPlayed,
      completionTime: completionTime ?? this.completionTime,
    );
  }

  /// Start the timer
  RestTimer start() {
    return copyWith(
      status: TimerStatus.running,
      startTime: DateTime.now(),
    );
  }

  /// Pause the timer
  RestTimer pause() {
    return copyWith(
      status: TimerStatus.paused,
    );
  }

  /// Resume the timer
  RestTimer resume() {
    return copyWith(
      status: TimerStatus.running,
    );
  }

  /// Complete the timer
  RestTimer complete() {
    final now = DateTime.now();
    return copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      endTime: now,
      completionTime: now,  // Track when timer completed
      audioAlreadyPlayed: false,  // Will be set to true after audio plays
    );
  }

  /// Transition to RPE mode (waiting for user input)
  RestTimer awaitRPE() {
    return copyWith(
      status: TimerStatus.awaitingRPE,
      remainingSeconds: 0,
      endTime: DateTime.now(),
    );
  }

  /// Reset the timer
  RestTimer reset() {
    return copyWith(
      status: TimerStatus.idle,
      remainingSeconds: totalDurationSeconds,
      startTime: null,
      endTime: null,
    );
  }

  /// Tick the timer (reduce by 1 second)
  RestTimer tick() {
    if (remainingSeconds <= 1) {
      return complete();
    }
    return copyWith(remainingSeconds: remainingSeconds - 1);
  }

  /// Add time to the timer
  RestTimer addTime(int seconds) {
    return copyWith(
      remainingSeconds: remainingSeconds + seconds,
      totalDurationSeconds: totalDurationSeconds + seconds,
    );
  }

  /// Skip timer (complete immediately)
  RestTimer skip() {
    return complete();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'totalDurationSeconds': totalDurationSeconds,
      'remainingSeconds': remainingSeconds,
      'status': status.name,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exerciseName': exerciseName,
      'currentSet': currentSet,
      'totalSets': totalSets,
      'workoutId': workoutId,
      'audioAlreadyPlayed': audioAlreadyPlayed,
      'completionTime': completionTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RestTimer(type: $type, remaining: $formattedTime, status: $status, exercise: $exerciseName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestTimer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Factory methods for common timer configurations
extension RestTimerFactory on RestTimer {
  /// Create a strength training rest timer (3-5 minutes)
  static RestTimer strength({
    required String exerciseName,
    int currentSet = 1,
    int totalSets = 4,
    int durationMinutes = 3,
    String? workoutId,
  }) {
    return RestTimer(
      type: TimerType.rest,
      totalDurationSeconds: durationMinutes * 60,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
    );
  }

  /// Create a hypertrophy rest timer (1-2 minutes)
  static RestTimer hypertrophy({
    required String exerciseName,
    int currentSet = 1,
    int totalSets = 4,
    int durationMinutes = 2,
    String? workoutId,
  }) {
    return RestTimer(
      type: TimerType.rest,
      totalDurationSeconds: durationMinutes * 60,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
    );
  }

  /// Create a endurance rest timer (30-60 seconds)
  static RestTimer endurance({
    required String exerciseName,
    int currentSet = 1,
    int totalSets = 4,
    int durationSeconds = 60,
    String? workoutId,
  }) {
    return RestTimer(
      type: TimerType.rest,
      totalDurationSeconds: durationSeconds,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
    );
  }

  /// Create a superset rest timer (30-45 seconds)
  static RestTimer superset({
    required String exerciseName,
    int currentSet = 1,
    int totalSets = 3,
    int durationSeconds = 45,
    String? workoutId,
  }) {
    return RestTimer(
      type: TimerType.rest,
      totalDurationSeconds: durationSeconds,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
    );
  }

  /// Create a custom timer with specific duration
  static RestTimer custom({
    required String exerciseName,
    required int durationSeconds,
    int currentSet = 1,
    int totalSets = 4,
    TimerType type = TimerType.rest,
    String? workoutId,
  }) {
    return RestTimer(
      type: type,
      totalDurationSeconds: durationSeconds,
      exerciseName: exerciseName,
      currentSet: currentSet,
      totalSets: totalSets,
      workoutId: workoutId,
    );
  }
}