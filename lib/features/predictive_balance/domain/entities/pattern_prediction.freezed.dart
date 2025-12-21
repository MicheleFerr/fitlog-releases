// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pattern_prediction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatternPrediction {

/// The workout fingerprint that is missing
 WorkoutFingerprint get missing;/// Muscles that would be covered by completing this workout
 List<String> get musclesCovered;/// Template ID if there's a matching template to suggest
 String? get suggestedTemplateId;/// Template name for display
 String? get suggestedTemplateName;/// How many workouts are missing (could be multiple)
 int get missingCount;/// Pattern confidence this prediction is based on
 double get patternConfidence;
/// Create a copy of PatternPrediction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternPredictionCopyWith<PatternPrediction> get copyWith => _$PatternPredictionCopyWithImpl<PatternPrediction>(this as PatternPrediction, _$identity);

  /// Serializes this PatternPrediction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatternPrediction&&(identical(other.missing, missing) || other.missing == missing)&&const DeepCollectionEquality().equals(other.musclesCovered, musclesCovered)&&(identical(other.suggestedTemplateId, suggestedTemplateId) || other.suggestedTemplateId == suggestedTemplateId)&&(identical(other.suggestedTemplateName, suggestedTemplateName) || other.suggestedTemplateName == suggestedTemplateName)&&(identical(other.missingCount, missingCount) || other.missingCount == missingCount)&&(identical(other.patternConfidence, patternConfidence) || other.patternConfidence == patternConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,missing,const DeepCollectionEquality().hash(musclesCovered),suggestedTemplateId,suggestedTemplateName,missingCount,patternConfidence);

@override
String toString() {
  return 'PatternPrediction(missing: $missing, musclesCovered: $musclesCovered, suggestedTemplateId: $suggestedTemplateId, suggestedTemplateName: $suggestedTemplateName, missingCount: $missingCount, patternConfidence: $patternConfidence)';
}


}

