// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frequency_cap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FrequencyCapImpl _$$FrequencyCapImplFromJson(Map<String, dynamic> json) =>
    _$FrequencyCapImpl(
      maxPerDay: (json['maxPerDay'] as num?)?.toInt() ?? 3,
      maxPerWeek: (json['maxPerWeek'] as num?)?.toInt() ?? 5,
      minIntervalHours: (json['minIntervalHours'] as num?)?.toInt() ?? 2,
    );

Map<String, dynamic> _$$FrequencyCapImplToJson(_$FrequencyCapImpl instance) =>
    <String, dynamic>{
      'maxPerDay': instance.maxPerDay,
      'maxPerWeek': instance.maxPerWeek,
      'minIntervalHours': instance.minIntervalHours,
    };
