/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/presentation/widgets
/// Feature: Journey Themes Gamification
/// Type: Widget
///
/// Widget displaying unlocked and locked features for a journey theme.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/unlockable_feature.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal displaying features breakdown for a theme
class ThemeFeaturesBreakdown extends StatelessWidget {
  const ThemeFeaturesBreakdown({
    super.key,
    required this.theme,
    required this.userTier,
    required this.currentXP,
  });

  /// The journey theme to display features for
  final JourneyTheme theme;

  /// User's current tier
  final UserTier userTier;

  /// User's current XP (for calculating remaining XP)
  final int currentXP;

  /// Show as modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required JourneyTheme theme,
    required UserTier userTier,
    required int currentXP,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ThemeFeaturesBreakdown(
            theme: theme,
            userTier: userTier,
            currentXP: currentXP,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlockedFeatures = theme.getUnlockedFeatures(userTier);
    final lockedFeatures = theme.getLockedFeatures(userTier);

    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        _buildHeader(context, l10n),

        // Features list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Unlocked features section
              if (unlockedFeatures.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  l10n.featuresUnlocked(unlockedFeatures.length, theme.totalFeatures),
                  AppIcons.check,
                  context.colors.primary,
                ),
                const SizedBox(height: 8),
                ...unlockedFeatures.map((f) => _buildFeatureRow(context, f, true)),
                const SizedBox(height: 24),
              ],

              // Locked features section
              if (lockedFeatures.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  l10n.featuresLocked,
                  AppIcons.lock,
                  context.colors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                ...lockedFeatures.map((f) => _buildFeatureRow(context, f, false)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final unlockPercentage = theme.getUnlockPercentage(userTier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              // Theme emoji
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.2),
                      theme.secondaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    theme.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Theme info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.displayName,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.tagline,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: SemanticIcon(
                  icon: AppIcons.close,
                  semanticLabel: l10n.close,
                  size: AppIconSize.medium,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.journeyThemeSubtitle(
                      theme.getUnlockedFeaturesCount(userTier),
                      theme.totalFeatures,
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${(unlockPercentage * 100).round()}%',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: unlockPercentage,
                  minHeight: 10,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: AppIconSize.small, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    UnlockableFeature feature,
    bool isUnlocked,
  ) {
    final l10n = AppLocalizations.of(context);
    final xpRemaining = feature.xpToUnlock(currentXP);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? theme.primaryColor.withValues(alpha: 0.08)
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? theme.primaryColor.withValues(alpha: 0.3)
              : context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? theme.primaryColor.withValues(alpha: 0.15)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(feature.category),
              size: AppIconSize.medium,
              color: isUnlocked
                  ? theme.primaryColor
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 12),
          // Feature info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant.withValues(
                      alpha: isUnlocked ? 0.8 : 0.6,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Status indicator
          if (isUnlocked)
            Icon(
              AppIcons.check,
              size: AppIconSize.medium,
              color: theme.primaryColor,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                xpRemaining > 0
                    ? l10n.xpToUnlock(xpRemaining)
                    : l10n.unlockAt(feature.requiredTier.displayName),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(FeatureCategory category) {
    return switch (category) {
      FeatureCategory.colors => AppIcons.theme,
      FeatureCategory.cards => AppIcons.viewAgenda,
      FeatureCategory.buttons => AppIcons.touchApp,
      FeatureCategory.progress => AppIcons.analytics,
      FeatureCategory.effects => AppIcons.autoAwesome,
      FeatureCategory.icons => AppIcons.achievement,
    };
  }
}
