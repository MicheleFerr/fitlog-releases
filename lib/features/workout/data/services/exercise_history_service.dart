/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data/services
 * 🎯 Feature: workout
 * 🔧 Type: service
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Hive (local storage)
 * - Domain entities
 */

import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_model.dart';

class ExerciseHistoryData {
  final double? weight;
  final int? reps;
  final DateTime date;
  final String workoutName;

  const ExerciseHistoryData({
    this.weight,
    this.reps,
    required this.date,
    required this.workoutName,
  });
}

class ExerciseHistoryService {
  static const String _workoutsBoxName = 'workouts';
  
  /// Enable debug logging (useful for troubleshooting)
  final bool enableDebugLogging;
  
  const ExerciseHistoryService({this.enableDebugLogging = true});
  
  /// Helper method for conditional debug logging
  void _debugLog(String message) {
    if (enableDebugLogging) {
      print(message);
    }
  }

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
  Future<List<ExerciseHistoryData>> getExerciseHistory(String exerciseName, String userId, {int limit = 50}) async {
    return _getExerciseHistory(exerciseName, userId, limit: limit);
  }

  /// Get exercise history grouped by date for better display
  Future<Map<DateTime, List<ExerciseHistoryData>>> getExerciseHistoryGrouped(String exerciseName, String userId, {int limit = 50}) async {
    final history = await _getExerciseHistory(exerciseName, userId, limit: limit);
    final grouped = <DateTime, List<ExerciseHistoryData>>{};
    
    for (final data in history) {
      final date = DateTime(data.date.year, data.date.month, data.date.day);
      grouped.putIfAbsent(date, () => []).add(data);
    }
    
    return grouped;
  }

