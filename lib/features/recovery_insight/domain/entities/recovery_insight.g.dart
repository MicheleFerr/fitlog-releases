// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecoveryInsight _$RecoveryInsightFromJson(Map<String, dynamic> json) =>
    _RecoveryInsight(
      score: (json['score'] as num).toInt(),
      category: $enumDecode(_$RecoveryCategoryEnumMap, json['category']),
      recommendation: json['recommendation'] as String,
      lastNightSleep: Duration(
        microseconds: (json['lastNightSleep'] as num).toInt(),
      ),
      weeklyAverageHours: (json['weeklyAverageHours'] as num).toDouble(),
      consecutiveBadNights: (json['consecutiveBadNights'] as num).toInt(),
      streakDays: (json['streakDays'] as num).toInt(),
      correlation: json['correlation'] == null
          ? null
          : SleepWorkoutCorrelation.fromJson(
              json['correlation'] as Map<String, dynamic>,
            ),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
      hasSleepData: json['hasSleepData'] as bool? ?? true,
    );

Map<String, dynamic> _$RecoveryInsightToJson(_RecoveryInsight instance) =>
    <String, dynamic>{
      'score': instance.score,
      'category': _$RecoveryCategoryEnumMap[instance.category]!,
      'recommendation': instance.recommendation,
      'lastNightSleep': instance.lastNightSleep.inMicroseconds,
      'weeklyAverageHours': instance.weeklyAverageHours,
      'consecutiveBadNights': instance.consecutiveBadNights,
      'streakDays': instance.streakDays,
      'correlation': instance.correlation?.toJson(),
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
      'hasSleepData': instance.hasSleepData,
    };

const _$RecoveryCategoryEnumMap = {
  RecoveryCategory.optimal: 'optimal',
  RecoveryCategory.good: 'good',
  RecoveryCategory.moderate: 'moderate',
  RecoveryCategory.low: 'low',
  RecoveryCategory.critical: 'critical',
};
