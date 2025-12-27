/// Modal rapido per upgrade esercizio inline
///
/// Versione semplificata del MergeConfirmationBottomSheet
/// ottimizzata per l'uso diretto dal workout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Risultato dell'upgrade
class UpgradeResult {
  const UpgradeResult({
    required this.targetExercise,
    required this.updateOtherWorkouts,
  });

  /// Esercizio target selezionato dal database
  final ExerciseDefinition targetExercise;

  /// Se aggiornare anche negli altri workout
  final bool updateOtherWorkouts;
}

/// Modal rapido per upgrade esercizio
///
/// Mostra preview del best match con opzione "Vedi altri".
/// Checkbox per aggiornare anche altri workout.
class QuickUpgradeModal extends ConsumerStatefulWidget {
  const QuickUpgradeModal({
    super.key,
    required this.currentExerciseName,
    required this.candidate,
    this.affectedWorkoutsCount = 0,
  });

  /// Nome esercizio corrente nel workout
  final String currentExerciseName;

  /// Candidato con lista match
  final MergeCandidate candidate;

  /// Numero di altri workout che contengono questo esercizio
  final int affectedWorkoutsCount;

  /// Mostra il modal e restituisce il risultato
  static Future<UpgradeResult?> show(
    BuildContext context, {
    required String currentExerciseName,
    required MergeCandidate candidate,
    int affectedWorkoutsCount = 0,
  }) async {
    return ModalService.showBottomSheet<UpgradeResult>(
      context,
      child: QuickUpgradeModal(
        currentExerciseName: currentExerciseName,
        candidate: candidate,
        affectedWorkoutsCount: affectedWorkoutsCount,
      ),
    );
  }

  @override
  ConsumerState<QuickUpgradeModal> createState() => _QuickUpgradeModalState();
}

class _QuickUpgradeModalState extends ConsumerState<QuickUpgradeModal> {
  late ExerciseMatch _selectedMatch;
  bool _updateOtherWorkouts = true;
  bool _showAlternatives = false;

  @override
  void initState() {
    super.initState();
    _selectedMatch = widget.candidate.matchingExercises.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.syncAlt,
                      color: colorScheme.onPrimaryContainer,
                      size: AppIconSize.medium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.upgradeExerciseTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.upgradeExerciseSubtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Match visualization
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Source exercise (current)
                    _ExerciseRow(
                      exerciseName: widget.currentExerciseName,
                      isSource: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Arrow with match percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.arrowDownward,
                          color: colorScheme.primary,
                          size: AppIconSize.small,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedMatch.scorePercentage,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Target exercise (selected match)
                    _ExerciseRow(
                      exerciseName: _selectedMatch.exercise.nome,
                      isSource: false,
                      muscleGroups: _selectedMatch.exercise.focus,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Metadata preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _MetadataRow(
                      icon: AppIcons.fitnessCenter,
                      label: l10n.muscles,
                      value: _selectedMatch.exercise.focus.join(', '),
                    ),
                    if (_selectedMatch.exercise.muscoliSecondari.isNotEmpty) ...[
                      const Divider(height: 16),
                      _MetadataRow(
                        icon: AppIcons.accessibility,
                        label: l10n.secondaryMuscles,
                        value: _selectedMatch.exercise.muscoliSecondari.join(', '),
                      ),
                    ],
                    const Divider(height: 16),
                    _MetadataRow(
                      icon: AppIcons.category,
                      label: l10n.movementPattern,
                      value: _selectedMatch.exercise.patternMovimento,
                    ),
                    const Divider(height: 16),
                    _MetadataRow(
                      icon: AppIcons.build,
                      label: l10n.equipment,
                      value: _selectedMatch.exercise.attrezzatura,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Checkbox for other workouts
              if (widget.affectedWorkoutsCount > 0)
                CheckboxListTile(
                  value: _updateOtherWorkouts,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _updateOtherWorkouts = value ?? true);
                  },
                  title: Text(
                    l10n.updateOtherWorkouts(widget.affectedWorkoutsCount),
                    style: textTheme.bodyMedium,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              const SizedBox(height: AppSpacing.md),

              // Alternatives section (collapsible)
              if (widget.candidate.matchingExercises.length > 1) ...[
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _showAlternatives = !_showAlternatives);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAlternatives
                              ? l10n.hideAlternatives
                              : l10n.showAlternatives(
                                  widget.candidate.matchingExercises.length - 1,
                                ),
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAlternatives
                              ? AppIcons.keyboardArrowUp
                              : AppIcons.keyboardArrowDown,
                          size: AppIconSize.small,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showAlternatives) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ...widget.candidate.matchingExercises.skip(1).map(
                        (match) => _AlternativeMatchTile(
                          match: match,
                          isSelected: _selectedMatch == match,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedMatch = match);
                          },
                        ),
                      ),
                ],
              ],
              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _onConfirm,
                      icon: const Icon(AppIcons.check),
                      label: Text(l10n.confirmUpgrade),
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

  void _onConfirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      UpgradeResult(
        targetExercise: _selectedMatch.exercise,
        updateOtherWorkouts: _updateOtherWorkouts,
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exerciseName,
    required this.isSource,
    this.muscleGroups,
  });

  final String exerciseName;
  final bool isSource;
  final List<String>? muscleGroups;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSource
                ? colorScheme.onSurfaceVariant
                : colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exerciseName,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: isSource ? TextDecoration.lineThrough : null,
                  color: isSource
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
              if (muscleGroups != null && muscleGroups!.isNotEmpty)
                Text(
                  muscleGroups!.join(', '),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.small,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AlternativeMatchTile extends StatelessWidget {
  const _AlternativeMatchTile({
    required this.match,
    required this.isSelected,
    required this.onTap,
  });

  final ExerciseMatch match;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.exercise.nome,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      match.exercise.focus.join(', '),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  match.scorePercentage,
                  style: textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
