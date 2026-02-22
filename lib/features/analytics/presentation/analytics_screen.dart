import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/dashboard_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/exercises_tab.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/tabs/inline_analytics_tab.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statistics),
        backgroundColor: Colors.transparent,
      ),
      body: authState != AuthState.authenticated
          ? const _NotAuthenticatedView()
          : userId == null
              ? const _NotAuthenticatedView()
              : _AuthenticatedAnalyticsView(userId: userId),
    );
  }
}

class _AuthenticatedAnalyticsView extends ConsumerWidget {
  const _AuthenticatedAnalyticsView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(exerciseHistoryStreamProvider(userId));

    return historyAsync.when(
      data: (exerciseHistories) => _AnalyticsContent(
        exerciseHistories: exerciseHistories,
        userId: userId,
      ),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }
}

class _AnalyticsContent extends ConsumerStatefulWidget {
  const _AnalyticsContent({
    required this.exerciseHistories,
    required this.userId,
  });

  final List<ExerciseHistory> exerciseHistories;
  final String userId;

  @override
  ConsumerState<_AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends ConsumerState<_AnalyticsContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exerciseHistories.isEmpty) {
      return EnhancedEmptyState(
        type: EmptyStateType.motivational,
        icon: AppIcons.barChart,
        title: context.l10n.noWorkoutDataYet,
        description: context.l10n.completeWorkoutsToSeeAnalytics,
        motivationalQuote: context.l10n.analyticsEmptyQuote,
        proTip: context.l10n.analyticsEmptyTip,
        primaryActionLabel: context.l10n.startYourFirstWorkout,
        onPrimaryAction: () => context.go(AppRoutes.workoutPath),
      );
    }

    return Column(
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.onSurfaceVariant,
          tabs: [
            Tab(text: context.l10n.statisticsDashboard),
            Tab(text: context.l10n.statisticsAnalytics),
            Tab(text: context.l10n.statisticsExercises),
          ],
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DashboardTab(
                exerciseHistories: widget.exerciseHistories,
                userId: widget.userId,
              ),
              InlineAnalyticsTab(
                exerciseHistories: widget.exerciseHistories,
                userId: widget.userId,
              ),
              ExercisesTab(
                exerciseHistories: widget.exerciseHistories,
                userId: widget.userId,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -- Utility views ----------------------------------------------------------

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
          const SizedBox(height: AppSpacing.md),
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonLoadingView();
  }
}

/// Skeleton loading view with shimmer effect for better UX
class _SkeletonLoadingView extends StatelessWidget {
  const _SkeletonLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Search bar skeleton
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: _ShimmerBox(
            width: double.infinity,
            height: 56,
            borderRadius: 12,
          ),
        ),

        // Exercise cards skeletons
        Expanded(child: _SkeletonList()),
      ],
    );
  }
}

/// Skeleton list with multiple cards
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => const _SkeletonExerciseCard(),
    );
  }
}

/// Skeleton exercise card
class _SkeletonExerciseCard extends StatelessWidget {
  const _SkeletonExerciseCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 200, height: 20, borderRadius: 4),
            SizedBox(height: AppSpacing.xs),
            _ShimmerBox(width: 100, height: 14, borderRadius: 4),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer box widget for skeleton loading
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                context.colors.surfaceContainerHighest,
                context.colors.surfaceContainerHigh,
                context.colors.surfaceContainerHighest,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
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
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.errorLoadingAnalytics,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
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
