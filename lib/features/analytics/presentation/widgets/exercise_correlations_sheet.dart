/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Exercise Correlations Bottom Sheet - L2 Progressive Disclosure
///
/// **Key Features**:
/// - Displays Weight vs RPE and Volume vs RPE correlations
/// - 50% initial height, expandable to 95%
/// - Closes before navigation to L3 (Critical Fix #1)
/// - Uses cached correlations from exerciseAnalyticsProvider
///
/// **Usage**:
/// ```dart
/// ExerciseCorrelationsSheet.show(
///   context,
///   exerciseId: exerciseId,
///   exerciseName: exerciseName,
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_analytics_data.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_analytics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Bottom sheet displaying correlation analytics for an exercise
class ExerciseCorrelationsSheet extends ConsumerStatefulWidget {
  const ExerciseCorrelationsSheet({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  final String exerciseId;
  final String exerciseName;

  /// Show the correlations bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String exerciseId,
    required String exerciseName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseCorrelationsSheet(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
      ),
    );
  }

  @override
  ConsumerState<ExerciseCorrelationsSheet> createState() =>
      _ExerciseCorrelationsSheetState();
}

class _ExerciseCorrelationsSheetState
    extends ConsumerState<ExerciseCorrelationsSheet> {
  // Track expanded state for collapsible sections
  bool _correlationsExpanded = true;
  bool _trendsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(exerciseAnalyticsProvider(widget.exerciseId));

    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // 50% height
      minChildSize: 0.3,
      maxChildSize: safeMax, // Safe max (avoids notch)
      snap: true,
      snapSizes: [0.5, safeMax],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.analytics,
                      color: context.colors.primary,
                      size: AppIconSize.large,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.analyticsCorrelationsTitle,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.exerciseName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        AppIcons.close,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: analyticsAsync.when(
                  data: (analytics) => analytics != null
                      ? _buildContent(analytics, scrollController)
                      : _buildNoData(),
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (e, _) => _buildError(e),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    ExerciseAnalyticsData analytics,
    ScrollController scrollController,
  ) {
    final correlations = analytics.correlations;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Quick summary at a glance
        _buildQuickSummary(analytics),
        const SizedBox(height: 20),

        // Data quality indicator
        _buildDataQualityCard(analytics),
        const SizedBox(height: 20),

        // Collapsible Correlations Section
        _buildCollapsibleSection(
          title: context.l10n.analyticsCorrelationsTitle,
          icon: AppIcons.insights,
          isExpanded: _correlationsExpanded,
          onToggle: () => setState(() => _correlationsExpanded = !_correlationsExpanded),
          child: Column(
            children: [
              // Weight vs RPE Correlation
              _buildCorrelationCard(
                title: context.l10n.analyticsWeightVsRpe,
                subtitle: context.l10n.analyticsWeightVsRpeDescription,
                result: correlations.weightRpe,
                icon: AppIcons.workout,
                color: context.colors.primary,
              ),
              const SizedBox(height: 16),

              // Volume vs RPE Correlation
              _buildCorrelationCard(
                title: context.l10n.analyticsVolumeVsRpe,
                subtitle: context.l10n.analyticsVolumeVsRpeDescription,
                result: correlations.volumeRpe,
                icon: AppIcons.analytics,
                color: context.colors.secondary,
              ),

              // Interpretation section
              if (correlations.hasSignificantCorrelations) ...[
                const SizedBox(height: 16),
                _buildInterpretationSection(correlations),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Collapsible Trend Section
        _buildCollapsibleSection(
          title: context.l10n.analyticsTrendSummary,
          icon: AppIcons.trendUp,
          isExpanded: _trendsExpanded,
          onToggle: () => setState(() => _trendsExpanded = !_trendsExpanded),
          child: _buildTrendContent(analytics),
        ),
        const SizedBox(height: 24),

        // Navigate to full analytics (L3)
        _buildFullAnalyticsButton(analytics),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Quick at-a-glance summary showing key metrics
  Widget _buildQuickSummary(ExerciseAnalyticsData analytics) {
    final trend = analytics.trend;
    final weightRpe = analytics.correlations.weightRpe;
    final volumeRpe = analytics.correlations.volumeRpe;

    // Determine the most relevant insight
    String quickInsight;
    IconData quickIcon;
    Color quickColor;

    if (trend.type == TrendType.improving) {
      quickInsight = context.l10n.analyticsTrendImproving;
      quickIcon = AppIcons.trendUp;
      quickColor = context.colors.success;
    } else if (trend.type == TrendType.declining) {
      quickInsight = context.l10n.analyticsTrendDeclining;
      quickIcon = AppIcons.trendDown;
      quickColor = context.colors.error;
    } else if (weightRpe.isSignificant || volumeRpe.isSignificant) {
      final strongestR = weightRpe.r.abs() > volumeRpe.r.abs() ? weightRpe : volumeRpe;
      quickInsight = strongestR.interpretation.isNotEmpty
          ? strongestR.interpretation
          : context.l10n.analyticsCorrelationsTitle;
      quickIcon = AppIcons.insights;
      quickColor = context.colors.tertiary;
    } else {
      quickInsight = context.l10n.analyticsInsightStable;
      quickIcon = AppIcons.trendFlat;
      quickColor = context.colors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            quickColor.withValues(alpha: 0.15),
            quickColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: quickColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: quickColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(quickIcon, color: quickColor, size: AppIconSize.large),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.analyticsKeyInsights,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: quickColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quickInsight,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a collapsible section with animated expand/collapse
  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        // Section header (always visible)
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: context.colors.primary, size: AppIconSize.medium),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    AppIcons.expandMore,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated content
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: child,
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  /// Build trend content (extracted from _buildTrendSummary)
  Widget _buildTrendContent(ExerciseAnalyticsData analytics) {
    final trend = analytics.trend;
    final overload = analytics.overload;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTrendItem(
                  icon: _getTrendIcon(trend.type),
                  label: context.l10n.analyticsTrend,
                  value: _getTrendLabel(trend.type),
                  color: _getTrendColor(trend.type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendItem(
                  icon: AppIcons.trendUp,
                  label: context.l10n.analyticsOverload,
                  value: '${overload.currentPercent.toStringAsFixed(1)}%',
                  color: _getOverloadColor(overload.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.lightbulb,
                  size: AppIconSize.small,
                  color: context.colors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trend.recommendation,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface,
                      fontStyle: FontStyle.italic,
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

  Widget _buildDataQualityCard(ExerciseAnalyticsData analytics) {
    final hasEnoughData = analytics.hasEnoughDataForCorrelations;
    final sessionCount = analytics.sessionCount;
    final dataSpanDays = analytics.dataSpanDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasEnoughData
            ? context.colors.primaryContainer.withValues(alpha: 0.3)
            : context.colors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasEnoughData
              ? context.colors.primary.withValues(alpha: 0.3)
              : context.colors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasEnoughData ? AppIcons.checkCircle : AppIcons.warning,
            color: hasEnoughData ? context.colors.primary : context.colors.error,
            size: AppIconSize.large,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasEnoughData
                      ? context.l10n.analyticsDataSufficient
                      : context.l10n.analyticsDataInsufficient,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasEnoughData
                        ? context.colors.primary
                        : context.colors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.analyticsDataPoints(sessionCount, dataSpanDays),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard({
    required String title,
    required String subtitle,
    required CorrelationResult result,
    required IconData icon,
    required Color color,
  }) {
    final strengthColor = _getStrengthColor(result.strength);
    final strengthLabel = _getStrengthLabel(result.strength);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: AppIconSize.medium),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Metrics row
          Row(
            children: [
              // R value
              Expanded(
                child: _buildMetricItem(
                  label: 'r',
                  value: result.r.toStringAsFixed(2),
                  color: result.isPositive
                      ? context.colors.success
                      : context.colors.error,
                  tooltip: context.l10n.analyticsRValueTooltip,
                ),
              ),
              // R² value
              Expanded(
                child: _buildMetricItem(
                  label: 'r²',
                  value: '${(result.rSquared * 100).toStringAsFixed(0)}%',
                  color: color,
                  tooltip: context.l10n.analyticsRSquaredTooltip,
                ),
              ),
              // Strength
              Expanded(
                child: _buildMetricItem(
                  label: context.l10n.analyticsStrength,
                  value: strengthLabel,
                  color: strengthColor,
                  tooltip: context.l10n.analyticsStrengthTooltip,
                ),
              ),
            ],
          ),

          // Significance indicator
          if (result.strength != CorrelationStrength.insufficient) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: result.isSignificant
                    ? context.colors.successContainer.withValues(alpha: 0.5)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    result.isSignificant ? AppIcons.checkCircle : AppIcons.info,
                    size: AppIconSize.small,
                    color: result.isSignificant
                        ? context.colors.success
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.isSignificant
                        ? context.l10n.analyticsStatisticallySignificant
                        : context.l10n.analyticsNotSignificant,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: result.isSignificant
                          ? context.colors.success
                          : context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Interpretation
          if (result.interpretation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              result.interpretation,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
    String? tooltip,
  }) {
    final content = Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: content,
      );
    }
    return content;
  }

  Widget _buildInterpretationSection(CorrelationResults correlations) {
    final insights = <String>[];

    // Weight-RPE insight
    if (correlations.weightRpe.isSignificant) {
      if (correlations.weightRpe.isPositive) {
        insights.add(context.l10n.analyticsInsightWeightRpePositive);
      } else {
        insights.add(context.l10n.analyticsInsightWeightRpeNegative);
      }
    }

    // Volume-RPE insight
    if (correlations.volumeRpe.isSignificant) {
      if (correlations.volumeRpe.isPositive) {
        insights.add(context.l10n.analyticsInsightVolumeRpePositive);
      } else {
        insights.add(context.l10n.analyticsInsightVolumeRpeNegative);
      }
    }

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.tertiaryContainer.withValues(alpha: 0.5),
            context.colors.tertiaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.insights,
                color: context.colors.tertiary,
                size: AppIconSize.medium,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.analyticsKeyInsights,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        insight,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTrendItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppIconSize.medium),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullAnalyticsButton(ExerciseAnalyticsData analytics) {
    return FilledButton.icon(
      onPressed: () {
        HapticFeedback.mediumImpact();
        // Critical Fix #1: Close bottom sheet before navigation
        Navigator.pop(context);
        // Navigate to L3 full analytics screen using named route
        context.pushNamed(
          AppRoutes.analyticsExerciseDetailName,
          pathParameters: {
            'exerciseName': Uri.encodeComponent(widget.exerciseName),
          },
        );
      },
      icon: const Icon(AppIcons.analytics),
      label: Text(context.l10n.analyticsViewFullAnalytics),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.analytics,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.analyticsNoDataTitle,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.analyticsNoDataDescription,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              size: 64,
              color: context.colors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.analyticsErrorLoading,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getStrengthColor(CorrelationStrength strength) {
    switch (strength) {
      case CorrelationStrength.strong:
        return context.colors.success;
      case CorrelationStrength.moderate:
        return context.colors.warning;
      case CorrelationStrength.weak:
        return context.colors.error;
      case CorrelationStrength.insufficient:
        return context.colors.onSurfaceVariant;
    }
  }

  String _getStrengthLabel(CorrelationStrength strength) {
    switch (strength) {
      case CorrelationStrength.strong:
        return context.l10n.analyticsCorrelationStrong;
      case CorrelationStrength.moderate:
        return context.l10n.analyticsCorrelationModerate;
      case CorrelationStrength.weak:
        return context.l10n.analyticsCorrelationWeak;
      case CorrelationStrength.insufficient:
        return context.l10n.analyticsCorrelationInsufficient;
    }
  }

  IconData _getTrendIcon(TrendType type) {
    switch (type) {
      case TrendType.improving:
        return AppIcons.trendingUp;
      case TrendType.declining:
        return AppIcons.trendingDown;
      case TrendType.plateau:
        return AppIcons.trendingFlat;
      case TrendType.inconsistent:
        return AppIcons.shuffle;
    }
  }

  String _getTrendLabel(TrendType type) {
    switch (type) {
      case TrendType.improving:
        return context.l10n.analyticsTrendImproving;
      case TrendType.declining:
        return context.l10n.analyticsTrendDeclining;
      case TrendType.plateau:
        return context.l10n.analyticsTrendPlateau;
      case TrendType.inconsistent:
        return context.l10n.analyticsTrendInconsistent;
    }
  }

  Color _getTrendColor(TrendType type) {
    switch (type) {
      case TrendType.improving:
        return context.colors.success;
      case TrendType.declining:
        return context.colors.error;
      case TrendType.plateau:
        return context.colors.warning;
      case TrendType.inconsistent:
        return context.colors.onSurfaceVariant;
    }
  }

  Color _getOverloadColor(OverloadStatus status) {
    switch (status) {
      case OverloadStatus.optimal:
        return context.colors.success;
      case OverloadStatus.belowTarget:
        return context.colors.warning;
      case OverloadStatus.aboveTarget:
        return context.colors.error;
      case OverloadStatus.noBaseline:
        return context.colors.onSurfaceVariant;
    }
  }
}
