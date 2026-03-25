import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_target_muscle_map.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/alternative_exercises_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/equipment_icon_badge.dart';

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
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.tabBarInset),
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
                  if (exercise.focus.isNotEmpty ||
                      exercise.muscoliSecondari.isNotEmpty)
                    ExerciseTargetMuscleMap(
                      primaryMuscles: exercise.focus,
                      secondaryMuscles: exercise.muscoliSecondari,
                      previewWidth: 94,
                      previewHeight: 70,
                    ),
                  if (exercise.focus.isNotEmpty ||
                      exercise.muscoliSecondari.isNotEmpty)
                    const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildDifficultyChip(context, exercise.difficolta),
                      if (exercise.attrezzatura.isNotEmpty)
                        _buildEquipmentChip(context, exercise.attrezzatura),
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

  Widget _buildDifficultyChip(BuildContext context, String difficulty) {
    final color = _getDifficultyColor(context, difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEquipmentChip(BuildContext context, String equipment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EquipmentIconBadge(equipment: equipment, size: 16),
          const SizedBox(width: 6),
          Text(
            equipment,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.tertiary,
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
              size: AppIconSize.emptyState,
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

  /// Get difficulty color (supports both IT and EN values)
  Color _getDifficultyColor(BuildContext context, String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
      case 'beginner':
        return context.colors.success;
      case 'intermedio':
      case 'intermediate':
        return context.colors.secondary;
      case 'avanzato':
      case 'advanced':
        return context.colors.error;
      default:
        return context.colors.surfaceContainerHighest;
    }
  }
}
