/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Service for automatic error recovery and fallback handling during template import
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/recovery_result.dart';

/// Service for handling import errors with automatic recovery and fallbacks
class ImportErrorRecoveryService {
  
  /// Attempt to recover from JSON parsing errors
  Future<RecoveryResult<String>> recoverFromJsonError(
    String originalJson,
    dynamic error,
  ) async {
    final fixes = <String>[];
    var recoveredJson = originalJson;
    
    try {
      // Common JSON fixes
      if (error.toString().contains('Unexpected character')) {
        recoveredJson = _fixCommonJsonCharacterErrors(recoveredJson);
        fixes.add('Fixed character encoding issues');
      }
      
      if (error.toString().contains('Unterminated string')) {
        recoveredJson = _fixUnterminatedStrings(recoveredJson);
        fixes.add('Fixed unterminated strings');
      }
      
      // Try to fix trailing commas
      recoveredJson = _fixTrailingCommas(recoveredJson);
      fixes.add('Removed trailing commas');
      
      // Try to fix missing quotes
      recoveredJson = _fixMissingQuotes(recoveredJson);
      fixes.add('Added missing quotes');
      
      // Try to parse again
      json.decode(recoveredJson);
      
      return RecoveryResult.success(
        data: recoveredJson,
        appliedFixes: fixes,
        confidence: 0.8,
      );
      
    } catch (e) {
      // If still failing, try more aggressive fixes
      return await _attemptAggressiveJsonRecovery(originalJson, fixes);
    }
  }
  
  /// Attempt to recover from template parsing errors
  /// TODO: Uncomment when WorkoutTemplateImportData is defined
  /*
  Future<RecoveryResult<WorkoutTemplateImportData>> recoverFromTemplateError(
    WorkoutTemplateImportData template,
    List<String> errors,
  ) async {
    final fixes = <String>[];
    var recoveredTemplate = template;
    
    for (final error in errors) {
      if (error.contains('name is required') || error.contains('name is empty')) {
        recoveredTemplate = recoveredTemplate.copyWith(
          name: _generateDefaultTemplateName(template),
        );
        fixes.add('Generated default template name');
      }
      
      if (error.contains('must have at least one exercise')) {
        recoveredTemplate = recoveredTemplate.copyWith(
          exercises: [_createDefaultExercise()],
        );
        fixes.add('Added placeholder exercise');
      }
      
      if (error.contains('invalid weight') || error.contains('invalid reps')) {
        final fixedExercises = recoveredTemplate.exercises
            .map((exercise) => _fixExerciseSets(exercise))
            .toList();
        recoveredTemplate = recoveredTemplate.copyWith(exercises: fixedExercises);
        fixes.add('Fixed invalid set values');
      }
    }
    
    // Final validation
    final validation = ImportValidationUtils.validateWorkoutTemplate(recoveredTemplate);
    
    return RecoveryResult.success(
      data: recoveredTemplate,
      appliedFixes: fixes,
      confidence: validation.isValid ? 0.9 : 0.6,
      remainingIssues: validation.errors,
    );
  }
  */
  
  /// Attempt to recover from text parsing errors
  Future<RecoveryResult<String>> recoverFromTextParsingError(
    String originalText,
    List<String> errors,
  ) async {
    final fixes = <String>[];
    var recoveredText = originalText;
    
    // Fix common text formatting issues
    recoveredText = _fixTextFormatting(recoveredText);
    fixes.add('Fixed text formatting');
    
    // Fix common exercise name issues
    recoveredText = _fixCommonExerciseNames(recoveredText);
    fixes.add('Fixed exercise name variations');
    
    // Fix set notation issues
    recoveredText = _fixSetNotation(recoveredText);
    fixes.add('Fixed set notation format');
    
    // Fix weight notation issues
    recoveredText = _fixWeightNotation(recoveredText);
    fixes.add('Fixed weight notation');
    
    // Add missing set information if needed
    if (errors.any((e) => e.contains('no set information'))) {
      recoveredText = _addMissingSetInformation(recoveredText);
      fixes.add('Added missing set information');
    }
    
    return RecoveryResult.success(
      data: recoveredText,
      appliedFixes: fixes,
      confidence: 0.7,
    );
  }
  
