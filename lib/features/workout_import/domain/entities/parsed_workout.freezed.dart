// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedWorkout {

 List<ParsedDay> get days; String? get rawText; bool get hasMultipleDays;
/// Create a copy of ParsedWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedWorkoutCopyWith<ParsedWorkout> get copyWith => _$ParsedWorkoutCopyWithImpl<ParsedWorkout>(this as ParsedWorkout, _$identity);

  /// Serializes this ParsedWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedWorkout&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.hasMultipleDays, hasMultipleDays) || other.hasMultipleDays == hasMultipleDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(days),rawText,hasMultipleDays);

@override
String toString() {
  return 'ParsedWorkout(days: $days, rawText: $rawText, hasMultipleDays: $hasMultipleDays)';
}


}

/// @nodoc
abstract mixin class $ParsedWorkoutCopyWith<$Res>  {
  factory $ParsedWorkoutCopyWith(ParsedWorkout value, $Res Function(ParsedWorkout) _then) = _$ParsedWorkoutCopyWithImpl;
@useResult
$Res call({
 List<ParsedDay> days, String? rawText, bool hasMultipleDays
});




}
/// @nodoc
class _$ParsedWorkoutCopyWithImpl<$Res>
    implements $ParsedWorkoutCopyWith<$Res> {
  _$ParsedWorkoutCopyWithImpl(this._self, this._then);

  final ParsedWorkout _self;
  final $Res Function(ParsedWorkout) _then;

/// Create a copy of ParsedWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? days = null,Object? rawText = freezed,Object? hasMultipleDays = null,}) {
  return _then(_self.copyWith(
days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<ParsedDay>,rawText: freezed == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String?,hasMultipleDays: null == hasMultipleDays ? _self.hasMultipleDays : hasMultipleDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedWorkout].
extension ParsedWorkoutPatterns on ParsedWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedWorkout value)  $default,){
final _that = this;
switch (_that) {
case _ParsedWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ParsedDay> days,  String? rawText,  bool hasMultipleDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedWorkout() when $default != null:
return $default(_that.days,_that.rawText,_that.hasMultipleDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ParsedDay> days,  String? rawText,  bool hasMultipleDays)  $default,) {final _that = this;
switch (_that) {
case _ParsedWorkout():
return $default(_that.days,_that.rawText,_that.hasMultipleDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ParsedDay> days,  String? rawText,  bool hasMultipleDays)?  $default,) {final _that = this;
switch (_that) {
case _ParsedWorkout() when $default != null:
return $default(_that.days,_that.rawText,_that.hasMultipleDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedWorkout implements ParsedWorkout {
  const _ParsedWorkout({required final  List<ParsedDay> days, this.rawText, this.hasMultipleDays = false}): _days = days;
  factory _ParsedWorkout.fromJson(Map<String, dynamic> json) => _$ParsedWorkoutFromJson(json);

 final  List<ParsedDay> _days;
@override List<ParsedDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  String? rawText;
@override@JsonKey() final  bool hasMultipleDays;

/// Create a copy of ParsedWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedWorkoutCopyWith<_ParsedWorkout> get copyWith => __$ParsedWorkoutCopyWithImpl<_ParsedWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedWorkout&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.hasMultipleDays, hasMultipleDays) || other.hasMultipleDays == hasMultipleDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),rawText,hasMultipleDays);

@override
String toString() {
  return 'ParsedWorkout(days: $days, rawText: $rawText, hasMultipleDays: $hasMultipleDays)';
}


}

/// @nodoc
abstract mixin class _$ParsedWorkoutCopyWith<$Res> implements $ParsedWorkoutCopyWith<$Res> {
  factory _$ParsedWorkoutCopyWith(_ParsedWorkout value, $Res Function(_ParsedWorkout) _then) = __$ParsedWorkoutCopyWithImpl;
@override @useResult
$Res call({
 List<ParsedDay> days, String? rawText, bool hasMultipleDays
});




}
/// @nodoc
class __$ParsedWorkoutCopyWithImpl<$Res>
    implements _$ParsedWorkoutCopyWith<$Res> {
  __$ParsedWorkoutCopyWithImpl(this._self, this._then);

  final _ParsedWorkout _self;
  final $Res Function(_ParsedWorkout) _then;

/// Create a copy of ParsedWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? rawText = freezed,Object? hasMultipleDays = null,}) {
  return _then(_ParsedWorkout(
days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<ParsedDay>,rawText: freezed == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String?,hasMultipleDays: null == hasMultipleDays ? _self.hasMultipleDays : hasMultipleDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ParsedDay {

 String get name; List<ParsedExerciseLine> get exercises;
/// Create a copy of ParsedDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedDayCopyWith<ParsedDay> get copyWith => _$ParsedDayCopyWithImpl<ParsedDay>(this as ParsedDay, _$identity);

  /// Serializes this ParsedDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedDay&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'ParsedDay(name: $name, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $ParsedDayCopyWith<$Res>  {
  factory $ParsedDayCopyWith(ParsedDay value, $Res Function(ParsedDay) _then) = _$ParsedDayCopyWithImpl;
@useResult
$Res call({
 String name, List<ParsedExerciseLine> exercises
});




}
/// @nodoc
class _$ParsedDayCopyWithImpl<$Res>
    implements $ParsedDayCopyWith<$Res> {
  _$ParsedDayCopyWithImpl(this._self, this._then);

  final ParsedDay _self;
  final $Res Function(ParsedDay) _then;

/// Create a copy of ParsedDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? exercises = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ParsedExerciseLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedDay].
extension ParsedDayPatterns on ParsedDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedDay value)  $default,){
final _that = this;
switch (_that) {
case _ParsedDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedDay value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<ParsedExerciseLine> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedDay() when $default != null:
return $default(_that.name,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<ParsedExerciseLine> exercises)  $default,) {final _that = this;
switch (_that) {
case _ParsedDay():
return $default(_that.name,_that.exercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<ParsedExerciseLine> exercises)?  $default,) {final _that = this;
switch (_that) {
case _ParsedDay() when $default != null:
return $default(_that.name,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedDay implements ParsedDay {
  const _ParsedDay({required this.name, required final  List<ParsedExerciseLine> exercises}): _exercises = exercises;
  factory _ParsedDay.fromJson(Map<String, dynamic> json) => _$ParsedDayFromJson(json);

@override final  String name;
 final  List<ParsedExerciseLine> _exercises;
@override List<ParsedExerciseLine> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of ParsedDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedDayCopyWith<_ParsedDay> get copyWith => __$ParsedDayCopyWithImpl<_ParsedDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedDay&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'ParsedDay(name: $name, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$ParsedDayCopyWith<$Res> implements $ParsedDayCopyWith<$Res> {
  factory _$ParsedDayCopyWith(_ParsedDay value, $Res Function(_ParsedDay) _then) = __$ParsedDayCopyWithImpl;
@override @useResult
$Res call({
 String name, List<ParsedExerciseLine> exercises
});




}
/// @nodoc
class __$ParsedDayCopyWithImpl<$Res>
    implements _$ParsedDayCopyWith<$Res> {
  __$ParsedDayCopyWithImpl(this._self, this._then);

  final _ParsedDay _self;
  final $Res Function(_ParsedDay) _then;

/// Create a copy of ParsedDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? exercises = null,}) {
  return _then(_ParsedDay(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ParsedExerciseLine>,
  ));
}


}


/// @nodoc
mixin _$ParsedExerciseLine {

 String get rawName; List<ParsedSet> get sets; int? get restSeconds; String? get muscleGroup; String? get notes; String? get supersetGroup;// Fuzzy match results (populated after matching)
 String? get matchedExerciseId; String? get matchedExerciseName; double? get matchConfidence; ExerciseCategory? get matchedCategory;
/// Create a copy of ParsedExerciseLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedExerciseLineCopyWith<ParsedExerciseLine> get copyWith => _$ParsedExerciseLineCopyWithImpl<ParsedExerciseLine>(this as ParsedExerciseLine, _$identity);

  /// Serializes this ParsedExerciseLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedExerciseLine&&(identical(other.rawName, rawName) || other.rawName == rawName)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroup, supersetGroup) || other.supersetGroup == supersetGroup)&&(identical(other.matchedExerciseId, matchedExerciseId) || other.matchedExerciseId == matchedExerciseId)&&(identical(other.matchedExerciseName, matchedExerciseName) || other.matchedExerciseName == matchedExerciseName)&&(identical(other.matchConfidence, matchConfidence) || other.matchConfidence == matchConfidence)&&(identical(other.matchedCategory, matchedCategory) || other.matchedCategory == matchedCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawName,const DeepCollectionEquality().hash(sets),restSeconds,muscleGroup,notes,supersetGroup,matchedExerciseId,matchedExerciseName,matchConfidence,matchedCategory);

@override
String toString() {
  return 'ParsedExerciseLine(rawName: $rawName, sets: $sets, restSeconds: $restSeconds, muscleGroup: $muscleGroup, notes: $notes, supersetGroup: $supersetGroup, matchedExerciseId: $matchedExerciseId, matchedExerciseName: $matchedExerciseName, matchConfidence: $matchConfidence, matchedCategory: $matchedCategory)';
}


}

/// @nodoc
abstract mixin class $ParsedExerciseLineCopyWith<$Res>  {
  factory $ParsedExerciseLineCopyWith(ParsedExerciseLine value, $Res Function(ParsedExerciseLine) _then) = _$ParsedExerciseLineCopyWithImpl;
@useResult
$Res call({
 String rawName, List<ParsedSet> sets, int? restSeconds, String? muscleGroup, String? notes, String? supersetGroup, String? matchedExerciseId, String? matchedExerciseName, double? matchConfidence, ExerciseCategory? matchedCategory
});




}
/// @nodoc
class _$ParsedExerciseLineCopyWithImpl<$Res>
    implements $ParsedExerciseLineCopyWith<$Res> {
  _$ParsedExerciseLineCopyWithImpl(this._self, this._then);

  final ParsedExerciseLine _self;
  final $Res Function(ParsedExerciseLine) _then;

/// Create a copy of ParsedExerciseLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawName = null,Object? sets = null,Object? restSeconds = freezed,Object? muscleGroup = freezed,Object? notes = freezed,Object? supersetGroup = freezed,Object? matchedExerciseId = freezed,Object? matchedExerciseName = freezed,Object? matchConfidence = freezed,Object? matchedCategory = freezed,}) {
  return _then(_self.copyWith(
rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<ParsedSet>,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,muscleGroup: freezed == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroup: freezed == supersetGroup ? _self.supersetGroup : supersetGroup // ignore: cast_nullable_to_non_nullable
as String?,matchedExerciseId: freezed == matchedExerciseId ? _self.matchedExerciseId : matchedExerciseId // ignore: cast_nullable_to_non_nullable
as String?,matchedExerciseName: freezed == matchedExerciseName ? _self.matchedExerciseName : matchedExerciseName // ignore: cast_nullable_to_non_nullable
as String?,matchConfidence: freezed == matchConfidence ? _self.matchConfidence : matchConfidence // ignore: cast_nullable_to_non_nullable
as double?,matchedCategory: freezed == matchedCategory ? _self.matchedCategory : matchedCategory // ignore: cast_nullable_to_non_nullable
as ExerciseCategory?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedExerciseLine].
extension ParsedExerciseLinePatterns on ParsedExerciseLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedExerciseLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedExerciseLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedExerciseLine value)  $default,){
final _that = this;
switch (_that) {
case _ParsedExerciseLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedExerciseLine value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedExerciseLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawName,  List<ParsedSet> sets,  int? restSeconds,  String? muscleGroup,  String? notes,  String? supersetGroup,  String? matchedExerciseId,  String? matchedExerciseName,  double? matchConfidence,  ExerciseCategory? matchedCategory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedExerciseLine() when $default != null:
return $default(_that.rawName,_that.sets,_that.restSeconds,_that.muscleGroup,_that.notes,_that.supersetGroup,_that.matchedExerciseId,_that.matchedExerciseName,_that.matchConfidence,_that.matchedCategory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawName,  List<ParsedSet> sets,  int? restSeconds,  String? muscleGroup,  String? notes,  String? supersetGroup,  String? matchedExerciseId,  String? matchedExerciseName,  double? matchConfidence,  ExerciseCategory? matchedCategory)  $default,) {final _that = this;
switch (_that) {
case _ParsedExerciseLine():
return $default(_that.rawName,_that.sets,_that.restSeconds,_that.muscleGroup,_that.notes,_that.supersetGroup,_that.matchedExerciseId,_that.matchedExerciseName,_that.matchConfidence,_that.matchedCategory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawName,  List<ParsedSet> sets,  int? restSeconds,  String? muscleGroup,  String? notes,  String? supersetGroup,  String? matchedExerciseId,  String? matchedExerciseName,  double? matchConfidence,  ExerciseCategory? matchedCategory)?  $default,) {final _that = this;
switch (_that) {
case _ParsedExerciseLine() when $default != null:
return $default(_that.rawName,_that.sets,_that.restSeconds,_that.muscleGroup,_that.notes,_that.supersetGroup,_that.matchedExerciseId,_that.matchedExerciseName,_that.matchConfidence,_that.matchedCategory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedExerciseLine extends ParsedExerciseLine {
  const _ParsedExerciseLine({required this.rawName, required final  List<ParsedSet> sets, this.restSeconds, this.muscleGroup, this.notes, this.supersetGroup, this.matchedExerciseId, this.matchedExerciseName, this.matchConfidence, this.matchedCategory}): _sets = sets,super._();
  factory _ParsedExerciseLine.fromJson(Map<String, dynamic> json) => _$ParsedExerciseLineFromJson(json);

@override final  String rawName;
 final  List<ParsedSet> _sets;
@override List<ParsedSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override final  int? restSeconds;
@override final  String? muscleGroup;
@override final  String? notes;
@override final  String? supersetGroup;
// Fuzzy match results (populated after matching)
@override final  String? matchedExerciseId;
@override final  String? matchedExerciseName;
@override final  double? matchConfidence;
@override final  ExerciseCategory? matchedCategory;

/// Create a copy of ParsedExerciseLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedExerciseLineCopyWith<_ParsedExerciseLine> get copyWith => __$ParsedExerciseLineCopyWithImpl<_ParsedExerciseLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedExerciseLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedExerciseLine&&(identical(other.rawName, rawName) || other.rawName == rawName)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.muscleGroup, muscleGroup) || other.muscleGroup == muscleGroup)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroup, supersetGroup) || other.supersetGroup == supersetGroup)&&(identical(other.matchedExerciseId, matchedExerciseId) || other.matchedExerciseId == matchedExerciseId)&&(identical(other.matchedExerciseName, matchedExerciseName) || other.matchedExerciseName == matchedExerciseName)&&(identical(other.matchConfidence, matchConfidence) || other.matchConfidence == matchConfidence)&&(identical(other.matchedCategory, matchedCategory) || other.matchedCategory == matchedCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawName,const DeepCollectionEquality().hash(_sets),restSeconds,muscleGroup,notes,supersetGroup,matchedExerciseId,matchedExerciseName,matchConfidence,matchedCategory);

@override
String toString() {
  return 'ParsedExerciseLine(rawName: $rawName, sets: $sets, restSeconds: $restSeconds, muscleGroup: $muscleGroup, notes: $notes, supersetGroup: $supersetGroup, matchedExerciseId: $matchedExerciseId, matchedExerciseName: $matchedExerciseName, matchConfidence: $matchConfidence, matchedCategory: $matchedCategory)';
}


}

/// @nodoc
abstract mixin class _$ParsedExerciseLineCopyWith<$Res> implements $ParsedExerciseLineCopyWith<$Res> {
  factory _$ParsedExerciseLineCopyWith(_ParsedExerciseLine value, $Res Function(_ParsedExerciseLine) _then) = __$ParsedExerciseLineCopyWithImpl;
@override @useResult
$Res call({
 String rawName, List<ParsedSet> sets, int? restSeconds, String? muscleGroup, String? notes, String? supersetGroup, String? matchedExerciseId, String? matchedExerciseName, double? matchConfidence, ExerciseCategory? matchedCategory
});




}
/// @nodoc
class __$ParsedExerciseLineCopyWithImpl<$Res>
    implements _$ParsedExerciseLineCopyWith<$Res> {
  __$ParsedExerciseLineCopyWithImpl(this._self, this._then);

  final _ParsedExerciseLine _self;
  final $Res Function(_ParsedExerciseLine) _then;

/// Create a copy of ParsedExerciseLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawName = null,Object? sets = null,Object? restSeconds = freezed,Object? muscleGroup = freezed,Object? notes = freezed,Object? supersetGroup = freezed,Object? matchedExerciseId = freezed,Object? matchedExerciseName = freezed,Object? matchConfidence = freezed,Object? matchedCategory = freezed,}) {
  return _then(_ParsedExerciseLine(
rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<ParsedSet>,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,muscleGroup: freezed == muscleGroup ? _self.muscleGroup : muscleGroup // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroup: freezed == supersetGroup ? _self.supersetGroup : supersetGroup // ignore: cast_nullable_to_non_nullable
as String?,matchedExerciseId: freezed == matchedExerciseId ? _self.matchedExerciseId : matchedExerciseId // ignore: cast_nullable_to_non_nullable
as String?,matchedExerciseName: freezed == matchedExerciseName ? _self.matchedExerciseName : matchedExerciseName // ignore: cast_nullable_to_non_nullable
as String?,matchConfidence: freezed == matchConfidence ? _self.matchConfidence : matchConfidence // ignore: cast_nullable_to_non_nullable
as double?,matchedCategory: freezed == matchedCategory ? _self.matchedCategory : matchedCategory // ignore: cast_nullable_to_non_nullable
as ExerciseCategory?,
  ));
}


}


/// @nodoc
mixin _$ParsedSet {

 int? get reps; bool get isMaxReps; double? get weight; int? get durationSeconds; int? get minReps; int? get maxReps;
/// Create a copy of ParsedSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedSetCopyWith<ParsedSet> get copyWith => _$ParsedSetCopyWithImpl<ParsedSet>(this as ParsedSet, _$identity);

  /// Serializes this ParsedSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedSet&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.isMaxReps, isMaxReps) || other.isMaxReps == isMaxReps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.minReps, minReps) || other.minReps == minReps)&&(identical(other.maxReps, maxReps) || other.maxReps == maxReps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reps,isMaxReps,weight,durationSeconds,minReps,maxReps);

@override
String toString() {
  return 'ParsedSet(reps: $reps, isMaxReps: $isMaxReps, weight: $weight, durationSeconds: $durationSeconds, minReps: $minReps, maxReps: $maxReps)';
}


}

/// @nodoc
abstract mixin class $ParsedSetCopyWith<$Res>  {
  factory $ParsedSetCopyWith(ParsedSet value, $Res Function(ParsedSet) _then) = _$ParsedSetCopyWithImpl;
@useResult
$Res call({
 int? reps, bool isMaxReps, double? weight, int? durationSeconds, int? minReps, int? maxReps
});




}
/// @nodoc
class _$ParsedSetCopyWithImpl<$Res>
    implements $ParsedSetCopyWith<$Res> {
  _$ParsedSetCopyWithImpl(this._self, this._then);

  final ParsedSet _self;
  final $Res Function(ParsedSet) _then;

/// Create a copy of ParsedSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reps = freezed,Object? isMaxReps = null,Object? weight = freezed,Object? durationSeconds = freezed,Object? minReps = freezed,Object? maxReps = freezed,}) {
  return _then(_self.copyWith(
reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,isMaxReps: null == isMaxReps ? _self.isMaxReps : isMaxReps // ignore: cast_nullable_to_non_nullable
as bool,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,minReps: freezed == minReps ? _self.minReps : minReps // ignore: cast_nullable_to_non_nullable
as int?,maxReps: freezed == maxReps ? _self.maxReps : maxReps // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedSet].
extension ParsedSetPatterns on ParsedSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedSet value)  $default,){
final _that = this;
switch (_that) {
case _ParsedSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedSet value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? reps,  bool isMaxReps,  double? weight,  int? durationSeconds,  int? minReps,  int? maxReps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedSet() when $default != null:
return $default(_that.reps,_that.isMaxReps,_that.weight,_that.durationSeconds,_that.minReps,_that.maxReps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? reps,  bool isMaxReps,  double? weight,  int? durationSeconds,  int? minReps,  int? maxReps)  $default,) {final _that = this;
switch (_that) {
case _ParsedSet():
return $default(_that.reps,_that.isMaxReps,_that.weight,_that.durationSeconds,_that.minReps,_that.maxReps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? reps,  bool isMaxReps,  double? weight,  int? durationSeconds,  int? minReps,  int? maxReps)?  $default,) {final _that = this;
switch (_that) {
case _ParsedSet() when $default != null:
return $default(_that.reps,_that.isMaxReps,_that.weight,_that.durationSeconds,_that.minReps,_that.maxReps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedSet implements ParsedSet {
  const _ParsedSet({this.reps, this.isMaxReps = false, this.weight, this.durationSeconds, this.minReps, this.maxReps});
  factory _ParsedSet.fromJson(Map<String, dynamic> json) => _$ParsedSetFromJson(json);

@override final  int? reps;
@override@JsonKey() final  bool isMaxReps;
@override final  double? weight;
@override final  int? durationSeconds;
@override final  int? minReps;
@override final  int? maxReps;

/// Create a copy of ParsedSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedSetCopyWith<_ParsedSet> get copyWith => __$ParsedSetCopyWithImpl<_ParsedSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedSet&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.isMaxReps, isMaxReps) || other.isMaxReps == isMaxReps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.minReps, minReps) || other.minReps == minReps)&&(identical(other.maxReps, maxReps) || other.maxReps == maxReps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reps,isMaxReps,weight,durationSeconds,minReps,maxReps);

@override
String toString() {
  return 'ParsedSet(reps: $reps, isMaxReps: $isMaxReps, weight: $weight, durationSeconds: $durationSeconds, minReps: $minReps, maxReps: $maxReps)';
}


}

/// @nodoc
abstract mixin class _$ParsedSetCopyWith<$Res> implements $ParsedSetCopyWith<$Res> {
  factory _$ParsedSetCopyWith(_ParsedSet value, $Res Function(_ParsedSet) _then) = __$ParsedSetCopyWithImpl;
@override @useResult
$Res call({
 int? reps, bool isMaxReps, double? weight, int? durationSeconds, int? minReps, int? maxReps
});




}
/// @nodoc
class __$ParsedSetCopyWithImpl<$Res>
    implements _$ParsedSetCopyWith<$Res> {
  __$ParsedSetCopyWithImpl(this._self, this._then);

  final _ParsedSet _self;
  final $Res Function(_ParsedSet) _then;

/// Create a copy of ParsedSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reps = freezed,Object? isMaxReps = null,Object? weight = freezed,Object? durationSeconds = freezed,Object? minReps = freezed,Object? maxReps = freezed,}) {
  return _then(_ParsedSet(
reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,isMaxReps: null == isMaxReps ? _self.isMaxReps : isMaxReps // ignore: cast_nullable_to_non_nullable
as bool,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,minReps: freezed == minReps ? _self.minReps : minReps // ignore: cast_nullable_to_non_nullable
as int?,maxReps: freezed == maxReps ? _self.maxReps : maxReps // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
