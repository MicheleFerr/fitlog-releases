// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatConversation {

/// Unique conversation ID (format: {coachId}_{athleteId})
 String get id;/// Coach user ID
 String get coachId;/// Athlete user ID
 String get athleteId;/// Coach display name (denormalized)
 String get coachName;/// Athlete display name (denormalized)
 String get athleteName;/// Preview of last message (max 100 chars)
 String? get lastMessage;/// When the last message was sent
 DateTime? get lastMessageAt;/// Who sent the last message
 String? get lastMessageSenderId;/// Unread count for coach
 int get coachUnreadCount;/// Unread count for athlete
 int get athleteUnreadCount;/// When the conversation was created
 DateTime get createdAt;/// When the conversation was last updated
 DateTime get updatedAt;
/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationCopyWith<ChatConversation> get copyWith => _$ChatConversationCopyWithImpl<ChatConversation>(this as ChatConversation, _$identity);

  /// Serializes this ChatConversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversation&&(identical(other.id, id) || other.id == id)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.athleteName, athleteName) || other.athleteName == athleteName)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.coachUnreadCount, coachUnreadCount) || other.coachUnreadCount == coachUnreadCount)&&(identical(other.athleteUnreadCount, athleteUnreadCount) || other.athleteUnreadCount == athleteUnreadCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachId,athleteId,coachName,athleteName,lastMessage,lastMessageAt,lastMessageSenderId,coachUnreadCount,athleteUnreadCount,createdAt,updatedAt);

@override
String toString() {
  return 'ChatConversation(id: $id, coachId: $coachId, athleteId: $athleteId, coachName: $coachName, athleteName: $athleteName, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, lastMessageSenderId: $lastMessageSenderId, coachUnreadCount: $coachUnreadCount, athleteUnreadCount: $athleteUnreadCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ChatConversationCopyWith<$Res>  {
  factory $ChatConversationCopyWith(ChatConversation value, $Res Function(ChatConversation) _then) = _$ChatConversationCopyWithImpl;
@useResult
$Res call({
 String id, String coachId, String athleteId, String coachName, String athleteName, String? lastMessage, DateTime? lastMessageAt, String? lastMessageSenderId, int coachUnreadCount, int athleteUnreadCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ChatConversationCopyWithImpl<$Res>
    implements $ChatConversationCopyWith<$Res> {
  _$ChatConversationCopyWithImpl(this._self, this._then);

  final ChatConversation _self;
  final $Res Function(ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coachId = null,Object? athleteId = null,Object? coachName = null,Object? athleteName = null,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? lastMessageSenderId = freezed,Object? coachUnreadCount = null,Object? athleteUnreadCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,coachName: null == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String,athleteName: null == athleteName ? _self.athleteName : athleteName // ignore: cast_nullable_to_non_nullable
as String,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,coachUnreadCount: null == coachUnreadCount ? _self.coachUnreadCount : coachUnreadCount // ignore: cast_nullable_to_non_nullable
as int,athleteUnreadCount: null == athleteUnreadCount ? _self.athleteUnreadCount : athleteUnreadCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversation].
extension ChatConversationPatterns on ChatConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversation value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversation value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String coachId,  String athleteId,  String coachName,  String athleteName,  String? lastMessage,  DateTime? lastMessageAt,  String? lastMessageSenderId,  int coachUnreadCount,  int athleteUnreadCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.id,_that.coachId,_that.athleteId,_that.coachName,_that.athleteName,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderId,_that.coachUnreadCount,_that.athleteUnreadCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String coachId,  String athleteId,  String coachName,  String athleteName,  String? lastMessage,  DateTime? lastMessageAt,  String? lastMessageSenderId,  int coachUnreadCount,  int athleteUnreadCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatConversation():
return $default(_that.id,_that.coachId,_that.athleteId,_that.coachName,_that.athleteName,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderId,_that.coachUnreadCount,_that.athleteUnreadCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String coachId,  String athleteId,  String coachName,  String athleteName,  String? lastMessage,  DateTime? lastMessageAt,  String? lastMessageSenderId,  int coachUnreadCount,  int athleteUnreadCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.id,_that.coachId,_that.athleteId,_that.coachName,_that.athleteName,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderId,_that.coachUnreadCount,_that.athleteUnreadCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatConversation extends ChatConversation {
  const _ChatConversation({required this.id, required this.coachId, required this.athleteId, required this.coachName, required this.athleteName, this.lastMessage, this.lastMessageAt, this.lastMessageSenderId, this.coachUnreadCount = 0, this.athleteUnreadCount = 0, required this.createdAt, required this.updatedAt}): super._();
  factory _ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);

/// Unique conversation ID (format: {coachId}_{athleteId})
@override final  String id;
/// Coach user ID
@override final  String coachId;
/// Athlete user ID
@override final  String athleteId;
/// Coach display name (denormalized)
@override final  String coachName;
/// Athlete display name (denormalized)
@override final  String athleteName;
/// Preview of last message (max 100 chars)
@override final  String? lastMessage;
/// When the last message was sent
@override final  DateTime? lastMessageAt;
/// Who sent the last message
@override final  String? lastMessageSenderId;
/// Unread count for coach
@override@JsonKey() final  int coachUnreadCount;
/// Unread count for athlete
@override@JsonKey() final  int athleteUnreadCount;
/// When the conversation was created
@override final  DateTime createdAt;
/// When the conversation was last updated
@override final  DateTime updatedAt;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationCopyWith<_ChatConversation> get copyWith => __$ChatConversationCopyWithImpl<_ChatConversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversation&&(identical(other.id, id) || other.id == id)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.athleteName, athleteName) || other.athleteName == athleteName)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.coachUnreadCount, coachUnreadCount) || other.coachUnreadCount == coachUnreadCount)&&(identical(other.athleteUnreadCount, athleteUnreadCount) || other.athleteUnreadCount == athleteUnreadCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachId,athleteId,coachName,athleteName,lastMessage,lastMessageAt,lastMessageSenderId,coachUnreadCount,athleteUnreadCount,createdAt,updatedAt);

@override
String toString() {
  return 'ChatConversation(id: $id, coachId: $coachId, athleteId: $athleteId, coachName: $coachName, athleteName: $athleteName, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, lastMessageSenderId: $lastMessageSenderId, coachUnreadCount: $coachUnreadCount, athleteUnreadCount: $athleteUnreadCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationCopyWith<$Res> implements $ChatConversationCopyWith<$Res> {
  factory _$ChatConversationCopyWith(_ChatConversation value, $Res Function(_ChatConversation) _then) = __$ChatConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, String coachId, String athleteId, String coachName, String athleteName, String? lastMessage, DateTime? lastMessageAt, String? lastMessageSenderId, int coachUnreadCount, int athleteUnreadCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ChatConversationCopyWithImpl<$Res>
    implements _$ChatConversationCopyWith<$Res> {
  __$ChatConversationCopyWithImpl(this._self, this._then);

  final _ChatConversation _self;
  final $Res Function(_ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coachId = null,Object? athleteId = null,Object? coachName = null,Object? athleteName = null,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? lastMessageSenderId = freezed,Object? coachUnreadCount = null,Object? athleteUnreadCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ChatConversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as String,coachName: null == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String,athleteName: null == athleteName ? _self.athleteName : athleteName // ignore: cast_nullable_to_non_nullable
as String,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,coachUnreadCount: null == coachUnreadCount ? _self.coachUnreadCount : coachUnreadCount // ignore: cast_nullable_to_non_nullable
as int,athleteUnreadCount: null == athleteUnreadCount ? _self.athleteUnreadCount : athleteUnreadCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
