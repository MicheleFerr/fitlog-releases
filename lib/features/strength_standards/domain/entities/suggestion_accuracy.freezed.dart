// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggestion_accuracy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SuggestionAccuracy {

/// Unique ID for this record
 String get id;/// User ID
 String get userId;/// Exercise ID from GymBro database
 String get exerciseId;/// Weight suggested by system (kg)
 double get suggestedWeight;/// Weight actually used by user (kg)
 double get actualWeight;/// Reps suggested by system
 int get suggestedReps;/// Reps actually completed by user
 int get actualReps;/// Absolute error percentage: |actual - suggested| / suggested * 100
 double get weightErrorPercent;/// Reps error: actualReps - suggestedReps (can be negative)
 int get repsError;/// Timestamp when set was performed
 DateTime get timestamp;/// Experience level at time of suggestion
 String get experienceLevel;/// Training goal at time of suggestion
 String get trainingGoal;/// Whether user found suggestion helpful (optional feedback)
 bool? get wasHelpful;/// User's perceived exertion (1-10 RPE scale)
 int? get perceivedExertion;
/// Create a copy of SuggestionAccuracy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestionAccuracyCopyWith<SuggestionAccuracy> get copyWith => _$SuggestionAccuracyCopyWithImpl<SuggestionAccuracy>(this as SuggestionAccuracy, _$identity);

  /// Serializes this SuggestionAccuracy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestionAccuracy&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.actualWeight, actualWeight) || other.actualWeight == actualWeight)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.actualReps, actualReps) || other.actualReps == actualReps)&&(identical(other.weightErrorPercent, weightErrorPercent) || other.weightErrorPercent == weightErrorPercent)&&(identical(other.repsError, repsError) || other.repsError == repsError)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.trainingGoal, trainingGoal) || other.trainingGoal == trainingGoal)&&(identical(other.wasHelpful, wasHelpful) || other.wasHelpful == wasHelpful)&&(identical(other.perceivedExertion, perceivedExertion) || other.perceivedExertion == perceivedExertion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,exerciseId,suggestedWeight,actualWeight,suggestedReps,actualReps,weightErrorPercent,repsError,timestamp,experienceLevel,trainingGoal,wasHelpful,perceivedExertion);

@override
String toString() {
  return 'SuggestionAccuracy(id: $id, userId: $userId, exerciseId: $exerciseId, suggestedWeight: $suggestedWeight, actualWeight: $actualWeight, suggestedReps: $suggestedReps, actualReps: $actualReps, weightErrorPercent: $weightErrorPercent, repsError: $repsError, timestamp: $timestamp, experienceLevel: $experienceLevel, trainingGoal: $trainingGoal, wasHelpful: $wasHelpful, perceivedExertion: $perceivedExertion)';
}


}

