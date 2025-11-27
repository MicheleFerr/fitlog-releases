// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_mapping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseMapping {

/// GymBro exercise ID
 String get gymbroId;/// GymBro exercise name
 String get gymbroName;/// GymBro equipment type
 String get gymbroEquipment;/// GymBro muscle focus (e.g., "PETT, TRIC") - nullable for exercises without defined focus
 String? get gymbroFocus;/// Semantic similarity confidence (0.0-1.0)
 double get confidence;/// Mapping status: "auto", "review", or "fallback"
 MappingStatus get status;/// Strength standard ID (null if fallback)
 String? get standardId;/// Strength standard name (null if fallback)
 String? get standardName;/// Strength standard equipment (null if fallback)
 String? get standardEquipment;/// Data source (null if fallback)
 String? get dataSource;/// Fallback reason (only for fallback status)
 String? get fallbackReason;
/// Create a copy of ExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseMappingCopyWith<ExerciseMapping> get copyWith => _$ExerciseMappingCopyWithImpl<ExerciseMapping>(this as ExerciseMapping, _$identity);

  /// Serializes this ExerciseMapping to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseMapping&&(identical(other.gymbroId, gymbroId) || other.gymbroId == gymbroId)&&(identical(other.gymbroName, gymbroName) || other.gymbroName == gymbroName)&&(identical(other.gymbroEquipment, gymbroEquipment) || other.gymbroEquipment == gymbroEquipment)&&(identical(other.gymbroFocus, gymbroFocus) || other.gymbroFocus == gymbroFocus)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.standardId, standardId) || other.standardId == standardId)&&(identical(other.standardName, standardName) || other.standardName == standardName)&&(identical(other.standardEquipment, standardEquipment) || other.standardEquipment == standardEquipment)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.fallbackReason, fallbackReason) || other.fallbackReason == fallbackReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gymbroId,gymbroName,gymbroEquipment,gymbroFocus,confidence,status,standardId,standardName,standardEquipment,dataSource,fallbackReason);

@override
String toString() {
  return 'ExerciseMapping(gymbroId: $gymbroId, gymbroName: $gymbroName, gymbroEquipment: $gymbroEquipment, gymbroFocus: $gymbroFocus, confidence: $confidence, status: $status, standardId: $standardId, standardName: $standardName, standardEquipment: $standardEquipment, dataSource: $dataSource, fallbackReason: $fallbackReason)';
}


}

