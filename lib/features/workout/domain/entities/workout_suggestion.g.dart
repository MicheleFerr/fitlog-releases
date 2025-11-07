// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutSuggestionImpl _$$WorkoutSuggestionImplFromJson(
        Map<String, dynamic> json) =>
    _$WorkoutSuggestionImpl(
      level: $enumDecode(_$SuggestionLevelEnumMap, json['level']),
      workoutName: json['workoutName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
      patternInfo: json['patternInfo'] as String?,
      routineTemplateId: json['routineTemplateId'] as String?,
      frequencyData: json['frequencyData'] as String?,
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
      isRecovery: json['isRecovery'] as bool? ?? false,
      recoveryDate: json['recoveryDate'] == null
          ? null
          : DateTime.parse(json['recoveryDate'] as String),
    );

Map<String, dynamic> _$$WorkoutSuggestionImplToJson(
        _$WorkoutSuggestionImpl instance) =>
    <String, dynamic>{
      'level': _$SuggestionLevelEnumMap[instance.level]!,
      'workoutName': instance.workoutName,
      'confidence': instance.confidence,
      'reason': instance.reason,
      'patternInfo': instance.patternInfo,
      'routineTemplateId': instance.routineTemplateId,
      'frequencyData': instance.frequencyData,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'generatedAt': instance.generatedAt?.toIso8601String(),
      'isRecovery': instance.isRecovery,
      'recoveryDate': instance.recoveryDate?.toIso8601String(),
    };

const _$SuggestionLevelEnumMap = {
  SuggestionLevel.pattern: 'pattern',
  SuggestionLevel.routine: 'routine',
  SuggestionLevel.frequency: 'frequency',
  SuggestionLevel.dayBased: 'dayBased',
};
