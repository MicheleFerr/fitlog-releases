// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'questionnaire_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuestionnaireAnalytics {

/// User ID for aggregation
 String get userId;/// Timestamp when questionnaire was started
 DateTime get startedAt;/// Timestamp when completed (null if abandoned)
 DateTime? get completedAt;/// Last step user reached before abandoning/completing
 int get lastStepReached;/// Total steps in questionnaire (usually 7: 0-6)
 int get totalSteps;/// Time spent on each step (step index → seconds)
 Map<int, int> get stepDurations;/// Whether user abandoned (true) or completed (false)
 bool? get wasAbandoned;/// Feedback ratings for each step (1-5 scale, null if not rated)
 Map<int, int?> get stepFeedback;/// Total time from start to completion/abandon (seconds)
 int? get totalDurationSeconds;/// Device/platform info for analytics
 String? get platform;/// App version
 String? get appVersion;
/// Create a copy of QuestionnaireAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionnaireAnalyticsCopyWith<QuestionnaireAnalytics> get copyWith => _$QuestionnaireAnalyticsCopyWithImpl<QuestionnaireAnalytics>(this as QuestionnaireAnalytics, _$identity);

  /// Serializes this QuestionnaireAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionnaireAnalytics&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.lastStepReached, lastStepReached) || other.lastStepReached == lastStepReached)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&const DeepCollectionEquality().equals(other.stepDurations, stepDurations)&&(identical(other.wasAbandoned, wasAbandoned) || other.wasAbandoned == wasAbandoned)&&const DeepCollectionEquality().equals(other.stepFeedback, stepFeedback)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,startedAt,completedAt,lastStepReached,totalSteps,const DeepCollectionEquality().hash(stepDurations),wasAbandoned,const DeepCollectionEquality().hash(stepFeedback),totalDurationSeconds,platform,appVersion);

@override
String toString() {
  return 'QuestionnaireAnalytics(userId: $userId, startedAt: $startedAt, completedAt: $completedAt, lastStepReached: $lastStepReached, totalSteps: $totalSteps, stepDurations: $stepDurations, wasAbandoned: $wasAbandoned, stepFeedback: $stepFeedback, totalDurationSeconds: $totalDurationSeconds, platform: $platform, appVersion: $appVersion)';
}


}

