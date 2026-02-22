/// InlineAnalyticsTab - Embedded Pro Analytics for Statistics page
///
/// Wraps the 5 Pro Analytics tabs (RepZone, Volume, MuscleBalance,
/// StressIndex, Plateau) as an inline widget, replacing the need
/// to navigate to a separate ProAnalyticsTabbedScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/muscle_balance_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/plateau_detection_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/rep_zone_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/stress_index_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/volume_progression_tab.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Inline analytics tab that embeds the 5 Pro Analytics sub-tabs
/// directly within the Statistics page TabBarView.
///
/// No Scaffold or AppBar -- this is a widget, not a full screen.
class InlineAnalyticsTab extends ConsumerStatefulWidget {
  const InlineAnalyticsTab({
    required this.exerciseHistories,
    required this.userId,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final String userId;

  @override
  ConsumerState<InlineAnalyticsTab> createState() => _InlineAnalyticsTabState();
}

class _InlineAnalyticsTabState extends ConsumerState<InlineAnalyticsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    // Get exercise muscle map for weighted distribution
    final exerciseMuscleMapAsync = ref.watch(exerciseMuscleMapProvider);
    final exerciseMuscleMap = exerciseMuscleMapAsync.value;

    return Column(
      children: [
        // Sub-tab bar for the 5 analytics sections
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (_) => HapticFeedback.selectionClick(),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  colorScheme.tertiary.withValues(alpha: 0.2),
                  colorScheme.tertiary.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
            labelColor: colorScheme.tertiary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            labelStyle: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: context.textTheme.labelMedium,
            dividerColor: colorScheme.surface.withValues(alpha: 0),
            tabs: [
              Tab(text: context.l10n.repZones),
              Tab(text: context.l10n.volume),
              Tab(text: context.l10n.muscleBalance),
              Tab(text: context.l10n.stressIndex),
              Tab(text: context.l10n.analyticsTrendPlateau),
            ],
          ),
        ),

        // Sub-tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Rep Zone Distribution
              RepZoneTab(exerciseHistories: widget.exerciseHistories),

              // Tab 2: Volume Progression
              VolumeProgressionTab(
                exerciseHistories: widget.exerciseHistories,
                exerciseMuscleMap: exerciseMuscleMap,
              ),

              // Tab 3: Muscle Balance
              MuscleBalanceTab(
                exerciseHistories: widget.exerciseHistories,
                exerciseMuscleMap: exerciseMuscleMap,
              ),

              // Tab 4: Stress Index
              const StressIndexTab(),

              // Tab 5: Plateau Detection
              const PlateauDetectionTab(),
            ],
          ),
        ),
      ],
    );
  }
}
