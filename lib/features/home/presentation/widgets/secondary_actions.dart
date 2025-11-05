import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/animated_icon_swap.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/pressable_card.dart';

/// Secondary Actions widget for the optimized homepage - Minimal Flat Redesign
///
/// Provides quick access to 4 core features with minimal flat design:
/// - Analytics dashboard
/// - Settings and customization
/// - Exercise progress tracking
/// - Workout history
///
/// Design:
/// - 4 columns horizontal layout (toolbar-like)
/// - Minimal flat cards (no glassmorphism)
/// - Standardized press animations via PressableCard
/// - SF Symbols style icons with outlined→filled swap
///
/// Removed from original design:
/// - Community (redundant navigation)
/// - Notifications (unused placeholder)
/// - Import Exercises (developer tool)
/// - Exercise sub-menu (consolidated to Progress only)
class SecondaryActions extends ConsumerWidget {
  const SecondaryActions({
    super.key,
    this.analyticsKey,
    this.historyKey,
  });

  /// Optional GlobalKey for Analytics card (for onboarding tour)
  final GlobalKey? analyticsKey;

  /// Optional GlobalKey for History card (for onboarding tour)
  final GlobalKey? historyKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          l10n.otherTools,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),

        // Secondary Actions Grid - 4 columns
        _buildSecondaryActionsGrid(context, l10n),
      ],
    );
  }

  Widget _buildSecondaryActionsGrid(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final actions = _getSecondaryActions(context, l10n);

    // Responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    const crossAxisCount = 4; // Always 4 columns (toolbar layout)
    final crossAxisSpacing = screenWidth > 600 ? 12.0 : 8.0;
    final mainAxisSpacing = screenWidth > 600 ? 12.0 : 8.0;
    const aspectRatio = 1.2; // Slightly wider than tall (compact)

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
    );
  }

  List<Widget> _getSecondaryActions(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return [
      // Analytics & Progress
      _SecondaryActionCard(
        key: analyticsKey,
        outlinedIcon: AppIcons.analytics, // Material Icons doesn't have outlined variant
        filledIcon: AppIcons.analyticsRounded,
        title: l10n.analytics,
        subtitle: l10n.trackProgress,
        accentColor: _SecondaryActionColors.analytics(context),
        onTap: () => context.goNamed('analytics'),
      ),

      // Settings & Customization
      _SecondaryActionCard(
        outlinedIcon: AppIcons.settings,
        filledIcon: AppIcons.settingsRounded,
        title: l10n.settings,
        subtitle: l10n.customizeApp,
        accentColor: _SecondaryActionColors.settings(context),
        onTap: () => context.goNamed('settings'),
      ),

      // Exercise Progress (consolidated from 3 sub-options)
      _SecondaryActionCard(
        outlinedIcon: AppIcons.insights,
        filledIcon: AppIcons.insightsRounded,
        title: l10n.exerciseProgress,
        subtitle: l10n.trackProgress,
        accentColor: _SecondaryActionColors.exerciseProgress(context),
        onTap: () => context.push('/exercise-progress'),
      ),

      // Workout History Database
      _SecondaryActionCard(
        key: historyKey,
        outlinedIcon: AppIcons.historyOutlined,
        filledIcon: AppIcons.history,
        title: l10n.history,
        subtitle: l10n.viewPastWorkouts,
        accentColor: _SecondaryActionColors.history(context),
        onTap: () => context.pushNamed('workout-history'),
      ),
    ];
  }
}

/// Minimal flat card for secondary actions using PressableCard wrapper
class _SecondaryActionCard extends StatefulWidget {
  const _SecondaryActionCard({
    super.key,
    required this.outlinedIcon,
    required this.filledIcon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData outlinedIcon;
  final IconData filledIcon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_SecondaryActionCard> createState() => _SecondaryActionCardState();
}

class _SecondaryActionCardState extends State<_SecondaryActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: PressableCard(
        accentColor: widget.accentColor,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Tighter padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animated swap
              AnimatedIconSwap(
                outlinedIcon: widget.outlinedIcon,
                filledIcon: widget.filledIcon,
                isPressed: _isPressed,
                color: _isPressed
                    ? widget.accentColor
                    : context.colors.onSurface.withValues(alpha: 0.75),
                size: AppAnimations.iconSizeMedium,
              ),

              const SizedBox(height: 6), // Reduced spacing

              // Title (slightly smaller for more space)
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13, // Reduced from ~14
                      color: context.colors.onSurface,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2), // Reduced spacing

              // Subtitle (much smaller font for better fit)
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10, // Reduced from ~12 to 10
                      height: 1.2, // Tighter line height
                      color: context.colors.onSurface.withValues(alpha: 0.65),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accent colors for different secondary action categories
/// Using theme-aware colors instead of hardcoded values
class _SecondaryActionColors {
  static Color analytics(BuildContext context) =>
      context.colors.primary; // Purple - data/insights
  static Color settings(BuildContext context) =>
      context.colors.secondary.withValues(alpha: 0.9); // Neutral - customization
  static Color exerciseProgress(BuildContext context) =>
      context.colors.tertiary; // Blue - growth/charts
  static Color history(BuildContext context) =>
      context.colors.primary.withValues(alpha: 0.8); // Past/heritage
}
