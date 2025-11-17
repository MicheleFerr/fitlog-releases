// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  /// Unique achievement identifier
  String get id => throw _privateConstructorUsedError;

  /// User who unlocked this achievement
  String get userId => throw _privateConstructorUsedError;

  /// Type of badge/achievement
  BadgeType get badgeType => throw _privateConstructorUsedError;

  /// When the achievement was unlocked
  DateTime get unlockedAt => throw _privateConstructorUsedError;

  /// Evidence/context for the achievement
  /// Examples:
  /// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
  /// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
  /// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
  Map<String, dynamic> get evidence => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {String id,
      String userId,
      BadgeType badgeType,
      DateTime unlockedAt,
      Map<String, dynamic> evidence});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? badgeType = null,
    Object? unlockedAt = null,
    Object? evidence = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      badgeType: null == badgeType
          ? _value.badgeType
          : badgeType // ignore: cast_nullable_to_non_nullable
              as BadgeType,
      unlockedAt: null == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      evidence: null == evidence
          ? _value.evidence
          : evidence // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      BadgeType badgeType,
      DateTime unlockedAt,
      Map<String, dynamic> evidence});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? badgeType = null,
    Object? unlockedAt = null,
    Object? evidence = null,
  }) {
    return _then(_$AchievementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      badgeType: null == badgeType
          ? _value.badgeType
          : badgeType // ignore: cast_nullable_to_non_nullable
              as BadgeType,
      unlockedAt: null == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      evidence: null == evidence
          ? _value._evidence
          : evidence // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl(
      {required this.id,
      required this.userId,
      required this.badgeType,
      required this.unlockedAt,
      required final Map<String, dynamic> evidence})
      : _evidence = evidence;

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  /// Unique achievement identifier
  @override
  final String id;

  /// User who unlocked this achievement
  @override
  final String userId;

  /// Type of badge/achievement
  @override
  final BadgeType badgeType;

  /// When the achievement was unlocked
  @override
  final DateTime unlockedAt;

  /// Evidence/context for the achievement
  /// Examples:
  /// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
  /// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
  /// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
  final Map<String, dynamic> _evidence;

  /// Evidence/context for the achievement
  /// Examples:
  /// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
  /// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
  /// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
  @override
  Map<String, dynamic> get evidence {
    if (_evidence is EqualUnmodifiableMapView) return _evidence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_evidence);
  }

  @override
  String toString() {
    return 'Achievement(id: $id, userId: $userId, badgeType: $badgeType, unlockedAt: $unlockedAt, evidence: $evidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.badgeType, badgeType) ||
                other.badgeType == badgeType) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            const DeepCollectionEquality().equals(other._evidence, _evidence));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, badgeType,
      unlockedAt, const DeepCollectionEquality().hash(_evidence));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {required final String id,
      required final String userId,
      required final BadgeType badgeType,
      required final DateTime unlockedAt,
      required final Map<String, dynamic> evidence}) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override

  /// Unique achievement identifier
  String get id;
  @override

  /// User who unlocked this achievement
  String get userId;
  @override

  /// Type of badge/achievement
  BadgeType get badgeType;
  @override

  /// When the achievement was unlocked
  DateTime get unlockedAt;
  @override

  /// Evidence/context for the achievement
  /// Examples:
  /// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
  /// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
  /// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
  Map<String, dynamic> get evidence;
  @override
  @JsonKey(ignore: true)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
