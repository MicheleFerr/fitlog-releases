// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_correction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleCorrection {

/// Exercise name (e.g., "Bench Press", "Squat")
 String get exerciseName;/// Original muscle group (e.g., "Chest", "Back")
 String get oldMuscleGroup;/// Corrected muscle group (e.g., "Shoulders", "Legs")
 String get newMuscleGroup;/// When the correction was made (local timestamp)
 DateTime get timestamp;
/// Create a copy of MuscleCorrection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleCorrectionCopyWith<MuscleCorrection> get copyWith => _$MuscleCorrectionCopyWithImpl<MuscleCorrection>(this as MuscleCorrection, _$identity);

  /// Serializes this MuscleCorrection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleCorrection&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.oldMuscleGroup, oldMuscleGroup) || other.oldMuscleGroup == oldMuscleGroup)&&(identical(other.newMuscleGroup, newMuscleGroup) || other.newMuscleGroup == newMuscleGroup)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,oldMuscleGroup,newMuscleGroup,timestamp);

@override
String toString() {
  return 'MuscleCorrection(exerciseName: $exerciseName, oldMuscleGroup: $oldMuscleGroup, newMuscleGroup: $newMuscleGroup, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $MuscleCorrectionCopyWith<$Res>  {
  factory $MuscleCorrectionCopyWith(MuscleCorrection value, $Res Function(MuscleCorrection) _then) = _$MuscleCorrectionCopyWithImpl;
@useResult
$Res call({
 String exerciseName, String oldMuscleGroup, String newMuscleGroup, DateTime timestamp
});




}
/// @nodoc
class _$MuscleCorrectionCopyWithImpl<$Res>
    implements $MuscleCorrectionCopyWith<$Res> {
  _$MuscleCorrectionCopyWithImpl(this._self, this._then);

  final MuscleCorrection _self;
  final $Res Function(MuscleCorrection) _then;

/// Create a copy of MuscleCorrection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? oldMuscleGroup = null,Object? newMuscleGroup = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,oldMuscleGroup: null == oldMuscleGroup ? _self.oldMuscleGroup : oldMuscleGroup // ignore: cast_nullable_to_non_nullable
as String,newMuscleGroup: null == newMuscleGroup ? _self.newMuscleGroup : newMuscleGroup // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleCorrection].
extension MuscleCorrectionPatterns on MuscleCorrection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleCorrection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleCorrection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleCorrection value)  $default,){
final _that = this;
switch (_that) {
case _MuscleCorrection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleCorrection value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleCorrection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  String oldMuscleGroup,  String newMuscleGroup,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleCorrection() when $default != null:
return $default(_that.exerciseName,_that.oldMuscleGroup,_that.newMuscleGroup,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  String oldMuscleGroup,  String newMuscleGroup,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _MuscleCorrection():
return $default(_that.exerciseName,_that.oldMuscleGroup,_that.newMuscleGroup,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  String oldMuscleGroup,  String newMuscleGroup,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _MuscleCorrection() when $default != null:
return $default(_that.exerciseName,_that.oldMuscleGroup,_that.newMuscleGroup,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleCorrection implements MuscleCorrection {
  const _MuscleCorrection({required this.exerciseName, required this.oldMuscleGroup, required this.newMuscleGroup, required this.timestamp});
  factory _MuscleCorrection.fromJson(Map<String, dynamic> json) => _$MuscleCorrectionFromJson(json);

/// Exercise name (e.g., "Bench Press", "Squat")
@override final  String exerciseName;
/// Original muscle group (e.g., "Chest", "Back")
@override final  String oldMuscleGroup;
/// Corrected muscle group (e.g., "Shoulders", "Legs")
@override final  String newMuscleGroup;
/// When the correction was made (local timestamp)
@override final  DateTime timestamp;

/// Create a copy of MuscleCorrection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleCorrectionCopyWith<_MuscleCorrection> get copyWith => __$MuscleCorrectionCopyWithImpl<_MuscleCorrection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleCorrectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleCorrection&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.oldMuscleGroup, oldMuscleGroup) || other.oldMuscleGroup == oldMuscleGroup)&&(identical(other.newMuscleGroup, newMuscleGroup) || other.newMuscleGroup == newMuscleGroup)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,oldMuscleGroup,newMuscleGroup,timestamp);

@override
String toString() {
  return 'MuscleCorrection(exerciseName: $exerciseName, oldMuscleGroup: $oldMuscleGroup, newMuscleGroup: $newMuscleGroup, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$MuscleCorrectionCopyWith<$Res> implements $MuscleCorrectionCopyWith<$Res> {
  factory _$MuscleCorrectionCopyWith(_MuscleCorrection value, $Res Function(_MuscleCorrection) _then) = __$MuscleCorrectionCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, String oldMuscleGroup, String newMuscleGroup, DateTime timestamp
});




}
/// @nodoc
class __$MuscleCorrectionCopyWithImpl<$Res>
    implements _$MuscleCorrectionCopyWith<$Res> {
  __$MuscleCorrectionCopyWithImpl(this._self, this._then);

  final _MuscleCorrection _self;
  final $Res Function(_MuscleCorrection) _then;

/// Create a copy of MuscleCorrection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? oldMuscleGroup = null,Object? newMuscleGroup = null,Object? timestamp = null,}) {
  return _then(_MuscleCorrection(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,oldMuscleGroup: null == oldMuscleGroup ? _self.oldMuscleGroup : oldMuscleGroup // ignore: cast_nullable_to_non_nullable
as String,newMuscleGroup: null == newMuscleGroup ? _self.newMuscleGroup : newMuscleGroup // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
