// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduling_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScheduleBottomSheetState {

/// Currently selected dates for scheduling
 List<DateTime> get selectedDates;/// Hour component of reminder time
 int get reminderHour;/// Minute component of reminder time
 int get reminderMinute;/// Whether the form is currently submitting
 bool get isSubmitting;/// Error message if submission failed
 String? get errorMessage;/// Success message after successful scheduling
 String? get successMessage;
/// Create a copy of ScheduleBottomSheetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleBottomSheetStateCopyWith<ScheduleBottomSheetState> get copyWith => _$ScheduleBottomSheetStateCopyWithImpl<ScheduleBottomSheetState>(this as ScheduleBottomSheetState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleBottomSheetState&&const DeepCollectionEquality().equals(other.selectedDates, selectedDates)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedDates),reminderHour,reminderMinute,isSubmitting,errorMessage,successMessage);

@override
String toString() {
  return 'ScheduleBottomSheetState(selectedDates: $selectedDates, reminderHour: $reminderHour, reminderMinute: $reminderMinute, isSubmitting: $isSubmitting, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $ScheduleBottomSheetStateCopyWith<$Res>  {
  factory $ScheduleBottomSheetStateCopyWith(ScheduleBottomSheetState value, $Res Function(ScheduleBottomSheetState) _then) = _$ScheduleBottomSheetStateCopyWithImpl;
@useResult
$Res call({
 List<DateTime> selectedDates, int reminderHour, int reminderMinute, bool isSubmitting, String? errorMessage, String? successMessage
});




}
/// @nodoc
class _$ScheduleBottomSheetStateCopyWithImpl<$Res>
    implements $ScheduleBottomSheetStateCopyWith<$Res> {
  _$ScheduleBottomSheetStateCopyWithImpl(this._self, this._then);

  final ScheduleBottomSheetState _self;
  final $Res Function(ScheduleBottomSheetState) _then;

/// Create a copy of ScheduleBottomSheetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedDates = null,Object? reminderHour = null,Object? reminderMinute = null,Object? isSubmitting = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_self.copyWith(
selectedDates: null == selectedDates ? _self.selectedDates : selectedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleBottomSheetState].
extension ScheduleBottomSheetStatePatterns on ScheduleBottomSheetState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleBottomSheetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleBottomSheetState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleBottomSheetState value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleBottomSheetState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleBottomSheetState value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleBottomSheetState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DateTime> selectedDates,  int reminderHour,  int reminderMinute,  bool isSubmitting,  String? errorMessage,  String? successMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleBottomSheetState() when $default != null:
return $default(_that.selectedDates,_that.reminderHour,_that.reminderMinute,_that.isSubmitting,_that.errorMessage,_that.successMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DateTime> selectedDates,  int reminderHour,  int reminderMinute,  bool isSubmitting,  String? errorMessage,  String? successMessage)  $default,) {final _that = this;
switch (_that) {
case _ScheduleBottomSheetState():
return $default(_that.selectedDates,_that.reminderHour,_that.reminderMinute,_that.isSubmitting,_that.errorMessage,_that.successMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DateTime> selectedDates,  int reminderHour,  int reminderMinute,  bool isSubmitting,  String? errorMessage,  String? successMessage)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleBottomSheetState() when $default != null:
return $default(_that.selectedDates,_that.reminderHour,_that.reminderMinute,_that.isSubmitting,_that.errorMessage,_that.successMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ScheduleBottomSheetState extends ScheduleBottomSheetState {
  const _ScheduleBottomSheetState({final  List<DateTime> selectedDates = const [], this.reminderHour = 9, this.reminderMinute = 0, this.isSubmitting = false, this.errorMessage, this.successMessage}): _selectedDates = selectedDates,super._();
  

/// Currently selected dates for scheduling
 final  List<DateTime> _selectedDates;
/// Currently selected dates for scheduling
@override@JsonKey() List<DateTime> get selectedDates {
  if (_selectedDates is EqualUnmodifiableListView) return _selectedDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedDates);
}

/// Hour component of reminder time
@override@JsonKey() final  int reminderHour;
/// Minute component of reminder time
@override@JsonKey() final  int reminderMinute;
/// Whether the form is currently submitting
@override@JsonKey() final  bool isSubmitting;
/// Error message if submission failed
@override final  String? errorMessage;
/// Success message after successful scheduling
@override final  String? successMessage;

/// Create a copy of ScheduleBottomSheetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleBottomSheetStateCopyWith<_ScheduleBottomSheetState> get copyWith => __$ScheduleBottomSheetStateCopyWithImpl<_ScheduleBottomSheetState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleBottomSheetState&&const DeepCollectionEquality().equals(other._selectedDates, _selectedDates)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedDates),reminderHour,reminderMinute,isSubmitting,errorMessage,successMessage);

@override
String toString() {
  return 'ScheduleBottomSheetState(selectedDates: $selectedDates, reminderHour: $reminderHour, reminderMinute: $reminderMinute, isSubmitting: $isSubmitting, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class _$ScheduleBottomSheetStateCopyWith<$Res> implements $ScheduleBottomSheetStateCopyWith<$Res> {
  factory _$ScheduleBottomSheetStateCopyWith(_ScheduleBottomSheetState value, $Res Function(_ScheduleBottomSheetState) _then) = __$ScheduleBottomSheetStateCopyWithImpl;
@override @useResult
$Res call({
 List<DateTime> selectedDates, int reminderHour, int reminderMinute, bool isSubmitting, String? errorMessage, String? successMessage
});




}
/// @nodoc
class __$ScheduleBottomSheetStateCopyWithImpl<$Res>
    implements _$ScheduleBottomSheetStateCopyWith<$Res> {
  __$ScheduleBottomSheetStateCopyWithImpl(this._self, this._then);

  final _ScheduleBottomSheetState _self;
  final $Res Function(_ScheduleBottomSheetState) _then;

/// Create a copy of ScheduleBottomSheetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedDates = null,Object? reminderHour = null,Object? reminderMinute = null,Object? isSubmitting = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_ScheduleBottomSheetState(
selectedDates: null == selectedDates ? _self._selectedDates : selectedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
