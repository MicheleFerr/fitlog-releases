// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_limit_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RateLimitResult {

 RateLimitStatus get status; String get message; int get waitSeconds;
/// Create a copy of RateLimitResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitResultCopyWith<RateLimitResult> get copyWith => _$RateLimitResultCopyWithImpl<RateLimitResult>(this as RateLimitResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitResult&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.waitSeconds, waitSeconds) || other.waitSeconds == waitSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,waitSeconds);

@override
String toString() {
  return 'RateLimitResult(status: $status, message: $message, waitSeconds: $waitSeconds)';
}


}

/// @nodoc
abstract mixin class $RateLimitResultCopyWith<$Res>  {
  factory $RateLimitResultCopyWith(RateLimitResult value, $Res Function(RateLimitResult) _then) = _$RateLimitResultCopyWithImpl;
@useResult
$Res call({
 RateLimitStatus status, String message, int waitSeconds
});




}
/// @nodoc
class _$RateLimitResultCopyWithImpl<$Res>
    implements $RateLimitResultCopyWith<$Res> {
  _$RateLimitResultCopyWithImpl(this._self, this._then);

  final RateLimitResult _self;
  final $Res Function(RateLimitResult) _then;

/// Create a copy of RateLimitResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? message = null,Object? waitSeconds = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateLimitStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,waitSeconds: null == waitSeconds ? _self.waitSeconds : waitSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RateLimitResult].
extension RateLimitResultPatterns on RateLimitResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RateLimitResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RateLimitResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RateLimitResult value)  $default,){
final _that = this;
switch (_that) {
case _RateLimitResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RateLimitResult value)?  $default,){
final _that = this;
switch (_that) {
case _RateLimitResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RateLimitStatus status,  String message,  int waitSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RateLimitResult() when $default != null:
return $default(_that.status,_that.message,_that.waitSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RateLimitStatus status,  String message,  int waitSeconds)  $default,) {final _that = this;
switch (_that) {
case _RateLimitResult():
return $default(_that.status,_that.message,_that.waitSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RateLimitStatus status,  String message,  int waitSeconds)?  $default,) {final _that = this;
switch (_that) {
case _RateLimitResult() when $default != null:
return $default(_that.status,_that.message,_that.waitSeconds);case _:
  return null;

}
}

}

/// @nodoc


class _RateLimitResult extends RateLimitResult {
  const _RateLimitResult({required this.status, required this.message, this.waitSeconds = 0}): super._();
  

@override final  RateLimitStatus status;
@override final  String message;
@override@JsonKey() final  int waitSeconds;

/// Create a copy of RateLimitResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RateLimitResultCopyWith<_RateLimitResult> get copyWith => __$RateLimitResultCopyWithImpl<_RateLimitResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateLimitResult&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.waitSeconds, waitSeconds) || other.waitSeconds == waitSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,waitSeconds);

@override
String toString() {
  return 'RateLimitResult(status: $status, message: $message, waitSeconds: $waitSeconds)';
}


}

/// @nodoc
abstract mixin class _$RateLimitResultCopyWith<$Res> implements $RateLimitResultCopyWith<$Res> {
  factory _$RateLimitResultCopyWith(_RateLimitResult value, $Res Function(_RateLimitResult) _then) = __$RateLimitResultCopyWithImpl;
@override @useResult
$Res call({
 RateLimitStatus status, String message, int waitSeconds
});




}
/// @nodoc
class __$RateLimitResultCopyWithImpl<$Res>
    implements _$RateLimitResultCopyWith<$Res> {
  __$RateLimitResultCopyWithImpl(this._self, this._then);

  final _RateLimitResult _self;
  final $Res Function(_RateLimitResult) _then;

/// Create a copy of RateLimitResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = null,Object? waitSeconds = null,}) {
  return _then(_RateLimitResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RateLimitStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,waitSeconds: null == waitSeconds ? _self.waitSeconds : waitSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
