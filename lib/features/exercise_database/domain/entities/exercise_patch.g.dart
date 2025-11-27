// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExercisePatch _$ExercisePatchFromJson(Map<String, dynamic> json) =>
    _ExercisePatch(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      userId: json['userId'] as String,
      fieldName: json['fieldName'] as String,
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      originalValue: json['originalValue'],
      reason: json['reason'] as String,
      status: $enumDecode(_$PatchStatusEnumMap, json['status']),
      language: json['language'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      version: (json['version'] as num).toInt(),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      rejectedAt: json['rejectedAt'] == null
          ? null
          : DateTime.parse(json['rejectedAt'] as String),
      rejectReason: json['rejectReason'] as String?,
      adminNote: json['adminNote'] as String?,
      autoExpired: json['autoExpired'] as bool? ?? false,
      userEmail: json['userEmail'] as String?,
      userDisplayName: json['userDisplayName'] as String?,
    );

Map<String, dynamic> _$ExercisePatchToJson(_ExercisePatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'userId': instance.userId,
      'fieldName': instance.fieldName,
      'oldValue': instance.oldValue,
      'newValue': instance.newValue,
      'originalValue': instance.originalValue,
      'reason': instance.reason,
      'status': _$PatchStatusEnumMap[instance.status]!,
      'language': instance.language,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'version': instance.version,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'rejectReason': instance.rejectReason,
      'adminNote': instance.adminNote,
      'autoExpired': instance.autoExpired,
      'userEmail': instance.userEmail,
      'userDisplayName': instance.userDisplayName,
    };

const _$PatchStatusEnumMap = {
  PatchStatus.pending: 'pending',
  PatchStatus.approved: 'approved',
  PatchStatus.rejected: 'rejected',
  PatchStatus.autoRejected: 'autoRejected',
  PatchStatus.expired: 'expired',
};
