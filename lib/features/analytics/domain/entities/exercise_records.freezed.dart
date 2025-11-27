// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_records.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseRecords {

/// Exercise name (matches ExerciseHistory.exerciseName)
 String get exerciseName;/// Personal Records
 double get maxWeightRecord;// Heaviest single set weight (kg)
 double get estimated1RM;// Estimated 1 rep max (Epley formula)
 double get totalVolumeRecord;// Highest single-workout volume (kg)
 int get totalSetsRecord;// Most sets in single workout
/// Recent Activity
 DateTime get lastWorkoutDate;// Most recent workout date
 double get weeklyFrequency;// Avg workouts per week (last 4 weeks)
/// Time Range
 DateTime get firstWorkoutDate;// First recorded workout
 int get totalWorkouts;
/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseRecordsCopyWith<ExerciseRecords> get copyWith => _$ExerciseRecordsCopyWithImpl<ExerciseRecords>(this as ExerciseRecords, _$identity);

  /// Serializes this ExerciseRecords to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseRecords&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.maxWeightRecord, maxWeightRecord) || other.maxWeightRecord == maxWeightRecord)&&(identical(other.estimated1RM, estimated1RM) || other.estimated1RM == estimated1RM)&&(identical(other.totalVolumeRecord, totalVolumeRecord) || other.totalVolumeRecord == totalVolumeRecord)&&(identical(other.totalSetsRecord, totalSetsRecord) || other.totalSetsRecord == totalSetsRecord)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.weeklyFrequency, weeklyFrequency) || other.weeklyFrequency == weeklyFrequency)&&(identical(other.firstWorkoutDate, firstWorkoutDate) || other.firstWorkoutDate == firstWorkoutDate)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,maxWeightRecord,estimated1RM,totalVolumeRecord,totalSetsRecord,lastWorkoutDate,weeklyFrequency,firstWorkoutDate,totalWorkouts);

@override
String toString() {
  return 'ExerciseRecords(exerciseName: $exerciseName, maxWeightRecord: $maxWeightRecord, estimated1RM: $estimated1RM, totalVolumeRecord: $totalVolumeRecord, totalSetsRecord: $totalSetsRecord, lastWorkoutDate: $lastWorkoutDate, weeklyFrequency: $weeklyFrequency, firstWorkoutDate: $firstWorkoutDate, totalWorkouts: $totalWorkouts)';
}


}

/// @nodoc
abstract mixin class $ExerciseRecordsCopyWith<$Res>  {
  factory $ExerciseRecordsCopyWith(ExerciseRecords value, $Res Function(ExerciseRecords) _then) = _$ExerciseRecordsCopyWithImpl;
@useResult
$Res call({
 String exerciseName, double maxWeightRecord, double estimated1RM, double totalVolumeRecord, int totalSetsRecord, DateTime lastWorkoutDate, double weeklyFrequency, DateTime firstWorkoutDate, int totalWorkouts
});




}
/// @nodoc
class _$ExerciseRecordsCopyWithImpl<$Res>
    implements $ExerciseRecordsCopyWith<$Res> {
  _$ExerciseRecordsCopyWithImpl(this._self, this._then);

  final ExerciseRecords _self;
  final $Res Function(ExerciseRecords) _then;

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? maxWeightRecord = null,Object? estimated1RM = null,Object? totalVolumeRecord = null,Object? totalSetsRecord = null,Object? lastWorkoutDate = null,Object? weeklyFrequency = null,Object? firstWorkoutDate = null,Object? totalWorkouts = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,maxWeightRecord: null == maxWeightRecord ? _self.maxWeightRecord : maxWeightRecord // ignore: cast_nullable_to_non_nullable
as double,estimated1RM: null == estimated1RM ? _self.estimated1RM : estimated1RM // ignore: cast_nullable_to_non_nullable
as double,totalVolumeRecord: null == totalVolumeRecord ? _self.totalVolumeRecord : totalVolumeRecord // ignore: cast_nullable_to_non_nullable
as double,totalSetsRecord: null == totalSetsRecord ? _self.totalSetsRecord : totalSetsRecord // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: null == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,weeklyFrequency: null == weeklyFrequency ? _self.weeklyFrequency : weeklyFrequency // ignore: cast_nullable_to_non_nullable
as double,firstWorkoutDate: null == firstWorkoutDate ? _self.firstWorkoutDate : firstWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseRecords].
extension ExerciseRecordsPatterns on ExerciseRecords {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseRecords value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseRecords value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseRecords():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseRecords value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  double maxWeightRecord,  double estimated1RM,  double totalVolumeRecord,  int totalSetsRecord,  DateTime lastWorkoutDate,  double weeklyFrequency,  DateTime firstWorkoutDate,  int totalWorkouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
return $default(_that.exerciseName,_that.maxWeightRecord,_that.estimated1RM,_that.totalVolumeRecord,_that.totalSetsRecord,_that.lastWorkoutDate,_that.weeklyFrequency,_that.firstWorkoutDate,_that.totalWorkouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  double maxWeightRecord,  double estimated1RM,  double totalVolumeRecord,  int totalSetsRecord,  DateTime lastWorkoutDate,  double weeklyFrequency,  DateTime firstWorkoutDate,  int totalWorkouts)  $default,) {final _that = this;
switch (_that) {
case _ExerciseRecords():
return $default(_that.exerciseName,_that.maxWeightRecord,_that.estimated1RM,_that.totalVolumeRecord,_that.totalSetsRecord,_that.lastWorkoutDate,_that.weeklyFrequency,_that.firstWorkoutDate,_that.totalWorkouts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  double maxWeightRecord,  double estimated1RM,  double totalVolumeRecord,  int totalSetsRecord,  DateTime lastWorkoutDate,  double weeklyFrequency,  DateTime firstWorkoutDate,  int totalWorkouts)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseRecords() when $default != null:
return $default(_that.exerciseName,_that.maxWeightRecord,_that.estimated1RM,_that.totalVolumeRecord,_that.totalSetsRecord,_that.lastWorkoutDate,_that.weeklyFrequency,_that.firstWorkoutDate,_that.totalWorkouts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseRecords implements ExerciseRecords {
  const _ExerciseRecords({required this.exerciseName, required this.maxWeightRecord, required this.estimated1RM, required this.totalVolumeRecord, required this.totalSetsRecord, required this.lastWorkoutDate, required this.weeklyFrequency, required this.firstWorkoutDate, required this.totalWorkouts});
  factory _ExerciseRecords.fromJson(Map<String, dynamic> json) => _$ExerciseRecordsFromJson(json);

/// Exercise name (matches ExerciseHistory.exerciseName)
@override final  String exerciseName;
/// Personal Records
@override final  double maxWeightRecord;
// Heaviest single set weight (kg)
@override final  double estimated1RM;
// Estimated 1 rep max (Epley formula)
@override final  double totalVolumeRecord;
// Highest single-workout volume (kg)
@override final  int totalSetsRecord;
// Most sets in single workout
/// Recent Activity
@override final  DateTime lastWorkoutDate;
// Most recent workout date
@override final  double weeklyFrequency;
// Avg workouts per week (last 4 weeks)
/// Time Range
@override final  DateTime firstWorkoutDate;
// First recorded workout
@override final  int totalWorkouts;

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseRecordsCopyWith<_ExerciseRecords> get copyWith => __$ExerciseRecordsCopyWithImpl<_ExerciseRecords>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseRecordsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseRecords&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.maxWeightRecord, maxWeightRecord) || other.maxWeightRecord == maxWeightRecord)&&(identical(other.estimated1RM, estimated1RM) || other.estimated1RM == estimated1RM)&&(identical(other.totalVolumeRecord, totalVolumeRecord) || other.totalVolumeRecord == totalVolumeRecord)&&(identical(other.totalSetsRecord, totalSetsRecord) || other.totalSetsRecord == totalSetsRecord)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.weeklyFrequency, weeklyFrequency) || other.weeklyFrequency == weeklyFrequency)&&(identical(other.firstWorkoutDate, firstWorkoutDate) || other.firstWorkoutDate == firstWorkoutDate)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,maxWeightRecord,estimated1RM,totalVolumeRecord,totalSetsRecord,lastWorkoutDate,weeklyFrequency,firstWorkoutDate,totalWorkouts);

