import 'package:uuid/uuid.dart';

/// Unified timer state model that consolidates all timer functionality
/// This replaces RestTimer and TimerState with a single, clean model
class UnifiedTimerState {
  UnifiedTimerState({
    String? id,
    this.type = TimerType.rest,
    required this.totalDurationSeconds,
    int? remainingSeconds,
    this.status = TimerStatus.idle,
    this.startTime,
    this.endTime,
    this.pausedTime,
    this.completionTime,
    this.exerciseName,
    this.currentSet,
    this.totalSets,
    this.workoutId,
    this.audioEnabled = true,
    this.customSoundName,
    this.notificationScheduled = false,
    this.audioPlayed = false,
    this.skipped = false,
    this.liveActivityActive = false,
    this.liveActivityId,
    DateTime? createdAt,
    this.tickCount = 0,
    List<DateTime>? pauseHistory,
    this.lastBackgroundTime,
    this.secondsAdded = 0, // ✅ Rest Timer Tracking
  }) : id = id ?? const Uuid().v4(),
       remainingSeconds = remainingSeconds ?? totalDurationSeconds,
       createdAt = createdAt ?? DateTime.now(),
       pauseHistory = pauseHistory ?? <DateTime>[];

  factory UnifiedTimerState.fromJson(Map<String, dynamic> json) {
    return UnifiedTimerState(
      id: json['id'] as String,
      type: TimerType.values[json['type'] as int],
      totalDurationSeconds: json['totalDurationSeconds'] as int,
      remainingSeconds: json['remainingSeconds'] as int,
      status: TimerStatus.values[json['status'] as int],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      pausedTime: json['pausedTime'] != null
          ? DateTime.parse(json['pausedTime'] as String)
          : null,
      completionTime: json['completionTime'] != null
          ? DateTime.parse(json['completionTime'] as String)
          : null,
      exerciseName: json['exerciseName'] as String?,
      currentSet: json['currentSet'] as int?,
      totalSets: json['totalSets'] as int?,
      workoutId: json['workoutId'] as String?,
      audioEnabled: json['audioEnabled'] as bool? ?? true,
      customSoundName: json['customSoundName'] as String?,
      notificationScheduled: json['notificationScheduled'] as bool? ?? false,
      audioPlayed: json['audioPlayed'] as bool? ?? false,
      skipped: json['skipped'] as bool? ?? false,
      liveActivityActive: json['liveActivityActive'] as bool? ?? false,
      liveActivityId: json['liveActivityId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tickCount: json['tickCount'] as int? ?? 0,
      pauseHistory:
          (json['pauseHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          <DateTime>[],
      lastBackgroundTime: json['lastBackgroundTime'] != null
          ? DateTime.parse(json['lastBackgroundTime'] as String)
          : null,
      secondsAdded: json['secondsAdded'] as int? ?? 0, // ✅ Rest Timer Tracking
    );
  }
  final String id;
  final TimerType type;
  final int totalDurationSeconds;
  final int remainingSeconds;
  final TimerStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? pausedTime;
  final DateTime? completionTime;

  // Workout context
  final String? exerciseName;
  final int? currentSet;
  final int? totalSets;
  final String? workoutId;

  // Audio/notification state
  final bool audioEnabled;
  final String? customSoundName;
  final bool notificationScheduled;
  final bool audioPlayed;
  final bool skipped; // CRITICAL: Track if timer was manually skipped
  final bool liveActivityActive;
  final String? liveActivityId;

  // Performance tracking
  final DateTime createdAt;
  final int tickCount;
  final List<DateTime> pauseHistory;

  // Background sync state
  final DateTime? lastBackgroundTime;

  // ✅ Rest Timer Tracking
  /// Contatore dei secondi aggiunti durante questo timer (via +30s button)
  /// Reset a 0 quando il timer viene avviato
  final int secondsAdded;

  // Computed properties
  double get progress => totalDurationSeconds > 0
      ? (totalDurationSeconds - remainingSeconds) / totalDurationSeconds
      : 0.0;

  double get remainingProgress =>
      totalDurationSeconds > 0 ? remainingSeconds / totalDurationSeconds : 0.0;

  Duration get elapsed => totalDurationSeconds > remainingSeconds
      ? Duration(seconds: totalDurationSeconds - remainingSeconds)
      : Duration.zero;

  Duration get remaining => Duration(seconds: remainingSeconds);

  bool get isActive => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;

  /// Timer is completed when status is completed OR remaining seconds reached 0
  bool get isCompleted =>
      status == TimerStatus.completed ||
      (status == TimerStatus.running && remainingSeconds <= 0);
  bool get isIdle => status == TimerStatus.idle;

  bool get canStart =>
      status == TimerStatus.idle || status == TimerStatus.paused;
  bool get canPause => status == TimerStatus.running;
  bool get canReset => status != TimerStatus.idle;

  // State transitions with PRECISION TIMING to prevent drift
  UnifiedTimerState start() {
    final now = DateTime.now();
    // CRITICAL FIX: Use precise microsecond-level timing to prevent drift
    final preciseEndTime = _calculatePreciseEndTime(now, remainingSeconds);

    return copyWith(
      status: TimerStatus.running,
      startTime: startTime ?? now,
      pausedTime: null,
      endTime: preciseEndTime,
    );
  }

  /// Calculate precise end time using microsecond precision
  /// This prevents drift caused by system clock adjustments
  static DateTime _calculatePreciseEndTime(
    DateTime startTime,
    int durationSeconds,
  ) {
    // Use microsecond precision to minimize rounding errors
    final preciseStartMicros = startTime.microsecondsSinceEpoch;
    final durationMicros = durationSeconds * Duration.microsecondsPerSecond;
    final endTimeMicros = preciseStartMicros + durationMicros;

    return DateTime.fromMicrosecondsSinceEpoch(endTimeMicros);
  }

  /// Validate timer precision and detect significant drift
  /// Returns corrected remaining time if drift is detected
  int calculatePreciseRemainingTime() {
    if (endTime == null) return remainingSeconds;

    final now = DateTime.now();
    final calculatedRemaining = endTime!.difference(now).inSeconds;

    // Detect significant drift (more than 2 seconds difference)
    final driftSeconds = (calculatedRemaining - remainingSeconds).abs();

    if (driftSeconds > 2) {
      // Significant drift detected - use precise calculation
      return calculatedRemaining > 0 ? calculatedRemaining : 0;
    }

    // Normal case - use stored value
    return remainingSeconds;
  }

  /// Update timer with drift correction
  UnifiedTimerState correctDrift() {
    final correctedTime = calculatePreciseRemainingTime();
    if (correctedTime != remainingSeconds) {
      return copyWith(remainingSeconds: correctedTime);
    }
    return this;
  }

  UnifiedTimerState pause() {
    return copyWith(
      status: TimerStatus.paused,
      pausedTime: DateTime.now(),
      endTime: null,
      pauseHistory: [...pauseHistory, DateTime.now()],
    );
  }

  UnifiedTimerState resume() {
    if (pausedTime == null) return this;

    final now = DateTime.now();
    // CRITICAL FIX: Use precise timing for resume as well
    final preciseEndTime = _calculatePreciseEndTime(now, remainingSeconds);

    return copyWith(
      status: TimerStatus.running,
      pausedTime: null,
      endTime: preciseEndTime,
    );
  }

  UnifiedTimerState tick() {
    if (status != TimerStatus.running) return this;

    final newRemaining = remainingSeconds - 1;

    if (newRemaining <= 0) {
      return copyWith(
        status: TimerStatus.completed,
        remainingSeconds: 0,
        completionTime: DateTime.now(),
        tickCount: tickCount + 1,
      );
    }

    return copyWith(remainingSeconds: newRemaining, tickCount: tickCount + 1);
  }

  UnifiedTimerState reset() {
    return copyWith(
      status: TimerStatus.idle,
      remainingSeconds: totalDurationSeconds,
      startTime: null,
      endTime: null,
      pausedTime: null,
      completionTime: null,
      audioPlayed: false,
      skipped: false,
      notificationScheduled: false,
      liveActivityActive: false,
      liveActivityId: null,
      tickCount: 0,
      pauseHistory: <DateTime>[],
      secondsAdded: 0, // ✅ Reset seconds added
    );
  }

  UnifiedTimerState complete() {
    return copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      completionTime: DateTime.now(),
    );
  }

  /// Skip timer - complete without playing audio
  UnifiedTimerState skip() {
    return copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      completionTime: DateTime.now(),
      skipped: true, // Mark as skipped to prevent audio
      audioPlayed: true, // Also mark audio as played to prevent any playback
    );
  }

  // Audio state management
  UnifiedTimerState markAudioPlayed() {
    return copyWith(audioPlayed: true);
  }

  UnifiedTimerState scheduleNotification() {
    return copyWith(notificationScheduled: true);
  }

  UnifiedTimerState activateLiveActivity() {
    return copyWith(liveActivityActive: true);
  }

  UnifiedTimerState copyWith({
    String? id,
    TimerType? type,
    int? totalDurationSeconds,
    int? remainingSeconds,
    TimerStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? pausedTime,
    DateTime? completionTime,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    String? workoutId,
    bool? audioEnabled,
    String? customSoundName,
    bool? notificationScheduled,
    bool? audioPlayed,
    bool? skipped,
    bool? liveActivityActive,
    String? liveActivityId,
    DateTime? createdAt,
    int? tickCount,
    List<DateTime>? pauseHistory,
    DateTime? lastBackgroundTime,
    int? secondsAdded, // ✅ Rest Timer Tracking
  }) {
    return UnifiedTimerState(
      id: id ?? this.id,
      type: type ?? this.type,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pausedTime: pausedTime ?? this.pausedTime,
      completionTime: completionTime ?? this.completionTime,
      exerciseName: exerciseName ?? this.exerciseName,
      currentSet: currentSet ?? this.currentSet,
      totalSets: totalSets ?? this.totalSets,
      workoutId: workoutId ?? this.workoutId,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      customSoundName: customSoundName ?? this.customSoundName,
      notificationScheduled:
          notificationScheduled ?? this.notificationScheduled,
      audioPlayed: audioPlayed ?? this.audioPlayed,
      skipped: skipped ?? this.skipped,
      liveActivityActive: liveActivityActive ?? this.liveActivityActive,
      liveActivityId: liveActivityId ?? this.liveActivityId,
      createdAt: createdAt ?? this.createdAt,
      tickCount: tickCount ?? this.tickCount,
      pauseHistory: pauseHistory ?? this.pauseHistory,
      lastBackgroundTime: lastBackgroundTime ?? this.lastBackgroundTime,
      secondsAdded: secondsAdded ?? this.secondsAdded, // ✅ Rest Timer Tracking
    );
  }

  // Serialization for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'totalDurationSeconds': totalDurationSeconds,
      'remainingSeconds': remainingSeconds,
      'status': status.index,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'pausedTime': pausedTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'exerciseName': exerciseName,
      'currentSet': currentSet,
      'totalSets': totalSets,
      'workoutId': workoutId,
      'audioEnabled': audioEnabled,
      'customSoundName': customSoundName,
      'notificationScheduled': notificationScheduled,
      'audioPlayed': audioPlayed,
      'skipped': skipped,
      'liveActivityActive': liveActivityActive,
      'liveActivityId': liveActivityId,
      'createdAt': createdAt.toIso8601String(),
      'tickCount': tickCount,
      'pauseHistory': pauseHistory.map((e) => e.toIso8601String()).toList(),
      'lastBackgroundTime': lastBackgroundTime?.toIso8601String(),
      'secondsAdded': secondsAdded, // ✅ Rest Timer Tracking
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UnifiedTimerState) return false;
    // CRITICAL: Compare all fields that affect UI rendering
    // Previously only compared id, which caused Riverpod to think
    // states were equal even when remainingSeconds changed,
    // preventing UI updates.
    return other.id == id &&
        other.remainingSeconds == remainingSeconds &&
        other.status == status &&
        other.tickCount == tickCount &&
        other.audioPlayed == audioPlayed &&
        other.liveActivityActive == liveActivityActive &&
        other.totalDurationSeconds == totalDurationSeconds;
  }

  @override
  int get hashCode => Object.hash(
        id,
        remainingSeconds,
        status,
        tickCount,
      );

  @override
  String toString() {
    return 'UnifiedTimerState(id: $id, type: $type, status: $status, '
        'remaining: $remainingSeconds/${totalDurationSeconds}s, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}

// Re-export enums for compatibility
enum TimerStatus { idle, running, paused, completed }

enum TimerType {
  rest, // Rest between sets
  workout, // Active workout timer
  warmup, // Warmup countdown
  cooldown, // Cooldown period
  interExercise, // Rest between exercises (after last set)
}
