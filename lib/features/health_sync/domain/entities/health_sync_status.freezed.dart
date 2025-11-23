// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthSyncStatus _$HealthSyncStatusFromJson(Map<String, dynamic> json) {
  return _HealthSyncStatus.fromJson(json);
}

/// @nodoc
mixin _$HealthSyncStatus {
  /// The type of health data this status represents
  HealthDataType get dataType => throw _privateConstructorUsedError;

  /// Timestamp of the last sync attempt (null if never synced)
  DateTime? get lastSyncTime => throw _privateConstructorUsedError;

  /// Result of the last sync operation
  SyncResult get lastResult => throw _privateConstructorUsedError;

  /// Number of retry attempts (0-3, exponential backoff)
  /// - 0: No retries
  /// - 1: First retry (1h delay)
  /// - 2: Second retry (4h delay)
  /// - 3: Third retry (24h delay)
  int get retryCount => throw _privateConstructorUsedError;

  /// Error message from last failed sync (null if no error)
  String? get errorMessage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HealthSyncStatusCopyWith<HealthSyncStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthSyncStatusCopyWith<$Res> {
  factory $HealthSyncStatusCopyWith(
          HealthSyncStatus value, $Res Function(HealthSyncStatus) then) =
      _$HealthSyncStatusCopyWithImpl<$Res, HealthSyncStatus>;
  @useResult
  $Res call(
      {HealthDataType dataType,
      DateTime? lastSyncTime,
      SyncResult lastResult,
      int retryCount,
      String? errorMessage});
}

/// @nodoc
class _$HealthSyncStatusCopyWithImpl<$Res, $Val extends HealthSyncStatus>
    implements $HealthSyncStatusCopyWith<$Res> {
  _$HealthSyncStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dataType = null,
    Object? lastSyncTime = freezed,
    Object? lastResult = null,
    Object? retryCount = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      dataType: null == dataType
          ? _value.dataType
          : dataType // ignore: cast_nullable_to_non_nullable
              as HealthDataType,
      lastSyncTime: freezed == lastSyncTime
          ? _value.lastSyncTime
          : lastSyncTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastResult: null == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SyncResult,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthSyncStatusImplCopyWith<$Res>
    implements $HealthSyncStatusCopyWith<$Res> {
  factory _$$HealthSyncStatusImplCopyWith(_$HealthSyncStatusImpl value,
          $Res Function(_$HealthSyncStatusImpl) then) =
      __$$HealthSyncStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HealthDataType dataType,
      DateTime? lastSyncTime,
      SyncResult lastResult,
      int retryCount,
      String? errorMessage});
}

/// @nodoc
class __$$HealthSyncStatusImplCopyWithImpl<$Res>
    extends _$HealthSyncStatusCopyWithImpl<$Res, _$HealthSyncStatusImpl>
    implements _$$HealthSyncStatusImplCopyWith<$Res> {
  __$$HealthSyncStatusImplCopyWithImpl(_$HealthSyncStatusImpl _value,
      $Res Function(_$HealthSyncStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dataType = null,
    Object? lastSyncTime = freezed,
    Object? lastResult = null,
    Object? retryCount = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$HealthSyncStatusImpl(
      dataType: null == dataType
          ? _value.dataType
          : dataType // ignore: cast_nullable_to_non_nullable
              as HealthDataType,
      lastSyncTime: freezed == lastSyncTime
          ? _value.lastSyncTime
          : lastSyncTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastResult: null == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SyncResult,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthSyncStatusImpl implements _HealthSyncStatus {
  const _$HealthSyncStatusImpl(
      {required this.dataType,
      required this.lastSyncTime,
      required this.lastResult,
      this.retryCount = 0,
      this.errorMessage});

  factory _$HealthSyncStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthSyncStatusImplFromJson(json);

  /// The type of health data this status represents
  @override
  final HealthDataType dataType;

  /// Timestamp of the last sync attempt (null if never synced)
  @override
  final DateTime? lastSyncTime;

  /// Result of the last sync operation
  @override
  final SyncResult lastResult;

  /// Number of retry attempts (0-3, exponential backoff)
  /// - 0: No retries
  /// - 1: First retry (1h delay)
  /// - 2: Second retry (4h delay)
  /// - 3: Third retry (24h delay)
  @override
  @JsonKey()
  final int retryCount;

  /// Error message from last failed sync (null if no error)
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'HealthSyncStatus(dataType: $dataType, lastSyncTime: $lastSyncTime, lastResult: $lastResult, retryCount: $retryCount, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthSyncStatusImpl &&
            (identical(other.dataType, dataType) ||
                other.dataType == dataType) &&
            (identical(other.lastSyncTime, lastSyncTime) ||
                other.lastSyncTime == lastSyncTime) &&
            (identical(other.lastResult, lastResult) ||
                other.lastResult == lastResult) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, dataType, lastSyncTime,
      lastResult, retryCount, errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthSyncStatusImplCopyWith<_$HealthSyncStatusImpl> get copyWith =>
      __$$HealthSyncStatusImplCopyWithImpl<_$HealthSyncStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthSyncStatusImplToJson(
      this,
    );
  }
}

abstract class _HealthSyncStatus implements HealthSyncStatus {
  const factory _HealthSyncStatus(
      {required final HealthDataType dataType,
      required final DateTime? lastSyncTime,
      required final SyncResult lastResult,
      final int retryCount,
      final String? errorMessage}) = _$HealthSyncStatusImpl;

  factory _HealthSyncStatus.fromJson(Map<String, dynamic> json) =
      _$HealthSyncStatusImpl.fromJson;

  @override

  /// The type of health data this status represents
  HealthDataType get dataType;
  @override

  /// Timestamp of the last sync attempt (null if never synced)
  DateTime? get lastSyncTime;
  @override

  /// Result of the last sync operation
  SyncResult get lastResult;
  @override

  /// Number of retry attempts (0-3, exponential backoff)
  /// - 0: No retries
  /// - 1: First retry (1h delay)
  /// - 2: Second retry (4h delay)
  /// - 3: Third retry (24h delay)
  int get retryCount;
  @override

  /// Error message from last failed sync (null if no error)
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$HealthSyncStatusImplCopyWith<_$HealthSyncStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
