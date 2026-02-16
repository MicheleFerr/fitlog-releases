import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_usage_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Horizontal section showing recently used exercises for quick access
///
/// Displays up to 8 most recently used exercises based on ExerciseUsageTracker.
/// Always visible (not hidden during search) to maximize efficiency for power users.
///
/// UX Rationale:
/// - Recognition over recall (UX best practice)
/// - Progressive disclosure (recent first, then explore)
/// - Cognitive load reduction (max 8 items)
/// - Mobile-first design (large tap targets)
///
/// Personas:
/// - Chiara (Busy Mom): +++ Time-saving, zero friction
/// - Roberto (Busy Pro): +++ Workflow efficiency
/// - Marco (Beginner): ++ Recognition pattern
/// - Luca (Powerlifter): ++ Routine exercises always visible
/// - Sofia (Aesthetic): + Nice to have
class RecentExercisesSection extends StatelessWidget {
  const RecentExercisesSection({
    required this.recentUsage,
    required this.allExercises,
    required this.onExerciseTap,
    this.selectedExercises = const [],
    super.key,
  });

  /// List of recently used exercises from ExerciseUsageTracker
  final List<ExerciseUsageModel> recentUsage;

  /// All available exercises to match IDs
  final List<Exercise> allExercises;

  /// Callback when user taps an exercise chip
  final void Function(Exercise exercise) onExerciseTap;

  /// Currently selected exercises (for visual feedback)
  final List<Exercise> selectedExercises;

  @override
  Widget build(BuildContext context) {
    // Empty state: no recent exercises yet
    if (recentUsage.isEmpty) {
      return const SizedBox.shrink();
    }

    // Map usage models to actual exercises
    final recentExercises = _mapToExercises();

    // If mapping failed or empty, hide section
    if (recentExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.history,
                size: 18,
                color: context.colors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.recentExercises,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),

        // Horizontal scrolling chips
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: recentExercises.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              final exercise = recentExercises[index];
              final isSelected = selectedExercises.contains(exercise);

              return ActionChip(
                avatar: isSelected
                    ? Icon(
                        AppIcons.check,
                        size: 16,
                        color: context.colors.onPrimary,
                      )
                    : null,
                label: Text(
                  exercise.nome,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: isSelected ? context.colors.onPrimary : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: isSelected ? context.colors.primary : null,
                onPressed: () => onExerciseTap(exercise),
              );
            },
          ),
        ),

        // Divider for visual separation
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Divider(height: 1),
        ),
      ],
    );
  }

  /// Map ExerciseUsageModel to actual Exercise objects
  List<Exercise> _mapToExercises() {
    final mapped = <Exercise>[];

    for (final usage in recentUsage) {
      // Find matching exercise by ID
      final exercise = allExercises.firstWhere(
        (e) => e.id == usage.exerciseId,
        orElse: () {
          // Fallback: try matching by name (case-insensitive)
          return allExercises.firstWhere(
            (e) => e.nome.toLowerCase() == usage.exerciseName.toLowerCase(),
            orElse: () => allExercises.first, // Last resort fallback
          );
        },
      );

      if (!mapped.contains(exercise)) {
        mapped.add(exercise);
      }
    }

    return mapped;
  }
}

/// Shimmer loading state for RecentExercisesSection
class RecentExercisesSectionShimmer extends StatelessWidget {
  const RecentExercisesSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        // Chips shimmer
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) {
              return Container(
                width: 100 + (index * 10), // Varied widths for realism
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),

        // Divider
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}
