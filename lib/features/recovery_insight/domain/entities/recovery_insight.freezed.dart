// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovery_insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecoveryInsight {

/// Recovery score (0-100)
 int get score;/// Category derived from score
 RecoveryCategory get category;/// Localized recommendation text
 String get recommendation;/// Last night's sleep duration
 Duration get lastNightSleep;/// Average sleep over last 7 days (in hours)
 double get weeklyAverageHours;/// Consecutive nights with <6h sleep
 int get consecutiveBadNights;/// Days in a row meeting sleep goal
 int get streakDays;/// Sleep-workout correlation data (Pro only)
 SleepWorkoutCorrelation? get correlation;/// Timestamp when calculated
 DateTime? get calculatedAt;/// Whether sleep data is available
 bool get hasSleepData;/// Score breakdown components for transparency
 double get baseScore; double get sleepModifier; double get consecutivePenalty;
/// Create a copy of RecoveryInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryInsightCopyWith<RecoveryInsight> get copyWith => _$RecoveryInsightCopyWithImpl<RecoveryInsight>(this as RecoveryInsight, _$identity);

  /// Serializes this RecoveryInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryInsight&&(identical(other.score, score) || other.score == score)&&(identical(other.category, category) || other.category == category)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.lastNightSleep, lastNightSleep) || other.lastNightSleep == lastNightSleep)&&(identical(other.weeklyAverageHours, weeklyAverageHours) || other.weeklyAverageHours == weeklyAverageHours)&&(identical(other.consecutiveBadNights, consecutiveBadNights) || other.consecutiveBadNights == consecutiveBadNights)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.correlation, correlation) || other.correlation == correlation)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.hasSleepData, hasSleepData) || other.hasSleepData == hasSleepData)&&(identical(other.baseScore, baseScore) || other.baseScore == baseScore)&&(identical(other.sleepModifier, sleepModifier) || other.sleepModifier == sleepModifier)&&(identical(other.consecutivePenalty, consecutivePenalty) || other.consecutivePenalty == consecutivePenalty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,category,recommendation,lastNightSleep,weeklyAverageHours,consecutiveBadNights,streakDays,correlation,calculatedAt,hasSleepData,baseScore,sleepModifier,consecutivePenalty);

@override
String toString() {
  return 'RecoveryInsight(score: $score, category: $category, recommendation: $recommendation, lastNightSleep: $lastNightSleep, weeklyAverageHours: $weeklyAverageHours, consecutiveBadNights: $consecutiveBadNights, streakDays: $streakDays, correlation: $correlation, calculatedAt: $calculatedAt, hasSleepData: $hasSleepData, baseScore: $baseScore, sleepModifier: $sleepModifier, consecutivePenalty: $consecutivePenalty)';
}


}

