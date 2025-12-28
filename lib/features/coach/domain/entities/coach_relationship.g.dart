// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_relationship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachPermissions _$CoachPermissionsFromJson(Map<String, dynamic> json) =>
    _CoachPermissions(
      canViewDashboard: json['canViewDashboard'] as bool? ?? true,
      canEditWorkout: json['canEditWorkout'] as bool? ?? true,
      canViewHealth: json['canViewHealth'] as bool? ?? false,
      canViewMeasurements: json['canViewMeasurements'] as bool? ?? false,
    );

Map<String, dynamic> _$CoachPermissionsToJson(_CoachPermissions instance) =>
    <String, dynamic>{
      'canViewDashboard': instance.canViewDashboard,
      'canEditWorkout': instance.canEditWorkout,
      'canViewHealth': instance.canViewHealth,
      'canViewMeasurements': instance.canViewMeasurements,
    };

_CoachRelationship _$CoachRelationshipFromJson(Map<String, dynamic> json) =>
    _CoachRelationship(
      id: json['id'] as String,
      athleteId: json['athleteId'] as String,
      athleteEmail: json['athleteEmail'] as String?,
      athleteName: json['athleteName'] as String?,
      coachId: json['coachId'] as String?,
      coachEmail: json['coachEmail'] as String,
      coachName: json['coachName'] as String?,
      status:
          $enumDecodeNullable(_$RelationshipStatusEnumMap, json['status']) ??
          RelationshipStatus.pending,
      athleteHasApp: json['athleteHasApp'] as bool? ?? true,
      permissions: json['permissions'] == null
          ? const CoachPermissions()
          : CoachPermissions.fromJson(
              json['permissions'] as Map<String, dynamic>,
            ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      connectedAt: json['connectedAt'] == null
          ? null
          : DateTime.parse(json['connectedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      coachNotes: json['coachNotes'] as String?,
    );

Map<String, dynamic> _$CoachRelationshipToJson(_CoachRelationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'athleteId': instance.athleteId,
      'athleteEmail': instance.athleteEmail,
      'athleteName': instance.athleteName,
      'coachId': instance.coachId,
      'coachEmail': instance.coachEmail,
      'coachName': instance.coachName,
      'status': _$RelationshipStatusEnumMap[instance.status]!,
      'athleteHasApp': instance.athleteHasApp,
      'permissions': instance.permissions.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'connectedAt': instance.connectedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'coachNotes': instance.coachNotes,
    };

const _$RelationshipStatusEnumMap = {
  RelationshipStatus.pending: 'pending',
  RelationshipStatus.active: 'active',
  RelationshipStatus.paused: 'paused',
  RelationshipStatus.ended: 'ended',
};
