// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_mapping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseMappingImpl _$$ExerciseMappingImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseMappingImpl(
  gymbroId: json['gymbroId'] as String,
  gymbroName: json['gymbroName'] as String,
  gymbroEquipment: json['gymbroEquipment'] as String,
  gymbroFocus: json['gymbroFocus'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
  status: $enumDecode(_$MappingStatusEnumMap, json['status']),
  standardId: json['standardId'] as String?,
  standardName: json['standardName'] as String?,
  standardEquipment: json['standardEquipment'] as String?,
  dataSource: json['dataSource'] as String?,
  fallbackReason: json['fallbackReason'] as String?,
);

Map<String, dynamic> _$$ExerciseMappingImplToJson(
  _$ExerciseMappingImpl instance,
) => <String, dynamic>{
  'gymbroId': instance.gymbroId,
  'gymbroName': instance.gymbroName,
  'gymbroEquipment': instance.gymbroEquipment,
  'gymbroFocus': instance.gymbroFocus,
  'confidence': instance.confidence,
  'status': _$MappingStatusEnumMap[instance.status]!,
  'standardId': instance.standardId,
  'standardName': instance.standardName,
  'standardEquipment': instance.standardEquipment,
  'dataSource': instance.dataSource,
  'fallbackReason': instance.fallbackReason,
};

const _$MappingStatusEnumMap = {
  MappingStatus.auto: 'auto',
  MappingStatus.review: 'review',
  MappingStatus.fallback: 'fallback',
};