/// @nodoc
abstract mixin class $ExerciseMappingCopyWith<$Res>  {
  factory $ExerciseMappingCopyWith(ExerciseMapping value, $Res Function(ExerciseMapping) _then) = _$ExerciseMappingCopyWithImpl;
@useResult
$Res call({
 String gymbroId, String gymbroName, String gymbroEquipment, String? gymbroFocus, double confidence, MappingStatus status, String? standardId, String? standardName, String? standardEquipment, String? dataSource, String? fallbackReason
});




}
/// @nodoc
class _$ExerciseMappingCopyWithImpl<$Res>
    implements $ExerciseMappingCopyWith<$Res> {
  _$ExerciseMappingCopyWithImpl(this._self, this._then);

  final ExerciseMapping _self;
  final $Res Function(ExerciseMapping) _then;

/// Create a copy of ExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gymbroId = null,Object? gymbroName = null,Object? gymbroEquipment = null,Object? gymbroFocus = freezed,Object? confidence = null,Object? status = null,Object? standardId = freezed,Object? standardName = freezed,Object? standardEquipment = freezed,Object? dataSource = freezed,Object? fallbackReason = freezed,}) {
  return _then(_self.copyWith(
gymbroId: null == gymbroId ? _self.gymbroId : gymbroId // ignore: cast_nullable_to_non_nullable
as String,gymbroName: null == gymbroName ? _self.gymbroName : gymbroName // ignore: cast_nullable_to_non_nullable
as String,gymbroEquipment: null == gymbroEquipment ? _self.gymbroEquipment : gymbroEquipment // ignore: cast_nullable_to_non_nullable
as String,gymbroFocus: freezed == gymbroFocus ? _self.gymbroFocus : gymbroFocus // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MappingStatus,standardId: freezed == standardId ? _self.standardId : standardId // ignore: cast_nullable_to_non_nullable
as String?,standardName: freezed == standardName ? _self.standardName : standardName // ignore: cast_nullable_to_non_nullable
as String?,standardEquipment: freezed == standardEquipment ? _self.standardEquipment : standardEquipment // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,fallbackReason: freezed == fallbackReason ? _self.fallbackReason : fallbackReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseMapping].
extension ExerciseMappingPatterns on ExerciseMapping {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseMapping value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseMapping() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseMapping value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseMapping():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseMapping value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseMapping() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String gymbroId,  String gymbroName,  String gymbroEquipment,  String? gymbroFocus,  double confidence,  MappingStatus status,  String? standardId,  String? standardName,  String? standardEquipment,  String? dataSource,  String? fallbackReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseMapping() when $default != null:
return $default(_that.gymbroId,_that.gymbroName,_that.gymbroEquipment,_that.gymbroFocus,_that.confidence,_that.status,_that.standardId,_that.standardName,_that.standardEquipment,_that.dataSource,_that.fallbackReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String gymbroId,  String gymbroName,  String gymbroEquipment,  String? gymbroFocus,  double confidence,  MappingStatus status,  String? standardId,  String? standardName,  String? standardEquipment,  String? dataSource,  String? fallbackReason)  $default,) {final _that = this;
switch (_that) {
case _ExerciseMapping():
return $default(_that.gymbroId,_that.gymbroName,_that.gymbroEquipment,_that.gymbroFocus,_that.confidence,_that.status,_that.standardId,_that.standardName,_that.standardEquipment,_that.dataSource,_that.fallbackReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String gymbroId,  String gymbroName,  String gymbroEquipment,  String? gymbroFocus,  double confidence,  MappingStatus status,  String? standardId,  String? standardName,  String? standardEquipment,  String? dataSource,  String? fallbackReason)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseMapping() when $default != null:
return $default(_that.gymbroId,_that.gymbroName,_that.gymbroEquipment,_that.gymbroFocus,_that.confidence,_that.status,_that.standardId,_that.standardName,_that.standardEquipment,_that.dataSource,_that.fallbackReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseMapping implements ExerciseMapping {
  const _ExerciseMapping({required this.gymbroId, required this.gymbroName, required this.gymbroEquipment, this.gymbroFocus, required this.confidence, required this.status, this.standardId, this.standardName, this.standardEquipment, this.dataSource, this.fallbackReason});
  factory _ExerciseMapping.fromJson(Map<String, dynamic> json) => _$ExerciseMappingFromJson(json);

/// GymBro exercise ID
@override final  String gymbroId;
/// GymBro exercise name
@override final  String gymbroName;
/// GymBro equipment type
@override final  String gymbroEquipment;
/// GymBro muscle focus (e.g., "PETT, TRIC") - nullable for exercises without defined focus
@override final  String? gymbroFocus;
/// Semantic similarity confidence (0.0-1.0)
@override final  double confidence;
/// Mapping status: "auto", "review", or "fallback"
@override final  MappingStatus status;
/// Strength standard ID (null if fallback)
@override final  String? standardId;
/// Strength standard name (null if fallback)
@override final  String? standardName;
/// Strength standard equipment (null if fallback)
@override final  String? standardEquipment;
/// Data source (null if fallback)
@override final  String? dataSource;
/// Fallback reason (only for fallback status)
@override final  String? fallbackReason;

/// Create a copy of ExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseMappingCopyWith<_ExerciseMapping> get copyWith => __$ExerciseMappingCopyWithImpl<_ExerciseMapping>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseMappingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseMapping&&(identical(other.gymbroId, gymbroId) || other.gymbroId == gymbroId)&&(identical(other.gymbroName, gymbroName) || other.gymbroName == gymbroName)&&(identical(other.gymbroEquipment, gymbroEquipment) || other.gymbroEquipment == gymbroEquipment)&&(identical(other.gymbroFocus, gymbroFocus) || other.gymbroFocus == gymbroFocus)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.standardId, standardId) || other.standardId == standardId)&&(identical(other.standardName, standardName) || other.standardName == standardName)&&(identical(other.standardEquipment, standardEquipment) || other.standardEquipment == standardEquipment)&&(identical(other.dataSource, dataSource) || other.dataSource == dataSource)&&(identical(other.fallbackReason, fallbackReason) || other.fallbackReason == fallbackReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gymbroId,gymbroName,gymbroEquipment,gymbroFocus,confidence,status,standardId,standardName,standardEquipment,dataSource,fallbackReason);

@override
String toString() {
  return 'ExerciseMapping(gymbroId: $gymbroId, gymbroName: $gymbroName, gymbroEquipment: $gymbroEquipment, gymbroFocus: $gymbroFocus, confidence: $confidence, status: $status, standardId: $standardId, standardName: $standardName, standardEquipment: $standardEquipment, dataSource: $dataSource, fallbackReason: $fallbackReason)';
}


}

/// @nodoc
abstract mixin class _$ExerciseMappingCopyWith<$Res> implements $ExerciseMappingCopyWith<$Res> {
  factory _$ExerciseMappingCopyWith(_ExerciseMapping value, $Res Function(_ExerciseMapping) _then) = __$ExerciseMappingCopyWithImpl;
@override @useResult
$Res call({
 String gymbroId, String gymbroName, String gymbroEquipment, String? gymbroFocus, double confidence, MappingStatus status, String? standardId, String? standardName, String? standardEquipment, String? dataSource, String? fallbackReason
});




}
/// @nodoc
class __$ExerciseMappingCopyWithImpl<$Res>
    implements _$ExerciseMappingCopyWith<$Res> {
  __$ExerciseMappingCopyWithImpl(this._self, this._then);

  final _ExerciseMapping _self;
  final $Res Function(_ExerciseMapping) _then;

/// Create a copy of ExerciseMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gymbroId = null,Object? gymbroName = null,Object? gymbroEquipment = null,Object? gymbroFocus = freezed,Object? confidence = null,Object? status = null,Object? standardId = freezed,Object? standardName = freezed,Object? standardEquipment = freezed,Object? dataSource = freezed,Object? fallbackReason = freezed,}) {
  return _then(_ExerciseMapping(
gymbroId: null == gymbroId ? _self.gymbroId : gymbroId // ignore: cast_nullable_to_non_nullable
as String,gymbroName: null == gymbroName ? _self.gymbroName : gymbroName // ignore: cast_nullable_to_non_nullable
as String,gymbroEquipment: null == gymbroEquipment ? _self.gymbroEquipment : gymbroEquipment // ignore: cast_nullable_to_non_nullable
as String,gymbroFocus: freezed == gymbroFocus ? _self.gymbroFocus : gymbroFocus // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MappingStatus,standardId: freezed == standardId ? _self.standardId : standardId // ignore: cast_nullable_to_non_nullable
as String?,standardName: freezed == standardName ? _self.standardName : standardName // ignore: cast_nullable_to_non_nullable
as String?,standardEquipment: freezed == standardEquipment ? _self.standardEquipment : standardEquipment // ignore: cast_nullable_to_non_nullable
as String?,dataSource: freezed == dataSource ? _self.dataSource : dataSource // ignore: cast_nullable_to_non_nullable
as String?,fallbackReason: freezed == fallbackReason ? _self.fallbackReason : fallbackReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
