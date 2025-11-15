// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingState {
  OnboardingStep get currentStep => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  UserGoal? get userGoal => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
          OnboardingState value, $Res Function(OnboardingState) then) =
      _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({OnboardingStep currentStep, bool isCompleted, UserGoal? userGoal});

  $UserGoalCopyWith<$Res>? get userGoal;
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? isCompleted = null,
    Object? userGoal = freezed,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as OnboardingStep,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      userGoal: freezed == userGoal
          ? _value.userGoal
          : userGoal // ignore: cast_nullable_to_non_nullable
              as UserGoal?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserGoalCopyWith<$Res>? get userGoal {
    if (_value.userGoal == null) {
      return null;
    }

    return $UserGoalCopyWith<$Res>(_value.userGoal!, (value) {
      return _then(_value.copyWith(userGoal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(_$OnboardingStateImpl value,
          $Res Function(_$OnboardingStateImpl) then) =
      __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OnboardingStep currentStep, bool isCompleted, UserGoal? userGoal});

  @override
  $UserGoalCopyWith<$Res>? get userGoal;
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
      _$OnboardingStateImpl _value, $Res Function(_$OnboardingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? isCompleted = null,
    Object? userGoal = freezed,
  }) {
    return _then(_$OnboardingStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as OnboardingStep,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      userGoal: freezed == userGoal
          ? _value.userGoal
          : userGoal // ignore: cast_nullable_to_non_nullable
              as UserGoal?,
    ));
  }
}

/// @nodoc

class _$OnboardingStateImpl implements _OnboardingState {
  const _$OnboardingStateImpl(
      {required this.currentStep,
      required this.isCompleted,
      required this.userGoal});

  @override
  final OnboardingStep currentStep;
  @override
  final bool isCompleted;
  @override
  final UserGoal? userGoal;

  @override
  String toString() {
    return 'OnboardingState(currentStep: $currentStep, isCompleted: $isCompleted, userGoal: $userGoal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.userGoal, userGoal) ||
                other.userGoal == userGoal));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentStep, isCompleted, userGoal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
          this, _$identity);
}

abstract class _OnboardingState implements OnboardingState {
  const factory _OnboardingState(
      {required final OnboardingStep currentStep,
      required final bool isCompleted,
      required final UserGoal? userGoal}) = _$OnboardingStateImpl;

  @override
  OnboardingStep get currentStep;
  @override
  bool get isCompleted;
  @override
  UserGoal? get userGoal;
  @override
  @JsonKey(ignore: true)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
