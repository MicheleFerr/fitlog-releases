// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_screen_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkoutScreenState implements DiagnosticableTreeMixin {

/// Whether exercise reorder mode is active
 bool get isReorderMode;/// Currently selected template ID for workout creation
 String? get selectedTemplateId;/// Whether to show the welcome view
 bool get showWelcome;/// Whether to show the "Change Workout" banner
 bool get showChangeWorkoutBanner;
/// Create a copy of WorkoutScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutScreenStateCopyWith<WorkoutScreenState> get copyWith => _$WorkoutScreenStateCopyWithImpl<WorkoutScreenState>(this as WorkoutScreenState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorkoutScreenState'))
    ..add(DiagnosticsProperty('isReorderMode', isReorderMode))..add(DiagnosticsProperty('selectedTemplateId', selectedTemplateId))..add(DiagnosticsProperty('showWelcome', showWelcome))..add(DiagnosticsProperty('showChangeWorkoutBanner', showChangeWorkoutBanner));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutScreenState&&(identical(other.isReorderMode, isReorderMode) || other.isReorderMode == isReorderMode)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.showWelcome, showWelcome) || other.showWelcome == showWelcome)&&(identical(other.showChangeWorkoutBanner, showChangeWorkoutBanner) || other.showChangeWorkoutBanner == showChangeWorkoutBanner));
}


@override
int get hashCode => Object.hash(runtimeType,isReorderMode,selectedTemplateId,showWelcome,showChangeWorkoutBanner);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorkoutScreenState(isReorderMode: $isReorderMode, selectedTemplateId: $selectedTemplateId, showWelcome: $showWelcome, showChangeWorkoutBanner: $showChangeWorkoutBanner)';
}


}

/// @nodoc
abstract mixin class $WorkoutScreenStateCopyWith<$Res>  {
  factory $WorkoutScreenStateCopyWith(WorkoutScreenState value, $Res Function(WorkoutScreenState) _then) = _$WorkoutScreenStateCopyWithImpl;
@useResult
$Res call({
 bool isReorderMode, String? selectedTemplateId, bool showWelcome, bool showChangeWorkoutBanner
});




}
/// @nodoc
class _$WorkoutScreenStateCopyWithImpl<$Res>
    implements $WorkoutScreenStateCopyWith<$Res> {
  _$WorkoutScreenStateCopyWithImpl(this._self, this._then);

  final WorkoutScreenState _self;
  final $Res Function(WorkoutScreenState) _then;

/// Create a copy of WorkoutScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isReorderMode = null,Object? selectedTemplateId = freezed,Object? showWelcome = null,Object? showChangeWorkoutBanner = null,}) {
  return _then(_self.copyWith(
isReorderMode: null == isReorderMode ? _self.isReorderMode : isReorderMode // ignore: cast_nullable_to_non_nullable
as bool,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,showWelcome: null == showWelcome ? _self.showWelcome : showWelcome // ignore: cast_nullable_to_non_nullable
as bool,showChangeWorkoutBanner: null == showChangeWorkoutBanner ? _self.showChangeWorkoutBanner : showChangeWorkoutBanner // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutScreenState].
extension WorkoutScreenStatePatterns on WorkoutScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutScreenState value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isReorderMode,  String? selectedTemplateId,  bool showWelcome,  bool showChangeWorkoutBanner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutScreenState() when $default != null:
return $default(_that.isReorderMode,_that.selectedTemplateId,_that.showWelcome,_that.showChangeWorkoutBanner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isReorderMode,  String? selectedTemplateId,  bool showWelcome,  bool showChangeWorkoutBanner)  $default,) {final _that = this;
switch (_that) {
case _WorkoutScreenState():
return $default(_that.isReorderMode,_that.selectedTemplateId,_that.showWelcome,_that.showChangeWorkoutBanner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isReorderMode,  String? selectedTemplateId,  bool showWelcome,  bool showChangeWorkoutBanner)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutScreenState() when $default != null:
return $default(_that.isReorderMode,_that.selectedTemplateId,_that.showWelcome,_that.showChangeWorkoutBanner);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutScreenState with DiagnosticableTreeMixin implements WorkoutScreenState {
  const _WorkoutScreenState({this.isReorderMode = false, this.selectedTemplateId, this.showWelcome = false, this.showChangeWorkoutBanner = false});
  

/// Whether exercise reorder mode is active
@override@JsonKey() final  bool isReorderMode;
/// Currently selected template ID for workout creation
@override final  String? selectedTemplateId;
/// Whether to show the welcome view
@override@JsonKey() final  bool showWelcome;
/// Whether to show the "Change Workout" banner
@override@JsonKey() final  bool showChangeWorkoutBanner;

/// Create a copy of WorkoutScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutScreenStateCopyWith<_WorkoutScreenState> get copyWith => __$WorkoutScreenStateCopyWithImpl<_WorkoutScreenState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorkoutScreenState'))
    ..add(DiagnosticsProperty('isReorderMode', isReorderMode))..add(DiagnosticsProperty('selectedTemplateId', selectedTemplateId))..add(DiagnosticsProperty('showWelcome', showWelcome))..add(DiagnosticsProperty('showChangeWorkoutBanner', showChangeWorkoutBanner));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutScreenState&&(identical(other.isReorderMode, isReorderMode) || other.isReorderMode == isReorderMode)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.showWelcome, showWelcome) || other.showWelcome == showWelcome)&&(identical(other.showChangeWorkoutBanner, showChangeWorkoutBanner) || other.showChangeWorkoutBanner == showChangeWorkoutBanner));
}


@override
int get hashCode => Object.hash(runtimeType,isReorderMode,selectedTemplateId,showWelcome,showChangeWorkoutBanner);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorkoutScreenState(isReorderMode: $isReorderMode, selectedTemplateId: $selectedTemplateId, showWelcome: $showWelcome, showChangeWorkoutBanner: $showChangeWorkoutBanner)';
}


}

/// @nodoc
abstract mixin class _$WorkoutScreenStateCopyWith<$Res> implements $WorkoutScreenStateCopyWith<$Res> {
  factory _$WorkoutScreenStateCopyWith(_WorkoutScreenState value, $Res Function(_WorkoutScreenState) _then) = __$WorkoutScreenStateCopyWithImpl;
@override @useResult
$Res call({
 bool isReorderMode, String? selectedTemplateId, bool showWelcome, bool showChangeWorkoutBanner
});




}
/// @nodoc
class __$WorkoutScreenStateCopyWithImpl<$Res>
    implements _$WorkoutScreenStateCopyWith<$Res> {
  __$WorkoutScreenStateCopyWithImpl(this._self, this._then);

  final _WorkoutScreenState _self;
  final $Res Function(_WorkoutScreenState) _then;

/// Create a copy of WorkoutScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isReorderMode = null,Object? selectedTemplateId = freezed,Object? showWelcome = null,Object? showChangeWorkoutBanner = null,}) {
  return _then(_WorkoutScreenState(
isReorderMode: null == isReorderMode ? _self.isReorderMode : isReorderMode // ignore: cast_nullable_to_non_nullable
as bool,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,showWelcome: null == showWelcome ? _self.showWelcome : showWelcome // ignore: cast_nullable_to_non_nullable
as bool,showChangeWorkoutBanner: null == showChangeWorkoutBanner ? _self.showChangeWorkoutBanner : showChangeWorkoutBanner // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
