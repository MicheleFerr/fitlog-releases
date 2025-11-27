// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeeklyStats {

/// Average workouts completed per week
 double get avgWorkoutsPerWeek;/// Average rest days per week
 double get avgRestDaysPerWeek;/// Total workouts in period
 int get totalWorkouts;/// Total rest days in period
 int get totalRestDays;/// Total active days (days with at least one workout)
 int get totalActiveDays;/// Week start date
 DateTime? get weekStartDate;/// Week end date
 DateTime? get weekEndDate;
/// Create a copy of WeeklyStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyStatsCopyWith<WeeklyStats> get copyWith => _$WeeklyStatsCopyWithImpl<WeeklyStats>(this as WeeklyStats, _$identity);

  /// Serializes this WeeklyStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyStats&&(identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) || other.avgWorkoutsPerWeek == avgWorkoutsPerWeek)&&(identical(other.avgRestDaysPerWeek, avgRestDaysPerWeek) || other.avgRestDaysPerWeek == avgRestDaysPerWeek)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.totalRestDays, totalRestDays) || other.totalRestDays == totalRestDays)&&(identical(other.totalActiveDays, totalActiveDays) || other.totalActiveDays == totalActiveDays)&&(identical(other.weekStartDate, weekStartDate) || other.weekStartDate == weekStartDate)&&(identical(other.weekEndDate, weekEndDate) || other.weekEndDate == weekEndDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,avgWorkoutsPerWeek,avgRestDaysPerWeek,totalWorkouts,totalRestDays,totalActiveDays,weekStartDate,weekEndDate);

@override
String toString() {
  return 'WeeklyStats(avgWorkoutsPerWeek: $avgWorkoutsPerWeek, avgRestDaysPerWeek: $avgRestDaysPerWeek, totalWorkouts: $totalWorkouts, totalRestDays: $totalRestDays, totalActiveDays: $totalActiveDays, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate)';
}


}

