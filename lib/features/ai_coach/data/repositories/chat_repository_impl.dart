/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository_implementation
///
/// Chat Repository Implementation - Pattern-Based Bot + Hive Cache
///
/// **Data Sources**:
/// - **ChatBotDatasource**: Local pattern-based bot (NO LLM, NO API)
/// - **HiveChatLocalDatasource**: Conversation history cache (instant, offline)
///
/// **Architecture**:
/// - Write-through caching: Save to Hive immediately
/// - Offline-first: All responses generated locally
/// - Reactive streams: Real-time updates via Hive watch
///
/// **No External Dependencies**: 100% local, instant, free, private
library;

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/conversation_tree.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/chat_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/chatbot_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/hive_chat_local_datasource.dart';
import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart'; // 🔐 SECURITY: XSS/injection prevention
import 'package:uuid/uuid.dart';

/// Chat repository implementation (pattern-based bot)
///
/// **Usage (Provider)**:
/// ```dart
/// final chatRepositoryProvider = Provider<ChatRepository>((ref) {
///   final botDatasource = ref.read(chatBotDatasourceProvider);
///   final hiveDatasource = ref.read(hiveChatDatasourceProvider);
///
///   return ChatRepositoryImpl(
///     botDatasource: botDatasource,
///     localDatasource: hiveDatasource,
///   );
/// });
/// ```
class ChatRepositoryImpl implements ChatRepository {

  ChatRepositoryImpl({
    required this.botDatasource,
    required this.localDatasource,
  });
  final ChatBotDatasource botDatasource;
  final HiveChatLocalDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  /// 🔐 SECURITY: Input validator for XSS/injection prevention
  final InputValidator _validator = InputValidator();

  // ========================================================================
  // Message Streaming
  // ========================================================================

  @override
  Stream<Either<Failure, AIMessage>> sendMessage({
    required String message,
    required String userId,
    String? userName,
    String? systemPrompt,
  }) async* {
    try {
      // 🔐 SECURITY: Sanitize user input to prevent XSS/injection attacks
      final sanitizedMessage = _validator.sanitize(message);

      // 🔐 SECURITY: Check for dangerous patterns
      if (_validator.containsDangerousPatterns(message)) {
        yield const Left(
          ValidationFailure(
            'Invalid characters detected in message',
            code: 'DANGEROUS_PATTERNS_DETECTED',
          ),
        );
        return;
      }

      // Validate message length after sanitization
      if (sanitizedMessage.trim().isEmpty) {
        yield const Left(
          ValidationFailure(
            'Message cannot be empty',
            code: 'EMPTY_MESSAGE',
          ),
        );
        return;
      }

      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Sending message for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
        // Only log first 50 chars of sanitized message (avoid logging full user input)
        final logPreview = sanitizedMessage.length > 50
            ? '${sanitizedMessage.substring(0, 50)}...'
            : sanitizedMessage;
        debugPrint('💬 [ChatBot] Message preview: $logPreview');
      }

      // 1. Save user message to Hive immediately (with sanitized content)
      final userMessage = AIMessage(
        id: _uuid.v4(),
        content: sanitizedMessage, // 🔐 SECURITY: Using sanitized message
        role: MessageRole.user,
        timestamp: DateTime.now(),
        isStreaming: false,
      );

      await localDatasource.saveMessage(
        userId: userId,
        message: userMessage,
      );

      if (kDebugMode) {
        debugPrint('💬 [ChatBot] User message saved to Hive');
      }

      // 2. Get user context (name, locale, preferences)
      // Get locale from platform (respects device/app language settings)
      final platformLocale = PlatformDispatcher.instance.locale;
      final localeCode = platformLocale.languageCode; // 'en', 'it', etc.

      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Using locale: $localeCode (from platform: ${platformLocale.toString()})');
      }

      // Use provided userName or fallback to generic name
      final displayName = userName ?? 'GymBro';
      final userContext = {
        'username': displayName,
        'locale': localeCode,
      };

