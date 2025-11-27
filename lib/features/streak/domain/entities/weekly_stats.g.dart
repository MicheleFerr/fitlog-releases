// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeeklyStatsImpl _$$WeeklyStatsImplFromJson(
  Map<String, dynamic> json,
) => _$WeeklyStatsImpl(
  avgWorkoutsPerWeek: (json['avgWorkoutsPerWeek'] as num?)?.toDouble() ?? 0.0,
  avgRestDaysPerWeek: (json['avgRestDaysPerWeek'] as num?)?.toDouble() ?? 0.0,
  totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
  totalRestDays: (json['totalRestDays'] as num?)?.toInt() ?? 0,
  totalActiveDays: (json['totalActiveDays'] as num?)?.toInt() ?? 0,
  weekStartDate: json['weekStartDate'] == null
      ? null
      : DateTime.parse(json['weekStartDate'] as String),
  weekEndDate: json['weekEndDate'] == null
      ? null
      : DateTime.parse(json['weekEndDate'] as String),
);

Map<String, dynamic> _$$WeeklyStatsImplToJson(_$WeeklyStatsImpl instance) =>
    <String, dynamic>{
      'avgWorkoutsPerWeek': instance.avgWorkoutsPerWeek,
      'avgRestDaysPerWeek': instance.avgRestDaysPerWeek,
      'totalWorkouts': instance.totalWorkouts,
      'totalRestDays': instance.totalRestDays,
      'totalActiveDays': instance.totalActiveDays,
      'weekStartDate': instance.weekStartDate?.toIso8601String(),
      'weekEndDate': instance.weekEndDate?.toIso8601String(),
    };
