/// AI Coach Screen
///
/// Main chat interface for AI Coach feature.
/// Displays messages, typing indicator, input bar, and rate limit warnings.
/// Auto-scrolls on new messages for better UX.
///
/// **Layer**: Presentation - Screen
/// **Feature**: AI Coach
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_chat_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_input_bar.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_rate_limit_banner.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_typing_indicator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_coach_disclaimer_dialog.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/exercise_suggestions_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/smart_suggestions_overlay.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

/// AI Coach chat screen
class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;
  bool _disclaimerChecked = false;
  bool _disclaimerAccepted = false;
  String? _lastFailedMessage;

  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  /// Check and show disclaimer on first access
  Future<void> _checkDisclaimer() async {
    // Check if already accepted (cached)
    final accepted = await AICoachDisclaimerDialog.hasAccepted();
    if (mounted) {
      setState(() {
        _disclaimerChecked = true;
        _disclaimerAccepted = accepted;
      });

      // Show dialog if not yet accepted
      if (!accepted) {
        // Wait for build to complete before showing dialog
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            final result = await AICoachDisclaimerDialog.show(context);
            if (mounted) {
              if (result) {
                setState(() => _disclaimerAccepted = true);
              } else {
                // User cancelled - go back
                context.pop();
              }
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return; // evita animazione su widget dispose
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking disclaimer
    if (!_disclaimerChecked) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.aiCoach)),
        body: const Center(child: LoadingIndicator()),
      );
    }

    // Show empty state if disclaimer not accepted (will pop shortly)
    if (!_disclaimerAccepted) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.aiCoach)),
        body: const SizedBox.shrink(),
      );
    }

    final chatState = ref.watch(aIChatProvider);
    final rateLimitAsync = ref.watch(aIRateLimitProvider);

    // Auto-scroll when new messages arrive — ref.listen evita side effect nel build()
    ref.listen<ChatState>(aIChatProvider, (previous, next) {
      if (next.messages.length > _previousMessageCount) {
        _previousMessageCount = next.messages.length;
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aiCoach),
        actions: [
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.delete,
              semanticLabel: context.l10n.delete,
            ),
            onPressed: () => _showClearDialog(context),
            tooltip: context.l10n.clearConversation,
          ),
          PopupMenuButton<String>(
            icon: SemanticIcon.button(
              icon: AppIcons.moreVert,
              semanticLabel: 'More options',
            ),
            onSelected: (value) {
              if (value == 'sources') {
                context.goNamed(AppRoutes.aiCoachDocumentsAttributionName);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sources',
                child: Row(
                  children: [
                    const Icon(AppIcons.science, size: 20),
                    const SizedBox(width: 12),
                    Text(context.l10n.scientificSources),
                  ],
                ),
              ),
            ],
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
            child: Column(
              children: [
                // Show suggestions when chat is empty (only disclaimer)
                if (chatState.messages.length <= 1)
                  _buildSuggestionChips(context),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];

                      // Don't show system messages (disclaimer is special)
                      if (message.role == MessageRole.system &&
                          message.id != 'disclaimer') {
                        return const SizedBox.shrink();
                      }

                      return AIMessageBubble(
                        message: message,
                        isFromUser: message.role == MessageRole.user,
                        onSuggestionTap: (exercise) {
                          if (message.isDisambiguation) {
                            // Disambiguation: send exercise name directly
                            ref.read(aIChatProvider.notifier).sendMessage(exercise);
                          } else {
                            // Suggestion: ask about the exercise
                            ref
                                .read(aIChatProvider.notifier)
                                .sendMessage('Qual e il mio massimale su $exercise?');
                          }
                          _scrollToBottom();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Typing indicator
          if (chatState.isLoading) AITypingIndicator(),

          // Error message with retry button
          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    chatState.error!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_lastFailedMessage != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        final message = _lastFailedMessage!;
                        ref.read(aIChatProvider.notifier).sendMessage(message);
                        _scrollToBottom();
                      },
                      icon: const Icon(AppIcons.refresh),
                      label: Text(context.l10n.retry),
                    ),
                  ],
                ],
              ),
            ),

          // Smart suggestions overlay + Input bar
          // Use tabBarInset to position above the overlay tab bar
          Padding(
            padding: EdgeInsets.only(
              bottom: context.tabBarInset,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmartSuggestionsOverlay(
                  onSelect: _onSuggestionSelected,
                ),
                AIInputBar(
                  onSend: (text) {
                    // Clear suggestions when sending
                    ref.read(exerciseSuggestionsProvider.notifier).clear();
                    setState(() => _lastFailedMessage = text);
                    ref.read(aIChatProvider.notifier).sendMessage(text);
                    _scrollToBottom();
                  },
                  onTextChanged: _onInputTextChanged,
                  isLoading: chatState.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle input text changes for smart suggestions
  void _onInputTextChanged(String text) {
    ref.read(exerciseSuggestionsProvider.notifier).updateQuery(text);
  }

  /// Handle suggestion selection
  void _onSuggestionSelected(String fullQuestion) {
    // Track analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'ai_coach_suggestion_selected',
      parameters: {
        'question_length': fullQuestion.length,
      },
    );

    // Clear suggestions
    ref.read(exerciseSuggestionsProvider.notifier).clear();

    // Send message
    ref.read(aIChatProvider.notifier).sendMessage(fullQuestion);

    // Scroll to bottom
    _scrollToBottom();
  }

  void _showClearDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearConversation),
        content: Text(l10n.clearConversationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(aIChatProvider.notifier).clearMessages();
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(BuildContext context) {
    final suggestions = [
      context.l10n.aiCoachSuggestion1,
      context.l10n.aiCoachSuggestion2,
      context.l10n.aiCoachSuggestion3,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.aiCoachSuggestionsTitle,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  ref.read(aIChatProvider.notifier).sendMessage(suggestion);
                  _scrollToBottom();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
