/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: test/data/services
 * 🎯 Feature: workout
 * 🔧 Type: test
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Test for ExerciseHistoryService
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';

void main() {
  group('ExerciseHistoryService', () {
    late ExerciseHistoryService service;
    late Box<Map> box;
    
    const testUserId = 'test_user_123';
    const testExerciseName = 'Bench Press';
    
    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
    });
    
    setUp(() async {
      service = ExerciseHistoryService();
      
      // Create a temporary box for testing - use the same name as the service
      box = await Hive.openBox<Map>('workouts');
      await box.clear(); // Clean slate for each test
      
      // Add test workout data
      await _addTestWorkouts(box, testUserId);
    });
    
    tearDown(() async {
      await box.clear();
      await box.close();
    });
    
    test('should return exercise history for existing exercise', () async {
      final history = await service.getExerciseHistory(testExerciseName, testUserId);
      
      expect(history, isNotEmpty);
      expect(history.first.weight, equals(80.0));
      expect(history.first.reps, equals(10));
      expect(history.first.workoutName, contains('Test Workout'));
    });
    
    test('should return empty list for non-existent exercise', () async {
      final history = await service.getExerciseHistory('Non-Existent Exercise', testUserId);
      
      expect(history, isEmpty);
    });
    
    test('should return empty list for non-existent user', () async {
      final history = await service.getExerciseHistory(testExerciseName, 'non_existent_user');
      
      expect(history, isEmpty);
    });
    
    test('should get recent weights correctly', () async {
      final weights = await service.getRecentWeights(testExerciseName, testUserId, limit: 3);
      
      expect(weights, isNotEmpty);
      expect(weights, contains(80.0));
      expect(weights, contains(85.0));
    });
    
    test('should get last exercise data', () async {
      final lastData = await service.getLastExerciseData(testExerciseName, testUserId);
      
      expect(lastData.weight, isNotNull);
      expect(lastData.date, isNotNull);
    });
    
    test('should get exercise stats', () async {
      final stats = await service.getExerciseStats(testExerciseName, testUserId);
      
      expect(stats.totalSets, greaterThan(0));
      expect(stats.maxWeight, isNotNull);
      expect(stats.avgWeight, greaterThan(0));
    });
    
    test('should handle case-insensitive exercise matching', () async {
      final history1 = await service.getExerciseHistory('bench press', testUserId);
      final history2 = await service.getExerciseHistory('BENCH PRESS', testUserId);
      final history3 = await service.getExerciseHistory('Bench Press', testUserId);
      
      expect(history1.length, equals(history2.length));
      expect(history2.length, equals(history3.length));
    });
    
    test('should include sets with weight > 0 when no completed sets', () async {
      // Add a workout with uncompleted sets but with weight data
      final workout = _createTestWorkout(
        'test_user_123_incomplete',
        'Incomplete Workout',
        'Squat',
        [
          ExerciseSetModel(
            id: 'set1',
            setNumber: 1,
            weight: 100.0,
            reps: 8,
            volume: 800.0,
            isCompleted: false, // Not marked as completed
            restTime: 60,
          ),
        ],
      );
      
      await box.put('${testUserId}_incomplete', workout.toJson());
      
      final history = await service.getExerciseHistory('Squat', testUserId);
      
      expect(history, isNotEmpty);
      expect(history.first.weight, equals(100.0));
    });
  });
}

/// Helper function to add test workout data
Future<void> _addTestWorkouts(Box<Map> box, String userId) async {
  // Workout 1 - Recent
  final workout1 = _createTestWorkout(
    '${userId}_workout1',
    'Test Workout 1',
    'Bench Press',
    [
      ExerciseSetModel(
        id: 'set1',
        setNumber: 1,
        weight: 80.0,
        reps: 10,
        volume: 800.0,
        isCompleted: true,
        restTime: 60,
      ),
      ExerciseSetModel(
        id: 'set2',
        setNumber: 2,
        weight: 80.0,
        reps: 8,
        volume: 640.0,
        isCompleted: true,
        restTime: 60,
      ),
    ],
  );
  
  // Workout 2 - Older
  final workout2 = _createTestWorkout(
    '${userId}_workout2',
    'Test Workout 2',
    'Bench Press',
    [
      ExerciseSetModel(
        id: 'set1',
        setNumber: 1,
        weight: 85.0,
        reps: 8,
        volume: 680.0,
        isCompleted: true,
        restTime: 60,
      ),
      ExerciseSetModel(
        id: 'set2',
        setNumber: 2,
        weight: 85.0,
        reps: 6,
        volume: 510.0,
        isCompleted: true,
        restTime: 60,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );
  
  await box.put('${userId}_workout1', workout1.toJson());
  await box.put('${userId}_workout2', workout2.toJson());
}

/// Helper function to create test workout
WorkoutModel _createTestWorkout(
  String id,
  String name,
  String exerciseName,
  List<ExerciseSetModel> sets, {
  DateTime? createdAt,
}) {
  final totalVolume = sets.fold<double>(0.0, (sum, set) => sum + set.volume);
  
  final exercise = ExerciseModel(
    id: 'exercise1',
    name: exerciseName,
    type: 'strength',
    category: 'chest',
    sets: sets,
    restTime: 60,
    notes: '',
    isCompleted: sets.any((s) => s.isCompleted),
    totalVolume: totalVolume,
    createdAt: createdAt ?? DateTime.now(),
  );
  
  return WorkoutModel(
    id: id,
    name: name,
    exercises: [exercise],
    status: 'completed',
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: createdAt ?? DateTime.now(),
    startTime: createdAt ?? DateTime.now(),
    endTime: (createdAt ?? DateTime.now()).add(const Duration(hours: 1)),
  );
}