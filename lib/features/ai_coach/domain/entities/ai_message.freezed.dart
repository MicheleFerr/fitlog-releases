// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIMessage {

 String get id; String get content; MessageRole get role; DateTime get timestamp; bool get isStreaming; Map<String, dynamic>? get metadata;// Branching conversation support
 List<FollowUpChip> get followUpChips;// Suggested follow-up questions
 int get conversationDepth;// Branching depth (0 = root, max 3)
 String? get parentIntent;
/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIMessageCopyWith<AIMessage> get copyWith => _$AIMessageCopyWithImpl<AIMessage>(this as AIMessage, _$identity);

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.role, role) || other.role == role)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.followUpChips, followUpChips)&&(identical(other.conversationDepth, conversationDepth) || other.conversationDepth == conversationDepth)&&(identical(other.parentIntent, parentIntent) || other.parentIntent == parentIntent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,role,timestamp,isStreaming,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(followUpChips),conversationDepth,parentIntent);

@override
String toString() {
  return 'AIMessage(id: $id, content: $content, role: $role, timestamp: $timestamp, isStreaming: $isStreaming, metadata: $metadata, followUpChips: $followUpChips, conversationDepth: $conversationDepth, parentIntent: $parentIntent)';
}


}

/// @nodoc
abstract mixin class $AIMessageCopyWith<$Res>  {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) _then) = _$AIMessageCopyWithImpl;
@useResult
$Res call({
 String id, String content, MessageRole role, DateTime timestamp, bool isStreaming, Map<String, dynamic>? metadata, List<FollowUpChip> followUpChips, int conversationDepth, String? parentIntent
});




}
/// @nodoc
class _$AIMessageCopyWithImpl<$Res>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._self, this._then);

  final AIMessage _self;
  final $Res Function(AIMessage) _then;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? role = null,Object? timestamp = null,Object? isStreaming = null,Object? metadata = freezed,Object? followUpChips = null,Object? conversationDepth = null,Object? parentIntent = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MessageRole,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,followUpChips: null == followUpChips ? _self.followUpChips : followUpChips // ignore: cast_nullable_to_non_nullable
as List<FollowUpChip>,conversationDepth: null == conversationDepth ? _self.conversationDepth : conversationDepth // ignore: cast_nullable_to_non_nullable
as int,parentIntent: freezed == parentIntent ? _self.parentIntent : parentIntent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AIMessage].
extension AIMessagePatterns on AIMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIMessage value)  $default,){
final _that = this;
switch (_that) {
case _AIMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  MessageRole role,  DateTime timestamp,  bool isStreaming,  Map<String, dynamic>? metadata,  List<FollowUpChip> followUpChips,  int conversationDepth,  String? parentIntent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
return $default(_that.id,_that.content,_that.role,_that.timestamp,_that.isStreaming,_that.metadata,_that.followUpChips,_that.conversationDepth,_that.parentIntent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  MessageRole role,  DateTime timestamp,  bool isStreaming,  Map<String, dynamic>? metadata,  List<FollowUpChip> followUpChips,  int conversationDepth,  String? parentIntent)  $default,) {final _that = this;
switch (_that) {
case _AIMessage():
return $default(_that.id,_that.content,_that.role,_that.timestamp,_that.isStreaming,_that.metadata,_that.followUpChips,_that.conversationDepth,_that.parentIntent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  MessageRole role,  DateTime timestamp,  bool isStreaming,  Map<String, dynamic>? metadata,  List<FollowUpChip> followUpChips,  int conversationDepth,  String? parentIntent)?  $default,) {final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
return $default(_that.id,_that.content,_that.role,_that.timestamp,_that.isStreaming,_that.metadata,_that.followUpChips,_that.conversationDepth,_that.parentIntent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIMessage implements AIMessage {
  const _AIMessage({required this.id, required this.content, required this.role, required this.timestamp, this.isStreaming = false, final  Map<String, dynamic>? metadata, final  List<FollowUpChip> followUpChips = const [], this.conversationDepth = 0, this.parentIntent}): _metadata = metadata,_followUpChips = followUpChips;
  factory _AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);

@override final  String id;
@override final  String content;
@override final  MessageRole role;
@override final  DateTime timestamp;
@override@JsonKey() final  bool isStreaming;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Branching conversation support
 final  List<FollowUpChip> _followUpChips;
// Branching conversation support
@override@JsonKey() List<FollowUpChip> get followUpChips {
  if (_followUpChips is EqualUnmodifiableListView) return _followUpChips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followUpChips);
}

// Suggested follow-up questions
@override@JsonKey() final  int conversationDepth;
// Branching depth (0 = root, max 3)
@override final  String? parentIntent;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIMessageCopyWith<_AIMessage> get copyWith => __$AIMessageCopyWithImpl<_AIMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.role, role) || other.role == role)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.isStreaming, isStreaming) || other.isStreaming == isStreaming)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._followUpChips, _followUpChips)&&(identical(other.conversationDepth, conversationDepth) || other.conversationDepth == conversationDepth)&&(identical(other.parentIntent, parentIntent) || other.parentIntent == parentIntent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,role,timestamp,isStreaming,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_followUpChips),conversationDepth,parentIntent);

@override
String toString() {
  return 'AIMessage(id: $id, content: $content, role: $role, timestamp: $timestamp, isStreaming: $isStreaming, metadata: $metadata, followUpChips: $followUpChips, conversationDepth: $conversationDepth, parentIntent: $parentIntent)';
}


}

