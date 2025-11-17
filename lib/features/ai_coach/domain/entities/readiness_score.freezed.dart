// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'readiness_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReadinessScore _$ReadinessScoreFromJson(Map<String, dynamic> json) {
  return _ReadinessScore.fromJson(json);
}

/// @nodoc
mixin _$ReadinessScore {
  /// Readiness score (0-100)
  ///
  /// **Interpretation**:
  /// - 90-100: Optimal (🔥)
  /// - 75-89: Good (💪)
  /// - 60-74: Moderate (😐)
  /// - 40-59: Low (😴)
  /// - 0-39: Very Low (🚫)
  int get score => throw _privateConstructorUsedError;

  /// Category derived from score
  ReadinessCategory get category => throw _privateConstructorUsedError;

  /// Human-readable recommendation
  ///
  /// **Examples**:
  /// - "Great! Ready for a challenging workout."
  /// - "Moderate energy. Consider a light workout."
  /// - "Low readiness. Active recovery or rest recommended."
  String get recommendation => throw _privateConstructorUsedError;

  /// Optional: Factors contributing to score
  ReadinessFactors? get factors => throw _privateConstructorUsedError;

  /// Timestamp when score was calculated
  DateTime? get calculatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadinessScoreCopyWith<ReadinessScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadinessScoreCopyWith<$Res> {
  factory $ReadinessScoreCopyWith(
          ReadinessScore value, $Res Function(ReadinessScore) then) =
      _$ReadinessScoreCopyWithImpl<$Res, ReadinessScore>;
  @useResult
  $Res call(
      {int score,
      ReadinessCategory category,
      String recommendation,
      ReadinessFactors? factors,
      DateTime? calculatedAt});

  $ReadinessFactorsCopyWith<$Res>? get factors;
}

/// @nodoc
class _$ReadinessScoreCopyWithImpl<$Res, $Val extends ReadinessScore>
    implements $ReadinessScoreCopyWith<$Res> {
  _$ReadinessScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? category = null,
    Object? recommendation = null,
    Object? factors = freezed,
    Object? calculatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ReadinessCategory,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      factors: freezed == factors
          ? _value.factors
          : factors // ignore: cast_nullable_to_non_nullable
              as ReadinessFactors?,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ReadinessFactorsCopyWith<$Res>? get factors {
    if (_value.factors == null) {
      return null;
    }

    return $ReadinessFactorsCopyWith<$Res>(_value.factors!, (value) {
      return _then(_value.copyWith(factors: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReadinessScoreImplCopyWith<$Res>
    implements $ReadinessScoreCopyWith<$Res> {
  factory _$$ReadinessScoreImplCopyWith(_$ReadinessScoreImpl value,
          $Res Function(_$ReadinessScoreImpl) then) =
      __$$ReadinessScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int score,
      ReadinessCategory category,
      String recommendation,
      ReadinessFactors? factors,
      DateTime? calculatedAt});

  @override
  $ReadinessFactorsCopyWith<$Res>? get factors;
}

/// @nodoc
class __$$ReadinessScoreImplCopyWithImpl<$Res>
    extends _$ReadinessScoreCopyWithImpl<$Res, _$ReadinessScoreImpl>
    implements _$$ReadinessScoreImplCopyWith<$Res> {
  __$$ReadinessScoreImplCopyWithImpl(
      _$ReadinessScoreImpl _value, $Res Function(_$ReadinessScoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? category = null,
    Object? recommendation = null,
    Object? factors = freezed,
    Object? calculatedAt = freezed,
  }) {
    return _then(_$ReadinessScoreImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ReadinessCategory,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      factors: freezed == factors
          ? _value.factors
          : factors // ignore: cast_nullable_to_non_nullable
              as ReadinessFactors?,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadinessScoreImpl extends _ReadinessScore {
  const _$ReadinessScoreImpl(
      {required this.score,
      required this.category,
      required this.recommendation,
      this.factors,
      this.calculatedAt = null})
      : super._();

  factory _$ReadinessScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadinessScoreImplFromJson(json);

  /// Readiness score (0-100)
  ///
  /// **Interpretation**:
  /// - 90-100: Optimal (🔥)
  /// - 75-89: Good (💪)
  /// - 60-74: Moderate (😐)
  /// - 40-59: Low (😴)
  /// - 0-39: Very Low (🚫)
  @override
  final int score;

  /// Category derived from score
  @override
  final ReadinessCategory category;

  /// Human-readable recommendation
  ///
  /// **Examples**:
  /// - "Great! Ready for a challenging workout."
  /// - "Moderate energy. Consider a light workout."
  /// - "Low readiness. Active recovery or rest recommended."
  @override
  final String recommendation;

  /// Optional: Factors contributing to score
  @override
  final ReadinessFactors? factors;

  /// Timestamp when score was calculated
  @override
  @JsonKey()
  final DateTime? calculatedAt;

  @override
  String toString() {
    return 'ReadinessScore(score: $score, category: $category, recommendation: $recommendation, factors: $factors, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadinessScoreImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.factors, factors) || other.factors == factors) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, score, category, recommendation, factors, calculatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadinessScoreImplCopyWith<_$ReadinessScoreImpl> get copyWith =>
      __$$ReadinessScoreImplCopyWithImpl<_$ReadinessScoreImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadinessScoreImplToJson(
      this,
    );
  }
}

abstract class _ReadinessScore extends ReadinessScore {
  const factory _ReadinessScore(
      {required final int score,
      required final ReadinessCategory category,
      required final String recommendation,
      final ReadinessFactors? factors,
      final DateTime? calculatedAt}) = _$ReadinessScoreImpl;
  const _ReadinessScore._() : super._();

  factory _ReadinessScore.fromJson(Map<String, dynamic> json) =
      _$ReadinessScoreImpl.fromJson;

  @override

  /// Readiness score (0-100)
  ///
  /// **Interpretation**:
  /// - 90-100: Optimal (🔥)
  /// - 75-89: Good (💪)
  /// - 60-74: Moderate (😐)
  /// - 40-59: Low (😴)
  /// - 0-39: Very Low (🚫)
  int get score;
  @override

  /// Category derived from score
  ReadinessCategory get category;
  @override

  /// Human-readable recommendation
  ///
  /// **Examples**:
  /// - "Great! Ready for a challenging workout."
  /// - "Moderate energy. Consider a light workout."
  /// - "Low readiness. Active recovery or rest recommended."
  String get recommendation;
  @override

  /// Optional: Factors contributing to score
  ReadinessFactors? get factors;
  @override

  /// Timestamp when score was calculated
  DateTime? get calculatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ReadinessScoreImplCopyWith<_$ReadinessScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReadinessFactors _$ReadinessFactorsFromJson(Map<String, dynamic> json) {
  return _ReadinessFactors.fromJson(json);
}

/// @nodoc
mixin _$ReadinessFactors {
  /// Workout frequency score (0-100)
  ///
  /// **Calculation**: Recent training volume vs baseline (40% weight)
  int get workoutFrequencyScore => throw _privateConstructorUsedError;

  /// Recovery time score (0-100)
  ///
  /// **Calculation**: Days since last workout (30% weight)
  int get recoveryTimeScore => throw _privateConstructorUsedError;

  /// Training consistency score (0-100)
  ///
  /// **Calculation**: Adherence to workout schedule (30% weight)
  int get consistencyScore => throw _privateConstructorUsedError;

  /// Optional: Days since last workout
  int? get daysSinceLastWorkout => throw _privateConstructorUsedError;

  /// Optional: Workouts in last 7 days
  int? get workoutsLast7Days => throw _privateConstructorUsedError;

  /// Optional: Average workouts per week
  double? get avgWorkoutsPerWeek => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadinessFactorsCopyWith<ReadinessFactors> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadinessFactorsCopyWith<$Res> {
  factory $ReadinessFactorsCopyWith(
          ReadinessFactors value, $Res Function(ReadinessFactors) then) =
      _$ReadinessFactorsCopyWithImpl<$Res, ReadinessFactors>;
  @useResult
  $Res call(
      {int workoutFrequencyScore,
      int recoveryTimeScore,
      int consistencyScore,
      int? daysSinceLastWorkout,
      int? workoutsLast7Days,
      double? avgWorkoutsPerWeek});
}

/// @nodoc
class _$ReadinessFactorsCopyWithImpl<$Res, $Val extends ReadinessFactors>
    implements $ReadinessFactorsCopyWith<$Res> {
  _$ReadinessFactorsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutFrequencyScore = null,
    Object? recoveryTimeScore = null,
    Object? consistencyScore = null,
    Object? daysSinceLastWorkout = freezed,
    Object? workoutsLast7Days = freezed,
    Object? avgWorkoutsPerWeek = freezed,
  }) {
    return _then(_value.copyWith(
      workoutFrequencyScore: null == workoutFrequencyScore
          ? _value.workoutFrequencyScore
          : workoutFrequencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      recoveryTimeScore: null == recoveryTimeScore
          ? _value.recoveryTimeScore
          : recoveryTimeScore // ignore: cast_nullable_to_non_nullable
              as int,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      daysSinceLastWorkout: freezed == daysSinceLastWorkout
          ? _value.daysSinceLastWorkout
          : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
              as int?,
      workoutsLast7Days: freezed == workoutsLast7Days
          ? _value.workoutsLast7Days
          : workoutsLast7Days // ignore: cast_nullable_to_non_nullable
              as int?,
      avgWorkoutsPerWeek: freezed == avgWorkoutsPerWeek
          ? _value.avgWorkoutsPerWeek
          : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReadinessFactorsImplCopyWith<$Res>
    implements $ReadinessFactorsCopyWith<$Res> {
  factory _$$ReadinessFactorsImplCopyWith(_$ReadinessFactorsImpl value,
          $Res Function(_$ReadinessFactorsImpl) then) =
      __$$ReadinessFactorsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int workoutFrequencyScore,
      int recoveryTimeScore,
      int consistencyScore,
      int? daysSinceLastWorkout,
      int? workoutsLast7Days,
      double? avgWorkoutsPerWeek});
}

/// @nodoc
class __$$ReadinessFactorsImplCopyWithImpl<$Res>
    extends _$ReadinessFactorsCopyWithImpl<$Res, _$ReadinessFactorsImpl>
    implements _$$ReadinessFactorsImplCopyWith<$Res> {
  __$$ReadinessFactorsImplCopyWithImpl(_$ReadinessFactorsImpl _value,
      $Res Function(_$ReadinessFactorsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutFrequencyScore = null,
    Object? recoveryTimeScore = null,
    Object? consistencyScore = null,
    Object? daysSinceLastWorkout = freezed,
    Object? workoutsLast7Days = freezed,
    Object? avgWorkoutsPerWeek = freezed,
  }) {
    return _then(_$ReadinessFactorsImpl(
      workoutFrequencyScore: null == workoutFrequencyScore
          ? _value.workoutFrequencyScore
          : workoutFrequencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      recoveryTimeScore: null == recoveryTimeScore
          ? _value.recoveryTimeScore
          : recoveryTimeScore // ignore: cast_nullable_to_non_nullable
              as int,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      daysSinceLastWorkout: freezed == daysSinceLastWorkout
          ? _value.daysSinceLastWorkout
          : daysSinceLastWorkout // ignore: cast_nullable_to_non_nullable
              as int?,
      workoutsLast7Days: freezed == workoutsLast7Days
          ? _value.workoutsLast7Days
          : workoutsLast7Days // ignore: cast_nullable_to_non_nullable
              as int?,
      avgWorkoutsPerWeek: freezed == avgWorkoutsPerWeek
          ? _value.avgWorkoutsPerWeek
          : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadinessFactorsImpl implements _ReadinessFactors {
  const _$ReadinessFactorsImpl(
      {required this.workoutFrequencyScore,
      required this.recoveryTimeScore,
      required this.consistencyScore,
      this.daysSinceLastWorkout,
      this.workoutsLast7Days,
      this.avgWorkoutsPerWeek});

  factory _$ReadinessFactorsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadinessFactorsImplFromJson(json);

  /// Workout frequency score (0-100)
  ///
  /// **Calculation**: Recent training volume vs baseline (40% weight)
  @override
  final int workoutFrequencyScore;

  /// Recovery time score (0-100)
  ///
  /// **Calculation**: Days since last workout (30% weight)
  @override
  final int recoveryTimeScore;

  /// Training consistency score (0-100)
  ///
  /// **Calculation**: Adherence to workout schedule (30% weight)
  @override
  final int consistencyScore;

  /// Optional: Days since last workout
  @override
  final int? daysSinceLastWorkout;

  /// Optional: Workouts in last 7 days
  @override
  final int? workoutsLast7Days;

  /// Optional: Average workouts per week
  @override
  final double? avgWorkoutsPerWeek;

  @override
  String toString() {
    return 'ReadinessFactors(workoutFrequencyScore: $workoutFrequencyScore, recoveryTimeScore: $recoveryTimeScore, consistencyScore: $consistencyScore, daysSinceLastWorkout: $daysSinceLastWorkout, workoutsLast7Days: $workoutsLast7Days, avgWorkoutsPerWeek: $avgWorkoutsPerWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadinessFactorsImpl &&
            (identical(other.workoutFrequencyScore, workoutFrequencyScore) ||
                other.workoutFrequencyScore == workoutFrequencyScore) &&
            (identical(other.recoveryTimeScore, recoveryTimeScore) ||
                other.recoveryTimeScore == recoveryTimeScore) &&
            (identical(other.consistencyScore, consistencyScore) ||
                other.consistencyScore == consistencyScore) &&
            (identical(other.daysSinceLastWorkout, daysSinceLastWorkout) ||
                other.daysSinceLastWorkout == daysSinceLastWorkout) &&
            (identical(other.workoutsLast7Days, workoutsLast7Days) ||
                other.workoutsLast7Days == workoutsLast7Days) &&
            (identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) ||
                other.avgWorkoutsPerWeek == avgWorkoutsPerWeek));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      workoutFrequencyScore,
      recoveryTimeScore,
      consistencyScore,
      daysSinceLastWorkout,
      workoutsLast7Days,
      avgWorkoutsPerWeek);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadinessFactorsImplCopyWith<_$ReadinessFactorsImpl> get copyWith =>
      __$$ReadinessFactorsImplCopyWithImpl<_$ReadinessFactorsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadinessFactorsImplToJson(
      this,
    );
  }
}

abstract class _ReadinessFactors implements ReadinessFactors {
  const factory _ReadinessFactors(
      {required final int workoutFrequencyScore,
      required final int recoveryTimeScore,
      required final int consistencyScore,
      final int? daysSinceLastWorkout,
      final int? workoutsLast7Days,
      final double? avgWorkoutsPerWeek}) = _$ReadinessFactorsImpl;

  factory _ReadinessFactors.fromJson(Map<String, dynamic> json) =
      _$ReadinessFactorsImpl.fromJson;

  @override

  /// Workout frequency score (0-100)
  ///
  /// **Calculation**: Recent training volume vs baseline (40% weight)
  int get workoutFrequencyScore;
  @override

  /// Recovery time score (0-100)
  ///
  /// **Calculation**: Days since last workout (30% weight)
  int get recoveryTimeScore;
  @override

  /// Training consistency score (0-100)
  ///
  /// **Calculation**: Adherence to workout schedule (30% weight)
  int get consistencyScore;
  @override

  /// Optional: Days since last workout
  int? get daysSinceLastWorkout;
  @override

  /// Optional: Workouts in last 7 days
  int? get workoutsLast7Days;
  @override

  /// Optional: Average workouts per week
  double? get avgWorkoutsPerWeek;
  @override
  @JsonKey(ignore: true)
  _$$ReadinessFactorsImplCopyWith<_$ReadinessFactorsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
