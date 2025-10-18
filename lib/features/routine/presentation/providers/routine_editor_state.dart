/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: state
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE EDITOR STATE - State management for routine creation wizard
///
/// This manages:
/// - Multi-step wizard state
/// - Form data for each step
/// - Validation state
/// - Pattern selection
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pattern.dart';

/// State for routine editor wizard
class RoutineEditorState {

  RoutineEditorState({
    this.currentStep = 0,
    this.name = '',
    this.description,
    this.type = RoutineType.weekly,
    DateTime? startDate,
    DateTime? endDate,
    this.selectedPattern,
    this.usePresetPattern = true,
    this.customSequence,
    this.selectedTemplates = const [],
    this.recoverySettings,
    this.isValid = false,
    this.errorMessage,
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 7));
  final int currentStep;
  final String name;
  final String? description;
  final RoutineType type;
  final DateTime startDate;
  final DateTime endDate;
  final RoutinePattern? selectedPattern;
  final bool usePresetPattern;
  final List<String>? customSequence;
  final List<String> selectedTemplates; // Template IDs in rotation order
  final RecoverySettings? recoverySettings;
  final bool isValid;
  final String? errorMessage;

  RoutineEditorState copyWith({
    int? currentStep,
    String? name,
    String? description,
    RoutineType? type,
    DateTime? startDate,
    DateTime? endDate,
    RoutinePattern? selectedPattern,
    bool? usePresetPattern,
    List<String>? customSequence,
    List<String>? selectedTemplates,
    RecoverySettings? recoverySettings,
    bool? isValid,
    String? errorMessage,
  }) {
    return RoutineEditorState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedPattern: selectedPattern ?? this.selectedPattern,
      usePresetPattern: usePresetPattern ?? this.usePresetPattern,
      customSequence: customSequence ?? this.customSequence,
      selectedTemplates: selectedTemplates ?? this.selectedTemplates,
      recoverySettings: recoverySettings ?? this.recoverySettings,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  /// Validate current step
  bool isStepValid(int step) {
    switch (step) {
      case 0: // Basic info
        return name.isNotEmpty &&
            name.length >= 3 &&
            startDate.isBefore(endDate);
      case 1: // Pattern selection
        return selectedPattern != null ||
            (customSequence != null && customSequence!.isNotEmpty);
      case 2: // Template selection
        // At least one template must be selected
        return selectedTemplates.isNotEmpty;
      case 3: // Template rotation
        // At least one template must still be selected
        return selectedTemplates.isNotEmpty;
      case 4: // Review (always valid if we got here)
        return true;
      default:
        return false;
    }
  }

  /// Get routine pattern (selected preset or custom)
  RoutinePattern? get finalPattern {
    if (usePresetPattern) {
      return selectedPattern;
    } else {
      return customSequence != null && customSequence!.isNotEmpty
          ? RoutinePattern(
              name: 'Custom Pattern',
              description: 'Custom workout sequence',
              sequence: customSequence!,
              type: PatternType.repeating,
            )
          : null;
    }
  }

  /// Get custom pattern days (alias for customSequence)
  List<String> get customPatternDays => customSequence ?? [];
}

/// Notifier for routine editor state
class RoutineEditorNotifier extends StateNotifier<RoutineEditorState> {
  RoutineEditorNotifier() : super(RoutineEditorState());

  /// Move to next step
  void nextStep() {
    if (state.currentStep < 4 && state.isStepValid(state.currentStep)) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        errorMessage: null,
      );
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(
        currentStep: step,
        errorMessage: null,
      );
    }
  }

  /// Update basic info
  void updateBasicInfo({
    String? name,
    String? description,
    RoutineType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    state = state.copyWith(
      name: name,
      description: description,
      type: type,
      startDate: startDate,
      endDate: endDate,
      isValid: _validateState(
        name: name ?? state.name,
        startDate: startDate ?? state.startDate,
        endDate: endDate ?? state.endDate,
      ),
    );
  }

  /// Select a preset pattern
  void selectPresetPattern(RoutinePattern pattern) {
    state = state.copyWith(
      selectedPattern: pattern,
      usePresetPattern: true,
      customSequence: null,
    );
  }

  /// Set custom pattern sequence
  void setCustomSequence(List<String> sequence) {
    state = state.copyWith(
      customSequence: sequence,
      usePresetPattern: false,
      selectedPattern: null,
    );
  }

  /// Add a day to custom pattern
  void addCustomPatternDay(String dayName) {
    final currentSequence = state.customSequence ?? [];
    final newSequence = [...currentSequence, dayName];

    state = state.copyWith(
      customSequence: newSequence,
      usePresetPattern: false,
      selectedPattern: null,
    );
  }

  /// Remove a day from custom pattern
  void removeCustomPatternDay(int index) {
    final currentSequence = state.customSequence ?? [];
    if (index >= 0 && index < currentSequence.length) {
      final newSequence = [...currentSequence];
      newSequence.removeAt(index);

      state = state.copyWith(
        customSequence: newSequence,
        usePresetPattern: false,
        selectedPattern: null,
      );
    }
  }

  /// Reorder days in custom pattern
  void reorderCustomPatternDay(int oldIndex, int newIndex) {
    final currentSequence = state.customSequence ?? [];
    if (oldIndex < 0 || oldIndex >= currentSequence.length) return;

    final newSequence = [...currentSequence];

    // Adjust newIndex if needed (ReorderableListView behavior)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = newSequence.removeAt(oldIndex);
    newSequence.insert(newIndex, item);

    state = state.copyWith(
      customSequence: newSequence,
      usePresetPattern: false,
      selectedPattern: null,
    );
  }

  /// Clear custom pattern
  void clearCustomPattern() {
    state = state.copyWith(
      customSequence: [],
      usePresetPattern: true,
    );
  }

  /// Update recovery settings
  void updateRecoverySettings(RecoverySettings settings) {
    state = state.copyWith(recoverySettings: settings);
  }

  /// Toggle template selection
  void toggleTemplate(String templateId) {
    final currentTemplates = List<String>.from(state.selectedTemplates);
    if (currentTemplates.contains(templateId)) {
      currentTemplates.remove(templateId);
    } else {
      currentTemplates.add(templateId);
    }
    state = state.copyWith(selectedTemplates: currentTemplates);
  }

  /// Set selected templates list
  void setSelectedTemplates(List<String> templates) {
    state = state.copyWith(selectedTemplates: templates);
  }

  /// Reorder selected templates
  void reorderTemplate(int oldIndex, int newIndex) {
    final templates = List<String>.from(state.selectedTemplates);
    if (oldIndex < 0 || oldIndex >= templates.length) return;

    // Adjust newIndex if needed (ReorderableListView behavior)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = templates.removeAt(oldIndex);
    templates.insert(newIndex, item);

    state = state.copyWith(selectedTemplates: templates);
  }

  /// Reset to initial state
  void reset() {
    state = RoutineEditorState();
  }

  /// Validate entire state
  bool _validateState({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return name.isNotEmpty &&
        name.length >= 3 &&
        startDate.isBefore(endDate);
  }

  /// Set error message
  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for routine editor state
final routineEditorProvider =
    StateNotifierProvider<RoutineEditorNotifier, RoutineEditorState>((ref) {
  return RoutineEditorNotifier();
});
