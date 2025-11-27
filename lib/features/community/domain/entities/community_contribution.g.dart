// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_contribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunityContribution _$CommunityContributionFromJson(
  Map<String, dynamic> json,
) => _CommunityContribution(
  id: json['id'] as String,
  exerciseId: json['exerciseId'] as String,
  exerciseName: json['exerciseName'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userAvatar: json['userAvatar'] as String?,
  type: $enumDecode(_$ContributionTypeEnumMap, json['type']),
  status: $enumDecode(_$ContributionStatusEnumMap, json['status']),
  title: json['title'] as String,
  description: json['description'] as String,
  originalValue: json['originalValue'] as String?,
  suggestedValue: json['suggestedValue'] as String?,
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
  upvotedBy:
      (json['upvotedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  downvotedBy:
      (json['downvotedBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => ContributionComment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  reviewNote: json['reviewNote'] as String?,
  reviewedBy: json['reviewedBy'] as String?,
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isFeatured: json['isFeatured'] as bool? ?? false,
  trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
  metadata: json['metadata'] as Map<String, dynamic>?,
  exerciseIds:
      (json['exerciseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  difficulty: json['difficulty'] as String? ?? 'beginner',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  applicableTo:
      (json['applicableTo'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  authorTier: json['authorTier'] as String?,
  authorTrustScore: (json['authorTrustScore'] as num?)?.toDouble() ?? 0.5,
  qualityScore: (json['qualityScore'] as num?)?.toDouble() ?? 0.5,
  saves: (json['saves'] as num?)?.toInt() ?? 0,
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  sourceType: json['sourceType'] as String?,
  relatedExerciseIds:
      (json['relatedExerciseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$CommunityContributionToJson(
  _CommunityContribution instance,
) => <String, dynamic>{
  'id': instance.id,
  'exerciseId': instance.exerciseId,
  'exerciseName': instance.exerciseName,
  'userId': instance.userId,
  'userName': instance.userName,
  'userAvatar': instance.userAvatar,
  'type': _$ContributionTypeEnumMap[instance.type]!,
  'status': _$ContributionStatusEnumMap[instance.status]!,
  'title': instance.title,
  'description': instance.description,
  'originalValue': instance.originalValue,
  'suggestedValue': instance.suggestedValue,
  'upvotes': instance.upvotes,
  'downvotes': instance.downvotes,
  'upvotedBy': instance.upvotedBy,
  'downvotedBy': instance.downvotedBy,
  'comments': instance.comments.map((e) => e.toJson()).toList(),
  'reviewNote': instance.reviewNote,
  'reviewedBy': instance.reviewedBy,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isFeatured': instance.isFeatured,
  'trustScore': instance.trustScore,
  'metadata': instance.metadata,
  'exerciseIds': instance.exerciseIds,
  'difficulty': instance.difficulty,
  'tags': instance.tags,
  'applicableTo': instance.applicableTo,
  'authorTier': instance.authorTier,
  'authorTrustScore': instance.authorTrustScore,
  'qualityScore': instance.qualityScore,
  'saves': instance.saves,
  'viewCount': instance.viewCount,
  'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
  'sourceType': instance.sourceType,
  'relatedExerciseIds': instance.relatedExerciseIds,
};

const _$ContributionTypeEnumMap = {
  ContributionType.correction: 'correction',
  ContributionType.tip: 'tip',
  ContributionType.warning: 'warning',
  ContributionType.variant: 'variant',
  ContributionType.translation: 'translation',
  ContributionType.technique: 'technique',
};

const _$ContributionStatusEnumMap = {
  ContributionStatus.pending: 'pending',
  ContributionStatus.approved: 'approved',
  ContributionStatus.rejected: 'rejected',
  ContributionStatus.underReview: 'underReview',
};

_ContributionComment _$ContributionCommentFromJson(Map<String, dynamic> json) =>
    _ContributionComment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedBy:
          (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ContributionCommentToJson(
  _ContributionComment instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userAvatar': instance.userAvatar,
  'text': instance.text,
  'createdAt': instance.createdAt.toIso8601String(),
  'likes': instance.likes,
  'likedBy': instance.likedBy,
};

_UserContributionStats _$UserContributionStatsFromJson(
  Map<String, dynamic> json,
) => _UserContributionStats(
  userId: json['userId'] as String,
  totalContributions: (json['totalContributions'] as num?)?.toInt() ?? 0,
  approvedContributions: (json['approvedContributions'] as num?)?.toInt() ?? 0,
  rejectedContributions: (json['rejectedContributions'] as num?)?.toInt() ?? 0,
  pendingContributions: (json['pendingContributions'] as num?)?.toInt() ?? 0,
  totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
  totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  level: json['level'] as String? ?? 'Rookie',
  badges:
      (json['badges'] as List<dynamic>?)
          ?.map((e) => ContributorBadge.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastContributionDate: json['lastContributionDate'] == null
      ? null
      : DateTime.parse(json['lastContributionDate'] as String),
  contributionsByType:
      (json['contributionsByType'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  approvalRate: (json['approvalRate'] as num?)?.toDouble() ?? 0.0,
  weeklyRank: (json['weeklyRank'] as num?)?.toInt() ?? 0,
  monthlyRank: (json['monthlyRank'] as num?)?.toInt() ?? 0,
  allTimeRank: (json['allTimeRank'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserContributionStatsToJson(
  _UserContributionStats instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'totalContributions': instance.totalContributions,
  'approvedContributions': instance.approvedContributions,
  'rejectedContributions': instance.rejectedContributions,
  'pendingContributions': instance.pendingContributions,
  'totalVotes': instance.totalVotes,
  'totalPoints': instance.totalPoints,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'level': instance.level,
  'badges': instance.badges.map((e) => e.toJson()).toList(),
  'lastContributionDate': instance.lastContributionDate?.toIso8601String(),
  'contributionsByType': instance.contributionsByType,
  'approvalRate': instance.approvalRate,
  'weeklyRank': instance.weeklyRank,
  'monthlyRank': instance.monthlyRank,
  'allTimeRank': instance.allTimeRank,
};

_ContributorBadge _$ContributorBadgeFromJson(Map<String, dynamic> json) =>
    _ContributorBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      isRare: json['isRare'] as bool? ?? false,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$ContributorBadgeToJson(_ContributorBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'isRare': instance.isRare,
      'category': instance.category,
    };
