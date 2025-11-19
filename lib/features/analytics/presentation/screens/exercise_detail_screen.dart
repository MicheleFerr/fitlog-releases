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
/// **Layout**: Collapsible Header with Sticky Tabs (UX Enhanced)
/// ```
/// ┌─────────────────────────────────┐
/// │  ↓ EXPANDED STATE (340px) ↓    │
/// │  Hero Title + Back + Refresh    │ ← SliverAppBar
/// │  ─────────────────────────────  │
/// │  PR Badge Header (80px)         │ ← Always visible
/// │  ─────────────────────────────  │
/// │  📊 Volume Chart (200px)        │ ← Fades out on scroll
/// │     Parallax animation          │    (opacity + offset)
/// ├─────────────────────────────────┤
/// │  ↓ COLLAPSED STATE (80px) ↓    │
/// │  Hero Title + Back + Refresh    │ ← Pinned
/// │  (Chart hidden, PR badges fade) │
/// ├═════════════════════════════════┤
/// │  [History] [Records] Tabs       │ ← Sticky tabs (48px)
/// ├─────────────────────────────────┤
/// │  Tab Content (scrollable)       │
/// │  - History: Session cards       │
/// │  - Records: PR breakdown        │
/// └─────────────────────────────────┘
/// ```
///
/// **Features**:
/// - Real-time data sync from Firestore
/// - 3-layer caching (2ms cached, 300ms first load)
/// - Pull-to-refresh
/// - **Collapsible header** (340px → 80px smooth transition)
/// - **Parallax animation** (chart fades + 20px offset)
/// - **Sticky tabs** below header
/// - Empty state handling
/// - Localized (EN/IT)
///
/// **UX Enhancement (Jan 2025)**:
/// - CustomScrollView with SliverAppBar for native iOS feel
/// - LayoutBuilder for smooth collapse ratio calculation
/// - Transform.translate + Opacity for parallax effect
/// - SliverPersistentHeader for pinned tabs
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
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_records_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/animated_exercise_title.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/screens/landscape_graph_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';

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

  /// Scroll controller for auto-collapse/expand behavior
  ///
  /// **Feature 3**: Snap behavior with asymmetric thresholds
  /// - Scroll down > 100px → auto-collapse
  /// - Scroll up > 120px (from collapsed) → auto-expand
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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
                scrollController: _scrollController,
                onRefresh: () {
                  // Invalidate both providers to force refresh
                  ref.invalidate(exerciseRecordsProvider(widget.exerciseName));
                  if (userId != null) {
                    ref.invalidate(exerciseHistoryStreamProvider(userId));
                  }
                  // Clear in-memory cache
                  clearRecordsCache(widget.exerciseName);
                },
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
///
/// **New Layout**: CustomScrollView with collapsible SliverAppBar
/// - Expanded (340px): Shows title + PR badges + volume chart
/// - Collapsed (80px): Shows only title + action buttons
/// - Tabs pinned below header
///
/// **Feature 3**: Auto-collapse/expand with snap behavior
/// - Asymmetric thresholds: 100px down (collapse), 120px up (expand)
/// - Smooth animation to snap positions
class _ExerciseDetailContent extends StatefulWidget {
  const _ExerciseDetailContent({
    required this.exerciseName,
    required this.records,
    required this.history,
    required this.tabController,
    required this.scrollController,
    required this.onRefresh,
  });

  final String exerciseName;
  final dynamic records; // ExerciseRecords
  final dynamic history; // ExerciseHistory
  final TabController tabController;
  final ScrollController scrollController;
  final VoidCallback onRefresh;

  @override
  State<_ExerciseDetailContent> createState() =>
      _ExerciseDetailContentState();
}

