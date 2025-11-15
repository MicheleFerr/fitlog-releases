// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_streak.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WorkoutStreak {
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get lastWorkoutDate => throw _privateConstructorUsedError;
  int get totalWorkoutDays => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutStreakCopyWith<WorkoutStreak> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutStreakCopyWith<$Res> {
  factory $WorkoutStreakCopyWith(
          WorkoutStreak value, $Res Function(WorkoutStreak) then) =
      _$WorkoutStreakCopyWithImpl<$Res, WorkoutStreak>;
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      bool isActive,
      DateTime? lastWorkoutDate,
      int totalWorkoutDays});
}

/// @nodoc
class _$WorkoutStreakCopyWithImpl<$Res, $Val extends WorkoutStreak>
    implements $WorkoutStreakCopyWith<$Res> {
  _$WorkoutStreakCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? isActive = null,
    Object? lastWorkoutDate = freezed,
    Object? totalWorkoutDays = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalWorkoutDays: null == totalWorkoutDays
          ? _value.totalWorkoutDays
          : totalWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutStreakImplCopyWith<$Res>
    implements $WorkoutStreakCopyWith<$Res> {
  factory _$$WorkoutStreakImplCopyWith(
          _$WorkoutStreakImpl value, $Res Function(_$WorkoutStreakImpl) then) =
      __$$WorkoutStreakImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      bool isActive,
      DateTime? lastWorkoutDate,
      int totalWorkoutDays});
}

/// @nodoc
class __$$WorkoutStreakImplCopyWithImpl<$Res>
    extends _$WorkoutStreakCopyWithImpl<$Res, _$WorkoutStreakImpl>
    implements _$$WorkoutStreakImplCopyWith<$Res> {
  __$$WorkoutStreakImplCopyWithImpl(
      _$WorkoutStreakImpl _value, $Res Function(_$WorkoutStreakImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? isActive = null,
    Object? lastWorkoutDate = freezed,
    Object? totalWorkoutDays = null,
  }) {
    return _then(_$WorkoutStreakImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastWorkoutDate: freezed == lastWorkoutDate
          ? _value.lastWorkoutDate
          : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalWorkoutDays: null == totalWorkoutDays
          ? _value.totalWorkoutDays
          : totalWorkoutDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$WorkoutStreakImpl extends _WorkoutStreak {
  const _$WorkoutStreakImpl(
      {required this.currentStreak,
      required this.longestStreak,
      required this.isActive,
      required this.lastWorkoutDate,
      required this.totalWorkoutDays})
      : super._();

  @override
  final int currentStreak;
  @override
  final int longestStreak;
  @override
  final bool isActive;
  @override
  final DateTime? lastWorkoutDate;
  @override
  final int totalWorkoutDays;

  @override
  String toString() {
    return 'WorkoutStreak(currentStreak: $currentStreak, longestStreak: $longestStreak, isActive: $isActive, lastWorkoutDate: $lastWorkoutDate, totalWorkoutDays: $totalWorkoutDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutStreakImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            (identical(other.totalWorkoutDays, totalWorkoutDays) ||
                other.totalWorkoutDays == totalWorkoutDays));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentStreak, longestStreak,
      isActive, lastWorkoutDate, totalWorkoutDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutStreakImplCopyWith<_$WorkoutStreakImpl> get copyWith =>
      __$$WorkoutStreakImplCopyWithImpl<_$WorkoutStreakImpl>(this, _$identity);
}

abstract class _WorkoutStreak extends WorkoutStreak {
  const factory _WorkoutStreak(
      {required final int currentStreak,
      required final int longestStreak,
      required final bool isActive,
      required final DateTime? lastWorkoutDate,
      required final int totalWorkoutDays}) = _$WorkoutStreakImpl;
  const _WorkoutStreak._() : super._();

  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  bool get isActive;
  @override
  DateTime? get lastWorkoutDate;
  @override
  int get totalWorkoutDays;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutStreakImplCopyWith<_$WorkoutStreakImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
