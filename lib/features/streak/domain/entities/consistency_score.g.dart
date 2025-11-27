// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consistency_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsistencyScoreImpl _$$ConsistencyScoreImplFromJson(
  Map<String, dynamic> json,
) => _$ConsistencyScoreImpl(
  frequencyOptimal: json['frequencyOptimal'] as bool? ?? false,
  restOptimal: json['restOptimal'] as bool? ?? false,
  progressionPositive: json['progressionPositive'] as bool? ?? false,
  frequencyScore: (json['frequencyScore'] as num?)?.toInt() ?? 0,
  restScore: (json['restScore'] as num?)?.toInt() ?? 0,
  progressionScore: (json['progressionScore'] as num?)?.toInt() ?? 0,
  weeklyStats: WeeklyStats.fromJson(
    json['weeklyStats'] as Map<String, dynamic>,
  ),
  workoutsCompleted: (json['workoutsCompleted'] as num?)?.toInt() ?? 0,
  workoutsSkipped: (json['workoutsSkipped'] as num?)?.toInt() ?? 0,
  avgFrequency: (json['avgFrequency'] as num?)?.toDouble() ?? 0.0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  calculatedAt: json['calculatedAt'] == null
      ? null
      : DateTime.parse(json['calculatedAt'] as String),
  overallScore: (json['overallScore'] as num?)?.toInt(),
  scoreRating: json['scoreRating'] as String?,
  rating: json['rating'] as String?,
  riskLevel: json['riskLevel'] as String?,
  overtrainingRisk: $enumDecodeNullable(
    _$OvertrainingRiskEnumMap,
    json['overtrainingRisk'],
  ),
  volumeScore: (json['volumeScore'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ConsistencyScoreImplToJson(
  _$ConsistencyScoreImpl instance,
) => <String, dynamic>{
  'frequencyOptimal': instance.frequencyOptimal,
  'restOptimal': instance.restOptimal,
  'progressionPositive': instance.progressionPositive,
  'frequencyScore': instance.frequencyScore,
  'restScore': instance.restScore,
  'progressionScore': instance.progressionScore,
  'weeklyStats': instance.weeklyStats.toJson(),
  'workoutsCompleted': instance.workoutsCompleted,
  'workoutsSkipped': instance.workoutsSkipped,
  'avgFrequency': instance.avgFrequency,
  'longestStreak': instance.longestStreak,
  'currentStreak': instance.currentStreak,
  'calculatedAt': instance.calculatedAt?.toIso8601String(),
  'overallScore': instance.overallScore,
  'scoreRating': instance.scoreRating,
  'rating': instance.rating,
  'riskLevel': instance.riskLevel,
  'overtrainingRisk': _$OvertrainingRiskEnumMap[instance.overtrainingRisk],
  'volumeScore': instance.volumeScore,
};

const _$OvertrainingRiskEnumMap = {
  OvertrainingRisk.low: 'low',
  OvertrainingRisk.medium: 'medium',
  OvertrainingRisk.high: 'high',
};
