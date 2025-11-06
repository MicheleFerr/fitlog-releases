/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: routine_center
/// 🔧 Type: widget
/// 🌍 Localization: YES
/// 🎨 Theme: YES
/// 📱 Platform: Universal
///
/// WORKOUT SELECTOR SHEET - Bottom sheet for manual routine day completion
///
/// Structure:
/// DraggableScrollableSheet (70% height)
/// ├─ Handle bar (drag indicator)
/// ├─ Header: "Complete Day with Workout"
/// ├─ Subtitle: "Select a workout to link to [date]"
/// ├─ Divider
/// ├─ WorkoutList (ScrollView)
/// │  └─ recentWorkoutsProvider(7 days)
/// │      └─ ListView.builder → WorkoutSelectorCard
/// ├─ Divider
/// └─ TextButton: "Complete without workout"
///
/// Features:
/// - Fetch recent workouts (last 7 days)
/// - Highlight template matches
/// - Empty state handling
/// - Loading indicator
/// - Error state handling
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_card.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class WorkoutSelectorSheet extends ConsumerWidget {
  const WorkoutSelectorSheet({
    super.key,
    required this.routine,
    required this.date,
    this.templateId,
    required this.onWorkoutSelected,
    required this.onCompleteWithoutWorkout,
  });

  final FlexibleRoutine routine;
  final DateTime date;
  final String? templateId;
  final Future<void> Function(String workoutId) onWorkoutSelected;
  final Future<void> Function() onCompleteWithoutWorkout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.completeDayWithWorkout,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${context.l10n.selectWorkoutToLinkTo} ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date)}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Divider(height: 1, color: context.colors.outlineVariant),

              // Workout list
              Expanded(
                child: _buildWorkoutList(context, ref, scrollController),
              ),

              // Fallback button
              Divider(height: 1, color: context.colors.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => onCompleteWithoutWorkout(),
                  child: Text(context.l10n.completeWithoutWorkout),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutList(
    BuildContext context,
    WidgetRef ref,
    ScrollController scrollController,
  ) {
    final workoutsAsync = ref.watch(recentWorkoutsProvider(7));

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: workouts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final workout = workouts[index];
            final isMatch = _isTemplateMatch(workout.templateId);
            const isLinked = false; // TODO: Check if already linked

            return WorkoutSelectorCard(
              workout: workout,
              isTemplateMatch: isMatch,
              isAlreadyLinked: isLinked,
              onTap: () => onWorkoutSelected(workout.id),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  bool _isTemplateMatch(String? workoutTemplateId) {
    if (templateId == null || workoutTemplateId == null) return false;
    return workoutTemplateId.toLowerCase() == templateId!.toLowerCase();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.workout,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16),
            Text(
              context.l10n.noRecentWorkoutsFound,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.completeDayWithoutWorkout,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => onCompleteWithoutWorkout(),
              child: Text(context.l10n.completeDay),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.error,
              size: AppIconSize.xxlarge,
              color: context.colors.error,
            ),
            SizedBox(height: 16),
            Text(
              context.l10n.failedToLoadWorkouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
