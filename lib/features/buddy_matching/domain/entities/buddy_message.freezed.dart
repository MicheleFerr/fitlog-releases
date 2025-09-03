// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuddyMessage _$BuddyMessageFromJson(Map<String, dynamic> json) {
  return _BuddyMessage.fromJson(json);
}

/// @nodoc
mixin _$BuddyMessage {
  String get id => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String get content =>
      throw _privateConstructorUsedError; // Metadata for different message types
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  bool get isDelivered => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // Reply functionality
  String? get replyToMessageId => throw _privateConstructorUsedError;
  String? get replyToContent => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BuddyMessageCopyWith<BuddyMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddyMessageCopyWith<$Res> {
  factory $BuddyMessageCopyWith(
          BuddyMessage value, $Res Function(BuddyMessage) then) =
      _$BuddyMessageCopyWithImpl<$Res, BuddyMessage>;
  @useResult
  $Res call(
      {String id,
      String matchId,
      String senderId,
      String receiverId,
      MessageType type,
      String content,
      Map<String, dynamic>? metadata,
      bool isRead,
      DateTime? readAt,
      bool isDelivered,
      DateTime? deliveredAt,
      bool isEdited,
      DateTime? editedAt,
      bool isDeleted,
      DateTime? deletedAt,
      String? replyToMessageId,
      String? replyToContent,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$BuddyMessageCopyWithImpl<$Res, $Val extends BuddyMessage>
    implements $BuddyMessageCopyWith<$Res> {
  _$BuddyMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? type = null,
    Object? content = null,
    Object? metadata = freezed,
    Object? isRead = null,
    Object? readAt = freezed,
    Object? isDelivered = null,
    Object? deliveredAt = freezed,
    Object? isEdited = null,
    Object? editedAt = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? replyToMessageId = freezed,
    Object? replyToContent = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDelivered: null == isDelivered
          ? _value.isDelivered
          : isDelivered // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      replyToContent: freezed == replyToContent
          ? _value.replyToContent
          : replyToContent // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BuddyMessageImplCopyWith<$Res>
    implements $BuddyMessageCopyWith<$Res> {
  factory _$$BuddyMessageImplCopyWith(
          _$BuddyMessageImpl value, $Res Function(_$BuddyMessageImpl) then) =
      __$$BuddyMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String matchId,
      String senderId,
      String receiverId,
      MessageType type,
      String content,
      Map<String, dynamic>? metadata,
      bool isRead,
      DateTime? readAt,
      bool isDelivered,
      DateTime? deliveredAt,
      bool isEdited,
      DateTime? editedAt,
      bool isDeleted,
      DateTime? deletedAt,
      String? replyToMessageId,
      String? replyToContent,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$BuddyMessageImplCopyWithImpl<$Res>
    extends _$BuddyMessageCopyWithImpl<$Res, _$BuddyMessageImpl>
    implements _$$BuddyMessageImplCopyWith<$Res> {
  __$$BuddyMessageImplCopyWithImpl(
      _$BuddyMessageImpl _value, $Res Function(_$BuddyMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? type = null,
    Object? content = null,
    Object? metadata = freezed,
    Object? isRead = null,
    Object? readAt = freezed,
    Object? isDelivered = null,
    Object? deliveredAt = freezed,
    Object? isEdited = null,
    Object? editedAt = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? replyToMessageId = freezed,
    Object? replyToContent = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BuddyMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDelivered: null == isDelivered
          ? _value.isDelivered
          : isDelivered // ignore: cast_nullable_to_non_nullable
              as bool,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      replyToContent: freezed == replyToContent
          ? _value.replyToContent
          : replyToContent // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BuddyMessageImpl implements _BuddyMessage {
  const _$BuddyMessageImpl(
      {required this.id,
      required this.matchId,
      required this.senderId,
      required this.receiverId,
      required this.type,
      required this.content,
      final Map<String, dynamic>? metadata,
      this.isRead = false,
      this.readAt,
      this.isDelivered = false,
      this.deliveredAt,
      this.isEdited = false,
      this.editedAt,
      this.isDeleted = false,
      this.deletedAt,
      this.replyToMessageId,
      this.replyToContent,
      this.createdAt,
      this.updatedAt})
      : _metadata = metadata;

  factory _$BuddyMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddyMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String matchId;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final MessageType type;
  @override
  final String content;
// Metadata for different message types
  final Map<String, dynamic>? _metadata;
// Metadata for different message types
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime? readAt;
  @override
  @JsonKey()
  final bool isDelivered;
  @override
  final DateTime? deliveredAt;
  @override
  @JsonKey()
  final bool isEdited;
  @override
  final DateTime? editedAt;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  final DateTime? deletedAt;
// Reply functionality
  @override
  final String? replyToMessageId;
  @override
  final String? replyToContent;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BuddyMessage(id: $id, matchId: $matchId, senderId: $senderId, receiverId: $receiverId, type: $type, content: $content, metadata: $metadata, isRead: $isRead, readAt: $readAt, isDelivered: $isDelivered, deliveredAt: $deliveredAt, isEdited: $isEdited, editedAt: $editedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, replyToMessageId: $replyToMessageId, replyToContent: $replyToContent, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddyMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.isDelivered, isDelivered) ||
                other.isDelivered == isDelivered) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.replyToContent, replyToContent) ||
                other.replyToContent == replyToContent) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        matchId,
        senderId,
        receiverId,
        type,
        content,
        const DeepCollectionEquality().hash(_metadata),
        isRead,
        readAt,
        isDelivered,
        deliveredAt,
        isEdited,
        editedAt,
        isDeleted,
        deletedAt,
        replyToMessageId,
        replyToContent,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddyMessageImplCopyWith<_$BuddyMessageImpl> get copyWith =>
      __$$BuddyMessageImplCopyWithImpl<_$BuddyMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddyMessageImplToJson(
      this,
    );
  }
}

abstract class _BuddyMessage implements BuddyMessage {
  const factory _BuddyMessage(
      {required final String id,
      required final String matchId,
      required final String senderId,
      required final String receiverId,
      required final MessageType type,
      required final String content,
      final Map<String, dynamic>? metadata,
      final bool isRead,
      final DateTime? readAt,
      final bool isDelivered,
      final DateTime? deliveredAt,
      final bool isEdited,
      final DateTime? editedAt,
      final bool isDeleted,
      final DateTime? deletedAt,
      final String? replyToMessageId,
      final String? replyToContent,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$BuddyMessageImpl;

  factory _BuddyMessage.fromJson(Map<String, dynamic> json) =
      _$BuddyMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get matchId;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  MessageType get type;
  @override
  String get content;
  @override // Metadata for different message types
  Map<String, dynamic>? get metadata;
  @override
  bool get isRead;
  @override
  DateTime? get readAt;
  @override
  bool get isDelivered;
  @override
  DateTime? get deliveredAt;
  @override
  bool get isEdited;
  @override
  DateTime? get editedAt;
  @override
  bool get isDeleted;
  @override
  DateTime? get deletedAt;
  @override // Reply functionality
  String? get replyToMessageId;
  @override
  String? get replyToContent;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BuddyMessageImplCopyWith<_$BuddyMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
