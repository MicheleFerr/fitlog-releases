/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: utils
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Comprehensive validation utilities for import/export operations with error recovery
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';

/// Comprehensive validation utilities for import operations
class ImportValidationUtils {
  
  /// Validate JSON content before parsing
  static ValidationResult validateJsonContent(String jsonContent) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (jsonContent.trim().isEmpty) {
      errors.add('JSON content is empty');
      return ValidationResult(errors: errors, warnings: warnings);
    }
    
    try {
      final parsed = json.decode(jsonContent);
      
      // Validate JSON structure
      if (parsed is Map<String, dynamic>) {
        _validateJsonStructure(parsed, errors, warnings);
      } else if (parsed is List) {
        _validateJsonArray(parsed, errors, warnings);
      } else {
        errors.add('JSON must be an object or array');
      }
      
    } catch (e) {
      errors.add('Invalid JSON format: $e');
    }
    
    return ValidationResult(errors: errors, warnings: warnings);
  }
  
  /// Validate text content before parsing
  static ValidationResult validateTextContent(String textContent) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (textContent.trim().isEmpty) {
      errors.add('Text content is empty');
      return ValidationResult(errors: errors, warnings: warnings);
    }
    
    // Check for common patterns
    final lines = textContent.split('\n');
    var hasWorkoutTitles = false;
    var hasExercises = false;
    var hasSets = false;
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      // Check for workout titles
      if (_looksLikeWorkoutTitle(trimmed)) {
        hasWorkoutTitles = true;
      }
      
      // Check for exercises
      if (_looksLikeExercise(trimmed)) {
        hasExercises = true;
      }
      
      // Check for sets
      if (_looksLikeSet(trimmed)) {
        hasSets = true;
      }
    }
    
    if (!hasWorkoutTitles) {
      warnings.add('No workout titles found - content may not parse correctly');
    }
    
    if (!hasExercises) {
      warnings.add('No exercise names detected');
    }
    
    if (!hasSets) {
      errors.add('No set information found (Set1 x reps: weight format)');
    }
    
    // Check text length
    if (textContent.length > 50000) {
      warnings.add('Very large text content - parsing may be slow');
    }
    
    return ValidationResult(errors: errors, warnings: warnings);
  }
  
  /// Validate workout template structure
  static ValidationResult validateWorkoutTemplate(WorkoutTemplateImportData template) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validate name
    if (template.name.trim().isEmpty) {
      errors.add('Template name is required');
    } else if (template.name.length > 100) {
      warnings.add('Template name is very long (${template.name.length} characters)');
    }
    
    // Validate exercises
    if (template.exercises.isEmpty) {
      errors.add('Template must contain at least one exercise');
    } else if (template.exercises.length > 20) {
      warnings.add('Template has many exercises (${template.exercises.length}) - may be hard to complete');
    }
    
    // Validate each exercise
    for (int i = 0; i < template.exercises.length; i++) {
      final exercise = template.exercises[i];
      final exerciseErrors = _validateExercise(exercise, i + 1);
      errors.addAll(exerciseErrors.errors);
      warnings.addAll(exerciseErrors.warnings);
    }
    
    // Validate estimated duration
    if (template.estimatedDurationMinutes != null) {
      if (template.estimatedDurationMinutes! < 10) {
        warnings.add('Very short workout duration (${template.estimatedDurationMinutes} min)');
      } else if (template.estimatedDurationMinutes! > 240) {
        warnings.add('Very long workout duration (${template.estimatedDurationMinutes} min)');
      }
    }
    
    return ValidationResult(errors: errors, warnings: warnings);
  }
  
  // NOTE: ExerciseDisambiguation and PercentageConversion classes don't exist yet
  // Commenting out these validation methods until the classes are implemented

  // /// Validate exercise disambiguation
  // static ValidationResult validateExerciseDisambiguation(dynamic disambiguation) {
  //   final errors = <String>[];
  //   final warnings = <String>[];
  //
  //   // TODO: Implement when ExerciseDisambiguation class is created
  //   errors.add('Exercise disambiguation validation not implemented');
  //
  //   return ValidationResult(errors: errors, warnings: warnings);
  // }
  //
  // /// Validate percentage conversion
  // static ValidationResult validatePercentageConversion(dynamic conversion) {
  //   final errors = <String>[];
  //   final warnings = <String>[];
  //
  //   // TODO: Implement when PercentageConversion class is created
  //   errors.add('Percentage conversion validation not implemented');
  //
  //   return ValidationResult(errors: errors, warnings: warnings);
  // }
  
  /// Sanitize and fix common import issues
  static WorkoutTemplateImportData sanitizeTemplate(WorkoutTemplateImportData template) {
    return template.copyWith(
      name: _sanitizeName(template.name),
      description: _sanitizeDescription(template.description),
      exercises: template.exercises.map(_sanitizeExercise).toList(),
      tags: _sanitizeTags(template.tags ?? []),
      requiredEquipment: _sanitizeStringList(template.requiredEquipment ?? []),
      targetMuscles: _sanitizeStringList(template.targetMuscles ?? []),
      estimatedDurationMinutes: _sanitizeDuration(template.estimatedDurationMinutes),
    );
  }
  
  /// Auto-fix common parsing errors
  static String autoFixCommonErrors(String input) {
    var fixed = input;
    
    // Fix common typos in exercise names
    final exerciseFixes = {
      'bench press': ['bench', 'panca piana', 'chest press'],
      'squat': ['squad', 'squats'],
      'deadlift': ['dead lift', 'stacco da terra'],
      'overhead press': ['ohp', 'military press'],
      'lat pulldown': ['lat pull down', 'lat machine'],
    };
    
    for (final entry in exerciseFixes.entries) {
      final correct = entry.key;
      final alternatives = entry.value;
      
      for (final alt in alternatives) {
        fixed = fixed.replaceAll(RegExp(alt, caseSensitive: false), correct);
      }
    }
    
    // Fix common set notation errors
    fixed = fixed.replaceAll(RegExp(r'Set\s*(\d+)\s*[x×]\s*(\d+)\s*:\s*'), 'Set\$1 x \$2: ');
    
    // Fix weight notation
    fixed = fixed.replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*kgs?'), '\$1kg');
    fixed = fixed.replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*lbs?'), '\$1lb');
    
    // Fix rest time notation
    fixed = fixed.replaceAll(RegExp(r'(\d+)\s*minutes?'), '\$1 min');
    fixed = fixed.replaceAll(RegExp(r'(\d+)\s*seconds?'), '\$1 sec');
    
    return fixed;
  }
  
  /// Generate suggestions for fixing errors
  static List<ErrorFixSuggestion> generateFixSuggestions(List<String> errors) {
    final suggestions = <ErrorFixSuggestion>[];
    
    for (final error in errors) {
      if (error.contains('empty')) {
        suggestions.add(ErrorFixSuggestion(
          error: error,
          suggestion: 'Provide a descriptive name or remove empty entries',
          autoFixable: false,
        ));
      } else if (error.contains('invalid weight') || error.contains('invalid percentage')) {
        suggestions.add(ErrorFixSuggestion(
          error: error,
          suggestion: 'Check numeric values and ensure they are positive',
          autoFixable: true,
        ));
      } else if (error.contains('no sets')) {
        suggestions.add(ErrorFixSuggestion(
          error: error,
          suggestion: 'Add set information in format: Set1 x 5: 80kg',
          autoFixable: false,
        ));
      }
    }
    
    return suggestions;
  }
  
  // Private helper methods
  
  static void _validateJsonStructure(
    Map<String, dynamic> json,
    List<String> errors,
    List<String> warnings,
  ) {
    // Check for required fields in single template
    if (json.containsKey('name') && json.containsKey('exercises')) {
      _validateSingleTemplateJson(json, errors, warnings);
    } 
    // Check for batch import format
    else if (json.containsKey('templates')) {
      _validateBatchImportJson(json, errors, warnings);
    } else {
      errors.add('JSON must contain either template fields (name, exercises) or templates array');
    }
  }
  
  static void _validateJsonArray(
    List<dynamic> jsonArray,
    List<String> errors,
    List<String> warnings,
  ) {
    if (jsonArray.isEmpty) {
      errors.add('Template array is empty');
      return;
    }
    
    if (jsonArray.length > 50) {
      warnings.add('Large number of templates (${jsonArray.length}) - processing may be slow');
    }
    
    for (int i = 0; i < jsonArray.length; i++) {
      if (jsonArray[i] is! Map<String, dynamic>) {
        errors.add('Template $i is not a valid object');
      }
    }
  }
  
  static void _validateSingleTemplateJson(
    Map<String, dynamic> json,
    List<String> errors,
    List<String> warnings,
  ) {
    if (json['name'] == null || json['name'].toString().trim().isEmpty) {
      errors.add('Template name is required');
    }
    
    if (json['exercises'] == null || json['exercises'] is! List) {
      errors.add('Exercises array is required');
    } else {
      final exercises = json['exercises'] as List;
      if (exercises.isEmpty) {
        errors.add('Template must have at least one exercise');
      }
    }
  }
  
  static void _validateBatchImportJson(
    Map<String, dynamic> json,
    List<String> errors,
    List<String> warnings,
  ) {
    final templates = json['templates'];
    if (templates == null || templates is! List) {
      errors.add('Templates must be an array');
    } else {
      final templateList = templates;
      if (templateList.isEmpty) {
        errors.add('Templates array is empty');
      }
    }
  }
  
  static ValidationResult _validateExercise(ExerciseImportData exercise, int exerciseNumber) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (exercise.name.trim().isEmpty) {
      errors.add('Exercise $exerciseNumber: name is required');
    }
    
    if (exercise.sets.isEmpty) {
      errors.add('Exercise $exerciseNumber: must have at least one set');
    } else if (exercise.sets.length > 10) {
      warnings.add('Exercise $exerciseNumber: many sets (${exercise.sets.length}) - may be excessive');
    }
    
    // Validate sets
    for (int i = 0; i < exercise.sets.length; i++) {
      final set = exercise.sets[i];
      final setErrors = _validateSet(set, exerciseNumber, i + 1);
      errors.addAll(setErrors.errors);
      warnings.addAll(setErrors.warnings);
    }
    
    return ValidationResult(errors: errors, warnings: warnings);
  }
  
  static ValidationResult _validateSet(SetImportData set, int exerciseNumber, int setNumber) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validate weight
    if (set.weight != null && set.weight!.isNotEmpty) {
      final weightValue = _extractNumericValue(set.weight!);
      if (weightValue != null && weightValue <= 0) {
        errors.add('Exercise $exerciseNumber, Set $setNumber: weight must be positive');
      } else if (weightValue != null && weightValue > 1000) {
        warnings.add('Exercise $exerciseNumber, Set $setNumber: very high weight (${weightValue}kg)');
      }
    }
    
    // Validate reps
    if (set.reps != null && set.reps!.isNotEmpty) {
      final repsValue = _extractNumericValue(set.reps!);
      if (repsValue != null && repsValue <= 0) {
        errors.add('Exercise $exerciseNumber, Set $setNumber: reps must be positive');
      } else if (repsValue != null && repsValue > 100) {
        warnings.add('Exercise $exerciseNumber, Set $setNumber: very high reps ($repsValue)');
      }
    }
    
    return ValidationResult(errors: errors, warnings: warnings);
  }
  
  static bool _looksLikeWorkoutTitle(String line) {
    final patterns = [
      r'LUNEDÌ|MARTEDÌ|MERCOLEDÌ|GIOVEDÌ|VENERDÌ|SABATO|DOMENICA',
      r'MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY|SUNDAY',
      r'DAY\s*\d+|GIORNO\s*\d+',
      r'WORKOUT\s*\d*|ALLENAMENTO\s*\d*',
      r'PUSH|PULL|LEGS|ARMS',
    ];
    
    return patterns.any((pattern) => RegExp(pattern, caseSensitive: false).hasMatch(line));
  }
  
  static bool _looksLikeExercise(String line) {
    // Exercise lines usually have rest time or exercise-like keywords
    return RegExp(r'(-\s*\d+(-\d+)?\s*(min|sec))|'
                  r'(press|curl|squat|deadlift|panca|stacco|alzate)',
                  caseSensitive: false).hasMatch(line) &&
           !RegExp(r'^Set\d+', caseSensitive: false).hasMatch(line);
  }
  
  static bool _looksLikeSet(String line) {
    return RegExp(r'Set\d+\s*x\s*\d+', caseSensitive: false).hasMatch(line);
  }
  
  static String _sanitizeName(String name) {
    return name.trim().isEmpty ? 'Imported Workout' : name.trim();
  }
  
  static String? _sanitizeDescription(String? description) {
    return description?.trim().isEmpty == true ? null : description?.trim();
  }
  
  static ExerciseImportData _sanitizeExercise(ExerciseImportData exercise) {
    return exercise.copyWith(
      name: exercise.name.trim().isEmpty ? 'Unknown Exercise' : exercise.name.trim(),
      sets: exercise.sets.map(_sanitizeSet).toList(),
      restTimeSeconds: _sanitizeRestTime(exercise.restTimeSeconds),
    );
  }
  
  static SetImportData _sanitizeSet(SetImportData set) {
    return set.copyWith(
      weight: _sanitizeWeight(set.weight),
      reps: _sanitizeReps(set.reps),
    );
  }
  
  static List<String> _sanitizeTags(List<String> tags) {
    return tags
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }
  
  static List<String> _sanitizeStringList(List<String> list) {
    return list
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  
  static int? _sanitizeDuration(int? duration) {
    if (duration == null) return null;
    return duration.clamp(5, 300); // 5 minutes to 5 hours max
  }
  
  static String? _sanitizeWeight(String? weight) {
    if (weight == null) return null;
    // Remove extra spaces and normalize format
    return weight.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  static String? _sanitizeReps(String? reps) {
    if (reps == null) return null;
    return reps.trim();
  }
  
  static int? _sanitizeRestTime(int? restTime) {
    if (restTime == null) return null;
    return restTime.clamp(10, 600); // 10 seconds to 10 minutes max
  }
  
  static double? _extractNumericValue(String input) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(input);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}

/// Result of validation operation
class ValidationResult {
  
  ValidationResult({
    this.errors = const [],
    this.warnings = const [],
  });
  final List<String> errors;
  final List<String> warnings;
  
  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;
  
  int get totalIssues => errors.length + warnings.length;
}

/// Suggestion for fixing an error
class ErrorFixSuggestion {
  
  ErrorFixSuggestion({
    required this.error,
    required this.suggestion,
    required this.autoFixable,
  });
  final String error;
  final String suggestion;
  final bool autoFixable;
}