// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoReminderSettings {

/// Whether reminders are enabled
 bool get isEnabled;/// Selected frequency
 PhotoReminderFrequency get frequency;/// Custom interval in days (used when frequency == custom)
 int get customIntervalDays;/// Preferred reminder time (hour component)
 int get reminderHour;/// Preferred reminder time (minute component)
 int get reminderMinute;/// Whether to include specific pose suggestions in reminder
 bool get suggestPose;/// Last reminder sent timestamp
 DateTime? get lastReminderSent;/// Next scheduled reminder timestamp
 DateTime? get nextReminderScheduled;/// Notification ID for cancellation
 int? get notificationId;/// Anti-spam: consecutive ignores count
 int get consecutiveIgnores;/// Anti-spam: max ignores before auto-disable (0 = no limit)
 int get maxIgnoresBeforeDisable;/// Whether user manually disabled after too many ignores
 bool get disabledByAntiSpam;
/// Create a copy of PhotoReminderSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoReminderSettingsCopyWith<PhotoReminderSettings> get copyWith => _$PhotoReminderSettingsCopyWithImpl<PhotoReminderSettings>(this as PhotoReminderSettings, _$identity);

  /// Serializes this PhotoReminderSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoReminderSettings&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.suggestPose, suggestPose) || other.suggestPose == suggestPose)&&(identical(other.lastReminderSent, lastReminderSent) || other.lastReminderSent == lastReminderSent)&&(identical(other.nextReminderScheduled, nextReminderScheduled) || other.nextReminderScheduled == nextReminderScheduled)&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId)&&(identical(other.consecutiveIgnores, consecutiveIgnores) || other.consecutiveIgnores == consecutiveIgnores)&&(identical(other.maxIgnoresBeforeDisable, maxIgnoresBeforeDisable) || other.maxIgnoresBeforeDisable == maxIgnoresBeforeDisable)&&(identical(other.disabledByAntiSpam, disabledByAntiSpam) || other.disabledByAntiSpam == disabledByAntiSpam));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isEnabled,frequency,customIntervalDays,reminderHour,reminderMinute,suggestPose,lastReminderSent,nextReminderScheduled,notificationId,consecutiveIgnores,maxIgnoresBeforeDisable,disabledByAntiSpam);

@override
String toString() {
  return 'PhotoReminderSettings(isEnabled: $isEnabled, frequency: $frequency, customIntervalDays: $customIntervalDays, reminderHour: $reminderHour, reminderMinute: $reminderMinute, suggestPose: $suggestPose, lastReminderSent: $lastReminderSent, nextReminderScheduled: $nextReminderScheduled, notificationId: $notificationId, consecutiveIgnores: $consecutiveIgnores, maxIgnoresBeforeDisable: $maxIgnoresBeforeDisable, disabledByAntiSpam: $disabledByAntiSpam)';
}


}

