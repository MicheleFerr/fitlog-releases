// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_permission_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HealthPermissionStatus {
  /// Map of permission states per data type
  /// Key: HealthDataType (workout, bodyWeight, etc.)
  /// Value: PermissionState (authorized, denied, etc.)
  Map<HealthDataType, PermissionState> get permissions =>
      throw _privateConstructorUsedError;

  /// Android-only: Whether Health Connect is installed and available
  /// - iOS: Always false (uses HealthKit natively)
  /// - Android 14+: True if Health Connect app installed
  bool get healthConnectAvailable => throw _privateConstructorUsedError;

  /// Create a copy of HealthPermissionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthPermissionStatusCopyWith<HealthPermissionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthPermissionStatusCopyWith<$Res> {
  factory $HealthPermissionStatusCopyWith(
    HealthPermissionStatus value,
    $Res Function(HealthPermissionStatus) then,
  ) = _$HealthPermissionStatusCopyWithImpl<$Res, HealthPermissionStatus>;
  @useResult
  $Res call({
    Map<HealthDataType, PermissionState> permissions,
    bool healthConnectAvailable,
  });
}

/// @nodoc
class _$HealthPermissionStatusCopyWithImpl<
  $Res,
  $Val extends HealthPermissionStatus
>
    implements $HealthPermissionStatusCopyWith<$Res> {
  _$HealthPermissionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthPermissionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? permissions = null,
    Object? healthConnectAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as Map<HealthDataType, PermissionState>,
            healthConnectAvailable: null == healthConnectAvailable
                ? _value.healthConnectAvailable
                : healthConnectAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HealthPermissionStatusImplCopyWith<$Res>
    implements $HealthPermissionStatusCopyWith<$Res> {
  factory _$$HealthPermissionStatusImplCopyWith(
    _$HealthPermissionStatusImpl value,
    $Res Function(_$HealthPermissionStatusImpl) then,
  ) = __$$HealthPermissionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<HealthDataType, PermissionState> permissions,
    bool healthConnectAvailable,
  });
}

/// @nodoc
class __$$HealthPermissionStatusImplCopyWithImpl<$Res>
    extends
        _$HealthPermissionStatusCopyWithImpl<$Res, _$HealthPermissionStatusImpl>
    implements _$$HealthPermissionStatusImplCopyWith<$Res> {
  __$$HealthPermissionStatusImplCopyWithImpl(
    _$HealthPermissionStatusImpl _value,
    $Res Function(_$HealthPermissionStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HealthPermissionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? permissions = null,
    Object? healthConnectAvailable = null,
  }) {
    return _then(
      _$HealthPermissionStatusImpl(
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as Map<HealthDataType, PermissionState>,
        healthConnectAvailable: null == healthConnectAvailable
            ? _value.healthConnectAvailable
            : healthConnectAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$HealthPermissionStatusImpl implements _HealthPermissionStatus {
  const _$HealthPermissionStatusImpl({
    required final Map<HealthDataType, PermissionState> permissions,
    this.healthConnectAvailable = false,
  }) : _permissions = permissions;

  /// Map of permission states per data type
  /// Key: HealthDataType (workout, bodyWeight, etc.)
  /// Value: PermissionState (authorized, denied, etc.)
  final Map<HealthDataType, PermissionState> _permissions;

  /// Map of permission states per data type
  /// Key: HealthDataType (workout, bodyWeight, etc.)
  /// Value: PermissionState (authorized, denied, etc.)
  @override
  Map<HealthDataType, PermissionState> get permissions {
    if (_permissions is EqualUnmodifiableMapView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_permissions);
  }

  /// Android-only: Whether Health Connect is installed and available
  /// - iOS: Always false (uses HealthKit natively)
  /// - Android 14+: True if Health Connect app installed
  @override
  @JsonKey()
  final bool healthConnectAvailable;

  @override
  String toString() {
    return 'HealthPermissionStatus(permissions: $permissions, healthConnectAvailable: $healthConnectAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthPermissionStatusImpl &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            (identical(other.healthConnectAvailable, healthConnectAvailable) ||
                other.healthConnectAvailable == healthConnectAvailable));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_permissions),
    healthConnectAvailable,
  );

  /// Create a copy of HealthPermissionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthPermissionStatusImplCopyWith<_$HealthPermissionStatusImpl>
  get copyWith =>
      __$$HealthPermissionStatusImplCopyWithImpl<_$HealthPermissionStatusImpl>(
        this,
        _$identity,
      );
}

abstract class _HealthPermissionStatus implements HealthPermissionStatus {
  const factory _HealthPermissionStatus({
    required final Map<HealthDataType, PermissionState> permissions,
    final bool healthConnectAvailable,
  }) = _$HealthPermissionStatusImpl;

  /// Map of permission states per data type
  /// Key: HealthDataType (workout, bodyWeight, etc.)
  /// Value: PermissionState (authorized, denied, etc.)
  @override
  Map<HealthDataType, PermissionState> get permissions;

  /// Android-only: Whether Health Connect is installed and available
  /// - iOS: Always false (uses HealthKit natively)
  /// - Android 14+: True if Health Connect app installed
  @override
  bool get healthConnectAvailable;

  /// Create a copy of HealthPermissionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthPermissionStatusImplCopyWith<_$HealthPermissionStatusImpl>
  get copyWith => throw _privateConstructorUsedError;
}
