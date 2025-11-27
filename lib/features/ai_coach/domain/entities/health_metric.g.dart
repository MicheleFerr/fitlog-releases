// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_metric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthMetric _$HealthMetricFromJson(Map<String, dynamic> json) =>
    _HealthMetric(
      type: $enumDecode(_$HealthMetricTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      dateFrom: DateTime.parse(json['dateFrom'] as String),
      dateTo: DateTime.parse(json['dateTo'] as String),
      sourceDevice: json['sourceDevice'] as String?,
      sourceApp: json['sourceApp'] as String?,
      workoutType: json['workoutType'] as String?,
      workoutDuration: (json['workoutDuration'] as num?)?.toInt(),
      workoutDistance: (json['workoutDistance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HealthMetricToJson(_HealthMetric instance) =>
    <String, dynamic>{
      'type': _$HealthMetricTypeEnumMap[instance.type]!,
      'value': instance.value,
      'unit': instance.unit,
      'dateFrom': instance.dateFrom.toIso8601String(),
      'dateTo': instance.dateTo.toIso8601String(),
      'sourceDevice': instance.sourceDevice,
      'sourceApp': instance.sourceApp,
      'workoutType': instance.workoutType,
      'workoutDuration': instance.workoutDuration,
      'workoutDistance': instance.workoutDistance,
    };

const _$HealthMetricTypeEnumMap = {
  HealthMetricType.steps: 'steps',
  HealthMetricType.heartRate: 'heartRate',
  HealthMetricType.activeEnergy: 'activeEnergy',
  HealthMetricType.exerciseTime: 'exerciseTime',
  HealthMetricType.workout: 'workout',
};

_HealthMetricSummary _$HealthMetricSummaryFromJson(Map<String, dynamic> json) =>
    _HealthMetricSummary(
      metricType: $enumDecode(_$HealthMetricTypeEnumMap, json['metricType']),
      totalValue: (json['totalValue'] as num).toDouble(),
      averageValue: (json['averageValue'] as num).toDouble(),
      minValue: (json['minValue'] as num).toDouble(),
      maxValue: (json['maxValue'] as num).toDouble(),
      dataPoints: (json['dataPoints'] as num).toInt(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$HealthMetricSummaryToJson(
  _HealthMetricSummary instance,
) => <String, dynamic>{
  'metricType': _$HealthMetricTypeEnumMap[instance.metricType]!,
  'totalValue': instance.totalValue,
  'averageValue': instance.averageValue,
  'minValue': instance.minValue,
  'maxValue': instance.maxValue,
  'dataPoints': instance.dataPoints,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'unit': instance.unit,
};
