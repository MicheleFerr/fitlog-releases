/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/screens
/// 🎯 Feature: analytics
/// 🔧 Type: screen
///
/// ExerciseDetailScreen - Detailed analytics for a single exercise
///
/// **Purpose**: Show comprehensive exercise history, charts, and personal records
///
/// **Layout**: Hybrid (Chart + Tabs)
/// ```
/// ┌─────────────────────────────────┐
/// │  AppBar (Back + Exercise Name)  │
/// ├─────────────────────────────────┤
/// │  PR Badge Header                │ ← Personal record highlights
/// ├─────────────────────────────────┤
/// │  Volume Progression Chart       │ ← Always visible
/// ├─────────────────────────────────┤
/// │  [History] [Records] Tabs       │
/// ├─────────────────────────────────┤
/// │                                 │
/// │  Tab Content (scrollable)       │
/// │  - History: Session cards       │
/// │  - Records: PR breakdown        │
/// │                                 │
/// └─────────────────────────────────┘
/// ```
///
/// **Features**:
/// - Real-time data sync from Firestore
/// - 3-layer caching (2ms cached, 300ms first load)
/// - Pull-to-refresh
/// - Empty state handling
/// - Localized (EN/IT)
///
/// **Navigation**:
/// - From: Analytics screen exercise card tap
/// - Route: `/analytics/exercise/:exerciseName`
/// - Back: Pop to analytics
///
/// **Usage**:
/// ```dart
/// // Via GoRouter
/// context.push('/analytics/exercise/Bench Press');
///
/// // Direct navigation
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ExerciseDetailScreen(exerciseName: 'Bench Press'),
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_records_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_badge_header.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_volume_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_history_tab.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Exercise Detail Screen
///
/// **Route Parameter**: `exerciseName` (String)
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({
    required this.exerciseName,
    super.key,
  });

  final String exerciseName;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  /// Tab controller for History/Records tabs
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch exercise records
    final recordsAsync = ref.watch(
      exerciseRecordsProvider(widget.exerciseName),
    );

    // Watch exercise history (for chart + tabs)
    final userId = ref.watch(currentUserIdProvider);
    final historyAsync = userId != null
        ? ref.watch(exerciseHistoryStreamProvider(userId))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: context.colors.surfaceContainerHighest,
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.back,
            semanticLabel: context.l10n.back,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/analytics');
            }
          },
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.refresh,
              semanticLabel: context.l10n.refresh,
            ),
            onPressed: () {
              // Invalidate both providers to force refresh
              ref.invalidate(exerciseRecordsProvider(widget.exerciseName));
              if (userId != null) {
                ref.invalidate(exerciseHistoryStreamProvider(userId));
              }
              // Clear in-memory cache
              clearRecordsCache(widget.exerciseName);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: SemanticIcon(
                icon: AppIcons.calendar,
                semanticLabel: context.l10n.history,
                size: AppIconSize.medium,
              ),
              text: context.l10n.history,
            ),
            Tab(
              icon: SemanticIcon(
                icon: AppIcons.achievement,
                semanticLabel: 'Records', // TODO(Phase 4.1): Replace with context.l10n.records
                size: AppIconSize.medium,
              ),
              text: 'Records', // TODO(Phase 4.1): Replace with context.l10n.records
            ),
          ],
        ),
      ),
      body: recordsAsync.when(
        data: (records) {
          // Get history for chart + tabs
          if (historyAsync == null) {
            return const _NotAuthenticatedView();
          }

          return historyAsync.when(
            data: (allHistories) {
              // Find this exercise's history
              final history = allHistories.firstWhere(
                (h) => h.exerciseName == widget.exerciseName,
                orElse: () => throw Exception('Exercise not found'),
              );

              return _ExerciseDetailContent(
                exerciseName: widget.exerciseName,
                records: records,
                history: history,
                tabController: _tabController,
              );
            },
            loading: () => const _LoadingView(),
            error: (error, _) => _ErrorView(error: error.toString()),
          );
        },
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(error: error.toString()),
      ),
    );
  }
}

/// Main content widget (when data loaded successfully)
class _ExerciseDetailContent extends StatelessWidget {
  const _ExerciseDetailContent({
    required this.exerciseName,
    required this.records,
    required this.history,
    required this.tabController,
  });

  final String exerciseName;
  final dynamic records; // ExerciseRecords
  final dynamic history; // ExerciseHistory
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ========================================================================
        // PERSISTENT HEADER: PR Badge + Chart (always visible, scrolls with tabs)
        // ========================================================================
        Container(
          color: context.colors.surface,
          child: Column(
            children: [
              // PR Badge Header - Personal records display
              PrBadgeHeader(records: records),

              // Volume Progression Chart - Per-session volume over time
              ExerciseVolumeChart(history: history),
            ],
          ),
        ),

        // ========================================================================
        // TABS CONTENT (scrollable)
        // ========================================================================
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              // History Tab - Workout session history
              ExerciseHistoryTab(history: history),

              // Records Tab (placeholder for Phase 2.5)
              Container(
                color: context.colors.success.withValues(alpha: 0.1),
                child: Center(
                  child: Text(
                    'Records Tab (Phase 2.5)',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STATE VIEWS (Loading, Error, Empty, Not Authenticated)
// ============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(context.l10n.loadingYourAnalytics),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: context.l10n.errorLoadingAnalytics,
            size: AppIconSize.xxlarge,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotAuthenticatedView extends StatelessWidget {
  const _NotAuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.lock,
            semanticLabel: context.l10n.pleaseLoginToViewAnalytics,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.pleaseLoginToViewAnalytics,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
