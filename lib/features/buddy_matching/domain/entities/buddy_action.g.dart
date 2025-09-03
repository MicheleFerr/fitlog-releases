// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuddyActionImpl _$$BuddyActionImplFromJson(Map<String, dynamic> json) =>
    _$BuddyActionImpl(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      actionType: $enumDecode(_$BuddyActionTypeEnumMap, json['actionType']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      reportReason:
          $enumDecodeNullable(_$ReportReasonEnumMap, json['reportReason']),
      reportDescription: json['reportDescription'] as String?,
      wasSuperLike: json['wasSuperLike'] as bool?,
      resultedInMatch: json['resultedInMatch'] as bool?,
    );

Map<String, dynamic> _$$BuddyActionImplToJson(_$BuddyActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromUserId': instance.fromUserId,
      'toUserId': instance.toUserId,
      'actionType': _$BuddyActionTypeEnumMap[instance.actionType]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'reportReason': _$ReportReasonEnumMap[instance.reportReason],
      'reportDescription': instance.reportDescription,
      'wasSuperLike': instance.wasSuperLike,
      'resultedInMatch': instance.resultedInMatch,
    };

const _$BuddyActionTypeEnumMap = {
  BuddyActionType.like: 'like',
  BuddyActionType.superLike: 'superLike',
  BuddyActionType.pass: 'pass',
  BuddyActionType.block: 'block',
  BuddyActionType.report: 'report',
};

const _$ReportReasonEnumMap = {
  ReportReason.inappropriatePhotos: 'inappropriatePhotos',
  ReportReason.harassment: 'harassment',
  ReportReason.spam: 'spam',
  ReportReason.fakeProfile: 'fakeProfile',
  ReportReason.underage: 'underage',
  ReportReason.other: 'other',
};
