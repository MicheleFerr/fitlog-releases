// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionnaireAnalytics _$QuestionnaireAnalyticsFromJson(
  Map<String, dynamic> json,
) => _QuestionnaireAnalytics(
  userId: json['userId'] as String,
  startedAt: DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  lastStepReached: (json['lastStepReached'] as num?)?.toInt() ?? 0,
  totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 7,
  stepDurations:
      (json['stepDurations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ) ??
      const {},
  wasAbandoned: json['wasAbandoned'] as bool?,
  stepFeedback:
      (json['stepFeedback'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as num?)?.toInt()),
      ) ??
      const {},
  totalDurationSeconds: (json['totalDurationSeconds'] as num?)?.toInt(),
  platform: json['platform'] as String?,
  appVersion: json['appVersion'] as String?,
);

Map<String, dynamic> _$QuestionnaireAnalyticsToJson(
  _QuestionnaireAnalytics instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'startedAt': instance.startedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'lastStepReached': instance.lastStepReached,
  'totalSteps': instance.totalSteps,
  'stepDurations': instance.stepDurations.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'wasAbandoned': instance.wasAbandoned,
  'stepFeedback': instance.stepFeedback.map(
    (k, e) => MapEntry(k.toString(), e),
  ),
  'totalDurationSeconds': instance.totalDurationSeconds,
  'platform': instance.platform,
  'appVersion': instance.appVersion,
};
