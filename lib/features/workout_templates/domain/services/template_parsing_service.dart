/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// AI-powered service for parsing workout templates from natural language text
library;

import 'dart:convert';
import 'dart:math';

import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/import_parsing_result.dart';

/// AI parsing instructions
class AIParsingInstructions {
  const AIParsingInstructions({
    this.language,
    this.units,
    this.customExercises,
  });

  final String? language;
  final String? units;
  final List<String>? customExercises;
}

/// Import error
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

/// Import warning
class ImportWarning {
  const ImportWarning({
    required this.message,
    required this.field,
  });

  final String message;
  final String field;
}

/// Service for parsing workout templates from natural language descriptions
class TemplateParsingService {
  
  /// Parse workout template from natural language text
  /// 
  /// Supports Italian and English text formats like:
  /// "LUNEDÌ - PUSH (Petto/Spalle/Tricipiti)
  /// Panca Piana - 3-4 min
  /// Set1 x 5: 80kg
  /// Set2 x 5: 82.5kg"
  Future<ImportParsingResult> parseWorkoutText(
    String text, {
    AIParsingInstructions? instructions,
  }) async {
    final warnings = <ImportWarning>[];
    final errors = <ImportError>[];
    
    try {
      // Split text into sections by day/workout
      final workoutSections = _splitIntoWorkoutSections(text);
      
      if (workoutSections.isEmpty) {
        errors.add(const ImportError(
          message: 'No workout sections found in text',
          field: 'text',
          isBlocking: true,
        ));
        return ImportParsingResult(
          template: const WorkoutTemplateImportData(
            name: '',
            exercises: [],
            category: 'other',
          ),
          errors: errors,
        );
      }
      
      // Parse the first section (or combine if multiple)
      final firstSection = workoutSections.first;
      final workoutName = _extractWorkoutName(firstSection);
      final exercises = await _parseExercises(firstSection, warnings, errors);
      
      final template = WorkoutTemplateImportData(
        name: workoutName,
        description: _extractDescription(firstSection),
        exercises: exercises,
        category: _inferCategory(workoutName, exercises),
        difficulty: _inferDifficulty(exercises),
        estimatedDurationMinutes: _estimateDuration(exercises),
        tags: _extractTags(workoutName),
        requiredEquipment: _inferEquipment(exercises),
        targetMuscles: _inferTargetMuscles(workoutName, exercises),
      );
      
      return ImportParsingResult(
        template: template,
        warnings: warnings,
        errors: errors,
      );
    } catch (e) {
      errors.add(ImportError(
        message: 'Failed to parse workout: $e',
        field: 'parsing',
        isBlocking: true,
      ));

      return ImportParsingResult(
        template: const WorkoutTemplateImportData(
          name: '',
          exercises: [],
          category: 'other',
        ),
        errors: errors,
      );
    }
  }
  
  /// Parse multiple workout templates from text
  Future<List<ImportParsingResult>> parseMultipleWorkouts(
    String text, {
    AIParsingInstructions? instructions,
  }) async {
    final results = <ImportParsingResult>[];
    
    // Split text into individual workout sections
    final workoutSections = _splitIntoWorkoutSections(text);
    
    for (final section in workoutSections) {
      final result = await parseWorkoutText(section, instructions: instructions);
      results.add(result);
    }
    
    return results;
  }
  
  /// Split text into workout sections (by day names)
  List<String> _splitIntoWorkoutSections(String text) {
    final sections = <String>[];
    final lines = text.split('\n');
    
    var currentSection = <String>[];
    
    for (final line in lines) {
      if (_isWorkoutTitle(line.trim())) {
        // Save previous section if exists
        if (currentSection.isNotEmpty) {
          sections.add(currentSection.join('\n'));
        }
        // Start new section
        currentSection = [line];
      } else if (line.trim().isNotEmpty) {
        currentSection.add(line);
      }
    }
    
    // Add last section
    if (currentSection.isNotEmpty) {
      sections.add(currentSection.join('\n'));
    }
    
    return sections.where((s) => s.isNotEmpty).toList();
  }
  
  /// Check if line is a workout title (day name + muscle groups)
  bool _isWorkoutTitle(String line) {
    final dayPatterns = [
      r'LUNEDÌ|MONDAY|MON',
      r'MARTEDÌ|TUESDAY|TUE', 
      r'MERCOLEDÌ|WEDNESDAY|WED',
      r'GIOVEDÌ|THURSDAY|THU',
      r'VENERDÌ|FRIDAY|FRI',
      r'SABATO|SATURDAY|SAT',
      r'DOMENICA|SUNDAY|SUN',
      r'DAY\s*\d+',
      r'GIORNO\s*\d+',
      r'WORKOUT\s*\d*',
      r'ALLENAMENTO\s*\d*',
    ];
    
    final pattern = dayPatterns.join('|');
    return RegExp(pattern, caseSensitive: false).hasMatch(line);
  }
  
