// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggestion_accuracy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SuggestionAccuracy _$SuggestionAccuracyFromJson(Map<String, dynamic> json) {
  return _SuggestionAccuracy.fromJson(json);
}

/// @nodoc
mixin _$SuggestionAccuracy {
  /// Unique ID for this record
  String get id => throw _privateConstructorUsedError;

  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// Exercise ID from GymBro database
  String get exerciseId => throw _privateConstructorUsedError;

  /// Weight suggested by system (kg)
  double get suggestedWeight => throw _privateConstructorUsedError;

  /// Weight actually used by user (kg)
  double get actualWeight => throw _privateConstructorUsedError;

  /// Reps suggested by system
  int get suggestedReps => throw _privateConstructorUsedError;

  /// Reps actually completed by user
  int get actualReps => throw _privateConstructorUsedError;

  /// Absolute error percentage: |actual - suggested| / suggested * 100
  double get weightErrorPercent => throw _privateConstructorUsedError;

  /// Reps error: actualReps - suggestedReps (can be negative)
  int get repsError => throw _privateConstructorUsedError;

  /// Timestamp when set was performed
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Experience level at time of suggestion
  String get experienceLevel => throw _privateConstructorUsedError;

  /// Training goal at time of suggestion
  String get trainingGoal => throw _privateConstructorUsedError;

  /// Whether user found suggestion helpful (optional feedback)
  bool? get wasHelpful => throw _privateConstructorUsedError;

  /// User's perceived exertion (1-10 RPE scale)
  int? get perceivedExertion => throw _privateConstructorUsedError;

  /// Serializes this SuggestionAccuracy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SuggestionAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SuggestionAccuracyCopyWith<SuggestionAccuracy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuggestionAccuracyCopyWith<$Res> {
  factory $SuggestionAccuracyCopyWith(
    SuggestionAccuracy value,
    $Res Function(SuggestionAccuracy) then,
  ) = _$SuggestionAccuracyCopyWithImpl<$Res, SuggestionAccuracy>;
  @useResult
  $Res call({
    String id,
    String userId,
    String exerciseId,
    double suggestedWeight,
    double actualWeight,
    int suggestedReps,
    int actualReps,
    double weightErrorPercent,
    int repsError,
    DateTime timestamp,
    String experienceLevel,
    String trainingGoal,
    bool? wasHelpful,
    int? perceivedExertion,
  });
}

/// @nodoc
class _$SuggestionAccuracyCopyWithImpl<$Res, $Val extends SuggestionAccuracy>
    implements $SuggestionAccuracyCopyWith<$Res> {
  _$SuggestionAccuracyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SuggestionAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? exerciseId = null,
    Object? suggestedWeight = null,
    Object? actualWeight = null,
    Object? suggestedReps = null,
    Object? actualReps = null,
    Object? weightErrorPercent = null,
    Object? repsError = null,
    Object? timestamp = null,
    Object? experienceLevel = null,
    Object? trainingGoal = null,
    Object? wasHelpful = freezed,
    Object? perceivedExertion = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestedWeight: null == suggestedWeight
                ? _value.suggestedWeight
                : suggestedWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            actualWeight: null == actualWeight
                ? _value.actualWeight
                : actualWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            suggestedReps: null == suggestedReps
                ? _value.suggestedReps
                : suggestedReps // ignore: cast_nullable_to_non_nullable
                      as int,
            actualReps: null == actualReps
                ? _value.actualReps
                : actualReps // ignore: cast_nullable_to_non_nullable
                      as int,
            weightErrorPercent: null == weightErrorPercent
                ? _value.weightErrorPercent
                : weightErrorPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            repsError: null == repsError
                ? _value.repsError
                : repsError // ignore: cast_nullable_to_non_nullable
                      as int,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            experienceLevel: null == experienceLevel
                ? _value.experienceLevel
                : experienceLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            trainingGoal: null == trainingGoal
                ? _value.trainingGoal
                : trainingGoal // ignore: cast_nullable_to_non_nullable
                      as String,
            wasHelpful: freezed == wasHelpful
                ? _value.wasHelpful
                : wasHelpful // ignore: cast_nullable_to_non_nullable
                      as bool?,
            perceivedExertion: freezed == perceivedExertion
                ? _value.perceivedExertion
                : perceivedExertion // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SuggestionAccuracyImplCopyWith<$Res>
    implements $SuggestionAccuracyCopyWith<$Res> {
  factory _$$SuggestionAccuracyImplCopyWith(
    _$SuggestionAccuracyImpl value,
    $Res Function(_$SuggestionAccuracyImpl) then,
  ) = __$$SuggestionAccuracyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String exerciseId,
    double suggestedWeight,
    double actualWeight,
    int suggestedReps,
    int actualReps,
    double weightErrorPercent,
    int repsError,
    DateTime timestamp,
    String experienceLevel,
    String trainingGoal,
    bool? wasHelpful,
    int? perceivedExertion,
  });
}