  /// Attempt to recover from exercise disambiguation errors
  /// TODO: Uncomment when ExerciseDisambiguation is defined
  /*
  Future<RecoveryResult<ExerciseDisambiguation>> recoverFromDisambiguationError(
    ExerciseDisambiguation disambiguation,
  ) async {
    final fixes = <String>[];
    
    if (disambiguation.options.isEmpty) {
      // Create fallback options based on exercise name
      final fallbackOptions = _createFallbackExerciseOptions(disambiguation.originalName);
      
      final recovered = disambiguation.copyWith(
        options: fallbackOptions,
        selectedOptionIndex: 0, // Auto-select first option
      );
      
      fixes.add('Generated fallback exercise options');
      fixes.add('Auto-selected best match');
      
      return RecoveryResult.success(
        data: recovered,
        appliedFixes: fixes,
        confidence: 0.5, // Low confidence for fallback
      );
    }
    
    // If options exist but none selected, auto-select best option
    if (disambiguation.selectedOptionIndex == null && disambiguation.options.isNotEmpty) {
      final bestOptionIndex = _findBestExerciseMatch(disambiguation.options);
      
      final recovered = disambiguation.copyWith(
        selectedOptionIndex: bestOptionIndex,
      );
      
      fixes.add('Auto-selected best matching exercise');
      
      return RecoveryResult.success(
        data: recovered,
        appliedFixes: fixes,
        confidence: 0.8,
      );
    }
    
    return RecoveryResult.noRecoveryNeeded(disambiguation);
  }
  */

  /// Attempt to recover from percentage conversion errors
  /// TODO: Uncomment when PercentageConversion is defined
  /*
  Future<RecoveryResult<PercentageConversion>> recoverFromPercentageError(
    PercentageConversion conversion,
  ) async {
    final fixes = <String>[];
    var recovered = conversion;
    
    // Fix invalid percentage values
    if (conversion.percentage < 0 || conversion.percentage > 200) {
      final fixedPercentage = conversion.percentage.clamp(50.0, 100.0);
      recovered = recovered.copyWith(percentage: fixedPercentage);
      fixes.add('Fixed invalid percentage to ${fixedPercentage.toInt()}%');
    }
    
    // Provide default estimated max if missing or invalid
    if (conversion.estimatedMax == null || conversion.estimatedMax! <= 0) {
      final defaultMax = _getDefaultMaxForExercise(conversion.exerciseName);
      recovered = recovered.copyWith(estimatedMax: defaultMax);
      fixes.add('Used default estimated max (${defaultMax}kg)');
    }
    
    // Recalculate weight with corrected values
    if (recovered.estimatedMax != null) {
      final calculatedWeight = recovered.estimatedMax! * recovered.percentage / 100;
      recovered = recovered.copyWith(calculatedWeight: calculatedWeight);
      fixes.add('Recalculated weight (${calculatedWeight.toStringAsFixed(1)}kg)');
    }
    
    return RecoveryResult.success(
      data: recovered,
      appliedFixes: fixes,
      confidence: 0.7,
    );
  }
  */

  /// Generate recovery suggestions for unrecoverable errors
  /// TODO: Uncomment when RecoverySuggestion is defined
  /*
  List<RecoverySuggestion> generateRecoverySuggestions(
    List<String> errors,
    String context,
  ) {
    final suggestions = <RecoverySuggestion>[];
    
    for (final error in errors) {
      if (error.contains('JSON')) {
        suggestions.add(RecoverySuggestion(
          error: error,
          suggestion: 'Check JSON format - ensure proper quotes, commas, and brackets',
          action: RecoveryAction.manualFix,
          priority: RecoveryPriority.high,
        ));
      } else if (error.contains('empty')) {
        suggestions.add(RecoverySuggestion(
          error: error,
          suggestion: 'Provide missing required information',
          action: RecoveryAction.userInput,
          priority: RecoveryPriority.medium,
        ));
      } else if (error.contains('invalid')) {
        suggestions.add(RecoverySuggestion(
          error: error,
          suggestion: 'Check numeric values and data formats',
          action: RecoveryAction.autoFix,
          priority: RecoveryPriority.medium,
        ));
      } else if (error.contains('no set information')) {
        suggestions.add(RecoverySuggestion(
          error: error,
          suggestion: 'Add set information in format: Set1 x 5: 80kg',
          action: RecoveryAction.templateFix,
          priority: RecoveryPriority.high,
        ));
      }
    }
    
    return suggestions;
  }
  */

  // Private helper methods
  
  Future<RecoveryResult<String>> _attemptAggressiveJsonRecovery(
    String originalJson,
    List<String> previousFixes,
  ) async {
    final fixes = List<String>.from(previousFixes);
    var recoveredJson = originalJson;
    
    try {
      // Try to extract valid JSON objects/arrays from the text
      recoveredJson = _extractJsonFromText(recoveredJson);
      fixes.add('Extracted JSON from mixed content');
      
      json.decode(recoveredJson);
      
      return RecoveryResult.success(
        data: recoveredJson,
        appliedFixes: fixes,
        confidence: 0.5, // Low confidence for aggressive recovery
      );
      
    } catch (e) {
      return RecoveryResult.failed(
        originalData: originalJson,
        error: 'Unable to recover JSON: ${e.toString()}',
        attemptedFixes: fixes,
      );
    }
  }
  