/// @nodoc
abstract mixin class $PatternPredictionCopyWith<$Res>  {
  factory $PatternPredictionCopyWith(PatternPrediction value, $Res Function(PatternPrediction) _then) = _$PatternPredictionCopyWithImpl;
@useResult
$Res call({
 WorkoutFingerprint missing, List<String> musclesCovered, String? suggestedTemplateId, String? suggestedTemplateName, int missingCount, double patternConfidence
});


$WorkoutFingerprintCopyWith<$Res> get missing;

}
/// @nodoc
class _$PatternPredictionCopyWithImpl<$Res>
    implements $PatternPredictionCopyWith<$Res> {
  _$PatternPredictionCopyWithImpl(this._self, this._then);

  final PatternPrediction _self;
  final $Res Function(PatternPrediction) _then;

/// Create a copy of PatternPrediction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? missing = null,Object? musclesCovered = null,Object? suggestedTemplateId = freezed,Object? suggestedTemplateName = freezed,Object? missingCount = null,Object? patternConfidence = null,}) {
  return _then(_self.copyWith(
missing: null == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as WorkoutFingerprint,musclesCovered: null == musclesCovered ? _self.musclesCovered : musclesCovered // ignore: cast_nullable_to_non_nullable
as List<String>,suggestedTemplateId: freezed == suggestedTemplateId ? _self.suggestedTemplateId : suggestedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,suggestedTemplateName: freezed == suggestedTemplateName ? _self.suggestedTemplateName : suggestedTemplateName // ignore: cast_nullable_to_non_nullable
as String?,missingCount: null == missingCount ? _self.missingCount : missingCount // ignore: cast_nullable_to_non_nullable
as int,patternConfidence: null == patternConfidence ? _self.patternConfidence : patternConfidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of PatternPrediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutFingerprintCopyWith<$Res> get missing {
  
  return $WorkoutFingerprintCopyWith<$Res>(_self.missing, (value) {
    return _then(_self.copyWith(missing: value));
  });
}
}


/// Adds pattern-matching-related methods to [PatternPrediction].
extension PatternPredictionPatterns on PatternPrediction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatternPrediction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatternPrediction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatternPrediction value)  $default,){
final _that = this;
switch (_that) {
case _PatternPrediction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatternPrediction value)?  $default,){
final _that = this;
switch (_that) {
case _PatternPrediction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkoutFingerprint missing,  List<String> musclesCovered,  String? suggestedTemplateId,  String? suggestedTemplateName,  int missingCount,  double patternConfidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatternPrediction() when $default != null:
return $default(_that.missing,_that.musclesCovered,_that.suggestedTemplateId,_that.suggestedTemplateName,_that.missingCount,_that.patternConfidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkoutFingerprint missing,  List<String> musclesCovered,  String? suggestedTemplateId,  String? suggestedTemplateName,  int missingCount,  double patternConfidence)  $default,) {final _that = this;
switch (_that) {
case _PatternPrediction():
return $default(_that.missing,_that.musclesCovered,_that.suggestedTemplateId,_that.suggestedTemplateName,_that.missingCount,_that.patternConfidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkoutFingerprint missing,  List<String> musclesCovered,  String? suggestedTemplateId,  String? suggestedTemplateName,  int missingCount,  double patternConfidence)?  $default,) {final _that = this;
switch (_that) {
case _PatternPrediction() when $default != null:
return $default(_that.missing,_that.musclesCovered,_that.suggestedTemplateId,_that.suggestedTemplateName,_that.missingCount,_that.patternConfidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatternPrediction extends PatternPrediction {
  const _PatternPrediction({required this.missing, required final  List<String> musclesCovered, this.suggestedTemplateId, this.suggestedTemplateName, this.missingCount = 1, required this.patternConfidence}): _musclesCovered = musclesCovered,super._();
  factory _PatternPrediction.fromJson(Map<String, dynamic> json) => _$PatternPredictionFromJson(json);

/// The workout fingerprint that is missing
@override final  WorkoutFingerprint missing;
/// Muscles that would be covered by completing this workout
 final  List<String> _musclesCovered;
/// Muscles that would be covered by completing this workout
@override List<String> get musclesCovered {
  if (_musclesCovered is EqualUnmodifiableListView) return _musclesCovered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_musclesCovered);
}

/// Template ID if there's a matching template to suggest
@override final  String? suggestedTemplateId;
/// Template name for display
@override final  String? suggestedTemplateName;
/// How many workouts are missing (could be multiple)
@override@JsonKey() final  int missingCount;
/// Pattern confidence this prediction is based on
@override final  double patternConfidence;

/// Create a copy of PatternPrediction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternPredictionCopyWith<_PatternPrediction> get copyWith => __$PatternPredictionCopyWithImpl<_PatternPrediction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatternPredictionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatternPrediction&&(identical(other.missing, missing) || other.missing == missing)&&const DeepCollectionEquality().equals(other._musclesCovered, _musclesCovered)&&(identical(other.suggestedTemplateId, suggestedTemplateId) || other.suggestedTemplateId == suggestedTemplateId)&&(identical(other.suggestedTemplateName, suggestedTemplateName) || other.suggestedTemplateName == suggestedTemplateName)&&(identical(other.missingCount, missingCount) || other.missingCount == missingCount)&&(identical(other.patternConfidence, patternConfidence) || other.patternConfidence == patternConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,missing,const DeepCollectionEquality().hash(_musclesCovered),suggestedTemplateId,suggestedTemplateName,missingCount,patternConfidence);

@override
String toString() {
  return 'PatternPrediction(missing: $missing, musclesCovered: $musclesCovered, suggestedTemplateId: $suggestedTemplateId, suggestedTemplateName: $suggestedTemplateName, missingCount: $missingCount, patternConfidence: $patternConfidence)';
}


}

/// @nodoc
abstract mixin class _$PatternPredictionCopyWith<$Res> implements $PatternPredictionCopyWith<$Res> {
  factory _$PatternPredictionCopyWith(_PatternPrediction value, $Res Function(_PatternPrediction) _then) = __$PatternPredictionCopyWithImpl;
@override @useResult
$Res call({
 WorkoutFingerprint missing, List<String> musclesCovered, String? suggestedTemplateId, String? suggestedTemplateName, int missingCount, double patternConfidence
});


@override $WorkoutFingerprintCopyWith<$Res> get missing;

}
/// @nodoc
class __$PatternPredictionCopyWithImpl<$Res>
    implements _$PatternPredictionCopyWith<$Res> {
  __$PatternPredictionCopyWithImpl(this._self, this._then);

  final _PatternPrediction _self;
  final $Res Function(_PatternPrediction) _then;

/// Create a copy of PatternPrediction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? missing = null,Object? musclesCovered = null,Object? suggestedTemplateId = freezed,Object? suggestedTemplateName = freezed,Object? missingCount = null,Object? patternConfidence = null,}) {
  return _then(_PatternPrediction(
missing: null == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as WorkoutFingerprint,musclesCovered: null == musclesCovered ? _self._musclesCovered : musclesCovered // ignore: cast_nullable_to_non_nullable
as List<String>,suggestedTemplateId: freezed == suggestedTemplateId ? _self.suggestedTemplateId : suggestedTemplateId // ignore: cast_nullable_to_non_nullable
as String?,suggestedTemplateName: freezed == suggestedTemplateName ? _self.suggestedTemplateName : suggestedTemplateName // ignore: cast_nullable_to_non_nullable
as String?,missingCount: null == missingCount ? _self.missingCount : missingCount // ignore: cast_nullable_to_non_nullable
as int,patternConfidence: null == patternConfidence ? _self.patternConfidence : patternConfidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of PatternPrediction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutFingerprintCopyWith<$Res> get missing {
  
  return $WorkoutFingerprintCopyWith<$Res>(_self.missing, (value) {
    return _then(_self.copyWith(missing: value));
  });
}
}

// dart format on
