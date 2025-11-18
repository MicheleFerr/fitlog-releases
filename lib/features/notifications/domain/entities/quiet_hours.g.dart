// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiet_hours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuietHoursImpl _$$QuietHoursImplFromJson(Map<String, dynamic> json) =>
    _$QuietHoursImpl(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      allowPriorityBypass: json['allowPriorityBypass'] as bool? ?? true,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$QuietHoursImplToJson(_$QuietHoursImpl instance) =>
    <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'allowPriorityBypass': instance.allowPriorityBypass,
      'daysOfWeek': instance.daysOfWeek,
    };
