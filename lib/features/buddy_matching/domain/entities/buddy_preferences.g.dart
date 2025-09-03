// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BuddyPreferencesImpl _$$BuddyPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$BuddyPreferencesImpl(
      isLookingForBuddy: json['isLookingForBuddy'] as bool? ?? false,
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 25.0,
      fitnessLevel:
          $enumDecodeNullable(_$FitnessLevelEnumMap, json['fitnessLevel']) ??
              FitnessLevel.intermediate,
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$WorkoutGoalEnumMap, e))
              .toList() ??
          const [],
      preferredTimes: (json['preferredTimes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PreferredTimeEnumMap, e))
              .toList() ??
          const [],
      preferredDays: (json['preferredDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      instagramHandle: json['instagramHandle'] as String?,
      bio: json['bio'] as String?,
      minAge: (json['minAge'] as num?)?.toInt() ?? 18,
      maxAge: (json['maxAge'] as num?)?.toInt() ?? 65,
      allowMessages: json['allowMessages'] as bool? ?? true,
      showOnMap: json['showOnMap'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      cityName: json['cityName'] as String?,
      cityCode: json['cityCode'] as String?,
      zoneName: json['zoneName'] as String?,
      lastLocationUpdate: json['lastLocationUpdate'] == null
          ? null
          : DateTime.parse(json['lastLocationUpdate'] as String),
      matchingPurpose: $enumDecodeNullable(
              _$MatchingPurposeEnumMap, json['matchingPurpose']) ??
          MatchingPurpose.workoutPartner,
      openToDating: json['openToDating'] as bool? ?? false,
      openToFriendship: json['openToFriendship'] as bool? ?? true,
      matchSameFitnessLevel: json['matchSameFitnessLevel'] as bool? ?? true,
      matchSameGoals: json['matchSameGoals'] as bool? ?? true,
      matchOnlyVerified: json['matchOnlyVerified'] as bool? ?? false,
      requireVerification: json['requireVerification'] as bool? ?? false,
      allowSuperLikes: json['allowSuperLikes'] as bool? ?? true,
      allowBoosts: json['allowBoosts'] as bool? ?? true,
    );

Map<String, dynamic> _$$BuddyPreferencesImplToJson(
        _$BuddyPreferencesImpl instance) =>
    <String, dynamic>{
      'isLookingForBuddy': instance.isLookingForBuddy,
      'maxDistance': instance.maxDistance,
      'fitnessLevel': _$FitnessLevelEnumMap[instance.fitnessLevel]!,
      'goals': instance.goals.map((e) => _$WorkoutGoalEnumMap[e]!).toList(),
      'preferredTimes': instance.preferredTimes
          .map((e) => _$PreferredTimeEnumMap[e]!)
          .toList(),
      'preferredDays': instance.preferredDays,
      'instagramHandle': instance.instagramHandle,
      'bio': instance.bio,
      'minAge': instance.minAge,
      'maxAge': instance.maxAge,
      'allowMessages': instance.allowMessages,
      'showOnMap': instance.showOnMap,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationName': instance.locationName,
      'cityName': instance.cityName,
      'cityCode': instance.cityCode,
      'zoneName': instance.zoneName,
      'lastLocationUpdate': instance.lastLocationUpdate?.toIso8601String(),
      'matchingPurpose': _$MatchingPurposeEnumMap[instance.matchingPurpose]!,
      'openToDating': instance.openToDating,
      'openToFriendship': instance.openToFriendship,
      'matchSameFitnessLevel': instance.matchSameFitnessLevel,
      'matchSameGoals': instance.matchSameGoals,
      'matchOnlyVerified': instance.matchOnlyVerified,
      'requireVerification': instance.requireVerification,
      'allowSuperLikes': instance.allowSuperLikes,
      'allowBoosts': instance.allowBoosts,
    };

const _$FitnessLevelEnumMap = {
  FitnessLevel.beginner: 'beginner',
  FitnessLevel.intermediate: 'intermediate',
  FitnessLevel.advanced: 'advanced',
  FitnessLevel.expert: 'expert',
};

const _$WorkoutGoalEnumMap = {
  WorkoutGoal.weightLoss: 'weightLoss',
  WorkoutGoal.muscleGain: 'muscleGain',
  WorkoutGoal.strength: 'strength',
  WorkoutGoal.endurance: 'endurance',
  WorkoutGoal.flexibility: 'flexibility',
  WorkoutGoal.general: 'general',
};

const _$PreferredTimeEnumMap = {
  PreferredTime.morning: 'morning',
  PreferredTime.midday: 'midday',
  PreferredTime.afternoon: 'afternoon',
  PreferredTime.evening: 'evening',
};

const _$MatchingPurposeEnumMap = {
  MatchingPurpose.workoutPartner: 'workoutPartner',
  MatchingPurpose.gymBuddy: 'gymBuddy',
  MatchingPurpose.both: 'both',
  MatchingPurpose.openToEverything: 'openToEverything',
};
