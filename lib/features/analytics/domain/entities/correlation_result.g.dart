// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correlation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CorrelationResult _$CorrelationResultFromJson(Map<String, dynamic> json) =>
    _CorrelationResult(
      r: (json['r'] as num).toDouble(),
      rSquared: (json['rSquared'] as num).toDouble(),
      strength: $enumDecode(_$CorrelationStrengthEnumMap, json['strength']),
      interpretation: json['interpretation'] as String,
      dataPoints: (json['dataPoints'] as num?)?.toInt() ?? 0,
      isSignificant: json['isSignificant'] as bool? ?? false,
    );

Map<String, dynamic> _$CorrelationResultToJson(_CorrelationResult instance) =>
    <String, dynamic>{
      'r': instance.r,
      'rSquared': instance.rSquared,
      'strength': _$CorrelationStrengthEnumMap[instance.strength]!,
      'interpretation': instance.interpretation,
      'dataPoints': instance.dataPoints,
      'isSignificant': instance.isSignificant,
    };

const _$CorrelationStrengthEnumMap = {
  CorrelationStrength.strong: 'strong',
  CorrelationStrength.moderate: 'moderate',
  CorrelationStrength.weak: 'weak',
  CorrelationStrength.insufficient: 'insufficient',
};

_CorrelationResults _$CorrelationResultsFromJson(Map<String, dynamic> json) =>
    _CorrelationResults(
      weightRpe: CorrelationResult.fromJson(
        json['weightRpe'] as Map<String, dynamic>,
      ),
      volumeRpe: CorrelationResult.fromJson(
        json['volumeRpe'] as Map<String, dynamic>,
      ),
      weightVolume: json['weightVolume'] == null
          ? null
          : CorrelationResult.fromJson(
              json['weightVolume'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CorrelationResultsToJson(_CorrelationResults instance) =>
    <String, dynamic>{
      'weightRpe': instance.weightRpe.toJson(),
      'volumeRpe': instance.volumeRpe.toJson(),
      'weightVolume': instance.weightVolume?.toJson(),
    };
