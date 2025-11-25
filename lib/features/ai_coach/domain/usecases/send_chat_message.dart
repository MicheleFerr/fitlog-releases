/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/usecases
/// 🎯 Feature: ai_coach
/// 🔧 Type: use_case
///
/// Send Chat Message - Stream AI Coach response in real-time
///
/// **Purpose**: Send user message to AI Coach and receive streaming response
///
/// **Responsibilities**:
/// - Validate user input (non-empty, length limits)
/// - Delegate to ChatRepository for AI processing
/// - Stream response tokens as they arrive
/// - Handle errors gracefully (network, API limits, etc.)
///
/// **Use Case**: Conversational AI chat interface with typewriter effect
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/chat_repository.dart';

/// Send chat message to AI Coach and stream response
///
/// **Usage**:
/// ```dart
/// final useCase = SendChatMessage(repository: chatRepository);
///
/// useCase.call(
///   message: "What's my progression trend?",
///   userId: currentUser.id,
/// ).listen(
///   (result) => result.fold(
///     (failure) => showError(failure.message),
///     (aiMessage) {
///       if (aiMessage.isStreaming) {
///         updateChatBubble(aiMessage.content); // Append token
///       } else {
///         finalizeChatBubble(aiMessage.content); // Complete message
///       }
///     },
///   ),
/// );
/// ```
class SendChatMessage {

  SendChatMessage({required this.repository});
  final ChatRepository repository;

  /// Send message and stream AI response
  ///
  /// **Parameters**:
  /// - `message`: User's input text (1-2000 characters)
  /// - `userId`: Current user ID for conversation context
  /// - `systemPrompt`: Optional custom system prompt (defaults to AI Coach persona)
  ///
  /// **Returns**: Stream of Either<Failure, AIMessage> chunks
  ///
  /// **Validation Rules**:
  /// - Message must not be empty (after trimming)
  /// - Message must be <= 2000 characters
  ///
  /// **Error Cases**:
  /// - Empty message → ValidationFailure emitted immediately
  /// - Message too long → ValidationFailure emitted immediately
  /// - Network error → NetworkFailure streamed from repository
  /// - API error → ServerFailure streamed from repository
  Stream<Either<Failure, AIMessage>> call({
    required String message,
    required String userId,
    String? systemPrompt,
  }) async* {
    // Validate input
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      yield const Left(
        ValidationFailure('Message cannot be empty'),
      );
      return;
    }

    if (trimmedMessage.length > 2000) {
      yield const Left(
        ValidationFailure('Message too long (max 2000 characters)'),
      );
      return;
    }

    // Delegate to repository and stream response
    yield* repository.sendMessage(
      message: trimmedMessage,
      userId: userId,
      systemPrompt: systemPrompt,
    );
  }
}
