// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_distribution_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MuscleDistributionData _$MuscleDistributionDataFromJson(
    Map<String, dynamic> json) {
  return _MuscleDistributionData.fromJson(json);
}

/// @nodoc
mixin _$MuscleDistributionData {
  /// Mappa gruppo muscolare → volume totale (kg)
  Map<MuscleGroup, double> get volumeByMuscle =>
      throw _privateConstructorUsedError;

  /// Mappa gruppo muscolare → numero di serie
  Map<MuscleGroup, int> get setsByMuscle => throw _privateConstructorUsedError;

  /// Mappa gruppo muscolare → percentuale di volume (0-100)
  Map<MuscleGroup, double> get volumePercentage =>
      throw _privateConstructorUsedError;

  /// Periodo temporale di riferimento
  TimePeriod get period => throw _privateConstructorUsedError;

  /// Data inizio periodo
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Data fine periodo (tipicamente oggi)
  DateTime get endDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleDistributionDataCopyWith<MuscleDistributionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleDistributionDataCopyWith<$Res> {
  factory $MuscleDistributionDataCopyWith(MuscleDistributionData value,
          $Res Function(MuscleDistributionData) then) =
      _$MuscleDistributionDataCopyWithImpl<$Res, MuscleDistributionData>;
  @useResult
  $Res call(
      {Map<MuscleGroup, double> volumeByMuscle,
      Map<MuscleGroup, int> setsByMuscle,
      Map<MuscleGroup, double> volumePercentage,
      TimePeriod period,
      DateTime startDate,
      DateTime endDate});
}

/// @nodoc
class _$MuscleDistributionDataCopyWithImpl<$Res,
        $Val extends MuscleDistributionData>
    implements $MuscleDistributionDataCopyWith<$Res> {
  _$MuscleDistributionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? volumeByMuscle = null,
    Object? setsByMuscle = null,
    Object? volumePercentage = null,
    Object? period = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_value.copyWith(
      volumeByMuscle: null == volumeByMuscle
          ? _value.volumeByMuscle
          : volumeByMuscle // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, double>,
      setsByMuscle: null == setsByMuscle
          ? _value.setsByMuscle
          : setsByMuscle // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, int>,
      volumePercentage: null == volumePercentage
          ? _value.volumePercentage
          : volumePercentage // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, double>,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as TimePeriod,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuscleDistributionDataImplCopyWith<$Res>
    implements $MuscleDistributionDataCopyWith<$Res> {
  factory _$$MuscleDistributionDataImplCopyWith(
          _$MuscleDistributionDataImpl value,
          $Res Function(_$MuscleDistributionDataImpl) then) =
      __$$MuscleDistributionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<MuscleGroup, double> volumeByMuscle,
      Map<MuscleGroup, int> setsByMuscle,
      Map<MuscleGroup, double> volumePercentage,
      TimePeriod period,
      DateTime startDate,
      DateTime endDate});
}

/// @nodoc
class __$$MuscleDistributionDataImplCopyWithImpl<$Res>
    extends _$MuscleDistributionDataCopyWithImpl<$Res,
        _$MuscleDistributionDataImpl>
    implements _$$MuscleDistributionDataImplCopyWith<$Res> {
  __$$MuscleDistributionDataImplCopyWithImpl(
      _$MuscleDistributionDataImpl _value,
      $Res Function(_$MuscleDistributionDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? volumeByMuscle = null,
    Object? setsByMuscle = null,
    Object? volumePercentage = null,
    Object? period = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_$MuscleDistributionDataImpl(
      volumeByMuscle: null == volumeByMuscle
          ? _value._volumeByMuscle
          : volumeByMuscle // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, double>,
      setsByMuscle: null == setsByMuscle
          ? _value._setsByMuscle
          : setsByMuscle // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, int>,
      volumePercentage: null == volumePercentage
          ? _value._volumePercentage
          : volumePercentage // ignore: cast_nullable_to_non_nullable
              as Map<MuscleGroup, double>,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as TimePeriod,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleDistributionDataImpl implements _MuscleDistributionData {
  const _$MuscleDistributionDataImpl(
      {required final Map<MuscleGroup, double> volumeByMuscle,
      required final Map<MuscleGroup, int> setsByMuscle,
      required final Map<MuscleGroup, double> volumePercentage,
      required this.period,
      required this.startDate,
      required this.endDate})
      : _volumeByMuscle = volumeByMuscle,
        _setsByMuscle = setsByMuscle,
        _volumePercentage = volumePercentage;

  factory _$MuscleDistributionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleDistributionDataImplFromJson(json);

  /// Mappa gruppo muscolare → volume totale (kg)
  final Map<MuscleGroup, double> _volumeByMuscle;

  /// Mappa gruppo muscolare → volume totale (kg)
  @override
  Map<MuscleGroup, double> get volumeByMuscle {
    if (_volumeByMuscle is EqualUnmodifiableMapView) return _volumeByMuscle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_volumeByMuscle);
  }

  /// Mappa gruppo muscolare → numero di serie
  final Map<MuscleGroup, int> _setsByMuscle;

  /// Mappa gruppo muscolare → numero di serie
  @override
  Map<MuscleGroup, int> get setsByMuscle {
    if (_setsByMuscle is EqualUnmodifiableMapView) return _setsByMuscle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_setsByMuscle);
  }

  /// Mappa gruppo muscolare → percentuale di volume (0-100)
  final Map<MuscleGroup, double> _volumePercentage;

  /// Mappa gruppo muscolare → percentuale di volume (0-100)
  @override
  Map<MuscleGroup, double> get volumePercentage {
    if (_volumePercentage is EqualUnmodifiableMapView) return _volumePercentage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_volumePercentage);
  }

  /// Periodo temporale di riferimento
  @override
  final TimePeriod period;

  /// Data inizio periodo
  @override
  final DateTime startDate;

  /// Data fine periodo (tipicamente oggi)
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'MuscleDistributionData(volumeByMuscle: $volumeByMuscle, setsByMuscle: $setsByMuscle, volumePercentage: $volumePercentage, period: $period, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleDistributionDataImpl &&
            const DeepCollectionEquality()
                .equals(other._volumeByMuscle, _volumeByMuscle) &&
            const DeepCollectionEquality()
                .equals(other._setsByMuscle, _setsByMuscle) &&
            const DeepCollectionEquality()
                .equals(other._volumePercentage, _volumePercentage) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_volumeByMuscle),
      const DeepCollectionEquality().hash(_setsByMuscle),
      const DeepCollectionEquality().hash(_volumePercentage),
      period,
      startDate,
      endDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleDistributionDataImplCopyWith<_$MuscleDistributionDataImpl>
      get copyWith => __$$MuscleDistributionDataImplCopyWithImpl<
          _$MuscleDistributionDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleDistributionDataImplToJson(
      this,
    );
  }
}

