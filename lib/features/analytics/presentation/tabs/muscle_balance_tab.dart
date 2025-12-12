/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// MUSCLE BALANCE TAB
/// Shows muscle balance analysis with push/pull ratio,
/// upper/lower ratio, heatmap, and exercise suggestions.
///
/// Features:
/// - Balance score (0-10)
/// - Push/Pull and Upper/Lower ratios
/// - Muscle heatmap visualization
/// - Neglected muscle detection
/// - Exercise suggestions
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/ratio_breakdown.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/balance_trend_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/ratio_breakdown_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/expandable_ratio_card.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_suggestions_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Muscle Balance Tab
///
/// Shows comprehensive muscle balance analysis with actionable insights.
class MuscleBalanceTab extends StatefulWidget {
  const MuscleBalanceTab({
    super.key,
    required this.exerciseHistories,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  State<MuscleBalanceTab> createState() => _MuscleBalanceTabState();
}

class _MuscleBalanceTabState extends State<MuscleBalanceTab> {
  TimePeriod _selectedPeriod = TimePeriod.last30Days;
  late BalanceTrendCalculator _trendCalculator;
  late RatioBreakdownCalculator _ratioBreakdownCalculator;
  late BalanceTrendData _trendData;
  late RatioBreakdown _ratioBreakdown;

  @override
  void initState() {
    super.initState();
    _trendCalculator = BalanceTrendCalculator();
    _ratioBreakdownCalculator = RatioBreakdownCalculator();
    _updateTrendData();
  }

  @override
  void didUpdateWidget(MuscleBalanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exerciseHistories != oldWidget.exerciseHistories) {
      _updateTrendData();
    }
  }

  void _updateTrendData() {
    setState(() {
      _trendData = _trendCalculator.calculateTrend(
        exerciseHistories: widget.exerciseHistories,
        period: _selectedPeriod,
      );
      // Use corrected breakdown to fix historical data issues
      // (e.g., Leg Extension incorrectly categorized as chest)
      _ratioBreakdown = _ratioBreakdownCalculator.calculateCorrectedBreakdown(
        widget.exerciseHistories,
      );
    });
  }

  void _onPeriodChanged(TimePeriod? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedPeriod = newPeriod;
      });
      _updateTrendData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final balance = _trendData.currentMetrics;

