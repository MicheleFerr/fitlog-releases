// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queued_sync.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QueuedSync {

/// Unique ID for this sync attempt
@HiveField(0) String get id;/// Timestamp when sync failed
@HiveField(1) DateTime get timestamp;/// Health metrics that failed to sync
@HiveField(2) Map<String, dynamic> get healthMetrics;/// Error message (for logging)
@HiveField(3) String get error;/// Number of retry attempts (0 = first attempt)
@HiveField(4) int get retryCount;/// Is this sync retryable (false for rate limit, quota errors)
@HiveField(5) bool get retryable;/// Next retry time (calculated with exponential backoff)
@HiveField(6) DateTime? get nextRetryAt;
/// Create a copy of QueuedSync
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueuedSyncCopyWith<QueuedSync> get copyWith => _$QueuedSyncCopyWithImpl<QueuedSync>(this as QueuedSync, _$identity);

  /// Serializes this QueuedSync to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueuedSync&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.healthMetrics, healthMetrics)&&(identical(other.error, error) || other.error == error)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.retryable, retryable) || other.retryable == retryable)&&(identical(other.nextRetryAt, nextRetryAt) || other.nextRetryAt == nextRetryAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,const DeepCollectionEquality().hash(healthMetrics),error,retryCount,retryable,nextRetryAt);

@override
String toString() {
  return 'QueuedSync(id: $id, timestamp: $timestamp, healthMetrics: $healthMetrics, error: $error, retryCount: $retryCount, retryable: $retryable, nextRetryAt: $nextRetryAt)';
}


}

