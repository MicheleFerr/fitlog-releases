/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Achievement Unlock Animation - Celebratory widget for unlocked achievements
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/achievement_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Achievement Unlock Animation Widget
///
/// Shows celebratory animation when achievement is unlocked:
/// - Slide-in animation from bottom
/// - Rarity-based colors
/// - Achievement name and description
/// - Reward message
/// - Auto-dismiss after 5 seconds
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => AchievementUnlockAnimation(
///     achievement: unlockedAchievement,
///   ),
/// );
/// ```
class AchievementUnlockAnimation extends StatefulWidget {
  const AchievementUnlockAnimation({
    required this.achievement,
    this.onDismiss,
    super.key,
  });

  final AchievementData achievement;
  final VoidCallback? onDismiss;

  @override
  State<AchievementUnlockAnimation> createState() =>
      _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState
    extends State<AchievementUnlockAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: _getRarityColor(context).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Achievement Unlocked Title
                    Text(
                      context.l10n.achievementUnlocked,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Achievement Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getRarityColor(context).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SemanticIcon(
                          icon: _getIconData(widget.achievement.iconKey),
                          semanticLabel: widget.achievement.name,
                          size: 48,
                          color: _getRarityColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Achievement Name
                    Text(
                      _getLocalizedText(context, widget.achievement.name),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Rarity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRarityColor(context).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getLocalizedText(
                          context,
                          widget.achievement.rarityNameKey,
                        ),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: _getRarityColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reward Message
                    Text(
                      _getLocalizedText(
                        context,
                        widget.achievement.rewardMessage,
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Dismiss Button
                    FilledButton(
                      onPressed: _dismiss,
                      child: Text(context.l10n.awesome),
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

  /// Get rarity color
  Color _getRarityColor(BuildContext context) {
    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return context.colors.onSurfaceVariant;
      case AchievementRarity.uncommon:
        return context.iconSuccess;
      case AchievementRarity.rare:
        return context.colors.primary;
      case AchievementRarity.epic:
        return context.colors.tertiary;
      case AchievementRarity.legendary:
        return context.iconWarning;
    }
  }

  /// Map icon key to IconData
  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'workout':
        return AppIcons.workout;
      case 'template':
        return AppIcons.list;
      case 'stars':
        return AppIcons.stars;
      case 'trendingUp':
        return AppIcons.trendingUp;
      case 'checkCircle':
        return AppIcons.checkCircle;
      case 'wbSunny':
        return AppIcons.wbSunny;
      case 'nightlightRound':
        return AppIcons.nightlightRound;
      default:
        return AppIcons.stars;
    }
  }

  /// Get localized text (fallback to key if not found)
  String _getLocalizedText(BuildContext context, String key) {
    // In production, use context.l10n with dynamic key lookup
    // For now, return key as fallback
    try {
      // TODO: Implement dynamic localization lookup
      // return context.l10n.lookupKey(key);
      return key;
    } catch (e) {
      return key;
    }
  }
}