/// @nodoc
class __$$SuggestionAccuracyImplCopyWithImpl<$Res>
    extends _$SuggestionAccuracyCopyWithImpl<$Res, _$SuggestionAccuracyImpl>
    implements _$$SuggestionAccuracyImplCopyWith<$Res> {
  __$$SuggestionAccuracyImplCopyWithImpl(
    _$SuggestionAccuracyImpl _value,
    $Res Function(_$SuggestionAccuracyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SuggestionAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? exerciseId = null,
    Object? suggestedWeight = null,
    Object? actualWeight = null,
    Object? suggestedReps = null,
    Object? actualReps = null,
    Object? weightErrorPercent = null,
    Object? repsError = null,
    Object? timestamp = null,
    Object? experienceLevel = null,
    Object? trainingGoal = null,
    Object? wasHelpful = freezed,
    Object? perceivedExertion = freezed,
  }) {
    return _then(
      _$SuggestionAccuracyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestedWeight: null == suggestedWeight
            ? _value.suggestedWeight
            : suggestedWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        actualWeight: null == actualWeight
            ? _value.actualWeight
            : actualWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        suggestedReps: null == suggestedReps
            ? _value.suggestedReps
            : suggestedReps // ignore: cast_nullable_to_non_nullable
                  as int,
        actualReps: null == actualReps
            ? _value.actualReps
            : actualReps // ignore: cast_nullable_to_non_nullable
                  as int,
        weightErrorPercent: null == weightErrorPercent
            ? _value.weightErrorPercent
            : weightErrorPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        repsError: null == repsError
            ? _value.repsError
            : repsError // ignore: cast_nullable_to_non_nullable
                  as int,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        experienceLevel: null == experienceLevel
            ? _value.experienceLevel
            : experienceLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        trainingGoal: null == trainingGoal
            ? _value.trainingGoal
            : trainingGoal // ignore: cast_nullable_to_non_nullable
                  as String,
        wasHelpful: freezed == wasHelpful
            ? _value.wasHelpful
            : wasHelpful // ignore: cast_nullable_to_non_nullable
                  as bool?,
        perceivedExertion: freezed == perceivedExertion
            ? _value.perceivedExertion
            : perceivedExertion // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SuggestionAccuracyImpl implements _SuggestionAccuracy {
  const _$SuggestionAccuracyImpl({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.suggestedWeight,
    required this.actualWeight,
    required this.suggestedReps,
    required this.actualReps,
    required this.weightErrorPercent,
    required this.repsError,
    required this.timestamp,
    required this.experienceLevel,
    required this.trainingGoal,
    this.wasHelpful,
    this.perceivedExertion,
  });

  factory _$SuggestionAccuracyImpl.fromJson(Map<String, dynamic> json) =>
      _$$SuggestionAccuracyImplFromJson(json);

  /// Unique ID for this record
  @override
  final String id;

  /// User ID
  @override
  final String userId;

  /// Exercise ID from GymBro database
  @override
  final String exerciseId;

  /// Weight suggested by system (kg)
  @override
  final double suggestedWeight;

  /// Weight actually used by user (kg)
  @override
  final double actualWeight;

  /// Reps suggested by system
  @override
  final int suggestedReps;

  /// Reps actually completed by user
  @override
  final int actualReps;

  /// Absolute error percentage: |actual - suggested| / suggested * 100
  @override
  final double weightErrorPercent;

  /// Reps error: actualReps - suggestedReps (can be negative)
  @override
  final int repsError;

  /// Timestamp when set was performed
  @override
  final DateTime timestamp;

  /// Experience level at time of suggestion
  @override
  final String experienceLevel;

  /// Training goal at time of suggestion
  @override
  final String trainingGoal;

  /// Whether user found suggestion helpful (optional feedback)
  @override
  final bool? wasHelpful;

  /// User's perceived exertion (1-10 RPE scale)
  @override
  final int? perceivedExertion;

  @override
  String toString() {
    return 'SuggestionAccuracy(id: $id, userId: $userId, exerciseId: $exerciseId, suggestedWeight: $suggestedWeight, actualWeight: $actualWeight, suggestedReps: $suggestedReps, actualReps: $actualReps, weightErrorPercent: $weightErrorPercent, repsError: $repsError, timestamp: $timestamp, experienceLevel: $experienceLevel, trainingGoal: $trainingGoal, wasHelpful: $wasHelpful, perceivedExertion: $perceivedExertion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuggestionAccuracyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.suggestedWeight, suggestedWeight) ||
                other.suggestedWeight == suggestedWeight) &&
            (identical(other.actualWeight, actualWeight) ||
                other.actualWeight == actualWeight) &&
            (identical(other.suggestedReps, suggestedReps) ||
                other.suggestedReps == suggestedReps) &&
            (identical(other.actualReps, actualReps) ||
                other.actualReps == actualReps) &&
            (identical(other.weightErrorPercent, weightErrorPercent) ||
                other.weightErrorPercent == weightErrorPercent) &&
            (identical(other.repsError, repsError) ||
                other.repsError == repsError) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.experienceLevel, experienceLevel) ||
                other.experienceLevel == experienceLevel) &&
            (identical(other.trainingGoal, trainingGoal) ||
                other.trainingGoal == trainingGoal) &&
            (identical(other.wasHelpful, wasHelpful) ||
                other.wasHelpful == wasHelpful) &&
            (identical(other.perceivedExertion, perceivedExertion) ||
                other.perceivedExertion == perceivedExertion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    exerciseId,
    suggestedWeight,
    actualWeight,
    suggestedReps,
    actualReps,
    weightErrorPercent,
    repsError,
    timestamp,
    experienceLevel,
    trainingGoal,
    wasHelpful,
    perceivedExertion,
  );

  /// Create a copy of SuggestionAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuggestionAccuracyImplCopyWith<_$SuggestionAccuracyImpl> get copyWith =>
      __$$SuggestionAccuracyImplCopyWithImpl<_$SuggestionAccuracyImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SuggestionAccuracyImplToJson(this);
  }
}

