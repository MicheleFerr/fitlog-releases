// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_tree.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationTree {

/// User ID who owns this tree
 String get userId;/// Root node ID (first message in conversation)
 String? get rootNodeId;/// Current active node ID (where user is in tree)
 String? get currentNodeId;/// All nodes in tree (keyed by node ID)
 Map<String, ConversationNode> get nodes;/// Last update timestamp
 DateTime get lastUpdated;
/// Create a copy of ConversationTree
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationTreeCopyWith<ConversationTree> get copyWith => _$ConversationTreeCopyWithImpl<ConversationTree>(this as ConversationTree, _$identity);

  /// Serializes this ConversationTree to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationTree&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rootNodeId, rootNodeId) || other.rootNodeId == rootNodeId)&&(identical(other.currentNodeId, currentNodeId) || other.currentNodeId == currentNodeId)&&const DeepCollectionEquality().equals(other.nodes, nodes)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,rootNodeId,currentNodeId,const DeepCollectionEquality().hash(nodes),lastUpdated);

@override
String toString() {
  return 'ConversationTree(userId: $userId, rootNodeId: $rootNodeId, currentNodeId: $currentNodeId, nodes: $nodes, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $ConversationTreeCopyWith<$Res>  {
  factory $ConversationTreeCopyWith(ConversationTree value, $Res Function(ConversationTree) _then) = _$ConversationTreeCopyWithImpl;
@useResult
$Res call({
 String userId, String? rootNodeId, String? currentNodeId, Map<String, ConversationNode> nodes, DateTime lastUpdated
});




}
/// @nodoc
class _$ConversationTreeCopyWithImpl<$Res>
    implements $ConversationTreeCopyWith<$Res> {
  _$ConversationTreeCopyWithImpl(this._self, this._then);

  final ConversationTree _self;
  final $Res Function(ConversationTree) _then;

/// Create a copy of ConversationTree
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? rootNodeId = freezed,Object? currentNodeId = freezed,Object? nodes = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rootNodeId: freezed == rootNodeId ? _self.rootNodeId : rootNodeId // ignore: cast_nullable_to_non_nullable
as String?,currentNodeId: freezed == currentNodeId ? _self.currentNodeId : currentNodeId // ignore: cast_nullable_to_non_nullable
as String?,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as Map<String, ConversationNode>,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationTree].
extension ConversationTreePatterns on ConversationTree {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationTree value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationTree() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationTree value)  $default,){
final _that = this;
switch (_that) {
case _ConversationTree():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationTree value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationTree() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? rootNodeId,  String? currentNodeId,  Map<String, ConversationNode> nodes,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationTree() when $default != null:
return $default(_that.userId,_that.rootNodeId,_that.currentNodeId,_that.nodes,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? rootNodeId,  String? currentNodeId,  Map<String, ConversationNode> nodes,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _ConversationTree():
return $default(_that.userId,_that.rootNodeId,_that.currentNodeId,_that.nodes,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? rootNodeId,  String? currentNodeId,  Map<String, ConversationNode> nodes,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _ConversationTree() when $default != null:
return $default(_that.userId,_that.rootNodeId,_that.currentNodeId,_that.nodes,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationTree extends ConversationTree {
  const _ConversationTree({required this.userId, this.rootNodeId, this.currentNodeId, final  Map<String, ConversationNode> nodes = const {}, required this.lastUpdated}): _nodes = nodes,super._();
  factory _ConversationTree.fromJson(Map<String, dynamic> json) => _$ConversationTreeFromJson(json);

/// User ID who owns this tree
@override final  String userId;
/// Root node ID (first message in conversation)
@override final  String? rootNodeId;
/// Current active node ID (where user is in tree)
@override final  String? currentNodeId;
/// All nodes in tree (keyed by node ID)
 final  Map<String, ConversationNode> _nodes;
/// All nodes in tree (keyed by node ID)
@override@JsonKey() Map<String, ConversationNode> get nodes {
  if (_nodes is EqualUnmodifiableMapView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nodes);
}

/// Last update timestamp
@override final  DateTime lastUpdated;

/// Create a copy of ConversationTree
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationTreeCopyWith<_ConversationTree> get copyWith => __$ConversationTreeCopyWithImpl<_ConversationTree>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationTreeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationTree&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rootNodeId, rootNodeId) || other.rootNodeId == rootNodeId)&&(identical(other.currentNodeId, currentNodeId) || other.currentNodeId == currentNodeId)&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,rootNodeId,currentNodeId,const DeepCollectionEquality().hash(_nodes),lastUpdated);

@override
String toString() {
  return 'ConversationTree(userId: $userId, rootNodeId: $rootNodeId, currentNodeId: $currentNodeId, nodes: $nodes, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$ConversationTreeCopyWith<$Res> implements $ConversationTreeCopyWith<$Res> {
  factory _$ConversationTreeCopyWith(_ConversationTree value, $Res Function(_ConversationTree) _then) = __$ConversationTreeCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? rootNodeId, String? currentNodeId, Map<String, ConversationNode> nodes, DateTime lastUpdated
});




}
/// @nodoc
class __$ConversationTreeCopyWithImpl<$Res>
    implements _$ConversationTreeCopyWith<$Res> {
  __$ConversationTreeCopyWithImpl(this._self, this._then);

  final _ConversationTree _self;
  final $Res Function(_ConversationTree) _then;

/// Create a copy of ConversationTree
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? rootNodeId = freezed,Object? currentNodeId = freezed,Object? nodes = null,Object? lastUpdated = null,}) {
  return _then(_ConversationTree(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rootNodeId: freezed == rootNodeId ? _self.rootNodeId : rootNodeId // ignore: cast_nullable_to_non_nullable
as String?,currentNodeId: freezed == currentNodeId ? _self.currentNodeId : currentNodeId // ignore: cast_nullable_to_non_nullable
as String?,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as Map<String, ConversationNode>,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
