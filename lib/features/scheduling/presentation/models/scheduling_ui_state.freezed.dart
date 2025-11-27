// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ScheduleBottomSheetState {
  /// Currently selected dates for scheduling
  List<DateTime> get selectedDates => throw _privateConstructorUsedError;

  /// Hour component of reminder time
  int get reminderHour => throw _privateConstructorUsedError;

  /// Minute component of reminder time
  int get reminderMinute => throw _privateConstructorUsedError;

  /// Whether the form is currently submitting
  bool get isSubmitting => throw _privateConstructorUsedError;

  /// Error message if submission failed
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Success message after successful scheduling
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleBottomSheetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleBottomSheetStateCopyWith<ScheduleBottomSheetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleBottomSheetStateCopyWith<$Res> {
  factory $ScheduleBottomSheetStateCopyWith(
    ScheduleBottomSheetState value,
    $Res Function(ScheduleBottomSheetState) then,
  ) = _$ScheduleBottomSheetStateCopyWithImpl<$Res, ScheduleBottomSheetState>;
  @useResult
  $Res call({
    List<DateTime> selectedDates,
    int reminderHour,
    int reminderMinute,
    bool isSubmitting,
    String? errorMessage,
    String? successMessage,
  });
}

/// @nodoc
class _$ScheduleBottomSheetStateCopyWithImpl<
  $Res,
  $Val extends ScheduleBottomSheetState
>
    implements $ScheduleBottomSheetStateCopyWith<$Res> {
  _$ScheduleBottomSheetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleBottomSheetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDates = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? isSubmitting = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedDates: null == selectedDates
                ? _value.selectedDates
                : selectedDates // ignore: cast_nullable_to_non_nullable
                      as List<DateTime>,
            reminderHour: null == reminderHour
                ? _value.reminderHour
                : reminderHour // ignore: cast_nullable_to_non_nullable
                      as int,
            reminderMinute: null == reminderMinute
                ? _value.reminderMinute
                : reminderMinute // ignore: cast_nullable_to_non_nullable
                      as int,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            successMessage: freezed == successMessage
                ? _value.successMessage
                : successMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScheduleBottomSheetStateImplCopyWith<$Res>
    implements $ScheduleBottomSheetStateCopyWith<$Res> {
  factory _$$ScheduleBottomSheetStateImplCopyWith(
    _$ScheduleBottomSheetStateImpl value,
    $Res Function(_$ScheduleBottomSheetStateImpl) then,
  ) = __$$ScheduleBottomSheetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DateTime> selectedDates,
    int reminderHour,
    int reminderMinute,
    bool isSubmitting,
    String? errorMessage,
    String? successMessage,
  });
}

/// @nodoc
class __$$ScheduleBottomSheetStateImplCopyWithImpl<$Res>
    extends
        _$ScheduleBottomSheetStateCopyWithImpl<
          $Res,
          _$ScheduleBottomSheetStateImpl
        >
    implements _$$ScheduleBottomSheetStateImplCopyWith<$Res> {
  __$$ScheduleBottomSheetStateImplCopyWithImpl(
    _$ScheduleBottomSheetStateImpl _value,
    $Res Function(_$ScheduleBottomSheetStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduleBottomSheetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDates = null,
    Object? reminderHour = null,
    Object? reminderMinute = null,
    Object? isSubmitting = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(
      _$ScheduleBottomSheetStateImpl(
        selectedDates: null == selectedDates
            ? _value._selectedDates
            : selectedDates // ignore: cast_nullable_to_non_nullable
                  as List<DateTime>,
        reminderHour: null == reminderHour
            ? _value.reminderHour
            : reminderHour // ignore: cast_nullable_to_non_nullable
                  as int,
        reminderMinute: null == reminderMinute
            ? _value.reminderMinute
            : reminderMinute // ignore: cast_nullable_to_non_nullable
                  as int,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        successMessage: freezed == successMessage
            ? _value.successMessage
            : successMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ScheduleBottomSheetStateImpl extends _ScheduleBottomSheetState {
  const _$ScheduleBottomSheetStateImpl({
    final List<DateTime> selectedDates = const [],
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  }) : _selectedDates = selectedDates,
       super._();

  /// Currently selected dates for scheduling
  final List<DateTime> _selectedDates;

  /// Currently selected dates for scheduling
  @override
  @JsonKey()
  List<DateTime> get selectedDates {
    if (_selectedDates is EqualUnmodifiableListView) return _selectedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedDates);
  }

  /// Hour component of reminder time
  @override
  @JsonKey()
  final int reminderHour;

  /// Minute component of reminder time
  @override
  @JsonKey()
  final int reminderMinute;

  /// Whether the form is currently submitting
  @override
  @JsonKey()
  final bool isSubmitting;

  /// Error message if submission failed
  @override
  final String? errorMessage;

  /// Success message after successful scheduling
  @override
  final String? successMessage;

  @override
  String toString() {
    return 'ScheduleBottomSheetState(selectedDates: $selectedDates, reminderHour: $reminderHour, reminderMinute: $reminderMinute, isSubmitting: $isSubmitting, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleBottomSheetStateImpl &&
            const DeepCollectionEquality().equals(
              other._selectedDates,
              _selectedDates,
            ) &&
            (identical(other.reminderHour, reminderHour) ||
                other.reminderHour == reminderHour) &&
            (identical(other.reminderMinute, reminderMinute) ||
                other.reminderMinute == reminderMinute) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_selectedDates),
    reminderHour,
    reminderMinute,
    isSubmitting,
    errorMessage,
    successMessage,
  );

  /// Create a copy of ScheduleBottomSheetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleBottomSheetStateImplCopyWith<_$ScheduleBottomSheetStateImpl>
  get copyWith =>
      __$$ScheduleBottomSheetStateImplCopyWithImpl<
        _$ScheduleBottomSheetStateImpl
      >(this, _$identity);
}

abstract class _ScheduleBottomSheetState extends ScheduleBottomSheetState {
  const factory _ScheduleBottomSheetState({
    final List<DateTime> selectedDates,
    final int reminderHour,
    final int reminderMinute,
    final bool isSubmitting,
    final String? errorMessage,
    final String? successMessage,
  }) = _$ScheduleBottomSheetStateImpl;
  const _ScheduleBottomSheetState._() : super._();

  /// Currently selected dates for scheduling
  @override
  List<DateTime> get selectedDates;

  /// Hour component of reminder time
  @override
  int get reminderHour;

  /// Minute component of reminder time
  @override
  int get reminderMinute;

  /// Whether the form is currently submitting
  @override
  bool get isSubmitting;

  /// Error message if submission failed
  @override
  String? get errorMessage;

  /// Success message after successful scheduling
  @override
  String? get successMessage;

  /// Create a copy of ScheduleBottomSheetState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleBottomSheetStateImplCopyWith<_$ScheduleBottomSheetStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
