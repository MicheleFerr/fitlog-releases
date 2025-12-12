// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stress_index_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StressIndexResult {

/// Primary stress score (0-100, logarithmic)
/// Based on RPE when available
 double get primaryScore;/// Fallback score (weight-only calculation)
/// Used when RPE data is incomplete
 double get fallbackScore;/// Confidence level (0.0 - 1.0)
/// Percentage of sets with RPE data
 double get confidence;/// Breakdown by muscle group
 Map<String, MuscleStressData> get muscleBreakdown;/// Total sets analyzed
 int get totalSets;/// Sets with RPE data
 int get setsWithRpe;/// Workout ID this belongs to
 String get workoutId;/// Calculation timestamp
 DateTime get calculatedAt;/// Raw score before logarithmic conversion
 double get rawScore;
/// Create a copy of StressIndexResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StressIndexResultCopyWith<StressIndexResult> get copyWith => _$StressIndexResultCopyWithImpl<StressIndexResult>(this as StressIndexResult, _$identity);

  /// Serializes this StressIndexResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StressIndexResult&&(identical(other.primaryScore, primaryScore) || other.primaryScore == primaryScore)&&(identical(other.fallbackScore, fallbackScore) || other.fallbackScore == fallbackScore)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.muscleBreakdown, muscleBreakdown)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.setsWithRpe, setsWithRpe) || other.setsWithRpe == setsWithRpe)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.rawScore, rawScore) || other.rawScore == rawScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryScore,fallbackScore,confidence,const DeepCollectionEquality().hash(muscleBreakdown),totalSets,setsWithRpe,workoutId,calculatedAt,rawScore);

@override
String toString() {
  return 'StressIndexResult(primaryScore: $primaryScore, fallbackScore: $fallbackScore, confidence: $confidence, muscleBreakdown: $muscleBreakdown, totalSets: $totalSets, setsWithRpe: $setsWithRpe, workoutId: $workoutId, calculatedAt: $calculatedAt, rawScore: $rawScore)';
}


}

