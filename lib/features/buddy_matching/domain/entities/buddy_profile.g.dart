// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuddyProfileImpl _$$BuddyProfileImplFromJson(Map<String, dynamic> json) =>
    _$BuddyProfileImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      preferences: BuddyPreferences.fromJson(
          json['preferences'] as Map<String, dynamic>),
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$BadgeTypeEnumMap, e))
              .toList() ??
          const [],
      partnershipsCount: (json['partnershipsCount'] as num?)?.toInt() ?? 0,
      successfulPartnerships:
          (json['successfulPartnerships'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      currentPartnershipId: json['currentPartnershipId'] as String?,
      partnershipStartDate: json['partnershipStartDate'] == null
          ? null
          : DateTime.parse(json['partnershipStartDate'] as String),
      likedProfiles: (json['likedProfiles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dislikedProfiles: (json['dislikedProfiles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mutualMatches: (json['mutualMatches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      superLikesRemaining: (json['superLikesRemaining'] as num?)?.toInt() ?? 3,
      lastSuperLikeReset: json['lastSuperLikeReset'] == null
          ? null
          : DateTime.parse(json['lastSuperLikeReset'] as String),
      boostExpiry: json['boostExpiry'] == null
          ? null
          : DateTime.parse(json['boostExpiry'] as String),
      isBoosted: json['isBoosted'] as bool? ?? false,
      reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
      isBanned: json['isBanned'] as bool? ?? false,
      isPhotoVerified: json['isPhotoVerified'] as bool? ?? false,
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reportedUsers: (json['reportedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      workoutTogetherIds: (json['workoutTogetherIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedWorkoutsTogether:
          (json['completedWorkoutsTogether'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BuddyProfileImplToJson(_$BuddyProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'preferences': instance.preferences.toJson(),
      'badges': instance.badges.map((e) => _$BadgeTypeEnumMap[e]!).toList(),
      'partnershipsCount': instance.partnershipsCount,
      'successfulPartnerships': instance.successfulPartnerships,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
      'totalWorkouts': instance.totalWorkouts,
      'totalVolume': instance.totalVolume,
      'currentPartnershipId': instance.currentPartnershipId,
      'partnershipStartDate': instance.partnershipStartDate?.toIso8601String(),
      'likedProfiles': instance.likedProfiles,
      'dislikedProfiles': instance.dislikedProfiles,
      'mutualMatches': instance.mutualMatches,
      'superLikesRemaining': instance.superLikesRemaining,
      'lastSuperLikeReset': instance.lastSuperLikeReset?.toIso8601String(),
      'boostExpiry': instance.boostExpiry?.toIso8601String(),
      'isBoosted': instance.isBoosted,
      'reportCount': instance.reportCount,
      'isBanned': instance.isBanned,
      'isPhotoVerified': instance.isPhotoVerified,
      'blockedUsers': instance.blockedUsers,
      'reportedUsers': instance.reportedUsers,
      'workoutTogetherIds': instance.workoutTogetherIds,
      'completedWorkoutsTogether': instance.completedWorkoutsTogether,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$BadgeTypeEnumMap = {
  BadgeType.workoutBuddy: 'workoutBuddy',
  BadgeType.consistentPartner: 'consistentPartner',
  BadgeType.motivator: 'motivator',
  BadgeType.newbie: 'newbie',
  BadgeType.veteran: 'veteran',
  BadgeType.verified: 'verified',
  BadgeType.instagramVerified: 'instagramVerified',
  BadgeType.superLiker: 'superLiker',
  BadgeType.earlyAdopter: 'earlyAdopter',
};
