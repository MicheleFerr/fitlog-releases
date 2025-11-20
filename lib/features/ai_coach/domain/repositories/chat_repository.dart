/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository_interface
///
/// Chat Repository Interface
///
/// **Purpose**: Abstract repository for AI Coach conversational chat
///
/// **Responsibilities**:
/// - Send user messages to AI Coach and receive streaming responses
/// - Persist conversation history (local + cloud sync)
/// - Provide reactive conversation updates
/// - Manage conversation context and memory
///
/// **Data Sources**:
/// - OpenAI API (GPT-4): LLM-powered conversational AI
/// - Hive (local cache): Conversation history, offline support
/// - Firestore (cloud sync): Cross-device conversation persistence
///
/// **Implementation**: See `ChatRepositoryImpl` in data layer
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/conversation_tree.dart';

/// Repository interface for AI Coach chat functionality
///
/// **Usage (in use cases)**:
/// ```dart
/// class SendChatMessage {
///   final ChatRepository repository;
///
///   Stream<Either<Failure, AIMessage>> call(String message) {
///     return repository.sendMessage(message: message);
///   }
/// }
/// ```
abstract class ChatRepository {
  // ========================================================================
  // Message Streaming
  // ========================================================================

  /// Send user message and stream AI response tokens
  ///
  /// **Parameters**:
  /// - `message`: User's input text
  /// - `userId`: Current user ID for context/history
  /// - `systemPrompt`: Optional system prompt override (defaults to AI Coach persona)
  ///
  /// **Returns**: Stream of [AIMessage] chunks (isStreaming=true until final)
  ///
  /// **Data Flow**:
  /// 1. Save user message to Hive cache immediately
  /// 2. Fetch last N messages for conversation context
  /// 3. Call OpenAI API with streaming=true
  /// 4. Emit AIMessage chunks as tokens arrive (isStreaming=true)
  /// 5. Emit final AIMessage with complete response (isStreaming=false)
  /// 6. Save assistant message to Hive + queue Firestore sync
  ///
  /// **Use Case**: Real-time chat interface with typewriter effect
  ///
  /// **Error Handling**:
  /// - Network error → Emit Left(NetworkFailure) and return cached response
  /// - API rate limit → Emit Left(ServerFailure) with retry guidance
  /// - Context limit → Emit Left(ServerFailure) and trigger context pruning
  Stream<Either<Failure, AIMessage>> sendMessage({
    required String message,
    required String userId,
    String? systemPrompt,
  });

  // ========================================================================
  // Conversation History
  // ========================================================================

  /// Get paginated conversation history (most recent first)
  ///
  /// **Parameters**:
  /// - `userId`: User ID to fetch history for
  /// - `limit`: Max messages to return (default: 50)
  /// - `beforeTimestamp`: Optional pagination cursor (fetch messages before this)
  ///
  /// **Returns**: List of [AIMessage] in reverse chronological order
  ///
  /// **Data Flow**:
  /// 1. Query Hive cache (instant)
  /// 2. If cache miss or stale → fetch from Firestore
  /// 3. Update Hive cache with latest messages
  ///
  /// **Use Case**: Display chat history when opening conversation screen
  Future<Either<Failure, List<AIMessage>>> getConversationHistory({
    required String userId,
    int limit = 50,
    DateTime? beforeTimestamp,
  });

  /// Watch conversation for real-time updates
  ///
  /// **Parameters**:
  /// - `userId`: User ID to watch
  ///
  /// **Returns**: Stream of message lists (emits on every new message)
  ///
  /// **Data Flow**:
  /// 1. Listen to Hive box changes
  /// 2. Emit updated message list on every add/update
  /// 3. Auto-cancel when screen disposed
  ///
  /// **Use Case**: Reactive chat UI (auto-scroll to new messages)
  Stream<Either<Failure, List<AIMessage>>> watchConversation({
    required String userId,
  });

  // ========================================================================
  // Conversation Management
  // ========================================================================

  /// Clear all conversation history for user
  ///
  /// **Parameters**:
  /// - `userId`: User ID to clear history for
  ///
  /// **Side Effects**:
  /// - Deletes all messages from Hive cache
  /// - Triggers Firestore batch delete (background)
  /// - Analytics event: conversation_cleared
  ///
  /// **Use Case**: "Start Fresh" button in chat settings
  Future<Either<Failure, void>> clearHistory({
    required String userId,
  });

  /// Get conversation context for system prompt
  ///
  /// **Parameters**:
  /// - `userId`: User ID to fetch context for
  /// - `messageCount`: How many recent messages to include (default: 10)
  ///
  /// **Returns**: Formatted conversation context string
  ///
  /// **Data Flow**:
  /// 1. Fetch last N messages from cache
  /// 2. Format as "User: ...\nAssistant: ..." string
  /// 3. Truncate if exceeds token limit (4096 tokens)
  ///
  /// **Use Case**: Include conversation memory in API calls
  Future<Either<Failure, String>> getConversationContext({
    required String userId,
    int messageCount = 10,
  });

  // ========================================================================
  // Conversation Tree Navigation (NEW)
  // ========================================================================

  /// Save conversation tree to persistent storage
  ///
  /// **Parameters**:
  /// - `tree`: ConversationTree to save
  ///
  /// **Side Effects**:
  /// - Updates Hive cache with tree structure
  /// - Triggers Firestore sync (background)
  ///
  /// **Use Case**: Persist tree state after user navigates or adds message
  Future<Either<Failure, void>> saveTree(ConversationTree tree);

  /// Load conversation tree from persistent storage
  ///
  /// **Parameters**:
  /// - `userId`: User ID to load tree for
  ///
  /// **Returns**: ConversationTree (empty if no tree exists)
  ///
  /// **Data Flow**:
  /// 1. Query Hive cache (instant)
  /// 2. If cache miss → fetch from Firestore
  /// 3. Update Hive cache with latest tree
  ///
  /// **Use Case**: Initialize chat screen with tree state
  Future<Either<Failure, ConversationTree>> loadTree({
    required String userId,
  });

  /// Watch conversation tree for real-time updates
  ///
  /// **Parameters**:
  /// - `userId`: User ID to watch
  ///
  /// **Returns**: Stream of ConversationTree (emits on every tree update)
  ///
  /// **Data Flow**:
  /// 1. Listen to Hive box changes
  /// 2. Emit updated tree on every add/navigate
  /// 3. Auto-cancel when screen disposed
  ///
  /// **Use Case**: Reactive tree UI (auto-update navigation controls)
  Stream<Either<Failure, ConversationTree>> watchTree({
    required String userId,
  });

  /// Clear conversation tree for user
  ///
  /// **Parameters**:
  /// - `userId`: User ID to clear tree for
  ///
  /// **Side Effects**:
  /// - Deletes tree from Hive cache
  /// - Triggers Firestore delete (background)
  ///
  /// **Use Case**: "Start Fresh" button (clears tree + messages)
  Future<Either<Failure, void>> clearTree({
    required String userId,
  });
}