/// @nodoc
abstract mixin class $StressIndexResultCopyWith<$Res>  {
  factory $StressIndexResultCopyWith(StressIndexResult value, $Res Function(StressIndexResult) _then) = _$StressIndexResultCopyWithImpl;
@useResult
$Res call({
 double primaryScore, double fallbackScore, double confidence, Map<String, MuscleStressData> muscleBreakdown, int totalSets, int setsWithRpe, String workoutId, DateTime calculatedAt, double rawScore
});




}
/// @nodoc
class _$StressIndexResultCopyWithImpl<$Res>
    implements $StressIndexResultCopyWith<$Res> {
  _$StressIndexResultCopyWithImpl(this._self, this._then);

  final StressIndexResult _self;
  final $Res Function(StressIndexResult) _then;

/// Create a copy of StressIndexResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryScore = null,Object? fallbackScore = null,Object? confidence = null,Object? muscleBreakdown = null,Object? totalSets = null,Object? setsWithRpe = null,Object? workoutId = null,Object? calculatedAt = null,Object? rawScore = null,}) {
  return _then(_self.copyWith(
primaryScore: null == primaryScore ? _self.primaryScore : primaryScore // ignore: cast_nullable_to_non_nullable
as double,fallbackScore: null == fallbackScore ? _self.fallbackScore : fallbackScore // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,muscleBreakdown: null == muscleBreakdown ? _self.muscleBreakdown : muscleBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, MuscleStressData>,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,setsWithRpe: null == setsWithRpe ? _self.setsWithRpe : setsWithRpe // ignore: cast_nullable_to_non_nullable
as int,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,calculatedAt: null == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,rawScore: null == rawScore ? _self.rawScore : rawScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [StressIndexResult].
extension StressIndexResultPatterns on StressIndexResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StressIndexResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StressIndexResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StressIndexResult value)  $default,){
final _that = this;
switch (_that) {
case _StressIndexResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StressIndexResult value)?  $default,){
final _that = this;
switch (_that) {
case _StressIndexResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double primaryScore,  double fallbackScore,  double confidence,  Map<String, MuscleStressData> muscleBreakdown,  int totalSets,  int setsWithRpe,  String workoutId,  DateTime calculatedAt,  double rawScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StressIndexResult() when $default != null:
return $default(_that.primaryScore,_that.fallbackScore,_that.confidence,_that.muscleBreakdown,_that.totalSets,_that.setsWithRpe,_that.workoutId,_that.calculatedAt,_that.rawScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double primaryScore,  double fallbackScore,  double confidence,  Map<String, MuscleStressData> muscleBreakdown,  int totalSets,  int setsWithRpe,  String workoutId,  DateTime calculatedAt,  double rawScore)  $default,) {final _that = this;
switch (_that) {
case _StressIndexResult():
return $default(_that.primaryScore,_that.fallbackScore,_that.confidence,_that.muscleBreakdown,_that.totalSets,_that.setsWithRpe,_that.workoutId,_that.calculatedAt,_that.rawScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double primaryScore,  double fallbackScore,  double confidence,  Map<String, MuscleStressData> muscleBreakdown,  int totalSets,  int setsWithRpe,  String workoutId,  DateTime calculatedAt,  double rawScore)?  $default,) {final _that = this;
switch (_that) {
case _StressIndexResult() when $default != null:
return $default(_that.primaryScore,_that.fallbackScore,_that.confidence,_that.muscleBreakdown,_that.totalSets,_that.setsWithRpe,_that.workoutId,_that.calculatedAt,_that.rawScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StressIndexResult extends StressIndexResult {
  const _StressIndexResult({required this.primaryScore, required this.fallbackScore, required this.confidence, required final  Map<String, MuscleStressData> muscleBreakdown, required this.totalSets, required this.setsWithRpe, required this.workoutId, required this.calculatedAt, required this.rawScore}): _muscleBreakdown = muscleBreakdown,super._();
  factory _StressIndexResult.fromJson(Map<String, dynamic> json) => _$StressIndexResultFromJson(json);

/// Primary stress score (0-100, logarithmic)
/// Based on RPE when available
@override final  double primaryScore;
/// Fallback score (weight-only calculation)
/// Used when RPE data is incomplete
@override final  double fallbackScore;
/// Confidence level (0.0 - 1.0)
/// Percentage of sets with RPE data
@override final  double confidence;
/// Breakdown by muscle group
 final  Map<String, MuscleStressData> _muscleBreakdown;
/// Breakdown by muscle group
@override Map<String, MuscleStressData> get muscleBreakdown {
  if (_muscleBreakdown is EqualUnmodifiableMapView) return _muscleBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_muscleBreakdown);
}

/// Total sets analyzed
@override final  int totalSets;
/// Sets with RPE data
@override final  int setsWithRpe;
/// Workout ID this belongs to
@override final  String workoutId;
/// Calculation timestamp
@override final  DateTime calculatedAt;
/// Raw score before logarithmic conversion
@override final  double rawScore;

/// Create a copy of StressIndexResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StressIndexResultCopyWith<_StressIndexResult> get copyWith => __$StressIndexResultCopyWithImpl<_StressIndexResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StressIndexResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StressIndexResult&&(identical(other.primaryScore, primaryScore) || other.primaryScore == primaryScore)&&(identical(other.fallbackScore, fallbackScore) || other.fallbackScore == fallbackScore)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._muscleBreakdown, _muscleBreakdown)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.setsWithRpe, setsWithRpe) || other.setsWithRpe == setsWithRpe)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.rawScore, rawScore) || other.rawScore == rawScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primaryScore,fallbackScore,confidence,const DeepCollectionEquality().hash(_muscleBreakdown),totalSets,setsWithRpe,workoutId,calculatedAt,rawScore);

@override
String toString() {
  return 'StressIndexResult(primaryScore: $primaryScore, fallbackScore: $fallbackScore, confidence: $confidence, muscleBreakdown: $muscleBreakdown, totalSets: $totalSets, setsWithRpe: $setsWithRpe, workoutId: $workoutId, calculatedAt: $calculatedAt, rawScore: $rawScore)';
}


}

/// @nodoc
abstract mixin class _$StressIndexResultCopyWith<$Res> implements $StressIndexResultCopyWith<$Res> {
  factory _$StressIndexResultCopyWith(_StressIndexResult value, $Res Function(_StressIndexResult) _then) = __$StressIndexResultCopyWithImpl;
@override @useResult
$Res call({
 double primaryScore, double fallbackScore, double confidence, Map<String, MuscleStressData> muscleBreakdown, int totalSets, int setsWithRpe, String workoutId, DateTime calculatedAt, double rawScore
});




}
/// @nodoc
class __$StressIndexResultCopyWithImpl<$Res>
    implements _$StressIndexResultCopyWith<$Res> {
  __$StressIndexResultCopyWithImpl(this._self, this._then);

  final _StressIndexResult _self;
  final $Res Function(_StressIndexResult) _then;

/// Create a copy of StressIndexResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryScore = null,Object? fallbackScore = null,Object? confidence = null,Object? muscleBreakdown = null,Object? totalSets = null,Object? setsWithRpe = null,Object? workoutId = null,Object? calculatedAt = null,Object? rawScore = null,}) {
  return _then(_StressIndexResult(
primaryScore: null == primaryScore ? _self.primaryScore : primaryScore // ignore: cast_nullable_to_non_nullable
as double,fallbackScore: null == fallbackScore ? _self.fallbackScore : fallbackScore // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,muscleBreakdown: null == muscleBreakdown ? _self._muscleBreakdown : muscleBreakdown // ignore: cast_nullable_to_non_nullable
as Map<String, MuscleStressData>,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,setsWithRpe: null == setsWithRpe ? _self.setsWithRpe : setsWithRpe // ignore: cast_nullable_to_non_nullable
as int,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,calculatedAt: null == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,rawScore: null == rawScore ? _self.rawScore : rawScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
