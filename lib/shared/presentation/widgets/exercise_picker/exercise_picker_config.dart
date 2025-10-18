/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets/exercise_picker
/// 🎯 Feature: shared
/// 🔧 Type: configuration
///
/// Configurazione e strategy per Exercise Picker
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Strategy pattern per gestire il comportamento di selezione esercizi
abstract class ExerciseSelectionStrategy {
  /// Chiamato quando un esercizio viene tappato
  void onExerciseTap(BuildContext context, Exercise exercise);

  /// Se mostrare la UI di multi-selezione
  bool get showMultiSelect => false;

  /// Se mostrare la bottom bar con il conteggio selezionati
  bool get showBottomBar => false;

  /// Se mostrare i filtri avanzati
  bool get showFilters => true;

  /// Se mostrare l'indicatore di selezione sulle card
  bool get showSelectionIndicator => false;
}

/// Strategy per selezione rapida (Community, quick picks)
/// Tap = selezione immediata e chiusura
class QuickPickStrategy extends ExerciseSelectionStrategy {

  QuickPickStrategy({this.onSelected});
  final void Function(Exercise exercise)? onSelected;

  @override
  void onExerciseTap(BuildContext context, Exercise exercise) {
    if (onSelected != null) {
      onSelected!(exercise);
    }
    // Chiudi immediatamente e ritorna l'esercizio
    Navigator.of(context).pop(exercise);
  }

  @override
  bool get showMultiSelect => false;

  @override
  bool get showBottomBar => false;

  @override
  bool get showFilters => false; // Quick pick = solo search, no filtri

  @override
  bool get showSelectionIndicator => false;
}

/// Strategy per selezione multipla (Workout, Templates)
/// Accumula selezioni e naviga a customization
class MultiSelectStrategy extends ExerciseSelectionStrategy {

  MultiSelectStrategy({
    required this.selectedExercises,
    required this.onSelectionChanged,
  });
  final Set<Exercise> selectedExercises;
  final VoidCallback onSelectionChanged;

  @override
  void onExerciseTap(BuildContext context, Exercise exercise) {
    // Toggle selezione
    if (selectedExercises.contains(exercise)) {
      selectedExercises.remove(exercise);
    } else {
      selectedExercises.add(exercise);
    }
    onSelectionChanged();
  }

  @override
  bool get showMultiSelect => true;

  @override
  bool get showBottomBar => true;

  @override
  bool get showFilters => true;

  @override
  bool get showSelectionIndicator => true;
}

/// Configurazione per il picker
class ExercisePickerConfig {

  const ExercisePickerConfig({
    required this.title,
    this.showSearchBar = true,
    this.showMissingExerciseWidget = true,
    required this.strategy,
  });

  /// Config per Quick Pick (Community)
  factory ExercisePickerConfig.quickPick({
    String title = 'Seleziona Esercizio',
    void Function(Exercise)? onSelected,
  }) {
    return ExercisePickerConfig(
      title: title,
      showSearchBar: true,
      showMissingExerciseWidget: false,
      strategy: QuickPickStrategy(onSelected: onSelected),
    );
  }

  /// Config per Multi Select (Workout)
  factory ExercisePickerConfig.multiSelect({
    String title = 'Aggiungi Esercizi',
    required Set<Exercise> selectedExercises,
    required VoidCallback onSelectionChanged,
  }) {
    return ExercisePickerConfig(
      title: title,
      showSearchBar: true,
      showMissingExerciseWidget: true,
      strategy: MultiSelectStrategy(
        selectedExercises: selectedExercises,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
  /// Titolo della schermata
  final String title;

  /// Se mostrare la search bar
  final bool showSearchBar;

  /// Se mostrare il widget "Missing Exercise"
  final bool showMissingExerciseWidget;

  /// Strategy per gestire la selezione
  final ExerciseSelectionStrategy strategy;
}
