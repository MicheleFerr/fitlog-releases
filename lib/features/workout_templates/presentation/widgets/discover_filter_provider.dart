/// State management for Discover tab filters
///
/// Provides reactive filter state and filtered template list.
/// Uses Riverpod for state management with proper invalidation.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/widgets/discover_filter_bar.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';

part 'discover_filter_provider.g.dart';

/// State class for discover filters
typedef DiscoverFiltersState = ({
  DurationFilter duration,
  CategoryFilter category,
});

/// Provider for managing Discover tab filter state
@riverpod
class DiscoverFilters extends _$DiscoverFilters {
  @override
  DiscoverFiltersState build() {
    return (duration: DurationFilter.all, category: CategoryFilter.all);
  }

  /// Update duration filter
  void setDuration(DurationFilter filter) {
    state = (duration: filter, category: state.category);
  }

  /// Update category filter
  void setCategory(CategoryFilter filter) {
    state = (duration: state.duration, category: filter);
  }

  /// Reset all filters to default
  void reset() {
    state = (duration: DurationFilter.all, category: CategoryFilter.all);
  }

  /// Check if any filter is active
  bool get hasActiveFilters =>
      state.duration != DurationFilter.all ||
      state.category != CategoryFilter.all;
}

/// Provider that filters templates based on current filter state
@riverpod
List<WorkoutTemplate> filteredDiscoverTemplates(
  Ref ref,
  List<WorkoutTemplate> templates,
) {
  final filters = ref.watch(discoverFiltersProvider);

  return templates.where((template) {
    // Apply duration filter
    if (filters.duration != DurationFilter.all) {
      final duration = template.estimatedDuration;
      final passes = switch (filters.duration) {
        DurationFilter.quick => duration < 25,
        DurationFilter.medium => duration >= 25 && duration <= 45,
        DurationFilter.long => duration > 45,
        DurationFilter.all => true,
      };
      if (!passes) return false;
    }

    // Apply category filter
    if (filters.category != CategoryFilter.all) {
      final category = template.effectiveCategory;
      final passes = switch (filters.category) {
        CategoryFilter.strength =>
          category == TemplateCategory.strength,
        CategoryFilter.cardio => category == TemplateCategory.cardio,
        CategoryFilter.flexibility =>
          category == TemplateCategory.flexibility,
        CategoryFilter.hybrid => category == TemplateCategory.hybrid,
        CategoryFilter.all => true,
      };
      if (!passes) return false;
    }

    return true;
  }).toList();
}
