/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Provider per gestione stato Database Manager con editing veloce
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/database_manager_service.dart';

/// Provider per il servizio Database Manager
final databaseManagerServiceProvider = Provider<DatabaseManagerService>((ref) {
  return DatabaseManagerService();
});

/// Stato del Database Manager
class DatabaseManagerState {

  DatabaseManagerState({
    this.exercises = const [],
    this.filteredExercises = const [],
    this.selectedExerciseIds = const {},
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedDifficulty,
    this.selectedEquipment,
    this.selectedMuscles = const [],
    this.selectedExerciseType,
    this.isInlineEditMode = false,
    this.editingExerciseId,
    this.editingField,
  });
  final List<Exercise> exercises;
  final List<Exercise> filteredExercises;
  final Set<String> selectedExerciseIds;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? selectedDifficulty;
  final String? selectedEquipment;
  final List<String> selectedMuscles;
  final String? selectedExerciseType;
  final bool isInlineEditMode;
  final String? editingExerciseId;
  final String? editingField;

  DatabaseManagerState copyWith({
    List<Exercise>? exercises,
    List<Exercise>? filteredExercises,
    Set<String>? selectedExerciseIds,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedDifficulty,
    String? selectedEquipment,
    List<String>? selectedMuscles,
    String? selectedExerciseType,
    bool? isInlineEditMode,
    String? editingExerciseId,
    String? editingField,
    bool clearError = false,
  }) {
    return DatabaseManagerState(
      exercises: exercises ?? this.exercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      selectedExerciseIds: selectedExerciseIds ?? this.selectedExerciseIds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      selectedMuscles: selectedMuscles ?? this.selectedMuscles,
      selectedExerciseType: selectedExerciseType ?? this.selectedExerciseType,
      isInlineEditMode: isInlineEditMode ?? this.isInlineEditMode,
      editingExerciseId: editingExerciseId ?? this.editingExerciseId,
      editingField: editingField ?? this.editingField,
    );
  }

  bool get hasSelection => selectedExerciseIds.isNotEmpty;
  int get selectionCount => selectedExerciseIds.length;

  bool isEditing(String exerciseId, String field) {
    return editingExerciseId == exerciseId && editingField == field;
  }
}

/// Notifier per Database Manager
class DatabaseManagerNotifier extends Notifier<DatabaseManagerState> {
  @override
  DatabaseManagerState build() {
    _service = ref.watch(databaseManagerServiceProvider);
    return DatabaseManagerState();
  }

  late final DatabaseManagerService _service;

  /// Carica esercizi
  Future<void> loadExercises({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final exercises = await _service.getAllExercises(
        forceRefresh: forceRefresh,
        searchQuery: state.searchQuery,
        difficulty: state.selectedDifficulty,
        equipment: state.selectedEquipment,
        focusMuscles: state.selectedMuscles.isEmpty ? null : state.selectedMuscles,
        exerciseType: state.selectedExerciseType,
      );

      state = state.copyWith(
        exercises: exercises,
        filteredExercises: exercises,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Applica filtri
  Future<void> applyFilters({
    String? searchQuery,
    String? difficulty,
    String? equipment,
    List<String>? muscles,
    String? exerciseType,
  }) async {
    state = state.copyWith(
      searchQuery: searchQuery,
      selectedDifficulty: difficulty,
      selectedEquipment: equipment,
      selectedMuscles: muscles ?? [],
      selectedExerciseType: exerciseType,
    );

    await loadExercises();
  }

  /// Resetta filtri
  void resetFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedDifficulty: null,
      selectedEquipment: null,
      selectedMuscles: [],
      selectedExerciseType: null,
    );
    loadExercises();
  }

  /// Toggle selezione esercizio
  void toggleExerciseSelection(String exerciseId) {
    final newSelection = Set<String>.from(state.selectedExerciseIds);

    if (newSelection.contains(exerciseId)) {
      newSelection.remove(exerciseId);
    } else {
      newSelection.add(exerciseId);
    }

    state = state.copyWith(selectedExerciseIds: newSelection);
  }

  /// Seleziona tutti
  void selectAll() {
    final allIds = state.filteredExercises.map((e) => e.id).toSet();
    state = state.copyWith(selectedExerciseIds: allIds);
  }

  /// Deseleziona tutti
  void clearSelection() {
    state = state.copyWith(selectedExerciseIds: {});
  }

  /// Avvia inline edit
  void startInlineEdit(String exerciseId, String field) {
    state = state.copyWith(
      isInlineEditMode: true,
      editingExerciseId: exerciseId,
      editingField: field,
    );
  }

  /// Cancella inline edit
  void cancelInlineEdit() {
    state = state.copyWith(
      isInlineEditMode: false,
      editingExerciseId: null,
      editingField: null,
    );
  }

  /// Quick update campo singolo
  Future<void> quickUpdateField(String exerciseId, String field, dynamic value) async {
    try {
      final result = await _service.quickUpdateField(
        exerciseId: exerciseId,
        fieldName: field,
        value: value,
      );

      if (result.success) {
        // Aggiorna localmente
        final updatedExercises = state.exercises.map((e) {
          if (e.id == exerciseId) {
            // Crea nuovo esercizio con campo aggiornato
            final json = e.toJson();
            json[field] = value;
            return Exercise.fromJson(json);
          }
          return e;
        }).toList();

        state = state.copyWith(
          exercises: updatedExercises,
          filteredExercises: updatedExercises,
        );

        cancelInlineEdit();
      } else {
        state = state.copyWith(error: result.message);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Bulk update campo per esercizi selezionati
  Future<void> bulkUpdateField(String field, dynamic value) async {
    if (!state.hasSelection) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _service.bulkUpdateField(
        exerciseIds: state.selectedExerciseIds.toList(),
        fieldName: field,
        value: value,
      );

      if (result.success) {
        // Ricarica esercizi
        await loadExercises(forceRefresh: true);
        clearSelection();
      } else {
        state = state.copyWith(error: result.message, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Elimina esercizi selezionati
  Future<void> deleteSelectedExercises() async {
    if (!state.hasSelection) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _service.bulkDeleteExercises(
        state.selectedExerciseIds.toList(),
      );

      if (result.success) {
        await loadExercises(forceRefresh: true);
        clearSelection();
      } else {
        state = state.copyWith(error: result.message, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Export esercizi
  Future<String?> exportExercises({bool selectedOnly = false}) async {
    try {
      final exerciseIds = selectedOnly && state.hasSelection
          ? state.selectedExerciseIds.toList()
          : null;

      final json = await _service.exportToJson(exerciseIds: exerciseIds);
      return json;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Import esercizi
  Future<void> importExercises(String jsonString) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _service.importFromJson(jsonString);

      if (result.success) {
        await loadExercises(forceRefresh: true);
      } else {
        state = state.copyWith(error: result.message, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

/// Provider principale per Database Manager
final databaseManagerProvider =
    NotifierProvider<DatabaseManagerNotifier, DatabaseManagerState>(DatabaseManagerNotifier.new);

/// Provider per dropdown values
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseDropdownValuesProvider = FutureProvider.autoDispose<ExerciseDropdownValues>((ref) async {
  final service = ref.watch(databaseManagerServiceProvider);
  return await service.getDropdownValues();
});

/// Provider per statistiche database
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final databaseStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(databaseManagerServiceProvider);
  return await service.getDatabaseStats();
});

/// Provider per controllo se esercizio richiede peso
final requiresWeightProvider = Provider.family<bool, String>((ref, equipment) {
  final service = ref.watch(databaseManagerServiceProvider);
  return service.requiresWeight(equipment);
});