/// @nodoc
abstract mixin class $QueuedSyncCopyWith<$Res>  {
  factory $QueuedSyncCopyWith(QueuedSync value, $Res Function(QueuedSync) _then) = _$QueuedSyncCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) DateTime timestamp,@HiveField(2) Map<String, dynamic> healthMetrics,@HiveField(3) String error,@HiveField(4) int retryCount,@HiveField(5) bool retryable,@HiveField(6) DateTime? nextRetryAt
});




}
/// @nodoc
class _$QueuedSyncCopyWithImpl<$Res>
    implements $QueuedSyncCopyWith<$Res> {
  _$QueuedSyncCopyWithImpl(this._self, this._then);

  final QueuedSync _self;
  final $Res Function(QueuedSync) _then;

/// Create a copy of QueuedSync
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? timestamp = null,Object? healthMetrics = null,Object? error = null,Object? retryCount = null,Object? retryable = null,Object? nextRetryAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,healthMetrics: null == healthMetrics ? _self.healthMetrics : healthMetrics // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,retryable: null == retryable ? _self.retryable : retryable // ignore: cast_nullable_to_non_nullable
as bool,nextRetryAt: freezed == nextRetryAt ? _self.nextRetryAt : nextRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [QueuedSync].
extension QueuedSyncPatterns on QueuedSync {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueuedSync value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueuedSync() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueuedSync value)  $default,){
final _that = this;
switch (_that) {
case _QueuedSync():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueuedSync value)?  $default,){
final _that = this;
switch (_that) {
case _QueuedSync() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  DateTime timestamp, @HiveField(2)  Map<String, dynamic> healthMetrics, @HiveField(3)  String error, @HiveField(4)  int retryCount, @HiveField(5)  bool retryable, @HiveField(6)  DateTime? nextRetryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueuedSync() when $default != null:
return $default(_that.id,_that.timestamp,_that.healthMetrics,_that.error,_that.retryCount,_that.retryable,_that.nextRetryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  DateTime timestamp, @HiveField(2)  Map<String, dynamic> healthMetrics, @HiveField(3)  String error, @HiveField(4)  int retryCount, @HiveField(5)  bool retryable, @HiveField(6)  DateTime? nextRetryAt)  $default,) {final _that = this;
switch (_that) {
case _QueuedSync():
return $default(_that.id,_that.timestamp,_that.healthMetrics,_that.error,_that.retryCount,_that.retryable,_that.nextRetryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  DateTime timestamp, @HiveField(2)  Map<String, dynamic> healthMetrics, @HiveField(3)  String error, @HiveField(4)  int retryCount, @HiveField(5)  bool retryable, @HiveField(6)  DateTime? nextRetryAt)?  $default,) {final _that = this;
switch (_that) {
case _QueuedSync() when $default != null:
return $default(_that.id,_that.timestamp,_that.healthMetrics,_that.error,_that.retryCount,_that.retryable,_that.nextRetryAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QueuedSync implements QueuedSync {
  const _QueuedSync({@HiveField(0) required this.id, @HiveField(1) required this.timestamp, @HiveField(2) required final  Map<String, dynamic> healthMetrics, @HiveField(3) required this.error, @HiveField(4) this.retryCount = 0, @HiveField(5) this.retryable = true, @HiveField(6) this.nextRetryAt}): _healthMetrics = healthMetrics;
  factory _QueuedSync.fromJson(Map<String, dynamic> json) => _$QueuedSyncFromJson(json);

/// Unique ID for this sync attempt
@override@HiveField(0) final  String id;
/// Timestamp when sync failed
@override@HiveField(1) final  DateTime timestamp;
/// Health metrics that failed to sync
 final  Map<String, dynamic> _healthMetrics;
/// Health metrics that failed to sync
@override@HiveField(2) Map<String, dynamic> get healthMetrics {
  if (_healthMetrics is EqualUnmodifiableMapView) return _healthMetrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_healthMetrics);
}

/// Error message (for logging)
@override@HiveField(3) final  String error;
/// Number of retry attempts (0 = first attempt)
@override@JsonKey()@HiveField(4) final  int retryCount;
/// Is this sync retryable (false for rate limit, quota errors)
@override@JsonKey()@HiveField(5) final  bool retryable;
/// Next retry time (calculated with exponential backoff)
@override@HiveField(6) final  DateTime? nextRetryAt;

/// Create a copy of QueuedSync
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueuedSyncCopyWith<_QueuedSync> get copyWith => __$QueuedSyncCopyWithImpl<_QueuedSync>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueuedSyncToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueuedSync&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._healthMetrics, _healthMetrics)&&(identical(other.error, error) || other.error == error)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.retryable, retryable) || other.retryable == retryable)&&(identical(other.nextRetryAt, nextRetryAt) || other.nextRetryAt == nextRetryAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,const DeepCollectionEquality().hash(_healthMetrics),error,retryCount,retryable,nextRetryAt);

@override
String toString() {
  return 'QueuedSync(id: $id, timestamp: $timestamp, healthMetrics: $healthMetrics, error: $error, retryCount: $retryCount, retryable: $retryable, nextRetryAt: $nextRetryAt)';
}


}

/// @nodoc
abstract mixin class _$QueuedSyncCopyWith<$Res> implements $QueuedSyncCopyWith<$Res> {
  factory _$QueuedSyncCopyWith(_QueuedSync value, $Res Function(_QueuedSync) _then) = __$QueuedSyncCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) DateTime timestamp,@HiveField(2) Map<String, dynamic> healthMetrics,@HiveField(3) String error,@HiveField(4) int retryCount,@HiveField(5) bool retryable,@HiveField(6) DateTime? nextRetryAt
});




}
/// @nodoc
class __$QueuedSyncCopyWithImpl<$Res>
    implements _$QueuedSyncCopyWith<$Res> {
  __$QueuedSyncCopyWithImpl(this._self, this._then);

  final _QueuedSync _self;
  final $Res Function(_QueuedSync) _then;

/// Create a copy of QueuedSync
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? timestamp = null,Object? healthMetrics = null,Object? error = null,Object? retryCount = null,Object? retryable = null,Object? nextRetryAt = freezed,}) {
  return _then(_QueuedSync(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,healthMetrics: null == healthMetrics ? _self._healthMetrics : healthMetrics // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,retryable: null == retryable ? _self.retryable : retryable // ignore: cast_nullable_to_non_nullable
as bool,nextRetryAt: freezed == nextRetryAt ? _self.nextRetryAt : nextRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
