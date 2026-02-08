/// Achievements Screen - Badge Showcase
///
/// Displays all available achievements with locked/unlocked state.
/// Shows progress towards locked achievements.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// Achievements Screen
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.achievements),
        // Accessibility: Back button with tooltip
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBack, size: AppIconSize.medium),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Text(
                context.l10n.signInToViewAchievements,
                style: context.textTheme.bodyLarge,
              ),
            );
          }

          final achievementsAsync = ref.watch(
            loadUnlockedAchievementsProvider(user.uid),
          );

          return achievementsAsync.when(
            data: (unlockedAchievements) {
              return _AchievementsGrid(
                unlockedAchievements: unlockedAchievements,
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(
              child: Text(
                context.l10n.errorLoadingAchievements,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text(
            context.l10n.errorLoadingUser,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.error,
            ),
          ),
        ),
      ),
    );
  }
}

/// Achievements Grid
class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.unlockedAchievements});

  final List<Achievement> unlockedAchievements;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header stats
        _StatsHeader(unlockedCount: unlockedAchievements.length),
        const SizedBox(height: 24),

        // Badge categories
        _BadgeCategory(
          title: context.l10n.personalRecords,
          badges: const [BadgeType.firstPR, BadgeType.oneRepMonarch],
          unlockedBadges: unlockedAchievements,
        ),
        const SizedBox(height: 24),

        _BadgeCategory(
          title: context.l10n.streaks,
          badges: const [
            BadgeType.streakMaster7,
            BadgeType.streakMaster14,
            BadgeType.streakMaster30,
          ],
          unlockedBadges: unlockedAchievements,
        ),
        const SizedBox(height: 24),

        _BadgeCategory(
          title: context.l10n.volumeMilestones,
          badges: const [
            BadgeType.volumeLegend10k,
            BadgeType.volumeLegend50k,
            BadgeType.volumeLegend100k,
          ],
          unlockedBadges: unlockedAchievements,
        ),
        const SizedBox(height: 24),

        _BadgeCategory(
          title: context.l10n.workoutCount,
          badges: const [
            BadgeType.workoutCompletionist50,
            BadgeType.workoutCompletionist100,
            BadgeType.workoutCompletionist500,
          ],
          unlockedBadges: unlockedAchievements,
        ),
        const SizedBox(height: 24),

        _BadgeCategory(
          title: context.l10n.special,
          badges: const [BadgeType.balancedBuilder, BadgeType.consistencyChampion],
          unlockedBadges: unlockedAchievements,
        ),
      ],
    );
  }
}

/// Stats Header
class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.unlockedCount});

  final int unlockedCount;

  @override
  Widget build(BuildContext context) {
    const total = 13; // Total badges

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(AppIcons.achievement, size: 48, color: context.colors.onPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.achievementsUnlockedCount(unlockedCount, total),
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.achievementsUnlockedLabel,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge Category Section
class _BadgeCategory extends StatelessWidget {
  const _BadgeCategory({
    required this.title,
    required this.badges,
    required this.unlockedBadges,
  });

  final String title;
  final List<BadgeType> badges;
  final List<Achievement> unlockedBadges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map((badgeType) {
            final isUnlocked = unlockedBadges.any(
              (a) => a.badgeType == badgeType,
            );
            return _BadgeCard(badgeType: badgeType, isUnlocked: isUnlocked);
          }).toList(),
        ),
      ],
    );
  }
}

