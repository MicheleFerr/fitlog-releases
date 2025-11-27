// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakData _$StreakDataFromJson(Map<String, dynamic> json) => _StreakData(
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  lastWorkoutDate: json['lastWorkoutDate'] == null
      ? null
      : DateTime.parse(json['lastWorkoutDate'] as String),
  workedOutToday: json['workedOutToday'] as bool? ?? false,
  milestonesAchieved:
      (json['milestonesAchieved'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StreakDataToJson(_StreakData instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastWorkoutDate': instance.lastWorkoutDate?.toIso8601String(),
      'workedOutToday': instance.workedOutToday,
      'milestonesAchieved': instance.milestonesAchieved,
      'totalWorkouts': instance.totalWorkouts,
    };
