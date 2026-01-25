// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
  id: json['id'] as String,
  userId: json['userId'] as String,
  badgeType: $enumDecode(_$BadgeTypeEnumMap, json['badgeType']),
  unlockedAt: DateTime.parse(json['unlockedAt'] as String),
  evidence: json['evidence'] as Map<String, dynamic>,
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'badgeType': _$BadgeTypeEnumMap[instance.badgeType]!,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
      'evidence': instance.evidence,
    };

const _$BadgeTypeEnumMap = {
  BadgeType.firstPR: 'firstPR',
  BadgeType.streakMaster7: 'streakMaster7',
  BadgeType.streakMaster14: 'streakMaster14',
  BadgeType.streakMaster30: 'streakMaster30',
  BadgeType.volumeLegend10k: 'volumeLegend10k',
  BadgeType.volumeLegend50k: 'volumeLegend50k',
  BadgeType.volumeLegend100k: 'volumeLegend100k',
  BadgeType.balancedBuilder: 'balancedBuilder',
  BadgeType.oneRepMonarch: 'oneRepMonarch',
  BadgeType.workoutCompletionist50: 'workoutCompletionist50',
  BadgeType.workoutCompletionist100: 'workoutCompletionist100',
  BadgeType.workoutCompletionist500: 'workoutCompletionist500',
  BadgeType.consistencyChampion: 'consistencyChampion',
};
