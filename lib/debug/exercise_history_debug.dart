/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: debug
 * 🎯 Feature: workout
 * 🔧 Type: debug_tool
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Hive (local storage)
 * - Workout models
 */

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/workout/data/models/workout_model.dart';
import '../features/workout/data/services/exercise_history_service.dart';

class ExerciseHistoryDebug {
  static const String _workoutsBoxName = 'workouts';

  /// Debug method to inspect all workout data in Hive
  static Future<void> inspectHiveData({String? userId}) async {
    try {
      debugPrint('🔍 === EXERCISE HISTORY DEBUG INSPECTION ===');
      
      final box = await Hive.openBox<Map>(_workoutsBoxName);
      debugPrint('📦 Total keys in workouts box: ${box.keys.length}');
      
      if (box.keys.isEmpty) {
        debugPrint('❌ No workout data found in Hive box');
        return;
      }
      
      debugPrint('📋 All keys in box:');
      for (final key in box.keys) {
        debugPrint('  - $key');
      }
      
      if (userId != null) {
        debugPrint('\n🔍 Filtering for user: $userId');
        final userKeys = box.keys.where((key) => key.toString().startsWith('${userId}_'));
        debugPrint('📦 Found ${userKeys.length} keys for user $userId');
        
        for (final key in userKeys) {
          await _inspectWorkout(box, key.toString());
        }
      } else {
        debugPrint('\n🔍 Inspecting all workouts (no user filter)');
        for (final key in box.keys.take(5)) { // Limit to first 5 for readability
          await _inspectWorkout(box, key.toString());
        }
      }
      
      debugPrint('🔍 === END DEBUG INSPECTION ===\n');
    } catch (e) {
      debugPrint('❌ Error during inspection: $e');
    }
  }

