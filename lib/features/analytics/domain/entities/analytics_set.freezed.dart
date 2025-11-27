// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsSet {

/// Weight lifted in kg (must be > 0)
 double get weight;/// Number of repetitions performed (must be > 0)
 int get reps;/// When the set was performed
 DateTime get date;
/// Create a copy of AnalyticsSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsSetCopyWith<AnalyticsSet> get copyWith => _$AnalyticsSetCopyWithImpl<AnalyticsSet>(this as AnalyticsSet, _$identity);

  /// Serializes this AnalyticsSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsSet&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,reps,date);

@override
String toString() {
  return 'AnalyticsSet(weight: $weight, reps: $reps, date: $date)';
}


}

/// @nodoc
abstract mixin class $AnalyticsSetCopyWith<$Res>  {
  factory $AnalyticsSetCopyWith(AnalyticsSet value, $Res Function(AnalyticsSet) _then) = _$AnalyticsSetCopyWithImpl;
@useResult
$Res call({
 double weight, int reps, DateTime date
});




}
/// @nodoc
class _$AnalyticsSetCopyWithImpl<$Res>
    implements $AnalyticsSetCopyWith<$Res> {
  _$AnalyticsSetCopyWithImpl(this._self, this._then);

  final AnalyticsSet _self;
  final $Res Function(AnalyticsSet) _then;

/// Create a copy of AnalyticsSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weight = null,Object? reps = null,Object? date = null,}) {
  return _then(_self.copyWith(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsSet].
extension AnalyticsSetPatterns on AnalyticsSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsSet value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsSet value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weight,  int reps,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsSet() when $default != null:
return $default(_that.weight,_that.reps,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weight,  int reps,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSet():
return $default(_that.weight,_that.reps,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weight,  int reps,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsSet() when $default != null:
return $default(_that.weight,_that.reps,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsSet extends AnalyticsSet {
  const _AnalyticsSet({required this.weight, required this.reps, required this.date}): super._();
  factory _AnalyticsSet.fromJson(Map<String, dynamic> json) => _$AnalyticsSetFromJson(json);

/// Weight lifted in kg (must be > 0)
@override final  double weight;
/// Number of repetitions performed (must be > 0)
@override final  int reps;
/// When the set was performed
@override final  DateTime date;

/// Create a copy of AnalyticsSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsSetCopyWith<_AnalyticsSet> get copyWith => __$AnalyticsSetCopyWithImpl<_AnalyticsSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsSet&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,reps,date);

@override
String toString() {
  return 'AnalyticsSet(weight: $weight, reps: $reps, date: $date)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsSetCopyWith<$Res> implements $AnalyticsSetCopyWith<$Res> {
  factory _$AnalyticsSetCopyWith(_AnalyticsSet value, $Res Function(_AnalyticsSet) _then) = __$AnalyticsSetCopyWithImpl;
@override @useResult
$Res call({
 double weight, int reps, DateTime date
});




}
/// @nodoc
class __$AnalyticsSetCopyWithImpl<$Res>
    implements _$AnalyticsSetCopyWith<$Res> {
  __$AnalyticsSetCopyWithImpl(this._self, this._then);

  final _AnalyticsSet _self;
  final $Res Function(_AnalyticsSet) _then;

/// Create a copy of AnalyticsSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weight = null,Object? reps = null,Object? date = null,}) {
  return _then(_AnalyticsSet(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
