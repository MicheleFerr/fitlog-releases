// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_popularity_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExercisePopularityData {

/// Unique exercise identifier
 String get exerciseId;/// Global usage count (number of times used in templates)
 int get count;/// Timestamp of last update (from Firestore server)
 DateTime get lastUpdated;
/// Create a copy of ExercisePopularityData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExercisePopularityDataCopyWith<ExercisePopularityData> get copyWith => _$ExercisePopularityDataCopyWithImpl<ExercisePopularityData>(this as ExercisePopularityData, _$identity);

  /// Serializes this ExercisePopularityData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExercisePopularityData&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.count, count) || other.count == count)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,count,lastUpdated);

@override
String toString() {
  return 'ExercisePopularityData(exerciseId: $exerciseId, count: $count, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $ExercisePopularityDataCopyWith<$Res>  {
  factory $ExercisePopularityDataCopyWith(ExercisePopularityData value, $Res Function(ExercisePopularityData) _then) = _$ExercisePopularityDataCopyWithImpl;
@useResult
$Res call({
 String exerciseId, int count, DateTime lastUpdated
});




}
/// @nodoc
class _$ExercisePopularityDataCopyWithImpl<$Res>
    implements $ExercisePopularityDataCopyWith<$Res> {
  _$ExercisePopularityDataCopyWithImpl(this._self, this._then);

  final ExercisePopularityData _self;
  final $Res Function(ExercisePopularityData) _then;

/// Create a copy of ExercisePopularityData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? count = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ExercisePopularityData].
extension ExercisePopularityDataPatterns on ExercisePopularityData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExercisePopularityData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExercisePopularityData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExercisePopularityData value)  $default,){
final _that = this;
switch (_that) {
case _ExercisePopularityData():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExercisePopularityData value)?  $default,){
final _that = this;
switch (_that) {
case _ExercisePopularityData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  int count,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExercisePopularityData() when $default != null:
return $default(_that.exerciseId,_that.count,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  int count,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _ExercisePopularityData():
return $default(_that.exerciseId,_that.count,_that.lastUpdated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  int count,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _ExercisePopularityData() when $default != null:
return $default(_that.exerciseId,_that.count,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExercisePopularityData implements ExercisePopularityData {
  const _ExercisePopularityData({required this.exerciseId, required this.count, required this.lastUpdated});
  factory _ExercisePopularityData.fromJson(Map<String, dynamic> json) => _$ExercisePopularityDataFromJson(json);

/// Unique exercise identifier
@override final  String exerciseId;
/// Global usage count (number of times used in templates)
@override final  int count;
/// Timestamp of last update (from Firestore server)
@override final  DateTime lastUpdated;

/// Create a copy of ExercisePopularityData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExercisePopularityDataCopyWith<_ExercisePopularityData> get copyWith => __$ExercisePopularityDataCopyWithImpl<_ExercisePopularityData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExercisePopularityDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExercisePopularityData&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.count, count) || other.count == count)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,count,lastUpdated);

@override
String toString() {
  return 'ExercisePopularityData(exerciseId: $exerciseId, count: $count, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$ExercisePopularityDataCopyWith<$Res> implements $ExercisePopularityDataCopyWith<$Res> {
  factory _$ExercisePopularityDataCopyWith(_ExercisePopularityData value, $Res Function(_ExercisePopularityData) _then) = __$ExercisePopularityDataCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, int count, DateTime lastUpdated
});




}
/// @nodoc
class __$ExercisePopularityDataCopyWithImpl<$Res>
    implements _$ExercisePopularityDataCopyWith<$Res> {
  __$ExercisePopularityDataCopyWithImpl(this._self, this._then);

  final _ExercisePopularityData _self;
  final $Res Function(_ExercisePopularityData) _then;

/// Create a copy of ExercisePopularityData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? count = null,Object? lastUpdated = null,}) {
  return _then(_ExercisePopularityData(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
