// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_metric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthMetric {

/// Metric type (steps, heart rate, etc.)
 HealthMetricType get type;/// Numeric value (e.g., 8500 steps, 72 BPM)
 double get value;/// Unit of measurement (count, bpm, kcal, minutes)
 String get unit;/// Start timestamp for metric collection
 DateTime get dateFrom;/// End timestamp for metric collection
 DateTime get dateTo;/// Source device (optional)
 String? get sourceDevice;/// Source app (optional)
 String? get sourceApp;/// Workout type (for HealthMetricType.workout only)
 String? get workoutType;/// Workout duration (seconds, for HealthMetricType.workout only)
 int? get workoutDuration;/// Workout distance (meters, for HealthMetricType.workout only)
 double? get workoutDistance;
/// Create a copy of HealthMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthMetricCopyWith<HealthMetric> get copyWith => _$HealthMetricCopyWithImpl<HealthMetric>(this as HealthMetric, _$identity);

  /// Serializes this HealthMetric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthMetric&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.sourceDevice, sourceDevice) || other.sourceDevice == sourceDevice)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.workoutType, workoutType) || other.workoutType == workoutType)&&(identical(other.workoutDuration, workoutDuration) || other.workoutDuration == workoutDuration)&&(identical(other.workoutDistance, workoutDistance) || other.workoutDistance == workoutDistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,unit,dateFrom,dateTo,sourceDevice,sourceApp,workoutType,workoutDuration,workoutDistance);

@override
String toString() {
  return 'HealthMetric(type: $type, value: $value, unit: $unit, dateFrom: $dateFrom, dateTo: $dateTo, sourceDevice: $sourceDevice, sourceApp: $sourceApp, workoutType: $workoutType, workoutDuration: $workoutDuration, workoutDistance: $workoutDistance)';
}


}

