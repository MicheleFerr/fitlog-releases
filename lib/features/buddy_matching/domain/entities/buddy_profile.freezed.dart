// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuddyProfile _$BuddyProfileFromJson(Map<String, dynamic> json) {
  return _BuddyProfile.fromJson(json);
}

/// @nodoc
mixin _$BuddyProfile {
  String get uid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get photoURL => throw _privateConstructorUsedError;
  BuddyPreferences get preferences => throw _privateConstructorUsedError;
  List<BadgeType> get badges => throw _privateConstructorUsedError;
  int get partnershipsCount => throw _privateConstructorUsedError;
  int get successfulPartnerships => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalRatings => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError; // Statistics
  int get totalWorkouts => throw _privateConstructorUsedError;
  double get totalVolume => throw _privateConstructorUsedError;
  String? get currentPartnershipId => throw _privateConstructorUsedError;
  DateTime? get partnershipStartDate =>
      throw _privateConstructorUsedError; // Matching history
  List<String> get likedProfiles => throw _privateConstructorUsedError;
  List<String> get dislikedProfiles => throw _privateConstructorUsedError;
  List<String> get mutualMatches =>
      throw _privateConstructorUsedError; // Tier-1 features
  int get superLikesRemaining => throw _privateConstructorUsedError;
  DateTime? get lastSuperLikeReset => throw _privateConstructorUsedError;
  DateTime? get boostExpiry => throw _privateConstructorUsedError;
  bool get isBoosted => throw _privateConstructorUsedError;
  int get reportCount => throw _privateConstructorUsedError;
  bool get isBanned => throw _privateConstructorUsedError;
  bool get isPhotoVerified => throw _privateConstructorUsedError;
  List<String> get blockedUsers => throw _privateConstructorUsedError;
  List<String> get reportedUsers =>
      throw _privateConstructorUsedError; // Workout tracking
  List<String> get workoutTogetherIds => throw _privateConstructorUsedError;
  int get completedWorkoutsTogether => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BuddyProfileCopyWith<BuddyProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyProfileCopyWith<$Res> {
  factory $BuddyProfileCopyWith(
          BuddyProfile value, $Res Function(BuddyProfile) then) =
      _$BuddyProfileCopyWithImpl<$Res, BuddyProfile>;
  @useResult
  $Res call(
      {String uid,
      String displayName,
      String? photoURL,
      BuddyPreferences preferences,
      List<BadgeType> badges,
      int partnershipsCount,
      int successfulPartnerships,
      double averageRating,
      int totalRatings,
      DateTime? lastSeen,
      bool isActive,
      bool isVerified,
      int totalWorkouts,
      double totalVolume,
      String? currentPartnershipId,
      DateTime? partnershipStartDate,
      List<String> likedProfiles,
      List<String> dislikedProfiles,
      List<String> mutualMatches,
      int superLikesRemaining,
      DateTime? lastSuperLikeReset,
      DateTime? boostExpiry,
      bool isBoosted,
      int reportCount,
      bool isBanned,
      bool isPhotoVerified,
      List<String> blockedUsers,
      List<String> reportedUsers,
      List<String> workoutTogetherIds,
      int completedWorkoutsTogether,
      DateTime? createdAt,
      DateTime? updatedAt});

  $BuddyPreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class _$BuddyProfileCopyWithImpl<$Res, $Val extends BuddyProfile>
    implements $BuddyProfileCopyWith<$Res> {
  _$BuddyProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? photoURL = freezed,
    Object? preferences = null,
    Object? badges = null,
    Object? partnershipsCount = null,
    Object? successfulPartnerships = null,
    Object? averageRating = null,
    Object? totalRatings = null,
    Object? lastSeen = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? totalWorkouts = null,
    Object? totalVolume = null,
    Object? currentPartnershipId = freezed,
    Object? partnershipStartDate = freezed,
    Object? likedProfiles = null,
    Object? dislikedProfiles = null,
    Object? mutualMatches = null,
    Object? superLikesRemaining = null,
    Object? lastSuperLikeReset = freezed,
    Object? boostExpiry = freezed,
    Object? isBoosted = null,
    Object? reportCount = null,
    Object? isBanned = null,
    Object? isPhotoVerified = null,
    Object? blockedUsers = null,
    Object? reportedUsers = null,
    Object? workoutTogetherIds = null,
    Object? completedWorkoutsTogether = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: freezed == photoURL
          ? _value.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as BuddyPreferences,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<BadgeType>,
      partnershipsCount: null == partnershipsCount
          ? _value.partnershipsCount
          : partnershipsCount // ignore: cast_nullable_to_non_nullable
              as int,
      successfulPartnerships: null == successfulPartnerships
          ? _value.successfulPartnerships
          : successfulPartnerships // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as double,
      currentPartnershipId: freezed == currentPartnershipId
          ? _value.currentPartnershipId
          : currentPartnershipId // ignore: cast_nullable_to_non_nullable
              as String?,
      partnershipStartDate: freezed == partnershipStartDate
          ? _value.partnershipStartDate
          : partnershipStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likedProfiles: null == likedProfiles
          ? _value.likedProfiles
          : likedProfiles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedProfiles: null == dislikedProfiles
          ? _value.dislikedProfiles
          : dislikedProfiles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mutualMatches: null == mutualMatches
          ? _value.mutualMatches
          : mutualMatches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      superLikesRemaining: null == superLikesRemaining
          ? _value.superLikesRemaining
          : superLikesRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      lastSuperLikeReset: freezed == lastSuperLikeReset
          ? _value.lastSuperLikeReset
          : lastSuperLikeReset // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      boostExpiry: freezed == boostExpiry
          ? _value.boostExpiry
          : boostExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isBoosted: null == isBoosted
          ? _value.isBoosted
          : isBoosted // ignore: cast_nullable_to_non_nullable
              as bool,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhotoVerified: null == isPhotoVerified
          ? _value.isPhotoVerified
          : isPhotoVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      blockedUsers: null == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reportedUsers: null == reportedUsers
          ? _value.reportedUsers
          : reportedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      workoutTogetherIds: null == workoutTogetherIds
          ? _value.workoutTogetherIds
          : workoutTogetherIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completedWorkoutsTogether: null == completedWorkoutsTogether
          ? _value.completedWorkoutsTogether
          : completedWorkoutsTogether // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BuddyPreferencesCopyWith<$Res> get preferences {
    return $BuddyPreferencesCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BuddyProfileImplCopyWith<$Res>
    implements $BuddyProfileCopyWith<$Res> {
  factory _$$BuddyProfileImplCopyWith(
          _$BuddyProfileImpl value, $Res Function(_$BuddyProfileImpl) then) =
      __$$BuddyProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String displayName,
      String? photoURL,
      BuddyPreferences preferences,
      List<BadgeType> badges,
      int partnershipsCount,
      int successfulPartnerships,
      double averageRating,
      int totalRatings,
      DateTime? lastSeen,
      bool isActive,
      bool isVerified,
      int totalWorkouts,
      double totalVolume,
      String? currentPartnershipId,
      DateTime? partnershipStartDate,
      List<String> likedProfiles,
      List<String> dislikedProfiles,
      List<String> mutualMatches,
      int superLikesRemaining,
      DateTime? lastSuperLikeReset,
      DateTime? boostExpiry,
      bool isBoosted,
      int reportCount,
      bool isBanned,
      bool isPhotoVerified,
      List<String> blockedUsers,
      List<String> reportedUsers,
      List<String> workoutTogetherIds,
      int completedWorkoutsTogether,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $BuddyPreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class __$$BuddyProfileImplCopyWithImpl<$Res>
    extends _$BuddyProfileCopyWithImpl<$Res, _$BuddyProfileImpl>
    implements _$$BuddyProfileImplCopyWith<$Res> {
  __$$BuddyProfileImplCopyWithImpl(
      _$BuddyProfileImpl _value, $Res Function(_$BuddyProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? photoURL = freezed,
    Object? preferences = null,
    Object? badges = null,
    Object? partnershipsCount = null,
    Object? successfulPartnerships = null,
    Object? averageRating = null,
    Object? totalRatings = null,
    Object? lastSeen = freezed,
    Object? isActive = null,
    Object? isVerified = null,
    Object? totalWorkouts = null,
    Object? totalVolume = null,
    Object? currentPartnershipId = freezed,
    Object? partnershipStartDate = freezed,
    Object? likedProfiles = null,
    Object? dislikedProfiles = null,
    Object? mutualMatches = null,
    Object? superLikesRemaining = null,
    Object? lastSuperLikeReset = freezed,
    Object? boostExpiry = freezed,
    Object? isBoosted = null,
    Object? reportCount = null,
    Object? isBanned = null,
    Object? isPhotoVerified = null,
    Object? blockedUsers = null,
    Object? reportedUsers = null,
    Object? workoutTogetherIds = null,
    Object? completedWorkoutsTogether = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BuddyProfileImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoURL: freezed == photoURL
          ? _value.photoURL
          : photoURL // ignore: cast_nullable_to_non_nullable
              as String?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as BuddyPreferences,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<BadgeType>,
      partnershipsCount: null == partnershipsCount
          ? _value.partnershipsCount
          : partnershipsCount // ignore: cast_nullable_to_non_nullable
              as int,
      successfulPartnerships: null == successfulPartnerships
          ? _value.successfulPartnerships
          : successfulPartnerships // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as double,
      currentPartnershipId: freezed == currentPartnershipId
          ? _value.currentPartnershipId
          : currentPartnershipId // ignore: cast_nullable_to_non_nullable
              as String?,
      partnershipStartDate: freezed == partnershipStartDate
          ? _value.partnershipStartDate
          : partnershipStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      likedProfiles: null == likedProfiles
          ? _value._likedProfiles
          : likedProfiles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dislikedProfiles: null == dislikedProfiles
          ? _value._dislikedProfiles
          : dislikedProfiles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mutualMatches: null == mutualMatches
          ? _value._mutualMatches
          : mutualMatches // ignore: cast_nullable_to_non_nullable
              as List<String>,
      superLikesRemaining: null == superLikesRemaining
          ? _value.superLikesRemaining
          : superLikesRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      lastSuperLikeReset: freezed == lastSuperLikeReset
          ? _value.lastSuperLikeReset
          : lastSuperLikeReset // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      boostExpiry: freezed == boostExpiry
          ? _value.boostExpiry
          : boostExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isBoosted: null == isBoosted
          ? _value.isBoosted
          : isBoosted // ignore: cast_nullable_to_non_nullable
              as bool,
      reportCount: null == reportCount
          ? _value.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhotoVerified: null == isPhotoVerified
          ? _value.isPhotoVerified
          : isPhotoVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      blockedUsers: null == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reportedUsers: null == reportedUsers
          ? _value._reportedUsers
          : reportedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      workoutTogetherIds: null == workoutTogetherIds
          ? _value._workoutTogetherIds
          : workoutTogetherIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completedWorkoutsTogether: null == completedWorkoutsTogether
          ? _value.completedWorkoutsTogether
          : completedWorkoutsTogether // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyProfileImpl implements _BuddyProfile {
  const _$BuddyProfileImpl(
      {required this.uid,
      required this.displayName,
      this.photoURL,
      required this.preferences,
      final List<BadgeType> badges = const [],
      this.partnershipsCount = 0,
      this.successfulPartnerships = 0,
      this.averageRating = 0.0,
      this.totalRatings = 0,
      this.lastSeen,
      this.isActive = true,
      this.isVerified = false,
      this.totalWorkouts = 0,
      this.totalVolume = 0.0,
      this.currentPartnershipId,
      this.partnershipStartDate,
      final List<String> likedProfiles = const [],
      final List<String> dislikedProfiles = const [],
      final List<String> mutualMatches = const [],
      this.superLikesRemaining = 3,
      this.lastSuperLikeReset,
      this.boostExpiry,
      this.isBoosted = false,
      this.reportCount = 0,
      this.isBanned = false,
      this.isPhotoVerified = false,
      final List<String> blockedUsers = const [],
      final List<String> reportedUsers = const [],
      final List<String> workoutTogetherIds = const [],
      this.completedWorkoutsTogether = 0,
      this.createdAt,
      this.updatedAt})
      : _badges = badges,
        _likedProfiles = likedProfiles,
        _dislikedProfiles = dislikedProfiles,
        _mutualMatches = mutualMatches,
        _blockedUsers = blockedUsers,
        _reportedUsers = reportedUsers,
        _workoutTogetherIds = workoutTogetherIds;

  factory _$BuddyProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyProfileImplFromJson(json);

  @override
  final String uid;
  @override
  final String displayName;
  @override
  final String? photoURL;
  @override
  final BuddyPreferences preferences;
  final List<BadgeType> _badges;
  @override
  @JsonKey()
  List<BadgeType> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  @JsonKey()
  final int partnershipsCount;
  @override
  @JsonKey()
  final int successfulPartnerships;
  @override
  @JsonKey()
  final double averageRating;
  @override
  @JsonKey()
  final int totalRatings;
  @override
  final DateTime? lastSeen;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isVerified;
// Statistics
  @override
  @JsonKey()
  final int totalWorkouts;
  @override
  @JsonKey()
  final double totalVolume;
  @override
  final String? currentPartnershipId;
  @override
  final DateTime? partnershipStartDate;
// Matching history
  final List<String> _likedProfiles;
// Matching history
  @override
  @JsonKey()
  List<String> get likedProfiles {
    if (_likedProfiles is EqualUnmodifiableListView) return _likedProfiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedProfiles);
  }

  final List<String> _dislikedProfiles;
  @override
  @JsonKey()
  List<String> get dislikedProfiles {
    if (_dislikedProfiles is EqualUnmodifiableListView)
      return _dislikedProfiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dislikedProfiles);
  }

  final List<String> _mutualMatches;
  @override
  @JsonKey()
  List<String> get mutualMatches {
    if (_mutualMatches is EqualUnmodifiableListView) return _mutualMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mutualMatches);
  }

// Tier-1 features
  @override
  @JsonKey()
  final int superLikesRemaining;
  @override
  final DateTime? lastSuperLikeReset;
  @override
  final DateTime? boostExpiry;
  @override
  @JsonKey()
  final bool isBoosted;
  @override
  @JsonKey()
  final int reportCount;
  @override
  @JsonKey()
  final bool isBanned;
  @override
  @JsonKey()
  final bool isPhotoVerified;
  final List<String> _blockedUsers;
  @override
  @JsonKey()
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  final List<String> _reportedUsers;
  @override
  @JsonKey()
  List<String> get reportedUsers {
    if (_reportedUsers is EqualUnmodifiableListView) return _reportedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reportedUsers);
  }

// Workout tracking
  final List<String> _workoutTogetherIds;
// Workout tracking
  @override
  @JsonKey()
  List<String> get workoutTogetherIds {
    if (_workoutTogetherIds is EqualUnmodifiableListView)
      return _workoutTogetherIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workoutTogetherIds);
  }

  @override
  @JsonKey()
  final int completedWorkoutsTogether;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BuddyProfile(uid: $uid, displayName: $displayName, photoURL: $photoURL, preferences: $preferences, badges: $badges, partnershipsCount: $partnershipsCount, successfulPartnerships: $successfulPartnerships, averageRating: $averageRating, totalRatings: $totalRatings, lastSeen: $lastSeen, isActive: $isActive, isVerified: $isVerified, totalWorkouts: $totalWorkouts, totalVolume: $totalVolume, currentPartnershipId: $currentPartnershipId, partnershipStartDate: $partnershipStartDate, likedProfiles: $likedProfiles, dislikedProfiles: $dislikedProfiles, mutualMatches: $mutualMatches, superLikesRemaining: $superLikesRemaining, lastSuperLikeReset: $lastSuperLikeReset, boostExpiry: $boostExpiry, isBoosted: $isBoosted, reportCount: $reportCount, isBanned: $isBanned, isPhotoVerified: $isPhotoVerified, blockedUsers: $blockedUsers, reportedUsers: $reportedUsers, workoutTogetherIds: $workoutTogetherIds, completedWorkoutsTogether: $completedWorkoutsTogether, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyProfileImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.partnershipsCount, partnershipsCount) ||
                other.partnershipsCount == partnershipsCount) &&
            (identical(other.successfulPartnerships, successfulPartnerships) ||
                other.successfulPartnerships == successfulPartnerships) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalRatings, totalRatings) ||
                other.totalRatings == totalRatings) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.currentPartnershipId, currentPartnershipId) ||
                other.currentPartnershipId == currentPartnershipId) &&
            (identical(other.partnershipStartDate, partnershipStartDate) ||
                other.partnershipStartDate == partnershipStartDate) &&
            const DeepCollectionEquality()
                .equals(other._likedProfiles, _likedProfiles) &&
            const DeepCollectionEquality()
                .equals(other._dislikedProfiles, _dislikedProfiles) &&
            const DeepCollectionEquality()
                .equals(other._mutualMatches, _mutualMatches) &&
            (identical(other.superLikesRemaining, superLikesRemaining) ||
                other.superLikesRemaining == superLikesRemaining) &&
            (identical(other.lastSuperLikeReset, lastSuperLikeReset) ||
                other.lastSuperLikeReset == lastSuperLikeReset) &&
            (identical(other.boostExpiry, boostExpiry) ||
                other.boostExpiry == boostExpiry) &&
            (identical(other.isBoosted, isBoosted) ||
                other.isBoosted == isBoosted) &&
            (identical(other.reportCount, reportCount) ||
                other.reportCount == reportCount) &&
            (identical(other.isBanned, isBanned) ||
                other.isBanned == isBanned) &&
            (identical(other.isPhotoVerified, isPhotoVerified) ||
                other.isPhotoVerified == isPhotoVerified) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            const DeepCollectionEquality()
                .equals(other._reportedUsers, _reportedUsers) &&
            const DeepCollectionEquality()
                .equals(other._workoutTogetherIds, _workoutTogetherIds) &&
            (identical(other.completedWorkoutsTogether,
                    completedWorkoutsTogether) ||
                other.completedWorkoutsTogether == completedWorkoutsTogether) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        uid,
        displayName,
        photoURL,
        preferences,
        const DeepCollectionEquality().hash(_badges),
        partnershipsCount,
        successfulPartnerships,
        averageRating,
        totalRatings,
        lastSeen,
        isActive,
        isVerified,
        totalWorkouts,
        totalVolume,
        currentPartnershipId,
        partnershipStartDate,
        const DeepCollectionEquality().hash(_likedProfiles),
        const DeepCollectionEquality().hash(_dislikedProfiles),
        const DeepCollectionEquality().hash(_mutualMatches),
        superLikesRemaining,
        lastSuperLikeReset,
        boostExpiry,
        isBoosted,
        reportCount,
        isBanned,
        isPhotoVerified,
        const DeepCollectionEquality().hash(_blockedUsers),
        const DeepCollectionEquality().hash(_reportedUsers),
        const DeepCollectionEquality().hash(_workoutTogetherIds),
        completedWorkoutsTogether,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyProfileImplCopyWith<_$BuddyProfileImpl> get copyWith =>
      __$$BuddyProfileImplCopyWithImpl<_$BuddyProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyProfileImplToJson(
      this,
    );
  }
}

