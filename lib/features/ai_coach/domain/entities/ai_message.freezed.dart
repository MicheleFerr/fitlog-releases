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
mixin _$AIToolCall {

 String get name; Map<String, dynamic> get arguments; String? get result;
/// Create a copy of AIToolCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIToolCallCopyWith<AIToolCall> get copyWith => _$AIToolCallCopyWithImpl<AIToolCall>(this as AIToolCall, _$identity);

  /// Serializes this AIToolCall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIToolCall&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.arguments, arguments)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(arguments),result);

@override
String toString() {
  return 'AIToolCall(name: $name, arguments: $arguments, result: $result)';
}


}

/// @nodoc
abstract mixin class $AIToolCallCopyWith<$Res>  {
  factory $AIToolCallCopyWith(AIToolCall value, $Res Function(AIToolCall) _then) = _$AIToolCallCopyWithImpl;
@useResult
$Res call({
 String name, Map<String, dynamic> arguments, String? result
});




}
/// @nodoc
class _$AIToolCallCopyWithImpl<$Res>
    implements $AIToolCallCopyWith<$Res> {
  _$AIToolCallCopyWithImpl(this._self, this._then);

  final AIToolCall _self;
  final $Res Function(AIToolCall) _then;

/// Create a copy of AIToolCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? arguments = null,Object? result = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AIToolCall].
extension AIToolCallPatterns on AIToolCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIToolCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIToolCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIToolCall value)  $default,){
final _that = this;
switch (_that) {
case _AIToolCall():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIToolCall value)?  $default,){
final _that = this;
switch (_that) {
case _AIToolCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  Map<String, dynamic> arguments,  String? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIToolCall() when $default != null:
return $default(_that.name,_that.arguments,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  Map<String, dynamic> arguments,  String? result)  $default,) {final _that = this;
switch (_that) {
case _AIToolCall():
return $default(_that.name,_that.arguments,_that.result);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  Map<String, dynamic> arguments,  String? result)?  $default,) {final _that = this;
switch (_that) {
case _AIToolCall() when $default != null:
return $default(_that.name,_that.arguments,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIToolCall implements AIToolCall {
  const _AIToolCall({required this.name, required final  Map<String, dynamic> arguments, this.result}): _arguments = arguments;
  factory _AIToolCall.fromJson(Map<String, dynamic> json) => _$AIToolCallFromJson(json);

@override final  String name;
 final  Map<String, dynamic> _arguments;
@override Map<String, dynamic> get arguments {
  if (_arguments is EqualUnmodifiableMapView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_arguments);
}

@override final  String? result;

/// Create a copy of AIToolCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIToolCallCopyWith<_AIToolCall> get copyWith => __$AIToolCallCopyWithImpl<_AIToolCall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIToolCallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIToolCall&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._arguments, _arguments)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_arguments),result);

@override
String toString() {
  return 'AIToolCall(name: $name, arguments: $arguments, result: $result)';
}


}

/// @nodoc
abstract mixin class _$AIToolCallCopyWith<$Res> implements $AIToolCallCopyWith<$Res> {
  factory _$AIToolCallCopyWith(_AIToolCall value, $Res Function(_AIToolCall) _then) = __$AIToolCallCopyWithImpl;
@override @useResult
$Res call({
 String name, Map<String, dynamic> arguments, String? result
});




}
/// @nodoc
class __$AIToolCallCopyWithImpl<$Res>
    implements _$AIToolCallCopyWith<$Res> {
  __$AIToolCallCopyWithImpl(this._self, this._then);

  final _AIToolCall _self;
  final $Res Function(_AIToolCall) _then;

/// Create a copy of AIToolCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? arguments = null,Object? result = freezed,}) {
  return _then(_AIToolCall(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AIMessage {

 String get id; MessageRole get role; String get content; DateTime get timestamp; AIToolCall? get toolCall; bool get isTyping; String? get error; List<String> get suggestions;
/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIMessageCopyWith<AIMessage> get copyWith => _$AIMessageCopyWithImpl<AIMessage>(this as AIMessage, _$identity);

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.toolCall, toolCall) || other.toolCall == toolCall)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.suggestions, suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,content,timestamp,toolCall,isTyping,error,const DeepCollectionEquality().hash(suggestions));

@override
String toString() {
  return 'AIMessage(id: $id, role: $role, content: $content, timestamp: $timestamp, toolCall: $toolCall, isTyping: $isTyping, error: $error, suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class $AIMessageCopyWith<$Res>  {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) _then) = _$AIMessageCopyWithImpl;
@useResult
$Res call({
 String id, MessageRole role, String content, DateTime timestamp, AIToolCall? toolCall, bool isTyping, String? error, List<String> suggestions
});


$AIToolCallCopyWith<$Res>? get toolCall;

}
/// @nodoc
class _$AIMessageCopyWithImpl<$Res>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._self, this._then);

  final AIMessage _self;
  final $Res Function(AIMessage) _then;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? content = null,Object? timestamp = null,Object? toolCall = freezed,Object? isTyping = null,Object? error = freezed,Object? suggestions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,toolCall: freezed == toolCall ? _self.toolCall : toolCall // ignore: cast_nullable_to_non_nullable
as AIToolCall?,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AIToolCallCopyWith<$Res>? get toolCall {
    if (_self.toolCall == null) {
    return null;
  }

  return $AIToolCallCopyWith<$Res>(_self.toolCall!, (value) {
    return _then(_self.copyWith(toolCall: value));
  });
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
return $default(_that);}
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MessageRole role,  String content,  DateTime timestamp,  AIToolCall? toolCall,  bool isTyping,  String? error,  List<String> suggestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
return $default(_that.id,_that.role,_that.content,_that.timestamp,_that.toolCall,_that.isTyping,_that.error,_that.suggestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MessageRole role,  String content,  DateTime timestamp,  AIToolCall? toolCall,  bool isTyping,  String? error,  List<String> suggestions)  $default,) {final _that = this;
switch (_that) {
case _AIMessage():
return $default(_that.id,_that.role,_that.content,_that.timestamp,_that.toolCall,_that.isTyping,_that.error,_that.suggestions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MessageRole role,  String content,  DateTime timestamp,  AIToolCall? toolCall,  bool isTyping,  String? error,  List<String> suggestions)?  $default,) {final _that = this;
switch (_that) {
case _AIMessage() when $default != null:
return $default(_that.id,_that.role,_that.content,_that.timestamp,_that.toolCall,_that.isTyping,_that.error,_that.suggestions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIMessage extends AIMessage {
  const _AIMessage({required this.id, required this.role, required this.content, required this.timestamp, this.toolCall, this.isTyping = false, this.error, final  List<String> suggestions = const []}): _suggestions = suggestions,super._();
  factory _AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);

@override final  String id;
@override final  MessageRole role;
@override final  String content;
@override final  DateTime timestamp;
@override final  AIToolCall? toolCall;
@override@JsonKey() final  bool isTyping;
@override final  String? error;
 final  List<String> _suggestions;
@override@JsonKey() List<String> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.toolCall, toolCall) || other.toolCall == toolCall)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._suggestions, _suggestions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,content,timestamp,toolCall,isTyping,error,const DeepCollectionEquality().hash(_suggestions));

@override
String toString() {
  return 'AIMessage(id: $id, role: $role, content: $content, timestamp: $timestamp, toolCall: $toolCall, isTyping: $isTyping, error: $error, suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class _$AIMessageCopyWith<$Res> implements $AIMessageCopyWith<$Res> {
  factory _$AIMessageCopyWith(_AIMessage value, $Res Function(_AIMessage) _then) = __$AIMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, MessageRole role, String content, DateTime timestamp, AIToolCall? toolCall, bool isTyping, String? error, List<String> suggestions
});


@override $AIToolCallCopyWith<$Res>? get toolCall;

}
/// @nodoc
class __$AIMessageCopyWithImpl<$Res>
    implements _$AIMessageCopyWith<$Res> {
  __$AIMessageCopyWithImpl(this._self, this._then);

  final _AIMessage _self;
  final $Res Function(_AIMessage) _then;

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? content = null,Object? timestamp = null,Object? toolCall = freezed,Object? isTyping = null,Object? error = freezed,Object? suggestions = null,}) {
  return _then(_AIMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MessageRole,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,toolCall: freezed == toolCall ? _self.toolCall : toolCall // ignore: cast_nullable_to_non_nullable
as AIToolCall?,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of AIMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AIToolCallCopyWith<$Res>? get toolCall {
    if (_self.toolCall == null) {
    return null;
  }

  return $AIToolCallCopyWith<$Res>(_self.toolCall!, (value) {
    return _then(_self.copyWith(toolCall: value));
  });
}
}

// dart format on
