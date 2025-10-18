// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutineAdherenceMetrics _$RoutineAdherenceMetricsFromJson(
    Map<String, dynamic> json) {
  return _RoutineAdherenceMetrics.fromJson(json);
}

/// @nodoc
mixin _$RoutineAdherenceMetrics {
  /// Overall adherence rate: completedDays / totalPlannedDays
  /// Range: 0.0 (no adherence) to 1.0 (perfect adherence)
  double get adherenceRate => throw _privateConstructorUsedError;

  /// Total number of days planned in the routine schedule
  int get totalPlannedDays => throw _privateConstructorUsedError;

  /// Number of days successfully completed
  int get completedDays => throw _privateConstructorUsedError;

  /// Number of days skipped (not completed on schedule)
  int get skippedDays => throw _privateConstructorUsedError;

  /// Number of skipped days that were recovered later
  int get recoveredDays => throw _privateConstructorUsedError;

  /// Current consecutive days without skipping
  int get currentStreak => throw _privateConstructorUsedError;

  /// Longest streak achieved in this routine
  int get longestStreak => throw _privateConstructorUsedError;

  /// Distribution of workouts by template ID
  /// Map<templateId, percentageOfTotal>
  Map<String, double> get templateDistribution =>
      throw _privateConstructorUsedError;

  /// Skip rate: skippedDays / totalPlannedDays
  double get skipRate => throw _privateConstructorUsedError;

  /// Recovery rate: recoveredDays / skippedDays (0.0 if no skips)
  double get recoveryRate => throw _privateConstructorUsedError;

  /// Average days between workouts (for consistency analysis)
  double get avgDaysBetweenWorkouts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoutineAdherenceMetricsCopyWith<RoutineAdherenceMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineAdherenceMetricsCopyWith<$Res> {
  factory $RoutineAdherenceMetricsCopyWith(RoutineAdherenceMetrics value,
          $Res Function(RoutineAdherenceMetrics) then) =
      _$RoutineAdherenceMetricsCopyWithImpl<$Res, RoutineAdherenceMetrics>;
  @useResult
  $Res call(
      {double adherenceRate,
      int totalPlannedDays,
      int completedDays,
      int skippedDays,
      int recoveredDays,
      int currentStreak,
      int longestStreak,
      Map<String, double> templateDistribution,
      double skipRate,
      double recoveryRate,
      double avgDaysBetweenWorkouts});
}

/// @nodoc
class _$RoutineAdherenceMetricsCopyWithImpl<$Res,
        $Val extends RoutineAdherenceMetrics>
    implements $RoutineAdherenceMetricsCopyWith<$Res> {
  _$RoutineAdherenceMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? adherenceRate = null,
    Object? totalPlannedDays = null,
    Object? completedDays = null,
    Object? skippedDays = null,
    Object? recoveredDays = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? templateDistribution = null,
    Object? skipRate = null,
    Object? recoveryRate = null,
    Object? avgDaysBetweenWorkouts = null,
  }) {
    return _then(_value.copyWith(
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalPlannedDays: null == totalPlannedDays
          ? _value.totalPlannedDays
          : totalPlannedDays // ignore: cast_nullable_to_non_nullable
              as int,
      completedDays: null == completedDays
          ? _value.completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as int,
      skippedDays: null == skippedDays
          ? _value.skippedDays
          : skippedDays // ignore: cast_nullable_to_non_nullable
              as int,
      recoveredDays: null == recoveredDays
          ? _value.recoveredDays
          : recoveredDays // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      templateDistribution: null == templateDistribution
          ? _value.templateDistribution
          : templateDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      skipRate: null == skipRate
          ? _value.skipRate
          : skipRate // ignore: cast_nullable_to_non_nullable
              as double,
      recoveryRate: null == recoveryRate
          ? _value.recoveryRate
          : recoveryRate // ignore: cast_nullable_to_non_nullable
              as double,
      avgDaysBetweenWorkouts: null == avgDaysBetweenWorkouts
          ? _value.avgDaysBetweenWorkouts
          : avgDaysBetweenWorkouts // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutineAdherenceMetricsImplCopyWith<$Res>
    implements $RoutineAdherenceMetricsCopyWith<$Res> {
  factory _$$RoutineAdherenceMetricsImplCopyWith(
          _$RoutineAdherenceMetricsImpl value,
          $Res Function(_$RoutineAdherenceMetricsImpl) then) =
      __$$RoutineAdherenceMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double adherenceRate,
      int totalPlannedDays,
      int completedDays,
      int skippedDays,
      int recoveredDays,
      int currentStreak,
      int longestStreak,
      Map<String, double> templateDistribution,
      double skipRate,
      double recoveryRate,
      double avgDaysBetweenWorkouts});
}

/// @nodoc
class __$$RoutineAdherenceMetricsImplCopyWithImpl<$Res>
    extends _$RoutineAdherenceMetricsCopyWithImpl<$Res,
        _$RoutineAdherenceMetricsImpl>
    implements _$$RoutineAdherenceMetricsImplCopyWith<$Res> {
  __$$RoutineAdherenceMetricsImplCopyWithImpl(
      _$RoutineAdherenceMetricsImpl _value,
      $Res Function(_$RoutineAdherenceMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? adherenceRate = null,
    Object? totalPlannedDays = null,
    Object? completedDays = null,
    Object? skippedDays = null,
    Object? recoveredDays = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? templateDistribution = null,
    Object? skipRate = null,
    Object? recoveryRate = null,
    Object? avgDaysBetweenWorkouts = null,
  }) {
    return _then(_$RoutineAdherenceMetricsImpl(
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalPlannedDays: null == totalPlannedDays
          ? _value.totalPlannedDays
          : totalPlannedDays // ignore: cast_nullable_to_non_nullable
              as int,
      completedDays: null == completedDays
          ? _value.completedDays
          : completedDays // ignore: cast_nullable_to_non_nullable
              as int,
      skippedDays: null == skippedDays
          ? _value.skippedDays
          : skippedDays // ignore: cast_nullable_to_non_nullable
              as int,
      recoveredDays: null == recoveredDays
          ? _value.recoveredDays
          : recoveredDays // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      templateDistribution: null == templateDistribution
          ? _value._templateDistribution
          : templateDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      skipRate: null == skipRate
          ? _value.skipRate
          : skipRate // ignore: cast_nullable_to_non_nullable
              as double,
      recoveryRate: null == recoveryRate
          ? _value.recoveryRate
          : recoveryRate // ignore: cast_nullable_to_non_nullable
              as double,
      avgDaysBetweenWorkouts: null == avgDaysBetweenWorkouts
          ? _value.avgDaysBetweenWorkouts
          : avgDaysBetweenWorkouts // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineAdherenceMetricsImpl implements _RoutineAdherenceMetrics {
  const _$RoutineAdherenceMetricsImpl(
      {required this.adherenceRate,
      required this.totalPlannedDays,
      required this.completedDays,
      required this.skippedDays,
      required this.recoveredDays,
      required this.currentStreak,
      required this.longestStreak,
      required final Map<String, double> templateDistribution,
      required this.skipRate,
      required this.recoveryRate,
      required this.avgDaysBetweenWorkouts})
      : _templateDistribution = templateDistribution;

  factory _$RoutineAdherenceMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineAdherenceMetricsImplFromJson(json);

  /// Overall adherence rate: completedDays / totalPlannedDays
  /// Range: 0.0 (no adherence) to 1.0 (perfect adherence)
  @override
  final double adherenceRate;

  /// Total number of days planned in the routine schedule
  @override
  final int totalPlannedDays;

  /// Number of days successfully completed
  @override
  final int completedDays;

  /// Number of days skipped (not completed on schedule)
  @override
  final int skippedDays;

  /// Number of skipped days that were recovered later
  @override
  final int recoveredDays;

  /// Current consecutive days without skipping
  @override
  final int currentStreak;

  /// Longest streak achieved in this routine
  @override
  final int longestStreak;

  /// Distribution of workouts by template ID
  /// Map<templateId, percentageOfTotal>
  final Map<String, double> _templateDistribution;

  /// Distribution of workouts by template ID
  /// Map<templateId, percentageOfTotal>
  @override
  Map<String, double> get templateDistribution {
    if (_templateDistribution is EqualUnmodifiableMapView)
      return _templateDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_templateDistribution);
  }

  /// Skip rate: skippedDays / totalPlannedDays
  @override
  final double skipRate;

  /// Recovery rate: recoveredDays / skippedDays (0.0 if no skips)
  @override
  final double recoveryRate;

  /// Average days between workouts (for consistency analysis)
  @override
  final double avgDaysBetweenWorkouts;

  @override
  String toString() {
    return 'RoutineAdherenceMetrics(adherenceRate: $adherenceRate, totalPlannedDays: $totalPlannedDays, completedDays: $completedDays, skippedDays: $skippedDays, recoveredDays: $recoveredDays, currentStreak: $currentStreak, longestStreak: $longestStreak, templateDistribution: $templateDistribution, skipRate: $skipRate, recoveryRate: $recoveryRate, avgDaysBetweenWorkouts: $avgDaysBetweenWorkouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineAdherenceMetricsImpl &&
            (identical(other.adherenceRate, adherenceRate) ||
                other.adherenceRate == adherenceRate) &&
            (identical(other.totalPlannedDays, totalPlannedDays) ||
                other.totalPlannedDays == totalPlannedDays) &&
            (identical(other.completedDays, completedDays) ||
                other.completedDays == completedDays) &&
            (identical(other.skippedDays, skippedDays) ||
                other.skippedDays == skippedDays) &&
            (identical(other.recoveredDays, recoveredDays) ||
                other.recoveredDays == recoveredDays) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            const DeepCollectionEquality()
                .equals(other._templateDistribution, _templateDistribution) &&
            (identical(other.skipRate, skipRate) ||
                other.skipRate == skipRate) &&
            (identical(other.recoveryRate, recoveryRate) ||
                other.recoveryRate == recoveryRate) &&
            (identical(other.avgDaysBetweenWorkouts, avgDaysBetweenWorkouts) ||
                other.avgDaysBetweenWorkouts == avgDaysBetweenWorkouts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      adherenceRate,
      totalPlannedDays,
      completedDays,
      skippedDays,
      recoveredDays,
      currentStreak,
      longestStreak,
      const DeepCollectionEquality().hash(_templateDistribution),
      skipRate,
      recoveryRate,
      avgDaysBetweenWorkouts);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineAdherenceMetricsImplCopyWith<_$RoutineAdherenceMetricsImpl>
      get copyWith => __$$RoutineAdherenceMetricsImplCopyWithImpl<
          _$RoutineAdherenceMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineAdherenceMetricsImplToJson(
      this,
    );
  }
}

abstract class _RoutineAdherenceMetrics implements RoutineAdherenceMetrics {
  const factory _RoutineAdherenceMetrics(
          {required final double adherenceRate,
          required final int totalPlannedDays,
          required final int completedDays,
          required final int skippedDays,
          required final int recoveredDays,
          required final int currentStreak,
          required final int longestStreak,
          required final Map<String, double> templateDistribution,
          required final double skipRate,
          required final double recoveryRate,
          required final double avgDaysBetweenWorkouts}) =
      _$RoutineAdherenceMetricsImpl;

  factory _RoutineAdherenceMetrics.fromJson(Map<String, dynamic> json) =
      _$RoutineAdherenceMetricsImpl.fromJson;

  @override

  /// Overall adherence rate: completedDays / totalPlannedDays
  /// Range: 0.0 (no adherence) to 1.0 (perfect adherence)
  double get adherenceRate;
  @override

  /// Total number of days planned in the routine schedule
  int get totalPlannedDays;
  @override

  /// Number of days successfully completed
  int get completedDays;
  @override

  /// Number of days skipped (not completed on schedule)
  int get skippedDays;
  @override

  /// Number of skipped days that were recovered later
  int get recoveredDays;
  @override

  /// Current consecutive days without skipping
  int get currentStreak;
  @override

  /// Longest streak achieved in this routine
  int get longestStreak;
  @override

  /// Distribution of workouts by template ID
  /// Map<templateId, percentageOfTotal>
  Map<String, double> get templateDistribution;
  @override

  /// Skip rate: skippedDays / totalPlannedDays
  double get skipRate;
  @override

  /// Recovery rate: recoveredDays / skippedDays (0.0 if no skips)
  double get recoveryRate;
  @override

  /// Average days between workouts (for consistency analysis)
  double get avgDaysBetweenWorkouts;
  @override
  @JsonKey(ignore: true)
  _$$RoutineAdherenceMetricsImplCopyWith<_$RoutineAdherenceMetricsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ScheduleMatchData _$ScheduleMatchDataFromJson(Map<String, dynamic> json) {
  return _ScheduleMatchData.fromJson(json);
}

/// @nodoc
mixin _$ScheduleMatchData {
  /// Date of the scheduled workout
  DateTime get date => throw _privateConstructorUsedError;

  /// Template ID that was scheduled for this day (null if rest day)
  String? get scheduledTemplateId => throw _privateConstructorUsedError;

  /// Template ID that was actually performed (null if nothing done)
  String? get actualTemplateId => throw _privateConstructorUsedError;

  /// Whether the actual workout matches the scheduled one
  bool get isMatch => throw _privateConstructorUsedError;

  /// Whether any workout was completed on this day
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Whether this day was marked as skipped
  bool get isSkipped => throw _privateConstructorUsedError;

  /// Whether this day was later recovered
  bool get isRecovered => throw _privateConstructorUsedError;

  /// Day of week (1 = Monday, 7 = Sunday) for pattern analysis
  int get dayOfWeek => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleMatchDataCopyWith<ScheduleMatchData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleMatchDataCopyWith<$Res> {
  factory $ScheduleMatchDataCopyWith(
          ScheduleMatchData value, $Res Function(ScheduleMatchData) then) =
      _$ScheduleMatchDataCopyWithImpl<$Res, ScheduleMatchData>;
  @useResult
  $Res call(
      {DateTime date,
      String? scheduledTemplateId,
      String? actualTemplateId,
      bool isMatch,
      bool isCompleted,
      bool isSkipped,
      bool isRecovered,
      int dayOfWeek});
}

/// @nodoc
class _$ScheduleMatchDataCopyWithImpl<$Res, $Val extends ScheduleMatchData>
    implements $ScheduleMatchDataCopyWith<$Res> {
  _$ScheduleMatchDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? scheduledTemplateId = freezed,
    Object? actualTemplateId = freezed,
    Object? isMatch = null,
    Object? isCompleted = null,
    Object? isSkipped = null,
    Object? isRecovered = null,
    Object? dayOfWeek = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduledTemplateId: freezed == scheduledTemplateId
          ? _value.scheduledTemplateId
          : scheduledTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      actualTemplateId: freezed == actualTemplateId
          ? _value.actualTemplateId
          : actualTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      isMatch: null == isMatch
          ? _value.isMatch
          : isMatch // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSkipped: null == isSkipped
          ? _value.isSkipped
          : isSkipped // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecovered: null == isRecovered
          ? _value.isRecovered
          : isRecovered // ignore: cast_nullable_to_non_nullable
              as bool,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleMatchDataImplCopyWith<$Res>
    implements $ScheduleMatchDataCopyWith<$Res> {
  factory _$$ScheduleMatchDataImplCopyWith(_$ScheduleMatchDataImpl value,
          $Res Function(_$ScheduleMatchDataImpl) then) =
      __$$ScheduleMatchDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      String? scheduledTemplateId,
      String? actualTemplateId,
      bool isMatch,
      bool isCompleted,
      bool isSkipped,
      bool isRecovered,
      int dayOfWeek});
}

/// @nodoc
class __$$ScheduleMatchDataImplCopyWithImpl<$Res>
    extends _$ScheduleMatchDataCopyWithImpl<$Res, _$ScheduleMatchDataImpl>
    implements _$$ScheduleMatchDataImplCopyWith<$Res> {
  __$$ScheduleMatchDataImplCopyWithImpl(_$ScheduleMatchDataImpl _value,
      $Res Function(_$ScheduleMatchDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? scheduledTemplateId = freezed,
    Object? actualTemplateId = freezed,
    Object? isMatch = null,
    Object? isCompleted = null,
    Object? isSkipped = null,
    Object? isRecovered = null,
    Object? dayOfWeek = null,
  }) {
    return _then(_$ScheduleMatchDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      scheduledTemplateId: freezed == scheduledTemplateId
          ? _value.scheduledTemplateId
          : scheduledTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      actualTemplateId: freezed == actualTemplateId
          ? _value.actualTemplateId
          : actualTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      isMatch: null == isMatch
          ? _value.isMatch
          : isMatch // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSkipped: null == isSkipped
          ? _value.isSkipped
          : isSkipped // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecovered: null == isRecovered
          ? _value.isRecovered
          : isRecovered // ignore: cast_nullable_to_non_nullable
              as bool,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleMatchDataImpl implements _ScheduleMatchData {
  const _$ScheduleMatchDataImpl(
      {required this.date,
      required this.scheduledTemplateId,
      required this.actualTemplateId,
      required this.isMatch,
      required this.isCompleted,
      required this.isSkipped,
      required this.isRecovered,
      required this.dayOfWeek});

  factory _$ScheduleMatchDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleMatchDataImplFromJson(json);

  /// Date of the scheduled workout
  @override
  final DateTime date;

  /// Template ID that was scheduled for this day (null if rest day)
  @override
  final String? scheduledTemplateId;

  /// Template ID that was actually performed (null if nothing done)
  @override
  final String? actualTemplateId;

  /// Whether the actual workout matches the scheduled one
  @override
  final bool isMatch;

  /// Whether any workout was completed on this day
  @override
  final bool isCompleted;

  /// Whether this day was marked as skipped
  @override
  final bool isSkipped;

  /// Whether this day was later recovered
  @override
  final bool isRecovered;

  /// Day of week (1 = Monday, 7 = Sunday) for pattern analysis
  @override
  final int dayOfWeek;

  @override
  String toString() {
    return 'ScheduleMatchData(date: $date, scheduledTemplateId: $scheduledTemplateId, actualTemplateId: $actualTemplateId, isMatch: $isMatch, isCompleted: $isCompleted, isSkipped: $isSkipped, isRecovered: $isRecovered, dayOfWeek: $dayOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleMatchDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.scheduledTemplateId, scheduledTemplateId) ||
                other.scheduledTemplateId == scheduledTemplateId) &&
            (identical(other.actualTemplateId, actualTemplateId) ||
                other.actualTemplateId == actualTemplateId) &&
            (identical(other.isMatch, isMatch) || other.isMatch == isMatch) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.isSkipped, isSkipped) ||
                other.isSkipped == isSkipped) &&
            (identical(other.isRecovered, isRecovered) ||
                other.isRecovered == isRecovered) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      scheduledTemplateId,
      actualTemplateId,
      isMatch,
      isCompleted,
      isSkipped,
      isRecovered,
      dayOfWeek);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleMatchDataImplCopyWith<_$ScheduleMatchDataImpl> get copyWith =>
      __$$ScheduleMatchDataImplCopyWithImpl<_$ScheduleMatchDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleMatchDataImplToJson(
      this,
    );
  }
}

abstract class _ScheduleMatchData implements ScheduleMatchData {
  const factory _ScheduleMatchData(
      {required final DateTime date,
      required final String? scheduledTemplateId,
      required final String? actualTemplateId,
      required final bool isMatch,
      required final bool isCompleted,
      required final bool isSkipped,
      required final bool isRecovered,
      required final int dayOfWeek}) = _$ScheduleMatchDataImpl;

  factory _ScheduleMatchData.fromJson(Map<String, dynamic> json) =
      _$ScheduleMatchDataImpl.fromJson;

  @override

  /// Date of the scheduled workout
  DateTime get date;
  @override

  /// Template ID that was scheduled for this day (null if rest day)
  String? get scheduledTemplateId;
  @override

  /// Template ID that was actually performed (null if nothing done)
  String? get actualTemplateId;
  @override

  /// Whether the actual workout matches the scheduled one
  bool get isMatch;
  @override

  /// Whether any workout was completed on this day
  bool get isCompleted;
  @override

  /// Whether this day was marked as skipped
  bool get isSkipped;
  @override

  /// Whether this day was later recovered
  bool get isRecovered;
  @override

  /// Day of week (1 = Monday, 7 = Sunday) for pattern analysis
  int get dayOfWeek;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleMatchDataImplCopyWith<_$ScheduleMatchDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoutineInsight _$RoutineInsightFromJson(Map<String, dynamic> json) {
  return _RoutineInsight.fromJson(json);
}

/// @nodoc
mixin _$RoutineInsight {
  /// Type of insight (consistency, recovery, performance, motivation)
  RoutineInsightType get type => throw _privateConstructorUsedError;

  /// Priority level (higher = more important to show)
  int get priority => throw _privateConstructorUsedError;

  /// Localized message to display to user
  String get message => throw _privateConstructorUsedError;

  /// Optional action label (e.g., "View Recovery Options")
  String? get actionLabel => throw _privateConstructorUsedError;

  /// Optional route to navigate when action is tapped
  String? get actionRoute => throw _privateConstructorUsedError;

  /// Icon to display with the insight
  String? get icon => throw _privateConstructorUsedError;

  /// Whether this is positive or negative insight
  bool get isPositive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoutineInsightCopyWith<RoutineInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineInsightCopyWith<$Res> {
  factory $RoutineInsightCopyWith(
          RoutineInsight value, $Res Function(RoutineInsight) then) =
      _$RoutineInsightCopyWithImpl<$Res, RoutineInsight>;
  @useResult
  $Res call(
      {RoutineInsightType type,
      int priority,
      String message,
      String? actionLabel,
      String? actionRoute,
      String? icon,
      bool isPositive});
}

/// @nodoc
class _$RoutineInsightCopyWithImpl<$Res, $Val extends RoutineInsight>
    implements $RoutineInsightCopyWith<$Res> {
  _$RoutineInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? priority = null,
    Object? message = null,
    Object? actionLabel = freezed,
    Object? actionRoute = freezed,
    Object? icon = freezed,
    Object? isPositive = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoutineInsightType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      actionLabel: freezed == actionLabel
          ? _value.actionLabel
          : actionLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      isPositive: null == isPositive
          ? _value.isPositive
          : isPositive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoutineInsightImplCopyWith<$Res>
    implements $RoutineInsightCopyWith<$Res> {
  factory _$$RoutineInsightImplCopyWith(_$RoutineInsightImpl value,
          $Res Function(_$RoutineInsightImpl) then) =
      __$$RoutineInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RoutineInsightType type,
      int priority,
      String message,
      String? actionLabel,
      String? actionRoute,
      String? icon,
      bool isPositive});
}

/// @nodoc
class __$$RoutineInsightImplCopyWithImpl<$Res>
    extends _$RoutineInsightCopyWithImpl<$Res, _$RoutineInsightImpl>
    implements _$$RoutineInsightImplCopyWith<$Res> {
  __$$RoutineInsightImplCopyWithImpl(
      _$RoutineInsightImpl _value, $Res Function(_$RoutineInsightImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? priority = null,
    Object? message = null,
    Object? actionLabel = freezed,
    Object? actionRoute = freezed,
    Object? icon = freezed,
    Object? isPositive = null,
  }) {
    return _then(_$RoutineInsightImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoutineInsightType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      actionLabel: freezed == actionLabel
          ? _value.actionLabel
          : actionLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      isPositive: null == isPositive
          ? _value.isPositive
          : isPositive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineInsightImpl implements _RoutineInsight {
  const _$RoutineInsightImpl(
      {required this.type,
      required this.priority,
      required this.message,
      this.actionLabel,
      this.actionRoute,
      this.icon,
      required this.isPositive});

  factory _$RoutineInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineInsightImplFromJson(json);

  /// Type of insight (consistency, recovery, performance, motivation)
  @override
  final RoutineInsightType type;

  /// Priority level (higher = more important to show)
  @override
  final int priority;

  /// Localized message to display to user
  @override
  final String message;

  /// Optional action label (e.g., "View Recovery Options")
  @override
  final String? actionLabel;

  /// Optional route to navigate when action is tapped
  @override
  final String? actionRoute;

  /// Icon to display with the insight
  @override
  final String? icon;

  /// Whether this is positive or negative insight
  @override
  final bool isPositive;

  @override
  String toString() {
    return 'RoutineInsight(type: $type, priority: $priority, message: $message, actionLabel: $actionLabel, actionRoute: $actionRoute, icon: $icon, isPositive: $isPositive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineInsightImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.actionLabel, actionLabel) ||
                other.actionLabel == actionLabel) &&
            (identical(other.actionRoute, actionRoute) ||
                other.actionRoute == actionRoute) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isPositive, isPositive) ||
                other.isPositive == isPositive));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type, priority, message,
      actionLabel, actionRoute, icon, isPositive);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineInsightImplCopyWith<_$RoutineInsightImpl> get copyWith =>
      __$$RoutineInsightImplCopyWithImpl<_$RoutineInsightImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineInsightImplToJson(
      this,
    );
  }
}

abstract class _RoutineInsight implements RoutineInsight {
  const factory _RoutineInsight(
      {required final RoutineInsightType type,
      required final int priority,
      required final String message,
      final String? actionLabel,
      final String? actionRoute,
      final String? icon,
      required final bool isPositive}) = _$RoutineInsightImpl;

  factory _RoutineInsight.fromJson(Map<String, dynamic> json) =
      _$RoutineInsightImpl.fromJson;

  @override

  /// Type of insight (consistency, recovery, performance, motivation)
  RoutineInsightType get type;
  @override

  /// Priority level (higher = more important to show)
  int get priority;
  @override

  /// Localized message to display to user
  String get message;
  @override

  /// Optional action label (e.g., "View Recovery Options")
  String? get actionLabel;
  @override

  /// Optional route to navigate when action is tapped
  String? get actionRoute;
  @override

  /// Icon to display with the insight
  String? get icon;
  @override

  /// Whether this is positive or negative insight
  bool get isPositive;
  @override
  @JsonKey(ignore: true)
  _$$RoutineInsightImplCopyWith<_$RoutineInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyAdherenceSummary _$WeeklyAdherenceSummaryFromJson(
    Map<String, dynamic> json) {
  return _WeeklyAdherenceSummary.fromJson(json);
}

/// @nodoc
mixin _$WeeklyAdherenceSummary {
  /// Start date of the week (Monday)
  DateTime get weekStart => throw _privateConstructorUsedError;

  /// End date of the week (Sunday)
  DateTime get weekEnd => throw _privateConstructorUsedError;

  /// Adherence rate for this week
  double get adherenceRate => throw _privateConstructorUsedError;

  /// Number of workouts planned this week
  int get plannedWorkouts => throw _privateConstructorUsedError;

  /// Number of workouts completed this week
  int get completedWorkouts => throw _privateConstructorUsedError;

  /// Number of days skipped this week
  int get skippedDays => throw _privateConstructorUsedError;

  /// Number of days recovered this week
  int get recoveredDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyAdherenceSummaryCopyWith<WeeklyAdherenceSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyAdherenceSummaryCopyWith<$Res> {
  factory $WeeklyAdherenceSummaryCopyWith(WeeklyAdherenceSummary value,
          $Res Function(WeeklyAdherenceSummary) then) =
      _$WeeklyAdherenceSummaryCopyWithImpl<$Res, WeeklyAdherenceSummary>;
  @useResult
  $Res call(
      {DateTime weekStart,
      DateTime weekEnd,
      double adherenceRate,
      int plannedWorkouts,
      int completedWorkouts,
      int skippedDays,
      int recoveredDays});
}

/// @nodoc
class _$WeeklyAdherenceSummaryCopyWithImpl<$Res,
        $Val extends WeeklyAdherenceSummary>
    implements $WeeklyAdherenceSummaryCopyWith<$Res> {
  _$WeeklyAdherenceSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? adherenceRate = null,
    Object? plannedWorkouts = null,
    Object? completedWorkouts = null,
    Object? skippedDays = null,
    Object? recoveredDays = null,
  }) {
    return _then(_value.copyWith(
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEnd: null == weekEnd
          ? _value.weekEnd
          : weekEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      plannedWorkouts: null == plannedWorkouts
          ? _value.plannedWorkouts
          : plannedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      completedWorkouts: null == completedWorkouts
          ? _value.completedWorkouts
          : completedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      skippedDays: null == skippedDays
          ? _value.skippedDays
          : skippedDays // ignore: cast_nullable_to_non_nullable
              as int,
      recoveredDays: null == recoveredDays
          ? _value.recoveredDays
          : recoveredDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyAdherenceSummaryImplCopyWith<$Res>
    implements $WeeklyAdherenceSummaryCopyWith<$Res> {
  factory _$$WeeklyAdherenceSummaryImplCopyWith(
          _$WeeklyAdherenceSummaryImpl value,
          $Res Function(_$WeeklyAdherenceSummaryImpl) then) =
      __$$WeeklyAdherenceSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime weekStart,
      DateTime weekEnd,
      double adherenceRate,
      int plannedWorkouts,
      int completedWorkouts,
      int skippedDays,
      int recoveredDays});
}

/// @nodoc
class __$$WeeklyAdherenceSummaryImplCopyWithImpl<$Res>
    extends _$WeeklyAdherenceSummaryCopyWithImpl<$Res,
        _$WeeklyAdherenceSummaryImpl>
    implements _$$WeeklyAdherenceSummaryImplCopyWith<$Res> {
  __$$WeeklyAdherenceSummaryImplCopyWithImpl(
      _$WeeklyAdherenceSummaryImpl _value,
      $Res Function(_$WeeklyAdherenceSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? adherenceRate = null,
    Object? plannedWorkouts = null,
    Object? completedWorkouts = null,
    Object? skippedDays = null,
    Object? recoveredDays = null,
  }) {
    return _then(_$WeeklyAdherenceSummaryImpl(
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEnd: null == weekEnd
          ? _value.weekEnd
          : weekEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      plannedWorkouts: null == plannedWorkouts
          ? _value.plannedWorkouts
          : plannedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      completedWorkouts: null == completedWorkouts
          ? _value.completedWorkouts
          : completedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      skippedDays: null == skippedDays
          ? _value.skippedDays
          : skippedDays // ignore: cast_nullable_to_non_nullable
              as int,
      recoveredDays: null == recoveredDays
          ? _value.recoveredDays
          : recoveredDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyAdherenceSummaryImpl implements _WeeklyAdherenceSummary {
  const _$WeeklyAdherenceSummaryImpl(
      {required this.weekStart,
      required this.weekEnd,
      required this.adherenceRate,
      required this.plannedWorkouts,
      required this.completedWorkouts,
      required this.skippedDays,
      required this.recoveredDays});

  factory _$WeeklyAdherenceSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyAdherenceSummaryImplFromJson(json);

  /// Start date of the week (Monday)
  @override
  final DateTime weekStart;

  /// End date of the week (Sunday)
  @override
  final DateTime weekEnd;

  /// Adherence rate for this week
  @override
  final double adherenceRate;

  /// Number of workouts planned this week
  @override
  final int plannedWorkouts;

  /// Number of workouts completed this week
  @override
  final int completedWorkouts;

  /// Number of days skipped this week
  @override
  final int skippedDays;

  /// Number of days recovered this week
  @override
  final int recoveredDays;

  @override
  String toString() {
    return 'WeeklyAdherenceSummary(weekStart: $weekStart, weekEnd: $weekEnd, adherenceRate: $adherenceRate, plannedWorkouts: $plannedWorkouts, completedWorkouts: $completedWorkouts, skippedDays: $skippedDays, recoveredDays: $recoveredDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyAdherenceSummaryImpl &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.adherenceRate, adherenceRate) ||
                other.adherenceRate == adherenceRate) &&
            (identical(other.plannedWorkouts, plannedWorkouts) ||
                other.plannedWorkouts == plannedWorkouts) &&
            (identical(other.completedWorkouts, completedWorkouts) ||
                other.completedWorkouts == completedWorkouts) &&
            (identical(other.skippedDays, skippedDays) ||
                other.skippedDays == skippedDays) &&
            (identical(other.recoveredDays, recoveredDays) ||
                other.recoveredDays == recoveredDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      weekStart,
      weekEnd,
      adherenceRate,
      plannedWorkouts,
      completedWorkouts,
      skippedDays,
      recoveredDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyAdherenceSummaryImplCopyWith<_$WeeklyAdherenceSummaryImpl>
      get copyWith => __$$WeeklyAdherenceSummaryImplCopyWithImpl<
          _$WeeklyAdherenceSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyAdherenceSummaryImplToJson(
      this,
    );
  }
}

abstract class _WeeklyAdherenceSummary implements WeeklyAdherenceSummary {
  const factory _WeeklyAdherenceSummary(
      {required final DateTime weekStart,
      required final DateTime weekEnd,
      required final double adherenceRate,
      required final int plannedWorkouts,
      required final int completedWorkouts,
      required final int skippedDays,
      required final int recoveredDays}) = _$WeeklyAdherenceSummaryImpl;

  factory _WeeklyAdherenceSummary.fromJson(Map<String, dynamic> json) =
      _$WeeklyAdherenceSummaryImpl.fromJson;

  @override

  /// Start date of the week (Monday)
  DateTime get weekStart;
  @override

  /// End date of the week (Sunday)
  DateTime get weekEnd;
  @override

  /// Adherence rate for this week
  double get adherenceRate;
  @override

  /// Number of workouts planned this week
  int get plannedWorkouts;
  @override

  /// Number of workouts completed this week
  int get completedWorkouts;
  @override

  /// Number of days skipped this week
  int get skippedDays;
  @override

  /// Number of days recovered this week
  int get recoveredDays;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyAdherenceSummaryImplCopyWith<_$WeeklyAdherenceSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DayOfWeekPattern _$DayOfWeekPatternFromJson(Map<String, dynamic> json) {
  return _DayOfWeekPattern.fromJson(json);
}

/// @nodoc
mixin _$DayOfWeekPattern {
  /// Day of week (1 = Monday, 7 = Sunday)
  int get dayOfWeek => throw _privateConstructorUsedError;

  /// Number of times this day was scheduled
  int get timesScheduled => throw _privateConstructorUsedError;

  /// Number of times workout was completed on this day
  int get timesCompleted => throw _privateConstructorUsedError;

  /// Adherence rate for this specific day of week
  double get adherenceRate => throw _privateConstructorUsedError;

  /// Average skip rate for this day
  double get skipRate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DayOfWeekPatternCopyWith<DayOfWeekPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayOfWeekPatternCopyWith<$Res> {
  factory $DayOfWeekPatternCopyWith(
          DayOfWeekPattern value, $Res Function(DayOfWeekPattern) then) =
      _$DayOfWeekPatternCopyWithImpl<$Res, DayOfWeekPattern>;
  @useResult
  $Res call(
      {int dayOfWeek,
      int timesScheduled,
      int timesCompleted,
      double adherenceRate,
      double skipRate});
}

/// @nodoc
class _$DayOfWeekPatternCopyWithImpl<$Res, $Val extends DayOfWeekPattern>
    implements $DayOfWeekPatternCopyWith<$Res> {
  _$DayOfWeekPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? timesScheduled = null,
    Object? timesCompleted = null,
    Object? adherenceRate = null,
    Object? skipRate = null,
  }) {
    return _then(_value.copyWith(
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      timesScheduled: null == timesScheduled
          ? _value.timesScheduled
          : timesScheduled // ignore: cast_nullable_to_non_nullable
              as int,
      timesCompleted: null == timesCompleted
          ? _value.timesCompleted
          : timesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      skipRate: null == skipRate
          ? _value.skipRate
          : skipRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayOfWeekPatternImplCopyWith<$Res>
    implements $DayOfWeekPatternCopyWith<$Res> {
  factory _$$DayOfWeekPatternImplCopyWith(_$DayOfWeekPatternImpl value,
          $Res Function(_$DayOfWeekPatternImpl) then) =
      __$$DayOfWeekPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int dayOfWeek,
      int timesScheduled,
      int timesCompleted,
      double adherenceRate,
      double skipRate});
}

/// @nodoc
class __$$DayOfWeekPatternImplCopyWithImpl<$Res>
    extends _$DayOfWeekPatternCopyWithImpl<$Res, _$DayOfWeekPatternImpl>
    implements _$$DayOfWeekPatternImplCopyWith<$Res> {
  __$$DayOfWeekPatternImplCopyWithImpl(_$DayOfWeekPatternImpl _value,
      $Res Function(_$DayOfWeekPatternImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? timesScheduled = null,
    Object? timesCompleted = null,
    Object? adherenceRate = null,
    Object? skipRate = null,
  }) {
    return _then(_$DayOfWeekPatternImpl(
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      timesScheduled: null == timesScheduled
          ? _value.timesScheduled
          : timesScheduled // ignore: cast_nullable_to_non_nullable
              as int,
      timesCompleted: null == timesCompleted
          ? _value.timesCompleted
          : timesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      skipRate: null == skipRate
          ? _value.skipRate
          : skipRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DayOfWeekPatternImpl implements _DayOfWeekPattern {
  const _$DayOfWeekPatternImpl(
      {required this.dayOfWeek,
      required this.timesScheduled,
      required this.timesCompleted,
      required this.adherenceRate,
      required this.skipRate});

  factory _$DayOfWeekPatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayOfWeekPatternImplFromJson(json);

  /// Day of week (1 = Monday, 7 = Sunday)
  @override
  final int dayOfWeek;

  /// Number of times this day was scheduled
  @override
  final int timesScheduled;

  /// Number of times workout was completed on this day
  @override
  final int timesCompleted;

  /// Adherence rate for this specific day of week
  @override
  final double adherenceRate;

  /// Average skip rate for this day
  @override
  final double skipRate;

  @override
  String toString() {
    return 'DayOfWeekPattern(dayOfWeek: $dayOfWeek, timesScheduled: $timesScheduled, timesCompleted: $timesCompleted, adherenceRate: $adherenceRate, skipRate: $skipRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayOfWeekPatternImpl &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.timesScheduled, timesScheduled) ||
                other.timesScheduled == timesScheduled) &&
            (identical(other.timesCompleted, timesCompleted) ||
                other.timesCompleted == timesCompleted) &&
            (identical(other.adherenceRate, adherenceRate) ||
                other.adherenceRate == adherenceRate) &&
            (identical(other.skipRate, skipRate) ||
                other.skipRate == skipRate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, dayOfWeek, timesScheduled,
      timesCompleted, adherenceRate, skipRate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DayOfWeekPatternImplCopyWith<_$DayOfWeekPatternImpl> get copyWith =>
      __$$DayOfWeekPatternImplCopyWithImpl<_$DayOfWeekPatternImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayOfWeekPatternImplToJson(
      this,
    );
  }
}

abstract class _DayOfWeekPattern implements DayOfWeekPattern {
  const factory _DayOfWeekPattern(
      {required final int dayOfWeek,
      required final int timesScheduled,
      required final int timesCompleted,
      required final double adherenceRate,
      required final double skipRate}) = _$DayOfWeekPatternImpl;

  factory _DayOfWeekPattern.fromJson(Map<String, dynamic> json) =
      _$DayOfWeekPatternImpl.fromJson;

  @override

  /// Day of week (1 = Monday, 7 = Sunday)
  int get dayOfWeek;
  @override

  /// Number of times this day was scheduled
  int get timesScheduled;
  @override

  /// Number of times workout was completed on this day
  int get timesCompleted;
  @override

  /// Adherence rate for this specific day of week
  double get adherenceRate;
  @override

  /// Average skip rate for this day
  double get skipRate;
  @override
  @JsonKey(ignore: true)
  _$$DayOfWeekPatternImplCopyWith<_$DayOfWeekPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoutineAnalyticsState _$RoutineAnalyticsStateFromJson(
    Map<String, dynamic> json) {
  return _RoutineAnalyticsState.fromJson(json);
}

/// @nodoc
mixin _$RoutineAnalyticsState {
  /// Routine ID being analyzed
  String get routineId => throw _privateConstructorUsedError;

  /// Routine name
  String get routineName => throw _privateConstructorUsedError;

  /// Overall adherence metrics
  RoutineAdherenceMetrics get adherenceMetrics =>
      throw _privateConstructorUsedError;

  /// Schedule matching data points
  List<ScheduleMatchData> get scheduleMatchData =>
      throw _privateConstructorUsedError;

  /// Weekly summaries for trend analysis
  List<WeeklyAdherenceSummary> get weeklySummaries =>
      throw _privateConstructorUsedError;

  /// Day of week patterns
  List<DayOfWeekPattern> get dayOfWeekPatterns =>
      throw _privateConstructorUsedError;

  /// Generated insights
  List<RoutineInsight> get insights => throw _privateConstructorUsedError;

  /// Whether data is currently loading
  bool get isLoading => throw _privateConstructorUsedError;

  /// Error message if loading failed
  String? get error => throw _privateConstructorUsedError;

  /// Last updated timestamp
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoutineAnalyticsStateCopyWith<RoutineAnalyticsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineAnalyticsStateCopyWith<$Res> {
  factory $RoutineAnalyticsStateCopyWith(RoutineAnalyticsState value,
          $Res Function(RoutineAnalyticsState) then) =
      _$RoutineAnalyticsStateCopyWithImpl<$Res, RoutineAnalyticsState>;
  @useResult
  $Res call(
      {String routineId,
      String routineName,
      RoutineAdherenceMetrics adherenceMetrics,
      List<ScheduleMatchData> scheduleMatchData,
      List<WeeklyAdherenceSummary> weeklySummaries,
      List<DayOfWeekPattern> dayOfWeekPatterns,
      List<RoutineInsight> insights,
      bool isLoading,
      String? error,
      DateTime? lastUpdated});

  $RoutineAdherenceMetricsCopyWith<$Res> get adherenceMetrics;
}

/// @nodoc
class _$RoutineAnalyticsStateCopyWithImpl<$Res,
        $Val extends RoutineAnalyticsState>
    implements $RoutineAnalyticsStateCopyWith<$Res> {
  _$RoutineAnalyticsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? routineName = null,
    Object? adherenceMetrics = null,
    Object? scheduleMatchData = null,
    Object? weeklySummaries = null,
    Object? dayOfWeekPatterns = null,
    Object? insights = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      routineId: null == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String,
      routineName: null == routineName
          ? _value.routineName
          : routineName // ignore: cast_nullable_to_non_nullable
              as String,
      adherenceMetrics: null == adherenceMetrics
          ? _value.adherenceMetrics
          : adherenceMetrics // ignore: cast_nullable_to_non_nullable
              as RoutineAdherenceMetrics,
      scheduleMatchData: null == scheduleMatchData
          ? _value.scheduleMatchData
          : scheduleMatchData // ignore: cast_nullable_to_non_nullable
              as List<ScheduleMatchData>,
      weeklySummaries: null == weeklySummaries
          ? _value.weeklySummaries
          : weeklySummaries // ignore: cast_nullable_to_non_nullable
              as List<WeeklyAdherenceSummary>,
      dayOfWeekPatterns: null == dayOfWeekPatterns
          ? _value.dayOfWeekPatterns
          : dayOfWeekPatterns // ignore: cast_nullable_to_non_nullable
              as List<DayOfWeekPattern>,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<RoutineInsight>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoutineAdherenceMetricsCopyWith<$Res> get adherenceMetrics {
    return $RoutineAdherenceMetricsCopyWith<$Res>(_value.adherenceMetrics,
        (value) {
      return _then(_value.copyWith(adherenceMetrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoutineAnalyticsStateImplCopyWith<$Res>
    implements $RoutineAnalyticsStateCopyWith<$Res> {
  factory _$$RoutineAnalyticsStateImplCopyWith(
          _$RoutineAnalyticsStateImpl value,
          $Res Function(_$RoutineAnalyticsStateImpl) then) =
      __$$RoutineAnalyticsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String routineId,
      String routineName,
      RoutineAdherenceMetrics adherenceMetrics,
      List<ScheduleMatchData> scheduleMatchData,
      List<WeeklyAdherenceSummary> weeklySummaries,
      List<DayOfWeekPattern> dayOfWeekPatterns,
      List<RoutineInsight> insights,
      bool isLoading,
      String? error,
      DateTime? lastUpdated});

  @override
  $RoutineAdherenceMetricsCopyWith<$Res> get adherenceMetrics;
}

/// @nodoc
class __$$RoutineAnalyticsStateImplCopyWithImpl<$Res>
    extends _$RoutineAnalyticsStateCopyWithImpl<$Res,
        _$RoutineAnalyticsStateImpl>
    implements _$$RoutineAnalyticsStateImplCopyWith<$Res> {
  __$$RoutineAnalyticsStateImplCopyWithImpl(_$RoutineAnalyticsStateImpl _value,
      $Res Function(_$RoutineAnalyticsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routineId = null,
    Object? routineName = null,
    Object? adherenceMetrics = null,
    Object? scheduleMatchData = null,
    Object? weeklySummaries = null,
    Object? dayOfWeekPatterns = null,
    Object? insights = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$RoutineAnalyticsStateImpl(
      routineId: null == routineId
          ? _value.routineId
          : routineId // ignore: cast_nullable_to_non_nullable
              as String,
      routineName: null == routineName
          ? _value.routineName
          : routineName // ignore: cast_nullable_to_non_nullable
              as String,
      adherenceMetrics: null == adherenceMetrics
          ? _value.adherenceMetrics
          : adherenceMetrics // ignore: cast_nullable_to_non_nullable
              as RoutineAdherenceMetrics,
      scheduleMatchData: null == scheduleMatchData
          ? _value._scheduleMatchData
          : scheduleMatchData // ignore: cast_nullable_to_non_nullable
              as List<ScheduleMatchData>,
      weeklySummaries: null == weeklySummaries
          ? _value._weeklySummaries
          : weeklySummaries // ignore: cast_nullable_to_non_nullable
              as List<WeeklyAdherenceSummary>,
      dayOfWeekPatterns: null == dayOfWeekPatterns
          ? _value._dayOfWeekPatterns
          : dayOfWeekPatterns // ignore: cast_nullable_to_non_nullable
              as List<DayOfWeekPattern>,
      insights: null == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<RoutineInsight>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineAnalyticsStateImpl implements _RoutineAnalyticsState {
  const _$RoutineAnalyticsStateImpl(
      {required this.routineId,
      required this.routineName,
      required this.adherenceMetrics,
      required final List<ScheduleMatchData> scheduleMatchData,
      required final List<WeeklyAdherenceSummary> weeklySummaries,
      required final List<DayOfWeekPattern> dayOfWeekPatterns,
      required final List<RoutineInsight> insights,
      this.isLoading = false,
      this.error,
      this.lastUpdated})
      : _scheduleMatchData = scheduleMatchData,
        _weeklySummaries = weeklySummaries,
        _dayOfWeekPatterns = dayOfWeekPatterns,
        _insights = insights;

  factory _$RoutineAnalyticsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineAnalyticsStateImplFromJson(json);

  /// Routine ID being analyzed
  @override
  final String routineId;

  /// Routine name
  @override
  final String routineName;

  /// Overall adherence metrics
  @override
  final RoutineAdherenceMetrics adherenceMetrics;

  /// Schedule matching data points
  final List<ScheduleMatchData> _scheduleMatchData;

  /// Schedule matching data points
  @override
  List<ScheduleMatchData> get scheduleMatchData {
    if (_scheduleMatchData is EqualUnmodifiableListView)
      return _scheduleMatchData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scheduleMatchData);
  }

  /// Weekly summaries for trend analysis
  final List<WeeklyAdherenceSummary> _weeklySummaries;

  /// Weekly summaries for trend analysis
  @override
  List<WeeklyAdherenceSummary> get weeklySummaries {
    if (_weeklySummaries is EqualUnmodifiableListView) return _weeklySummaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklySummaries);
  }

  /// Day of week patterns
  final List<DayOfWeekPattern> _dayOfWeekPatterns;

  /// Day of week patterns
  @override
  List<DayOfWeekPattern> get dayOfWeekPatterns {
    if (_dayOfWeekPatterns is EqualUnmodifiableListView)
      return _dayOfWeekPatterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dayOfWeekPatterns);
  }

  /// Generated insights
  final List<RoutineInsight> _insights;

  /// Generated insights
  @override
  List<RoutineInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  /// Whether data is currently loading
  @override
  @JsonKey()
  final bool isLoading;

  /// Error message if loading failed
  @override
  final String? error;

  /// Last updated timestamp
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'RoutineAnalyticsState(routineId: $routineId, routineName: $routineName, adherenceMetrics: $adherenceMetrics, scheduleMatchData: $scheduleMatchData, weeklySummaries: $weeklySummaries, dayOfWeekPatterns: $dayOfWeekPatterns, insights: $insights, isLoading: $isLoading, error: $error, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineAnalyticsStateImpl &&
            (identical(other.routineId, routineId) ||
                other.routineId == routineId) &&
            (identical(other.routineName, routineName) ||
                other.routineName == routineName) &&
            (identical(other.adherenceMetrics, adherenceMetrics) ||
                other.adherenceMetrics == adherenceMetrics) &&
            const DeepCollectionEquality()
                .equals(other._scheduleMatchData, _scheduleMatchData) &&
            const DeepCollectionEquality()
                .equals(other._weeklySummaries, _weeklySummaries) &&
            const DeepCollectionEquality()
                .equals(other._dayOfWeekPatterns, _dayOfWeekPatterns) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      routineId,
      routineName,
      adherenceMetrics,
      const DeepCollectionEquality().hash(_scheduleMatchData),
      const DeepCollectionEquality().hash(_weeklySummaries),
      const DeepCollectionEquality().hash(_dayOfWeekPatterns),
      const DeepCollectionEquality().hash(_insights),
      isLoading,
      error,
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineAnalyticsStateImplCopyWith<_$RoutineAnalyticsStateImpl>
      get copyWith => __$$RoutineAnalyticsStateImplCopyWithImpl<
          _$RoutineAnalyticsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineAnalyticsStateImplToJson(
      this,
    );
  }
}

abstract class _RoutineAnalyticsState implements RoutineAnalyticsState {
  const factory _RoutineAnalyticsState(
      {required final String routineId,
      required final String routineName,
      required final RoutineAdherenceMetrics adherenceMetrics,
      required final List<ScheduleMatchData> scheduleMatchData,
      required final List<WeeklyAdherenceSummary> weeklySummaries,
      required final List<DayOfWeekPattern> dayOfWeekPatterns,
      required final List<RoutineInsight> insights,
      final bool isLoading,
      final String? error,
      final DateTime? lastUpdated}) = _$RoutineAnalyticsStateImpl;

  factory _RoutineAnalyticsState.fromJson(Map<String, dynamic> json) =
      _$RoutineAnalyticsStateImpl.fromJson;

  @override

  /// Routine ID being analyzed
  String get routineId;
  @override

  /// Routine name
  String get routineName;
  @override

  /// Overall adherence metrics
  RoutineAdherenceMetrics get adherenceMetrics;
  @override

  /// Schedule matching data points
  List<ScheduleMatchData> get scheduleMatchData;
  @override

  /// Weekly summaries for trend analysis
  List<WeeklyAdherenceSummary> get weeklySummaries;
  @override

  /// Day of week patterns
  List<DayOfWeekPattern> get dayOfWeekPatterns;
  @override

  /// Generated insights
  List<RoutineInsight> get insights;
  @override

  /// Whether data is currently loading
  bool get isLoading;
  @override

  /// Error message if loading failed
  String? get error;
  @override

  /// Last updated timestamp
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$RoutineAnalyticsStateImplCopyWith<_$RoutineAnalyticsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
