// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Measurement _$MeasurementFromJson(Map<String, dynamic> json) => _Measurement(
  id: json['id'] as String,
  userId: json['userId'] as String,
  metricType: $enumDecode(_$MetricTypeEnumMap, json['metricType']),
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  source: $enumDecode(_$MeasurementSourceEnumMap, json['source']),
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$MeasurementToJson(_Measurement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'metricType': _$MetricTypeEnumMap[instance.metricType]!,
      'value': instance.value,
      'unit': instance.unit,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': _$MeasurementSourceEnumMap[instance.source]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$MetricTypeEnumMap = {
  MetricType.weight: 'weight',
  MetricType.bodyFatPercentage: 'bodyFatPercentage',
  MetricType.height: 'height',
  MetricType.leanMass: 'leanMass',
  MetricType.bmi: 'bmi',
  MetricType.bmr: 'bmr',
  MetricType.neckCircumference: 'neckCircumference',
  MetricType.shoulderCircumference: 'shoulderCircumference',
  MetricType.chestCircumference: 'chestCircumference',
  MetricType.waistCircumference: 'waistCircumference',
  MetricType.abdomenCircumference: 'abdomenCircumference',
  MetricType.hipCircumference: 'hipCircumference',
  MetricType.bicepLeftCircumference: 'bicepLeftCircumference',
  MetricType.bicepRightCircumference: 'bicepRightCircumference',
  MetricType.forearmLeftCircumference: 'forearmLeftCircumference',
  MetricType.forearmRightCircumference: 'forearmRightCircumference',
  MetricType.thighLeftCircumference: 'thighLeftCircumference',
  MetricType.thighRightCircumference: 'thighRightCircumference',
  MetricType.calfLeftCircumference: 'calfLeftCircumference',
  MetricType.calfRightCircumference: 'calfRightCircumference',
  MetricType.bodyTemperature: 'bodyTemperature',
  MetricType.waterMass: 'waterMass',
  MetricType.boneMass: 'boneMass',
};

const _$MeasurementSourceEnumMap = {
  MeasurementSource.manual: 'manual',
  MeasurementSource.healthKit: 'healthKit',
  MeasurementSource.healthConnect: 'healthConnect',
  MeasurementSource.imported: 'imported',
  MeasurementSource.calculated: 'calculated',
};

_MeasurementMetadata _$MeasurementMetadataFromJson(Map<String, dynamic> json) =>
    _MeasurementMetadata(
      deviceInfo: json['deviceInfo'] as String?,
      appVersion: json['appVersion'] as String?,
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.pending,
      lastSyncAttempt: json['lastSyncAttempt'] == null
          ? null
          : DateTime.parse(json['lastSyncAttempt'] as String),
      syncError: json['syncError'] as String?,
      isValidated: json['isValidated'] as bool? ?? false,
      validationErrors: (json['validationErrors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MeasurementMetadataToJson(
  _MeasurementMetadata instance,
) => <String, dynamic>{
  'deviceInfo': instance.deviceInfo,
  'appVersion': instance.appVersion,
  'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
  'lastSyncAttempt': instance.lastSyncAttempt?.toIso8601String(),
  'syncError': instance.syncError,
  'isValidated': instance.isValidated,
  'validationErrors': instance.validationErrors,
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.synced: 'synced',
  SyncStatus.conflict: 'conflict',
  SyncStatus.failed: 'failed',
};
