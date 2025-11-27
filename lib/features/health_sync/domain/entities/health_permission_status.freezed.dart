// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_permission_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthPermissionStatus {

/// Map of permission states per data type
/// Key: HealthDataType (workout, bodyWeight, etc.)
/// Value: PermissionState (authorized, denied, etc.)
 Map<HealthDataType, PermissionState> get permissions;/// Android-only: Whether Health Connect is installed and available
/// - iOS: Always false (uses HealthKit natively)
/// - Android 14+: True if Health Connect app installed
 bool get healthConnectAvailable;
/// Create a copy of HealthPermissionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthPermissionStatusCopyWith<HealthPermissionStatus> get copyWith => _$HealthPermissionStatusCopyWithImpl<HealthPermissionStatus>(this as HealthPermissionStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthPermissionStatus&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.healthConnectAvailable, healthConnectAvailable) || other.healthConnectAvailable == healthConnectAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(permissions),healthConnectAvailable);

@override
String toString() {
  return 'HealthPermissionStatus(permissions: $permissions, healthConnectAvailable: $healthConnectAvailable)';
}


}

/// @nodoc
abstract mixin class $HealthPermissionStatusCopyWith<$Res>  {
  factory $HealthPermissionStatusCopyWith(HealthPermissionStatus value, $Res Function(HealthPermissionStatus) _then) = _$HealthPermissionStatusCopyWithImpl;
@useResult
$Res call({
 Map<HealthDataType, PermissionState> permissions, bool healthConnectAvailable
});




}
/// @nodoc
class _$HealthPermissionStatusCopyWithImpl<$Res>
    implements $HealthPermissionStatusCopyWith<$Res> {
  _$HealthPermissionStatusCopyWithImpl(this._self, this._then);

  final HealthPermissionStatus _self;
  final $Res Function(HealthPermissionStatus) _then;

/// Create a copy of HealthPermissionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? permissions = null,Object? healthConnectAvailable = null,}) {
  return _then(_self.copyWith(
permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as Map<HealthDataType, PermissionState>,healthConnectAvailable: null == healthConnectAvailable ? _self.healthConnectAvailable : healthConnectAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthPermissionStatus].
extension HealthPermissionStatusPatterns on HealthPermissionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthPermissionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthPermissionStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthPermissionStatus value)  $default,){
final _that = this;
switch (_that) {
case _HealthPermissionStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthPermissionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _HealthPermissionStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<HealthDataType, PermissionState> permissions,  bool healthConnectAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthPermissionStatus() when $default != null:
return $default(_that.permissions,_that.healthConnectAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<HealthDataType, PermissionState> permissions,  bool healthConnectAvailable)  $default,) {final _that = this;
switch (_that) {
case _HealthPermissionStatus():
return $default(_that.permissions,_that.healthConnectAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<HealthDataType, PermissionState> permissions,  bool healthConnectAvailable)?  $default,) {final _that = this;
switch (_that) {
case _HealthPermissionStatus() when $default != null:
return $default(_that.permissions,_that.healthConnectAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _HealthPermissionStatus implements HealthPermissionStatus {
  const _HealthPermissionStatus({required final  Map<HealthDataType, PermissionState> permissions, this.healthConnectAvailable = false}): _permissions = permissions;
  

/// Map of permission states per data type
/// Key: HealthDataType (workout, bodyWeight, etc.)
/// Value: PermissionState (authorized, denied, etc.)
 final  Map<HealthDataType, PermissionState> _permissions;
/// Map of permission states per data type
/// Key: HealthDataType (workout, bodyWeight, etc.)
/// Value: PermissionState (authorized, denied, etc.)
@override Map<HealthDataType, PermissionState> get permissions {
  if (_permissions is EqualUnmodifiableMapView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_permissions);
}

/// Android-only: Whether Health Connect is installed and available
/// - iOS: Always false (uses HealthKit natively)
/// - Android 14+: True if Health Connect app installed
@override@JsonKey() final  bool healthConnectAvailable;

/// Create a copy of HealthPermissionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthPermissionStatusCopyWith<_HealthPermissionStatus> get copyWith => __$HealthPermissionStatusCopyWithImpl<_HealthPermissionStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthPermissionStatus&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.healthConnectAvailable, healthConnectAvailable) || other.healthConnectAvailable == healthConnectAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_permissions),healthConnectAvailable);

@override
String toString() {
  return 'HealthPermissionStatus(permissions: $permissions, healthConnectAvailable: $healthConnectAvailable)';
}


}

/// @nodoc
abstract mixin class _$HealthPermissionStatusCopyWith<$Res> implements $HealthPermissionStatusCopyWith<$Res> {
  factory _$HealthPermissionStatusCopyWith(_HealthPermissionStatus value, $Res Function(_HealthPermissionStatus) _then) = __$HealthPermissionStatusCopyWithImpl;
@override @useResult
$Res call({
 Map<HealthDataType, PermissionState> permissions, bool healthConnectAvailable
});




}
/// @nodoc
class __$HealthPermissionStatusCopyWithImpl<$Res>
    implements _$HealthPermissionStatusCopyWith<$Res> {
  __$HealthPermissionStatusCopyWithImpl(this._self, this._then);

  final _HealthPermissionStatus _self;
  final $Res Function(_HealthPermissionStatus) _then;

/// Create a copy of HealthPermissionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? permissions = null,Object? healthConnectAvailable = null,}) {
  return _then(_HealthPermissionStatus(
permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as Map<HealthDataType, PermissionState>,healthConnectAvailable: null == healthConnectAvailable ? _self.healthConnectAvailable : healthConnectAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
