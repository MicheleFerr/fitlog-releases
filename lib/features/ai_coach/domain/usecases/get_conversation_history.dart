/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/usecases
/// 🎯 Feature: ai_coach
/// 🔧 Type: use_case
///
/// Get Conversation History - Fetch paginated chat messages
///
/// **Purpose**: Retrieve user's conversation history with AI Coach
///
/// **Responsibilities**:
/// - Validate pagination parameters (limit, cursor)
/// - Delegate to ChatRepository for data fetching
/// - Return messages in reverse chronological order (newest first)
///
/// **Use Case**: Display chat history when opening conversation screen
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/chat_repository.dart';

/// Get paginated conversation history
///
/// **Usage**:
/// ```dart
/// final useCase = GetConversationHistory(repository: chatRepository);
///
/// final result = await useCase.call(
///   userId: currentUser.id,
///   limit: 50,
/// );
///
/// result.fold(
///   (failure) => showError(failure.message),
///   (messages) => displayChatHistory(messages),
/// );
/// ```
class GetConversationHistory {
  final ChatRepository repository;

  GetConversationHistory({required this.repository});

  /// Fetch conversation history with pagination
  ///
  /// **Parameters**:
  /// - `userId`: User ID to fetch history for
  /// - `limit`: Max messages to return (default: 50, max: 200)
  /// - `beforeTimestamp`: Optional pagination cursor (fetch messages before this date)
  ///
  /// **Returns**: Either<Failure, List<AIMessage>> in reverse chronological order
  ///
  /// **Validation Rules**:
  /// - userId must not be empty
  /// - limit must be between 1 and 200
  ///
  /// **Error Cases**:
  /// - Invalid userId → ValidationFailure
  /// - Invalid limit → ValidationFailure
  /// - Cache error → CacheFailure from repository
  /// - Network error → NetworkFailure from repository
  Future<Either<Failure, List<AIMessage>>> call({
    required String userId,
    int limit = 50,
    DateTime? beforeTimestamp,
  }) async {
    // Validate input
    if (userId.trim().isEmpty) {
      return Left(
        ValidationFailure('User ID cannot be empty'),
      );
    }

    if (limit < 1 || limit > 200) {
      return Left(
        ValidationFailure('Limit must be between 1 and 200'),
      );
    }

    // Delegate to repository
    return repository.getConversationHistory(
      userId: userId,
      limit: limit,
      beforeTimestamp: beforeTimestamp,
    );
  }
}