  /// Extract workout name from section
  String _extractWorkoutName(String section) {
    final lines = section.split('\n');
    final firstLine = lines.first.trim();
    
    // Clean up the title
    var name = firstLine
        .replaceAll(RegExp(r'^\w+\s*-\s*'), '') // Remove day prefix
        .replaceAll(RegExp(r'\([^)]*\)'), '') // Remove muscle group info
        .trim();
    
    if (name.isEmpty) {
      name = firstLine.split('-').first.trim();
    }
    
    return name.isEmpty ? 'Imported Workout' : name;
  }
  
  /// Extract description from section
  String? _extractDescription(String section) {
    final lines = section.split('\n');
    final firstLine = lines.first.trim();
    
    // Extract muscle group info from parentheses
    final muscleMatch = RegExp(r'\(([^)]+)\)').firstMatch(firstLine);
    return muscleMatch?.group(1);
  }
  
  /// Parse exercises from section
  Future<List<ExerciseImportData>> _parseExercises(
    String section,
    List<ImportWarning> warnings,
    List<ImportError> errors,
  ) async {
    final exercises = <ExerciseImportData>[];
    final lines = section.split('\n');
    
    var currentExercise = <String>[];
    
    for (int i = 1; i < lines.length; i++) { // Skip title line
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      if (_isExerciseName(line)) {
        // Process previous exercise
        if (currentExercise.isNotEmpty) {
          final exercise = await _parseExercise(currentExercise, warnings, errors);
          if (exercise != null) exercises.add(exercise);
        }
        // Start new exercise
        currentExercise = [line];
      } else {
        currentExercise.add(line);
      }
    }
    
    // Process last exercise
    if (currentExercise.isNotEmpty) {
      final exercise = await _parseExercise(currentExercise, warnings, errors);
      if (exercise != null) exercises.add(exercise);
    }
    
    return exercises;
  }
  
  /// Check if line is an exercise name
  bool _isExerciseName(String line) {
    // Exercise names usually don't start with "Set" or numbers
    if (RegExp(r'^(Set\d+|Superset|Round)', caseSensitive: false).hasMatch(line)) {
      return false;
    }
    
    // Usually contain exercise-like keywords or end with rest time
    return RegExp(r'(-\s*\d+(-\d+)?\s*(min|sec|secondi|minuti))|'
                  r'(press|curl|squat|deadlift|panca|stacco|curl|alzate)',
                  caseSensitive: false).hasMatch(line);
  }
  
  /// Parse individual exercise
  Future<ExerciseImportData?> _parseExercise(
    List<String> exerciseLines,
    List<ImportWarning> warnings,
    List<ImportError> errors,
  ) async {
    if (exerciseLines.isEmpty) return null;
    
    final firstLine = exerciseLines.first;
    final exerciseName = _extractExerciseName(firstLine);
    final restTime = _extractRestTime(firstLine);
    
    final sets = <SetImportData>[];
    
    // Parse sets from remaining lines
    for (int i = 1; i < exerciseLines.length; i++) {
      final line = exerciseLines[i].trim();
      final setData = _parseSet(line, i);
      if (setData != null) {
        sets.add(setData);
      }
    }
    
    if (sets.isEmpty) {
      warnings.add(ImportWarning(
        message: 'No sets found for exercise: $exerciseName',
        field: 'sets',
        context: {'exercise': exerciseName},
      ));
    }
    
    return ExerciseImportData(
      name: exerciseName,
      category: 'other', // Default category, could be inferred from exercise name
      type: 'single', // Default type for imported exercises
      sets: sets,
      notes: null,
      restTimeSeconds: restTime,
    );
  }
  
  /// Extract exercise name from line
  String _extractExerciseName(String line) {
    // Remove rest time info
    final name = line.replaceAll(RegExp(r'\s*-\s*\d+(-\d+)?\s*(min|sec|secondi|minuti).*$'), '').trim();
    
    return name.isEmpty ? 'Unknown Exercise' : name;
  }
  
  /// Extract rest time in seconds
  int? _extractRestTime(String line) {
    // Match patterns like "2-3 min", "90 sec", "3 min"
    final timeMatch = RegExp(r'(\d+)(?:-\d+)?\s*(min|sec|secondi|minuti)', 
                            caseSensitive: false).firstMatch(line);
    
    if (timeMatch != null) {
      final value = int.tryParse(timeMatch.group(1)!) ?? 0;
      final unit = timeMatch.group(2)!.toLowerCase();
      
      if (unit.startsWith('min')) {
        return value * 60; // Convert to seconds
      } else {
        return value; // Already in seconds
      }
    }
    
    return null;
  }
  
  /// Extract rest time string as is
  String? _extractRestTimeString(String line) {
    final timeMatch = RegExp(r'(\d+(?:-\d+)?\s*(?:min|sec|secondi|minuti))', 
                            caseSensitive: false).firstMatch(line);
    return timeMatch?.group(1);
  }
  
