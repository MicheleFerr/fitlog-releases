// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_recovery_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleRecoveryStatus {

/// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
 String get muscleId;/// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
 String get displayName;/// Recovery percentage (0-100+)
/// Can exceed 100% if fully recovered and supercompensated
 double get recoveryPercentage;/// When this muscle was last worked
 DateTime get lastWorked;/// Stress score from last workout
 double get lastStressScore;/// Current recovery state
 RecoveryState get state;
/// Create a copy of MuscleRecoveryStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleRecoveryStatusCopyWith<MuscleRecoveryStatus> get copyWith => _$MuscleRecoveryStatusCopyWithImpl<MuscleRecoveryStatus>(this as MuscleRecoveryStatus, _$identity);

  /// Serializes this MuscleRecoveryStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleRecoveryStatus&&(identical(other.muscleId, muscleId) || other.muscleId == muscleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.recoveryPercentage, recoveryPercentage) || other.recoveryPercentage == recoveryPercentage)&&(identical(other.lastWorked, lastWorked) || other.lastWorked == lastWorked)&&(identical(other.lastStressScore, lastStressScore) || other.lastStressScore == lastStressScore)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,muscleId,displayName,recoveryPercentage,lastWorked,lastStressScore,state);

@override
String toString() {
  return 'MuscleRecoveryStatus(muscleId: $muscleId, displayName: $displayName, recoveryPercentage: $recoveryPercentage, lastWorked: $lastWorked, lastStressScore: $lastStressScore, state: $state)';
}


}

