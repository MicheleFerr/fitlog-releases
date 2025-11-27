// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnifiedFeedback _$UnifiedFeedbackFromJson(Map<String, dynamic> json) =>
    _UnifiedFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$UnifiedFeedbackTypeEnumMap, json['type']),
      status: $enumDecode(_$UnifiedFeedbackStatusEnumMap, json['status']),
      severity: $enumDecode(_$FeedbackSeverityEnumMap, json['severity']),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      adminNotes: json['adminNotes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      userEmail: json['userEmail'] as String?,
      userDisplayName: json['userDisplayName'] as String?,
    );

Map<String, dynamic> _$UnifiedFeedbackToJson(_UnifiedFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$UnifiedFeedbackTypeEnumMap[instance.type]!,
      'status': _$UnifiedFeedbackStatusEnumMap[instance.status]!,
      'severity': _$FeedbackSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'adminNotes': instance.adminNotes,
      'metadata': instance.metadata,
      'userEmail': instance.userEmail,
      'userDisplayName': instance.userDisplayName,
    };

const _$UnifiedFeedbackTypeEnumMap = {
  UnifiedFeedbackType.exercise: 'exercise',
  UnifiedFeedbackType.aiInsight: 'aiInsight',
  UnifiedFeedbackType.analytics: 'analytics',
  UnifiedFeedbackType.buddyReport: 'buddyReport',
  UnifiedFeedbackType.general: 'general',
  UnifiedFeedbackType.exercisePatch: 'exercisePatch',
};

const _$UnifiedFeedbackStatusEnumMap = {
  UnifiedFeedbackStatus.open: 'open',
  UnifiedFeedbackStatus.reviewing: 'reviewing',
  UnifiedFeedbackStatus.resolved: 'resolved',
  UnifiedFeedbackStatus.dismissed: 'dismissed',
  UnifiedFeedbackStatus.closed: 'closed',
};

const _$FeedbackSeverityEnumMap = {
  FeedbackSeverity.low: 'low',
  FeedbackSeverity.medium: 'medium',
  FeedbackSeverity.high: 'high',
  FeedbackSeverity.critical: 'critical',
};
