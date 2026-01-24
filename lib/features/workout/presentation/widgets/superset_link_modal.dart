import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as exercise_db;
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/superset_round_config_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Modal for quickly creating a superset by linking exercises.
/// Accessible from exercise menu → "Create Superset"
///
/// Features:
/// - Current exercise pre-selected (locked)
/// - Toggle between "In Workout" and "From Database" tabs
/// - Multi-select exercises (min 2 required)
/// - Opens SupersetConfigSheet on continue
class SupersetLinkModal extends ConsumerStatefulWidget {
  const SupersetLinkModal({
    super.key,
    required this.currentExercise,
    required this.workoutExercises,
    required this.onSupersetCreated,
    this.scrollController,
  });

  final Exercise currentExercise;
  final List<Exercise> workoutExercises;
  final Function(SupersetConfiguration) onSupersetCreated;
  final ScrollController? scrollController;

  /// Show as modal bottom sheet
  static Future<SupersetConfiguration?> show({
    required BuildContext context,
    required Exercise currentExercise,
    required List<Exercise> workoutExercises,
  }) {
    return showModalBottomSheet<SupersetConfiguration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        builder: (context, scrollController) => SupersetLinkModal(
          currentExercise: currentExercise,
          workoutExercises: workoutExercises,
          scrollController: scrollController,
          onSupersetCreated: (config) {
            Navigator.of(context).pop(config);
          },
        ),
      ),
    );
  }

  @override
  ConsumerState<SupersetLinkModal> createState() => _SupersetLinkModalState();
}

class _SupersetLinkModalState extends ConsumerState<SupersetLinkModal> {
  // 0 = In Workout, 1 = From Database
  int _selectedTab = 0;

  // Selected exercise IDs (excluding current exercise which is always selected)
  final Set<String> _selectedExerciseIds = {};

  // Database search
  Timer? _searchDebounce;
  List<exercise_db.Exercise> _dbExercises = [];
  List<exercise_db.Exercise> _filteredDbExercises = [];
  bool _isLoadingDb = true;

  @override
  void initState() {
    super.initState();
    _loadDatabaseExercises();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadDatabaseExercises() async {
    try {
      // Use hybrid repository for Firebase-synced exercises
      final repository = ref.read(hybridExerciseRepositoryProvider);
      final exercises = await repository.getAllExercises();
      if (mounted) {
        setState(() {
          _dbExercises = exercises;
          _filteredDbExercises = exercises;
          _isLoadingDb = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDb = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (query.isEmpty) {
            _filteredDbExercises = _dbExercises;
          } else {
            final lowerQuery = query.toLowerCase();
            _filteredDbExercises = _dbExercises
                .where((ex) =>
                    ex.nome.toLowerCase().contains(lowerQuery) ||
                    ex.focus.any((m) => m.toLowerCase().contains(lowerQuery)))
                .toList();
          }
        });
      }
    });
  }

  void _toggleExerciseSelection(String exerciseId) {
    setState(() {
      if (_selectedExerciseIds.contains(exerciseId)) {
        _selectedExerciseIds.remove(exerciseId);
      } else {
        _selectedExerciseIds.add(exerciseId);
      }
    });
    HapticFeedback.selectionClick();
  }

  // Total selected count including current exercise
  int get _totalSelectedCount => _selectedExerciseIds.length + 1;

  bool get _canContinue => _totalSelectedCount >= 2;

  List<exercise_db.Exercise> _getSelectedDbExercises() {
    final result = <exercise_db.Exercise>[];

    // Add current exercise (find in DB)
    final currentDbMatch = _findDbExerciseByName(widget.currentExercise.name);
    if (currentDbMatch != null) {
      result.add(currentDbMatch);
    }

    // Add selected from workout (find in DB by name)
    for (final ex in widget.workoutExercises) {
      if (_selectedExerciseIds.contains(ex.id)) {
        final dbMatch = _findDbExerciseByName(ex.name);
        if (dbMatch != null) {
          result.add(dbMatch);
        }
      }
    }

    // Add selected from DB directly
    for (final dbEx in _dbExercises) {
      if (_selectedExerciseIds.contains(dbEx.id) &&
          !result.any((r) => r.id == dbEx.id)) {
        result.add(dbEx);
      }
    }

    return result;
  }

