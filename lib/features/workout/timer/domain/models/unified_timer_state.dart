import 'package:uuid/uuid.dart';

/// Unified timer state model that consolidates all timer functionality.
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
    this.completionDeliveryStrategy =
        TimerCompletionDeliveryStrategy.foregroundAudio,
    this.completionSoundName,
    this.audioPlayed = false,
    this.skipped = false,
    this.liveActivityActive = false,
    this.liveActivityId,
    DateTime? createdAt,
    this.tickCount = 0,
    List<DateTime>? pauseHistory,
    this.lastBackgroundTime,
    this.secondsAdded = 0,
  }) : id = id ?? const Uuid().v4(),
       remainingSeconds = remainingSeconds ?? totalDurationSeconds,
       createdAt = createdAt ?? DateTime.now(),
       pauseHistory = pauseHistory ?? <DateTime>[];

  factory UnifiedTimerState.fromJson(Map<String, dynamic> json) {
    final legacyNotificationOwned =
        (json['iosNativeCompletionArmed'] as bool? ?? false) ||
        (json['notificationScheduled'] as bool? ?? false);
    final completionSoundName =
        (json['completionSoundName'] as String?) ??
        (json['customSoundName'] as String?);

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
      completionDeliveryStrategy: _completionDeliveryStrategyFromJson(
        json['completionDeliveryStrategy'],
        legacyNotificationOwned: legacyNotificationOwned,
      ),
      completionSoundName: completionSoundName,
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
      secondsAdded: json['secondsAdded'] as int? ?? 0,
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

  // Audio / notification state
  final bool audioEnabled;
  final String? customSoundName;
  final TimerCompletionDeliveryStrategy completionDeliveryStrategy;
  final String? completionSoundName;
  final bool audioPlayed;
  final bool skipped;
  final bool liveActivityActive;
  final String? liveActivityId;

  // Performance tracking
  final DateTime createdAt;
  final int tickCount;
  final List<DateTime> pauseHistory;

  // Background sync state
  final DateTime? lastBackgroundTime;

  // Rest timer tracking
  final int secondsAdded;

  static TimerCompletionDeliveryStrategy _completionDeliveryStrategyFromJson(
    Object? raw, {
    required bool legacyNotificationOwned,
  }) {
    final storageValue = raw?.toString();
    switch (storageValue) {
      case 'notificationOwned':
        return TimerCompletionDeliveryStrategy.notificationOwned;
      case 'foregroundAudio':
        return TimerCompletionDeliveryStrategy.foregroundAudio;
      default:
        return legacyNotificationOwned
            ? TimerCompletionDeliveryStrategy.notificationOwned
            : TimerCompletionDeliveryStrategy.foregroundAudio;
    }
  }

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
  bool get isCompleted =>
      status == TimerStatus.completed ||
      (status == TimerStatus.running && remainingSeconds <= 0);
  bool get isIdle => status == TimerStatus.idle;

  bool get canStart =>
      status == TimerStatus.idle || status == TimerStatus.paused;
  bool get canPause => status == TimerStatus.running;
  bool get canReset => status != TimerStatus.idle;

  UnifiedTimerState start() {
    final now = DateTime.now();
    final preciseEndTime = _calculatePreciseEndTime(now, remainingSeconds);

    return copyWith(
      status: TimerStatus.running,
      startTime: startTime ?? now,
      pausedTime: null,
      endTime: preciseEndTime,
    );
  }

  static DateTime _calculatePreciseEndTime(
    DateTime startTime,
    int durationSeconds,
  ) {
    final preciseStartMicros = startTime.microsecondsSinceEpoch;
    final durationMicros = durationSeconds * Duration.microsecondsPerSecond;
    final endTimeMicros = preciseStartMicros + durationMicros;
    return DateTime.fromMicrosecondsSinceEpoch(endTimeMicros);
  }

  int calculatePreciseRemainingTime() {
    if (endTime == null) return remainingSeconds;

    final now = DateTime.now();
    final calculatedRemaining = endTime!.difference(now).inSeconds;
    final driftSeconds = (calculatedRemaining - remainingSeconds).abs();

    if (driftSeconds > 2) {
      return calculatedRemaining > 0 ? calculatedRemaining : 0;
    }

    return remainingSeconds;
  }

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
      completionDeliveryStrategy:
          TimerCompletionDeliveryStrategy.foregroundAudio,
      audioPlayed: false,
      skipped: false,
      liveActivityActive: false,
      liveActivityId: null,
      tickCount: 0,
      pauseHistory: <DateTime>[],
      secondsAdded: 0,
    );
  }

  UnifiedTimerState complete() {
    return copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      completionTime: DateTime.now(),
      completionDeliveryStrategy:
          TimerCompletionDeliveryStrategy.foregroundAudio,
    );
  }

  UnifiedTimerState skip() {
    return copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      completionTime: DateTime.now(),
      completionDeliveryStrategy:
          TimerCompletionDeliveryStrategy.foregroundAudio,
      skipped: true,
      audioPlayed: true,
    );
  }

  UnifiedTimerState markAudioPlayed() {
    return copyWith(audioPlayed: true);
  }

  UnifiedTimerState withForegroundAudioCompletion() {
    return copyWith(
      completionDeliveryStrategy:
          TimerCompletionDeliveryStrategy.foregroundAudio,
    );
  }

  UnifiedTimerState withNotificationOwnedCompletion() {
    return copyWith(
      completionDeliveryStrategy:
          TimerCompletionDeliveryStrategy.notificationOwned,
    );
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
    TimerCompletionDeliveryStrategy? completionDeliveryStrategy,
    String? completionSoundName,
    bool? audioPlayed,
    bool? skipped,
    bool? liveActivityActive,
    String? liveActivityId,
    DateTime? createdAt,
    int? tickCount,
    List<DateTime>? pauseHistory,
    DateTime? lastBackgroundTime,
    int? secondsAdded,
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
      completionDeliveryStrategy:
          completionDeliveryStrategy ?? this.completionDeliveryStrategy,
      completionSoundName: completionSoundName ?? this.completionSoundName,
      audioPlayed: audioPlayed ?? this.audioPlayed,
      skipped: skipped ?? this.skipped,
      liveActivityActive: liveActivityActive ?? this.liveActivityActive,
      liveActivityId: liveActivityId ?? this.liveActivityId,
      createdAt: createdAt ?? this.createdAt,
      tickCount: tickCount ?? this.tickCount,
      pauseHistory: pauseHistory ?? this.pauseHistory,
      lastBackgroundTime: lastBackgroundTime ?? this.lastBackgroundTime,
      secondsAdded: secondsAdded ?? this.secondsAdded,
    );
  }

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
      'completionDeliveryStrategy': completionDeliveryStrategy.name,
      'completionSoundName': completionSoundName,
      'audioPlayed': audioPlayed,
      'skipped': skipped,
      'liveActivityActive': liveActivityActive,
      'liveActivityId': liveActivityId,
      'createdAt': createdAt.toIso8601String(),
      'tickCount': tickCount,
      'pauseHistory': pauseHistory.map((e) => e.toIso8601String()).toList(),
      'lastBackgroundTime': lastBackgroundTime?.toIso8601String(),
      'secondsAdded': secondsAdded,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UnifiedTimerState) return false;

    return other.id == id &&
        other.remainingSeconds == remainingSeconds &&
        other.status == status &&
        other.tickCount == tickCount &&
        other.audioPlayed == audioPlayed &&
        other.liveActivityActive == liveActivityActive &&
        other.totalDurationSeconds == totalDurationSeconds &&
        other.completionDeliveryStrategy == completionDeliveryStrategy;
  }

  @override
  int get hashCode => Object.hash(
    id,
    remainingSeconds,
    status,
    tickCount,
    completionDeliveryStrategy,
  );

  @override
  String toString() {
    return 'UnifiedTimerState(id: $id, type: $type, status: $status, '
        'remaining: $remainingSeconds/${totalDurationSeconds}s, '
        'delivery: ${completionDeliveryStrategy.name}, '
        'progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}

enum TimerStatus { idle, running, paused, completed }

enum TimerType { rest, workout, warmup, cooldown, interExercise }

enum TimerCompletionDeliveryStrategy { foregroundAudio, notificationOwned }
