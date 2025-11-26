import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/community_initializer.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Card compatta per Exercise Wiki (ex Community Hub)
///
/// Mostra numero di contributi da revieware e invita a partecipare
class ExerciseWikiCardCompact extends ConsumerWidget {
  const ExerciseWikiCardCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsForReviewProvider);

    return CommunityInitializer.withInitialization(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/community');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.colors.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SemanticIcon(
                      icon: AppIcons.menuBook,
                      semanticLabel: context.l10n.exerciseWiki,
                      size: AppIconSize.medium,
                      color: context.colors.tertiary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.exerciseWiki,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        contributionsAsync.when(
                          data: (contributions) {
                            if (contributions.isEmpty) {
                              return Text(
                                context.l10n.allReviewed,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              );
                            }
                            return Text(
                              context.l10n.tipsToReviewCount(contributions.length),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            );
                          },
                          loading: () => Text(
                            context.l10n.loading,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          error: (_, __) => Text(
                            context.l10n.earnPoints,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge + Arrow
                  contributionsAsync.when(
                    data: (contributions) {
                      if (contributions.isNotEmpty) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.tertiary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${contributions.length}',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onTertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SemanticIcon(
                              icon: AppIcons.chevronRight,
                              semanticLabel: context.l10n.viewAll,
                              size: AppIconSize.small,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ],
                        );
                      }
                      return SemanticIcon(
                        icon: AppIcons.chevronRight,
                        semanticLabel: context.l10n.viewAll,
                        size: AppIconSize.small,
                        color: context.colors.onSurfaceVariant,
                      );
                    },
                    loading: () => SemanticIcon(
                      icon: AppIcons.chevronRight,
                      semanticLabel: context.l10n.viewAll,
                      size: AppIconSize.small,
                      color: context.colors.onSurfaceVariant,
                    ),
                    error: (_, __) => SemanticIcon(
                      icon: AppIcons.chevronRight,
                      semanticLabel: context.l10n.viewAll,
                      size: AppIconSize.small,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
