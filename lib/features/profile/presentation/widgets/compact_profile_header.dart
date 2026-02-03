/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Compact Header
/// Type: Widget
///
/// Apple Fitness+ style compact profile header with
/// horizontal layout, tier progress, and gamification elements.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart'
    hide currentStreakProvider;
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/level_info_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/ghost_mode_provider.dart';

/// Compact profile header with horizontal layout
///
/// Features:
/// - Avatar with tier gradient border (56x56)
/// - User name and stats inline
/// - Tier progress indicator
/// - Settings and edit actions top-right
class CompactProfileHeader extends ConsumerWidget {
  const CompactProfileHeader({
    required this.userName,
    required this.onSettingsTap,
    required this.onEditTap,
    super.key,
  });

  final String userName;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎮 FIX: Use central XP provider for accurate total XP
    final userXPState = ref.watch(userXPProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final totalWorkoutsAsync = ref.watch(completedWorkoutsCountProvider);

    // 👻 Ghost Mode: Hide tier and streak when enabled
    final shouldHideTier = ref.watch(shouldHideTierProvider);
    final shouldHideStreak = ref.watch(shouldHideStreakProvider);

    // Get XP and tier info from central provider
    final totalXP = userXPState.totalXP;
    final currentTier = userXPState.currentTier;
    final nextTier = currentTier.next;
    final tierProgress = currentTier.progressToNext(totalXP);

    // Get streak
    final streak = streakAsync.value?.currentStreak ?? 0;

    // Get total workouts from progress provider
    final totalWorkouts = totalWorkoutsAsync.value ?? 0;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top row: Settings and Edit icons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    AppIcons.edit,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onEditTap();
                  },
                  tooltip: context.l10n.editProfile,
                ),
                IconButton(
                  icon: Icon(
                    AppIcons.settingsOutlined,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSettingsTap();
                  },
                  tooltip: context.l10n.settings,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Main content: Avatar + Info horizontal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with tier gradient border (hidden in Ghost Mode)
                _TierAvatar(
                  initial: userName.isNotEmpty
                      ? userName[0].toUpperCase()
                      : '?',
                  tier: currentTier,
                  hideTier: shouldHideTier,
                ),
                const SizedBox(width: 16),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        userName,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Streak indicator (hidden in Ghost Mode)
                      if (!shouldHideStreak) ...[
                        Row(
                          children: [
                            Text('🔥', style: context.textTheme.bodyMedium),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.dayStreak(streak),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],

                      // Total workouts
                      Row(
                        children: [
                          Text('💪', style: context.textTheme.bodyMedium),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.totalWorkoutsLabel(totalWorkouts),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tier progress bar with info button (hidden in Ghost Mode)
                      if (!shouldHideTier) ...[
                        if (nextTier != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: tierProgress,
                                    minHeight: 4,
                                    backgroundColor:
                                        context.colors.surfaceContainerLow,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      currentTier.color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.tierProgress(
                                  currentTier.displayName,
                                  nextTier.displayName,
                                ),
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              // Info button to show level info modal
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  LevelInfoModal.show(
                                    context: context,
                                    currentXP: totalXP,
                                    currentTier: currentTier,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    AppIcons.info,
                                    size: AppIconSize.small,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Max tier reached
                          Row(
                            children: [
                              Icon(
                                AppIcons.achievement,
                                size: 16,
                                color: currentTier.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentTier.displayName,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: currentTier.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Info button for max tier
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  LevelInfoModal.show(
                                    context: context,
                                    currentXP: totalXP,
                                    currentTier: currentTier,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    AppIcons.info,
                                    size: AppIconSize.small,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar with tier gradient border (neutral when Ghost Mode hides tier)
class _TierAvatar extends StatelessWidget {
  const _TierAvatar({
    required this.initial,
    required this.tier,
    this.hideTier = false,
  });

  final String initial;
  final UserTier tier;
  final bool hideTier;

  @override
  Widget build(BuildContext context) {
    // Use neutral colors when tier is hidden (Ghost Mode)
    final gradientColors = hideTier
        ? [context.colors.outline, context.colors.outlineVariant]
        : _getGradientColors(tier);
    final accentColor = hideTier ? context.colors.outline : tier.color;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        // ✨ Material 3 2025: Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(
        4,
      ), // Border padding (must be multiple of 4)
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // ✨ Material 3 2025: Solid elevated surface
          color: context.colors.surfaceContainerHigh,
          // ✨ Inner shadow for depth
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            initial,
            style: context.textTheme.headlineSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(UserTier tier) {
    switch (tier) {
      case UserTier.starter:
        return [const Color(0xFF9E9E9E), const Color(0xFF757575)];
      case UserTier.bronze:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      case UserTier.silver:
        return [const Color(0xFFE8E8E8), const Color(0xFF9E9E9E)];
      case UserTier.gold:
        return [const Color(0xFFFFD700), const Color(0xFFDAA520)];
      case UserTier.platinum:
        return [
          const Color(0xFFE5E4E2),
          const Color(0xFFB0B0B0),
          const Color(0xFFE5E4E2),
        ];
    }
  }
}
