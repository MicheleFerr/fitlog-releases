// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_execution_timing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SetExecutionTiming _$SetExecutionTimingFromJson(Map<String, dynamic> json) =>
    _SetExecutionTiming(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      workoutId: json['workoutId'] as String,
      setNumber: (json['setNumber'] as num).toInt(),
      executionTimeMs: (json['executionTimeMs'] as num).toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      rpe: (json['rpe'] as num?)?.toInt() ?? 0,
      repTimingsMs:
          (json['repTimingsMs'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      velocityMps:
          (json['velocityMps'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      pauseTimingsMs:
          (json['pauseTimingsMs'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      formScore: (json['formScore'] as num?)?.toDouble() ?? 0.0,
      consistencyScore: (json['consistencyScore'] as num?)?.toDouble() ?? 0.0,
      fatigueIndex: (json['fatigueIndex'] as num?)?.toDouble() ?? 0.0,
      restStartedAt: json['restStartedAt'] == null
          ? null
          : DateTime.parse(json['restStartedAt'] as String),
      restDurationMs: (json['restDurationMs'] as num?)?.toInt(),
      heartRateBpm: (json['heartRateBpm'] as num?)?.toDouble() ?? 0.0,
      ambientTemperatureC:
          (json['ambientTemperatureC'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
      synced: json['synced'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SetExecutionTimingToJson(_SetExecutionTiming instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'workoutId': instance.workoutId,
      'setNumber': instance.setNumber,
      'executionTimeMs': instance.executionTimeMs,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'reps': instance.reps,
      'weight': instance.weight,
      'rpe': instance.rpe,
      'repTimingsMs': instance.repTimingsMs,
      'velocityMps': instance.velocityMps,
      'pauseTimingsMs': instance.pauseTimingsMs,
      'formScore': instance.formScore,
      'consistencyScore': instance.consistencyScore,
      'fatigueIndex': instance.fatigueIndex,
      'restStartedAt': instance.restStartedAt?.toIso8601String(),
      'restDurationMs': instance.restDurationMs,
      'heartRateBpm': instance.heartRateBpm,
      'ambientTemperatureC': instance.ambientTemperatureC,
      'createdAt': instance.createdAt.toIso8601String(),
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'synced': instance.synced,
      'metadata': instance.metadata,
    };

_$$SetTimingConfigImpl _$$$SetTimingConfigImplFromJson(
  Map<String, dynamic> json,
) => _$$SetTimingConfigImpl(
  mode: $enumDecode(_$TimingModeEnumMap, json['mode']),
  samplingRateHz: (json['samplingRateHz'] as num?)?.toInt() ?? 10,
  trackVelocity: json['trackVelocity'] as bool? ?? true,
  trackPauses: json['trackPauses'] as bool? ?? true,
  trackHeartRate: json['trackHeartRate'] as bool? ?? false,
  maxSetDurationMs: (json['maxSetDurationMs'] as num?)?.toInt() ?? 2000,
  minRepDurationMs: (json['minRepDurationMs'] as num?)?.toInt() ?? 100,
  maxRepDurationMs: (json['maxRepDurationMs'] as num?)?.toInt() ?? 5000,
  maxVelocityVariationPercent:
      (json['maxVelocityVariationPercent'] as num?)?.toDouble() ?? 20.0,
  maxPauseBetweenRepsMs:
      (json['maxPauseBetweenRepsMs'] as num?)?.toInt() ?? 1000,
  autoStartDetection: json['autoStartDetection'] as bool? ?? true,
  autoEndDetection: json['autoEndDetection'] as bool? ?? true,
  motionThresholdMs: (json['motionThresholdMs'] as num?)?.toInt() ?? 500,
);

Map<String, dynamic> _$$$SetTimingConfigImplToJson(
  _$$SetTimingConfigImpl instance,
) => <String, dynamic>{
  'mode': _$TimingModeEnumMap[instance.mode]!,
  'samplingRateHz': instance.samplingRateHz,
  'trackVelocity': instance.trackVelocity,
  'trackPauses': instance.trackPauses,
  'trackHeartRate': instance.trackHeartRate,
  'maxSetDurationMs': instance.maxSetDurationMs,
  'minRepDurationMs': instance.minRepDurationMs,
  'maxRepDurationMs': instance.maxRepDurationMs,
  'maxVelocityVariationPercent': instance.maxVelocityVariationPercent,
  'maxPauseBetweenRepsMs': instance.maxPauseBetweenRepsMs,
  'autoStartDetection': instance.autoStartDetection,
  'autoEndDetection': instance.autoEndDetection,
  'motionThresholdMs': instance.motionThresholdMs,
};

const _$TimingModeEnumMap = {
  TimingMode.precision: 'precision',
  TimingMode.performance: 'performance',
  TimingMode.endurance: 'endurance',
  TimingMode.rehabilitation: 'rehabilitation',
};

_$$LiveSetMetricsImpl _$$$LiveSetMetricsImplFromJson(
  Map<String, dynamic> json,
) => _$$LiveSetMetricsImpl(
  setId: json['setId'] as String,
  phase: $enumDecode(_$SetPhaseEnumMap, json['phase']),
  elapsedMs: (json['elapsedMs'] as num).toInt(),
  currentRep: (json['currentRep'] as num).toInt(),
  currentVelocityMps: (json['currentVelocityMps'] as num?)?.toDouble() ?? 0.0,
  averageVelocityMps: (json['averageVelocityMps'] as num?)?.toDouble() ?? 0.0,
  velocityDropPercent: (json['velocityDropPercent'] as num?)?.toDouble() ?? 0.0,
  currentFormScore: (json['currentFormScore'] as num?)?.toDouble() ?? 0.0,
  consistencyScore: (json['consistencyScore'] as num?)?.toDouble() ?? 0.0,
  fatigueIndex: (json['fatigueIndex'] as num?)?.toDouble() ?? 0.0,
  shouldStopSet: json['shouldStopSet'] as bool? ?? false,
  coachingTip: json['coachingTip'] as String?,
  suggestedWeight: (json['suggestedWeight'] as num?)?.toDouble(),
  suggestedReps: (json['suggestedReps'] as num?)?.toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$$LiveSetMetricsImplToJson(
  _$$LiveSetMetricsImpl instance,
) => <String, dynamic>{
  'setId': instance.setId,
  'phase': _$SetPhaseEnumMap[instance.phase]!,
  'elapsedMs': instance.elapsedMs,
  'currentRep': instance.currentRep,
  'currentVelocityMps': instance.currentVelocityMps,
  'averageVelocityMps': instance.averageVelocityMps,
  'velocityDropPercent': instance.velocityDropPercent,
  'currentFormScore': instance.currentFormScore,
  'consistencyScore': instance.consistencyScore,
  'fatigueIndex': instance.fatigueIndex,
  'shouldStopSet': instance.shouldStopSet,
  'coachingTip': instance.coachingTip,
  'suggestedWeight': instance.suggestedWeight,
  'suggestedReps': instance.suggestedReps,
  'timestamp': instance.timestamp.toIso8601String(),
};

const _$SetPhaseEnumMap = {
  SetPhase.preparation: 'preparation',
  SetPhase.execution: 'execution',
  SetPhase.completion: 'completion',
  SetPhase.rest: 'rest',
};
