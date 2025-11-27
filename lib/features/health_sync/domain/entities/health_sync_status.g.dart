// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_sync_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthSyncStatus _$HealthSyncStatusFromJson(Map<String, dynamic> json) =>
    _HealthSyncStatus(
      dataType: $enumDecode(_$HealthDataTypeEnumMap, json['dataType']),
      lastSyncTime: json['lastSyncTime'] == null
          ? null
          : DateTime.parse(json['lastSyncTime'] as String),
      lastResult: $enumDecode(_$SyncResultEnumMap, json['lastResult']),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$HealthSyncStatusToJson(_HealthSyncStatus instance) =>
    <String, dynamic>{
      'dataType': _$HealthDataTypeEnumMap[instance.dataType]!,
      'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
      'lastResult': _$SyncResultEnumMap[instance.lastResult]!,
      'retryCount': instance.retryCount,
      'errorMessage': instance.errorMessage,
    };

const _$HealthDataTypeEnumMap = {
  HealthDataType.workout: 'workout',
  HealthDataType.bodyWeight: 'bodyWeight',
  HealthDataType.bodyFat: 'bodyFat',
  HealthDataType.leanMass: 'leanMass',
  HealthDataType.heartRate: 'heartRate',
  HealthDataType.sleep: 'sleep',
  HealthDataType.nutrition: 'nutrition',
};

const _$SyncResultEnumMap = {
  SyncResult.idle: 'idle',
  SyncResult.syncing: 'syncing',
  SyncResult.success: 'success',
  SyncResult.error: 'error',
};
