// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFeedback _$UserFeedbackFromJson(Map<String, dynamic> json) =>
    _UserFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      category: $enumDecode(_$FeedbackCategoryEnumMap, json['category']),
      status: $enumDecode(_$FeedbackStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      rating: (json['rating'] as num?)?.toInt(),
      userEmail: json['userEmail'] as String?,
      userDisplayName: json['userDisplayName'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      appVersion: json['appVersion'] as String?,
      screenshotUrl: json['screenshotUrl'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      adminNotes: json['adminNotes'] as String?,
    );

Map<String, dynamic> _$UserFeedbackToJson(_UserFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'message': instance.message,
      'category': _$FeedbackCategoryEnumMap[instance.category]!,
      'status': _$FeedbackStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'rating': instance.rating,
      'userEmail': instance.userEmail,
      'userDisplayName': instance.userDisplayName,
      'deviceInfo': instance.deviceInfo,
      'appVersion': instance.appVersion,
      'screenshotUrl': instance.screenshotUrl,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'adminNotes': instance.adminNotes,
    };

const _$FeedbackCategoryEnumMap = {
  FeedbackCategory.bug: 'bug',
  FeedbackCategory.feature: 'feature',
  FeedbackCategory.improvement: 'improvement',
  FeedbackCategory.praise: 'praise',
  FeedbackCategory.other: 'other',
};

const _$FeedbackStatusEnumMap = {
  FeedbackStatus.newFeedback: 'newFeedback',
  FeedbackStatus.reviewed: 'reviewed',
  FeedbackStatus.resolved: 'resolved',
  FeedbackStatus.dismissed: 'dismissed',
};
