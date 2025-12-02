/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/presentation/widgets
/// Feature: Journey Themes Gamification
/// Type: Modal Widget
///
/// Bottom sheet modal for selecting and previewing journey themes.
/// Shows all 6 themes with unlock progress and feature breakdowns.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/journey_themes/presentation/providers/journey_theme_provider.dart';
import 'package:gymbro_flutter_new/features/journey_themes/presentation/widgets/journey_theme_card.dart';
import 'package:gymbro_flutter_new/features/journey_themes/presentation/widgets/theme_features_breakdown.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal for selecting journey themes
class JourneyThemeSelectorModal extends ConsumerStatefulWidget {
  const JourneyThemeSelectorModal({super.key});

  /// Show the modal
  static Future<JourneyTheme?> show(BuildContext context) {
    return showModalBottomSheet<JourneyTheme>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JourneyThemeSelectorModal(),
    );
  }

  @override
  ConsumerState<JourneyThemeSelectorModal> createState() =>
      _JourneyThemeSelectorModalState();
}

class _JourneyThemeSelectorModalState
    extends ConsumerState<JourneyThemeSelectorModal> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journeyThemeProvider);
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false, // Required for showModalBottomSheet
      snap: true,
      snapSizes: const [0.8, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              _buildHandleBar(context),

              // Header
              _buildHeader(context, l10n, state),

              // Theme grid
              Expanded(
                child: _buildThemeGrid(context, scrollController, state),
              ),

              // Bottom action buttons (when in preview mode)
              if (state.isPreviewMode) _buildPreviewActions(context, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    JourneyThemeState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Title
              Expanded(
                child: Text(
                  l10n.journeyThemes,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
          const SizedBox(height: 4),
          // Subtitle with unlock progress
          Text(
            l10n.journeyThemeSubtitle(
              state.effectiveTheme.getUnlockedFeaturesCount(state.userTier),
              state.effectiveTheme.totalFeatures,
            ),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          // Preview mode indicator
          if (state.isPreviewMode) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.preview,
                    semanticLabel: l10n.previewMode,
                    size: AppIconSize.small,
                    color: context.colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.previewMode,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeGrid(
    BuildContext context,
    ScrollController scrollController,
    JourneyThemeState state,
  ) {
    const themes = JourneyTheme.values;

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = theme == state.selectedTheme;
        final isPreview = state.isPreviewMode && theme == state.previewTheme;

        return JourneyThemeCard(
          theme: theme,
          userTier: state.userTier,
          isSelected: isSelected,
          isPreview: isPreview,
          onTap: () => _onThemeTap(theme, isSelected),
          onLongPress: () => _onThemeLongPress(theme),
        );
      },
    );
  }

  Widget _buildPreviewActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + context.mediaQuery.padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelPreview,
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 12),
          // Confirm button
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _confirmPreview,
              icon: const Icon(AppIcons.check),
              label: Text(l10n.applyTheme),
            ),
          ),
        ],
      ),
    );
  }

  void _onThemeTap(JourneyTheme theme, bool isSelected) {
    HapticFeedback.lightImpact();
    debugPrint('🎨 [JourneyTheme] Tap on ${theme.displayName}, isSelected: $isSelected');

    if (isSelected) {
      // Already selected - show features breakdown
      debugPrint('🎨 [JourneyTheme] Already selected, showing breakdown');
      _showFeaturesBreakdown(theme);
    } else {
      // Enter preview mode
      debugPrint('🎨 [JourneyTheme] Entering preview mode for ${theme.displayName}');
      ref.read(journeyThemeProvider.notifier).previewTheme(theme);
    }
  }

  void _onThemeLongPress(JourneyTheme theme) {
    HapticFeedback.mediumImpact();
    _showFeaturesBreakdown(theme);
  }

  void _showFeaturesBreakdown(JourneyTheme theme) {
    final state = ref.read(journeyThemeProvider);
    ThemeFeaturesBreakdown.show(
      context,
      theme: theme,
      userTier: state.userTier,
      currentXP: state.currentXP,
    );
  }

  void _cancelPreview() {
    HapticFeedback.lightImpact();
    ref.read(journeyThemeProvider.notifier).cancelPreview();
  }

  void _confirmPreview() {
    HapticFeedback.mediumImpact();
    final state = ref.read(journeyThemeProvider);
    ref.read(journeyThemeProvider.notifier).confirmPreview();

    // Return the selected theme and close
    Navigator.of(context).pop(state.previewTheme);
  }
}
