// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muscle_distribution_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MuscleDistributionData {

/// Mappa gruppo muscolare → volume totale (kg)
 Map<MuscleGroup, double> get volumeByMuscle;/// Mappa gruppo muscolare → numero di serie
 Map<MuscleGroup, int> get setsByMuscle;/// Mappa gruppo muscolare → percentuale di volume (0-100)
 Map<MuscleGroup, double> get volumePercentage;/// Periodo temporale di riferimento
 TimePeriod get period;/// Data inizio periodo
 DateTime get startDate;/// Data fine periodo (tipicamente oggi)
 DateTime get endDate;
/// Create a copy of MuscleDistributionData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleDistributionDataCopyWith<MuscleDistributionData> get copyWith => _$MuscleDistributionDataCopyWithImpl<MuscleDistributionData>(this as MuscleDistributionData, _$identity);

  /// Serializes this MuscleDistributionData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleDistributionData&&const DeepCollectionEquality().equals(other.volumeByMuscle, volumeByMuscle)&&const DeepCollectionEquality().equals(other.setsByMuscle, setsByMuscle)&&const DeepCollectionEquality().equals(other.volumePercentage, volumePercentage)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(volumeByMuscle),const DeepCollectionEquality().hash(setsByMuscle),const DeepCollectionEquality().hash(volumePercentage),period,startDate,endDate);

