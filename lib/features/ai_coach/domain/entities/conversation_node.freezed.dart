// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConversationNode _$ConversationNodeFromJson(Map<String, dynamic> json) {
  return _ConversationNode.fromJson(json);
}

/// @nodoc
mixin _$ConversationNode {
  /// Unique node ID (UUID)
  String get id => throw _privateConstructorUsedError;

  /// Parent node ID (null for root)
  String? get parentId => throw _privateConstructorUsedError;

  /// Child node IDs (branches)
  List<String> get childrenIds => throw _privateConstructorUsedError;

  /// Message at this node
  AIMessage get message => throw _privateConstructorUsedError;

  /// Node creation timestamp
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Whether this node is the current active node
  bool get isCurrent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConversationNodeCopyWith<ConversationNode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationNodeCopyWith<$Res> {
  factory $ConversationNodeCopyWith(
          ConversationNode value, $Res Function(ConversationNode) then) =
      _$ConversationNodeCopyWithImpl<$Res, ConversationNode>;
  @useResult
  $Res call(
      {String id,
      String? parentId,
      List<String> childrenIds,
      AIMessage message,
      DateTime timestamp,
      bool isCurrent});

  $AIMessageCopyWith<$Res> get message;
}

/// @nodoc
class _$ConversationNodeCopyWithImpl<$Res, $Val extends ConversationNode>
    implements $ConversationNodeCopyWith<$Res> {
  _$ConversationNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? childrenIds = null,
    Object? message = null,
    Object? timestamp = null,
    Object? isCurrent = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      childrenIds: null == childrenIds
          ? _value.childrenIds
          : childrenIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as AIMessage,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AIMessageCopyWith<$Res> get message {
    return $AIMessageCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationNodeImplCopyWith<$Res>
    implements $ConversationNodeCopyWith<$Res> {
  factory _$$ConversationNodeImplCopyWith(_$ConversationNodeImpl value,
          $Res Function(_$ConversationNodeImpl) then) =
      __$$ConversationNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? parentId,
      List<String> childrenIds,
      AIMessage message,
      DateTime timestamp,
      bool isCurrent});

  @override
  $AIMessageCopyWith<$Res> get message;
}

/// @nodoc
class __$$ConversationNodeImplCopyWithImpl<$Res>
    extends _$ConversationNodeCopyWithImpl<$Res, _$ConversationNodeImpl>
    implements _$$ConversationNodeImplCopyWith<$Res> {
  __$$ConversationNodeImplCopyWithImpl(_$ConversationNodeImpl _value,
      $Res Function(_$ConversationNodeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentId = freezed,
    Object? childrenIds = null,
    Object? message = null,
    Object? timestamp = null,
    Object? isCurrent = null,
  }) {
    return _then(_$ConversationNodeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      childrenIds: null == childrenIds
          ? _value._childrenIds
          : childrenIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as AIMessage,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationNodeImpl extends _ConversationNode {
  const _$ConversationNodeImpl(
      {required this.id,
      this.parentId,
      final List<String> childrenIds = const [],
      required this.message,
      required this.timestamp,
      this.isCurrent = false})
      : _childrenIds = childrenIds,
        super._();

  factory _$ConversationNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationNodeImplFromJson(json);

  /// Unique node ID (UUID)
  @override
  final String id;

  /// Parent node ID (null for root)
  @override
  final String? parentId;

  /// Child node IDs (branches)
  final List<String> _childrenIds;

  /// Child node IDs (branches)
  @override
  @JsonKey()
  List<String> get childrenIds {
    if (_childrenIds is EqualUnmodifiableListView) return _childrenIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_childrenIds);
  }

  /// Message at this node
  @override
  final AIMessage message;

  /// Node creation timestamp
  @override
  final DateTime timestamp;

  /// Whether this node is the current active node
  @override
  @JsonKey()
  final bool isCurrent;

  @override
  String toString() {
    return 'ConversationNode(id: $id, parentId: $parentId, childrenIds: $childrenIds, message: $message, timestamp: $timestamp, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            const DeepCollectionEquality()
                .equals(other._childrenIds, _childrenIds) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      parentId,
      const DeepCollectionEquality().hash(_childrenIds),
      message,
      timestamp,
      isCurrent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationNodeImplCopyWith<_$ConversationNodeImpl> get copyWith =>
      __$$ConversationNodeImplCopyWithImpl<_$ConversationNodeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationNodeImplToJson(
      this,
    );
  }
}

abstract class _ConversationNode extends ConversationNode {
  const factory _ConversationNode(
      {required final String id,
      final String? parentId,
      final List<String> childrenIds,
      required final AIMessage message,
      required final DateTime timestamp,
      final bool isCurrent}) = _$ConversationNodeImpl;
  const _ConversationNode._() : super._();

  factory _ConversationNode.fromJson(Map<String, dynamic> json) =
      _$ConversationNodeImpl.fromJson;

  @override

  /// Unique node ID (UUID)
  String get id;
  @override

  /// Parent node ID (null for root)
  String? get parentId;
  @override

  /// Child node IDs (branches)
  List<String> get childrenIds;
  @override

  /// Message at this node
  AIMessage get message;
  @override

  /// Node creation timestamp
  DateTime get timestamp;
  @override

  /// Whether this node is the current active node
  bool get isCurrent;
  @override
  @JsonKey(ignore: true)
  _$$ConversationNodeImplCopyWith<_$ConversationNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