  /// Internal method to get exercise history from Hive storage
  Future<List<ExerciseHistoryData>> _getExerciseHistory(String exerciseName, String userId, {int limit = 50}) async {
    try {
      final box = await Hive.openBox<Map>(_workoutsBoxName);
      final historyData = <ExerciseHistoryData>[];
      
      // Enhanced debugging
      if (enableDebugLogging) {
        print('🔍 ===== EXERCISE HISTORY DEBUG START =====');
        print('📦 ExerciseHistory: Total keys in box: ${box.keys.length}');
        print('📦 ExerciseHistory: Looking for exercise: "$exerciseName" for user: "$userId"');
      }
      
      // Show first few keys for debugging
      final allKeys = box.keys.take(10).toList();
      print('📦 ExerciseHistory: Sample keys: ${allKeys.join(", ")}');
      
      // Get all workouts for this user
      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_')).toList();
      print('📦 ExerciseHistory: Found ${userKeys.length} keys for user $userId');
      
      if (userKeys.isEmpty) {
        print('❌ ExerciseHistory: No keys found for user $userId');
        print('📦 ExerciseHistory: All keys in box: ${box.keys.toList()}');
        print('🔍 ===== EXERCISE HISTORY DEBUG END =====');
        return [];
      }
      
      final userWorkouts = <WorkoutModel>[];
      
      for (final key in userKeys) {
        final data = box.get(key);
        if (data == null) {
          print('❌ ExerciseHistory: No data for key: $key');
          continue;
        }
        
        try {
          final Map<String, dynamic> jsonData;
          if (data is Map<String, dynamic>) {
            jsonData = data;
          } else if (data is Map) {
            jsonData = Map<String, dynamic>.from(
              data.map((k, v) => MapEntry(k.toString(), v))
            );
          } else {
            print('❌ ExerciseHistory: Invalid data type for key $key: ${data.runtimeType}');
            continue;
          }
          
          final workout = WorkoutModel.fromJson(jsonData);
          userWorkouts.add(workout);
          print('✅ ExerciseHistory: Parsed workout: ${workout.name} (${workout.exercises.length} exercises)');
          
        } catch (e, stackTrace) {
          print('❌ ExerciseHistory: Error parsing workout for key $key: $e');
          print('❌ ExerciseHistory: Stack trace: $stackTrace');
          continue;
        }
      }
      
      print('📦 ExerciseHistory: Successfully parsed ${userWorkouts.length} workouts for user');
      
      if (userWorkouts.isEmpty) {
        print('❌ ExerciseHistory: No valid workouts found for user $userId');
        print('🔍 ===== EXERCISE HISTORY DEBUG END =====');
        return [];
      }
      
      // Sort workouts by date (newest first)
      userWorkouts.sort((a, b) => (b.startTime ?? b.createdAt).compareTo(a.startTime ?? a.createdAt));
      
      // Show all unique exercise names for debugging
      final allExerciseNames = <String>{};
      for (final workout in userWorkouts) {
        for (final exercise in workout.exercises) {
          allExerciseNames.add(exercise.name);
        }
      }
      print('📋 ExerciseHistory: All unique exercise names found: ${allExerciseNames.toList()}');
      
      // Extract exercise data from workouts
      for (final workout in userWorkouts) {
        print('🔍 ExerciseHistory: Checking workout "${workout.name}" (status: ${workout.status})');
        
        // Include workouts with status 'completed' OR 'inProgress' that have completed exercises
        // Skip only 'planned' workouts
        if (workout.status == 'planned') {
          print('⏭️ ExerciseHistory: Skipping planned workout');
          continue;
        }
        
        bool foundMatchingExercise = false;
        
        for (final exercise in workout.exercises) {
          // More flexible exercise name matching
          final exerciseNameLower = exercise.name.toLowerCase().trim();
          final searchNameLower = exerciseName.toLowerCase().trim();
          
          print('🔍 ExerciseHistory: Comparing "$exerciseNameLower" with "$searchNameLower"');
          
          // Try exact match, then partial match, then variations
          bool isMatch = false;
          if (exerciseNameLower == searchNameLower) {
            isMatch = true;
            print('✅ ExerciseHistory: Exact match found');
          } else if (exerciseNameLower.contains(searchNameLower) || searchNameLower.contains(exerciseNameLower)) {
            isMatch = true;
            print('✅ ExerciseHistory: Partial match found');
          } else {
            // Try with variations (Italian/English translations)
            final variations = _getExerciseVariations(searchNameLower);
            for (final variation in variations) {
              if (exerciseNameLower == variation || exerciseNameLower.contains(variation) || variation.contains(exerciseNameLower)) {
                isMatch = true;
                print('✅ ExerciseHistory: Variation match found: "$variation" matches "$exerciseNameLower"');
                break;
              }
            }
          }
          
          if (isMatch) {
            foundMatchingExercise = true;
            print('✅ ExerciseHistory: Found matching exercise: "${exercise.name}" with ${exercise.sets.length} sets');
            final workoutDate = workout.startTime ?? workout.createdAt;
            
            // Get completed sets first
            var setsToProcess = exercise.sets.where((set) => set.isCompleted).toList();
            print('📦 ExerciseHistory: Found ${setsToProcess.length} completed sets');
            
            // If no completed sets, look for sets with weight > 0 and reps > 0
            if (setsToProcess.isEmpty) {
              setsToProcess = exercise.sets.where((set) => set.weight > 0 && set.reps > 0).toList();
              if (setsToProcess.isNotEmpty) {
                print('⚠️ ExerciseHistory: No completed sets found, using ${setsToProcess.length} sets with weight > 0 and reps > 0');
              }
            }
            
            // If still no sets, include any sets with data
            if (setsToProcess.isEmpty) {
              setsToProcess = exercise.sets.where((set) => set.weight > 0 || set.reps > 0).toList();
              if (setsToProcess.isNotEmpty) {
                print('⚠️ ExerciseHistory: Using ${setsToProcess.length} sets with any data');
              }
            }
            
            print('📦 ExerciseHistory: Processing ${setsToProcess.length} sets for exercise "${exercise.name}"');
            
            for (final set in setsToProcess) {
              print('📝 ExerciseHistory: Adding set: ${set.weight}kg x ${set.reps} reps (completed: ${set.isCompleted})');
              historyData.add(ExerciseHistoryData(
                weight: set.weight > 0 ? set.weight : null,
                reps: set.reps > 0 ? set.reps : null,
                date: workoutDate,
                workoutName: workout.name,
              ));
            }
          }
        }
        
        if (!foundMatchingExercise) {
          // Don't log every workout without match to avoid spam
          // print('❌ ExerciseHistory: No matching exercise found in workout "${workout.name}"');
          // Show exercise names in this workout for debugging only if we want verbose output
          // final exerciseNames = workout.exercises.map((e) => '"${e.name}"').join(', ');
          // print('📋 ExerciseHistory: Exercises in this workout: [$exerciseNames]');
        }
        
        // REMOVED: Don't break early - search ALL workouts to find the exercise
        // if (historyData.length >= limit) break;
      }
      
      print('📦 ExerciseHistory: Found ${historyData.length} total history items for "$exerciseName"');
      print('📦 ExerciseHistory: Returning top ${historyData.length > limit ? limit : historyData.length} items');
      print('🔍 ===== EXERCISE HISTORY DEBUG END =====');
      
      // Sort by date (newest first) before limiting
      historyData.sort((a, b) => b.date.compareTo(a.date));
      
      return historyData.take(limit).toList();
    } catch (e, stackTrace) {
      print('❌ ExerciseHistory: Fatal error: $e');
      print('❌ ExerciseHistory: Stack trace: $stackTrace');
      // Return empty list on error
      return [];
    }
  }

  /// Debug method to get all exercise names for a user
  Future<List<String>> getAllExerciseNames(String userId) async {
    try {
      final box = await Hive.openBox<Map>(_workoutsBoxName);
      final exerciseNames = <String>{};
      
      final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));
      
      for (final key in userKeys) {
        final data = box.get(key);
        if (data == null) continue;
        
        try {
          final Map<String, dynamic> jsonData;
          if (data is Map<String, dynamic>) {
            jsonData = data;
          } else if (data is Map) {
            jsonData = Map<String, dynamic>.from(
              data.map((k, v) => MapEntry(k.toString(), v))
            );
          } else {
            continue;
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
      print('❌ ExerciseHistory: Error getting exercise names: $e');
      return [];
    }
  }

  /// Debug method to get workout count for a user
  Future<int> getWorkoutCount(String userId) async {
    try {
      final box = await Hive.openBox<Map>(_workoutsBoxName);
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
}