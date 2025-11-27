// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_page_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsPageFeedback {

/// Unique identifier: {userId}_{timestamp}
 String get id;/// Firebase Auth UID dell'utente
 String get userId;/// Feedback positivo (true = 👍) o negativo (false = 👎)
 bool get isHelpful;/// Commento opzionale dell'utente
 String? get comment;/// Timestamp quando il feedback è stato dato
 DateTime get timestamp;// ========================================
// METADATA OPZIONALE PER ANALYTICS
// ========================================
/// Numero totale di workout visualizzati in Analytics
/// (utile per capire quanto l'utente ha usato la feature)
 int? get totalWorkoutsViewed;/// Ultima sezione vista prima di dare feedback
/// Valori: 'overview', 'progress', 'insights', 'routine'
 String? get lastViewedSection;/// Device info per analytics (es: "iOS 18.1", "Android 14")
 Map<String, dynamic>? get deviceInfo;
/// Create a copy of AnalyticsPageFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsPageFeedbackCopyWith<AnalyticsPageFeedback> get copyWith => _$AnalyticsPageFeedbackCopyWithImpl<AnalyticsPageFeedback>(this as AnalyticsPageFeedback, _$identity);

  /// Serializes this AnalyticsPageFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsPageFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isHelpful, isHelpful) || other.isHelpful == isHelpful)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.totalWorkoutsViewed, totalWorkoutsViewed) || other.totalWorkoutsViewed == totalWorkoutsViewed)&&(identical(other.lastViewedSection, lastViewedSection) || other.lastViewedSection == lastViewedSection)&&const DeepCollectionEquality().equals(other.deviceInfo, deviceInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,isHelpful,comment,timestamp,totalWorkoutsViewed,lastViewedSection,const DeepCollectionEquality().hash(deviceInfo));

@override
String toString() {
  return 'AnalyticsPageFeedback(id: $id, userId: $userId, isHelpful: $isHelpful, comment: $comment, timestamp: $timestamp, totalWorkoutsViewed: $totalWorkoutsViewed, lastViewedSection: $lastViewedSection, deviceInfo: $deviceInfo)';
}


}

