// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeeklyStats _$WeeklyStatsFromJson(Map<String, dynamic> json) {
  return _WeeklyStats.fromJson(json);
}

/// @nodoc
mixin _$WeeklyStats {
  /// Average workouts completed per week
  double get avgWorkoutsPerWeek => throw _privateConstructorUsedError;

  /// Average rest days per week
  double get avgRestDaysPerWeek => throw _privateConstructorUsedError;

  /// Total workouts in period
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Total rest days in period
  int get totalRestDays => throw _privateConstructorUsedError;

  /// Total active days (days with at least one workout)
  int get totalActiveDays => throw _privateConstructorUsedError;

  /// Week start date
  DateTime? get weekStartDate => throw _privateConstructorUsedError;

  /// Week end date
  DateTime? get weekEndDate => throw _privateConstructorUsedError;

  /// Serializes this WeeklyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyStatsCopyWith<WeeklyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyStatsCopyWith<$Res> {
  factory $WeeklyStatsCopyWith(
    WeeklyStats value,
    $Res Function(WeeklyStats) then,
  ) = _$WeeklyStatsCopyWithImpl<$Res, WeeklyStats>;
  @useResult
  $Res call({
    double avgWorkoutsPerWeek,
    double avgRestDaysPerWeek,
    int totalWorkouts,
    int totalRestDays,
    int totalActiveDays,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
  });
}

/// @nodoc
class _$WeeklyStatsCopyWithImpl<$Res, $Val extends WeeklyStats>
    implements $WeeklyStatsCopyWith<$Res> {
  _$WeeklyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgWorkoutsPerWeek = null,
    Object? avgRestDaysPerWeek = null,
    Object? totalWorkouts = null,
    Object? totalRestDays = null,
    Object? totalActiveDays = null,
    Object? weekStartDate = freezed,
    Object? weekEndDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            avgWorkoutsPerWeek: null == avgWorkoutsPerWeek
                ? _value.avgWorkoutsPerWeek
                : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
                      as double,
            avgRestDaysPerWeek: null == avgRestDaysPerWeek
                ? _value.avgRestDaysPerWeek
                : avgRestDaysPerWeek // ignore: cast_nullable_to_non_nullable
                      as double,
            totalWorkouts: null == totalWorkouts
                ? _value.totalWorkouts
                : totalWorkouts // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRestDays: null == totalRestDays
                ? _value.totalRestDays
                : totalRestDays // ignore: cast_nullable_to_non_nullable
                      as int,
            totalActiveDays: null == totalActiveDays
                ? _value.totalActiveDays
                : totalActiveDays // ignore: cast_nullable_to_non_nullable
                      as int,
            weekStartDate: freezed == weekStartDate
                ? _value.weekStartDate
                : weekStartDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            weekEndDate: freezed == weekEndDate
                ? _value.weekEndDate
                : weekEndDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyStatsImplCopyWith<$Res>
    implements $WeeklyStatsCopyWith<$Res> {
  factory _$$WeeklyStatsImplCopyWith(
    _$WeeklyStatsImpl value,
    $Res Function(_$WeeklyStatsImpl) then,
  ) = __$$WeeklyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double avgWorkoutsPerWeek,
    double avgRestDaysPerWeek,
    int totalWorkouts,
    int totalRestDays,
    int totalActiveDays,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
  });
}

