// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_distribution_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MuscleDistributionData _$MuscleDistributionDataFromJson(
  Map<String, dynamic> json,
) => _MuscleDistributionData(
  volumeByMuscle: (json['volumeByMuscle'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$MuscleGroupEnumMap, k), (e as num).toDouble()),
  ),
  setsByMuscle: (json['setsByMuscle'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$MuscleGroupEnumMap, k), (e as num).toInt()),
  ),
  volumePercentage: (json['volumePercentage'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$MuscleGroupEnumMap, k), (e as num).toDouble()),
  ),
  period: $enumDecode(_$TimePeriodEnumMap, json['period']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$MuscleDistributionDataToJson(
  _MuscleDistributionData instance,
) => <String, dynamic>{
  'volumeByMuscle': instance.volumeByMuscle.map(
    (k, e) => MapEntry(_$MuscleGroupEnumMap[k]!, e),
  ),
  'setsByMuscle': instance.setsByMuscle.map(
    (k, e) => MapEntry(_$MuscleGroupEnumMap[k]!, e),
  ),
  'volumePercentage': instance.volumePercentage.map(
    (k, e) => MapEntry(_$MuscleGroupEnumMap[k]!, e),
  ),
  'period': _$TimePeriodEnumMap[instance.period]!,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};

const _$MuscleGroupEnumMap = {
  MuscleGroup.schiena: 'schiena',
  MuscleGroup.petto: 'petto',
  MuscleGroup.addome: 'addome',
  MuscleGroup.spalle: 'spalle',
  MuscleGroup.braccia: 'braccia',
  MuscleGroup.gambe: 'gambe',
};

const _$TimePeriodEnumMap = {
  TimePeriod.last7Days: 'last_7_days',
  TimePeriod.last30Days: 'last_30_days',
  TimePeriod.last90Days: 'last_90_days',
  TimePeriod.last6Months: 'last_6_months',
  TimePeriod.lastYear: 'last_year',
  TimePeriod.allTime: 'all_time',
};

_PeriodStatistics _$PeriodStatisticsFromJson(Map<String, dynamic> json) =>
    _PeriodStatistics(
      workoutsCount: (json['workoutsCount'] as num).toInt(),
      totalDurationMinutes: (json['totalDurationMinutes'] as num).toInt(),
      totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
      totalSets: (json['totalSets'] as num).toInt(),
      period: $enumDecode(_$TimePeriodEnumMap, json['period']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$PeriodStatisticsToJson(_PeriodStatistics instance) =>
    <String, dynamic>{
      'workoutsCount': instance.workoutsCount,
      'totalDurationMinutes': instance.totalDurationMinutes,
      'totalVolumeKg': instance.totalVolumeKg,
      'totalSets': instance.totalSets,
      'period': _$TimePeriodEnumMap[instance.period]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

_MuscleAnalyticsData _$MuscleAnalyticsDataFromJson(Map<String, dynamic> json) =>
    _MuscleAnalyticsData(
      current: MuscleDistributionData.fromJson(
        json['current'] as Map<String, dynamic>,
      ),
      previous: MuscleDistributionData.fromJson(
        json['previous'] as Map<String, dynamic>,
      ),
      currentStats: PeriodStatistics.fromJson(
        json['currentStats'] as Map<String, dynamic>,
      ),
      previousStats: PeriodStatistics.fromJson(
        json['previousStats'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MuscleAnalyticsDataToJson(
  _MuscleAnalyticsData instance,
) => <String, dynamic>{
  'current': instance.current.toJson(),
  'previous': instance.previous.toJson(),
  'currentStats': instance.currentStats.toJson(),
  'previousStats': instance.previousStats.toJson(),
};
