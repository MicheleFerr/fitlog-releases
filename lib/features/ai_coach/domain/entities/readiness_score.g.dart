// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadinessScore _$ReadinessScoreFromJson(Map<String, dynamic> json) =>
    _ReadinessScore(
      score: (json['score'] as num).toInt(),
      category: $enumDecode(_$ReadinessCategoryEnumMap, json['category']),
      recommendation: json['recommendation'] as String,
      factors: json['factors'] == null
          ? null
          : ReadinessFactors.fromJson(json['factors'] as Map<String, dynamic>),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$ReadinessScoreToJson(_ReadinessScore instance) =>
    <String, dynamic>{
      'score': instance.score,
      'category': _$ReadinessCategoryEnumMap[instance.category]!,
      'recommendation': instance.recommendation,
      'factors': instance.factors?.toJson(),
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };

const _$ReadinessCategoryEnumMap = {
  ReadinessCategory.locked: 'locked',
  ReadinessCategory.veryLow: 'very_low',
  ReadinessCategory.low: 'low',
  ReadinessCategory.moderate: 'moderate',
  ReadinessCategory.good: 'good',
  ReadinessCategory.optimal: 'optimal',
};

_ReadinessFactors _$ReadinessFactorsFromJson(Map<String, dynamic> json) =>
    _ReadinessFactors(
      workoutFrequencyScore: (json['workoutFrequencyScore'] as num).toInt(),
      recoveryTimeScore: (json['recoveryTimeScore'] as num).toInt(),
      consistencyScore: (json['consistencyScore'] as num).toInt(),
      daysSinceLastWorkout: (json['daysSinceLastWorkout'] as num?)?.toInt(),
      workoutsLast7Days: (json['workoutsLast7Days'] as num?)?.toInt(),
      avgWorkoutsPerWeek: (json['avgWorkoutsPerWeek'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReadinessFactorsToJson(_ReadinessFactors instance) =>
    <String, dynamic>{
      'workoutFrequencyScore': instance.workoutFrequencyScore,
      'recoveryTimeScore': instance.recoveryTimeScore,
      'consistencyScore': instance.consistencyScore,
      'daysSinceLastWorkout': instance.daysSinceLastWorkout,
      'workoutsLast7Days': instance.workoutsLast7Days,
      'avgWorkoutsPerWeek': instance.avgWorkoutsPerWeek,
    };
