/// AI Coach Screen
///
/// Main chat interface for AI Coach feature.
/// Displays messages, typing indicator, input bar, and rate limit warnings.
///
/// **Layer**: Presentation - Screen
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_chat_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_input_bar.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_rate_limit_banner.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_typing_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// AI Coach chat screen
class AICoachScreen extends ConsumerWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);
    final rateLimitAsync = ref.watch(aiRateLimitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Coach'),
        actions: [
          IconButton(
            icon: Icon(AppIcons.delete),
            onPressed: () => _showClearDialog(context, ref),
            tooltip: 'Cancella conversazione',
          ),
        ],
      ),
      body: Column(
        children: [
          // Rate limit warning banner
          rateLimitAsync.when(
            data: (rateLimit) {
              if (rateLimit.isThrottled || rateLimit.isBlocked) {
                return AIRateLimitBanner(
                  message: rateLimit.message,
                  isCritical: rateLimit.isBlocked,
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];

                // Don't show system messages (disclaimer is special)
                if (message.role == MessageRole.system && message.id != 'disclaimer') {
                  return const SizedBox.shrink();
                }

                return AIMessageBubble(
                  message: message,
                  isFromUser: message.role == MessageRole.user,
                );
              },
            ),
          ),

          // Typing indicator
          if (chatState.isLoading) const AITypingIndicator(),

          // Error message
          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                chatState.error!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Input bar
          AIInputBar(
            onSend: (text) => ref.read(aiChatProvider.notifier).sendMessage(text),
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancella conversazione'),
        content: Text(
          'Vuoi cancellare tutti i messaggi? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearMessages();
              Navigator.pop(context);
            },
            child: Text('Cancella'),
          ),
        ],
      ),
    );
  }
}
