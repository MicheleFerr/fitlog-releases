// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalyticsSetImpl _$$AnalyticsSetImplFromJson(Map<String, dynamic> json) =>
    _$AnalyticsSetImpl(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$AnalyticsSetImplToJson(_$AnalyticsSetImpl instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'reps': instance.reps,
      'date': instance.date.toIso8601String(),
    };
