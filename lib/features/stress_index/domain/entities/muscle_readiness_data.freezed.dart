// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_readiness_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleReadinessData {

/// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
 String get muscleId;/// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
 String get displayName;/// Recovery percentage (0-150%)
/// Can exceed 100% if supercompensated
 double get recoveryPercent;/// When this muscle was last worked
 DateTime? get lastWorkedAt;/// Hours since last workout
 int get hoursSinceWorkout;/// Stress from last workout (0-100)
 double get lastWorkoutStress;/// How this workout would stress this muscle (0-100)
 double get expectedStressFromWorkout;/// Whether this muscle is primary or secondary in the template
 bool get isPrimaryMuscle;// === CONTRIBUTING FACTORS ===
/// Sleep modifier applied (-30% to 0%)
 double get sleepModifier;/// HRV modifier applied (-25% to +10%)
 double get hrvModifier;/// Age modifier applied (-20% to 0%)
 double get ageModifier;
/// Create a copy of MuscleReadinessData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleReadinessDataCopyWith<MuscleReadinessData> get copyWith => _$MuscleReadinessDataCopyWithImpl<MuscleReadinessData>(this as MuscleReadinessData, _$identity);

  /// Serializes this MuscleReadinessData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleReadinessData&&(identical(other.muscleId, muscleId) || other.muscleId == muscleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.recoveryPercent, recoveryPercent) || other.recoveryPercent == recoveryPercent)&&(identical(other.lastWorkedAt, lastWorkedAt) || other.lastWorkedAt == lastWorkedAt)&&(identical(other.hoursSinceWorkout, hoursSinceWorkout) || other.hoursSinceWorkout == hoursSinceWorkout)&&(identical(other.lastWorkoutStress, lastWorkoutStress) || other.lastWorkoutStress == lastWorkoutStress)&&(identical(other.expectedStressFromWorkout, expectedStressFromWorkout) || other.expectedStressFromWorkout == expectedStressFromWorkout)&&(identical(other.isPrimaryMuscle, isPrimaryMuscle) || other.isPrimaryMuscle == isPrimaryMuscle)&&(identical(other.sleepModifier, sleepModifier) || other.sleepModifier == sleepModifier)&&(identical(other.hrvModifier, hrvModifier) || other.hrvModifier == hrvModifier)&&(identical(other.ageModifier, ageModifier) || other.ageModifier == ageModifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,muscleId,displayName,recoveryPercent,lastWorkedAt,hoursSinceWorkout,lastWorkoutStress,expectedStressFromWorkout,isPrimaryMuscle,sleepModifier,hrvModifier,ageModifier);

@override
String toString() {
  return 'MuscleReadinessData(muscleId: $muscleId, displayName: $displayName, recoveryPercent: $recoveryPercent, lastWorkedAt: $lastWorkedAt, hoursSinceWorkout: $hoursSinceWorkout, lastWorkoutStress: $lastWorkoutStress, expectedStressFromWorkout: $expectedStressFromWorkout, isPrimaryMuscle: $isPrimaryMuscle, sleepModifier: $sleepModifier, hrvModifier: $hrvModifier, ageModifier: $ageModifier)';
}


}

