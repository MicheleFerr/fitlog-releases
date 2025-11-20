import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

/// Represents a message in the AI Coach conversation
@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required String content,
    required MessageRole role,
    required DateTime timestamp,
    @Default(false) bool isStreaming,
    Map<String, dynamic>? metadata,

    // Branching conversation support
    @Default([]) List<FollowUpChip> followUpChips, // Suggested follow-up questions
    @Default(0) int conversationDepth, // Branching depth (0 = root, max 3)
    String? parentIntent, // Original intent for context tracking
  }) = _AIMessage;

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
}

/// Follow-up chip for branching conversations
@freezed
class FollowUpChip with _$FollowUpChip {
  const factory FollowUpChip({
    required String label, // Display text (e.g., "📊 Dettagli numeri")
    required String intent, // Sub-intent (e.g., "progression.details")
    String? emoji, // Optional emoji prefix
    Map<String, dynamic>? context, // Optional context data
  }) = _FollowUpChip;

  factory FollowUpChip.fromJson(Map<String, dynamic> json) =>
      _$FollowUpChipFromJson(json);
}

/// Role of the message sender
enum MessageRole {
  user,      // User's message
  assistant, // AI Coach's response
  system,    // System-generated prompt/context
}
