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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConsistencyScore _$ConsistencyScoreFromJson(Map<String, dynamic> json) {
  return _ConsistencyScore.fromJson(json);
}

/// @nodoc
mixin _$ConsistencyScore {
  // NEW: Binary indicators (100% validated thresholds)
  /// Frequency is optimal (3-5 workouts per week)
  /// Source: Schoenfeld et al. 2019 (PMID: 30558493)
  bool get frequencyOptimal => throw _privateConstructorUsedError;

  /// Rest is optimal (2-3 rest days per week)
  /// Source: UCLA Health 2024 - <2 days = 5.2x injury risk
  bool get restOptimal => throw _privateConstructorUsedError;

  /// Progression is positive (>5% improvement)
  /// Source: NASM 2023 - Progressive overload guidelines
  bool get progressionPositive =>
      throw _privateConstructorUsedError; // EXISTING: Detailed scores (keep for breakdown view)
  /// Frequency score component (0-100) - changed to int for widget compatibility
  int get frequencyScore => throw _privateConstructorUsedError;

  /// Rest score component (0-100) - changed to int for widget compatibility
  int get restScore => throw _privateConstructorUsedError;

  /// Progression score component (0-100) - changed to int for widget compatibility
  int get progressionScore =>
      throw _privateConstructorUsedError; // EXISTING: Statistics
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
  DateTime? get calculatedAt =>
      throw _privateConstructorUsedError; // DEPRECATED: Keep for backward compatibility (1 version)
  /// Overall consistency score (0-100)
  @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead')
  int? get overallScore => throw _privateConstructorUsedError;

  /// Score rating text (Excellent, Good, Fair, Poor)
  @Deprecated('Use binary indicators instead')
  String? get scoreRating => throw _privateConstructorUsedError;

  /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
  @Deprecated('Use binary indicators instead')
  String? get rating => throw _privateConstructorUsedError;

  /// Risk level (Low, Medium, High) - string version
  @Deprecated('Use binary indicators instead')
  String? get riskLevel => throw _privateConstructorUsedError;

  /// Overtraining risk level (enum)
  @Deprecated('Insufficient indicators - requires HR monitoring')
  OvertrainingRisk? get overtrainingRisk => throw _privateConstructorUsedError;

  /// Volume score component (0-100) - changed to int for widget compatibility
  @Deprecated('Total volume too generic - needs per-muscle-group')
  int? get volumeScore => throw _privateConstructorUsedError;

  /// Serializes this ConsistencyScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsistencyScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsistencyScoreCopyWith<ConsistencyScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsistencyScoreCopyWith<$Res> {
  factory $ConsistencyScoreCopyWith(
    ConsistencyScore value,
    $Res Function(ConsistencyScore) then,
  ) = _$ConsistencyScoreCopyWithImpl<$Res, ConsistencyScore>;
  @useResult
  $Res call({
    bool frequencyOptimal,
    bool restOptimal,
    bool progressionPositive,
    int frequencyScore,
    int restScore,
    int progressionScore,
    WeeklyStats weeklyStats,
    int workoutsCompleted,
    int workoutsSkipped,
    double avgFrequency,
    int longestStreak,
    int currentStreak,
    DateTime? calculatedAt,
    @Deprecated(
      'Use frequencyOptimal, restOptimal, progressionPositive instead',
    )
    int? overallScore,
    @Deprecated('Use binary indicators instead') String? scoreRating,
    @Deprecated('Use binary indicators instead') String? rating,
    @Deprecated('Use binary indicators instead') String? riskLevel,
    @Deprecated('Insufficient indicators - requires HR monitoring')
    OvertrainingRisk? overtrainingRisk,
    @Deprecated('Total volume too generic - needs per-muscle-group')
    int? volumeScore,
  });

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

  /// Create a copy of ConsistencyScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequencyOptimal = null,
    Object? restOptimal = null,
    Object? progressionPositive = null,
    Object? frequencyScore = null,
    Object? restScore = null,
    Object? progressionScore = null,
    Object? weeklyStats = null,
    Object? workoutsCompleted = null,
    Object? workoutsSkipped = null,
    Object? avgFrequency = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? calculatedAt = freezed,
    Object? overallScore = freezed,
    Object? scoreRating = freezed,
    Object? rating = freezed,
    Object? riskLevel = freezed,
    Object? overtrainingRisk = freezed,
    Object? volumeScore = freezed,
  }) {
    return _then(
      _value.copyWith(
            frequencyOptimal: null == frequencyOptimal
                ? _value.frequencyOptimal
                : frequencyOptimal // ignore: cast_nullable_to_non_nullable
                      as bool,
            restOptimal: null == restOptimal
                ? _value.restOptimal
                : restOptimal // ignore: cast_nullable_to_non_nullable
                      as bool,
            progressionPositive: null == progressionPositive
                ? _value.progressionPositive
                : progressionPositive // ignore: cast_nullable_to_non_nullable
                      as bool,
            frequencyScore: null == frequencyScore
                ? _value.frequencyScore
                : frequencyScore // ignore: cast_nullable_to_non_nullable
                      as int,
            restScore: null == restScore
                ? _value.restScore
                : restScore // ignore: cast_nullable_to_non_nullable
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
            overallScore: freezed == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            scoreRating: freezed == scoreRating
                ? _value.scoreRating
                : scoreRating // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as String?,
            riskLevel: freezed == riskLevel
                ? _value.riskLevel
                : riskLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            overtrainingRisk: freezed == overtrainingRisk
                ? _value.overtrainingRisk
                : overtrainingRisk // ignore: cast_nullable_to_non_nullable
                      as OvertrainingRisk?,
            volumeScore: freezed == volumeScore
                ? _value.volumeScore
                : volumeScore // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of ConsistencyScore
  /// with the given fields replaced by the non-null parameter values.
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
  factory _$$ConsistencyScoreImplCopyWith(
    _$ConsistencyScoreImpl value,
    $Res Function(_$ConsistencyScoreImpl) then,
  ) = __$$ConsistencyScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool frequencyOptimal,
    bool restOptimal,
    bool progressionPositive,
    int frequencyScore,
    int restScore,
    int progressionScore,
    WeeklyStats weeklyStats,
    int workoutsCompleted,
    int workoutsSkipped,
    double avgFrequency,
    int longestStreak,
    int currentStreak,
    DateTime? calculatedAt,
    @Deprecated(
      'Use frequencyOptimal, restOptimal, progressionPositive instead',
    )
    int? overallScore,
    @Deprecated('Use binary indicators instead') String? scoreRating,
    @Deprecated('Use binary indicators instead') String? rating,
    @Deprecated('Use binary indicators instead') String? riskLevel,
    @Deprecated('Insufficient indicators - requires HR monitoring')
    OvertrainingRisk? overtrainingRisk,
    @Deprecated('Total volume too generic - needs per-muscle-group')
    int? volumeScore,
  });

  @override
  $WeeklyStatsCopyWith<$Res> get weeklyStats;
}