/// @nodoc
abstract mixin class $MuscleReadinessDataCopyWith<$Res>  {
  factory $MuscleReadinessDataCopyWith(MuscleReadinessData value, $Res Function(MuscleReadinessData) _then) = _$MuscleReadinessDataCopyWithImpl;
@useResult
$Res call({
 String muscleId, String displayName, double recoveryPercent, DateTime? lastWorkedAt, int hoursSinceWorkout, double lastWorkoutStress, double expectedStressFromWorkout, bool isPrimaryMuscle, double sleepModifier, double hrvModifier, double ageModifier
});




}
/// @nodoc
class _$MuscleReadinessDataCopyWithImpl<$Res>
    implements $MuscleReadinessDataCopyWith<$Res> {
  _$MuscleReadinessDataCopyWithImpl(this._self, this._then);

  final MuscleReadinessData _self;
  final $Res Function(MuscleReadinessData) _then;

/// Create a copy of MuscleReadinessData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? muscleId = null,Object? displayName = null,Object? recoveryPercent = null,Object? lastWorkedAt = freezed,Object? hoursSinceWorkout = null,Object? lastWorkoutStress = null,Object? expectedStressFromWorkout = null,Object? isPrimaryMuscle = null,Object? sleepModifier = null,Object? hrvModifier = null,Object? ageModifier = null,}) {
  return _then(_self.copyWith(
muscleId: null == muscleId ? _self.muscleId : muscleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,recoveryPercent: null == recoveryPercent ? _self.recoveryPercent : recoveryPercent // ignore: cast_nullable_to_non_nullable
as double,lastWorkedAt: freezed == lastWorkedAt ? _self.lastWorkedAt : lastWorkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hoursSinceWorkout: null == hoursSinceWorkout ? _self.hoursSinceWorkout : hoursSinceWorkout // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutStress: null == lastWorkoutStress ? _self.lastWorkoutStress : lastWorkoutStress // ignore: cast_nullable_to_non_nullable
as double,expectedStressFromWorkout: null == expectedStressFromWorkout ? _self.expectedStressFromWorkout : expectedStressFromWorkout // ignore: cast_nullable_to_non_nullable
as double,isPrimaryMuscle: null == isPrimaryMuscle ? _self.isPrimaryMuscle : isPrimaryMuscle // ignore: cast_nullable_to_non_nullable
as bool,sleepModifier: null == sleepModifier ? _self.sleepModifier : sleepModifier // ignore: cast_nullable_to_non_nullable
as double,hrvModifier: null == hrvModifier ? _self.hrvModifier : hrvModifier // ignore: cast_nullable_to_non_nullable
as double,ageModifier: null == ageModifier ? _self.ageModifier : ageModifier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleReadinessData].
extension MuscleReadinessDataPatterns on MuscleReadinessData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleReadinessData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleReadinessData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleReadinessData value)  $default,){
final _that = this;
switch (_that) {
case _MuscleReadinessData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleReadinessData value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleReadinessData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String muscleId,  String displayName,  double recoveryPercent,  DateTime? lastWorkedAt,  int hoursSinceWorkout,  double lastWorkoutStress,  double expectedStressFromWorkout,  bool isPrimaryMuscle,  double sleepModifier,  double hrvModifier,  double ageModifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleReadinessData() when $default != null:
return $default(_that.muscleId,_that.displayName,_that.recoveryPercent,_that.lastWorkedAt,_that.hoursSinceWorkout,_that.lastWorkoutStress,_that.expectedStressFromWorkout,_that.isPrimaryMuscle,_that.sleepModifier,_that.hrvModifier,_that.ageModifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String muscleId,  String displayName,  double recoveryPercent,  DateTime? lastWorkedAt,  int hoursSinceWorkout,  double lastWorkoutStress,  double expectedStressFromWorkout,  bool isPrimaryMuscle,  double sleepModifier,  double hrvModifier,  double ageModifier)  $default,) {final _that = this;
switch (_that) {
case _MuscleReadinessData():
return $default(_that.muscleId,_that.displayName,_that.recoveryPercent,_that.lastWorkedAt,_that.hoursSinceWorkout,_that.lastWorkoutStress,_that.expectedStressFromWorkout,_that.isPrimaryMuscle,_that.sleepModifier,_that.hrvModifier,_that.ageModifier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String muscleId,  String displayName,  double recoveryPercent,  DateTime? lastWorkedAt,  int hoursSinceWorkout,  double lastWorkoutStress,  double expectedStressFromWorkout,  bool isPrimaryMuscle,  double sleepModifier,  double hrvModifier,  double ageModifier)?  $default,) {final _that = this;
switch (_that) {
case _MuscleReadinessData() when $default != null:
return $default(_that.muscleId,_that.displayName,_that.recoveryPercent,_that.lastWorkedAt,_that.hoursSinceWorkout,_that.lastWorkoutStress,_that.expectedStressFromWorkout,_that.isPrimaryMuscle,_that.sleepModifier,_that.hrvModifier,_that.ageModifier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleReadinessData extends MuscleReadinessData {
  const _MuscleReadinessData({required this.muscleId, required this.displayName, required this.recoveryPercent, this.lastWorkedAt, required this.hoursSinceWorkout, this.lastWorkoutStress = 0, this.expectedStressFromWorkout = 0, this.isPrimaryMuscle = false, this.sleepModifier = 0, this.hrvModifier = 0, this.ageModifier = 0}): super._();
  factory _MuscleReadinessData.fromJson(Map<String, dynamic> json) => _$MuscleReadinessDataFromJson(json);

/// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
@override final  String muscleId;
/// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
@override final  String displayName;
/// Recovery percentage (0-150%)
/// Can exceed 100% if supercompensated
@override final  double recoveryPercent;
/// When this muscle was last worked
@override final  DateTime? lastWorkedAt;
/// Hours since last workout
@override final  int hoursSinceWorkout;
/// Stress from last workout (0-100)
@override@JsonKey() final  double lastWorkoutStress;
/// How this workout would stress this muscle (0-100)
@override@JsonKey() final  double expectedStressFromWorkout;
/// Whether this muscle is primary or secondary in the template
@override@JsonKey() final  bool isPrimaryMuscle;
// === CONTRIBUTING FACTORS ===
/// Sleep modifier applied (-30% to 0%)
@override@JsonKey() final  double sleepModifier;
/// HRV modifier applied (-25% to +10%)
@override@JsonKey() final  double hrvModifier;
/// Age modifier applied (-20% to 0%)
@override@JsonKey() final  double ageModifier;

/// Create a copy of MuscleReadinessData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleReadinessDataCopyWith<_MuscleReadinessData> get copyWith => __$MuscleReadinessDataCopyWithImpl<_MuscleReadinessData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleReadinessDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleReadinessData&&(identical(other.muscleId, muscleId) || other.muscleId == muscleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.recoveryPercent, recoveryPercent) || other.recoveryPercent == recoveryPercent)&&(identical(other.lastWorkedAt, lastWorkedAt) || other.lastWorkedAt == lastWorkedAt)&&(identical(other.hoursSinceWorkout, hoursSinceWorkout) || other.hoursSinceWorkout == hoursSinceWorkout)&&(identical(other.lastWorkoutStress, lastWorkoutStress) || other.lastWorkoutStress == lastWorkoutStress)&&(identical(other.expectedStressFromWorkout, expectedStressFromWorkout) || other.expectedStressFromWorkout == expectedStressFromWorkout)&&(identical(other.isPrimaryMuscle, isPrimaryMuscle) || other.isPrimaryMuscle == isPrimaryMuscle)&&(identical(other.sleepModifier, sleepModifier) || other.sleepModifier == sleepModifier)&&(identical(other.hrvModifier, hrvModifier) || other.hrvModifier == hrvModifier)&&(identical(other.ageModifier, ageModifier) || other.ageModifier == ageModifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,muscleId,displayName,recoveryPercent,lastWorkedAt,hoursSinceWorkout,lastWorkoutStress,expectedStressFromWorkout,isPrimaryMuscle,sleepModifier,hrvModifier,ageModifier);

@override
String toString() {
  return 'MuscleReadinessData(muscleId: $muscleId, displayName: $displayName, recoveryPercent: $recoveryPercent, lastWorkedAt: $lastWorkedAt, hoursSinceWorkout: $hoursSinceWorkout, lastWorkoutStress: $lastWorkoutStress, expectedStressFromWorkout: $expectedStressFromWorkout, isPrimaryMuscle: $isPrimaryMuscle, sleepModifier: $sleepModifier, hrvModifier: $hrvModifier, ageModifier: $ageModifier)';
}


}

/// @nodoc
abstract mixin class _$MuscleReadinessDataCopyWith<$Res> implements $MuscleReadinessDataCopyWith<$Res> {
  factory _$MuscleReadinessDataCopyWith(_MuscleReadinessData value, $Res Function(_MuscleReadinessData) _then) = __$MuscleReadinessDataCopyWithImpl;
@override @useResult
$Res call({
 String muscleId, String displayName, double recoveryPercent, DateTime? lastWorkedAt, int hoursSinceWorkout, double lastWorkoutStress, double expectedStressFromWorkout, bool isPrimaryMuscle, double sleepModifier, double hrvModifier, double ageModifier
});




}
/// @nodoc
class __$MuscleReadinessDataCopyWithImpl<$Res>
    implements _$MuscleReadinessDataCopyWith<$Res> {
  __$MuscleReadinessDataCopyWithImpl(this._self, this._then);

  final _MuscleReadinessData _self;
  final $Res Function(_MuscleReadinessData) _then;

/// Create a copy of MuscleReadinessData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? muscleId = null,Object? displayName = null,Object? recoveryPercent = null,Object? lastWorkedAt = freezed,Object? hoursSinceWorkout = null,Object? lastWorkoutStress = null,Object? expectedStressFromWorkout = null,Object? isPrimaryMuscle = null,Object? sleepModifier = null,Object? hrvModifier = null,Object? ageModifier = null,}) {
  return _then(_MuscleReadinessData(
muscleId: null == muscleId ? _self.muscleId : muscleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,recoveryPercent: null == recoveryPercent ? _self.recoveryPercent : recoveryPercent // ignore: cast_nullable_to_non_nullable
as double,lastWorkedAt: freezed == lastWorkedAt ? _self.lastWorkedAt : lastWorkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hoursSinceWorkout: null == hoursSinceWorkout ? _self.hoursSinceWorkout : hoursSinceWorkout // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutStress: null == lastWorkoutStress ? _self.lastWorkoutStress : lastWorkoutStress // ignore: cast_nullable_to_non_nullable
as double,expectedStressFromWorkout: null == expectedStressFromWorkout ? _self.expectedStressFromWorkout : expectedStressFromWorkout // ignore: cast_nullable_to_non_nullable
as double,isPrimaryMuscle: null == isPrimaryMuscle ? _self.isPrimaryMuscle : isPrimaryMuscle // ignore: cast_nullable_to_non_nullable
as bool,sleepModifier: null == sleepModifier ? _self.sleepModifier : sleepModifier // ignore: cast_nullable_to_non_nullable
as double,hrvModifier: null == hrvModifier ? _self.hrvModifier : hrvModifier // ignore: cast_nullable_to_non_nullable
as double,ageModifier: null == ageModifier ? _self.ageModifier : ageModifier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
