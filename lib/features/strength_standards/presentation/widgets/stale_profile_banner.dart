/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: strength_standards
/// 🔧 Type: widget
/// 🌍 Localization: ✅ Full support (EN/IT)
/// 🎨 Theme: ✅ Adapts to theme
/// 📱 Platform: Universal
///
/// Banner widget that appears when user's fitness profile is stale (30+ days old)
/// Prompts user to update their profile for more accurate suggestions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/screens/fitness_questionnaire_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Widget that displays a banner when fitness profile is stale
class StaleProfileBanner extends ConsumerWidget {
  const StaleProfileBanner({super.key});

  /// Number of days before profile is considered stale
  static const int _staleDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(userFitnessQuestionnaireProvider);

    // Don't show banner if no questionnaire
    if (questionnaire == null) {
      return const SizedBox.shrink();
    }

    // Calculate days since last update
    final now = DateTime.now();
    final completedAt = questionnaire.completedAt;

    // Don't show banner if questionnaire was never completed
    if (completedAt == null) {
      return const SizedBox.shrink();
    }

    final daysSinceUpdate = now.difference(completedAt).inDays;

    // Don't show if profile is fresh
    if (daysSinceUpdate < _staleDays) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.update,
              color: context.colors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.staleProfileTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSubtitle(context, daysSinceUpdate),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () => _onUpdateProfile(context),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.onSecondary,
            ),
            child: Text(context.l10n.staleProfileUpdateButton),
          ),
        ],
      ),
    );
  }

  String _getSubtitle(BuildContext context, int days) {
    if (days < 60) {
      return context.l10n.staleProfileSubtitle1Month(days);
    } else if (days < 180) {
      final months = (days / 30).floor();
      return context.l10n.staleProfileSubtitleMonths(months);
    } else {
      final months = (days / 30).floor();
      return context.l10n.staleProfileSubtitleManyMonths(months);
    }
  }

  void _onUpdateProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FitnessQuestionnaireScreen(),
      ),
    );
  }
}
