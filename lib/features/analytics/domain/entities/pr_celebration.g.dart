// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_celebration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PRCelebrationImpl _$$PRCelebrationImplFromJson(Map<String, dynamic> json) =>
    _$PRCelebrationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      prId: json['prId'] as String,
      prType: $enumDecode(_$PRTypeEnumMap, json['prType']),
      celebratedAt: DateTime.parse(json['celebratedAt'] as String),
      engagement:
          $enumDecode(_$CelebrationEngagementEnumMap, json['engagement']),
      previousValue: (json['previousValue'] as num).toDouble(),
      newValue: (json['newValue'] as num).toDouble(),
      exerciseName: json['exerciseName'] as String?,
      notificationSent: json['notificationSent'] as bool? ?? false,
      notificationSentAt: json['notificationSentAt'] == null
          ? null
          : DateTime.parse(json['notificationSentAt'] as String),
    );

Map<String, dynamic> _$$PRCelebrationImplToJson(_$PRCelebrationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'prId': instance.prId,
      'prType': _$PRTypeEnumMap[instance.prType]!,
      'celebratedAt': instance.celebratedAt.toIso8601String(),
      'engagement': _$CelebrationEngagementEnumMap[instance.engagement]!,
      'previousValue': instance.previousValue,
      'newValue': instance.newValue,
      'exerciseName': instance.exerciseName,
      'notificationSent': instance.notificationSent,
      'notificationSentAt': instance.notificationSentAt?.toIso8601String(),
    };

const _$PRTypeEnumMap = {
  PRType.weight: 'weight',
  PRType.volume: 'volume',
  PRType.reps: 'reps',
  PRType.duration: 'duration',
  PRType.oneRM: 'oneRM',
  PRType.totalSets: 'totalSets',
};

const _$CelebrationEngagementEnumMap = {
  CelebrationEngagement.viewed: 'viewed',
  CelebrationEngagement.shared: 'shared',
  CelebrationEngagement.dismissed: 'dismissed',
};
