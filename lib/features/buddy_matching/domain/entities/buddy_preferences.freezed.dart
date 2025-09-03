// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuddyPreferences _$BuddyPreferencesFromJson(Map<String, dynamic> json) {
  return _BuddyPreferences.fromJson(json);
}

/// @nodoc
mixin _$BuddyPreferences {
  bool get isLookingForBuddy => throw _privateConstructorUsedError;
  double get maxDistance => throw _privateConstructorUsedError; // km
  FitnessLevel get fitnessLevel => throw _privateConstructorUsedError;
  List<WorkoutGoal> get goals => throw _privateConstructorUsedError;
  List<PreferredTime> get preferredTimes => throw _privateConstructorUsedError;
  List<String> get preferredDays =>
      throw _privateConstructorUsedError; // ['monday', 'tuesday', etc.]
  String? get instagramHandle => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  int get minAge => throw _privateConstructorUsedError;
  int get maxAge => throw _privateConstructorUsedError;
  bool get allowMessages => throw _privateConstructorUsedError;
  bool get showOnMap =>
      throw _privateConstructorUsedError; // Enhanced location system
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get locationName => throw _privateConstructorUsedError;
  String? get cityName => throw _privateConstructorUsedError;
  String? get cityCode =>
      throw _privateConstructorUsedError; // For Italian cities system
  String? get zoneName =>
      throw _privateConstructorUsedError; // For city zones/districts
  DateTime? get lastLocationUpdate =>
      throw _privateConstructorUsedError; // Multi-purpose matching
  MatchingPurpose get matchingPurpose => throw _privateConstructorUsedError;
  bool get openToDating => throw _privateConstructorUsedError; // Romance flag
  bool get openToFriendship =>
      throw _privateConstructorUsedError; // Friendship flag
// Matching preferences
  bool get matchSameFitnessLevel => throw _privateConstructorUsedError;
  bool get matchSameGoals => throw _privateConstructorUsedError;
  bool get matchOnlyVerified =>
      throw _privateConstructorUsedError; // Tier-1 preferences
  bool get requireVerification => throw _privateConstructorUsedError;
  bool get allowSuperLikes => throw _privateConstructorUsedError;
  bool get allowBoosts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BuddyPreferencesCopyWith<BuddyPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyPreferencesCopyWith<$Res> {
  factory $BuddyPreferencesCopyWith(
          BuddyPreferences value, $Res Function(BuddyPreferences) then) =
      _$BuddyPreferencesCopyWithImpl<$Res, BuddyPreferences>;
  @useResult
  $Res call(
      {bool isLookingForBuddy,
      double maxDistance,
      FitnessLevel fitnessLevel,
      List<WorkoutGoal> goals,
      List<PreferredTime> preferredTimes,
      List<String> preferredDays,
      String? instagramHandle,
      String? bio,
      int minAge,
      int maxAge,
      bool allowMessages,
      bool showOnMap,
      double? latitude,
      double? longitude,
      String? locationName,
      String? cityName,
      String? cityCode,
      String? zoneName,
      DateTime? lastLocationUpdate,
      MatchingPurpose matchingPurpose,
      bool openToDating,
      bool openToFriendship,
      bool matchSameFitnessLevel,
      bool matchSameGoals,
      bool matchOnlyVerified,
      bool requireVerification,
      bool allowSuperLikes,
      bool allowBoosts});
}

/// @nodoc
class _$BuddyPreferencesCopyWithImpl<$Res, $Val extends BuddyPreferences>
    implements $BuddyPreferencesCopyWith<$Res> {
  _$BuddyPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLookingForBuddy = null,
    Object? maxDistance = null,
    Object? fitnessLevel = null,
    Object? goals = null,
    Object? preferredTimes = null,
    Object? preferredDays = null,
    Object? instagramHandle = freezed,
    Object? bio = freezed,
    Object? minAge = null,
    Object? maxAge = null,
    Object? allowMessages = null,
    Object? showOnMap = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationName = freezed,
    Object? cityName = freezed,
    Object? cityCode = freezed,
    Object? zoneName = freezed,
    Object? lastLocationUpdate = freezed,
    Object? matchingPurpose = null,
    Object? openToDating = null,
    Object? openToFriendship = null,
    Object? matchSameFitnessLevel = null,
    Object? matchSameGoals = null,
    Object? matchOnlyVerified = null,
    Object? requireVerification = null,
    Object? allowSuperLikes = null,
    Object? allowBoosts = null,
  }) {
    return _then(_value.copyWith(
      isLookingForBuddy: null == isLookingForBuddy
          ? _value.isLookingForBuddy
          : isLookingForBuddy // ignore: cast_nullable_to_non_nullable
              as bool,
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
      fitnessLevel: null == fitnessLevel
          ? _value.fitnessLevel
          : fitnessLevel // ignore: cast_nullable_to_non_nullable
              as FitnessLevel,
      goals: null == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<WorkoutGoal>,
      preferredTimes: null == preferredTimes
          ? _value.preferredTimes
          : preferredTimes // ignore: cast_nullable_to_non_nullable
              as List<PreferredTime>,
      preferredDays: null == preferredDays
          ? _value.preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instagramHandle: freezed == instagramHandle
          ? _value.instagramHandle
          : instagramHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      minAge: null == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int,
      maxAge: null == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int,
      allowMessages: null == allowMessages
          ? _value.allowMessages
          : allowMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      showOnMap: null == showOnMap
          ? _value.showOnMap
          : showOnMap // ignore: cast_nullable_to_non_nullable
              as bool,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      cityName: freezed == cityName
          ? _value.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String?,
      cityCode: freezed == cityCode
          ? _value.cityCode
          : cityCode // ignore: cast_nullable_to_non_nullable
              as String?,
      zoneName: freezed == zoneName
          ? _value.zoneName
          : zoneName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastLocationUpdate: freezed == lastLocationUpdate
          ? _value.lastLocationUpdate
          : lastLocationUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      matchingPurpose: null == matchingPurpose
          ? _value.matchingPurpose
          : matchingPurpose // ignore: cast_nullable_to_non_nullable
              as MatchingPurpose,
      openToDating: null == openToDating
          ? _value.openToDating
          : openToDating // ignore: cast_nullable_to_non_nullable
              as bool,
      openToFriendship: null == openToFriendship
          ? _value.openToFriendship
          : openToFriendship // ignore: cast_nullable_to_non_nullable
              as bool,
      matchSameFitnessLevel: null == matchSameFitnessLevel
          ? _value.matchSameFitnessLevel
          : matchSameFitnessLevel // ignore: cast_nullable_to_non_nullable
              as bool,
      matchSameGoals: null == matchSameGoals
          ? _value.matchSameGoals
          : matchSameGoals // ignore: cast_nullable_to_non_nullable
              as bool,
      matchOnlyVerified: null == matchOnlyVerified
          ? _value.matchOnlyVerified
          : matchOnlyVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      requireVerification: null == requireVerification
          ? _value.requireVerification
          : requireVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      allowSuperLikes: null == allowSuperLikes
          ? _value.allowSuperLikes
          : allowSuperLikes // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBoosts: null == allowBoosts
          ? _value.allowBoosts
          : allowBoosts // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddyPreferencesImplCopyWith<$Res>
    implements $BuddyPreferencesCopyWith<$Res> {
  factory _$$BuddyPreferencesImplCopyWith(_$BuddyPreferencesImpl value,
          $Res Function(_$BuddyPreferencesImpl) then) =
      __$$BuddyPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLookingForBuddy,
      double maxDistance,
      FitnessLevel fitnessLevel,
      List<WorkoutGoal> goals,
      List<PreferredTime> preferredTimes,
      List<String> preferredDays,
      String? instagramHandle,
      String? bio,
      int minAge,
      int maxAge,
      bool allowMessages,
      bool showOnMap,
      double? latitude,
      double? longitude,
      String? locationName,
      String? cityName,
      String? cityCode,
      String? zoneName,
      DateTime? lastLocationUpdate,
      MatchingPurpose matchingPurpose,
      bool openToDating,
      bool openToFriendship,
      bool matchSameFitnessLevel,
      bool matchSameGoals,
      bool matchOnlyVerified,
      bool requireVerification,
      bool allowSuperLikes,
      bool allowBoosts});
}

/// @nodoc
class __$$BuddyPreferencesImplCopyWithImpl<$Res>
    extends _$BuddyPreferencesCopyWithImpl<$Res, _$BuddyPreferencesImpl>
    implements _$$BuddyPreferencesImplCopyWith<$Res> {
  __$$BuddyPreferencesImplCopyWithImpl(_$BuddyPreferencesImpl _value,
      $Res Function(_$BuddyPreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLookingForBuddy = null,
    Object? maxDistance = null,
    Object? fitnessLevel = null,
    Object? goals = null,
    Object? preferredTimes = null,
    Object? preferredDays = null,
    Object? instagramHandle = freezed,
    Object? bio = freezed,
    Object? minAge = null,
    Object? maxAge = null,
    Object? allowMessages = null,
    Object? showOnMap = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationName = freezed,
    Object? cityName = freezed,
    Object? cityCode = freezed,
    Object? zoneName = freezed,
    Object? lastLocationUpdate = freezed,
    Object? matchingPurpose = null,
    Object? openToDating = null,
    Object? openToFriendship = null,
    Object? matchSameFitnessLevel = null,
    Object? matchSameGoals = null,
    Object? matchOnlyVerified = null,
    Object? requireVerification = null,
    Object? allowSuperLikes = null,
    Object? allowBoosts = null,
  }) {
    return _then(_$BuddyPreferencesImpl(
      isLookingForBuddy: null == isLookingForBuddy
          ? _value.isLookingForBuddy
          : isLookingForBuddy // ignore: cast_nullable_to_non_nullable
              as bool,
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
      fitnessLevel: null == fitnessLevel
          ? _value.fitnessLevel
          : fitnessLevel // ignore: cast_nullable_to_non_nullable
              as FitnessLevel,
      goals: null == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<WorkoutGoal>,
      preferredTimes: null == preferredTimes
          ? _value._preferredTimes
          : preferredTimes // ignore: cast_nullable_to_non_nullable
              as List<PreferredTime>,
      preferredDays: null == preferredDays
          ? _value._preferredDays
          : preferredDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instagramHandle: freezed == instagramHandle
          ? _value.instagramHandle
          : instagramHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      minAge: null == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int,
      maxAge: null == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int,
      allowMessages: null == allowMessages
          ? _value.allowMessages
          : allowMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      showOnMap: null == showOnMap
          ? _value.showOnMap
          : showOnMap // ignore: cast_nullable_to_non_nullable
              as bool,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      cityName: freezed == cityName
          ? _value.cityName
          : cityName // ignore: cast_nullable_to_non_nullable
              as String?,
      cityCode: freezed == cityCode
          ? _value.cityCode
          : cityCode // ignore: cast_nullable_to_non_nullable
              as String?,
      zoneName: freezed == zoneName
          ? _value.zoneName
          : zoneName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastLocationUpdate: freezed == lastLocationUpdate
          ? _value.lastLocationUpdate
          : lastLocationUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      matchingPurpose: null == matchingPurpose
          ? _value.matchingPurpose
          : matchingPurpose // ignore: cast_nullable_to_non_nullable
              as MatchingPurpose,
      openToDating: null == openToDating
          ? _value.openToDating
          : openToDating // ignore: cast_nullable_to_non_nullable
              as bool,
      openToFriendship: null == openToFriendship
          ? _value.openToFriendship
          : openToFriendship // ignore: cast_nullable_to_non_nullable
              as bool,
      matchSameFitnessLevel: null == matchSameFitnessLevel
          ? _value.matchSameFitnessLevel
          : matchSameFitnessLevel // ignore: cast_nullable_to_non_nullable
              as bool,
      matchSameGoals: null == matchSameGoals
          ? _value.matchSameGoals
          : matchSameGoals // ignore: cast_nullable_to_non_nullable
              as bool,
      matchOnlyVerified: null == matchOnlyVerified
          ? _value.matchOnlyVerified
          : matchOnlyVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      requireVerification: null == requireVerification
          ? _value.requireVerification
          : requireVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      allowSuperLikes: null == allowSuperLikes
          ? _value.allowSuperLikes
          : allowSuperLikes // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBoosts: null == allowBoosts
          ? _value.allowBoosts
          : allowBoosts // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyPreferencesImpl implements _BuddyPreferences {
  const _$BuddyPreferencesImpl(
      {this.isLookingForBuddy = false,
      this.maxDistance = 25.0,
      this.fitnessLevel = FitnessLevel.intermediate,
      final List<WorkoutGoal> goals = const [],
      final List<PreferredTime> preferredTimes = const [],
      final List<String> preferredDays = const [],
      this.instagramHandle,
      this.bio,
      this.minAge = 18,
      this.maxAge = 65,
      this.allowMessages = true,
      this.showOnMap = true,
      this.latitude,
      this.longitude,
      this.locationName,
      this.cityName,
      this.cityCode,
      this.zoneName,
      this.lastLocationUpdate,
      this.matchingPurpose = MatchingPurpose.workoutPartner,
      this.openToDating = false,
      this.openToFriendship = true,
      this.matchSameFitnessLevel = true,
      this.matchSameGoals = true,
      this.matchOnlyVerified = false,
      this.requireVerification = false,
      this.allowSuperLikes = true,
      this.allowBoosts = true})
      : _goals = goals,
        _preferredTimes = preferredTimes,
        _preferredDays = preferredDays;

  factory _$BuddyPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final bool isLookingForBuddy;
  @override
  @JsonKey()
  final double maxDistance;
// km
  @override
  @JsonKey()
  final FitnessLevel fitnessLevel;
  final List<WorkoutGoal> _goals;
  @override
  @JsonKey()
  List<WorkoutGoal> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  final List<PreferredTime> _preferredTimes;
  @override
  @JsonKey()
  List<PreferredTime> get preferredTimes {
    if (_preferredTimes is EqualUnmodifiableListView) return _preferredTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredTimes);
  }

  final List<String> _preferredDays;
  @override
  @JsonKey()
  List<String> get preferredDays {
    if (_preferredDays is EqualUnmodifiableListView) return _preferredDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredDays);
  }

// ['monday', 'tuesday', etc.]
  @override
  final String? instagramHandle;
  @override
  final String? bio;
  @override
  @JsonKey()
  final int minAge;
  @override
  @JsonKey()
  final int maxAge;
  @override
  @JsonKey()
  final bool allowMessages;
  @override
  @JsonKey()
  final bool showOnMap;
// Enhanced location system
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? locationName;
  @override
  final String? cityName;
  @override
  final String? cityCode;
// For Italian cities system
  @override
  final String? zoneName;
// For city zones/districts
  @override
  final DateTime? lastLocationUpdate;
// Multi-purpose matching
  @override
  @JsonKey()
  final MatchingPurpose matchingPurpose;
  @override
  @JsonKey()
  final bool openToDating;
// Romance flag
  @override
  @JsonKey()
  final bool openToFriendship;
// Friendship flag
// Matching preferences
  @override
  @JsonKey()
  final bool matchSameFitnessLevel;
  @override
  @JsonKey()
  final bool matchSameGoals;
  @override
  @JsonKey()
  final bool matchOnlyVerified;
// Tier-1 preferences
  @override
  @JsonKey()
  final bool requireVerification;
  @override
  @JsonKey()
  final bool allowSuperLikes;
  @override
  @JsonKey()
  final bool allowBoosts;

  @override
  String toString() {
    return 'BuddyPreferences(isLookingForBuddy: $isLookingForBuddy, maxDistance: $maxDistance, fitnessLevel: $fitnessLevel, goals: $goals, preferredTimes: $preferredTimes, preferredDays: $preferredDays, instagramHandle: $instagramHandle, bio: $bio, minAge: $minAge, maxAge: $maxAge, allowMessages: $allowMessages, showOnMap: $showOnMap, latitude: $latitude, longitude: $longitude, locationName: $locationName, cityName: $cityName, cityCode: $cityCode, zoneName: $zoneName, lastLocationUpdate: $lastLocationUpdate, matchingPurpose: $matchingPurpose, openToDating: $openToDating, openToFriendship: $openToFriendship, matchSameFitnessLevel: $matchSameFitnessLevel, matchSameGoals: $matchSameGoals, matchOnlyVerified: $matchOnlyVerified, requireVerification: $requireVerification, allowSuperLikes: $allowSuperLikes, allowBoosts: $allowBoosts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyPreferencesImpl &&
            (identical(other.isLookingForBuddy, isLookingForBuddy) ||
                other.isLookingForBuddy == isLookingForBuddy) &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance) &&
            (identical(other.fitnessLevel, fitnessLevel) ||
                other.fitnessLevel == fitnessLevel) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            const DeepCollectionEquality()
                .equals(other._preferredTimes, _preferredTimes) &&
            const DeepCollectionEquality()
                .equals(other._preferredDays, _preferredDays) &&
            (identical(other.instagramHandle, instagramHandle) ||
                other.instagramHandle == instagramHandle) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.allowMessages, allowMessages) ||
                other.allowMessages == allowMessages) &&
            (identical(other.showOnMap, showOnMap) ||
                other.showOnMap == showOnMap) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName) &&
            (identical(other.cityCode, cityCode) ||
                other.cityCode == cityCode) &&
            (identical(other.zoneName, zoneName) ||
                other.zoneName == zoneName) &&
            (identical(other.lastLocationUpdate, lastLocationUpdate) ||
                other.lastLocationUpdate == lastLocationUpdate) &&
            (identical(other.matchingPurpose, matchingPurpose) ||
                other.matchingPurpose == matchingPurpose) &&
            (identical(other.openToDating, openToDating) ||
                other.openToDating == openToDating) &&
            (identical(other.openToFriendship, openToFriendship) ||
                other.openToFriendship == openToFriendship) &&
            (identical(other.matchSameFitnessLevel, matchSameFitnessLevel) ||
                other.matchSameFitnessLevel == matchSameFitnessLevel) &&
            (identical(other.matchSameGoals, matchSameGoals) ||
                other.matchSameGoals == matchSameGoals) &&
            (identical(other.matchOnlyVerified, matchOnlyVerified) ||
                other.matchOnlyVerified == matchOnlyVerified) &&
            (identical(other.requireVerification, requireVerification) ||
                other.requireVerification == requireVerification) &&
            (identical(other.allowSuperLikes, allowSuperLikes) ||
                other.allowSuperLikes == allowSuperLikes) &&
            (identical(other.allowBoosts, allowBoosts) ||
                other.allowBoosts == allowBoosts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        isLookingForBuddy,
        maxDistance,
        fitnessLevel,
        const DeepCollectionEquality().hash(_goals),
        const DeepCollectionEquality().hash(_preferredTimes),
        const DeepCollectionEquality().hash(_preferredDays),
        instagramHandle,
        bio,
        minAge,
        maxAge,
        allowMessages,
        showOnMap,
        latitude,
        longitude,
        locationName,
        cityName,
        cityCode,
        zoneName,
        lastLocationUpdate,
        matchingPurpose,
        openToDating,
        openToFriendship,
        matchSameFitnessLevel,
        matchSameGoals,
        matchOnlyVerified,
        requireVerification,
        allowSuperLikes,
        allowBoosts
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyPreferencesImplCopyWith<_$BuddyPreferencesImpl> get copyWith =>
      __$$BuddyPreferencesImplCopyWithImpl<_$BuddyPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyPreferencesImplToJson(
      this,
    );
  }
}

