// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutineAdherenceMetricsImpl _$$RoutineAdherenceMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$RoutineAdherenceMetricsImpl(
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      totalPlannedDays: (json['totalPlannedDays'] as num).toInt(),
      completedDays: (json['completedDays'] as num).toInt(),
      skippedDays: (json['skippedDays'] as num).toInt(),
      recoveredDays: (json['recoveredDays'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      templateDistribution:
          (json['templateDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      skipRate: (json['skipRate'] as num).toDouble(),
      recoveryRate: (json['recoveryRate'] as num).toDouble(),
      avgDaysBetweenWorkouts:
          (json['avgDaysBetweenWorkouts'] as num).toDouble(),
    );

Map<String, dynamic> _$$RoutineAdherenceMetricsImplToJson(
        _$RoutineAdherenceMetricsImpl instance) =>
    <String, dynamic>{
      'adherenceRate': instance.adherenceRate,
      'totalPlannedDays': instance.totalPlannedDays,
      'completedDays': instance.completedDays,
      'skippedDays': instance.skippedDays,
      'recoveredDays': instance.recoveredDays,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'templateDistribution': instance.templateDistribution,
      'skipRate': instance.skipRate,
      'recoveryRate': instance.recoveryRate,
      'avgDaysBetweenWorkouts': instance.avgDaysBetweenWorkouts,
    };

_$ScheduleMatchDataImpl _$$ScheduleMatchDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ScheduleMatchDataImpl(
      date: DateTime.parse(json['date'] as String),
      scheduledTemplateId: json['scheduledTemplateId'] as String?,
      actualTemplateId: json['actualTemplateId'] as String?,
      isMatch: json['isMatch'] as bool,
      isCompleted: json['isCompleted'] as bool,
      isSkipped: json['isSkipped'] as bool,
      isRecovered: json['isRecovered'] as bool,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
    );

Map<String, dynamic> _$$ScheduleMatchDataImplToJson(
        _$ScheduleMatchDataImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'scheduledTemplateId': instance.scheduledTemplateId,
      'actualTemplateId': instance.actualTemplateId,
      'isMatch': instance.isMatch,
      'isCompleted': instance.isCompleted,
      'isSkipped': instance.isSkipped,
      'isRecovered': instance.isRecovered,
      'dayOfWeek': instance.dayOfWeek,
    };

_$RoutineInsightImpl _$$RoutineInsightImplFromJson(Map<String, dynamic> json) =>
    _$RoutineInsightImpl(
      type: $enumDecode(_$RoutineInsightTypeEnumMap, json['type']),
      priority: (json['priority'] as num).toInt(),
      message: json['message'] as String,
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
      icon: json['icon'] as String?,
      isPositive: json['isPositive'] as bool,
    );

Map<String, dynamic> _$$RoutineInsightImplToJson(
        _$RoutineInsightImpl instance) =>
    <String, dynamic>{
      'type': _$RoutineInsightTypeEnumMap[instance.type]!,
      'priority': instance.priority,
      'message': instance.message,
      'actionLabel': instance.actionLabel,
      'actionRoute': instance.actionRoute,
      'icon': instance.icon,
      'isPositive': instance.isPositive,
    };

const _$RoutineInsightTypeEnumMap = {
  RoutineInsightType.consistency: 'consistency',
  RoutineInsightType.recovery: 'recovery',
  RoutineInsightType.performance: 'performance',
  RoutineInsightType.motivation: 'motivation',
  RoutineInsightType.warning: 'warning',
};

_$WeeklyAdherenceSummaryImpl _$$WeeklyAdherenceSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyAdherenceSummaryImpl(
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      plannedWorkouts: (json['plannedWorkouts'] as num).toInt(),
      completedWorkouts: (json['completedWorkouts'] as num).toInt(),
      skippedDays: (json['skippedDays'] as num).toInt(),
      recoveredDays: (json['recoveredDays'] as num).toInt(),
    );

Map<String, dynamic> _$$WeeklyAdherenceSummaryImplToJson(
        _$WeeklyAdherenceSummaryImpl instance) =>
    <String, dynamic>{
      'weekStart': instance.weekStart.toIso8601String(),
      'weekEnd': instance.weekEnd.toIso8601String(),
      'adherenceRate': instance.adherenceRate,
      'plannedWorkouts': instance.plannedWorkouts,
      'completedWorkouts': instance.completedWorkouts,
      'skippedDays': instance.skippedDays,
      'recoveredDays': instance.recoveredDays,
    };

_$DayOfWeekPatternImpl _$$DayOfWeekPatternImplFromJson(
        Map<String, dynamic> json) =>
    _$DayOfWeekPatternImpl(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      timesScheduled: (json['timesScheduled'] as num).toInt(),
      timesCompleted: (json['timesCompleted'] as num).toInt(),
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      skipRate: (json['skipRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$DayOfWeekPatternImplToJson(
        _$DayOfWeekPatternImpl instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'timesScheduled': instance.timesScheduled,
      'timesCompleted': instance.timesCompleted,
      'adherenceRate': instance.adherenceRate,
      'skipRate': instance.skipRate,
    };

_$RoutineAnalyticsStateImpl _$$RoutineAnalyticsStateImplFromJson(
        Map<String, dynamic> json) =>
    _$RoutineAnalyticsStateImpl(
      routineId: json['routineId'] as String,
      routineName: json['routineName'] as String,
      adherenceMetrics: RoutineAdherenceMetrics.fromJson(
          json['adherenceMetrics'] as Map<String, dynamic>),
      scheduleMatchData: (json['scheduleMatchData'] as List<dynamic>)
          .map((e) => ScheduleMatchData.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeklySummaries: (json['weeklySummaries'] as List<dynamic>)
          .map(
              (e) => WeeklyAdherenceSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      dayOfWeekPatterns: (json['dayOfWeekPatterns'] as List<dynamic>)
          .map((e) => DayOfWeekPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => RoutineInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$RoutineAnalyticsStateImplToJson(
        _$RoutineAnalyticsStateImpl instance) =>
    <String, dynamic>{
      'routineId': instance.routineId,
      'routineName': instance.routineName,
      'adherenceMetrics': instance.adherenceMetrics.toJson(),
      'scheduleMatchData':
          instance.scheduleMatchData.map((e) => e.toJson()).toList(),
      'weeklySummaries':
          instance.weeklySummaries.map((e) => e.toJson()).toList(),
      'dayOfWeekPatterns':
          instance.dayOfWeekPatterns.map((e) => e.toJson()).toList(),
      'insights': instance.insights.map((e) => e.toJson()).toList(),
      'isLoading': instance.isLoading,
      'error': instance.error,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