/// @nodoc
abstract mixin class $RecoveryInsightCopyWith<$Res>  {
  factory $RecoveryInsightCopyWith(RecoveryInsight value, $Res Function(RecoveryInsight) _then) = _$RecoveryInsightCopyWithImpl;
@useResult
$Res call({
 int score, RecoveryCategory category, String recommendation, Duration lastNightSleep, double weeklyAverageHours, int consecutiveBadNights, int streakDays, SleepWorkoutCorrelation? correlation, DateTime? calculatedAt, bool hasSleepData, double baseScore, double sleepModifier, double consecutivePenalty
});


$SleepWorkoutCorrelationCopyWith<$Res>? get correlation;

}
/// @nodoc
class _$RecoveryInsightCopyWithImpl<$Res>
    implements $RecoveryInsightCopyWith<$Res> {
  _$RecoveryInsightCopyWithImpl(this._self, this._then);

  final RecoveryInsight _self;
  final $Res Function(RecoveryInsight) _then;

/// Create a copy of RecoveryInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? score = null,Object? category = null,Object? recommendation = null,Object? lastNightSleep = null,Object? weeklyAverageHours = null,Object? consecutiveBadNights = null,Object? streakDays = null,Object? correlation = freezed,Object? calculatedAt = freezed,Object? hasSleepData = null,Object? baseScore = null,Object? sleepModifier = null,Object? consecutivePenalty = null,}) {
  return _then(_self.copyWith(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RecoveryCategory,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,lastNightSleep: null == lastNightSleep ? _self.lastNightSleep : lastNightSleep // ignore: cast_nullable_to_non_nullable
as Duration,weeklyAverageHours: null == weeklyAverageHours ? _self.weeklyAverageHours : weeklyAverageHours // ignore: cast_nullable_to_non_nullable
as double,consecutiveBadNights: null == consecutiveBadNights ? _self.consecutiveBadNights : consecutiveBadNights // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,correlation: freezed == correlation ? _self.correlation : correlation // ignore: cast_nullable_to_non_nullable
as SleepWorkoutCorrelation?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasSleepData: null == hasSleepData ? _self.hasSleepData : hasSleepData // ignore: cast_nullable_to_non_nullable
as bool,baseScore: null == baseScore ? _self.baseScore : baseScore // ignore: cast_nullable_to_non_nullable
as double,sleepModifier: null == sleepModifier ? _self.sleepModifier : sleepModifier // ignore: cast_nullable_to_non_nullable
as double,consecutivePenalty: null == consecutivePenalty ? _self.consecutivePenalty : consecutivePenalty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of RecoveryInsight
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SleepWorkoutCorrelationCopyWith<$Res>? get correlation {
    if (_self.correlation == null) {
    return null;
  }

  return $SleepWorkoutCorrelationCopyWith<$Res>(_self.correlation!, (value) {
    return _then(_self.copyWith(correlation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecoveryInsight].
extension RecoveryInsightPatterns on RecoveryInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryInsight value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryInsight value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int score,  RecoveryCategory category,  String recommendation,  Duration lastNightSleep,  double weeklyAverageHours,  int consecutiveBadNights,  int streakDays,  SleepWorkoutCorrelation? correlation,  DateTime? calculatedAt,  bool hasSleepData,  double baseScore,  double sleepModifier,  double consecutivePenalty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryInsight() when $default != null:
return $default(_that.score,_that.category,_that.recommendation,_that.lastNightSleep,_that.weeklyAverageHours,_that.consecutiveBadNights,_that.streakDays,_that.correlation,_that.calculatedAt,_that.hasSleepData,_that.baseScore,_that.sleepModifier,_that.consecutivePenalty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int score,  RecoveryCategory category,  String recommendation,  Duration lastNightSleep,  double weeklyAverageHours,  int consecutiveBadNights,  int streakDays,  SleepWorkoutCorrelation? correlation,  DateTime? calculatedAt,  bool hasSleepData,  double baseScore,  double sleepModifier,  double consecutivePenalty)  $default,) {final _that = this;
switch (_that) {
case _RecoveryInsight():
return $default(_that.score,_that.category,_that.recommendation,_that.lastNightSleep,_that.weeklyAverageHours,_that.consecutiveBadNights,_that.streakDays,_that.correlation,_that.calculatedAt,_that.hasSleepData,_that.baseScore,_that.sleepModifier,_that.consecutivePenalty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int score,  RecoveryCategory category,  String recommendation,  Duration lastNightSleep,  double weeklyAverageHours,  int consecutiveBadNights,  int streakDays,  SleepWorkoutCorrelation? correlation,  DateTime? calculatedAt,  bool hasSleepData,  double baseScore,  double sleepModifier,  double consecutivePenalty)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryInsight() when $default != null:
return $default(_that.score,_that.category,_that.recommendation,_that.lastNightSleep,_that.weeklyAverageHours,_that.consecutiveBadNights,_that.streakDays,_that.correlation,_that.calculatedAt,_that.hasSleepData,_that.baseScore,_that.sleepModifier,_that.consecutivePenalty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecoveryInsight extends RecoveryInsight {
  const _RecoveryInsight({required this.score, required this.category, required this.recommendation, required this.lastNightSleep, required this.weeklyAverageHours, required this.consecutiveBadNights, required this.streakDays, this.correlation, this.calculatedAt = null, this.hasSleepData = true, this.baseScore = 0.0, this.sleepModifier = 1.0, this.consecutivePenalty = 1.0}): super._();
  factory _RecoveryInsight.fromJson(Map<String, dynamic> json) => _$RecoveryInsightFromJson(json);

/// Recovery score (0-100)
@override final  int score;
/// Category derived from score
@override final  RecoveryCategory category;
/// Localized recommendation text
@override final  String recommendation;
/// Last night's sleep duration
@override final  Duration lastNightSleep;
/// Average sleep over last 7 days (in hours)
@override final  double weeklyAverageHours;
/// Consecutive nights with <6h sleep
@override final  int consecutiveBadNights;
/// Days in a row meeting sleep goal
@override final  int streakDays;
/// Sleep-workout correlation data (Pro only)
@override final  SleepWorkoutCorrelation? correlation;
/// Timestamp when calculated
@override@JsonKey() final  DateTime? calculatedAt;
/// Whether sleep data is available
@override@JsonKey() final  bool hasSleepData;
/// Score breakdown components for transparency
@override@JsonKey() final  double baseScore;
@override@JsonKey() final  double sleepModifier;
@override@JsonKey() final  double consecutivePenalty;

/// Create a copy of RecoveryInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryInsightCopyWith<_RecoveryInsight> get copyWith => __$RecoveryInsightCopyWithImpl<_RecoveryInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecoveryInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryInsight&&(identical(other.score, score) || other.score == score)&&(identical(other.category, category) || other.category == category)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.lastNightSleep, lastNightSleep) || other.lastNightSleep == lastNightSleep)&&(identical(other.weeklyAverageHours, weeklyAverageHours) || other.weeklyAverageHours == weeklyAverageHours)&&(identical(other.consecutiveBadNights, consecutiveBadNights) || other.consecutiveBadNights == consecutiveBadNights)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&(identical(other.correlation, correlation) || other.correlation == correlation)&&(identical(other.calculatedAt, calculatedAt) || other.calculatedAt == calculatedAt)&&(identical(other.hasSleepData, hasSleepData) || other.hasSleepData == hasSleepData)&&(identical(other.baseScore, baseScore) || other.baseScore == baseScore)&&(identical(other.sleepModifier, sleepModifier) || other.sleepModifier == sleepModifier)&&(identical(other.consecutivePenalty, consecutivePenalty) || other.consecutivePenalty == consecutivePenalty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,category,recommendation,lastNightSleep,weeklyAverageHours,consecutiveBadNights,streakDays,correlation,calculatedAt,hasSleepData,baseScore,sleepModifier,consecutivePenalty);

@override
String toString() {
  return 'RecoveryInsight(score: $score, category: $category, recommendation: $recommendation, lastNightSleep: $lastNightSleep, weeklyAverageHours: $weeklyAverageHours, consecutiveBadNights: $consecutiveBadNights, streakDays: $streakDays, correlation: $correlation, calculatedAt: $calculatedAt, hasSleepData: $hasSleepData, baseScore: $baseScore, sleepModifier: $sleepModifier, consecutivePenalty: $consecutivePenalty)';
}


}

/// @nodoc
abstract mixin class _$RecoveryInsightCopyWith<$Res> implements $RecoveryInsightCopyWith<$Res> {
  factory _$RecoveryInsightCopyWith(_RecoveryInsight value, $Res Function(_RecoveryInsight) _then) = __$RecoveryInsightCopyWithImpl;
@override @useResult
$Res call({
 int score, RecoveryCategory category, String recommendation, Duration lastNightSleep, double weeklyAverageHours, int consecutiveBadNights, int streakDays, SleepWorkoutCorrelation? correlation, DateTime? calculatedAt, bool hasSleepData, double baseScore, double sleepModifier, double consecutivePenalty
});


@override $SleepWorkoutCorrelationCopyWith<$Res>? get correlation;

}
/// @nodoc
class __$RecoveryInsightCopyWithImpl<$Res>
    implements _$RecoveryInsightCopyWith<$Res> {
  __$RecoveryInsightCopyWithImpl(this._self, this._then);

  final _RecoveryInsight _self;
  final $Res Function(_RecoveryInsight) _then;

/// Create a copy of RecoveryInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? score = null,Object? category = null,Object? recommendation = null,Object? lastNightSleep = null,Object? weeklyAverageHours = null,Object? consecutiveBadNights = null,Object? streakDays = null,Object? correlation = freezed,Object? calculatedAt = freezed,Object? hasSleepData = null,Object? baseScore = null,Object? sleepModifier = null,Object? consecutivePenalty = null,}) {
  return _then(_RecoveryInsight(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RecoveryCategory,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,lastNightSleep: null == lastNightSleep ? _self.lastNightSleep : lastNightSleep // ignore: cast_nullable_to_non_nullable
as Duration,weeklyAverageHours: null == weeklyAverageHours ? _self.weeklyAverageHours : weeklyAverageHours // ignore: cast_nullable_to_non_nullable
as double,consecutiveBadNights: null == consecutiveBadNights ? _self.consecutiveBadNights : consecutiveBadNights // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,correlation: freezed == correlation ? _self.correlation : correlation // ignore: cast_nullable_to_non_nullable
as SleepWorkoutCorrelation?,calculatedAt: freezed == calculatedAt ? _self.calculatedAt : calculatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasSleepData: null == hasSleepData ? _self.hasSleepData : hasSleepData // ignore: cast_nullable_to_non_nullable
as bool,baseScore: null == baseScore ? _self.baseScore : baseScore // ignore: cast_nullable_to_non_nullable
as double,sleepModifier: null == sleepModifier ? _self.sleepModifier : sleepModifier // ignore: cast_nullable_to_non_nullable
as double,consecutivePenalty: null == consecutivePenalty ? _self.consecutivePenalty : consecutivePenalty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of RecoveryInsight
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SleepWorkoutCorrelationCopyWith<$Res>? get correlation {
    if (_self.correlation == null) {
    return null;
  }

  return $SleepWorkoutCorrelationCopyWith<$Res>(_self.correlation!, (value) {
    return _then(_self.copyWith(correlation: value));
  });
}
}

// dart format on