  String _fixCommonJsonCharacterErrors(String json) {
    return json
        .replaceAll('“', '"')  // Fix smart quotes
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('…', '...')
        .replaceAll(RegExp(r'[\u00A0\u2028\u2029]'), ' '); // Fix non-breaking spaces
  }
  
  String _fixUnterminatedStrings(String json) {
    final lines = json.split('\n');
    final fixedLines = <String>[];
    
    for (final line in lines) {
      var fixedLine = line;
      
      // Count quotes to detect unterminated strings
      final quoteCount = line.split('"').length - 1;
      if (quoteCount % 2 != 0) {
        // Odd number of quotes - likely unterminated
        fixedLine = '$line"';
      }
      
      fixedLines.add(fixedLine);
    }
    
    return fixedLines.join('\n');
  }
  
  String _fixTrailingCommas(String json) {
    return json.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
  }
  
  String _fixMissingQuotes(String json) {
    // Fix unquoted object keys
    return json.replaceAll(RegExp(r'(\w+):\s*'), r'"$1": ');
  }
  
  String _extractJsonFromText(String text) {
    // Try to find JSON objects or arrays in mixed content
    final jsonPattern = RegExp(r'(\{.*\}|\[.*\])', dotAll: true);
    final match = jsonPattern.firstMatch(text);
    return match?.group(1) ?? text;
  }

