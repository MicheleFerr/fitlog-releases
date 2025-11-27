// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consistency_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsistencyScore {

// NEW: Binary indicators (100% validated thresholds)
/// Frequency is optimal (3-5 workouts per week)
/// Source: Schoenfeld et al. 2019 (PMID: 30558493)
 bool get frequencyOptimal;/// Rest is optimal (2-3 rest days per week)
/// Source: UCLA Health 2024 - <2 days = 5.2x injury risk
 bool get restOptimal;/// Progression is positive (>5% improvement)
/// Source: NASM 2023 - Progressive overload guidelines
 bool get progressionPositive;// EXISTING: Detailed scores (keep for breakdown view)
/// Frequency score component (0-100) - changed to int for widget compatibility
 int get frequencyScore;/// Rest score component (0-100) - changed to int for widget compatibility
 int get restScore;/// Progression score component (0-100) - changed to int for widget compatibility
 int get progressionScore;// EXISTING: Statistics
/// Weekly statistics (aggregated 7-day metrics)
 WeeklyStats get weeklyStats;/// Number of workouts completed
 int get workoutsCompleted;/// Number of workouts skipped
 int get workoutsSkipped;/// Average workout frequency (workouts per week)
 double get avgFrequency;/// Longest workout streak (consecutive days)
 int get longestStreak;/// Current workout streak (consecutive days)
 int get currentStreak;/// Timestamp of calculation
 DateTime? get calculatedAt;// DEPRECATED: Keep for backward compatibility (1 version)
/// Overall consistency score (0-100)
@Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead') int? get overallScore;/// Score rating text (Excellent, Good, Fair, Poor)
@Deprecated('Use binary indicators instead') String? get scoreRating;/// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
@Deprecated('Use binary indicators instead') String? get rating;/// Risk level (Low, Medium, High) - string version
@Deprecated('Use binary indicators instead') String? get riskLevel;/// Overtraining risk level (enum)
@Deprecated('Insufficient indicators - requires HR monitoring') OvertrainingRisk? get overtrainingRisk;/// Volume score component (0-100) - changed to int for widget compatibility
@Deprecated('Total volume too generic - needs per-muscle-group') int? get volumeScore;
/// Create a copy of ConsistencyScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsistencyScoreCopyWith<ConsistencyScore> get copyWith => _$ConsistencyScoreCopyWithImpl<ConsistencyScore>(this as ConsistencyScore, _$identity);

  /// Serializes this ConsistencyScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsistencyScore&&(identical(other.frequencyOptimal, frequencyOptimal) || other.frequencyOptimal == frequencyOptimal)&&(identical(other.restOptimal, restOptimal) || other.restOptimal == restOptimal)&&(identical(other.progressionPositive, progressionPositive) || other.progressionPositive == progressionPositive)&&(identical(other.frequencyScore, frequencyScore) || other.frequencyScore == frequencyScore)&&(identical(other.restScore, restScore) || other.restScore == restScore)&&(identical(other.progressionScore, progressionScore) || other.progressionScore == progressionScore)&&(identical(other.weeklyStats, weeklyStats) || other.weeklyStats == weeklyStats)&&(identical(other.workoutsCompleted, workoutsCompleted) || other.workoutsCompleted == workoutsCompleted)&&(identical(other.workoutsSkipped, workoutsSkipped) || other.workoutsSkipped == workoutsSkipped)&&(identical(other.avgFrequency, avgFrequency) || other.avgFrequency == avgFrequency)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.overallScore, overallScore) || other.overallScore == overallScore)&&(identical(other.scoreRating, scoreRating) || other.scoreRating == scoreRating)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.overtrainingRisk, overtrainingRisk) || other.overtrainingRisk == overtrainingRisk)&&(identical(other.volumeScore, volumeScore) || other.volumeScore == volumeScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,frequencyOptimal,restOptimal,progressionPositive,frequencyScore,restScore,progressionScore,weeklyStats,workoutsCompleted,workoutsSkipped,avgFrequency,longestStreak,currentStreak,calculatedAt,overallScore,scoreRating,rating,riskLevel,overtrainingRisk,volumeScore]);