  exercise_db.Exercise? _findDbExerciseByName(String name) {
    final nameLower = name.toLowerCase();
    return _dbExercises.where((db) =>
        db.nome.toLowerCase() == nameLower).firstOrNull;
  }

  void _onContinue() async {
    final selectedExercises = _getSelectedDbExercises();

    // Open SupersetRoundConfigSheet
    final config = await SupersetRoundConfigSheet.show(
      context: context,
      exercises: selectedExercises,
    );

    if (config != null && mounted) {
      widget.onSupersetCreated(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(theme),

          // Toggle tabs
          _buildToggleTabs(theme),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildWorkoutExercisesList(theme)
                : _buildDatabaseSearch(theme),
          ),

          // Footer with selection count and continue button
          _buildFooter(theme),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.link, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                context.l10n.createSuperset,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Current exercise (locked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.lock,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.currentExercise.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '1',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                index: 0,
                icon: AppIcons.list,
                label: context.l10n.inWorkout,
                theme: theme,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                index: 1,
                icon: AppIcons.search,
                label: context.l10n.fromDatabase,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutExercisesList(ThemeData theme) {
    // Exclude current exercise from the list
    final availableExercises = widget.workoutExercises
        .where((ex) => ex.id != widget.currentExercise.id)
        .toList();

    if (availableExercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.workout,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noOtherExercisesInWorkout,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.useSearchTabToAddExercises,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: availableExercises.length,
      itemBuilder: (context, index) {
        final exercise = availableExercises[index];
        final isSelected = _selectedExerciseIds.contains(exercise.id);

        return _buildExerciseTile(
          id: exercise.id,
          name: exercise.name,
          subtitle: exercise.category.name,
          isSelected: isSelected,
          theme: theme,
        );
      },
    );
  }

  Widget _buildDatabaseSearch(ThemeData theme) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: context.l10n.searchExercises,
              prefixIcon: const Icon(AppIcons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Results
        Expanded(
          child: _isLoadingDb
              ? const Center(child: LoadingIndicator())
              : _filteredDbExercises.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noExercisesFound,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredDbExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _filteredDbExercises[index];
                        final isSelected = _selectedExerciseIds.contains(exercise.id);
                        final isCurrentExercise = exercise.nome.toLowerCase() ==
                            widget.currentExercise.name.toLowerCase();

                        return _buildExerciseTile(
                          id: exercise.id,
                          name: exercise.nome,
                          subtitle: exercise.focus.take(2).join(', '),
                          isSelected: isSelected,
                          isLocked: isCurrentExercise,
                          theme: theme,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildExerciseTile({
    required String id,
    required String name,
    required String subtitle,
    required bool isSelected,
    required ThemeData theme,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLocked ? null : () => _toggleExerciseSelection(id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Checkbox/Lock icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLocked
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface.withValues(alpha: 0),
                    border: Border.all(
                      color: isLocked
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isLocked
                      ? Icon(
                          AppIcons.lock,
                          size: 14,
                          color: theme.colorScheme.primary,
                        )
                      : isSelected
                          ? Icon(
                              AppIcons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                ),
                const SizedBox(width: 12),
                // Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isLocked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Selection count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _canContinue
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalSelectedCount ${context.l10n.selected}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _canContinue
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          if (!_canContinue) ...[
            const SizedBox(width: 8),
            Text(
              '(min 2)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
          const Spacer(),
          // Continue button
          FilledButton.icon(
            onPressed: _canContinue ? _onContinue : null,
            icon: const Icon(AppIcons.forward, size: 18),
            label: Text(context.l10n.continueButton),
          ),
        ],
      ),
    );
  }
}
