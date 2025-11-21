// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consistency_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsistencyScoreImpl _$$ConsistencyScoreImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsistencyScoreImpl(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      scoreRating: json['scoreRating'] as String? ?? 'Not Available',
      rating: json['rating'] as String? ?? 'Not Available',
      riskLevel: json['riskLevel'] as String? ?? 'Unknown',
      overtrainingRisk: $enumDecodeNullable(
              _$OvertrainingRiskEnumMap, json['overtrainingRisk']) ??
          OvertrainingRisk.low,
      frequencyScore: (json['frequencyScore'] as num?)?.toInt() ?? 0,
      restScore: (json['restScore'] as num?)?.toInt() ?? 0,
      volumeScore: (json['volumeScore'] as num?)?.toInt() ?? 0,
      progressionScore: (json['progressionScore'] as num?)?.toInt() ?? 0,
      weeklyStats:
          WeeklyStats.fromJson(json['weeklyStats'] as Map<String, dynamic>),
      workoutsCompleted: (json['workoutsCompleted'] as num?)?.toInt() ?? 0,
      workoutsSkipped: (json['workoutsSkipped'] as num?)?.toInt() ?? 0,
      avgFrequency: (json['avgFrequency'] as num?)?.toDouble() ?? 0.0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$$ConsistencyScoreImplToJson(
        _$ConsistencyScoreImpl instance) =>
    <String, dynamic>{
      'overallScore': instance.overallScore,
      'scoreRating': instance.scoreRating,
      'rating': instance.rating,
      'riskLevel': instance.riskLevel,
      'overtrainingRisk': _$OvertrainingRiskEnumMap[instance.overtrainingRisk]!,
      'frequencyScore': instance.frequencyScore,
      'restScore': instance.restScore,
      'volumeScore': instance.volumeScore,
      'progressionScore': instance.progressionScore,
      'weeklyStats': instance.weeklyStats.toJson(),
      'workoutsCompleted': instance.workoutsCompleted,
      'workoutsSkipped': instance.workoutsSkipped,
      'avgFrequency': instance.avgFrequency,
      'longestStreak': instance.longestStreak,
      'currentStreak': instance.currentStreak,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };

const _$OvertrainingRiskEnumMap = {
  OvertrainingRisk.low: 'low',
  OvertrainingRisk.medium: 'medium',
  OvertrainingRisk.high: 'high',
};
