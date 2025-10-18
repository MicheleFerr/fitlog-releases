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
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                    color: _getDifficultyColor(exercise.difficolta).withOpacity(0.2),
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
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary)
                : const Icon(Icons.radio_button_unchecked))
            : null,
        onTap: () => widget.config.strategy.onExerciseTap(context, exercise),
      ),
    );
  }

  Widget _buildExerciseLeading(Exercise exercise, bool isSelected) {
    if (isSelected && widget.config.strategy.showSelectionIndicator) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.check, color: Colors.white),
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
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
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
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return Colors.green;
      case 'intermedio':
        return Colors.orange;
      case 'avanzato':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