abstract class _SuggestionAccuracy implements SuggestionAccuracy {
  const factory _SuggestionAccuracy({
    required final String id,
    required final String userId,
    required final String exerciseId,
    required final double suggestedWeight,
    required final double actualWeight,
    required final int suggestedReps,
    required final int actualReps,
    required final double weightErrorPercent,
    required final int repsError,
    required final DateTime timestamp,
    required final String experienceLevel,
    required final String trainingGoal,
    final bool? wasHelpful,
    final int? perceivedExertion,
  }) = _$SuggestionAccuracyImpl;

  factory _SuggestionAccuracy.fromJson(Map<String, dynamic> json) =
      _$SuggestionAccuracyImpl.fromJson;

  /// Unique ID for this record
  @override
  String get id;

  /// User ID
  @override
  String get userId;

  /// Exercise ID from GymBro database
  @override
  String get exerciseId;

  /// Weight suggested by system (kg)
  @override
  double get suggestedWeight;

  /// Weight actually used by user (kg)
  @override
  double get actualWeight;

  /// Reps suggested by system
  @override
  int get suggestedReps;

  /// Reps actually completed by user
  @override
  int get actualReps;

  /// Absolute error percentage: |actual - suggested| / suggested * 100
  @override
  double get weightErrorPercent;

  /// Reps error: actualReps - suggestedReps (can be negative)
  @override
  int get repsError;

  /// Timestamp when set was performed
  @override
  DateTime get timestamp;

  /// Experience level at time of suggestion
  @override
  String get experienceLevel;

  /// Training goal at time of suggestion
  @override
  String get trainingGoal;

  /// Whether user found suggestion helpful (optional feedback)
  @override
  bool? get wasHelpful;

  /// User's perceived exertion (1-10 RPE scale)
  @override
  int? get perceivedExertion;

  /// Create a copy of SuggestionAccuracy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuggestionAccuracyImplCopyWith<_$SuggestionAccuracyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
