// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_tree.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConversationTree _$ConversationTreeFromJson(Map<String, dynamic> json) {
  return _ConversationTree.fromJson(json);
}

/// @nodoc
mixin _$ConversationTree {
  /// User ID who owns this tree
  String get userId => throw _privateConstructorUsedError;

  /// Root node ID (first message in conversation)
  String? get rootNodeId => throw _privateConstructorUsedError;

  /// Current active node ID (where user is in tree)
  String? get currentNodeId => throw _privateConstructorUsedError;

  /// All nodes in tree (keyed by node ID)
  Map<String, ConversationNode> get nodes => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this ConversationTree to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationTree
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationTreeCopyWith<ConversationTree> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationTreeCopyWith<$Res> {
  factory $ConversationTreeCopyWith(
    ConversationTree value,
    $Res Function(ConversationTree) then,
  ) = _$ConversationTreeCopyWithImpl<$Res, ConversationTree>;
  @useResult
  $Res call({
    String userId,
    String? rootNodeId,
    String? currentNodeId,
    Map<String, ConversationNode> nodes,
    DateTime lastUpdated,
  });
}

/// @nodoc
class _$ConversationTreeCopyWithImpl<$Res, $Val extends ConversationTree>
    implements $ConversationTreeCopyWith<$Res> {
  _$ConversationTreeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationTree
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? rootNodeId = freezed,
    Object? currentNodeId = freezed,
    Object? nodes = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            rootNodeId: freezed == rootNodeId
                ? _value.rootNodeId
                : rootNodeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentNodeId: freezed == currentNodeId
                ? _value.currentNodeId
                : currentNodeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nodes: null == nodes
                ? _value.nodes
                : nodes // ignore: cast_nullable_to_non_nullable
                      as Map<String, ConversationNode>,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationTreeImplCopyWith<$Res>
    implements $ConversationTreeCopyWith<$Res> {
  factory _$$ConversationTreeImplCopyWith(
    _$ConversationTreeImpl value,
    $Res Function(_$ConversationTreeImpl) then,
  ) = __$$ConversationTreeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String? rootNodeId,
    String? currentNodeId,
    Map<String, ConversationNode> nodes,
    DateTime lastUpdated,
  });
}

/// @nodoc
class __$$ConversationTreeImplCopyWithImpl<$Res>
    extends _$ConversationTreeCopyWithImpl<$Res, _$ConversationTreeImpl>
    implements _$$ConversationTreeImplCopyWith<$Res> {
  __$$ConversationTreeImplCopyWithImpl(
    _$ConversationTreeImpl _value,
    $Res Function(_$ConversationTreeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationTree
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? rootNodeId = freezed,
    Object? currentNodeId = freezed,
    Object? nodes = null,
    Object? lastUpdated = null,
  }) {
    return _then(
      _$ConversationTreeImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        rootNodeId: freezed == rootNodeId
            ? _value.rootNodeId
            : rootNodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentNodeId: freezed == currentNodeId
            ? _value.currentNodeId
            : currentNodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nodes: null == nodes
            ? _value._nodes
            : nodes // ignore: cast_nullable_to_non_nullable
                  as Map<String, ConversationNode>,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationTreeImpl extends _ConversationTree {
  const _$ConversationTreeImpl({
    required this.userId,
    this.rootNodeId,
    this.currentNodeId,
    final Map<String, ConversationNode> nodes = const {},
    required this.lastUpdated,
  }) : _nodes = nodes,
       super._();

  factory _$ConversationTreeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationTreeImplFromJson(json);

  /// User ID who owns this tree
  @override
  final String userId;

  /// Root node ID (first message in conversation)
  @override
  final String? rootNodeId;

  /// Current active node ID (where user is in tree)
  @override
  final String? currentNodeId;

  /// All nodes in tree (keyed by node ID)
  final Map<String, ConversationNode> _nodes;

  /// All nodes in tree (keyed by node ID)
  @override
  @JsonKey()
  Map<String, ConversationNode> get nodes {
    if (_nodes is EqualUnmodifiableMapView) return _nodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nodes);
  }

  /// Last update timestamp
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'ConversationTree(userId: $userId, rootNodeId: $rootNodeId, currentNodeId: $currentNodeId, nodes: $nodes, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationTreeImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rootNodeId, rootNodeId) ||
                other.rootNodeId == rootNodeId) &&
            (identical(other.currentNodeId, currentNodeId) ||
                other.currentNodeId == currentNodeId) &&
            const DeepCollectionEquality().equals(other._nodes, _nodes) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    rootNodeId,
    currentNodeId,
    const DeepCollectionEquality().hash(_nodes),
    lastUpdated,
  );

  /// Create a copy of ConversationTree
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationTreeImplCopyWith<_$ConversationTreeImpl> get copyWith =>
      __$$ConversationTreeImplCopyWithImpl<_$ConversationTreeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationTreeImplToJson(this);
  }
}

abstract class _ConversationTree extends ConversationTree {
  const factory _ConversationTree({
    required final String userId,
    final String? rootNodeId,
    final String? currentNodeId,
    final Map<String, ConversationNode> nodes,
    required final DateTime lastUpdated,
  }) = _$ConversationTreeImpl;
  const _ConversationTree._() : super._();

  factory _ConversationTree.fromJson(Map<String, dynamic> json) =
      _$ConversationTreeImpl.fromJson;

  /// User ID who owns this tree
  @override
  String get userId;

  /// Root node ID (first message in conversation)
  @override
  String? get rootNodeId;

  /// Current active node ID (where user is in tree)
  @override
  String? get currentNodeId;

  /// All nodes in tree (keyed by node ID)
  @override
  Map<String, ConversationNode> get nodes;

  /// Last update timestamp
  @override
  DateTime get lastUpdated;

  /// Create a copy of ConversationTree
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationTreeImplCopyWith<_$ConversationTreeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
