// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Insight {

/// Unique insight identifier
 String get id;/// User this insight belongs to
 String get userId;/// Type of insight
 InsightType get type;/// Priority level
 InsightPriority get priority;/// Insight title (localized)
 String get title;/// Insight message/description (localized)
 String get message;/// Recommended action (localized)
 String get recommendation;/// When the insight was generated
 DateTime get generatedAt;/// Additional metadata (exercise names, metrics, etc.)
 Map<String, dynamic> get metadata;/// User's engagement with this insight (if any)
 InsightEngagement? get engagement;/// Specific action the user took (e.g., "started_workout", "adjusted_volume")
 String? get actionTaken;/// When the user dismissed the insight
 DateTime? get dismissedAt;/// When the user first viewed the insight
 DateTime? get viewedAt;/// When action was taken (if applicable)
 DateTime? get actionTakenAt;
/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsightCopyWith<Insight> get copyWith => _$InsightCopyWithImpl<Insight>(this as Insight, _$identity);

  /// Serializes this Insight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Insight&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&(identical(other.dismissedAt, dismissedAt) || other.dismissedAt == dismissedAt)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.actionTakenAt, actionTakenAt) || other.actionTakenAt == actionTakenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,priority,title,message,recommendation,generatedAt,const DeepCollectionEquality().hash(metadata),engagement,actionTaken,dismissedAt,viewedAt,actionTakenAt);

@override
String toString() {
  return 'Insight(id: $id, userId: $userId, type: $type, priority: $priority, title: $title, message: $message, recommendation: $recommendation, generatedAt: $generatedAt, metadata: $metadata, engagement: $engagement, actionTaken: $actionTaken, dismissedAt: $dismissedAt, viewedAt: $viewedAt, actionTakenAt: $actionTakenAt)';
}


}

/// @nodoc
abstract mixin class $InsightCopyWith<$Res>  {
  factory $InsightCopyWith(Insight value, $Res Function(Insight) _then) = _$InsightCopyWithImpl;
@useResult
$Res call({
 String id, String userId, InsightType type, InsightPriority priority, String title, String message, String recommendation, DateTime generatedAt, Map<String, dynamic> metadata, InsightEngagement? engagement, String? actionTaken, DateTime? dismissedAt, DateTime? viewedAt, DateTime? actionTakenAt
});




}
/// @nodoc
class _$InsightCopyWithImpl<$Res>
    implements $InsightCopyWith<$Res> {
  _$InsightCopyWithImpl(this._self, this._then);

  final Insight _self;
  final $Res Function(Insight) _then;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? priority = null,Object? title = null,Object? message = null,Object? recommendation = null,Object? generatedAt = null,Object? metadata = null,Object? engagement = freezed,Object? actionTaken = freezed,Object? dismissedAt = freezed,Object? viewedAt = freezed,Object? actionTakenAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as InsightPriority,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,engagement: freezed == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as InsightEngagement?,actionTaken: freezed == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as String?,dismissedAt: freezed == dismissedAt ? _self.dismissedAt : dismissedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,actionTakenAt: freezed == actionTakenAt ? _self.actionTakenAt : actionTakenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Insight].
