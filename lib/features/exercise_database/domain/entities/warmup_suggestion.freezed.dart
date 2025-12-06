// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warmup_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WarmupSuggestion {

/// ID of the warmup exercise in the database
 String get exerciseId;/// Display name of the exercise
 String get exerciseName;/// Number of sets to perform
 int get sets;/// Number of reps per set
 int get reps;/// Type of warmup (mobility or activation)
 WarmupType get type;
/// Create a copy of WarmupSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarmupSuggestionCopyWith<WarmupSuggestion> get copyWith => _$WarmupSuggestionCopyWithImpl<WarmupSuggestion>(this as WarmupSuggestion, _$identity);

  /// Serializes this WarmupSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarmupSuggestion&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,sets,reps,type);

@override
String toString() {
  return 'WarmupSuggestion(exerciseId: $exerciseId, exerciseName: $exerciseName, sets: $sets, reps: $reps, type: $type)';
}


}

/// @nodoc
abstract mixin class $WarmupSuggestionCopyWith<$Res>  {
  factory $WarmupSuggestionCopyWith(WarmupSuggestion value, $Res Function(WarmupSuggestion) _then) = _$WarmupSuggestionCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String exerciseName, int sets, int reps, WarmupType type
});




}
/// @nodoc
class _$WarmupSuggestionCopyWithImpl<$Res>
    implements $WarmupSuggestionCopyWith<$Res> {
  _$WarmupSuggestionCopyWithImpl(this._self, this._then);

  final WarmupSuggestion _self;
  final $Res Function(WarmupSuggestion) _then;

/// Create a copy of WarmupSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? sets = null,Object? reps = null,Object? type = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WarmupType,
  ));
}

}


/// Adds pattern-matching-related methods to [WarmupSuggestion].
extension WarmupSuggestionPatterns on WarmupSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarmupSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarmupSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarmupSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _WarmupSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarmupSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _WarmupSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  int sets,  int reps,  WarmupType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarmupSuggestion() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.sets,_that.reps,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  int sets,  int reps,  WarmupType type)  $default,) {final _that = this;
switch (_that) {
case _WarmupSuggestion():
return $default(_that.exerciseId,_that.exerciseName,_that.sets,_that.reps,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String exerciseName,  int sets,  int reps,  WarmupType type)?  $default,) {final _that = this;
switch (_that) {
case _WarmupSuggestion() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.sets,_that.reps,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WarmupSuggestion implements WarmupSuggestion {
  const _WarmupSuggestion({required this.exerciseId, required this.exerciseName, required this.sets, required this.reps, required this.type});
  factory _WarmupSuggestion.fromJson(Map<String, dynamic> json) => _$WarmupSuggestionFromJson(json);

/// ID of the warmup exercise in the database
@override final  String exerciseId;
/// Display name of the exercise
@override final  String exerciseName;
/// Number of sets to perform
@override final  int sets;
/// Number of reps per set
@override final  int reps;
/// Type of warmup (mobility or activation)
@override final  WarmupType type;

/// Create a copy of WarmupSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarmupSuggestionCopyWith<_WarmupSuggestion> get copyWith => __$WarmupSuggestionCopyWithImpl<_WarmupSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarmupSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarmupSuggestion&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,sets,reps,type);

@override
String toString() {
  return 'WarmupSuggestion(exerciseId: $exerciseId, exerciseName: $exerciseName, sets: $sets, reps: $reps, type: $type)';
}


}

/// @nodoc
abstract mixin class _$WarmupSuggestionCopyWith<$Res> implements $WarmupSuggestionCopyWith<$Res> {
  factory _$WarmupSuggestionCopyWith(_WarmupSuggestion value, $Res Function(_WarmupSuggestion) _then) = __$WarmupSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String exerciseName, int sets, int reps, WarmupType type
});




}
/// @nodoc
class __$WarmupSuggestionCopyWithImpl<$Res>
    implements _$WarmupSuggestionCopyWith<$Res> {
  __$WarmupSuggestionCopyWithImpl(this._self, this._then);

  final _WarmupSuggestion _self;
  final $Res Function(_WarmupSuggestion) _then;

/// Create a copy of WarmupSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? sets = null,Object? reps = null,Object? type = null,}) {
  return _then(_WarmupSuggestion(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WarmupType,
  ));
}


}

// dart format on