abstract class _BuddyProfile implements BuddyProfile {
  const factory _BuddyProfile(
      {required final String uid,
      required final String displayName,
      final String? photoURL,
      required final BuddyPreferences preferences,
      final List<BadgeType> badges,
      final int partnershipsCount,
      final int successfulPartnerships,
      final double averageRating,
      final int totalRatings,
      final DateTime? lastSeen,
      final bool isActive,
      final bool isVerified,
      final int totalWorkouts,
      final double totalVolume,
      final String? currentPartnershipId,
      final DateTime? partnershipStartDate,
      final List<String> likedProfiles,
      final List<String> dislikedProfiles,
      final List<String> mutualMatches,
      final int superLikesRemaining,
      final DateTime? lastSuperLikeReset,
      final DateTime? boostExpiry,
      final bool isBoosted,
      final int reportCount,
      final bool isBanned,
      final bool isPhotoVerified,
      final List<String> blockedUsers,
      final List<String> reportedUsers,
      final List<String> workoutTogetherIds,
      final int completedWorkoutsTogether,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BuddyProfileImpl;

  factory _BuddyProfile.fromJson(Map<String, dynamic> json) =
      _$BuddyProfileImpl.fromJson;

  @override
  String get uid;
  @override
  String get displayName;
  @override
  String? get photoURL;
  @override
  BuddyPreferences get preferences;
  @override
  List<BadgeType> get badges;
  @override
  int get partnershipsCount;
  @override
  int get successfulPartnerships;
  @override
  double get averageRating;
  @override
  int get totalRatings;
  @override
  DateTime? get lastSeen;
  @override
  bool get isActive;
  @override
  bool get isVerified;
  @override // Statistics
  int get totalWorkouts;
  @override
  double get totalVolume;
  @override
  String? get currentPartnershipId;
  @override
  DateTime? get partnershipStartDate;
  @override // Matching history
  List<String> get likedProfiles;
  @override
  List<String> get dislikedProfiles;
  @override
  List<String> get mutualMatches;
  @override // Tier-1 features
  int get superLikesRemaining;
  @override
  DateTime? get lastSuperLikeReset;
  @override
  DateTime? get boostExpiry;
  @override
  bool get isBoosted;
  @override
  int get reportCount;
  @override
  bool get isBanned;
  @override
  bool get isPhotoVerified;
  @override
  List<String> get blockedUsers;
  @override
  List<String> get reportedUsers;
  @override // Workout tracking
  List<String> get workoutTogetherIds;
  @override
  int get completedWorkoutsTogether;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BuddyProfileImplCopyWith<_$BuddyProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
