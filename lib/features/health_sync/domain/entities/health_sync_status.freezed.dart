// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HealthSyncStatus {

/// The type of health data this status represents
 HealthDataType get dataType;/// Timestamp of the last sync attempt (null if never synced)
 DateTime? get lastSyncTime;/// Result of the last sync operation
 SyncResult get lastResult;/// Number of retry attempts (0-3, exponential backoff)
/// - 0: No retries
/// - 1: First retry (1h delay)
/// - 2: Second retry (4h delay)
/// - 3: Third retry (24h delay)
 int get retryCount;/// Error message from last failed sync (null if no error)
 String? get errorMessage;
/// Create a copy of HealthSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthSyncStatusCopyWith<HealthSyncStatus> get copyWith => _$HealthSyncStatusCopyWithImpl<HealthSyncStatus>(this as HealthSyncStatus, _$identity);

  /// Serializes this HealthSyncStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthSyncStatus&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.lastSyncTime, lastSyncTime) || other.lastSyncTime == lastSyncTime)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dataType,lastSyncTime,lastResult,retryCount,errorMessage);

@override
String toString() {
  return 'HealthSyncStatus(dataType: $dataType, lastSyncTime: $lastSyncTime, lastResult: $lastResult, retryCount: $retryCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $HealthSyncStatusCopyWith<$Res>  {
  factory $HealthSyncStatusCopyWith(HealthSyncStatus value, $Res Function(HealthSyncStatus) _then) = _$HealthSyncStatusCopyWithImpl;
@useResult
$Res call({
 HealthDataType dataType, DateTime? lastSyncTime, SyncResult lastResult, int retryCount, String? errorMessage
});




}
/// @nodoc
class _$HealthSyncStatusCopyWithImpl<$Res>
    implements $HealthSyncStatusCopyWith<$Res> {
  _$HealthSyncStatusCopyWithImpl(this._self, this._then);

  final HealthSyncStatus _self;
  final $Res Function(HealthSyncStatus) _then;

/// Create a copy of HealthSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dataType = null,Object? lastSyncTime = freezed,Object? lastResult = null,Object? retryCount = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as HealthDataType,lastSyncTime: freezed == lastSyncTime ? _self.lastSyncTime : lastSyncTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lastResult: null == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as SyncResult,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthSyncStatus].
extension HealthSyncStatusPatterns on HealthSyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthSyncStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthSyncStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthSyncStatus value)  $default,){
final _that = this;
switch (_that) {
case _HealthSyncStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthSyncStatus value)?  $default,){
final _that = this;
switch (_that) {
case _HealthSyncStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HealthDataType dataType,  DateTime? lastSyncTime,  SyncResult lastResult,  int retryCount,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthSyncStatus() when $default != null:
return $default(_that.dataType,_that.lastSyncTime,_that.lastResult,_that.retryCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HealthDataType dataType,  DateTime? lastSyncTime,  SyncResult lastResult,  int retryCount,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HealthSyncStatus():
return $default(_that.dataType,_that.lastSyncTime,_that.lastResult,_that.retryCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HealthDataType dataType,  DateTime? lastSyncTime,  SyncResult lastResult,  int retryCount,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HealthSyncStatus() when $default != null:
return $default(_that.dataType,_that.lastSyncTime,_that.lastResult,_that.retryCount,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HealthSyncStatus implements HealthSyncStatus {
  const _HealthSyncStatus({required this.dataType, required this.lastSyncTime, required this.lastResult, this.retryCount = 0, this.errorMessage});
  factory _HealthSyncStatus.fromJson(Map<String, dynamic> json) => _$HealthSyncStatusFromJson(json);

/// The type of health data this status represents
@override final  HealthDataType dataType;
/// Timestamp of the last sync attempt (null if never synced)
@override final  DateTime? lastSyncTime;
/// Result of the last sync operation
@override final  SyncResult lastResult;
/// Number of retry attempts (0-3, exponential backoff)
/// - 0: No retries
/// - 1: First retry (1h delay)
/// - 2: Second retry (4h delay)
/// - 3: Third retry (24h delay)
@override@JsonKey() final  int retryCount;
/// Error message from last failed sync (null if no error)
@override final  String? errorMessage;

/// Create a copy of HealthSyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthSyncStatusCopyWith<_HealthSyncStatus> get copyWith => __$HealthSyncStatusCopyWithImpl<_HealthSyncStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HealthSyncStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthSyncStatus&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.lastSyncTime, lastSyncTime) || other.lastSyncTime == lastSyncTime)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dataType,lastSyncTime,lastResult,retryCount,errorMessage);

@override
String toString() {
  return 'HealthSyncStatus(dataType: $dataType, lastSyncTime: $lastSyncTime, lastResult: $lastResult, retryCount: $retryCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HealthSyncStatusCopyWith<$Res> implements $HealthSyncStatusCopyWith<$Res> {
  factory _$HealthSyncStatusCopyWith(_HealthSyncStatus value, $Res Function(_HealthSyncStatus) _then) = __$HealthSyncStatusCopyWithImpl;
@override @useResult
$Res call({
 HealthDataType dataType, DateTime? lastSyncTime, SyncResult lastResult, int retryCount, String? errorMessage
});




}
/// @nodoc
class __$HealthSyncStatusCopyWithImpl<$Res>
    implements _$HealthSyncStatusCopyWith<$Res> {
  __$HealthSyncStatusCopyWithImpl(this._self, this._then);

  final _HealthSyncStatus _self;
  final $Res Function(_HealthSyncStatus) _then;

/// Create a copy of HealthSyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dataType = null,Object? lastSyncTime = freezed,Object? lastResult = null,Object? retryCount = null,Object? errorMessage = freezed,}) {
  return _then(_HealthSyncStatus(
dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as HealthDataType,lastSyncTime: freezed == lastSyncTime ? _self.lastSyncTime : lastSyncTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lastResult: null == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as SyncResult,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