abstract class _BuddyPreferences implements BuddyPreferences {
  const factory _BuddyPreferences(
      {final bool isLookingForBuddy,
      final double maxDistance,
      final FitnessLevel fitnessLevel,
      final List<WorkoutGoal> goals,
      final List<PreferredTime> preferredTimes,
      final List<String> preferredDays,
      final String? instagramHandle,
      final String? bio,
      final int minAge,
      final int maxAge,
      final bool allowMessages,
      final bool showOnMap,
      final double? latitude,
      final double? longitude,
      final String? locationName,
      final String? cityName,
      final String? cityCode,
      final String? zoneName,
      final DateTime? lastLocationUpdate,
      final MatchingPurpose matchingPurpose,
      final bool openToDating,
      final bool openToFriendship,
      final bool matchSameFitnessLevel,
      final bool matchSameGoals,
      final bool matchOnlyVerified,
      final bool requireVerification,
      final bool allowSuperLikes,
      final bool allowBoosts}) = _$BuddyPreferencesImpl;

  factory _BuddyPreferences.fromJson(Map<String, dynamic> json) =
      _$BuddyPreferencesImpl.fromJson;

  @override
  bool get isLookingForBuddy;
  @override
  double get maxDistance;
  @override // km
  FitnessLevel get fitnessLevel;
  @override
  List<WorkoutGoal> get goals;
  @override
  List<PreferredTime> get preferredTimes;
  @override
  List<String> get preferredDays;
  @override // ['monday', 'tuesday', etc.]
  String? get instagramHandle;
  @override
  String? get bio;
  @override
  int get minAge;
  @override
  int get maxAge;
  @override
  bool get allowMessages;
  @override
  bool get showOnMap;
  @override // Enhanced location system
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get locationName;
  @override
  String? get cityName;
  @override
  String? get cityCode;
  @override // For Italian cities system
  String? get zoneName;
  @override // For city zones/districts
  DateTime? get lastLocationUpdate;
  @override // Multi-purpose matching
  MatchingPurpose get matchingPurpose;
  @override
  bool get openToDating;
  @override // Romance flag
  bool get openToFriendship;
  @override // Friendship flag
// Matching preferences
  bool get matchSameFitnessLevel;
  @override
  bool get matchSameGoals;
  @override
  bool get matchOnlyVerified;
  @override // Tier-1 preferences
  bool get requireVerification;
  @override
  bool get allowSuperLikes;
  @override
  bool get allowBoosts;
  @override
  @JsonKey(ignore: true)
  _$$BuddyPreferencesImplCopyWith<_$BuddyPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