  /// TODO: Uncomment all helper methods when import data classes are defined
  /*
  String _generateDefaultTemplateName(WorkoutTemplateImportData template) {
    if (template.exercises.isNotEmpty) {
      final firstExercise = template.exercises.first.name;
      if (firstExercise.isNotEmpty) {
        return 'Workout with $firstExercise';
      }
    }
    
    return 'Imported Workout ${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
  
  ExerciseImportData _createDefaultExercise() {
    return const ExerciseImportData(
      name: 'Exercise',
      sets: [
        SetImportData(
          setNumber: 1,
          reps: '8',
          weight: '50kg',
        ),
      ],
    );
  }
  
  ExerciseImportData _fixExerciseSets(ExerciseImportData exercise) {
    final fixedSets = exercise.sets.map((set) {
      var fixedSet = set;
      
      // Fix invalid weight
      if (set.weight != null) {
        final weightValue = _extractNumericValue(set.weight!);
        if (weightValue == null || weightValue <= 0) {
          fixedSet = fixedSet.copyWith(weight: '50kg');
        }
      }
      
      // Fix invalid reps
      if (set.reps != null) {
        final repsValue = _extractNumericValue(set.reps!);
        if (repsValue == null || repsValue <= 0) {
          fixedSet = fixedSet.copyWith(reps: '8');
        }
      }
      
      return fixedSet;
    }).toList();
    
    return exercise.copyWith(sets: fixedSets);
  }
  
  String _fixTextFormatting(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'^\s+', multiLine: true), '') // Remove leading spaces
        .trim();
  }
  
  String _fixCommonExerciseNames(String text) {
    final commonFixes = {
      // Italian to English standardization
      'panca piana': 'bench press',
      'squat back': 'back squat', 
      'stacco da terra': 'deadlift',
      'panca inclinata': 'incline bench press',
      'rematore': 'barbell row',
      'alzate laterali': 'lateral raises',
      'french press': 'tricep extension',
      
      // Common typos
      'benchpress': 'bench press',
      'dead lift': 'deadlift',
      'lat pull down': 'lat pulldown',
    };
    
    var fixedText = text;
    for (final entry in commonFixes.entries) {
      fixedText = fixedText.replaceAll(
        RegExp(entry.key, caseSensitive: false),
        entry.value,
      );
    }
    
    return fixedText;
  }
  
  String _fixSetNotation(String text) {
    // Standardize set notation to "Set1 x 5: 80kg" format
    return text.replaceAll(
      RegExp(r'Set\s*(\d+)\s*[x×]\s*(\d+)\s*[:=]\s*'),
      'Set\$1 x \$2: ',
    );
  }
  
  String _fixWeightNotation(String text) {
    return text
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*kgs?'), '\$1kg')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*lbs?'), '\$1lb');
  }
  
  String _addMissingSetInformation(String text) {
    final lines = text.split('\n');
    final enhancedLines = <String>[];
    
    for (final line in lines) {
      enhancedLines.add(line);
      
      // If this looks like an exercise name, add sample sets
      if (_looksLikeExerciseName(line) && !_hasFollowingSet(lines, lines.indexOf(line))) {
        enhancedLines.add('Set1 x 8: 50kg');
        enhancedLines.add('Set2 x 8: 50kg');
        enhancedLines.add('Set3 x 8: 50kg');
      }
    }
    
    return enhancedLines.join('\n');
  }
  
  bool _looksLikeExerciseName(String line) {
    return line.trim().isNotEmpty &&
           !line.toLowerCase().startsWith('set') &&
           !RegExp(r'^\w+DAY|^\w+DÌ', caseSensitive: false).hasMatch(line);
  }
  
  bool _hasFollowingSet(List<String> lines, int exerciseIndex) {
    if (exerciseIndex + 1 >= lines.length) return false;
    final nextLine = lines[exerciseIndex + 1];
    return RegExp(r'Set\d+', caseSensitive: false).hasMatch(nextLine);
  }
  
  List<ExerciseOption> _createFallbackExerciseOptions(String originalName) {
    // Create generic options based on common exercise patterns
    final options = <ExerciseOption>[];
    
    final nameUpper = originalName.toUpperCase();
    if (nameUpper.contains('PRESS') || nameUpper.contains('PANCA')) {
      options.add(ExerciseOption(
        id: 'fallback_bench_press',
        name: 'Bench Press',
        category: 'chest',
        primaryMuscleGroups: ['chest', 'triceps', 'shoulders'],
        matchConfidence: 0.6,
      ));
    } else if (nameUpper.contains('SQUAT')) {
      options.add(ExerciseOption(
        id: 'fallback_squat',
        name: 'Back Squat',
        category: 'legs',
        primaryMuscleGroups: ['quadriceps', 'glutes'],
        matchConfidence: 0.6,
      ));
    } else {
      // Generic fallback
      options.add(ExerciseOption(
        id: 'fallback_generic',
        name: originalName,
        category: 'other',
        primaryMuscleGroups: ['unknown'],
        matchConfidence: 0.3,
      ));
    }
    
    return options;
  }
  
  int _findBestExerciseMatch(List<ExerciseOption> options) {
    var bestIndex = 0;
    var bestConfidence = 0.0;
    
    for (int i = 0; i < options.length; i++) {
      final confidence = options[i].matchConfidence ?? 0.0;
      if (confidence > bestConfidence) {
        bestConfidence = confidence;
        bestIndex = i;
      }
    }
    
    return bestIndex;
  }
  
  double _getDefaultMaxForExercise(String exerciseName) {
    final nameUpper = exerciseName.toUpperCase();
    
    // Default 1RM estimates for common exercises (conservative values)
    if (nameUpper.contains('BENCH') || nameUpper.contains('PANCA')) return 80.0;
    if (nameUpper.contains('SQUAT')) return 100.0;
    if (nameUpper.contains('DEADLIFT') || nameUpper.contains('STACCO')) return 120.0;
    if (nameUpper.contains('PRESS') && nameUpper.contains('SHOULDER')) return 50.0;
    if (nameUpper.contains('ROW') || nameUpper.contains('REMATORE')) return 70.0;
    
    return 60.0; // Generic default
  }
  
  double? _extractNumericValue(String input) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(input);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}

/// Result of an error recovery attempt
class RecoveryResult<T> {
  final T data;
  final bool wasRecovered;
  final List<String> appliedFixes;
  final double confidence;
  final String? error;
  final List<String> remainingIssues;
  
  RecoveryResult._({
    required this.data,
    required this.wasRecovered,
    this.appliedFixes = const [],
    this.confidence = 1.0,
    this.error,
    this.remainingIssues = const [],
  });
  
  factory RecoveryResult.success({
    required T data,
    required List<String> appliedFixes,
    required double confidence,
    List<String> remainingIssues = const [],
  }) {
    return RecoveryResult._(
      data: data,
      wasRecovered: true,
      appliedFixes: appliedFixes,
      confidence: confidence,
      remainingIssues: remainingIssues,
    );
  }
  
  factory RecoveryResult.failed({
    required T originalData,
    required String error,
    List<String> attemptedFixes = const [],
  }) {
    return RecoveryResult._(
      data: originalData,
      wasRecovered: false,
      appliedFixes: attemptedFixes,
      confidence: 0.0,
      error: error,
    );
  }
  
  factory RecoveryResult.noRecoveryNeeded(T data) {
    return RecoveryResult._(
      data: data,
      wasRecovered: false,
      confidence: 1.0,
    );
  }
  
  bool get isSuccess => error == null;
  bool get hasRemainingIssues => remainingIssues.isNotEmpty;
}

/// Suggestion for recovering from an error
class RecoverySuggestion {
  final String error;
  final String suggestion;
  final RecoveryAction action;
  final RecoveryPriority priority;
  
  RecoverySuggestion({
    required this.error,
    required this.suggestion,
    required this.action,
    required this.priority,
  });
}

/// Types of recovery actions
enum RecoveryAction {
  autoFix,    // Can be automatically fixed
  userInput,  // Requires user input
  manualFix,  // Requires manual editing
  templateFix, // Requires template modification
}

/// Priority levels for recovery
enum RecoveryPriority {
  low,
  medium,
  high,
  critical,
}
*/
}