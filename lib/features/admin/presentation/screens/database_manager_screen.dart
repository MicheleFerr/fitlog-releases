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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/database_manager_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/widgets/exercise_quick_edit_card.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/database_manager_service.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/exercise_editor_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_publish_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:intl/intl.dart';
// 📊 Analytics migration imports
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

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
          // Version Management Card
          _buildVersionManagementCard(context, l10n, ref),

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
                  const Icon(AppIcons.upload),
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
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'migrate_analytics',
              child: Row(
                children: [
                  Icon(AppIcons.analytics),
                  SizedBox(width: 8),
                  Text('Migrate Analytics'), // Hardcoded for now (admin only)
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
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
              icon: AppIcons.accessibility,
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
            color: context.colors.onSurface.withValues(alpha: 0.05),
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
            icon: Icon(AppIcons.delete, size: 18, color: context.colors.error),
            label: Text(l10n.delete, style: TextStyle(color: context.colors.error)),
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
      return const Center(child: LoadingIndicator());
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
      case 'migrate_analytics':
        _showMigrationDialog(context, l10n);
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
        SnackBarService.showSuccess(
          context,
          'JSON copiato negli appunti',
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
              SnackBarService.showInfo(context, l10n.comingSoon);
            },
            child: Text(l10n.selectFile),
          ),
        ],
      ),
    );
  }

  /// 📊 Show analytics migration dialog
  ///
  /// **Flow**:
  /// 1. Show confirmation dialog with warning
  /// 2. Execute migration via AnalyticsMigrationService
  /// 3. Show loading dialog during migration
  /// 4. Display results (success/error)
  Future<void> _showMigrationDialog(BuildContext context, AppLocalizations l10n) async {
    // Get current user ID
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (context.mounted) {
        SnackBarService.showError(
          context,
          'User not authenticated', // Admin screen - hardcoded OK
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(AppIcons.analytics),
            SizedBox(width: 8),
            Text('Migrate Analytics'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will migrate all existing workouts to the analytics collection.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 What this does:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Reads all completed workouts'),
                  Text('• Extracts exercise sessions'),
                  Text('• Updates analytics collection'),
                  SizedBox(height: 12),
                  Text(
                    '✅ Safe: Can be run multiple times',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Start Migration'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingIndicator(),
              SizedBox(height: 16),
              Text('Migrating analytics...'),
              SizedBox(height: 8),
              Text(
                'This may take a few seconds',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Execute migration
    try {
      final migrationService = ref.read(analyticsMigrationServiceProvider);
      final result = await migrationService.migrateUserWorkouts(userId: userId);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Handle result
      result.fold(
        // Error case
        (failure) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(AppIcons.error, color: context.colors.error),
                    const SizedBox(width: 8),
                    const Text('Migration Failed'),
                  ],
                ),
                content: Text(
                  'Error: ${failure.message}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          }
        },
        // Success case
        (stats) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(AppIcons.checkCircle, color: context.colors.success),
                    const SizedBox(width: 8),
                    const Text('Migration Complete'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Successfully migrated workouts to analytics collection!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📊 Workouts processed: ${stats.totalWorkouts}'),
                          Text('🏋️ Unique exercises: ${stats.totalExercises}'),
                          Text('📈 Total sessions: ${stats.totalSessions}'),
                          Text('💪 Total sets: ${stats.totalSets}'),
                          if (stats.skippedExercises.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('⚠️ Skipped: ${stats.skippedExercises.length} exercises'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          }
        },
      );
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(AppIcons.error, color: context.colors.error),
                const SizedBox(width: 8),
                const Text('Migration Error'),
              ],
            ),
            content: Text(
              'Unexpected error: $e',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    }
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

  /// Build Version Management Card
  Widget _buildVersionManagementCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final versionMetadataAsync = ref.watch(versionMetadataProvider);

    return versionMetadataAsync.when(
      data: (metadata) {
        final currentVersion = metadata?['current_version'] as String? ?? '1.0.0';
        final lastUpdated = metadata?['last_updated'] as Timestamp?;
        final totalExercises = metadata?['total_exercises'] as int? ?? 0;
        final changelog = metadata?['changelog'] as List<dynamic>? ?? [];

        final dateStr = lastUpdated != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(lastUpdated.toDate())
            : 'N/A';

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primaryContainer,
                context.colors.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.onSurface.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.storage,
                          color: context.colors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.versionHistory,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () => _showPublishDialog(context, l10n, currentVersion, ref),
                      icon: const Icon(AppIcons.publish),
                      label: Text(l10n.publishNewVersion),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Version Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile(
                        context,
                        l10n.currentVersion,
                        currentVersion,
                        AppIcons.tag,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        context,
                        l10n.lastPublished,
                        dateStr,
                        AppIcons.calendar,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoTile(
                        context,
                        l10n.totalExercisesInDb,
                        totalExercises.toString(),
                        AppIcons.workout,
                      ),
                    ),
                  ],
                ),

                // Latest Changelog
                if (changelog.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.changelog} (Latest):',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildChangelogEntry(context, changelog.first as Map<String, dynamic>),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: context.colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogEntry(BuildContext context, Map<String, dynamic> entry) {
    final changes = entry['changes'] as List<dynamic>? ?? [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: changes.map((change) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: context.textTheme.bodyMedium),
                Expanded(
                  child: Text(
                    change.toString(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Show Publish New Version Dialog
  void _showPublishDialog(
    BuildContext context,
    AppLocalizations l10n,
    String currentVersion,
    WidgetRef ref,
  ) {
    final service = ref.read(exercisePublishServiceProvider);
    final newVersion = service.incrementVersion(currentVersion);

    final changelogController = TextEditingController();
    bool isRequired = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.publishVersion),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Version Number (read-only, auto-incremented)
                Text(
                  l10n.versionNumber,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.tag, size: 20, color: context.colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        newVersion,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Changelog Input
                Text(
                  l10n.changelog,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: changelogController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.changelogHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Force Update Checkbox
                CheckboxListTile(
                  value: isRequired,
                  onChanged: (value) {
                    setState(() => isRequired = value ?? false);
                  },
                  title: Text(l10n.forceUpdate),
                  subtitle: Text(
                    l10n.forceUpdateDesc,
                    style: context.textTheme.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (changelogController.text.trim().isEmpty) {
                  SnackBarService.showError(
                    context,
                    'Changelog cannot be empty',
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                // Show loading
                if (context.mounted) {
                  SnackBarService.showInfo(context, l10n.publishing);
                }

                try {
                  // Parse changelog (split by newlines)
                  final changelogEntries = changelogController.text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  // Publish new version
                  await service.publishNewVersion(
                    version: newVersion,
                    changelogEntries: changelogEntries,
                    isRequired: isRequired,
                  );

                  if (context.mounted) {
                    SnackBarService.showSuccess(
                      context,
                      l10n.versionPublished(newVersion),
                    );

                    // Refresh metadata
                    ref.invalidate(versionMetadataProvider);
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackBarService.showError(
                      context,
                      l10n.publishFailed(e.toString()),
                    );
                  }
                }
              },
              child: Text(l10n.publishVersion),
            ),
          ],
        ),
      ),
    );
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
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
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