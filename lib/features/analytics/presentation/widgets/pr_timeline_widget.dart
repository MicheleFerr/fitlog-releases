import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Widget showing personal records timeline
class PRTimelineWidget extends StatelessWidget {

  const PRTimelineWidget({
    super.key,
    required this.personalRecords,
  });
  final List<PersonalRecord> personalRecords;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    if (personalRecords.isEmpty) {
      return _buildEmptyState(context, localizations);
    }
    
    // Sort by date descending (most recent first)
    final sortedPRs = personalRecords.toList()
      ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.achievement,
                  color: context.colors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.personalRecords,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${personalRecords.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sortedPRs.length,
                itemBuilder: (context, index) {
                  return _buildPRCard(context, sortedPRs[index], colorScheme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPRCard(BuildContext context, PersonalRecord pr, ColorScheme colorScheme) {
    final dateFormat = DateFormat('MMM d');
    final isNew = DateTime.now().difference(pr.achievedAt).inDays <= 7;
    
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isNew
            ? LinearGradient(
                colors: [
                  context.colors.warning.withValues(alpha: 0.3),
                  context.colors.warning.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isNew ? null : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: isNew
            ? Border.all(color: context.colors.warning, width: 2)
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getIconForPRType(pr.type),
                size: 16,
                color: isNew ? context.colors.warning : colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getPRTypeLabel(pr.type),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.warning,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: context.colors.surface,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pr.exerciseName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _getFormattedValue(pr),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                dateFormat.format(pr.achievedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (pr.isSignificant) ...[
                const SizedBox(width: 4),
                Icon(
                  AppIcons.trendUp,
                  size: 12,
                  color: context.colors.success,
                ),
                Text(
                  '+${pr.improvementPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: context.colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                AppIcons.achievement,
                size: 48,
                color: context.colors.surfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.noPRsYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.surfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForPRType(PRType type) {
    switch (type) {
      case PRType.weight:
        return AppIcons.workout;
      case PRType.reps:
        return AppIcons.repeat;
      case PRType.volume:
        return AppIcons.barChart;
      case PRType.oneRM:
        return AppIcons.looksOne;
      case PRType.totalSets:
        return AppIcons.formatListNumbered;
      case PRType.duration:
        return AppIcons.timer;
    }
  }
  
  String _getPRTypeLabel(PRType type) {
    switch (type) {
      case PRType.weight:
        return 'Max Weight';
      case PRType.reps:
        return 'Max Reps';
      case PRType.volume:
        return 'Volume';
      case PRType.oneRM:
        return '1RM';
      case PRType.totalSets:
        return 'Sets';
      case PRType.duration:
        return 'Duration';
    }
  }
  
  String _getFormattedValue(PersonalRecord pr) {
    switch (pr.type) {
      case PRType.weight:
      case PRType.oneRM:
        return '${pr.value.toStringAsFixed(1)}kg';
      case PRType.volume:
        return '${(pr.value / 1000).toStringAsFixed(1)}t';
      case PRType.reps:
      case PRType.totalSets:
        return pr.value.toInt().toString();
      case PRType.duration:
        final minutes = pr.value.toInt();
        return '${minutes}min';
    }
  }
}