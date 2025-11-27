// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) {
  return _AIMessage.fromJson(json);
}

/// @nodoc
mixin _$AIMessage {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata =>
      throw _privateConstructorUsedError; // Branching conversation support
  List<FollowUpChip> get followUpChips =>
      throw _privateConstructorUsedError; // Suggested follow-up questions
  int get conversationDepth =>
      throw _privateConstructorUsedError; // Branching depth (0 = root, max 3)
  String? get parentIntent => throw _privateConstructorUsedError;

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIMessageCopyWith<AIMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIMessageCopyWith<$Res> {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) then) =
      _$AIMessageCopyWithImpl<$Res, AIMessage>;
  @useResult
  $Res call({
    String id,
    String content,
    MessageRole role,
    DateTime timestamp,
    bool isStreaming,
    Map<String, dynamic>? metadata,
    List<FollowUpChip> followUpChips,
    int conversationDepth,
    String? parentIntent,
  });
}

/// @nodoc
class _$AIMessageCopyWithImpl<$Res, $Val extends AIMessage>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? role = null,
    Object? timestamp = null,
    Object? isStreaming = null,
    Object? metadata = freezed,
    Object? followUpChips = null,
    Object? conversationDepth = null,
    Object? parentIntent = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as MessageRole,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            followUpChips: null == followUpChips
                ? _value.followUpChips
                : followUpChips // ignore: cast_nullable_to_non_nullable
                      as List<FollowUpChip>,
            conversationDepth: null == conversationDepth
                ? _value.conversationDepth
                : conversationDepth // ignore: cast_nullable_to_non_nullable
                      as int,
            parentIntent: freezed == parentIntent
                ? _value.parentIntent
                : parentIntent // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIMessageImplCopyWith<$Res>
    implements $AIMessageCopyWith<$Res> {
  factory _$$AIMessageImplCopyWith(
    _$AIMessageImpl value,
    $Res Function(_$AIMessageImpl) then,
  ) = __$$AIMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String content,
    MessageRole role,
    DateTime timestamp,
    bool isStreaming,
    Map<String, dynamic>? metadata,
    List<FollowUpChip> followUpChips,
    int conversationDepth,
    String? parentIntent,
  });
}

/// @nodoc
class __$$AIMessageImplCopyWithImpl<$Res>
    extends _$AIMessageCopyWithImpl<$Res, _$AIMessageImpl>
    implements _$$AIMessageImplCopyWith<$Res> {
  __$$AIMessageImplCopyWithImpl(
    _$AIMessageImpl _value,
    $Res Function(_$AIMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? role = null,
    Object? timestamp = null,
    Object? isStreaming = null,
    Object? metadata = freezed,
    Object? followUpChips = null,
    Object? conversationDepth = null,
    Object? parentIntent = freezed,
  }) {
    return _then(
      _$AIMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MessageRole,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        followUpChips: null == followUpChips
            ? _value._followUpChips
            : followUpChips // ignore: cast_nullable_to_non_nullable
                  as List<FollowUpChip>,
        conversationDepth: null == conversationDepth
            ? _value.conversationDepth
            : conversationDepth // ignore: cast_nullable_to_non_nullable
                  as int,
        parentIntent: freezed == parentIntent
            ? _value.parentIntent
            : parentIntent // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AIMessageImpl implements _AIMessage {
  const _$AIMessageImpl({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
    final Map<String, dynamic>? metadata,
    final List<FollowUpChip> followUpChips = const [],
    this.conversationDepth = 0,
    this.parentIntent,
  }) : _metadata = metadata,
       _followUpChips = followUpChips;

  factory _$AIMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final MessageRole role;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isStreaming;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // Branching conversation support
  final List<FollowUpChip> _followUpChips;
  // Branching conversation support
  @override
  @JsonKey()
  List<FollowUpChip> get followUpChips {
    if (_followUpChips is EqualUnmodifiableListView) return _followUpChips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followUpChips);
  }

  // Suggested follow-up questions
  @override
  @JsonKey()
  final int conversationDepth;
  // Branching depth (0 = root, max 3)
  @override
  final String? parentIntent;

  @override
  String toString() {
    return 'AIMessage(id: $id, content: $content, role: $role, timestamp: $timestamp, isStreaming: $isStreaming, metadata: $metadata, followUpChips: $followUpChips, conversationDepth: $conversationDepth, parentIntent: $parentIntent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(
              other._followUpChips,
              _followUpChips,
            ) &&
            (identical(other.conversationDepth, conversationDepth) ||
                other.conversationDepth == conversationDepth) &&
            (identical(other.parentIntent, parentIntent) ||
                other.parentIntent == parentIntent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    content,
    role,
    timestamp,
    isStreaming,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_followUpChips),
    conversationDepth,
    parentIntent,
  );

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      __$$AIMessageImplCopyWithImpl<_$AIMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIMessageImplToJson(this);
  }
}

abstract class _AIMessage implements AIMessage {
  const factory _AIMessage({
    required final String id,
    required final String content,
    required final MessageRole role,
    required final DateTime timestamp,
    final bool isStreaming,
    final Map<String, dynamic>? metadata,
    final List<FollowUpChip> followUpChips,
    final int conversationDepth,
    final String? parentIntent,
  }) = _$AIMessageImpl;

