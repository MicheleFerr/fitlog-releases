/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: workout_templates
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Provider for managing template import state and operations
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/import_parsing_result.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/services/exercise_matching_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/percentage_conversion_service.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';

part 'template_import_provider.freezed.dart';

/// Import error class
class ImportError {
  const ImportError({
    required this.message,
    required this.field,
    this.isBlocking = false,
  });

  final String message;
  final String field;
  final bool isBlocking;
}

/// Import warning class
class ImportWarning {
  const ImportWarning({
    required this.message,
    required this.field,
  });

  final String message;
  final String field;
}

/// Exercise disambiguation for ambiguous exercise matches
class ExerciseDisambiguation {
  const ExerciseDisambiguation({
    required this.exerciseId,
    required this.originalName,
    required this.options,
    this.selectedOptionIndex,
  });

  final String exerciseId;
  final String originalName;
  final List<ExerciseMatch> options;
  final int? selectedOptionIndex;

  ExerciseDisambiguation copyWith({
    String? exerciseId,
    String? originalName,
    List<ExerciseMatch>? options,
    int? selectedOptionIndex,
  }) {
    return ExerciseDisambiguation(
      exerciseId: exerciseId ?? this.exerciseId,
      originalName: originalName ?? this.originalName,
      options: options ?? this.options,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
    );
  }
}

/// State for template import process
@freezed
abstract class TemplateImportState with _$TemplateImportState {
  const factory TemplateImportState({
    @Default([]) List<ImportParsingResult> parsingResults,
    @Default([]) List<ExerciseDisambiguation> exerciseDisambiguations,
    @Default([]) List<PercentageConversion> percentageConversions,
    @Default([]) List<ImportWarning> warnings,
    @Default([]) List<ImportError> errors,
    @Default(0.0) double progress,
    String? currentStep,
    ImportPhase? currentPhase,
    @Default([]) List<WorkoutTemplateImportData> finalTemplates,
  }) = _TemplateImportState;
}

/// Phases of the import process
enum ImportPhase {
  parsing,
  exerciseMatching,
  percentageConversion,
  finalizing,
  completed,
}

/// Provider for template import functionality (Riverpod 2.x)
class TemplateImportNotifier extends Notifier<TemplateImportState> {

  late final ExerciseMatchingService _exerciseMatchingService;
  late final PercentageConversionService _percentageService;

  @override
  TemplateImportState build() {
    _exerciseMatchingService = ExerciseMatchingService.instance;
    _percentageService = PercentageConversionService();
    return const TemplateImportState();
  }
  
  /// Import from natural language text
  Future<void> importFromText(
    String text,
  ) async {
    try {
      _updateProgress(0.1, 'Parsing workout text...');
      state = state.copyWith(currentPhase: ImportPhase.parsing);

      // Parse multiple workouts if present (stub - not implemented yet)
      // final results = await _parsingService.parseMultipleWorkouts(text);
      final results = <ImportParsingResult>[];

      _updateProgress(0.3, 'Processing exercises...');

      // Combine all warnings and errors
      final allWarnings = <ImportWarning>[];
      final allErrors = <ImportError>[];
      
      // Check for blocking errors
      final blockingErrors = allErrors.where((e) => e.isBlocking == true);
      if (blockingErrors.isNotEmpty) {
        state = state.copyWith(
          errors: allErrors,
          warnings: allWarnings,
          progress: 0.0,
          currentStep: 'Import failed due to errors',
        );
        return;
      }
      
      state = state.copyWith(
        parsingResults: results,
        warnings: allWarnings,
        errors: allErrors,
      );
      
      // Continue with exercise matching
      await _processExerciseMatching();
      
    } catch (e) {
      state = state.copyWith(
        errors: [
          ImportError(
            message: 'Failed to parse text: $e',
            field: 'parsing',
            isBlocking: true,
          ),
        ],
        progress: 0.0,
        currentStep: 'Import failed',
      );
    }
  }
  
  /// Import from JSON
  Future<void> importFromJson(String jsonText) async {
    try {
      _updateProgress(0.1, 'Parsing JSON...');
      state = state.copyWith(currentPhase: ImportPhase.parsing);
      
      final jsonData = json.decode(jsonText);
      
      // Handle single template or batch import
      List<WorkoutTemplateImportData> templates;
      if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('templates')) {
          // Batch import
          final batchImport = WorkoutTemplatesBatchImport.fromJson(jsonData);
          templates = batchImport.templates;
        } else {
          // Single template
          templates = [WorkoutTemplateImportData.fromJson(jsonData)];
        }
      } else if (jsonData is List) {
        // Array of templates
        templates = jsonData
            .map((item) => WorkoutTemplateImportData.fromJson(item))
            .toList();
      } else {
        throw const FormatException('Invalid JSON format');
      }
      
      // Create parsing results
      final results = templates
          .map((template) => ImportParsingResult(template: template))
          .toList();
      
      _updateProgress(0.3, 'Processing exercises...');
      
      state = state.copyWith(parsingResults: results);
      
