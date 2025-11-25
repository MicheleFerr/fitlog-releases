/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// MigrationDialog - UI dialog for migrating historical workouts to analytics
///
/// **Purpose**: One-time migration UI with progress indicator
///
/// **Features**:
/// - Confirmation dialog before migration
/// - Loading indicator during migration
/// - Statistics display after completion
/// - Error handling with retry option
///
/// **Usage**:
/// ```dart
/// ElevatedButton(
///   onPressed: () => showMigrationDialog(context, ref),
///   child: Text('Migrate Workout History'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/data/services/analytics_migration_service.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Show migration dialog
///
/// **Parameters**:
/// - context: BuildContext for dialog
/// - ref: WidgetRef for providers
void showMigrationDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _MigrationDialog(ref: ref),
  );
}

/// Migration dialog widget
class _MigrationDialog extends StatefulWidget {

  const _MigrationDialog({required this.ref});
  final WidgetRef ref;

  @override
  State<_MigrationDialog> createState() => _MigrationDialogState();
}

class _MigrationDialogState extends State<_MigrationDialog> {
  bool _isMigrating = false;
  MigrationStats? _stats;
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_isMigrating) {
      return _buildLoadingDialog(context);
    }

    if (_stats != null) {
      return _buildSuccessDialog(context, _stats!);
    }

    if (_error != null) {
      return _buildErrorDialog(context, _error!);
    }

    return _buildConfirmationDialog(context);
  }

  /// Confirmation dialog (initial state)
  Widget _buildConfirmationDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.migrateWorkoutHistory),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.migrationWarning,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.migrationDescription,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _startMigration,
          child: Text(context.l10n.migrate),
        ),
      ],
    );
  }

  /// Loading dialog (during migration)
  Widget _buildLoadingDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.migratingWorkouts),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(
            context.l10n.pleaseWait,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Success dialog (after migration)
  Widget _buildSuccessDialog(BuildContext context, MigrationStats stats) {
    return AlertDialog(
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.checkCircle,
            semanticLabel: context.l10n.migrationComplete,
            color: context.colors.success,
            size: AppIconSize.dialog,
          ),
          const SizedBox(width: 12),
          Text(context.l10n.migrationComplete),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow(
            context,
            context.l10n.workoutsProcessed,
            '${stats.totalWorkouts}',
          ),
          _buildStatRow(
            context,
            context.l10n.uniqueExercises,
            '${stats.totalExercises}',
          ),
          _buildStatRow(
            context,
            context.l10n.totalSessions,
            '${stats.totalSessions}',
          ),
          _buildStatRow(
            context,
            context.l10n.totalSets,
            '${stats.totalSets}',
          ),
          if (stats.skippedExercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${context.l10n.skipped}: ${stats.skippedExercises.length}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.warning,
              ),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Invalidate providers to refresh data
            widget.ref.invalidate(exerciseHistoryStreamProvider);
          },
          child: Text(context.l10n.done),
        ),
      ],
    );
  }

  /// Error dialog (if migration fails)
  Widget _buildErrorDialog(BuildContext context, String error) {
    return AlertDialog(
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.migrationFailed,
            color: context.colors.error,
            size: AppIconSize.dialog,
          ),
          const SizedBox(width: 12),
          Text(context.l10n.migrationFailed),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _error = null;
            });
            _startMigration();
          },
          child: Text(context.l10n.retry),
        ),
      ],
    );
  }

  /// Build statistic row
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Start migration process
  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _stats = null;
      _error = null;
    });

    try {
      final userId = widget.ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final migrationService =
          widget.ref.read(analyticsMigrationServiceProvider);

      final result = await migrationService.migrateUserWorkouts(userId: userId);

      result.fold(
        (failure) {
          setState(() {
            _isMigrating = false;
            _error = failure.message;
          });
        },
        (stats) {
          setState(() {
            _isMigrating = false;
            _stats = stats;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _error = e.toString();
      });
    }
  }
}