@override
String toString() {
  return 'ExerciseRecords(exerciseName: $exerciseName, maxWeightRecord: $maxWeightRecord, estimated1RM: $estimated1RM, totalVolumeRecord: $totalVolumeRecord, totalSetsRecord: $totalSetsRecord, lastWorkoutDate: $lastWorkoutDate, weeklyFrequency: $weeklyFrequency, firstWorkoutDate: $firstWorkoutDate, totalWorkouts: $totalWorkouts)';
}


}

/// @nodoc
abstract mixin class _$ExerciseRecordsCopyWith<$Res> implements $ExerciseRecordsCopyWith<$Res> {
  factory _$ExerciseRecordsCopyWith(_ExerciseRecords value, $Res Function(_ExerciseRecords) _then) = __$ExerciseRecordsCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, double maxWeightRecord, double estimated1RM, double totalVolumeRecord, int totalSetsRecord, DateTime lastWorkoutDate, double weeklyFrequency, DateTime firstWorkoutDate, int totalWorkouts
});




}
/// @nodoc
class __$ExerciseRecordsCopyWithImpl<$Res>
    implements _$ExerciseRecordsCopyWith<$Res> {
  __$ExerciseRecordsCopyWithImpl(this._self, this._then);

  final _ExerciseRecords _self;
  final $Res Function(_ExerciseRecords) _then;

/// Create a copy of ExerciseRecords
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? maxWeightRecord = null,Object? estimated1RM = null,Object? totalVolumeRecord = null,Object? totalSetsRecord = null,Object? lastWorkoutDate = null,Object? weeklyFrequency = null,Object? firstWorkoutDate = null,Object? totalWorkouts = null,}) {
  return _then(_ExerciseRecords(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,maxWeightRecord: null == maxWeightRecord ? _self.maxWeightRecord : maxWeightRecord // ignore: cast_nullable_to_non_nullable
as double,estimated1RM: null == estimated1RM ? _self.estimated1RM : estimated1RM // ignore: cast_nullable_to_non_nullable
as double,totalVolumeRecord: null == totalVolumeRecord ? _self.totalVolumeRecord : totalVolumeRecord // ignore: cast_nullable_to_non_nullable
as double,totalSetsRecord: null == totalSetsRecord ? _self.totalSetsRecord : totalSetsRecord // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: null == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,weeklyFrequency: null == weeklyFrequency ? _self.weeklyFrequency : weeklyFrequency // ignore: cast_nullable_to_non_nullable
as double,firstWorkoutDate: null == firstWorkoutDate ? _self.firstWorkoutDate : firstWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
