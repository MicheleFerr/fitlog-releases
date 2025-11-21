// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consistency_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConsistencyScore _$ConsistencyScoreFromJson(Map<String, dynamic> json) {
  return _ConsistencyScore.fromJson(json);
}

/// @nodoc
mixin _$ConsistencyScore {
  /// Overall consistency score (0-100)
  int get overallScore => throw _privateConstructorUsedError;

  /// Score rating text (Excellent, Good, Fair, Poor)
  String get scoreRating => throw _privateConstructorUsedError;

  /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
  String get rating => throw _privateConstructorUsedError;

  /// Risk level (Low, Medium, High) - string version
  String get riskLevel => throw _privateConstructorUsedError;

  /// Overtraining risk level (enum)
  OvertrainingRisk get overtrainingRisk => throw _privateConstructorUsedError;

  /// Frequency score component (0-100) - changed to int for widget compatibility
  int get frequencyScore => throw _privateConstructorUsedError;

  /// Rest score component (0-100) - changed to int for widget compatibility
  int get restScore => throw _privateConstructorUsedError;

  /// Volume score component (0-100) - changed to int for widget compatibility
  int get volumeScore => throw _privateConstructorUsedError;

  /// Progression score component (0-100) - changed to int for widget compatibility
  int get progressionScore => throw _privateConstructorUsedError;

  /// Weekly statistics (aggregated 7-day metrics)
  WeeklyStats get weeklyStats => throw _privateConstructorUsedError;

  /// Number of workouts completed
  int get workoutsCompleted => throw _privateConstructorUsedError;

  /// Number of workouts skipped
  int get workoutsSkipped => throw _privateConstructorUsedError;

  /// Average workout frequency (workouts per week)
  double get avgFrequency => throw _privateConstructorUsedError;

  /// Longest workout streak (consecutive days)
  int get longestStreak => throw _privateConstructorUsedError;

  /// Current workout streak (consecutive days)
  int get currentStreak => throw _privateConstructorUsedError;

  /// Timestamp of calculation
  DateTime? get calculatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsistencyScoreCopyWith<ConsistencyScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsistencyScoreCopyWith<$Res> {
  factory $ConsistencyScoreCopyWith(
          ConsistencyScore value, $Res Function(ConsistencyScore) then) =
      _$ConsistencyScoreCopyWithImpl<$Res, ConsistencyScore>;
  @useResult
  $Res call(
      {int overallScore,
      String scoreRating,
      String rating,
      String riskLevel,
      OvertrainingRisk overtrainingRisk,
      int frequencyScore,
      int restScore,
      int volumeScore,
      int progressionScore,
      WeeklyStats weeklyStats,
      int workoutsCompleted,
      int workoutsSkipped,
      double avgFrequency,
      int longestStreak,
      int currentStreak,
      DateTime? calculatedAt});

  $WeeklyStatsCopyWith<$Res> get weeklyStats;
}

/// @nodoc
class _$ConsistencyScoreCopyWithImpl<$Res, $Val extends ConsistencyScore>
    implements $ConsistencyScoreCopyWith<$Res> {
  _$ConsistencyScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overallScore = null,
    Object? scoreRating = null,
    Object? rating = null,
    Object? riskLevel = null,
    Object? overtrainingRisk = null,
    Object? frequencyScore = null,
    Object? restScore = null,
    Object? volumeScore = null,
    Object? progressionScore = null,
    Object? weeklyStats = null,
    Object? workoutsCompleted = null,
    Object? workoutsSkipped = null,
    Object? avgFrequency = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? calculatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      scoreRating: null == scoreRating
          ? _value.scoreRating
          : scoreRating // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      overtrainingRisk: null == overtrainingRisk
          ? _value.overtrainingRisk
          : overtrainingRisk // ignore: cast_nullable_to_non_nullable
              as OvertrainingRisk,
      frequencyScore: null == frequencyScore
          ? _value.frequencyScore
          : frequencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      restScore: null == restScore
          ? _value.restScore
          : restScore // ignore: cast_nullable_to_non_nullable
              as int,
      volumeScore: null == volumeScore
          ? _value.volumeScore
          : volumeScore // ignore: cast_nullable_to_non_nullable
              as int,
      progressionScore: null == progressionScore
          ? _value.progressionScore
          : progressionScore // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyStats: null == weeklyStats
          ? _value.weeklyStats
          : weeklyStats // ignore: cast_nullable_to_non_nullable
              as WeeklyStats,
      workoutsCompleted: null == workoutsCompleted
          ? _value.workoutsCompleted
          : workoutsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsSkipped: null == workoutsSkipped
          ? _value.workoutsSkipped
          : workoutsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      avgFrequency: null == avgFrequency
          ? _value.avgFrequency
          : avgFrequency // ignore: cast_nullable_to_non_nullable
              as double,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklyStatsCopyWith<$Res> get weeklyStats {
    return $WeeklyStatsCopyWith<$Res>(_value.weeklyStats, (value) {
      return _then(_value.copyWith(weeklyStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConsistencyScoreImplCopyWith<$Res>
    implements $ConsistencyScoreCopyWith<$Res> {
  factory _$$ConsistencyScoreImplCopyWith(_$ConsistencyScoreImpl value,
          $Res Function(_$ConsistencyScoreImpl) then) =
      __$$ConsistencyScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int overallScore,
      String scoreRating,
      String rating,
      String riskLevel,
      OvertrainingRisk overtrainingRisk,
      int frequencyScore,
      int restScore,
      int volumeScore,
      int progressionScore,
      WeeklyStats weeklyStats,
      int workoutsCompleted,
      int workoutsSkipped,
      double avgFrequency,
      int longestStreak,
      int currentStreak,
      DateTime? calculatedAt});

  @override
  $WeeklyStatsCopyWith<$Res> get weeklyStats;
}

/// @nodoc
class __$$ConsistencyScoreImplCopyWithImpl<$Res>
    extends _$ConsistencyScoreCopyWithImpl<$Res, _$ConsistencyScoreImpl>
    implements _$$ConsistencyScoreImplCopyWith<$Res> {
  __$$ConsistencyScoreImplCopyWithImpl(_$ConsistencyScoreImpl _value,
      $Res Function(_$ConsistencyScoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overallScore = null,
    Object? scoreRating = null,
    Object? rating = null,
    Object? riskLevel = null,
    Object? overtrainingRisk = null,
    Object? frequencyScore = null,
    Object? restScore = null,
    Object? volumeScore = null,
    Object? progressionScore = null,
    Object? weeklyStats = null,
    Object? workoutsCompleted = null,
    Object? workoutsSkipped = null,
    Object? avgFrequency = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? calculatedAt = freezed,
  }) {
    return _then(_$ConsistencyScoreImpl(
      overallScore: null == overallScore
          ? _value.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as int,
      scoreRating: null == scoreRating
          ? _value.scoreRating
          : scoreRating // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as String,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      overtrainingRisk: null == overtrainingRisk
          ? _value.overtrainingRisk
          : overtrainingRisk // ignore: cast_nullable_to_non_nullable
              as OvertrainingRisk,
      frequencyScore: null == frequencyScore
          ? _value.frequencyScore
          : frequencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      restScore: null == restScore
          ? _value.restScore
          : restScore // ignore: cast_nullable_to_non_nullable
              as int,
      volumeScore: null == volumeScore
          ? _value.volumeScore
          : volumeScore // ignore: cast_nullable_to_non_nullable
              as int,
      progressionScore: null == progressionScore
          ? _value.progressionScore
          : progressionScore // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyStats: null == weeklyStats
          ? _value.weeklyStats
          : weeklyStats // ignore: cast_nullable_to_non_nullable
              as WeeklyStats,
      workoutsCompleted: null == workoutsCompleted
          ? _value.workoutsCompleted
          : workoutsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsSkipped: null == workoutsSkipped
          ? _value.workoutsSkipped
          : workoutsSkipped // ignore: cast_nullable_to_non_nullable
              as int,
      avgFrequency: null == avgFrequency
          ? _value.avgFrequency
          : avgFrequency // ignore: cast_nullable_to_non_nullable
              as double,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsistencyScoreImpl implements _ConsistencyScore {
  const _$ConsistencyScoreImpl(
      {this.overallScore = 0,
      this.scoreRating = 'Not Available',
      this.rating = 'Not Available',
      this.riskLevel = 'Unknown',
      this.overtrainingRisk = OvertrainingRisk.low,
      this.frequencyScore = 0,
      this.restScore = 0,
      this.volumeScore = 0,
      this.progressionScore = 0,
      required this.weeklyStats,
      this.workoutsCompleted = 0,
      this.workoutsSkipped = 0,
      this.avgFrequency = 0.0,
      this.longestStreak = 0,
      this.currentStreak = 0,
      this.calculatedAt});

  factory _$ConsistencyScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsistencyScoreImplFromJson(json);

  /// Overall consistency score (0-100)
  @override
  @JsonKey()
  final int overallScore;

  /// Score rating text (Excellent, Good, Fair, Poor)
  @override
  @JsonKey()
  final String scoreRating;

  /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
  @override
  @JsonKey()
  final String rating;

  /// Risk level (Low, Medium, High) - string version
  @override
  @JsonKey()
  final String riskLevel;

  /// Overtraining risk level (enum)
  @override
  @JsonKey()
  final OvertrainingRisk overtrainingRisk;

  /// Frequency score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int frequencyScore;

  /// Rest score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int restScore;

  /// Volume score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int volumeScore;

  /// Progression score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int progressionScore;

  /// Weekly statistics (aggregated 7-day metrics)
  @override
  final WeeklyStats weeklyStats;

  /// Number of workouts completed
  @override
  @JsonKey()
  final int workoutsCompleted;

  /// Number of workouts skipped
  @override
  @JsonKey()
  final int workoutsSkipped;

  /// Average workout frequency (workouts per week)
  @override
  @JsonKey()
  final double avgFrequency;

  /// Longest workout streak (consecutive days)
  @override
  @JsonKey()
  final int longestStreak;

  /// Current workout streak (consecutive days)
  @override
  @JsonKey()
  final int currentStreak;

  /// Timestamp of calculation
  @override
  final DateTime? calculatedAt;

  @override
  String toString() {
    return 'ConsistencyScore(overallScore: $overallScore, scoreRating: $scoreRating, rating: $rating, riskLevel: $riskLevel, overtrainingRisk: $overtrainingRisk, frequencyScore: $frequencyScore, restScore: $restScore, volumeScore: $volumeScore, progressionScore: $progressionScore, weeklyStats: $weeklyStats, workoutsCompleted: $workoutsCompleted, workoutsSkipped: $workoutsSkipped, avgFrequency: $avgFrequency, longestStreak: $longestStreak, currentStreak: $currentStreak, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsistencyScoreImpl &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.scoreRating, scoreRating) ||
                other.scoreRating == scoreRating) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.overtrainingRisk, overtrainingRisk) ||
                other.overtrainingRisk == overtrainingRisk) &&
            (identical(other.frequencyScore, frequencyScore) ||
                other.frequencyScore == frequencyScore) &&
            (identical(other.restScore, restScore) ||
                other.restScore == restScore) &&
            (identical(other.volumeScore, volumeScore) ||
                other.volumeScore == volumeScore) &&
            (identical(other.progressionScore, progressionScore) ||
                other.progressionScore == progressionScore) &&
            (identical(other.weeklyStats, weeklyStats) ||
                other.weeklyStats == weeklyStats) &&
            (identical(other.workoutsCompleted, workoutsCompleted) ||
                other.workoutsCompleted == workoutsCompleted) &&
            (identical(other.workoutsSkipped, workoutsSkipped) ||
                other.workoutsSkipped == workoutsSkipped) &&
            (identical(other.avgFrequency, avgFrequency) ||
                other.avgFrequency == avgFrequency) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      overallScore,
      scoreRating,
      rating,
      riskLevel,
      overtrainingRisk,
      frequencyScore,
      restScore,
      volumeScore,
      progressionScore,
      weeklyStats,
      workoutsCompleted,
      workoutsSkipped,
      avgFrequency,
      longestStreak,
      currentStreak,
      calculatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsistencyScoreImplCopyWith<_$ConsistencyScoreImpl> get copyWith =>
      __$$ConsistencyScoreImplCopyWithImpl<_$ConsistencyScoreImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsistencyScoreImplToJson(
      this,
    );
  }
}

abstract class _ConsistencyScore implements ConsistencyScore {
  const factory _ConsistencyScore(
      {final int overallScore,
      final String scoreRating,
      final String rating,
      final String riskLevel,
      final OvertrainingRisk overtrainingRisk,
      final int frequencyScore,
      final int restScore,
      final int volumeScore,
      final int progressionScore,
      required final WeeklyStats weeklyStats,
      final int workoutsCompleted,
      final int workoutsSkipped,
      final double avgFrequency,
      final int longestStreak,
      final int currentStreak,
      final DateTime? calculatedAt}) = _$ConsistencyScoreImpl;

  factory _ConsistencyScore.fromJson(Map<String, dynamic> json) =
      _$ConsistencyScoreImpl.fromJson;

  @override

  /// Overall consistency score (0-100)
  int get overallScore;
  @override

  /// Score rating text (Excellent, Good, Fair, Poor)
  String get scoreRating;
  @override

  /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
  String get rating;
  @override

  /// Risk level (Low, Medium, High) - string version
  String get riskLevel;
  @override

  /// Overtraining risk level (enum)
  OvertrainingRisk get overtrainingRisk;
  @override

  /// Frequency score component (0-100) - changed to int for widget compatibility
  int get frequencyScore;
  @override

  /// Rest score component (0-100) - changed to int for widget compatibility
  int get restScore;
  @override

  /// Volume score component (0-100) - changed to int for widget compatibility
  int get volumeScore;
  @override

  /// Progression score component (0-100) - changed to int for widget compatibility
  int get progressionScore;
  @override

  /// Weekly statistics (aggregated 7-day metrics)
  WeeklyStats get weeklyStats;
  @override

  /// Number of workouts completed
  int get workoutsCompleted;
  @override

  /// Number of workouts skipped
  int get workoutsSkipped;
  @override

  /// Average workout frequency (workouts per week)
  double get avgFrequency;
  @override

  /// Longest workout streak (consecutive days)
  int get longestStreak;
  @override

  /// Current workout streak (consecutive days)
  int get currentStreak;
  @override

  /// Timestamp of calculation
  DateTime? get calculatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ConsistencyScoreImplCopyWith<_$ConsistencyScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
