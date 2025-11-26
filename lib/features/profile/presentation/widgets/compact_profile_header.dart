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
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';

/// User tier based on XP
enum UserTier {
  starter(0, 'Starter', Color(0xFF9E9E9E)), // Grey
  bronze(100, 'Bronze', Color(0xFFCD7F32)),
  silver(500, 'Silver', Color(0xFFC0C0C0)),
  gold(1500, 'Gold', Color(0xFFFFD700)),
  platinum(5000, 'Platinum', Color(0xFFE5E4E2));

  const UserTier(this.minXP, this.displayName, this.color);

  final int minXP;
  final String displayName;
  final Color color;

  /// Get tier for given XP amount
  static UserTier fromXP(int xp) {
    if (xp >= platinum.minXP) return platinum;
    if (xp >= gold.minXP) return gold;
    if (xp >= silver.minXP) return silver;
    if (xp >= bronze.minXP) return bronze;
    return starter;
  }

  /// Get next tier (or null if max)
  UserTier? get next {
    final index = UserTier.values.indexOf(this);
    if (index >= UserTier.values.length - 1) return null;
    return UserTier.values[index + 1];
  }

  /// Calculate progress to next tier (0.0 to 1.0)
  double progressToNext(int currentXP) {
    final nextTier = next;
    if (nextTier == null) return 1.0; // Max tier reached

    final xpInCurrentTier = currentXP - minXP;
    final xpNeededForNext = nextTier.minXP - minXP;

    return (xpInCurrentTier / xpNeededForNext).clamp(0.0, 1.0);
  }
}

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
    final achievementDataAsync = ref.watch(achievementXPProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    // Get XP and tier info
    final totalXP = achievementDataAsync.valueOrNull?.totalXP ?? 0;
    final currentTier = UserTier.fromXP(totalXP);
    final nextTier = currentTier.next;
    final tierProgress = currentTier.progressToNext(totalXP);

    // Get streak
    final streak = streakAsync.valueOrNull?.currentStreak ?? 0;

    // Get total workouts
    final totalWorkouts =
        achievementDataAsync.valueOrNull?.allAchievements
            .where((a) => a.isUnlocked && a.type == AchievementType.workout)
            .length ??
        0;

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
                // Avatar with tier gradient border
                _TierAvatar(
                  initial: userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  tier: currentTier,
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

                      // Streak indicator
                      Row(
                        children: [
                          Text(
                            '🔥',
                            style: context.textTheme.bodyMedium,
                          ),
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

                      // Total workouts
                      Row(
                        children: [
                          Text(
                            '💪',
                            style: context.textTheme.bodyMedium,
                          ),
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

                      // Tier progress bar
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
                          ],
                        ),
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

/// Avatar with tier gradient border
class _TierAvatar extends StatelessWidget {
  const _TierAvatar({
    required this.initial,
    required this.tier,
  });

  final String initial;
  final UserTier tier;

  @override
  Widget build(BuildContext context) {
    // Create gradient colors based on tier
    final gradientColors = _getGradientColors(tier);

    return Container(
      width: 60, // 56 + 4 for border
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.all(4), // Border width (min allowed spacing)
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.primaryContainer,
        ),
        child: Center(
          child: Text(
            initial,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(UserTier tier) {
    switch (tier) {
      case UserTier.starter:
        return [
          const Color(0xFF9E9E9E),
          const Color(0xFF757575),
        ];
      case UserTier.bronze:
        return [
          const Color(0xFFCD7F32),
          const Color(0xFF8B4513),
        ];
      case UserTier.silver:
        return [
          const Color(0xFFE8E8E8),
          const Color(0xFF9E9E9E),
        ];
      case UserTier.gold:
        return [
          const Color(0xFFFFD700),
          const Color(0xFFDAA520),
        ];
      case UserTier.platinum:
        return [
          const Color(0xFFE5E4E2),
          const Color(0xFFB0B0B0),
          const Color(0xFFE5E4E2),
        ];
    }
  }
}