/// @nodoc
abstract mixin class $MuscleRecoveryStatusCopyWith<$Res>  {
  factory $MuscleRecoveryStatusCopyWith(MuscleRecoveryStatus value, $Res Function(MuscleRecoveryStatus) _then) = _$MuscleRecoveryStatusCopyWithImpl;
@useResult
$Res call({
 String muscleId, String displayName, double recoveryPercentage, DateTime lastWorked, double lastStressScore, RecoveryState state
});




}
/// @nodoc
class _$MuscleRecoveryStatusCopyWithImpl<$Res>
    implements $MuscleRecoveryStatusCopyWith<$Res> {
  _$MuscleRecoveryStatusCopyWithImpl(this._self, this._then);

  final MuscleRecoveryStatus _self;
  final $Res Function(MuscleRecoveryStatus) _then;

/// Create a copy of MuscleRecoveryStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? muscleId = null,Object? displayName = null,Object? recoveryPercentage = null,Object? lastWorked = null,Object? lastStressScore = null,Object? state = null,}) {
  return _then(_self.copyWith(
muscleId: null == muscleId ? _self.muscleId : muscleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,recoveryPercentage: null == recoveryPercentage ? _self.recoveryPercentage : recoveryPercentage // ignore: cast_nullable_to_non_nullable
as double,lastWorked: null == lastWorked ? _self.lastWorked : lastWorked // ignore: cast_nullable_to_non_nullable
as DateTime,lastStressScore: null == lastStressScore ? _self.lastStressScore : lastStressScore // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RecoveryState,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleRecoveryStatus].
extension MuscleRecoveryStatusPatterns on MuscleRecoveryStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleRecoveryStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleRecoveryStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleRecoveryStatus value)  $default,){
final _that = this;
switch (_that) {
case _MuscleRecoveryStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleRecoveryStatus value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleRecoveryStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String muscleId,  String displayName,  double recoveryPercentage,  DateTime lastWorked,  double lastStressScore,  RecoveryState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleRecoveryStatus() when $default != null:
return $default(_that.muscleId,_that.displayName,_that.recoveryPercentage,_that.lastWorked,_that.lastStressScore,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String muscleId,  String displayName,  double recoveryPercentage,  DateTime lastWorked,  double lastStressScore,  RecoveryState state)  $default,) {final _that = this;
switch (_that) {
case _MuscleRecoveryStatus():
return $default(_that.muscleId,_that.displayName,_that.recoveryPercentage,_that.lastWorked,_that.lastStressScore,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String muscleId,  String displayName,  double recoveryPercentage,  DateTime lastWorked,  double lastStressScore,  RecoveryState state)?  $default,) {final _that = this;
switch (_that) {
case _MuscleRecoveryStatus() when $default != null:
return $default(_that.muscleId,_that.displayName,_that.recoveryPercentage,_that.lastWorked,_that.lastStressScore,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleRecoveryStatus extends MuscleRecoveryStatus {
  const _MuscleRecoveryStatus({required this.muscleId, required this.displayName, required this.recoveryPercentage, required this.lastWorked, required this.lastStressScore, required this.state}): super._();
  factory _MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) => _$MuscleRecoveryStatusFromJson(json);

/// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
@override final  String muscleId;
/// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
@override final  String displayName;
/// Recovery percentage (0-100+)
/// Can exceed 100% if fully recovered and supercompensated
@override final  double recoveryPercentage;
/// When this muscle was last worked
@override final  DateTime lastWorked;
/// Stress score from last workout
@override final  double lastStressScore;
/// Current recovery state
@override final  RecoveryState state;

/// Create a copy of MuscleRecoveryStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleRecoveryStatusCopyWith<_MuscleRecoveryStatus> get copyWith => __$MuscleRecoveryStatusCopyWithImpl<_MuscleRecoveryStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleRecoveryStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleRecoveryStatus&&(identical(other.muscleId, muscleId) || other.muscleId == muscleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.recoveryPercentage, recoveryPercentage) || other.recoveryPercentage == recoveryPercentage)&&(identical(other.lastWorked, lastWorked) || other.lastWorked == lastWorked)&&(identical(other.lastStressScore, lastStressScore) || other.lastStressScore == lastStressScore)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,muscleId,displayName,recoveryPercentage,lastWorked,lastStressScore,state);

@override
String toString() {
  return 'MuscleRecoveryStatus(muscleId: $muscleId, displayName: $displayName, recoveryPercentage: $recoveryPercentage, lastWorked: $lastWorked, lastStressScore: $lastStressScore, state: $state)';
}


}

/// @nodoc
abstract mixin class _$MuscleRecoveryStatusCopyWith<$Res> implements $MuscleRecoveryStatusCopyWith<$Res> {
  factory _$MuscleRecoveryStatusCopyWith(_MuscleRecoveryStatus value, $Res Function(_MuscleRecoveryStatus) _then) = __$MuscleRecoveryStatusCopyWithImpl;
@override @useResult
$Res call({
 String muscleId, String displayName, double recoveryPercentage, DateTime lastWorked, double lastStressScore, RecoveryState state
});




}
/// @nodoc
class __$MuscleRecoveryStatusCopyWithImpl<$Res>
    implements _$MuscleRecoveryStatusCopyWith<$Res> {
  __$MuscleRecoveryStatusCopyWithImpl(this._self, this._then);

  final _MuscleRecoveryStatus _self;
  final $Res Function(_MuscleRecoveryStatus) _then;

/// Create a copy of MuscleRecoveryStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? muscleId = null,Object? displayName = null,Object? recoveryPercentage = null,Object? lastWorked = null,Object? lastStressScore = null,Object? state = null,}) {
  return _then(_MuscleRecoveryStatus(
muscleId: null == muscleId ? _self.muscleId : muscleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,recoveryPercentage: null == recoveryPercentage ? _self.recoveryPercentage : recoveryPercentage // ignore: cast_nullable_to_non_nullable
as double,lastWorked: null == lastWorked ? _self.lastWorked : lastWorked // ignore: cast_nullable_to_non_nullable
as DateTime,lastStressScore: null == lastStressScore ? _self.lastStressScore : lastStressScore // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RecoveryState,
  ));
}


}

// dart format on
