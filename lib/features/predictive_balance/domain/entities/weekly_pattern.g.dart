// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeeklyPattern _$WeeklyPatternFromJson(Map<String, dynamic> json) =>
    _WeeklyPattern(
      cycle: (json['cycle'] as List<dynamic>)
          .map((e) => WorkoutFingerprint.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      weeksAnalyzed: (json['weeksAnalyzed'] as num).toInt(),
      weeksMatched: (json['weeksMatched'] as num).toInt(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      avgWorkoutsPerWeek: (json['avgWorkoutsPerWeek'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WeeklyPatternToJson(_WeeklyPattern instance) =>
    <String, dynamic>{
      'cycle': instance.cycle.map((e) => e.toJson()).toList(),
      'confidence': instance.confidence,
      'weeksAnalyzed': instance.weeksAnalyzed,
      'weeksMatched': instance.weeksMatched,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'avgWorkoutsPerWeek': instance.avgWorkoutsPerWeek,
    };
