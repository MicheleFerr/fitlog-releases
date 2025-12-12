// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_stress_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleStressData {

/// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
 String get muscleId;/// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
 String get displayName;/// Stress score for this muscle (0-100, logarithmic)
 double get stressScore;/// Number of sets targeting this muscle
 int get setsCount;/// Total volume for this muscle (kg × reps)
 double get totalVolume;/// Average RPE for sets targeting this muscle
/// 0 if no RPE data available
 double get avgRpe;/// Estimated recovery time in hours
 int get recoveryHours;/// Estimated full recovery timestamp
 DateTime? get estimatedRecovery;
/// Create a copy of MuscleStressData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleStressDataCopyWith<MuscleStressData> get copyWith => _$MuscleStressDataCopyWithImpl<MuscleStressData>(this as MuscleStressData, _$identity);

  /// Serializes this MuscleStressData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleStressData&&(identical(other.muscleId, muscleId) || other.muscleId == muscleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.stressScore, stressScore) || other.stressScore == stressScore)&&(identical(other.setsCount, setsCount) || other.setsCount == setsCount)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&(identical(other.avgRpe, avgRpe) || other.avgRpe == avgRpe)&&(identical(other.recoveryHours, recoveryHours) || other.recoveryHours == recoveryHours)&&(identical(other.estimatedRecovery, estimatedRecovery) || other.estimatedRecovery == estimatedRecovery));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,muscleId,displayName,stressScore,setsCount,totalVolume,avgRpe,recoveryHours,estimatedRecovery);

@override
String toString() {
  return 'MuscleStressData(muscleId: $muscleId, displayName: $displayName, stressScore: $stressScore, setsCount: $setsCount, totalVolume: $totalVolume, avgRpe: $avgRpe, recoveryHours: $recoveryHours, estimatedRecovery: $estimatedRecovery)';
}


}

