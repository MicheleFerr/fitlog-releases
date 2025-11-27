// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_progress_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExerciseProgressMetrics {

 String get exerciseName; int get totalSessions; double get maxWeight; double get averageWeight; double get averageReps; double get averageRPE; double get totalVolume; DateTime get lastWorkoutDate; TrendDirection get weightTrend; TrendDirection get volumeTrend; List<ExerciseSetData> get allSets;
/// Create a copy of ExerciseProgressMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseProgressMetricsCopyWith<ExerciseProgressMetrics> get copyWith => _$ExerciseProgressMetricsCopyWithImpl<ExerciseProgressMetrics>(this as ExerciseProgressMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseProgressMetrics&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.averageWeight, averageWeight) || other.averageWeight == averageWeight)&&(identical(other.averageReps, averageReps) || other.averageReps == averageReps)&&(identical(other.averageRPE, averageRPE) || other.averageRPE == averageRPE)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.weightTrend, weightTrend) || other.weightTrend == weightTrend)&&(identical(other.volumeTrend, volumeTrend) || other.volumeTrend == volumeTrend)&&const DeepCollectionEquality().equals(other.allSets, allSets));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,totalSessions,maxWeight,averageWeight,averageReps,averageRPE,totalVolume,lastWorkoutDate,weightTrend,volumeTrend,const DeepCollectionEquality().hash(allSets));

@override
String toString() {
  return 'ExerciseProgressMetrics(exerciseName: $exerciseName, totalSessions: $totalSessions, maxWeight: $maxWeight, averageWeight: $averageWeight, averageReps: $averageReps, averageRPE: $averageRPE, totalVolume: $totalVolume, lastWorkoutDate: $lastWorkoutDate, weightTrend: $weightTrend, volumeTrend: $volumeTrend, allSets: $allSets)';
}


}