/// @nodoc
abstract mixin class _$AIMessageCopyWith<$Res> implements $AIMessageCopyWith<$Res> {
  factory _$AIMessageCopyWith(_AIMessage value, $Res Function(_AIMessage) _then) = __$AIMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, MessageRole role, DateTime timestamp, bool isStreaming, Map<String, dynamic>? metadata, List<FollowUpChip> followUpChips, int conversationDepth, String? parentIntent
});




}
/// @nodoc
class __$AIMessageCopyWithImpl<$Res>
    implements _$AIMessageCopyWith<$Res> {
  __$AIMessageCopyWithImpl(this._self, this._then);

  final _AIMessage _self;
  final $Res Function(_AIMessage) _then;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? role = null,Object? timestamp = null,Object? isStreaming = null,Object? metadata = freezed,Object? followUpChips = null,Object? conversationDepth = null,Object? parentIntent = freezed,}) {
  return _then(_AIMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MessageRole,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,isStreaming: null == isStreaming ? _self.isStreaming : isStreaming // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,followUpChips: null == followUpChips ? _self._followUpChips : followUpChips // ignore: cast_nullable_to_non_nullable
as List<FollowUpChip>,conversationDepth: null == conversationDepth ? _self.conversationDepth : conversationDepth // ignore: cast_nullable_to_non_nullable
as int,parentIntent: freezed == parentIntent ? _self.parentIntent : parentIntent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FollowUpChip {

 String get label;// Display text (e.g., "📊 Dettagli numeri")
 String get intent;// Sub-intent (e.g., "progression.details")
 String? get emoji;// Optional emoji prefix
 Map<String, dynamic>? get context;
/// Create a copy of FollowUpChip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUpChipCopyWith<FollowUpChip> get copyWith => _$FollowUpChipCopyWithImpl<FollowUpChip>(this as FollowUpChip, _$identity);

  /// Serializes this FollowUpChip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpChip&&(identical(other.label, label) || other.label == label)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other.context, context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,intent,emoji,const DeepCollectionEquality().hash(context));

@override
String toString() {
  return 'FollowUpChip(label: $label, intent: $intent, emoji: $emoji, context: $context)';
}


}

/// @nodoc
abstract mixin class $FollowUpChipCopyWith<$Res>  {
  factory $FollowUpChipCopyWith(FollowUpChip value, $Res Function(FollowUpChip) _then) = _$FollowUpChipCopyWithImpl;
@useResult
$Res call({
 String label, String intent, String? emoji, Map<String, dynamic>? context
});




}
/// @nodoc
class _$FollowUpChipCopyWithImpl<$Res>
    implements $FollowUpChipCopyWith<$Res> {
  _$FollowUpChipCopyWithImpl(this._self, this._then);

  final FollowUpChip _self;
  final $Res Function(FollowUpChip) _then;

/// Create a copy of FollowUpChip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? intent = null,Object? emoji = freezed,Object? context = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,context: freezed == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowUpChip].
extension FollowUpChipPatterns on FollowUpChip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowUpChip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowUpChip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowUpChip value)  $default,){
final _that = this;
switch (_that) {
case _FollowUpChip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowUpChip value)?  $default,){
final _that = this;
switch (_that) {
case _FollowUpChip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String intent,  String? emoji,  Map<String, dynamic>? context)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowUpChip() when $default != null:
return $default(_that.label,_that.intent,_that.emoji,_that.context);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String intent,  String? emoji,  Map<String, dynamic>? context)  $default,) {final _that = this;
switch (_that) {
case _FollowUpChip():
return $default(_that.label,_that.intent,_that.emoji,_that.context);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String intent,  String? emoji,  Map<String, dynamic>? context)?  $default,) {final _that = this;
switch (_that) {
case _FollowUpChip() when $default != null:
return $default(_that.label,_that.intent,_that.emoji,_that.context);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowUpChip implements FollowUpChip {
  const _FollowUpChip({required this.label, required this.intent, this.emoji, final  Map<String, dynamic>? context}): _context = context;
  factory _FollowUpChip.fromJson(Map<String, dynamic> json) => _$FollowUpChipFromJson(json);

@override final  String label;
// Display text (e.g., "📊 Dettagli numeri")
@override final  String intent;
// Sub-intent (e.g., "progression.details")
@override final  String? emoji;
// Optional emoji prefix
 final  Map<String, dynamic>? _context;
// Optional emoji prefix
@override Map<String, dynamic>? get context {
  final value = _context;
  if (value == null) return null;
  if (_context is EqualUnmodifiableMapView) return _context;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of FollowUpChip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUpChipCopyWith<_FollowUpChip> get copyWith => __$FollowUpChipCopyWithImpl<_FollowUpChip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUpChipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUpChip&&(identical(other.label, label) || other.label == label)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other._context, _context));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,intent,emoji,const DeepCollectionEquality().hash(_context));

@override
String toString() {
  return 'FollowUpChip(label: $label, intent: $intent, emoji: $emoji, context: $context)';
}


}

/// @nodoc
abstract mixin class _$FollowUpChipCopyWith<$Res> implements $FollowUpChipCopyWith<$Res> {
  factory _$FollowUpChipCopyWith(_FollowUpChip value, $Res Function(_FollowUpChip) _then) = __$FollowUpChipCopyWithImpl;
@override @useResult
$Res call({
 String label, String intent, String? emoji, Map<String, dynamic>? context
});




}
/// @nodoc
class __$FollowUpChipCopyWithImpl<$Res>
    implements _$FollowUpChipCopyWith<$Res> {
  __$FollowUpChipCopyWithImpl(this._self, this._then);

  final _FollowUpChip _self;
  final $Res Function(_FollowUpChip) _then;

/// Create a copy of FollowUpChip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? intent = null,Object? emoji = freezed,Object? context = freezed,}) {
  return _then(_FollowUpChip(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,context: freezed == context ? _self._context : context // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
