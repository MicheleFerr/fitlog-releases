/// Suggestion Info Sheet - Bottom sheet with suggestion details
///
/// Shows detailed information when user taps on a SmartSuggestionChip.
/// Similar design pattern to WeightJumpInfoSheet.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Shows the suggestion info bottom sheet
void showSuggestionInfoSheet(BuildContext context, SmartSuggestion suggestion) {
  HapticFeedback.lightImpact();

  ModalService.showSheet(context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SuggestionInfoSheet(suggestion: suggestion),
  );
}

/// Bottom sheet with suggestion details
class SuggestionInfoSheet extends StatelessWidget {
  const SuggestionInfoSheet({super.key, required this.suggestion});

  final SmartSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(),
                      color: _getIconColor(context),
                      size: AppIconSize.large,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitle(context),
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSubtitle(context),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  suggestion.text,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurface,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Context-specific tips
              ..._buildContextTips(context),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.understood),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    return switch (suggestion.type) {
      'tip' => AppIcons.lightbulb,
      'warning' => AppIcons.warning,
      'correction' => AppIcons.checkCircle,
      'technique' => AppIcons.workout,
      'variant' => AppIcons.swapHoriz,
      'translation' => AppIcons.language,
      _ => AppIcons.lightbulb,
    };
  }

  Color _getIconColor(BuildContext context) {
    return switch (suggestion.type) {
      'tip' => context.colors.primary,
      'warning' => context.colors.error,
      'correction' => context.colors.tertiary,
      'technique' => context.colors.secondary,
      'variant' => context.colors.primary,
      'translation' => context.colors.onSurfaceVariant,
      _ => context.colors.primary,
    };
  }

  Color _getIconBackgroundColor(BuildContext context) {
    return switch (suggestion.type) {
      'tip' => context.colors.primaryContainer,
      'warning' => context.colors.errorContainer,
      'correction' => context.colors.tertiaryContainer,
      'technique' => context.colors.secondaryContainer,
      'variant' => context.colors.primaryContainer,
      'translation' => context.colors.surfaceContainerHighest,
      _ => context.colors.primaryContainer,
    };
  }

  String _getTitle(BuildContext context) {
    // Check for PR-related suggestions
    if (suggestion.id.contains('pr_') || suggestion.trigger.contains('pr')) {
      return context.l10n.personalRecord;
    }

    return switch (suggestion.type) {
      'tip' => context.l10n.tip,
      'warning' => context.l10n.warning,
      'correction' => context.l10n.correction,
      'technique' => context.l10n.technique,
      'variant' => context.l10n.variant,
      'translation' => context.l10n.translation,
      _ => suggestion.type,
    };
  }

  String _getSubtitle(BuildContext context) {
    // Check for PR-related suggestions
    if (suggestion.id.contains('pr_') || suggestion.trigger.contains('pr')) {
      return context.l10n.youBeatYourRecord;
    }

    if (suggestion.trigger.contains('motivation') ||
        suggestion.trigger.contains('consistency')) {
      return context.l10n.keepUpTheGoodWork;
    }

    return context.l10n.suggestionBasedOnYourWorkout;
  }

  List<Widget> _buildContextTips(BuildContext context) {
    final tips = <String>[];

    // PR-specific tips
    if (suggestion.id.contains('pr_') || suggestion.trigger.contains('pr')) {
      tips.addAll([
        context.l10n.prTip1,
        context.l10n.prTip2,
        context.l10n.prTip3,
      ]);
    }
    // Motivation-specific tips
    else if (suggestion.trigger.contains('motivation') ||
        suggestion.trigger.contains('consistency')) {
      tips.addAll([
        context.l10n.motivationTip1,
        context.l10n.motivationTip2,
        context.l10n.motivationTip3,
      ]);
    }
    // Generic tips based on type
    else {
      if (suggestion.type == 'tip') {
        tips.addAll([context.l10n.tipAdvice1, context.l10n.tipAdvice2]);
      } else if (suggestion.type == 'warning') {
        tips.addAll([
          context.l10n.warningAdvice1,
          context.l10n.warningAdvice2,
        ]);
      }
    }

    if (tips.isEmpty) return [];

    return [
      Text(
        context.l10n.whatThisMeans,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      ...tips.map(
        (tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.checkCircle,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
