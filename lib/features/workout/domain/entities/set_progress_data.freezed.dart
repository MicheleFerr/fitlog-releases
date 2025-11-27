// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_progress_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SetProgressData _$SetProgressDataFromJson(Map<String, dynamic> json) {
  return _SetProgressData.fromJson(json);
}

/// @nodoc
mixin _$SetProgressData {
  /// Current weight being lifted
  double get currentWeight => throw _privateConstructorUsedError;

  /// Weight from last workout for same exercise/set
  double get lastWeight => throw _privateConstructorUsedError;

  /// Current reps being performed
  int get currentReps => throw _privateConstructorUsedError;

  /// Reps from last workout for same exercise/set
  int get lastReps => throw _privateConstructorUsedError;

  /// Date of the last workout for reference
  DateTime get lastWorkoutDate => throw _privateConstructorUsedError;

  /// Set number this comparison is for
  int get setNumber => throw _privateConstructorUsedError;

  /// Exercise name for reference
  String get exerciseName => throw _privateConstructorUsedError;

  /// Serializes this SetProgressData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetProgressDataCopyWith<SetProgressData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetProgressDataCopyWith<$Res> {
  factory $SetProgressDataCopyWith(
    SetProgressData value,
    $Res Function(SetProgressData) then,
  ) = _$SetProgressDataCopyWithImpl<$Res, SetProgressData>;
  @useResult
  $Res call({
    double currentWeight,
    double lastWeight,
    int currentReps,
    int lastReps,
    DateTime lastWorkoutDate,
    int setNumber,
    String exerciseName,
  });
}