/// @nodoc
class __$$WeeklyStatsImplCopyWithImpl<$Res>
    extends _$WeeklyStatsCopyWithImpl<$Res, _$WeeklyStatsImpl>
    implements _$$WeeklyStatsImplCopyWith<$Res> {
  __$$WeeklyStatsImplCopyWithImpl(
    _$WeeklyStatsImpl _value,
    $Res Function(_$WeeklyStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgWorkoutsPerWeek = null,
    Object? avgRestDaysPerWeek = null,
    Object? totalWorkouts = null,
    Object? totalRestDays = null,
    Object? totalActiveDays = null,
    Object? weekStartDate = freezed,
    Object? weekEndDate = freezed,
  }) {
    return _then(
      _$WeeklyStatsImpl(
        avgWorkoutsPerWeek: null == avgWorkoutsPerWeek
            ? _value.avgWorkoutsPerWeek
            : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
                  as double,
        avgRestDaysPerWeek: null == avgRestDaysPerWeek
            ? _value.avgRestDaysPerWeek
            : avgRestDaysPerWeek // ignore: cast_nullable_to_non_nullable
                  as double,
        totalWorkouts: null == totalWorkouts
            ? _value.totalWorkouts
            : totalWorkouts // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRestDays: null == totalRestDays
            ? _value.totalRestDays
            : totalRestDays // ignore: cast_nullable_to_non_nullable
                  as int,
        totalActiveDays: null == totalActiveDays
            ? _value.totalActiveDays
            : totalActiveDays // ignore: cast_nullable_to_non_nullable
                  as int,
        weekStartDate: freezed == weekStartDate
            ? _value.weekStartDate
            : weekStartDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        weekEndDate: freezed == weekEndDate
            ? _value.weekEndDate
            : weekEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyStatsImpl implements _WeeklyStats {
  const _$WeeklyStatsImpl({
    this.avgWorkoutsPerWeek = 0.0,
    this.avgRestDaysPerWeek = 0.0,
    this.totalWorkouts = 0,
    this.totalRestDays = 0,
    this.totalActiveDays = 0,
    this.weekStartDate,
    this.weekEndDate,
  });

  factory _$WeeklyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyStatsImplFromJson(json);

  /// Average workouts completed per week
  @override
  @JsonKey()
  final double avgWorkoutsPerWeek;

  /// Average rest days per week
  @override
  @JsonKey()
  final double avgRestDaysPerWeek;

  /// Total workouts in period
  @override
  @JsonKey()
  final int totalWorkouts;

  /// Total rest days in period
  @override
  @JsonKey()
  final int totalRestDays;

  /// Total active days (days with at least one workout)
  @override
  @JsonKey()
  final int totalActiveDays;

  /// Week start date
  @override
  final DateTime? weekStartDate;

  /// Week end date
  @override
  final DateTime? weekEndDate;

  @override
  String toString() {
    return 'WeeklyStats(avgWorkoutsPerWeek: $avgWorkoutsPerWeek, avgRestDaysPerWeek: $avgRestDaysPerWeek, totalWorkouts: $totalWorkouts, totalRestDays: $totalRestDays, totalActiveDays: $totalActiveDays, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyStatsImpl &&
            (identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) ||
                other.avgWorkoutsPerWeek == avgWorkoutsPerWeek) &&
            (identical(other.avgRestDaysPerWeek, avgRestDaysPerWeek) ||
                other.avgRestDaysPerWeek == avgRestDaysPerWeek) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalRestDays, totalRestDays) ||
                other.totalRestDays == totalRestDays) &&
            (identical(other.totalActiveDays, totalActiveDays) ||
                other.totalActiveDays == totalActiveDays) &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.weekEndDate, weekEndDate) ||
                other.weekEndDate == weekEndDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    avgWorkoutsPerWeek,
    avgRestDaysPerWeek,
    totalWorkouts,
    totalRestDays,
    totalActiveDays,
    weekStartDate,
    weekEndDate,
  );

  /// Create a copy of WeeklyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyStatsImplCopyWith<_$WeeklyStatsImpl> get copyWith =>
      __$$WeeklyStatsImplCopyWithImpl<_$WeeklyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyStatsImplToJson(this);
  }
}

abstract class _WeeklyStats implements WeeklyStats {
  const factory _WeeklyStats({
    final double avgWorkoutsPerWeek,
    final double avgRestDaysPerWeek,
    final int totalWorkouts,
    final int totalRestDays,
    final int totalActiveDays,
    final DateTime? weekStartDate,
    final DateTime? weekEndDate,
  }) = _$WeeklyStatsImpl;

  factory _WeeklyStats.fromJson(Map<String, dynamic> json) =
      _$WeeklyStatsImpl.fromJson;

  /// Average workouts completed per week
  @override
  double get avgWorkoutsPerWeek;

  /// Average rest days per week
  @override
  double get avgRestDaysPerWeek;

  /// Total workouts in period
  @override
  int get totalWorkouts;

  /// Total rest days in period
  @override
  int get totalRestDays;

  /// Total active days (days with at least one workout)
  @override
  int get totalActiveDays;

  /// Week start date
  @override
  DateTime? get weekStartDate;

  /// Week end date
  @override
  DateTime? get weekEndDate;

  /// Create a copy of WeeklyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyStatsImplCopyWith<_$WeeklyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