abstract class _MuscleDistributionData implements MuscleDistributionData {
  const factory _MuscleDistributionData(
      {required final Map<MuscleGroup, double> volumeByMuscle,
      required final Map<MuscleGroup, int> setsByMuscle,
      required final Map<MuscleGroup, double> volumePercentage,
      required final TimePeriod period,
      required final DateTime startDate,
      required final DateTime endDate}) = _$MuscleDistributionDataImpl;

  factory _MuscleDistributionData.fromJson(Map<String, dynamic> json) =
      _$MuscleDistributionDataImpl.fromJson;

  @override

  /// Mappa gruppo muscolare → volume totale (kg)
  Map<MuscleGroup, double> get volumeByMuscle;
  @override

  /// Mappa gruppo muscolare → numero di serie
  Map<MuscleGroup, int> get setsByMuscle;
  @override

  /// Mappa gruppo muscolare → percentuale di volume (0-100)
  Map<MuscleGroup, double> get volumePercentage;
  @override

  /// Periodo temporale di riferimento
  TimePeriod get period;
  @override

  /// Data inizio periodo
  DateTime get startDate;
  @override

  /// Data fine periodo (tipicamente oggi)
  DateTime get endDate;
  @override
  @JsonKey(ignore: true)
  _$$MuscleDistributionDataImplCopyWith<_$MuscleDistributionDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PeriodStatistics _$PeriodStatisticsFromJson(Map<String, dynamic> json) {
  return _PeriodStatistics.fromJson(json);
}

/// @nodoc
mixin _$PeriodStatistics {
  /// Numero di allenamenti completati
  int get workoutsCount => throw _privateConstructorUsedError;

  /// Durata totale in minuti
  int get totalDurationMinutes => throw _privateConstructorUsedError;

  /// Volume totale sollevato (kg)
  double get totalVolumeKg => throw _privateConstructorUsedError;

  /// Numero totale di serie completate
  int get totalSets => throw _privateConstructorUsedError;

  /// Periodo di riferimento
  TimePeriod get period => throw _privateConstructorUsedError;

  /// Data inizio periodo
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Data fine periodo
  DateTime get endDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PeriodStatisticsCopyWith<PeriodStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeriodStatisticsCopyWith<$Res> {
  factory $PeriodStatisticsCopyWith(
          PeriodStatistics value, $Res Function(PeriodStatistics) then) =
      _$PeriodStatisticsCopyWithImpl<$Res, PeriodStatistics>;
  @useResult
  $Res call(
      {int workoutsCount,
      int totalDurationMinutes,
      double totalVolumeKg,
      int totalSets,
      TimePeriod period,
      DateTime startDate,
      DateTime endDate});
}

/// @nodoc
class _$PeriodStatisticsCopyWithImpl<$Res, $Val extends PeriodStatistics>
    implements $PeriodStatisticsCopyWith<$Res> {
  _$PeriodStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutsCount = null,
    Object? totalDurationMinutes = null,
    Object? totalVolumeKg = null,
    Object? totalSets = null,
    Object? period = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_value.copyWith(
      workoutsCount: null == workoutsCount
          ? _value.workoutsCount
          : workoutsCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMinutes: null == totalDurationMinutes
          ? _value.totalDurationMinutes
          : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolumeKg: null == totalVolumeKg
          ? _value.totalVolumeKg
          : totalVolumeKg // ignore: cast_nullable_to_non_nullable
              as double,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as TimePeriod,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeriodStatisticsImplCopyWith<$Res>
    implements $PeriodStatisticsCopyWith<$Res> {
  factory _$$PeriodStatisticsImplCopyWith(_$PeriodStatisticsImpl value,
          $Res Function(_$PeriodStatisticsImpl) then) =
      __$$PeriodStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int workoutsCount,
      int totalDurationMinutes,
      double totalVolumeKg,
      int totalSets,
      TimePeriod period,
      DateTime startDate,
      DateTime endDate});
}

/// @nodoc
class __$$PeriodStatisticsImplCopyWithImpl<$Res>
    extends _$PeriodStatisticsCopyWithImpl<$Res, _$PeriodStatisticsImpl>
    implements _$$PeriodStatisticsImplCopyWith<$Res> {
  __$$PeriodStatisticsImplCopyWithImpl(_$PeriodStatisticsImpl _value,
      $Res Function(_$PeriodStatisticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutsCount = null,
    Object? totalDurationMinutes = null,
    Object? totalVolumeKg = null,
    Object? totalSets = null,
    Object? period = null,
    Object? startDate = null,
    Object? endDate = null,
  }) {
    return _then(_$PeriodStatisticsImpl(
      workoutsCount: null == workoutsCount
          ? _value.workoutsCount
          : workoutsCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMinutes: null == totalDurationMinutes
          ? _value.totalDurationMinutes
          : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolumeKg: null == totalVolumeKg
          ? _value.totalVolumeKg
          : totalVolumeKg // ignore: cast_nullable_to_non_nullable
              as double,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as TimePeriod,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PeriodStatisticsImpl implements _PeriodStatistics {
  const _$PeriodStatisticsImpl(
      {required this.workoutsCount,
      required this.totalDurationMinutes,
      required this.totalVolumeKg,
      required this.totalSets,
      required this.period,
      required this.startDate,
      required this.endDate});

  factory _$PeriodStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeriodStatisticsImplFromJson(json);

  /// Numero di allenamenti completati
  @override
  final int workoutsCount;

  /// Durata totale in minuti
  @override
  final int totalDurationMinutes;

  /// Volume totale sollevato (kg)
  @override
  final double totalVolumeKg;

  /// Numero totale di serie completate
  @override
  final int totalSets;

  /// Periodo di riferimento
  @override
  final TimePeriod period;

  /// Data inizio periodo
  @override
  final DateTime startDate;

  /// Data fine periodo
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'PeriodStatistics(workoutsCount: $workoutsCount, totalDurationMinutes: $totalDurationMinutes, totalVolumeKg: $totalVolumeKg, totalSets: $totalSets, period: $period, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeriodStatisticsImpl &&
            (identical(other.workoutsCount, workoutsCount) ||
                other.workoutsCount == workoutsCount) &&
            (identical(other.totalDurationMinutes, totalDurationMinutes) ||
                other.totalDurationMinutes == totalDurationMinutes) &&
            (identical(other.totalVolumeKg, totalVolumeKg) ||
                other.totalVolumeKg == totalVolumeKg) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      workoutsCount,
      totalDurationMinutes,
      totalVolumeKg,
      totalSets,
      period,
      startDate,
      endDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PeriodStatisticsImplCopyWith<_$PeriodStatisticsImpl> get copyWith =>
      __$$PeriodStatisticsImplCopyWithImpl<_$PeriodStatisticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeriodStatisticsImplToJson(
      this,
    );
  }
}

abstract class _PeriodStatistics implements PeriodStatistics {
  const factory _PeriodStatistics(
      {required final int workoutsCount,
      required final int totalDurationMinutes,
      required final double totalVolumeKg,
      required final int totalSets,
      required final TimePeriod period,
      required final DateTime startDate,
      required final DateTime endDate}) = _$PeriodStatisticsImpl;

  factory _PeriodStatistics.fromJson(Map<String, dynamic> json) =
      _$PeriodStatisticsImpl.fromJson;

  @override

  /// Numero di allenamenti completati
  int get workoutsCount;
  @override

  /// Durata totale in minuti
  int get totalDurationMinutes;
  @override

  /// Volume totale sollevato (kg)
  double get totalVolumeKg;
  @override

  /// Numero totale di serie completate
  int get totalSets;
  @override

  /// Periodo di riferimento
  TimePeriod get period;
  @override

  /// Data inizio periodo
  DateTime get startDate;
  @override

  /// Data fine periodo
  DateTime get endDate;
  @override
  @JsonKey(ignore: true)
  _$$PeriodStatisticsImplCopyWith<_$PeriodStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MuscleAnalyticsData _$MuscleAnalyticsDataFromJson(Map<String, dynamic> json) {
  return _MuscleAnalyticsData.fromJson(json);
}

/// @nodoc
mixin _$MuscleAnalyticsData {
  /// Distribuzione muscolare periodo attuale
  MuscleDistributionData get current => throw _privateConstructorUsedError;

  /// Distribuzione muscolare periodo precedente (per confronto radar chart)
  MuscleDistributionData get previous => throw _privateConstructorUsedError;

  /// Statistiche aggregate periodo attuale
  PeriodStatistics get currentStats => throw _privateConstructorUsedError;

  /// Statistiche aggregate periodo precedente
  PeriodStatistics get previousStats => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleAnalyticsDataCopyWith<MuscleAnalyticsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleAnalyticsDataCopyWith<$Res> {
  factory $MuscleAnalyticsDataCopyWith(
          MuscleAnalyticsData value, $Res Function(MuscleAnalyticsData) then) =
      _$MuscleAnalyticsDataCopyWithImpl<$Res, MuscleAnalyticsData>;
  @useResult
  $Res call(
      {MuscleDistributionData current,
      MuscleDistributionData previous,
      PeriodStatistics currentStats,
      PeriodStatistics previousStats});

  $MuscleDistributionDataCopyWith<$Res> get current;
  $MuscleDistributionDataCopyWith<$Res> get previous;
  $PeriodStatisticsCopyWith<$Res> get currentStats;
  $PeriodStatisticsCopyWith<$Res> get previousStats;
}

/// @nodoc
class _$MuscleAnalyticsDataCopyWithImpl<$Res, $Val extends MuscleAnalyticsData>
    implements $MuscleAnalyticsDataCopyWith<$Res> {
  _$MuscleAnalyticsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? previous = null,
    Object? currentStats = null,
    Object? previousStats = null,
  }) {
    return _then(_value.copyWith(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as MuscleDistributionData,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as MuscleDistributionData,
      currentStats: null == currentStats
          ? _value.currentStats
          : currentStats // ignore: cast_nullable_to_non_nullable
              as PeriodStatistics,
      previousStats: null == previousStats
          ? _value.previousStats
          : previousStats // ignore: cast_nullable_to_non_nullable
              as PeriodStatistics,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MuscleDistributionDataCopyWith<$Res> get current {
    return $MuscleDistributionDataCopyWith<$Res>(_value.current, (value) {
      return _then(_value.copyWith(current: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MuscleDistributionDataCopyWith<$Res> get previous {
    return $MuscleDistributionDataCopyWith<$Res>(_value.previous, (value) {
      return _then(_value.copyWith(previous: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PeriodStatisticsCopyWith<$Res> get currentStats {
    return $PeriodStatisticsCopyWith<$Res>(_value.currentStats, (value) {
      return _then(_value.copyWith(currentStats: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PeriodStatisticsCopyWith<$Res> get previousStats {
    return $PeriodStatisticsCopyWith<$Res>(_value.previousStats, (value) {
      return _then(_value.copyWith(previousStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MuscleAnalyticsDataImplCopyWith<$Res>
    implements $MuscleAnalyticsDataCopyWith<$Res> {
  factory _$$MuscleAnalyticsDataImplCopyWith(_$MuscleAnalyticsDataImpl value,
          $Res Function(_$MuscleAnalyticsDataImpl) then) =
      __$$MuscleAnalyticsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MuscleDistributionData current,
      MuscleDistributionData previous,
      PeriodStatistics currentStats,
      PeriodStatistics previousStats});

  @override
  $MuscleDistributionDataCopyWith<$Res> get current;
  @override
  $MuscleDistributionDataCopyWith<$Res> get previous;
  @override
  $PeriodStatisticsCopyWith<$Res> get currentStats;
  @override
  $PeriodStatisticsCopyWith<$Res> get previousStats;
}

/// @nodoc
class __$$MuscleAnalyticsDataImplCopyWithImpl<$Res>
    extends _$MuscleAnalyticsDataCopyWithImpl<$Res, _$MuscleAnalyticsDataImpl>
    implements _$$MuscleAnalyticsDataImplCopyWith<$Res> {
  __$$MuscleAnalyticsDataImplCopyWithImpl(_$MuscleAnalyticsDataImpl _value,
      $Res Function(_$MuscleAnalyticsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? previous = null,
    Object? currentStats = null,
    Object? previousStats = null,
  }) {
    return _then(_$MuscleAnalyticsDataImpl(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as MuscleDistributionData,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as MuscleDistributionData,
      currentStats: null == currentStats
          ? _value.currentStats
          : currentStats // ignore: cast_nullable_to_non_nullable
              as PeriodStatistics,
      previousStats: null == previousStats
          ? _value.previousStats
          : previousStats // ignore: cast_nullable_to_non_nullable
              as PeriodStatistics,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleAnalyticsDataImpl implements _MuscleAnalyticsData {
  const _$MuscleAnalyticsDataImpl(
      {required this.current,
      required this.previous,
      required this.currentStats,
      required this.previousStats});

  factory _$MuscleAnalyticsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleAnalyticsDataImplFromJson(json);

  /// Distribuzione muscolare periodo attuale
  @override
  final MuscleDistributionData current;

  /// Distribuzione muscolare periodo precedente (per confronto radar chart)
  @override
  final MuscleDistributionData previous;

  /// Statistiche aggregate periodo attuale
  @override
  final PeriodStatistics currentStats;

  /// Statistiche aggregate periodo precedente
  @override
  final PeriodStatistics previousStats;

  @override
  String toString() {
    return 'MuscleAnalyticsData(current: $current, previous: $previous, currentStats: $currentStats, previousStats: $previousStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleAnalyticsDataImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            (identical(other.currentStats, currentStats) ||
                other.currentStats == currentStats) &&
            (identical(other.previousStats, previousStats) ||
                other.previousStats == previousStats));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, current, previous, currentStats, previousStats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleAnalyticsDataImplCopyWith<_$MuscleAnalyticsDataImpl> get copyWith =>
      __$$MuscleAnalyticsDataImplCopyWithImpl<_$MuscleAnalyticsDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleAnalyticsDataImplToJson(
      this,
    );
  }
}

abstract class _MuscleAnalyticsData implements MuscleAnalyticsData {
  const factory _MuscleAnalyticsData(
          {required final MuscleDistributionData current,
          required final MuscleDistributionData previous,
          required final PeriodStatistics currentStats,
          required final PeriodStatistics previousStats}) =
      _$MuscleAnalyticsDataImpl;

  factory _MuscleAnalyticsData.fromJson(Map<String, dynamic> json) =
      _$MuscleAnalyticsDataImpl.fromJson;

  @override

  /// Distribuzione muscolare periodo attuale
  MuscleDistributionData get current;
  @override

  /// Distribuzione muscolare periodo precedente (per confronto radar chart)
  MuscleDistributionData get previous;
  @override

  /// Statistiche aggregate periodo attuale
  PeriodStatistics get currentStats;
  @override

  /// Statistiche aggregate periodo precedente
  PeriodStatistics get previousStats;
  @override
  @JsonKey(ignore: true)
  _$$MuscleAnalyticsDataImplCopyWith<_$MuscleAnalyticsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