/// @nodoc
abstract mixin class $PhotoReminderSettingsCopyWith<$Res>  {
  factory $PhotoReminderSettingsCopyWith(PhotoReminderSettings value, $Res Function(PhotoReminderSettings) _then) = _$PhotoReminderSettingsCopyWithImpl;
@useResult
$Res call({
 bool isEnabled, PhotoReminderFrequency frequency, int customIntervalDays, int reminderHour, int reminderMinute, bool suggestPose, DateTime? lastReminderSent, DateTime? nextReminderScheduled, int? notificationId, int consecutiveIgnores, int maxIgnoresBeforeDisable, bool disabledByAntiSpam
});




}
/// @nodoc
class _$PhotoReminderSettingsCopyWithImpl<$Res>
    implements $PhotoReminderSettingsCopyWith<$Res> {
  _$PhotoReminderSettingsCopyWithImpl(this._self, this._then);

  final PhotoReminderSettings _self;
  final $Res Function(PhotoReminderSettings) _then;

/// Create a copy of PhotoReminderSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEnabled = null,Object? frequency = null,Object? customIntervalDays = null,Object? reminderHour = null,Object? reminderMinute = null,Object? suggestPose = null,Object? lastReminderSent = freezed,Object? nextReminderScheduled = freezed,Object? notificationId = freezed,Object? consecutiveIgnores = null,Object? maxIgnoresBeforeDisable = null,Object? disabledByAntiSpam = null,}) {
  return _then(_self.copyWith(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PhotoReminderFrequency,customIntervalDays: null == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,suggestPose: null == suggestPose ? _self.suggestPose : suggestPose // ignore: cast_nullable_to_non_nullable
as bool,lastReminderSent: freezed == lastReminderSent ? _self.lastReminderSent : lastReminderSent // ignore: cast_nullable_to_non_nullable
as DateTime?,nextReminderScheduled: freezed == nextReminderScheduled ? _self.nextReminderScheduled : nextReminderScheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationId: freezed == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as int?,consecutiveIgnores: null == consecutiveIgnores ? _self.consecutiveIgnores : consecutiveIgnores // ignore: cast_nullable_to_non_nullable
as int,maxIgnoresBeforeDisable: null == maxIgnoresBeforeDisable ? _self.maxIgnoresBeforeDisable : maxIgnoresBeforeDisable // ignore: cast_nullable_to_non_nullable
as int,disabledByAntiSpam: null == disabledByAntiSpam ? _self.disabledByAntiSpam : disabledByAntiSpam // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoReminderSettings].
extension PhotoReminderSettingsPatterns on PhotoReminderSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoReminderSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoReminderSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoReminderSettings value)  $default,){
final _that = this;
switch (_that) {
case _PhotoReminderSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoReminderSettings value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoReminderSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEnabled,  PhotoReminderFrequency frequency,  int customIntervalDays,  int reminderHour,  int reminderMinute,  bool suggestPose,  DateTime? lastReminderSent,  DateTime? nextReminderScheduled,  int? notificationId,  int consecutiveIgnores,  int maxIgnoresBeforeDisable,  bool disabledByAntiSpam)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoReminderSettings() when $default != null:
return $default(_that.isEnabled,_that.frequency,_that.customIntervalDays,_that.reminderHour,_that.reminderMinute,_that.suggestPose,_that.lastReminderSent,_that.nextReminderScheduled,_that.notificationId,_that.consecutiveIgnores,_that.maxIgnoresBeforeDisable,_that.disabledByAntiSpam);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEnabled,  PhotoReminderFrequency frequency,  int customIntervalDays,  int reminderHour,  int reminderMinute,  bool suggestPose,  DateTime? lastReminderSent,  DateTime? nextReminderScheduled,  int? notificationId,  int consecutiveIgnores,  int maxIgnoresBeforeDisable,  bool disabledByAntiSpam)  $default,) {final _that = this;
switch (_that) {
case _PhotoReminderSettings():
return $default(_that.isEnabled,_that.frequency,_that.customIntervalDays,_that.reminderHour,_that.reminderMinute,_that.suggestPose,_that.lastReminderSent,_that.nextReminderScheduled,_that.notificationId,_that.consecutiveIgnores,_that.maxIgnoresBeforeDisable,_that.disabledByAntiSpam);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEnabled,  PhotoReminderFrequency frequency,  int customIntervalDays,  int reminderHour,  int reminderMinute,  bool suggestPose,  DateTime? lastReminderSent,  DateTime? nextReminderScheduled,  int? notificationId,  int consecutiveIgnores,  int maxIgnoresBeforeDisable,  bool disabledByAntiSpam)?  $default,) {final _that = this;
switch (_that) {
case _PhotoReminderSettings() when $default != null:
return $default(_that.isEnabled,_that.frequency,_that.customIntervalDays,_that.reminderHour,_that.reminderMinute,_that.suggestPose,_that.lastReminderSent,_that.nextReminderScheduled,_that.notificationId,_that.consecutiveIgnores,_that.maxIgnoresBeforeDisable,_that.disabledByAntiSpam);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoReminderSettings extends PhotoReminderSettings {
  const _PhotoReminderSettings({this.isEnabled = false, this.frequency = PhotoReminderFrequency.monthly, this.customIntervalDays = 28, this.reminderHour = 9, this.reminderMinute = 0, this.suggestPose = true, this.lastReminderSent, this.nextReminderScheduled, this.notificationId, this.consecutiveIgnores = 0, this.maxIgnoresBeforeDisable = 3, this.disabledByAntiSpam = false}): super._();
  factory _PhotoReminderSettings.fromJson(Map<String, dynamic> json) => _$PhotoReminderSettingsFromJson(json);

/// Whether reminders are enabled
@override@JsonKey() final  bool isEnabled;
/// Selected frequency
@override@JsonKey() final  PhotoReminderFrequency frequency;
/// Custom interval in days (used when frequency == custom)
@override@JsonKey() final  int customIntervalDays;
/// Preferred reminder time (hour component)
@override@JsonKey() final  int reminderHour;
/// Preferred reminder time (minute component)
@override@JsonKey() final  int reminderMinute;
/// Whether to include specific pose suggestions in reminder
@override@JsonKey() final  bool suggestPose;
/// Last reminder sent timestamp
@override final  DateTime? lastReminderSent;
/// Next scheduled reminder timestamp
@override final  DateTime? nextReminderScheduled;
/// Notification ID for cancellation
@override final  int? notificationId;
/// Anti-spam: consecutive ignores count
@override@JsonKey() final  int consecutiveIgnores;
/// Anti-spam: max ignores before auto-disable (0 = no limit)
@override@JsonKey() final  int maxIgnoresBeforeDisable;
/// Whether user manually disabled after too many ignores
@override@JsonKey() final  bool disabledByAntiSpam;

/// Create a copy of PhotoReminderSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoReminderSettingsCopyWith<_PhotoReminderSettings> get copyWith => __$PhotoReminderSettingsCopyWithImpl<_PhotoReminderSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoReminderSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoReminderSettings&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.customIntervalDays, customIntervalDays) || other.customIntervalDays == customIntervalDays)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.suggestPose, suggestPose) || other.suggestPose == suggestPose)&&(identical(other.lastReminderSent, lastReminderSent) || other.lastReminderSent == lastReminderSent)&&(identical(other.nextReminderScheduled, nextReminderScheduled) || other.nextReminderScheduled == nextReminderScheduled)&&(identical(other.notificationId, notificationId) || other.notificationId == notificationId)&&(identical(other.consecutiveIgnores, consecutiveIgnores) || other.consecutiveIgnores == consecutiveIgnores)&&(identical(other.maxIgnoresBeforeDisable, maxIgnoresBeforeDisable) || other.maxIgnoresBeforeDisable == maxIgnoresBeforeDisable)&&(identical(other.disabledByAntiSpam, disabledByAntiSpam) || other.disabledByAntiSpam == disabledByAntiSpam));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isEnabled,frequency,customIntervalDays,reminderHour,reminderMinute,suggestPose,lastReminderSent,nextReminderScheduled,notificationId,consecutiveIgnores,maxIgnoresBeforeDisable,disabledByAntiSpam);

@override
String toString() {
  return 'PhotoReminderSettings(isEnabled: $isEnabled, frequency: $frequency, customIntervalDays: $customIntervalDays, reminderHour: $reminderHour, reminderMinute: $reminderMinute, suggestPose: $suggestPose, lastReminderSent: $lastReminderSent, nextReminderScheduled: $nextReminderScheduled, notificationId: $notificationId, consecutiveIgnores: $consecutiveIgnores, maxIgnoresBeforeDisable: $maxIgnoresBeforeDisable, disabledByAntiSpam: $disabledByAntiSpam)';
}


}

/// @nodoc
abstract mixin class _$PhotoReminderSettingsCopyWith<$Res> implements $PhotoReminderSettingsCopyWith<$Res> {
  factory _$PhotoReminderSettingsCopyWith(_PhotoReminderSettings value, $Res Function(_PhotoReminderSettings) _then) = __$PhotoReminderSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool isEnabled, PhotoReminderFrequency frequency, int customIntervalDays, int reminderHour, int reminderMinute, bool suggestPose, DateTime? lastReminderSent, DateTime? nextReminderScheduled, int? notificationId, int consecutiveIgnores, int maxIgnoresBeforeDisable, bool disabledByAntiSpam
});




}
/// @nodoc
class __$PhotoReminderSettingsCopyWithImpl<$Res>
    implements _$PhotoReminderSettingsCopyWith<$Res> {
  __$PhotoReminderSettingsCopyWithImpl(this._self, this._then);

  final _PhotoReminderSettings _self;
  final $Res Function(_PhotoReminderSettings) _then;

/// Create a copy of PhotoReminderSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,Object? frequency = null,Object? customIntervalDays = null,Object? reminderHour = null,Object? reminderMinute = null,Object? suggestPose = null,Object? lastReminderSent = freezed,Object? nextReminderScheduled = freezed,Object? notificationId = freezed,Object? consecutiveIgnores = null,Object? maxIgnoresBeforeDisable = null,Object? disabledByAntiSpam = null,}) {
  return _then(_PhotoReminderSettings(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as PhotoReminderFrequency,customIntervalDays: null == customIntervalDays ? _self.customIntervalDays : customIntervalDays // ignore: cast_nullable_to_non_nullable
as int,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,suggestPose: null == suggestPose ? _self.suggestPose : suggestPose // ignore: cast_nullable_to_non_nullable
as bool,lastReminderSent: freezed == lastReminderSent ? _self.lastReminderSent : lastReminderSent // ignore: cast_nullable_to_non_nullable
as DateTime?,nextReminderScheduled: freezed == nextReminderScheduled ? _self.nextReminderScheduled : nextReminderScheduled // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationId: freezed == notificationId ? _self.notificationId : notificationId // ignore: cast_nullable_to_non_nullable
as int?,consecutiveIgnores: null == consecutiveIgnores ? _self.consecutiveIgnores : consecutiveIgnores // ignore: cast_nullable_to_non_nullable
as int,maxIgnoresBeforeDisable: null == maxIgnoresBeforeDisable ? _self.maxIgnoresBeforeDisable : maxIgnoresBeforeDisable // ignore: cast_nullable_to_non_nullable
as int,disabledByAntiSpam: null == disabledByAntiSpam ? _self.disabledByAntiSpam : disabledByAntiSpam // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PhotoReminderRecord {

/// Unique identifier
 String get id;/// When the reminder was sent
 DateTime get sentAt;/// When the reminder was opened/acted upon (null if not)
 DateTime? get openedAt;/// When a photo was taken in response (null if not)
 DateTime? get photoTakenAt;/// Message variation used (for rotation tracking)
 int get messageVariation;/// Whether this reminder was canceled before delivery
 bool get wasCanceled;
/// Create a copy of PhotoReminderRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoReminderRecordCopyWith<PhotoReminderRecord> get copyWith => _$PhotoReminderRecordCopyWithImpl<PhotoReminderRecord>(this as PhotoReminderRecord, _$identity);

  /// Serializes this PhotoReminderRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoReminderRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.photoTakenAt, photoTakenAt) || other.photoTakenAt == photoTakenAt)&&(identical(other.messageVariation, messageVariation) || other.messageVariation == messageVariation)&&(identical(other.wasCanceled, wasCanceled) || other.wasCanceled == wasCanceled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sentAt,openedAt,photoTakenAt,messageVariation,wasCanceled);

@override
String toString() {
  return 'PhotoReminderRecord(id: $id, sentAt: $sentAt, openedAt: $openedAt, photoTakenAt: $photoTakenAt, messageVariation: $messageVariation, wasCanceled: $wasCanceled)';
}


}

/// @nodoc
abstract mixin class $PhotoReminderRecordCopyWith<$Res>  {
  factory $PhotoReminderRecordCopyWith(PhotoReminderRecord value, $Res Function(PhotoReminderRecord) _then) = _$PhotoReminderRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime sentAt, DateTime? openedAt, DateTime? photoTakenAt, int messageVariation, bool wasCanceled
});




}
/// @nodoc
class _$PhotoReminderRecordCopyWithImpl<$Res>
    implements $PhotoReminderRecordCopyWith<$Res> {
  _$PhotoReminderRecordCopyWithImpl(this._self, this._then);

  final PhotoReminderRecord _self;
  final $Res Function(PhotoReminderRecord) _then;

/// Create a copy of PhotoReminderRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sentAt = null,Object? openedAt = freezed,Object? photoTakenAt = freezed,Object? messageVariation = null,Object? wasCanceled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,openedAt: freezed == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,photoTakenAt: freezed == photoTakenAt ? _self.photoTakenAt : photoTakenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageVariation: null == messageVariation ? _self.messageVariation : messageVariation // ignore: cast_nullable_to_non_nullable
as int,wasCanceled: null == wasCanceled ? _self.wasCanceled : wasCanceled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoReminderRecord].
extension PhotoReminderRecordPatterns on PhotoReminderRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoReminderRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoReminderRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoReminderRecord value)  $default,){
final _that = this;
switch (_that) {
case _PhotoReminderRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoReminderRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoReminderRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime sentAt,  DateTime? openedAt,  DateTime? photoTakenAt,  int messageVariation,  bool wasCanceled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoReminderRecord() when $default != null:
return $default(_that.id,_that.sentAt,_that.openedAt,_that.photoTakenAt,_that.messageVariation,_that.wasCanceled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime sentAt,  DateTime? openedAt,  DateTime? photoTakenAt,  int messageVariation,  bool wasCanceled)  $default,) {final _that = this;
switch (_that) {
case _PhotoReminderRecord():
return $default(_that.id,_that.sentAt,_that.openedAt,_that.photoTakenAt,_that.messageVariation,_that.wasCanceled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime sentAt,  DateTime? openedAt,  DateTime? photoTakenAt,  int messageVariation,  bool wasCanceled)?  $default,) {final _that = this;
switch (_that) {
case _PhotoReminderRecord() when $default != null:
return $default(_that.id,_that.sentAt,_that.openedAt,_that.photoTakenAt,_that.messageVariation,_that.wasCanceled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoReminderRecord extends PhotoReminderRecord {
  const _PhotoReminderRecord({required this.id, required this.sentAt, this.openedAt, this.photoTakenAt, required this.messageVariation, this.wasCanceled = false}): super._();
  factory _PhotoReminderRecord.fromJson(Map<String, dynamic> json) => _$PhotoReminderRecordFromJson(json);

/// Unique identifier
@override final  String id;
/// When the reminder was sent
@override final  DateTime sentAt;
/// When the reminder was opened/acted upon (null if not)
@override final  DateTime? openedAt;
/// When a photo was taken in response (null if not)
@override final  DateTime? photoTakenAt;
/// Message variation used (for rotation tracking)
@override final  int messageVariation;
/// Whether this reminder was canceled before delivery
@override@JsonKey() final  bool wasCanceled;

/// Create a copy of PhotoReminderRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoReminderRecordCopyWith<_PhotoReminderRecord> get copyWith => __$PhotoReminderRecordCopyWithImpl<_PhotoReminderRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoReminderRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoReminderRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.photoTakenAt, photoTakenAt) || other.photoTakenAt == photoTakenAt)&&(identical(other.messageVariation, messageVariation) || other.messageVariation == messageVariation)&&(identical(other.wasCanceled, wasCanceled) || other.wasCanceled == wasCanceled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sentAt,openedAt,photoTakenAt,messageVariation,wasCanceled);

@override
String toString() {
  return 'PhotoReminderRecord(id: $id, sentAt: $sentAt, openedAt: $openedAt, photoTakenAt: $photoTakenAt, messageVariation: $messageVariation, wasCanceled: $wasCanceled)';
}


}

/// @nodoc
abstract mixin class _$PhotoReminderRecordCopyWith<$Res> implements $PhotoReminderRecordCopyWith<$Res> {
  factory _$PhotoReminderRecordCopyWith(_PhotoReminderRecord value, $Res Function(_PhotoReminderRecord) _then) = __$PhotoReminderRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime sentAt, DateTime? openedAt, DateTime? photoTakenAt, int messageVariation, bool wasCanceled
});




}
/// @nodoc
class __$PhotoReminderRecordCopyWithImpl<$Res>
    implements _$PhotoReminderRecordCopyWith<$Res> {
  __$PhotoReminderRecordCopyWithImpl(this._self, this._then);

  final _PhotoReminderRecord _self;
  final $Res Function(_PhotoReminderRecord) _then;

/// Create a copy of PhotoReminderRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sentAt = null,Object? openedAt = freezed,Object? photoTakenAt = freezed,Object? messageVariation = null,Object? wasCanceled = null,}) {
  return _then(_PhotoReminderRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,openedAt: freezed == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,photoTakenAt: freezed == photoTakenAt ? _self.photoTakenAt : photoTakenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageVariation: null == messageVariation ? _self.messageVariation : messageVariation // ignore: cast_nullable_to_non_nullable
as int,wasCanceled: null == wasCanceled ? _self.wasCanceled : wasCanceled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
