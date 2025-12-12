// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportParseResult {

/// Source app (strong, hevy, generic)
 String get sourceApp;/// Parsed workouts ready for import
 List<ParsedWorkout> get workouts;/// Exercises that need manual mapping
 List<UnmappedExercise> get unmappedExercises;/// Exercises successfully auto-mapped
 Map<String, String> get autoMappedExercises;/// Parse errors/warnings
 List<String> get warnings;/// Total rows in CSV
 int get totalRows;/// Successfully parsed rows
 int get parsedRows;
/// Create a copy of ImportParseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportParseResultCopyWith<ImportParseResult> get copyWith => _$ImportParseResultCopyWithImpl<ImportParseResult>(this as ImportParseResult, _$identity);

  /// Serializes this ImportParseResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportParseResult&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&const DeepCollectionEquality().equals(other.workouts, workouts)&&const DeepCollectionEquality().equals(other.unmappedExercises, unmappedExercises)&&const DeepCollectionEquality().equals(other.autoMappedExercises, autoMappedExercises)&&const DeepCollectionEquality().equals(other.warnings, warnings)&&(identical(other.totalRows, totalRows) || other.totalRows == totalRows)&&(identical(other.parsedRows, parsedRows) || other.parsedRows == parsedRows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceApp,const DeepCollectionEquality().hash(workouts),const DeepCollectionEquality().hash(unmappedExercises),const DeepCollectionEquality().hash(autoMappedExercises),const DeepCollectionEquality().hash(warnings),totalRows,parsedRows);

@override
String toString() {
  return 'ImportParseResult(sourceApp: $sourceApp, workouts: $workouts, unmappedExercises: $unmappedExercises, autoMappedExercises: $autoMappedExercises, warnings: $warnings, totalRows: $totalRows, parsedRows: $parsedRows)';
}


}