/// @nodoc
abstract mixin class $MuscleStressDataCopyWith<$Res>  {
  factory $MuscleStressDataCopyWith(MuscleStressData value, $Res Function(MuscleStressData) _then) = _$MuscleStressDataCopyWithImpl;
@useResult
$Res call({
 String muscleId, String displayName, double stressScore, int setsCount, double totalVolume, double avgRpe, int recoveryHours, DateTime? estimatedRecovery
});




}
/// @nodoc
class _$MuscleStressDataCopyWithImpl<$Res>
    implements $MuscleStressDataCopyWith<$Res> {
  _$MuscleStressDataCopyWithImpl(this._self, this._then);

  final MuscleStressData _self;
  final $Res Function(MuscleStressData) _then;

/// Create a copy of MuscleStressData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? muscleId = null,Object? displayName = null,Object? stressScore = null,Object? setsCount = null,Object? totalVolume = null,Object? avgRpe = null,Object? recoveryHours = null,Object? estimatedRecovery = freezed,}) {
  return _then(_self.copyWith(
muscleId: null == muscleId ? _self.muscleId : muscleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,stressScore: null == stressScore ? _self.stressScore : stressScore // ignore: cast_nullable_to_non_nullable
as double,setsCount: null == setsCount ? _self.setsCount : setsCount // ignore: cast_nullable_to_non_nullable
as int,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,avgRpe: null == avgRpe ? _self.avgRpe : avgRpe // ignore: cast_nullable_to_non_nullable
as double,recoveryHours: null == recoveryHours ? _self.recoveryHours : recoveryHours // ignore: cast_nullable_to_non_nullable
as int,estimatedRecovery: freezed == estimatedRecovery ? _self.estimatedRecovery : estimatedRecovery // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleStressData].
extension MuscleStressDataPatterns on MuscleStressData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleStressData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleStressData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleStressData value)  $default,){
final _that = this;
switch (_that) {
case _MuscleStressData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleStressData value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleStressData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String muscleId,  String displayName,  double stressScore,  int setsCount,  double totalVolume,  double avgRpe,  int recoveryHours,  DateTime? estimatedRecovery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleStressData() when $default != null:
return $default(_that.muscleId,_that.displayName,_that.stressScore,_that.setsCount,_that.totalVolume,_that.avgRpe,_that.recoveryHours,_that.estimatedRecovery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String muscleId,  String displayName,  double stressScore,  int setsCount,  double totalVolume,  double avgRpe,  int recoveryHours,  DateTime? estimatedRecovery)  $default,) {final _that = this;
switch (_that) {
case _MuscleStressData():
return $default(_that.muscleId,_that.displayName,_that.stressScore,_that.setsCount,_that.totalVolume,_that.avgRpe,_that.recoveryHours,_that.estimatedRecovery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String muscleId,  String displayName,  double stressScore,  int setsCount,  double totalVolume,  double avgRpe,  int recoveryHours,  DateTime? estimatedRecovery)?  $default,) {final _that = this;
switch (_that) {
case _MuscleStressData() when $default != null:
return $default(_that.muscleId,_that.displayName,_that.stressScore,_that.setsCount,_that.totalVolume,_that.avgRpe,_that.recoveryHours,_that.estimatedRecovery);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleStressData extends MuscleStressData {
  const _MuscleStressData({required this.muscleId, required this.displayName, required this.stressScore, required this.setsCount, required this.totalVolume, required this.avgRpe, required this.recoveryHours, required this.estimatedRecovery}): super._();
  factory _MuscleStressData.fromJson(Map<String, dynamic> json) => _$MuscleStressDataFromJson(json);

/// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
@override final  String muscleId;
/// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
@override final  String displayName;
/// Stress score for this muscle (0-100, logarithmic)
@override final  double stressScore;
/// Number of sets targeting this muscle
@override final  int setsCount;
/// Total volume for this muscle (kg × reps)
@override final  double totalVolume;
/// Average RPE for sets targeting this muscle
/// 0 if no RPE data available
@override final  double avgRpe;
/// Estimated recovery time in hours
@override final  int recoveryHours;
/// Estimated full recovery timestamp
@override final  DateTime? estimatedRecovery;

/// Create a copy of MuscleStressData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleStressDataCopyWith<_MuscleStressData> get copyWith => __$MuscleStressDataCopyWithImpl<_MuscleStressData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleStressDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleStressData&&(identical(other.muscleId, muscleId) || other.muscleId == muscleId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.stressScore, stressScore) || other.stressScore == stressScore)&&(identical(other.setsCount, setsCount) || other.setsCount == setsCount)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&(identical(other.avgRpe, avgRpe) || other.avgRpe == avgRpe)&&(identical(other.recoveryHours, recoveryHours) || other.recoveryHours == recoveryHours)&&(identical(other.estimatedRecovery, estimatedRecovery) || other.estimatedRecovery == estimatedRecovery));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,muscleId,displayName,stressScore,setsCount,totalVolume,avgRpe,recoveryHours,estimatedRecovery);

@override
String toString() {
  return 'MuscleStressData(muscleId: $muscleId, displayName: $displayName, stressScore: $stressScore, setsCount: $setsCount, totalVolume: $totalVolume, avgRpe: $avgRpe, recoveryHours: $recoveryHours, estimatedRecovery: $estimatedRecovery)';
}


}

/// @nodoc
abstract mixin class _$MuscleStressDataCopyWith<$Res> implements $MuscleStressDataCopyWith<$Res> {
  factory _$MuscleStressDataCopyWith(_MuscleStressData value, $Res Function(_MuscleStressData) _then) = __$MuscleStressDataCopyWithImpl;
@override @useResult
$Res call({
 String muscleId, String displayName, double stressScore, int setsCount, double totalVolume, double avgRpe, int recoveryHours, DateTime? estimatedRecovery
});




}
/// @nodoc
class __$MuscleStressDataCopyWithImpl<$Res>
    implements _$MuscleStressDataCopyWith<$Res> {
  __$MuscleStressDataCopyWithImpl(this._self, this._then);

  final _MuscleStressData _self;
  final $Res Function(_MuscleStressData) _then;

/// Create a copy of MuscleStressData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? muscleId = null,Object? displayName = null,Object? stressScore = null,Object? setsCount = null,Object? totalVolume = null,Object? avgRpe = null,Object? recoveryHours = null,Object? estimatedRecovery = freezed,}) {
  return _then(_MuscleStressData(
muscleId: null == muscleId ? _self.muscleId : muscleId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,stressScore: null == stressScore ? _self.stressScore : stressScore // ignore: cast_nullable_to_non_nullable
as double,setsCount: null == setsCount ? _self.setsCount : setsCount // ignore: cast_nullable_to_non_nullable
as int,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,avgRpe: null == avgRpe ? _self.avgRpe : avgRpe // ignore: cast_nullable_to_non_nullable
as double,recoveryHours: null == recoveryHours ? _self.recoveryHours : recoveryHours // ignore: cast_nullable_to_non_nullable
as int,estimatedRecovery: freezed == estimatedRecovery ? _self.estimatedRecovery : estimatedRecovery // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
