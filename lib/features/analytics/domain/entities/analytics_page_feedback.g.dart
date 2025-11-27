// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_page_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsPageFeedback _$AnalyticsPageFeedbackFromJson(
  Map<String, dynamic> json,
) => _AnalyticsPageFeedback(
  id: json['id'] as String,
  userId: json['userId'] as String,
  isHelpful: json['isHelpful'] as bool,
  comment: json['comment'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  totalWorkoutsViewed: (json['totalWorkoutsViewed'] as num?)?.toInt(),
  lastViewedSection: json['lastViewedSection'] as String?,
  deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AnalyticsPageFeedbackToJson(
  _AnalyticsPageFeedback instance,
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
