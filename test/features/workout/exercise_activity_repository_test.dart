import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// Mock Firebase Implementation for Testing
class MockExerciseActivityRepository {
  final List<Map<String, dynamic>> _activities = [];
  
  // Simulate Firestore save
  Future<List<String>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async {
    if (!workout.isCompleted) {
      throw Exception('Il workout deve essere completato per essere salvato');
    }
    
    final savedActivityIds = <String>[];
    
    for (final exercise in workout.exercises) {
      final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
      
      if (completedSets.isNotEmpty) {
        final activityId = await saveExerciseActivity(
          exercise: exercise,
          userEmail: userEmail,
          workoutName: workout.name,
        );
        
        if (activityId != null) {
          savedActivityIds.add(activityId);
        }
      }
    }
    
    return savedActivityIds;
  }
  
  Future<String?> saveExerciseActivity({
    required Exercise exercise,
    required String userEmail,
    required String workoutName,
    String? exerciseImageUrl,
  }) async {
    try {
      final normalizedEmail = userEmail.toLowerCase().trim();
      
      // Create activity data
      final activityData = {
        'id': 'activity-${DateTime.now().millisecondsSinceEpoch}',
        'email': normalizedEmail,
        'exerciseName': exercise.name,
        'workoutName': workoutName,
        'exerciseImageUrl': exerciseImageUrl,
        'sets': exercise.sets.map((set) => {
          'reps': set.reps,
          'weight': set.weight,
          'isCompleted': set.isCompleted,
          'isWarmup': set.isWarmup,
        }).toList(),
        'totalVolume': _calculateTotalVolume(exercise),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      _activities.add(activityData);
      return activityData['id'] as String;
    } catch (e) {
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> getUserActivities({
    required String userEmail,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final normalizedEmail = userEmail.toLowerCase().trim();
    
    var filtered = _activities.where((activity) => 
      activity['email'] == normalizedEmail
    ).toList();
    
    // Apply date filters
    if (startDate != null) {
      filtered = filtered.where((activity) {
        final createdAt = DateTime.parse(activity['createdAt'] as String);
        return createdAt.isAfter(startDate) || createdAt.isAtSameMomentAs(startDate);
      }).toList();
    }
    
    if (endDate != null) {
      filtered = filtered.where((activity) {
        final createdAt = DateTime.parse(activity['createdAt'] as String);
        return createdAt.isBefore(endDate) || createdAt.isAtSameMomentAs(endDate);
      }).toList();
    }
    
    // Sort by date descending
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['createdAt'] as String);
      final dateB = DateTime.parse(b['createdAt'] as String);
      return dateB.compareTo(dateA);
    });
    
    // Apply limit
    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }
  
  Future<List<Map<String, dynamic>>> getActivitiesByExercise({
    required String userEmail,
    required String exerciseName,
    int? limit,
  }) async {
    final normalizedEmail = userEmail.toLowerCase().trim();
    
    var filtered = _activities.where((activity) => 
      activity['email'] == normalizedEmail &&
      activity['exerciseName'] == exerciseName
    ).toList();
    
    // Sort by date descending
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['createdAt'] as String);
      final dateB = DateTime.parse(b['createdAt'] as String);
      return dateB.compareTo(dateA);
    });
    
    // Apply limit
    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }
  
  Future<ExerciseStats?> getExerciseStats({
    required String userEmail,
    required String exerciseName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activities = await getActivitiesByExercise(
      userEmail: userEmail,
      exerciseName: exerciseName,
    );
    
    if (activities.isEmpty) return null;
    
    double maxWeight = 0;
    int totalVolume = 0;
    int totalSets = 0;
    int totalReps = 0;
    
    for (final activity in activities) {
      final sets = activity['sets'] as List;
      for (final set in sets) {
        if (set['isCompleted'] == true) {
          final weight = double.tryParse(set['weight'].toString()) ?? 0;
          final reps = int.tryParse(set['reps'].toString()) ?? 0;
          
          maxWeight = maxWeight > weight ? maxWeight : weight;
          totalVolume += (weight * reps).round();
          totalSets++;
          totalReps += reps;
        }
      }
    }
    
    return ExerciseStats(
      exerciseName: exerciseName,
      maxWeight: maxWeight,
      totalVolume: totalVolume,
      totalSets: totalSets,
      totalReps: totalReps,
      totalWorkouts: activities.length,
      lastWorkout: DateTime.parse(activities.first['createdAt'] as String),
    );
  }
  
  Future<bool> deleteActivity(String activityId) async {
    try {
      _activities.removeWhere((activity) => activity['id'] == activityId);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Stream simulation
  Stream<List<Map<String, dynamic>>> getUserActivitiesStream({
    required String userEmail,
    int? limit,
  }) async* {
    while (true) {
      yield await getUserActivities(userEmail: userEmail, limit: limit);
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  
  // Helper to clear all data
  void clearAll() {
    _activities.clear();
  }
  
  // Helper to calculate total volume
  double _calculateTotalVolume(Exercise exercise) {
    double volume = 0;
    for (final set in exercise.sets) {
      if (set.isCompleted && set.weight != null && set.reps != null) {
        volume += set.weight! * set.reps!;
      }
    }
    return volume;
  }
}

class ExerciseStats {
  
  ExerciseStats({
    required this.exerciseName,
    required this.maxWeight,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
    required this.totalWorkouts,
    required this.lastWorkout,
  });
  final String exerciseName;
  final double maxWeight;
  final int totalVolume;
  final int totalSets;
  final int totalReps;
  final int totalWorkouts;
  final DateTime lastWorkout;
}

void main() {
  group('🏋️ Exercise Activity Repository Tests', () {
    late MockExerciseActivityRepository repository;
    
    setUp(() {
      repository = MockExerciseActivityRepository();
    });
    
    tearDown(() {
      repository.clearAll();
    });
    
    group('💾 Save Workout Activities', () {
      test('✅ Save completed workout with multiple exercises', () async {
        final workout = createTestWorkout(isCompleted: true);
        
        final savedIds = await repository.saveCompletedWorkout(
          workout: workout,
          userEmail: 'test@example.com',
        );
        
        expect(savedIds.length, 2); // Two exercises with completed sets
        expect(savedIds.every((id) => id.startsWith('activity-')), true);
      });
      
      test('❌ Cannot save incomplete workout', () async {
        final workout = createTestWorkout(isCompleted: false);
        
        expect(
          () async => await repository.saveCompletedWorkout(
            workout: workout,
            userEmail: 'test@example.com',
          ),
          throwsException,
        );
      });
      
      test('✅ Save single exercise activity', () async {
        final exercise = createTestExercise('Bench Press');
        
        final activityId = await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: 'test@example.com',
          workoutName: 'Chest Day',
          exerciseImageUrl: 'https://example.com/bench.jpg',
        );
        
        expect(activityId, isNotNull);
        expect(activityId!.startsWith('activity-'), true);
      });
      
      test('✅ Normalize email addresses', () async {
        final exercise = createTestExercise('Squat');
        
        // Save with different email formats
        await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: 'TEST@EXAMPLE.COM',
          workoutName: 'Leg Day',
        );
        
        await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: '  test@example.com  ',
          workoutName: 'Leg Day 2',
        );
        
        // Should retrieve both with normalized email
        final activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
        );
        
        expect(activities.length, 2);
        expect(activities.every((a) => a['email'] == 'test@example.com'), true);
      });
    });
    
    group('📊 Retrieve User Activities', () {
      test('✅ Get all user activities', () async {
        // Save multiple activities
        for (int i = 0; i < 5; i++) {
          final exercise = createTestExercise('Exercise $i');
          await repository.saveExerciseActivity(
            exercise: exercise,
            userEmail: 'test@example.com',
            workoutName: 'Workout $i',
          );
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        final activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
        );
        
        expect(activities.length, 5);
        // Check descending order
        for (int i = 0; i < activities.length - 1; i++) {
          final date1 = DateTime.parse(activities[i]['createdAt'] as String);
          final date2 = DateTime.parse(activities[i + 1]['createdAt'] as String);
          expect(date1.isAfter(date2) || date1.isAtSameMomentAs(date2), true);
        }
      });
      
      test('✅ Get activities with limit', () async {
        // Save 10 activities
        for (int i = 0; i < 10; i++) {
          final exercise = createTestExercise('Exercise $i');
          await repository.saveExerciseActivity(
            exercise: exercise,
            userEmail: 'test@example.com',
            workoutName: 'Workout $i',
          );
        }
        
        final activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
          limit: 5,
        );
        
        expect(activities.length, 5);
      });
      
      test('✅ Get activities by date range', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));
        
        // Save activity
        final exercise = createTestExercise('Bench Press');
        await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: 'test@example.com',
          workoutName: 'Today Workout',
        );
        
        // Should find with date range
        final activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
          startDate: yesterday,
          endDate: tomorrow,
        );
        
        expect(activities.length, 1);
        
        // Should not find outside date range
        final noActivities = await repository.getUserActivities(
          userEmail: 'test@example.com',
          startDate: tomorrow,
        );
        
        expect(noActivities.isEmpty, true);
      });
      
      test('✅ Get activities by exercise name', () async {
        // Save different exercises
        await repository.saveExerciseActivity(
          exercise: createTestExercise('Bench Press'),
          userEmail: 'test@example.com',
          workoutName: 'Chest Day 1',
        );
        
        await repository.saveExerciseActivity(
          exercise: createTestExercise('Squat'),
          userEmail: 'test@example.com',
          workoutName: 'Leg Day',
        );
        
        await repository.saveExerciseActivity(
          exercise: createTestExercise('Bench Press'),
          userEmail: 'test@example.com',
          workoutName: 'Chest Day 2',
        );
        
        final benchActivities = await repository.getActivitiesByExercise(
          userEmail: 'test@example.com',
          exerciseName: 'Bench Press',
        );
        
        expect(benchActivities.length, 2);
        expect(benchActivities.every((a) => a['exerciseName'] == 'Bench Press'), true);
      });
    });
    
    group('📈 Exercise Statistics', () {
      test('✅ Calculate exercise stats', () async {
        // Save multiple workouts with same exercise
        for (int i = 1; i <= 3; i++) {
          final exercise = Exercise(
            id: 'bench-$i',
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(
                id: 'set-1',
                setNumber: 1,
                reps: 10,
                weight: 60.0 + (i * 5), // Increasing weight
                isCompleted: true,
              ),
              ExerciseSet(
                id: 'set-2',
                setNumber: 2,
                reps: 8,
                weight: 60.0 + (i * 5),
                isCompleted: true,
              ),
            ],
            notes: '',
            restTime: 60,
          );
          
          await repository.saveExerciseActivity(
            exercise: exercise,
            userEmail: 'test@example.com',
            workoutName: 'Workout $i',
          );
        }
        
        final stats = await repository.getExerciseStats(
          userEmail: 'test@example.com',
          exerciseName: 'Bench Press',
        );
        
        expect(stats, isNotNull);
        expect(stats!.exerciseName, 'Bench Press');
        expect(stats.maxWeight, 75.0); // Max weight from last workout
        expect(stats.totalWorkouts, 3);
        expect(stats.totalSets, 6); // 2 sets × 3 workouts
        expect(stats.totalReps, 54); // (10+8) × 3
      });
      
      test('✅ Calculate total volume correctly', () async {
        final exercise = Exercise(
          id: 'bench',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'set-1',
              setNumber: 1,
              reps: 10,
              weight: 60.0,
              isCompleted: true,
            ),
            ExerciseSet(
              id: 'set-2',
              setNumber: 2,
              reps: 10,
              weight: 60.0,
              isCompleted: true,
            ),
            ExerciseSet(
              id: 'set-3',
              setNumber: 3,
              reps: 10,
              weight: 60.0,
              isCompleted: false, // Not completed
            ),
          ],
          notes: '',
          restTime: 60,
        );
        
        await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: 'test@example.com',
          workoutName: 'Test Workout',
        );
        
        final stats = await repository.getExerciseStats(
          userEmail: 'test@example.com',
          exerciseName: 'Bench Press',
        );
        
        expect(stats!.totalVolume, 1200); // Only completed sets: 2 × 10 × 60
        expect(stats.totalSets, 2); // Only completed sets
      });
      
      test('✅ Return null for no activities', () async {
        final stats = await repository.getExerciseStats(
          userEmail: 'test@example.com',
          exerciseName: 'Non-existent Exercise',
        );
        
        expect(stats, isNull);
      });
    });
    
    group('🗑️ Delete Activities', () {
      test('✅ Delete specific activity', () async {
        final exercise = createTestExercise('Bench Press');
        final activityId = await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: 'test@example.com',
          workoutName: 'Test Workout',
        );
        
        expect(activityId, isNotNull);
        
        // Verify it exists
        var activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
        );
        expect(activities.length, 1);
        
        // Delete it
        final deleted = await repository.deleteActivity(activityId!);
        expect(deleted, true);
        
        // Verify it's gone
        activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
        );
        expect(activities.isEmpty, true);
      });
      
      test('✅ Handle delete non-existent activity', () async {
        final deleted = await repository.deleteActivity('non-existent-id');
        expect(deleted, true); // Should return true even if not found
      });
    });
    
    group('📡 Activity Stream', () {
      test('✅ Stream user activities', () async {
        final exercise = createTestExercise('Bench Press');
        
        // Listen to stream
        final streamEvents = <List<Map<String, dynamic>>>[];
        final subscription = repository.getUserActivitiesStream(
          userEmail: 'test@example.com',
        ).listen((activities) {
          streamEvents.add(activities);
        });
        
        // Wait for initial emission
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Add an activity
        await repository.saveExerciseActivity(
          exercise: exercise,
          userEmail: 'test@example.com',
          workoutName: 'Test Workout',
        );
        
        // Wait for stream update
        await Future.delayed(const Duration(milliseconds: 1100));
        
        expect(streamEvents.length, greaterThanOrEqualTo(2));
        expect(streamEvents.first.isEmpty, true); // Initially empty
        expect(streamEvents.last.length, 1); // After adding activity
        
        await subscription.cancel();
      });
    });
    
    group('🏋️ Complex Workout Scenarios', () {
      test('✅ Save workout with warmup and working sets', () async {
        final exercise = Exercise(
          id: 'bench',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'warmup-1',
              setNumber: 1,
              reps: 10,
              weight: 20.0,
              isCompleted: true,
              isWarmup: true,
            ),
            ExerciseSet(
              id: 'warmup-2',
              setNumber: 2,
              reps: 5,
              weight: 40.0,
              isCompleted: true,
              isWarmup: true,
            ),
            ExerciseSet(
              id: 'work-1',
              setNumber: 3,
              reps: 8,
              weight: 60.0,
              isCompleted: true,
              isWarmup: false,
            ),
            ExerciseSet(
              id: 'work-2',
              setNumber: 4,
              reps: 8,
              weight: 60.0,
              isCompleted: true,
              isWarmup: false,
            ),
            ExerciseSet(
              id: 'work-3',
              setNumber: 5,
              reps: 6,
              weight: 65.0,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
          notes: 'Good session',
          restTime: 90,
        );
        
        final workout = Workout(
          id: 'workout-1',
          name: 'Chest Day',
          exercises: [exercise],
          status: WorkoutStatus.completed,
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now(),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        
        final savedIds = await repository.saveCompletedWorkout(
          workout: workout,
          userEmail: 'test@example.com',
        );
        
        expect(savedIds.length, 1);
        
        // Verify saved data
        final activities = await repository.getUserActivities(
          userEmail: 'test@example.com',
        );
        
        expect(activities.length, 1);
        final savedSets = activities.first['sets'] as List;
        expect(savedSets.length, 5);
        
        // Count warmup vs working sets
        final warmupSets = savedSets.where((s) => s['isWarmup'] == true).length;
        final workingSets = savedSets.where((s) => s['isWarmup'] == false).length;
        
        expect(warmupSets, 2);
        expect(workingSets, 3);
      });
      
      test('✅ Handle workout with no completed sets', () async {
        final exercise = Exercise(
          id: 'bench',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              id: 'set-1',
              setNumber: 1,
              reps: 10,
              weight: 60.0,
              isCompleted: false,
            ),
          ],
          notes: '',
          restTime: 60,
        );
        
        final workout = Workout(
          id: 'workout-1',
          name: 'Failed Workout',
          exercises: [exercise],
          status: WorkoutStatus.completed,
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now(),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        
        final savedIds = await repository.saveCompletedWorkout(
          workout: workout,
          userEmail: 'test@example.com',
        );
        
        expect(savedIds.isEmpty, true); // No activities saved
      });
    });
  });
}

// Helper functions
Workout createTestWorkout({bool isCompleted = true}) {
  return Workout(
    id: 'workout-1',
    name: 'Test Workout',
    exercises: [
      createTestExercise('Bench Press'),
      createTestExercise('Squat'),
    ],
    status: isCompleted ? WorkoutStatus.completed : WorkoutStatus.inProgress,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    startTime: DateTime.now().subtract(const Duration(hours: 1)),
    endTime: isCompleted ? DateTime.now() : null,
  );
}

Exercise createTestExercise(String name) {
  return Exercise(
    id: 'exercise-${name.toLowerCase().replaceAll(' ', '-')}',
    name: name,
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: [
      ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        reps: 10,
        weight: 60.0,
        isCompleted: true,
      ),
      ExerciseSet(
        id: 'set-2',
        setNumber: 2,
        reps: 10,
        weight: 60.0,
        isCompleted: true,
      ),
    ],
    notes: 'Test notes',
    restTime: 60,
  );
}