/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Schermata principale Database Manager per gestione completa esercizi
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/database_manager_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/widgets/exercise_quick_edit_card.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/database_manager_service.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_editor_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class DatabaseManagerScreen extends ConsumerStatefulWidget {
  const DatabaseManagerScreen({super.key});

  @override
  ConsumerState<DatabaseManagerScreen> createState() => _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends ConsumerState<DatabaseManagerScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    // Carica esercizi all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(databaseManagerProvider.notifier).loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(databaseManagerProvider);
    final stats = ref.watch(databaseStatsProvider);

    return Scaffold(
      appBar: _buildAppBar(context, l10n, state),
      body: Column(
        children: [
          // Stats bar
          _buildStatsBar(context, l10n, stats),

          // Filter bar
          _buildFilterBar(context, l10n, state),

          // Selection bar (se in modalità selezione)
          if (_isMultiSelectMode && state.hasSelection)
            _buildSelectionBar(context, l10n, state),

          // Exercise list
          Expanded(
            child: _buildExerciseList(context, l10n, state),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context, l10n),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    DatabaseManagerState state,
  ) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            AppIcons.storage,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(l10n.databaseManager),
        ],
      ),
      actions: [
        // Toggle multi-select mode
        IconButton(
          onPressed: () {
            setState(() => _isMultiSelectMode = !_isMultiSelectMode);
            if (!_isMultiSelectMode) {
              ref.read(databaseManagerProvider.notifier).clearSelection();
            }
          },
          icon: Icon(
            _isMultiSelectMode ? AppIcons.checkBox : AppIcons.checkBoxOutlineBlank,
          ),
          tooltip: l10n.multiSelectMode,
        ),

        // Export menu
        PopupMenuButton<String>(
          icon: const Icon(AppIcons.moreVert),
          onSelected: (value) => _handleMenuAction(value, context, l10n),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export_all',
              child: Row(
                children: [
                  const Icon(AppIcons.download),
                  const SizedBox(width: 8),
                  Text(l10n.exportAllJson),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export_selected',
              enabled: state.hasSelection,
              child: Row(
                children: [
                  const Icon(AppIcons.downloadDone),
                  const SizedBox(width: 8),
                  Text(l10n.exportSelectedJson),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  const Icon(AppIcons.export),
                  const SizedBox(width: 8),
                  Text(l10n.importJson),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  const Icon(AppIcons.refresh),
                  const SizedBox(width: 8),
                  Text(l10n.refresh),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsBar(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<Map<String, dynamic>> stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: stats.when(
        data: (data) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatChip(
              label: l10n.totalExercises,
              value: data['totalExercises']?.toString() ?? '0',
              icon: AppIcons.workout,
            ),
            _StatChip(
              label: l10n.bodyweight,
              value: data['bodyweightCount']?.toString() ?? '0',
              icon: AppIcons.accessibilityIcon,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _StatChip(
              label: l10n.uniqueMuscles,
              value: data['uniqueMuscles']?.toString() ?? '0',
              icon: AppIcons.category,
            ),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    AppLocalizations l10n,
    DatabaseManagerState state,
  ) {
    final dropdownValues = ref.watch(exerciseDropdownValuesProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchExercises,
              prefixIcon: const Icon(AppIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(AppIcons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applySearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) => _applySearch(),
          ),

          const SizedBox(height: 8),

          // Filter dropdowns
          dropdownValues.when(
            data: (values) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Difficulty filter
                  _FilterChip(
                    label: l10n.difficulty,
                    value: state.selectedDifficulty,
                    items: values.difficulties,
                    onChanged: (value) => _applyFilter('difficulty', value),
                  ),
                  const SizedBox(width: 8),

                  // Equipment filter
                  _FilterChip(
                    label: l10n.equipment,
                    value: state.selectedEquipment,
                    items: values.equipments,
                    onChanged: (value) => _applyFilter('equipment', value),
                  ),
                  const SizedBox(width: 8),

                  // Exercise type filter
                  _FilterChip(
                    label: l10n.exerciseType,
                    value: state.selectedExerciseType,
                    items: values.exerciseTypes,
                    onChanged: (value) => _applyFilter('exerciseType', value),
                  ),
                  const SizedBox(width: 8),

                  // Clear filters button
                  if (state.searchQuery != null ||
                      state.selectedDifficulty != null ||
                      state.selectedEquipment != null ||
                      state.selectedExerciseType != null)
                    ActionChip(
                      label: Text(l10n.clearFilters),
                      avatar: const Icon(AppIcons.clearAll, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(databaseManagerProvider.notifier).resetFilters();
                      },
                    ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(
    BuildContext context,
    AppLocalizations l10n,
    DatabaseManagerState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Row(
        children: [
          Text(
            '${state.selectionCount} ${l10n.selected}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),

          // Bulk actions
          TextButton.icon(
            onPressed: () => _showBulkEditDialog(context, l10n),
            icon: const Icon(AppIcons.edit, size: 18),
            label: Text(l10n.bulkEdit),
          ),
          const SizedBox(width: 8),

          TextButton.icon(
            onPressed: () => _confirmBulkDelete(context, l10n),
            icon: const Icon(AppIcons.delete, size: 18, color: Colors.red),
            label: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    AppLocalizations l10n,
    DatabaseManagerState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(databaseManagerProvider.notifier).loadExercises(),
              icon: const Icon(AppIcons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state.filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.searchOff, size: 64),
            const SizedBox(height: 16),
            Text(l10n.noExercisesFound),
            const SizedBox(height: 8),
            if (state.searchQuery != null || state.selectedDifficulty != null)
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  ref.read(databaseManagerProvider.notifier).resetFilters();
                },
                icon: const Icon(AppIcons.clear),
                label: Text(l10n.clearFilters),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(databaseManagerProvider.notifier).loadExercises(forceRefresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: state.filteredExercises.length,
        itemBuilder: (context, index) {
          final exercise = state.filteredExercises[index];
          final isSelected = state.selectedExerciseIds.contains(exercise.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExerciseQuickEditCard(
              exercise: exercise,
              isSelected: isSelected,
              onSelectionChanged: _isMultiSelectMode
                  ? (_) => ref
                      .read(databaseManagerProvider.notifier)
                      .toggleExerciseSelection(exercise.id)
                  : null,
              onTap: () {
                if (_isMultiSelectMode) {
                  ref
                      .read(databaseManagerProvider.notifier)
                      .toggleExerciseSelection(exercise.id);
                } else {
                  _openExerciseEditor(context, exercise);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAB(BuildContext context, AppLocalizations l10n) {
    return FloatingActionButton.extended(
      onPressed: () => _openExerciseEditor(context, null),
      icon: const Icon(AppIcons.add),
      label: Text(l10n.addExercise),
    );
  }

  void _applySearch() {
    ref.read(databaseManagerProvider.notifier).applyFilters(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  void _applyFilter(String filterType, String? value) {
    final notifier = ref.read(databaseManagerProvider.notifier);

    switch (filterType) {
      case 'difficulty':
        notifier.applyFilters(difficulty: value);
        break;
      case 'equipment':
        notifier.applyFilters(equipment: value);
        break;
      case 'exerciseType':
        notifier.applyFilters(exerciseType: value);
        break;
    }
  }

  void _handleMenuAction(String action, BuildContext context, AppLocalizations l10n) {
    switch (action) {
      case 'export_all':
        _exportExercises(context, l10n, false);
        break;
      case 'export_selected':
        _exportExercises(context, l10n, true);
        break;
      case 'import':
        _showImportDialog(context, l10n);
        break;
      case 'refresh':
        ref.read(databaseManagerProvider.notifier).loadExercises(forceRefresh: true);
        break;
    }
  }

  Future<void> _exportExercises(
    BuildContext context,
    AppLocalizations l10n,
    bool selectedOnly,
  ) async {
    final json = await ref
        .read(databaseManagerProvider.notifier)
        .exportExercises(selectedOnly: selectedOnly);

    if (json != null) {
      // Copy to clipboard for now (simplified export)
      await Clipboard.setData(ClipboardData(text: json));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('JSON copiato negli appunti'),
            action: SnackBarAction(
              label: l10n.ok,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showImportDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importJson),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.importJsonDescription),
            const SizedBox(height: 16),
            Text(
              l10n.importWarning,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement file picker and import
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.comingSoon)),
              );
            },
            child: Text(l10n.selectFile),
          ),
        ],
      ),
    );
  }

  void _showBulkEditDialog(BuildContext context, AppLocalizations l10n) {
    final dropdownValues = ref.read(exerciseDropdownValuesProvider).value;
    if (dropdownValues == null) return;

    String? selectedField;
    String? selectedValue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.bulkEdit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Field selector
              DropdownButtonFormField<String>(
                initialValue: selectedField,
                decoration: InputDecoration(
                  labelText: l10n.selectField,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'difficolta', child: Text(l10n.difficulty)),
                  DropdownMenuItem(value: 'attrezzatura', child: Text(l10n.equipment)),
                  DropdownMenuItem(value: 'tipoEsercizio', child: Text(l10n.exerciseType)),
                  DropdownMenuItem(value: 'rangeRipetizioni', child: Text(l10n.repRange)),
                ],
                onChanged: (value) => setState(() {
                  selectedField = value;
                  selectedValue = null;
                }),
              ),

              if (selectedField != null) ...[
                const SizedBox(height: 16),

                // Value selector
                DropdownButtonFormField<String>(
                  initialValue: selectedValue,
                  decoration: InputDecoration(
                    labelText: l10n.newValue,
                    border: const OutlineInputBorder(),
                  ),
                  items: _getBulkEditValues(selectedField!, dropdownValues)
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedValue = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: selectedField != null && selectedValue != null
                  ? () {
                      Navigator.of(context).pop();
                      ref.read(databaseManagerProvider.notifier).bulkUpdateField(
                            selectedField!,
                            selectedValue!,
                          );
                    }
                  : null,
              child: Text(l10n.apply),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getBulkEditValues(String field, ExerciseDropdownValues values) {
    switch (field) {
      case 'difficolta':
        return values.difficulties;
      case 'attrezzatura':
        return values.equipments;
      case 'tipoEsercizio':
        return values.exerciseTypes;
      case 'rangeRipetizioni':
        return values.repRanges;
      default:
        return [];
    }
  }

  void _confirmBulkDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMultiple(
          ref.read(databaseManagerProvider).selectionCount,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(databaseManagerProvider.notifier).deleteSelectedExercises();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _openExerciseEditor(BuildContext context, Exercise? exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseEditorScreen(exercise: exercise),
      ),
    ).then((_) {
      // Refresh list after editing
      ref.read(databaseManagerProvider.notifier).loadExercises();
    });
  }
}

/// Stat chip widget
class _StatChip extends StatelessWidget {

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

/// Filter chip dropdown
class _FilterChip extends StatelessWidget {

  const _FilterChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(20),
        color: value != null
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dropdown button
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(label, style: const TextStyle(fontSize: 12)),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(label),
                ),
                ...items.map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 12)),
                    )),
              ],
              onChanged: onChanged,
              isDense: true,
              icon: value == null
                  ? const Icon(AppIcons.arrowDropDown, size: 18)
                  : const SizedBox.shrink(),
            ),
          ),

          // Clear button (only when value is selected)
          if (value != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onChanged(null),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.clear,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
