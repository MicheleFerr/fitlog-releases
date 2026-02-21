import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/alternative_exercises_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';

/// Tab Esercizi Alternativi: mostra esercizi simili nella stessa categoria
class ExerciseAlternativesTab extends ConsumerWidget {
  const ExerciseAlternativesTab({super.key, required this.exerciseName});
  final String exerciseName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alternativesAsync = ref.watch(
      alternativeExercisesProvider(exerciseName),
    );

    return alternativesAsync.when(
      data: (alternatives) {
        if (alternatives.isEmpty) {
          return _buildEmptyState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Icon(
                    AppIcons.swapHoriz,
                    color: context.colors.primary,
                    size: AppIconSize.large,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.alternativeExercises,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        Text(
                          context.l10n.alternativeExercisesCount(
                            alternatives.length,
                          ),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Alternative exercises list
              ...alternatives.map(
                (exercise) => _buildAlternativeCard(context, exercise),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => _buildEmptyState(context),
    );
  }

  /// Build alternative exercise card
  Widget _buildAlternativeCard(BuildContext context, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise image/GIF
            ExerciseGifWidget(
              gifUrl: exercise.imageUrl,
              exerciseName: exercise.nome,
              size: 64,
            ),
            const SizedBox(width: 12),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name
                  Text(
                    exercise.nome,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Metadata chips row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Difficulty
                      _buildMetadataChip(
                        context,
                        _getDifficultyIcon(exercise.difficolta),
                        exercise.difficolta,
                        _getDifficultyColor(context, exercise.difficolta),
                      ),
                      // Equipment
                      if (exercise.attrezzatura.isNotEmpty)
                        _buildMetadataChip(
                          context,
                          AppIcons.construction,
                          exercise.attrezzatura,
                          context.colors.tertiary,
                        ),
                      // Primary muscles
                      if (exercise.focus.isNotEmpty)
                        _buildMetadataChip(
                          context,
                          AppIcons.accessibility,
                          exercise.focus.join(', '),
                          context.colors.secondary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build metadata chip
  Widget _buildMetadataChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.tiny, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no alternatives found
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.searchOff,
              semanticLabel: context.l10n.noAlternativesFound,
              size: AppIconSize.medium,
              color: context.colors.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noAlternativesFound,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noAlternativesHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get difficulty icon
  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return AppIcons.star;
      case 'intermedio':
        return AppIcons.starHalf;
      case 'avanzato':
        return AppIcons.stars;
      default:
        return AppIcons.help;
    }
  }

  /// Get difficulty color
  Color _getDifficultyColor(BuildContext context, String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return context.colors.success;
      case 'intermedio':
        return context.colors.secondary;
      case 'avanzato':
        return context.colors.error;
      default:
        return context.colors.surfaceContainerHighest;
    }
  }
}