/// @nodoc
abstract mixin class $AnalyticsPageFeedbackCopyWith<$Res>  {
  factory $AnalyticsPageFeedbackCopyWith(AnalyticsPageFeedback value, $Res Function(AnalyticsPageFeedback) _then) = _$AnalyticsPageFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, String userId, bool isHelpful, String? comment, DateTime timestamp, int? totalWorkoutsViewed, String? lastViewedSection, Map<String, dynamic>? deviceInfo
});




}
/// @nodoc
class _$AnalyticsPageFeedbackCopyWithImpl<$Res>
    implements $AnalyticsPageFeedbackCopyWith<$Res> {
  _$AnalyticsPageFeedbackCopyWithImpl(this._self, this._then);

  final AnalyticsPageFeedback _self;
  final $Res Function(AnalyticsPageFeedback) _then;

/// Create a copy of AnalyticsPageFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? isHelpful = null,Object? comment = freezed,Object? timestamp = null,Object? totalWorkoutsViewed = freezed,Object? lastViewedSection = freezed,Object? deviceInfo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isHelpful: null == isHelpful ? _self.isHelpful : isHelpful // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,totalWorkoutsViewed: freezed == totalWorkoutsViewed ? _self.totalWorkoutsViewed : totalWorkoutsViewed // ignore: cast_nullable_to_non_nullable
as int?,lastViewedSection: freezed == lastViewedSection ? _self.lastViewedSection : lastViewedSection // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsPageFeedback].
extension AnalyticsPageFeedbackPatterns on AnalyticsPageFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsPageFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsPageFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsPageFeedback value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsPageFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsPageFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsPageFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  bool isHelpful,  String? comment,  DateTime timestamp,  int? totalWorkoutsViewed,  String? lastViewedSection,  Map<String, dynamic>? deviceInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsPageFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.isHelpful,_that.comment,_that.timestamp,_that.totalWorkoutsViewed,_that.lastViewedSection,_that.deviceInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  bool isHelpful,  String? comment,  DateTime timestamp,  int? totalWorkoutsViewed,  String? lastViewedSection,  Map<String, dynamic>? deviceInfo)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsPageFeedback():
return $default(_that.id,_that.userId,_that.isHelpful,_that.comment,_that.timestamp,_that.totalWorkoutsViewed,_that.lastViewedSection,_that.deviceInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  bool isHelpful,  String? comment,  DateTime timestamp,  int? totalWorkoutsViewed,  String? lastViewedSection,  Map<String, dynamic>? deviceInfo)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsPageFeedback() when $default != null:
return $default(_that.id,_that.userId,_that.isHelpful,_that.comment,_that.timestamp,_that.totalWorkoutsViewed,_that.lastViewedSection,_that.deviceInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyticsPageFeedback implements AnalyticsPageFeedback {
  const _AnalyticsPageFeedback({required this.id, required this.userId, required this.isHelpful, this.comment, required this.timestamp, this.totalWorkoutsViewed, this.lastViewedSection, final  Map<String, dynamic>? deviceInfo}): _deviceInfo = deviceInfo;
  factory _AnalyticsPageFeedback.fromJson(Map<String, dynamic> json) => _$AnalyticsPageFeedbackFromJson(json);

/// Unique identifier: {userId}_{timestamp}
@override final  String id;
/// Firebase Auth UID dell'utente
@override final  String userId;
/// Feedback positivo (true = 👍) o negativo (false = 👎)
@override final  bool isHelpful;
/// Commento opzionale dell'utente
@override final  String? comment;
/// Timestamp quando il feedback è stato dato
@override final  DateTime timestamp;
// ========================================
// METADATA OPZIONALE PER ANALYTICS
// ========================================
/// Numero totale di workout visualizzati in Analytics
/// (utile per capire quanto l'utente ha usato la feature)
@override final  int? totalWorkoutsViewed;
/// Ultima sezione vista prima di dare feedback
/// Valori: 'overview', 'progress', 'insights', 'routine'
@override final  String? lastViewedSection;
/// Device info per analytics (es: "iOS 18.1", "Android 14")
 final  Map<String, dynamic>? _deviceInfo;
/// Device info per analytics (es: "iOS 18.1", "Android 14")
@override Map<String, dynamic>? get deviceInfo {
  final value = _deviceInfo;
  if (value == null) return null;
  if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AnalyticsPageFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsPageFeedbackCopyWith<_AnalyticsPageFeedback> get copyWith => __$AnalyticsPageFeedbackCopyWithImpl<_AnalyticsPageFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyticsPageFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsPageFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isHelpful, isHelpful) || other.isHelpful == isHelpful)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.totalWorkoutsViewed, totalWorkoutsViewed) || other.totalWorkoutsViewed == totalWorkoutsViewed)&&(identical(other.lastViewedSection, lastViewedSection) || other.lastViewedSection == lastViewedSection)&&const DeepCollectionEquality().equals(other._deviceInfo, _deviceInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,isHelpful,comment,timestamp,totalWorkoutsViewed,lastViewedSection,const DeepCollectionEquality().hash(_deviceInfo));

@override
String toString() {
  return 'AnalyticsPageFeedback(id: $id, userId: $userId, isHelpful: $isHelpful, comment: $comment, timestamp: $timestamp, totalWorkoutsViewed: $totalWorkoutsViewed, lastViewedSection: $lastViewedSection, deviceInfo: $deviceInfo)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsPageFeedbackCopyWith<$Res> implements $AnalyticsPageFeedbackCopyWith<$Res> {
  factory _$AnalyticsPageFeedbackCopyWith(_AnalyticsPageFeedback value, $Res Function(_AnalyticsPageFeedback) _then) = __$AnalyticsPageFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, bool isHelpful, String? comment, DateTime timestamp, int? totalWorkoutsViewed, String? lastViewedSection, Map<String, dynamic>? deviceInfo
});




}
/// @nodoc
class __$AnalyticsPageFeedbackCopyWithImpl<$Res>
    implements _$AnalyticsPageFeedbackCopyWith<$Res> {
  __$AnalyticsPageFeedbackCopyWithImpl(this._self, this._then);

  final _AnalyticsPageFeedback _self;
  final $Res Function(_AnalyticsPageFeedback) _then;

/// Create a copy of AnalyticsPageFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? isHelpful = null,Object? comment = freezed,Object? timestamp = null,Object? totalWorkoutsViewed = freezed,Object? lastViewedSection = freezed,Object? deviceInfo = freezed,}) {
  return _then(_AnalyticsPageFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isHelpful: null == isHelpful ? _self.isHelpful : isHelpful // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,totalWorkoutsViewed: freezed == totalWorkoutsViewed ? _self.totalWorkoutsViewed : totalWorkoutsViewed // ignore: cast_nullable_to_non_nullable
as int?,lastViewedSection: freezed == lastViewedSection ? _self.lastViewedSection : lastViewedSection // ignore: cast_nullable_to_non_nullable
as String?,deviceInfo: freezed == deviceInfo ? _self._deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
