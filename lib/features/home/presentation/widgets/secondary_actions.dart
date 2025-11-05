import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/gradient_action_card.dart';

/// Secondary Actions widget for the optimized homepage - Gradient Card Redesign
///
/// Provides quick access to 4 core features with gradient personality:
/// - Analytics dashboard (Blue → Purple gradient)
/// - Exercise progress tracking (Green → Teal gradient)
/// - Workout history (Orange → Pink gradient)
/// - Settings and customization (Gray → Purple gradient)
///
/// Design:
/// - 2 columns grid layout (centered composition)
/// - Radial gradients with WCAG AA compliance
/// - Accessibility-first (reduced motion, haptic, semantic)
/// - Staggered animations (icon 100ms, card 150ms)
/// - Material Design 3 aligned
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return [
      // Analytics - Blue → Purple gradient
      GradientActionCard(
        key: analyticsKey,
        outlinedIcon: AppIcons.analytics,
        filledIcon: AppIcons.analyticsRounded,
        title: l10n.analytics,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            colorScheme.primary,
            colorScheme.tertiary.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.7],
        ),
        accentColor: colorScheme.primary,
        onTap: () => context.goNamed('analytics'),
      ),

      // Exercise Progress - Green → Teal gradient
      GradientActionCard(
        outlinedIcon: AppIcons.insights,
        filledIcon: AppIcons.insightsRounded,
        title: l10n.exerciseProgress,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            colorScheme.success.withValues(alpha: 0.85),
            Color.lerp(
              colorScheme.success,
              colorScheme.primary.withValues(alpha: 0.6),
              0.5,
            )!,
          ],
          stops: const [0.0, 0.7],
        ),
        accentColor: colorScheme.success,
        onTap: () => context.push('/exercise-progress'),
      ),

      // Workout History - Orange → Pink gradient
      GradientActionCard(
        key: historyKey,
        outlinedIcon: AppIcons.historyOutlined,
        filledIcon: AppIcons.history,
        title: l10n.history,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            colorScheme.secondary,
            colorScheme.error.withValues(alpha: 0.5),
          ],
          stops: const [0.0, 0.7],
        ),
        accentColor: colorScheme.secondary,
        onTap: () => context.pushNamed('workout-history'),
      ),

      // Settings - Gray → Purple gradient
      GradientActionCard(
        outlinedIcon: AppIcons.settings,
        filledIcon: AppIcons.settingsRounded,
        title: l10n.settings,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color.lerp(
              colorScheme.surfaceContainerHighest,
              colorScheme.tertiary,
              0.4,
            )!,
            colorScheme.tertiary.withValues(alpha: 0.4),
          ],
          stops: const [0.0, 0.7],
        ),
        accentColor: colorScheme.tertiary,
        onTap: () => context.goNamed('settings'),
      ),
    ];
  }
}