/// @nodoc
abstract mixin class $QuestionnaireAnalyticsCopyWith<$Res>  {
  factory $QuestionnaireAnalyticsCopyWith(QuestionnaireAnalytics value, $Res Function(QuestionnaireAnalytics) _then) = _$QuestionnaireAnalyticsCopyWithImpl;
@useResult
$Res call({
 String userId, DateTime startedAt, DateTime? completedAt, int lastStepReached, int totalSteps, Map<int, int> stepDurations, bool? wasAbandoned, Map<int, int?> stepFeedback, int? totalDurationSeconds, String? platform, String? appVersion
});




}
/// @nodoc
class _$QuestionnaireAnalyticsCopyWithImpl<$Res>
    implements $QuestionnaireAnalyticsCopyWith<$Res> {
  _$QuestionnaireAnalyticsCopyWithImpl(this._self, this._then);

  final QuestionnaireAnalytics _self;
  final $Res Function(QuestionnaireAnalytics) _then;

/// Create a copy of QuestionnaireAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? startedAt = null,Object? completedAt = freezed,Object? lastStepReached = null,Object? totalSteps = null,Object? stepDurations = null,Object? wasAbandoned = freezed,Object? stepFeedback = null,Object? totalDurationSeconds = freezed,Object? platform = freezed,Object? appVersion = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStepReached: null == lastStepReached ? _self.lastStepReached : lastStepReached // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,stepDurations: null == stepDurations ? _self.stepDurations : stepDurations // ignore: cast_nullable_to_non_nullable
as Map<int, int>,wasAbandoned: freezed == wasAbandoned ? _self.wasAbandoned : wasAbandoned // ignore: cast_nullable_to_non_nullable
as bool?,stepFeedback: null == stepFeedback ? _self.stepFeedback : stepFeedback // ignore: cast_nullable_to_non_nullable
as Map<int, int?>,totalDurationSeconds: freezed == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionnaireAnalytics].
extension QuestionnaireAnalyticsPatterns on QuestionnaireAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionnaireAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionnaireAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionnaireAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _QuestionnaireAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionnaireAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionnaireAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  DateTime startedAt,  DateTime? completedAt,  int lastStepReached,  int totalSteps,  Map<int, int> stepDurations,  bool? wasAbandoned,  Map<int, int?> stepFeedback,  int? totalDurationSeconds,  String? platform,  String? appVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionnaireAnalytics() when $default != null:
return $default(_that.userId,_that.startedAt,_that.completedAt,_that.lastStepReached,_that.totalSteps,_that.stepDurations,_that.wasAbandoned,_that.stepFeedback,_that.totalDurationSeconds,_that.platform,_that.appVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  DateTime startedAt,  DateTime? completedAt,  int lastStepReached,  int totalSteps,  Map<int, int> stepDurations,  bool? wasAbandoned,  Map<int, int?> stepFeedback,  int? totalDurationSeconds,  String? platform,  String? appVersion)  $default,) {final _that = this;
switch (_that) {
case _QuestionnaireAnalytics():
return $default(_that.userId,_that.startedAt,_that.completedAt,_that.lastStepReached,_that.totalSteps,_that.stepDurations,_that.wasAbandoned,_that.stepFeedback,_that.totalDurationSeconds,_that.platform,_that.appVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  DateTime startedAt,  DateTime? completedAt,  int lastStepReached,  int totalSteps,  Map<int, int> stepDurations,  bool? wasAbandoned,  Map<int, int?> stepFeedback,  int? totalDurationSeconds,  String? platform,  String? appVersion)?  $default,) {final _that = this;
switch (_that) {
case _QuestionnaireAnalytics() when $default != null:
return $default(_that.userId,_that.startedAt,_that.completedAt,_that.lastStepReached,_that.totalSteps,_that.stepDurations,_that.wasAbandoned,_that.stepFeedback,_that.totalDurationSeconds,_that.platform,_that.appVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionnaireAnalytics implements QuestionnaireAnalytics {
  const _QuestionnaireAnalytics({required this.userId, required this.startedAt, this.completedAt, this.lastStepReached = 0, this.totalSteps = 7, final  Map<int, int> stepDurations = const {}, this.wasAbandoned, final  Map<int, int?> stepFeedback = const {}, this.totalDurationSeconds, this.platform, this.appVersion}): _stepDurations = stepDurations,_stepFeedback = stepFeedback;
  factory _QuestionnaireAnalytics.fromJson(Map<String, dynamic> json) => _$QuestionnaireAnalyticsFromJson(json);

/// User ID for aggregation
@override final  String userId;
/// Timestamp when questionnaire was started
@override final  DateTime startedAt;
/// Timestamp when completed (null if abandoned)
@override final  DateTime? completedAt;
/// Last step user reached before abandoning/completing
@override@JsonKey() final  int lastStepReached;
/// Total steps in questionnaire (usually 7: 0-6)
@override@JsonKey() final  int totalSteps;
/// Time spent on each step (step index → seconds)
 final  Map<int, int> _stepDurations;
/// Time spent on each step (step index → seconds)
@override@JsonKey() Map<int, int> get stepDurations {
  if (_stepDurations is EqualUnmodifiableMapView) return _stepDurations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stepDurations);
}

/// Whether user abandoned (true) or completed (false)
@override final  bool? wasAbandoned;
/// Feedback ratings for each step (1-5 scale, null if not rated)
 final  Map<int, int?> _stepFeedback;
/// Feedback ratings for each step (1-5 scale, null if not rated)
@override@JsonKey() Map<int, int?> get stepFeedback {
  if (_stepFeedback is EqualUnmodifiableMapView) return _stepFeedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stepFeedback);
}

/// Total time from start to completion/abandon (seconds)
@override final  int? totalDurationSeconds;
/// Device/platform info for analytics
@override final  String? platform;
/// App version
@override final  String? appVersion;

/// Create a copy of QuestionnaireAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionnaireAnalyticsCopyWith<_QuestionnaireAnalytics> get copyWith => __$QuestionnaireAnalyticsCopyWithImpl<_QuestionnaireAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionnaireAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionnaireAnalytics&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.lastStepReached, lastStepReached) || other.lastStepReached == lastStepReached)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&const DeepCollectionEquality().equals(other._stepDurations, _stepDurations)&&(identical(other.wasAbandoned, wasAbandoned) || other.wasAbandoned == wasAbandoned)&&const DeepCollectionEquality().equals(other._stepFeedback, _stepFeedback)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,startedAt,completedAt,lastStepReached,totalSteps,const DeepCollectionEquality().hash(_stepDurations),wasAbandoned,const DeepCollectionEquality().hash(_stepFeedback),totalDurationSeconds,platform,appVersion);

@override
String toString() {
  return 'QuestionnaireAnalytics(userId: $userId, startedAt: $startedAt, completedAt: $completedAt, lastStepReached: $lastStepReached, totalSteps: $totalSteps, stepDurations: $stepDurations, wasAbandoned: $wasAbandoned, stepFeedback: $stepFeedback, totalDurationSeconds: $totalDurationSeconds, platform: $platform, appVersion: $appVersion)';
}


}

/// @nodoc
abstract mixin class _$QuestionnaireAnalyticsCopyWith<$Res> implements $QuestionnaireAnalyticsCopyWith<$Res> {
  factory _$QuestionnaireAnalyticsCopyWith(_QuestionnaireAnalytics value, $Res Function(_QuestionnaireAnalytics) _then) = __$QuestionnaireAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String userId, DateTime startedAt, DateTime? completedAt, int lastStepReached, int totalSteps, Map<int, int> stepDurations, bool? wasAbandoned, Map<int, int?> stepFeedback, int? totalDurationSeconds, String? platform, String? appVersion
});




}
/// @nodoc
class __$QuestionnaireAnalyticsCopyWithImpl<$Res>
    implements _$QuestionnaireAnalyticsCopyWith<$Res> {
  __$QuestionnaireAnalyticsCopyWithImpl(this._self, this._then);

  final _QuestionnaireAnalytics _self;
  final $Res Function(_QuestionnaireAnalytics) _then;

/// Create a copy of QuestionnaireAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? startedAt = null,Object? completedAt = freezed,Object? lastStepReached = null,Object? totalSteps = null,Object? stepDurations = null,Object? wasAbandoned = freezed,Object? stepFeedback = null,Object? totalDurationSeconds = freezed,Object? platform = freezed,Object? appVersion = freezed,}) {
  return _then(_QuestionnaireAnalytics(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStepReached: null == lastStepReached ? _self.lastStepReached : lastStepReached // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,stepDurations: null == stepDurations ? _self._stepDurations : stepDurations // ignore: cast_nullable_to_non_nullable
as Map<int, int>,wasAbandoned: freezed == wasAbandoned ? _self.wasAbandoned : wasAbandoned // ignore: cast_nullable_to_non_nullable
as bool?,stepFeedback: null == stepFeedback ? _self._stepFeedback : stepFeedback // ignore: cast_nullable_to_non_nullable
as Map<int, int?>,totalDurationSeconds: freezed == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String?,appVersion: freezed == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
