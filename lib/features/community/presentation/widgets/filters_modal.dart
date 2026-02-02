/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/widgets
/// 🎯 Feature: community discovery filters
/// 🔧 Type: modal widget
///
/// Filters Modal - Bottom sheet for filtering community contributions
///
/// Features:
/// - Difficulty filter (beginner, intermediate, advanced)
/// - Type filter (correction, tip, warning, variant, translation, technique)
/// - Author tier filter (community, expert, admin)
/// - Date range filter (from/to date picker)
/// - Reset all filters button
/// - Apply/Cancel actions
/// - Apple HIG compliant design
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class FiltersModal extends ConsumerStatefulWidget {
  const FiltersModal({super.key});

  @override
  ConsumerState<FiltersModal> createState() => _FiltersModalState();

  /// Show the filters modal as a bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (_) => const FiltersModal(),
    );
  }
}

class _FiltersModalState extends ConsumerState<FiltersModal> {
  // Local state for filters (before applying)
  String? _selectedDifficulty;
  String? _selectedType;
  String? _selectedAuthorTier;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    // Initialize with current active filters
    final currentFilters = ref.read(activeFiltersProvider);
    _selectedDifficulty = currentFilters.difficulty;
    _selectedType = currentFilters.type;
    _selectedAuthorTier = currentFilters.authorTier;
    _dateFrom = currentFilters.dateFrom;
    _dateTo = currentFilters.dateTo;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.colors.surface),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),

              // Filters Content (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDifficultyFilter(),
                      const SizedBox(height: 24),
                      _buildTypeFilter(),
                      const SizedBox(height: 24),
                      _buildAuthorTierFilter(),
                      const SizedBox(height: 24),
                      _buildDateRangeFilter(),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            context.l10n.filters,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _resetFilters,
            child: Text(context.l10n.resetFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByDifficulty,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip(
              label: context.l10n.difficultyBeginner,
              selected: _selectedDifficulty == 'beginner',
              onSelected: (selected) {
                setState(() {
                  _selectedDifficulty = selected ? 'beginner' : null;
                });
              },
            ),
            _buildFilterChip(
              label: context.l10n.difficultyIntermediate,
              selected: _selectedDifficulty == 'intermediate',
              onSelected: (selected) {
                setState(() {
                  _selectedDifficulty = selected ? 'intermediate' : null;
                });
              },
            ),
            _buildFilterChip(
              label: context.l10n.difficultyAdvanced,
              selected: _selectedDifficulty == 'advanced',
              onSelected: (selected) {
                setState(() {
                  _selectedDifficulty = selected ? 'advanced' : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    final types = [
      ('correction', context.l10n.contributionTypeCorrection),
      ('tip', context.l10n.contributionTypeTip),
      ('warning', context.l10n.contributionTypeWarning),
      ('variant', context.l10n.contributionTypeVariant),
      ('translation', context.l10n.contributionTypeTranslation),
      ('technique', context.l10n.contributionTypeTechnique),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByType,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            return _buildFilterChip(
              label: type.$2,
              selected: _selectedType == type.$1,
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? type.$1 : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAuthorTierFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByAuthorTier,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildFilterChip(
              label: context.l10n.authorTierCommunity,
              selected: _selectedAuthorTier == 'community',
              onSelected: (selected) {
                setState(() {
                  _selectedAuthorTier = selected ? 'community' : null;
                });
              },
            ),
            _buildFilterChip(
              label: context.l10n.authorTierExpert,
              selected: _selectedAuthorTier == 'expert',
              onSelected: (selected) {
                setState(() {
                  _selectedAuthorTier = selected ? 'expert' : null;
                });
              },
            ),
            _buildFilterChip(
              label: context.l10n.authorTierAdmin,
              selected: _selectedAuthorTier == 'admin',
              onSelected: (selected) {
                setState(() {
                  _selectedAuthorTier = selected ? 'admin' : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterByDateRange,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                label: context.l10n.dateFrom,
                date: _dateFrom,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateFrom ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _dateFrom = date);
                  }
                },
                onClear: () => setState(() => _dateFrom = null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateButton(
                label: context.l10n.dateTo,
                date: _dateTo,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateTo ?? DateTime.now(),
                    firstDate: _dateFrom ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _dateTo = date);
                  }
                },
                onClear: () => setState(() => _dateTo = null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: context.colors.primaryContainer,
      checkmarkColor: context.colors.onPrimaryContainer,
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null ? '${date.day}/${date.month}/${date.year}' : '-',
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (date != null)
            IconButton(
              icon: SemanticIcon(
                icon: AppIcons.clear,
                semanticLabel: 'Clear',
                size: AppIconSize.small,
                color: context.colors.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.l10n.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _applyFilters,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.l10n.applyFilters),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDifficulty = null;
      _selectedType = null;
      _selectedAuthorTier = null;
      _dateFrom = null;
      _dateTo = null;
    });
  }

  void _applyFilters() {
    final filters = ContributionFilters(
      difficulty: _selectedDifficulty,
      type: _selectedType,
      authorTier: _selectedAuthorTier,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      sortBy: ref.read(activeFiltersProvider).sortBy, // Keep current sort
    );

    ref.read(activeFiltersProvider.notifier).state = filters;
    Navigator.pop(context);
  }
}
