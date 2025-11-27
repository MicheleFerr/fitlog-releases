// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scheduled_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduledWorkout {

/// Unique identifier
 String get id;/// ID of the template this workout is based on
 String get templateId;/// Name of the template (cached for display)
 String get templateName;/// Date when the workout is scheduled
 DateTime get scheduledDate;/// Hour component of reminder time (0-23)
 int get reminderHour;/// Minute component of reminder time (0-59)
 int get reminderMinute;/// Current status of the scheduled workout
 ScheduleStatus get status;/// When the workout was completed (if applicable)
 DateTime? get completedAt;/// When this schedule was created
 DateTime? get createdAt;/// ID of the notification scheduled for this workout (for cancellation)
 String? get notificationId;
/// Create a copy of ScheduledWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledWorkoutCopyWith<ScheduledWorkout> get copyWith => _$ScheduledWorkoutCopyWithImpl<ScheduledWorkout>(this as ScheduledWorkout, _$identity);

  /// Serializes this ScheduledWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateId,templateName,scheduledDate,reminderHour,reminderMinute,status,completedAt,createdAt,notificationId);

@override
String toString() {
  return 'ScheduledWorkout(id: $id, templateId: $templateId, templateName: $templateName, scheduledDate: $scheduledDate, reminderHour: $reminderHour, reminderMinute: $reminderMinute, status: $status, completedAt: $completedAt, createdAt: $createdAt, notificationId: $notificationId)';
}


}

/// @nodoc
abstract mixin class $ScheduledWorkoutCopyWith<$Res>  {
  factory $ScheduledWorkoutCopyWith(ScheduledWorkout value, $Res Function(ScheduledWorkout) _then) = _$ScheduledWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String templateId, String templateName, DateTime scheduledDate, int reminderHour, int reminderMinute, ScheduleStatus status, DateTime? completedAt, DateTime? createdAt, String? notificationId
});




}
/// @nodoc
class _$ScheduledWorkoutCopyWithImpl<$Res>
    implements $ScheduledWorkoutCopyWith<$Res> {
  _$ScheduledWorkoutCopyWithImpl(this._self, this._then);

  final ScheduledWorkout _self;
  final $Res Function(ScheduledWorkout) _then;

/// Create a copy of ScheduledWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? templateId = null,Object? templateName = null,Object? scheduledDate = null,Object? reminderHour = null,Object? reminderMinute = null,Object? status = null,Object? completedAt = freezed,Object? createdAt = freezed,Object? notificationId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScheduleStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationId: freezed == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledWorkout].
extension ScheduledWorkoutPatterns on ScheduledWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledWorkout value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String templateId,  String templateName,  DateTime scheduledDate,  int reminderHour,  int reminderMinute,  ScheduleStatus status,  DateTime? completedAt,  DateTime? createdAt,  String? notificationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledWorkout() when $default != null:
return $default(_that.id,_that.templateId,_that.templateName,_that.scheduledDate,_that.reminderHour,_that.reminderMinute,_that.status,_that.completedAt,_that.createdAt,_that.notificationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String templateId,  String templateName,  DateTime scheduledDate,  int reminderHour,  int reminderMinute,  ScheduleStatus status,  DateTime? completedAt,  DateTime? createdAt,  String? notificationId)  $default,) {final _that = this;
switch (_that) {
case _ScheduledWorkout():
return $default(_that.id,_that.templateId,_that.templateName,_that.scheduledDate,_that.reminderHour,_that.reminderMinute,_that.status,_that.completedAt,_that.createdAt,_that.notificationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String templateId,  String templateName,  DateTime scheduledDate,  int reminderHour,  int reminderMinute,  ScheduleStatus status,  DateTime? completedAt,  DateTime? createdAt,  String? notificationId)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledWorkout() when $default != null:
return $default(_that.id,_that.templateId,_that.templateName,_that.scheduledDate,_that.reminderHour,_that.reminderMinute,_that.status,_that.completedAt,_that.createdAt,_that.notificationId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledWorkout extends ScheduledWorkout {
  const _ScheduledWorkout({required this.id, required this.templateId, required this.templateName, required this.scheduledDate, required this.reminderHour, required this.reminderMinute, this.status = ScheduleStatus.pending, this.completedAt, this.createdAt, this.notificationId}): super._();
  factory _ScheduledWorkout.fromJson(Map<String, dynamic> json) => _$ScheduledWorkoutFromJson(json);

/// Unique identifier
@override final  String id;
/// ID of the template this workout is based on
@override final  String templateId;
/// Name of the template (cached for display)
@override final  String templateName;
/// Date when the workout is scheduled
@override final  DateTime scheduledDate;
/// Hour component of reminder time (0-23)
@override final  int reminderHour;
/// Minute component of reminder time (0-59)
@override final  int reminderMinute;
/// Current status of the scheduled workout
@override@JsonKey() final  ScheduleStatus status;
/// When the workout was completed (if applicable)
@override final  DateTime? completedAt;
/// When this schedule was created
@override final  DateTime? createdAt;
/// ID of the notification scheduled for this workout (for cancellation)
@override final  String? notificationId;

/// Create a copy of ScheduledWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledWorkoutCopyWith<_ScheduledWorkout> get copyWith => __$ScheduledWorkoutCopyWithImpl<_ScheduledWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateName, templateName) || other.templateName == templateName)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,templateId,templateName,scheduledDate,reminderHour,reminderMinute,status,completedAt,createdAt,notificationId);

@override
String toString() {
  return 'ScheduledWorkout(id: $id, templateId: $templateId, templateName: $templateName, scheduledDate: $scheduledDate, reminderHour: $reminderHour, reminderMinute: $reminderMinute, status: $status, completedAt: $completedAt, createdAt: $createdAt, notificationId: $notificationId)';
}


}

/// @nodoc
abstract mixin class _$ScheduledWorkoutCopyWith<$Res> implements $ScheduledWorkoutCopyWith<$Res> {
  factory _$ScheduledWorkoutCopyWith(_ScheduledWorkout value, $Res Function(_ScheduledWorkout) _then) = __$ScheduledWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String templateId, String templateName, DateTime scheduledDate, int reminderHour, int reminderMinute, ScheduleStatus status, DateTime? completedAt, DateTime? createdAt, String? notificationId
});




}
/// @nodoc
class __$ScheduledWorkoutCopyWithImpl<$Res>
    implements _$ScheduledWorkoutCopyWith<$Res> {
  __$ScheduledWorkoutCopyWithImpl(this._self, this._then);

  final _ScheduledWorkout _self;
  final $Res Function(_ScheduledWorkout) _then;

/// Create a copy of ScheduledWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? templateId = null,Object? templateName = null,Object? scheduledDate = null,Object? reminderHour = null,Object? reminderMinute = null,Object? status = null,Object? completedAt = freezed,Object? createdAt = freezed,Object? notificationId = freezed,}) {
  return _then(_ScheduledWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateName: null == templateName ? _self.templateName : templateName // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScheduleStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationId: freezed == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