/// @nodoc
class __$$ConsistencyScoreImplCopyWithImpl<$Res>
    extends _$ConsistencyScoreCopyWithImpl<$Res, _$ConsistencyScoreImpl>
    implements _$$ConsistencyScoreImplCopyWith<$Res> {
  __$$ConsistencyScoreImplCopyWithImpl(
    _$ConsistencyScoreImpl _value,
    $Res Function(_$ConsistencyScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConsistencyScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequencyOptimal = null,
    Object? restOptimal = null,
    Object? progressionPositive = null,
    Object? frequencyScore = null,
    Object? restScore = null,
    Object? progressionScore = null,
    Object? weeklyStats = null,
    Object? workoutsCompleted = null,
    Object? workoutsSkipped = null,
    Object? avgFrequency = null,
    Object? longestStreak = null,
    Object? currentStreak = null,
    Object? calculatedAt = freezed,
    Object? overallScore = freezed,
    Object? scoreRating = freezed,
    Object? rating = freezed,
    Object? riskLevel = freezed,
    Object? overtrainingRisk = freezed,
    Object? volumeScore = freezed,
  }) {
    return _then(
      _$ConsistencyScoreImpl(
        frequencyOptimal: null == frequencyOptimal
            ? _value.frequencyOptimal
            : frequencyOptimal // ignore: cast_nullable_to_non_nullable
                  as bool,
        restOptimal: null == restOptimal
            ? _value.restOptimal
            : restOptimal // ignore: cast_nullable_to_non_nullable
                  as bool,
        progressionPositive: null == progressionPositive
            ? _value.progressionPositive
            : progressionPositive // ignore: cast_nullable_to_non_nullable
                  as bool,
        frequencyScore: null == frequencyScore
            ? _value.frequencyScore
            : frequencyScore // ignore: cast_nullable_to_non_nullable
                  as int,
        restScore: null == restScore
            ? _value.restScore
            : restScore // ignore: cast_nullable_to_non_nullable
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
        overallScore: freezed == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        scoreRating: freezed == scoreRating
            ? _value.scoreRating
            : scoreRating // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as String?,
        riskLevel: freezed == riskLevel
            ? _value.riskLevel
            : riskLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        overtrainingRisk: freezed == overtrainingRisk
            ? _value.overtrainingRisk
            : overtrainingRisk // ignore: cast_nullable_to_non_nullable
                  as OvertrainingRisk?,
        volumeScore: freezed == volumeScore
            ? _value.volumeScore
            : volumeScore // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsistencyScoreImpl implements _ConsistencyScore {
  const _$ConsistencyScoreImpl({
    this.frequencyOptimal = false,
    this.restOptimal = false,
    this.progressionPositive = false,
    this.frequencyScore = 0,
    this.restScore = 0,
    this.progressionScore = 0,
    required this.weeklyStats,
    this.workoutsCompleted = 0,
    this.workoutsSkipped = 0,
    this.avgFrequency = 0.0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.calculatedAt,
    @Deprecated(
      'Use frequencyOptimal, restOptimal, progressionPositive instead',
    )
    this.overallScore,
    @Deprecated('Use binary indicators instead') this.scoreRating,
    @Deprecated('Use binary indicators instead') this.rating,
    @Deprecated('Use binary indicators instead') this.riskLevel,
    @Deprecated('Insufficient indicators - requires HR monitoring')
    this.overtrainingRisk,
    @Deprecated('Total volume too generic - needs per-muscle-group')
    this.volumeScore,
  });

  factory _$ConsistencyScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsistencyScoreImplFromJson(json);

  // NEW: Binary indicators (100% validated thresholds)
  /// Frequency is optimal (3-5 workouts per week)
  /// Source: Schoenfeld et al. 2019 (PMID: 30558493)
  @override
  @JsonKey()
  final bool frequencyOptimal;

  /// Rest is optimal (2-3 rest days per week)
  /// Source: UCLA Health 2024 - <2 days = 5.2x injury risk
  @override
  @JsonKey()
  final bool restOptimal;

  /// Progression is positive (>5% improvement)
  /// Source: NASM 2023 - Progressive overload guidelines
  @override
  @JsonKey()
  final bool progressionPositive;
  // EXISTING: Detailed scores (keep for breakdown view)
  /// Frequency score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int frequencyScore;

  /// Rest score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int restScore;

  /// Progression score component (0-100) - changed to int for widget compatibility
  @override
  @JsonKey()
  final int progressionScore;
  // EXISTING: Statistics
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
  // DEPRECATED: Keep for backward compatibility (1 version)
  /// Overall consistency score (0-100)
  @override
  @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead')
  final int? overallScore;

  /// Score rating text (Excellent, Good, Fair, Poor)
  @override
  @Deprecated('Use binary indicators instead')
  final String? scoreRating;

  /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
  @override
  @Deprecated('Use binary indicators instead')
  final String? rating;

  /// Risk level (Low, Medium, High) - string version
  @override
  @Deprecated('Use binary indicators instead')
  final String? riskLevel;

  /// Overtraining risk level (enum)
  @override
  @Deprecated('Insufficient indicators - requires HR monitoring')
  final OvertrainingRisk? overtrainingRisk;

  /// Volume score component (0-100) - changed to int for widget compatibility
  @override
  @Deprecated('Total volume too generic - needs per-muscle-group')
  final int? volumeScore;

  @override
  String toString() {
    return 'ConsistencyScore(frequencyOptimal: $frequencyOptimal, restOptimal: $restOptimal, progressionPositive: $progressionPositive, frequencyScore: $frequencyScore, restScore: $restScore, progressionScore: $progressionScore, weeklyStats: $weeklyStats, workoutsCompleted: $workoutsCompleted, workoutsSkipped: $workoutsSkipped, avgFrequency: $avgFrequency, longestStreak: $longestStreak, currentStreak: $currentStreak, calculatedAt: $calculatedAt, overallScore: $overallScore, scoreRating: $scoreRating, rating: $rating, riskLevel: $riskLevel, overtrainingRisk: $overtrainingRisk, volumeScore: $volumeScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsistencyScoreImpl &&
            (identical(other.frequencyOptimal, frequencyOptimal) ||
                other.frequencyOptimal == frequencyOptimal) &&
            (identical(other.restOptimal, restOptimal) ||
                other.restOptimal == restOptimal) &&
            (identical(other.progressionPositive, progressionPositive) ||
                other.progressionPositive == progressionPositive) &&
            (identical(other.frequencyScore, frequencyScore) ||
                other.frequencyScore == frequencyScore) &&
            (identical(other.restScore, restScore) ||
                other.restScore == restScore) &&
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
                other.calculatedAt == calculatedAt) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.scoreRating, scoreRating) ||
                other.scoreRating == scoreRating) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.overtrainingRisk, overtrainingRisk) ||
                other.overtrainingRisk == overtrainingRisk) &&
            (identical(other.volumeScore, volumeScore) ||
                other.volumeScore == volumeScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    frequencyOptimal,
    restOptimal,
    progressionPositive,
    frequencyScore,
    restScore,
    progressionScore,
    weeklyStats,
    workoutsCompleted,
    workoutsSkipped,
    avgFrequency,
    longestStreak,
    currentStreak,
    calculatedAt,
    overallScore,
    scoreRating,
    rating,
    riskLevel,
    overtrainingRisk,
    volumeScore,
  ]);

  /// Create a copy of ConsistencyScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsistencyScoreImplCopyWith<_$ConsistencyScoreImpl> get copyWith =>
      __$$ConsistencyScoreImplCopyWithImpl<_$ConsistencyScoreImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsistencyScoreImplToJson(this);
  }
}

