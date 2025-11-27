// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationRecord {

/// Unique identifier
 String get id;/// Type of notification sent
 NotificationType get type;/// When the notification was scheduled/sent
 DateTime get sentAt;/// When the notification was opened (null if not opened)
 DateTime? get openedAt;/// The message that was sent (for rotation tracking)
 String get messageKey;/// Additional context (e.g., exercise name for PR)
 String? get context;/// For inactivity: which day in sequence (3, 7, or 14)
 int? get inactivityDay;/// Whether this notification was canceled before delivery
 bool get wasCanceled;
/// Create a copy of NotificationRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationRecordCopyWith<NotificationRecord> get copyWith => _$NotificationRecordCopyWithImpl<NotificationRecord>(this as NotificationRecord, _$identity);

  /// Serializes this NotificationRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&(identical(other.context, context) || other.context == context)&&(identical(other.inactivityDay, inactivityDay) || other.inactivityDay == inactivityDay)&&(identical(other.wasCanceled, wasCanceled) || other.wasCanceled == wasCanceled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,sentAt,openedAt,messageKey,context,inactivityDay,wasCanceled);

@override
String toString() {
  return 'NotificationRecord(id: $id, type: $type, sentAt: $sentAt, openedAt: $openedAt, messageKey: $messageKey, context: $context, inactivityDay: $inactivityDay, wasCanceled: $wasCanceled)';
}


}

