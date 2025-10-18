// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strength_standard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrengthStandardImpl _$$StrengthStandardImplFromJson(
        Map<String, dynamic> json) =>
    _$StrengthStandardImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      keywords:
          (json['keywords'] as List<dynamic>).map((e) => e as String).toList(),
      equipment: json['equipment'] as String,
      muscleGroups: (json['muscleGroups'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dataSource: json['dataSource'] as String,
      bodyweightTable: (json['bodyweightTable'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, (e as num).toDouble()),
            )),
      ),
      bodyweightMultipliers:
          (json['bodyweightMultipliers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      isBodyweightExercise: json['isBodyweightExercise'] as bool? ?? false,
    );

Map<String, dynamic> _$$StrengthStandardImplToJson(
        _$StrengthStandardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'keywords': instance.keywords,
      'equipment': instance.equipment,
      'muscleGroups': instance.muscleGroups,
      'dataSource': instance.dataSource,
      'bodyweightTable': instance.bodyweightTable,
      'bodyweightMultipliers': instance.bodyweightMultipliers,
      'isBodyweightExercise': instance.isBodyweightExercise,
    };
