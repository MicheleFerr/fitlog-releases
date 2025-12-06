// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warmup_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WarmupSuggestion _$WarmupSuggestionFromJson(Map<String, dynamic> json) =>
    _WarmupSuggestion(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      type: $enumDecode(_$WarmupTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$WarmupSuggestionToJson(_WarmupSuggestion instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'reps': instance.reps,
      'type': _$WarmupTypeEnumMap[instance.type]!,
    };

const _$WarmupTypeEnumMap = {
  WarmupType.mobility: 'mobility',
  WarmupType.activation: 'activation',
};
