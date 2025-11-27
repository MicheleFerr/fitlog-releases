// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_page_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnalyticsPageFeedbackImpl _$$AnalyticsPageFeedbackImplFromJson(
  Map<String, dynamic> json,
) => _$AnalyticsPageFeedbackImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  isHelpful: json['isHelpful'] as bool,
  comment: json['comment'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  totalWorkoutsViewed: (json['totalWorkoutsViewed'] as num?)?.toInt(),
  lastViewedSection: json['lastViewedSection'] as String?,
  deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$AnalyticsPageFeedbackImplToJson(
  _$AnalyticsPageFeedbackImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'isHelpful': instance.isHelpful,
  'comment': instance.comment,
  'timestamp': instance.timestamp.toIso8601String(),
  'totalWorkoutsViewed': instance.totalWorkoutsViewed,
  'lastViewedSection': instance.lastViewedSection,
  'deviceInfo': instance.deviceInfo,
};
