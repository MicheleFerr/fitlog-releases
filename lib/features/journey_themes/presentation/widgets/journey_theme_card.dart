/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/presentation/widgets
/// Feature: Journey Themes Gamification
/// Type: Widget
///
/// Card widget displaying a single journey theme with its unlock progress.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Card displaying a journey theme option
class JourneyThemeCard extends StatelessWidget {
  const JourneyThemeCard({
    super.key,
    required this.theme,
    required this.userTier,
    required this.isSelected,
    this.isPreview = false,
    this.onTap,
    this.onLongPress,
  });

  /// The journey theme to display
  final JourneyTheme theme;

  /// User's current tier
  final UserTier userTier;

  /// Whether this theme is currently selected
  final bool isSelected;

  /// Whether this is the preview theme
  final bool isPreview;

  /// Called when card is tapped
  final VoidCallback? onTap;

  /// Called when card is long pressed
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final unlockPercentage = theme.getUnlockPercentage(userTier);
    final unlockedCount = theme.getUnlockedFeaturesCount(userTier);
    final totalCount = theme.totalFeatures;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withValues(alpha: isSelected || isPreview ? 0.2 : 0.1),
              theme.secondaryColor.withValues(alpha: isSelected || isPreview ? 0.15 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPreview
                ? context.colors.tertiary
                : isSelected
                    ? theme.primaryColor
                    : context.colors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected || isPreview ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected || isPreview)
              BoxShadow(
                color: (isPreview ? context.colors.tertiary : theme.primaryColor)
                    .withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme emoji and name
                  _buildHeader(context),

                  const Spacer(),

                  // Tagline
                  Text(
                    theme.tagline,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Unlock progress
                  _buildProgressIndicator(
                    context,
                    unlockPercentage,
                    unlockedCount,
                    totalCount,
                  ),
                ],
              ),
            ),

            // Selected checkmark
            if (isSelected && !isPreview)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const SemanticIcon(
                    icon: AppIcons.check,
                    semanticLabel: 'Selected',
                    size: AppIconSize.tiny,
                    color: Colors.white,
                  ),
                ),
              ),

            // Preview indicator
            if (isPreview)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Preview',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Emoji with colored background
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              theme.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Theme name
        Expanded(
          child: Text(
            theme.displayName,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    double percentage,
    int unlocked,
    int total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$unlocked/$total features',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(
              '${(percentage * 100).round()}%',
              style: context.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      ],
    );
  }
}
