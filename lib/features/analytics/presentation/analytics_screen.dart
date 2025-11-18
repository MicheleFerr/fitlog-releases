import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/migration_dialog.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/current_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 ${context.l10n.analytics}'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.back,
            semanticLabel: context.l10n.back,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          // Migration button (temporary - for testing)
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.sync,
              semanticLabel: context.l10n.migrateWorkoutHistory,
            ),
            onPressed: () => showMigrationDialog(context, ref),
            tooltip: context.l10n.migrateWorkoutHistory,
          ),
          IconButton(
            icon: SemanticIcon.button(
              icon: AppIcons.refresh,
              semanticLabel: context.l10n.refresh,
            ),
            onPressed: () {
              if (userId != null) {
                ref.invalidate(exerciseHistoryStreamProvider(userId));
              }
            },
          ),
        ],
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
      ),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }
}

class _AnalyticsContent extends StatefulWidget {
  const _AnalyticsContent({
    required this.exerciseHistories,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  State<_AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<_AnalyticsContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseHistory> get _filteredHistories {
    if (_searchQuery.isEmpty) {
      return widget.exerciseHistories;
    }

    final query = _searchQuery.toLowerCase();
    return widget.exerciseHistories.where((history) {
      final exerciseName = history.exerciseName.toLowerCase();
      final muscleGroup = history.muscleGroup.toLowerCase();
      return exerciseName.contains(query) || muscleGroup.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exerciseHistories.isEmpty) {
      return const _EmptyStateView();
    }

    final filteredHistories = _filteredHistories;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.searchExercises,
              prefixIcon: SemanticIcon(
                icon: AppIcons.search,
                semanticLabel: context.l10n.search,
                size: AppIconSize.medium,
                color: context.colors.onSurfaceVariant,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: SemanticIcon.button(
                        icon: AppIcons.close,
                        semanticLabel: context.l10n.clear,
                      ),
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
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Results list
        Expanded(
          child: filteredHistories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
                        icon: AppIcons.search,
                        semanticLabel: context.l10n.noResultsFound,
                        size: AppIconSize.xxlarge,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.noResultsFound,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.tryAnotherSearch,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // Invalidation is handled by the refresh button in AppBar
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHistories.length,
                    itemBuilder: (context, index) {
                      final history = filteredHistories[index];
                      return _ExerciseHistoryCard(history: history);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

/// Exercise history card - shows exercise name, PR, sessions count
class _ExerciseHistoryCard extends StatelessWidget {
  const _ExerciseHistoryCard({required this.history});

  final ExerciseHistory history;

  @override
  Widget build(BuildContext context) {
    final pr = history.personalRecord;
    final sessionsCount = history.sessions.length;
    final weeklyProgression = history.weeklyVolumeProgression;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to exercise detail screen
          context.push('/analytics/exercise/${history.exerciseName}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name + muscle group
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.exerciseName,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          history.muscleGroup.toUpperCase(),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SemanticIcon(
                    icon: AppIcons.chevronRight,
                    semanticLabel: context.l10n.viewDetails,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  // PR
                  Expanded(
                    child: _StatChip(
                      icon: AppIcons.achievement,
                      label: 'PR', // Short for Personal Record
                      value: '${pr.toStringAsFixed(1)} kg',
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sessions count
                  Expanded(
                    child: _StatChip(
                      icon: AppIcons.calendar,
                      label: context.l10n.workouts, // Using existing key
                      value: '$sessionsCount',
                      color: context.colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Weekly progression
                  Expanded(
                    child: _StatChip(
                      icon: weeklyProgression >= 0
                          ? AppIcons.trendingUp
                          : AppIcons.trendingDown,
                      label: context.l10n.progress, // Using existing key
                      value: '${weeklyProgression.toStringAsFixed(1)}%',
                      color: weeklyProgression >= 0
                          ? context.colors.success
                          : context.colors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat chip widget - small colored box with icon and value
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: '$label: $value',
            size: AppIconSize.small,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Empty/Error/Loading States
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

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.workout,
            semanticLabel: context.l10n.noWorkoutDataYet,
            size: AppIconSize.xxlarge,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.noWorkoutDataYet,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.completeWorkoutsToSeeAnalytics,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/workout'),
            icon: SemanticIcon.button(
              icon: AppIcons.play,
              semanticLabel: context.l10n.startYourFirstWorkout,
            ),
            label: Text(context.l10n.startYourFirstWorkout),
          ),
        ],
      ),
    );
  }
}