  static Future<void> _inspectWorkout(Box<Map> box, String key) async {
    try {
      debugPrint('\n--- Inspecting workout: $key ---');
      
      final data = box.get(key);
      if (data == null) {
        debugPrint('❌ No data for key: $key');
        return;
      }
      
      debugPrint('📄 Raw data type: ${data.runtimeType}');
      
      // Try to parse as WorkoutModel
      WorkoutModel? workout;
      try {
        final Map<String, dynamic> jsonData;
        if (data is Map<String, dynamic>) {
          jsonData = data;
        } else if (data is Map) {
          jsonData = Map<String, dynamic>.from(
            data.map((key, value) => MapEntry(key.toString(), value))
          );
        } else {
          debugPrint('❌ Invalid data type: ${data.runtimeType}');
          return;
        }
        
        workout = WorkoutModel.fromJson(jsonData);
        debugPrint('✅ Successfully parsed workout: ${workout.name}');
        debugPrint('   - ID: ${workout.id}');
        debugPrint('   - Status: ${workout.status}');
        debugPrint('   - Created: ${workout.createdAt}');
        debugPrint('   - Start time: ${workout.startTime}');
        debugPrint('   - End time: ${workout.endTime}');
        debugPrint('   - Exercise count: ${workout.exercises.length}');
        
        // Inspect exercises
        for (int i = 0; i < workout.exercises.length; i++) {
          final exercise = workout.exercises[i];
          debugPrint('   📋 Exercise $i: ${exercise.name}');
          debugPrint('     - Type: ${exercise.type}');
          debugPrint('     - Category: ${exercise.category}');
          debugPrint('     - Total sets: ${exercise.sets.length}');
          debugPrint('     - Completed sets: ${exercise.sets.where((s) => s.isCompleted).length}');
          debugPrint('     - Sets with weight > 0: ${exercise.sets.where((s) => s.weight > 0).length}');
          
          // Show first few sets
          final setsToShow = exercise.sets.take(3);
          for (int j = 0; j < setsToShow.length; j++) {
            final set = exercise.sets[j];
            debugPrint('       Set $j: ${set.weight}kg x ${set.reps} reps (completed: ${set.isCompleted})');
          }
          if (exercise.sets.length > 3) {
            debugPrint('       ... and ${exercise.sets.length - 3} more sets');
          }
        }
        
      } catch (e) {
        debugPrint('❌ Error parsing workout: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Error inspecting workout $key: $e');
    }
  }

  /// Test exercise history retrieval for a specific exercise
  static Future<void> testExerciseHistory({
    required String exerciseName,
    required String userId,
  }) async {
    try {
      debugPrint('🔍 === TESTING EXERCISE HISTORY RETRIEVAL ===');
      debugPrint('🔍 Exercise: $exerciseName');
      debugPrint('🔍 User: $userId');
      
      final service = ExerciseHistoryService();
      
      // Test different methods
      debugPrint('\n📊 Testing getExerciseHistory...');
      final history = await service.getExerciseHistory(exerciseName, userId);
      debugPrint('✅ Found ${history.length} history items');
      
      for (int i = 0; i < history.length && i < 5; i++) {
        final item = history[i];
        debugPrint('  Item $i: ${item.weight}kg x ${item.reps} reps on ${item.date} (${item.workoutName})');
      }
      
      debugPrint('\n📊 Testing getRecentWeights...');
      final weights = await service.getRecentWeights(exerciseName, userId);
      debugPrint('✅ Recent weights: $weights');
      
      debugPrint('\n📊 Testing getLastExerciseData...');
      final lastData = await service.getLastExerciseData(exerciseName, userId);
      debugPrint('✅ Last data: weight=${lastData.weight}, date=${lastData.date}');
      
      debugPrint('\n📊 Testing getExerciseStats...');
      final stats = await service.getExerciseStats(exerciseName, userId);
      debugPrint('✅ Stats:');
      debugPrint('   - Max weight: ${stats.maxWeight}');
      debugPrint('   - Total sets: ${stats.totalSets}');
      debugPrint('   - Avg weight: ${stats.avgWeight}');
      debugPrint('   - First workout: ${stats.firstWorkout}');
      debugPrint('   - Last workout: ${stats.lastWorkout}');
      
      debugPrint('🔍 === END EXERCISE HISTORY TEST ===\n');
    } catch (e) {
      debugPrint('❌ Error testing exercise history: $e');
    }
  }

  /// Test with common exercise name variations
  static Future<void> testExerciseNameVariations({
    required String userId,
  }) async {
    try {
      debugPrint('🔍 === TESTING EXERCISE NAME VARIATIONS ===');
      
      // First, get all unique exercise names from the database
      final box = await Hive.openBox<Map>(_workoutsBoxName);
      final uniqueExercises = <String>{};
      
      final userWorkouts = box.keys
          .where((key) => key.toString().startsWith('${userId}_'))
          .map((key) {
            final data = box.get(key);
            if (data == null) return null;
            try {
              final Map<String, dynamic> jsonData;
              if (data is Map<String, dynamic>) {
                jsonData = data;
              } else if (data is Map) {
                jsonData = Map<String, dynamic>.from(
                  data.map((key, value) => MapEntry(key.toString(), value))
                );
              } else {
                return null;
              }
              return WorkoutModel.fromJson(jsonData);
            } catch (e) {
              return null;
            }
          })
          .where((workout) => workout != null)
          .cast<WorkoutModel>()
          .toList();

      for (final workout in userWorkouts) {
        for (final exercise in workout.exercises) {
          uniqueExercises.add(exercise.name);
        }
      }
      
      debugPrint('📋 Found ${uniqueExercises.length} unique exercises:');
      for (final exerciseName in uniqueExercises.take(10)) {
        debugPrint('  - "$exerciseName"');
      }
      
      // Test each exercise
      for (final exerciseName in uniqueExercises.take(5)) {
        debugPrint('\n🧪 Testing: "$exerciseName"');
        await testExerciseHistory(exerciseName: exerciseName, userId: userId);
      }
      
      debugPrint('🔍 === END NAME VARIATIONS TEST ===\n');
    } catch (e) {
      debugPrint('❌ Error testing exercise name variations: $e');
    }
  }

  /// Find workouts that should contain a specific exercise
  static Future<void> findWorkoutsWithExercise({
    required String exerciseName,
    required String userId,
  }) async {
    try {
      debugPrint('🔍 === FINDING WORKOUTS WITH EXERCISE ===');
      debugPrint('🔍 Looking for: "$exerciseName"');
      debugPrint('🔍 User: $userId');
      
      final box = await Hive.openBox<Map>(_workoutsBoxName);
      final matchingWorkouts = <String, List<String>>{};
      
      for (final key in box.keys) {
        if (!key.toString().startsWith('${userId}_')) continue;
        
        final data = box.get(key);
        if (data == null) continue;
        
        try {
          final Map<String, dynamic> jsonData;
          if (data is Map<String, dynamic>) {
            jsonData = data;
          } else if (data is Map) {
            jsonData = Map<String, dynamic>.from(
              data.map((key, value) => MapEntry(key.toString(), value))
            );
          } else {
            continue;
          }
          
          final workout = WorkoutModel.fromJson(jsonData);
          final exerciseNames = <String>[];
          
          for (final exercise in workout.exercises) {
            exerciseNames.add(exercise.name);
            
            // Check for exact match, case-insensitive match, and partial match
            if (exercise.name.toLowerCase() == exerciseName.toLowerCase()) {
              debugPrint('✅ Exact match found in workout: ${workout.name} (${key})');
              debugPrint('   Exercise: "${exercise.name}" (sets: ${exercise.sets.length}, completed: ${exercise.sets.where((s) => s.isCompleted).length})');
            } else if (exercise.name.toLowerCase().contains(exerciseName.toLowerCase())) {
              debugPrint('🔍 Partial match found in workout: ${workout.name} (${key})');
              debugPrint('   Exercise: "${exercise.name}" (sets: ${exercise.sets.length}, completed: ${exercise.sets.where((s) => s.isCompleted).length})');
            }
          }
          
          matchingWorkouts[key.toString()] = exerciseNames;
          
        } catch (e) {
          debugPrint('❌ Error parsing workout $key: $e');
        }
      }
      
      if (matchingWorkouts.isEmpty) {
        debugPrint('❌ No workouts found for user $userId');
      } else {
        debugPrint('\n📋 All workouts for user (first 3):');
        int count = 0;
        for (final entry in matchingWorkouts.entries) {
          if (count >= 3) break;
          debugPrint('  Workout: ${entry.key}');
          debugPrint('    Exercises: ${entry.value.join(", ")}');
          count++;
        }
      }
      
      debugPrint('🔍 === END WORKOUT SEARCH ===\n');
    } catch (e) {
      debugPrint('❌ Error finding workouts: $e');
    }
  }
}