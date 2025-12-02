/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/home/presentation/widgets
/// Feature: Gamification
/// Type: Widget
///
/// XP Progress bar with journey theme styling.
/// Shows current XP and progress to next tier.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// XP Progress bar widget with journey theme styling
class XPProgressBar extends ConsumerStatefulWidget {
  const XPProgressBar({super.key});

  @override
  ConsumerState<XPProgressBar> createState() => _XPProgressBarState();
}

class _XPProgressBarState extends ConsumerState<XPProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementData = ref.watch(achievementXPProvider);
    final journeyTheme = context.journeyThemeOrDefault;

    return achievementData.when(
      data: (data) {
        final currentXP = data.totalXP;
        final currentTier = UserTier.fromXP(currentXP);
        final nextTier = _getNextTier(currentTier);
        final progress = _calculateProgress(currentXP, currentTier, nextTier);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  journeyTheme.primaryColor.withValues(alpha: 0.15),
                  journeyTheme.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: journeyTheme.primaryColor.withValues(alpha: 0.3),
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
                    // Tier icon
                    _buildTierIcon(context, currentTier, journeyTheme.primaryColor),
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
                              color: journeyTheme.primaryColor,
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
                                color: journeyTheme.secondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                nextTier.displayName,
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: nextTier.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${nextTier.minXP - currentXP} XP ${context.l10n.remaining}',
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
                          color: journeyTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.star,
                              size: AppIconSize.tiny,
                              color: journeyTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.maxLevel,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: journeyTheme.primaryColor,
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

                // Progress bar
                _buildProgressBar(
                  context,
                  progress,
                  journeyTheme.primaryColor,
                  journeyTheme.secondaryColor,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingSkeleton(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTierIcon(BuildContext context, UserTier tier, Color themeColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tier.color,
            tier.color.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getTierIcon(tier),
          color: Colors.white,
          size: AppIconSize.medium,
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

  Widget _buildProgressBar(
    BuildContext context,
    double progress,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          // Background
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
            ),
          ),

          // Progress fill with gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            height: 12,
            width: (MediaQuery.of(context).size.width - 64) * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
            ),
          ),

          // Shimmer effect
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              final shimmerPosition = _shimmerController.value;
              return Positioned.fill(
                child: ClipRect(
                  child: Transform.translate(
                    offset: Offset(
                      (MediaQuery.of(context).size.width - 64) *
                          (shimmerPosition * 2 - 0.5),
                      0,
                    ),
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Progress dots
          if (progress > 0.1)
            Positioned(
              left: (MediaQuery.of(context).size.width - 64) * progress - 8,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
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

  double _calculateProgress(int currentXP, UserTier current, UserTier? next) {
    if (next == null) return 1.0; // Max tier

    final tierStart = current.minXP;
    final tierEnd = next.minXP;
    final range = tierEnd - tierStart;

    if (range <= 0) return 1.0;

    final progress = (currentXP - tierStart) / range;
    return progress.clamp(0.0, 1.0);
  }
}
