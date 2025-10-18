// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuddyMatch _$BuddyMatchFromJson(Map<String, dynamic> json) {
  return _BuddyMatch.fromJson(json);
}

/// @nodoc
mixin _$BuddyMatch {
  String get id => throw _privateConstructorUsedError;
  String get user1Id => throw _privateConstructorUsedError;
  String get user2Id => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  double get compatibilityScore => throw _privateConstructorUsedError;
  String? get initiatorId =>
      throw _privateConstructorUsedError; // Who liked first
  DateTime? get user1LikedAt => throw _privateConstructorUsedError;
  DateTime? get user2LikedAt => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  DateTime? get partnershipStartedAt => throw _privateConstructorUsedError;
  DateTime? get partnershipEndedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt =>
      throw _privateConstructorUsedError; // Partnership data
  int get sharedWorkouts => throw _privateConstructorUsedError;
  int get plannedWorkouts => throw _privateConstructorUsedError;
  int get completedWorkouts =>
      throw _privateConstructorUsedError; // Communication
  String? get lastMessageId => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount1 =>
      throw _privateConstructorUsedError; // User1's unread messages
  int get unreadCount2 =>
      throw _privateConstructorUsedError; // User2's unread messages
// Ratings (after partnership ends)
  int? get user1Rating => throw _privateConstructorUsedError; // 1-5 stars
  int? get user2Rating => throw _privateConstructorUsedError;
  String? get user1Feedback => throw _privateConstructorUsedError;
  String? get user2Feedback => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BuddyMatchCopyWith<BuddyMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyMatchCopyWith<$Res> {
  factory $BuddyMatchCopyWith(
          BuddyMatch value, $Res Function(BuddyMatch) then) =
      _$BuddyMatchCopyWithImpl<$Res, BuddyMatch>;
  @useResult
  $Res call(
      {String id,
      String user1Id,
      String user2Id,
      MatchStatus status,
      double compatibilityScore,
      String? initiatorId,
      DateTime? user1LikedAt,
      DateTime? user2LikedAt,
      DateTime? confirmedAt,
      DateTime? partnershipStartedAt,
      DateTime? partnershipEndedAt,
      DateTime? expiresAt,
      int sharedWorkouts,
      int plannedWorkouts,
      int completedWorkouts,
      String? lastMessageId,
      DateTime? lastMessageAt,
      int unreadCount1,
      int unreadCount2,
      int? user1Rating,
      int? user2Rating,
      String? user1Feedback,
      String? user2Feedback,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$BuddyMatchCopyWithImpl<$Res, $Val extends BuddyMatch>
    implements $BuddyMatchCopyWith<$Res> {
  _$BuddyMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user1Id = null,
    Object? user2Id = null,
    Object? status = null,
    Object? compatibilityScore = null,
    Object? initiatorId = freezed,
    Object? user1LikedAt = freezed,
    Object? user2LikedAt = freezed,
    Object? confirmedAt = freezed,
    Object? partnershipStartedAt = freezed,
    Object? partnershipEndedAt = freezed,
    Object? expiresAt = freezed,
    Object? sharedWorkouts = null,
    Object? plannedWorkouts = null,
    Object? completedWorkouts = null,
    Object? lastMessageId = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount1 = null,
    Object? unreadCount2 = null,
    Object? user1Rating = freezed,
    Object? user2Rating = freezed,
    Object? user1Feedback = freezed,
    Object? user2Feedback = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user1Id: null == user1Id
          ? _value.user1Id
          : user1Id // ignore: cast_nullable_to_non_nullable
              as String,
      user2Id: null == user2Id
          ? _value.user2Id
          : user2Id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      compatibilityScore: null == compatibilityScore
          ? _value.compatibilityScore
          : compatibilityScore // ignore: cast_nullable_to_non_nullable
              as double,
      initiatorId: freezed == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      user1LikedAt: freezed == user1LikedAt
          ? _value.user1LikedAt
          : user1LikedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user2LikedAt: freezed == user2LikedAt
          ? _value.user2LikedAt
          : user2LikedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      partnershipStartedAt: freezed == partnershipStartedAt
          ? _value.partnershipStartedAt
          : partnershipStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      partnershipEndedAt: freezed == partnershipEndedAt
          ? _value.partnershipEndedAt
          : partnershipEndedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sharedWorkouts: null == sharedWorkouts
          ? _value.sharedWorkouts
          : sharedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      plannedWorkouts: null == plannedWorkouts
          ? _value.plannedWorkouts
          : plannedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      completedWorkouts: null == completedWorkouts
          ? _value.completedWorkouts
          : completedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessageId: freezed == lastMessageId
          ? _value.lastMessageId
          : lastMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount1: null == unreadCount1
          ? _value.unreadCount1
          : unreadCount1 // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount2: null == unreadCount2
          ? _value.unreadCount2
          : unreadCount2 // ignore: cast_nullable_to_non_nullable
              as int,
      user1Rating: freezed == user1Rating
          ? _value.user1Rating
          : user1Rating // ignore: cast_nullable_to_non_nullable
              as int?,
      user2Rating: freezed == user2Rating
          ? _value.user2Rating
          : user2Rating // ignore: cast_nullable_to_non_nullable
              as int?,
      user1Feedback: freezed == user1Feedback
          ? _value.user1Feedback
          : user1Feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      user2Feedback: freezed == user2Feedback
          ? _value.user2Feedback
          : user2Feedback // ignore: cast_nullable_to_non_nullable
              as String?,
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
}

/// @nodoc
abstract class _$$BuddyMatchImplCopyWith<$Res>
    implements $BuddyMatchCopyWith<$Res> {
  factory _$$BuddyMatchImplCopyWith(
          _$BuddyMatchImpl value, $Res Function(_$BuddyMatchImpl) then) =
      __$$BuddyMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String user1Id,
      String user2Id,
      MatchStatus status,
      double compatibilityScore,
      String? initiatorId,
      DateTime? user1LikedAt,
      DateTime? user2LikedAt,
      DateTime? confirmedAt,
      DateTime? partnershipStartedAt,
      DateTime? partnershipEndedAt,
      DateTime? expiresAt,
      int sharedWorkouts,
      int plannedWorkouts,
      int completedWorkouts,
      String? lastMessageId,
      DateTime? lastMessageAt,
      int unreadCount1,
      int unreadCount2,
      int? user1Rating,
      int? user2Rating,
      String? user1Feedback,
      String? user2Feedback,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$BuddyMatchImplCopyWithImpl<$Res>
    extends _$BuddyMatchCopyWithImpl<$Res, _$BuddyMatchImpl>
    implements _$$BuddyMatchImplCopyWith<$Res> {
  __$$BuddyMatchImplCopyWithImpl(
      _$BuddyMatchImpl _value, $Res Function(_$BuddyMatchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user1Id = null,
    Object? user2Id = null,
    Object? status = null,
    Object? compatibilityScore = null,
    Object? initiatorId = freezed,
    Object? user1LikedAt = freezed,
    Object? user2LikedAt = freezed,
    Object? confirmedAt = freezed,
    Object? partnershipStartedAt = freezed,
    Object? partnershipEndedAt = freezed,
    Object? expiresAt = freezed,
    Object? sharedWorkouts = null,
    Object? plannedWorkouts = null,
    Object? completedWorkouts = null,
    Object? lastMessageId = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount1 = null,
    Object? unreadCount2 = null,
    Object? user1Rating = freezed,
    Object? user2Rating = freezed,
    Object? user1Feedback = freezed,
    Object? user2Feedback = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BuddyMatchImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user1Id: null == user1Id
          ? _value.user1Id
          : user1Id // ignore: cast_nullable_to_non_nullable
              as String,
      user2Id: null == user2Id
          ? _value.user2Id
          : user2Id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      compatibilityScore: null == compatibilityScore
          ? _value.compatibilityScore
          : compatibilityScore // ignore: cast_nullable_to_non_nullable
              as double,
      initiatorId: freezed == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      user1LikedAt: freezed == user1LikedAt
          ? _value.user1LikedAt
          : user1LikedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user2LikedAt: freezed == user2LikedAt
          ? _value.user2LikedAt
          : user2LikedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      partnershipStartedAt: freezed == partnershipStartedAt
          ? _value.partnershipStartedAt
          : partnershipStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      partnershipEndedAt: freezed == partnershipEndedAt
          ? _value.partnershipEndedAt
          : partnershipEndedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sharedWorkouts: null == sharedWorkouts
          ? _value.sharedWorkouts
          : sharedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      plannedWorkouts: null == plannedWorkouts
          ? _value.plannedWorkouts
          : plannedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      completedWorkouts: null == completedWorkouts
          ? _value.completedWorkouts
          : completedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessageId: freezed == lastMessageId
          ? _value.lastMessageId
          : lastMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount1: null == unreadCount1
          ? _value.unreadCount1
          : unreadCount1 // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount2: null == unreadCount2
          ? _value.unreadCount2
          : unreadCount2 // ignore: cast_nullable_to_non_nullable
              as int,
      user1Rating: freezed == user1Rating
          ? _value.user1Rating
          : user1Rating // ignore: cast_nullable_to_non_nullable
              as int?,
      user2Rating: freezed == user2Rating
          ? _value.user2Rating
          : user2Rating // ignore: cast_nullable_to_non_nullable
              as int?,
      user1Feedback: freezed == user1Feedback
          ? _value.user1Feedback
          : user1Feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      user2Feedback: freezed == user2Feedback
          ? _value.user2Feedback
          : user2Feedback // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$BuddyMatchImpl extends _BuddyMatch {
  const _$BuddyMatchImpl(
      {required this.id,
      required this.user1Id,
      required this.user2Id,
      required this.status,
      required this.compatibilityScore,
      this.initiatorId,
      this.user1LikedAt,
      this.user2LikedAt,
      this.confirmedAt,
      this.partnershipStartedAt,
      this.partnershipEndedAt,
      this.expiresAt,
      this.sharedWorkouts = 0,
      this.plannedWorkouts = 0,
      this.completedWorkouts = 0,
      this.lastMessageId,
      this.lastMessageAt,
      this.unreadCount1 = 0,
      this.unreadCount2 = 0,
      this.user1Rating,
      this.user2Rating,
      this.user1Feedback,
      this.user2Feedback,
      this.createdAt,
      this.updatedAt})
      : super._();

  factory _$BuddyMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyMatchImplFromJson(json);

  @override
  final String id;
  @override
  final String user1Id;
  @override
  final String user2Id;
  @override
  final MatchStatus status;
  @override
  final double compatibilityScore;
  @override
  final String? initiatorId;
// Who liked first
  @override
  final DateTime? user1LikedAt;
  @override
  final DateTime? user2LikedAt;
  @override
  final DateTime? confirmedAt;
  @override
  final DateTime? partnershipStartedAt;
  @override
  final DateTime? partnershipEndedAt;
  @override
  final DateTime? expiresAt;
// Partnership data
  @override
  @JsonKey()
  final int sharedWorkouts;
  @override
  @JsonKey()
  final int plannedWorkouts;
  @override
  @JsonKey()
  final int completedWorkouts;
// Communication
  @override
  final String? lastMessageId;
  @override
  final DateTime? lastMessageAt;
  @override
  @JsonKey()
  final int unreadCount1;
// User1's unread messages
  @override
  @JsonKey()
  final int unreadCount2;
// User2's unread messages
// Ratings (after partnership ends)
  @override
  final int? user1Rating;
// 1-5 stars
  @override
  final int? user2Rating;
  @override
  final String? user1Feedback;
  @override
  final String? user2Feedback;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BuddyMatch(id: $id, user1Id: $user1Id, user2Id: $user2Id, status: $status, compatibilityScore: $compatibilityScore, initiatorId: $initiatorId, user1LikedAt: $user1LikedAt, user2LikedAt: $user2LikedAt, confirmedAt: $confirmedAt, partnershipStartedAt: $partnershipStartedAt, partnershipEndedAt: $partnershipEndedAt, expiresAt: $expiresAt, sharedWorkouts: $sharedWorkouts, plannedWorkouts: $plannedWorkouts, completedWorkouts: $completedWorkouts, lastMessageId: $lastMessageId, lastMessageAt: $lastMessageAt, unreadCount1: $unreadCount1, unreadCount2: $unreadCount2, user1Rating: $user1Rating, user2Rating: $user2Rating, user1Feedback: $user1Feedback, user2Feedback: $user2Feedback, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyMatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user1Id, user1Id) || other.user1Id == user1Id) &&
            (identical(other.user2Id, user2Id) || other.user2Id == user2Id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.compatibilityScore, compatibilityScore) ||
                other.compatibilityScore == compatibilityScore) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.user1LikedAt, user1LikedAt) ||
                other.user1LikedAt == user1LikedAt) &&
            (identical(other.user2LikedAt, user2LikedAt) ||
                other.user2LikedAt == user2LikedAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.partnershipStartedAt, partnershipStartedAt) ||
                other.partnershipStartedAt == partnershipStartedAt) &&
            (identical(other.partnershipEndedAt, partnershipEndedAt) ||
                other.partnershipEndedAt == partnershipEndedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.sharedWorkouts, sharedWorkouts) ||
                other.sharedWorkouts == sharedWorkouts) &&
            (identical(other.plannedWorkouts, plannedWorkouts) ||
                other.plannedWorkouts == plannedWorkouts) &&
            (identical(other.completedWorkouts, completedWorkouts) ||
                other.completedWorkouts == completedWorkouts) &&
            (identical(other.lastMessageId, lastMessageId) ||
                other.lastMessageId == lastMessageId) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount1, unreadCount1) ||
                other.unreadCount1 == unreadCount1) &&
            (identical(other.unreadCount2, unreadCount2) ||
                other.unreadCount2 == unreadCount2) &&
            (identical(other.user1Rating, user1Rating) ||
                other.user1Rating == user1Rating) &&
            (identical(other.user2Rating, user2Rating) ||
                other.user2Rating == user2Rating) &&
            (identical(other.user1Feedback, user1Feedback) ||
                other.user1Feedback == user1Feedback) &&
            (identical(other.user2Feedback, user2Feedback) ||
                other.user2Feedback == user2Feedback) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        user1Id,
        user2Id,
        status,
        compatibilityScore,
        initiatorId,
        user1LikedAt,
        user2LikedAt,
        confirmedAt,
        partnershipStartedAt,
        partnershipEndedAt,
        expiresAt,
        sharedWorkouts,
        plannedWorkouts,
        completedWorkouts,
        lastMessageId,
        lastMessageAt,
        unreadCount1,
        unreadCount2,
        user1Rating,
        user2Rating,
        user1Feedback,
        user2Feedback,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyMatchImplCopyWith<_$BuddyMatchImpl> get copyWith =>
      __$$BuddyMatchImplCopyWithImpl<_$BuddyMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyMatchImplToJson(
      this,
    );
  }
}

