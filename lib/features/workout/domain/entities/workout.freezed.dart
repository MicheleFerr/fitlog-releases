// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Workout {

 String get id; String get name; List<Exercise> get exercises; WorkoutStatus get status; DateTime? get startTime; DateTime? get endTime; String? get notes; DateTime get createdAt; DateTime get updatedAt; String? get templateId;// 🆕 Pre-load management
 bool get isPreloaded; DateTime? get preloadExpiry; bool? get exercisesModified;// 🆕 Analytics tracking
 String? get sessionId;
/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutCopyWith<Workout> get copyWith => _$WorkoutCopyWithImpl<Workout>(this as Workout, _$identity);

  /// Serializes this Workout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Workout&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.status, status) || other.status == status)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.isPreloaded, isPreloaded) || other.isPreloaded == isPreloaded)&&(identical(other.preloadExpiry, preloadExpiry) || other.preloadExpiry == preloadExpiry)&&(identical(other.exercisesModified, exercisesModified) || other.exercisesModified == exercisesModified)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(exercises),status,startTime,endTime,notes,createdAt,updatedAt,templateId,isPreloaded,preloadExpiry,exercisesModified,sessionId);

@override
String toString() {
  return 'Workout(id: $id, name: $name, exercises: $exercises, status: $status, startTime: $startTime, endTime: $endTime, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, templateId: $templateId, isPreloaded: $isPreloaded, preloadExpiry: $preloadExpiry, exercisesModified: $exercisesModified, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $WorkoutCopyWith<$Res>  {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) _then) = _$WorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<Exercise> exercises, WorkoutStatus status, DateTime? startTime, DateTime? endTime, String? notes, DateTime createdAt, DateTime updatedAt, String? templateId, bool isPreloaded, DateTime? preloadExpiry, bool? exercisesModified, String? sessionId
});




}
/// @nodoc
class _$WorkoutCopyWithImpl<$Res>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._self, this._then);

  final Workout _self;
  final $Res Function(Workout) _then;

/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? exercises = null,Object? status = null,Object? startTime = freezed,Object? endTime = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? templateId = freezed,Object? isPreloaded = null,Object? preloadExpiry = freezed,Object? exercisesModified = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkoutStatus,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,isPreloaded: null == isPreloaded ? _self.isPreloaded : isPreloaded // ignore: cast_nullable_to_non_nullable
as bool,preloadExpiry: freezed == preloadExpiry ? _self.preloadExpiry : preloadExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,exercisesModified: freezed == exercisesModified ? _self.exercisesModified : exercisesModified // ignore: cast_nullable_to_non_nullable
as bool?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Workout].
extension WorkoutPatterns on Workout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Workout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Workout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Workout value)  $default,){
final _that = this;
switch (_that) {
case _Workout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Workout value)?  $default,){
final _that = this;
switch (_that) {
case _Workout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<Exercise> exercises,  WorkoutStatus status,  DateTime? startTime,  DateTime? endTime,  String? notes,  DateTime createdAt,  DateTime updatedAt,  String? templateId,  bool isPreloaded,  DateTime? preloadExpiry,  bool? exercisesModified,  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Workout() when $default != null:
return $default(_that.id,_that.name,_that.exercises,_that.status,_that.startTime,_that.endTime,_that.notes,_that.createdAt,_that.updatedAt,_that.templateId,_that.isPreloaded,_that.preloadExpiry,_that.exercisesModified,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<Exercise> exercises,  WorkoutStatus status,  DateTime? startTime,  DateTime? endTime,  String? notes,  DateTime createdAt,  DateTime updatedAt,  String? templateId,  bool isPreloaded,  DateTime? preloadExpiry,  bool? exercisesModified,  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _Workout():
return $default(_that.id,_that.name,_that.exercises,_that.status,_that.startTime,_that.endTime,_that.notes,_that.createdAt,_that.updatedAt,_that.templateId,_that.isPreloaded,_that.preloadExpiry,_that.exercisesModified,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<Exercise> exercises,  WorkoutStatus status,  DateTime? startTime,  DateTime? endTime,  String? notes,  DateTime createdAt,  DateTime updatedAt,  String? templateId,  bool isPreloaded,  DateTime? preloadExpiry,  bool? exercisesModified,  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _Workout() when $default != null:
return $default(_that.id,_that.name,_that.exercises,_that.status,_that.startTime,_that.endTime,_that.notes,_that.createdAt,_that.updatedAt,_that.templateId,_that.isPreloaded,_that.preloadExpiry,_that.exercisesModified,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Workout extends Workout {
  const _Workout({required this.id, required this.name, final  List<Exercise> exercises = const [], this.status = WorkoutStatus.planned, this.startTime, this.endTime, this.notes, required this.createdAt, required this.updatedAt, this.templateId, this.isPreloaded = false, this.preloadExpiry, this.exercisesModified, this.sessionId}): _exercises = exercises,super._();
  factory _Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

@override final  String id;
@override final  String name;
 final  List<Exercise> _exercises;
@override@JsonKey() List<Exercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey() final  WorkoutStatus status;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? templateId;
// 🆕 Pre-load management
@override@JsonKey() final  bool isPreloaded;
@override final  DateTime? preloadExpiry;
@override final  bool? exercisesModified;
// 🆕 Analytics tracking
@override final  String? sessionId;

/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutCopyWith<_Workout> get copyWith => __$WorkoutCopyWithImpl<_Workout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Workout&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.status, status) || other.status == status)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.isPreloaded, isPreloaded) || other.isPreloaded == isPreloaded)&&(identical(other.preloadExpiry, preloadExpiry) || other.preloadExpiry == preloadExpiry)&&(identical(other.exercisesModified, exercisesModified) || other.exercisesModified == exercisesModified)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_exercises),status,startTime,endTime,notes,createdAt,updatedAt,templateId,isPreloaded,preloadExpiry,exercisesModified,sessionId);

@override
String toString() {
  return 'Workout(id: $id, name: $name, exercises: $exercises, status: $status, startTime: $startTime, endTime: $endTime, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, templateId: $templateId, isPreloaded: $isPreloaded, preloadExpiry: $preloadExpiry, exercisesModified: $exercisesModified, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$WorkoutCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$WorkoutCopyWith(_Workout value, $Res Function(_Workout) _then) = __$WorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<Exercise> exercises, WorkoutStatus status, DateTime? startTime, DateTime? endTime, String? notes, DateTime createdAt, DateTime updatedAt, String? templateId, bool isPreloaded, DateTime? preloadExpiry, bool? exercisesModified, String? sessionId
});




}
/// @nodoc
class __$WorkoutCopyWithImpl<$Res>
    implements _$WorkoutCopyWith<$Res> {
  __$WorkoutCopyWithImpl(this._self, this._then);

  final _Workout _self;
  final $Res Function(_Workout) _then;

/// Create a copy of Workout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? exercises = null,Object? status = null,Object? startTime = freezed,Object? endTime = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? templateId = freezed,Object? isPreloaded = null,Object? preloadExpiry = freezed,Object? exercisesModified = freezed,Object? sessionId = freezed,}) {
  return _then(_Workout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkoutStatus,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,isPreloaded: null == isPreloaded ? _self.isPreloaded : isPreloaded // ignore: cast_nullable_to_non_nullable
as bool,preloadExpiry: freezed == preloadExpiry ? _self.preloadExpiry : preloadExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,exercisesModified: freezed == exercisesModified ? _self.exercisesModified : exercisesModified // ignore: cast_nullable_to_non_nullable
as bool?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