/// @nodoc
abstract mixin class $ExerciseProgressMetricsCopyWith<$Res>  {
  factory $ExerciseProgressMetricsCopyWith(ExerciseProgressMetrics value, $Res Function(ExerciseProgressMetrics) _then) = _$ExerciseProgressMetricsCopyWithImpl;
@useResult
$Res call({
 String exerciseName, int totalSessions, double maxWeight, double averageWeight, double averageReps, double averageRPE, double totalVolume, DateTime lastWorkoutDate, TrendDirection weightTrend, TrendDirection volumeTrend, List<ExerciseSetData> allSets
});




}
/// @nodoc
class _$ExerciseProgressMetricsCopyWithImpl<$Res>
    implements $ExerciseProgressMetricsCopyWith<$Res> {
  _$ExerciseProgressMetricsCopyWithImpl(this._self, this._then);

  final ExerciseProgressMetrics _self;
  final $Res Function(ExerciseProgressMetrics) _then;

/// Create a copy of ExerciseProgressMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? totalSessions = null,Object? maxWeight = null,Object? averageWeight = null,Object? averageReps = null,Object? averageRPE = null,Object? totalVolume = null,Object? lastWorkoutDate = null,Object? weightTrend = null,Object? volumeTrend = null,Object? allSets = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,averageWeight: null == averageWeight ? _self.averageWeight : averageWeight // ignore: cast_nullable_to_non_nullable
as double,averageReps: null == averageReps ? _self.averageReps : averageReps // ignore: cast_nullable_to_non_nullable
as double,averageRPE: null == averageRPE ? _self.averageRPE : averageRPE // ignore: cast_nullable_to_non_nullable
as double,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,lastWorkoutDate: null == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,weightTrend: null == weightTrend ? _self.weightTrend : weightTrend // ignore: cast_nullable_to_non_nullable
as TrendDirection,volumeTrend: null == volumeTrend ? _self.volumeTrend : volumeTrend // ignore: cast_nullable_to_non_nullable
as TrendDirection,allSets: null == allSets ? _self.allSets : allSets // ignore: cast_nullable_to_non_nullable
as List<ExerciseSetData>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseProgressMetrics].
extension ExerciseProgressMetricsPatterns on ExerciseProgressMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseProgressMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseProgressMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseProgressMetrics value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseProgressMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseProgressMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseProgressMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  int totalSessions,  double maxWeight,  double averageWeight,  double averageReps,  double averageRPE,  double totalVolume,  DateTime lastWorkoutDate,  TrendDirection weightTrend,  TrendDirection volumeTrend,  List<ExerciseSetData> allSets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseProgressMetrics() when $default != null:
return $default(_that.exerciseName,_that.totalSessions,_that.maxWeight,_that.averageWeight,_that.averageReps,_that.averageRPE,_that.totalVolume,_that.lastWorkoutDate,_that.weightTrend,_that.volumeTrend,_that.allSets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  int totalSessions,  double maxWeight,  double averageWeight,  double averageReps,  double averageRPE,  double totalVolume,  DateTime lastWorkoutDate,  TrendDirection weightTrend,  TrendDirection volumeTrend,  List<ExerciseSetData> allSets)  $default,) {final _that = this;
switch (_that) {
case _ExerciseProgressMetrics():
return $default(_that.exerciseName,_that.totalSessions,_that.maxWeight,_that.averageWeight,_that.averageReps,_that.averageRPE,_that.totalVolume,_that.lastWorkoutDate,_that.weightTrend,_that.volumeTrend,_that.allSets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  int totalSessions,  double maxWeight,  double averageWeight,  double averageReps,  double averageRPE,  double totalVolume,  DateTime lastWorkoutDate,  TrendDirection weightTrend,  TrendDirection volumeTrend,  List<ExerciseSetData> allSets)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseProgressMetrics() when $default != null:
return $default(_that.exerciseName,_that.totalSessions,_that.maxWeight,_that.averageWeight,_that.averageReps,_that.averageRPE,_that.totalVolume,_that.lastWorkoutDate,_that.weightTrend,_that.volumeTrend,_that.allSets);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseProgressMetrics extends ExerciseProgressMetrics {
  const _ExerciseProgressMetrics({required this.exerciseName, required this.totalSessions, required this.maxWeight, required this.averageWeight, required this.averageReps, required this.averageRPE, required this.totalVolume, required this.lastWorkoutDate, required this.weightTrend, required this.volumeTrend, required final  List<ExerciseSetData> allSets}): _allSets = allSets,super._();
  

@override final  String exerciseName;
@override final  int totalSessions;
@override final  double maxWeight;
@override final  double averageWeight;
@override final  double averageReps;
@override final  double averageRPE;
@override final  double totalVolume;
@override final  DateTime lastWorkoutDate;
@override final  TrendDirection weightTrend;
@override final  TrendDirection volumeTrend;
 final  List<ExerciseSetData> _allSets;
@override List<ExerciseSetData> get allSets {
  if (_allSets is EqualUnmodifiableListView) return _allSets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allSets);
}


/// Create a copy of ExerciseProgressMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseProgressMetricsCopyWith<_ExerciseProgressMetrics> get copyWith => __$ExerciseProgressMetricsCopyWithImpl<_ExerciseProgressMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseProgressMetrics&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.averageWeight, averageWeight) || other.averageWeight == averageWeight)&&(identical(other.averageReps, averageReps) || other.averageReps == averageReps)&&(identical(other.averageRPE, averageRPE) || other.averageRPE == averageRPE)&&(identical(other.totalVolume, totalVolume) || other.totalVolume == totalVolume)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.weightTrend, weightTrend) || other.weightTrend == weightTrend)&&(identical(other.volumeTrend, volumeTrend) || other.volumeTrend == volumeTrend)&&const DeepCollectionEquality().equals(other._allSets, _allSets));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,totalSessions,maxWeight,averageWeight,averageReps,averageRPE,totalVolume,lastWorkoutDate,weightTrend,volumeTrend,const DeepCollectionEquality().hash(_allSets));

@override
String toString() {
  return 'ExerciseProgressMetrics(exerciseName: $exerciseName, totalSessions: $totalSessions, maxWeight: $maxWeight, averageWeight: $averageWeight, averageReps: $averageReps, averageRPE: $averageRPE, totalVolume: $totalVolume, lastWorkoutDate: $lastWorkoutDate, weightTrend: $weightTrend, volumeTrend: $volumeTrend, allSets: $allSets)';
}


}

/// @nodoc
abstract mixin class _$ExerciseProgressMetricsCopyWith<$Res> implements $ExerciseProgressMetricsCopyWith<$Res> {
  factory _$ExerciseProgressMetricsCopyWith(_ExerciseProgressMetrics value, $Res Function(_ExerciseProgressMetrics) _then) = __$ExerciseProgressMetricsCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, int totalSessions, double maxWeight, double averageWeight, double averageReps, double averageRPE, double totalVolume, DateTime lastWorkoutDate, TrendDirection weightTrend, TrendDirection volumeTrend, List<ExerciseSetData> allSets
});




}
/// @nodoc
class __$ExerciseProgressMetricsCopyWithImpl<$Res>
    implements _$ExerciseProgressMetricsCopyWith<$Res> {
  __$ExerciseProgressMetricsCopyWithImpl(this._self, this._then);

  final _ExerciseProgressMetrics _self;
  final $Res Function(_ExerciseProgressMetrics) _then;

/// Create a copy of ExerciseProgressMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? totalSessions = null,Object? maxWeight = null,Object? averageWeight = null,Object? averageReps = null,Object? averageRPE = null,Object? totalVolume = null,Object? lastWorkoutDate = null,Object? weightTrend = null,Object? volumeTrend = null,Object? allSets = null,}) {
  return _then(_ExerciseProgressMetrics(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,averageWeight: null == averageWeight ? _self.averageWeight : averageWeight // ignore: cast_nullable_to_non_nullable
as double,averageReps: null == averageReps ? _self.averageReps : averageReps // ignore: cast_nullable_to_non_nullable
as double,averageRPE: null == averageRPE ? _self.averageRPE : averageRPE // ignore: cast_nullable_to_non_nullable
as double,totalVolume: null == totalVolume ? _self.totalVolume : totalVolume // ignore: cast_nullable_to_non_nullable
as double,lastWorkoutDate: null == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,weightTrend: null == weightTrend ? _self.weightTrend : weightTrend // ignore: cast_nullable_to_non_nullable
as TrendDirection,volumeTrend: null == volumeTrend ? _self.volumeTrend : volumeTrend // ignore: cast_nullable_to_non_nullable
as TrendDirection,allSets: null == allSets ? _self._allSets : allSets // ignore: cast_nullable_to_non_nullable
as List<ExerciseSetData>,
  ));
}


}

