// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_execution_timing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SetExecutionTiming _$SetExecutionTimingFromJson(Map<String, dynamic> json) {
  return _SetExecutionTiming.fromJson(json);
}

/// @nodoc
mixin _$SetExecutionTiming {
  String get id => throw _privateConstructorUsedError;
  String get exerciseId => throw _privateConstructorUsedError;
  String get workoutId => throw _privateConstructorUsedError;
  int get setNumber =>
      throw _privateConstructorUsedError; // Timing precision data (milliseconds)
  int get executionTimeMs => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime =>
      throw _privateConstructorUsedError; // Performance metrics
  int get reps => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  int get rpe =>
      throw _privateConstructorUsedError; // Rate of Perceived Exertion
// Advanced timing analysis
  List<int> get repTimingsMs =>
      throw _privateConstructorUsedError; // Individual rep timings
  List<double> get velocityMps =>
      throw _privateConstructorUsedError; // Velocity per rep (m/s)
  List<int> get pauseTimingsMs =>
      throw _privateConstructorUsedError; // Pauses between reps
// Quality indicators
  double get formScore =>
      throw _privateConstructorUsedError; // 0-100 based on video analysis
  double get consistencyScore =>
      throw _privateConstructorUsedError; // 0-100 based on rep variation
  double get fatigueIndex =>
      throw _privateConstructorUsedError; // 0-100 calculated fatigue
// Environmental data
  DateTime? get restStartedAt => throw _privateConstructorUsedError;
  int? get restDurationMs => throw _privateConstructorUsedError;
  double get heartRateBpm => throw _privateConstructorUsedError;
  double get ambientTemperatureC =>
      throw _privateConstructorUsedError; // Synchronization
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError; // Metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetExecutionTimingCopyWith<SetExecutionTiming> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetExecutionTimingCopyWith<$Res> {
  factory $SetExecutionTimingCopyWith(
          SetExecutionTiming value, $Res Function(SetExecutionTiming) then) =
      _$SetExecutionTimingCopyWithImpl<$Res, SetExecutionTiming>;
  @useResult
  $Res call(
      {String id,
      String exerciseId,
      String workoutId,
      int setNumber,
      int executionTimeMs,
      DateTime startTime,
      DateTime endTime,
      int reps,
      double? weight,
      int rpe,
      List<int> repTimingsMs,
      List<double> velocityMps,
      List<int> pauseTimingsMs,
      double formScore,
      double consistencyScore,
      double fatigueIndex,
      DateTime? restStartedAt,
      int? restDurationMs,
      double heartRateBpm,
      double ambientTemperatureC,
      DateTime createdAt,
      DateTime? uploadedAt,
      bool synced,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$SetExecutionTimingCopyWithImpl<$Res, $Val extends SetExecutionTiming>
    implements $SetExecutionTimingCopyWith<$Res> {
  _$SetExecutionTimingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? workoutId = null,
    Object? setNumber = null,
    Object? executionTimeMs = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? reps = null,
    Object? weight = freezed,
    Object? rpe = null,
    Object? repTimingsMs = null,
    Object? velocityMps = null,
    Object? pauseTimingsMs = null,
    Object? formScore = null,
    Object? consistencyScore = null,
    Object? fatigueIndex = null,
    Object? restStartedAt = freezed,
    Object? restDurationMs = freezed,
    Object? heartRateBpm = null,
    Object? ambientTemperatureC = null,
    Object? createdAt = null,
    Object? uploadedAt = freezed,
    Object? synced = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      executionTimeMs: null == executionTimeMs
          ? _value.executionTimeMs
          : executionTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int,
      repTimingsMs: null == repTimingsMs
          ? _value.repTimingsMs
          : repTimingsMs // ignore: cast_nullable_to_non_nullable
              as List<int>,
      velocityMps: null == velocityMps
          ? _value.velocityMps
          : velocityMps // ignore: cast_nullable_to_non_nullable
              as List<double>,
      pauseTimingsMs: null == pauseTimingsMs
          ? _value.pauseTimingsMs
          : pauseTimingsMs // ignore: cast_nullable_to_non_nullable
              as List<int>,
      formScore: null == formScore
          ? _value.formScore
          : formScore // ignore: cast_nullable_to_non_nullable
              as double,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as double,
      fatigueIndex: null == fatigueIndex
          ? _value.fatigueIndex
          : fatigueIndex // ignore: cast_nullable_to_non_nullable
              as double,
      restStartedAt: freezed == restStartedAt
          ? _value.restStartedAt
          : restStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      restDurationMs: freezed == restDurationMs
          ? _value.restDurationMs
          : restDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      heartRateBpm: null == heartRateBpm
          ? _value.heartRateBpm
          : heartRateBpm // ignore: cast_nullable_to_non_nullable
              as double,
      ambientTemperatureC: null == ambientTemperatureC
          ? _value.ambientTemperatureC
          : ambientTemperatureC // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetExecutionTimingImplCopyWith<$Res>
    implements $SetExecutionTimingCopyWith<$Res> {
  factory _$$SetExecutionTimingImplCopyWith(_$SetExecutionTimingImpl value,
          $Res Function(_$SetExecutionTimingImpl) then) =
      __$$SetExecutionTimingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String exerciseId,
      String workoutId,
      int setNumber,
      int executionTimeMs,
      DateTime startTime,
      DateTime endTime,
      int reps,
      double? weight,
      int rpe,
      List<int> repTimingsMs,
      List<double> velocityMps,
      List<int> pauseTimingsMs,
      double formScore,
      double consistencyScore,
      double fatigueIndex,
      DateTime? restStartedAt,
      int? restDurationMs,
      double heartRateBpm,
      double ambientTemperatureC,
      DateTime createdAt,
      DateTime? uploadedAt,
      bool synced,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$SetExecutionTimingImplCopyWithImpl<$Res>
    extends _$SetExecutionTimingCopyWithImpl<$Res, _$SetExecutionTimingImpl>
    implements _$$SetExecutionTimingImplCopyWith<$Res> {
  __$$SetExecutionTimingImplCopyWithImpl(_$SetExecutionTimingImpl _value,
      $Res Function(_$SetExecutionTimingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? workoutId = null,
    Object? setNumber = null,
    Object? executionTimeMs = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? reps = null,
    Object? weight = freezed,
    Object? rpe = null,
    Object? repTimingsMs = null,
    Object? velocityMps = null,
    Object? pauseTimingsMs = null,
    Object? formScore = null,
    Object? consistencyScore = null,
    Object? fatigueIndex = null,
    Object? restStartedAt = freezed,
    Object? restDurationMs = freezed,
    Object? heartRateBpm = null,
    Object? ambientTemperatureC = null,
    Object? createdAt = null,
    Object? uploadedAt = freezed,
    Object? synced = null,
    Object? metadata = freezed,
  }) {
    return _then(_$SetExecutionTimingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      executionTimeMs: null == executionTimeMs
          ? _value.executionTimeMs
          : executionTimeMs // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      rpe: null == rpe
          ? _value.rpe
          : rpe // ignore: cast_nullable_to_non_nullable
              as int,
      repTimingsMs: null == repTimingsMs
          ? _value._repTimingsMs
          : repTimingsMs // ignore: cast_nullable_to_non_nullable
              as List<int>,
      velocityMps: null == velocityMps
          ? _value._velocityMps
          : velocityMps // ignore: cast_nullable_to_non_nullable
              as List<double>,
      pauseTimingsMs: null == pauseTimingsMs
          ? _value._pauseTimingsMs
          : pauseTimingsMs // ignore: cast_nullable_to_non_nullable
              as List<int>,
      formScore: null == formScore
          ? _value.formScore
          : formScore // ignore: cast_nullable_to_non_nullable
              as double,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as double,
      fatigueIndex: null == fatigueIndex
          ? _value.fatigueIndex
          : fatigueIndex // ignore: cast_nullable_to_non_nullable
              as double,
      restStartedAt: freezed == restStartedAt
          ? _value.restStartedAt
          : restStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      restDurationMs: freezed == restDurationMs
          ? _value.restDurationMs
          : restDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      heartRateBpm: null == heartRateBpm
          ? _value.heartRateBpm
          : heartRateBpm // ignore: cast_nullable_to_non_nullable
              as double,
      ambientTemperatureC: null == ambientTemperatureC
          ? _value.ambientTemperatureC
          : ambientTemperatureC // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetExecutionTimingImpl implements _SetExecutionTiming {
  const _$SetExecutionTimingImpl(
      {required this.id,
      required this.exerciseId,
      required this.workoutId,
      required this.setNumber,
      required this.executionTimeMs,
      required this.startTime,
      required this.endTime,
      this.reps = 0,
      this.weight,
      this.rpe = 0,
      final List<int> repTimingsMs = const [],
      final List<double> velocityMps = const [],
      final List<int> pauseTimingsMs = const [],
      this.formScore = 0.0,
      this.consistencyScore = 0.0,
      this.fatigueIndex = 0.0,
      this.restStartedAt,
      this.restDurationMs,
      this.heartRateBpm = 0.0,
      this.ambientTemperatureC = 0.0,
      required this.createdAt,
      this.uploadedAt,
      this.synced = false,
      final Map<String, dynamic>? metadata})
      : _repTimingsMs = repTimingsMs,
        _velocityMps = velocityMps,
        _pauseTimingsMs = pauseTimingsMs,
        _metadata = metadata;

  factory _$SetExecutionTimingImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetExecutionTimingImplFromJson(json);

  @override
  final String id;
  @override
  final String exerciseId;
  @override
  final String workoutId;
  @override
  final int setNumber;
// Timing precision data (milliseconds)
  @override
  final int executionTimeMs;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
// Performance metrics
  @override
  @JsonKey()
  final int reps;
  @override
  final double? weight;
  @override
  @JsonKey()
  final int rpe;
// Rate of Perceived Exertion
// Advanced timing analysis
  final List<int> _repTimingsMs;
// Rate of Perceived Exertion
// Advanced timing analysis
  @override
  @JsonKey()
  List<int> get repTimingsMs {
    if (_repTimingsMs is EqualUnmodifiableListView) return _repTimingsMs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repTimingsMs);
  }

// Individual rep timings
  final List<double> _velocityMps;
// Individual rep timings
  @override
  @JsonKey()
  List<double> get velocityMps {
    if (_velocityMps is EqualUnmodifiableListView) return _velocityMps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_velocityMps);
  }

// Velocity per rep (m/s)
  final List<int> _pauseTimingsMs;
// Velocity per rep (m/s)
  @override
  @JsonKey()
  List<int> get pauseTimingsMs {
    if (_pauseTimingsMs is EqualUnmodifiableListView) return _pauseTimingsMs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pauseTimingsMs);
  }

// Pauses between reps
// Quality indicators
  @override
  @JsonKey()
  final double formScore;
// 0-100 based on video analysis
  @override
  @JsonKey()
  final double consistencyScore;
// 0-100 based on rep variation
  @override
  @JsonKey()
  final double fatigueIndex;
// 0-100 calculated fatigue
// Environmental data
  @override
  final DateTime? restStartedAt;
  @override
  final int? restDurationMs;
  @override
  @JsonKey()
  final double heartRateBpm;
  @override
  @JsonKey()
  final double ambientTemperatureC;
// Synchronization
  @override
  final DateTime createdAt;
  @override
  final DateTime? uploadedAt;
  @override
  @JsonKey()
  final bool synced;
// Metadata
  final Map<String, dynamic>? _metadata;
// Metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SetExecutionTiming(id: $id, exerciseId: $exerciseId, workoutId: $workoutId, setNumber: $setNumber, executionTimeMs: $executionTimeMs, startTime: $startTime, endTime: $endTime, reps: $reps, weight: $weight, rpe: $rpe, repTimingsMs: $repTimingsMs, velocityMps: $velocityMps, pauseTimingsMs: $pauseTimingsMs, formScore: $formScore, consistencyScore: $consistencyScore, fatigueIndex: $fatigueIndex, restStartedAt: $restStartedAt, restDurationMs: $restDurationMs, heartRateBpm: $heartRateBpm, ambientTemperatureC: $ambientTemperatureC, createdAt: $createdAt, uploadedAt: $uploadedAt, synced: $synced, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetExecutionTimingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.executionTimeMs, executionTimeMs) ||
                other.executionTimeMs == executionTimeMs) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            const DeepCollectionEquality()
                .equals(other._repTimingsMs, _repTimingsMs) &&
            const DeepCollectionEquality()
                .equals(other._velocityMps, _velocityMps) &&
            const DeepCollectionEquality()
                .equals(other._pauseTimingsMs, _pauseTimingsMs) &&
            (identical(other.formScore, formScore) ||
                other.formScore == formScore) &&
            (identical(other.consistencyScore, consistencyScore) ||
                other.consistencyScore == consistencyScore) &&
            (identical(other.fatigueIndex, fatigueIndex) ||
                other.fatigueIndex == fatigueIndex) &&
            (identical(other.restStartedAt, restStartedAt) ||
                other.restStartedAt == restStartedAt) &&
            (identical(other.restDurationMs, restDurationMs) ||
                other.restDurationMs == restDurationMs) &&
            (identical(other.heartRateBpm, heartRateBpm) ||
                other.heartRateBpm == heartRateBpm) &&
            (identical(other.ambientTemperatureC, ambientTemperatureC) ||
                other.ambientTemperatureC == ambientTemperatureC) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.synced, synced) || other.synced == synced) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        exerciseId,
        workoutId,
        setNumber,
        executionTimeMs,
        startTime,
        endTime,
        reps,
        weight,
        rpe,
        const DeepCollectionEquality().hash(_repTimingsMs),
        const DeepCollectionEquality().hash(_velocityMps),
        const DeepCollectionEquality().hash(_pauseTimingsMs),
        formScore,
        consistencyScore,
        fatigueIndex,
        restStartedAt,
        restDurationMs,
        heartRateBpm,
        ambientTemperatureC,
        createdAt,
        uploadedAt,
        synced,
        const DeepCollectionEquality().hash(_metadata)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetExecutionTimingImplCopyWith<_$SetExecutionTimingImpl> get copyWith =>
      __$$SetExecutionTimingImplCopyWithImpl<_$SetExecutionTimingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetExecutionTimingImplToJson(
      this,
    );
  }
}