/// Badge Card Widget
class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badgeType, required this.isUnlocked});

  final BadgeType badgeType;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final badgeName = _getBadgeName(context, badgeType);
    final badgeIcon = _getBadgeIcon(badgeType);
    final badgeColor = _getBadgeColor(badgeType, context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBadgeDetails(context, badgeType, isUnlocked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? badgeColor.withValues(alpha: 0.1)
              : context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? badgeColor.withValues(alpha: 0.3)
                : context.colors.outlineVariant,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Badge icon
            Icon(
              badgeIcon,
              size: 48,
              color: isUnlocked
                  ? badgeColor
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),

            // Badge name
            Text(
              badgeName,
              style: context.textTheme.labelLarge?.copyWith(
                color: isUnlocked
                    ? badgeColor
                    : context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Lock icon if locked
            if (!isUnlocked) ...[
              const SizedBox(height: 8),
              Icon(
                AppIcons.lock,
                size: 16,
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeType type, bool unlocked) {
    final description = _getBadgeDescription(context, type);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getBadgeName(context, type)),
        content: Text(description),
        actions: [
          // Accessibility: Close button with semantic label
          Semantics(
            label: context.l10n.closeDialog,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.closeDialog),
            ),
          ),
        ],
      ),
    );
  }

  String _getBadgeName(BuildContext context, BadgeType type) {
    switch (type) {
      case BadgeType.firstPR:
        return context.l10n.badgeFirstPR;
      case BadgeType.streakMaster7:
        return context.l10n.badgeStreakMaster7;
      case BadgeType.streakMaster14:
        return context.l10n.badgeStreakMaster14;
      case BadgeType.streakMaster30:
        return context.l10n.badgeStreakMaster30;
      case BadgeType.volumeLegend10k:
        return context.l10n.badgeVolumeLegend10k;
      case BadgeType.volumeLegend50k:
        return context.l10n.badgeVolumeLegend50k;
      case BadgeType.volumeLegend100k:
        return context.l10n.badgeVolumeLegend100k;
      case BadgeType.balancedBuilder:
        return context.l10n.badgeBalancedBuilder;
      case BadgeType.oneRepMonarch:
        return context.l10n.badgeOneRepMonarch;
      case BadgeType.workoutCompletionist50:
        return context.l10n.badgeWorkoutCompletionist50;
      case BadgeType.workoutCompletionist100:
        return context.l10n.badgeWorkoutCompletionist100;
      case BadgeType.workoutCompletionist500:
        return context.l10n.badgeWorkoutCompletionist500;
      case BadgeType.consistencyChampion:
        return context.l10n.badgeConsistencyChampion;
    }
  }

  String _getBadgeDescription(BuildContext context, BadgeType type) {
    switch (type) {
      case BadgeType.firstPR:
        return context.l10n.badgeFirstPRDescription;
      case BadgeType.streakMaster7:
        return context.l10n.badgeStreakMaster7Description;
      case BadgeType.streakMaster14:
        return context.l10n.badgeStreakMaster14Description;
      case BadgeType.streakMaster30:
        return context.l10n.badgeStreakMaster30Description;
      case BadgeType.volumeLegend10k:
        return context.l10n.badgeVolumeLegend10kDescription;
      case BadgeType.volumeLegend50k:
        return context.l10n.badgeVolumeLegend50kDescription;
      case BadgeType.volumeLegend100k:
        return context.l10n.badgeVolumeLegend100kDescription;
      case BadgeType.balancedBuilder:
        return context.l10n.badgeBalancedBuilderDescription;
      case BadgeType.oneRepMonarch:
        return context.l10n.badgeOneRepMonarchDescription;
      case BadgeType.workoutCompletionist50:
        return context.l10n.badgeWorkoutCompletionist50Description;
      case BadgeType.workoutCompletionist100:
        return context.l10n.badgeWorkoutCompletionist100Description;
      case BadgeType.workoutCompletionist500:
        return context.l10n.badgeWorkoutCompletionist500Description;
      case BadgeType.consistencyChampion:
        return context.l10n.badgeConsistencyChampionDescription;
    }
  }

  IconData _getBadgeIcon(BadgeType type) {
    switch (type) {
      case BadgeType.firstPR:
        return AppIcons.trendingUp;
      case BadgeType.streakMaster7:
      case BadgeType.streakMaster14:
      case BadgeType.streakMaster30:
        return AppIcons.localFireDepartment;
      case BadgeType.volumeLegend10k:
      case BadgeType.volumeLegend50k:
      case BadgeType.volumeLegend100k:
        return AppIcons.fitnessCenter;
      case BadgeType.balancedBuilder:
        return AppIcons.balance;
      case BadgeType.oneRepMonarch:
        return AppIcons.achievement;
      case BadgeType.workoutCompletionist50:
      case BadgeType.workoutCompletionist100:
      case BadgeType.workoutCompletionist500:
        return AppIcons.checkCircle;
      case BadgeType.consistencyChampion:
        return AppIcons.timerOutlined;
    }
  }

  Color _getBadgeColor(BadgeType type, BuildContext context) {
    switch (type) {
      case BadgeType.firstPR:
      case BadgeType.oneRepMonarch:
        return context.colors.error;
      case BadgeType.streakMaster7:
      case BadgeType.streakMaster14:
      case BadgeType.streakMaster30:
        return const Color(0xFFFF9800);
      case BadgeType.volumeLegend10k:
      case BadgeType.volumeLegend50k:
      case BadgeType.volumeLegend100k:
        return context.colors.success;
      case BadgeType.balancedBuilder:
        return context.colors.primary;
      case BadgeType.workoutCompletionist50:
      case BadgeType.workoutCompletionist100:
      case BadgeType.workoutCompletionist500:
        return context.colors.tertiary;
      case BadgeType.consistencyChampion:
        return context.colors.secondary;
    }
  }
}