@override
String toString() {
  return 'ConsistencyScore(frequencyOptimal: $frequencyOptimal, restOptimal: $restOptimal, progressionPositive: $progressionPositive, frequencyScore: $frequencyScore, restScore: $restScore, progressionScore: $progressionScore, weeklyStats: $weeklyStats, workoutsCompleted: $workoutsCompleted, workoutsSkipped: $workoutsSkipped, avgFrequency: $avgFrequency, longestStreak: $longestStreak, currentStreak: $currentStreak, calculatedAt: $calculatedAt, overallScore: $overallScore, scoreRating: $scoreRating, rating: $rating, riskLevel: $riskLevel, overtrainingRisk: $overtrainingRisk, volumeScore: $volumeScore)';
}


}

/// @nodoc
abstract mixin class $ConsistencyScoreCopyWith<$Res>  {
  factory $ConsistencyScoreCopyWith(ConsistencyScore value, $Res Function(ConsistencyScore) _then) = _$ConsistencyScoreCopyWithImpl;
@useResult
$Res call({
 bool frequencyOptimal, bool restOptimal, bool progressionPositive, int frequencyScore, int restScore, int progressionScore, WeeklyStats weeklyStats, int workoutsCompleted, int workoutsSkipped, double avgFrequency, int longestStreak, int currentStreak, DateTime? calculatedAt,@Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead') int? overallScore,@Deprecated('Use binary indicators instead') String? scoreRating,@Deprecated('Use binary indicators instead') String? rating,@Deprecated('Use binary indicators instead') String? riskLevel,@Deprecated('Insufficient indicators - requires HR monitoring') OvertrainingRisk? overtrainingRisk,@Deprecated('Total volume too generic - needs per-muscle-group') int? volumeScore
});


$WeeklyStatsCopyWith<$Res> get weeklyStats;

}
/// @nodoc
class _$ConsistencyScoreCopyWithImpl<$Res>
    implements $ConsistencyScoreCopyWith<$Res> {
  _$ConsistencyScoreCopyWithImpl(this._self, this._then);

  final ConsistencyScore _self;
  final $Res Function(ConsistencyScore) _then;

/// Create a copy of ConsistencyScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frequencyOptimal = null,Object? restOptimal = null,Object? progressionPositive = null,Object? frequencyScore = null,Object? restScore = null,Object? progressionScore = null,Object? weeklyStats = null,Object? workoutsCompleted = null,Object? workoutsSkipped = null,Object? avgFrequency = null,Object? longestStreak = null,Object? currentStreak = null,Object? calculatedAt = freezed,Object? overallScore = freezed,Object? scoreRating = freezed,Object? rating = freezed,Object? riskLevel = freezed,Object? overtrainingRisk = freezed,Object? volumeScore = freezed,}) {
  return _then(_self.copyWith(
frequencyOptimal: null == frequencyOptimal ? _self.frequencyOptimal : frequencyOptimal // ignore: cast_nullable_to_non_nullable
as bool,restOptimal: null == restOptimal ? _self.restOptimal : restOptimal // ignore: cast_nullable_to_non_nullable
as bool,progressionPositive: null == progressionPositive ? _self.progressionPositive : progressionPositive // ignore: cast_nullable_to_non_nullable
as bool,frequencyScore: null == frequencyScore ? _self.frequencyScore : frequencyScore // ignore: cast_nullable_to_non_nullable
as int,restScore: null == restScore ? _self.restScore : restScore // ignore: cast_nullable_to_non_nullable
as int,progressionScore: null == progressionScore ? _self.progressionScore : progressionScore // ignore: cast_nullable_to_non_nullable
as int,weeklyStats: null == weeklyStats ? _self.weeklyStats : weeklyStats // ignore: cast_nullable_to_non_nullable
as WeeklyStats,workoutsCompleted: null == workoutsCompleted ? _self.workoutsCompleted : workoutsCompleted // ignore: cast_nullable_to_non_nullable
as int,workoutsSkipped: null == workoutsSkipped ? _self.workoutsSkipped : workoutsSkipped // ignore: cast_nullable_to_non_nullable
as int,avgFrequency: null == avgFrequency ? _self.avgFrequency : avgFrequency // ignore: cast_nullable_to_non_nullable
as double,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,overallScore: freezed == overallScore ? _self.overallScore : overallScore // ignore: cast_nullable_to_non_nullable
as int?,scoreRating: freezed == scoreRating ? _self.scoreRating : scoreRating // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,riskLevel: freezed == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as String?,overtrainingRisk: freezed == overtrainingRisk ? _self.overtrainingRisk : overtrainingRisk // ignore: cast_nullable_to_non_nullable
as OvertrainingRisk?,volumeScore: freezed == volumeScore ? _self.volumeScore : volumeScore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ConsistencyScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyStatsCopyWith<$Res> get weeklyStats {
  
  return $WeeklyStatsCopyWith<$Res>(_self.weeklyStats, (value) {
    return _then(_self.copyWith(weeklyStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConsistencyScore].
extension ConsistencyScorePatterns on ConsistencyScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsistencyScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsistencyScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsistencyScore value)  $default,){
final _that = this;
switch (_that) {
case _ConsistencyScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsistencyScore value)?  $default,){
final _that = this;
switch (_that) {
case _ConsistencyScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool frequencyOptimal,  bool restOptimal,  bool progressionPositive,  int frequencyScore,  int restScore,  int progressionScore,  WeeklyStats weeklyStats,  int workoutsCompleted,  int workoutsSkipped,  double avgFrequency,  int longestStreak,  int currentStreak,  DateTime? calculatedAt, @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead')  int? overallScore, @Deprecated('Use binary indicators instead')  String? scoreRating, @Deprecated('Use binary indicators instead')  String? rating, @Deprecated('Use binary indicators instead')  String? riskLevel, @Deprecated('Insufficient indicators - requires HR monitoring')  OvertrainingRisk? overtrainingRisk, @Deprecated('Total volume too generic - needs per-muscle-group')  int? volumeScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsistencyScore() when $default != null:
return $default(_that.frequencyOptimal,_that.restOptimal,_that.progressionPositive,_that.frequencyScore,_that.restScore,_that.progressionScore,_that.weeklyStats,_that.workoutsCompleted,_that.workoutsSkipped,_that.avgFrequency,_that.longestStreak,_that.currentStreak,_that.calculatedAt,_that.overallScore,_that.scoreRating,_that.rating,_that.riskLevel,_that.overtrainingRisk,_that.volumeScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool frequencyOptimal,  bool restOptimal,  bool progressionPositive,  int frequencyScore,  int restScore,  int progressionScore,  WeeklyStats weeklyStats,  int workoutsCompleted,  int workoutsSkipped,  double avgFrequency,  int longestStreak,  int currentStreak,  DateTime? calculatedAt, @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead')  int? overallScore, @Deprecated('Use binary indicators instead')  String? scoreRating, @Deprecated('Use binary indicators instead')  String? rating, @Deprecated('Use binary indicators instead')  String? riskLevel, @Deprecated('Insufficient indicators - requires HR monitoring')  OvertrainingRisk? overtrainingRisk, @Deprecated('Total volume too generic - needs per-muscle-group')  int? volumeScore)  $default,) {final _that = this;
switch (_that) {
case _ConsistencyScore():
return $default(_that.frequencyOptimal,_that.restOptimal,_that.progressionPositive,_that.frequencyScore,_that.restScore,_that.progressionScore,_that.weeklyStats,_that.workoutsCompleted,_that.workoutsSkipped,_that.avgFrequency,_that.longestStreak,_that.currentStreak,_that.calculatedAt,_that.overallScore,_that.scoreRating,_that.rating,_that.riskLevel,_that.overtrainingRisk,_that.volumeScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool frequencyOptimal,  bool restOptimal,  bool progressionPositive,  int frequencyScore,  int restScore,  int progressionScore,  WeeklyStats weeklyStats,  int workoutsCompleted,  int workoutsSkipped,  double avgFrequency,  int longestStreak,  int currentStreak,  DateTime? calculatedAt, @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead')  int? overallScore, @Deprecated('Use binary indicators instead')  String? scoreRating, @Deprecated('Use binary indicators instead')  String? rating, @Deprecated('Use binary indicators instead')  String? riskLevel, @Deprecated('Insufficient indicators - requires HR monitoring')  OvertrainingRisk? overtrainingRisk, @Deprecated('Total volume too generic - needs per-muscle-group')  int? volumeScore)?  $default,) {final _that = this;
switch (_that) {
case _ConsistencyScore() when $default != null:
return $default(_that.frequencyOptimal,_that.restOptimal,_that.progressionPositive,_that.frequencyScore,_that.restScore,_that.progressionScore,_that.weeklyStats,_that.workoutsCompleted,_that.workoutsSkipped,_that.avgFrequency,_that.longestStreak,_that.currentStreak,_that.calculatedAt,_that.overallScore,_that.scoreRating,_that.rating,_that.riskLevel,_that.overtrainingRisk,_that.volumeScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConsistencyScore implements ConsistencyScore {
  const _ConsistencyScore({this.frequencyOptimal = false, this.restOptimal = false, this.progressionPositive = false, this.frequencyScore = 0, this.restScore = 0, this.progressionScore = 0, required this.weeklyStats, this.workoutsCompleted = 0, this.workoutsSkipped = 0, this.avgFrequency = 0.0, this.longestStreak = 0, this.currentStreak = 0, this.calculatedAt, @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead') this.overallScore, @Deprecated('Use binary indicators instead') this.scoreRating, @Deprecated('Use binary indicators instead') this.rating, @Deprecated('Use binary indicators instead') this.riskLevel, @Deprecated('Insufficient indicators - requires HR monitoring') this.overtrainingRisk, @Deprecated('Total volume too generic - needs per-muscle-group') this.volumeScore});
  factory _ConsistencyScore.fromJson(Map<String, dynamic> json) => _$ConsistencyScoreFromJson(json);

// NEW: Binary indicators (100% validated thresholds)
/// Frequency is optimal (3-5 workouts per week)
/// Source: Schoenfeld et al. 2019 (PMID: 30558493)
@override@JsonKey() final  bool frequencyOptimal;
/// Rest is optimal (2-3 rest days per week)
/// Source: UCLA Health 2024 - <2 days = 5.2x injury risk
@override@JsonKey() final  bool restOptimal;
/// Progression is positive (>5% improvement)
/// Source: NASM 2023 - Progressive overload guidelines
@override@JsonKey() final  bool progressionPositive;
// EXISTING: Detailed scores (keep for breakdown view)
/// Frequency score component (0-100) - changed to int for widget compatibility
@override@JsonKey() final  int frequencyScore;
/// Rest score component (0-100) - changed to int for widget compatibility
@override@JsonKey() final  int restScore;
/// Progression score component (0-100) - changed to int for widget compatibility
@override@JsonKey() final  int progressionScore;
// EXISTING: Statistics
/// Weekly statistics (aggregated 7-day metrics)
@override final  WeeklyStats weeklyStats;
/// Number of workouts completed
@override@JsonKey() final  int workoutsCompleted;
/// Number of workouts skipped
@override@JsonKey() final  int workoutsSkipped;
/// Average workout frequency (workouts per week)
@override@JsonKey() final  double avgFrequency;
/// Longest workout streak (consecutive days)
@override@JsonKey() final  int longestStreak;
/// Current workout streak (consecutive days)
@override@JsonKey() final  int currentStreak;
/// Timestamp of calculation
@override final  DateTime? calculatedAt;
// DEPRECATED: Keep for backward compatibility (1 version)
/// Overall consistency score (0-100)
@override@Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead') final  int? overallScore;
/// Score rating text (Excellent, Good, Fair, Poor)
@override@Deprecated('Use binary indicators instead') final  String? scoreRating;
/// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
@override@Deprecated('Use binary indicators instead') final  String? rating;
/// Risk level (Low, Medium, High) - string version
@override@Deprecated('Use binary indicators instead') final  String? riskLevel;
/// Overtraining risk level (enum)
@override@Deprecated('Insufficient indicators - requires HR monitoring') final  OvertrainingRisk? overtrainingRisk;
/// Volume score component (0-100) - changed to int for widget compatibility
@override@Deprecated('Total volume too generic - needs per-muscle-group') final  int? volumeScore;

/// Create a copy of ConsistencyScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsistencyScoreCopyWith<_ConsistencyScore> get copyWith => __$ConsistencyScoreCopyWithImpl<_ConsistencyScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsistencyScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsistencyScore&&(identical(other.frequencyOptimal, frequencyOptimal) || other.frequencyOptimal == frequencyOptimal)&&(identical(other.restOptimal, restOptimal) || other.restOptimal == restOptimal)&&(identical(other.progressionPositive, progressionPositive) || other.progressionPositive == progressionPositive)&&(identical(other.frequencyScore, frequencyScore) || other.frequencyScore == frequencyScore)&&(identical(other.restScore, restScore) || other.restScore == restScore)&&(identical(other.progressionScore, progressionScore) || other.progressionScore == progressionScore)&&(identical(other.weeklyStats, weeklyStats) || other.weeklyStats == weeklyStats)&&(identical(other.workoutsCompleted, workoutsCompleted) || other.workoutsCompleted == workoutsCompleted)&&(identical(other.workoutsSkipped, workoutsSkipped) || other.workoutsSkipped == workoutsSkipped)&&(identical(other.avgFrequency, avgFrequency) || other.avgFrequency == avgFrequency)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.overallScore, overallScore) || other.overallScore == overallScore)&&(identical(other.scoreRating, scoreRating) || other.scoreRating == scoreRating)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.riskLevel, riskLevel) || other.riskLevel == riskLevel)&&(identical(other.overtrainingRisk, overtrainingRisk) || other.overtrainingRisk == overtrainingRisk)&&(identical(other.volumeScore, volumeScore) || other.volumeScore == volumeScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,frequencyOptimal,restOptimal,progressionPositive,frequencyScore,restScore,progressionScore,weeklyStats,workoutsCompleted,workoutsSkipped,avgFrequency,longestStreak,currentStreak,calculatedAt,overallScore,scoreRating,rating,riskLevel,overtrainingRisk,volumeScore]);

@override
String toString() {
  return 'ConsistencyScore(frequencyOptimal: $frequencyOptimal, restOptimal: $restOptimal, progressionPositive: $progressionPositive, frequencyScore: $frequencyScore, restScore: $restScore, progressionScore: $progressionScore, weeklyStats: $weeklyStats, workoutsCompleted: $workoutsCompleted, workoutsSkipped: $workoutsSkipped, avgFrequency: $avgFrequency, longestStreak: $longestStreak, currentStreak: $currentStreak, calculatedAt: $calculatedAt, overallScore: $overallScore, scoreRating: $scoreRating, rating: $rating, riskLevel: $riskLevel, overtrainingRisk: $overtrainingRisk, volumeScore: $volumeScore)';
}


}

/// @nodoc
abstract mixin class _$ConsistencyScoreCopyWith<$Res> implements $ConsistencyScoreCopyWith<$Res> {
  factory _$ConsistencyScoreCopyWith(_ConsistencyScore value, $Res Function(_ConsistencyScore) _then) = __$ConsistencyScoreCopyWithImpl;
@override @useResult
$Res call({
 bool frequencyOptimal, bool restOptimal, bool progressionPositive, int frequencyScore, int restScore, int progressionScore, WeeklyStats weeklyStats, int workoutsCompleted, int workoutsSkipped, double avgFrequency, int longestStreak, int currentStreak, DateTime? calculatedAt,@Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead') int? overallScore,@Deprecated('Use binary indicators instead') String? scoreRating,@Deprecated('Use binary indicators instead') String? rating,@Deprecated('Use binary indicators instead') String? riskLevel,@Deprecated('Insufficient indicators - requires HR monitoring') OvertrainingRisk? overtrainingRisk,@Deprecated('Total volume too generic - needs per-muscle-group') int? volumeScore
});


@override $WeeklyStatsCopyWith<$Res> get weeklyStats;

}
/// @nodoc
class __$ConsistencyScoreCopyWithImpl<$Res>
    implements _$ConsistencyScoreCopyWith<$Res> {
  __$ConsistencyScoreCopyWithImpl(this._self, this._then);

  final _ConsistencyScore _self;
  final $Res Function(_ConsistencyScore) _then;

/// Create a copy of ConsistencyScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frequencyOptimal = null,Object? restOptimal = null,Object? progressionPositive = null,Object? frequencyScore = null,Object? restScore = null,Object? progressionScore = null,Object? weeklyStats = null,Object? workoutsCompleted = null,Object? workoutsSkipped = null,Object? avgFrequency = null,Object? longestStreak = null,Object? currentStreak = null,Object? calculatedAt = freezed,Object? overallScore = freezed,Object? scoreRating = freezed,Object? rating = freezed,Object? riskLevel = freezed,Object? overtrainingRisk = freezed,Object? volumeScore = freezed,}) {
  return _then(_ConsistencyScore(
frequencyOptimal: null == frequencyOptimal ? _self.frequencyOptimal : frequencyOptimal // ignore: cast_nullable_to_non_nullable
as bool,restOptimal: null == restOptimal ? _self.restOptimal : restOptimal // ignore: cast_nullable_to_non_nullable
as bool,progressionPositive: null == progressionPositive ? _self.progressionPositive : progressionPositive // ignore: cast_nullable_to_non_nullable
as bool,frequencyScore: null == frequencyScore ? _self.frequencyScore : frequencyScore // ignore: cast_nullable_to_non_nullable
as int,restScore: null == restScore ? _self.restScore : restScore // ignore: cast_nullable_to_non_nullable
as int,progressionScore: null == progressionScore ? _self.progressionScore : progressionScore // ignore: cast_nullable_to_non_nullable
as int,weeklyStats: null == weeklyStats ? _self.weeklyStats : weeklyStats // ignore: cast_nullable_to_non_nullable
as WeeklyStats,workoutsCompleted: null == workoutsCompleted ? _self.workoutsCompleted : workoutsCompleted // ignore: cast_nullable_to_non_nullable
as int,workoutsSkipped: null == workoutsSkipped ? _self.workoutsSkipped : workoutsSkipped // ignore: cast_nullable_to_non_nullable
as int,avgFrequency: null == avgFrequency ? _self.avgFrequency : avgFrequency // ignore: cast_nullable_to_non_nullable
as double,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,overallScore: freezed == overallScore ? _self.overallScore : overallScore // ignore: cast_nullable_to_non_nullable
as int?,scoreRating: freezed == scoreRating ? _self.scoreRating : scoreRating // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as String?,riskLevel: freezed == riskLevel ? _self.riskLevel : riskLevel // ignore: cast_nullable_to_non_nullable
as String?,overtrainingRisk: freezed == overtrainingRisk ? _self.overtrainingRisk : overtrainingRisk // ignore: cast_nullable_to_non_nullable
as OvertrainingRisk?,volumeScore: freezed == volumeScore ? _self.volumeScore : volumeScore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ConsistencyScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeeklyStatsCopyWith<$Res> get weeklyStats {
  
  return $WeeklyStatsCopyWith<$Res>(_self.weeklyStats, (value) {
    return _then(_self.copyWith(weeklyStats: value));
  });
}
}

// dart format on
