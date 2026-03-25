/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Compact Fixed Header
/// Type: Widget
///
/// Fixed compact header bar with mini avatar, user name,
/// and action buttons. Stays pinned at top while body scrolls.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/ghost_mode_provider.dart';

/// Fixed compact profile header bar
///
/// Displays:
/// - Mini avatar (36px) with tier gradient border
/// - User name
/// - Edit and Settings action buttons
///
/// Designed to remain pinned at the top of the profile screen.
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
    final userXPState = ref.watch(userXPProvider);
    final currentTier = userXPState.currentTier;
    final shouldHideTier = ref.watch(shouldHideTierProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.xxs),

              // Mini avatar with tier gradient border
              _MiniTierAvatar(
                initial: userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                tier: currentTier,
                hideTier: shouldHideTier,
              ),
              const SizedBox(width: AppSpacing.sm),

              // User name
              Expanded(
                child: Text(
                  userName,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Edit button
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

              // Settings button
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
                padding: const EdgeInsets.all(14),
                constraints: const BoxConstraints.tightFor(
                  width: 56,
                  height: 56,
                ),
                tooltip: context.l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact avatar (36px) with tier gradient border
class _MiniTierAvatar extends StatelessWidget {
  const _MiniTierAvatar({
    required this.initial,
    required this.tier,
    this.hideTier = false,
  });

  final String initial;
  final UserTier tier;
  final bool hideTier;

  @override
  Widget build(BuildContext context) {
    final gradientColors = hideTier
        ? [context.colors.outline, context.colors.outlineVariant]
        : _getGradientColors(tier);
    final accentColor = hideTier ? context.colors.outline : tier.color;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surfaceContainerHigh,
        ),
        child: Center(
          child: Text(
            initial,
            style: context.textTheme.titleSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
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
      case UserTier.diamond:
        return [
          const Color(0xFFB9F2FF),
          const Color(0xFF4FC3F7),
          const Color(0xFFB9F2FF),
        ];
      case UserTier.legend:
        return [
          const Color(0xFFFF6B35),
          const Color(0xFFFF8A65),
          const Color(0xFFFFD54F),
        ];
    }
  }
}