extension InsightPatterns on Insight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Insight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Insight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Insight value)  $default,){
final _that = this;
switch (_that) {
case _Insight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Insight value)?  $default,){
final _that = this;
switch (_that) {
case _Insight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  InsightType type,  InsightPriority priority,  String title,  String message,  String recommendation,  DateTime generatedAt,  Map<String, dynamic> metadata,  InsightEngagement? engagement,  String? actionTaken,  DateTime? dismissedAt,  DateTime? viewedAt,  DateTime? actionTakenAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Insight() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.priority,_that.title,_that.message,_that.recommendation,_that.generatedAt,_that.metadata,_that.engagement,_that.actionTaken,_that.dismissedAt,_that.viewedAt,_that.actionTakenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  InsightType type,  InsightPriority priority,  String title,  String message,  String recommendation,  DateTime generatedAt,  Map<String, dynamic> metadata,  InsightEngagement? engagement,  String? actionTaken,  DateTime? dismissedAt,  DateTime? viewedAt,  DateTime? actionTakenAt)  $default,) {final _that = this;
switch (_that) {
case _Insight():
return $default(_that.id,_that.userId,_that.type,_that.priority,_that.title,_that.message,_that.recommendation,_that.generatedAt,_that.metadata,_that.engagement,_that.actionTaken,_that.dismissedAt,_that.viewedAt,_that.actionTakenAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  InsightType type,  InsightPriority priority,  String title,  String message,  String recommendation,  DateTime generatedAt,  Map<String, dynamic> metadata,  InsightEngagement? engagement,  String? actionTaken,  DateTime? dismissedAt,  DateTime? viewedAt,  DateTime? actionTakenAt)?  $default,) {final _that = this;
switch (_that) {
case _Insight() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.priority,_that.title,_that.message,_that.recommendation,_that.generatedAt,_that.metadata,_that.engagement,_that.actionTaken,_that.dismissedAt,_that.viewedAt,_that.actionTakenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Insight implements Insight {
  const _Insight({required this.id, required this.userId, required this.type, required this.priority, required this.title, required this.message, required this.recommendation, required this.generatedAt, final  Map<String, dynamic> metadata = const {}, this.engagement, this.actionTaken, this.dismissedAt, this.viewedAt, this.actionTakenAt}): _metadata = metadata;
  factory _Insight.fromJson(Map<String, dynamic> json) => _$InsightFromJson(json);

/// Unique insight identifier
@override final  String id;
/// User this insight belongs to
@override final  String userId;
/// Type of insight
@override final  InsightType type;
/// Priority level
@override final  InsightPriority priority;
/// Insight title (localized)
@override final  String title;
/// Insight message/description (localized)
@override final  String message;
/// Recommended action (localized)
@override final  String recommendation;
/// When the insight was generated
@override final  DateTime generatedAt;
/// Additional metadata (exercise names, metrics, etc.)
 final  Map<String, dynamic> _metadata;
/// Additional metadata (exercise names, metrics, etc.)
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

/// User's engagement with this insight (if any)
@override final  InsightEngagement? engagement;
/// Specific action the user took (e.g., "started_workout", "adjusted_volume")
@override final  String? actionTaken;
/// When the user dismissed the insight
@override final  DateTime? dismissedAt;
/// When the user first viewed the insight
@override final  DateTime? viewedAt;
/// When action was taken (if applicable)
@override final  DateTime? actionTakenAt;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsightCopyWith<_Insight> get copyWith => __$InsightCopyWithImpl<_Insight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Insight&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.recommendation, recommendation) || other.recommendation == recommendation)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.actionTaken, actionTaken) || other.actionTaken == actionTaken)&&(identical(other.dismissedAt, dismissedAt) || other.dismissedAt == dismissedAt)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.actionTakenAt, actionTakenAt) || other.actionTakenAt == actionTakenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,priority,title,message,recommendation,generatedAt,const DeepCollectionEquality().hash(_metadata),engagement,actionTaken,dismissedAt,viewedAt,actionTakenAt);

@override
String toString() {
  return 'Insight(id: $id, userId: $userId, type: $type, priority: $priority, title: $title, message: $message, recommendation: $recommendation, generatedAt: $generatedAt, metadata: $metadata, engagement: $engagement, actionTaken: $actionTaken, dismissedAt: $dismissedAt, viewedAt: $viewedAt, actionTakenAt: $actionTakenAt)';
}


}

/// @nodoc
abstract mixin class _$InsightCopyWith<$Res> implements $InsightCopyWith<$Res> {
  factory _$InsightCopyWith(_Insight value, $Res Function(_Insight) _then) = __$InsightCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, InsightType type, InsightPriority priority, String title, String message, String recommendation, DateTime generatedAt, Map<String, dynamic> metadata, InsightEngagement? engagement, String? actionTaken, DateTime? dismissedAt, DateTime? viewedAt, DateTime? actionTakenAt
});




}
/// @nodoc
class __$InsightCopyWithImpl<$Res>
    implements _$InsightCopyWith<$Res> {
  __$InsightCopyWithImpl(this._self, this._then);

  final _Insight _self;
  final $Res Function(_Insight) _then;

/// Create a copy of Insight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? priority = null,Object? title = null,Object? message = null,Object? recommendation = null,Object? generatedAt = null,Object? metadata = null,Object? engagement = freezed,Object? actionTaken = freezed,Object? dismissedAt = freezed,Object? viewedAt = freezed,Object? actionTakenAt = freezed,}) {
  return _then(_Insight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as InsightPriority,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,recommendation: null == recommendation ? _self.recommendation : recommendation // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,engagement: freezed == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as InsightEngagement?,actionTaken: freezed == actionTaken ? _self.actionTaken : actionTaken // ignore: cast_nullable_to_non_nullable
as String?,dismissedAt: freezed == dismissedAt ? _self.dismissedAt : dismissedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,actionTakenAt: freezed == actionTakenAt ? _self.actionTakenAt : actionTakenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
