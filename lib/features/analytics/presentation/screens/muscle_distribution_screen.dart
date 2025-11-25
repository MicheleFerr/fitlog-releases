/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/screens
/// 🎯 Feature: analytics
/// 🔧 Type: screen
///
/// Schermata di analisi distribuzione muscolare con radar chart
///
/// Features:
/// - Tab system (Progressi, Analisi, Dettagli)
/// - Radar chart esagonale con 6 assi muscolari
/// - Time period dropdown (Ultimi 7/30/90 giorni, etc.)
/// - 4 stat cards con confronto periodo precedente
/// - 3 action buttons (Serie per muscolo, Distribuzione, Feedback)
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_distribution_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:url_launcher/url_launcher.dart';

/// Provider per il periodo temporale selezionato
final selectedTimePeriodProvider =
    StateProvider.autoDispose<TimePeriod>((ref) => TimePeriod.last30Days);

/// Schermata principale distribuzione muscolare con tab
class MuscleDistributionScreen extends ConsumerStatefulWidget {
  const MuscleDistributionScreen({super.key});

  @override
  ConsumerState<MuscleDistributionScreen> createState() =>
      _MuscleDistributionScreenState();
}

class _MuscleDistributionScreenState
    extends ConsumerState<MuscleDistributionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.back,
            semanticLabel: context.l10n.back,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.muscleDistribution,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: ColoredBox(
            color: context.colors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              indicatorColor: context.colors.primary,
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.onSurfaceVariant,
              tabs: [
                Tab(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
                        icon: AppIcons.trendUp,
                        semanticLabel: context.l10n.progress,
                        size: AppIconSize.small,
                      ),
                      const SizedBox(width: 8),
                      Text(context.l10n.progress),
                    ],
                  ),
                ),
                Tab(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
                        icon: AppIcons.barChart,
                        semanticLabel: context.l10n.analysis,
                        size: AppIconSize.small,
                      ),
                      const SizedBox(width: 8),
                      Text(context.l10n.analysis),
                    ],
                  ),
                ),
                Tab(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
                        icon: AppIcons.info,
                        semanticLabel: context.l10n.details,
                        size: AppIconSize.small,
                      ),
                      const SizedBox(width: 8),
                      Text(context.l10n.details),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProgressTab(),
          _AnalysisTab(),
          _DetailsTab(),
        ],
      ),
    );
  }
}

/// Tab "Progressi" con radar chart e statistiche
class _ProgressTab extends ConsumerWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedTimePeriodProvider);

    // TODO: Replace with real data from provider
    final mockData = MuscleAnalyticsData.empty(selectedPeriod);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period dropdown
          _TimePeriodDropdown(),
          const SizedBox(height: 24),

          // Radar chart
          _MuscleRadarChart(data: mockData),
          const SizedBox(height: 32),

          // Stats cards
          _StatsCardsGrid(stats: mockData),
        ],
      ),
    );
  }
}

/// Tab "Analisi" con 3 action buttons
class _AnalysisTab extends ConsumerWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sezione titolo
          Text(
            context.l10n.availableAnalytics,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 3 action buttons
          _ActionButton(
            icon: AppIcons.barChart,
            title: context.l10n.setsByMuscleGroup,
            description: context.l10n.setsByMuscleGroupDesc,
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to sets by muscle group screen
            },
          ),
          const SizedBox(height: 12),

          _ActionButton(
            icon: AppIcons.pieChart,
            title: context.l10n.muscleDistribution,
            description: context.l10n.muscleDistributionDesc,
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to muscle distribution detail screen
            },
          ),
          const SizedBox(height: 12),

          _ActionButton(
            icon: AppIcons.feedback,
            title: context.l10n.requestNewMetric,
            description: context.l10n.requestNewMetricDesc,
            onTap: () {
              HapticFeedback.lightImpact();
              _showFeedbackDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// Mostra dialog per richiedere nuove metriche via email
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.requestNewMetric),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.requestNewMetricDialogContent),
            const SizedBox(height: 16),
            SelectableText(
              'ferrara-michele@hotmail.it',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close),
          ),
          FilledButton.icon(
            onPressed: () async {
              final emailUri = Uri(
                scheme: 'mailto',
                path: 'ferrara-michele@hotmail.it',
                query: 'subject=${Uri.encodeComponent('Richiesta nuova metrica - GymBro TrackLog')}&body=${Uri.encodeComponent('Ciao,\n\nVorrei richiedere una nuova metrica:\n\n[Descrivi qui la metrica che vorresti vedere nell\'app]\n\nGrazie!')}',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            icon: SemanticIcon.button(
              icon: AppIcons.email,
              semanticLabel: context.l10n.sendEmail,
            ),
            label: Text(context.l10n.sendEmail),
          ),
        ],
      ),
    );
  }
}

