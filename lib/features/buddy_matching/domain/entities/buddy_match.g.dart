// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuddyMatchImpl _$$BuddyMatchImplFromJson(Map<String, dynamic> json) =>
    _$BuddyMatchImpl(
      id: json['id'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      status: $enumDecode(_$MatchStatusEnumMap, json['status']),
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      initiatorId: json['initiatorId'] as String?,
      user1LikedAt: json['user1LikedAt'] == null
          ? null
          : DateTime.parse(json['user1LikedAt'] as String),
      user2LikedAt: json['user2LikedAt'] == null
          ? null
          : DateTime.parse(json['user2LikedAt'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      partnershipStartedAt: json['partnershipStartedAt'] == null
          ? null
          : DateTime.parse(json['partnershipStartedAt'] as String),
      partnershipEndedAt: json['partnershipEndedAt'] == null
          ? null
          : DateTime.parse(json['partnershipEndedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      sharedWorkouts: (json['sharedWorkouts'] as num?)?.toInt() ?? 0,
      plannedWorkouts: (json['plannedWorkouts'] as num?)?.toInt() ?? 0,
      completedWorkouts: (json['completedWorkouts'] as num?)?.toInt() ?? 0,
      lastMessageId: json['lastMessageId'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      unreadCount1: (json['unreadCount1'] as num?)?.toInt() ?? 0,
      unreadCount2: (json['unreadCount2'] as num?)?.toInt() ?? 0,
      user1Rating: (json['user1Rating'] as num?)?.toInt(),
      user2Rating: (json['user2Rating'] as num?)?.toInt(),
      user1Feedback: json['user1Feedback'] as String?,
      user2Feedback: json['user2Feedback'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BuddyMatchImplToJson(_$BuddyMatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user1Id': instance.user1Id,
      'user2Id': instance.user2Id,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'compatibilityScore': instance.compatibilityScore,
      'initiatorId': instance.initiatorId,
      'user1LikedAt': instance.user1LikedAt?.toIso8601String(),
      'user2LikedAt': instance.user2LikedAt?.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'partnershipStartedAt': instance.partnershipStartedAt?.toIso8601String(),
      'partnershipEndedAt': instance.partnershipEndedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'sharedWorkouts': instance.sharedWorkouts,
      'plannedWorkouts': instance.plannedWorkouts,
      'completedWorkouts': instance.completedWorkouts,
      'lastMessageId': instance.lastMessageId,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCount1': instance.unreadCount1,
      'unreadCount2': instance.unreadCount2,
      'user1Rating': instance.user1Rating,
      'user2Rating': instance.user2Rating,
      'user1Feedback': instance.user1Feedback,
      'user2Feedback': instance.user2Feedback,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MatchStatusEnumMap = {
  MatchStatus.pending: 'pending',
  MatchStatus.confirmed: 'confirmed',
  MatchStatus.partnership: 'partnership',
  MatchStatus.completed: 'completed',
  MatchStatus.expired: 'expired',
  MatchStatus.cancelled: 'cancelled',
};
