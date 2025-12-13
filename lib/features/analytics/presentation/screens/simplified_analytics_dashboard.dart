/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/screens
/// Feature: analytics
/// Type: screen
///
/// Simplified Analytics Dashboard combining all widgets in a single screen.
///
/// Architecture:
/// - 4 sections: Hero stat, Stats bar + Body heatmap, Top exercises, Recent activity
/// - Uses MuscleHeatData.fromVolumePercentages for body heatmap
/// - Feature flag ready for routing
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/anatomical_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/hero_stat_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/stats_bar_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Simplified Analytics Dashboard - 4 sections:
/// 1. Hero stat (workout count)
/// 2. Stats bar + Body heatmap
/// 3. Top exercises
/// 4. Recent activity
class SimplifiedAnalyticsDashboard extends ConsumerWidget {
  const SimplifiedAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SemanticIcon(
            icon: AppIcons.back,
            semanticLabel: l10n.back,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.homePath);
            }
          },
        ),
        title: Text(
          l10n.analytics,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.barChart,
              semanticLabel: 'Pro Analytics',
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pushNamed(AppRoutes.proAnalyticsName);
            },
          ),
        ],
      ),
      body: authState != AuthState.authenticated
          ? _buildNotAuthenticatedView(context, ref)
          : _buildContent(context, ref),
    );
  }

  Widget _buildNotAuthenticatedView(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.barChart,
            size: 64,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
            semanticLabel: 'Analytics',
          ),
          const SizedBox(height: 16),
          Text(
            l10n.signInToViewAnalytics,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.loginPath),
            child: Text(l10n.signIn),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(historicalWorkoutsProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final colors = context.colors;
    final l10n = context.l10n;

    return workoutsAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.errorOutline,
              size: 48,
              color: colors.error,
              semanticLabel: 'Error',
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (workouts) {
        // Calculate data from workouts
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final thisWeekWorkouts = workouts
            .where((w) => w.startTime != null && w.startTime!.isAfter(startOfWeek))
            .toList();
        final lastWeekWorkouts = workouts
            .where((w) =>
                w.startTime != null &&
                w.startTime!
                    .isAfter(startOfWeek.subtract(const Duration(days: 7))) &&
                w.startTime!.isBefore(startOfWeek))
            .toList();

        // Calculate volume
        double weeklyVolume = 0;
        for (final workout in thisWeekWorkouts) {
          for (final ex in workout.exercises) {
            for (final set in ex.sets) {
              if (set.isCompleted) {
                weeklyVolume += (set.weight ?? 0) * (set.reps ?? 0);
              }
            }
          }
        }

        // Calculate muscle heat data (simplified - using exercise categories)
        final categoryVolumes = <String, double>{};
        double maxVolume = 0;
        for (final workout in thisWeekWorkouts) {
          for (final ex in workout.exercises) {
            final volume = ex.sets
                .where((s) => s.isCompleted)
                .fold<double>(
                    0, (sum, s) => sum + (s.weight ?? 0) * (s.reps ?? 0));
            final categoryKey = ex.category.name;
            categoryVolumes[categoryKey] = (categoryVolumes[categoryKey] ?? 0) + volume;
            if (categoryVolumes[categoryKey]! > maxVolume) {
              maxVolume = categoryVolumes[categoryKey]!;
            }
          }
        }

        // Normalize category volumes to 0-100 percentages
        final muscleVolumePercentages = <String, double>{};
        if (maxVolume > 0) {
          for (final entry in categoryVolumes.entries) {
            muscleVolumePercentages[entry.key] =
                (entry.value / maxVolume * 100).clamp(0.0, 100.0);
          }
        }

        // Build top exercises
        final exerciseCounts = <String, int>{};
        final exerciseLastSets = <String, (double, int)>{};
        final exerciseWeightDeltas = <String, double>{};

        for (final workout in thisWeekWorkouts) {
          for (final ex in workout.exercises) {
            exerciseCounts[ex.name] = (exerciseCounts[ex.name] ?? 0) + 1;
            final lastSet = ex.sets.lastWhere(
              (s) => s.isCompleted,
              orElse: () => ex.sets.first,
            );
            exerciseLastSets[ex.name] =
                (lastSet.weight ?? 0, lastSet.reps ?? 0);
            // TODO: Calculate weight delta from previous week
            exerciseWeightDeltas[ex.name] = 0;
          }
        }

        final topExercises = exerciseCounts.entries
            .map((e) => TopExerciseData(
                  name: e.key,
                  sessionCount: e.value,
                  lastWeight: exerciseLastSets[e.key]!.$1,
                  lastReps: exerciseLastSets[e.key]!.$2,
                  weightDelta: exerciseWeightDeltas[e.key]!,
                  measurementUnit: 'kg',
                ))
            .toList()
          ..sort((a, b) => b.sessionCount.compareTo(a.sessionCount));

        // Build recent workouts
        final recentWorkouts = thisWeekWorkouts.take(5).map((w) {
          double vol = 0;
          final categories = <String>{};
          for (final ex in w.exercises) {
            categories.add(ex.category.name);
            for (final set in ex.sets) {
              if (set.isCompleted) {
                vol += (set.weight ?? 0) * (set.reps ?? 0);
              }
            }
          }
          return RecentWorkoutData(
            id: w.id,
            name: w.name,
            date: w.startTime ?? DateTime.now(),
            durationMinutes: w.duration?.inMinutes ?? 0,
            exerciseCount: w.exercises.length,
            totalVolume: vol,
            muscleGroups: categories.toList(),
          );
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(historicalWorkoutsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Hero Stat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HeroStatSection(
                    workoutCount: thisWeekWorkouts.length,
                    previousWeekCount: lastWeekWorkouts.length,
                    weeklyGoal: 5, // TODO: from settings
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Stats Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StatsBarWidget(
                    totalVolume: weeklyVolume,
                    streakDays: 0, // TODO: from streak provider
                    prCount: 0, // TODO: from PR provider
                    measurementUnit: 'kg',
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2b: Body Heatmap
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildBodyHeatmapSection(
                    context,
                    muscleVolumePercentages,
                    isPremium,
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: Top Exercises
                if (topExercises.isNotEmpty)
                  TopExercisesSection(
                    exercises: topExercises.take(4).toList(),
                    onExerciseTap: (name) {
                      context.pushNamed(
                        AppRoutes.exerciseProgressName,
                        queryParameters: {'exercise': name},
                      );
                    },
                    onSeeAllTap: () {
                      context.pushNamed(AppRoutes.exerciseProgressName);
                    },
                  ),
                const SizedBox(height: 24),

                // Section 4: Recent Activity
                RecentActivitySection(
                  workouts: recentWorkouts,
                  onWorkoutTap: (id) {
                    // TODO: Open workout detail modal
                  },
                  onSeeAllTap: () {
                    context.pushNamed(AppRoutes.workoutHistoryName);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyHeatmapSection(
    BuildContext context,
    Map<String, double> muscleVolumePercentages,
    bool isPremium,
  ) {
    final colors = context.colors;
    final l10n = context.l10n;

    // Create MuscleHeatData from percentages
    final heatData =
        MuscleHeatData.fromVolumePercentages(muscleVolumePercentages);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isPremium) {
          // TODO: Navigate to muscle balance screen
          context.pushNamed(AppRoutes.analyticsName);
        } else {
          context.pushNamed(AppRoutes.premiumName);
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: AnatomicalBodyHeatmap(
                heatData: heatData,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SemanticIcon(
                    icon: AppIcons.touchApp,
                    size: 16,
                    color: colors.primary,
                    semanticLabel: 'Tap',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tapForDetailedAnalysis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRO',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
