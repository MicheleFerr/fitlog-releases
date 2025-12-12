// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SleepRecord _$SleepRecordFromJson(Map<String, dynamic> json) => _SleepRecord(
  date: DateTime.parse(json['date'] as String),
  asleepDuration: Duration(
    microseconds: (json['asleepDuration'] as num).toInt(),
  ),
  inBedDuration: Duration(microseconds: (json['inBedDuration'] as num).toInt()),
  efficiency: (json['efficiency'] as num).toDouble(),
  quality: $enumDecode(_$SleepQualityEnumMap, json['quality']),
  source: json['source'] as String?,
);

Map<String, dynamic> _$SleepRecordToJson(_SleepRecord instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'asleepDuration': instance.asleepDuration.inMicroseconds,
      'inBedDuration': instance.inBedDuration.inMicroseconds,
      'efficiency': instance.efficiency,
      'quality': _$SleepQualityEnumMap[instance.quality]!,
      'source': instance.source,
    };

const _$SleepQualityEnumMap = {
  SleepQuality.critical: 'critical',
  SleepQuality.suboptimal: 'suboptimal',
  SleepQuality.optimal: 'optimal',
  SleepQuality.excessive: 'excessive',
};
