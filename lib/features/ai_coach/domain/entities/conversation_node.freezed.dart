// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationNode {

/// Unique node ID (UUID)
 String get id;/// Parent node ID (null for root)
 String? get parentId;/// Child node IDs (branches)
 List<String> get childrenIds;/// Message at this node
 AIMessage get message;/// Node creation timestamp
 DateTime get timestamp;/// Whether this node is the current active node
 bool get isCurrent;
/// Create a copy of ConversationNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationNodeCopyWith<ConversationNode> get copyWith => _$ConversationNodeCopyWithImpl<ConversationNode>(this as ConversationNode, _$identity);

  /// Serializes this ConversationNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationNode&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&const DeepCollectionEquality().equals(other.childrenIds, childrenIds)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId,const DeepCollectionEquality().hash(childrenIds),message,timestamp,isCurrent);

@override
String toString() {
  return 'ConversationNode(id: $id, parentId: $parentId, childrenIds: $childrenIds, message: $message, timestamp: $timestamp, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $ConversationNodeCopyWith<$Res>  {
  factory $ConversationNodeCopyWith(ConversationNode value, $Res Function(ConversationNode) _then) = _$ConversationNodeCopyWithImpl;
@useResult
$Res call({
 String id, String? parentId, List<String> childrenIds, AIMessage message, DateTime timestamp, bool isCurrent
});


$AIMessageCopyWith<$Res> get message;

}
/// @nodoc
class _$ConversationNodeCopyWithImpl<$Res>
    implements $ConversationNodeCopyWith<$Res> {
  _$ConversationNodeCopyWithImpl(this._self, this._then);

  final ConversationNode _self;
  final $Res Function(ConversationNode) _then;

/// Create a copy of ConversationNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = freezed,Object? childrenIds = null,Object? message = null,Object? timestamp = null,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,childrenIds: null == childrenIds ? _self.childrenIds : childrenIds // ignore: cast_nullable_to_non_nullable
as List<String>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as AIMessage,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ConversationNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AIMessageCopyWith<$Res> get message {
  
  return $AIMessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationNode].
extension ConversationNodePatterns on ConversationNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationNode value)  $default,){
final _that = this;
switch (_that) {
case _ConversationNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationNode value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? parentId,  List<String> childrenIds,  AIMessage message,  DateTime timestamp,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationNode() when $default != null:
return $default(_that.id,_that.parentId,_that.childrenIds,_that.message,_that.timestamp,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? parentId,  List<String> childrenIds,  AIMessage message,  DateTime timestamp,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _ConversationNode():
return $default(_that.id,_that.parentId,_that.childrenIds,_that.message,_that.timestamp,_that.isCurrent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? parentId,  List<String> childrenIds,  AIMessage message,  DateTime timestamp,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _ConversationNode() when $default != null:
return $default(_that.id,_that.parentId,_that.childrenIds,_that.message,_that.timestamp,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationNode extends ConversationNode {
  const _ConversationNode({required this.id, this.parentId, final  List<String> childrenIds = const [], required this.message, required this.timestamp, this.isCurrent = false}): _childrenIds = childrenIds,super._();
  factory _ConversationNode.fromJson(Map<String, dynamic> json) => _$ConversationNodeFromJson(json);

/// Unique node ID (UUID)
@override final  String id;
/// Parent node ID (null for root)
@override final  String? parentId;
/// Child node IDs (branches)
 final  List<String> _childrenIds;
/// Child node IDs (branches)
@override@JsonKey() List<String> get childrenIds {
  if (_childrenIds is EqualUnmodifiableListView) return _childrenIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childrenIds);
}

/// Message at this node
@override final  AIMessage message;
/// Node creation timestamp
@override final  DateTime timestamp;
/// Whether this node is the current active node
@override@JsonKey() final  bool isCurrent;

/// Create a copy of ConversationNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationNodeCopyWith<_ConversationNode> get copyWith => __$ConversationNodeCopyWithImpl<_ConversationNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationNode&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&const DeepCollectionEquality().equals(other._childrenIds, _childrenIds)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId,const DeepCollectionEquality().hash(_childrenIds),message,timestamp,isCurrent);

@override
String toString() {
  return 'ConversationNode(id: $id, parentId: $parentId, childrenIds: $childrenIds, message: $message, timestamp: $timestamp, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$ConversationNodeCopyWith<$Res> implements $ConversationNodeCopyWith<$Res> {
  factory _$ConversationNodeCopyWith(_ConversationNode value, $Res Function(_ConversationNode) _then) = __$ConversationNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String? parentId, List<String> childrenIds, AIMessage message, DateTime timestamp, bool isCurrent
});


@override $AIMessageCopyWith<$Res> get message;

}
/// @nodoc
class __$ConversationNodeCopyWithImpl<$Res>
    implements _$ConversationNodeCopyWith<$Res> {
  __$ConversationNodeCopyWithImpl(this._self, this._then);

  final _ConversationNode _self;
  final $Res Function(_ConversationNode) _then;

/// Create a copy of ConversationNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = freezed,Object? childrenIds = null,Object? message = null,Object? timestamp = null,Object? isCurrent = null,}) {
  return _then(_ConversationNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,childrenIds: null == childrenIds ? _self._childrenIds : childrenIds // ignore: cast_nullable_to_non_nullable
as List<String>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as AIMessage,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ConversationNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AIMessageCopyWith<$Res> get message {
  
  return $AIMessageCopyWith<$Res>(_self.message, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

// dart format on
