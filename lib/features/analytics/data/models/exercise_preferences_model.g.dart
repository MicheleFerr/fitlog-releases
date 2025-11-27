// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExercisePreferencesModelImpl _$$ExercisePreferencesModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExercisePreferencesModelImpl(
  favorites:
      (json['favorites'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  lastUpdated: const TimestampConverter().fromJson(json['lastUpdated']),
);

Map<String, dynamic> _$$ExercisePreferencesModelImplToJson(
  _$ExercisePreferencesModelImpl instance,
) => <String, dynamic>{
  'favorites': instance.favorites,
  'lastUpdated': const TimestampConverter().toJson(instance.lastUpdated),
};
