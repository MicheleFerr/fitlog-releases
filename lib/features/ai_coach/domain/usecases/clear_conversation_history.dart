/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/usecases
/// 🎯 Feature: ai_coach
/// 🔧 Type: use_case
///
/// Clear Conversation History - Delete all chat messages for user
///
/// **Purpose**: Clear user's conversation history with AI Coach
///
/// **Responsibilities**:
/// - Validate userId parameter
/// - Delegate to ChatRepository for data deletion
/// - Return success/failure result
///
/// **Use Case**: "Clear History" button in chat modal header
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/chat_repository.dart';

/// Clear all conversation history for user
///
/// **Usage**:
/// ```dart
/// final useCase = ClearConversationHistory(repository: chatRepository);
///
/// final result = await useCase.call(userId: currentUser.id);
///
/// result.fold(
///   (failure) => showError(failure.message),
///   (_) => showSuccess('History cleared'),
/// );
/// ```
class ClearConversationHistory {

  ClearConversationHistory({required this.repository});
  final ChatRepository repository;

  /// Clear conversation history from cache and cloud
  ///
  /// **Parameters**:
  /// - `userId`: User ID to clear history for
  ///
  /// **Returns**: Either<Failure, void>
  ///
  /// **Validation Rules**:
  /// - userId must not be empty
  ///
  /// **Side Effects**:
  /// - Deletes all messages from Hive cache
  /// - Triggers Firestore batch delete (background)
  /// - Analytics event: conversation_cleared
  ///
  /// **Error Cases**:
  /// - Invalid userId → ValidationFailure
  /// - Cache error → CacheFailure from repository
  Future<Either<Failure, void>> call({
    required String userId,
  }) async {
    // Validate input
    if (userId.trim().isEmpty) {
      return const Left(
        ValidationFailure('User ID cannot be empty'),
      );
    }

    // Delegate to repository
    return repository.clearHistory(userId: userId);
  }
}
