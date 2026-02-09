/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: AI Coach
/// 🔧 Type: widget
///
/// SmartSuggestionsOverlay - Contextual suggestions dropdown
///
/// **Purpose**: Shows exercise suggestions above the chat input
/// when user types exercise names. Inspired by Perplexity AI.
///
/// **Behavior**:
/// - Appears when suggestions are available
/// - Shows exercise name with session count badge
/// - Lists clickable questions for exercises with data
/// - Shows "No data available" for exercises without history
/// - Disappears when suggestions are empty or cleared
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/exercise_suggestion.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/exercise_suggestions_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Overlay showing contextual suggestions above the input
///
/// Position this widget directly above the AIInputBar in a Column.
/// It will collapse to zero height when no suggestions are available.
class SmartSuggestionsOverlay extends ConsumerWidget {
  const SmartSuggestionsOverlay({
    super.key,
    required this.onSelect,
  });

  /// Called when user taps a suggestion
  /// [fullQuestion] is the complete question to send to chat
  final void Function(String fullQuestion) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(exerciseSuggestionsProvider);

    return suggestionsAsync.when(
      loading: () => const SizedBox.shrink(), // No loading indicator (design)
      error: (_, __) => const SizedBox.shrink(), // Silent errors
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 16,
                color: context.colors.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _SuggestionCard(
                  suggestion: suggestion,
                  onQuestionTap: onSelect,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Card for a single exercise with its suggested questions
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.onQuestionTap,
  });

  final ExerciseSuggestion suggestion;
  final void Function(String) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: exercise name + session badge
        Row(
          children: [
            Icon(
              AppIcons.workout,
              size: 16,
              color: suggestion.hasData
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion.exerciseName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _SessionBadge(count: suggestion.sessionCount),
          ],
        ),
        const SizedBox(height: 8),

        // Suggested questions or "no data" message
        if (suggestion.hasData)
          ...suggestion.suggestedQuestions.map(
            (q) => _QuestionItem(
              question: q,
              onTap: () => onQuestionTap(q.fullQuestion),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              context.l10n.aiCoachNoDataAvailable,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

/// Clickable question item
class _QuestionItem extends StatelessWidget {
  const _QuestionItem({
    required this.question,
    required this.onTap,
  });

  final SuggestedQuestion question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Icon(
              question.icon,
              size: 14,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question.displayText,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: 14,
              color: context.colors.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge showing session count
class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final hasData = count > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: hasData
            ? context.colors.primaryContainer
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        context.l10n.aiCoachSessionsCount(count),
        style: context.textTheme.labelSmall?.copyWith(
          color: hasData
              ? context.colors.onPrimaryContainer
              : context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
