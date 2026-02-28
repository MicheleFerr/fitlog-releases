/// AI Coach Screen
///
/// Main chat interface for AI Coach feature.
/// Displays messages, typing indicator, input bar, and rate limit warnings.
/// Auto-scrolls on new messages for better UX.
///
/// **Layer**: Presentation - Screen
/// **Feature**: AI Coach
library;

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_chat_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_input_bar.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_typing_indicator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_coach_disclaimer_dialog.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/exercise_suggestions_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/smart_suggestions_overlay.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/quick_exercise_picker.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/default_set_rep_setup_sheet.dart';
import 'package:go_router/go_router.dart';

/// AI Coach chat screen
class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  static const String _openSettingsCommand = '__OPEN_SETTINGS__';
  static final RegExp _addWithExercisePattern = RegExp(
    r'\baggiungi\s+"[^"]+"\s+al\s+template\b',
    caseSensitive: false,
  );
  static final RegExp _removeWithExercisePattern = RegExp(
    r'\brimuovi\s+"[^"]+"\s+dal\s+template\b',
    caseSensitive: false,
  );
  static final RegExp _replaceWithPairPattern = RegExp(
    r'\bsostituisci\s+"[^"]+"\s+con\s+"[^"]+"\s+nel\s+template\b',
    caseSensitive: false,
  );
  static final RegExp _templateQuotedPattern = RegExp(
    r'template\s+"([^"]+)"',
    caseSensitive: false,
  );
  static final RegExp _replaceNewQuotedPattern = RegExp(
    r'\bcon\s+"([^"]+)"',
    caseSensitive: false,
  );
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;
  bool _disclaimerChecked = false;
  bool _disclaimerAccepted = false;
  String? _lastFailedMessage;
  bool _isNearBottom = true;
  List<CommunityWorkoutTemplate>? _templateCache;
  DateTime? _templateCacheAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_metricsObserver);
    _scrollController.addListener(_onScrollChanged);
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
    WidgetsBinding.instance.removeObserver(_metricsObserver);
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  late final WidgetsBindingObserver _metricsObserver = _KeyboardMetricsObserver(
    onMetricsChanged: () {
      if (_isNearBottom) {
        _scrollToBottom();
      }
    },
  );

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final distanceFromBottom =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    final nextNearBottom = distanceFromBottom <= 96;
    if (nextNearBottom != _isNearBottom && mounted) {
      setState(() => _isNearBottom = nextNearBottom);
    }
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
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final appConfig = ref.watch(appConfigProvider);

    // Detect active workout mini-bar to add extra bottom padding
    final workout = ref.watch(currentWorkoutProvider);
    final hasMiniBar =
        workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused);

    // Auto-scroll when new messages arrive — ref.listen evita side effect nel build()
    ref.listen<AIChatState>(aIChatProvider, (previous, next) {
      if (next.messages.length > _previousMessageCount) {
        _previousMessageCount = next.messages.length;
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 12,
        title: _buildAppBarTitle(context, chatState.quota),
        actions: [
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.help,
              semanticLabel: 'Guida AI Coach',
            ),
            onPressed: () => _showQuickGuideSheet(context),
            tooltip: 'Guida rapida',
          ),
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.delete,
              semanticLabel: context.l10n.delete,
            ),
            onPressed: () => _showClearDialog(context),
            tooltip: context.l10n.clearConversation,
          ),
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.moreVert,
              semanticLabel: 'More options',
            ),
            onPressed: () => _showOptionsSheet(context),
          ),
        ],
      ),
      floatingActionButton:
          (_shouldShowScrollToBottom(chatState, keyboardVisible))
          ? FloatingActionButton.small(
              heroTag: 'ai_coach_scroll_bottom_fab',
              onPressed: _scrollToBottom,
              tooltip: 'Vai in fondo',
              child: const Icon(AppIcons.keyboardArrowDownRounded),
            )
          : null,
      body: Column(
        children: [
          _buildContextUsageRow(context, chatState.messages),

          // Messages list
          Expanded(
            child: Column(
              children: [
                // Show suggestions when chat is empty (only disclaimer)
                if (chatState.messages.length <= 1 &&
                    _shouldShowWorkoutSetupNudge(appConfig))
                  _buildWorkoutSetupNudge(context),

                if (chatState.messages.length <= 1)
                  _buildSuggestionChips(context),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];

                      // Don't show system messages (disclaimer is special)
                      if (message.role == MessageRole.system &&
                          message.id != 'disclaimer') {
                        return const SizedBox.shrink();
                      }

                      final isLastMessage =
                          index == chatState.messages.length - 1;
                      return AIMessageBubble(
                        message: message,
                        isFromUser: message.role == MessageRole.user,
                        animate: isLastMessage,
                        onSuggestionTap: (exercise) {
                          if (message.isDisambiguation) {
                            // Disambiguation: send exercise name directly
                            _handleInlineCommandOrSend(exercise);
                          } else {
                            // Generic quick reply suggestion from AI/tool result
                            _handleInlineCommandOrSend(exercise);
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
          if (chatState.isLoading) const AITypingIndicator(),

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
                  const SizedBox(height: 8),
                  _buildErrorQuickActions(context, chatState.error!),
                ],
              ),
            ),

          // Smart suggestions overlay + Input bar
          // Use tabBarInset to position above the overlay tab bar
          // Add extra padding when workout mini-bar is visible (56h + 8gap + 8breathing)
          AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(
              bottom: context.tabBarInset + (hasMiniBar ? 72.0 : 0.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPersistentStarterBar(context),
                SmartSuggestionsOverlay(onSelect: _onSuggestionSelected),
                AIInputBar(
                  onSend: (text) {
                    // Clear suggestions when sending
                    ref.read(exerciseSuggestionsProvider.notifier).clear();
                    setState(() => _lastFailedMessage = text);
                    _handleInlineCommandOrSend(text);
                    _scrollToBottom();
                  },
                  onTextChanged: _onInputTextChanged,
                  onFieldTap: _scrollToBottom,
                  isLoading: chatState.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowScrollToBottom(AIChatState chatState, bool keyboardVisible) {
    final enoughMessages = chatState.messages.length > 2;
    if (!enoughMessages) return false;
    if (!_isNearBottom) return true;
    if (chatState.isLoading && keyboardVisible) return true;
    return false;
  }

  Widget _buildAppBarTitle(BuildContext context, AIQuota? quota) {
    final quotaPercent = _quotaPercentLabel(quota);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.aiCoach),
        if (quotaPercent != null)
          Text(
            quotaPercent,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  String? _quotaPercentLabel(AIQuota? quota) {
    if (quota == null || quota.limitPerDay <= 0) {
      return null;
    }
    final usedPercent = ((quota.usedToday / quota.limitPerDay) * 100)
        .clamp(0, 100)
        .round();
    return 'Quota oggi: $usedPercent%';
  }

  Widget _buildContextUsageRow(BuildContext context, List<AIMessage> messages) {
    final conversationMessages = messages
        .where((m) => m.role != MessageRole.system)
        .length;

    final clamped = conversationMessages > aiCoachContextWindowMaxMessages
        ? aiCoachContextWindowMaxMessages
        : conversationMessages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Contesto chat: $clamped/$aiCoachContextWindowMaxMessages messaggi recenti.',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
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
      parameters: {'question_length': fullQuestion.length},
    );

    // Clear suggestions
    ref.read(exerciseSuggestionsProvider.notifier).clear();

    // Send message
    _handleInlineCommandOrSend(fullQuestion);

    // Scroll to bottom
    _scrollToBottom();
  }

  void _showOptionsSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext sheetContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              context.goNamed(AppRoutes.aiCoachDocumentsAttributionName);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.science, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.scientificSources,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          isDefaultAction: true,
          child: Text(context.l10n.cancel),
        ),
      ),
    );
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

  void _showQuickGuideSheet(BuildContext context) {
    final quickPrompts = _starterPrompts();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final maxSheetHeight = MediaQuery.of(sheetContext).size.height * 0.72;

        return SizedBox(
          height: maxSheetHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guida rapida AI Coach',
                  style: sheetContext.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scegli una sola azione qui sotto per inviarla in chat.',
                  style: sheetContext.textTheme.bodyMedium?.copyWith(
                    color: sheetContext.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sheetContext.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Modifiche template: 1) Anteprima  2) Conferma  3) Azione',
                    style: sheetContext.textTheme.bodySmall?.copyWith(
                      color: sheetContext.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: quickPrompts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = quickPrompts[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        tileColor: context.colors.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: const Icon(AppIcons.bolt),
                        title: Text(item.title),
                        subtitle: Text(item.prompt),
                        trailing: const Icon(AppIcons.send),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _sendGuidePrompt(
                            item.prompt,
                            source: 'quick_guide_list',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<({String title, String prompt})> _starterPrompts() {
    return const <({String title, String prompt})>[
      (
        title: 'Analisi template',
        prompt: 'Analizza i miei template e dimmi punti forti/deboli.',
      ),
      (
        title: 'Allenamento oggi',
        prompt: 'Cosa alleno oggi in base al mio storico?',
      ),
      (
        title: 'Aggiungi esercizio',
        prompt: 'Aggiungi un esercizio al template UPPER POWER.',
      ),
      (
        title: 'Sostituisci esercizio',
        prompt:
            'Sostituisci un esercizio nel template LOWER HYPERTROPHY con un\'alternativa migliore.',
      ),
      (
        title: 'Rimuovi esercizio',
        prompt: 'Rimuovi un esercizio dal template UPPER HYPERTROPHY.',
      ),
      (
        title: 'Bilanciamento muscolare',
        prompt: 'Mostrami il mio bilanciamento muscolare e cosa migliorare.',
      ),
    ];
  }

  Widget _buildPersistentStarterBar(BuildContext context) {
    final prompts = _starterPrompts();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = prompts[index];
          return ActionChip(
            avatar: const Icon(AppIcons.bolt, size: 14),
            label: Text(item.title),
            onPressed: () =>
                _sendGuidePrompt(item.prompt, source: 'persistent_starter_bar'),
          );
        },
      ),
    );
  }

  Widget _buildErrorQuickActions(BuildContext context, String error) {
    final lower = error.toLowerCase();
    final actions = <({String label, String prompt})>[];

    if (lower.contains('template') || lower.contains('nome template')) {
      actions.add((
        label: 'Mostra i miei template',
        prompt: 'Mostrami i miei template salvati.',
      ));
      actions.add((
        label: 'Analizza template',
        prompt: 'Analizza i miei template e guidami nella scelta.',
      ));
    }

    if (lower.contains('esercizio') || lower.contains('non trovato')) {
      actions.add((
        label: 'Trova esercizio simile',
        prompt: 'Trova esercizi simili per lo stesso gruppo muscolare.',
      ));
    }

    if (actions.isEmpty) {
      actions.add((
        label: 'Come usare AI Coach',
        prompt: 'Spiegami come usare al meglio AI Coach con esempi pratici.',
      ));
      actions.add((
        label: 'Cosa alleno oggi?',
        prompt: 'Cosa alleno oggi in base al mio recupero?',
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: actions.map((action) {
        return ActionChip(
          label: Text(action.label),
          onPressed: () =>
              _sendGuidePrompt(action.prompt, source: 'error_context_action'),
        );
      }).toList(),
    );
  }

  void _sendGuidePrompt(String prompt, {required String source}) {
    ref.read(exerciseSuggestionsProvider.notifier).clear();
    setState(() => _lastFailedMessage = prompt);
    _handleInlineCommandOrSend(prompt);
    _scrollToBottom();
    FirebaseAnalytics.instance.logEvent(
      name: 'ai_coach_quick_guide_prompt_selected',
      parameters: {'prompt_length': prompt.length, 'source': source},
    );
  }

  Widget _buildSuggestionChips(BuildContext context) {
    final suggestions = [
      context.l10n.aiCoachSuggestion1,
      context.l10n.aiCoachSuggestion2,
      context.l10n.aiCoachSuggestion3,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _handleInlineCommandOrSend(suggestion);
                  _scrollToBottom();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _shouldShowWorkoutSetupNudge(AppConfig appConfig) {
    return appConfig.defaultExerciseSets == 4 &&
        appConfig.defaultExerciseReps == 8 &&
        appConfig.defaultRestTime == 90 &&
        appConfig.defaultRestBetweenExercises == 90;
  }

  Widget _buildWorkoutSetupNudge(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setup guidato preferenze',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Imposta rapidamente preset serie/ripetizioni (5×5, 4×8...) e recuperi.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(AppIcons.bolt, size: 14),
                  label: const Text('Avvia setup guidato'),
                  onPressed: () => _handleInlineCommandOrSend(
                    'Guidami a personalizzare set, ripetizioni e recuperi passo passo.',
                  ),
                ),
                ActionChip(
                  avatar: const Icon(AppIcons.settings, size: 14),
                  label: const Text('Apri impostazioni'),
                  onPressed: () => DefaultSetRepSetupSheet.show(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleInlineCommandOrSend(String input) {
    final trimmed = input.trim();
    if (trimmed == _openSettingsCommand) {
      unawaited(DefaultSetRepSetupSheet.show(context, ref));
      return;
    }
    if (_shouldInterceptTemplateAction(trimmed)) {
      unawaited(_handleTemplateActionWithPicker(trimmed));
      return;
    }
    ref.read(aIChatProvider.notifier).sendMessage(trimmed);
  }

  bool _shouldInterceptTemplateAction(String command) {
    final lower = command.toLowerCase();
    if (!lower.contains('template')) return false;
    if (lower.startsWith('confermo:')) return false;

    final isAddIntent = lower.contains('aggiungi');
    final isRemoveIntent = lower.contains('rimuovi');
    final isReplaceIntent = lower.contains('sostituis');

    if (isAddIntent && !_addWithExercisePattern.hasMatch(command)) {
      return true;
    }
    if (isRemoveIntent && !_removeWithExercisePattern.hasMatch(command)) {
      return true;
    }
    if (isReplaceIntent && !_replaceWithPairPattern.hasMatch(command)) {
      return true;
    }
    return false;
  }

  Future<void> _handleTemplateActionWithPicker(String originalCommand) async {
    final lower = originalCommand.toLowerCase();
    if (lower.contains('aggiungi') &&
        !_addWithExercisePattern.hasMatch(originalCommand)) {
      await _handleAddWithExercisePicker(originalCommand);
      return;
    }
    if (lower.contains('rimuovi') &&
        !_removeWithExercisePattern.hasMatch(originalCommand)) {
      await _handleRemoveWithTemplatePicker(originalCommand);
      return;
    }
    if (lower.contains('sostituis') &&
        !_replaceWithPairPattern.hasMatch(originalCommand)) {
      await _handleReplaceWithExercisePicker(originalCommand);
      return;
    }
    _dispatchMessage(originalCommand);
  }

  Future<void> _handleAddWithExercisePicker(String originalCommand) async {
    final selectedTemplate = await _resolveTemplateFromCommand(originalCommand);
    if (selectedTemplate == null || !mounted) {
      _dispatchMessage(originalCommand);
      return;
    }

    final pickedExercise = await context.showQuickExercisePicker();
    if (pickedExercise == null || !mounted) return;

    final command =
        'Aggiungi "${pickedExercise.nome}" al template "${selectedTemplate.name}".';
    _dispatchMessage(command);
  }

  Future<void> _handleRemoveWithTemplatePicker(String originalCommand) async {
    final selectedTemplate = await _resolveTemplateFromCommand(originalCommand);
    if (selectedTemplate == null || !mounted) {
      _dispatchMessage(originalCommand);
      return;
    }

    final exerciseNames = _extractTemplateExerciseNames(selectedTemplate);
    if (exerciseNames.isEmpty) {
      _dispatchMessage(originalCommand);
      return;
    }

    final selectedExercise = await _showTemplateExercisePickerModal(
      title: 'Seleziona esercizio da rimuovere',
      templateName: selectedTemplate.name,
      exerciseNames: exerciseNames,
    );
    if (selectedExercise == null || !mounted) return;

    final command =
        'Rimuovi "$selectedExercise" dal template "${selectedTemplate.name}".';
    _dispatchMessage(command);
  }

  Future<void> _handleReplaceWithExercisePicker(String originalCommand) async {
    final selectedTemplate = await _resolveTemplateFromCommand(originalCommand);
    if (selectedTemplate == null || !mounted) {
      _dispatchMessage(originalCommand);
      return;
    }

    final exerciseNames = _extractTemplateExerciseNames(selectedTemplate);
    if (exerciseNames.isEmpty) {
      _dispatchMessage(originalCommand);
      return;
    }

    final exerciseToReplace = await _showTemplateExercisePickerModal(
      title: 'Quale esercizio vuoi sostituire?',
      templateName: selectedTemplate.name,
      exerciseNames: exerciseNames,
    );
    if (exerciseToReplace == null || !mounted) return;

    final quotedNewExercise = _extractQuotedNewExercise(originalCommand);
    String? replacementExerciseName = quotedNewExercise;
    if (replacementExerciseName == null || replacementExerciseName.isEmpty) {
      final pickedExercise = await context.showQuickExercisePicker();
      if (pickedExercise == null || !mounted) return;
      replacementExerciseName = pickedExercise.nome;
    }

    if (_normalizeForLookup(replacementExerciseName) ==
        _normalizeForLookup(exerciseToReplace)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Scegli un esercizio diverso da quello che vuoi sostituire.',
            ),
          ),
        );
      }
      return;
    }

    final command =
        'Sostituisci "$exerciseToReplace" con "$replacementExerciseName" nel template "${selectedTemplate.name}".';
    _dispatchMessage(command);
  }

  Future<List<CommunityWorkoutTemplate>> _loadUserTemplates({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _templateCache != null &&
        _templateCacheAt != null &&
        DateTime.now().difference(_templateCacheAt!) <
            const Duration(minutes: 2)) {
      return _templateCache!;
    }
    final templates = await ref
        .read(templateRepositoryProvider)
        .getUserTemplates();
    _templateCache = templates;
    _templateCacheAt = DateTime.now();
    return templates;
  }

  Future<CommunityWorkoutTemplate?> _resolveTemplateFromCommand(
    String command,
  ) async {
    try {
      final templates = await _loadUserTemplates();
      if (templates.isEmpty) return null;

      final quotedMatch = _templateQuotedPattern.firstMatch(command);
      final quotedTemplateName = quotedMatch?.group(1)?.trim();
      if (quotedTemplateName != null && quotedTemplateName.isNotEmpty) {
        final normalizedQuoted = _normalizeForLookup(quotedTemplateName);
        final exactMatch = templates.firstWhere(
          (template) => _normalizeForLookup(template.name) == normalizedQuoted,
          orElse: () => templates.first,
        );
        if (_normalizeForLookup(exactMatch.name) == normalizedQuoted) {
          return exactMatch;
        }
      }

      final normalizedCommand = _normalizeForLookup(command);
      final templateMatches = templates.where((template) {
        final normalizedTemplateName = _normalizeForLookup(template.name);
        return normalizedTemplateName.isNotEmpty &&
            normalizedCommand.contains(normalizedTemplateName);
      }).toList()..sort((a, b) => b.name.length.compareTo(a.name.length));

      if (templateMatches.isNotEmpty) {
        return templateMatches.first;
      }

      if (quotedTemplateName != null && quotedTemplateName.isNotEmpty) {
        final normalizedQuoted = _normalizeForLookup(quotedTemplateName);
        final fuzzyMatches = templates.where((template) {
          final normalizedTemplateName = _normalizeForLookup(template.name);
          return normalizedTemplateName.contains(normalizedQuoted) ||
              normalizedQuoted.contains(normalizedTemplateName);
        }).toList()..sort((a, b) => b.name.length.compareTo(a.name.length));
        if (fuzzyMatches.isNotEmpty) {
          return fuzzyMatches.first;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<String> _extractTemplateExerciseNames(
    CommunityWorkoutTemplate template,
  ) {
    final uniqueNames = <String>{};
    for (final exercise in template.exercises) {
      final trimmedName = exercise.name.trim();
      if (trimmedName.isEmpty) continue;
      uniqueNames.add(trimmedName);
    }
    return uniqueNames.toList(growable: false);
  }

  Future<String?> _showTemplateExercisePickerModal({
    required String title,
    required String templateName,
    required List<String> exerciseNames,
  }) async {
    var query = '';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final normalizedQuery = _normalizeForLookup(query);
            final filteredExercises = exerciseNames.where((name) {
              if (normalizedQuery.isEmpty) return true;
              return _normalizeForLookup(name).contains(normalizedQuery);
            }).toList();

            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(modalContext).size.height * 0.72,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: modalContext.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        templateName,
                        style: modalContext.textTheme.bodySmall?.copyWith(
                          color: modalContext.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Cerca esercizio nel template',
                          prefixIcon: Icon(AppIcons.search),
                        ),
                        onChanged: (value) =>
                            setModalState(() => query = value),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredExercises.isEmpty
                            ? Center(
                                child: Text(
                                  'Nessun esercizio trovato',
                                  style: modalContext.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: modalContext
                                            .colors
                                            .onSurfaceVariant,
                                      ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: filteredExercises.map((exercise) {
                                    return ActionChip(
                                      label: Text(exercise),
                                      onPressed: () =>
                                          Navigator.pop(sheetContext, exercise),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _normalizeForLookup(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9à-ÿ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _extractQuotedNewExercise(String command) {
    final match = _replaceNewQuotedPattern.firstMatch(command);
    final value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  void _dispatchMessage(String message) {
    if (!mounted) return;
    ref.read(exerciseSuggestionsProvider.notifier).clear();
    setState(() => _lastFailedMessage = message);
    _templateCache = null;
    _templateCacheAt = null;
    ref.read(aIChatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }
}

class _KeyboardMetricsObserver extends WidgetsBindingObserver {
  _KeyboardMetricsObserver({required this.onMetricsChanged});

  final VoidCallback onMetricsChanged;

  @override
  void didChangeMetrics() {
    onMetricsChanged();
  }
}
