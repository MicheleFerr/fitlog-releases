/// InlineAnalyticsTab - Embedded Pro Analytics for Statistics page
///
/// Wraps the 5 Pro Analytics tabs (RepZone, Volume, MuscleBalance,
/// StressIndex, Plateau) as an inline widget, replacing the need
/// to navigate to a separate ProAnalyticsTabbedScreen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/muscle_balance_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/plateau_detection_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/rep_zone_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/stress_index_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/volume_progression_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/analytics_navigation_tab_bar.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';

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
    final tabLabels = buildAnalyticsNavigationLabels(context);

    // Get exercise muscle map for weighted distribution
    final exerciseMuscleMapAsync = ref.watch(exerciseMuscleMapProvider);
    final exerciseMuscleMap = exerciseMuscleMapAsync.value;

    return Column(
      children: [
        // Sub-tab bar for the 5 analytics sections
        AnalyticsNavigationTabBar(
          controller: _tabController,
          labels: tabLabels,
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
