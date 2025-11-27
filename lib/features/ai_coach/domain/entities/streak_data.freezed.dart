// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakData {

/// Current consecutive workout days
 int get currentStreak;/// Longest streak ever achieved (all-time best)
 int get longestStreak;/// Last workout timestamp (null if never worked out)
 DateTime? get lastWorkoutDate;/// Whether user worked out today
 bool get workedOutToday;/// Streak milestones achieved (7, 14, 30, etc.)
 List<int> get milestonesAchieved;/// Total workouts completed (all-time)
 int get totalWorkouts;
/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakDataCopyWith<StreakData> get copyWith => _$StreakDataCopyWithImpl<StreakData>(this as StreakData, _$identity);

  /// Serializes this StreakData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakData&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.workedOutToday, workedOutToday) || other.workedOutToday == workedOutToday)&&const DeepCollectionEquality().equals(other.milestonesAchieved, milestonesAchieved)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,lastWorkoutDate,workedOutToday,const DeepCollectionEquality().hash(milestonesAchieved),totalWorkouts);

@override
String toString() {
  return 'StreakData(currentStreak: $currentStreak, longestStreak: $longestStreak, lastWorkoutDate: $lastWorkoutDate, workedOutToday: $workedOutToday, milestonesAchieved: $milestonesAchieved, totalWorkouts: $totalWorkouts)';
}


}

/// @nodoc
abstract mixin class $StreakDataCopyWith<$Res>  {
  factory $StreakDataCopyWith(StreakData value, $Res Function(StreakData) _then) = _$StreakDataCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int longestStreak, DateTime? lastWorkoutDate, bool workedOutToday, List<int> milestonesAchieved, int totalWorkouts
});




}
/// @nodoc
class _$StreakDataCopyWithImpl<$Res>
    implements $StreakDataCopyWith<$Res> {
  _$StreakDataCopyWithImpl(this._self, this._then);

  final StreakData _self;
  final $Res Function(StreakData) _then;

/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? lastWorkoutDate = freezed,Object? workedOutToday = null,Object? milestonesAchieved = null,Object? totalWorkouts = null,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,workedOutToday: null == workedOutToday ? _self.workedOutToday : workedOutToday // ignore: cast_nullable_to_non_nullable
as bool,milestonesAchieved: null == milestonesAchieved ? _self.milestonesAchieved : milestonesAchieved // ignore: cast_nullable_to_non_nullable
as List<int>,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakData].
extension StreakDataPatterns on StreakData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakData value)  $default,){
final _that = this;
switch (_that) {
case _StreakData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakData value)?  $default,){
final _that = this;
switch (_that) {
case _StreakData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  DateTime? lastWorkoutDate,  bool workedOutToday,  List<int> milestonesAchieved,  int totalWorkouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakData() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.lastWorkoutDate,_that.workedOutToday,_that.milestonesAchieved,_that.totalWorkouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  DateTime? lastWorkoutDate,  bool workedOutToday,  List<int> milestonesAchieved,  int totalWorkouts)  $default,) {final _that = this;
switch (_that) {
case _StreakData():
return $default(_that.currentStreak,_that.longestStreak,_that.lastWorkoutDate,_that.workedOutToday,_that.milestonesAchieved,_that.totalWorkouts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int longestStreak,  DateTime? lastWorkoutDate,  bool workedOutToday,  List<int> milestonesAchieved,  int totalWorkouts)?  $default,) {final _that = this;
switch (_that) {
case _StreakData() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.lastWorkoutDate,_that.workedOutToday,_that.milestonesAchieved,_that.totalWorkouts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakData implements StreakData {
  const _StreakData({this.currentStreak = 0, this.longestStreak = 0, this.lastWorkoutDate, this.workedOutToday = false, final  List<int> milestonesAchieved = const [], this.totalWorkouts = 0}): _milestonesAchieved = milestonesAchieved;
  factory _StreakData.fromJson(Map<String, dynamic> json) => _$StreakDataFromJson(json);

/// Current consecutive workout days
@override@JsonKey() final  int currentStreak;
/// Longest streak ever achieved (all-time best)
@override@JsonKey() final  int longestStreak;
/// Last workout timestamp (null if never worked out)
@override final  DateTime? lastWorkoutDate;
/// Whether user worked out today
@override@JsonKey() final  bool workedOutToday;
/// Streak milestones achieved (7, 14, 30, etc.)
 final  List<int> _milestonesAchieved;
/// Streak milestones achieved (7, 14, 30, etc.)
@override@JsonKey() List<int> get milestonesAchieved {
  if (_milestonesAchieved is EqualUnmodifiableListView) return _milestonesAchieved;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_milestonesAchieved);
}

/// Total workouts completed (all-time)
@override@JsonKey() final  int totalWorkouts;

/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakDataCopyWith<_StreakData> get copyWith => __$StreakDataCopyWithImpl<_StreakData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakData&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.workedOutToday, workedOutToday) || other.workedOutToday == workedOutToday)&&const DeepCollectionEquality().equals(other._milestonesAchieved, _milestonesAchieved)&&(identical(other.totalWorkouts, totalWorkouts) || other.totalWorkouts == totalWorkouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,lastWorkoutDate,workedOutToday,const DeepCollectionEquality().hash(_milestonesAchieved),totalWorkouts);

@override
String toString() {
  return 'StreakData(currentStreak: $currentStreak, longestStreak: $longestStreak, lastWorkoutDate: $lastWorkoutDate, workedOutToday: $workedOutToday, milestonesAchieved: $milestonesAchieved, totalWorkouts: $totalWorkouts)';
}


}

/// @nodoc
abstract mixin class _$StreakDataCopyWith<$Res> implements $StreakDataCopyWith<$Res> {
  factory _$StreakDataCopyWith(_StreakData value, $Res Function(_StreakData) _then) = __$StreakDataCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int longestStreak, DateTime? lastWorkoutDate, bool workedOutToday, List<int> milestonesAchieved, int totalWorkouts
});




}
/// @nodoc
class __$StreakDataCopyWithImpl<$Res>
    implements _$StreakDataCopyWith<$Res> {
  __$StreakDataCopyWithImpl(this._self, this._then);

  final _StreakData _self;
  final $Res Function(_StreakData) _then;

/// Create a copy of StreakData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? lastWorkoutDate = freezed,Object? workedOutToday = null,Object? milestonesAchieved = null,Object? totalWorkouts = null,}) {
  return _then(_StreakData(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,workedOutToday: null == workedOutToday ? _self.workedOutToday : workedOutToday // ignore: cast_nullable_to_non_nullable
as bool,milestonesAchieved: null == milestonesAchieved ? _self._milestonesAchieved : milestonesAchieved // ignore: cast_nullable_to_non_nullable
as List<int>,totalWorkouts: null == totalWorkouts ? _self.totalWorkouts : totalWorkouts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