    if (widget.exerciseHistories.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            l10n.muscleBalance,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.muscleBalanceDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Time period filter
          _buildTimePeriodFilter(context),
          const SizedBox(height: 16),

          // Trend indicator (if previous data exists)
          if (_trendData.previousMetrics != null) ...[
            _TrendIndicator(trendData: _trendData),
            const SizedBox(height: 16),
          ],

          // Balance Score Card
          _buildBalanceScoreCard(context, balance),
          const SizedBox(height: 24),

          // Ratio cards
          Text(
            l10n.ratioAnalysis,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ExpandableRatioCard(
            icon: AppIcons.balance,
            title: l10n.pushPullRatio,
            ratio: balance.pushPullRatio,
            hasWarning: balance.pushPullWarning,
            description: l10n.pushPullDescription,
            firstCategory: _ratioBreakdown.pushBreakdown,
            secondCategory: _ratioBreakdown.pullBreakdown,
            firstCategoryName: l10n.pushCategory,
            secondCategoryName: l10n.pullCategory,
          ),
          const SizedBox(height: 12),
          ExpandableRatioCard(
            icon: AppIcons.accessibility,
            title: l10n.upperLowerRatio,
            ratio: balance.upperLowerRatio,
            hasWarning: balance.upperLowerWarning,
            description: l10n.upperLowerDescription,
            firstCategory: _ratioBreakdown.upperBreakdown,
            secondCategory: _ratioBreakdown.lowerBreakdown,
            firstCategoryName: l10n.upperCategory,
            secondCategoryName: l10n.lowerCategory,
          ),

          // Warnings section
          if (balance.hasWarnings) ...[
            const SizedBox(height: 24),
            _buildWarningsSection(context, balance),
          ],

          // Muscle Heatmap - Anatomical Body View
          if (balance.muscleVolumePercentages.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              l10n.muscleHeatmap,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 480,
              child: ProfessionalBodyHeatmap(
                heatValues: MuscleHeatValues(
                  balance.muscleVolumePercentages,
                ),
              ),
            ),
          ],

          // Exercise Suggestions
          const SizedBox(height: 32),
          Text(
            l10n.exerciseSuggestions,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final detector = NeglectedMuscleDetector();
              final neglectedMuscles = detector.detectNeglectedMuscles(balance);

              return ExerciseSuggestionsWidget(
                neglectedMuscles: neglectedMuscles,
                onExerciseAdded: () {
                  HapticFeedback.mediumImpact();
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
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
              AppIcons.accessibility,
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

  Widget _buildTimePeriodFilter(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.timeFilter,
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          DropdownButton<TimePeriod>(
            value: _selectedPeriod,
            onChanged: _onPeriodChanged,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: TimePeriod.last7Days,
                child: Text(l10n.last7Days),
              ),
              DropdownMenuItem(
                value: TimePeriod.last30Days,
                child: Text(l10n.last30Days),
              ),
              DropdownMenuItem(
                value: TimePeriod.last3Months,
                child: Text(l10n.last3Months),
              ),
              DropdownMenuItem(
                value: TimePeriod.lastYear,
                child: Text(l10n.lastYear),
              ),
              DropdownMenuItem(
                value: TimePeriod.allTime,
                child: Text(l10n.allTime),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceScoreCard(
      BuildContext context, MuscleBalanceMetrics balance) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // Color based on score
    final Color scoreColor;
    if (balance.balanceScore >= 7.5) {
      scoreColor = const Color(0xFF4CAF50); // Green
    } else if (balance.balanceScore >= 6.0) {
      scoreColor = const Color(0xFFFFA726); // Orange
    } else {
      scoreColor = colorScheme.error; // Red
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withValues(alpha: 0.15),
            scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: scoreColor.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                balance.balanceScore.toStringAsFixed(1),
                style: context.textTheme.headlineMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.balanceScore,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getLocalizedRating(context, balance.balanceRating),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.outOf10,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedRating(BuildContext context, String rating) {
    final l10n = context.l10n;
    switch (rating) {
      case 'Excellent':
        return l10n.balanceRatingExcellent;
      case 'Good':
        return l10n.balanceRatingGood;
      case 'Fair':
        return l10n.balanceRatingFair;
      case 'Needs Improvement':
        return l10n.balanceRatingNeedsImprovement;
      case 'Poor':
        return l10n.balanceRatingPoor;
      default:
        return rating;
    }
  }

  Widget _buildWarningsSection(
      BuildContext context, MuscleBalanceMetrics balance) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    final warnings = <String>[];

    if (balance.pushPullWarning) {
      warnings.add(l10n.pushPullImbalance);
    }

    if (balance.upperLowerWarning) {
      warnings.add(l10n.upperLowerImbalance);
    }

    if (balance.neglectedMuscles.isNotEmpty) {
      warnings.add(
        l10n.neglectedMusclesWarning(balance.neglectedMuscles.length),
      );
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.warning,
                size: AppIconSize.small,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.warningsDetected,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    Expanded(
                      child: Text(
                        warning,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Trend Indicator - Shows balance trend over time
class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trendData});

  final BalanceTrendData trendData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    final IconData trendIcon;
    final Color trendColor;
    final String trendText;

    switch (trendData.trendDirection) {
      case TrendDirection.improving:
        trendIcon = AppIcons.trendingUp;
        trendColor = const Color(0xFF4CAF50);
        trendText = l10n.trendImproving;
        break;
      case TrendDirection.declining:
        trendIcon = AppIcons.trendingDown;
        trendColor = colorScheme.error;
        trendText = l10n.trendDeclining;
        break;
      case TrendDirection.stable:
        trendIcon = AppIcons.trendingFlat;
        trendColor = colorScheme.onSurfaceVariant;
        trendText = l10n.trendStable;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            trendIcon,
            size: AppIconSize.medium,
            color: trendColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trendText,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${trendData.percentageChange >= 0 ? '+' : ''}${trendData.percentageChange.toStringAsFixed(1)}% ${l10n.comparedToPrevious}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