/// @nodoc
abstract mixin class $NotificationRecordCopyWith<$Res>  {
  factory $NotificationRecordCopyWith(NotificationRecord value, $Res Function(NotificationRecord) _then) = _$NotificationRecordCopyWithImpl;
@useResult
$Res call({
 String id, NotificationType type, DateTime sentAt, DateTime? openedAt, String messageKey, String? context, int? inactivityDay, bool wasCanceled
});




}
/// @nodoc
class _$NotificationRecordCopyWithImpl<$Res>
    implements $NotificationRecordCopyWith<$Res> {
  _$NotificationRecordCopyWithImpl(this._self, this._then);

  final NotificationRecord _self;
  final $Res Function(NotificationRecord) _then;

/// Create a copy of NotificationRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? sentAt = null,Object? openedAt = freezed,Object? messageKey = null,Object? context = freezed,Object? inactivityDay = freezed,Object? wasCanceled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,openedAt: freezed == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,inactivityDay: freezed == inactivityDay ? _self.inactivityDay : inactivityDay // ignore: cast_nullable_to_non_nullable
as int?,wasCanceled: null == wasCanceled ? _self.wasCanceled : wasCanceled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationRecord].
extension NotificationRecordPatterns on NotificationRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationRecord value)  $default,){
final _that = this;
switch (_that) {
case _NotificationRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationRecord value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  NotificationType type,  DateTime sentAt,  DateTime? openedAt,  String messageKey,  String? context,  int? inactivityDay,  bool wasCanceled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationRecord() when $default != null:
return $default(_that.id,_that.type,_that.sentAt,_that.openedAt,_that.messageKey,_that.context,_that.inactivityDay,_that.wasCanceled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  NotificationType type,  DateTime sentAt,  DateTime? openedAt,  String messageKey,  String? context,  int? inactivityDay,  bool wasCanceled)  $default,) {final _that = this;
switch (_that) {
case _NotificationRecord():
return $default(_that.id,_that.type,_that.sentAt,_that.openedAt,_that.messageKey,_that.context,_that.inactivityDay,_that.wasCanceled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  NotificationType type,  DateTime sentAt,  DateTime? openedAt,  String messageKey,  String? context,  int? inactivityDay,  bool wasCanceled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationRecord() when $default != null:
return $default(_that.id,_that.type,_that.sentAt,_that.openedAt,_that.messageKey,_that.context,_that.inactivityDay,_that.wasCanceled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationRecord extends NotificationRecord {
  const _NotificationRecord({required this.id, required this.type, required this.sentAt, this.openedAt, required this.messageKey, this.context, this.inactivityDay, this.wasCanceled = false}): super._();
  factory _NotificationRecord.fromJson(Map<String, dynamic> json) => _$NotificationRecordFromJson(json);

/// Unique identifier
@override final  String id;
/// Type of notification sent
@override final  NotificationType type;
/// When the notification was scheduled/sent
@override final  DateTime sentAt;
/// When the notification was opened (null if not opened)
@override final  DateTime? openedAt;
/// The message that was sent (for rotation tracking)
@override final  String messageKey;
/// Additional context (e.g., exercise name for PR)
@override final  String? context;
/// For inactivity: which day in sequence (3, 7, or 14)
@override final  int? inactivityDay;
/// Whether this notification was canceled before delivery
@override@JsonKey() final  bool wasCanceled;

/// Create a copy of NotificationRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationRecordCopyWith<_NotificationRecord> get copyWith => __$NotificationRecordCopyWithImpl<_NotificationRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&(identical(other.context, context) || other.context == context)&&(identical(other.inactivityDay, inactivityDay) || other.inactivityDay == inactivityDay)&&(identical(other.wasCanceled, wasCanceled) || other.wasCanceled == wasCanceled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,sentAt,openedAt,messageKey,context,inactivityDay,wasCanceled);

@override
String toString() {
  return 'NotificationRecord(id: $id, type: $type, sentAt: $sentAt, openedAt: $openedAt, messageKey: $messageKey, context: $context, inactivityDay: $inactivityDay, wasCanceled: $wasCanceled)';
}


}

/// @nodoc
abstract mixin class _$NotificationRecordCopyWith<$Res> implements $NotificationRecordCopyWith<$Res> {
  factory _$NotificationRecordCopyWith(_NotificationRecord value, $Res Function(_NotificationRecord) _then) = __$NotificationRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, NotificationType type, DateTime sentAt, DateTime? openedAt, String messageKey, String? context, int? inactivityDay, bool wasCanceled
});




}
/// @nodoc
class __$NotificationRecordCopyWithImpl<$Res>
    implements _$NotificationRecordCopyWith<$Res> {
  __$NotificationRecordCopyWithImpl(this._self, this._then);

  final _NotificationRecord _self;
  final $Res Function(_NotificationRecord) _then;

/// Create a copy of NotificationRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? sentAt = null,Object? openedAt = freezed,Object? messageKey = null,Object? context = freezed,Object? inactivityDay = freezed,Object? wasCanceled = null,}) {
  return _then(_NotificationRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,openedAt: freezed == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as String?,inactivityDay: freezed == inactivityDay ? _self.inactivityDay : inactivityDay // ignore: cast_nullable_to_non_nullable
as int?,wasCanceled: null == wasCanceled ? _self.wasCanceled : wasCanceled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$NotificationStats {

/// Total notifications sent
 int get totalSent;/// How many were opened
 int get totalOpened;/// How many consecutive ignores (for stop-after-ignore logic)
 int get consecutiveIgnores;/// Last notification sent timestamp
 DateTime? get lastSentAt;/// Last message key used (for rotation)
 String? get lastMessageKey;
/// Create a copy of NotificationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationStatsCopyWith<NotificationStats> get copyWith => _$NotificationStatsCopyWithImpl<NotificationStats>(this as NotificationStats, _$identity);

  /// Serializes this NotificationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationStats&&(identical(other.totalSent, totalSent) || other.totalSent == totalSent)&&(identical(other.totalOpened, totalOpened) || other.totalOpened == totalOpened)&&(identical(other.consecutiveIgnores, consecutiveIgnores) || other.consecutiveIgnores == consecutiveIgnores)&&(identical(other.lastSentAt, lastSentAt) || other.lastSentAt == lastSentAt)&&(identical(other.lastMessageKey, lastMessageKey) || other.lastMessageKey == lastMessageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSent,totalOpened,consecutiveIgnores,lastSentAt,lastMessageKey);

@override
String toString() {
  return 'NotificationStats(totalSent: $totalSent, totalOpened: $totalOpened, consecutiveIgnores: $consecutiveIgnores, lastSentAt: $lastSentAt, lastMessageKey: $lastMessageKey)';
}


}

/// @nodoc
abstract mixin class $NotificationStatsCopyWith<$Res>  {
  factory $NotificationStatsCopyWith(NotificationStats value, $Res Function(NotificationStats) _then) = _$NotificationStatsCopyWithImpl;
@useResult
$Res call({
 int totalSent, int totalOpened, int consecutiveIgnores, DateTime? lastSentAt, String? lastMessageKey
});




}
/// @nodoc
class _$NotificationStatsCopyWithImpl<$Res>
    implements $NotificationStatsCopyWith<$Res> {
  _$NotificationStatsCopyWithImpl(this._self, this._then);

  final NotificationStats _self;
  final $Res Function(NotificationStats) _then;

/// Create a copy of NotificationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSent = null,Object? totalOpened = null,Object? consecutiveIgnores = null,Object? lastSentAt = freezed,Object? lastMessageKey = freezed,}) {
  return _then(_self.copyWith(
totalSent: null == totalSent ? _self.totalSent : totalSent // ignore: cast_nullable_to_non_nullable
as int,totalOpened: null == totalOpened ? _self.totalOpened : totalOpened // ignore: cast_nullable_to_non_nullable
as int,consecutiveIgnores: null == consecutiveIgnores ? _self.consecutiveIgnores : consecutiveIgnores // ignore: cast_nullable_to_non_nullable
as int,lastSentAt: freezed == lastSentAt ? _self.lastSentAt : lastSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageKey: freezed == lastMessageKey ? _self.lastMessageKey : lastMessageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationStats].
extension NotificationStatsPatterns on NotificationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationStats value)  $default,){
final _that = this;
switch (_that) {
case _NotificationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationStats value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSent,  int totalOpened,  int consecutiveIgnores,  DateTime? lastSentAt,  String? lastMessageKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationStats() when $default != null:
return $default(_that.totalSent,_that.totalOpened,_that.consecutiveIgnores,_that.lastSentAt,_that.lastMessageKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSent,  int totalOpened,  int consecutiveIgnores,  DateTime? lastSentAt,  String? lastMessageKey)  $default,) {final _that = this;
switch (_that) {
case _NotificationStats():
return $default(_that.totalSent,_that.totalOpened,_that.consecutiveIgnores,_that.lastSentAt,_that.lastMessageKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSent,  int totalOpened,  int consecutiveIgnores,  DateTime? lastSentAt,  String? lastMessageKey)?  $default,) {final _that = this;
switch (_that) {
case _NotificationStats() when $default != null:
return $default(_that.totalSent,_that.totalOpened,_that.consecutiveIgnores,_that.lastSentAt,_that.lastMessageKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationStats extends NotificationStats {
  const _NotificationStats({required this.totalSent, required this.totalOpened, required this.consecutiveIgnores, this.lastSentAt, this.lastMessageKey}): super._();
  factory _NotificationStats.fromJson(Map<String, dynamic> json) => _$NotificationStatsFromJson(json);

/// Total notifications sent
@override final  int totalSent;
/// How many were opened
@override final  int totalOpened;
/// How many consecutive ignores (for stop-after-ignore logic)
@override final  int consecutiveIgnores;
/// Last notification sent timestamp
@override final  DateTime? lastSentAt;
/// Last message key used (for rotation)
@override final  String? lastMessageKey;

/// Create a copy of NotificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationStatsCopyWith<_NotificationStats> get copyWith => __$NotificationStatsCopyWithImpl<_NotificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationStats&&(identical(other.totalSent, totalSent) || other.totalSent == totalSent)&&(identical(other.totalOpened, totalOpened) || other.totalOpened == totalOpened)&&(identical(other.consecutiveIgnores, consecutiveIgnores) || other.consecutiveIgnores == consecutiveIgnores)&&(identical(other.lastSentAt, lastSentAt) || other.lastSentAt == lastSentAt)&&(identical(other.lastMessageKey, lastMessageKey) || other.lastMessageKey == lastMessageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSent,totalOpened,consecutiveIgnores,lastSentAt,lastMessageKey);

@override
String toString() {
  return 'NotificationStats(totalSent: $totalSent, totalOpened: $totalOpened, consecutiveIgnores: $consecutiveIgnores, lastSentAt: $lastSentAt, lastMessageKey: $lastMessageKey)';
}


}

/// @nodoc
abstract mixin class _$NotificationStatsCopyWith<$Res> implements $NotificationStatsCopyWith<$Res> {
  factory _$NotificationStatsCopyWith(_NotificationStats value, $Res Function(_NotificationStats) _then) = __$NotificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalSent, int totalOpened, int consecutiveIgnores, DateTime? lastSentAt, String? lastMessageKey
});




}
/// @nodoc
class __$NotificationStatsCopyWithImpl<$Res>
    implements _$NotificationStatsCopyWith<$Res> {
  __$NotificationStatsCopyWithImpl(this._self, this._then);

  final _NotificationStats _self;
  final $Res Function(_NotificationStats) _then;

/// Create a copy of NotificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSent = null,Object? totalOpened = null,Object? consecutiveIgnores = null,Object? lastSentAt = freezed,Object? lastMessageKey = freezed,}) {
  return _then(_NotificationStats(
totalSent: null == totalSent ? _self.totalSent : totalSent // ignore: cast_nullable_to_non_nullable
as int,totalOpened: null == totalOpened ? _self.totalOpened : totalOpened // ignore: cast_nullable_to_non_nullable
as int,consecutiveIgnores: null == consecutiveIgnores ? _self.consecutiveIgnores : consecutiveIgnores // ignore: cast_nullable_to_non_nullable
as int,lastSentAt: freezed == lastSentAt ? _self.lastSentAt : lastSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageKey: freezed == lastMessageKey ? _self.lastMessageKey : lastMessageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
