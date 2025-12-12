/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// PRO ANALYTICS SECTION
/// Premium analytics section with layered complexity:
/// - FREE users: Preview cards with blur + upgrade CTA
/// - PREMIUM users: Full expandable analytics with charts
///
/// Best Practice 2025: "Layered Complexity" pattern
/// - Show value before paywall
/// - Don't interrupt workflow
/// - Subtle but persistent upgrade reminders
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_heatmap_data.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/balance_trend_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_suggestions_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/muscle_heatmap_widget.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Pro Analytics Section - Shows premium analytics with layered complexity
///
/// When isPremium = false:
/// - Shows preview cards with blur overlay
/// - Single CTA button to upgrade
///
/// When isPremium = true:
/// - Shows full expandable analytics cards
/// - Interactive charts with real data
class ProAnalyticsSection extends ConsumerStatefulWidget {
  const ProAnalyticsSection({
    super.key,
    required this.exerciseHistories,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  ConsumerState<ProAnalyticsSection> createState() => _ProAnalyticsSectionState();
}

class _ProAnalyticsSectionState extends ConsumerState<ProAnalyticsSection> {
  // Track which cards are expanded (for premium users)
  final Set<String> _expandedCards = {};

  @override
  Widget build(BuildContext context) {
    // Check if user has access via paid premium OR tier-based entitlement (Platinum)
    final isPaidPremium = ref.watch(isPremiumUserProvider);
    final hasTierProAnalytics = ref.watch(hasProAnalyticsProvider);
    final isPremium = isPaidPremium || hasTierProAnalytics;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate real stats from user data
    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with PRO badge
          _buildHeader(context, isPremium),

          // Content: Different based on premium status
          if (isPremium)
            _buildPremiumContent(context, stats)
          else
            _buildFreePreview(context, stats),

          // CTA for free users
          if (!isPremium) _buildUpgradeCTA(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // PRO badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiary,
                  colorScheme.tertiary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.premium,
                  size: AppIconSize.small,
                  color: colorScheme.onTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  'PRO',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Title + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.proInsights,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPremium
                      ? l10n.proAnalyticsUnlocked
                      : l10n.proInsightsSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPremium
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.checkCircle,
                    size: AppIconSize.tiny,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.active,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Premium content: Full expandable analytics cards
  Widget _buildPremiumContent(BuildContext context, _ProStats stats) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Rep Zone Distribution
          _ProAnalyticsCard(
            id: 'rep_zones',
            icon: AppIcons.barChart,
            title: l10n.repZoneDistribution,
            subtitle: l10n.repZoneDescription,
            isExpanded: _expandedCards.contains('rep_zones'),
            onToggle: () => _toggleCard('rep_zones'),
            child: _RepZoneChart(stats: stats),
          ),
          const SizedBox(height: 12),

          // Volume Progression
          _ProAnalyticsCard(
            id: 'volume',
            icon: AppIcons.trendUp,
            title: l10n.volumeProgression,
            subtitle: l10n.volumeProgressionDescription,
            isExpanded: _expandedCards.contains('volume'),
            onToggle: () => _toggleCard('volume'),
            child: _VolumeProgressionChart(stats: stats),
          ),
          const SizedBox(height: 12),

          // Muscle Balance
          _ProAnalyticsCard(
            id: 'muscle_balance',
            icon: AppIcons.accessibility,
            title: l10n.muscleBalance,
            subtitle: l10n.muscleBalanceDescription,
            isExpanded: _expandedCards.contains('muscle_balance'),
            onToggle: () => _toggleCard('muscle_balance'),
            child: _MuscleBalanceChart(
              stats: stats,
              exerciseHistories: widget.exerciseHistories,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Free preview: Blurred cards with lock overlay
  Widget _buildFreePreview(BuildContext context, _ProStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Stack(
        children: [
          // Preview content (blurred)
          Column(
            children: [
              _PreviewCard(
                icon: AppIcons.barChart,
                title: l10n.repZoneDistribution,
                value: '${stats.strengthPercent}% / ${stats.hypertrophyPercent}% / ${stats.endurancePercent}%',
              ),
              const SizedBox(height: 8),
              _PreviewCard(
                icon: AppIcons.trendUp,
                title: l10n.volumeProgression,
                value: '+${stats.volumeChange}% ${l10n.thisWeek}',
              ),
              const SizedBox(height: 8),
              _PreviewCard(
                icon: AppIcons.accessibility,
                title: l10n.muscleBalance,
                value: stats.topMuscles.take(3).join(', '),
              ),
            ],
          ),

          // Blur + lock overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: colorScheme.surface.withValues(alpha: 0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.lock,
                            size: AppIconSize.xlarge,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.unlockProAnalytics,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            l10n.proAnalyticsDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCTA(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/premium');
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.tertiary,
            foregroundColor: colorScheme.onTertiary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(AppIcons.premium, size: AppIconSize.small),
          label: Text(
            l10n.upgradeToPro,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCard(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedCards.contains(id)) {
        _expandedCards.remove(id);
      } else {
        _expandedCards.add(id);
      }
    });
  }

  _ProStats _calculateStats() {
    if (widget.exerciseHistories.isEmpty) {
      return _ProStats.empty();
    }

    // Calculate rep zone distribution
    int strengthSets = 0; // 1-5 reps
    int hypertrophySets = 0; // 6-12 reps
    int enduranceSets = 0; // 13+ reps
    int totalSets = 0;

    // Calculate volume by week
    final Map<int, double> weeklyVolumes = {};
    final now = DateTime.now();

    // Track muscle groups
    final Map<String, int> muscleFrequency = {};

    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        // Week calculation
        final weekDiff = now.difference(session.date).inDays ~/ 7;
        if (weekDiff < 4) {
          weeklyVolumes[weekDiff] = (weeklyVolumes[weekDiff] ?? 0) + session.totalVolume;
        }

        // Rep zones
        for (final set in session.sets) {
          totalSets++;
          if (set.reps <= 5) {
            strengthSets++;
          } else if (set.reps <= 12) {
            hypertrophySets++;
          } else {
            enduranceSets++;
          }
        }
      }

      // Muscle groups (muscleGroup is a single String)
      final muscle = history.muscleGroup;
      if (muscle.isNotEmpty) {
        muscleFrequency[muscle] = (muscleFrequency[muscle] ?? 0) + 1;
      }
    }

    // Sort muscles by frequency
    final sortedMuscles = muscleFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate volume change
    final thisWeek = weeklyVolumes[0] ?? 0;
    final lastWeek = weeklyVolumes[1] ?? 1;
    final volumeChange = lastWeek > 0
        ? ((thisWeek - lastWeek) / lastWeek * 100).round()
        : 0;

    // Calculate muscle balance metrics (NEW)
    final balanceCalculator = MuscleBalanceCalculator();
    final balanceMetrics = balanceCalculator.calculateBalance(widget.exerciseHistories);

    return _ProStats(
      strengthPercent: totalSets > 0 ? (strengthSets / totalSets * 100).round() : 0,
      hypertrophyPercent: totalSets > 0 ? (hypertrophySets / totalSets * 100).round() : 0,
      endurancePercent: totalSets > 0 ? (enduranceSets / totalSets * 100).round() : 0,
      weeklyVolumes: List.generate(4, (i) => weeklyVolumes[3 - i] ?? 0),
      volumeChange: volumeChange,
      topMuscles: sortedMuscles.take(5).map((e) => e.key).toList(),
      balanceMetrics: balanceMetrics,
    );
  }
}

/// Expandable analytics card for premium users
class _ProAnalyticsCard extends StatelessWidget {
  const _ProAnalyticsCard({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible, tappable)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: AppIconSize.medium,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      AppIcons.expandMore,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// Preview card for free users (shown blurred)
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.medium, color: colorScheme.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
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

// ============================================================================
// CHART WIDGETS (for premium users)
// ============================================================================

class _RepZoneChart extends StatelessWidget {
  const _RepZoneChart({required this.stats});

  final _ProStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Column(
      children: [
        // Bar chart
        Row(
          children: [
            _ZoneBar(
              label: l10n.strength,
              value: stats.strengthPercent,
              color: colorScheme.error,
            ),
            const SizedBox(width: 8),
            _ZoneBar(
              label: l10n.hypertrophy,
              value: stats.hypertrophyPercent,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            _ZoneBar(
              label: l10n.endurance,
              value: stats.endurancePercent,
              color: colorScheme.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ZoneLegend(
              label: '${l10n.strength} (1-5)',
              color: colorScheme.error,
              percent: stats.strengthPercent,
            ),
            _ZoneLegend(
              label: '${l10n.hypertrophy} (6-12)',
              color: colorScheme.primary,
              percent: stats.hypertrophyPercent,
            ),
            _ZoneLegend(
              label: '${l10n.endurance} (13+)',
              color: colorScheme.tertiary,
              percent: stats.endurancePercent,
            ),
          ],
        ),
      ],
    );
  }
}

class _ZoneBar extends StatelessWidget {
  const _ZoneBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ZoneLegend extends StatelessWidget {
  const _ZoneLegend({
    required this.label,
    required this.color,
    required this.percent,
  });

  final String label;
  final Color color;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VolumeProgressionChart extends StatelessWidget {
  const _VolumeProgressionChart({required this.stats});

  final _ProStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    final maxVolume = stats.weeklyVolumes.reduce((a, b) => a > b ? a : b);
    final minValue = maxVolume > 0 ? maxVolume : 1;

    return Column(
      children: [
        // Simple line chart representation
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (index) {
              final volume = stats.weeklyVolumes[index];
              final height = maxVolume > 0 ? (volume / minValue * 80).toDouble() : 20.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height.clamp(4.0, 80.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.week} ${index + 1}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                stats.volumeChange >= 0 ? AppIcons.trendUp : AppIcons.trendDown,
                color: stats.volumeChange >= 0
                    ? colorScheme.primary
                    : colorScheme.error,
                size: AppIconSize.small,
              ),
              const SizedBox(width: 8),
              Text(
                '${stats.volumeChange >= 0 ? '+' : ''}${stats.volumeChange}% ${l10n.vsLastWeek}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: stats.volumeChange >= 0
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MuscleBalanceChart extends StatefulWidget {
  const _MuscleBalanceChart({required this.stats, required this.exerciseHistories});

  final _ProStats stats;
  final List<ExerciseHistory> exerciseHistories;

  @override
  State<_MuscleBalanceChart> createState() => _MuscleBalanceChartState();
}

class _MuscleBalanceChartState extends State<_MuscleBalanceChart> {
  TimePeriod _selectedPeriod = TimePeriod.last30Days;
  late BalanceTrendCalculator _trendCalculator;
  late BalanceTrendData _trendData;

  @override
  void initState() {
    super.initState();
    _trendCalculator = BalanceTrendCalculator();
    _updateTrendData();
  }

  @override
  void didUpdateWidget(_MuscleBalanceChart oldWidget) {
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
    });
  }

  void _onPeriodChanged(TimePeriod? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
      });
      _updateTrendData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final balance = _trendData.currentMetrics;

    if (widget.stats.topMuscles.isEmpty) {
      return Center(
        child: Text(
          l10n.noDataYet,
          style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Period Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.timeFilter,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<TimePeriod>(
              value: _selectedPeriod,
              onChanged: _onPeriodChanged,
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

        // Trend Indicator (if previous data exists)
        if (_trendData.previousMetrics != null) ...[
          const SizedBox(height: 8),
          _TrendIndicator(trendData: _trendData),
        ],

        const SizedBox(height: 16),
        // Balance Score Header
        _BalanceScoreHeader(balanceScore: balance.balanceScore, rating: balance.balanceRating),
        const SizedBox(height: 16),

        // Push/Pull Ratio
        _BalanceRatioRow(
          icon: AppIcons.balance,
          label: l10n.pushPullRatio,
          ratio: balance.pushPullRatio,
          hasWarning: balance.pushPullWarning,
          optimalRatio: 1.0,
        ),
        const SizedBox(height: 12),

        // Upper/Lower Ratio
        _BalanceRatioRow(
          icon: AppIcons.accessibility,
          label: l10n.upperLowerRatio,
          ratio: balance.upperLowerRatio,
          hasWarning: balance.upperLowerWarning,
          optimalRatio: 1.0,
        ),

        // Warnings Section (if any)
        if (balance.hasWarnings) ...[
          const SizedBox(height: 16),
          _WarningsSection(balance: balance),
        ],

        // Muscle Heatmap Section
        if (balance.muscleVolumePercentages.isNotEmpty) ...[
          const SizedBox(height: 24),
          MuscleHeatmapWidget(
            heatmapData: MuscleHeatmapData.fromVolumePercentages(
              muscleVolumePercentages: balance.muscleVolumePercentages,
            ),
          ),
        ],

        // Exercise Suggestions Section
        const SizedBox(height: 24),
        Builder(
          builder: (context) {
            // Detect neglected muscles
            final detector = NeglectedMuscleDetector();
            final neglectedMuscles = detector.detectNeglectedMuscles(balance);

            return ExerciseSuggestionsWidget(
              neglectedMuscles: neglectedMuscles,
            );
          },
        ),
      ],
    );
  }
}

/// Balance Score Header - Shows overall balance score (0-10)
class _BalanceScoreHeader extends StatelessWidget {
  const _BalanceScoreHeader({
    required this.balanceScore,
    required this.rating,
  });

  final double balanceScore;
  final String rating;

  /// Convert English rating to localized string
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
        return rating; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Color based on score
    final Color scoreColor;
    if (balanceScore >= 7.5) {
      scoreColor = colorScheme.primary; // Green - Excellent/Good
    } else if (balanceScore >= 6.0) {
      scoreColor = context.warningColor; // Orange - Fair
    } else {
      scoreColor = colorScheme.error; // Red - Poor
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.15),
            scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                balanceScore.toStringAsFixed(1),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.balanceScore,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedRating(context, rating),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
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

/// Balance Ratio Row - Shows individual ratio with warning
class _BalanceRatioRow extends StatelessWidget {
  const _BalanceRatioRow({
    required this.icon,
    required this.label,
    required this.ratio,
    required this.hasWarning,
    required this.optimalRatio,
  });

  final IconData icon;
  final String label;
  final double ratio;
  final bool hasWarning;
  final double optimalRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final ratioColor = hasWarning ? colorScheme.error : colorScheme.primary;

    return Row(
      children: [
        Icon(icon, size: AppIconSize.medium, color: ratioColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${ratio.toStringAsFixed(2)}:1',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ratioColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${l10n.optimalRatio('${optimalRatio.toStringAsFixed(1)}:1')})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (hasWarning)
          Icon(
            AppIcons.warning,
            size: AppIconSize.small,
            color: colorScheme.error,
          ),
      ],
    );
  }
}

/// Warnings Section - Shows detected imbalances
class _WarningsSection extends StatelessWidget {
  const _WarningsSection({required this.balance});

  final MuscleBalanceMetrics balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final warnings = <String>[];

    if (balance.pushPullWarning) {
      warnings.add('⚠️ ${l10n.pushPullImbalance}');
    }

    if (balance.upperLowerWarning) {
      warnings.add('⚠️ ${l10n.upperLowerImbalance}');
    }

    if (balance.neglectedMuscles.isNotEmpty) {
      warnings.add(
        '⚠️ ${l10n.neglectedMusclesWarning(balance.neglectedMuscles.length)}: ${balance.neglectedMuscles.join(', ')}',
      );
    }

    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
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
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  warning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ============================================================================
// DATA CLASS
// ============================================================================

class _ProStats {
  const _ProStats({
    required this.strengthPercent,
    required this.hypertrophyPercent,
    required this.endurancePercent,
    required this.weeklyVolumes,
    required this.volumeChange,
    required this.topMuscles,
    required this.balanceMetrics,
  });

  factory _ProStats.empty() => _ProStats(
        strengthPercent: 33,
        hypertrophyPercent: 34,
        endurancePercent: 33,
        weeklyVolumes: const [0, 0, 0, 0],
        volumeChange: 0,
        topMuscles: const [],
        balanceMetrics: MuscleBalanceMetrics.empty(),
      );

  final int strengthPercent;
  final int hypertrophyPercent;
  final int endurancePercent;
  final List<double> weeklyVolumes;
  final int volumeChange;
  final List<String> topMuscles;
  final MuscleBalanceMetrics balanceMetrics;
}

/// Trend Indicator - Shows balance trend (improving/stable/declining)
class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trendData});

  final BalanceTrendData trendData;

  @override
  Widget build(BuildContext context) {
    // Determine trend icon and color
    final IconData trendIcon;
    final Color trendColor;
    final String trendText;

    switch (trendData.trendDirection) {
      case TrendDirection.improving:
        trendIcon = AppIcons.trendingUp;
        trendColor = context.colors.success;
        trendText = context.l10n.trendImproving;
        break;
      case TrendDirection.declining:
        trendIcon = AppIcons.trendingDown;
        trendColor = context.colors.error;
        trendText = context.l10n.trendDeclining;
        break;
      case TrendDirection.stable:
        trendIcon = AppIcons.trendingFlat;
        trendColor = context.colors.onSurfaceVariant;
        trendText = context.l10n.trendStable;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: AppIconSize.small,
            color: trendColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trendText,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${trendData.percentageChange >= 0 ? '+' : ''}${trendData.percentageChange.toStringAsFixed(1)}% ${context.l10n.comparedToPrevious}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
