// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pattern_detection_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatternDetectionResult {

/// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
 List<String> get pattern;/// Number of times the pattern repeats in workout history
/// Must be >= 2 for valid pattern
 int get repetitions;/// Confidence score (0.0 - 1.0)
/// Based on: repetitions, coverage, pattern length
/// Typical range: 0.60-0.90
 double get confidence;/// Position of last completed workout in pattern (0-indexed)
/// Used to predict next workout
/// Example: lastPosition=1 means user just did pattern[1]
 int get lastPosition;
/// Create a copy of PatternDetectionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternDetectionResultCopyWith<PatternDetectionResult> get copyWith => _$PatternDetectionResultCopyWithImpl<PatternDetectionResult>(this as PatternDetectionResult, _$identity);

  /// Serializes this PatternDetectionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatternDetectionResult&&const DeepCollectionEquality().equals(other.pattern, pattern)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.lastPosition, lastPosition) || other.lastPosition == lastPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pattern),repetitions,confidence,lastPosition);

@override
String toString() {
  return 'PatternDetectionResult(pattern: $pattern, repetitions: $repetitions, confidence: $confidence, lastPosition: $lastPosition)';
}


}

/// @nodoc
abstract mixin class $PatternDetectionResultCopyWith<$Res>  {
  factory $PatternDetectionResultCopyWith(PatternDetectionResult value, $Res Function(PatternDetectionResult) _then) = _$PatternDetectionResultCopyWithImpl;
@useResult
$Res call({
 List<String> pattern, int repetitions, double confidence, int lastPosition
});




}
/// @nodoc
class _$PatternDetectionResultCopyWithImpl<$Res>
    implements $PatternDetectionResultCopyWith<$Res> {
  _$PatternDetectionResultCopyWithImpl(this._self, this._then);

  final PatternDetectionResult _self;
  final $Res Function(PatternDetectionResult) _then;

/// Create a copy of PatternDetectionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pattern = null,Object? repetitions = null,Object? confidence = null,Object? lastPosition = null,}) {
  return _then(_self.copyWith(
pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as List<String>,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,lastPosition: null == lastPosition ? _self.lastPosition : lastPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PatternDetectionResult].
extension PatternDetectionResultPatterns on PatternDetectionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatternDetectionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatternDetectionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatternDetectionResult value)  $default,){
final _that = this;
switch (_that) {
case _PatternDetectionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatternDetectionResult value)?  $default,){
final _that = this;
switch (_that) {
case _PatternDetectionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> pattern,  int repetitions,  double confidence,  int lastPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatternDetectionResult() when $default != null:
return $default(_that.pattern,_that.repetitions,_that.confidence,_that.lastPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> pattern,  int repetitions,  double confidence,  int lastPosition)  $default,) {final _that = this;
switch (_that) {
case _PatternDetectionResult():
return $default(_that.pattern,_that.repetitions,_that.confidence,_that.lastPosition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> pattern,  int repetitions,  double confidence,  int lastPosition)?  $default,) {final _that = this;
switch (_that) {
case _PatternDetectionResult() when $default != null:
return $default(_that.pattern,_that.repetitions,_that.confidence,_that.lastPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatternDetectionResult extends PatternDetectionResult {
  const _PatternDetectionResult({required final  List<String> pattern, required this.repetitions, required this.confidence, required this.lastPosition}): _pattern = pattern,super._();
  factory _PatternDetectionResult.fromJson(Map<String, dynamic> json) => _$PatternDetectionResultFromJson(json);

/// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
 final  List<String> _pattern;
/// The detected pattern sequence (e.g., ["Franco", "Ciccio", "Paolo"])
@override List<String> get pattern {
  if (_pattern is EqualUnmodifiableListView) return _pattern;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pattern);
}

/// Number of times the pattern repeats in workout history
/// Must be >= 2 for valid pattern
@override final  int repetitions;
/// Confidence score (0.0 - 1.0)
/// Based on: repetitions, coverage, pattern length
/// Typical range: 0.60-0.90
@override final  double confidence;
/// Position of last completed workout in pattern (0-indexed)
/// Used to predict next workout
/// Example: lastPosition=1 means user just did pattern[1]
@override final  int lastPosition;

/// Create a copy of PatternDetectionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternDetectionResultCopyWith<_PatternDetectionResult> get copyWith => __$PatternDetectionResultCopyWithImpl<_PatternDetectionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatternDetectionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatternDetectionResult&&const DeepCollectionEquality().equals(other._pattern, _pattern)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.lastPosition, lastPosition) || other.lastPosition == lastPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pattern),repetitions,confidence,lastPosition);

@override
String toString() {
  return 'PatternDetectionResult(pattern: $pattern, repetitions: $repetitions, confidence: $confidence, lastPosition: $lastPosition)';
}


}

/// @nodoc
abstract mixin class _$PatternDetectionResultCopyWith<$Res> implements $PatternDetectionResultCopyWith<$Res> {
  factory _$PatternDetectionResultCopyWith(_PatternDetectionResult value, $Res Function(_PatternDetectionResult) _then) = __$PatternDetectionResultCopyWithImpl;
@override @useResult
$Res call({
 List<String> pattern, int repetitions, double confidence, int lastPosition
});




}
/// @nodoc
class __$PatternDetectionResultCopyWithImpl<$Res>
    implements _$PatternDetectionResultCopyWith<$Res> {
  __$PatternDetectionResultCopyWithImpl(this._self, this._then);

  final _PatternDetectionResult _self;
  final $Res Function(_PatternDetectionResult) _then;

/// Create a copy of PatternDetectionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = null,Object? repetitions = null,Object? confidence = null,Object? lastPosition = null,}) {
  return _then(_PatternDetectionResult(
pattern: null == pattern ? _self._pattern : pattern // ignore: cast_nullable_to_non_nullable
as List<String>,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,lastPosition: null == lastPosition ? _self.lastPosition : lastPosition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