  factory _AIMessage.fromJson(Map<String, dynamic> json) =
      _$AIMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  MessageRole get role;
  @override
  DateTime get timestamp;
  @override
  bool get isStreaming;
  @override
  Map<String, dynamic>? get metadata; // Branching conversation support
  @override
  List<FollowUpChip> get followUpChips; // Suggested follow-up questions
  @override
  int get conversationDepth; // Branching depth (0 = root, max 3)
  @override
  String? get parentIntent;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowUpChip _$FollowUpChipFromJson(Map<String, dynamic> json) {
  return _FollowUpChip.fromJson(json);
}

/// @nodoc
mixin _$FollowUpChip {
  String get label =>
      throw _privateConstructorUsedError; // Display text (e.g., "📊 Dettagli numeri")
  String get intent =>
      throw _privateConstructorUsedError; // Sub-intent (e.g., "progression.details")
  String? get emoji =>
      throw _privateConstructorUsedError; // Optional emoji prefix
  Map<String, dynamic>? get context => throw _privateConstructorUsedError;

  /// Serializes this FollowUpChip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowUpChip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowUpChipCopyWith<FollowUpChip> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowUpChipCopyWith<$Res> {
  factory $FollowUpChipCopyWith(
    FollowUpChip value,
    $Res Function(FollowUpChip) then,
  ) = _$FollowUpChipCopyWithImpl<$Res, FollowUpChip>;
  @useResult
  $Res call({
    String label,
    String intent,
    String? emoji,
    Map<String, dynamic>? context,
  });
}

/// @nodoc
class _$FollowUpChipCopyWithImpl<$Res, $Val extends FollowUpChip>
    implements $FollowUpChipCopyWith<$Res> {
  _$FollowUpChipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowUpChip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? intent = null,
    Object? emoji = freezed,
    Object? context = freezed,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            intent: null == intent
                ? _value.intent
                : intent // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: freezed == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowUpChipImplCopyWith<$Res>
    implements $FollowUpChipCopyWith<$Res> {
  factory _$$FollowUpChipImplCopyWith(
    _$FollowUpChipImpl value,
    $Res Function(_$FollowUpChipImpl) then,
  ) = __$$FollowUpChipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String label,
    String intent,
    String? emoji,
    Map<String, dynamic>? context,
  });
}

/// @nodoc
class __$$FollowUpChipImplCopyWithImpl<$Res>
    extends _$FollowUpChipCopyWithImpl<$Res, _$FollowUpChipImpl>
    implements _$$FollowUpChipImplCopyWith<$Res> {
  __$$FollowUpChipImplCopyWithImpl(
    _$FollowUpChipImpl _value,
    $Res Function(_$FollowUpChipImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowUpChip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? intent = null,
    Object? emoji = freezed,
    Object? context = freezed,
  }) {
    return _then(
      _$FollowUpChipImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        intent: null == intent
            ? _value.intent
            : intent // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: freezed == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        context: freezed == context
            ? _value._context
            : context // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowUpChipImpl implements _FollowUpChip {
  const _$FollowUpChipImpl({
    required this.label,
    required this.intent,
    this.emoji,
    final Map<String, dynamic>? context,
  }) : _context = context;

  factory _$FollowUpChipImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowUpChipImplFromJson(json);

  @override
  final String label;
  // Display text (e.g., "📊 Dettagli numeri")
  @override
  final String intent;
  // Sub-intent (e.g., "progression.details")
  @override
  final String? emoji;
  // Optional emoji prefix
  final Map<String, dynamic>? _context;
  // Optional emoji prefix
  @override
  Map<String, dynamic>? get context {
    final value = _context;
    if (value == null) return null;
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'FollowUpChip(label: $label, intent: $intent, emoji: $emoji, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUpChipImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.intent, intent) || other.intent == intent) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality().equals(other._context, _context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    label,
    intent,
    emoji,
    const DeepCollectionEquality().hash(_context),
  );

  /// Create a copy of FollowUpChip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUpChipImplCopyWith<_$FollowUpChipImpl> get copyWith =>
      __$$FollowUpChipImplCopyWithImpl<_$FollowUpChipImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowUpChipImplToJson(this);
  }
}

abstract class _FollowUpChip implements FollowUpChip {
  const factory _FollowUpChip({
    required final String label,
    required final String intent,
    final String? emoji,
    final Map<String, dynamic>? context,
  }) = _$FollowUpChipImpl;

  factory _FollowUpChip.fromJson(Map<String, dynamic> json) =
      _$FollowUpChipImpl.fromJson;

  @override
  String get label; // Display text (e.g., "📊 Dettagli numeri")
  @override
  String get intent; // Sub-intent (e.g., "progression.details")
  @override
  String? get emoji; // Optional emoji prefix
  @override
  Map<String, dynamic>? get context;

  /// Create a copy of FollowUpChip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowUpChipImplCopyWith<_$FollowUpChipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