abstract class _ConsistencyScore implements ConsistencyScore {
  const factory _ConsistencyScore({
    final bool frequencyOptimal,
    final bool restOptimal,
    final bool progressionPositive,
    final int frequencyScore,
    final int restScore,
    final int progressionScore,
    required final WeeklyStats weeklyStats,
    final int workoutsCompleted,
    final int workoutsSkipped,
    final double avgFrequency,
    final int longestStreak,
    final int currentStreak,
    final DateTime? calculatedAt,
    @Deprecated(
      'Use frequencyOptimal, restOptimal, progressionPositive instead',
    )
    final int? overallScore,
    @Deprecated('Use binary indicators instead') final String? scoreRating,
    @Deprecated('Use binary indicators instead') final String? rating,
    @Deprecated('Use binary indicators instead') final String? riskLevel,
    @Deprecated('Insufficient indicators - requires HR monitoring')
    final OvertrainingRisk? overtrainingRisk,
    @Deprecated('Total volume too generic - needs per-muscle-group')
    final int? volumeScore,
  }) = _$ConsistencyScoreImpl;

  factory _ConsistencyScore.fromJson(Map<String, dynamic> json) =
      _$ConsistencyScoreImpl.fromJson;

  // NEW: Binary indicators (100% validated thresholds)
  /// Frequency is optimal (3-5 workouts per week)
  /// Source: Schoenfeld et al. 2019 (PMID: 30558493)
  @override
  bool get frequencyOptimal;

