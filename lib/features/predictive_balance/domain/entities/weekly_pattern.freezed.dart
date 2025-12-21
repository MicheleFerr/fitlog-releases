// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklyPattern {

/// Fingerprints of workouts in the cycle
/// Order represents typical sequence (e.g., Push → Pull → Legs)
 List<WorkoutFingerprint> get cycle;/// Confidence score (0.0 - 1.0)
/// Based on how consistently the pattern repeats
 double get confidence;/// Number of weeks analyzed to detect pattern
 int get weeksAnalyzed;/// Number of weeks that matched the pattern
 int get weeksMatched;/// When this pattern was last analyzed
 DateTime get analyzedAt;/// Average workouts per week in the pattern
 int get avgWorkoutsPerWeek;
/// Create a copy of WeeklyPattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyPatternCopyWith<WeeklyPattern> get copyWith => _$WeeklyPatternCopyWithImpl<WeeklyPattern>(this as WeeklyPattern, _$identity);

  /// Serializes this WeeklyPattern to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyPattern&&const DeepCollectionEquality().equals(other.cycle, cycle)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.weeksAnalyzed, weeksAnalyzed) || other.weeksAnalyzed == weeksAnalyzed)&&(identical(other.weeksMatched, weeksMatched) || other.weeksMatched == weeksMatched)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) || other.avgWorkoutsPerWeek == avgWorkoutsPerWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cycle),confidence,weeksAnalyzed,weeksMatched,analyzedAt,avgWorkoutsPerWeek);

@override
String toString() {
  return 'WeeklyPattern(cycle: $cycle, confidence: $confidence, weeksAnalyzed: $weeksAnalyzed, weeksMatched: $weeksMatched, analyzedAt: $analyzedAt, avgWorkoutsPerWeek: $avgWorkoutsPerWeek)';
}


}