      // Continue with exercise matching
      await _processExerciseMatching();
      
    } catch (e) {
      state = state.copyWith(
        errors: [
          ImportError(
            message: 'Failed to parse JSON: $e',
            field: 'json',
            isBlocking: true,
          ),
        ],
        progress: 0.0,
        currentStep: 'JSON parsing failed',
      );
    }
  }
  
  /// Process exercise matching for all templates
  Future<void> _processExerciseMatching() async {
    _updateProgress(0.4, 'Matching exercises...');
    state = state.copyWith(currentPhase: ImportPhase.exerciseMatching);
    
    final allDisambiguations = <ExerciseDisambiguation>[];

    for (final result in state.parsingResults) {
      if (result.template == null) continue;

      for (final exercise in result.template!.exercises) {
        // Find matching exercises
        final matches = await _exerciseMatchingService.findMatches(exercise.name);

        if (matches.isNotEmpty) {
          // Create disambiguation object
          final disambiguation = ExerciseDisambiguation(
            exerciseId: '${result.template!.name}_${exercise.name}',
            originalName: exercise.name,
            options: matches,
          );
          allDisambiguations.add(disambiguation);
        }
      }
    }
    
    _updateProgress(0.6, 'Processing percentage weights...');
    
    if (allDisambiguations.isNotEmpty) {
      // Need user input for exercise disambiguation
      state = state.copyWith(
        exerciseDisambiguations: allDisambiguations,
        progress: 0.6,
        currentStep: 'Select correct exercises',
      );
      return;
    }
    
    // No disambiguation needed, continue with percentage conversion
    await _processPercentageConversion();
  }
  
  /// Process percentage conversion
  Future<void> _processPercentageConversion() async {
    _updateProgress(0.7, 'Converting percentage weights...');
    state = state.copyWith(currentPhase: ImportPhase.percentageConversion);

    final userValue = ref.read(unifiedUserProvider);
    final user = userValue.value; // Extract value from AsyncValue

    if (user == null) {
      state = state.copyWith(
        errors: [
          const ImportError(
            message: 'User not authenticated',
            field: 'auth',
            isBlocking: true,
          ),
        ],
      );
      return;
    }

    final allConversions = <PercentageConversion>[];

    for (final result in state.parsingResults) {
      if (result.template == null) continue;

      final conversions = await _percentageService.processPercentageConversions(
        result.template!,
        user.uid,
      );
      allConversions.addAll(conversions);
    }
    
    if (allConversions.isNotEmpty) {
      // Need user input for percentage conversion
      state = state.copyWith(
        percentageConversions: allConversions,
        progress: 0.8,
        currentStep: 'Review percentage conversions',
      );
      return;
    }
    
    // No conversion needed, finalize import
    await finalizeImport();
  }
  
  /// Update exercise disambiguation selection
  void updateExerciseDisambiguation(String exerciseId, int selectedIndex) {
    final updated = state.exerciseDisambiguations
        .map((d) => d.exerciseId == exerciseId 
            ? d.copyWith(selectedOptionIndex: selectedIndex)
            : d)
        .toList();
    
    state = state.copyWith(exerciseDisambiguations: updated);
  }
  
  /// Resolve exercise disambiguations and continue
  Future<void> resolveExerciseDisambiguations() async {
    // Check all disambiguations are resolved
    final unresolved = state.exerciseDisambiguations
        .where((d) => d.selectedOptionIndex == null)
        .toList();
    
    if (unresolved.isNotEmpty) {
      state = state.copyWith(
        errors: [
          const ImportError(
            message: 'Please select exercises for all disambiguations',
            field: 'disambiguation',
            isBlocking: false,
          ),
        ],
      );
      return;
    }
    
    // Apply disambiguations to templates
    // This would involve updating the exercise names/IDs in the templates
    // Implementation depends on how exercises are stored
    
    await _processPercentageConversion();
  }
  
  /// Update percentage conversion
  void updatePercentageConversion(String exerciseId, double newMax) {
    final updated = state.percentageConversions
        .map((c) => c.exerciseId == exerciseId 
            ? c.copyWith(userAdjustedMax: newMax)
            : c)
        .toList();
    
    state = state.copyWith(percentageConversions: updated);
  }
  
  /// Confirm percentage conversion
  void confirmPercentageConversion(String exerciseId, bool confirmed) {
    final updated = state.percentageConversions
        .map((c) => c.exerciseId == exerciseId 
            ? c.copyWith(userConfirmed: confirmed)
            : c)
        .toList();
    
    state = state.copyWith(percentageConversions: updated);
  }
  
  /// Finalize import process
  Future<bool> finalizeImport() async {
    _updateProgress(0.9, 'Finalizing import...');
    state = state.copyWith(currentPhase: ImportPhase.finalizing);

    try {
      final userValue = ref.read(unifiedUserProvider);
      final user = userValue.value;

      if (user == null) {
        state = state.copyWith(
          errors: [
            const ImportError(
              message: 'User not authenticated',
              field: 'auth',
              isBlocking: true,
            ),
          ],
        );
        return false;
      }

      final finalTemplates = <WorkoutTemplateImportData>[];
      
      // Apply percentage conversions
      for (final result in state.parsingResults) {
        var template = result.template;

        if (template == null) continue;

        // Apply percentage conversions if any
        final templateConversions = state.percentageConversions
            .where((c) => c.exerciseId.startsWith(template!.name))
            .toList();

        if (templateConversions.isNotEmpty) {
          template = _percentageService.applyPercentageConversions(
            template,
            templateConversions,
          );
        }

        finalTemplates.add(template);
      }

      // Convert to domain entities and save
      for (final template in finalTemplates) {
        final _ = _convertToDomainTemplate(template, user.uid);

        // Save template (implementation depends on repository)
        // await _templateRepository.saveTemplate(domainTemplate);
      }
      
      _updateProgress(1.0, 'Import completed!');
      state = state.copyWith(
        currentPhase: ImportPhase.completed,
        finalTemplates: finalTemplates,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        errors: [
          ImportError(
            message: 'Failed to finalize import: $e',
            field: 'finalization',
            isBlocking: true,
          ),
        ],
        progress: 0.8,
        currentStep: 'Import failed',
      );
      return false;
    }
  }
  
  /// Convert import data to domain template
  WorkoutTemplate _convertToDomainTemplate(
    WorkoutTemplateImportData importData,
    String userId,
  ) {
    final exercises = importData.exercises
        .map((exercise) => _convertToExercise(exercise))
        .toList();
    
    return WorkoutTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: importData.name,
      description: importData.description,
      exercises: exercises,
      category: _mapCategory(importData.category),
      visibility: TemplateVisibility.private,
      createdAt: DateTime.now(),
      tags: importData.tags ?? [],
      estimatedDurationMinutes: importData.estimatedDurationMinutes,
      difficultyLevel: importData.difficulty?.toString(),
      requiredEquipment: importData.requiredEquipment ?? [],
      targetMuscles: importData.targetMuscles ?? [],
    );
  }
  
  /// Convert import exercise to domain exercise
  Exercise _convertToExercise(ExerciseImportData importData) {
    final sets = importData.sets
        .asMap()
        .entries
        .map((entry) => _convertToExerciseSet(entry.value, entry.key + 1))
        .toList();
    
    return Exercise(
      name: importData.name,
      type: ExerciseType.single, // Default, could be inferred
      category: _mapExerciseCategory(importData.category),
      sets: sets,
      notes: importData.notes,
      restTime: importData.restTimeSeconds,
    );
  }
  
  /// Convert import set to domain set
  ExerciseSet _convertToExerciseSet(SetImportData importData, int setNumber) {
    return ExerciseSet(
      setNumber: setNumber,
      weight: _parseWeight(importData.weight),
      reps: _parseReps(importData.reps),
      notes: importData.notes,
      isWarmup: importData.isWarmup ?? false,
    );
  }
  
  /// Parse weight from string
  double? _parseWeight(String? weight) {
    if (weight == null) return null;
    
    // Extract numeric value from weight string
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
  
  /// Parse reps from string  
  int? _parseReps(String? reps) {
    if (reps == null) return null;
    
    // Extract first number from reps string
    final match = RegExp(r'(\d+)').firstMatch(reps);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
  
  /// Map category string to enum
  TemplateCategory _mapCategory(String? category) {
    if (category == null) return TemplateCategory.custom;
    
    switch (category.toLowerCase()) {
      case 'strength': return TemplateCategory.strength;
      case 'hypertrophy': return TemplateCategory.hypertrophy;
      case 'endurance': return TemplateCategory.endurance;
      case 'powerlifting': return TemplateCategory.powerlifting;
      case 'bodybuilding': return TemplateCategory.bodybuilding;
      case 'cardio': return TemplateCategory.cardio;
      default: return TemplateCategory.custom;
    }
  }
  
  /// Map exercise category
  ExerciseCategory _mapExerciseCategory(String? category) {
    if (category == null) return ExerciseCategory.other;
    
    switch (category.toLowerCase()) {
      case 'chest': return ExerciseCategory.chest;
      case 'back': return ExerciseCategory.back;
      case 'shoulders': return ExerciseCategory.shoulders;
      case 'arms': return ExerciseCategory.arms;
      case 'legs': return ExerciseCategory.legs;
      case 'abs': return ExerciseCategory.abs;
      case 'cardio': return ExerciseCategory.cardio;
      default: return ExerciseCategory.other;
    }
  }
  
  /// Update progress
  void _updateProgress(double progress, String step) {
    state = state.copyWith(
      progress: progress,
      currentStep: step,
    );
  }
  
  /// Reset state
  void reset() {
    state = const TemplateImportState();
  }
}

/// Provider for template import (Riverpod 2.x)
final templateImportProvider = NotifierProvider<TemplateImportNotifier, TemplateImportState>(
  TemplateImportNotifier.new,
);