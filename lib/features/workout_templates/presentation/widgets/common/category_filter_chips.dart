/// Category filter chips for Discover tab
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Delegate for sticky category filter chips
class CategoryFilterDelegate extends SliverPersistentHeaderDelegate {
  CategoryFilterDelegate({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String? selectedCategory;
  final void Function(String?) onCategorySelected;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  bool shouldRebuild(covariant CategoryFilterDelegate oldDelegate) {
    return selectedCategory != oldDelegate.selectedCategory;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final l10n = AppLocalizations.of(context);

    // Category data with localized names and icons
    final categoryData = [
      (key: null, label: l10n.seeAll, icon: AppIcons.gridView),
      (key: 'strength', label: l10n.templateCategoryStrength, icon: AppIcons.workout),
      (key: 'cardio', label: l10n.templateCategoryCardio, icon: AppIcons.directionsRun),
      (key: 'flexibility', label: l10n.templateCategoryFlexibility, icon: AppIcons.flexibility),
      (key: 'hybrid', label: l10n.templateCategoryHybrid, icon: AppIcons.fitnessCenter),
    ];

    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categoryData.map((cat) {
            final isSelected = selectedCategory == cat.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected
                          ? context.colors.onPrimary
                          : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(cat.label),
                  ],
                ),
                onSelected: (_) => onCategorySelected(cat.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
