// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InsightRule _$InsightRuleFromJson(Map<String, dynamic> json) => _InsightRule(
  insightType: $enumDecode(_$InsightTypeEnumMap, json['insightType']),
  minWeeks: (json['minWeeks'] as num).toInt(),
  volumeThreshold: (json['volumeThreshold'] as num).toDouble(),
  personalizedThresholds:
      (json['personalizedThresholds'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          $enumDecode(_$ExperienceLevelEnumMap, k),
          PersonalizedThreshold.fromJson(e as Map<String, dynamic>),
        ),
      ),
);

Map<String, dynamic> _$InsightRuleToJson(_InsightRule instance) =>
    <String, dynamic>{
      'insightType': _$InsightTypeEnumMap[instance.insightType]!,
      'minWeeks': instance.minWeeks,
      'volumeThreshold': instance.volumeThreshold,
      'personalizedThresholds': instance.personalizedThresholds.map(
        (k, e) => MapEntry(_$ExperienceLevelEnumMap[k]!, e.toJson()),
      ),
    };

const _$InsightTypeEnumMap = {
  InsightType.muscleGroupBalance: 'muscleGroupBalance',
  InsightType.progressOverload: 'progressOverload',
  InsightType.recoveryPattern: 'recoveryPattern',
  InsightType.volumeOptimization: 'volumeOptimization',
  InsightType.frequencyRecommendation: 'frequencyRecommendation',
  InsightType.plateauBreaker: 'plateauBreaker',
  InsightType.formWarning: 'formWarning',
  InsightType.motivational: 'motivational',
  InsightType.cnsFatigue: 'cnsFatigue',
  InsightType.periodization: 'periodization',
  InsightType.mobility: 'mobility',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};

_PersonalizedThreshold _$PersonalizedThresholdFromJson(
  Map<String, dynamic> json,
) => _PersonalizedThreshold(
  mev: (json['mev'] as num).toDouble(),
  mav: (json['mav'] as num).toDouble(),
  mrv: (json['mrv'] as num).toDouble(),
);

Map<String, dynamic> _$PersonalizedThresholdToJson(
  _PersonalizedThreshold instance,
) => <String, dynamic>{
  'mev': instance.mev,
  'mav': instance.mav,
  'mrv': instance.mrv,
};
