/// Smart filter bar for Discover tab
///
/// UX Research Base:
/// - Duration filter as PRIMARY (Chiara's #1 need - busy mom)
/// - Category filter as SECONDARY (for specific focus)
///
/// Filter hierarchy:
/// 1. Duration: Quick (<25'), Medium (25-45'), Long (45'+)
/// 2. Category: All | Strength | Cardio | Flexibility | Hybrid
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Duration filter options for workout templates
enum DurationFilter {
  /// Show all durations
  all,

  /// Quick workouts: under 25 minutes
  quick,

  /// Medium workouts: 25-45 minutes
  medium,

  /// Long workouts: over 45 minutes
  long,
}

/// Category filter options for workout templates
enum CategoryFilter {
  /// Show all categories
  all,

  /// Strength/resistance training
  strength,

  /// Cardio/aerobic training
  cardio,

  /// Flexibility/mobility training
  flexibility,

  /// Hybrid/mixed training
  hybrid,
}

/// Extension to get localized labels for duration filters
extension DurationFilterExtension on DurationFilter {
  String label(AppLocalizations l10n) {
    return switch (this) {
      DurationFilter.all => l10n.all,
      DurationFilter.quick => '< 25\'',
      DurationFilter.medium => '25-45\'',
      DurationFilter.long => '> 45\'',
    };
  }

  IconData get icon {
    return switch (this) {
      DurationFilter.all => AppIcons.timerOff,
      DurationFilter.quick => AppIcons.bolt,
      DurationFilter.medium => AppIcons.timer,
      DurationFilter.long => AppIcons.hourglassEmpty,
    };
  }
}

/// Extension to get localized labels for category filters
extension CategoryFilterExtension on CategoryFilter {
  String label(AppLocalizations l10n) {
    return switch (this) {
      CategoryFilter.all => l10n.all,
      CategoryFilter.strength => l10n.strength,
      CategoryFilter.cardio => l10n.cardio,
      CategoryFilter.flexibility => l10n.flexibility,
      CategoryFilter.hybrid => l10n.templateCategoryHybrid,
    };
  }

  IconData get icon {
    return switch (this) {
      CategoryFilter.all => AppIcons.gridView,
      CategoryFilter.strength => AppIcons.workout,
      CategoryFilter.cardio => AppIcons.directionsRun,
      CategoryFilter.flexibility => AppIcons.flexibility,
      CategoryFilter.hybrid => AppIcons.fitnessCenter,
    };
  }
}

/// Smart filter bar widget for the Discover tab
///
/// Features:
/// - Two rows of filter chips
/// - Duration filters (primary) on top row
/// - Category filters on second row
/// - Haptic feedback on selection
/// - Animated selection state
class DiscoverFilterBar extends StatelessWidget {
  const DiscoverFilterBar({
    super.key,
    required this.selectedDuration,
    required this.selectedCategory,
    required this.onDurationChanged,
    required this.onCategoryChanged,
  });

  /// Currently selected duration filter
  final DurationFilter selectedDuration;

  /// Currently selected category filter
  final CategoryFilter selectedCategory;

  /// Callback when duration filter changes
  final ValueChanged<DurationFilter> onDurationChanged;

  /// Callback when category filter changes
  final ValueChanged<CategoryFilter> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ROW 1: Duration chips (PRIMARY - most important for Chiara)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: DurationFilter.values.map((filter) {
              final isSelected = selectedDuration == filter;
              final color = _getDurationColor(context, filter);

              return Padding(
                padding: EdgeInsets.only(
                  right: filter != DurationFilter.values.last
                      ? AppSpacing.sm
                      : 0,
                ),
                child: _FilterChip(
                  icon: filter.icon,
                  label: filter.label(l10n),
                  isSelected: isSelected,
                  onTap: () => onDurationChanged(filter),
                  accentColor: isSelected ? color : null,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ROW 2: Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: CategoryFilter.values.map((filter) {
              final isSelected = selectedCategory == filter;
              final color = _getCategoryColor(context, filter);

              return Padding(
                padding: EdgeInsets.only(
                  right: filter != CategoryFilter.values.last
                      ? AppSpacing.sm
                      : 0,
                ),
                child: _FilterChip(
                  icon: filter.icon,
                  label: filter.label(l10n),
                  isSelected: isSelected,
                  onTap: () => onCategoryChanged(filter),
                  accentColor: isSelected ? color : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getDurationColor(BuildContext context, DurationFilter filter) {
    return switch (filter) {
      DurationFilter.all => context.colors.onSurfaceVariant,
      DurationFilter.quick => context.colors.success,
      DurationFilter.medium => context.colors.warning,
      DurationFilter.long => context.colors.primary,
    };
  }

  Color _getCategoryColor(BuildContext context, CategoryFilter filter) {
    return switch (filter) {
      CategoryFilter.all => context.colors.onSurfaceVariant,
      CategoryFilter.strength => context.colors.error,
      CategoryFilter.cardio => context.colors.primary,
      CategoryFilter.flexibility => context.colors.success,
      CategoryFilter.hybrid => context.colors.tertiary,
    };
  }
}

/// Individual filter chip widget
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? context.colors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.small,
              color: isSelected ? color : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