/// @nodoc
mixin _$ExerciseSetData {

 DateTime get date; double get weight; int get reps; int? get rpe; double get volume; String get workoutName;
/// Create a copy of ExerciseSetData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseSetDataCopyWith<ExerciseSetData> get copyWith => _$ExerciseSetDataCopyWithImpl<ExerciseSetData>(this as ExerciseSetData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseSetData&&(identical(other.date, date) || other.date == date)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName));
}


@override
int get hashCode => Object.hash(runtimeType,date,weight,reps,rpe,volume,workoutName);

@override
String toString() {
  return 'ExerciseSetData(date: $date, weight: $weight, reps: $reps, rpe: $rpe, volume: $volume, workoutName: $workoutName)';
}


}

/// @nodoc
abstract mixin class $ExerciseSetDataCopyWith<$Res>  {
  factory $ExerciseSetDataCopyWith(ExerciseSetData value, $Res Function(ExerciseSetData) _then) = _$ExerciseSetDataCopyWithImpl;
@useResult
$Res call({
 DateTime date, double weight, int reps, int? rpe, double volume, String workoutName
});




}
/// @nodoc
class _$ExerciseSetDataCopyWithImpl<$Res>
    implements $ExerciseSetDataCopyWith<$Res> {
  _$ExerciseSetDataCopyWithImpl(this._self, this._then);

  final ExerciseSetData _self;
  final $Res Function(ExerciseSetData) _then;

/// Create a copy of ExerciseSetData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? weight = null,Object? reps = null,Object? rpe = freezed,Object? volume = null,Object? workoutName = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseSetData].
extension ExerciseSetDataPatterns on ExerciseSetData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseSetData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseSetData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseSetData value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseSetData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseSetData value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseSetData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double weight,  int reps,  int? rpe,  double volume,  String workoutName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseSetData() when $default != null:
return $default(_that.date,_that.weight,_that.reps,_that.rpe,_that.volume,_that.workoutName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double weight,  int reps,  int? rpe,  double volume,  String workoutName)  $default,) {final _that = this;
switch (_that) {
case _ExerciseSetData():
return $default(_that.date,_that.weight,_that.reps,_that.rpe,_that.volume,_that.workoutName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double weight,  int reps,  int? rpe,  double volume,  String workoutName)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseSetData() when $default != null:
return $default(_that.date,_that.weight,_that.reps,_that.rpe,_that.volume,_that.workoutName);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseSetData implements ExerciseSetData {
  const _ExerciseSetData({required this.date, required this.weight, required this.reps, required this.rpe, required this.volume, required this.workoutName});
  

@override final  DateTime date;
@override final  double weight;
@override final  int reps;
@override final  int? rpe;
@override final  double volume;
@override final  String workoutName;

/// Create a copy of ExerciseSetData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseSetDataCopyWith<_ExerciseSetData> get copyWith => __$ExerciseSetDataCopyWithImpl<_ExerciseSetData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseSetData&&(identical(other.date, date) || other.date == date)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName));
}


@override
int get hashCode => Object.hash(runtimeType,date,weight,reps,rpe,volume,workoutName);

@override
String toString() {
  return 'ExerciseSetData(date: $date, weight: $weight, reps: $reps, rpe: $rpe, volume: $volume, workoutName: $workoutName)';
}


}

/// @nodoc
abstract mixin class _$ExerciseSetDataCopyWith<$Res> implements $ExerciseSetDataCopyWith<$Res> {
  factory _$ExerciseSetDataCopyWith(_ExerciseSetData value, $Res Function(_ExerciseSetData) _then) = __$ExerciseSetDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double weight, int reps, int? rpe, double volume, String workoutName
});




}
/// @nodoc
class __$ExerciseSetDataCopyWithImpl<$Res>
    implements _$ExerciseSetDataCopyWith<$Res> {
  __$ExerciseSetDataCopyWithImpl(this._self, this._then);

  final _ExerciseSetData _self;
  final $Res Function(_ExerciseSetData) _then;

/// Create a copy of ExerciseSetData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? weight = null,Object? reps = null,Object? rpe = freezed,Object? volume = null,Object? workoutName = null,}) {
  return _then(_ExerciseSetData(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,workoutName: null == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
