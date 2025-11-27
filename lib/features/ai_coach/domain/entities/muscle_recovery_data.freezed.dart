// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_recovery_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleRecoveryData {

/// Map of muscle group to recovery status
///
/// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
/// **Values**: MuscleRecoveryStatus with detailed metrics
 Map<MuscleGroup, MuscleRecoveryStatus> get muscleGroups;/// Overall recovery score (0-100)
///
/// **Calculation**: Average of all muscle group recovery scores
/// - 90-100: All muscles fully recovered
/// - 75-89: Most muscles recovered
/// - 60-74: Mixed recovery status
/// - 40-59: Multiple muscles fatigued
/// - 0-39: Significant fatigue across muscles
 int get overallRecoveryScore;/// Timestamp when data was calculated
 DateTime? get calculatedAt;
/// Create a copy of MuscleRecoveryData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleRecoveryDataCopyWith<MuscleRecoveryData> get copyWith => _$MuscleRecoveryDataCopyWithImpl<MuscleRecoveryData>(this as MuscleRecoveryData, _$identity);

  /// Serializes this MuscleRecoveryData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleRecoveryData&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&(identical(other.overallRecoveryScore, overallRecoveryScore) || other.overallRecoveryScore == overallRecoveryScore)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(muscleGroups),overallRecoveryScore,calculatedAt);

