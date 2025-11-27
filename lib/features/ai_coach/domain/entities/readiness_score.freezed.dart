// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'readiness_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadinessScore {

/// Readiness score (0-100)
///
/// **Interpretation**:
/// - 90-100: Optimal (🔥)
/// - 75-89: Good (💪)
/// - 60-74: Moderate (😐)
/// - 40-59: Low (😴)
/// - 0-39: Very Low (🚫)
 int get score;/// Category derived from score
 ReadinessCategory get category;/// Human-readable recommendation
///
/// **Examples**:
/// - "Great! Ready for a challenging workout."
/// - "Moderate energy. Consider a light workout."
/// - "Low readiness. Active recovery or rest recommended."
 String get recommendation;/// Optional: Factors contributing to score
 ReadinessFactors? get factors;/// Timestamp when score was calculated
 DateTime? get calculatedAt;
/// Create a copy of ReadinessScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadinessScoreCopyWith<ReadinessScore> get copyWith => _$ReadinessScoreCopyWithImpl<ReadinessScore>(this as ReadinessScore, _$identity);

  /// Serializes this ReadinessScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadinessScore&&(identical(other.score, score) || other.score == score)&&(identical(other.category, category) || other.category == category)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.factors, factors) || other.factors == factors)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,category,recommendation,factors,calculatedAt);