/// @nodoc
abstract mixin class $WeeklyStatsCopyWith<$Res>  {
  factory $WeeklyStatsCopyWith(WeeklyStats value, $Res Function(WeeklyStats) _then) = _$WeeklyStatsCopyWithImpl;
@useResult
$Res call({
 double avgWorkoutsPerWeek, double avgRestDaysPerWeek, int totalWorkouts, int totalRestDays, int totalActiveDays, DateTime? weekStartDate, DateTime? weekEndDate
});




}
/// @nodoc
class _$WeeklyStatsCopyWithImpl<$Res>
    implements $WeeklyStatsCopyWith<$Res> {
  _$WeeklyStatsCopyWithImpl(this._self, this._then);

  final WeeklyStats _self;
  final $Res Function(WeeklyStats) _then;

/// Create a copy of WeeklyStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? avgWorkoutsPerWeek = null,Object? avgRestDaysPerWeek = null,Object? totalWorkouts = null,Object? totalRestDays = null,Object? totalActiveDays = null,Object? weekStartDate = freezed,Object? weekEndDate = freezed,}) {
  return _then(_self.copyWith(
avgWorkoutsPerWeek: null == avgWorkoutsPerWeek ? _self.avgWorkoutsPerWeek : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
as double,avgRestDaysPerWeek: null == avgRestDaysPerWeek ? _self.avgRestDaysPerWeek : avgRestDaysPerWeek // ignore: cast_nullable_to_non_nullable
as double,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,totalRestDays: null == totalRestDays ? _self.totalRestDays : totalRestDays // ignore: cast_nullable_to_non_nullable
as int,totalActiveDays: null == totalActiveDays ? _self.totalActiveDays : totalActiveDays // ignore: cast_nullable_to_non_nullable
as int,weekStartDate: freezed == weekStartDate ? _self.weekStartDate : weekStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weekEndDate: freezed == weekEndDate ? _self.weekEndDate : weekEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeeklyStats].
extension WeeklyStatsPatterns on WeeklyStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeeklyStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeeklyStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeeklyStats value)  $default,){
final _that = this;
switch (_that) {
case _WeeklyStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeeklyStats value)?  $default,){
final _that = this;
switch (_that) {
case _WeeklyStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double avgWorkoutsPerWeek,  double avgRestDaysPerWeek,  int totalWorkouts,  int totalRestDays,  int totalActiveDays,  DateTime? weekStartDate,  DateTime? weekEndDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeeklyStats() when $default != null:
return $default(_that.avgWorkoutsPerWeek,_that.avgRestDaysPerWeek,_that.totalWorkouts,_that.totalRestDays,_that.totalActiveDays,_that.weekStartDate,_that.weekEndDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double avgWorkoutsPerWeek,  double avgRestDaysPerWeek,  int totalWorkouts,  int totalRestDays,  int totalActiveDays,  DateTime? weekStartDate,  DateTime? weekEndDate)  $default,) {final _that = this;
switch (_that) {
case _WeeklyStats():
return $default(_that.avgWorkoutsPerWeek,_that.avgRestDaysPerWeek,_that.totalWorkouts,_that.totalRestDays,_that.totalActiveDays,_that.weekStartDate,_that.weekEndDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double avgWorkoutsPerWeek,  double avgRestDaysPerWeek,  int totalWorkouts,  int totalRestDays,  int totalActiveDays,  DateTime? weekStartDate,  DateTime? weekEndDate)?  $default,) {final _that = this;
switch (_that) {
case _WeeklyStats() when $default != null:
return $default(_that.avgWorkoutsPerWeek,_that.avgRestDaysPerWeek,_that.totalWorkouts,_that.totalRestDays,_that.totalActiveDays,_that.weekStartDate,_that.weekEndDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeeklyStats implements WeeklyStats {
  const _WeeklyStats({this.avgWorkoutsPerWeek = 0.0, this.avgRestDaysPerWeek = 0.0, this.totalWorkouts = 0, this.totalRestDays = 0, this.totalActiveDays = 0, this.weekStartDate, this.weekEndDate});
  factory _WeeklyStats.fromJson(Map<String, dynamic> json) => _$WeeklyStatsFromJson(json);

/// Average workouts completed per week
@override@JsonKey() final  double avgWorkoutsPerWeek;
/// Average rest days per week
@override@JsonKey() final  double avgRestDaysPerWeek;
/// Total workouts in period
@override@JsonKey() final  int totalWorkouts;
/// Total rest days in period
@override@JsonKey() final  int totalRestDays;
/// Total active days (days with at least one workout)
@override@JsonKey() final  int totalActiveDays;
/// Week start date
@override final  DateTime? weekStartDate;
/// Week end date
@override final  DateTime? weekEndDate;

/// Create a copy of WeeklyStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeeklyStatsCopyWith<_WeeklyStats> get copyWith => __$WeeklyStatsCopyWithImpl<_WeeklyStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeeklyStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeeklyStats&&(identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) || other.avgWorkoutsPerWeek == avgWorkoutsPerWeek)&&(identical(other.avgRestDaysPerWeek, avgRestDaysPerWeek) || other.avgRestDaysPerWeek == avgRestDaysPerWeek)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts)&&(identical(other.totalRestDays, totalRestDays) || other.totalRestDays == totalRestDays)&&(identical(other.totalActiveDays, totalActiveDays) || other.totalActiveDays == totalActiveDays)&&(identical(other.weekStartDate, weekStartDate) || other.weekStartDate == weekStartDate)&&(identical(other.weekEndDate, weekEndDate) || other.weekEndDate == weekEndDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,avgWorkoutsPerWeek,avgRestDaysPerWeek,totalWorkouts,totalRestDays,totalActiveDays,weekStartDate,weekEndDate);

@override
String toString() {
  return 'WeeklyStats(avgWorkoutsPerWeek: $avgWorkoutsPerWeek, avgRestDaysPerWeek: $avgRestDaysPerWeek, totalWorkouts: $totalWorkouts, totalRestDays: $totalRestDays, totalActiveDays: $totalActiveDays, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate)';
}


}

/// @nodoc
abstract mixin class _$WeeklyStatsCopyWith<$Res> implements $WeeklyStatsCopyWith<$Res> {
  factory _$WeeklyStatsCopyWith(_WeeklyStats value, $Res Function(_WeeklyStats) _then) = __$WeeklyStatsCopyWithImpl;
@override @useResult
$Res call({
 double avgWorkoutsPerWeek, double avgRestDaysPerWeek, int totalWorkouts, int totalRestDays, int totalActiveDays, DateTime? weekStartDate, DateTime? weekEndDate
});




}
/// @nodoc
class __$WeeklyStatsCopyWithImpl<$Res>
    implements _$WeeklyStatsCopyWith<$Res> {
  __$WeeklyStatsCopyWithImpl(this._self, this._then);

  final _WeeklyStats _self;
  final $Res Function(_WeeklyStats) _then;

/// Create a copy of WeeklyStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? avgWorkoutsPerWeek = null,Object? avgRestDaysPerWeek = null,Object? totalWorkouts = null,Object? totalRestDays = null,Object? totalActiveDays = null,Object? weekStartDate = freezed,Object? weekEndDate = freezed,}) {
  return _then(_WeeklyStats(
avgWorkoutsPerWeek: null == avgWorkoutsPerWeek ? _self.avgWorkoutsPerWeek : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
as double,avgRestDaysPerWeek: null == avgRestDaysPerWeek ? _self.avgRestDaysPerWeek : avgRestDaysPerWeek // ignore: cast_nullable_to_non_nullable
as double,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,totalRestDays: null == totalRestDays ? _self.totalRestDays : totalRestDays // ignore: cast_nullable_to_non_nullable
as int,totalActiveDays: null == totalActiveDays ? _self.totalActiveDays : totalActiveDays // ignore: cast_nullable_to_non_nullable
as int,weekStartDate: freezed == weekStartDate ? _self.weekStartDate : weekStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weekEndDate: freezed == weekEndDate ? _self.weekEndDate : weekEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
