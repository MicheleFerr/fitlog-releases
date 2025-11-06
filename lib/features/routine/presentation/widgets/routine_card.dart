/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ROUTINE CARD - Display flexible routine with stats and actions
///
/// Features:
/// - Active badge for current routine
/// - Progress bar and completion stats
/// - Quick actions (Activate, View, Archive, Delete)
/// - Skip rate and adherence indicators
/// - Visual feedback for routine state
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Card widget for displaying a flexible routine
class RoutineCard extends StatelessWidget {

  const RoutineCard({
    super.key,
    required this.routine,
    this.showActiveBadge = false,
    this.onTap,
    this.onActivate,
    this.onArchive,
    this.onDelete,
  });
  final FlexibleRoutine routine;
  final bool showActiveBadge;
  final VoidCallback? onTap;
  final VoidCallback? onActivate;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: showActiveBadge ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: showActiveBadge
            ? BorderSide(
                color: context.colors.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and badge
              _buildHeader(context),

              const SizedBox(height: 12),

              // Routine type and dates
              _buildMetadata(context),

              const SizedBox(height: 16),

              // Progress bar
              _buildProgressBar(context),

              const SizedBox(height: 12),

              // Statistics chips
              _buildStatistics(context),

              const SizedBox(height: 16),

              // Action buttons
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.name,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showActiveBadge) ...[
                SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.complete,
                        size: 14,
                        color: context.colors.onPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ACTIVE',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Routine type icon
        _buildTypeIcon(context),
      ],
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (routine.type) {
      case RoutineType.weekly:
        icon = AppIcons.calendarViewWeek;
        color = context.colors.primary;
        break;
      case RoutineType.monthly:
        icon = AppIcons.calendarMonth;
        color = context.colors.secondary;
        break;
      case RoutineType.bimonthly:
        icon = AppIcons.dateRange;
        color = context.colors.tertiary;
        break;
      case RoutineType.semester:
        icon = AppIcons.eventNote;
        color = context.colors.tertiary;
        break;
      case RoutineType.custom:
        icon = AppIcons.tune;
        color = context.colors.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final typeLabel = _getTypeLabel(routine.type);
    final duration = routine.endDate.difference(routine.startDate).inDays + 1;
    final remaining =
        routine.endDate.difference(DateTime.now()).inDays.clamp(0, duration);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildInfoChip(
          context,
          icon: AppIcons.category,
          label: typeLabel,
          color: context.colors.primary,
        ),
        _buildInfoChip(
          context,
          icon: AppIcons.clock,
          label: '$remaining days left',
          color: context.colors.secondary,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = routine.progressPercentage;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
            Text(
              '$percentage%',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                context.colors.primaryContainer.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final adherence = routine.adherenceRate;
    final skipRate = routine.skipRate;

    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            context,
            icon: AppIcons.trendUp,
            label: 'Adherence',
            value: '${adherence.toInt()}%',
            color: _getAdherenceColor(context, adherence),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            context,
            icon: AppIcons.eventBusy,
            label: 'Skipped',
            value: '${routine.skipTracker.totalSkips}',
            color: context.colors.secondary,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            context,
            icon: AppIcons.complete,
            label: 'Completed',
            value: '${routine.completedDays}/${routine.totalWorkoutDays}',
            color: context.colors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // View button
        TextButton.icon(
          onPressed: onTap,
          icon: Icon(AppIcons.visibility, size: 16),
          label: Text('View'),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.primary,
          ),
        ),

        if (!showActiveBadge && onActivate != null) ...[
          SizedBox(width: 8),
          // Activate button
          ElevatedButton.icon(
            onPressed: onActivate,
            icon: Icon(AppIcons.play, size: 16),
            label: Text('Activate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],

        // More actions menu
        IconButton(
          onPressed: () => _showMoreActions(context),
          icon: Icon(AppIcons.moreVert),
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Actions
            if (onArchive != null)
              ListTile(
                leading: Icon(
                  routine.isArchived ? Icons.unarchive : AppIcons.archive,
                  color: context.colors.secondary,
                ),
                title: Text(
                  routine.isArchived ? 'Unarchive' : 'Archive',
                  style: context.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onArchive?.call();
                },
              ),

            if (onDelete != null)
              ListTile(
                leading: Icon(
                  AppIcons.delete,
                  color: context.colors.error,
                ),
                title: Text(
                  'Delete',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(RoutineType type) {
    switch (type) {
      case RoutineType.weekly:
        return 'Weekly';
      case RoutineType.monthly:
        return 'Monthly';
      case RoutineType.bimonthly:
        return 'Bimonthly';
      case RoutineType.semester:
        return 'Semester';
      case RoutineType.custom:
        return 'Custom';
    }
  }

  Color _getAdherenceColor(BuildContext context, double adherence) {
    if (adherence >= 80) {
      return context.colors.success;
    } else if (adherence >= 60) {
      return context.colors.secondary;
    } else {
      return context.colors.error;
    }
  }
}
