// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_set_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnalyticsSetModel {

/// Weight lifted in kg
 double get weight;/// Number of repetitions performed
 int get reps;/// When the set was performed (Firestore Timestamp)
 DateTime get date;
/// Create a copy of AnalyticsSetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsSetModelCopyWith<AnalyticsSetModel> get copyWith => _$AnalyticsSetModelCopyWithImpl<AnalyticsSetModel>(this as AnalyticsSetModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsSetModel&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,weight,reps,date);

@override
String toString() {
  return 'AnalyticsSetModel(weight: $weight, reps: $reps, date: $date)';
}


}

/// @nodoc
abstract mixin class $AnalyticsSetModelCopyWith<$Res>  {
  factory $AnalyticsSetModelCopyWith(AnalyticsSetModel value, $Res Function(AnalyticsSetModel) _then) = _$AnalyticsSetModelCopyWithImpl;
@useResult
$Res call({
 double weight, int reps, DateTime date
});




}
/// @nodoc
class _$AnalyticsSetModelCopyWithImpl<$Res>
    implements $AnalyticsSetModelCopyWith<$Res> {
  _$AnalyticsSetModelCopyWithImpl(this._self, this._then);

  final AnalyticsSetModel _self;
  final $Res Function(AnalyticsSetModel) _then;

/// Create a copy of AnalyticsSetModel
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


/// Adds pattern-matching-related methods to [AnalyticsSetModel].
extension AnalyticsSetModelPatterns on AnalyticsSetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsSetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsSetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsSetModel value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsSetModel value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsSetModel() when $default != null:
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
case _AnalyticsSetModel() when $default != null:
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
case _AnalyticsSetModel():
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
case _AnalyticsSetModel() when $default != null:
return $default(_that.weight,_that.reps,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsSetModel extends AnalyticsSetModel {
  const _AnalyticsSetModel({required this.weight, required this.reps, required this.date}): super._();
  

/// Weight lifted in kg
@override final  double weight;
/// Number of repetitions performed
@override final  int reps;
/// When the set was performed (Firestore Timestamp)
@override final  DateTime date;

/// Create a copy of AnalyticsSetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsSetModelCopyWith<_AnalyticsSetModel> get copyWith => __$AnalyticsSetModelCopyWithImpl<_AnalyticsSetModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsSetModel&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,weight,reps,date);

@override
String toString() {
  return 'AnalyticsSetModel(weight: $weight, reps: $reps, date: $date)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsSetModelCopyWith<$Res> implements $AnalyticsSetModelCopyWith<$Res> {
  factory _$AnalyticsSetModelCopyWith(_AnalyticsSetModel value, $Res Function(_AnalyticsSetModel) _then) = __$AnalyticsSetModelCopyWithImpl;
@override @useResult
$Res call({
 double weight, int reps, DateTime date
});




}
/// @nodoc
class __$AnalyticsSetModelCopyWithImpl<$Res>
    implements _$AnalyticsSetModelCopyWith<$Res> {
  __$AnalyticsSetModelCopyWithImpl(this._self, this._then);

  final _AnalyticsSetModel _self;
  final $Res Function(_AnalyticsSetModel) _then;

/// Create a copy of AnalyticsSetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weight = null,Object? reps = null,Object? date = null,}) {
  return _then(_AnalyticsSetModel(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
