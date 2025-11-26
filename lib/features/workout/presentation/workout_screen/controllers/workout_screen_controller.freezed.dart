// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_screen_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WorkoutScreenState {
  /// Whether exercise reorder mode is active
  bool get isReorderMode => throw _privateConstructorUsedError;

  /// Currently selected template ID for workout creation
  String? get selectedTemplateId => throw _privateConstructorUsedError;

  /// Whether to show the welcome view
  bool get showWelcome => throw _privateConstructorUsedError;

  /// Whether to show the "Change Workout" banner
  bool get showChangeWorkoutBanner => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutScreenStateCopyWith<WorkoutScreenState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutScreenStateCopyWith<$Res> {
  factory $WorkoutScreenStateCopyWith(
          WorkoutScreenState value, $Res Function(WorkoutScreenState) then) =
      _$WorkoutScreenStateCopyWithImpl<$Res, WorkoutScreenState>;
  @useResult
  $Res call(
      {bool isReorderMode,
      String? selectedTemplateId,
      bool showWelcome,
      bool showChangeWorkoutBanner});
}

/// @nodoc
class _$WorkoutScreenStateCopyWithImpl<$Res, $Val extends WorkoutScreenState>
    implements $WorkoutScreenStateCopyWith<$Res> {
  _$WorkoutScreenStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isReorderMode = null,
    Object? selectedTemplateId = freezed,
    Object? showWelcome = null,
    Object? showChangeWorkoutBanner = null,
  }) {
    return _then(_value.copyWith(
      isReorderMode: null == isReorderMode
          ? _value.isReorderMode
          : isReorderMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedTemplateId: freezed == selectedTemplateId
          ? _value.selectedTemplateId
          : selectedTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      showWelcome: null == showWelcome
          ? _value.showWelcome
          : showWelcome // ignore: cast_nullable_to_non_nullable
              as bool,
      showChangeWorkoutBanner: null == showChangeWorkoutBanner
          ? _value.showChangeWorkoutBanner
          : showChangeWorkoutBanner // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutScreenStateImplCopyWith<$Res>
    implements $WorkoutScreenStateCopyWith<$Res> {
  factory _$$WorkoutScreenStateImplCopyWith(_$WorkoutScreenStateImpl value,
          $Res Function(_$WorkoutScreenStateImpl) then) =
      __$$WorkoutScreenStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isReorderMode,
      String? selectedTemplateId,
      bool showWelcome,
      bool showChangeWorkoutBanner});
}

/// @nodoc
class __$$WorkoutScreenStateImplCopyWithImpl<$Res>
    extends _$WorkoutScreenStateCopyWithImpl<$Res, _$WorkoutScreenStateImpl>
    implements _$$WorkoutScreenStateImplCopyWith<$Res> {
  __$$WorkoutScreenStateImplCopyWithImpl(_$WorkoutScreenStateImpl _value,
      $Res Function(_$WorkoutScreenStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isReorderMode = null,
    Object? selectedTemplateId = freezed,
    Object? showWelcome = null,
    Object? showChangeWorkoutBanner = null,
  }) {
    return _then(_$WorkoutScreenStateImpl(
      isReorderMode: null == isReorderMode
          ? _value.isReorderMode
          : isReorderMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedTemplateId: freezed == selectedTemplateId
          ? _value.selectedTemplateId
          : selectedTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      showWelcome: null == showWelcome
          ? _value.showWelcome
          : showWelcome // ignore: cast_nullable_to_non_nullable
              as bool,
      showChangeWorkoutBanner: null == showChangeWorkoutBanner
          ? _value.showChangeWorkoutBanner
          : showChangeWorkoutBanner // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$WorkoutScreenStateImpl
    with DiagnosticableTreeMixin
    implements _WorkoutScreenState {
  const _$WorkoutScreenStateImpl(
      {this.isReorderMode = false,
      this.selectedTemplateId,
      this.showWelcome = false,
      this.showChangeWorkoutBanner = false});

  /// Whether exercise reorder mode is active
  @override
  @JsonKey()
  final bool isReorderMode;

  /// Currently selected template ID for workout creation
  @override
  final String? selectedTemplateId;

  /// Whether to show the welcome view
  @override
  @JsonKey()
  final bool showWelcome;

  /// Whether to show the "Change Workout" banner
  @override
  @JsonKey()
  final bool showChangeWorkoutBanner;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WorkoutScreenState(isReorderMode: $isReorderMode, selectedTemplateId: $selectedTemplateId, showWelcome: $showWelcome, showChangeWorkoutBanner: $showChangeWorkoutBanner)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'WorkoutScreenState'))
      ..add(DiagnosticsProperty('isReorderMode', isReorderMode))
      ..add(DiagnosticsProperty('selectedTemplateId', selectedTemplateId))
      ..add(DiagnosticsProperty('showWelcome', showWelcome))
      ..add(DiagnosticsProperty(
          'showChangeWorkoutBanner', showChangeWorkoutBanner));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutScreenStateImpl &&
            (identical(other.isReorderMode, isReorderMode) ||
                other.isReorderMode == isReorderMode) &&
            (identical(other.selectedTemplateId, selectedTemplateId) ||
                other.selectedTemplateId == selectedTemplateId) &&
            (identical(other.showWelcome, showWelcome) ||
                other.showWelcome == showWelcome) &&
            (identical(
                    other.showChangeWorkoutBanner, showChangeWorkoutBanner) ||
                other.showChangeWorkoutBanner == showChangeWorkoutBanner));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isReorderMode,
      selectedTemplateId, showWelcome, showChangeWorkoutBanner);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutScreenStateImplCopyWith<_$WorkoutScreenStateImpl> get copyWith =>
      __$$WorkoutScreenStateImplCopyWithImpl<_$WorkoutScreenStateImpl>(
          this, _$identity);
}

abstract class _WorkoutScreenState implements WorkoutScreenState {
  const factory _WorkoutScreenState(
      {final bool isReorderMode,
      final String? selectedTemplateId,
      final bool showWelcome,
      final bool showChangeWorkoutBanner}) = _$WorkoutScreenStateImpl;

  @override

  /// Whether exercise reorder mode is active
  bool get isReorderMode;
  @override

  /// Currently selected template ID for workout creation
  String? get selectedTemplateId;
  @override

  /// Whether to show the welcome view
  bool get showWelcome;
  @override

  /// Whether to show the "Change Workout" banner
  bool get showChangeWorkoutBanner;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutScreenStateImplCopyWith<_$WorkoutScreenStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
