/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/screens
/// 🎯 Feature: workout
/// 🔧 Type: screen
/// 🌍 Localization: ✅ context.l10n used
/// 🎨 Theme: ✅ context.colors used
/// 📱 Platform: Universal
///
/// **Performance Optimization (2024)**:
/// - Uses cursor-based pagination via workoutHistoryPaginatedProvider
/// - Only loads 20 workouts per page (configurable)
/// - Infinite scroll with hasMore detection
/// - No memory leak from holding all workouts
///
/// Dependencies:
/// - workout/domain/entities: Workout
/// - workout/presentation/providers: WorkoutHistoryPaginatedProvider
/// - shared/presentation/extensions: BuildContext extensions
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_paginated_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_history_list_item.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_history_editor.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Debounce timer for search
  DateTime? _lastSearchTime;
  static const _searchDebounce = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);

    // Sync search controller with provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(workoutHistoryPaginatedProvider);
      if (state.searchQuery.isNotEmpty) {
        _searchController.text = state.searchQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Infinite scroll trigger - loads more when near bottom
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // Trigger load more when 200px from bottom
    if (currentScroll >= maxScroll - 200) {
      final canLoad = ref.read(canLoadMoreWorkoutsProvider);
      if (canLoad) {
        ref.read(workoutHistoryPaginatedProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch paginated state (auto-loads on first access via build())
    final state = ref.watch(workoutHistoryPaginatedProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: context.colors.onSurface),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/');
          },
        ),
        title: Text(context.l10n.workoutHistory),
        actions: [
          // Filter button with badge if filters active
          Badge(
            isLabelVisible: state.hasFilters,
            backgroundColor: context.colors.primary,
            child: IconButton(
              icon: Icon(AppIcons.filter, color: context.colors.onSurface),
              onPressed: _showFilterDialog,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(AppIcons.moreVert, color: context.colors.onSurface),
            onSelected: _onMenuItemSelected,
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(AppIcons.download, color: context.colors.onSurface),
                    const SizedBox(width: 8),
                    Text(context.l10n.exportData),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(AppIcons.analytics, color: context.colors.onSurface),
                    const SizedBox(width: 8),
                    Text(context.l10n.statistics),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchBar(context),

          // Active filters chips
          if (state.hasFilters) _buildActiveFilters(context, state),

          // Workout list with loading/error/empty states
          Expanded(
            child: _buildBody(context, state),
          ),
        ],
      ),
    );
  }

  /// Build body based on state
  Widget _buildBody(BuildContext context, WorkoutHistoryPaginatedState state) {
    // Initial loading state
    if (state.isLoading && state.workouts.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    // Error state
    if (state.hasError && state.workouts.isEmpty) {
      return _buildErrorWidget(context, state.error!);
    }

    // Empty state
    if (state.isEmpty) {
      return _buildEmptyState(context);
    }

    // Workout list with infinite scroll
    return _buildWorkoutList(context, state);
  }

  Widget _buildSearchBar(BuildContext context) {
    final state = ref.watch(workoutHistoryPaginatedProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.l10n.searchWorkouts,
          prefixIcon: Icon(AppIcons.search, color: context.colors.onSurfaceVariant),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(AppIcons.close, color: context.colors.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    _updateSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        onChanged: _updateSearch,
      ),
    );
  }

  Widget _buildActiveFilters(
    BuildContext context,
    WorkoutHistoryPaginatedState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (state.searchQuery.isNotEmpty)
              _buildFilterChip(
                context: context,
                label: '${context.l10n.search}: ${state.searchQuery}',
                onDeleted: () => _updateSearch(''),
              ),
            if (state.statusFilter != null)
              _buildFilterChip(
                context: context,
                label: _getFilterDisplayName(state.statusFilter!, context),
                onDeleted: () => _updateFilter(null),
              ),
            if (state.dateFrom != null || state.dateTo != null)
              _buildFilterChip(
                context: context,
                label:
                    '${context.l10n.dateRange}: ${state.dateFrom != null ? DateFormat('dd/MM').format(state.dateFrom!) : '...'} - ${state.dateTo != null ? DateFormat('dd/MM').format(state.dateTo!) : '...'}',
                onDeleted: () => _updateDateFilter(null, null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: Icon(AppIcons.close, size: 16, color: context.colors.onPrimaryContainer),
        onDeleted: () {
          HapticFeedback.lightImpact();
          onDeleted();
        },
        backgroundColor: context.colors.primaryContainer,
        deleteIconColor: context.colors.onPrimaryContainer,
        labelStyle: TextStyle(
          color: context.colors.onPrimaryContainer,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildWorkoutList(
    BuildContext context,
    WorkoutHistoryPaginatedState state,
  ) {
    final workouts = state.workouts;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await ref.read(workoutHistoryPaginatedProvider.notifier).refresh();
      },
      color: context.colors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        // Add 1 for loading indicator when loading more
        itemCount: workouts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (ctx, index) {
          // Loading indicator at bottom when loading more
          if (index == workouts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LoadingIndicator(size: 32),
              ),
            );
          }

          final workout = workouts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkoutHistoryListItem(
              workout: workout,
              onEdit: () => _editWorkout(workout),
              onDuplicate: () => _duplicateWorkout(workout),
              onDelete: () => _deleteWorkout(workout),
              onView: () => _viewWorkout(workout),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.workout,
              size: 64,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noWorkoutsFound,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noWorkoutsFoundDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Fire and forget - no need to await
                ref.read(workoutHistoryPaginatedProvider.notifier).refresh();
              },
              icon: const Icon(AppIcons.refresh),
              label: Text(context.l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingWorkouts,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Fire and forget - no need to await
                ref.read(workoutHistoryPaginatedProvider.notifier).refresh();
              },
              icon: const Icon(AppIcons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// Update search with debounce
  void _updateSearch(String query) {
    // Update provider immediately for UI
    ref.read(workoutHistoryPaginatedProvider.notifier).updateSearchQuery(query);

    // Debounce actual search reload
    _lastSearchTime = DateTime.now();
    Future.delayed(_searchDebounce, () {
      if (DateTime.now().difference(_lastSearchTime ?? DateTime.now()) >=
          _searchDebounce) {
        ref.read(workoutHistoryPaginatedProvider.notifier).applyFilters(
              searchQuery: query,
            );
      }
    });
  }

  /// Update status filter
  void _updateFilter(String? filter) {
    HapticFeedback.lightImpact();
    ref.read(workoutHistoryPaginatedProvider.notifier).applyFilters(
          statusFilter: filter,
          clearStatusFilter: filter == null,
        );
  }

  /// Update date range filter
  void _updateDateFilter(DateTime? from, DateTime? to) {
    HapticFeedback.lightImpact();
    ref.read(workoutHistoryPaginatedProvider.notifier).applyFilters(
          dateFrom: from,
          dateTo: to,
          clearDateFrom: from == null,
          clearDateTo: to == null,
        );
  }

  void _showFilterDialog() {
    final state = ref.read(workoutHistoryPaginatedProvider);
    showDialog(
      context: context,
      builder: (ctx) => _FilterDialog(
        currentFilter: state.statusFilter,
        currentDateFrom: state.dateFrom,
        currentDateTo: state.dateTo,
        onFilterChanged: _updateFilter,
        onDateRangeChanged: _updateDateFilter,
      ),
    );
  }

  String _getFilterDisplayName(String filter, BuildContext context) {
    switch (filter) {
      case 'completed':
        return context.l10n.workoutStatusCompleted;
      case 'inProgress':
        return context.l10n.workoutStatusInProgress;
      case 'planned':
        return context.l10n.workoutStatusPlanned;
      default:
        return filter;
    }
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'export':
        // TODO: Implement export with new paginated provider
        SnackBarService.showInfo(context, context.l10n.featureComingSoon);
        break;
      case 'stats':
        _showStatsDialog();
        break;
    }
  }

  void _editWorkout(Workout workout) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WorkoutHistoryEditor(workout: workout),
    ).then((updatedWorkout) {
      if (updatedWorkout != null && updatedWorkout is Workout) {
        ref.read(workoutHistoryPaginatedProvider.notifier).updateWorkout(updatedWorkout);
      }
    });
  }

  void _duplicateWorkout(Workout workout) {
    HapticFeedback.mediumImpact();
    // Create duplicated workout
    final now = DateTime.now();
    final duplicated = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${workout.name} (Copy)',
      exercises: workout.exercises,
      status: WorkoutStatus.planned,
      notes: workout.notes,
      createdAt: now,
      updatedAt: now,
    );

    // Add to provider state (for immediate UI update)
    ref.read(workoutHistoryPaginatedProvider.notifier).addWorkout(duplicated);

    SnackBarService.showSuccess(context, context.l10n.workoutDuplicated);
  }

  void _deleteWorkout(Workout workout) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteWorkout),
        content: Text(context.l10n.deleteWorkoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.mediumImpact();
              ref.read(workoutHistoryPaginatedProvider.notifier).removeWorkout(workout.id);
              SnackBarService.showError(context, context.l10n.workoutDeleted);
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  void _viewWorkout(Workout workout) {
    HapticFeedback.lightImpact();
    // Navigate to workout detail view
    context.push('/workout/${workout.id}');
  }

  void _showStatsDialog() {
    HapticFeedback.lightImpact();
    // Navigate to analytics screen
    context.push('/analytics');
  }
}

/// Filter dialog for workout history
class _FilterDialog extends StatefulWidget {
  const _FilterDialog({
    required this.currentFilter,
    required this.currentDateFrom,
    required this.currentDateTo,
    required this.onFilterChanged,
    required this.onDateRangeChanged,
  });

  final String? currentFilter;
  final DateTime? currentDateFrom;
  final DateTime? currentDateTo;
  final Function(String?) onFilterChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _selectedFilter;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedDateFrom = widget.currentDateFrom;
    _selectedDateTo = widget.currentDateTo;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.filterWorkouts),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status filter section
            Text(context.l10n.status, style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(null, context.l10n.allTime),
                _buildFilterChip('completed', context.l10n.workoutStatusCompleted),
                _buildFilterChip('inProgress', context.l10n.workoutStatusInProgress),
                _buildFilterChip('planned', context.l10n.workoutStatusPlanned),
              ],
            ),
            const SizedBox(height: 20),

            // Date range section
            Text(context.l10n.customDateRange, style: context.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(true),
                    icon: const Icon(AppIcons.calendar, size: 18),
                    label: Text(
                      _selectedDateFrom != null
                          ? DateFormat('dd/MM/yy').format(_selectedDateFrom!)
                          : context.l10n.dateFrom,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(AppIcons.forwardIos, size: 16, color: context.colors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(false),
                    icon: const Icon(AppIcons.calendar, size: 18),
                    label: Text(
                      _selectedDateTo != null
                          ? DateFormat('dd/MM/yy').format(_selectedDateTo!)
                          : context.l10n.dateTo,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _selectedFilter = null;
            _selectedDateFrom = null;
            _selectedDateTo = null;
            widget.onFilterChanged(null);
            widget.onDateRangeChanged(null, null);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.clearAll),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            widget.onFilterChanged(_selectedFilter);
            widget.onDateRangeChanged(_selectedDateFrom, _selectedDateTo);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.apply),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: context.colors.primaryContainer,
      checkmarkColor: context.colors.onPrimaryContainer,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = selected ? value : null);
      },
    );
  }

  Future<void> _selectDate(bool isFrom) async {
    final initialDate = isFrom
        ? (_selectedDateFrom ?? DateTime.now().subtract(const Duration(days: 30)))
        : (_selectedDateTo ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() {
        if (isFrom) {
          _selectedDateFrom = picked;
        } else {
          _selectedDateTo = picked;
        }
      });
    }
  }
}