/// @nodoc
abstract mixin class $HealthMetricCopyWith<$Res>  {
  factory $HealthMetricCopyWith(HealthMetric value, $Res Function(HealthMetric) _then) = _$HealthMetricCopyWithImpl;
@useResult
$Res call({
 HealthMetricType type, double value, String unit, DateTime dateFrom, DateTime dateTo, String? sourceDevice, String? sourceApp, String? workoutType, int? workoutDuration, double? workoutDistance
});




}
/// @nodoc
class _$HealthMetricCopyWithImpl<$Res>
    implements $HealthMetricCopyWith<$Res> {
  _$HealthMetricCopyWithImpl(this._self, this._then);

  final HealthMetric _self;
  final $Res Function(HealthMetric) _then;

/// Create a copy of HealthMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? value = null,Object? unit = null,Object? dateFrom = null,Object? dateTo = null,Object? sourceDevice = freezed,Object? sourceApp = freezed,Object? workoutType = freezed,Object? workoutDuration = freezed,Object? workoutDistance = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HealthMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,dateFrom: null == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime,dateTo: null == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime,sourceDevice: freezed == sourceDevice ? _self.sourceDevice : sourceDevice // ignore: cast_nullable_to_non_nullable
as String?,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,workoutType: freezed == workoutType ? _self.workoutType : workoutType // ignore: cast_nullable_to_non_nullable
as String?,workoutDuration: freezed == workoutDuration ? _self.workoutDuration : workoutDuration // ignore: cast_nullable_to_non_nullable
as int?,workoutDistance: freezed == workoutDistance ? _self.workoutDistance : workoutDistance // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthMetric].
extension HealthMetricPatterns on HealthMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthMetric value)  $default,){
final _that = this;
switch (_that) {
case _HealthMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthMetric value)?  $default,){
final _that = this;
switch (_that) {
case _HealthMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthMetricType type,  double value,  String unit,  DateTime dateFrom,  DateTime dateTo,  String? sourceDevice,  String? sourceApp,  String? workoutType,  int? workoutDuration,  double? workoutDistance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthMetric() when $default != null:
return $default(_that.type,_that.value,_that.unit,_that.dateFrom,_that.dateTo,_that.sourceDevice,_that.sourceApp,_that.workoutType,_that.workoutDuration,_that.workoutDistance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthMetricType type,  double value,  String unit,  DateTime dateFrom,  DateTime dateTo,  String? sourceDevice,  String? sourceApp,  String? workoutType,  int? workoutDuration,  double? workoutDistance)  $default,) {final _that = this;
switch (_that) {
case _HealthMetric():
return $default(_that.type,_that.value,_that.unit,_that.dateFrom,_that.dateTo,_that.sourceDevice,_that.sourceApp,_that.workoutType,_that.workoutDuration,_that.workoutDistance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthMetricType type,  double value,  String unit,  DateTime dateFrom,  DateTime dateTo,  String? sourceDevice,  String? sourceApp,  String? workoutType,  int? workoutDuration,  double? workoutDistance)?  $default,) {final _that = this;
switch (_that) {
case _HealthMetric() when $default != null:
return $default(_that.type,_that.value,_that.unit,_that.dateFrom,_that.dateTo,_that.sourceDevice,_that.sourceApp,_that.workoutType,_that.workoutDuration,_that.workoutDistance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthMetric implements HealthMetric {
  const _HealthMetric({required this.type, required this.value, required this.unit, required this.dateFrom, required this.dateTo, this.sourceDevice, this.sourceApp, this.workoutType, this.workoutDuration, this.workoutDistance});
  factory _HealthMetric.fromJson(Map<String, dynamic> json) => _$HealthMetricFromJson(json);

/// Metric type (steps, heart rate, etc.)
@override final  HealthMetricType type;
/// Numeric value (e.g., 8500 steps, 72 BPM)
@override final  double value;
/// Unit of measurement (count, bpm, kcal, minutes)
@override final  String unit;
/// Start timestamp for metric collection
@override final  DateTime dateFrom;
/// End timestamp for metric collection
@override final  DateTime dateTo;
/// Source device (optional)
@override final  String? sourceDevice;
/// Source app (optional)
@override final  String? sourceApp;
/// Workout type (for HealthMetricType.workout only)
@override final  String? workoutType;
/// Workout duration (seconds, for HealthMetricType.workout only)
@override final  int? workoutDuration;
/// Workout distance (meters, for HealthMetricType.workout only)
@override final  double? workoutDistance;

/// Create a copy of HealthMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthMetricCopyWith<_HealthMetric> get copyWith => __$HealthMetricCopyWithImpl<_HealthMetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthMetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthMetric&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.sourceDevice, sourceDevice) || other.sourceDevice == sourceDevice)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.workoutType, workoutType) || other.workoutType == workoutType)&&(identical(other.workoutDuration, workoutDuration) || other.workoutDuration == workoutDuration)&&(identical(other.workoutDistance, workoutDistance) || other.workoutDistance == workoutDistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,unit,dateFrom,dateTo,sourceDevice,sourceApp,workoutType,workoutDuration,workoutDistance);

@override
String toString() {
  return 'HealthMetric(type: $type, value: $value, unit: $unit, dateFrom: $dateFrom, dateTo: $dateTo, sourceDevice: $sourceDevice, sourceApp: $sourceApp, workoutType: $workoutType, workoutDuration: $workoutDuration, workoutDistance: $workoutDistance)';
}


}

/// @nodoc
abstract mixin class _$HealthMetricCopyWith<$Res> implements $HealthMetricCopyWith<$Res> {
  factory _$HealthMetricCopyWith(_HealthMetric value, $Res Function(_HealthMetric) _then) = __$HealthMetricCopyWithImpl;
@override @useResult
$Res call({
 HealthMetricType type, double value, String unit, DateTime dateFrom, DateTime dateTo, String? sourceDevice, String? sourceApp, String? workoutType, int? workoutDuration, double? workoutDistance
});




}
/// @nodoc
class __$HealthMetricCopyWithImpl<$Res>
    implements _$HealthMetricCopyWith<$Res> {
  __$HealthMetricCopyWithImpl(this._self, this._then);

  final _HealthMetric _self;
  final $Res Function(_HealthMetric) _then;

/// Create a copy of HealthMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = null,Object? unit = null,Object? dateFrom = null,Object? dateTo = null,Object? sourceDevice = freezed,Object? sourceApp = freezed,Object? workoutType = freezed,Object? workoutDuration = freezed,Object? workoutDistance = freezed,}) {
  return _then(_HealthMetric(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HealthMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,dateFrom: null == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime,dateTo: null == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime,sourceDevice: freezed == sourceDevice ? _self.sourceDevice : sourceDevice // ignore: cast_nullable_to_non_nullable
as String?,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,workoutType: freezed == workoutType ? _self.workoutType : workoutType // ignore: cast_nullable_to_non_nullable
as String?,workoutDuration: freezed == workoutDuration ? _self.workoutDuration : workoutDuration // ignore: cast_nullable_to_non_nullable
as int?,workoutDistance: freezed == workoutDistance ? _self.workoutDistance : workoutDistance // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$HealthMetricSummary {

/// Metric type being summarized
 HealthMetricType get metricType;/// Total/sum of all values in period
 double get totalValue;/// Average value per day
 double get averageValue;/// Minimum value in period
 double get minValue;/// Maximum value in period
 double get maxValue;/// Number of data points
 int get dataPoints;/// Period start
 DateTime get periodStart;/// Period end
 DateTime get periodEnd;/// Unit of measurement
 String get unit;
/// Create a copy of HealthMetricSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthMetricSummaryCopyWith<HealthMetricSummary> get copyWith => _$HealthMetricSummaryCopyWithImpl<HealthMetricSummary>(this as HealthMetricSummary, _$identity);

  /// Serializes this HealthMetricSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthMetricSummary&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.averageValue, averageValue) || other.averageValue == averageValue)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.dataPoints, dataPoints) || other.dataPoints == dataPoints)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricType,totalValue,averageValue,minValue,maxValue,dataPoints,periodStart,periodEnd,unit);

@override
String toString() {
  return 'HealthMetricSummary(metricType: $metricType, totalValue: $totalValue, averageValue: $averageValue, minValue: $minValue, maxValue: $maxValue, dataPoints: $dataPoints, periodStart: $periodStart, periodEnd: $periodEnd, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $HealthMetricSummaryCopyWith<$Res>  {
  factory $HealthMetricSummaryCopyWith(HealthMetricSummary value, $Res Function(HealthMetricSummary) _then) = _$HealthMetricSummaryCopyWithImpl;
@useResult
$Res call({
 HealthMetricType metricType, double totalValue, double averageValue, double minValue, double maxValue, int dataPoints, DateTime periodStart, DateTime periodEnd, String unit
});




}
/// @nodoc
class _$HealthMetricSummaryCopyWithImpl<$Res>
    implements $HealthMetricSummaryCopyWith<$Res> {
  _$HealthMetricSummaryCopyWithImpl(this._self, this._then);

  final HealthMetricSummary _self;
  final $Res Function(HealthMetricSummary) _then;

/// Create a copy of HealthMetricSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metricType = null,Object? totalValue = null,Object? averageValue = null,Object? minValue = null,Object? maxValue = null,Object? dataPoints = null,Object? periodStart = null,Object? periodEnd = null,Object? unit = null,}) {
  return _then(_self.copyWith(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as HealthMetricType,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,averageValue: null == averageValue ? _self.averageValue : averageValue // ignore: cast_nullable_to_non_nullable
as double,minValue: null == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double,maxValue: null == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double,dataPoints: null == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as int,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthMetricSummary].
extension HealthMetricSummaryPatterns on HealthMetricSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthMetricSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthMetricSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthMetricSummary value)  $default,){
final _that = this;
switch (_that) {
case _HealthMetricSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthMetricSummary value)?  $default,){
final _that = this;
switch (_that) {
case _HealthMetricSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthMetricType metricType,  double totalValue,  double averageValue,  double minValue,  double maxValue,  int dataPoints,  DateTime periodStart,  DateTime periodEnd,  String unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthMetricSummary() when $default != null:
return $default(_that.metricType,_that.totalValue,_that.averageValue,_that.minValue,_that.maxValue,_that.dataPoints,_that.periodStart,_that.periodEnd,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthMetricType metricType,  double totalValue,  double averageValue,  double minValue,  double maxValue,  int dataPoints,  DateTime periodStart,  DateTime periodEnd,  String unit)  $default,) {final _that = this;
switch (_that) {
case _HealthMetricSummary():
return $default(_that.metricType,_that.totalValue,_that.averageValue,_that.minValue,_that.maxValue,_that.dataPoints,_that.periodStart,_that.periodEnd,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthMetricType metricType,  double totalValue,  double averageValue,  double minValue,  double maxValue,  int dataPoints,  DateTime periodStart,  DateTime periodEnd,  String unit)?  $default,) {final _that = this;
switch (_that) {
case _HealthMetricSummary() when $default != null:
return $default(_that.metricType,_that.totalValue,_that.averageValue,_that.minValue,_that.maxValue,_that.dataPoints,_that.periodStart,_that.periodEnd,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthMetricSummary implements HealthMetricSummary {
  const _HealthMetricSummary({required this.metricType, required this.totalValue, required this.averageValue, required this.minValue, required this.maxValue, required this.dataPoints, required this.periodStart, required this.periodEnd, required this.unit});
  factory _HealthMetricSummary.fromJson(Map<String, dynamic> json) => _$HealthMetricSummaryFromJson(json);

/// Metric type being summarized
@override final  HealthMetricType metricType;
/// Total/sum of all values in period
@override final  double totalValue;
/// Average value per day
@override final  double averageValue;
/// Minimum value in period
@override final  double minValue;
/// Maximum value in period
@override final  double maxValue;
/// Number of data points
@override final  int dataPoints;
/// Period start
@override final  DateTime periodStart;
/// Period end
@override final  DateTime periodEnd;
/// Unit of measurement
@override final  String unit;

/// Create a copy of HealthMetricSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthMetricSummaryCopyWith<_HealthMetricSummary> get copyWith => __$HealthMetricSummaryCopyWithImpl<_HealthMetricSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthMetricSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthMetricSummary&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.averageValue, averageValue) || other.averageValue == averageValue)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.dataPoints, dataPoints) || other.dataPoints == dataPoints)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricType,totalValue,averageValue,minValue,maxValue,dataPoints,periodStart,periodEnd,unit);

@override
String toString() {
  return 'HealthMetricSummary(metricType: $metricType, totalValue: $totalValue, averageValue: $averageValue, minValue: $minValue, maxValue: $maxValue, dataPoints: $dataPoints, periodStart: $periodStart, periodEnd: $periodEnd, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$HealthMetricSummaryCopyWith<$Res> implements $HealthMetricSummaryCopyWith<$Res> {
  factory _$HealthMetricSummaryCopyWith(_HealthMetricSummary value, $Res Function(_HealthMetricSummary) _then) = __$HealthMetricSummaryCopyWithImpl;
@override @useResult
$Res call({
 HealthMetricType metricType, double totalValue, double averageValue, double minValue, double maxValue, int dataPoints, DateTime periodStart, DateTime periodEnd, String unit
});




}
/// @nodoc
class __$HealthMetricSummaryCopyWithImpl<$Res>
    implements _$HealthMetricSummaryCopyWith<$Res> {
  __$HealthMetricSummaryCopyWithImpl(this._self, this._then);

  final _HealthMetricSummary _self;
  final $Res Function(_HealthMetricSummary) _then;

/// Create a copy of HealthMetricSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metricType = null,Object? totalValue = null,Object? averageValue = null,Object? minValue = null,Object? maxValue = null,Object? dataPoints = null,Object? periodStart = null,Object? periodEnd = null,Object? unit = null,}) {
  return _then(_HealthMetricSummary(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as HealthMetricType,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,averageValue: null == averageValue ? _self.averageValue : averageValue // ignore: cast_nullable_to_non_nullable
as double,minValue: null == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double,maxValue: null == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double,dataPoints: null == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as int,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
