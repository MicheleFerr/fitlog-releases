// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SleepRecord {

/// Date of the sleep (night of)
 DateTime get date;/// Time actually asleep (excludes awake time)
 Duration get asleepDuration;/// Total time in bed (includes awake time)
 Duration get inBedDuration;/// Sleep efficiency = asleep / inBed * 100
///
/// - >85%: Good efficiency
/// - 75-85%: Normal
/// - <75%: Poor efficiency
 double get efficiency;/// Quality category based on asleep duration
 SleepQuality get quality;/// Data source (e.g., "HealthKit", "Health Connect")
 String? get source;
/// Create a copy of SleepRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepRecordCopyWith<SleepRecord> get copyWith => _$SleepRecordCopyWithImpl<SleepRecord>(this as SleepRecord, _$identity);

  /// Serializes this SleepRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepRecord&&(identical(other.date, date) || other.date == date)&&(identical(other.asleepDuration, asleepDuration) || other.asleepDuration == asleepDuration)&&(identical(other.inBedDuration, inBedDuration) || other.inBedDuration == inBedDuration)&&(identical(other.efficiency, efficiency) || other.efficiency == efficiency)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,asleepDuration,inBedDuration,efficiency,quality,source);

@override
String toString() {
  return 'SleepRecord(date: $date, asleepDuration: $asleepDuration, inBedDuration: $inBedDuration, efficiency: $efficiency, quality: $quality, source: $source)';
}


}

/// @nodoc
abstract mixin class $SleepRecordCopyWith<$Res>  {
  factory $SleepRecordCopyWith(SleepRecord value, $Res Function(SleepRecord) _then) = _$SleepRecordCopyWithImpl;
@useResult
$Res call({
 DateTime date, Duration asleepDuration, Duration inBedDuration, double efficiency, SleepQuality quality, String? source
});




}
/// @nodoc
class _$SleepRecordCopyWithImpl<$Res>
    implements $SleepRecordCopyWith<$Res> {
  _$SleepRecordCopyWithImpl(this._self, this._then);

  final SleepRecord _self;
  final $Res Function(SleepRecord) _then;

/// Create a copy of SleepRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? asleepDuration = null,Object? inBedDuration = null,Object? efficiency = null,Object? quality = null,Object? source = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,asleepDuration: null == asleepDuration ? _self.asleepDuration : asleepDuration // ignore: cast_nullable_to_non_nullable
as Duration,inBedDuration: null == inBedDuration ? _self.inBedDuration : inBedDuration // ignore: cast_nullable_to_non_nullable
as Duration,efficiency: null == efficiency ? _self.efficiency : efficiency // ignore: cast_nullable_to_non_nullable
as double,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as SleepQuality,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SleepRecord].
extension SleepRecordPatterns on SleepRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SleepRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SleepRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SleepRecord value)  $default,){
final _that = this;
switch (_that) {
case _SleepRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SleepRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SleepRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  Duration asleepDuration,  Duration inBedDuration,  double efficiency,  SleepQuality quality,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SleepRecord() when $default != null:
return $default(_that.date,_that.asleepDuration,_that.inBedDuration,_that.efficiency,_that.quality,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  Duration asleepDuration,  Duration inBedDuration,  double efficiency,  SleepQuality quality,  String? source)  $default,) {final _that = this;
switch (_that) {
case _SleepRecord():
return $default(_that.date,_that.asleepDuration,_that.inBedDuration,_that.efficiency,_that.quality,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  Duration asleepDuration,  Duration inBedDuration,  double efficiency,  SleepQuality quality,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _SleepRecord() when $default != null:
return $default(_that.date,_that.asleepDuration,_that.inBedDuration,_that.efficiency,_that.quality,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SleepRecord extends SleepRecord {
  const _SleepRecord({required this.date, required this.asleepDuration, required this.inBedDuration, required this.efficiency, required this.quality, this.source}): super._();
  factory _SleepRecord.fromJson(Map<String, dynamic> json) => _$SleepRecordFromJson(json);

/// Date of the sleep (night of)
@override final  DateTime date;
/// Time actually asleep (excludes awake time)
@override final  Duration asleepDuration;
/// Total time in bed (includes awake time)
@override final  Duration inBedDuration;
/// Sleep efficiency = asleep / inBed * 100
///
/// - >85%: Good efficiency
/// - 75-85%: Normal
/// - <75%: Poor efficiency
@override final  double efficiency;
/// Quality category based on asleep duration
@override final  SleepQuality quality;
/// Data source (e.g., "HealthKit", "Health Connect")
@override final  String? source;

/// Create a copy of SleepRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SleepRecordCopyWith<_SleepRecord> get copyWith => __$SleepRecordCopyWithImpl<_SleepRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SleepRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SleepRecord&&(identical(other.date, date) || other.date == date)&&(identical(other.asleepDuration, asleepDuration) || other.asleepDuration == asleepDuration)&&(identical(other.inBedDuration, inBedDuration) || other.inBedDuration == inBedDuration)&&(identical(other.efficiency, efficiency) || other.efficiency == efficiency)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,asleepDuration,inBedDuration,efficiency,quality,source);

@override
String toString() {
  return 'SleepRecord(date: $date, asleepDuration: $asleepDuration, inBedDuration: $inBedDuration, efficiency: $efficiency, quality: $quality, source: $source)';
}


}

/// @nodoc
abstract mixin class _$SleepRecordCopyWith<$Res> implements $SleepRecordCopyWith<$Res> {
  factory _$SleepRecordCopyWith(_SleepRecord value, $Res Function(_SleepRecord) _then) = __$SleepRecordCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, Duration asleepDuration, Duration inBedDuration, double efficiency, SleepQuality quality, String? source
});




}
/// @nodoc
class __$SleepRecordCopyWithImpl<$Res>
    implements _$SleepRecordCopyWith<$Res> {
  __$SleepRecordCopyWithImpl(this._self, this._then);

  final _SleepRecord _self;
  final $Res Function(_SleepRecord) _then;

/// Create a copy of SleepRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? asleepDuration = null,Object? inBedDuration = null,Object? efficiency = null,Object? quality = null,Object? source = freezed,}) {
  return _then(_SleepRecord(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,asleepDuration: null == asleepDuration ? _self.asleepDuration : asleepDuration // ignore: cast_nullable_to_non_nullable
as Duration,inBedDuration: null == inBedDuration ? _self.inBedDuration : inBedDuration // ignore: cast_nullable_to_non_nullable
as Duration,efficiency: null == efficiency ? _self.efficiency : efficiency // ignore: cast_nullable_to_non_nullable
as double,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as SleepQuality,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
