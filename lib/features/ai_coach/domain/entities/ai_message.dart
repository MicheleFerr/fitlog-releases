/// AI Message Entity
///
/// Represents a single message in the AI Coach conversation.
/// Supports text messages, tool calls, and typing indicators.
///
/// **Layer**: Domain - Entity
/// **Feature**: AI Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

/// Role of the message sender
enum MessageRole {
  /// User-sent message
  user,

  /// AI assistant response
  assistant,

  /// System message (hidden from UI)
  system,

  /// Tool call result (hidden from UI)
  tool,
}

/// Tool call made by the AI
@freezed
sealed class AIToolCall with _$AIToolCall {
  const factory AIToolCall({
    required String name,
    required Map<String, dynamic> arguments,
    String? result,
  }) = _AIToolCall;

  factory AIToolCall.fromJson(Map<String, dynamic> json) =>
      _$AIToolCallFromJson(json);
}

/// AI chat message
@freezed
sealed class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required MessageRole role,
    required String content,
    required DateTime timestamp,
    AIToolCall? toolCall,
    @Default(false) bool isTyping,
    String? error,
    @Default([]) List<String> suggestions,
  }) = _AIMessage;

  const AIMessage._();

  /// Whether this message should be visible in the UI
  bool get isVisible => role == MessageRole.user || role == MessageRole.assistant;

  /// Whether this message contains a tool call
  bool get hasToolCall => toolCall != null;

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
}
