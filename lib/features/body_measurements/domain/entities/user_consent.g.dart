// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_consent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserConsentImpl _$$UserConsentImplFromJson(Map<String, dynamic> json) =>
    _$UserConsentImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      groupConsents: (json['groupConsents'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          $enumDecode(_$MetricGroupEnumMap, k),
          $enumDecode(_$ConsentStateEnumMap, e),
        ),
      ),
      consentVersion: (json['consentVersion'] as num).toInt(),
      acceptedAt: DateTime.parse(json['acceptedAt'] as String),
      ipAddress: json['ipAddress'] as String,
      essentialGrantedAt: json['essentialGrantedAt'] == null
          ? null
          : DateTime.parse(json['essentialGrantedAt'] as String),
      measurementsGrantedAt: json['measurementsGrantedAt'] == null
          ? null
          : DateTime.parse(json['measurementsGrantedAt'] as String),
      vitalsGrantedAt: json['vitalsGrantedAt'] == null
          ? null
          : DateTime.parse(json['vitalsGrantedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isRevoked: json['isRevoked'] as bool? ?? false,
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      userAgent: json['userAgent'] as String?,
    );

Map<String, dynamic> _$$UserConsentImplToJson(
  _$UserConsentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'groupConsents': instance.groupConsents.map(
    (k, e) => MapEntry(_$MetricGroupEnumMap[k]!, _$ConsentStateEnumMap[e]!),
  ),
  'consentVersion': instance.consentVersion,
  'acceptedAt': instance.acceptedAt.toIso8601String(),
  'ipAddress': instance.ipAddress,
  'essentialGrantedAt': instance.essentialGrantedAt?.toIso8601String(),
  'measurementsGrantedAt': instance.measurementsGrantedAt?.toIso8601String(),
  'vitalsGrantedAt': instance.vitalsGrantedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isRevoked': instance.isRevoked,
  'revokedAt': instance.revokedAt?.toIso8601String(),
  'userAgent': instance.userAgent,
};

const _$ConsentStateEnumMap = {
  ConsentState.notAsked: 'notAsked',
  ConsentState.denied: 'denied',
  ConsentState.granted: 'granted',
};

const _$MetricGroupEnumMap = {
  MetricGroup.essential: 'essential',
  MetricGroup.measurements: 'measurements',
  MetricGroup.vitals: 'vitals',
};

_$AuditLogImpl _$$AuditLogImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ipAddress'] as String,
      affectedMetrics: (json['affectedMetrics'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MetricTypeEnumMap, e))
          .toList(),
      actionDetails: json['actionDetails'] as String?,
      previousHash: json['previousHash'] as String?,
      hash: json['hash'] as String?,
      userAgent: json['userAgent'] as String?,
      platform: json['platform'] as String?,
      appVersion: json['appVersion'] as String?,
    );

Map<String, dynamic> _$$AuditLogImplToJson(_$AuditLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'ipAddress': instance.ipAddress,
      'affectedMetrics': instance.affectedMetrics
          ?.map((e) => _$MetricTypeEnumMap[e]!)
          .toList(),
      'actionDetails': instance.actionDetails,
      'previousHash': instance.previousHash,
      'hash': instance.hash,
      'userAgent': instance.userAgent,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
    };

const _$AuditActionEnumMap = {
  AuditAction.dataAccess: 'dataAccess',
  AuditAction.dataExport: 'dataExport',
  AuditAction.dataDelete: 'dataDelete',
  AuditAction.consentChange: 'consentChange',
  AuditAction.measurementCreated: 'measurementCreated',
  AuditAction.measurementUpdated: 'measurementUpdated',
  AuditAction.healthPlatformSync: 'healthPlatformSync',
  AuditAction.keyRotation: 'keyRotation',
  AuditAction.privacyPolicyAccepted: 'privacyPolicyAccepted',
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
