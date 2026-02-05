// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentSyncStatus {

 String get localVersion;// Current cached version
 String get remoteVersion;// Latest remote version
 DateTime get lastSyncAt; int get documentsCount; bool get isSyncing; String? get error;
/// Create a copy of DocumentSyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentSyncStatusCopyWith<DocumentSyncStatus> get copyWith => _$DocumentSyncStatusCopyWithImpl<DocumentSyncStatus>(this as DocumentSyncStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentSyncStatus&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.remoteVersion, remoteVersion) || other.remoteVersion == remoteVersion)&&(identical(other.lastSyncAt, lastSyncAt) || other.lastSyncAt == lastSyncAt)&&(identical(other.documentsCount, documentsCount) || other.documentsCount == documentsCount)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,localVersion,remoteVersion,lastSyncAt,documentsCount,isSyncing,error);

@override
String toString() {
  return 'DocumentSyncStatus(localVersion: $localVersion, remoteVersion: $remoteVersion, lastSyncAt: $lastSyncAt, documentsCount: $documentsCount, isSyncing: $isSyncing, error: $error)';
}


}

/// @nodoc
abstract mixin class $DocumentSyncStatusCopyWith<$Res>  {
  factory $DocumentSyncStatusCopyWith(DocumentSyncStatus value, $Res Function(DocumentSyncStatus) _then) = _$DocumentSyncStatusCopyWithImpl;
@useResult
$Res call({
 String localVersion, String remoteVersion, DateTime lastSyncAt, int documentsCount, bool isSyncing, String? error
});




}
/// @nodoc
class _$DocumentSyncStatusCopyWithImpl<$Res>
    implements $DocumentSyncStatusCopyWith<$Res> {
  _$DocumentSyncStatusCopyWithImpl(this._self, this._then);

  final DocumentSyncStatus _self;
  final $Res Function(DocumentSyncStatus) _then;

/// Create a copy of DocumentSyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localVersion = null,Object? remoteVersion = null,Object? lastSyncAt = null,Object? documentsCount = null,Object? isSyncing = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as String,remoteVersion: null == remoteVersion ? _self.remoteVersion : remoteVersion // ignore: cast_nullable_to_non_nullable
as String,lastSyncAt: null == lastSyncAt ? _self.lastSyncAt : lastSyncAt // ignore: cast_nullable_to_non_nullable
as DateTime,documentsCount: null == documentsCount ? _self.documentsCount : documentsCount // ignore: cast_nullable_to_non_nullable
as int,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentSyncStatus].
extension DocumentSyncStatusPatterns on DocumentSyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentSyncStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentSyncStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentSyncStatus value)  $default,){
final _that = this;
switch (_that) {
case _DocumentSyncStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentSyncStatus value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentSyncStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String localVersion,  String remoteVersion,  DateTime lastSyncAt,  int documentsCount,  bool isSyncing,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentSyncStatus() when $default != null:
return $default(_that.localVersion,_that.remoteVersion,_that.lastSyncAt,_that.documentsCount,_that.isSyncing,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String localVersion,  String remoteVersion,  DateTime lastSyncAt,  int documentsCount,  bool isSyncing,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DocumentSyncStatus():
return $default(_that.localVersion,_that.remoteVersion,_that.lastSyncAt,_that.documentsCount,_that.isSyncing,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String localVersion,  String remoteVersion,  DateTime lastSyncAt,  int documentsCount,  bool isSyncing,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DocumentSyncStatus() when $default != null:
return $default(_that.localVersion,_that.remoteVersion,_that.lastSyncAt,_that.documentsCount,_that.isSyncing,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentSyncStatus extends DocumentSyncStatus {
  const _DocumentSyncStatus({required this.localVersion, required this.remoteVersion, required this.lastSyncAt, required this.documentsCount, required this.isSyncing, this.error}): super._();
  

@override final  String localVersion;
// Current cached version
@override final  String remoteVersion;
// Latest remote version
@override final  DateTime lastSyncAt;
@override final  int documentsCount;
@override final  bool isSyncing;
@override final  String? error;

/// Create a copy of DocumentSyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentSyncStatusCopyWith<_DocumentSyncStatus> get copyWith => __$DocumentSyncStatusCopyWithImpl<_DocumentSyncStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentSyncStatus&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.remoteVersion, remoteVersion) || other.remoteVersion == remoteVersion)&&(identical(other.lastSyncAt, lastSyncAt) || other.lastSyncAt == lastSyncAt)&&(identical(other.documentsCount, documentsCount) || other.documentsCount == documentsCount)&&(identical(other.isSyncing, isSyncing) || other.isSyncing == isSyncing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,localVersion,remoteVersion,lastSyncAt,documentsCount,isSyncing,error);

@override
String toString() {
  return 'DocumentSyncStatus(localVersion: $localVersion, remoteVersion: $remoteVersion, lastSyncAt: $lastSyncAt, documentsCount: $documentsCount, isSyncing: $isSyncing, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DocumentSyncStatusCopyWith<$Res> implements $DocumentSyncStatusCopyWith<$Res> {
  factory _$DocumentSyncStatusCopyWith(_DocumentSyncStatus value, $Res Function(_DocumentSyncStatus) _then) = __$DocumentSyncStatusCopyWithImpl;
@override @useResult
$Res call({
 String localVersion, String remoteVersion, DateTime lastSyncAt, int documentsCount, bool isSyncing, String? error
});




}
/// @nodoc
class __$DocumentSyncStatusCopyWithImpl<$Res>
    implements _$DocumentSyncStatusCopyWith<$Res> {
  __$DocumentSyncStatusCopyWithImpl(this._self, this._then);

  final _DocumentSyncStatus _self;
  final $Res Function(_DocumentSyncStatus) _then;

/// Create a copy of DocumentSyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localVersion = null,Object? remoteVersion = null,Object? lastSyncAt = null,Object? documentsCount = null,Object? isSyncing = null,Object? error = freezed,}) {
  return _then(_DocumentSyncStatus(
localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as String,remoteVersion: null == remoteVersion ? _self.remoteVersion : remoteVersion // ignore: cast_nullable_to_non_nullable
as String,lastSyncAt: null == lastSyncAt ? _self.lastSyncAt : lastSyncAt // ignore: cast_nullable_to_non_nullable
as DateTime,documentsCount: null == documentsCount ? _self.documentsCount : documentsCount // ignore: cast_nullable_to_non_nullable
as int,isSyncing: null == isSyncing ? _self.isSyncing : isSyncing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