abstract class _SetExecutionTiming implements SetExecutionTiming {
  const factory _SetExecutionTiming(
      {required final String id,
      required final String exerciseId,
      required final String workoutId,
      required final int setNumber,
      required final int executionTimeMs,
      required final DateTime startTime,
      required final DateTime endTime,
      final int reps,
      final double? weight,
      final int rpe,
      final List<int> repTimingsMs,
      final List<double> velocityMps,
      final List<int> pauseTimingsMs,
      final double formScore,
      final double consistencyScore,
      final double fatigueIndex,
      final DateTime? restStartedAt,
      final int? restDurationMs,
      final double heartRateBpm,
      final double ambientTemperatureC,
      required final DateTime createdAt,
      final DateTime? uploadedAt,
      final bool synced,
      final Map<String, dynamic>? metadata}) = _$SetExecutionTimingImpl;

  factory _SetExecutionTiming.fromJson(Map<String, dynamic> json) =
      _$SetExecutionTimingImpl.fromJson;

  @override
  String get id;
  @override
  String get exerciseId;
  @override
  String get workoutId;
  @override
  int get setNumber;
  @override // Timing precision data (milliseconds)
  int get executionTimeMs;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override // Performance metrics
  int get reps;
  @override
  double? get weight;
  @override
  int get rpe;
  @override // Rate of Perceived Exertion
// Advanced timing analysis
  List<int> get repTimingsMs;
  @override // Individual rep timings
  List<double> get velocityMps;
  @override // Velocity per rep (m/s)
  List<int> get pauseTimingsMs;
  @override // Pauses between reps
// Quality indicators
  double get formScore;
  @override // 0-100 based on video analysis
  double get consistencyScore;
  @override // 0-100 based on rep variation
  double get fatigueIndex;
  @override // 0-100 calculated fatigue
// Environmental data
  DateTime? get restStartedAt;
  @override
  int? get restDurationMs;
  @override
  double get heartRateBpm;
  @override
  double get ambientTemperatureC;
  @override // Synchronization
  DateTime get createdAt;
  @override
  DateTime? get uploadedAt;
  @override
  bool get synced;
  @override // Metadata
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$SetExecutionTimingImplCopyWith<_$SetExecutionTimingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetTimingConfig _$SetTimingConfigFromJson(Map<String, dynamic> json) {
  return _$SetTimingConfig.fromJson(json);
}

/// @nodoc
mixin _$SetTimingConfig {
  TimingMode get mode =>
      throw _privateConstructorUsedError; // Precision settings
  int get samplingRateHz => throw _privateConstructorUsedError;
  bool get trackVelocity => throw _privateConstructorUsedError;
  bool get trackPauses => throw _privateConstructorUsedError;
  bool get trackHeartRate =>
      throw _privateConstructorUsedError; // Analysis thresholds
  int get maxSetDurationMs => throw _privateConstructorUsedError;
  int get minRepDurationMs => throw _privateConstructorUsedError;
  int get maxRepDurationMs =>
      throw _privateConstructorUsedError; // Quality thresholds
  double get maxVelocityVariationPercent => throw _privateConstructorUsedError;
  int get maxPauseBetweenRepsMs =>
      throw _privateConstructorUsedError; // Auto-detection settings
  bool get autoStartDetection => throw _privateConstructorUsedError;
  bool get autoEndDetection => throw _privateConstructorUsedError;
  int get motionThresholdMs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetTimingConfigCopyWith<SetTimingConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetTimingConfigCopyWith<$Res> {
  factory $SetTimingConfigCopyWith(
          SetTimingConfig value, $Res Function(SetTimingConfig) then) =
      _$SetTimingConfigCopyWithImpl<$Res, SetTimingConfig>;
  @useResult
  $Res call(
      {TimingMode mode,
      int samplingRateHz,
      bool trackVelocity,
      bool trackPauses,
      bool trackHeartRate,
      int maxSetDurationMs,
      int minRepDurationMs,
      int maxRepDurationMs,
      double maxVelocityVariationPercent,
      int maxPauseBetweenRepsMs,
      bool autoStartDetection,
      bool autoEndDetection,
      int motionThresholdMs});
}

/// @nodoc
class _$SetTimingConfigCopyWithImpl<$Res, $Val extends SetTimingConfig>
    implements $SetTimingConfigCopyWith<$Res> {
  _$SetTimingConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? samplingRateHz = null,
    Object? trackVelocity = null,
    Object? trackPauses = null,
    Object? trackHeartRate = null,
    Object? maxSetDurationMs = null,
    Object? minRepDurationMs = null,
    Object? maxRepDurationMs = null,
    Object? maxVelocityVariationPercent = null,
    Object? maxPauseBetweenRepsMs = null,
    Object? autoStartDetection = null,
    Object? autoEndDetection = null,
    Object? motionThresholdMs = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as TimingMode,
      samplingRateHz: null == samplingRateHz
          ? _value.samplingRateHz
          : samplingRateHz // ignore: cast_nullable_to_non_nullable
              as int,
      trackVelocity: null == trackVelocity
          ? _value.trackVelocity
          : trackVelocity // ignore: cast_nullable_to_non_nullable
              as bool,
      trackPauses: null == trackPauses
          ? _value.trackPauses
          : trackPauses // ignore: cast_nullable_to_non_nullable
              as bool,
      trackHeartRate: null == trackHeartRate
          ? _value.trackHeartRate
          : trackHeartRate // ignore: cast_nullable_to_non_nullable
              as bool,
      maxSetDurationMs: null == maxSetDurationMs
          ? _value.maxSetDurationMs
          : maxSetDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      minRepDurationMs: null == minRepDurationMs
          ? _value.minRepDurationMs
          : minRepDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      maxRepDurationMs: null == maxRepDurationMs
          ? _value.maxRepDurationMs
          : maxRepDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      maxVelocityVariationPercent: null == maxVelocityVariationPercent
          ? _value.maxVelocityVariationPercent
          : maxVelocityVariationPercent // ignore: cast_nullable_to_non_nullable
              as double,
      maxPauseBetweenRepsMs: null == maxPauseBetweenRepsMs
          ? _value.maxPauseBetweenRepsMs
          : maxPauseBetweenRepsMs // ignore: cast_nullable_to_non_nullable
              as int,
      autoStartDetection: null == autoStartDetection
          ? _value.autoStartDetection
          : autoStartDetection // ignore: cast_nullable_to_non_nullable
              as bool,
      autoEndDetection: null == autoEndDetection
          ? _value.autoEndDetection
          : autoEndDetection // ignore: cast_nullable_to_non_nullable
              as bool,
      motionThresholdMs: null == motionThresholdMs
          ? _value.motionThresholdMs
          : motionThresholdMs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$$SetTimingConfigImplCopyWith<$Res>
    implements $SetTimingConfigCopyWith<$Res> {
  factory _$$$SetTimingConfigImplCopyWith(_$$SetTimingConfigImpl value,
          $Res Function(_$$SetTimingConfigImpl) then) =
      __$$$SetTimingConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TimingMode mode,
      int samplingRateHz,
      bool trackVelocity,
      bool trackPauses,
      bool trackHeartRate,
      int maxSetDurationMs,
      int minRepDurationMs,
      int maxRepDurationMs,
      double maxVelocityVariationPercent,
      int maxPauseBetweenRepsMs,
      bool autoStartDetection,
      bool autoEndDetection,
      int motionThresholdMs});
}

/// @nodoc
class __$$$SetTimingConfigImplCopyWithImpl<$Res>
    extends _$SetTimingConfigCopyWithImpl<$Res, _$$SetTimingConfigImpl>
    implements _$$$SetTimingConfigImplCopyWith<$Res> {
  __$$$SetTimingConfigImplCopyWithImpl(_$$SetTimingConfigImpl _value,
      $Res Function(_$$SetTimingConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? samplingRateHz = null,
    Object? trackVelocity = null,
    Object? trackPauses = null,
    Object? trackHeartRate = null,
    Object? maxSetDurationMs = null,
    Object? minRepDurationMs = null,
    Object? maxRepDurationMs = null,
    Object? maxVelocityVariationPercent = null,
    Object? maxPauseBetweenRepsMs = null,
    Object? autoStartDetection = null,
    Object? autoEndDetection = null,
    Object? motionThresholdMs = null,
  }) {
    return _then(_$$SetTimingConfigImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as TimingMode,
      samplingRateHz: null == samplingRateHz
          ? _value.samplingRateHz
          : samplingRateHz // ignore: cast_nullable_to_non_nullable
              as int,
      trackVelocity: null == trackVelocity
          ? _value.trackVelocity
          : trackVelocity // ignore: cast_nullable_to_non_nullable
              as bool,
      trackPauses: null == trackPauses
          ? _value.trackPauses
          : trackPauses // ignore: cast_nullable_to_non_nullable
              as bool,
      trackHeartRate: null == trackHeartRate
          ? _value.trackHeartRate
          : trackHeartRate // ignore: cast_nullable_to_non_nullable
              as bool,
      maxSetDurationMs: null == maxSetDurationMs
          ? _value.maxSetDurationMs
          : maxSetDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      minRepDurationMs: null == minRepDurationMs
          ? _value.minRepDurationMs
          : minRepDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      maxRepDurationMs: null == maxRepDurationMs
          ? _value.maxRepDurationMs
          : maxRepDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      maxVelocityVariationPercent: null == maxVelocityVariationPercent
          ? _value.maxVelocityVariationPercent
          : maxVelocityVariationPercent // ignore: cast_nullable_to_non_nullable
              as double,
      maxPauseBetweenRepsMs: null == maxPauseBetweenRepsMs
          ? _value.maxPauseBetweenRepsMs
          : maxPauseBetweenRepsMs // ignore: cast_nullable_to_non_nullable
              as int,
      autoStartDetection: null == autoStartDetection
          ? _value.autoStartDetection
          : autoStartDetection // ignore: cast_nullable_to_non_nullable
              as bool,
      autoEndDetection: null == autoEndDetection
          ? _value.autoEndDetection
          : autoEndDetection // ignore: cast_nullable_to_non_nullable
              as bool,
      motionThresholdMs: null == motionThresholdMs
          ? _value.motionThresholdMs
          : motionThresholdMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$$SetTimingConfigImpl implements _$SetTimingConfig {
  const _$$SetTimingConfigImpl(
      {required this.mode,
      this.samplingRateHz = 10,
      this.trackVelocity = true,
      this.trackPauses = true,
      this.trackHeartRate = false,
      this.maxSetDurationMs = 2000,
      this.minRepDurationMs = 100,
      this.maxRepDurationMs = 5000,
      this.maxVelocityVariationPercent = 20.0,
      this.maxPauseBetweenRepsMs = 1000,
      this.autoStartDetection = true,
      this.autoEndDetection = true,
      this.motionThresholdMs = 500});

  factory _$$SetTimingConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$$SetTimingConfigImplFromJson(json);

  @override
  final TimingMode mode;
// Precision settings
  @override
  @JsonKey()
  final int samplingRateHz;
  @override
  @JsonKey()
  final bool trackVelocity;
  @override
  @JsonKey()
  final bool trackPauses;
  @override
  @JsonKey()
  final bool trackHeartRate;
// Analysis thresholds
  @override
  @JsonKey()
  final int maxSetDurationMs;
  @override
  @JsonKey()
  final int minRepDurationMs;
  @override
  @JsonKey()
  final int maxRepDurationMs;
// Quality thresholds
  @override
  @JsonKey()
  final double maxVelocityVariationPercent;
  @override
  @JsonKey()
  final int maxPauseBetweenRepsMs;
// Auto-detection settings
  @override
  @JsonKey()
  final bool autoStartDetection;
  @override
  @JsonKey()
  final bool autoEndDetection;
  @override
  @JsonKey()
  final int motionThresholdMs;

  @override
  String toString() {
    return 'SetTimingConfig(mode: $mode, samplingRateHz: $samplingRateHz, trackVelocity: $trackVelocity, trackPauses: $trackPauses, trackHeartRate: $trackHeartRate, maxSetDurationMs: $maxSetDurationMs, minRepDurationMs: $minRepDurationMs, maxRepDurationMs: $maxRepDurationMs, maxVelocityVariationPercent: $maxVelocityVariationPercent, maxPauseBetweenRepsMs: $maxPauseBetweenRepsMs, autoStartDetection: $autoStartDetection, autoEndDetection: $autoEndDetection, motionThresholdMs: $motionThresholdMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$SetTimingConfigImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.samplingRateHz, samplingRateHz) ||
                other.samplingRateHz == samplingRateHz) &&
            (identical(other.trackVelocity, trackVelocity) ||
                other.trackVelocity == trackVelocity) &&
            (identical(other.trackPauses, trackPauses) ||
                other.trackPauses == trackPauses) &&
            (identical(other.trackHeartRate, trackHeartRate) ||
                other.trackHeartRate == trackHeartRate) &&
            (identical(other.maxSetDurationMs, maxSetDurationMs) ||
                other.maxSetDurationMs == maxSetDurationMs) &&
            (identical(other.minRepDurationMs, minRepDurationMs) ||
                other.minRepDurationMs == minRepDurationMs) &&
            (identical(other.maxRepDurationMs, maxRepDurationMs) ||
                other.maxRepDurationMs == maxRepDurationMs) &&
            (identical(other.maxVelocityVariationPercent,
                    maxVelocityVariationPercent) ||
                other.maxVelocityVariationPercent ==
                    maxVelocityVariationPercent) &&
            (identical(other.maxPauseBetweenRepsMs, maxPauseBetweenRepsMs) ||
                other.maxPauseBetweenRepsMs == maxPauseBetweenRepsMs) &&
            (identical(other.autoStartDetection, autoStartDetection) ||
                other.autoStartDetection == autoStartDetection) &&
            (identical(other.autoEndDetection, autoEndDetection) ||
                other.autoEndDetection == autoEndDetection) &&
            (identical(other.motionThresholdMs, motionThresholdMs) ||
                other.motionThresholdMs == motionThresholdMs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      samplingRateHz,
      trackVelocity,
      trackPauses,
      trackHeartRate,
      maxSetDurationMs,
      minRepDurationMs,
      maxRepDurationMs,
      maxVelocityVariationPercent,
      maxPauseBetweenRepsMs,
      autoStartDetection,
      autoEndDetection,
      motionThresholdMs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$$SetTimingConfigImplCopyWith<_$$SetTimingConfigImpl> get copyWith =>
      __$$$SetTimingConfigImplCopyWithImpl<_$$SetTimingConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$$SetTimingConfigImplToJson(
      this,
    );
  }
}

abstract class _$SetTimingConfig implements SetTimingConfig {
  const factory _$SetTimingConfig(
      {required final TimingMode mode,
      final int samplingRateHz,
      final bool trackVelocity,
      final bool trackPauses,
      final bool trackHeartRate,
      final int maxSetDurationMs,
      final int minRepDurationMs,
      final int maxRepDurationMs,
      final double maxVelocityVariationPercent,
      final int maxPauseBetweenRepsMs,
      final bool autoStartDetection,
      final bool autoEndDetection,
      final int motionThresholdMs}) = _$$SetTimingConfigImpl;

  factory _$SetTimingConfig.fromJson(Map<String, dynamic> json) =
      _$$SetTimingConfigImpl.fromJson;

  @override
  TimingMode get mode;
  @override // Precision settings
  int get samplingRateHz;
  @override
  bool get trackVelocity;
  @override
  bool get trackPauses;
  @override
  bool get trackHeartRate;
  @override // Analysis thresholds
  int get maxSetDurationMs;
  @override
  int get minRepDurationMs;
  @override
  int get maxRepDurationMs;
  @override // Quality thresholds
  double get maxVelocityVariationPercent;
  @override
  int get maxPauseBetweenRepsMs;
  @override // Auto-detection settings
  bool get autoStartDetection;
  @override
  bool get autoEndDetection;
  @override
  int get motionThresholdMs;
  @override
  @JsonKey(ignore: true)
  _$$$SetTimingConfigImplCopyWith<_$$SetTimingConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveSetMetrics _$LiveSetMetricsFromJson(Map<String, dynamic> json) {
  return _$LiveSetMetrics.fromJson(json);
}

/// @nodoc
mixin _$LiveSetMetrics {
  String get setId => throw _privateConstructorUsedError;
  SetPhase get phase => throw _privateConstructorUsedError; // Current timing
  int get elapsedMs => throw _privateConstructorUsedError;
  int get currentRep =>
      throw _privateConstructorUsedError; // Live velocity data
  double get currentVelocityMps => throw _privateConstructorUsedError;
  double get averageVelocityMps => throw _privateConstructorUsedError;
  double get velocityDropPercent =>
      throw _privateConstructorUsedError; // Form feedback
  double get currentFormScore => throw _privateConstructorUsedError;
  double get consistencyScore =>
      throw _privateConstructorUsedError; // Fatigue indicators
  double get fatigueIndex => throw _privateConstructorUsedError;
  bool get shouldStopSet =>
      throw _privateConstructorUsedError; // Recommendations
  String? get coachingTip => throw _privateConstructorUsedError;
  double? get suggestedWeight => throw _privateConstructorUsedError;
  int? get suggestedReps => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveSetMetricsCopyWith<LiveSetMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveSetMetricsCopyWith<$Res> {
  factory $LiveSetMetricsCopyWith(
          LiveSetMetrics value, $Res Function(LiveSetMetrics) then) =
      _$LiveSetMetricsCopyWithImpl<$Res, LiveSetMetrics>;
  @useResult
  $Res call(
      {String setId,
      SetPhase phase,
      int elapsedMs,
      int currentRep,
      double currentVelocityMps,
      double averageVelocityMps,
      double velocityDropPercent,
      double currentFormScore,
      double consistencyScore,
      double fatigueIndex,
      bool shouldStopSet,
      String? coachingTip,
      double? suggestedWeight,
      int? suggestedReps,
      DateTime timestamp});
}

/// @nodoc
class _$LiveSetMetricsCopyWithImpl<$Res, $Val extends LiveSetMetrics>
    implements $LiveSetMetricsCopyWith<$Res> {
  _$LiveSetMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setId = null,
    Object? phase = null,
    Object? elapsedMs = null,
    Object? currentRep = null,
    Object? currentVelocityMps = null,
    Object? averageVelocityMps = null,
    Object? velocityDropPercent = null,
    Object? currentFormScore = null,
    Object? consistencyScore = null,
    Object? fatigueIndex = null,
    Object? shouldStopSet = null,
    Object? coachingTip = freezed,
    Object? suggestedWeight = freezed,
    Object? suggestedReps = freezed,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      setId: null == setId
          ? _value.setId
          : setId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as SetPhase,
      elapsedMs: null == elapsedMs
          ? _value.elapsedMs
          : elapsedMs // ignore: cast_nullable_to_non_nullable
              as int,
      currentRep: null == currentRep
          ? _value.currentRep
          : currentRep // ignore: cast_nullable_to_non_nullable
              as int,
      currentVelocityMps: null == currentVelocityMps
          ? _value.currentVelocityMps
          : currentVelocityMps // ignore: cast_nullable_to_non_nullable
              as double,
      averageVelocityMps: null == averageVelocityMps
          ? _value.averageVelocityMps
          : averageVelocityMps // ignore: cast_nullable_to_non_nullable
              as double,
      velocityDropPercent: null == velocityDropPercent
          ? _value.velocityDropPercent
          : velocityDropPercent // ignore: cast_nullable_to_non_nullable
              as double,
      currentFormScore: null == currentFormScore
          ? _value.currentFormScore
          : currentFormScore // ignore: cast_nullable_to_non_nullable
              as double,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as double,
      fatigueIndex: null == fatigueIndex
          ? _value.fatigueIndex
          : fatigueIndex // ignore: cast_nullable_to_non_nullable
              as double,
      shouldStopSet: null == shouldStopSet
          ? _value.shouldStopSet
          : shouldStopSet // ignore: cast_nullable_to_non_nullable
              as bool,
      coachingTip: freezed == coachingTip
          ? _value.coachingTip
          : coachingTip // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestedWeight: freezed == suggestedWeight
          ? _value.suggestedWeight
          : suggestedWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      suggestedReps: freezed == suggestedReps
          ? _value.suggestedReps
          : suggestedReps // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$$LiveSetMetricsImplCopyWith<$Res>
    implements $LiveSetMetricsCopyWith<$Res> {
  factory _$$$LiveSetMetricsImplCopyWith(_$$LiveSetMetricsImpl value,
          $Res Function(_$$LiveSetMetricsImpl) then) =
      __$$$LiveSetMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String setId,
      SetPhase phase,
      int elapsedMs,
      int currentRep,
      double currentVelocityMps,
      double averageVelocityMps,
      double velocityDropPercent,
      double currentFormScore,
      double consistencyScore,
      double fatigueIndex,
      bool shouldStopSet,
      String? coachingTip,
      double? suggestedWeight,
      int? suggestedReps,
      DateTime timestamp});
}

/// @nodoc
class __$$$LiveSetMetricsImplCopyWithImpl<$Res>
    extends _$LiveSetMetricsCopyWithImpl<$Res, _$$LiveSetMetricsImpl>
    implements _$$$LiveSetMetricsImplCopyWith<$Res> {
  __$$$LiveSetMetricsImplCopyWithImpl(
      _$$LiveSetMetricsImpl _value, $Res Function(_$$LiveSetMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setId = null,
    Object? phase = null,
    Object? elapsedMs = null,
    Object? currentRep = null,
    Object? currentVelocityMps = null,
    Object? averageVelocityMps = null,
    Object? velocityDropPercent = null,
    Object? currentFormScore = null,
    Object? consistencyScore = null,
    Object? fatigueIndex = null,
    Object? shouldStopSet = null,
    Object? coachingTip = freezed,
    Object? suggestedWeight = freezed,
    Object? suggestedReps = freezed,
    Object? timestamp = null,
  }) {
    return _then(_$$LiveSetMetricsImpl(
      setId: null == setId
          ? _value.setId
          : setId // ignore: cast_nullable_to_non_nullable
              as String,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as SetPhase,
      elapsedMs: null == elapsedMs
          ? _value.elapsedMs
          : elapsedMs // ignore: cast_nullable_to_non_nullable
              as int,
      currentRep: null == currentRep
          ? _value.currentRep
          : currentRep // ignore: cast_nullable_to_non_nullable
              as int,
      currentVelocityMps: null == currentVelocityMps
          ? _value.currentVelocityMps
          : currentVelocityMps // ignore: cast_nullable_to_non_nullable
              as double,
      averageVelocityMps: null == averageVelocityMps
          ? _value.averageVelocityMps
          : averageVelocityMps // ignore: cast_nullable_to_non_nullable
              as double,
      velocityDropPercent: null == velocityDropPercent
          ? _value.velocityDropPercent
          : velocityDropPercent // ignore: cast_nullable_to_non_nullable
              as double,
      currentFormScore: null == currentFormScore
          ? _value.currentFormScore
          : currentFormScore // ignore: cast_nullable_to_non_nullable
              as double,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as double,
      fatigueIndex: null == fatigueIndex
          ? _value.fatigueIndex
          : fatigueIndex // ignore: cast_nullable_to_non_nullable
              as double,
      shouldStopSet: null == shouldStopSet
          ? _value.shouldStopSet
          : shouldStopSet // ignore: cast_nullable_to_non_nullable
              as bool,
      coachingTip: freezed == coachingTip
          ? _value.coachingTip
          : coachingTip // ignore: cast_nullable_to_non_nullable
              as String?,
      suggestedWeight: freezed == suggestedWeight
          ? _value.suggestedWeight
          : suggestedWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      suggestedReps: freezed == suggestedReps
          ? _value.suggestedReps
          : suggestedReps // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$$LiveSetMetricsImpl implements _$LiveSetMetrics {
  const _$$LiveSetMetricsImpl(
      {required this.setId,
      required this.phase,
      required this.elapsedMs,
      required this.currentRep,
      this.currentVelocityMps = 0.0,
      this.averageVelocityMps = 0.0,
      this.velocityDropPercent = 0.0,
      this.currentFormScore = 0.0,
      this.consistencyScore = 0.0,
      this.fatigueIndex = 0.0,
      this.shouldStopSet = false,
      this.coachingTip,
      this.suggestedWeight,
      this.suggestedReps,
      required this.timestamp});

  factory _$$LiveSetMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$$LiveSetMetricsImplFromJson(json);

  @override
  final String setId;
  @override
  final SetPhase phase;
// Current timing
  @override
  final int elapsedMs;
  @override
  final int currentRep;
// Live velocity data
  @override
  @JsonKey()
  final double currentVelocityMps;
  @override
  @JsonKey()
  final double averageVelocityMps;
  @override
  @JsonKey()
  final double velocityDropPercent;
// Form feedback
  @override
  @JsonKey()
  final double currentFormScore;
  @override
  @JsonKey()
  final double consistencyScore;
// Fatigue indicators
  @override
  @JsonKey()
  final double fatigueIndex;
  @override
  @JsonKey()
  final bool shouldStopSet;
// Recommendations
  @override
  final String? coachingTip;
  @override
  final double? suggestedWeight;
  @override
  final int? suggestedReps;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'LiveSetMetrics(setId: $setId, phase: $phase, elapsedMs: $elapsedMs, currentRep: $currentRep, currentVelocityMps: $currentVelocityMps, averageVelocityMps: $averageVelocityMps, velocityDropPercent: $velocityDropPercent, currentFormScore: $currentFormScore, consistencyScore: $consistencyScore, fatigueIndex: $fatigueIndex, shouldStopSet: $shouldStopSet, coachingTip: $coachingTip, suggestedWeight: $suggestedWeight, suggestedReps: $suggestedReps, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$LiveSetMetricsImpl &&
            (identical(other.setId, setId) || other.setId == setId) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.elapsedMs, elapsedMs) ||
                other.elapsedMs == elapsedMs) &&
            (identical(other.currentRep, currentRep) ||
                other.currentRep == currentRep) &&
            (identical(other.currentVelocityMps, currentVelocityMps) ||
                other.currentVelocityMps == currentVelocityMps) &&
            (identical(other.averageVelocityMps, averageVelocityMps) ||
                other.averageVelocityMps == averageVelocityMps) &&
            (identical(other.velocityDropPercent, velocityDropPercent) ||
                other.velocityDropPercent == velocityDropPercent) &&
            (identical(other.currentFormScore, currentFormScore) ||
                other.currentFormScore == currentFormScore) &&
            (identical(other.consistencyScore, consistencyScore) ||
                other.consistencyScore == consistencyScore) &&
            (identical(other.fatigueIndex, fatigueIndex) ||
                other.fatigueIndex == fatigueIndex) &&
            (identical(other.shouldStopSet, shouldStopSet) ||
                other.shouldStopSet == shouldStopSet) &&
            (identical(other.coachingTip, coachingTip) ||
                other.coachingTip == coachingTip) &&
            (identical(other.suggestedWeight, suggestedWeight) ||
                other.suggestedWeight == suggestedWeight) &&
            (identical(other.suggestedReps, suggestedReps) ||
                other.suggestedReps == suggestedReps) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      setId,
      phase,
      elapsedMs,
      currentRep,
      currentVelocityMps,
      averageVelocityMps,
      velocityDropPercent,
      currentFormScore,
      consistencyScore,
      fatigueIndex,
      shouldStopSet,
      coachingTip,
      suggestedWeight,
      suggestedReps,
      timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$$LiveSetMetricsImplCopyWith<_$$LiveSetMetricsImpl> get copyWith =>
      __$$$LiveSetMetricsImplCopyWithImpl<_$$LiveSetMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$$LiveSetMetricsImplToJson(
      this,
    );
  }
}

abstract class _$LiveSetMetrics implements LiveSetMetrics {
  const factory _$LiveSetMetrics(
      {required final String setId,
      required final SetPhase phase,
      required final int elapsedMs,
      required final int currentRep,
      final double currentVelocityMps,
      final double averageVelocityMps,
      final double velocityDropPercent,
      final double currentFormScore,
      final double consistencyScore,
      final double fatigueIndex,
      final bool shouldStopSet,
      final String? coachingTip,
      final double? suggestedWeight,
      final int? suggestedReps,
      required final DateTime timestamp}) = _$$LiveSetMetricsImpl;

  factory _$LiveSetMetrics.fromJson(Map<String, dynamic> json) =
      _$$LiveSetMetricsImpl.fromJson;

  @override
  String get setId;
  @override
  SetPhase get phase;
  @override // Current timing
  int get elapsedMs;
  @override
  int get currentRep;
  @override // Live velocity data
  double get currentVelocityMps;
  @override
  double get averageVelocityMps;
  @override
  double get velocityDropPercent;
  @override // Form feedback
  double get currentFormScore;
  @override
  double get consistencyScore;
  @override // Fatigue indicators
  double get fatigueIndex;
  @override
  bool get shouldStopSet;
  @override // Recommendations
  String? get coachingTip;
  @override
  double? get suggestedWeight;
  @override
  int? get suggestedReps;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$$LiveSetMetricsImplCopyWith<_$$LiveSetMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
