/// Pro Insights Preview Section
///
/// A homepage teaser for Pro Analytics features.
/// Shows simplified previews of:
/// - Muscle Map (body heatmap)
/// - Volume Radar (muscle distribution)
/// - Stress Index (workout intensity)
/// - Rep Zones (training distribution)
///
/// Design: Material Design 3 with premium tertiary accents
/// UX Pattern: Show real data as teaser, CTA to Pro Analytics
library;

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/stress_index_calculator.dart'
    show SleepQualityCategory;
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Pro Insights Preview Section
///
/// Displays simplified analytics previews on the homepage.
/// Tapping navigates to Pro Analytics for detailed views.
class ProInsightsPreviewSection extends ConsumerWidget {
  const ProInsightsPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // Get current user ID for analytics
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const SizedBox.shrink();

    // Watch exercise histories for data
    final exerciseHistoriesAsync =
        ref.watch(exerciseHistoryStreamProvider(userId));

    return exerciseHistoriesAsync.when(
      data: (histories) {
        // Don't show section if no workout data
        if (histories.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              _buildSectionHeader(context, l10n, colorScheme),
              const SizedBox(height: AppSpacing.sm),

              // Main content card
              GestureDetector(
                onTap: () => _navigateToProAnalytics(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.tertiary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Row 1: Muscle Map (large preview)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _MuscleMapPreview(histories: histories),
                      ),

                      // Divider
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),

                      // Row 2: Volume Radar + Stress Index side by side
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _VolumeRadarPreview(histories: histories),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Expanded(
                              child: _StressIndexPreview(),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),

                      // Row 3: Rep Zones Bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _RepZonesBarPreview(histories: histories),
                      ),

                      // CTA Footer
                      _buildCTAFooter(context, l10n, colorScheme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    dynamic l10n,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // PRO badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.tertiary,
                colorScheme.tertiary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: AppIcons.premium,
                semanticLabel: 'Pro',
                size: AppIconSize.tiny,
                color: colorScheme.onTertiary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'PRO',
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          l10n.proInsights,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        SemanticIcon(
          icon: AppIcons.chevronRight,
          semanticLabel: l10n.viewDetails,
          size: AppIconSize.small,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildCTAFooter(
    BuildContext context,
    dynamic l10n,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.analytics,
            semanticLabel: l10n.viewDetails,
            size: AppIconSize.small,
            color: colorScheme.tertiary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.viewDetails,
            style: context.textTheme.labelLarge?.copyWith(
              color: colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          SemanticIcon(
            icon: AppIcons.arrowForward,
            semanticLabel: l10n.viewDetails,
            size: AppIconSize.tiny,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  void _navigateToProAnalytics(BuildContext context) {
    HapticFeedback.lightImpact();
    context.push(AppRoutes.proAnalyticsPath);
  }
}

/// Muscle Map Preview - Uses same MuscleBalanceCalculator as Pro Analytics
class _MuscleMapPreview extends ConsumerWidget {
  const _MuscleMapPreview({required this.histories});

  final List<ExerciseHistory> histories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // 🔧 PERF FIX: Use cached provider instead of calculating in build()
    // This saves 30-50ms per rebuild for 1000+ exercises
    final metrics = ref.watch(cachedMuscleBalanceProvider(histories));

    // Convert muscleVolumePercentages to grouped display format
    final muscleActivity = _groupMuscleVolumes(metrics.muscleVolumePercentages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.accessibility,
              semanticLabel: l10n.muscleBalance,
              size: AppIconSize.small,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              l10n.muscleBalance,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Simplified muscle indicator bars
        SizedBox(
          height: 120,
          child: Row(
            children: [
              // Left side - muscle group bars
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MuscleBar(
                      label: l10n.muscleGroupChest,
                      value: muscleActivity['chest'] ?? 0.0,
                      color: _getHeatColor(muscleActivity['chest'] ?? 0.0),
                    ),
                    _MuscleBar(
                      label: l10n.muscleGroupBack,
                      value: muscleActivity['back'] ?? 0.0,
                      color: _getHeatColor(muscleActivity['back'] ?? 0.0),
                    ),
                    _MuscleBar(
                      label: l10n.muscleGroupShoulders,
                      value: muscleActivity['shoulders'] ?? 0.0,
                      color: _getHeatColor(muscleActivity['shoulders'] ?? 0.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Right side - muscle group bars
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MuscleBar(
                      label: l10n.muscleGroupArms,
                      value: muscleActivity['arms'] ?? 0.0,
                      color: _getHeatColor(muscleActivity['arms'] ?? 0.0),
                    ),
                    _MuscleBar(
                      label: l10n.muscleGroupLegs,
                      value: muscleActivity['legs'] ?? 0.0,
                      color: _getHeatColor(muscleActivity['legs'] ?? 0.0),
                    ),
                    _MuscleBar(
                      label: l10n.muscleCore,
                      value: muscleActivity['core'] ?? 0.0,
                      color: _getHeatColor(muscleActivity['core'] ?? 0.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Group detailed muscle percentages into display categories
  /// Same grouping logic as Pro Analytics muscle balance chart
  Map<String, double> _groupMuscleVolumes(Map<String, double> volumePercentages) {
    final grouped = <String, double>{
      'chest': 0.0,
      'back': 0.0,
      'shoulders': 0.0,
      'arms': 0.0,
      'legs': 0.0,
      'core': 0.0,
    };

    volumePercentages.forEach((muscle, percentage) {
      final muscleLower = muscle.toLowerCase();

      // Chest: pett, chest, pectorals
      if (muscleLower.contains('pett') || muscleLower.contains('chest')) {
        grouped['chest'] = (grouped['chest'] ?? 0) + percentage;
      }
      // Back: lat, trap, dorso, back, rhomboids
      else if (muscleLower.contains('lat') ||
          muscleLower.contains('trap') ||
          muscleLower.contains('dorso') ||
          muscleLower.contains('back') ||
          muscleLower.contains('rhomb')) {
        grouped['back'] = (grouped['back'] ?? 0) + percentage;
      }
      // Shoulders: delt (all types)
      else if (muscleLower.contains('delt') || muscleLower.contains('spall')) {
        grouped['shoulders'] = (grouped['shoulders'] ?? 0) + percentage;
      }
      // Arms: bic, tric, avamb
      else if (muscleLower.contains('bic') ||
          muscleLower.contains('tric') ||
          muscleLower.contains('avamb') ||
          muscleLower.contains('forearm')) {
        grouped['arms'] = (grouped['arms'] ?? 0) + percentage;
      }
      // Legs: quad, femor, glut, polp, addut, abdut
      else if (muscleLower.contains('quad') ||
          muscleLower.contains('femor') ||
          muscleLower.contains('glut') ||
          muscleLower.contains('polp') ||
          muscleLower.contains('addut') ||
          muscleLower.contains('abdut') ||
          muscleLower.contains('leg') ||
          muscleLower.contains('hamstring') ||
          muscleLower.contains('calv')) {
        grouped['legs'] = (grouped['legs'] ?? 0) + percentage;
      }
      // Core: addom, core, abs, lombar
      else if (muscleLower.contains('addom') ||
          muscleLower.contains('core') ||
          muscleLower.contains('abs') ||
          muscleLower.contains('lombar') ||
          muscleLower.contains('lomb')) {
        grouped['core'] = (grouped['core'] ?? 0) + percentage;
      }
    });

    // Normalize to 0-1 range for display
    final maxVolume = grouped.values.fold(0.0, math.max);
    if (maxVolume > 0) {
      for (final key in grouped.keys) {
        grouped[key] = (grouped[key] ?? 0) / maxVolume;
      }
    }

    return grouped;
  }

  Color _getHeatColor(double heat) {
    const blue = Color(0xFF2196F3);
    const amber = Color(0xFFFFC107);
    const red = Color(0xFFF44336);

    if (heat < 0.5) {
      return Color.lerp(blue, amber, heat * 2)!;
    } else {
      return Color.lerp(amber, red, (heat - 0.5) * 2)!;
    }
  }
}

/// Single muscle group bar indicator
class _MuscleBar extends StatelessWidget {
  const _MuscleBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}

/// Volume Radar Preview - Mini radar chart (uses same data as Pro Analytics)
class _VolumeRadarPreview extends ConsumerWidget {
  const _VolumeRadarPreview({required this.histories});

  final List<ExerciseHistory> histories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // 🔧 PERF FIX: Use cached provider instead of calculating in build
    final metrics = ref.watch(cachedMuscleBalanceProvider(histories));

    // Convert to radar chart format
    final volumeData = _metricsToRadarData(metrics.muscleVolumePercentages);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
                icon: AppIcons.hexagonOutlined,
                semanticLabel: l10n.volume,
                size: 14,
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                l10n.volume,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          // Radar chart
          Expanded(
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    dataEntries: volumeData.map((v) => RadarEntry(value: v)).toList(),
                    fillColor: colorScheme.tertiary.withValues(alpha: 0.2),
                    borderColor: colorScheme.tertiary,
                    borderWidth: 2,
                  ),
                ],
                radarBackgroundColor: colorScheme.surface.withValues(alpha: 0),
                tickCount: 3,
                // Hidden labels - transparent color to hide tick/title text
                ticksTextStyle: context.textTheme.bodySmall!.copyWith(
                  color: colorScheme.surface.withValues(alpha: 0),
                ),
                titleTextStyle: context.textTheme.bodySmall!.copyWith(
                  color: colorScheme.surface.withValues(alpha: 0),
                ),
                radarBorderData: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                tickBorderData: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
                gridBorderData: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
                getTitle: (index, _) => const RadarChartTitle(text: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Convert MuscleBalanceCalculator percentages to 6-point radar format
  List<double> _metricsToRadarData(Map<String, double> volumePercentages) {
    // 6-point radar: chest, back, shoulders, arms, legs, core
    final grouped = <String, double>{
      'chest': 0.0,
      'back': 0.0,
      'shoulders': 0.0,
      'arms': 0.0,
      'legs': 0.0,
      'core': 0.0,
    };

    volumePercentages.forEach((muscle, percentage) {
      final muscleLower = muscle.toLowerCase();

      if (muscleLower.contains('pett') || muscleLower.contains('chest')) {
        grouped['chest'] = (grouped['chest'] ?? 0) + percentage;
      } else if (muscleLower.contains('lat') ||
          muscleLower.contains('trap') ||
          muscleLower.contains('dorso') ||
          muscleLower.contains('back') ||
          muscleLower.contains('rhomb')) {
        grouped['back'] = (grouped['back'] ?? 0) + percentage;
      } else if (muscleLower.contains('delt') || muscleLower.contains('spall')) {
        grouped['shoulders'] = (grouped['shoulders'] ?? 0) + percentage;
      } else if (muscleLower.contains('bic') ||
          muscleLower.contains('tric') ||
          muscleLower.contains('avamb') ||
          muscleLower.contains('forearm')) {
        grouped['arms'] = (grouped['arms'] ?? 0) + percentage;
      } else if (muscleLower.contains('quad') ||
          muscleLower.contains('femor') ||
          muscleLower.contains('glut') ||
          muscleLower.contains('polp') ||
          muscleLower.contains('addut') ||
          muscleLower.contains('abdut') ||
          muscleLower.contains('leg') ||
          muscleLower.contains('hamstring') ||
          muscleLower.contains('calv')) {
        grouped['legs'] = (grouped['legs'] ?? 0) + percentage;
      } else if (muscleLower.contains('addom') ||
          muscleLower.contains('core') ||
          muscleLower.contains('abs') ||
          muscleLower.contains('lombar') ||
          muscleLower.contains('lomb')) {
        grouped['core'] = (grouped['core'] ?? 0) + percentage;
      }
    });

    // Return as list: [chest, back, shoulders, arms, legs, core]
    // Already in percentages (0-100 range from MuscleBalanceCalculator)
    return [
      grouped['chest'] ?? 0.0,
      grouped['back'] ?? 0.0,
      grouped['shoulders'] ?? 0.0,
      grouped['arms'] ?? 0.0,
      grouped['legs'] ?? 0.0,
      grouped['core'] ?? 0.0,
    ];
  }
}

/// Stress Index Preview - Circular score indicator with sleep integration
///
/// Displays sleep-aware stress score that considers:
/// - Training fatigue from FFM model
/// - Sleep quality from HealthKit
/// - Consecutive bad nights penalty
class _StressIndexPreview extends ConsumerWidget {
  const _StressIndexPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // Use sleep-aware stress provider for complete recovery picture
    final sleepAwareDataAsync = ref.watch(sleepAwareStressDataProvider);

    return sleepAwareDataAsync.when(
      data: (data) {
        final score = data.stressScore;
        final scoreColor = _getScoreColor(score, context);
        final hasSleepImpact = data.hasSleepImpact && data.hasSleepData;

        return Container(
          height: 120,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Title with optional sleep impact badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SemanticIcon(
                    icon: AppIcons.bolt,
                    semanticLabel: l10n.stressIndex,
                    size: 14,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    l10n.stressIndex,
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  // Sleep impact indicator
                  if (hasSleepImpact) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    SemanticIcon(
                      icon: AppIcons.bedtime,
                      semanticLabel: 'Sleep impact',
                      size: 12,
                      color: data.sleepCategory == SleepQualityCategory.critical
                          ? context.errorColor
                          : context.warningColor,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // Score circle
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        LoadingIndicator(
                          progress: (score / 100).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          size: 60,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: scoreColor,
                        ),
                        Center(
                          child: Text(
                            score.toStringAsFixed(0),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildEmptyState(context, colorScheme, l10n),
      error: (_, __) => _buildEmptyState(context, colorScheme, l10n),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    dynamic l10n,
  ) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.bolt,
            semanticLabel: l10n.stressIndex,
            size: 24,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.stressIndex,
            style: context.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score, BuildContext context) {
    if (score < 30) return context.successColor;
    if (score < 60) return context.infoColor;
    if (score < 80) return context.warningColor;
    return context.errorColor;
  }
}

/// Rep Zones Bar Preview - Horizontal segmented bar
class _RepZonesBarPreview extends StatelessWidget {
  const _RepZonesBarPreview({required this.histories});

  final List<ExerciseHistory> histories;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // Calculate rep zone distribution
    final zoneData = _calculateRepZones();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.barChart,
              semanticLabel: l10n.repZones,
              size: AppIconSize.small,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              l10n.repZones,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                // Strength (1-5 reps) - Red/Orange
                Expanded(
                  flex: (zoneData['strength']! * 100).round().clamp(1, 100),
                  child: Container(
                    color: context.errorColor.withValues(alpha: 0.8),
                  ),
                ),
                // Hypertrophy (6-12 reps) - Green
                Expanded(
                  flex: (zoneData['hypertrophy']! * 100).round().clamp(1, 100),
                  child: Container(
                    color: context.successColor.withValues(alpha: 0.8),
                  ),
                ),
                // Endurance (13+ reps) - Blue
                Expanded(
                  flex: (zoneData['endurance']! * 100).round().clamp(1, 100),
                  child: Container(
                    color: context.infoColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ZoneLegend(
              color: context.errorColor,
              label: l10n.strength,
              percentage: (zoneData['strength']! * 100).toStringAsFixed(0),
            ),
            _ZoneLegend(
              color: context.successColor,
              label: l10n.hypertrophy,
              percentage: (zoneData['hypertrophy']! * 100).toStringAsFixed(0),
            ),
            _ZoneLegend(
              color: context.infoColor,
              label: l10n.endurance,
              percentage: (zoneData['endurance']! * 100).toStringAsFixed(0),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, double> _calculateRepZones() {
    int strengthSets = 0;
    int hypertrophySets = 0;
    int enduranceSets = 0;

    for (final history in histories) {
      // ExerciseHistory has sessions (List<ExerciseSession>)
      // Each ExerciseSession has sets (List<AnalyticsSet>)
      for (final session in history.sessions) {
        for (final set in session.sets) {
          final reps = set.reps;
          if (reps >= 1 && reps <= 5) {
            strengthSets++;
          } else if (reps >= 6 && reps <= 12) {
            hypertrophySets++;
          } else if (reps > 12) {
            enduranceSets++;
          }
        }
      }
    }

    final total = strengthSets + hypertrophySets + enduranceSets;
    if (total == 0) {
      return {'strength': 0.33, 'hypertrophy': 0.34, 'endurance': 0.33};
    }

    return {
      'strength': strengthSets / total,
      'hypertrophy': hypertrophySets / total,
      'endurance': enduranceSets / total,
    };
  }
}

/// Zone legend item
class _ZoneLegend extends StatelessWidget {
  const _ZoneLegend({
    required this.color,
    required this.label,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$label $percentage%',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
