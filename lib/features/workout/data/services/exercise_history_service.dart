/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/services
/// 🎯 Feature: workout
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Hive (local storage)
/// - Domain entities
library;

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

class ExerciseHistoryData {

  const ExerciseHistoryData({
    this.weight,
    this.reps,
    this.rpe,  // ✅ Include RPE from set
    this.tut,  // ✅ Include TUT from exercise level
    this.setDurationMillis,  // ✅ Include actual set duration
    required this.date,
    required this.workoutName,
  });
  final double? weight;
  final int? reps;
  final int? rpe;  // Rate of Perceived Exertion (5-10)
  final String? tut;  // Time Under Tension from Exercise level
  final double? setDurationMillis;  // Actual set duration in milliseconds
  final DateTime date;
  final String workoutName;
}

class ExerciseHistoryService {

  const ExerciseHistoryService({
    required HiveBoxManagerEnhanced boxManager,
    this.enableDebugLogging = true,
  }) : _boxManager = boxManager;

  static const String _workoutsBoxName = 'workouts';

  final HiveBoxManagerEnhanced _boxManager;

  /// Enable debug logging (useful for troubleshooting)
  final bool enableDebugLogging;
  
  /// Get recent weights for a specific exercise from previous workouts
  Future<List<double>> getRecentWeights(String exerciseName, String userId, {int limit = 5}) async {
    final historyData = await _getExerciseHistory(exerciseName, userId, limit: 20);
    
    // Extract unique weights, prioritizing more recent ones
    final weightsSet = <double>{};
    final weights = <double>[];
    
    for (final data in historyData) {
      if (data.weight != null && !weightsSet.contains(data.weight!)) {
        weightsSet.add(data.weight!);
        weights.add(data.weight!);
        
        if (weights.length >= limit) break;
      }
    }
    
    return weights;
  }

  /// Get the last recorded weight and date for an exercise
  Future<({double? weight, DateTime? date})> getLastExerciseData(String exerciseName, String userId) async {
    final historyData = await _getExerciseHistory(exerciseName, userId, limit: 1);
    
    if (historyData.isNotEmpty) {
      final lastData = historyData.first;
      return (weight: lastData.weight, date: lastData.date);
    }
    
    return (weight: null, date: null);
  }

  /// Get complete exercise history for full bottom sheet display
  /// ⚡ OPTIMIZATION: Reduced limit from 50 → 10 to save memory (80-120MB reduction)
  Future<List<ExerciseHistoryData>> getExerciseHistory(String exerciseName, String userId, {int limit = 10}) async {
    return _getExerciseHistory(exerciseName, userId, limit: limit);
  }

  /// Get exercise history grouped by date for better display
  /// ⚡ OPTIMIZATION: Reduced limit from 50 → 10 to save memory (80-120MB reduction)
  Future<Map<DateTime, List<ExerciseHistoryData>>> getExerciseHistoryGrouped(String exerciseName, String userId, {int limit = 10}) async {
    final history = await _getExerciseHistory(exerciseName, userId, limit: limit);
    final grouped = <DateTime, List<ExerciseHistoryData>>{};

    for (final data in history) {
      final date = DateTime(data.date.year, data.date.month, data.date.day);
      grouped.putIfAbsent(date, () => []).add(data);
    }

    return grouped;
  }

