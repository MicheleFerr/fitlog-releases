/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: shared
/// 🔧 Type: widget
/// 🌍 Localization: Uses context.l10n
/// 🎨 Theme: Uses context.colors
/// 📱 Platform: Universal
///
/// Premium Feature Card with Blur/Lock Overlay
///
/// Best Practices Applied (2024/2025):
/// - Glassmorphism blur effect (iOS 26 "Liquid Glass" inspired)
/// - Clear value proposition visible through blur
/// - Non-intrusive soft paywall pattern
/// - Accessibility-friendly with proper semantics
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// A card that displays premium content with a blur/lock overlay for non-premium users.
///
/// When [isUnlocked] is true, shows the [child] content normally.
/// When [isUnlocked] is false, shows a blurred preview with a lock overlay.
class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.child,
    this.previewChild,
    this.onUpgradeTap,
    this.blurIntensity = 6.0,
    this.height,
  });

  /// Title of the premium feature
  final String title;

  /// Short description of what this feature offers
  final String description;

  /// Icon representing the feature
  final IconData icon;

  /// Whether the user has premium access
  final bool isUnlocked;

  /// The actual premium content to show when unlocked
  final Widget child;

  /// Optional preview content to show blurred (defaults to [child])
  final Widget? previewChild;

  /// Callback when user taps the upgrade button
  final VoidCallback? onUpgradeTap;

  /// Blur intensity (default: 6.0 - subtle but effective)
  final double blurIntensity;

  /// Fixed height for the card (optional)
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (isUnlocked) {
      // Premium user: show content normally
      return _buildUnlockedCard(context, theme, colorScheme);
    }

    // Free user: show blurred preview with lock overlay
    return _buildLockedCard(context, theme, colorScheme, l10n);
  }

  Widget _buildUnlockedCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with PRO badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                SemanticIcon(
                  icon: icon,
                  semanticLabel: title,
                  size: AppIconSize.medium,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.tertiary,
                        colorScheme.tertiary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.premium,
                        size: AppIconSize.tiny,
                        color: colorScheme.onTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Flexible(child: child),
        ],
      ),
    );
  }

  Widget _buildLockedCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Semantics(
      label: '$title - ${l10n.premiumFeature}',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onUpgradeTap?.call();
        },
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Stack(
            children: [
              // Blurred preview content
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (not blurred)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          children: [
                            SemanticIcon(
                              icon: icon,
                              semanticLabel: title,
                              size: AppIconSize.medium,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Blurred content area
                      Expanded(
                        child: Stack(
                          children: [
                            // Preview content (will be blurred)
                            Positioned.fill(
                              child: previewChild ?? child,
                            ),
                            // Glassmorphism blur overlay
                            Positioned.fill(
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: blurIntensity,
                                    sigmaY: blurIntensity,
                                  ),
                                  child: Container(
                                    color: colorScheme.surface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Compact lock overlay - centered PRO badge
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface.withValues(alpha: 0.0),
                        colorScheme.surface.withValues(alpha: 0.95),
                        colorScheme.surface,
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.tertiary,
                            colorScheme.tertiary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.tertiary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.lock,
                            size: AppIconSize.tiny,
                            color: colorScheme.onTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PRO',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section header for premium features with optional "See All" action
class PremiumSectionHeader extends StatelessWidget {
  const PremiumSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAllTap,
    this.isPremium = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAllTap;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // PRO badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiary,
                  colorScheme.tertiary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.premium,
                  size: AppIconSize.tiny,
                  color: colorScheme.onTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'PRO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          // See All button (only for premium users)
          if (onSeeAllTap != null && isPremium)
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(l10n.seeAll),
            ),
        ],
      ),
    );
  }
}