/// @nodoc
abstract mixin class $ImportParseResultCopyWith<$Res>  {
  factory $ImportParseResultCopyWith(ImportParseResult value, $Res Function(ImportParseResult) _then) = _$ImportParseResultCopyWithImpl;
@useResult
$Res call({
 String sourceApp, List<ParsedWorkout> workouts, List<UnmappedExercise> unmappedExercises, Map<String, String> autoMappedExercises, List<String> warnings, int totalRows, int parsedRows
});




}
/// @nodoc
class _$ImportParseResultCopyWithImpl<$Res>
    implements $ImportParseResultCopyWith<$Res> {
  _$ImportParseResultCopyWithImpl(this._self, this._then);

  final ImportParseResult _self;
  final $Res Function(ImportParseResult) _then;

/// Create a copy of ImportParseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceApp = null,Object? workouts = null,Object? unmappedExercises = null,Object? autoMappedExercises = null,Object? warnings = null,Object? totalRows = null,Object? parsedRows = null,}) {
  return _then(_self.copyWith(
sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<ParsedWorkout>,unmappedExercises: null == unmappedExercises ? _self.unmappedExercises : unmappedExercises // ignore: cast_nullable_to_non_nullable
as List<UnmappedExercise>,autoMappedExercises: null == autoMappedExercises ? _self.autoMappedExercises : autoMappedExercises // ignore: cast_nullable_to_non_nullable
as Map<String, String>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,totalRows: null == totalRows ? _self.totalRows : totalRows // ignore: cast_nullable_to_non_nullable
as int,parsedRows: null == parsedRows ? _self.parsedRows : parsedRows // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportParseResult].
extension ImportParseResultPatterns on ImportParseResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportParseResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportParseResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportParseResult value)  $default,){
final _that = this;
switch (_that) {
case _ImportParseResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportParseResult value)?  $default,){
final _that = this;
switch (_that) {
case _ImportParseResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceApp,  List<ParsedWorkout> workouts,  List<UnmappedExercise> unmappedExercises,  Map<String, String> autoMappedExercises,  List<String> warnings,  int totalRows,  int parsedRows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportParseResult() when $default != null:
return $default(_that.sourceApp,_that.workouts,_that.unmappedExercises,_that.autoMappedExercises,_that.warnings,_that.totalRows,_that.parsedRows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceApp,  List<ParsedWorkout> workouts,  List<UnmappedExercise> unmappedExercises,  Map<String, String> autoMappedExercises,  List<String> warnings,  int totalRows,  int parsedRows)  $default,) {final _that = this;
switch (_that) {
case _ImportParseResult():
return $default(_that.sourceApp,_that.workouts,_that.unmappedExercises,_that.autoMappedExercises,_that.warnings,_that.totalRows,_that.parsedRows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceApp,  List<ParsedWorkout> workouts,  List<UnmappedExercise> unmappedExercises,  Map<String, String> autoMappedExercises,  List<String> warnings,  int totalRows,  int parsedRows)?  $default,) {final _that = this;
switch (_that) {
case _ImportParseResult() when $default != null:
return $default(_that.sourceApp,_that.workouts,_that.unmappedExercises,_that.autoMappedExercises,_that.warnings,_that.totalRows,_that.parsedRows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportParseResult implements ImportParseResult {
  const _ImportParseResult({required this.sourceApp, required final  List<ParsedWorkout> workouts, required final  List<UnmappedExercise> unmappedExercises, required final  Map<String, String> autoMappedExercises, final  List<String> warnings = const [], required this.totalRows, required this.parsedRows}): _workouts = workouts,_unmappedExercises = unmappedExercises,_autoMappedExercises = autoMappedExercises,_warnings = warnings;
  factory _ImportParseResult.fromJson(Map<String, dynamic> json) => _$ImportParseResultFromJson(json);

/// Source app (strong, hevy, generic)
@override final  String sourceApp;
/// Parsed workouts ready for import
 final  List<ParsedWorkout> _workouts;
/// Parsed workouts ready for import
@override List<ParsedWorkout> get workouts {
  if (_workouts is EqualUnmodifiableListView) return _workouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workouts);
}

/// Exercises that need manual mapping
 final  List<UnmappedExercise> _unmappedExercises;
/// Exercises that need manual mapping
@override List<UnmappedExercise> get unmappedExercises {
  if (_unmappedExercises is EqualUnmodifiableListView) return _unmappedExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unmappedExercises);
}

/// Exercises successfully auto-mapped
 final  Map<String, String> _autoMappedExercises;
/// Exercises successfully auto-mapped
@override Map<String, String> get autoMappedExercises {
  if (_autoMappedExercises is EqualUnmodifiableMapView) return _autoMappedExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_autoMappedExercises);
}

/// Parse errors/warnings
 final  List<String> _warnings;
/// Parse errors/warnings
@override@JsonKey() List<String> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}

/// Total rows in CSV
@override final  int totalRows;
/// Successfully parsed rows
@override final  int parsedRows;

/// Create a copy of ImportParseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportParseResultCopyWith<_ImportParseResult> get copyWith => __$ImportParseResultCopyWithImpl<_ImportParseResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportParseResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportParseResult&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&const DeepCollectionEquality().equals(other._workouts, _workouts)&&const DeepCollectionEquality().equals(other._unmappedExercises, _unmappedExercises)&&const DeepCollectionEquality().equals(other._autoMappedExercises, _autoMappedExercises)&&const DeepCollectionEquality().equals(other._warnings, _warnings)&&(identical(other.totalRows, totalRows) || other.totalRows == totalRows)&&(identical(other.parsedRows, parsedRows) || other.parsedRows == parsedRows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceApp,const DeepCollectionEquality().hash(_workouts),const DeepCollectionEquality().hash(_unmappedExercises),const DeepCollectionEquality().hash(_autoMappedExercises),const DeepCollectionEquality().hash(_warnings),totalRows,parsedRows);

@override
String toString() {
  return 'ImportParseResult(sourceApp: $sourceApp, workouts: $workouts, unmappedExercises: $unmappedExercises, autoMappedExercises: $autoMappedExercises, warnings: $warnings, totalRows: $totalRows, parsedRows: $parsedRows)';
}


}

/// @nodoc
abstract mixin class _$ImportParseResultCopyWith<$Res> implements $ImportParseResultCopyWith<$Res> {
  factory _$ImportParseResultCopyWith(_ImportParseResult value, $Res Function(_ImportParseResult) _then) = __$ImportParseResultCopyWithImpl;
@override @useResult
$Res call({
 String sourceApp, List<ParsedWorkout> workouts, List<UnmappedExercise> unmappedExercises, Map<String, String> autoMappedExercises, List<String> warnings, int totalRows, int parsedRows
});




}
/// @nodoc
class __$ImportParseResultCopyWithImpl<$Res>
    implements _$ImportParseResultCopyWith<$Res> {
  __$ImportParseResultCopyWithImpl(this._self, this._then);

  final _ImportParseResult _self;
  final $Res Function(_ImportParseResult) _then;

/// Create a copy of ImportParseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceApp = null,Object? workouts = null,Object? unmappedExercises = null,Object? autoMappedExercises = null,Object? warnings = null,Object? totalRows = null,Object? parsedRows = null,}) {
  return _then(_ImportParseResult(
sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,workouts: null == workouts ? _self._workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<ParsedWorkout>,unmappedExercises: null == unmappedExercises ? _self._unmappedExercises : unmappedExercises // ignore: cast_nullable_to_non_nullable
as List<UnmappedExercise>,autoMappedExercises: null == autoMappedExercises ? _self._autoMappedExercises : autoMappedExercises // ignore: cast_nullable_to_non_nullable
as Map<String, String>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,totalRows: null == totalRows ? _self.totalRows : totalRows // ignore: cast_nullable_to_non_nullable
as int,parsedRows: null == parsedRows ? _self.parsedRows : parsedRows // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ParsedWorkout {

/// Original workout name from CSV
 String get name;/// Workout date
 DateTime get date;/// Duration in minutes (if available)
 int? get durationMinutes;/// Workout notes
 String? get notes;/// Exercises in this workout
 List<ParsedExercise> get exercises;
/// Create a copy of ParsedWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedWorkoutCopyWith<ParsedWorkout> get copyWith => _$ParsedWorkoutCopyWithImpl<ParsedWorkout>(this as ParsedWorkout, _$identity);

  /// Serializes this ParsedWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedWorkout&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,date,durationMinutes,notes,const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'ParsedWorkout(name: $name, date: $date, durationMinutes: $durationMinutes, notes: $notes, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $ParsedWorkoutCopyWith<$Res>  {
  factory $ParsedWorkoutCopyWith(ParsedWorkout value, $Res Function(ParsedWorkout) _then) = _$ParsedWorkoutCopyWithImpl;
@useResult
$Res call({
 String name, DateTime date, int? durationMinutes, String? notes, List<ParsedExercise> exercises
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? date = null,Object? durationMinutes = freezed,Object? notes = freezed,Object? exercises = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ParsedExercise>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime date,  int? durationMinutes,  String? notes,  List<ParsedExercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedWorkout() when $default != null:
return $default(_that.name,_that.date,_that.durationMinutes,_that.notes,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime date,  int? durationMinutes,  String? notes,  List<ParsedExercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _ParsedWorkout():
return $default(_that.name,_that.date,_that.durationMinutes,_that.notes,_that.exercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime date,  int? durationMinutes,  String? notes,  List<ParsedExercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _ParsedWorkout() when $default != null:
return $default(_that.name,_that.date,_that.durationMinutes,_that.notes,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedWorkout implements ParsedWorkout {
  const _ParsedWorkout({required this.name, required this.date, this.durationMinutes, this.notes, required final  List<ParsedExercise> exercises}): _exercises = exercises;
  factory _ParsedWorkout.fromJson(Map<String, dynamic> json) => _$ParsedWorkoutFromJson(json);

/// Original workout name from CSV
@override final  String name;
/// Workout date
@override final  DateTime date;
/// Duration in minutes (if available)
@override final  int? durationMinutes;
/// Workout notes
@override final  String? notes;
/// Exercises in this workout
 final  List<ParsedExercise> _exercises;
/// Exercises in this workout
@override List<ParsedExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedWorkout&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,date,durationMinutes,notes,const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'ParsedWorkout(name: $name, date: $date, durationMinutes: $durationMinutes, notes: $notes, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$ParsedWorkoutCopyWith<$Res> implements $ParsedWorkoutCopyWith<$Res> {
  factory _$ParsedWorkoutCopyWith(_ParsedWorkout value, $Res Function(_ParsedWorkout) _then) = __$ParsedWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime date, int? durationMinutes, String? notes, List<ParsedExercise> exercises
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? date = null,Object? durationMinutes = freezed,Object? notes = freezed,Object? exercises = null,}) {
  return _then(_ParsedWorkout(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<ParsedExercise>,
  ));
}


}


/// @nodoc
mixin _$ParsedExercise {

/// Original exercise name from CSV
 String get originalName;/// Mapped exercise ID in our database (null if unmapped)
 String? get mappedExerciseId;/// Mapped exercise name (null if unmapped)
 String? get mappedExerciseName;/// Sets for this exercise
 List<ParsedSet> get sets;/// Exercise notes
 String? get notes;
/// Create a copy of ParsedExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedExerciseCopyWith<ParsedExercise> get copyWith => _$ParsedExerciseCopyWithImpl<ParsedExercise>(this as ParsedExercise, _$identity);

  /// Serializes this ParsedExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedExercise&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.mappedExerciseId, mappedExerciseId) || other.mappedExerciseId == mappedExerciseId)&&(identical(other.mappedExerciseName, mappedExerciseName) || other.mappedExerciseName == mappedExerciseName)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,mappedExerciseId,mappedExerciseName,const DeepCollectionEquality().hash(sets),notes);

@override
String toString() {
  return 'ParsedExercise(originalName: $originalName, mappedExerciseId: $mappedExerciseId, mappedExerciseName: $mappedExerciseName, sets: $sets, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $ParsedExerciseCopyWith<$Res>  {
  factory $ParsedExerciseCopyWith(ParsedExercise value, $Res Function(ParsedExercise) _then) = _$ParsedExerciseCopyWithImpl;
@useResult
$Res call({
 String originalName, String? mappedExerciseId, String? mappedExerciseName, List<ParsedSet> sets, String? notes
});




}
/// @nodoc
class _$ParsedExerciseCopyWithImpl<$Res>
    implements $ParsedExerciseCopyWith<$Res> {
  _$ParsedExerciseCopyWithImpl(this._self, this._then);

  final ParsedExercise _self;
  final $Res Function(ParsedExercise) _then;

/// Create a copy of ParsedExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalName = null,Object? mappedExerciseId = freezed,Object? mappedExerciseName = freezed,Object? sets = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,mappedExerciseId: freezed == mappedExerciseId ? _self.mappedExerciseId : mappedExerciseId // ignore: cast_nullable_to_non_nullable
as String?,mappedExerciseName: freezed == mappedExerciseName ? _self.mappedExerciseName : mappedExerciseName // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<ParsedSet>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedExercise].
extension ParsedExercisePatterns on ParsedExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedExercise value)  $default,){
final _that = this;
switch (_that) {
case _ParsedExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedExercise value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String originalName,  String? mappedExerciseId,  String? mappedExerciseName,  List<ParsedSet> sets,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedExercise() when $default != null:
return $default(_that.originalName,_that.mappedExerciseId,_that.mappedExerciseName,_that.sets,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String originalName,  String? mappedExerciseId,  String? mappedExerciseName,  List<ParsedSet> sets,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ParsedExercise():
return $default(_that.originalName,_that.mappedExerciseId,_that.mappedExerciseName,_that.sets,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String originalName,  String? mappedExerciseId,  String? mappedExerciseName,  List<ParsedSet> sets,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ParsedExercise() when $default != null:
return $default(_that.originalName,_that.mappedExerciseId,_that.mappedExerciseName,_that.sets,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedExercise implements ParsedExercise {
  const _ParsedExercise({required this.originalName, this.mappedExerciseId, this.mappedExerciseName, required final  List<ParsedSet> sets, this.notes}): _sets = sets;
  factory _ParsedExercise.fromJson(Map<String, dynamic> json) => _$ParsedExerciseFromJson(json);

/// Original exercise name from CSV
@override final  String originalName;
/// Mapped exercise ID in our database (null if unmapped)
@override final  String? mappedExerciseId;
/// Mapped exercise name (null if unmapped)
@override final  String? mappedExerciseName;
/// Sets for this exercise
 final  List<ParsedSet> _sets;
/// Sets for this exercise
@override List<ParsedSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

/// Exercise notes
@override final  String? notes;

/// Create a copy of ParsedExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedExerciseCopyWith<_ParsedExercise> get copyWith => __$ParsedExerciseCopyWithImpl<_ParsedExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedExercise&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.mappedExerciseId, mappedExerciseId) || other.mappedExerciseId == mappedExerciseId)&&(identical(other.mappedExerciseName, mappedExerciseName) || other.mappedExerciseName == mappedExerciseName)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,mappedExerciseId,mappedExerciseName,const DeepCollectionEquality().hash(_sets),notes);

@override
String toString() {
  return 'ParsedExercise(originalName: $originalName, mappedExerciseId: $mappedExerciseId, mappedExerciseName: $mappedExerciseName, sets: $sets, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ParsedExerciseCopyWith<$Res> implements $ParsedExerciseCopyWith<$Res> {
  factory _$ParsedExerciseCopyWith(_ParsedExercise value, $Res Function(_ParsedExercise) _then) = __$ParsedExerciseCopyWithImpl;
@override @useResult
$Res call({
 String originalName, String? mappedExerciseId, String? mappedExerciseName, List<ParsedSet> sets, String? notes
});




}
/// @nodoc
class __$ParsedExerciseCopyWithImpl<$Res>
    implements _$ParsedExerciseCopyWith<$Res> {
  __$ParsedExerciseCopyWithImpl(this._self, this._then);

  final _ParsedExercise _self;
  final $Res Function(_ParsedExercise) _then;

/// Create a copy of ParsedExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalName = null,Object? mappedExerciseId = freezed,Object? mappedExerciseName = freezed,Object? sets = null,Object? notes = freezed,}) {
  return _then(_ParsedExercise(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,mappedExerciseId: freezed == mappedExerciseId ? _self.mappedExerciseId : mappedExerciseId // ignore: cast_nullable_to_non_nullable
as String?,mappedExerciseName: freezed == mappedExerciseName ? _self.mappedExerciseName : mappedExerciseName // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<ParsedSet>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ParsedSet {

/// Set number (1-based)
 int get setNumber;/// Weight (in user's unit preference)
 double? get weight;/// Reps performed
 int? get reps;/// Duration in seconds (for timed exercises)
 int? get seconds;/// Distance (for cardio)
 double? get distance;/// RPE if available
 int? get rpe;/// Set notes
 String? get notes;
/// Create a copy of ParsedSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedSetCopyWith<ParsedSet> get copyWith => _$ParsedSetCopyWithImpl<ParsedSet>(this as ParsedSet, _$identity);

  /// Serializes this ParsedSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedSet&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setNumber,weight,reps,seconds,distance,rpe,notes);

@override
String toString() {
  return 'ParsedSet(setNumber: $setNumber, weight: $weight, reps: $reps, seconds: $seconds, distance: $distance, rpe: $rpe, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $ParsedSetCopyWith<$Res>  {
  factory $ParsedSetCopyWith(ParsedSet value, $Res Function(ParsedSet) _then) = _$ParsedSetCopyWithImpl;
@useResult
$Res call({
 int setNumber, double? weight, int? reps, int? seconds, double? distance, int? rpe, String? notes
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
@pragma('vm:prefer-inline') @override $Res call({Object? setNumber = null,Object? weight = freezed,Object? reps = freezed,Object? seconds = freezed,Object? distance = freezed,Object? rpe = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,seconds: freezed == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int?,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int setNumber,  double? weight,  int? reps,  int? seconds,  double? distance,  int? rpe,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedSet() when $default != null:
return $default(_that.setNumber,_that.weight,_that.reps,_that.seconds,_that.distance,_that.rpe,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int setNumber,  double? weight,  int? reps,  int? seconds,  double? distance,  int? rpe,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _ParsedSet():
return $default(_that.setNumber,_that.weight,_that.reps,_that.seconds,_that.distance,_that.rpe,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int setNumber,  double? weight,  int? reps,  int? seconds,  double? distance,  int? rpe,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _ParsedSet() when $default != null:
return $default(_that.setNumber,_that.weight,_that.reps,_that.seconds,_that.distance,_that.rpe,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedSet implements ParsedSet {
  const _ParsedSet({required this.setNumber, this.weight, this.reps, this.seconds, this.distance, this.rpe, this.notes});
  factory _ParsedSet.fromJson(Map<String, dynamic> json) => _$ParsedSetFromJson(json);

/// Set number (1-based)
@override final  int setNumber;
/// Weight (in user's unit preference)
@override final  double? weight;
/// Reps performed
@override final  int? reps;
/// Duration in seconds (for timed exercises)
@override final  int? seconds;
/// Distance (for cardio)
@override final  double? distance;
/// RPE if available
@override final  int? rpe;
/// Set notes
@override final  String? notes;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedSet&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.rpe, rpe) || other.rpe == rpe)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setNumber,weight,reps,seconds,distance,rpe,notes);

@override
String toString() {
  return 'ParsedSet(setNumber: $setNumber, weight: $weight, reps: $reps, seconds: $seconds, distance: $distance, rpe: $rpe, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$ParsedSetCopyWith<$Res> implements $ParsedSetCopyWith<$Res> {
  factory _$ParsedSetCopyWith(_ParsedSet value, $Res Function(_ParsedSet) _then) = __$ParsedSetCopyWithImpl;
@override @useResult
$Res call({
 int setNumber, double? weight, int? reps, int? seconds, double? distance, int? rpe, String? notes
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
@override @pragma('vm:prefer-inline') $Res call({Object? setNumber = null,Object? weight = freezed,Object? reps = freezed,Object? seconds = freezed,Object? distance = freezed,Object? rpe = freezed,Object? notes = freezed,}) {
  return _then(_ParsedSet(
setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,seconds: freezed == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int?,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,rpe: freezed == rpe ? _self.rpe : rpe // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UnmappedExercise {

/// Original name from CSV
 String get originalName;/// How many times this exercise appears
 int get occurrences;/// Best fuzzy match suggestions
 List<ExerciseMatch> get suggestions;
/// Create a copy of UnmappedExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnmappedExerciseCopyWith<UnmappedExercise> get copyWith => _$UnmappedExerciseCopyWithImpl<UnmappedExercise>(this as UnmappedExercise, _$identity);

  /// Serializes this UnmappedExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnmappedExercise&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.occurrences, occurrences) || other.occurrences == occurrences)&&const DeepCollectionEquality().equals(other.suggestions, suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,occurrences,const DeepCollectionEquality().hash(suggestions));

@override
String toString() {
  return 'UnmappedExercise(originalName: $originalName, occurrences: $occurrences, suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class $UnmappedExerciseCopyWith<$Res>  {
  factory $UnmappedExerciseCopyWith(UnmappedExercise value, $Res Function(UnmappedExercise) _then) = _$UnmappedExerciseCopyWithImpl;
@useResult
$Res call({
 String originalName, int occurrences, List<ExerciseMatch> suggestions
});




}
/// @nodoc
class _$UnmappedExerciseCopyWithImpl<$Res>
    implements $UnmappedExerciseCopyWith<$Res> {
  _$UnmappedExerciseCopyWithImpl(this._self, this._then);

  final UnmappedExercise _self;
  final $Res Function(UnmappedExercise) _then;

/// Create a copy of UnmappedExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalName = null,Object? occurrences = null,Object? suggestions = null,}) {
  return _then(_self.copyWith(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,occurrences: null == occurrences ? _self.occurrences : occurrences // ignore: cast_nullable_to_non_nullable
as int,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<ExerciseMatch>,
  ));
}

}


/// Adds pattern-matching-related methods to [UnmappedExercise].
extension UnmappedExercisePatterns on UnmappedExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnmappedExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnmappedExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnmappedExercise value)  $default,){
final _that = this;
switch (_that) {
case _UnmappedExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnmappedExercise value)?  $default,){
final _that = this;
switch (_that) {
case _UnmappedExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String originalName,  int occurrences,  List<ExerciseMatch> suggestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnmappedExercise() when $default != null:
return $default(_that.originalName,_that.occurrences,_that.suggestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String originalName,  int occurrences,  List<ExerciseMatch> suggestions)  $default,) {final _that = this;
switch (_that) {
case _UnmappedExercise():
return $default(_that.originalName,_that.occurrences,_that.suggestions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String originalName,  int occurrences,  List<ExerciseMatch> suggestions)?  $default,) {final _that = this;
switch (_that) {
case _UnmappedExercise() when $default != null:
return $default(_that.originalName,_that.occurrences,_that.suggestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnmappedExercise implements UnmappedExercise {
  const _UnmappedExercise({required this.originalName, required this.occurrences, final  List<ExerciseMatch> suggestions = const []}): _suggestions = suggestions;
  factory _UnmappedExercise.fromJson(Map<String, dynamic> json) => _$UnmappedExerciseFromJson(json);

/// Original name from CSV
@override final  String originalName;
/// How many times this exercise appears
@override final  int occurrences;
/// Best fuzzy match suggestions
 final  List<ExerciseMatch> _suggestions;
/// Best fuzzy match suggestions
@override@JsonKey() List<ExerciseMatch> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}


/// Create a copy of UnmappedExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnmappedExerciseCopyWith<_UnmappedExercise> get copyWith => __$UnmappedExerciseCopyWithImpl<_UnmappedExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnmappedExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnmappedExercise&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.occurrences, occurrences) || other.occurrences == occurrences)&&const DeepCollectionEquality().equals(other._suggestions, _suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalName,occurrences,const DeepCollectionEquality().hash(_suggestions));

@override
String toString() {
  return 'UnmappedExercise(originalName: $originalName, occurrences: $occurrences, suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class _$UnmappedExerciseCopyWith<$Res> implements $UnmappedExerciseCopyWith<$Res> {
  factory _$UnmappedExerciseCopyWith(_UnmappedExercise value, $Res Function(_UnmappedExercise) _then) = __$UnmappedExerciseCopyWithImpl;
@override @useResult
$Res call({
 String originalName, int occurrences, List<ExerciseMatch> suggestions
});




}
/// @nodoc
class __$UnmappedExerciseCopyWithImpl<$Res>
    implements _$UnmappedExerciseCopyWith<$Res> {
  __$UnmappedExerciseCopyWithImpl(this._self, this._then);

  final _UnmappedExercise _self;
  final $Res Function(_UnmappedExercise) _then;

/// Create a copy of UnmappedExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalName = null,Object? occurrences = null,Object? suggestions = null,}) {
  return _then(_UnmappedExercise(
originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,occurrences: null == occurrences ? _self.occurrences : occurrences // ignore: cast_nullable_to_non_nullable
as int,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<ExerciseMatch>,
  ));
}


}


/// @nodoc
mixin _$ExerciseMatch {

/// Exercise ID in our database
 String get exerciseId;/// Exercise name
 String get name;/// Match confidence (0.0 - 1.0)
 double get confidence;
/// Create a copy of ExerciseMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseMatchCopyWith<ExerciseMatch> get copyWith => _$ExerciseMatchCopyWithImpl<ExerciseMatch>(this as ExerciseMatch, _$identity);

  /// Serializes this ExerciseMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseMatch&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,name,confidence);

@override
String toString() {
  return 'ExerciseMatch(exerciseId: $exerciseId, name: $name, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $ExerciseMatchCopyWith<$Res>  {
  factory $ExerciseMatchCopyWith(ExerciseMatch value, $Res Function(ExerciseMatch) _then) = _$ExerciseMatchCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String name, double confidence
});




}
/// @nodoc
class _$ExerciseMatchCopyWithImpl<$Res>
    implements $ExerciseMatchCopyWith<$Res> {
  _$ExerciseMatchCopyWithImpl(this._self, this._then);

  final ExerciseMatch _self;
  final $Res Function(ExerciseMatch) _then;

/// Create a copy of ExerciseMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? name = null,Object? confidence = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseMatch].
extension ExerciseMatchPatterns on ExerciseMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseMatch value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseMatch value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String name,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseMatch() when $default != null:
return $default(_that.exerciseId,_that.name,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String name,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _ExerciseMatch():
return $default(_that.exerciseId,_that.name,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String name,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseMatch() when $default != null:
return $default(_that.exerciseId,_that.name,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseMatch implements ExerciseMatch {
  const _ExerciseMatch({required this.exerciseId, required this.name, required this.confidence});
  factory _ExerciseMatch.fromJson(Map<String, dynamic> json) => _$ExerciseMatchFromJson(json);

/// Exercise ID in our database
@override final  String exerciseId;
/// Exercise name
@override final  String name;
/// Match confidence (0.0 - 1.0)
@override final  double confidence;

/// Create a copy of ExerciseMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseMatchCopyWith<_ExerciseMatch> get copyWith => __$ExerciseMatchCopyWithImpl<_ExerciseMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseMatch&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,name,confidence);

@override
String toString() {
  return 'ExerciseMatch(exerciseId: $exerciseId, name: $name, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$ExerciseMatchCopyWith<$Res> implements $ExerciseMatchCopyWith<$Res> {
  factory _$ExerciseMatchCopyWith(_ExerciseMatch value, $Res Function(_ExerciseMatch) _then) = __$ExerciseMatchCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String name, double confidence
});




}
/// @nodoc
class __$ExerciseMatchCopyWithImpl<$Res>
    implements _$ExerciseMatchCopyWith<$Res> {
  __$ExerciseMatchCopyWithImpl(this._self, this._then);

  final _ExerciseMatch _self;
  final $Res Function(_ExerciseMatch) _then;

/// Create a copy of ExerciseMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? name = null,Object? confidence = null,}) {
  return _then(_ExerciseMatch(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ImportFinalResult {

/// Number of workouts imported
 int get workoutsImported;/// Number of workouts skipped (duplicates, errors)
 int get workoutsSkipped;/// Total exercises imported
 int get exercisesImported;/// Total sets imported
 int get setsImported;/// Import errors
 List<String> get errors;/// Import timestamp
 DateTime get importedAt;/// Source app
 String get sourceApp;
/// Create a copy of ImportFinalResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportFinalResultCopyWith<ImportFinalResult> get copyWith => _$ImportFinalResultCopyWithImpl<ImportFinalResult>(this as ImportFinalResult, _$identity);

  /// Serializes this ImportFinalResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportFinalResult&&(identical(other.workoutsImported, workoutsImported) || other.workoutsImported == workoutsImported)&&(identical(other.workoutsSkipped, workoutsSkipped) || other.workoutsSkipped == workoutsSkipped)&&(identical(other.exercisesImported, exercisesImported) || other.exercisesImported == exercisesImported)&&(identical(other.setsImported, setsImported) || other.setsImported == setsImported)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutsImported,workoutsSkipped,exercisesImported,setsImported,const DeepCollectionEquality().hash(errors),importedAt,sourceApp);

@override
String toString() {
  return 'ImportFinalResult(workoutsImported: $workoutsImported, workoutsSkipped: $workoutsSkipped, exercisesImported: $exercisesImported, setsImported: $setsImported, errors: $errors, importedAt: $importedAt, sourceApp: $sourceApp)';
}


}

/// @nodoc
abstract mixin class $ImportFinalResultCopyWith<$Res>  {
  factory $ImportFinalResultCopyWith(ImportFinalResult value, $Res Function(ImportFinalResult) _then) = _$ImportFinalResultCopyWithImpl;
@useResult
$Res call({
 int workoutsImported, int workoutsSkipped, int exercisesImported, int setsImported, List<String> errors, DateTime importedAt, String sourceApp
});




}
/// @nodoc
class _$ImportFinalResultCopyWithImpl<$Res>
    implements $ImportFinalResultCopyWith<$Res> {
  _$ImportFinalResultCopyWithImpl(this._self, this._then);

  final ImportFinalResult _self;
  final $Res Function(ImportFinalResult) _then;

/// Create a copy of ImportFinalResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutsImported = null,Object? workoutsSkipped = null,Object? exercisesImported = null,Object? setsImported = null,Object? errors = null,Object? importedAt = null,Object? sourceApp = null,}) {
  return _then(_self.copyWith(
workoutsImported: null == workoutsImported ? _self.workoutsImported : workoutsImported // ignore: cast_nullable_to_non_nullable
as int,workoutsSkipped: null == workoutsSkipped ? _self.workoutsSkipped : workoutsSkipped // ignore: cast_nullable_to_non_nullable
as int,exercisesImported: null == exercisesImported ? _self.exercisesImported : exercisesImported // ignore: cast_nullable_to_non_nullable
as int,setsImported: null == setsImported ? _self.setsImported : setsImported // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportFinalResult].
extension ImportFinalResultPatterns on ImportFinalResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportFinalResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportFinalResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportFinalResult value)  $default,){
final _that = this;
switch (_that) {
case _ImportFinalResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportFinalResult value)?  $default,){
final _that = this;
switch (_that) {
case _ImportFinalResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int workoutsImported,  int workoutsSkipped,  int exercisesImported,  int setsImported,  List<String> errors,  DateTime importedAt,  String sourceApp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportFinalResult() when $default != null:
return $default(_that.workoutsImported,_that.workoutsSkipped,_that.exercisesImported,_that.setsImported,_that.errors,_that.importedAt,_that.sourceApp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int workoutsImported,  int workoutsSkipped,  int exercisesImported,  int setsImported,  List<String> errors,  DateTime importedAt,  String sourceApp)  $default,) {final _that = this;
switch (_that) {
case _ImportFinalResult():
return $default(_that.workoutsImported,_that.workoutsSkipped,_that.exercisesImported,_that.setsImported,_that.errors,_that.importedAt,_that.sourceApp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int workoutsImported,  int workoutsSkipped,  int exercisesImported,  int setsImported,  List<String> errors,  DateTime importedAt,  String sourceApp)?  $default,) {final _that = this;
switch (_that) {
case _ImportFinalResult() when $default != null:
return $default(_that.workoutsImported,_that.workoutsSkipped,_that.exercisesImported,_that.setsImported,_that.errors,_that.importedAt,_that.sourceApp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportFinalResult implements ImportFinalResult {
  const _ImportFinalResult({required this.workoutsImported, required this.workoutsSkipped, required this.exercisesImported, required this.setsImported, final  List<String> errors = const [], required this.importedAt, required this.sourceApp}): _errors = errors;
  factory _ImportFinalResult.fromJson(Map<String, dynamic> json) => _$ImportFinalResultFromJson(json);

/// Number of workouts imported
@override final  int workoutsImported;
/// Number of workouts skipped (duplicates, errors)
@override final  int workoutsSkipped;
/// Total exercises imported
@override final  int exercisesImported;
/// Total sets imported
@override final  int setsImported;
/// Import errors
 final  List<String> _errors;
/// Import errors
@override@JsonKey() List<String> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

/// Import timestamp
@override final  DateTime importedAt;
/// Source app
@override final  String sourceApp;

/// Create a copy of ImportFinalResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportFinalResultCopyWith<_ImportFinalResult> get copyWith => __$ImportFinalResultCopyWithImpl<_ImportFinalResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportFinalResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportFinalResult&&(identical(other.workoutsImported, workoutsImported) || other.workoutsImported == workoutsImported)&&(identical(other.workoutsSkipped, workoutsSkipped) || other.workoutsSkipped == workoutsSkipped)&&(identical(other.exercisesImported, exercisesImported) || other.exercisesImported == exercisesImported)&&(identical(other.setsImported, setsImported) || other.setsImported == setsImported)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutsImported,workoutsSkipped,exercisesImported,setsImported,const DeepCollectionEquality().hash(_errors),importedAt,sourceApp);

@override
String toString() {
  return 'ImportFinalResult(workoutsImported: $workoutsImported, workoutsSkipped: $workoutsSkipped, exercisesImported: $exercisesImported, setsImported: $setsImported, errors: $errors, importedAt: $importedAt, sourceApp: $sourceApp)';
}


}

/// @nodoc
abstract mixin class _$ImportFinalResultCopyWith<$Res> implements $ImportFinalResultCopyWith<$Res> {
  factory _$ImportFinalResultCopyWith(_ImportFinalResult value, $Res Function(_ImportFinalResult) _then) = __$ImportFinalResultCopyWithImpl;
@override @useResult
$Res call({
 int workoutsImported, int workoutsSkipped, int exercisesImported, int setsImported, List<String> errors, DateTime importedAt, String sourceApp
});




}
/// @nodoc
class __$ImportFinalResultCopyWithImpl<$Res>
    implements _$ImportFinalResultCopyWith<$Res> {
  __$ImportFinalResultCopyWithImpl(this._self, this._then);

  final _ImportFinalResult _self;
  final $Res Function(_ImportFinalResult) _then;

/// Create a copy of ImportFinalResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutsImported = null,Object? workoutsSkipped = null,Object? exercisesImported = null,Object? setsImported = null,Object? errors = null,Object? importedAt = null,Object? sourceApp = null,}) {
  return _then(_ImportFinalResult(
workoutsImported: null == workoutsImported ? _self.workoutsImported : workoutsImported // ignore: cast_nullable_to_non_nullable
as int,workoutsSkipped: null == workoutsSkipped ? _self.workoutsSkipped : workoutsSkipped // ignore: cast_nullable_to_non_nullable
as int,exercisesImported: null == exercisesImported ? _self.exercisesImported : exercisesImported // ignore: cast_nullable_to_non_nullable
as int,setsImported: null == setsImported ? _self.setsImported : setsImported // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<String>,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