  /// Parse individual set
  SetImportData? _parseSet(String line, int setNumber) {
    // Match patterns like "Set1 x 5: 80kg", "Set2 x 8: -20kg assist"
    final setMatch = RegExp(r'Set(\d+)\s*x\s*(\d+(?:-\d+)?)\s*:\s*(.+)', 
                           caseSensitive: false).firstMatch(line);
    
    if (setMatch != null) {
      final number = int.tryParse(setMatch.group(1)!) ?? setNumber;
      final reps = setMatch.group(2)!;
      final weightAndNotes = setMatch.group(3)!.trim();
      
      // Split weight and notes
      final parts = weightAndNotes.split(' ');
      final weight = parts.first;
      final notes = parts.length > 1 ? parts.skip(1).join(' ') : null;
      
      return SetImportData(
        setNumber: number,
        weight: weight,
        reps: reps,
        notes: notes,
      );
    }
    
    return null;
  }
  
  /// Infer workout category from name and exercises
  String? _inferCategory(String name, List<ExerciseImportData> exercises) {
    final nameUpper = name.toUpperCase();
    
    if (nameUpper.contains('PUSH') || nameUpper.contains('PETTO')) return 'strength';
    if (nameUpper.contains('PULL') || nameUpper.contains('DORSO')) return 'strength';
    if (nameUpper.contains('LEGS') || nameUpper.contains('GAMBE')) return 'strength';
    if (nameUpper.contains('ARMS') || nameUpper.contains('BRACCIA')) return 'hypertrophy';
    if (nameUpper.contains('CARDIO')) return 'cardio';
    
    return 'strength'; // Default
  }
  
  /// Infer difficulty from exercise complexity and volume
  String? _inferDifficulty(List<ExerciseImportData> exercises) {
    if (exercises.isEmpty) return 'beginner';
    
    final totalSets = exercises.fold(0, (sum, ex) => sum + ex.sets.length);
    
    if (totalSets <= 15) return 'beginner';
    if (totalSets <= 25) return 'intermediate';
    return 'advanced';
  }
  
  /// Estimate workout duration
  int? _estimateDuration(List<ExerciseImportData> exercises) {
    if (exercises.isEmpty) return null;
    
    var totalMinutes = 0;
    
    for (final exercise in exercises) {
      // Add set time (assume 1 min per set)
      totalMinutes += exercise.sets.length;
      
      // Add rest time
      if (exercise.restTimeSeconds != null) {
        totalMinutes += (exercise.restTimeSeconds! / 60).ceil() * (exercise.sets.length - 1);
      } else {
        totalMinutes += 2 * (exercise.sets.length - 1); // Default 2 min rest
      }
    }
    
    return totalMinutes;
  }
  
  /// Extract tags from workout name
  List<String> _extractTags(String name) {
    final tags = <String>[];
    final nameUpper = name.toUpperCase();
    
    if (nameUpper.contains('PUSH')) tags.add('push');
    if (nameUpper.contains('PULL')) tags.add('pull');
    if (nameUpper.contains('LEGS')) tags.add('legs');
    if (nameUpper.contains('ARMS')) tags.add('arms');
    if (nameUpper.contains('CHEST') || nameUpper.contains('PETTO')) tags.add('chest');
    if (nameUpper.contains('BACK') || nameUpper.contains('DORSO')) tags.add('back');
    if (nameUpper.contains('SHOULDERS') || nameUpper.contains('SPALLE')) tags.add('shoulders');
    
    return tags;
  }
  
  /// Infer required equipment from exercises
  List<String> _inferEquipment(List<ExerciseImportData> exercises) {
    final equipment = <String>{};
    
    for (final exercise in exercises) {
      final nameUpper = exercise.name.toUpperCase();
      
      if (nameUpper.contains('BARBELL') || nameUpper.contains('BILANCIERE')) {
        equipment.add('barbell');
      }
      if (nameUpper.contains('DUMBBELL') || nameUpper.contains('MANUBR')) {
        equipment.add('dumbbells');
      }
      if (nameUpper.contains('CABLE') || nameUpper.contains('CAVO')) {
        equipment.add('cables');
      }
      if (nameUpper.contains('MACHINE') || nameUpper.contains('MACCHINA')) {
        equipment.add('machines');
      }
    }
    
    return equipment.toList();
  }
  
  /// Infer target muscles from name and exercises
  List<String> _inferTargetMuscles(String name, List<ExerciseImportData> exercises) {
    final muscles = <String>{};
    final fullText = '$name ${exercises.map((e) => e.name).join(' ')}';
    final textUpper = fullText.toUpperCase();
    
    if (textUpper.contains('CHEST') || textUpper.contains('PETTO') || textUpper.contains('BENCH')) {
      muscles.add('chest');
    }
    if (textUpper.contains('BACK') || textUpper.contains('DORSO') || textUpper.contains('LAT')) {
      muscles.add('back');
    }
    if (textUpper.contains('SHOULDERS') || textUpper.contains('SPALLE') || textUpper.contains('PRESS')) {
      muscles.add('shoulders');
    }
    if (textUpper.contains('LEGS') || textUpper.contains('GAMBE') || textUpper.contains('SQUAT')) {
      muscles.add('legs');
    }
    if (textUpper.contains('ARMS') || textUpper.contains('BRACCIA') || textUpper.contains('CURL')) {
      muscles.add('arms');
    }
    
    return muscles.toList();
  }
}