@override
String toString() {
  return 'MuscleRecoveryData(muscleGroups: $muscleGroups, overallRecoveryScore: $overallRecoveryScore, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $MuscleRecoveryDataCopyWith<$Res>  {
  factory $MuscleRecoveryDataCopyWith(MuscleRecoveryData value, $Res Function(MuscleRecoveryData) _then) = _$MuscleRecoveryDataCopyWithImpl;
@useResult
$Res call({
 Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups, int overallRecoveryScore, DateTime? calculatedAt
});




}
/// @nodoc
class _$MuscleRecoveryDataCopyWithImpl<$Res>
    implements $MuscleRecoveryDataCopyWith<$Res> {
  _$MuscleRecoveryDataCopyWithImpl(this._self, this._then);

  final MuscleRecoveryData _self;
  final $Res Function(MuscleRecoveryData) _then;

/// Create a copy of MuscleRecoveryData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? muscleGroups = null,Object? overallRecoveryScore = null,Object? calculatedAt = freezed,}) {
  return _then(_self.copyWith(
muscleGroups: null == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, MuscleRecoveryStatus>,overallRecoveryScore: null == overallRecoveryScore ? _self.overallRecoveryScore : overallRecoveryScore // ignore: cast_nullable_to_non_nullable
as int,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleRecoveryData].
extension MuscleRecoveryDataPatterns on MuscleRecoveryData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleRecoveryData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleRecoveryData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleRecoveryData value)  $default,){
final _that = this;
switch (_that) {
case _MuscleRecoveryData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleRecoveryData value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleRecoveryData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,  int overallRecoveryScore,  DateTime? calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleRecoveryData() when $default != null:
return $default(_that.muscleGroups,_that.overallRecoveryScore,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,  int overallRecoveryScore,  DateTime? calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _MuscleRecoveryData():
return $default(_that.muscleGroups,_that.overallRecoveryScore,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups,  int overallRecoveryScore,  DateTime? calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MuscleRecoveryData() when $default != null:
return $default(_that.muscleGroups,_that.overallRecoveryScore,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleRecoveryData extends MuscleRecoveryData {
  const _MuscleRecoveryData({required final  Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups, required this.overallRecoveryScore, this.calculatedAt = null}): _muscleGroups = muscleGroups,super._();
  factory _MuscleRecoveryData.fromJson(Map<String, dynamic> json) => _$MuscleRecoveryDataFromJson(json);

/// Map of muscle group to recovery status
///
/// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
/// **Values**: MuscleRecoveryStatus with detailed metrics
 final  Map<MuscleGroup, MuscleRecoveryStatus> _muscleGroups;
/// Map of muscle group to recovery status
///
/// **Keys**: MuscleGroup enum (chest, back, legs, etc.)
/// **Values**: MuscleRecoveryStatus with detailed metrics
@override Map<MuscleGroup, MuscleRecoveryStatus> get muscleGroups {
  if (_muscleGroups is EqualUnmodifiableMapView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_muscleGroups);
}

/// Overall recovery score (0-100)
///
/// **Calculation**: Average of all muscle group recovery scores
/// - 90-100: All muscles fully recovered
/// - 75-89: Most muscles recovered
/// - 60-74: Mixed recovery status
/// - 40-59: Multiple muscles fatigued
/// - 0-39: Significant fatigue across muscles
@override final  int overallRecoveryScore;
/// Timestamp when data was calculated
@override@JsonKey() final  DateTime? calculatedAt;

/// Create a copy of MuscleRecoveryData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleRecoveryDataCopyWith<_MuscleRecoveryData> get copyWith => __$MuscleRecoveryDataCopyWithImpl<_MuscleRecoveryData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleRecoveryDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleRecoveryData&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&(identical(other.overallRecoveryScore, overallRecoveryScore) || other.overallRecoveryScore == overallRecoveryScore)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_muscleGroups),overallRecoveryScore,calculatedAt);

@override
String toString() {
  return 'MuscleRecoveryData(muscleGroups: $muscleGroups, overallRecoveryScore: $overallRecoveryScore, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$MuscleRecoveryDataCopyWith<$Res> implements $MuscleRecoveryDataCopyWith<$Res> {
  factory _$MuscleRecoveryDataCopyWith(_MuscleRecoveryData value, $Res Function(_MuscleRecoveryData) _then) = __$MuscleRecoveryDataCopyWithImpl;
@override @useResult
$Res call({
 Map<MuscleGroup, MuscleRecoveryStatus> muscleGroups, int overallRecoveryScore, DateTime? calculatedAt
});




}
/// @nodoc
class __$MuscleRecoveryDataCopyWithImpl<$Res>
    implements _$MuscleRecoveryDataCopyWith<$Res> {
  __$MuscleRecoveryDataCopyWithImpl(this._self, this._then);

  final _MuscleRecoveryData _self;
  final $Res Function(_MuscleRecoveryData) _then;

/// Create a copy of MuscleRecoveryData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? muscleGroups = null,Object? overallRecoveryScore = null,Object? calculatedAt = freezed,}) {
  return _then(_MuscleRecoveryData(
muscleGroups: null == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, MuscleRecoveryStatus>,overallRecoveryScore: null == overallRecoveryScore ? _self.overallRecoveryScore : overallRecoveryScore // ignore: cast_nullable_to_non_nullable
as int,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MuscleRecoveryStatus {

/// Muscle group this status applies to
 MuscleGroup get group;/// Current recovery status
 RecoveryStatus get status;/// Days since last workout for this muscle
 int get daysSinceLastWorkout;/// Total volume load in last 7 days (sets × reps × weight)
///
/// Used to assess training intensity per muscle
 int get volumeLoad;/// Human-readable recommendation
///
/// **Examples**:
/// - "Ready for high volume training" (Fully Recovered)
/// - "Ready for normal training" (Recovered)
/// - "Light training recommended" (Partially Recovered)
/// - "Rest or alternative muscle groups" (Fatigued)
 String get recommendedAction;/// Optional: Estimated hours until fully recovered
///
/// **Calculation**: Based on 48-72h recovery window
/// - <24h: 24-48h remaining
/// - 24-48h: 0-24h remaining
/// - 48h+: 0h (fully recovered)
 int? get hoursUntilFullyRecovered;
/// Create a copy of MuscleRecoveryStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleRecoveryStatusCopyWith<MuscleRecoveryStatus> get copyWith => _$MuscleRecoveryStatusCopyWithImpl<MuscleRecoveryStatus>(this as MuscleRecoveryStatus, _$identity);

  /// Serializes this MuscleRecoveryStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleRecoveryStatus&&(identical(other.group, group) || other.group == group)&&(identical(other.status, status) || other.status == status)&&(identical(other.daysSinceLastWorkout, daysSinceLastWorkout) || other.daysSinceLastWorkout == daysSinceLastWorkout)&&(identical(other.volumeLoad, volumeLoad) || other.volumeLoad == volumeLoad)&&(identical(other.recommendedAction, recommendedAction) || other.recommendedAction == recommendedAction)&&(identical(other.hoursUntilFullyRecovered, hoursUntilFullyRecovered) || other.hoursUntilFullyRecovered == hoursUntilFullyRecovered));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,group,status,daysSinceLastWorkout,volumeLoad,recommendedAction,hoursUntilFullyRecovered);

@override
String toString() {
  return 'MuscleRecoveryStatus(group: $group, status: $status, daysSinceLastWorkout: $daysSinceLastWorkout, volumeLoad: $volumeLoad, recommendedAction: $recommendedAction, hoursUntilFullyRecovered: $hoursUntilFullyRecovered)';
}


}

/// @nodoc
abstract mixin class $MuscleRecoveryStatusCopyWith<$Res>  {
  factory $MuscleRecoveryStatusCopyWith(MuscleRecoveryStatus value, $Res Function(MuscleRecoveryStatus) _then) = _$MuscleRecoveryStatusCopyWithImpl;
@useResult
$Res call({
 MuscleGroup group, RecoveryStatus status, int daysSinceLastWorkout, int volumeLoad, String recommendedAction, int? hoursUntilFullyRecovered
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
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? status = null,Object? daysSinceLastWorkout = null,Object? volumeLoad = null,Object? recommendedAction = null,Object? hoursUntilFullyRecovered = freezed,}) {
  return _then(_self.copyWith(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as MuscleGroup,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecoveryStatus,daysSinceLastWorkout: null == daysSinceLastWorkout ? _self.daysSinceLastWorkout : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
as int,volumeLoad: null == volumeLoad ? _self.volumeLoad : volumeLoad // ignore: cast_nullable_to_non_nullable
as int,recommendedAction: null == recommendedAction ? _self.recommendedAction : recommendedAction // ignore: cast_nullable_to_non_nullable
as String,hoursUntilFullyRecovered: freezed == hoursUntilFullyRecovered ? _self.hoursUntilFullyRecovered : hoursUntilFullyRecovered // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MuscleGroup group,  RecoveryStatus status,  int daysSinceLastWorkout,  int volumeLoad,  String recommendedAction,  int? hoursUntilFullyRecovered)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleRecoveryStatus() when $default != null:
return $default(_that.group,_that.status,_that.daysSinceLastWorkout,_that.volumeLoad,_that.recommendedAction,_that.hoursUntilFullyRecovered);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MuscleGroup group,  RecoveryStatus status,  int daysSinceLastWorkout,  int volumeLoad,  String recommendedAction,  int? hoursUntilFullyRecovered)  $default,) {final _that = this;
switch (_that) {
case _MuscleRecoveryStatus():
return $default(_that.group,_that.status,_that.daysSinceLastWorkout,_that.volumeLoad,_that.recommendedAction,_that.hoursUntilFullyRecovered);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MuscleGroup group,  RecoveryStatus status,  int daysSinceLastWorkout,  int volumeLoad,  String recommendedAction,  int? hoursUntilFullyRecovered)?  $default,) {final _that = this;
switch (_that) {
case _MuscleRecoveryStatus() when $default != null:
return $default(_that.group,_that.status,_that.daysSinceLastWorkout,_that.volumeLoad,_that.recommendedAction,_that.hoursUntilFullyRecovered);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleRecoveryStatus extends MuscleRecoveryStatus {
  const _MuscleRecoveryStatus({required this.group, required this.status, required this.daysSinceLastWorkout, required this.volumeLoad, required this.recommendedAction, this.hoursUntilFullyRecovered}): super._();
  factory _MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) => _$MuscleRecoveryStatusFromJson(json);

/// Muscle group this status applies to
@override final  MuscleGroup group;
/// Current recovery status
@override final  RecoveryStatus status;
/// Days since last workout for this muscle
@override final  int daysSinceLastWorkout;
/// Total volume load in last 7 days (sets × reps × weight)
///
/// Used to assess training intensity per muscle
@override final  int volumeLoad;
/// Human-readable recommendation
///
/// **Examples**:
/// - "Ready for high volume training" (Fully Recovered)
/// - "Ready for normal training" (Recovered)
/// - "Light training recommended" (Partially Recovered)
/// - "Rest or alternative muscle groups" (Fatigued)
@override final  String recommendedAction;
/// Optional: Estimated hours until fully recovered
///
/// **Calculation**: Based on 48-72h recovery window
/// - <24h: 24-48h remaining
/// - 24-48h: 0-24h remaining
/// - 48h+: 0h (fully recovered)
@override final  int? hoursUntilFullyRecovered;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleRecoveryStatus&&(identical(other.group, group) || other.group == group)&&(identical(other.status, status) || other.status == status)&&(identical(other.daysSinceLastWorkout, daysSinceLastWorkout) || other.daysSinceLastWorkout == daysSinceLastWorkout)&&(identical(other.volumeLoad, volumeLoad) || other.volumeLoad == volumeLoad)&&(identical(other.recommendedAction, recommendedAction) || other.recommendedAction == recommendedAction)&&(identical(other.hoursUntilFullyRecovered, hoursUntilFullyRecovered) || other.hoursUntilFullyRecovered == hoursUntilFullyRecovered));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,group,status,daysSinceLastWorkout,volumeLoad,recommendedAction,hoursUntilFullyRecovered);

@override
String toString() {
  return 'MuscleRecoveryStatus(group: $group, status: $status, daysSinceLastWorkout: $daysSinceLastWorkout, volumeLoad: $volumeLoad, recommendedAction: $recommendedAction, hoursUntilFullyRecovered: $hoursUntilFullyRecovered)';
}


}

/// @nodoc
abstract mixin class _$MuscleRecoveryStatusCopyWith<$Res> implements $MuscleRecoveryStatusCopyWith<$Res> {
  factory _$MuscleRecoveryStatusCopyWith(_MuscleRecoveryStatus value, $Res Function(_MuscleRecoveryStatus) _then) = __$MuscleRecoveryStatusCopyWithImpl;
@override @useResult
$Res call({
 MuscleGroup group, RecoveryStatus status, int daysSinceLastWorkout, int volumeLoad, String recommendedAction, int? hoursUntilFullyRecovered
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
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? status = null,Object? daysSinceLastWorkout = null,Object? volumeLoad = null,Object? recommendedAction = null,Object? hoursUntilFullyRecovered = freezed,}) {
  return _then(_MuscleRecoveryStatus(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as MuscleGroup,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecoveryStatus,daysSinceLastWorkout: null == daysSinceLastWorkout ? _self.daysSinceLastWorkout : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
as int,volumeLoad: null == volumeLoad ? _self.volumeLoad : volumeLoad // ignore: cast_nullable_to_non_nullable
as int,recommendedAction: null == recommendedAction ? _self.recommendedAction : recommendedAction // ignore: cast_nullable_to_non_nullable
as String,hoursUntilFullyRecovered: freezed == hoursUntilFullyRecovered ? _self.hoursUntilFullyRecovered : hoursUntilFullyRecovered // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
