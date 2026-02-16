import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Horizontal carousel showing recently used workout templates
///
/// Displays up to 3 most recently updated templates with quick start buttons.
/// Last item is a "View all" card that navigates to templates screen.
class RecentTemplatesCarousel extends ConsumerWidget {
  const RecentTemplatesCarousel({
    required this.onStartTemplate,
    super.key,
  });

  /// Callback when user taps start button on a template
  final void Function(WorkoutTemplate template) onStartTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => _buildShimmer(context),
      error: (_, __) => const SizedBox.shrink(),
      data: (templates) {
        // Empty state: no templates yet
        if (templates.isEmpty) {
          return _buildEmptyState(context);
        }

        // Sort by updatedAt descending (most recent first)
        final sortedTemplates = [...templates]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        // Take up to 3 most recent
        final recentTemplates = sortedTemplates.take(3).toList();
        final totalCount = templates.length;

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: recentTemplates.length + 1, // +1 for "View all" card
            itemBuilder: (context, index) {
              // Last item: "View all" card
              if (index == recentTemplates.length) {
                return _buildViewAllCard(context, totalCount);
              }

              // Template card
              final template = recentTemplates[index];
              return _TemplateCard(
                template: template,
                onStartTemplate: onStartTemplate,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.folder,
            size: AppIconSize.large,
            color: context.colors.onSurfaceVariant,
            semanticLabel: context.l10n.noTemplatesYet,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.noTemplatesYet,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.createFirstTemplateHint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () => context.push('/templates'),
            child: Text(context.l10n.createTemplate),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllCard(BuildContext context, int totalCount) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/templates'),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
                icon: AppIcons.arrowForward,
                size: AppIconSize.medium,
                color: context.colors.primary,
                semanticLabel: context.l10n.viewAll,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.viewAllCount(totalCount),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Template card showing name, difficulty, duration, and start button
///
/// Displays actual duration from last completed workout if available,
/// otherwise shows estimated duration from template.
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({
    required this.template,
    required this.onStartTemplate,
  });

  final WorkoutTemplate template;
  final void Function(WorkoutTemplate) onStartTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutHistoryAsync = ref.watch(workoutHistoryProvider);

    // Calculate actual duration and completion from workout history
    Duration? actualDuration;
    int completionCount = 0;
    workoutHistoryAsync.whenData((workouts) {
      // Find all completed workouts with this template
      final templateWorkouts = workouts
          .where((w) => w.templateId == template.id)
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

      completionCount = templateWorkouts.length;
      if (templateWorkouts.isNotEmpty) {
        actualDuration = templateWorkouts.first.duration;
      }
    });

    // Use actual duration if available, otherwise estimated
    final displayMinutes = actualDuration != null
        ? actualDuration!.inMinutes
        : template.estimatedDuration;

    // Get difficulty color for accent bar and badge
    final difficultyColor = _getDifficultyColor(context, template.difficulty);
    final difficultyIcon = _getDifficultyIcon(template.difficulty);

    // Build exercise preview (first 2 exercises)
    final exercisePreview = _buildExercisePreview();

    return GestureDetector(
      onTap: () => onStartTemplate(template),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
          // 🎨 LEFT ACCENT BAR (colored, matching badge)
          boxShadow: [
            BoxShadow(
              color: difficultyColor.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: difficultyColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.md),
                    bottomLeft: Radius.circular(AppSpacing.md),
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: Badge icon + difficulty chip
                  Row(
                    children: [
                      // 🎨 CIRCULAR BADGE with icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: SemanticIcon(
                          icon: difficultyIcon,
                          size: AppIconSize.medium,
                          color: difficultyColor,
                          semanticLabel: template.difficulty ?? 'Workout',
                        ),
                      ),
                      const Spacer(),

                      // Difficulty chip (if available)
                      if (template.difficulty != null)
                        _buildDifficultyChip(context, template.difficulty!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // TITLE
                  Text(
                    template.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),

                  // EXERCISE PREVIEW
                  Text(
                    exercisePreview,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // FOOTER: Stats row
                  Container(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.colors.outlineVariant.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Exercise count
                        SemanticIcon(
                          icon: AppIcons.exercise,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                          semanticLabel: 'Exercises',
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '${template.exercises.length}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        // Duration
                        SemanticIcon(
                          icon: AppIcons.timer,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                          semanticLabel: context.l10n.duration,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '~${displayMinutes}m',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),

                        const Spacer(),

                        // Performance badge (if completed before)
                        if (completionCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.xxs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.check,
                                  size: AppIconSize.tiny,
                                  color: context.colors.success,
                                  semanticLabel: 'Completed',
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$completionCount×',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build exercise preview string (first 2 exercises)
  String _buildExercisePreview() {
    if (template.exercises.isEmpty) return 'No exercises';
    if (template.exercises.length == 1) {
      return template.exercises.first.exerciseName;
    }

    final first = template.exercises.first.exerciseName;
    final second = template.exercises[1].exerciseName;
    return '$first · $second';
  }

  /// Get difficulty color
  Color _getDifficultyColor(BuildContext context, String? difficulty) {
    if (difficulty == null) return context.colors.primary;

    final difficultyLower = difficulty.toLowerCase();
    switch (difficultyLower) {
      case 'beginner':
      case 'principiante':
        return context.colors.success;
      case 'intermediate':
      case 'intermedio':
        return context.colors.warning;
      case 'advanced':
      case 'avanzato':
      case 'expert':
        return context.colors.error;
      default:
        return context.colors.primary;
    }
  }

  /// Get difficulty icon
  IconData _getDifficultyIcon(String? difficulty) {
    if (difficulty == null) return AppIcons.exercise;

    final difficultyLower = difficulty.toLowerCase();
    switch (difficultyLower) {
      case 'beginner':
      case 'principiante':
        return AppIcons.exercise; // Basic dumbbell
      case 'intermediate':
      case 'intermedio':
        return AppIcons.trending; // Trending up
      case 'advanced':
      case 'avanzato':
      case 'expert':
        return AppIcons.localFireDepartment; // Fire for advanced
      default:
        return AppIcons.exercise;
    }
  }

  /// Build difficulty chip with outline (modern design)
  Widget _buildDifficultyChip(BuildContext context, String difficulty) {
    final color = _getDifficultyColor(context, difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        difficulty,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
