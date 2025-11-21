/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ENHANCED PRESET CARD WIDGET - FASE 1 UI Enhancement
///
/// Features:
/// - Preset image with gradient overlay
/// - Difficulty badge (Beginner/Intermediate/Advanced)
/// - Estimated duration display
/// - Localized description text
/// - Selection state with elevated border
/// - Visual hierarchy and modern design
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Enhanced Preset Card - Modern card design with metadata
class EnhancedPresetCard extends StatelessWidget {
  const EnhancedPresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  /// Routine preset to display
  final RoutinePreset preset;

  /// Whether this preset is currently selected
  final bool isSelected;

  /// Callback when card is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(
                color: context.colors.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Image with gradient overlay + difficulty badge
            _buildImageHeader(context),

            // Body: Title, description, metadata
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _buildTitle(context),
                  const SizedBox(height: 8),

                  // Description
                  _buildDescription(context),
                  const SizedBox(height: 16),

                  // Footer: Duration + Days per week
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header section with image and difficulty badge
  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      children: [
        // Background image with gradient overlay
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.primary.withValues(alpha: 0.3),
                context.colors.primary.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getPresetIcon(),
              size: 64,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),

        // Difficulty badge (top-right corner)
        Positioned(
          top: 8,
          right: 8,
          child: _buildDifficultyBadge(context),
        ),

        // Selection checkmark (top-left corner)
        if (isSelected)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.check,
                color: context.colors.onPrimary,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  /// Difficulty badge widget
  Widget _buildDifficultyBadge(BuildContext context) {
    final difficulty = preset.difficulty;
    final difficultyColor = _getDifficultyColor(context, difficulty);

    String difficultyText;
    switch (difficulty) {
      case PresetDifficulty.beginner:
        difficultyText = context.l10n.beginnerLevel;
        break;
      case PresetDifficulty.intermediate:
        difficultyText = context.l10n.intermediateLevel;
        break;
      case PresetDifficulty.advanced:
        difficultyText = context.l10n.advancedLevel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: difficultyColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficultyText,
        style: context.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Title section
  Widget _buildTitle(BuildContext context) {
    return Text(
      preset.displayName,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: isSelected
            ? context.colors.primary
            : context.colors.onSurface,
      ),
    );
  }

  /// Description section
  Widget _buildDescription(BuildContext context) {
    // Get localized description using the descriptionKey
    final description = _getLocalizedDescription(context, preset.descriptionKey);

    return Text(
      description,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Footer section with duration and days per week
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Duration
        Icon(
          AppIcons.timer,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${preset.estimatedDuration} ${context.l10n.minutes}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),

        // Days per week
        Icon(
          AppIcons.calendar,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${preset.frequencyDays} ${context.l10n.daysPerWeek}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Get icon for preset (fallback for when images are not available)
  IconData _getPresetIcon() {
    switch (preset) {
      case RoutinePreset.ppl6Day:
        return AppIcons.workout;
      case RoutinePreset.upperLower4Day:
        return AppIcons.fitnessCenter;
      case RoutinePreset.fullBody3Day:
        return AppIcons.workout;
      case RoutinePreset.broSplit5Day:
        return AppIcons.star;
      case RoutinePreset.custom:
        return AppIcons.settings;
    }
  }

  /// Get color for difficulty level
  Color _getDifficultyColor(BuildContext context, PresetDifficulty difficulty) {
    switch (difficulty) {
      case PresetDifficulty.beginner:
        return context.colors.success; // Green for beginner
      case PresetDifficulty.intermediate:
        return context.colors.warning; // Amber for intermediate
      case PresetDifficulty.advanced:
        return context.colors.error; // Red for advanced
    }
  }

  /// Get localized description from ARB file
  String _getLocalizedDescription(BuildContext context, String key) {
    // Use reflection to get the localized string dynamically
    // Note: This requires the keys to be added to app_en.arb and app_it.arb
    switch (key) {
      case 'presetPpl6DayDescription':
        return context.l10n.presetPpl6DayDescription;
      case 'presetUpperLower4DayDescription':
        return context.l10n.presetUpperLower4DayDescription;
      case 'presetFullBody3DayDescription':
        return context.l10n.presetFullBody3DayDescription;
      case 'presetBroSplit5DayDescription':
        return context.l10n.presetBroSplit5DayDescription;
      case 'presetCustomDescription':
        return context.l10n.presetCustomDescription;
      default:
        return preset.displayName; // Fallback to display name
    }
  }
}