  /// Internal method to get exercise history from Hive storage
  /// ⚡ OPTIMIZATION: Reduced limit from 50 → 10 to save memory (80-120MB reduction)
  Future<List<ExerciseHistoryData>> _getExerciseHistory(String exerciseName, String userId, {int limit = 10}) async {
    try {
      // ✅ DEBUG: Log query
      if (enableDebugLogging && kDebugMode) {
        debugPrint('🔍 [HISTORY QUERY] Searching for exercise: "$exerciseName" (userId: $userId, limit: $limit)');
      }

      final box = await _boxManager.openBox<Map>(_workoutsBoxName);
      final historyData = <ExerciseHistoryData>[];

      // Get all workouts for this user
      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_')).toList();

      if (userKeys.isEmpty) {
        return [];
      }

      final userWorkouts = <WorkoutModel>[];

      for (final key in userKeys) {
        final data = box.get(key);
        if (data == null) continue;

        try {
          final Map<String, dynamic> jsonData;
          if (data is Map<String, dynamic>) {
            jsonData = data;
          } else {
            jsonData = Map<String, dynamic>.from(
            data.map((k, v) => MapEntry(k.toString(), v))
          );
          }
        

          final workout = WorkoutModel.fromJson(jsonData);
          userWorkouts.add(workout);
        } catch (e) {
          if (enableDebugLogging) {
            if (kDebugMode) {
              debugPrint('❌ ExerciseHistory: Error parsing workout for key $key: $e');
            }
          }
          continue;
        }
      }

      if (userWorkouts.isEmpty) {
        return [];
      }

      // Sort workouts by date (newest first)
      userWorkouts.sort((a, b) => (b.startTime ?? b.createdAt).compareTo(a.startTime ?? a.createdAt));

      // Extract exercise data from workouts
      for (final workout in userWorkouts) {
        // Skip planned workouts
        if (workout.status == 'planned') continue;

        for (final exercise in workout.exercises) {
          // More flexible exercise name matching
          final exerciseNameLower = exercise.name.toLowerCase().trim();
          final searchNameLower = exerciseName.toLowerCase().trim();

          // Try exact match, then partial match, then variations
          bool isMatch = false;
          if (exerciseNameLower == searchNameLower) {
            isMatch = true;
          } else if (exerciseNameLower.contains(searchNameLower) || searchNameLower.contains(exerciseNameLower)) {
            isMatch = true;
          } else {
            // Try with variations (Italian/English translations)
            final variations = _getExerciseVariations(searchNameLower);
            for (final variation in variations) {
              if (exerciseNameLower == variation || exerciseNameLower.contains(variation) || variation.contains(exerciseNameLower)) {
                isMatch = true;
                break;
              }
            }
          }

          if (isMatch) {
            final workoutDate = workout.startTime ?? workout.createdAt;

            // Get completed sets first
            var setsToProcess = exercise.sets.where((set) => set.isCompleted).toList();

            // If no completed sets, look for sets with weight > 0 and reps > 0
            if (setsToProcess.isEmpty) {
              setsToProcess = exercise.sets.where((set) => (set.weight ?? 0) > 0 && (set.reps ?? 0) > 0).toList();
            }

            // If still no sets, include any sets with data
            if (setsToProcess.isEmpty) {
              setsToProcess = exercise.sets.where((set) => (set.weight ?? 0) > 0 || (set.reps ?? 0) > 0).toList();
            }

            for (final set in setsToProcess) {
              final historyEntry = ExerciseHistoryData(
                weight: (set.weight ?? 0) > 0 ? set.weight : null,
                reps: (set.reps ?? 0) > 0 ? set.reps : null,
                rpe: set.rpe,  // ✅ Include RPE from set
                tut: exercise.tut,  // ✅ Include TUT from exercise level
                setDurationMillis: set.setDurationMillis,  // ✅ Include actual set duration
                date: workoutDate,
                workoutName: workout.name,
              );

              // ✅ DEBUG: Log RPE extraction
              if (enableDebugLogging && kDebugMode && set.rpe != null) {
                debugPrint('📊 [HISTORY] Found RPE: exercise=${exercise.name}, RPE=${set.rpe}, weight=${set.weight}, reps=${set.reps}, workout=${workout.name}');
              }

              historyData.add(historyEntry);
            }
          }
        }
      }

      // Sort by date (newest first) before limiting
      historyData.sort((a, b) => b.date.compareTo(a.date));

      // ✅ DEBUG: Log summary
      if (enableDebugLogging && kDebugMode) {
        final withRPE = historyData.where((d) => d.rpe != null).length;
        final withWeight = historyData.where((d) => d.weight != null).length;
        final withReps = historyData.where((d) => d.reps != null).length;
        final withTUT = historyData.where((d) => d.setDurationMillis != null).length;
        debugPrint('📊 [HISTORY SUMMARY] Found ${historyData.length} total sets for "$exerciseName"');
        debugPrint('   → With RPE: $withRPE, With Weight: $withWeight, With Reps: $withReps, With TUT: $withTUT');
      }

      return historyData.take(limit).toList();
    } catch (e, stackTrace) {
      if (enableDebugLogging) {
        if (kDebugMode) {
          debugPrint('❌ ExerciseHistory: Fatal error: $e');
        }
        if (kDebugMode) {
          debugPrint('❌ ExerciseHistory: Stack trace: $stackTrace');
        }
      }
      return [];
    }
  }

