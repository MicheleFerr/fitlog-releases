import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/lazy_analytics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/widgets/workout_skeleton_loader.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Lazy loading version of RecentWorkoutsCard with progressive data fetching
class LazyRecentWorkoutsCard extends ConsumerStatefulWidget {
  const LazyRecentWorkoutsCard({super.key});

  @override
  ConsumerState<LazyRecentWorkoutsCard> createState() => _LazyRecentWorkoutsCardState();
}

class _LazyRecentWorkoutsCardState extends ConsumerState<LazyRecentWorkoutsCard> {
  final ScrollController _scrollController = ScrollController();
  static const int _initialDisplayCount = 5;
  int _displayedWorkouts = _initialDisplayCount;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final scrollPercentage = currentScroll / maxScroll;
    
    // Load more when scrolled 80% down
    if (scrollPercentage > 0.8) {
      final notifier = ref.read(lazyAnalyticsProvider.notifier);
      if (notifier.shouldLoadMore(scrollPercentage)) {
        notifier.loadMoreData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(lazyAnalyticsProvider);
    final isLoadingMore = ref.watch(isLoadingMoreAnalyticsProvider);
    final currentPhase = ref.watch(currentLoadingPhaseProvider);
    final canLoadMore = ref.watch(canLoadMoreAnalyticsProvider);
    
    // Group activities by workout
    final Map<String, List<ExerciseActivity>> workouts = {};
    for (final activity in analyticsState.activities) {
      final key = '${activity.schedaName}_${_formatDateKey(activity.createdAt)}';
      workouts.putIfAbsent(key, () => []).add(activity);
    }
    
    final allWorkouts = workouts.entries.toList();
    final displayedWorkoutsList = allWorkouts.take(_displayedWorkouts).toList();

    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.history,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).recentWorkouts,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Phase indicator
                    _buildPhaseIndicator(context, currentPhase),
                  ],
                ),
                if (allWorkouts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${allWorkouts.length} workouts loaded',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          if (analyticsState.activities.isEmpty && analyticsState.isLoadingMore)
            // Initial loading skeleton
            Padding(
              padding: EdgeInsets.all(16),
              child: WorkoutSkeletonLoader(itemCount: 3),
            )
          else if (allWorkouts.isEmpty)
            // Empty state
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      AppIcons.workout,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).noWorkoutsYet,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Workout list with lazy loading
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: displayedWorkoutsList.length + (canLoadMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show load more button/indicator at the end
                  if (index == displayedWorkoutsList.length) {
                    if (isLoadingMore) {
                      return _buildLoadingIndicator(context);
                    } else {
                      return _buildLoadMoreButton(context);
                    }
                  }
                  
                  final entry = displayedWorkoutsList[index];
                  final workoutActivities = entry.value;
                  final firstActivity = workoutActivities.first;
                  
                  return _buildWorkoutItem(
                    context,
                    firstActivity.schedaName,
                    firstActivity.createdAt,
                    workoutActivities.length,
                    _calculateWorkoutVolume(workoutActivities),
                    workoutActivities,
                    index,
                  );
                },
              ),
            ),
          
          // Show more workouts available indicator
          if (!canLoadMore && displayedWorkoutsList.length < allWorkouts.length)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _displayedWorkouts = _displayedWorkouts + 10;
                  });
                },
                child: Text('Show ${allWorkouts.length - displayedWorkoutsList.length} more workouts'),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPhaseIndicator(BuildContext context, LoadingPhase phase) {
    String phaseText;
    Color phaseColor;
    
    switch (phase) {
      case LoadingPhase.initial:
        phaseText = 'Last 30 days';
        phaseColor = context.colors.success;
        break;
      case LoadingPhase.extended:
        phaseText = 'Last 3 months';
        phaseColor = context.colors.primary;
        break;
      case LoadingPhase.full:
        phaseText = 'Last year';
        phaseColor = context.colors.secondary;
        break;
      case LoadingPhase.complete:
        phaseText = 'All time';
        phaseColor = context.colors.tertiary;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: phaseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: phaseColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            phaseText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: phaseColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutItem(
    BuildContext context,
    String workoutName,
    DateTime date,
    int exerciseCount,
    double totalVolume,
    List<ExerciseActivity> activities,
    int index,
  ) {
    // Animate item appearance
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300 + (index * 50)),
      opacity: 1.0,
      child: AnimatedSlide(
        duration: Duration(milliseconds: 300 + (index * 50)),
        offset: const Offset(0, 0),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showWorkoutDetails(context, activities),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    // Date badge
                    Container(
                      width: 56,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            date.day.toString(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            _getMonthAbbr(date.month),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Workout info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                AppIcons.workout,
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$exerciseCount exercises',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                AppIcons.scale,
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatVolume(totalVolume),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow
                    Icon(
                      AppIcons.chevronRight,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              ref.read(lazyAnalyticsProvider.notifier).loadingMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadMoreButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: () {
            ref.read(lazyAnalyticsProvider.notifier).loadMoreData();
          },
          icon: Icon(AppIcons.expandMore),
          label: Text('Load older workouts'),
        ),
      ),
    );
  }
  
  void _showWorkoutDetails(BuildContext context, List<ExerciseActivity> activities) {
    // Reuse the detailed bottom sheet from the original widget
    // (Implementation omitted for brevity - would be the same as original)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _WorkoutDetailsSheet(activities: activities),
    );
  }
  
  double _calculateWorkoutVolume(List<ExerciseActivity> activities) {
    return activities.fold(0.0, (sum, activity) => 
      sum + activity.sets.fold(0.0, (setSum, set) {
        if (!set.done) return setSum;
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      })
    );
  }
  
  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toStringAsFixed(0)}kg';
  }
  
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  String _getMonthAbbr(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                   'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

// Separate widget for workout details sheet to keep code organized
class _WorkoutDetailsSheet extends StatelessWidget {
  
  const _WorkoutDetailsSheet({required this.activities});
  final List<ExerciseActivity> activities;
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activities.first.schedaName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatDate(activities.first.createdAt),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(AppIcons.close),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Exercise list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildExerciseCard(context, activity);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildExerciseCard(BuildContext context, ExerciseActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.exerciseName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...activity.sets.map((set) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      'Set ${set.set}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '${set.weight} kg × ${set.reps} reps',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
