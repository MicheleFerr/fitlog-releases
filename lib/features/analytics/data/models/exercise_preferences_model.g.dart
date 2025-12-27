// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExercisePreferencesModel _$ExercisePreferencesModelFromJson(
  Map<String, dynamic> json,
) => _ExercisePreferencesModel(
  favorites:
      (json['favorites'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  countingModeOverrides:
      (json['countingModeOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  lastUpdated: const TimestampConverter().fromJson(json['lastUpdated']),
);

Map<String, dynamic> _$ExercisePreferencesModelToJson(
  _ExercisePreferencesModel instance,
) => <String, dynamic>{
  'favorites': instance.favorites,
  'countingModeOverrides': instance.countingModeOverrides,
  'lastUpdated': const TimestampConverter().toJson(instance.lastUpdated),
};