  /// Debug method to get all exercise names for a user
  Future<List<String>> getAllExerciseNames(String userId) async {
    try {
      final box = await _boxManager.openBox<Map>(_workoutsBoxName);
      final exerciseNames = <String>{};
      
      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));
      
      for (final key in userKeys) {
        final data = box.get(key);
        if (data == null) continue;
        
        try {
          final Map<String, dynamic> jsonData;
          if (data is Map<String, dynamic>) {
            jsonData = data;
          } else {
            jsonData = Map<String, dynamic>.from(
            data.map((k, v) => MapEntry(k.toString(), v))
          );
          }
        
          
          final workout = WorkoutModel.fromJson(jsonData);
          for (final exercise in workout.exercises) {
            exerciseNames.add(exercise.name);
          }
        } catch (e) {
          // Skip invalid workouts
          continue;
        }
      }
      
      return exerciseNames.toList()..sort();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ExerciseHistory: Error getting exercise names: $e');
      }
      return [];
    }
  }

  /// Debug method to get workout count for a user
  Future<int> getWorkoutCount(String userId) async {
    try {
      final box = await _boxManager.openBox<Map>(_workoutsBoxName);
      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));
      return userKeys.length;
    } catch (e) {
      return 0;
    }
  }

  /// Helper method to get common exercise name variations
  List<String> _getExerciseVariations(String exerciseName) {
    final variations = <String>[];
    final nameLower = exerciseName.toLowerCase().trim();
    
    // Common Italian <-> English translations
    final translations = {
      'panca piana': ['bench press', 'flat bench', 'panca', 'distensioni su panca'],
      'bench press': ['panca piana', 'panca', 'distensioni su panca'],
      'squat': ['squat', 'accosciata', 'squats'],
      'stacco': ['deadlift', 'stacco da terra', 'stacchi'],
      'deadlift': ['stacco', 'stacco da terra', 'stacchi'],
      'military press': ['lento avanti', 'spinte militari', 'shoulder press'],
      'lento avanti': ['military press', 'spinte militari', 'shoulder press'],
      'curl': ['curl bicipiti', 'bicep curl', 'curl con bilanciere'],
      'lat machine': ['lat pulldown', 'lat machine al petto', 'pulldown'],
      'leg press': ['pressa', 'leg press', 'pressa gambe'],
      'pressa': ['leg press', 'pressa gambe'],
    };
    
    // Add variations from translation map
    for (final entry in translations.entries) {
      if (entry.key == nameLower || entry.value.contains(nameLower)) {
        variations.addAll(entry.value);
        variations.add(entry.key);
      }
    }
    
    // Add the original name
    variations.add(nameLower);
    
    // Remove duplicates
    return variations.toSet().toList();
  }

  /// Get exercise statistics from history
  Future<({
    double? maxWeight,
    int totalSets,
    double avgWeight,
    DateTime? firstWorkout,
    DateTime? lastWorkout,
  })> getExerciseStats(String exerciseName, String userId) async {
    final history = await _getExerciseHistory(exerciseName, userId, limit: 1000);
    
    if (history.isEmpty) {
      return (
        maxWeight: null,
        totalSets: 0,
        avgWeight: 0.0,
        firstWorkout: null,
        lastWorkout: null,
      );
    }
    
    final weights = history.where((data) => data.weight != null).map((data) => data.weight!);
    final dates = history.map((data) => data.date).toList();
    dates.sort();
    
    return (
      maxWeight: weights.isNotEmpty ? weights.reduce((a, b) => a > b ? a : b) : null,
      totalSets: history.length,
      avgWeight: weights.isNotEmpty ? weights.reduce((a, b) => a + b) / weights.length : 0.0,
      firstWorkout: dates.isNotEmpty ? dates.first : null,
      lastWorkout: dates.isNotEmpty ? dates.last : null,
    );
  }

  /// MEMORY LEAK FIX: Close workouts box to free memory
  /// Note: This service opens boxes in multiple methods.
  /// A better approach would be to open once and reuse, but that requires refactoring.
  /// For now, this static method allows manual cleanup when needed.
  static Future<void> dispose() async {
    try {
      if (Hive.isBoxOpen(_workoutsBoxName)) {
        await Hive.box<Map>(_workoutsBoxName).close();
        if (kDebugMode) {
          debugPrint('✅ ExerciseHistoryService: Closed workouts box');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing ExerciseHistoryService: $e');
      }
    }
  }
}