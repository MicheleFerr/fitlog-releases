// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedbackData _$FeedbackDataFromJson(Map<String, dynamic> json) =>
    _FeedbackData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      insightId: json['insightId'] as String,
      insightType: json['insightType'] as String,
      insightCategory: json['insightCategory'] as String,
      feedbackType: $enumDecode(_$FeedbackTypeEnumMap, json['feedbackType']),
      dismissReason: $enumDecodeNullable(
        _$DismissReasonEnumMap,
        json['dismissReason'],
      ),
      comment: json['comment'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      viewDurationSeconds: (json['viewDurationSeconds'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FeedbackDataToJson(_FeedbackData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'insightId': instance.insightId,
      'insightType': instance.insightType,
      'insightCategory': instance.insightCategory,
      'feedbackType': _$FeedbackTypeEnumMap[instance.feedbackType]!,
      'dismissReason': _$DismissReasonEnumMap[instance.dismissReason],
      'comment': instance.comment,
      'timestamp': instance.timestamp.toIso8601String(),
      'viewDurationSeconds': instance.viewDurationSeconds,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.helpful: 'helpful',
  FeedbackType.notHelpful: 'notHelpful',
  FeedbackType.dismissed: 'dismissed',
  FeedbackType.actedUpon: 'actedUpon',
};

const _$DismissReasonEnumMap = {
  DismissReason.alreadyKnow: 'alreadyKnow',
  DismissReason.notRelevant: 'notRelevant',
  DismissReason.incorrect: 'incorrect',
  DismissReason.tooAdvanced: 'tooAdvanced',
  DismissReason.tooBasic: 'tooBasic',
  DismissReason.notInterested: 'notInterested',
  DismissReason.other: 'other',
};

_FeedbackStats _$FeedbackStatsFromJson(Map<String, dynamic> json) =>
    _FeedbackStats(
      identifier: json['identifier'] as String,
      totalFeedback: (json['totalFeedback'] as num?)?.toInt() ?? 0,
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      notHelpfulCount: (json['notHelpfulCount'] as num?)?.toInt() ?? 0,
      dismissedCount: (json['dismissedCount'] as num?)?.toInt() ?? 0,
      actedUponCount: (json['actedUponCount'] as num?)?.toInt() ?? 0,
      avgViewDuration: (json['avgViewDuration'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$FeedbackStatsToJson(_FeedbackStats instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'totalFeedback': instance.totalFeedback,
      'helpfulCount': instance.helpfulCount,
      'notHelpfulCount': instance.notHelpfulCount,
      'dismissedCount': instance.dismissedCount,
      'actedUponCount': instance.actedUponCount,
      'avgViewDuration': instance.avgViewDuration,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
