// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_execution_timing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetExecutionTiming {

 String get id; String get exerciseId; String get workoutId; int get setNumber;// Timing precision data (milliseconds)
 int get executionTimeMs; DateTime get startTime; DateTime get endTime;// Performance metrics
 int get reps; double? get weight; int get rpe;// Rate of Perceived Exertion
// Advanced timing analysis
 List<int> get repTimingsMs;// Individual rep timings
 List<double> get velocityMps;// Velocity per rep (m/s)
 List<int> get pauseTimingsMs;// Pauses between reps
// Quality indicators
 double get formScore;// 0-100 based on video analysis
 double get consistencyScore;// 0-100 based on rep variation
 double get fatigueIndex;// 0-100 calculated fatigue
// Environmental data
 DateTime? get restStartedAt; int? get restDurationMs; double get heartRateBpm; double get ambientTemperatureC;// Synchronization
 DateTime get createdAt; DateTime? get uploadedAt; bool get synced;// Metadata
 Map<String, dynamic>? get metadata;
/// Create a copy of SetExecutionTiming
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetExecutionTimingCopyWith<SetExecutionTiming> get copyWith => _$SetExecutionTimingCopyWithImpl<SetExecutionTiming>(this as SetExecutionTiming, _$identity);

  /// Serializes this SetExecutionTiming to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetExecutionTiming&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.executionTimeMs, executionTimeMs) || other.executionTimeMs == executionTimeMs)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&const DeepCollectionEquality().equals(other.repTimingsMs, repTimingsMs)&&const DeepCollectionEquality().equals(other.velocityMps, velocityMps)&&const DeepCollectionEquality().equals(other.pauseTimingsMs, pauseTimingsMs)&&(identical(other.formScore, formScore) || other.formScore == formScore)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore)&&(identical(other.fatigueIndex, fatigueIndex) || other.fatigueIndex == fatigueIndex)&&(identical(other.restStartedAt, restStartedAt) || other.restStartedAt == restStartedAt)&&(identical(other.restDurationMs, restDurationMs) || other.restDurationMs == restDurationMs)&&(identical(other.heartRateBpm, heartRateBpm) || other.heartRateBpm == heartRateBpm)&&(identical(other.ambientTemperatureC, ambientTemperatureC) || other.ambientTemperatureC == ambientTemperatureC)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.synced, synced) || other.synced == synced)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,workoutId,setNumber,executionTimeMs,startTime,endTime,reps,weight,rpe,const DeepCollectionEquality().hash(repTimingsMs),const DeepCollectionEquality().hash(velocityMps),const DeepCollectionEquality().hash(pauseTimingsMs),formScore,consistencyScore,fatigueIndex,restStartedAt,restDurationMs,heartRateBpm,ambientTemperatureC,createdAt,uploadedAt,synced,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'SetExecutionTiming(id: $id, exerciseId: $exerciseId, workoutId: $workoutId, setNumber: $setNumber, executionTimeMs: $executionTimeMs, startTime: $startTime, endTime: $endTime, reps: $reps, weight: $weight, rpe: $rpe, repTimingsMs: $repTimingsMs, velocityMps: $velocityMps, pauseTimingsMs: $pauseTimingsMs, formScore: $formScore, consistencyScore: $consistencyScore, fatigueIndex: $fatigueIndex, restStartedAt: $restStartedAt, restDurationMs: $restDurationMs, heartRateBpm: $heartRateBpm, ambientTemperatureC: $ambientTemperatureC, createdAt: $createdAt, uploadedAt: $uploadedAt, synced: $synced, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $SetExecutionTimingCopyWith<$Res>  {
  factory $SetExecutionTimingCopyWith(SetExecutionTiming value, $Res Function(SetExecutionTiming) _then) = _$SetExecutionTimingCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String workoutId, int setNumber, int executionTimeMs, DateTime startTime, DateTime endTime, int reps, double? weight, int rpe, List<int> repTimingsMs, List<double> velocityMps, List<int> pauseTimingsMs, double formScore, double consistencyScore, double fatigueIndex, DateTime? restStartedAt, int? restDurationMs, double heartRateBpm, double ambientTemperatureC, DateTime createdAt, DateTime? uploadedAt, bool synced, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$SetExecutionTimingCopyWithImpl<$Res>
    implements $SetExecutionTimingCopyWith<$Res> {
  _$SetExecutionTimingCopyWithImpl(this._self, this._then);

  final SetExecutionTiming _self;
  final $Res Function(SetExecutionTiming) _then;

/// Create a copy of SetExecutionTiming
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? workoutId = null,Object? setNumber = null,Object? executionTimeMs = null,Object? startTime = null,Object? endTime = null,Object? reps = null,Object? weight = freezed,Object? rpe = null,Object? repTimingsMs = null,Object? velocityMps = null,Object? pauseTimingsMs = null,Object? formScore = null,Object? consistencyScore = null,Object? fatigueIndex = null,Object? restStartedAt = freezed,Object? restDurationMs = freezed,Object? heartRateBpm = null,Object? ambientTemperatureC = null,Object? createdAt = null,Object? uploadedAt = freezed,Object? synced = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,executionTimeMs: null == executionTimeMs ? _self.executionTimeMs : executionTimeMs // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,rpe: null == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int,repTimingsMs: null == repTimingsMs ? _self.repTimingsMs : repTimingsMs // ignore: cast_nullable_to_non_nullable
as List<int>,velocityMps: null == velocityMps ? _self.velocityMps : velocityMps // ignore: cast_nullable_to_non_nullable
as List<double>,pauseTimingsMs: null == pauseTimingsMs ? _self.pauseTimingsMs : pauseTimingsMs // ignore: cast_nullable_to_non_nullable
as List<int>,formScore: null == formScore ? _self.formScore : formScore // ignore: cast_nullable_to_non_nullable
as double,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as double,fatigueIndex: null == fatigueIndex ? _self.fatigueIndex : fatigueIndex // ignore: cast_nullable_to_non_nullable
as double,restStartedAt: freezed == restStartedAt ? _self.restStartedAt : restStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restDurationMs: freezed == restDurationMs ? _self.restDurationMs : restDurationMs // ignore: cast_nullable_to_non_nullable
as int?,heartRateBpm: null == heartRateBpm ? _self.heartRateBpm : heartRateBpm // ignore: cast_nullable_to_non_nullable
as double,ambientTemperatureC: null == ambientTemperatureC ? _self.ambientTemperatureC : ambientTemperatureC // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetExecutionTiming].
extension SetExecutionTimingPatterns on SetExecutionTiming {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetExecutionTiming value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetExecutionTiming() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetExecutionTiming value)  $default,){
final _that = this;
switch (_that) {
case _SetExecutionTiming():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetExecutionTiming value)?  $default,){
final _that = this;
switch (_that) {
case _SetExecutionTiming() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String workoutId,  int setNumber,  int executionTimeMs,  DateTime startTime,  DateTime endTime,  int reps,  double? weight,  int rpe,  List<int> repTimingsMs,  List<double> velocityMps,  List<int> pauseTimingsMs,  double formScore,  double consistencyScore,  double fatigueIndex,  DateTime? restStartedAt,  int? restDurationMs,  double heartRateBpm,  double ambientTemperatureC,  DateTime createdAt,  DateTime? uploadedAt,  bool synced,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetExecutionTiming() when $default != null:
return $default(_that.id,_that.exerciseId,_that.workoutId,_that.setNumber,_that.executionTimeMs,_that.startTime,_that.endTime,_that.reps,_that.weight,_that.rpe,_that.repTimingsMs,_that.velocityMps,_that.pauseTimingsMs,_that.formScore,_that.consistencyScore,_that.fatigueIndex,_that.restStartedAt,_that.restDurationMs,_that.heartRateBpm,_that.ambientTemperatureC,_that.createdAt,_that.uploadedAt,_that.synced,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String workoutId,  int setNumber,  int executionTimeMs,  DateTime startTime,  DateTime endTime,  int reps,  double? weight,  int rpe,  List<int> repTimingsMs,  List<double> velocityMps,  List<int> pauseTimingsMs,  double formScore,  double consistencyScore,  double fatigueIndex,  DateTime? restStartedAt,  int? restDurationMs,  double heartRateBpm,  double ambientTemperatureC,  DateTime createdAt,  DateTime? uploadedAt,  bool synced,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _SetExecutionTiming():
return $default(_that.id,_that.exerciseId,_that.workoutId,_that.setNumber,_that.executionTimeMs,_that.startTime,_that.endTime,_that.reps,_that.weight,_that.rpe,_that.repTimingsMs,_that.velocityMps,_that.pauseTimingsMs,_that.formScore,_that.consistencyScore,_that.fatigueIndex,_that.restStartedAt,_that.restDurationMs,_that.heartRateBpm,_that.ambientTemperatureC,_that.createdAt,_that.uploadedAt,_that.synced,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String workoutId,  int setNumber,  int executionTimeMs,  DateTime startTime,  DateTime endTime,  int reps,  double? weight,  int rpe,  List<int> repTimingsMs,  List<double> velocityMps,  List<int> pauseTimingsMs,  double formScore,  double consistencyScore,  double fatigueIndex,  DateTime? restStartedAt,  int? restDurationMs,  double heartRateBpm,  double ambientTemperatureC,  DateTime createdAt,  DateTime? uploadedAt,  bool synced,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _SetExecutionTiming() when $default != null:
return $default(_that.id,_that.exerciseId,_that.workoutId,_that.setNumber,_that.executionTimeMs,_that.startTime,_that.endTime,_that.reps,_that.weight,_that.rpe,_that.repTimingsMs,_that.velocityMps,_that.pauseTimingsMs,_that.formScore,_that.consistencyScore,_that.fatigueIndex,_that.restStartedAt,_that.restDurationMs,_that.heartRateBpm,_that.ambientTemperatureC,_that.createdAt,_that.uploadedAt,_that.synced,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetExecutionTiming implements SetExecutionTiming {
  const _SetExecutionTiming({required this.id, required this.exerciseId, required this.workoutId, required this.setNumber, required this.executionTimeMs, required this.startTime, required this.endTime, this.reps = 0, this.weight, this.rpe = 0, final  List<int> repTimingsMs = const [], final  List<double> velocityMps = const [], final  List<int> pauseTimingsMs = const [], this.formScore = 0.0, this.consistencyScore = 0.0, this.fatigueIndex = 0.0, this.restStartedAt, this.restDurationMs, this.heartRateBpm = 0.0, this.ambientTemperatureC = 0.0, required this.createdAt, this.uploadedAt, this.synced = false, final  Map<String, dynamic>? metadata}): _repTimingsMs = repTimingsMs,_velocityMps = velocityMps,_pauseTimingsMs = pauseTimingsMs,_metadata = metadata;
  factory _SetExecutionTiming.fromJson(Map<String, dynamic> json) => _$SetExecutionTimingFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  String workoutId;
@override final  int setNumber;
// Timing precision data (milliseconds)
@override final  int executionTimeMs;
@override final  DateTime startTime;
@override final  DateTime endTime;
// Performance metrics
@override@JsonKey() final  int reps;
@override final  double? weight;
@override@JsonKey() final  int rpe;
// Rate of Perceived Exertion
// Advanced timing analysis
 final  List<int> _repTimingsMs;
// Rate of Perceived Exertion
// Advanced timing analysis
@override@JsonKey() List<int> get repTimingsMs {
  if (_repTimingsMs is EqualUnmodifiableListView) return _repTimingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_repTimingsMs);
}

// Individual rep timings
 final  List<double> _velocityMps;
// Individual rep timings
@override@JsonKey() List<double> get velocityMps {
  if (_velocityMps is EqualUnmodifiableListView) return _velocityMps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_velocityMps);
}

// Velocity per rep (m/s)
 final  List<int> _pauseTimingsMs;
// Velocity per rep (m/s)
@override@JsonKey() List<int> get pauseTimingsMs {
  if (_pauseTimingsMs is EqualUnmodifiableListView) return _pauseTimingsMs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pauseTimingsMs);
}

// Pauses between reps
// Quality indicators
@override@JsonKey() final  double formScore;
// 0-100 based on video analysis
@override@JsonKey() final  double consistencyScore;
// 0-100 based on rep variation
@override@JsonKey() final  double fatigueIndex;
// 0-100 calculated fatigue
// Environmental data
@override final  DateTime? restStartedAt;
@override final  int? restDurationMs;
@override@JsonKey() final  double heartRateBpm;
@override@JsonKey() final  double ambientTemperatureC;
// Synchronization
@override final  DateTime createdAt;
@override final  DateTime? uploadedAt;
@override@JsonKey() final  bool synced;
// Metadata
 final  Map<String, dynamic>? _metadata;
// Metadata
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SetExecutionTiming
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetExecutionTimingCopyWith<_SetExecutionTiming> get copyWith => __$SetExecutionTimingCopyWithImpl<_SetExecutionTiming>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetExecutionTimingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetExecutionTiming&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.executionTimeMs, executionTimeMs) || other.executionTimeMs == executionTimeMs)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&const DeepCollectionEquality().equals(other._repTimingsMs, _repTimingsMs)&&const DeepCollectionEquality().equals(other._velocityMps, _velocityMps)&&const DeepCollectionEquality().equals(other._pauseTimingsMs, _pauseTimingsMs)&&(identical(other.formScore, formScore) || other.formScore == formScore)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore)&&(identical(other.fatigueIndex, fatigueIndex) || other.fatigueIndex == fatigueIndex)&&(identical(other.restStartedAt, restStartedAt) || other.restStartedAt == restStartedAt)&&(identical(other.restDurationMs, restDurationMs) || other.restDurationMs == restDurationMs)&&(identical(other.heartRateBpm, heartRateBpm) || other.heartRateBpm == heartRateBpm)&&(identical(other.ambientTemperatureC, ambientTemperatureC) || other.ambientTemperatureC == ambientTemperatureC)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.synced, synced) || other.synced == synced)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,exerciseId,workoutId,setNumber,executionTimeMs,startTime,endTime,reps,weight,rpe,const DeepCollectionEquality().hash(_repTimingsMs),const DeepCollectionEquality().hash(_velocityMps),const DeepCollectionEquality().hash(_pauseTimingsMs),formScore,consistencyScore,fatigueIndex,restStartedAt,restDurationMs,heartRateBpm,ambientTemperatureC,createdAt,uploadedAt,synced,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'SetExecutionTiming(id: $id, exerciseId: $exerciseId, workoutId: $workoutId, setNumber: $setNumber, executionTimeMs: $executionTimeMs, startTime: $startTime, endTime: $endTime, reps: $reps, weight: $weight, rpe: $rpe, repTimingsMs: $repTimingsMs, velocityMps: $velocityMps, pauseTimingsMs: $pauseTimingsMs, formScore: $formScore, consistencyScore: $consistencyScore, fatigueIndex: $fatigueIndex, restStartedAt: $restStartedAt, restDurationMs: $restDurationMs, heartRateBpm: $heartRateBpm, ambientTemperatureC: $ambientTemperatureC, createdAt: $createdAt, uploadedAt: $uploadedAt, synced: $synced, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$SetExecutionTimingCopyWith<$Res> implements $SetExecutionTimingCopyWith<$Res> {
  factory _$SetExecutionTimingCopyWith(_SetExecutionTiming value, $Res Function(_SetExecutionTiming) _then) = __$SetExecutionTimingCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String workoutId, int setNumber, int executionTimeMs, DateTime startTime, DateTime endTime, int reps, double? weight, int rpe, List<int> repTimingsMs, List<double> velocityMps, List<int> pauseTimingsMs, double formScore, double consistencyScore, double fatigueIndex, DateTime? restStartedAt, int? restDurationMs, double heartRateBpm, double ambientTemperatureC, DateTime createdAt, DateTime? uploadedAt, bool synced, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$SetExecutionTimingCopyWithImpl<$Res>
    implements _$SetExecutionTimingCopyWith<$Res> {
  __$SetExecutionTimingCopyWithImpl(this._self, this._then);

  final _SetExecutionTiming _self;
  final $Res Function(_SetExecutionTiming) _then;

/// Create a copy of SetExecutionTiming
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? workoutId = null,Object? setNumber = null,Object? executionTimeMs = null,Object? startTime = null,Object? endTime = null,Object? reps = null,Object? weight = freezed,Object? rpe = null,Object? repTimingsMs = null,Object? velocityMps = null,Object? pauseTimingsMs = null,Object? formScore = null,Object? consistencyScore = null,Object? fatigueIndex = null,Object? restStartedAt = freezed,Object? restDurationMs = freezed,Object? heartRateBpm = null,Object? ambientTemperatureC = null,Object? createdAt = null,Object? uploadedAt = freezed,Object? synced = null,Object? metadata = freezed,}) {
  return _then(_SetExecutionTiming(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,executionTimeMs: null == executionTimeMs ? _self.executionTimeMs : executionTimeMs // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,rpe: null == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int,repTimingsMs: null == repTimingsMs ? _self._repTimingsMs : repTimingsMs // ignore: cast_nullable_to_non_nullable
as List<int>,velocityMps: null == velocityMps ? _self._velocityMps : velocityMps // ignore: cast_nullable_to_non_nullable
as List<double>,pauseTimingsMs: null == pauseTimingsMs ? _self._pauseTimingsMs : pauseTimingsMs // ignore: cast_nullable_to_non_nullable
as List<int>,formScore: null == formScore ? _self.formScore : formScore // ignore: cast_nullable_to_non_nullable
as double,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as double,fatigueIndex: null == fatigueIndex ? _self.fatigueIndex : fatigueIndex // ignore: cast_nullable_to_non_nullable
as double,restStartedAt: freezed == restStartedAt ? _self.restStartedAt : restStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restDurationMs: freezed == restDurationMs ? _self.restDurationMs : restDurationMs // ignore: cast_nullable_to_non_nullable
as int?,heartRateBpm: null == heartRateBpm ? _self.heartRateBpm : heartRateBpm // ignore: cast_nullable_to_non_nullable
as double,ambientTemperatureC: null == ambientTemperatureC ? _self.ambientTemperatureC : ambientTemperatureC // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

SetTimingConfig _$SetTimingConfigFromJson(
  Map<String, dynamic> json
) {
    return _$$SetTimingConfigImpl.fromJson(
      json
    );
}

/// @nodoc
mixin _$SetTimingConfig {

 TimingMode get mode;// Precision settings
 int get samplingRateHz; bool get trackVelocity; bool get trackPauses; bool get trackHeartRate;// Analysis thresholds
 int get maxSetDurationMs; int get minRepDurationMs; int get maxRepDurationMs;// Quality thresholds
 double get maxVelocityVariationPercent; int get maxPauseBetweenRepsMs;// Auto-detection settings
 bool get autoStartDetection; bool get autoEndDetection; int get motionThresholdMs;
/// Create a copy of SetTimingConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetTimingConfigCopyWith<SetTimingConfig> get copyWith => _$SetTimingConfigCopyWithImpl<SetTimingConfig>(this as SetTimingConfig, _$identity);

  /// Serializes this SetTimingConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetTimingConfig&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.samplingRateHz, samplingRateHz) || other.samplingRateHz == samplingRateHz)&&(identical(other.trackVelocity, trackVelocity) || other.trackVelocity == trackVelocity)&&(identical(other.trackPauses, trackPauses) || other.trackPauses == trackPauses)&&(identical(other.trackHeartRate, trackHeartRate) || other.trackHeartRate == trackHeartRate)&&(identical(other.maxSetDurationMs, maxSetDurationMs) || other.maxSetDurationMs == maxSetDurationMs)&&(identical(other.minRepDurationMs, minRepDurationMs) || other.minRepDurationMs == minRepDurationMs)&&(identical(other.maxRepDurationMs, maxRepDurationMs) || other.maxRepDurationMs == maxRepDurationMs)&&(identical(other.maxVelocityVariationPercent, maxVelocityVariationPercent) || other.maxVelocityVariationPercent == maxVelocityVariationPercent)&&(identical(other.maxPauseBetweenRepsMs, maxPauseBetweenRepsMs) || other.maxPauseBetweenRepsMs == maxPauseBetweenRepsMs)&&(identical(other.autoStartDetection, autoStartDetection) || other.autoStartDetection == autoStartDetection)&&(identical(other.autoEndDetection, autoEndDetection) || other.autoEndDetection == autoEndDetection)&&(identical(other.motionThresholdMs, motionThresholdMs) || other.motionThresholdMs == motionThresholdMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,samplingRateHz,trackVelocity,trackPauses,trackHeartRate,maxSetDurationMs,minRepDurationMs,maxRepDurationMs,maxVelocityVariationPercent,maxPauseBetweenRepsMs,autoStartDetection,autoEndDetection,motionThresholdMs);

@override
String toString() {
  return 'SetTimingConfig(mode: $mode, samplingRateHz: $samplingRateHz, trackVelocity: $trackVelocity, trackPauses: $trackPauses, trackHeartRate: $trackHeartRate, maxSetDurationMs: $maxSetDurationMs, minRepDurationMs: $minRepDurationMs, maxRepDurationMs: $maxRepDurationMs, maxVelocityVariationPercent: $maxVelocityVariationPercent, maxPauseBetweenRepsMs: $maxPauseBetweenRepsMs, autoStartDetection: $autoStartDetection, autoEndDetection: $autoEndDetection, motionThresholdMs: $motionThresholdMs)';
}


}

/// @nodoc
abstract mixin class $SetTimingConfigCopyWith<$Res>  {
  factory $SetTimingConfigCopyWith(SetTimingConfig value, $Res Function(SetTimingConfig) _then) = _$SetTimingConfigCopyWithImpl;
@useResult
$Res call({
 TimingMode mode, int samplingRateHz, bool trackVelocity, bool trackPauses, bool trackHeartRate, int maxSetDurationMs, int minRepDurationMs, int maxRepDurationMs, double maxVelocityVariationPercent, int maxPauseBetweenRepsMs, bool autoStartDetection, bool autoEndDetection, int motionThresholdMs
});




}
/// @nodoc
class _$SetTimingConfigCopyWithImpl<$Res>
    implements $SetTimingConfigCopyWith<$Res> {
  _$SetTimingConfigCopyWithImpl(this._self, this._then);

  final SetTimingConfig _self;
  final $Res Function(SetTimingConfig) _then;

/// Create a copy of SetTimingConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? samplingRateHz = null,Object? trackVelocity = null,Object? trackPauses = null,Object? trackHeartRate = null,Object? maxSetDurationMs = null,Object? minRepDurationMs = null,Object? maxRepDurationMs = null,Object? maxVelocityVariationPercent = null,Object? maxPauseBetweenRepsMs = null,Object? autoStartDetection = null,Object? autoEndDetection = null,Object? motionThresholdMs = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TimingMode,samplingRateHz: null == samplingRateHz ? _self.samplingRateHz : samplingRateHz // ignore: cast_nullable_to_non_nullable
as int,trackVelocity: null == trackVelocity ? _self.trackVelocity : trackVelocity // ignore: cast_nullable_to_non_nullable
as bool,trackPauses: null == trackPauses ? _self.trackPauses : trackPauses // ignore: cast_nullable_to_non_nullable
as bool,trackHeartRate: null == trackHeartRate ? _self.trackHeartRate : trackHeartRate // ignore: cast_nullable_to_non_nullable
as bool,maxSetDurationMs: null == maxSetDurationMs ? _self.maxSetDurationMs : maxSetDurationMs // ignore: cast_nullable_to_non_nullable
as int,minRepDurationMs: null == minRepDurationMs ? _self.minRepDurationMs : minRepDurationMs // ignore: cast_nullable_to_non_nullable
as int,maxRepDurationMs: null == maxRepDurationMs ? _self.maxRepDurationMs : maxRepDurationMs // ignore: cast_nullable_to_non_nullable
as int,maxVelocityVariationPercent: null == maxVelocityVariationPercent ? _self.maxVelocityVariationPercent : maxVelocityVariationPercent // ignore: cast_nullable_to_non_nullable
as double,maxPauseBetweenRepsMs: null == maxPauseBetweenRepsMs ? _self.maxPauseBetweenRepsMs : maxPauseBetweenRepsMs // ignore: cast_nullable_to_non_nullable
as int,autoStartDetection: null == autoStartDetection ? _self.autoStartDetection : autoStartDetection // ignore: cast_nullable_to_non_nullable
as bool,autoEndDetection: null == autoEndDetection ? _self.autoEndDetection : autoEndDetection // ignore: cast_nullable_to_non_nullable
as bool,motionThresholdMs: null == motionThresholdMs ? _self.motionThresholdMs : motionThresholdMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SetTimingConfig].
extension SetTimingConfigPatterns on SetTimingConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _$$SetTimingConfigImpl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _$$SetTimingConfigImpl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _$$SetTimingConfigImpl value)  $default,){
final _that = this;
switch (_that) {
case _$$SetTimingConfigImpl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _$$SetTimingConfigImpl value)?  $default,){
final _that = this;
switch (_that) {
case _$$SetTimingConfigImpl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TimingMode mode,  int samplingRateHz,  bool trackVelocity,  bool trackPauses,  bool trackHeartRate,  int maxSetDurationMs,  int minRepDurationMs,  int maxRepDurationMs,  double maxVelocityVariationPercent,  int maxPauseBetweenRepsMs,  bool autoStartDetection,  bool autoEndDetection,  int motionThresholdMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _$$SetTimingConfigImpl() when $default != null:
return $default(_that.mode,_that.samplingRateHz,_that.trackVelocity,_that.trackPauses,_that.trackHeartRate,_that.maxSetDurationMs,_that.minRepDurationMs,_that.maxRepDurationMs,_that.maxVelocityVariationPercent,_that.maxPauseBetweenRepsMs,_that.autoStartDetection,_that.autoEndDetection,_that.motionThresholdMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TimingMode mode,  int samplingRateHz,  bool trackVelocity,  bool trackPauses,  bool trackHeartRate,  int maxSetDurationMs,  int minRepDurationMs,  int maxRepDurationMs,  double maxVelocityVariationPercent,  int maxPauseBetweenRepsMs,  bool autoStartDetection,  bool autoEndDetection,  int motionThresholdMs)  $default,) {final _that = this;
switch (_that) {
case _$$SetTimingConfigImpl():
return $default(_that.mode,_that.samplingRateHz,_that.trackVelocity,_that.trackPauses,_that.trackHeartRate,_that.maxSetDurationMs,_that.minRepDurationMs,_that.maxRepDurationMs,_that.maxVelocityVariationPercent,_that.maxPauseBetweenRepsMs,_that.autoStartDetection,_that.autoEndDetection,_that.motionThresholdMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TimingMode mode,  int samplingRateHz,  bool trackVelocity,  bool trackPauses,  bool trackHeartRate,  int maxSetDurationMs,  int minRepDurationMs,  int maxRepDurationMs,  double maxVelocityVariationPercent,  int maxPauseBetweenRepsMs,  bool autoStartDetection,  bool autoEndDetection,  int motionThresholdMs)?  $default,) {final _that = this;
switch (_that) {
case _$$SetTimingConfigImpl() when $default != null:
return $default(_that.mode,_that.samplingRateHz,_that.trackVelocity,_that.trackPauses,_that.trackHeartRate,_that.maxSetDurationMs,_that.minRepDurationMs,_that.maxRepDurationMs,_that.maxVelocityVariationPercent,_that.maxPauseBetweenRepsMs,_that.autoStartDetection,_that.autoEndDetection,_that.motionThresholdMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _$$SetTimingConfigImpl implements SetTimingConfig {
  const _$$SetTimingConfigImpl({required this.mode, this.samplingRateHz = 10, this.trackVelocity = true, this.trackPauses = true, this.trackHeartRate = false, this.maxSetDurationMs = 2000, this.minRepDurationMs = 100, this.maxRepDurationMs = 5000, this.maxVelocityVariationPercent = 20.0, this.maxPauseBetweenRepsMs = 1000, this.autoStartDetection = true, this.autoEndDetection = true, this.motionThresholdMs = 500});
  factory _$$SetTimingConfigImpl.fromJson(Map<String, dynamic> json) => _$$$SetTimingConfigImplFromJson(json);

@override final  TimingMode mode;
// Precision settings
@override@JsonKey() final  int samplingRateHz;
@override@JsonKey() final  bool trackVelocity;
@override@JsonKey() final  bool trackPauses;
@override@JsonKey() final  bool trackHeartRate;
// Analysis thresholds
@override@JsonKey() final  int maxSetDurationMs;
@override@JsonKey() final  int minRepDurationMs;
@override@JsonKey() final  int maxRepDurationMs;
// Quality thresholds
@override@JsonKey() final  double maxVelocityVariationPercent;
@override@JsonKey() final  int maxPauseBetweenRepsMs;
// Auto-detection settings
@override@JsonKey() final  bool autoStartDetection;
@override@JsonKey() final  bool autoEndDetection;
@override@JsonKey() final  int motionThresholdMs;

/// Create a copy of SetTimingConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$$$SetTimingConfigImplCopyWith<_$$SetTimingConfigImpl> get copyWith => __$$$SetTimingConfigImplCopyWithImpl<_$$SetTimingConfigImpl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$$$SetTimingConfigImplToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _$$SetTimingConfigImpl&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.samplingRateHz, samplingRateHz) || other.samplingRateHz == samplingRateHz)&&(identical(other.trackVelocity, trackVelocity) || other.trackVelocity == trackVelocity)&&(identical(other.trackPauses, trackPauses) || other.trackPauses == trackPauses)&&(identical(other.trackHeartRate, trackHeartRate) || other.trackHeartRate == trackHeartRate)&&(identical(other.maxSetDurationMs, maxSetDurationMs) || other.maxSetDurationMs == maxSetDurationMs)&&(identical(other.minRepDurationMs, minRepDurationMs) || other.minRepDurationMs == minRepDurationMs)&&(identical(other.maxRepDurationMs, maxRepDurationMs) || other.maxRepDurationMs == maxRepDurationMs)&&(identical(other.maxVelocityVariationPercent, maxVelocityVariationPercent) || other.maxVelocityVariationPercent == maxVelocityVariationPercent)&&(identical(other.maxPauseBetweenRepsMs, maxPauseBetweenRepsMs) || other.maxPauseBetweenRepsMs == maxPauseBetweenRepsMs)&&(identical(other.autoStartDetection, autoStartDetection) || other.autoStartDetection == autoStartDetection)&&(identical(other.autoEndDetection, autoEndDetection) || other.autoEndDetection == autoEndDetection)&&(identical(other.motionThresholdMs, motionThresholdMs) || other.motionThresholdMs == motionThresholdMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,samplingRateHz,trackVelocity,trackPauses,trackHeartRate,maxSetDurationMs,minRepDurationMs,maxRepDurationMs,maxVelocityVariationPercent,maxPauseBetweenRepsMs,autoStartDetection,autoEndDetection,motionThresholdMs);

@override
String toString() {
  return 'SetTimingConfig(mode: $mode, samplingRateHz: $samplingRateHz, trackVelocity: $trackVelocity, trackPauses: $trackPauses, trackHeartRate: $trackHeartRate, maxSetDurationMs: $maxSetDurationMs, minRepDurationMs: $minRepDurationMs, maxRepDurationMs: $maxRepDurationMs, maxVelocityVariationPercent: $maxVelocityVariationPercent, maxPauseBetweenRepsMs: $maxPauseBetweenRepsMs, autoStartDetection: $autoStartDetection, autoEndDetection: $autoEndDetection, motionThresholdMs: $motionThresholdMs)';
}


}

/// @nodoc
abstract mixin class _$$$SetTimingConfigImplCopyWith<$Res> implements $SetTimingConfigCopyWith<$Res> {
  factory _$$$SetTimingConfigImplCopyWith(_$$SetTimingConfigImpl value, $Res Function(_$$SetTimingConfigImpl) _then) = __$$$SetTimingConfigImplCopyWithImpl;
@override @useResult
$Res call({
 TimingMode mode, int samplingRateHz, bool trackVelocity, bool trackPauses, bool trackHeartRate, int maxSetDurationMs, int minRepDurationMs, int maxRepDurationMs, double maxVelocityVariationPercent, int maxPauseBetweenRepsMs, bool autoStartDetection, bool autoEndDetection, int motionThresholdMs
});




}
/// @nodoc
class __$$$SetTimingConfigImplCopyWithImpl<$Res>
    implements _$$$SetTimingConfigImplCopyWith<$Res> {
  __$$$SetTimingConfigImplCopyWithImpl(this._self, this._then);

  final _$$SetTimingConfigImpl _self;
  final $Res Function(_$$SetTimingConfigImpl) _then;

/// Create a copy of SetTimingConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? samplingRateHz = null,Object? trackVelocity = null,Object? trackPauses = null,Object? trackHeartRate = null,Object? maxSetDurationMs = null,Object? minRepDurationMs = null,Object? maxRepDurationMs = null,Object? maxVelocityVariationPercent = null,Object? maxPauseBetweenRepsMs = null,Object? autoStartDetection = null,Object? autoEndDetection = null,Object? motionThresholdMs = null,}) {
  return _then(_$$SetTimingConfigImpl(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TimingMode,samplingRateHz: null == samplingRateHz ? _self.samplingRateHz : samplingRateHz // ignore: cast_nullable_to_non_nullable
as int,trackVelocity: null == trackVelocity ? _self.trackVelocity : trackVelocity // ignore: cast_nullable_to_non_nullable
as bool,trackPauses: null == trackPauses ? _self.trackPauses : trackPauses // ignore: cast_nullable_to_non_nullable
as bool,trackHeartRate: null == trackHeartRate ? _self.trackHeartRate : trackHeartRate // ignore: cast_nullable_to_non_nullable
as bool,maxSetDurationMs: null == maxSetDurationMs ? _self.maxSetDurationMs : maxSetDurationMs // ignore: cast_nullable_to_non_nullable
as int,minRepDurationMs: null == minRepDurationMs ? _self.minRepDurationMs : minRepDurationMs // ignore: cast_nullable_to_non_nullable
as int,maxRepDurationMs: null == maxRepDurationMs ? _self.maxRepDurationMs : maxRepDurationMs // ignore: cast_nullable_to_non_nullable
as int,maxVelocityVariationPercent: null == maxVelocityVariationPercent ? _self.maxVelocityVariationPercent : maxVelocityVariationPercent // ignore: cast_nullable_to_non_nullable
as double,maxPauseBetweenRepsMs: null == maxPauseBetweenRepsMs ? _self.maxPauseBetweenRepsMs : maxPauseBetweenRepsMs // ignore: cast_nullable_to_non_nullable
as int,autoStartDetection: null == autoStartDetection ? _self.autoStartDetection : autoStartDetection // ignore: cast_nullable_to_non_nullable
as bool,autoEndDetection: null == autoEndDetection ? _self.autoEndDetection : autoEndDetection // ignore: cast_nullable_to_non_nullable
as bool,motionThresholdMs: null == motionThresholdMs ? _self.motionThresholdMs : motionThresholdMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

LiveSetMetrics _$LiveSetMetricsFromJson(
  Map<String, dynamic> json
) {
    return _$$LiveSetMetricsImpl.fromJson(
      json
    );
}

/// @nodoc
mixin _$LiveSetMetrics {

 String get setId; SetPhase get phase;// Current timing
 int get elapsedMs; int get currentRep;// Live velocity data
 double get currentVelocityMps; double get averageVelocityMps; double get velocityDropPercent;// Form feedback
 double get currentFormScore; double get consistencyScore;// Fatigue indicators
 double get fatigueIndex; bool get shouldStopSet;// Recommendations
 String? get coachingTip; double? get suggestedWeight; int? get suggestedReps; DateTime get timestamp;
/// Create a copy of LiveSetMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveSetMetricsCopyWith<LiveSetMetrics> get copyWith => _$LiveSetMetricsCopyWithImpl<LiveSetMetrics>(this as LiveSetMetrics, _$identity);

  /// Serializes this LiveSetMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveSetMetrics&&(identical(other.setId, setId) || other.setId == setId)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.elapsedMs, elapsedMs) || other.elapsedMs == elapsedMs)&&(identical(other.currentRep, currentRep) || other.currentRep == currentRep)&&(identical(other.currentVelocityMps, currentVelocityMps) || other.currentVelocityMps == currentVelocityMps)&&(identical(other.averageVelocityMps, averageVelocityMps) || other.averageVelocityMps == averageVelocityMps)&&(identical(other.velocityDropPercent, velocityDropPercent) || other.velocityDropPercent == velocityDropPercent)&&(identical(other.currentFormScore, currentFormScore) || other.currentFormScore == currentFormScore)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore)&&(identical(other.fatigueIndex, fatigueIndex) || other.fatigueIndex == fatigueIndex)&&(identical(other.shouldStopSet, shouldStopSet) || other.shouldStopSet == shouldStopSet)&&(identical(other.coachingTip, coachingTip) || other.coachingTip == coachingTip)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setId,phase,elapsedMs,currentRep,currentVelocityMps,averageVelocityMps,velocityDropPercent,currentFormScore,consistencyScore,fatigueIndex,shouldStopSet,coachingTip,suggestedWeight,suggestedReps,timestamp);

@override
String toString() {
  return 'LiveSetMetrics(setId: $setId, phase: $phase, elapsedMs: $elapsedMs, currentRep: $currentRep, currentVelocityMps: $currentVelocityMps, averageVelocityMps: $averageVelocityMps, velocityDropPercent: $velocityDropPercent, currentFormScore: $currentFormScore, consistencyScore: $consistencyScore, fatigueIndex: $fatigueIndex, shouldStopSet: $shouldStopSet, coachingTip: $coachingTip, suggestedWeight: $suggestedWeight, suggestedReps: $suggestedReps, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $LiveSetMetricsCopyWith<$Res>  {
  factory $LiveSetMetricsCopyWith(LiveSetMetrics value, $Res Function(LiveSetMetrics) _then) = _$LiveSetMetricsCopyWithImpl;
@useResult
$Res call({
 String setId, SetPhase phase, int elapsedMs, int currentRep, double currentVelocityMps, double averageVelocityMps, double velocityDropPercent, double currentFormScore, double consistencyScore, double fatigueIndex, bool shouldStopSet, String? coachingTip, double? suggestedWeight, int? suggestedReps, DateTime timestamp
});




}
/// @nodoc
class _$LiveSetMetricsCopyWithImpl<$Res>
    implements $LiveSetMetricsCopyWith<$Res> {
  _$LiveSetMetricsCopyWithImpl(this._self, this._then);

  final LiveSetMetrics _self;
  final $Res Function(LiveSetMetrics) _then;

/// Create a copy of LiveSetMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? setId = null,Object? phase = null,Object? elapsedMs = null,Object? currentRep = null,Object? currentVelocityMps = null,Object? averageVelocityMps = null,Object? velocityDropPercent = null,Object? currentFormScore = null,Object? consistencyScore = null,Object? fatigueIndex = null,Object? shouldStopSet = null,Object? coachingTip = freezed,Object? suggestedWeight = freezed,Object? suggestedReps = freezed,Object? timestamp = null,}) {
  return _then(_self.copyWith(
setId: null == setId ? _self.setId : setId // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SetPhase,elapsedMs: null == elapsedMs ? _self.elapsedMs : elapsedMs // ignore: cast_nullable_to_non_nullable
as int,currentRep: null == currentRep ? _self.currentRep : currentRep // ignore: cast_nullable_to_non_nullable
as int,currentVelocityMps: null == currentVelocityMps ? _self.currentVelocityMps : currentVelocityMps // ignore: cast_nullable_to_non_nullable
as double,averageVelocityMps: null == averageVelocityMps ? _self.averageVelocityMps : averageVelocityMps // ignore: cast_nullable_to_non_nullable
as double,velocityDropPercent: null == velocityDropPercent ? _self.velocityDropPercent : velocityDropPercent // ignore: cast_nullable_to_non_nullable
as double,currentFormScore: null == currentFormScore ? _self.currentFormScore : currentFormScore // ignore: cast_nullable_to_non_nullable
as double,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as double,fatigueIndex: null == fatigueIndex ? _self.fatigueIndex : fatigueIndex // ignore: cast_nullable_to_non_nullable
as double,shouldStopSet: null == shouldStopSet ? _self.shouldStopSet : shouldStopSet // ignore: cast_nullable_to_non_nullable
as bool,coachingTip: freezed == coachingTip ? _self.coachingTip : coachingTip // ignore: cast_nullable_to_non_nullable
as String?,suggestedWeight: freezed == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double?,suggestedReps: freezed == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveSetMetrics].
extension LiveSetMetricsPatterns on LiveSetMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _$$LiveSetMetricsImpl value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _$$LiveSetMetricsImpl() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _$$LiveSetMetricsImpl value)  $default,){
final _that = this;
switch (_that) {
case _$$LiveSetMetricsImpl():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _$$LiveSetMetricsImpl value)?  $default,){
final _that = this;
switch (_that) {
case _$$LiveSetMetricsImpl() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String setId,  SetPhase phase,  int elapsedMs,  int currentRep,  double currentVelocityMps,  double averageVelocityMps,  double velocityDropPercent,  double currentFormScore,  double consistencyScore,  double fatigueIndex,  bool shouldStopSet,  String? coachingTip,  double? suggestedWeight,  int? suggestedReps,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _$$LiveSetMetricsImpl() when $default != null:
return $default(_that.setId,_that.phase,_that.elapsedMs,_that.currentRep,_that.currentVelocityMps,_that.averageVelocityMps,_that.velocityDropPercent,_that.currentFormScore,_that.consistencyScore,_that.fatigueIndex,_that.shouldStopSet,_that.coachingTip,_that.suggestedWeight,_that.suggestedReps,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String setId,  SetPhase phase,  int elapsedMs,  int currentRep,  double currentVelocityMps,  double averageVelocityMps,  double velocityDropPercent,  double currentFormScore,  double consistencyScore,  double fatigueIndex,  bool shouldStopSet,  String? coachingTip,  double? suggestedWeight,  int? suggestedReps,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _$$LiveSetMetricsImpl():
return $default(_that.setId,_that.phase,_that.elapsedMs,_that.currentRep,_that.currentVelocityMps,_that.averageVelocityMps,_that.velocityDropPercent,_that.currentFormScore,_that.consistencyScore,_that.fatigueIndex,_that.shouldStopSet,_that.coachingTip,_that.suggestedWeight,_that.suggestedReps,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String setId,  SetPhase phase,  int elapsedMs,  int currentRep,  double currentVelocityMps,  double averageVelocityMps,  double velocityDropPercent,  double currentFormScore,  double consistencyScore,  double fatigueIndex,  bool shouldStopSet,  String? coachingTip,  double? suggestedWeight,  int? suggestedReps,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _$$LiveSetMetricsImpl() when $default != null:
return $default(_that.setId,_that.phase,_that.elapsedMs,_that.currentRep,_that.currentVelocityMps,_that.averageVelocityMps,_that.velocityDropPercent,_that.currentFormScore,_that.consistencyScore,_that.fatigueIndex,_that.shouldStopSet,_that.coachingTip,_that.suggestedWeight,_that.suggestedReps,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _$$LiveSetMetricsImpl implements LiveSetMetrics {
  const _$$LiveSetMetricsImpl({required this.setId, required this.phase, required this.elapsedMs, required this.currentRep, this.currentVelocityMps = 0.0, this.averageVelocityMps = 0.0, this.velocityDropPercent = 0.0, this.currentFormScore = 0.0, this.consistencyScore = 0.0, this.fatigueIndex = 0.0, this.shouldStopSet = false, this.coachingTip, this.suggestedWeight, this.suggestedReps, required this.timestamp});
  factory _$$LiveSetMetricsImpl.fromJson(Map<String, dynamic> json) => _$$$LiveSetMetricsImplFromJson(json);

@override final  String setId;
@override final  SetPhase phase;
// Current timing
@override final  int elapsedMs;
@override final  int currentRep;
// Live velocity data
@override@JsonKey() final  double currentVelocityMps;
@override@JsonKey() final  double averageVelocityMps;
@override@JsonKey() final  double velocityDropPercent;
// Form feedback
@override@JsonKey() final  double currentFormScore;
@override@JsonKey() final  double consistencyScore;
// Fatigue indicators
@override@JsonKey() final  double fatigueIndex;
@override@JsonKey() final  bool shouldStopSet;
// Recommendations
@override final  String? coachingTip;
@override final  double? suggestedWeight;
@override final  int? suggestedReps;
@override final  DateTime timestamp;

/// Create a copy of LiveSetMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$$$LiveSetMetricsImplCopyWith<_$$LiveSetMetricsImpl> get copyWith => __$$$LiveSetMetricsImplCopyWithImpl<_$$LiveSetMetricsImpl>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$$$LiveSetMetricsImplToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _$$LiveSetMetricsImpl&&(identical(other.setId, setId) || other.setId == setId)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.elapsedMs, elapsedMs) || other.elapsedMs == elapsedMs)&&(identical(other.currentRep, currentRep) || other.currentRep == currentRep)&&(identical(other.currentVelocityMps, currentVelocityMps) || other.currentVelocityMps == currentVelocityMps)&&(identical(other.averageVelocityMps, averageVelocityMps) || other.averageVelocityMps == averageVelocityMps)&&(identical(other.velocityDropPercent, velocityDropPercent) || other.velocityDropPercent == velocityDropPercent)&&(identical(other.currentFormScore, currentFormScore) || other.currentFormScore == currentFormScore)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore)&&(identical(other.fatigueIndex, fatigueIndex) || other.fatigueIndex == fatigueIndex)&&(identical(other.shouldStopSet, shouldStopSet) || other.shouldStopSet == shouldStopSet)&&(identical(other.coachingTip, coachingTip) || other.coachingTip == coachingTip)&&(identical(other.suggestedWeight, suggestedWeight) || other.suggestedWeight == suggestedWeight)&&(identical(other.suggestedReps, suggestedReps) || other.suggestedReps == suggestedReps)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setId,phase,elapsedMs,currentRep,currentVelocityMps,averageVelocityMps,velocityDropPercent,currentFormScore,consistencyScore,fatigueIndex,shouldStopSet,coachingTip,suggestedWeight,suggestedReps,timestamp);

@override
String toString() {
  return 'LiveSetMetrics(setId: $setId, phase: $phase, elapsedMs: $elapsedMs, currentRep: $currentRep, currentVelocityMps: $currentVelocityMps, averageVelocityMps: $averageVelocityMps, velocityDropPercent: $velocityDropPercent, currentFormScore: $currentFormScore, consistencyScore: $consistencyScore, fatigueIndex: $fatigueIndex, shouldStopSet: $shouldStopSet, coachingTip: $coachingTip, suggestedWeight: $suggestedWeight, suggestedReps: $suggestedReps, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$$$LiveSetMetricsImplCopyWith<$Res> implements $LiveSetMetricsCopyWith<$Res> {
  factory _$$$LiveSetMetricsImplCopyWith(_$$LiveSetMetricsImpl value, $Res Function(_$$LiveSetMetricsImpl) _then) = __$$$LiveSetMetricsImplCopyWithImpl;
@override @useResult
$Res call({
 String setId, SetPhase phase, int elapsedMs, int currentRep, double currentVelocityMps, double averageVelocityMps, double velocityDropPercent, double currentFormScore, double consistencyScore, double fatigueIndex, bool shouldStopSet, String? coachingTip, double? suggestedWeight, int? suggestedReps, DateTime timestamp
});




}
/// @nodoc
class __$$$LiveSetMetricsImplCopyWithImpl<$Res>
    implements _$$$LiveSetMetricsImplCopyWith<$Res> {
  __$$$LiveSetMetricsImplCopyWithImpl(this._self, this._then);

  final _$$LiveSetMetricsImpl _self;
  final $Res Function(_$$LiveSetMetricsImpl) _then;

/// Create a copy of LiveSetMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? setId = null,Object? phase = null,Object? elapsedMs = null,Object? currentRep = null,Object? currentVelocityMps = null,Object? averageVelocityMps = null,Object? velocityDropPercent = null,Object? currentFormScore = null,Object? consistencyScore = null,Object? fatigueIndex = null,Object? shouldStopSet = null,Object? coachingTip = freezed,Object? suggestedWeight = freezed,Object? suggestedReps = freezed,Object? timestamp = null,}) {
  return _then(_$$LiveSetMetricsImpl(
setId: null == setId ? _self.setId : setId // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SetPhase,elapsedMs: null == elapsedMs ? _self.elapsedMs : elapsedMs // ignore: cast_nullable_to_non_nullable
as int,currentRep: null == currentRep ? _self.currentRep : currentRep // ignore: cast_nullable_to_non_nullable
as int,currentVelocityMps: null == currentVelocityMps ? _self.currentVelocityMps : currentVelocityMps // ignore: cast_nullable_to_non_nullable
as double,averageVelocityMps: null == averageVelocityMps ? _self.averageVelocityMps : averageVelocityMps // ignore: cast_nullable_to_non_nullable
as double,velocityDropPercent: null == velocityDropPercent ? _self.velocityDropPercent : velocityDropPercent // ignore: cast_nullable_to_non_nullable
as double,currentFormScore: null == currentFormScore ? _self.currentFormScore : currentFormScore // ignore: cast_nullable_to_non_nullable
as double,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as double,fatigueIndex: null == fatigueIndex ? _self.fatigueIndex : fatigueIndex // ignore: cast_nullable_to_non_nullable
as double,shouldStopSet: null == shouldStopSet ? _self.shouldStopSet : shouldStopSet // ignore: cast_nullable_to_non_nullable
as bool,coachingTip: freezed == coachingTip ? _self.coachingTip : coachingTip // ignore: cast_nullable_to_non_nullable
as String?,suggestedWeight: freezed == suggestedWeight ? _self.suggestedWeight : suggestedWeight // ignore: cast_nullable_to_non_nullable
as double?,suggestedReps: freezed == suggestedReps ? _self.suggestedReps : suggestedReps // ignore: cast_nullable_to_non_nullable
as int?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
