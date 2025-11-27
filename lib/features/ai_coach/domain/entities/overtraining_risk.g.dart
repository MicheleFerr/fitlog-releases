// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtraining_risk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OvertrainingRisk _$OvertrainingRiskFromJson(Map<String, dynamic> json) =>
    _OvertrainingRisk(
      riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
      tsbScore: (json['tsbScore'] as num).toDouble(),
      hrvDeviation: (json['hrvDeviation'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      factors: json['factors'] == null
          ? null
          : RiskFactors.fromJson(json['factors'] as Map<String, dynamic>),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$OvertrainingRiskToJson(_OvertrainingRisk instance) =>
    <String, dynamic>{
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'tsbScore': instance.tsbScore,
      'hrvDeviation': instance.hrvDeviation,
      'recommendation': instance.recommendation,
      'factors': instance.factors?.toJson(),
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };

const _$RiskLevelEnumMap = {
  RiskLevel.locked: 'locked',
  RiskLevel.low: 'low',
  RiskLevel.moderate: 'moderate',
  RiskLevel.high: 'high',
  RiskLevel.veryHigh: 'very_high',
};

_RiskFactors _$RiskFactorsFromJson(Map<String, dynamic> json) => _RiskFactors(
  acuteTrainingLoad: (json['acuteTrainingLoad'] as num).toInt(),
  chronicTrainingLoad: (json['chronicTrainingLoad'] as num).toInt(),
  hrvBaseline: (json['hrvBaseline'] as num).toDouble(),
  currentHrv: (json['currentHrv'] as num).toDouble(),
  sleepQualityScore: (json['sleepQualityScore'] as num?)?.toInt(),
  muscleSorenessScore: (json['muscleSorenessScore'] as num?)?.toInt(),
  moodEnergyScore: (json['moodEnergyScore'] as num?)?.toInt(),
);

Map<String, dynamic> _$RiskFactorsToJson(_RiskFactors instance) =>
    <String, dynamic>{
      'acuteTrainingLoad': instance.acuteTrainingLoad,
      'chronicTrainingLoad': instance.chronicTrainingLoad,
      'hrvBaseline': instance.hrvBaseline,
      'currentHrv': instance.currentHrv,
      'sleepQualityScore': instance.sleepQualityScore,
      'muscleSorenessScore': instance.muscleSorenessScore,
      'moodEnergyScore': instance.moodEnergyScore,
    };
