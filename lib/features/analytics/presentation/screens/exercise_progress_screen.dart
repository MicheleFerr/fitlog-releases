import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_progress_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class ExerciseProgressScreen extends ConsumerStatefulWidget {
  const ExerciseProgressScreen({super.key});

  @override
  ConsumerState<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends ConsumerState<ExerciseProgressScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMetrics = ref.watch(exerciseProgressMetricsProvider);

    // Filter exercises by search query
    final filteredExercises = allMetrics.entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList()
      ..sort((a, b) => b.value.lastWorkoutDate.compareTo(a.value.lastWorkoutDate));

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.exerciseProgress,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.l10n.selectExercise,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: context.l10n.searchExercisesPlaceholder,
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.colors.surfaceContainer,
              ),
            ),
          ),

          // Exercise list
          Expanded(
            child: _buildExerciseList(filteredExercises),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<MapEntry<String, ExerciseProgressMetrics>> exercises) {
    if (exercises.isEmpty) {
      return EnhancedEmptyState(
        type: EmptyStateType.info,
        icon: AppIcons.workout,
        title: _searchQuery.isEmpty
            ? context.l10n.noExercisesFound
            : context.l10n.noExercisesFound,
        description: _searchQuery.isEmpty
            ? context.l10n.noExercisesFoundDesc
            : 'No exercises match "$_searchQuery"',
        primaryActionLabel: context.l10n.startWorkout,
        primaryActionIcon: AppIcons.add,
        onPrimaryAction: () => context.push('/workout'),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('exercise_progress_list'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final entry = exercises[index];
        final exerciseName = entry.key;
        final metrics = entry.value;

        return _buildExerciseCard(exerciseName, metrics);
      },
    );
  }

  Widget _buildExerciseCard(String exerciseName, ExerciseProgressMetrics metrics) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/exercise-progress/detail', extra: exerciseName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name and trend indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.workout,
                      color: context.colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseName,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              AppIcons.calendar,
                              size: 14,
                              color: context.colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${metrics.totalSessions} ${context.l10n.totalSessions}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              AppIcons.clock,
                              size: 14,
                              color: context.colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getRelativeTime(metrics.lastWorkoutDate),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildTrendIndicator(metrics.weightTrend),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context.l10n.maxWeight,
                    '${metrics.maxWeight.toStringAsFixed(1)} kg',
                    context.colors.primary,
                  ),
                  _buildStatItem(
                    context.l10n.avgReps,
                    metrics.averageReps.toStringAsFixed(0),
                    context.colors.success,
                  ),
                  _buildStatItem(
                    context.l10n.averageRPE,
                    metrics.averageRPE > 0
                        ? metrics.averageRPE.toStringAsFixed(1)
                        : 'N/A',
                    context.colors.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(TrendDirection trend) {
    IconData icon;
    Color color;
    String label;

    switch (trend) {
      case TrendDirection.improving:
        icon = Icons.trending_up;
        color = context.colors.success;
        label = context.l10n.improving;
        break;
      case TrendDirection.declining:
        icon = Icons.trending_down;
        color = context.colors.error;
        label = context.l10n.declining;
        break;
      case TrendDirection.stable:
        icon = Icons.remove;
        color = context.colors.surfaceContainerHighest;
        label = context.l10n.stable;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else {
      final months = (difference.inDays / 30).round();
      return '$months ${months == 1 ? "month" : "months"} ago';
    }
  }
}
