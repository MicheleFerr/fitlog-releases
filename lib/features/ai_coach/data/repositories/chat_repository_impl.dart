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

import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/chat_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/chatbot_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/hive_chat_local_datasource.dart';
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
  final ChatBotDatasource botDatasource;
  final HiveChatLocalDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  ChatRepositoryImpl({
    required this.botDatasource,
    required this.localDatasource,
  });

  // ========================================================================
  // Message Streaming
  // ========================================================================

  @override
  Stream<Either<Failure, AIMessage>> sendMessage({
    required String message,
    required String userId,
    String? systemPrompt,
  }) async* {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Sending message for user: $userId');
        debugPrint('💬 [ChatBot] Message: $message');
      }

      // 1. Save user message to Hive immediately
      final userMessage = AIMessage(
        id: _uuid.v4(),
        content: message,
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

      // TODO: Fetch username from user profile provider
      final userContext = {
        'username': 'User', // TODO: Get real name from auth/profile
        'locale': localeCode, // ✅ FIXED: Now uses real locale!
      };

      // 3. Stream bot response
      await for (final botMessage in botDatasource.sendMessage(
        prompt: message,
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
        debugPrint('💬 [ChatBot] Fetching conversation history for user: $userId');
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

      return Left(CacheFailure('Failed to load conversation history'));
    }
  }

  @override
  Stream<Either<Failure, List<AIMessage>>> watchConversation({
    required String userId,
  }) async* {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Watching conversation for user: $userId');
      }

      // Stream updates from Hive (reactive)
      await for (final messages in localDatasource.watchMessages(userId: userId)) {
        yield Right(messages);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatBot] Error watching conversation: $e');
      }

      yield Left(CacheFailure('Failed to watch conversation updates'));
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
        debugPrint('💬 [ChatBot] Clearing conversation history for user: $userId');
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

      return Left(CacheFailure('Failed to clear conversation history'));
    }
  }

  @override
  Future<Either<Failure, String>> getConversationContext({
    required String userId,
    int messageCount = 10,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('💬 [ChatBot] Getting conversation context for user: $userId');
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

      return Left(CacheFailure('Failed to get conversation context'));
    }
  }
}
