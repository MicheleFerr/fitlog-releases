/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain/services
/// 🎯 Feature: workout
/// 🔧 Type: service
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Domain entities
/// - File system access
/// - JSON/CSV parsing
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

/// Opzioni per l'import
class ImportOptions {
  
  ImportOptions({
    this.overwriteExisting = false,
    this.mergeWithExisting = false,
    this.validateData = true,
    this.skipInvalidRows = true,
    this.defaultWorkoutName,
  });
  final bool overwriteExisting;
  final bool mergeWithExisting;
  final bool validateData;
  final bool skipInvalidRows;
  final String? defaultWorkoutName;
}

/// Service per importare workout da vari formati
class WorkoutImportService {
  final _uuid = const Uuid();
  
  /// Importa workout da file selezionato dall'utente
  Future<ImportResult> importFromFile({
    ImportOptions? options,
  }) async {
    options ??= ImportOptions();
    
    try {
      // Seleziona file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return ImportResult(
          success: false,
          message: 'No file selected',
        );
      }
      
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final extension = result.files.single.extension?.toLowerCase();
      
      // Importa in base al formato
      if (extension == 'json') {
        return await importFromJson(content, options);
      } else if (extension == 'csv') {
        return await importFromCsv(content, options);
      } else {
        return ImportResult(
          success: false,
          message: 'Unsupported file format',
        );
      }
      
    } catch (e) {
      debugPrint('Import failed: $e');
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
      );
    }
  }
  
  /// Importa da JSON
  Future<ImportResult> importFromJson(String jsonContent, ImportOptions options) async {
    try {
      final data = jsonDecode(jsonContent);
      
      // Verifica formato
      if (!_isValidJsonFormat(data)) {
        // Prova formato legacy o altri formati
        return _importLegacyJson(data, options);
      }
      
      final List<Workout> importedWorkouts = [];
      final List<String> errors = [];
      
      // Importa ogni workout
      final workouts = data['workouts'] as List;
      for (var i = 0; i < workouts.length; i++) {
        try {
          final workoutJson = workouts[i];
          
          // Valida dati se richiesto
          if (options.validateData && !_validateWorkoutJson(workoutJson)) {
            if (options.skipInvalidRows) {
              errors.add('Skipped invalid workout at index $i');
              continue;
            } else {
              return ImportResult(
                success: false,
                message: 'Invalid workout data at index $i',
              );
            }
          }
          
          // Crea workout entity
          final workout = _createWorkoutFromJson(workoutJson, options);
          importedWorkouts.add(workout);
          
        } catch (e) {
          if (options.skipInvalidRows) {
            errors.add('Failed to import workout $i: $e');
          } else {
            rethrow;
          }
        }
      }
      
      return ImportResult(
        success: true,
        message: 'Imported ${importedWorkouts.length} workouts',
        workouts: importedWorkouts,
        errors: errors.isNotEmpty ? errors : null,
      );
      
    } catch (e) {
      debugPrint('JSON import failed: $e');
      return ImportResult(
        success: false,
        message: 'Invalid JSON format: $e',
      );
    }
  }
  
  /// Importa da CSV
  Future<ImportResult> importFromCsv(String csvContent, ImportOptions options) async {
    try {
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);
      
      if (rows.isEmpty) {
        return ImportResult(
          success: false,
          message: 'Empty CSV file',
        );
      }
      
      // Parse header
      final headers = rows.first.map((h) => h.toString().toLowerCase()).toList();
      final dateIndex = headers.indexOf('workout date');
      final nameIndex = headers.indexOf('workout name');
      final exerciseIndex = headers.indexOf('exercise');
      final setIndex = headers.indexOf('set');
      final weightIndex = headers.indexOf('weight');
      final repsIndex = headers.indexOf('reps');
      final rpeIndex = headers.indexOf('rpe');
      final notesIndex = headers.indexOf('notes');
      
      if (dateIndex == -1 || exerciseIndex == -1 || weightIndex == -1 || repsIndex == -1) {
        return ImportResult(
          success: false,
          message: 'Missing required CSV columns',
        );
      }
      
      // Raggruppa per workout
      final Map<String, List<Map<String, dynamic>>> workoutGroups = {};
      final List<String> errors = [];
      
      for (var i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];
          if (row.length <= exerciseIndex) continue;
          
          final workoutKey = '${row[dateIndex]}_${nameIndex >= 0 ? row[nameIndex] : 'Workout'}';
          
          if (!workoutGroups.containsKey(workoutKey)) {
            workoutGroups[workoutKey] = [];
          }
          
          workoutGroups[workoutKey]!.add({
            'date': row[dateIndex].toString(),
            'name': nameIndex >= 0 ? row[nameIndex].toString() : options.defaultWorkoutName ?? 'Imported Workout',
            'exercise': row[exerciseIndex].toString(),
            'set': setIndex >= 0 ? int.tryParse(row[setIndex].toString()) ?? 1 : 1,
            'weight': double.tryParse(row[weightIndex].toString()) ?? 0.0,
            'reps': int.tryParse(row[repsIndex].toString()) ?? 0,
            'rpe': rpeIndex >= 0 && rpeIndex < row.length ? int.tryParse(row[rpeIndex].toString()) : null,
            'notes': notesIndex >= 0 && notesIndex < row.length ? row[notesIndex].toString() : null,
          });
          
        } catch (e) {
          if (options.skipInvalidRows) {
            errors.add('Failed to parse row $i: $e');
          } else {
            rethrow;
          }
        }
      }
      
      // Crea workout entities
      final List<Workout> importedWorkouts = [];
      
      for (final entry in workoutGroups.entries) {
        try {
          final workout = _createWorkoutFromCsvGroup(entry.key, entry.value, options);
          importedWorkouts.add(workout);
        } catch (e) {
          errors.add('Failed to create workout ${entry.key}: $e');
        }
      }
      
      return ImportResult(
        success: true,
        message: 'Imported ${importedWorkouts.length} workouts from CSV',
        workouts: importedWorkouts,
        errors: errors.isNotEmpty ? errors : null,
      );
      
    } catch (e) {
      debugPrint('CSV import failed: $e');
      return ImportResult(
        success: false,
        message: 'CSV import failed: $e',
      );
    }
  }
  
  /// Valida formato JSON
  bool _isValidJsonFormat(dynamic data) {
    if (data is! Map) return false;
    return data.containsKey('workouts') && data['workouts'] is List;
  }
  
  /// Importa formato JSON legacy o custom
  ImportResult _importLegacyJson(dynamic data, ImportOptions options) {
    try {
      final List<Workout> importedWorkouts = [];
      
      // Prova a interpretare come array di workout diretti
      if (data is List) {
        for (final workoutData in data) {
          final workout = _createWorkoutFromJson(workoutData, options);
          importedWorkouts.add(workout);
        }
      }
      // O come singolo workout
      else if (data is Map && data.containsKey('exercises')) {
        final workout = _createWorkoutFromJson(data as Map<String, dynamic>, options);
        importedWorkouts.add(workout);
      } else {
        return ImportResult(
          success: false,
          message: 'Unrecognized JSON format',
        );
      }
      
      return ImportResult(
        success: true,
        message: 'Imported ${importedWorkouts.length} workouts (legacy format)',
        workouts: importedWorkouts,
      );
      
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Failed to import legacy format: $e',
      );
    }
  }
  
  /// Valida dati workout JSON
  bool _validateWorkoutJson(Map<String, dynamic> json) {
    // Validazioni base
    if (!json.containsKey('name') || json['name'].toString().isEmpty) {
      return false;
    }
    
    if (!json.containsKey('exercises') || json['exercises'] is! List) {
      return false;
    }
    
    // Valida esercizi
    for (final exercise in json['exercises']) {
      if (exercise is! Map || !exercise.containsKey('name')) {
        return false;
      }
      
      if (exercise.containsKey('sets') && exercise['sets'] is List) {
        for (final set in exercise['sets']) {
          if (set is! Map) return false;
          // Validazioni set opzionali
        }
      }
    }
    
    return true;
  }
  
  /// Crea workout da JSON
  Workout _createWorkoutFromJson(Map<String, dynamic> json, ImportOptions options) {
    // Genera nuovo ID se import (non merge)
    final workoutId = options.mergeWithExisting && json.containsKey('id') 
        ? json['id'] 
        : _uuid.v4();
    
    return Workout(
      id: workoutId,
      name: json['name'] ?? options.defaultWorkoutName ?? 'Imported Workout',
      exercises: _parseExercises(json['exercises'] ?? []),
      status: _parseWorkoutStatus(json['status']),
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Parse esercizi da JSON
  List<Exercise> _parseExercises(List exercisesJson) {
    final exercises = <Exercise>[];
    
    for (final exerciseJson in exercisesJson) {
      try {
        final exercise = Exercise(
          id: _uuid.v4(), // Sempre nuovo ID per esercizi
          name: exerciseJson['name'] ?? 'Unknown Exercise',
          type: _parseExerciseType(exerciseJson['type']),
          category: _parseExerciseCategory(exerciseJson['category']),
          sets: _parseSets(exerciseJson['sets'] ?? []),
          notes: exerciseJson['notes'],
          restTime: exerciseJson['restTimeSeconds'],
          // Note: isCompleted is a computed getter based on sets completion
          // isSkipped and skipReason are not part of Exercise entity
        );
        exercises.add(exercise);
      } catch (e) {
        debugPrint('Failed to parse exercise: $e');
        // Skip invalid exercise
      }
    }
    
    return exercises;
  }
  
  /// Parse sets da JSON
  List<ExerciseSet> _parseSets(List setsJson) {
    final sets = <ExerciseSet>[];
    
    for (var i = 0; i < setsJson.length; i++) {
      final setJson = setsJson[i];
      try {
        final set = ExerciseSet(
          id: _uuid.v4(),
          setNumber: setJson['setNumber'] ?? (i + 1),
          weight: (setJson['weight'] as num?)?.toDouble() ?? 0.0,
          reps: setJson['reps'] ?? 0,
          actualReps: setJson['actualReps'],
          rpe: setJson['rpe'],
          isCompleted: setJson['isCompleted'] ?? false,
          notes: setJson['notes'],
          restTime: setJson['restTimeSeconds'],
          isWarmup: setJson['isWarmup'] ?? false,
        );
        sets.add(set);
      } catch (e) {
        debugPrint('Failed to parse set: $e');
      }
    }
    
    return sets;
  }
  
  /// Crea workout da gruppo CSV
  Workout _createWorkoutFromCsvGroup(
    String key, 
    List<Map<String, dynamic>> rows,
    ImportOptions options,
  ) {
    final firstRow = rows.first;
    final workoutName = firstRow['name'] ?? options.defaultWorkoutName ?? 'Imported Workout';
    
    // Raggruppa per esercizio
    final Map<String, List<Map<String, dynamic>>> exerciseGroups = {};
    
    for (final row in rows) {
      final exerciseName = row['exercise'];
      if (!exerciseGroups.containsKey(exerciseName)) {
        exerciseGroups[exerciseName] = [];
      }
      exerciseGroups[exerciseName]!.add(row);
    }
    
    // Crea esercizi
    final exercises = <Exercise>[];
    
    for (final entry in exerciseGroups.entries) {
      final sets = <ExerciseSet>[];
      
      for (final setData in entry.value) {
        sets.add(ExerciseSet(
          setNumber: setData['set'] ?? sets.length + 1,
          weight: setData['weight'] ?? 0.0,
          reps: setData['reps'] ?? 0,
          actualReps: setData['reps'], // CSV non distingue
          rpe: setData['rpe'],
          isCompleted: true, // Assumiamo completati se in CSV
          notes: setData['notes'],
        ));
      }
      
      exercises.add(Exercise(
        name: entry.key,
        type: ExerciseType.single,
        category: _guessCategory(entry.key),
        sets: sets,
      ));
    }
    
    // Parse data se disponibile
    DateTime? workoutDate;
    try {
      final dateStr = firstRow['date'];
      if (dateStr != null) {
        workoutDate = DateTime.tryParse(dateStr);
      }
    } catch (_) {}
    
    return Workout(
      name: workoutName,
      exercises: exercises,
      status: WorkoutStatus.completed,
      startTime: workoutDate,
      endTime: workoutDate,
      createdAt: workoutDate ?? DateTime.now(),
    );
  }
  
  /// Helper: parse workout status
  WorkoutStatus _parseWorkoutStatus(dynamic status) {
    if (status == null) return WorkoutStatus.planned;
    
    try {
      return WorkoutStatus.values.firstWhere(
        (s) => s.name == status.toString(),
        orElse: () => WorkoutStatus.planned,
      );
    } catch (_) {
      return WorkoutStatus.planned;
    }
  }
  
  /// Helper: parse exercise type
  ExerciseType _parseExerciseType(dynamic type) {
    if (type == null) return ExerciseType.single;
    
    try {
      return ExerciseType.values.firstWhere(
        (t) => t.name == type.toString(),
        orElse: () => ExerciseType.single,
      );
    } catch (_) {
      return ExerciseType.single;
    }
  }
  
  /// Helper: parse exercise category
  ExerciseCategory _parseExerciseCategory(dynamic category) {
    if (category == null) return ExerciseCategory.other;
    
    try {
      return ExerciseCategory.values.firstWhere(
        (c) => c.name == category.toString(),
        orElse: () => ExerciseCategory.other,
      );
    } catch (_) {
      return ExerciseCategory.other;
    }
  }
  
  /// Helper: indovina categoria da nome esercizio
  ExerciseCategory _guessCategory(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('squat') || name.contains('leg') || name.contains('calf')) {
      return ExerciseCategory.legs;
    } else if (name.contains('bench') || name.contains('chest') || name.contains('pec')) {
      return ExerciseCategory.chest;
    } else if (name.contains('row') || name.contains('pull') || name.contains('lat')) {
      return ExerciseCategory.back;
    } else if (name.contains('shoulder') || name.contains('press') || name.contains('delt')) {
      return ExerciseCategory.shoulders;
    } else if (name.contains('curl') || name.contains('tricep') || name.contains('bicep')) {
      return ExerciseCategory.arms;
    } else if (name.contains('abs') || name.contains('plank') || name.contains('crunch')) {
      return ExerciseCategory.abs;
    } else if (name.contains('cardio') || name.contains('run') || name.contains('bike')) {
      return ExerciseCategory.cardio;
    }
    
    return ExerciseCategory.other;
  }
}

/// Risultato dell'import
class ImportResult {
  
  ImportResult({
    required this.success,
    required this.message,
    this.workouts,
    this.errors,
  });
  final bool success;
  final String message;
  final List<Workout>? workouts;
  final List<String>? errors;
  
  int get importedCount => workouts?.length ?? 0;
  int get errorCount => errors?.length ?? 0;
}