@override
String toString() {
  return 'ReadinessScore(score: $score, category: $category, recommendation: $recommendation, factors: $factors, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class $ReadinessScoreCopyWith<$Res>  {
  factory $ReadinessScoreCopyWith(ReadinessScore value, $Res Function(ReadinessScore) _then) = _$ReadinessScoreCopyWithImpl;
@useResult
$Res call({
 int score, ReadinessCategory category, String recommendation, ReadinessFactors? factors, DateTime? calculatedAt
});


$ReadinessFactorsCopyWith<$Res>? get factors;

}
/// @nodoc
class _$ReadinessScoreCopyWithImpl<$Res>
    implements $ReadinessScoreCopyWith<$Res> {
  _$ReadinessScoreCopyWithImpl(this._self, this._then);

  final ReadinessScore _self;
  final $Res Function(ReadinessScore) _then;

/// Create a copy of ReadinessScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? score = null,Object? category = null,Object? recommendation = null,Object? factors = freezed,Object? calculatedAt = freezed,}) {
  return _then(_self.copyWith(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ReadinessCategory,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,factors: freezed == factors ? _self.factors : factors // ignore: cast_nullable_to_non_nullable
as ReadinessFactors?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ReadinessScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadinessFactorsCopyWith<$Res>? get factors {
    if (_self.factors == null) {
    return null;
  }

  return $ReadinessFactorsCopyWith<$Res>(_self.factors!, (value) {
    return _then(_self.copyWith(factors: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReadinessScore].
extension ReadinessScorePatterns on ReadinessScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadinessScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadinessScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadinessScore value)  $default,){
final _that = this;
switch (_that) {
case _ReadinessScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadinessScore value)?  $default,){
final _that = this;
switch (_that) {
case _ReadinessScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int score,  ReadinessCategory category,  String recommendation,  ReadinessFactors? factors,  DateTime? calculatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadinessScore() when $default != null:
return $default(_that.score,_that.category,_that.recommendation,_that.factors,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int score,  ReadinessCategory category,  String recommendation,  ReadinessFactors? factors,  DateTime? calculatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReadinessScore():
return $default(_that.score,_that.category,_that.recommendation,_that.factors,_that.calculatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int score,  ReadinessCategory category,  String recommendation,  ReadinessFactors? factors,  DateTime? calculatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReadinessScore() when $default != null:
return $default(_that.score,_that.category,_that.recommendation,_that.factors,_that.calculatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadinessScore extends ReadinessScore {
  const _ReadinessScore({required this.score, required this.category, required this.recommendation, this.factors, this.calculatedAt = null}): super._();
  factory _ReadinessScore.fromJson(Map<String, dynamic> json) => _$ReadinessScoreFromJson(json);

/// Readiness score (0-100)
///
/// **Interpretation**:
/// - 90-100: Optimal (🔥)
/// - 75-89: Good (💪)
/// - 60-74: Moderate (😐)
/// - 40-59: Low (😴)
/// - 0-39: Very Low (🚫)
@override final  int score;
/// Category derived from score
@override final  ReadinessCategory category;
/// Human-readable recommendation
///
/// **Examples**:
/// - "Great! Ready for a challenging workout."
/// - "Moderate energy. Consider a light workout."
/// - "Low readiness. Active recovery or rest recommended."
@override final  String recommendation;
/// Optional: Factors contributing to score
@override final  ReadinessFactors? factors;
/// Timestamp when score was calculated
@override@JsonKey() final  DateTime? calculatedAt;

/// Create a copy of ReadinessScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadinessScoreCopyWith<_ReadinessScore> get copyWith => __$ReadinessScoreCopyWithImpl<_ReadinessScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadinessScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadinessScore&&(identical(other.score, score) || other.score == score)&&(identical(other.category, category) || other.category == category)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.factors, factors) || other.factors == factors)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,category,recommendation,factors,calculatedAt);

@override
String toString() {
  return 'ReadinessScore(score: $score, category: $category, recommendation: $recommendation, factors: $factors, calculatedAt: $calculatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReadinessScoreCopyWith<$Res> implements $ReadinessScoreCopyWith<$Res> {
  factory _$ReadinessScoreCopyWith(_ReadinessScore value, $Res Function(_ReadinessScore) _then) = __$ReadinessScoreCopyWithImpl;
@override @useResult
$Res call({
 int score, ReadinessCategory category, String recommendation, ReadinessFactors? factors, DateTime? calculatedAt
});


@override $ReadinessFactorsCopyWith<$Res>? get factors;

}
/// @nodoc
class __$ReadinessScoreCopyWithImpl<$Res>
    implements _$ReadinessScoreCopyWith<$Res> {
  __$ReadinessScoreCopyWithImpl(this._self, this._then);

  final _ReadinessScore _self;
  final $Res Function(_ReadinessScore) _then;

/// Create a copy of ReadinessScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? score = null,Object? category = null,Object? recommendation = null,Object? factors = freezed,Object? calculatedAt = freezed,}) {
  return _then(_ReadinessScore(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ReadinessCategory,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,factors: freezed == factors ? _self.factors : factors // ignore: cast_nullable_to_non_nullable
as ReadinessFactors?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ReadinessScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadinessFactorsCopyWith<$Res>? get factors {
    if (_self.factors == null) {
    return null;
  }

  return $ReadinessFactorsCopyWith<$Res>(_self.factors!, (value) {
    return _then(_self.copyWith(factors: value));
  });
}
}


/// @nodoc
mixin _$ReadinessFactors {

/// Workout frequency score (0-100)
///
/// **Calculation**: Recent training volume vs baseline (40% weight)
 int get workoutFrequencyScore;/// Recovery time score (0-100)
///
/// **Calculation**: Days since last workout (30% weight)
 int get recoveryTimeScore;/// Training consistency score (0-100)
///
/// **Calculation**: Adherence to workout schedule (30% weight)
 int get consistencyScore;/// Optional: Days since last workout
 int? get daysSinceLastWorkout;/// Optional: Workouts in last 7 days
 int? get workoutsLast7Days;/// Optional: Average workouts per week
 double? get avgWorkoutsPerWeek;
/// Create a copy of ReadinessFactors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadinessFactorsCopyWith<ReadinessFactors> get copyWith => _$ReadinessFactorsCopyWithImpl<ReadinessFactors>(this as ReadinessFactors, _$identity);

  /// Serializes this ReadinessFactors to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadinessFactors&&(identical(other.workoutFrequencyScore, workoutFrequencyScore) || other.workoutFrequencyScore == workoutFrequencyScore)&&(identical(other.recoveryTimeScore, recoveryTimeScore) || other.recoveryTimeScore == recoveryTimeScore)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore)&&(identical(other.daysSinceLastWorkout, daysSinceLastWorkout) || other.daysSinceLastWorkout == daysSinceLastWorkout)&&(identical(other.workoutsLast7Days, workoutsLast7Days) || other.workoutsLast7Days == workoutsLast7Days)&&(identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) || other.avgWorkoutsPerWeek == avgWorkoutsPerWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutFrequencyScore,recoveryTimeScore,consistencyScore,daysSinceLastWorkout,workoutsLast7Days,avgWorkoutsPerWeek);

@override
String toString() {
  return 'ReadinessFactors(workoutFrequencyScore: $workoutFrequencyScore, recoveryTimeScore: $recoveryTimeScore, consistencyScore: $consistencyScore, daysSinceLastWorkout: $daysSinceLastWorkout, workoutsLast7Days: $workoutsLast7Days, avgWorkoutsPerWeek: $avgWorkoutsPerWeek)';
}


}

/// @nodoc
abstract mixin class $ReadinessFactorsCopyWith<$Res>  {
  factory $ReadinessFactorsCopyWith(ReadinessFactors value, $Res Function(ReadinessFactors) _then) = _$ReadinessFactorsCopyWithImpl;
@useResult
$Res call({
 int workoutFrequencyScore, int recoveryTimeScore, int consistencyScore, int? daysSinceLastWorkout, int? workoutsLast7Days, double? avgWorkoutsPerWeek
});




}
/// @nodoc
class _$ReadinessFactorsCopyWithImpl<$Res>
    implements $ReadinessFactorsCopyWith<$Res> {
  _$ReadinessFactorsCopyWithImpl(this._self, this._then);

  final ReadinessFactors _self;
  final $Res Function(ReadinessFactors) _then;

/// Create a copy of ReadinessFactors
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutFrequencyScore = null,Object? recoveryTimeScore = null,Object? consistencyScore = null,Object? daysSinceLastWorkout = freezed,Object? workoutsLast7Days = freezed,Object? avgWorkoutsPerWeek = freezed,}) {
  return _then(_self.copyWith(
workoutFrequencyScore: null == workoutFrequencyScore ? _self.workoutFrequencyScore : workoutFrequencyScore // ignore: cast_nullable_to_non_nullable
as int,recoveryTimeScore: null == recoveryTimeScore ? _self.recoveryTimeScore : recoveryTimeScore // ignore: cast_nullable_to_non_nullable
as int,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as int,daysSinceLastWorkout: freezed == daysSinceLastWorkout ? _self.daysSinceLastWorkout : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
as int?,workoutsLast7Days: freezed == workoutsLast7Days ? _self.workoutsLast7Days : workoutsLast7Days // ignore: cast_nullable_to_non_nullable
as int?,avgWorkoutsPerWeek: freezed == avgWorkoutsPerWeek ? _self.avgWorkoutsPerWeek : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadinessFactors].
extension ReadinessFactorsPatterns on ReadinessFactors {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadinessFactors value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadinessFactors() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadinessFactors value)  $default,){
final _that = this;
switch (_that) {
case _ReadinessFactors():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadinessFactors value)?  $default,){
final _that = this;
switch (_that) {
case _ReadinessFactors() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workoutFrequencyScore,  int recoveryTimeScore,  int consistencyScore,  int? daysSinceLastWorkout,  int? workoutsLast7Days,  double? avgWorkoutsPerWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadinessFactors() when $default != null:
return $default(_that.workoutFrequencyScore,_that.recoveryTimeScore,_that.consistencyScore,_that.daysSinceLastWorkout,_that.workoutsLast7Days,_that.avgWorkoutsPerWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workoutFrequencyScore,  int recoveryTimeScore,  int consistencyScore,  int? daysSinceLastWorkout,  int? workoutsLast7Days,  double? avgWorkoutsPerWeek)  $default,) {final _that = this;
switch (_that) {
case _ReadinessFactors():
return $default(_that.workoutFrequencyScore,_that.recoveryTimeScore,_that.consistencyScore,_that.daysSinceLastWorkout,_that.workoutsLast7Days,_that.avgWorkoutsPerWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workoutFrequencyScore,  int recoveryTimeScore,  int consistencyScore,  int? daysSinceLastWorkout,  int? workoutsLast7Days,  double? avgWorkoutsPerWeek)?  $default,) {final _that = this;
switch (_that) {
case _ReadinessFactors() when $default != null:
return $default(_that.workoutFrequencyScore,_that.recoveryTimeScore,_that.consistencyScore,_that.daysSinceLastWorkout,_that.workoutsLast7Days,_that.avgWorkoutsPerWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadinessFactors implements ReadinessFactors {
  const _ReadinessFactors({required this.workoutFrequencyScore, required this.recoveryTimeScore, required this.consistencyScore, this.daysSinceLastWorkout, this.workoutsLast7Days, this.avgWorkoutsPerWeek});
  factory _ReadinessFactors.fromJson(Map<String, dynamic> json) => _$ReadinessFactorsFromJson(json);

/// Workout frequency score (0-100)
///
/// **Calculation**: Recent training volume vs baseline (40% weight)
@override final  int workoutFrequencyScore;
/// Recovery time score (0-100)
///
/// **Calculation**: Days since last workout (30% weight)
@override final  int recoveryTimeScore;
/// Training consistency score (0-100)
///
/// **Calculation**: Adherence to workout schedule (30% weight)
@override final  int consistencyScore;
/// Optional: Days since last workout
@override final  int? daysSinceLastWorkout;
/// Optional: Workouts in last 7 days
@override final  int? workoutsLast7Days;
/// Optional: Average workouts per week
@override final  double? avgWorkoutsPerWeek;

/// Create a copy of ReadinessFactors
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadinessFactorsCopyWith<_ReadinessFactors> get copyWith => __$ReadinessFactorsCopyWithImpl<_ReadinessFactors>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadinessFactorsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadinessFactors&&(identical(other.workoutFrequencyScore, workoutFrequencyScore) || other.workoutFrequencyScore == workoutFrequencyScore)&&(identical(other.recoveryTimeScore, recoveryTimeScore) || other.recoveryTimeScore == recoveryTimeScore)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore)&&(identical(other.daysSinceLastWorkout, daysSinceLastWorkout) || other.daysSinceLastWorkout == daysSinceLastWorkout)&&(identical(other.workoutsLast7Days, workoutsLast7Days) || other.workoutsLast7Days == workoutsLast7Days)&&(identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) || other.avgWorkoutsPerWeek == avgWorkoutsPerWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutFrequencyScore,recoveryTimeScore,consistencyScore,daysSinceLastWorkout,workoutsLast7Days,avgWorkoutsPerWeek);

@override
String toString() {
  return 'ReadinessFactors(workoutFrequencyScore: $workoutFrequencyScore, recoveryTimeScore: $recoveryTimeScore, consistencyScore: $consistencyScore, daysSinceLastWorkout: $daysSinceLastWorkout, workoutsLast7Days: $workoutsLast7Days, avgWorkoutsPerWeek: $avgWorkoutsPerWeek)';
}


}

/// @nodoc
abstract mixin class _$ReadinessFactorsCopyWith<$Res> implements $ReadinessFactorsCopyWith<$Res> {
  factory _$ReadinessFactorsCopyWith(_ReadinessFactors value, $Res Function(_ReadinessFactors) _then) = __$ReadinessFactorsCopyWithImpl;
@override @useResult
$Res call({
 int workoutFrequencyScore, int recoveryTimeScore, int consistencyScore, int? daysSinceLastWorkout, int? workoutsLast7Days, double? avgWorkoutsPerWeek
});




}
/// @nodoc
class __$ReadinessFactorsCopyWithImpl<$Res>
    implements _$ReadinessFactorsCopyWith<$Res> {
  __$ReadinessFactorsCopyWithImpl(this._self, this._then);

  final _ReadinessFactors _self;
  final $Res Function(_ReadinessFactors) _then;

/// Create a copy of ReadinessFactors
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutFrequencyScore = null,Object? recoveryTimeScore = null,Object? consistencyScore = null,Object? daysSinceLastWorkout = freezed,Object? workoutsLast7Days = freezed,Object? avgWorkoutsPerWeek = freezed,}) {
  return _then(_ReadinessFactors(
workoutFrequencyScore: null == workoutFrequencyScore ? _self.workoutFrequencyScore : workoutFrequencyScore // ignore: cast_nullable_to_non_nullable
as int,recoveryTimeScore: null == recoveryTimeScore ? _self.recoveryTimeScore : recoveryTimeScore // ignore: cast_nullable_to_non_nullable
as int,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as int,daysSinceLastWorkout: freezed == daysSinceLastWorkout ? _self.daysSinceLastWorkout : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
as int?,workoutsLast7Days: freezed == workoutsLast7Days ? _self.workoutsLast7Days : workoutsLast7Days // ignore: cast_nullable_to_non_nullable
as int?,avgWorkoutsPerWeek: freezed == avgWorkoutsPerWeek ? _self.avgWorkoutsPerWeek : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