/// @nodoc
abstract mixin class $SuggestionAccuracyCopyWith<$Res>  {
  factory $SuggestionAccuracyCopyWith(SuggestionAccuracy value, $Res Function(SuggestionAccuracy) _then) = _$SuggestionAccuracyCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String exerciseId, double suggestedWeight, double actualWeight, int suggestedReps, int actualReps, double weightErrorPercent, int repsError, DateTime timestamp, String experienceLevel, String trainingGoal, bool? wasHelpful, int? perceivedExertion
});




}
/// @nodoc
class _$SuggestionAccuracyCopyWithImpl<$Res>
    implements $SuggestionAccuracyCopyWith<$Res> {
  _$SuggestionAccuracyCopyWithImpl(this._self, this._then);

  final SuggestionAccuracy _self;
  final $Res Function(SuggestionAccuracy) _then;

/// Create a copy of SuggestionAccuracy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? exerciseId = null,Object? suggestedWeight = null,Object? actualWeight = null,Object? suggestedReps = null,Object? actualReps = null,Object? weightErrorPercent = null,Object? repsError = null,Object? timestamp = null,Object? experienceLevel = null,Object? trainingGoal = null,Object? wasHelpful = freezed,Object? perceivedExertion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,suggestedWeight: null == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double,actualWeight: null == actualWeight ? _self.actualWeight : actualWeight // ignore: cast_nullable_to_non_nullable
as double,suggestedReps: null == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int,actualReps: null == actualReps ? _self.actualReps : actualReps // ignore: cast_nullable_to_non_nullable
as int,weightErrorPercent: null == weightErrorPercent ? _self.weightErrorPercent : weightErrorPercent // ignore: cast_nullable_to_non_nullable
as double,repsError: null == repsError ? _self.repsError : repsError // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as String,trainingGoal: null == trainingGoal ? _self.trainingGoal : trainingGoal // ignore: cast_nullable_to_non_nullable
as String,wasHelpful: freezed == wasHelpful ? _self.wasHelpful : wasHelpful // ignore: cast_nullable_to_non_nullable
as bool?,perceivedExertion: freezed == perceivedExertion ? _self.perceivedExertion : perceivedExertion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestionAccuracy].
extension SuggestionAccuracyPatterns on SuggestionAccuracy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestionAccuracy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestionAccuracy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestionAccuracy value)  $default,){
final _that = this;
switch (_that) {
case _SuggestionAccuracy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestionAccuracy value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestionAccuracy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String exerciseId,  double suggestedWeight,  double actualWeight,  int suggestedReps,  int actualReps,  double weightErrorPercent,  int repsError,  DateTime timestamp,  String experienceLevel,  String trainingGoal,  bool? wasHelpful,  int? perceivedExertion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestionAccuracy() when $default != null:
return $default(_that.id,_that.userId,_that.exerciseId,_that.suggestedWeight,_that.actualWeight,_that.suggestedReps,_that.actualReps,_that.weightErrorPercent,_that.repsError,_that.timestamp,_that.experienceLevel,_that.trainingGoal,_that.wasHelpful,_that.perceivedExertion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String exerciseId,  double suggestedWeight,  double actualWeight,  int suggestedReps,  int actualReps,  double weightErrorPercent,  int repsError,  DateTime timestamp,  String experienceLevel,  String trainingGoal,  bool? wasHelpful,  int? perceivedExertion)  $default,) {final _that = this;
switch (_that) {
case _SuggestionAccuracy():
return $default(_that.id,_that.userId,_that.exerciseId,_that.suggestedWeight,_that.actualWeight,_that.suggestedReps,_that.actualReps,_that.weightErrorPercent,_that.repsError,_that.timestamp,_that.experienceLevel,_that.trainingGoal,_that.wasHelpful,_that.perceivedExertion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String exerciseId,  double suggestedWeight,  double actualWeight,  int suggestedReps,  int actualReps,  double weightErrorPercent,  int repsError,  DateTime timestamp,  String experienceLevel,  String trainingGoal,  bool? wasHelpful,  int? perceivedExertion)?  $default,) {final _that = this;
switch (_that) {
case _SuggestionAccuracy() when $default != null:
return $default(_that.id,_that.userId,_that.exerciseId,_that.suggestedWeight,_that.actualWeight,_that.suggestedReps,_that.actualReps,_that.weightErrorPercent,_that.repsError,_that.timestamp,_that.experienceLevel,_that.trainingGoal,_that.wasHelpful,_that.perceivedExertion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SuggestionAccuracy implements SuggestionAccuracy {
  const _SuggestionAccuracy({required this.id, required this.userId, required this.exerciseId, required this.suggestedWeight, required this.actualWeight, required this.suggestedReps, required this.actualReps, required this.weightErrorPercent, required this.repsError, required this.timestamp, required this.experienceLevel, required this.trainingGoal, this.wasHelpful, this.perceivedExertion});
  factory _SuggestionAccuracy.fromJson(Map<String, dynamic> json) => _$SuggestionAccuracyFromJson(json);

/// Unique ID for this record
@override final  String id;
/// User ID
@override final  String userId;
/// Exercise ID from GymBro database
@override final  String exerciseId;
/// Weight suggested by system (kg)
@override final  double suggestedWeight;
/// Weight actually used by user (kg)
@override final  double actualWeight;
/// Reps suggested by system
@override final  int suggestedReps;
/// Reps actually completed by user
@override final  int actualReps;
/// Absolute error percentage: |actual - suggested| / suggested * 100
@override final  double weightErrorPercent;
/// Reps error: actualReps - suggestedReps (can be negative)
@override final  int repsError;
/// Timestamp when set was performed
@override final  DateTime timestamp;
/// Experience level at time of suggestion
@override final  String experienceLevel;
/// Training goal at time of suggestion
@override final  String trainingGoal;
/// Whether user found suggestion helpful (optional feedback)
@override final  bool? wasHelpful;
/// User's perceived exertion (1-10 RPE scale)
@override final  int? perceivedExertion;

/// Create a copy of SuggestionAccuracy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestionAccuracyCopyWith<_SuggestionAccuracy> get copyWith => __$SuggestionAccuracyCopyWithImpl<_SuggestionAccuracy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestionAccuracyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestionAccuracy&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.actualWeight, actualWeight) || other.actualWeight == actualWeight)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.actualReps, actualReps) || other.actualReps == actualReps)&&(identical(other.weightErrorPercent, weightErrorPercent) || other.weightErrorPercent == weightErrorPercent)&&(identical(other.repsError, repsError) || other.repsError == repsError)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.trainingGoal, trainingGoal) || other.trainingGoal == trainingGoal)&&(identical(other.wasHelpful, wasHelpful) || other.wasHelpful == wasHelpful)&&(identical(other.perceivedExertion, perceivedExertion) || other.perceivedExertion == perceivedExertion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,exerciseId,suggestedWeight,actualWeight,suggestedReps,actualReps,weightErrorPercent,repsError,timestamp,experienceLevel,trainingGoal,wasHelpful,perceivedExertion);

@override
String toString() {
  return 'SuggestionAccuracy(id: $id, userId: $userId, exerciseId: $exerciseId, suggestedWeight: $suggestedWeight, actualWeight: $actualWeight, suggestedReps: $suggestedReps, actualReps: $actualReps, weightErrorPercent: $weightErrorPercent, repsError: $repsError, timestamp: $timestamp, experienceLevel: $experienceLevel, trainingGoal: $trainingGoal, wasHelpful: $wasHelpful, perceivedExertion: $perceivedExertion)';
}


}

/// @nodoc
abstract mixin class _$SuggestionAccuracyCopyWith<$Res> implements $SuggestionAccuracyCopyWith<$Res> {
  factory _$SuggestionAccuracyCopyWith(_SuggestionAccuracy value, $Res Function(_SuggestionAccuracy) _then) = __$SuggestionAccuracyCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String exerciseId, double suggestedWeight, double actualWeight, int suggestedReps, int actualReps, double weightErrorPercent, int repsError, DateTime timestamp, String experienceLevel, String trainingGoal, bool? wasHelpful, int? perceivedExertion
});




}
/// @nodoc
class __$SuggestionAccuracyCopyWithImpl<$Res>
    implements _$SuggestionAccuracyCopyWith<$Res> {
  __$SuggestionAccuracyCopyWithImpl(this._self, this._then);

  final _SuggestionAccuracy _self;
  final $Res Function(_SuggestionAccuracy) _then;

/// Create a copy of SuggestionAccuracy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? exerciseId = null,Object? suggestedWeight = null,Object? actualWeight = null,Object? suggestedReps = null,Object? actualReps = null,Object? weightErrorPercent = null,Object? repsError = null,Object? timestamp = null,Object? experienceLevel = null,Object? trainingGoal = null,Object? wasHelpful = freezed,Object? perceivedExertion = freezed,}) {
  return _then(_SuggestionAccuracy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,suggestedWeight: null == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double,actualWeight: null == actualWeight ? _self.actualWeight : actualWeight // ignore: cast_nullable_to_non_nullable
as double,suggestedReps: null == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int,actualReps: null == actualReps ? _self.actualReps : actualReps // ignore: cast_nullable_to_non_nullable
as int,weightErrorPercent: null == weightErrorPercent ? _self.weightErrorPercent : weightErrorPercent // ignore: cast_nullable_to_non_nullable
as double,repsError: null == repsError ? _self.repsError : repsError // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,experienceLevel: null == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as String,trainingGoal: null == trainingGoal ? _self.trainingGoal : trainingGoal // ignore: cast_nullable_to_non_nullable
as String,wasHelpful: freezed == wasHelpful ? _self.wasHelpful : wasHelpful // ignore: cast_nullable_to_non_nullable
as bool?,perceivedExertion: freezed == perceivedExertion ? _self.perceivedExertion : perceivedExertion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