class _ExerciseDetailContentState extends State<_ExerciseDetailContent>
    with SafeSetStateMixin {
  /// Thresholds for snap behavior
  static const double _collapseThreshold = 100.0; // Scroll down > 100px → collapse
  static const double _expandThreshold = 120.0; // Scroll up > 120px → expand

  /// Expanded and collapsed heights for SliverAppBar
  static const double _expandedHeight = 340.0;
  static const double _collapsedHeight = 80.0;

  /// Track if we're currently animating to prevent double-snaps
  bool _isAnimating = false;

  /// Track previous scroll offset to detect direction
  double _previousOffset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  /// Scroll listener with asymmetric snap behavior
  void _onScroll() {
    if (_isAnimating) return;

    final offset = widget.scrollController.offset;
    final isScrollingDown = offset > _previousOffset;
    _previousOffset = offset;

    // Calculate how much of the header is visible
    // offset 0 = fully expanded, offset 260 = fully collapsed (340-80)
    final maxScroll = _expandedHeight - _collapsedHeight;

    if (isScrollingDown && offset > _collapseThreshold && offset < maxScroll) {
      // Scrolling down past threshold → snap to collapsed
      _snapTo(maxScroll);
    } else if (!isScrollingDown &&
        offset < (maxScroll - _expandThreshold) &&
        offset > 0) {
      // Scrolling up from collapsed, past threshold → snap to expanded
      _snapTo(0.0);
    }
  }

  /// Animate to target position
  Future<void> _snapTo(double target) async {
    if (_isAnimating) return;

    safeSetState(() {
      _isAnimating = true;
    });

    await widget.scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    safeSetState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        // ========================================================================
        // COLLAPSIBLE HEADER: Title + PR Badges + Chart
        // ========================================================================
        SliverAppBar(
          expandedHeight: 340,
          collapsedHeight: 80,
          floating: false,
          pinned: true,
          title: AnimatedExerciseTitle(exerciseName: widget.exerciseName),
          leading: IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.back,
              semanticLabel: context.l10n.back,
            ),
            onPressed: () => context.pop(),
            tooltip: context.l10n.back,
          ),
          actions: [
            // Fullscreen landscape graph button
            IconButton(
              icon: SemanticIcon.button(
                icon: AppIcons.zoomOutMap,
                semanticLabel: context.l10n.fullscreen,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LandscapeGraphScreen(
                      exerciseName: widget.exerciseName,
                      history: widget.history,
                    ),
                  ),
                );
              },
              tooltip: context.l10n.fullscreen,
            ),
            IconButton(
              icon: SemanticIcon.button(
                icon: AppIcons.refresh,
                semanticLabel: context.l10n.refresh,
              ),
              onPressed: widget.onRefresh,
              tooltip: context.l10n.refresh,
            ),
          ],
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Calculate collapse progress (0.0 = expanded, 1.0 = collapsed)
              final expandedHeight = 340.0;
              final collapsedHeight = 80.0;
              final currentHeight = constraints.maxHeight;
              final collapseRatio = ((expandedHeight - currentHeight) /
                  (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

              // Fade out chart as header collapses
              final chartOpacity = (1.0 - collapseRatio).clamp(0.0, 1.0);

              // Parallax offset for chart (moves slower than header)
              final parallaxOffset = collapseRatio * 20;

              return FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,

                // Background content (PR badges + chart) - visible when expanded
                background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.08),
                    context.colors.secondary.withValues(alpha: 0.05),
                    context.colors.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60), // Space for title + toolbar

                    // PR Badge Header - Personal records display (always visible)
                    PrBadgeHeader(records: widget.records),

                    // Volume Progression Chart - Fades out with parallax on collapse
                    // Chart has intrinsic height of 200px
                    Transform.translate(
                      offset: Offset(0, parallaxOffset),
                      child: Opacity(
                        opacity: chartOpacity,
                        child: ExerciseVolumeChart(history: widget.history),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
            },
          ),
        ),

        // ========================================================================
        // STICKY TABS AREA
        // ========================================================================
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabsDelegate(
            child: Container(
              color: context.colors.surface,
              child: TabBar(
                controller: widget.tabController,
                tabs: [
                  Tab(text: context.l10n.history),
                  Tab(text: context.l10n.records),
                ],
              ),
            ),
          ),
        ),

        // ========================================================================
        // SCROLLABLE TAB CONTENT
        // ========================================================================
        SliverFillRemaining(
          child: TabBarView(
            controller: widget.tabController,
            children: [
              // History Tab - Workout session history
              ExerciseHistoryTab(history: widget.history),

              // Records Tab - Personal records breakdown
              ExerciseRecordsTab(records: widget.records),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SLIVER DELEGATES
// ============================================================================

/// Sticky Tabs Delegate for SliverPersistentHeader
///
/// **Purpose**: Keep tabs pinned below the collapsible header
/// **Height**: Fixed 48px (standard Material tab height)
class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabsDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyTabsDelegate oldDelegate) {
    return child != oldDelegate.child;
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
