// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserGoal {
  GoalType get goalType => throw _privateConstructorUsedError;
  int get weeklyWorkoutTarget => throw _privateConstructorUsedError;
  ExperienceLevel get experienceLevel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserGoalCopyWith<UserGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGoalCopyWith<$Res> {
  factory $UserGoalCopyWith(UserGoal value, $Res Function(UserGoal) then) =
      _$UserGoalCopyWithImpl<$Res, UserGoal>;
  @useResult
  $Res call(
      {GoalType goalType,
      int weeklyWorkoutTarget,
      ExperienceLevel experienceLevel});
}

/// @nodoc
class _$UserGoalCopyWithImpl<$Res, $Val extends UserGoal>
    implements $UserGoalCopyWith<$Res> {
  _$UserGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalType = null,
    Object? weeklyWorkoutTarget = null,
    Object? experienceLevel = null,
  }) {
    return _then(_value.copyWith(
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as GoalType,
      weeklyWorkoutTarget: null == weeklyWorkoutTarget
          ? _value.weeklyWorkoutTarget
          : weeklyWorkoutTarget // ignore: cast_nullable_to_non_nullable
              as int,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserGoalImplCopyWith<$Res>
    implements $UserGoalCopyWith<$Res> {
  factory _$$UserGoalImplCopyWith(
          _$UserGoalImpl value, $Res Function(_$UserGoalImpl) then) =
      __$$UserGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GoalType goalType,
      int weeklyWorkoutTarget,
      ExperienceLevel experienceLevel});
}

/// @nodoc
class __$$UserGoalImplCopyWithImpl<$Res>
    extends _$UserGoalCopyWithImpl<$Res, _$UserGoalImpl>
    implements _$$UserGoalImplCopyWith<$Res> {
  __$$UserGoalImplCopyWithImpl(
      _$UserGoalImpl _value, $Res Function(_$UserGoalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalType = null,
    Object? weeklyWorkoutTarget = null,
    Object? experienceLevel = null,
  }) {
    return _then(_$UserGoalImpl(
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as GoalType,
      weeklyWorkoutTarget: null == weeklyWorkoutTarget
          ? _value.weeklyWorkoutTarget
          : weeklyWorkoutTarget // ignore: cast_nullable_to_non_nullable
              as int,
      experienceLevel: null == experienceLevel
          ? _value.experienceLevel
          : experienceLevel // ignore: cast_nullable_to_non_nullable
              as ExperienceLevel,
    ));
  }
}

/// @nodoc

class _$UserGoalImpl implements _UserGoal {
  const _$UserGoalImpl(
      {required this.goalType,
      required this.weeklyWorkoutTarget,
      required this.experienceLevel});

  @override
  final GoalType goalType;
  @override
  final int weeklyWorkoutTarget;
  @override
  final ExperienceLevel experienceLevel;

  @override
  String toString() {
    return 'UserGoal(goalType: $goalType, weeklyWorkoutTarget: $weeklyWorkoutTarget, experienceLevel: $experienceLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGoalImpl &&
            (identical(other.goalType, goalType) ||
                other.goalType == goalType) &&
            (identical(other.weeklyWorkoutTarget, weeklyWorkoutTarget) ||
                other.weeklyWorkoutTarget == weeklyWorkoutTarget) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, goalType, weeklyWorkoutTarget, experienceLevel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGoalImplCopyWith<_$UserGoalImpl> get copyWith =>
      __$$UserGoalImplCopyWithImpl<_$UserGoalImpl>(this, _$identity);
}

abstract class _UserGoal implements UserGoal {
  const factory _UserGoal(
      {required final GoalType goalType,
      required final int weeklyWorkoutTarget,
      required final ExperienceLevel experienceLevel}) = _$UserGoalImpl;

  @override
  GoalType get goalType;
  @override
  int get weeklyWorkoutTarget;
  @override
  ExperienceLevel get experienceLevel;
  @override
  @JsonKey(ignore: true)
  _$$UserGoalImplCopyWith<_$UserGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
