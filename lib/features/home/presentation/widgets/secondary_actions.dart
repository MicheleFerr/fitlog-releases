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
/// - 2 columns grid layout (better readability)
/// - Minimal flat cards (no glassmorphism)
/// - Standardized press animations via PressableCard
/// - Icon swap on press (normal → rounded)
/// - Title only (no subtitle for cleaner look)
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

    // Responsive layout - 2 columns
    final screenWidth = MediaQuery.of(context).size.width;
    const crossAxisCount = 2; // 2 columns for better readability
    final crossAxisSpacing = screenWidth > 600 ? 16.0 : 12.0;
    final mainAxisSpacing = screenWidth > 600 ? 16.0 : 12.0;
    const aspectRatio = 1.3; // Slightly wider for 2-column layout

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
      // Analytics
      _SecondaryActionCard(
        key: analyticsKey,
        outlinedIcon: AppIcons.analytics,
        filledIcon: AppIcons.analyticsRounded,
        title: l10n.analytics,
        accentColor: _SecondaryActionColors.analytics(context),
        onTap: () => context.goNamed('analytics'),
      ),

      // Exercise Progress
      _SecondaryActionCard(
        outlinedIcon: AppIcons.insights,
        filledIcon: AppIcons.insightsRounded,
        title: l10n.exerciseProgress,
        accentColor: _SecondaryActionColors.exerciseProgress(context),
        onTap: () => context.push('/exercise-progress'),
      ),

      // Workout History
      _SecondaryActionCard(
        key: historyKey,
        outlinedIcon: AppIcons.historyOutlined,
        filledIcon: AppIcons.history,
        title: l10n.history,
        accentColor: _SecondaryActionColors.history(context),
        onTap: () => context.pushNamed('workout-history'),
      ),

      // Settings
      _SecondaryActionCard(
        outlinedIcon: AppIcons.settings,
        filledIcon: AppIcons.settingsRounded,
        title: l10n.settings,
        accentColor: _SecondaryActionColors.settings(context),
        onTap: () => context.goNamed('settings'),
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
    required this.accentColor,
    required this.onTap,
  });

  final IconData outlinedIcon;
  final IconData filledIcon;
  final String title;
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
          padding: const EdgeInsets.all(20), // More breathing room with 2 columns
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
                size: AppAnimations.iconSizeLarge, // Larger icon for 2-column layout
              ),

              const SizedBox(height: 12), // More spacing with 2 columns

              // Title only (no subtitle)
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
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