/// Tab "Dettagli" (placeholder per future features)
class _DetailsTab extends StatelessWidget {
  const _DetailsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.info,
            semanticLabel: context.l10n.comingSoon,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.comingSoon,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dropdown per selezione periodo temporale
class _TimePeriodDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedTimePeriodProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimePeriod>(
          value: selectedPeriod,
          isExpanded: true,
          icon: SemanticIcon(
            icon: AppIcons.expandMore,
            semanticLabel: context.l10n.selectTimePeriod,
            size: AppIconSize.medium,
          ),
          items: TimePeriod.values.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(
                // TODO: Use context.locale to determine IT vs EN
                period.labelIT,
                style: context.textTheme.bodyLarge,
              ),
            );
          }).toList(),
          onChanged: (newPeriod) {
            if (newPeriod != null) {
              HapticFeedback.lightImpact();
              ref.read(selectedTimePeriodProvider.notifier).state = newPeriod;
            }
          },
        ),
      ),
    );
  }
}

/// Radar chart esagonale per distribuzione muscolare
class _MuscleRadarChart extends StatelessWidget {
  const _MuscleRadarChart({required this.data});

  final MuscleAnalyticsData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Title
          Text(
            context.l10n.muscleDistribution,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Radar chart
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 10,
                ),
                radarBorderData: BorderSide(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
                gridBorderData: BorderSide(
                  color: context.colors.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: context.colors.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                getTitle: (index, angle) {
                  final muscle = MuscleGroup.values[index];
                  return RadarChartTitle(
                    text: muscle.displayNameIT,
                    angle: angle,
                  );
                },
                dataSets: [
                  // Current period (blue)
                  RadarDataSet(
                    fillColor: context.colors.primary.withValues(alpha: 0.2),
                    borderColor: context.colors.primary,
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: MuscleGroup.values.map((muscle) {
                      final percentage =
                          data.current.volumePercentage[muscle] ?? 0.0;
                      return RadarEntry(value: percentage);
                    }).toList(),
                  ),
                  // Previous period (gray)
                  RadarDataSet(
                    fillColor:
                        context.colors.onSurfaceVariant.withValues(alpha: 0.1),
                    borderColor: context.colors.onSurfaceVariant,
                    borderWidth: 1,
                    entryRadius: 2,
                    dataEntries: MuscleGroup.values.map((muscle) {
                      final percentage =
                          data.previous.volumePercentage[muscle] ?? 0.0;
                      return RadarEntry(value: percentage);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: context.colors.primary,
                label: context.l10n.currentPeriod,
              ),
              const SizedBox(width: 24),
              _LegendItem(
                color: context.colors.onSurfaceVariant,
                label: context.l10n.previousPeriod,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Legend item per radar chart
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Grid di 4 stat cards con confronto periodo precedente
class _StatsCardsGrid extends StatelessWidget {
  const _StatsCardsGrid({required this.stats});

  final MuscleAnalyticsData stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: AppIcons.calendar,
          label: context.l10n.workouts,
          currentValue: stats.currentStats.workoutsCount.toString(),
          previousValue: stats.previousStats.workoutsCount.toString(),
        ),
        _StatCard(
          icon: AppIcons.timer,
          label: context.l10n.duration,
          currentValue: '${stats.currentStats.totalDurationMinutes}min',
          previousValue: '${stats.previousStats.totalDurationMinutes}min',
        ),
        _StatCard(
          icon: AppIcons.weight,
          label: context.l10n.volume,
          currentValue: '${stats.currentStats.totalVolumeKg.toStringAsFixed(0)} kg',
          previousValue: '${stats.previousStats.totalVolumeKg.toStringAsFixed(0)} kg',
        ),
        _StatCard(
          icon: AppIcons.repeat,
          label: context.l10n.sets,
          currentValue: stats.currentStats.totalSets.toString(),
          previousValue: stats.previousStats.totalSets.toString(),
        ),
      ],
    );
  }
}

/// Singola stat card con confronto periodo precedente
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.currentValue,
    required this.previousValue,
  });

  final IconData icon;
  final String label;
  final String currentValue;
  final String previousValue;

  @override
  Widget build(BuildContext context) {
    // Calculate trend (up/down/neutral)
    final current = int.tryParse(currentValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final previous = int.tryParse(previousValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final isIncreasing = current > previous;
    final isDecreasing = current < previous;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + Label
          Row(
            children: [
              SemanticIcon(
                icon: icon,
                semanticLabel: label,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Current value + trend arrow
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentValue,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (isIncreasing)
                SemanticIcon(
                  icon: AppIcons.arrowUpward,
                  semanticLabel: context.l10n.increased,
                  size: AppIconSize.tiny,
                  color: context.iconSuccess,
                )
              else if (isDecreasing)
                SemanticIcon(
                  icon: AppIcons.arrowDownward,
                  semanticLabel: context.l10n.decreased,
                  size: AppIconSize.tiny,
                  color: context.iconError,
                ),
            ],
          ),

          // Previous value (small gray text)
          Text(
            '${context.l10n.previous}: $previousValue',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button per le analisi disponibili
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SemanticIcon(
                  icon: icon,
                  semanticLabel: title,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: context.l10n.viewDetails,
                size: AppIconSize.medium,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
