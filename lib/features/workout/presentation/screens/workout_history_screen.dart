/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: workout
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - workout/domain/entities: Workout
/// - workout/presentation/providers: WorkoutHistoryProvider
/// - shared/presentation/l10n: AppLocalizations
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_provider.dart';
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
  
  String _searchQuery = '';
  String _selectedFilter = 'all';
  DateTimeRange? _dateFilter;

  @override
  void initState() {
    super.initState();
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutHistoryProvider.notifier).loadWorkouts();
    });
    
    // Setup pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(workoutHistoryProvider.notifier).loadMoreWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to home using Go Router
            context.go('/');
          },
        ),
        title: Text(l10n.workoutHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _onMenuItemSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.download),
                    const SizedBox(width: 8),
                    Text(l10n.exportData),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    const Icon(Icons.analytics),
                    const SizedBox(width: 8),
                    Text(l10n.statistics),
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
          _buildSearchBar(theme, l10n),
          
          // Active filters chips
          if (_searchQuery.isNotEmpty || _selectedFilter != 'all' || _dateFilter != null)
            _buildActiveFilters(theme, l10n),
          
          // Workout list
          Expanded(
            child: state.when(
              data: (workouts) => _buildWorkoutList(workouts, theme, l10n),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error, theme, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchWorkouts,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
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
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        onChanged: _updateSearch,
      ),
    );
  }

  Widget _buildActiveFilters(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_searchQuery.isNotEmpty)
              _buildFilterChip(
                label: '${l10n.search}: $_searchQuery',
                onDeleted: () => _updateSearch(''),
                theme: theme,
              ),
            if (_selectedFilter != 'all')
              _buildFilterChip(
                label: _getFilterDisplayName(_selectedFilter, l10n),
                onDeleted: () => _updateFilter('all'),
                theme: theme,
              ),
            if (_dateFilter != null)
              _buildFilterChip(
                label: '${l10n.dateRange}: ${DateFormat('dd/MM').format(_dateFilter!.start)} - ${DateFormat('dd/MM').format(_dateFilter!.end)}',
                onDeleted: () => _updateDateFilter(null),
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: theme.colorScheme.primaryContainer,
        deleteIconColor: theme.colorScheme.onPrimaryContainer,
        labelStyle: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildWorkoutList(List<Workout> workouts, ThemeData theme, AppLocalizations l10n) {
    if (workouts.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(workoutHistoryProvider.notifier).refreshWorkouts();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length + (ref.read(workoutHistoryProvider.notifier).hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == workouts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
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

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noWorkoutsFound,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noWorkoutsFoundDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.read(workoutHistoryProvider.notifier).refreshWorkouts(),
            child: Text(l10n.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingWorkouts,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.read(workoutHistoryProvider.notifier).refreshWorkouts(),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _updateSearch(String query) {
    setState(() => _searchQuery = query);
    ref.read(workoutHistoryProvider.notifier).updateFilters(
      search: query,
      filter: _selectedFilter,
      dateRange: _dateFilter,
    );
  }

  void _updateFilter(String filter) {
    setState(() => _selectedFilter = filter);
    ref.read(workoutHistoryProvider.notifier).updateFilters(
      search: _searchQuery,
      filter: filter,
      dateRange: _dateFilter,
    );
  }

  void _updateDateFilter(DateTimeRange? dateRange) {
    setState(() => _dateFilter = dateRange);
    ref.read(workoutHistoryProvider.notifier).updateFilters(
      search: _searchQuery,
      filter: _selectedFilter,
      dateRange: dateRange,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        currentFilter: _selectedFilter,
        currentDateRange: _dateFilter,
        onFilterChanged: _updateFilter,
        onDateRangeChanged: _updateDateFilter,
      ),
    );
  }

  String _getFilterDisplayName(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'week':
        return l10n.thisWeek;
      case 'month':
        return l10n.thisMonth;
      case 'strength':
        return l10n.strength;
      case 'hypertrophy':
        return l10n.hypertrophy;
      case 'cardio':
        return l10n.cardio;
      default:
        return filter;
    }
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'export':
        ref.read(workoutHistoryProvider.notifier).exportWorkouts();
        break;
      case 'stats':
        _showStatsDialog();
        break;
    }
  }

  void _editWorkout(Workout workout) {
    // Navigate to workout editor
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutHistoryEditor(workout: workout),
    );
  }

  void _duplicateWorkout(Workout workout) {
    ref.read(workoutHistoryProvider.notifier).duplicateWorkout(workout);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).workoutDuplicated),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _deleteWorkout(Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteWorkout),
        content: Text(AppLocalizations.of(context).deleteWorkoutConfirmation(workout.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(workoutHistoryProvider.notifier).deleteWorkout(workout);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).workoutDeleted),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _viewWorkout(Workout workout) {
    // Navigate to read-only workout view
    // TODO: Implement workout detail view
  }

  void _showStatsDialog() {
    // TODO: Implement statistics dialog
  }
}

class _FilterDialog extends StatefulWidget {

  const _FilterDialog({
    required this.currentFilter,
    required this.currentDateRange,
    required this.onFilterChanged,
    required this.onDateRangeChanged,
  });
  final String currentFilter;
  final DateTimeRange? currentDateRange;
  final Function(String) onFilterChanged;
  final Function(DateTimeRange?) onDateRangeChanged;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String _selectedFilter;
  late DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedDateRange = widget.currentDateRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.filterWorkouts),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.timeRange, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('all', l10n.allTime),
              _buildFilterChip('week', l10n.thisWeek),
              _buildFilterChip('month', l10n.thisMonth),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.workoutType, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('strength', l10n.strength),
              _buildFilterChip('hypertrophy', l10n.hypertrophy),
              _buildFilterChip('cardio', l10n.cardio),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.customDateRange, style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: _selectDateRange,
                child: Text(_selectedDateRange != null 
                  ? '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}'
                  : l10n.selectDates),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _selectedFilter = 'all';
            _selectedDateRange = null;
            widget.onFilterChanged(_selectedFilter);
            widget.onDateRangeChanged(_selectedDateRange);
            Navigator.of(context).pop();
          },
          child: Text(l10n.clearAll),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.onFilterChanged(_selectedFilter);
            widget.onDateRangeChanged(_selectedDateRange);
            Navigator.of(context).pop();
          },
          child: Text(l10n.apply),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }
}