/// @nodoc
class _$SetProgressDataCopyWithImpl<$Res, $Val extends SetProgressData>
    implements $SetProgressDataCopyWith<$Res> {
  _$SetProgressDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentWeight = null,
    Object? lastWeight = null,
    Object? currentReps = null,
    Object? lastReps = null,
    Object? lastWorkoutDate = null,
    Object? setNumber = null,
    Object? exerciseName = null,
  }) {
    return _then(
      _value.copyWith(
            currentWeight: null == currentWeight
                ? _value.currentWeight
                : currentWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            lastWeight: null == lastWeight
                ? _value.lastWeight
                : lastWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            currentReps: null == currentReps
                ? _value.currentReps
                : currentReps // ignore: cast_nullable_to_non_nullable
                      as int,
            lastReps: null == lastReps
                ? _value.lastReps
                : lastReps // ignore: cast_nullable_to_non_nullable
                      as int,
            lastWorkoutDate: null == lastWorkoutDate
                ? _value.lastWorkoutDate
                : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetProgressDataImplCopyWith<$Res>
    implements $SetProgressDataCopyWith<$Res> {
  factory _$$SetProgressDataImplCopyWith(
    _$SetProgressDataImpl value,
    $Res Function(_$SetProgressDataImpl) then,
  ) = __$$SetProgressDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double currentWeight,
    double lastWeight,
    int currentReps,
    int lastReps,
    DateTime lastWorkoutDate,
    int setNumber,
    String exerciseName,
  });
}

/// @nodoc
class __$$SetProgressDataImplCopyWithImpl<$Res>
    extends _$SetProgressDataCopyWithImpl<$Res, _$SetProgressDataImpl>
    implements _$$SetProgressDataImplCopyWith<$Res> {
  __$$SetProgressDataImplCopyWithImpl(
    _$SetProgressDataImpl _value,
    $Res Function(_$SetProgressDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentWeight = null,
    Object? lastWeight = null,
    Object? currentReps = null,
    Object? lastReps = null,
    Object? lastWorkoutDate = null,
    Object? setNumber = null,
    Object? exerciseName = null,
  }) {
    return _then(
      _$SetProgressDataImpl(
        currentWeight: null == currentWeight
            ? _value.currentWeight
            : currentWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        lastWeight: null == lastWeight
            ? _value.lastWeight
            : lastWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        currentReps: null == currentReps
            ? _value.currentReps
            : currentReps // ignore: cast_nullable_to_non_nullable
                  as int,
        lastReps: null == lastReps
            ? _value.lastReps
            : lastReps // ignore: cast_nullable_to_non_nullable
                  as int,
        lastWorkoutDate: null == lastWorkoutDate
            ? _value.lastWorkoutDate
            : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SetProgressDataImpl extends _SetProgressData {
  const _$SetProgressDataImpl({
    required this.currentWeight,
    required this.lastWeight,
    required this.currentReps,
    required this.lastReps,
    required this.lastWorkoutDate,
    required this.setNumber,
    required this.exerciseName,
  }) : super._();

  factory _$SetProgressDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetProgressDataImplFromJson(json);

  /// Current weight being lifted
  @override
  final double currentWeight;

  /// Weight from last workout for same exercise/set
  @override
  final double lastWeight;

  /// Current reps being performed
  @override
  final int currentReps;

  /// Reps from last workout for same exercise/set
  @override
  final int lastReps;

  /// Date of the last workout for reference
  @override
  final DateTime lastWorkoutDate;

  /// Set number this comparison is for
  @override
  final int setNumber;

  /// Exercise name for reference
  @override
  final String exerciseName;

  @override
  String toString() {
    return 'SetProgressData(currentWeight: $currentWeight, lastWeight: $lastWeight, currentReps: $currentReps, lastReps: $lastReps, lastWorkoutDate: $lastWorkoutDate, setNumber: $setNumber, exerciseName: $exerciseName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetProgressDataImpl &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.lastWeight, lastWeight) ||
                other.lastWeight == lastWeight) &&
            (identical(other.currentReps, currentReps) ||
                other.currentReps == currentReps) &&
            (identical(other.lastReps, lastReps) ||
                other.lastReps == lastReps) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentWeight,
    lastWeight,
    currentReps,
    lastReps,
    lastWorkoutDate,
    setNumber,
    exerciseName,
  );

  /// Create a copy of SetProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetProgressDataImplCopyWith<_$SetProgressDataImpl> get copyWith =>
      __$$SetProgressDataImplCopyWithImpl<_$SetProgressDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SetProgressDataImplToJson(this);
  }
}

abstract class _SetProgressData extends SetProgressData {
  const factory _SetProgressData({
    required final double currentWeight,
    required final double lastWeight,
    required final int currentReps,
    required final int lastReps,
    required final DateTime lastWorkoutDate,
    required final int setNumber,
    required final String exerciseName,
  }) = _$SetProgressDataImpl;
  const _SetProgressData._() : super._();

  factory _SetProgressData.fromJson(Map<String, dynamic> json) =
      _$SetProgressDataImpl.fromJson;

  /// Current weight being lifted
  @override
  double get currentWeight;

  /// Weight from last workout for same exercise/set
  @override
  double get lastWeight;

  /// Current reps being performed
  @override
  int get currentReps;

  /// Reps from last workout for same exercise/set
  @override
  int get lastReps;

  /// Date of the last workout for reference
  @override
  DateTime get lastWorkoutDate;

  /// Set number this comparison is for
  @override
  int get setNumber;

  /// Exercise name for reference
  @override
  String get exerciseName;

  /// Create a copy of SetProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetProgressDataImplCopyWith<_$SetProgressDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetProgressParams _$SetProgressParamsFromJson(Map<String, dynamic> json) {
  return _SetProgressParams.fromJson(json);
}

/// @nodoc
mixin _$SetProgressParams {
  String get exerciseName => throw _privateConstructorUsedError;
  int get setNumber => throw _privateConstructorUsedError;
  double get currentWeight => throw _privateConstructorUsedError;
  int get currentReps => throw _privateConstructorUsedError;

  /// Serializes this SetProgressParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetProgressParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetProgressParamsCopyWith<SetProgressParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetProgressParamsCopyWith<$Res> {
  factory $SetProgressParamsCopyWith(
    SetProgressParams value,
    $Res Function(SetProgressParams) then,
  ) = _$SetProgressParamsCopyWithImpl<$Res, SetProgressParams>;
  @useResult
  $Res call({
    String exerciseName,
    int setNumber,
    double currentWeight,
    int currentReps,
  });
}

/// @nodoc
class _$SetProgressParamsCopyWithImpl<$Res, $Val extends SetProgressParams>
    implements $SetProgressParamsCopyWith<$Res> {
  _$SetProgressParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetProgressParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? setNumber = null,
    Object? currentWeight = null,
    Object? currentReps = null,
  }) {
    return _then(
      _value.copyWith(
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            currentWeight: null == currentWeight
                ? _value.currentWeight
                : currentWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            currentReps: null == currentReps
                ? _value.currentReps
                : currentReps // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetProgressParamsImplCopyWith<$Res>
    implements $SetProgressParamsCopyWith<$Res> {
  factory _$$SetProgressParamsImplCopyWith(
    _$SetProgressParamsImpl value,
    $Res Function(_$SetProgressParamsImpl) then,
  ) = __$$SetProgressParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String exerciseName,
    int setNumber,
    double currentWeight,
    int currentReps,
  });
}

/// @nodoc
class __$$SetProgressParamsImplCopyWithImpl<$Res>
    extends _$SetProgressParamsCopyWithImpl<$Res, _$SetProgressParamsImpl>
    implements _$$SetProgressParamsImplCopyWith<$Res> {
  __$$SetProgressParamsImplCopyWithImpl(
    _$SetProgressParamsImpl _value,
    $Res Function(_$SetProgressParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetProgressParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? setNumber = null,
    Object? currentWeight = null,
    Object? currentReps = null,
  }) {
    return _then(
      _$SetProgressParamsImpl(
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        currentWeight: null == currentWeight
            ? _value.currentWeight
            : currentWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        currentReps: null == currentReps
            ? _value.currentReps
            : currentReps // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SetProgressParamsImpl implements _SetProgressParams {
  const _$SetProgressParamsImpl({
    required this.exerciseName,
    required this.setNumber,
    required this.currentWeight,
    required this.currentReps,
  });

  factory _$SetProgressParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetProgressParamsImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final int setNumber;
  @override
  final double currentWeight;
  @override
  final int currentReps;

  @override
  String toString() {
    return 'SetProgressParams(exerciseName: $exerciseName, setNumber: $setNumber, currentWeight: $currentWeight, currentReps: $currentReps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetProgressParamsImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.currentReps, currentReps) ||
                other.currentReps == currentReps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exerciseName,
    setNumber,
    currentWeight,
    currentReps,
  );

  /// Create a copy of SetProgressParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetProgressParamsImplCopyWith<_$SetProgressParamsImpl> get copyWith =>
      __$$SetProgressParamsImplCopyWithImpl<_$SetProgressParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SetProgressParamsImplToJson(this);
  }
}

abstract class _SetProgressParams implements SetProgressParams {
  const factory _SetProgressParams({
    required final String exerciseName,
    required final int setNumber,
    required final double currentWeight,
    required final int currentReps,
  }) = _$SetProgressParamsImpl;

  factory _SetProgressParams.fromJson(Map<String, dynamic> json) =
      _$SetProgressParamsImpl.fromJson;

  @override
  String get exerciseName;
  @override
  int get setNumber;
  @override
  double get currentWeight;
  @override
  int get currentReps;

  /// Create a copy of SetProgressParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetProgressParamsImplCopyWith<_$SetProgressParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
