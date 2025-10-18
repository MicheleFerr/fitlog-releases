// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutinePatternImpl _$$RoutinePatternImplFromJson(Map<String, dynamic> json) =>
    _$RoutinePatternImpl(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sequence:
          (json['sequence'] as List<dynamic>).map((e) => e as String).toList(),
      type: $enumDecodeNullable(_$PatternTypeEnumMap, json['type']) ??
          PatternType.repeating,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 1,
      startWeekday: (json['startWeekday'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RoutinePatternImplToJson(
        _$RoutinePatternImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'sequence': instance.sequence,
      'type': _$PatternTypeEnumMap[instance.type]!,
      'repetitions': instance.repetitions,
      'startWeekday': instance.startWeekday,
    };

const _$PatternTypeEnumMap = {
  PatternType.repeating: 'repeating',
  PatternType.fixed: 'fixed',
  PatternType.custom: 'custom',
};
