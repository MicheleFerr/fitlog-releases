// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExercisePreferencesModel {

/// Set of exercise names marked as favorite
///
/// Stored as List in Firestore, converted to Set for O(1) lookup
 List<String> get favorites;/// Timestamp of last update
///
/// Used for sync conflict resolution and cache invalidation
@TimestampConverter() DateTime? get lastUpdated;
/// Create a copy of ExercisePreferencesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExercisePreferencesModelCopyWith<ExercisePreferencesModel> get copyWith => _$ExercisePreferencesModelCopyWithImpl<ExercisePreferencesModel>(this as ExercisePreferencesModel, _$identity);

  /// Serializes this ExercisePreferencesModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExercisePreferencesModel&&const DeepCollectionEquality().equals(other.favorites, favorites)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(favorites),lastUpdated);

@override
String toString() {
  return 'ExercisePreferencesModel(favorites: $favorites, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $ExercisePreferencesModelCopyWith<$Res>  {
  factory $ExercisePreferencesModelCopyWith(ExercisePreferencesModel value, $Res Function(ExercisePreferencesModel) _then) = _$ExercisePreferencesModelCopyWithImpl;
@useResult
$Res call({
 List<String> favorites,@TimestampConverter() DateTime? lastUpdated
});




}
/// @nodoc
class _$ExercisePreferencesModelCopyWithImpl<$Res>
    implements $ExercisePreferencesModelCopyWith<$Res> {
  _$ExercisePreferencesModelCopyWithImpl(this._self, this._then);

  final ExercisePreferencesModel _self;
  final $Res Function(ExercisePreferencesModel) _then;

/// Create a copy of ExercisePreferencesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? favorites = null,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<String>,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExercisePreferencesModel].
extension ExercisePreferencesModelPatterns on ExercisePreferencesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExercisePreferencesModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExercisePreferencesModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExercisePreferencesModel value)  $default,){
final _that = this;
switch (_that) {
case _ExercisePreferencesModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExercisePreferencesModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExercisePreferencesModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> favorites, @TimestampConverter()  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExercisePreferencesModel() when $default != null:
return $default(_that.favorites,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> favorites, @TimestampConverter()  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _ExercisePreferencesModel():
return $default(_that.favorites,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> favorites, @TimestampConverter()  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _ExercisePreferencesModel() when $default != null:
return $default(_that.favorites,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExercisePreferencesModel extends ExercisePreferencesModel {
  const _ExercisePreferencesModel({final  List<String> favorites = const [], @TimestampConverter() this.lastUpdated}): _favorites = favorites,super._();
  factory _ExercisePreferencesModel.fromJson(Map<String, dynamic> json) => _$ExercisePreferencesModelFromJson(json);

/// Set of exercise names marked as favorite
///
/// Stored as List in Firestore, converted to Set for O(1) lookup
 final  List<String> _favorites;
/// Set of exercise names marked as favorite
///
/// Stored as List in Firestore, converted to Set for O(1) lookup
@override@JsonKey() List<String> get favorites {
  if (_favorites is EqualUnmodifiableListView) return _favorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favorites);
}

/// Timestamp of last update
///
/// Used for sync conflict resolution and cache invalidation
@override@TimestampConverter() final  DateTime? lastUpdated;

/// Create a copy of ExercisePreferencesModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExercisePreferencesModelCopyWith<_ExercisePreferencesModel> get copyWith => __$ExercisePreferencesModelCopyWithImpl<_ExercisePreferencesModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExercisePreferencesModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExercisePreferencesModel&&const DeepCollectionEquality().equals(other._favorites, _favorites)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_favorites),lastUpdated);

@override
String toString() {
  return 'ExercisePreferencesModel(favorites: $favorites, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$ExercisePreferencesModelCopyWith<$Res> implements $ExercisePreferencesModelCopyWith<$Res> {
  factory _$ExercisePreferencesModelCopyWith(_ExercisePreferencesModel value, $Res Function(_ExercisePreferencesModel) _then) = __$ExercisePreferencesModelCopyWithImpl;
@override @useResult
$Res call({
 List<String> favorites,@TimestampConverter() DateTime? lastUpdated
});




}
/// @nodoc
class __$ExercisePreferencesModelCopyWithImpl<$Res>
    implements _$ExercisePreferencesModelCopyWith<$Res> {
  __$ExercisePreferencesModelCopyWithImpl(this._self, this._then);

  final _ExercisePreferencesModel _self;
  final $Res Function(_ExercisePreferencesModel) _then;

/// Create a copy of ExercisePreferencesModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? favorites = null,Object? lastUpdated = freezed,}) {
  return _then(_ExercisePreferencesModel(
favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<String>,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
