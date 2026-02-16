/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: Gamification
/// Type: Widget
///
/// XP Progress bar with clean, minimal design.
/// Shows current XP and progress to next tier.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/level_info_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// XP Progress bar widget with clean minimal design
/// Uses userXPProvider (single source of truth) for XP data
class XPProgressBar extends ConsumerWidget {
  const XPProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use userXPProvider - same as profile for consistency
    final xpState = ref.watch(userXPProvider);

    // Show loading skeleton while loading
    if (xpState.isLoading) {
      return _buildLoadingSkeleton(context);
    }

    // Show nothing on error
    if (xpState.error != null) {
      return const SizedBox.shrink();
    }

    final currentXP = xpState.totalXP;
    final currentTier = xpState.currentTier;
    final nextTier = _getNextTier(currentTier);
    final progress = xpState.tierProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        child: Semantics(
          label: context.l10n.levelInfo,
          hint: context.l10n.tapToViewGamificationInfo,
          button: true,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              LevelInfoModal.show(
                context: context,
                currentXP: currentXP,
                currentTier: currentTier,
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
            // Header row with tier info
            Row(
              children: [
                // Tier icon - simple, no glow
                _buildTierIcon(context, currentTier),
                const SizedBox(width: 12),

                // Tier and XP info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTier.displayName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      Text(
                        '$currentXP XP',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Next tier indicator
                if (nextTier != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.trendUp,
                            size: AppIconSize.tiny,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            nextTier.displayName,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${xpState.xpToNextTier} XP ${context.l10n.remaining}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Max tier reached
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.star,
                          size: AppIconSize.tiny,
                          color: context.colors.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.maxLevel,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

                  // Progress bar - clean, no shimmer
                  _buildProgressBar(context, progress),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierIcon(BuildContext context, UserTier tier) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          _getTierIcon(tier),
          color: context.colors.onPrimaryContainer,
          size: AppIconSize.small,
        ),
      ),
    );
  }

  IconData _getTierIcon(UserTier tier) {
    switch (tier) {
      case UserTier.starter:
        return AppIcons.personOutline;
      case UserTier.bronze:
        return AppIcons.shield;
      case UserTier.silver:
        return AppIcons.star;
      case UserTier.gold:
        return AppIcons.emojiEvents;
      case UserTier.platinum:
        return AppIcons.militaryTech;
    }
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // Background
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
            ),
          ),

          // Progress fill - solid color, no gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: 8,
            width: (MediaQuery.of(context).size.width - 64) * progress,
            decoration: BoxDecoration(color: context.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  UserTier? _getNextTier(UserTier current) {
    switch (current) {
      case UserTier.starter:
        return UserTier.bronze;
      case UserTier.bronze:
        return UserTier.silver;
      case UserTier.silver:
        return UserTier.gold;
      case UserTier.gold:
        return UserTier.platinum;
      case UserTier.platinum:
        return null; // Max tier
    }
  }
}
