/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// REP ZONE TAB
/// Shows distribution of training across rep zones:
/// - Strength (1-5 reps)
/// - Hypertrophy (6-15 reps)
/// - Endurance (15+ reps)
///
/// Based on Schoenfeld et al. (2021) research.
///
/// **New Features**:
/// - "Optimize Training" button when variety < 80%
/// - Actionable suggestions to balance rep zones
/// - Tinder-style swipe cards or classic list view
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/rep_zone_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/rep_zone_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/rep_zone_optimization_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rep Zone Distribution Tab
///
/// Shows how training is distributed across different rep ranges,
/// helping users understand if their training aligns with their goals.
///
/// **Optimization Feature**:
/// When variety is low (>80% in one zone), shows an "Optimize Training"
/// button that opens a modal with actionable suggestions.
class RepZoneTab extends ConsumerStatefulWidget {
  const RepZoneTab({super.key, required this.exerciseHistories});

  final List<ExerciseHistory> exerciseHistories;

  @override
  ConsumerState<RepZoneTab> createState() => _RepZoneTabState();
}

class _RepZoneTabState extends ConsumerState<RepZoneTab>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  bool _showPieChart = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    // Calculate rep zone data from exercise histories
    final data = _calculateRepZoneData();

    if (data.totalSets == 0) {
      return _buildEmptyState(context);
    }

    // Check if optimization is needed using RepZoneSuggestionEngine
    final analysis = ref.watch(
      repZoneAnalysisProvider(widget.exerciseHistories),
    );
    final needsOptimization =
        analysis.needsSuggestions &&
        analysis.totalSets >= RepZoneSuggestionEngine.minimumSetsForAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            l10n.repZoneDistribution,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.repZoneDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Optimization CTA (when variety is low)
          if (needsOptimization) ...[
            _buildOptimizationCTA(context, analysis),
            const SizedBox(height: 24),
          ],

          // Total sets badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.totalSetsAnalyzed(data.totalSets),
                style: context.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Toggle chart (tap to switch between bar and pie)
          _buildToggleChart(context, data),
          const SizedBox(height: 32),

          // Zone breakdown cards
          _ZoneCard(
            icon: AppIcons.fitnessCenter,
            title: l10n.strengthZone,
            subtitle: '1-5 ${l10n.reps}',
            description: l10n.strengthZoneDesc,
            percentage: data.strengthPercentage,
            sets: data.strengthSets,
            color: colorScheme.error,
          ),
          const SizedBox(height: 12),
          _ZoneCard(
            icon: AppIcons.trendUp,
            title: l10n.hypertrophyZone,
            subtitle: '6-15 ${l10n.reps}',
            description: l10n.hypertrophyZoneDesc,
            percentage: data.hypertrophyPercentage,
            sets: data.hypertrophySets,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _ZoneCard(
            icon: AppIcons.timer,
            title: l10n.enduranceZone,
            subtitle: '15+ ${l10n.reps}',
            description: l10n.enduranceZoneDesc,
            percentage: data.endurancePercentage,
            sets: data.enduranceSets,
            color: colorScheme.tertiary,
          ),
          const SizedBox(height: 24),

          // Recommendation
          _buildRecommendation(context, data),
          const SizedBox(height: 24),

          // Scientific citation
          _buildScientificCitation(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build optimization CTA button
  Widget _buildOptimizationCTA(BuildContext context, RepZoneAnalysis analysis) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppIcons.autoAwesome,
              color: colorScheme.primary,
              size: AppIconSize.large,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lowVarietyDetected,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.optimizeTrainingHint,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _openOptimizationSheet(analysis),
            icon: const Icon(AppIcons.arrowForward, size: AppIconSize.small),
            label: Text(l10n.optimize),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Open optimization sheet
  void _openOptimizationSheet(RepZoneAnalysis analysis) async {
    debugPrint('🔍 [REP_ZONE_TAB] _openOptimizationSheet called');
    debugPrint(
      '🔍 [REP_ZONE_TAB] exerciseHistories: ${widget.exerciseHistories.length}',
    );
    HapticFeedback.mediumImpact();

    // Show loading dialog
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoadingIndicator(),
              const SizedBox(height: 16),
              Text(
                context.l10n.loadingSuggestions,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
    debugPrint('🔍 [REP_ZONE_TAB] Loading dialog shown');

    try {
      debugPrint('🔍 [REP_ZONE_TAB] Calling provider...');
      // Load suggestions with timeout
      final suggestions = await ref
          .read(repZoneSuggestionsProvider(widget.exerciseHistories).future)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏱️ [REP_ZONE_TAB] TIMEOUT after 10s!');
              return <RepZoneSuggestion>[];
            },
          );
      debugPrint('🔍 [REP_ZONE_TAB] Got ${suggestions.length} suggestions');

      // Close loading dialog
      debugPrint('🔍 [REP_ZONE_TAB] mounted=$mounted');
      if (!mounted) {
        debugPrint('❌ [REP_ZONE_TAB] NOT MOUNTED - returning');
        return;
      }
      debugPrint('🔍 [REP_ZONE_TAB] Closing loading dialog...');
      Navigator.of(context, rootNavigator: true).pop();
      debugPrint('🔍 [REP_ZONE_TAB] Dialog closed');

      // Open optimization sheet
      if (suggestions.isEmpty) {
        debugPrint('🔍 [REP_ZONE_TAB] No suggestions - showing snackbar');
        // No suggestions available
        SnackBarService.showInfo(context, context.l10n.noSuggestionsAvailable);
        return;
      }

      debugPrint(
        '🔍 [REP_ZONE_TAB] Opening bottom sheet with ${suggestions.length} suggestions...',
      );
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: context.colors.surface.withValues(alpha: 0),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => RepZoneOptimizationSheet(
            suggestions: suggestions,
            analysis: analysis,
          ),
        ),
      );
      debugPrint('🔍 [REP_ZONE_TAB] Bottom sheet closed');
    } catch (e, stack) {
      debugPrint('❌ [REP_ZONE_TAB] ERROR: $e');
      debugPrint('❌ [REP_ZONE_TAB] STACK: $stack');
      // Close loading dialog on error
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      SnackBarService.showError(context, context.l10n.errorLoadingExercises);
    }
  }

  RepContinuumData _calculateRepZoneData() {
    int strengthSets = 0;
    int hypertrophySets = 0;
    int enduranceSets = 0;
    int totalSets = 0;

    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        for (final set in session.sets) {
          totalSets++;
          if (set.reps <= 5) {
            strengthSets++;
          } else if (set.reps <= 15) {
            hypertrophySets++;
          } else {
            enduranceSets++;
          }
        }
      }
    }

    return RepContinuumData(
      strengthPercentage: totalSets > 0
          ? (strengthSets / totalSets * 100)
          : 0.0,
      hypertrophyPercentage: totalSets > 0
          ? (hypertrophySets / totalSets * 100)
          : 0.0,
      endurancePercentage: totalSets > 0
          ? (enduranceSets / totalSets * 100)
          : 0.0,
      strengthSets: strengthSets,
      hypertrophySets: hypertrophySets,
      enduranceSets: enduranceSets,
      totalSets: totalSets,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.barChart,
              size: AppIconSize.xxlarge,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDataYet,
              style: context.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completeWorkoutsToSeeStats,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle chart widget - switches between bar and pie via SegmentedButton
  Widget _buildToggleChart(BuildContext context, RepContinuumData data) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Column(
      children: [
        // Toggle button
        SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
              value: false,
              icon: const Icon(AppIcons.barChart, size: AppIconSize.small),
              label: Text(l10n.barChart),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: const Icon(AppIcons.pieChart, size: AppIconSize.small),
              label: Text(l10n.pieChart),
            ),
          ],
          selected: {_showPieChart},
          onSelectionChanged: (Set<bool> newSelection) {
            setState(() {
              _showPieChart = newSelection.first;
              _touchedIndex = -1;
            });
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primaryContainer;
              }
              return colorScheme.surface;
            }),
          ),
        ),
        const SizedBox(height: 16),
        // Chart container
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _showPieChart ? 200 : 48,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _showPieChart
                ? _buildPieChart(context, data)
                : _buildStackedBar(context, data),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedBar(BuildContext context, RepContinuumData data) {
    final colorScheme = context.colors;

    return ClipRRect(
      key: const ValueKey('bar'),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            if (data.strengthPercentage > 0)
              Expanded(
                flex: (data.strengthPercentage * 100).toInt().clamp(1, 10000),
                child: Container(
                  color: colorScheme.error,
                  alignment: Alignment.center,
                  child: data.strengthPercentage > 12
                      ? Text(
                          '${data.strengthPercentage.toStringAsFixed(0)}%',
                          style: context.textTheme.labelMedium!.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            if (data.hypertrophyPercentage > 0)
              Expanded(
                flex: (data.hypertrophyPercentage * 100).toInt().clamp(
                  1,
                  10000,
                ),
                child: Container(
                  color: colorScheme.primary,
                  alignment: Alignment.center,
                  child: data.hypertrophyPercentage > 12
                      ? Text(
                          '${data.hypertrophyPercentage.toStringAsFixed(0)}%',
                          style: context.textTheme.labelMedium!.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            if (data.endurancePercentage > 0)
              Expanded(
                flex: (data.endurancePercentage * 100).toInt().clamp(1, 10000),
                child: Container(
                  color: colorScheme.tertiary,
                  alignment: Alignment.center,
                  child: data.endurancePercentage > 12
                      ? Text(
                          '${data.endurancePercentage.toStringAsFixed(0)}%',
                          style: context.textTheme.labelMedium!.copyWith(
                            color: colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, RepContinuumData data) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    final sections = <PieChartSectionData>[];

    // Strength zone
    if (data.strengthPercentage > 0) {
      final isTouched = _touchedIndex == 0;
      sections.add(
        PieChartSectionData(
          color: colorScheme.error,
          value: data.strengthPercentage,
          title: isTouched
              ? '${l10n.strengthZone}\n${data.strengthPercentage.toStringAsFixed(1)}%'
              : '${data.strengthPercentage.toStringAsFixed(0)}%',
          radius: isTouched ? 75 : 65,
          titleStyle:
              (isTouched
                      ? context.textTheme.labelMedium
                      : context.textTheme.labelSmall)!
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onError,
                  ),
          titlePositionPercentageOffset: 0.55,
        ),
      );
    }

    // Hypertrophy zone
    if (data.hypertrophyPercentage > 0) {
      final isTouched = _touchedIndex == (data.strengthPercentage > 0 ? 1 : 0);
      sections.add(
        PieChartSectionData(
          color: colorScheme.primary,
          value: data.hypertrophyPercentage,
          title: isTouched
              ? '${l10n.hypertrophyZone}\n${data.hypertrophyPercentage.toStringAsFixed(1)}%'
              : '${data.hypertrophyPercentage.toStringAsFixed(0)}%',
          radius: isTouched ? 75 : 65,
          titleStyle:
              (isTouched
                      ? context.textTheme.labelMedium
                      : context.textTheme.labelSmall)!
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
          titlePositionPercentageOffset: 0.55,
        ),
      );
    }

    // Endurance zone
    if (data.endurancePercentage > 0) {
      int sectionIndex = 0;
      if (data.strengthPercentage > 0) sectionIndex++;
      if (data.hypertrophyPercentage > 0) sectionIndex++;
      final isTouched = _touchedIndex == sectionIndex;
      sections.add(
        PieChartSectionData(
          color: colorScheme.tertiary,
          value: data.endurancePercentage,
          title: isTouched
              ? '${l10n.enduranceZone}\n${data.endurancePercentage.toStringAsFixed(1)}%'
              : '${data.endurancePercentage.toStringAsFixed(0)}%',
          radius: isTouched ? 75 : 65,
          titleStyle:
              (isTouched
                      ? context.textTheme.labelMedium
                      : context.textTheme.labelSmall)!
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiary,
                  ),
          titlePositionPercentageOffset: 0.55,
        ),
      );
    }

    return SizedBox(
      key: const ValueKey('pie'),
      height: 200,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 3,
          centerSpaceRadius: 35,
          sections: sections,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutQuart,
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, RepContinuumData data) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    String recommendation;
    IconData icon;
    Color iconColor;

    if (data.hypertrophyPercentage >= 60) {
      recommendation = l10n.repContinuumRecommendationBalanced;
      icon = AppIcons.checkCircle;
      iconColor = colorScheme.primary;
    } else if (data.strengthPercentage > 50) {
      recommendation = l10n.repContinuumRecommendationStrength;
      icon = AppIcons.fitnessCenter;
      iconColor = colorScheme.error;
    } else if (data.endurancePercentage > 50) {
      recommendation = l10n.repContinuumRecommendationEndurance;
      icon = AppIcons.timer;
      iconColor = colorScheme.tertiary;
    } else {
      recommendation = l10n.repContinuumRecommendationMixed;
      icon = AppIcons.info;
      iconColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: AppIconSize.medium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(recommendation, style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificCitation(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return InkWell(
      onTap: () => _launchPaper(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              AppIcons.experiment,
              size: AppIconSize.medium,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scientificBasis,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Schoenfeld et al. (2021) - J Strength Cond Res',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.openInNew,
              size: AppIconSize.small,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPaper() async {
    final uri = Uri.parse('https://doi.org/10.1519/JSC.0000000000003932');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Zone Card - Shows details for each rep zone
class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.percentage,
    required this.sets,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final double percentage;
  final int sets;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color indicator and icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: AppIconSize.medium),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subtitle,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$sets sets',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