@override
String toString() {
  return 'MuscleDistributionData(volumeByMuscle: $volumeByMuscle, setsByMuscle: $setsByMuscle, volumePercentage: $volumePercentage, period: $period, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $MuscleDistributionDataCopyWith<$Res>  {
  factory $MuscleDistributionDataCopyWith(MuscleDistributionData value, $Res Function(MuscleDistributionData) _then) = _$MuscleDistributionDataCopyWithImpl;
@useResult
$Res call({
 Map<MuscleGroup, double> volumeByMuscle, Map<MuscleGroup, int> setsByMuscle, Map<MuscleGroup, double> volumePercentage, TimePeriod period, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class _$MuscleDistributionDataCopyWithImpl<$Res>
    implements $MuscleDistributionDataCopyWith<$Res> {
  _$MuscleDistributionDataCopyWithImpl(this._self, this._then);

  final MuscleDistributionData _self;
  final $Res Function(MuscleDistributionData) _then;

/// Create a copy of MuscleDistributionData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? volumeByMuscle = null,Object? setsByMuscle = null,Object? volumePercentage = null,Object? period = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_self.copyWith(
volumeByMuscle: null == volumeByMuscle ? _self.volumeByMuscle : volumeByMuscle // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, double>,setsByMuscle: null == setsByMuscle ? _self.setsByMuscle : setsByMuscle // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, int>,volumePercentage: null == volumePercentage ? _self.volumePercentage : volumePercentage // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, double>,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as TimePeriod,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleDistributionData].
extension MuscleDistributionDataPatterns on MuscleDistributionData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleDistributionData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleDistributionData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleDistributionData value)  $default,){
final _that = this;
switch (_that) {
case _MuscleDistributionData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleDistributionData value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleDistributionData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<MuscleGroup, double> volumeByMuscle,  Map<MuscleGroup, int> setsByMuscle,  Map<MuscleGroup, double> volumePercentage,  TimePeriod period,  DateTime startDate,  DateTime endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleDistributionData() when $default != null:
return $default(_that.volumeByMuscle,_that.setsByMuscle,_that.volumePercentage,_that.period,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<MuscleGroup, double> volumeByMuscle,  Map<MuscleGroup, int> setsByMuscle,  Map<MuscleGroup, double> volumePercentage,  TimePeriod period,  DateTime startDate,  DateTime endDate)  $default,) {final _that = this;
switch (_that) {
case _MuscleDistributionData():
return $default(_that.volumeByMuscle,_that.setsByMuscle,_that.volumePercentage,_that.period,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<MuscleGroup, double> volumeByMuscle,  Map<MuscleGroup, int> setsByMuscle,  Map<MuscleGroup, double> volumePercentage,  TimePeriod period,  DateTime startDate,  DateTime endDate)?  $default,) {final _that = this;
switch (_that) {
case _MuscleDistributionData() when $default != null:
return $default(_that.volumeByMuscle,_that.setsByMuscle,_that.volumePercentage,_that.period,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleDistributionData implements MuscleDistributionData {
  const _MuscleDistributionData({required final  Map<MuscleGroup, double> volumeByMuscle, required final  Map<MuscleGroup, int> setsByMuscle, required final  Map<MuscleGroup, double> volumePercentage, required this.period, required this.startDate, required this.endDate}): _volumeByMuscle = volumeByMuscle,_setsByMuscle = setsByMuscle,_volumePercentage = volumePercentage;
  factory _MuscleDistributionData.fromJson(Map<String, dynamic> json) => _$MuscleDistributionDataFromJson(json);

/// Mappa gruppo muscolare → volume totale (kg)
 final  Map<MuscleGroup, double> _volumeByMuscle;
/// Mappa gruppo muscolare → volume totale (kg)
@override Map<MuscleGroup, double> get volumeByMuscle {
  if (_volumeByMuscle is EqualUnmodifiableMapView) return _volumeByMuscle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_volumeByMuscle);
}

/// Mappa gruppo muscolare → numero di serie
 final  Map<MuscleGroup, int> _setsByMuscle;
/// Mappa gruppo muscolare → numero di serie
@override Map<MuscleGroup, int> get setsByMuscle {
  if (_setsByMuscle is EqualUnmodifiableMapView) return _setsByMuscle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_setsByMuscle);
}

/// Mappa gruppo muscolare → percentuale di volume (0-100)
 final  Map<MuscleGroup, double> _volumePercentage;
/// Mappa gruppo muscolare → percentuale di volume (0-100)
@override Map<MuscleGroup, double> get volumePercentage {
  if (_volumePercentage is EqualUnmodifiableMapView) return _volumePercentage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_volumePercentage);
}

/// Periodo temporale di riferimento
@override final  TimePeriod period;
/// Data inizio periodo
@override final  DateTime startDate;
/// Data fine periodo (tipicamente oggi)
@override final  DateTime endDate;

/// Create a copy of MuscleDistributionData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleDistributionDataCopyWith<_MuscleDistributionData> get copyWith => __$MuscleDistributionDataCopyWithImpl<_MuscleDistributionData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleDistributionDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleDistributionData&&const DeepCollectionEquality().equals(other._volumeByMuscle, _volumeByMuscle)&&const DeepCollectionEquality().equals(other._setsByMuscle, _setsByMuscle)&&const DeepCollectionEquality().equals(other._volumePercentage, _volumePercentage)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_volumeByMuscle),const DeepCollectionEquality().hash(_setsByMuscle),const DeepCollectionEquality().hash(_volumePercentage),period,startDate,endDate);

@override
String toString() {
  return 'MuscleDistributionData(volumeByMuscle: $volumeByMuscle, setsByMuscle: $setsByMuscle, volumePercentage: $volumePercentage, period: $period, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$MuscleDistributionDataCopyWith<$Res> implements $MuscleDistributionDataCopyWith<$Res> {
  factory _$MuscleDistributionDataCopyWith(_MuscleDistributionData value, $Res Function(_MuscleDistributionData) _then) = __$MuscleDistributionDataCopyWithImpl;
@override @useResult
$Res call({
 Map<MuscleGroup, double> volumeByMuscle, Map<MuscleGroup, int> setsByMuscle, Map<MuscleGroup, double> volumePercentage, TimePeriod period, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class __$MuscleDistributionDataCopyWithImpl<$Res>
    implements _$MuscleDistributionDataCopyWith<$Res> {
  __$MuscleDistributionDataCopyWithImpl(this._self, this._then);

  final _MuscleDistributionData _self;
  final $Res Function(_MuscleDistributionData) _then;

/// Create a copy of MuscleDistributionData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? volumeByMuscle = null,Object? setsByMuscle = null,Object? volumePercentage = null,Object? period = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_MuscleDistributionData(
volumeByMuscle: null == volumeByMuscle ? _self._volumeByMuscle : volumeByMuscle // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, double>,setsByMuscle: null == setsByMuscle ? _self._setsByMuscle : setsByMuscle // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, int>,volumePercentage: null == volumePercentage ? _self._volumePercentage : volumePercentage // ignore: cast_nullable_to_non_nullable
as Map<MuscleGroup, double>,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as TimePeriod,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PeriodStatistics {

/// Numero di allenamenti completati
 int get workoutsCount;/// Durata totale in minuti
 int get totalDurationMinutes;/// Volume totale sollevato (kg)
 double get totalVolumeKg;/// Numero totale di serie completate
 int get totalSets;/// Periodo di riferimento
 TimePeriod get period;/// Data inizio periodo
 DateTime get startDate;/// Data fine periodo
 DateTime get endDate;
/// Create a copy of PeriodStatistics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodStatisticsCopyWith<PeriodStatistics> get copyWith => _$PeriodStatisticsCopyWithImpl<PeriodStatistics>(this as PeriodStatistics, _$identity);

  /// Serializes this PeriodStatistics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodStatistics&&(identical(other.workoutsCount, workoutsCount) || other.workoutsCount == workoutsCount)&&(identical(other.totalDurationMinutes, totalDurationMinutes) || other.totalDurationMinutes == totalDurationMinutes)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutsCount,totalDurationMinutes,totalVolumeKg,totalSets,period,startDate,endDate);

@override
String toString() {
  return 'PeriodStatistics(workoutsCount: $workoutsCount, totalDurationMinutes: $totalDurationMinutes, totalVolumeKg: $totalVolumeKg, totalSets: $totalSets, period: $period, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $PeriodStatisticsCopyWith<$Res>  {
  factory $PeriodStatisticsCopyWith(PeriodStatistics value, $Res Function(PeriodStatistics) _then) = _$PeriodStatisticsCopyWithImpl;
@useResult
$Res call({
 int workoutsCount, int totalDurationMinutes, double totalVolumeKg, int totalSets, TimePeriod period, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class _$PeriodStatisticsCopyWithImpl<$Res>
    implements $PeriodStatisticsCopyWith<$Res> {
  _$PeriodStatisticsCopyWithImpl(this._self, this._then);

  final PeriodStatistics _self;
  final $Res Function(PeriodStatistics) _then;

/// Create a copy of PeriodStatistics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutsCount = null,Object? totalDurationMinutes = null,Object? totalVolumeKg = null,Object? totalSets = null,Object? period = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_self.copyWith(
workoutsCount: null == workoutsCount ? _self.workoutsCount : workoutsCount // ignore: cast_nullable_to_non_nullable
as int,totalDurationMinutes: null == totalDurationMinutes ? _self.totalDurationMinutes : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as TimePeriod,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodStatistics].
extension PeriodStatisticsPatterns on PeriodStatistics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodStatistics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodStatistics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodStatistics value)  $default,){
final _that = this;
switch (_that) {
case _PeriodStatistics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodStatistics value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodStatistics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workoutsCount,  int totalDurationMinutes,  double totalVolumeKg,  int totalSets,  TimePeriod period,  DateTime startDate,  DateTime endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodStatistics() when $default != null:
return $default(_that.workoutsCount,_that.totalDurationMinutes,_that.totalVolumeKg,_that.totalSets,_that.period,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workoutsCount,  int totalDurationMinutes,  double totalVolumeKg,  int totalSets,  TimePeriod period,  DateTime startDate,  DateTime endDate)  $default,) {final _that = this;
switch (_that) {
case _PeriodStatistics():
return $default(_that.workoutsCount,_that.totalDurationMinutes,_that.totalVolumeKg,_that.totalSets,_that.period,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workoutsCount,  int totalDurationMinutes,  double totalVolumeKg,  int totalSets,  TimePeriod period,  DateTime startDate,  DateTime endDate)?  $default,) {final _that = this;
switch (_that) {
case _PeriodStatistics() when $default != null:
return $default(_that.workoutsCount,_that.totalDurationMinutes,_that.totalVolumeKg,_that.totalSets,_that.period,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeriodStatistics implements PeriodStatistics {
  const _PeriodStatistics({required this.workoutsCount, required this.totalDurationMinutes, required this.totalVolumeKg, required this.totalSets, required this.period, required this.startDate, required this.endDate});
  factory _PeriodStatistics.fromJson(Map<String, dynamic> json) => _$PeriodStatisticsFromJson(json);

/// Numero di allenamenti completati
@override final  int workoutsCount;
/// Durata totale in minuti
@override final  int totalDurationMinutes;
/// Volume totale sollevato (kg)
@override final  double totalVolumeKg;
/// Numero totale di serie completate
@override final  int totalSets;
/// Periodo di riferimento
@override final  TimePeriod period;
/// Data inizio periodo
@override final  DateTime startDate;
/// Data fine periodo
@override final  DateTime endDate;

/// Create a copy of PeriodStatistics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodStatisticsCopyWith<_PeriodStatistics> get copyWith => __$PeriodStatisticsCopyWithImpl<_PeriodStatistics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodStatisticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodStatistics&&(identical(other.workoutsCount, workoutsCount) || other.workoutsCount == workoutsCount)&&(identical(other.totalDurationMinutes, totalDurationMinutes) || other.totalDurationMinutes == totalDurationMinutes)&&(identical(other.totalVolumeKg, totalVolumeKg) || other.totalVolumeKg == totalVolumeKg)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutsCount,totalDurationMinutes,totalVolumeKg,totalSets,period,startDate,endDate);

@override
String toString() {
  return 'PeriodStatistics(workoutsCount: $workoutsCount, totalDurationMinutes: $totalDurationMinutes, totalVolumeKg: $totalVolumeKg, totalSets: $totalSets, period: $period, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$PeriodStatisticsCopyWith<$Res> implements $PeriodStatisticsCopyWith<$Res> {
  factory _$PeriodStatisticsCopyWith(_PeriodStatistics value, $Res Function(_PeriodStatistics) _then) = __$PeriodStatisticsCopyWithImpl;
@override @useResult
$Res call({
 int workoutsCount, int totalDurationMinutes, double totalVolumeKg, int totalSets, TimePeriod period, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class __$PeriodStatisticsCopyWithImpl<$Res>
    implements _$PeriodStatisticsCopyWith<$Res> {
  __$PeriodStatisticsCopyWithImpl(this._self, this._then);

  final _PeriodStatistics _self;
  final $Res Function(_PeriodStatistics) _then;

/// Create a copy of PeriodStatistics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutsCount = null,Object? totalDurationMinutes = null,Object? totalVolumeKg = null,Object? totalSets = null,Object? period = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_PeriodStatistics(
workoutsCount: null == workoutsCount ? _self.workoutsCount : workoutsCount // ignore: cast_nullable_to_non_nullable
as int,totalDurationMinutes: null == totalDurationMinutes ? _self.totalDurationMinutes : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,totalVolumeKg: null == totalVolumeKg ? _self.totalVolumeKg : totalVolumeKg // ignore: cast_nullable_to_non_nullable
as double,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as TimePeriod,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MuscleAnalyticsData {

/// Distribuzione muscolare periodo attuale
 MuscleDistributionData get current;/// Distribuzione muscolare periodo precedente (per confronto radar chart)
 MuscleDistributionData get previous;/// Statistiche aggregate periodo attuale
 PeriodStatistics get currentStats;/// Statistiche aggregate periodo precedente
 PeriodStatistics get previousStats;
/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleAnalyticsDataCopyWith<MuscleAnalyticsData> get copyWith => _$MuscleAnalyticsDataCopyWithImpl<MuscleAnalyticsData>(this as MuscleAnalyticsData, _$identity);

  /// Serializes this MuscleAnalyticsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleAnalyticsData&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.currentStats, currentStats) || other.currentStats == currentStats)&&(identical(other.previousStats, previousStats) || other.previousStats == previousStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,previous,currentStats,previousStats);

@override
String toString() {
  return 'MuscleAnalyticsData(current: $current, previous: $previous, currentStats: $currentStats, previousStats: $previousStats)';
}


}

/// @nodoc
abstract mixin class $MuscleAnalyticsDataCopyWith<$Res>  {
  factory $MuscleAnalyticsDataCopyWith(MuscleAnalyticsData value, $Res Function(MuscleAnalyticsData) _then) = _$MuscleAnalyticsDataCopyWithImpl;
@useResult
$Res call({
 MuscleDistributionData current, MuscleDistributionData previous, PeriodStatistics currentStats, PeriodStatistics previousStats
});


$MuscleDistributionDataCopyWith<$Res> get current;$MuscleDistributionDataCopyWith<$Res> get previous;$PeriodStatisticsCopyWith<$Res> get currentStats;$PeriodStatisticsCopyWith<$Res> get previousStats;

}
/// @nodoc
class _$MuscleAnalyticsDataCopyWithImpl<$Res>
    implements $MuscleAnalyticsDataCopyWith<$Res> {
  _$MuscleAnalyticsDataCopyWithImpl(this._self, this._then);

  final MuscleAnalyticsData _self;
  final $Res Function(MuscleAnalyticsData) _then;

/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? previous = null,Object? currentStats = null,Object? previousStats = null,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as MuscleDistributionData,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as MuscleDistributionData,currentStats: null == currentStats ? _self.currentStats : currentStats // ignore: cast_nullable_to_non_nullable
as PeriodStatistics,previousStats: null == previousStats ? _self.previousStats : previousStats // ignore: cast_nullable_to_non_nullable
as PeriodStatistics,
  ));
}
/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MuscleDistributionDataCopyWith<$Res> get current {
  
  return $MuscleDistributionDataCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MuscleDistributionDataCopyWith<$Res> get previous {
  
  return $MuscleDistributionDataCopyWith<$Res>(_self.previous, (value) {
    return _then(_self.copyWith(previous: value));
  });
}/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatisticsCopyWith<$Res> get currentStats {
  
  return $PeriodStatisticsCopyWith<$Res>(_self.currentStats, (value) {
    return _then(_self.copyWith(currentStats: value));
  });
}/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatisticsCopyWith<$Res> get previousStats {
  
  return $PeriodStatisticsCopyWith<$Res>(_self.previousStats, (value) {
    return _then(_self.copyWith(previousStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [MuscleAnalyticsData].
extension MuscleAnalyticsDataPatterns on MuscleAnalyticsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleAnalyticsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleAnalyticsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleAnalyticsData value)  $default,){
final _that = this;
switch (_that) {
case _MuscleAnalyticsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleAnalyticsData value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleAnalyticsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MuscleDistributionData current,  MuscleDistributionData previous,  PeriodStatistics currentStats,  PeriodStatistics previousStats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleAnalyticsData() when $default != null:
return $default(_that.current,_that.previous,_that.currentStats,_that.previousStats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MuscleDistributionData current,  MuscleDistributionData previous,  PeriodStatistics currentStats,  PeriodStatistics previousStats)  $default,) {final _that = this;
switch (_that) {
case _MuscleAnalyticsData():
return $default(_that.current,_that.previous,_that.currentStats,_that.previousStats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MuscleDistributionData current,  MuscleDistributionData previous,  PeriodStatistics currentStats,  PeriodStatistics previousStats)?  $default,) {final _that = this;
switch (_that) {
case _MuscleAnalyticsData() when $default != null:
return $default(_that.current,_that.previous,_that.currentStats,_that.previousStats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleAnalyticsData implements MuscleAnalyticsData {
  const _MuscleAnalyticsData({required this.current, required this.previous, required this.currentStats, required this.previousStats});
  factory _MuscleAnalyticsData.fromJson(Map<String, dynamic> json) => _$MuscleAnalyticsDataFromJson(json);

/// Distribuzione muscolare periodo attuale
@override final  MuscleDistributionData current;
/// Distribuzione muscolare periodo precedente (per confronto radar chart)
@override final  MuscleDistributionData previous;
/// Statistiche aggregate periodo attuale
@override final  PeriodStatistics currentStats;
/// Statistiche aggregate periodo precedente
@override final  PeriodStatistics previousStats;

/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleAnalyticsDataCopyWith<_MuscleAnalyticsData> get copyWith => __$MuscleAnalyticsDataCopyWithImpl<_MuscleAnalyticsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleAnalyticsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleAnalyticsData&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous)&&(identical(other.currentStats, currentStats) || other.currentStats == currentStats)&&(identical(other.previousStats, previousStats) || other.previousStats == previousStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,previous,currentStats,previousStats);

@override
String toString() {
  return 'MuscleAnalyticsData(current: $current, previous: $previous, currentStats: $currentStats, previousStats: $previousStats)';
}


}

/// @nodoc
abstract mixin class _$MuscleAnalyticsDataCopyWith<$Res> implements $MuscleAnalyticsDataCopyWith<$Res> {
  factory _$MuscleAnalyticsDataCopyWith(_MuscleAnalyticsData value, $Res Function(_MuscleAnalyticsData) _then) = __$MuscleAnalyticsDataCopyWithImpl;
@override @useResult
$Res call({
 MuscleDistributionData current, MuscleDistributionData previous, PeriodStatistics currentStats, PeriodStatistics previousStats
});


@override $MuscleDistributionDataCopyWith<$Res> get current;@override $MuscleDistributionDataCopyWith<$Res> get previous;@override $PeriodStatisticsCopyWith<$Res> get currentStats;@override $PeriodStatisticsCopyWith<$Res> get previousStats;

}
/// @nodoc
class __$MuscleAnalyticsDataCopyWithImpl<$Res>
    implements _$MuscleAnalyticsDataCopyWith<$Res> {
  __$MuscleAnalyticsDataCopyWithImpl(this._self, this._then);

  final _MuscleAnalyticsData _self;
  final $Res Function(_MuscleAnalyticsData) _then;

/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? previous = null,Object? currentStats = null,Object? previousStats = null,}) {
  return _then(_MuscleAnalyticsData(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as MuscleDistributionData,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as MuscleDistributionData,currentStats: null == currentStats ? _self.currentStats : currentStats // ignore: cast_nullable_to_non_nullable
as PeriodStatistics,previousStats: null == previousStats ? _self.previousStats : previousStats // ignore: cast_nullable_to_non_nullable
as PeriodStatistics,
  ));
}

/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MuscleDistributionDataCopyWith<$Res> get current {
  
  return $MuscleDistributionDataCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MuscleDistributionDataCopyWith<$Res> get previous {
  
  return $MuscleDistributionDataCopyWith<$Res>(_self.previous, (value) {
    return _then(_self.copyWith(previous: value));
  });
}/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatisticsCopyWith<$Res> get currentStats {
  
  return $PeriodStatisticsCopyWith<$Res>(_self.currentStats, (value) {
    return _then(_self.copyWith(currentStats: value));
  });
}/// Create a copy of MuscleAnalyticsData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatisticsCopyWith<$Res> get previousStats {
  
  return $PeriodStatisticsCopyWith<$Res>(_self.previousStats, (value) {
    return _then(_self.copyWith(previousStats: value));
  });
}
}

// dart format on
