// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EncryptedMeasurement _$EncryptedMeasurementFromJson(
  Map<String, dynamic> json,
) => _EncryptedMeasurement(
  id: json['id'] as String,
  userId: json['userId'] as String,
  metricType: json['metricType'] as String,
  encryptedData: json['encryptedData'] as String,
  iv: json['iv'] as String,
  tag: json['tag'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EncryptedMeasurementToJson(
  _EncryptedMeasurement instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'metricType': instance.metricType,
  'encryptedData': instance.encryptedData,
  'iv': instance.iv,
  'tag': instance.tag,
  'timestamp': instance.timestamp.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_EncryptionMetadata _$EncryptionMetadataFromJson(Map<String, dynamic> json) =>
    _EncryptionMetadata(
      keyVersion: (json['keyVersion'] as num).toInt(),
      keyGeneratedAt: DateTime.parse(json['keyGeneratedAt'] as String),
      keyLastRotated: json['keyLastRotated'] == null
          ? null
          : DateTime.parse(json['keyLastRotated'] as String),
      keyRotationScheduled: json['keyRotationScheduled'] == null
          ? null
          : DateTime.parse(json['keyRotationScheduled'] as String),
      algorithm: json['algorithm'] as String? ?? 'AES-256-GCM',
      keyDerivationFunction: json['keyDerivationFunction'] as String?,
    );

Map<String, dynamic> _$EncryptionMetadataToJson(_EncryptionMetadata instance) =>
    <String, dynamic>{
      'keyVersion': instance.keyVersion,
      'keyGeneratedAt': instance.keyGeneratedAt.toIso8601String(),
      'keyLastRotated': instance.keyLastRotated?.toIso8601String(),
      'keyRotationScheduled': instance.keyRotationScheduled?.toIso8601String(),
      'algorithm': instance.algorithm,
      'keyDerivationFunction': instance.keyDerivationFunction,
    };
