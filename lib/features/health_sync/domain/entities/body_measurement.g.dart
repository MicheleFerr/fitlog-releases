// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BodyMeasurement _$BodyMeasurementFromJson(Map<String, dynamic> json) =>
    _BodyMeasurement(
      value: (json['value'] as num).toDouble(),
      unit: $enumDecode(_$MeasurementUnitEnumMap, json['unit']),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      dataType: $enumDecode(_$HealthDataTypeEnumMap, json['dataType']),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$BodyMeasurementToJson(_BodyMeasurement instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': _$MeasurementUnitEnumMap[instance.unit]!,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'dataType': _$HealthDataTypeEnumMap[instance.dataType]!,
      'source': instance.source,
    };

const _$MeasurementUnitEnumMap = {
  MeasurementUnit.kilograms: 'kilograms',
  MeasurementUnit.pounds: 'pounds',
  MeasurementUnit.percent: 'percent',
  MeasurementUnit.minutes: 'minutes',
  MeasurementUnit.bpm: 'bpm',
  MeasurementUnit.meters: 'meters',
  MeasurementUnit.centimeters: 'centimeters',
};

const _$HealthDataTypeEnumMap = {
  HealthDataType.workout: 'workout',
  HealthDataType.bodyWeight: 'bodyWeight',
  HealthDataType.height: 'height',
  HealthDataType.bodyFat: 'bodyFat',
  HealthDataType.leanMass: 'leanMass',
  HealthDataType.heartRate: 'heartRate',
  HealthDataType.sleep: 'sleep',
  HealthDataType.nutrition: 'nutrition',
};