      // 3. Stream bot response (use sanitized message for bot prompt)
      await for (final botMessage in botDatasource.sendMessage(
        prompt: sanitizedMessage, // 🔐 SECURITY: Using sanitized message
        userId: userId,
        userContext: userContext,
      )) {
        // Save final (non-streaming) message to Hive
        if (!botMessage.isStreaming) {
          await localDatasource.saveMessage(
            userId: userId,
            message: botMessage,
          );

          if (kDebugMode) {
            debugPrint('💬 [ChatBot] Bot response saved to Hive');
          }
        }

        // Emit message chunk
        yield Right(botMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error sending message: $e');
      }

      yield Left(UnexpectedFailure('Failed to send message: ${e.toString()}'));
    }
  }

  // ========================================================================
  // Conversation History
  // ========================================================================

  @override
  Future<Either<Failure, List<AIMessage>>> getConversationHistory({
    required String userId,
    int limit = 50,
    DateTime? beforeTimestamp,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Fetching conversation history for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
        debugPrint('💬 [ChatBot] Limit: $limit, beforeTimestamp: $beforeTimestamp');
      }

      // Fetch from Hive cache (instant, ~2ms)
      final messages = await localDatasource.getMessages(
        userId: userId,
        limit: limit,
        beforeTimestamp: beforeTimestamp,
      );

      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Loaded ${messages.length} messages from Hive');
      }

      return Right(messages);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error fetching conversation history: $e');
      }

      return const Left(CacheFailure('Failed to load conversation history'));
    }
  }

  @override
  Stream<Either<Failure, List<AIMessage>>> watchConversation({
    required String userId,
  }) async* {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Watching conversation for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
      }

      // Stream updates from Hive (reactive)
      await for (final messages in localDatasource.watchMessages(userId: userId)) {
        yield Right(messages);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error watching conversation: $e');
      }

      yield const Left(CacheFailure('Failed to watch conversation updates'));
    }
  }

  // ========================================================================
  // Conversation Management
  // ========================================================================

  @override
  Future<Either<Failure, void>> clearHistory({
    required String userId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Clearing conversation history for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
      }

      // Clear from Hive cache
      await localDatasource.clearHistory(userId: userId);

      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Conversation history cleared');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error clearing conversation history: $e');
      }

      return const Left(CacheFailure('Failed to clear conversation history'));
    }
  }

  @override
  Future<Either<Failure, String>> getConversationContext({
    required String userId,
    int messageCount = 10,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Getting conversation context for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
      }

      // Fetch last N messages from cache
      final messages = await localDatasource.getMessages(
        userId: userId,
        limit: messageCount,
      );

      // Format as "User: ...\nBot: ..." string
      final buffer = StringBuffer();
      for (final message in messages.reversed) {
        // Reverse to get chronological order
        final roleName = message.role == MessageRole.user ? 'User' : 'Bot';
        buffer.writeln('$roleName: ${message.content}');
      }

      final context = buffer.toString().trim();

      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Context length: ${context.length} characters');
      }

      return Right(context);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error getting conversation context: $e');
      }

      return const Left(CacheFailure('Failed to get conversation context'));
    }
  }

  // ========================================================================
  // Conversation Tree Navigation
  // ========================================================================

  @override
  Future<Either<Failure, void>> saveTree(ConversationTree tree) async {
    try {
      if (kDebugMode) {
        debugPrint('🌲 [ChatBot] Saving conversation tree for user: ${tree.userId.substring(0, 8.clamp(0, tree.userId.length))}...');
      }

      await localDatasource.saveTree(tree);

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error saving tree: $e');
      }

      return const Left(CacheFailure('Failed to save conversation tree'));
    }
  }

  @override
  Future<Either<Failure, ConversationTree>> loadTree({
    required String userId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🌲 [ChatBot] Loading conversation tree for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
      }

      final tree = await localDatasource.loadTree(userId: userId);

      return Right(tree);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error loading tree: $e');
      }

      return const Left(CacheFailure('Failed to load conversation tree'));
    }
  }

  @override
  Stream<Either<Failure, ConversationTree>> watchTree({
    required String userId,
  }) async* {
    try {
      if (kDebugMode) {
        debugPrint('🌲 [ChatBot] Watching conversation tree for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
      }

      // Stream updates from Hive (reactive)
      await for (final tree in localDatasource.watchTree(userId: userId)) {
        yield Right(tree);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error watching tree: $e');
      }

      yield const Left(CacheFailure('Failed to watch conversation tree updates'));
    }
  }

  @override
  Future<Either<Failure, void>> clearTree({
    required String userId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🌲 [ChatBot] Clearing conversation tree for user: ${userId.substring(0, 8.clamp(0, userId.length))}...');
      }

      await localDatasource.clearTree(userId: userId);

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error clearing tree: $e');
      }

      return const Left(CacheFailure('Failed to clear conversation tree'));
    }
  }
}