abstract class _BuddyMatch extends BuddyMatch {
  const factory _BuddyMatch(
      {required final String id,
      required final String user1Id,
      required final String user2Id,
      required final MatchStatus status,
      required final double compatibilityScore,
      final String? initiatorId,
      final DateTime? user1LikedAt,
      final DateTime? user2LikedAt,
      final DateTime? confirmedAt,
      final DateTime? partnershipStartedAt,
      final DateTime? partnershipEndedAt,
      final DateTime? expiresAt,
      final int sharedWorkouts,
      final int plannedWorkouts,
      final int completedWorkouts,
      final String? lastMessageId,
      final DateTime? lastMessageAt,
      final int unreadCount1,
      final int unreadCount2,
      final int? user1Rating,
      final int? user2Rating,
      final String? user1Feedback,
      final String? user2Feedback,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BuddyMatchImpl;
  const _BuddyMatch._() : super._();

  factory _BuddyMatch.fromJson(Map<String, dynamic> json) =
      _$BuddyMatchImpl.fromJson;

  @override
  String get id;
  @override
  String get user1Id;
  @override
  String get user2Id;
  @override
  MatchStatus get status;
  @override
  double get compatibilityScore;
  @override
  String? get initiatorId;
  @override // Who liked first
  DateTime? get user1LikedAt;
  @override
  DateTime? get user2LikedAt;
  @override
  DateTime? get confirmedAt;
  @override
  DateTime? get partnershipStartedAt;
  @override
  DateTime? get partnershipEndedAt;
  @override
  DateTime? get expiresAt;
  @override // Partnership data
  int get sharedWorkouts;
  @override
  int get plannedWorkouts;
  @override
  int get completedWorkouts;
  @override // Communication
  String? get lastMessageId;
  @override
  DateTime? get lastMessageAt;
  @override
  int get unreadCount1;
  @override // User1's unread messages
  int get unreadCount2;
  @override // User2's unread messages
// Ratings (after partnership ends)
  int? get user1Rating;
  @override // 1-5 stars
  int? get user2Rating;
  @override
  String? get user1Feedback;
  @override
  String? get user2Feedback;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BuddyMatchImplCopyWith<_$BuddyMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