/// @nodoc
abstract mixin class $WeeklyPatternCopyWith<$Res>  {
  factory $WeeklyPatternCopyWith(WeeklyPattern value, $Res Function(WeeklyPattern) _then) = _$WeeklyPatternCopyWithImpl;
@useResult
$Res call({
 List<WorkoutFingerprint> cycle, double confidence, int weeksAnalyzed, int weeksMatched, DateTime analyzedAt, int avgWorkoutsPerWeek
});




}
/// @nodoc
class _$WeeklyPatternCopyWithImpl<$Res>
    implements $WeeklyPatternCopyWith<$Res> {
  _$WeeklyPatternCopyWithImpl(this._self, this._then);

  final WeeklyPattern _self;
  final $Res Function(WeeklyPattern) _then;

/// Create a copy of WeeklyPattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cycle = null,Object? confidence = null,Object? weeksAnalyzed = null,Object? weeksMatched = null,Object? analyzedAt = null,Object? avgWorkoutsPerWeek = null,}) {
  return _then(_self.copyWith(
cycle: null == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as List<WorkoutFingerprint>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,weeksAnalyzed: null == weeksAnalyzed ? _self.weeksAnalyzed : weeksAnalyzed // ignore: cast_nullable_to_non_nullable
as int,weeksMatched: null == weeksMatched ? _self.weeksMatched : weeksMatched // ignore: cast_nullable_to_non_nullable
as int,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,avgWorkoutsPerWeek: null == avgWorkoutsPerWeek ? _self.avgWorkoutsPerWeek : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyPattern].
extension WeeklyPatternPatterns on WeeklyPattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyPattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyPattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyPattern value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyPattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyPattern value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyPattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WorkoutFingerprint> cycle,  double confidence,  int weeksAnalyzed,  int weeksMatched,  DateTime analyzedAt,  int avgWorkoutsPerWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyPattern() when $default != null:
return $default(_that.cycle,_that.confidence,_that.weeksAnalyzed,_that.weeksMatched,_that.analyzedAt,_that.avgWorkoutsPerWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WorkoutFingerprint> cycle,  double confidence,  int weeksAnalyzed,  int weeksMatched,  DateTime analyzedAt,  int avgWorkoutsPerWeek)  $default,) {final _that = this;
switch (_that) {
case _WeeklyPattern():
return $default(_that.cycle,_that.confidence,_that.weeksAnalyzed,_that.weeksMatched,_that.analyzedAt,_that.avgWorkoutsPerWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WorkoutFingerprint> cycle,  double confidence,  int weeksAnalyzed,  int weeksMatched,  DateTime analyzedAt,  int avgWorkoutsPerWeek)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyPattern() when $default != null:
return $default(_that.cycle,_that.confidence,_that.weeksAnalyzed,_that.weeksMatched,_that.analyzedAt,_that.avgWorkoutsPerWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyPattern extends WeeklyPattern {
  const _WeeklyPattern({required final  List<WorkoutFingerprint> cycle, required this.confidence, required this.weeksAnalyzed, required this.weeksMatched, required this.analyzedAt, this.avgWorkoutsPerWeek = 0}): _cycle = cycle,super._();
  factory _WeeklyPattern.fromJson(Map<String, dynamic> json) => _$WeeklyPatternFromJson(json);

/// Fingerprints of workouts in the cycle
/// Order represents typical sequence (e.g., Push → Pull → Legs)
 final  List<WorkoutFingerprint> _cycle;
/// Fingerprints of workouts in the cycle
/// Order represents typical sequence (e.g., Push → Pull → Legs)
@override List<WorkoutFingerprint> get cycle {
  if (_cycle is EqualUnmodifiableListView) return _cycle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cycle);
}

/// Confidence score (0.0 - 1.0)
/// Based on how consistently the pattern repeats
@override final  double confidence;
/// Number of weeks analyzed to detect pattern
@override final  int weeksAnalyzed;
/// Number of weeks that matched the pattern
@override final  int weeksMatched;
/// When this pattern was last analyzed
@override final  DateTime analyzedAt;
/// Average workouts per week in the pattern
@override@JsonKey() final  int avgWorkoutsPerWeek;

/// Create a copy of WeeklyPattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyPatternCopyWith<_WeeklyPattern> get copyWith => __$WeeklyPatternCopyWithImpl<_WeeklyPattern>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyPatternToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyPattern&&const DeepCollectionEquality().equals(other._cycle, _cycle)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.weeksAnalyzed, weeksAnalyzed) || other.weeksAnalyzed == weeksAnalyzed)&&(identical(other.weeksMatched, weeksMatched) || other.weeksMatched == weeksMatched)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) || other.avgWorkoutsPerWeek == avgWorkoutsPerWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cycle),confidence,weeksAnalyzed,weeksMatched,analyzedAt,avgWorkoutsPerWeek);

@override
String toString() {
  return 'WeeklyPattern(cycle: $cycle, confidence: $confidence, weeksAnalyzed: $weeksAnalyzed, weeksMatched: $weeksMatched, analyzedAt: $analyzedAt, avgWorkoutsPerWeek: $avgWorkoutsPerWeek)';
}


}

/// @nodoc
abstract mixin class _$WeeklyPatternCopyWith<$Res> implements $WeeklyPatternCopyWith<$Res> {
  factory _$WeeklyPatternCopyWith(_WeeklyPattern value, $Res Function(_WeeklyPattern) _then) = __$WeeklyPatternCopyWithImpl;
@override @useResult
$Res call({
 List<WorkoutFingerprint> cycle, double confidence, int weeksAnalyzed, int weeksMatched, DateTime analyzedAt, int avgWorkoutsPerWeek
});




}
/// @nodoc
class __$WeeklyPatternCopyWithImpl<$Res>
    implements _$WeeklyPatternCopyWith<$Res> {
  __$WeeklyPatternCopyWithImpl(this._self, this._then);

  final _WeeklyPattern _self;
  final $Res Function(_WeeklyPattern) _then;

/// Create a copy of WeeklyPattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cycle = null,Object? confidence = null,Object? weeksAnalyzed = null,Object? weeksMatched = null,Object? analyzedAt = null,Object? avgWorkoutsPerWeek = null,}) {
  return _then(_WeeklyPattern(
cycle: null == cycle ? _self._cycle : cycle // ignore: cast_nullable_to_non_nullable
as List<WorkoutFingerprint>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,weeksAnalyzed: null == weeksAnalyzed ? _self.weeksAnalyzed : weeksAnalyzed // ignore: cast_nullable_to_non_nullable
as int,weeksMatched: null == weeksMatched ? _self.weeksMatched : weeksMatched // ignore: cast_nullable_to_non_nullable
as int,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,avgWorkoutsPerWeek: null == avgWorkoutsPerWeek ? _self.avgWorkoutsPerWeek : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
