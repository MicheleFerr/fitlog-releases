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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_target_muscle_map.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/exercise_picker/exercise_picker_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/equipment_icon_badge.dart';
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

  /// Soglia minima per fuzzy match (0-100)
  static const int _fuzzyThreshold = 70;

  /// Verifica se una query matcha un testo usando fuzzy matching
  bool _fuzzyMatch(String query, String text) {
    // Prima prova match esatto (più veloce)
    if (text.toLowerCase().contains(query)) {
      return true;
    }
    // Poi prova fuzzy match per typos
    final queryTokens = query.split(RegExp(r'\s+')).where((t) => t.length >= 2);
    if (queryTokens.isEmpty) return false;

    final textLower = text.toLowerCase();
    for (final token in queryTokens) {
      if (textLower.contains(token)) continue;

      final textWords = textLower.split(RegExp(r'\s+'));
      bool tokenFound = false;
      for (final word in textWords) {
        if (ratio(token, word) >= _fuzzyThreshold) {
          tokenFound = true;
          break;
        }
      }
      if (!tokenFound) return false;
    }
    return true;
  }

  void _filterExercises() {
    final query = widget.searchQuery.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredExercises = widget.exercises;
      } else {
        // Usa fuzzy matching invece di contains() semplice
        _filteredExercises = widget.exercises.where((exercise) {
          return _fuzzyMatch(query, exercise.nome) ||
              _fuzzyMatch(query, exercise.focusDisplayName) ||
              _fuzzyMatch(query, exercise.attrezzatura);
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
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
              final isSelected =
                  widget.config.strategy is MultiSelectStrategy &&
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
          children: [_buildExerciseMetadata(exercise)],
        ),
        trailing: widget.config.strategy.showSelectionIndicator
            ? (isSelected
                  ? Icon(
                      AppIcons.complete,
                      color: Theme.of(context).colorScheme.primary,
                    )
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
          child: CachedNetworkImage(
            imageUrl: exercise.imageUrl!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
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
            placeholder: (context, url) => Container(
              width: 40,
              height: 40,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: LoadingIndicator(size: 16)),
            ),
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

  Widget _buildExerciseMetadata(Exercise exercise) {
    final hasMuscleData =
        exercise.focus.isNotEmpty || exercise.muscoliSecondari.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMuscleData)
          ExerciseTargetMuscleMap(
            primaryMuscles: exercise.focus,
            secondaryMuscles: exercise.muscoliSecondari,
            previewWidth: 82,
            previewHeight: 60,
            enableFullscreen: false,
          ),
        if (hasMuscleData) const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildDifficultyBadge(exercise.difficolta),
            if (exercise.attrezzatura.isNotEmpty)
              _buildEquipmentChip(exercise.attrezzatura),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final color = _getDifficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEquipmentChip(String equipment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EquipmentIconBadge(equipment: equipment, size: 16),
          const SizedBox(width: 6),
          Text(equipment, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
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
            color: Theme.of(
              context,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
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