  /// Rest is optimal (2-3 rest days per week)
  /// Source: UCLA Health 2024 - <2 days = 5.2x injury risk
  @override
  bool get restOptimal;

  /// Progression is positive (>5% improvement)
  /// Source: NASM 2023 - Progressive overload guidelines
  @override
  bool get progressionPositive; // EXISTING: Detailed scores (keep for breakdown view)
  /// Frequency score component (0-100) - changed to int for widget compatibility
  @override
  int get frequencyScore;

  /// Rest score component (0-100) - changed to int for widget compatibility
  @override
  int get restScore;

  /// Progression score component (0-100) - changed to int for widget compatibility
  @override
  int get progressionScore; // EXISTING: Statistics
  /// Weekly statistics (aggregated 7-day metrics)
  @override
  WeeklyStats get weeklyStats;

  /// Number of workouts completed
  @override
  int get workoutsCompleted;

  /// Number of workouts skipped
  @override
  int get workoutsSkipped;

  /// Average workout frequency (workouts per week)
  @override
  double get avgFrequency;

  /// Longest workout streak (consecutive days)
  @override
  int get longestStreak;

  /// Current workout streak (consecutive days)
  @override
  int get currentStreak;

  /// Timestamp of calculation
  @override
  DateTime? get calculatedAt; // DEPRECATED: Keep for backward compatibility (1 version)
  /// Overall consistency score (0-100)
  @override
  @Deprecated('Use frequencyOptimal, restOptimal, progressionPositive instead')
  int? get overallScore;

  /// Score rating text (Excellent, Good, Fair, Poor)
  @override
  @Deprecated('Use binary indicators instead')
  String? get scoreRating;

  /// Score rating (Excellent, Good, Fair, Poor) - DEPRECATED, use scoreRating
  @override
  @Deprecated('Use binary indicators instead')
  String? get rating;

  /// Risk level (Low, Medium, High) - string version
  @override
  @Deprecated('Use binary indicators instead')
  String? get riskLevel;

  /// Overtraining risk level (enum)
  @override
  @Deprecated('Insufficient indicators - requires HR monitoring')
  OvertrainingRisk? get overtrainingRisk;

  /// Volume score component (0-100) - changed to int for widget compatibility
  @override
  @Deprecated('Total volume too generic - needs per-muscle-group')
  int? get volumeScore;

  /// Create a copy of ConsistencyScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsistencyScoreImplCopyWith<_$ConsistencyScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
