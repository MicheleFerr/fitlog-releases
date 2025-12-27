/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/presentation/widgets
/// 🎯 Feature: exercise_merge
/// 🔧 Type: widget
///
/// Card compatta per suggerire merge esercizi nella home
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/presentation/providers/exercise_merge_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Card compatta per la home che mostra suggerimenti di merge
///
/// **UX**: Appare solo se ci sono candidati di merge.
/// Mostra il numero di esercizi che potrebbero essere consolidati.
class MergeSuggestionCard extends ConsumerWidget {
  const MergeSuggestionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(mergeCandidatesProvider);

    return candidatesAsync.when(
      data: (candidates) {
        // Non mostrare se non ci sono candidati
        if (candidates.isEmpty) {
          return const SizedBox.shrink();
        }

        final highQuality =
            candidates.where((c) => c.hasHighQualityMatch).length;

        return _MergeSuggestionCardContent(
          totalCandidates: candidates.length,
          highQualityCandidates: highQuality,
          topCandidate: candidates.first.customExerciseName,
          topMatchName: candidates.first.matchingExercises.isNotEmpty
              ? candidates.first.matchingExercises.first.exercise.nome
              : null,
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(AppRoutes.exerciseMergePath);
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MergeSuggestionCardContent extends StatelessWidget {
  const _MergeSuggestionCardContent({
    required this.totalCandidates,
    required this.highQualityCandidates,
    required this.topCandidate,
    required this.topMatchName,
    required this.onTap,
  });

  final int totalCandidates;
  final int highQualityCandidates;
  final String topCandidate;
  final String? topMatchName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.3),
              colorScheme.primaryContainer.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppIcons.merge,
                color: colorScheme.primary,
                size: AppIconSize.medium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mergeSuggestionTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitle(l10n),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Badge + Arrow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCandidates',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  AppIcons.chevronRight,
                  color: colorScheme.onSurfaceVariant,
                  size: AppIconSize.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(dynamic l10n) {
    if (topMatchName != null) {
      return '"$topCandidate" → "$topMatchName"';
    }
    return l10n.mergeSuggestionSubtitle;
  }
}
