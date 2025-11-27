// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseTemplate {

 String get exerciseName; double get defaultWeight; int get defaultReps; int get defaultSets; String? get notes;
/// Create a copy of ExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseTemplateCopyWith<ExerciseTemplate> get copyWith => _$ExerciseTemplateCopyWithImpl<ExerciseTemplate>(this as ExerciseTemplate, _$identity);

  /// Serializes this ExerciseTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseTemplate&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.defaultWeight, defaultWeight) || other.defaultWeight == defaultWeight)&&(identical(other.defaultReps, defaultReps) || other.defaultReps == defaultReps)&&(identical(other.defaultSets, defaultSets) || other.defaultSets == defaultSets)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,defaultWeight,defaultReps,defaultSets,notes);

@override
String toString() {
  return 'ExerciseTemplate(exerciseName: $exerciseName, defaultWeight: $defaultWeight, defaultReps: $defaultReps, defaultSets: $defaultSets, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $ExerciseTemplateCopyWith<$Res>  {
  factory $ExerciseTemplateCopyWith(ExerciseTemplate value, $Res Function(ExerciseTemplate) _then) = _$ExerciseTemplateCopyWithImpl;
@useResult
$Res call({
 String exerciseName, double defaultWeight, int defaultReps, int defaultSets, String? notes
});




}
/// @nodoc
class _$ExerciseTemplateCopyWithImpl<$Res>
    implements $ExerciseTemplateCopyWith<$Res> {
  _$ExerciseTemplateCopyWithImpl(this._self, this._then);

  final ExerciseTemplate _self;
  final $Res Function(ExerciseTemplate) _then;

/// Create a copy of ExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? defaultWeight = null,Object? defaultReps = null,Object? defaultSets = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,defaultWeight: null == defaultWeight ? _self.defaultWeight : defaultWeight // ignore: cast_nullable_to_non_nullable
as double,defaultReps: null == defaultReps ? _self.defaultReps : defaultReps // ignore: cast_nullable_to_non_nullable
as int,defaultSets: null == defaultSets ? _self.defaultSets : defaultSets // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseTemplate].
extension ExerciseTemplatePatterns on ExerciseTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseTemplate value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  double defaultWeight,  int defaultReps,  int defaultSets,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseTemplate() when $default != null:
return $default(_that.exerciseName,_that.defaultWeight,_that.defaultReps,_that.defaultSets,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  double defaultWeight,  int defaultReps,  int defaultSets,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ExerciseTemplate():
return $default(_that.exerciseName,_that.defaultWeight,_that.defaultReps,_that.defaultSets,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  double defaultWeight,  int defaultReps,  int defaultSets,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseTemplate() when $default != null:
return $default(_that.exerciseName,_that.defaultWeight,_that.defaultReps,_that.defaultSets,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseTemplate extends ExerciseTemplate {
  const _ExerciseTemplate({required this.exerciseName, required this.defaultWeight, required this.defaultReps, required this.defaultSets, this.notes}): super._();
  factory _ExerciseTemplate.fromJson(Map<String, dynamic> json) => _$ExerciseTemplateFromJson(json);

@override final  String exerciseName;
@override final  double defaultWeight;
@override final  int defaultReps;
@override final  int defaultSets;
@override final  String? notes;

/// Create a copy of ExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseTemplateCopyWith<_ExerciseTemplate> get copyWith => __$ExerciseTemplateCopyWithImpl<_ExerciseTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseTemplate&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.defaultWeight, defaultWeight) || other.defaultWeight == defaultWeight)&&(identical(other.defaultReps, defaultReps) || other.defaultReps == defaultReps)&&(identical(other.defaultSets, defaultSets) || other.defaultSets == defaultSets)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,defaultWeight,defaultReps,defaultSets,notes);

@override
String toString() {
  return 'ExerciseTemplate(exerciseName: $exerciseName, defaultWeight: $defaultWeight, defaultReps: $defaultReps, defaultSets: $defaultSets, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ExerciseTemplateCopyWith<$Res> implements $ExerciseTemplateCopyWith<$Res> {
  factory _$ExerciseTemplateCopyWith(_ExerciseTemplate value, $Res Function(_ExerciseTemplate) _then) = __$ExerciseTemplateCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, double defaultWeight, int defaultReps, int defaultSets, String? notes
});




}
/// @nodoc
class __$ExerciseTemplateCopyWithImpl<$Res>
    implements _$ExerciseTemplateCopyWith<$Res> {
  __$ExerciseTemplateCopyWithImpl(this._self, this._then);

  final _ExerciseTemplate _self;
  final $Res Function(_ExerciseTemplate) _then;

/// Create a copy of ExerciseTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? defaultWeight = null,Object? defaultReps = null,Object? defaultSets = null,Object? notes = freezed,}) {
  return _then(_ExerciseTemplate(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,defaultWeight: null == defaultWeight ? _self.defaultWeight : defaultWeight // ignore: cast_nullable_to_non_nullable
as double,defaultReps: null == defaultReps ? _self.defaultReps : defaultReps // ignore: cast_nullable_to_non_nullable
as int,defaultSets: null == defaultSets ? _self.defaultSets : defaultSets // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
