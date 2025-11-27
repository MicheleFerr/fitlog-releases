// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsSet _$AnalyticsSetFromJson(Map<String, dynamic> json) =>
    _AnalyticsSet(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$AnalyticsSetToJson(_AnalyticsSet instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'reps': instance.reps,
      'date': instance.date.toIso8601String(),
    };
