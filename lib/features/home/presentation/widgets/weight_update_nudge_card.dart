/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: Weight Update Nudge
/// Type: Widget
///
/// Dismissible card that reminds users to update their bodyweight
/// for accurate volume calculations in bodyweight exercises.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/weight_update_nudge_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Nudge card reminding users to update their bodyweight
///
/// Shows when weight hasn't been updated in 4+ weeks.
/// Dismissible with a cooldown before showing again.
class WeightUpdateNudgeCard extends ConsumerWidget {
  const WeightUpdateNudgeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowWeightNudgeProvider);
    final daysSinceUpdate = ref.watch(daysSinceWeightUpdateProvider);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Dismissible(
        key: const Key('weight_update_nudge'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          ref.read(weightUpdateNudgeProvider.notifier).dismissNudge();
        },
        background: _buildDismissBackground(context, Alignment.centerLeft),
        secondaryBackground:
            _buildDismissBackground(context, Alignment.centerRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.8),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _navigateToProfile(context),
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
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.scale,
                        size: AppIconSize.medium,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.weightUpdateNudgeTitle,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.weightUpdateNudgeSubtitle(daysSinceUpdate),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action arrow
                    Icon(
                      AppIcons.chevronRight,
                      size: AppIconSize.small,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context, Alignment alignment) {
    final colorScheme = context.colors;
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest,
      ),
      alignment: alignment,
      padding: EdgeInsets.only(
        left: isLeft ? 20 : 0,
        right: isLeft ? 0 : 20,
      ),
      child: Icon(
        AppIcons.close,
        color: colorScheme.onSurfaceVariant,
        size: AppIconSize.medium,
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    context.push('/profile/edit');
  }
}
