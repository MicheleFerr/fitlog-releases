import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Tab Cronologia: mostra lo storico delle esecuzioni dell'esercizio raggruppate per data
class ExerciseHistoryTab extends ConsumerStatefulWidget {
  const ExerciseHistoryTab({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  ConsumerState<ExerciseHistoryTab> createState() => _ExerciseHistoryTabState();
}

class _ExerciseHistoryTabState extends ConsumerState<ExerciseHistoryTab> {
  final Map<String, bool> _expandedDates = {};
  late DateFormat _dateFormatter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).toString();
    _dateFormatter = DateFormat('EEEE, dd MMMM yyyy', locale);
  }

  @override
  Widget build(BuildContext context) {
    final useRirMode = ref.watch(useRirModeProvider);
    final historyDataAsync = ref.watch(
      exerciseHistoryDataGroupedProvider(widget.exerciseName),
    );

    return historyDataAsync.when(
      data: (historyMap) {
        if (historyMap.isEmpty) {
          return _buildEmptyState();
        }

        // Converti la mappa in lista ordinata per data
        final historyList = historyMap.entries.map((entry) {
          return (date: entry.key, items: entry.value);
        }).toList()..sort((a, b) => b.date.compareTo(a.date));

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              exerciseHistoryDataGroupedProvider(widget.exerciseName),
            );
          },
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.tabBarInset),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final dateGroup = historyList[index];
              final date = dateGroup.date;
              final items = dateGroup.items;
              final dateKey = date.toIso8601String();
              final isExpanded = _expandedDates[dateKey] ?? false;

              return _buildDateGroup(
                date,
                items,
                isExpanded,
                dateKey,
                useRirMode,
              );
            },
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.errorOutline,
              semanticLabel: 'Error outline',
              size: AppIconSize.medium,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingHistory,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.history,
            semanticLabel: 'History',
            size: AppIconSize.emptyState,
            color: context.colors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noHistoryYet,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.startWorkoutToSeeHistory,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(
    DateTime date,
    List<ExerciseHistoryData> items,
    bool isExpanded,
    String dateKey,
    bool useRirMode,
  ) {
    final formattedDate = _dateFormatter.format(date);

    // Calcola totali per questa data
    final totalSets = items.length;
    final totalVolume = items.fold<double>(0, (sum, item) {
      final weight = item.weight ?? 0.0;
      final reps = item.reps ?? 0;
      return sum + (weight * reps);
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header della data (sempre visibile)
          InkWell(
            onTap: () {
              setState(() {
                _expandedDates[dateKey] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icona data
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppIcons.calendarToday,
                      color: context.colors.primary,
                      size: AppIconSize.small,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Data e info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalSets ${context.l10n.sets} · ${totalVolume.toStringAsFixed(0)} kg ${context.l10n.totalVolume}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icona espandi/comprimi
                  Icon(
                    isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          // Lista set (espandibile)
          if (isExpanded) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildHistoryItem(item, index + 1, useRirMode);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    ExerciseHistoryData item,
    int setNumber,
    bool useRirMode,
  ) {
    final weight = item.weight ?? 0.0;
    final reps = item.reps ?? 0;
    final workoutName = item.workoutName;
    final effortLabel = _formatEffortLabel(item.rpe, useRirMode);
    final hasNotes = item.notes?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Numero set
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$setNumber',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.secondary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Peso e reps
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (item.weight != null)
                      _buildMetric(
                        icon: AppIcons.fitnessCenter,
                        semanticLabel: 'Fitness center',
                        color: context.colors.primary,
                        text:
                            '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg',
                      ),
                    if (item.reps != null)
                      _buildMetric(
                        icon: AppIcons.repeat,
                        semanticLabel: 'Repeat',
                        color: context.colors.secondary,
                        text: '$reps ${context.l10n.reps}',
                      ),
                    if (effortLabel != null)
                      _buildMetric(
                        icon: AppIcons.localFireDepartment,
                        semanticLabel: 'Effort',
                        color: context.colors.tertiary,
                        text: effortLabel,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  workoutName,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (hasNotes) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        AppIcons.note,
                        size: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.notes!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String semanticLabel,
    required Color color,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: semanticLabel,
          size: AppIconSize.tiny,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }

  String? _formatEffortLabel(int? rpe, bool useRirMode) {
    if (rpe == null) return null;

    final rir = _rpeToRir(rpe);
    final primary = useRirMode
        ? '${context.l10n.rir} $rir'
        : '${context.l10n.rpe} $rpe';
    final secondary = useRirMode
        ? '${context.l10n.rpe} $rpe'
        : '${context.l10n.rir} $rir';

    return '$primary · $secondary';
  }

  int _rpeToRir(int rpe) {
    final rir = 10 - rpe;
    if (rir < 0) return 0;
    if (rir > 5) return 5;
    return rir;
  }
}
