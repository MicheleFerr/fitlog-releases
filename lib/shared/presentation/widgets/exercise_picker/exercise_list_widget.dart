/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets/exercise_picker
/// 🎯 Feature: shared
/// 🔧 Type: widget
///
/// Widget base riutilizzabile per mostrare lista esercizi
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/exercise_picker_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Widget base che mostra una lista di esercizi filtrabili
/// Usato come componente riutilizzabile da vari picker
class ExerciseListWidget extends ConsumerStatefulWidget {

  const ExerciseListWidget({
    super.key,
    required this.exercises,
    required this.config,
    this.searchQuery = '',
  });
  final List<Exercise> exercises;
  final ExercisePickerConfig config;
  final String searchQuery;

  @override
  ConsumerState<ExerciseListWidget> createState() => _ExerciseListWidgetState();
}

class _ExerciseListWidgetState extends ConsumerState<ExerciseListWidget> {
  late List<Exercise> _filteredExercises;

  @override
  void initState() {
    super.initState();
    _filteredExercises = widget.exercises;
  }

  @override
  void didUpdateWidget(ExerciseListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercises != widget.exercises ||
        oldWidget.searchQuery != widget.searchQuery) {
      _filterExercises();
    }
  }

  void _filterExercises() {
    final query = widget.searchQuery.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredExercises = widget.exercises;
      } else {
        _filteredExercises = widget.exercises.where((exercise) {
          return exercise.nome.toLowerCase().contains(query) ||
              exercise.focusDisplayName.toLowerCase().contains(query) ||
              exercise.attrezzatura.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_filteredExercises.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return Column(
      children: [
        // Results count
        if (_filteredExercises.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Text(
              '${_filteredExercises.length} ${l10n.exercisesFound}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

        // Exercise List
        Expanded(
          child: ListView.builder(
            itemCount: _filteredExercises.length,
            itemBuilder: (context, index) {
              final exercise = _filteredExercises[index];
              final isSelected = widget.config.strategy is MultiSelectStrategy &&
                  (widget.config.strategy as MultiSelectStrategy)
                      .selectedExercises
                      .contains(exercise);

              return _buildExerciseCard(exercise, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise, bool isSelected) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildExerciseLeading(exercise, isSelected),
        title: Text(
          exercise.nome,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.focusDisplayName),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(exercise.difficolta).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.difficolta,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getDifficultyColor(exercise.difficolta),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  exercise.attrezzatura,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: widget.config.strategy.showSelectionIndicator
            ? (isSelected
                ? Icon(AppIcons.complete,
                    color: Theme.of(context).colorScheme.primary)
                : const SemanticIcon(
  icon: AppIcons.radioButtonUnchecked,
  semanticLabel: 'Radio button unchecked',
))
            : null,
        onTap: () => widget.config.strategy.onExerciseTap(context, exercise),
      ),
    );
  }

  Widget _buildExerciseLeading(Exercise exercise, bool isSelected) {
    if (isSelected && widget.config.strategy.showSelectionIndicator) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(AppIcons.check, color: context.colors.surface),
      );
    }

    // Se c'è un'immagine, mostra quella, altrimenti l'icona
    if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        radius: 20,
        child: ClipOval(
          child: Image.network(
            exercise.imageUrl!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback all'icona se l'immagine non carica
              return Container(
                width: 40,
                height: 40,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    exercise.attrezzaturaIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 40,
                height: 40,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: LoadingIndicator(
                    size: 16,
                    progress: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(exercise.attrezzaturaIcon),
      );
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.searchOff,
  semanticLabel: 'Search off',
  size: AppIconSize.medium,
  color: Theme.of(context,
).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noExercisesFound,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryModifyingFilters,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
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
