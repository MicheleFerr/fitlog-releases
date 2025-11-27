// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Insight _$InsightFromJson(Map<String, dynamic> json) => _Insight(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$InsightTypeEnumMap, json['type']),
  priority: $enumDecode(_$InsightPriorityEnumMap, json['priority']),
  title: json['title'] as String,
  message: json['message'] as String,
  recommendation: json['recommendation'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  engagement: $enumDecodeNullable(
    _$InsightEngagementEnumMap,
    json['engagement'],
  ),
  actionTaken: json['actionTaken'] as String?,
  dismissedAt: json['dismissedAt'] == null
      ? null
      : DateTime.parse(json['dismissedAt'] as String),
  viewedAt: json['viewedAt'] == null
      ? null
      : DateTime.parse(json['viewedAt'] as String),
  actionTakenAt: json['actionTakenAt'] == null
      ? null
      : DateTime.parse(json['actionTakenAt'] as String),
);

Map<String, dynamic> _$InsightToJson(_Insight instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$InsightTypeEnumMap[instance.type]!,
  'priority': _$InsightPriorityEnumMap[instance.priority]!,
  'title': instance.title,
  'message': instance.message,
  'recommendation': instance.recommendation,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'metadata': instance.metadata,
  'engagement': _$InsightEngagementEnumMap[instance.engagement],
  'actionTaken': instance.actionTaken,
  'dismissedAt': instance.dismissedAt?.toIso8601String(),
  'viewedAt': instance.viewedAt?.toIso8601String(),
  'actionTakenAt': instance.actionTakenAt?.toIso8601String(),
};

const _$InsightTypeEnumMap = {
  InsightType.achievement: 'achievement',
  InsightType.warning: 'warning',
  InsightType.suggestion: 'suggestion',
  InsightType.improvement: 'improvement',
  InsightType.info: 'info',
  InsightType.motivation: 'motivation',
};

const _$InsightPriorityEnumMap = {
  InsightPriority.high: 'high',
  InsightPriority.medium: 'medium',
  InsightPriority.low: 'low',
};

const _$InsightEngagementEnumMap = {
  InsightEngagement.viewed: 'viewed',
  InsightEngagement.dismissed: 'dismissed',
  InsightEngagement.actionTaken: 'actionTaken',
};
