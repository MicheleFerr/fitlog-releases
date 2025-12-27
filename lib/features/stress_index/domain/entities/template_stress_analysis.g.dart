// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_stress_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateStressAnalysis _$TemplateStressAnalysisFromJson(
  Map<String, dynamic> json,
) => _TemplateStressAnalysis(
  templateId: json['templateId'] as String,
  templateName: json['templateName'] as String,
  templateIcon: json['templateIcon'] as String?,
  expectedStress: (json['expectedStress'] as num).toDouble(),
  currentStress: (json['currentStress'] as num).toDouble(),
  resultingTotalStress: (json['resultingTotalStress'] as num).toDouble(),
  muscleReadiness: (json['muscleReadiness'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, MuscleReadinessData.fromJson(e as Map<String, dynamic>)),
  ),
  primaryMuscles: (json['primaryMuscles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  underRecoveredMuscles: (json['underRecoveredMuscles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  fatiguedMuscles: (json['fatiguedMuscles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendation: $enumDecode(
    _$TemplateRecommendationEnumMap,
    json['recommendation'],
  ),
  rationale: json['rationale'] as String,
  optimalityScore: (json['optimalityScore'] as num).toDouble(),
  sleepDataUsed: json['sleepDataUsed'] as bool? ?? false,
  hrvDataUsed: json['hrvDataUsed'] as bool? ?? false,
  sleepHoursLastNight: (json['sleepHoursLastNight'] as num?)?.toDouble(),
  hrvMs: (json['hrvMs'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TemplateStressAnalysisToJson(
  _TemplateStressAnalysis instance,
) => <String, dynamic>{
  'templateId': instance.templateId,
  'templateName': instance.templateName,
  'templateIcon': instance.templateIcon,
  'expectedStress': instance.expectedStress,
  'currentStress': instance.currentStress,
  'resultingTotalStress': instance.resultingTotalStress,
  'muscleReadiness': instance.muscleReadiness.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'primaryMuscles': instance.primaryMuscles,
  'secondaryMuscles': instance.secondaryMuscles,
  'underRecoveredMuscles': instance.underRecoveredMuscles,
  'fatiguedMuscles': instance.fatiguedMuscles,
  'recommendation': _$TemplateRecommendationEnumMap[instance.recommendation]!,
  'rationale': instance.rationale,
  'optimalityScore': instance.optimalityScore,
  'sleepDataUsed': instance.sleepDataUsed,
  'hrvDataUsed': instance.hrvDataUsed,
  'sleepHoursLastNight': instance.sleepHoursLastNight,
  'hrvMs': instance.hrvMs,
};

const _$TemplateRecommendationEnumMap = {
  TemplateRecommendation.optimal: 'optimal',
  TemplateRecommendation.acceptable: 'acceptable',
  TemplateRecommendation.suboptimal: 'suboptimal',
  TemplateRecommendation.avoid: 'avoid',
};
