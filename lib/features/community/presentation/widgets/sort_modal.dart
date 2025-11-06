/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/widgets
/// 🎯 Feature: community discovery
/// 🔧 Type: widget
///
/// Sort Modal - Bottom sheet for selecting sort options
///
/// Features:
/// - 4 sort options: helpful, recent, saved, trending
/// - Single selection with immediate apply
/// - Selected option highlighted with check mark
/// - Apple HIG compliant bottom sheet design
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class SortModal extends ConsumerWidget {
  const SortModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SortModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(activeFiltersProvider);
    final currentSort = currentFilters.sortBy;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),

            // Sort Options
            _buildSortOption(
              context,
              ref,
              SortOption.helpful,
              currentSort,
              icon: AppIcons.thumbUp,
            ),
            _buildSortOption(
              context,
              ref,
              SortOption.recent,
              currentSort,
              icon: AppIcons.schedule,
            ),
            _buildSortOption(
              context,
              ref,
              SortOption.saved,
              currentSort,
              icon: AppIcons.save,
            ),
            _buildSortOption(
              context,
              ref,
              SortOption.trending,
              currentSort,
              icon: AppIcons.trendUp,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              context.l10n.sort,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref,
    SortOption option,
    String currentSort, {
    required IconData icon,
  }) {
    final isSelected = currentSort == option.value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? context.colors.primary
            : context.colors.onSurfaceVariant,
      ),
      title: Text(
        option.toLocalizedString(context),
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? context.colors.primary : context.colors.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(
              AppIcons.check,
              color: context.colors.primary,
            )
          : null,
      onTap: () {
        final currentFilters = ref.read(activeFiltersProvider);
        final updatedFilters = currentFilters.copyWith(sortBy: option.value);
        ref.read(activeFiltersProvider.notifier).state = updatedFilters;
        Navigator.pop(context);
      },
    );
  }
}
