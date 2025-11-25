/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/migration/presentation
/// 🎯 Feature: Data Migration UI
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations
/// 🎨 Theme: ✅ Theme.of(context)
/// 📱 Platform: Universal
///
/// Schermata per la migrazione dei dati da exerciseActivities a workouts
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/migration/presentation/providers/migration_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class MigrationScreen extends ConsumerWidget {
  const MigrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final migrationState = ref.watch(migrationProvider);
    final migrationNotifier = ref.read(migrationProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dataMigration),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  _buildHeaderCard(context, migrationState),
                  const SizedBox(height: 16),

                  // Options card
                  if (migrationState.hasDataToMigrate) ...[
                    _buildOptionsCard(context, migrationState, migrationNotifier),
                    const SizedBox(height: 16),
                  ],

                  // Preview/Results
                  if (migrationState.result != null) ...[
                    _buildResultCard(context, migrationState),
                    const SizedBox(height: 16),
                  ],

                  // Progress
                  if (migrationState.isLoading) ...[
                    _buildProgressCard(context, migrationState),
                    const SizedBox(height: 16),
                  ],

                  // Extra space at bottom for action buttons
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          // Action buttons fixed at bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _buildActionButtons(context, migrationState, migrationNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, MigrationState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.syncAlt,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dataMigration,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dataMigrationDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            if (!state.hasDataToMigrate && !state.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.noDataToMigrate,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(
    BuildContext context,
    MigrationState state,
    MigrationNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.migrationOptions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Time window option
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.timeWindowHours,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownButton<int>(
                  value: state.options.timeWindowHours,
                  items: [1, 2, 3, 4, 6, 8, 12].map((hours) {
                    return DropdownMenuItem(
                      value: hours,
                      child: Text('$hours ${l10n.hours}'),
                    );
                  }).toList(),
                  onChanged: state.isLoading ? null : (value) {
                    if (value != null) {
                      notifier.updateOptions(
                        state.options.copyWith(timeWindowHours: value),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Backup option
            SwitchListTile(
              title: Text(l10n.createBackup),
              subtitle: Text(l10n.createBackupDescription),
              value: state.options.createBackup,
              onChanged: state.isLoading ? null : (value) {
                notifier.updateOptions(
                  state.options.copyWith(createBackup: value),
                );
              },
            ),

            // Min exercises option
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.minExercisesPerWorkout,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownButton<int>(
                  value: state.options.minExercisesPerWorkout,
                  items: [1, 2, 3, 4, 5].map((count) {
                    return DropdownMenuItem(
                      value: count,
                      child: Text('$count'),
                    );
                  }).toList(),
                  onChanged: state.isLoading ? null : (value) {
                    if (value != null) {
                      notifier.updateOptions(
                        state.options.copyWith(minExercisesPerWorkout: value),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, MigrationState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final result = state.result!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.status == MigrationStatus.analyzed
                ? l10n.migrationPreview
                : l10n.migrationResults,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Statistics
            _buildStatRow(
              context,
              l10n.totalExercises,
              '${result.totalExercises}',
              AppIcons.workout,
            ),
            _buildStatRow(
              context,
              l10n.workoutsFound,
              '${result.totalWorkouts}',
              AppIcons.eventNote,
            ),
            if (state.isCompleted) ...[
              _buildStatRow(
                context,
                l10n.migratedWorkouts,
                '${result.migratedWorkouts}',
                AppIcons.complete,
                color: colorScheme.primary,
              ),
              if (result.skippedExercises > 0)
                _buildStatRow(
                  context,
                  l10n.skippedExercises,
                  '${result.skippedExercises}',
                  AppIcons.skipNext,
                  color: colorScheme.outline,
                ),
            ],

            // Errors
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.errors,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...result.errors.map((error) => Text(
                      '• $error',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    )),
                  ],
                ),
              ),
            ],

            // Workout groups preview
            if (result.workoutGroups.isNotEmpty && state.status == MigrationStatus.analyzed) ...[
              const SizedBox(height: 16),
              Text(
                l10n.workoutGroupsPreview,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: result.workoutGroups.length,
                  itemBuilder: (context, index) {
                    final group = result.workoutGroups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          AppIcons.eventNote,
                          color: colorScheme.primary,
                        ),
                        title: Text(group.schedaName),
                        subtitle: Text(
                          '${group.exerciseCount} ${l10n.exercises} • ${_formatDuration(group.duration)}',
                        ),
                        trailing: Text(
                          _formatDate(group.startTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, MigrationState state) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.status == MigrationStatus.analyzing
                ? l10n.analyzing
                : l10n.migrating,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            if (state.currentMessage != null)
              Text(
                state.currentMessage!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              '${(state.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final defaultColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? defaultColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color ?? defaultColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MigrationState state,
    MigrationNotifier notifier,
  ) {
    final l10n = AppLocalizations.of(context);

    if (!state.hasDataToMigrate && !state.isLoading) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.pop(),
          child: Text(l10n.goBack),
        ),
      );
    }

    return Column(
      children: [
        // Analyze button
        if (state.status == MigrationStatus.initial || state.hasError)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isLoading ? null : () => notifier.previewMigration(),
              icon: const SemanticIcon(
  icon: AppIcons.search,
  semanticLabel: 'Search',
),
              label: Text(l10n.analyzeData),
            ),
          ),

        // Execute button
        if (state.canExecute) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showConfirmationDialog(context, notifier),
              icon: const SemanticIcon(
  icon: AppIcons.syncIcon,
  semanticLabel: 'Sync icon',
),
              label: Text(l10n.startMigration),
            ),
          ),
        ],

        // Reset button
        if (state.status != MigrationStatus.initial && !state.isLoading) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => notifier.reset(),
              icon: const SemanticIcon(
  icon: AppIcons.refresh,
  semanticLabel: 'Refresh',
),
              label: Text(l10n.reset),
            ),
          ),
        ],

        // Back button
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.goBack),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context, MigrationNotifier notifier) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmMigration),
        content: Text(l10n.confirmMigrationDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.executeMigration();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
