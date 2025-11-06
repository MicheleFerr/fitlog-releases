import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

// Mock Workout Repository for testing
class WorkoutRepository {
  final Map<String, Workout> _workouts = {};
  final Map<String, Workout> _templates = {};
  final Map<String, List<String>> _userWorkouts = {};
  final Map<String, List<String>> _userTemplates = {};
  
  // Save workout
  Future<String> saveWorkout({
    required Workout workout,
    required String userId,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Validate workout
      if (workout.name.isEmpty) {
        throw Exception('Workout name cannot be empty');
      }
      
      if (workout.status != WorkoutStatus.completed && 
          workout.status != WorkoutStatus.inProgress) {
        throw Exception('Invalid workout status for saving');
      }
      
      // Save workout
      _workouts[workout.id] = workout;
      
      // Add to user's workouts
      _userWorkouts.putIfAbsent(userId, () => []);
      if (!_userWorkouts[userId]!.contains(workout.id)) {
        _userWorkouts[userId]!.add(workout.id);
      }
      
      return workout.id;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get workout by ID
  Future<Workout?> getWorkout(String workoutId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _workouts[workoutId];
  }
  
  // Get user workouts
  Future<List<Workout>> getUserWorkouts({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final workoutIds = _userWorkouts[userId] ?? [];
    var workouts = workoutIds
        .map((id) => _workouts[id])
        .whereType<Workout>()
        .toList();
    
    // Apply date filters
    if (startDate != null) {
      workouts = workouts.where((w) => 
        w.startTime != null && 
        (w.startTime!.isAfter(startDate) || w.startTime!.isAtSameMomentAs(startDate))
      ).toList();
    }
    
    if (endDate != null) {
      workouts = workouts.where((w) => 
        w.startTime != null && 
        (w.startTime!.isBefore(endDate) || w.startTime!.isAtSameMomentAs(endDate))
      ).toList();
    }
    
    // Sort by start time descending
    workouts.sort((a, b) {
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return b.startTime!.compareTo(a.startTime!);
    });
    
    // Apply limit
    if (limit != null && workouts.length > limit) {
      workouts = workouts.take(limit).toList();
    }
    
    return workouts;
  }
  
  // Update workout
  Future<void> updateWorkout(Workout workout) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!_workouts.containsKey(workout.id)) {
      throw Exception('Workout not found');
    }
    
    _workouts[workout.id] = workout;
  }
  
  // Delete workout
  Future<bool> deleteWorkout(String workoutId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!_workouts.containsKey(workoutId)) {
      return false;
    }
    
    _workouts.remove(workoutId);
    
    // Remove from all user lists
    for (var list in _userWorkouts.values) {
      list.remove(workoutId);
    }
    
    return true;
  }
  
  // Save template
  Future<String> saveTemplate({
    required Workout template,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Templates must use planned status
    if (template.status != WorkoutStatus.planned) {
      throw Exception('Only planned workouts can be saved as templates');
    }
    
    if (template.name.isEmpty) {
      throw Exception('Template name cannot be empty');
    }
    
    _templates[template.id] = template;
    
    _userTemplates.putIfAbsent(userId, () => []);
    if (!_userTemplates[userId]!.contains(template.id)) {
      _userTemplates[userId]!.add(template.id);
    }
    
    return template.id;
  }
  
  // Get user templates
  Future<List<Workout>> getUserTemplates(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final templateIds = _userTemplates[userId] ?? [];
    final templates = templateIds
        .map((id) => _templates[id])
        .whereType<Workout>()
        .toList();
    
    // Sort by name
    templates.sort((a, b) => a.name.compareTo(b.name));
    
    return templates;
  }
  
  // Get template by ID
  Future<Workout?> getTemplate(String templateId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _templates[templateId];
  }
  
  // Delete template
  Future<bool> deleteTemplate(String templateId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!_templates.containsKey(templateId)) {
      return false;
    }
    
    _templates.remove(templateId);
    
    // Remove from all user lists
    for (var list in _userTemplates.values) {
      list.remove(templateId);
    }
    
    return true;
  }
  
  // Get workout statistics
  Future<WorkoutStatistics> getStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final workouts = await getUserWorkouts(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
    
    final completedWorkouts = workouts.where((w) => w.status == WorkoutStatus.completed).toList();
    
    int totalExercises = 0;
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;
    int totalDuration = 0;
    final Map<String, int> exerciseFrequency = {};
    
    for (final workout in completedWorkouts) {
      totalExercises += workout.exercises.length;
      
      for (final exercise in workout.exercises) {
        totalSets += exercise.sets.length;
        
        // Track exercise frequency
        exerciseFrequency[exercise.name] = (exerciseFrequency[exercise.name] ?? 0) + 1;
        
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            totalReps += set.reps ?? 0;
            if (set.weight != null && set.reps != null) {
              totalVolume += set.weight! * set.reps!;
            }
          }
        }
      }
      
      // Calculate duration
      if (workout.startTime != null && workout.endTime != null) {
        totalDuration += workout.endTime!.difference(workout.startTime!).inMinutes;
      }
    }
    
    // Find most frequent exercise
    String? favoriteExercise;
    int maxFrequency = 0;
    exerciseFrequency.forEach((exercise, frequency) {
      if (frequency > maxFrequency) {
        maxFrequency = frequency;
        favoriteExercise = exercise;
      }
    });
    
    return WorkoutStatistics(
      totalWorkouts: completedWorkouts.length,
      totalExercises: totalExercises,
      totalSets: totalSets,
      totalReps: totalReps,
      totalVolume: totalVolume,
      totalDuration: totalDuration,
      averageDuration: completedWorkouts.isNotEmpty 
        ? (totalDuration / completedWorkouts.length).round()
        : 0,
      favoriteExercise: favoriteExercise,
      lastWorkout: completedWorkouts.isNotEmpty 
        ? completedWorkouts.first.endTime
        : null,
    );
  }
  
  // Search workouts
  Future<List<Workout>> searchWorkouts({
    required String userId,
    String? query,
    ExerciseCategory? category,
  }) async {
    final workouts = await getUserWorkouts(userId: userId);
    
    var filtered = workouts;
    
    // Filter by query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((w) {
        // Check workout name
        if (w.name.toLowerCase().contains(lowerQuery)) return true;
        
        // Check exercise names
        return w.exercises.any((e) => 
          e.name.toLowerCase().contains(lowerQuery)
        );
      }).toList();
    }
    
    // Filter by category
    if (category != null) {
      filtered = filtered.where((w) {
        return w.exercises.any((e) => e.category == category);
      }).toList();
    }
    
    return filtered;
  }
  
  // Clear all data
  void clearAll() {
    _workouts.clear();
    _templates.clear();
    _userWorkouts.clear();
    _userTemplates.clear();
  }
}

class WorkoutStatistics {
  
  WorkoutStatistics({
    required this.totalWorkouts,
    required this.totalExercises,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.totalDuration,
    required this.averageDuration,
    this.favoriteExercise,
    this.lastWorkout,
  });
  final int totalWorkouts;
  final int totalExercises;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final int totalDuration; // in minutes
  final int averageDuration; // in minutes
  final String? favoriteExercise;
  final DateTime? lastWorkout;
}

void main() {
  group('🏋️ Workout Repository Tests', () {
    late WorkoutRepository repository;
    
    setUp(() {
      repository = WorkoutRepository();
    });
    
    tearDown(() {
      repository.clearAll();
    });
    
    group('💾 Save & Retrieve Workouts', () {
      test('✅ Save workout successfully', () async {
        final workout = createTestWorkout();
        
        final workoutId = await repository.saveWorkout(
          workout: workout,
          userId: 'user-123',
        );
        
        expect(workoutId, workout.id);
        
        final retrieved = await repository.getWorkout(workoutId);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, workout.id);
        expect(retrieved.name, workout.name);
      });
      
      test('✅ Get user workouts', () async {
        // Save multiple workouts
        for (int i = 0; i < 3; i++) {
          final workout = createTestWorkout(
            id: 'workout-$i',
            name: 'Workout $i',
          );
          await repository.saveWorkout(workout: workout, userId: 'user-123');
        }
        
        final workouts = await repository.getUserWorkouts(userId: 'user-123');
        
        expect(workouts.length, 3);
        expect(workouts[0].name, 'Workout 2'); // Most recent first
      });
      
      test('✅ Get workouts with limit', () async {
        for (int i = 0; i < 5; i++) {
          await repository.saveWorkout(
            workout: createTestWorkout(id: 'workout-$i'),
            userId: 'user-123',
          );
        }
        
        final workouts = await repository.getUserWorkouts(
          userId: 'user-123',
          limit: 3,
        );
        
        expect(workouts.length, 3);
      });
      
      test('❌ Save workout with empty name', () async {
        final workout = createTestWorkout(name: '');
        
        expect(
          () async => await repository.saveWorkout(
            workout: workout,
            userId: 'user-123',
          ),
          throwsException,
        );
      });
    });
    
    group('✏️ Update & Delete', () {
      test('✅ Update workout', () async {
        final workout = createTestWorkout();
        await repository.saveWorkout(workout: workout, userId: 'user-123');
        
        final updated = workout.copyWith(name: 'Updated Workout');
        await repository.updateWorkout(updated);
        
        final retrieved = await repository.getWorkout(workout.id);
        expect(retrieved!.name, 'Updated Workout');
      });
      
      test('✅ Delete workout', () async {
        final workout = createTestWorkout();
        await repository.saveWorkout(workout: workout, userId: 'user-123');
        
        final deleted = await repository.deleteWorkout(workout.id);
        expect(deleted, true);
        
        final retrieved = await repository.getWorkout(workout.id);
        expect(retrieved, isNull);
      });
      
      test('❌ Update non-existent workout', () async {
        final workout = createTestWorkout();
        
        expect(
          () async => await repository.updateWorkout(workout),
          throwsException,
        );
      });
      
      test('✅ Delete non-existent workout', () async {
        final deleted = await repository.deleteWorkout('non-existent');
        expect(deleted, false);
      });
    });
    
    group('📋 Templates', () {
      test('✅ Save template', () async {
        final template = createTestTemplate();
        
        final templateId = await repository.saveTemplate(
          template: template,
          userId: 'user-123',
        );
        
        expect(templateId, template.id);
        
        final retrieved = await repository.getTemplate(templateId);
        expect(retrieved, isNotNull);
        expect(retrieved!.status, WorkoutStatus.planned);
      });
      
      test('✅ Get user templates', () async {
        await repository.saveTemplate(
          template: createTestTemplate(id: 'template-1', name: 'Push Day'),
          userId: 'user-123',
        );
        
        await repository.saveTemplate(
          template: createTestTemplate(id: 'template-2', name: 'Pull Day'),
          userId: 'user-123',
        );
        
        final templates = await repository.getUserTemplates('user-123');
        
        expect(templates.length, 2);
        expect(templates[0].name, 'Pull Day'); // Sorted alphabetically
        expect(templates[1].name, 'Push Day');
      });
      
      test('✅ Delete template', () async {
        final template = createTestTemplate();
        await repository.saveTemplate(template: template, userId: 'user-123');
        
        final deleted = await repository.deleteTemplate(template.id);
        expect(deleted, true);
        
        final retrieved = await repository.getTemplate(template.id);
        expect(retrieved, isNull);
      });
      
      test('❌ Save non-template workout as template', () async {
        final workout = createTestWorkout(); // Not a template
        
        expect(
          () async => await repository.saveTemplate(
            template: workout,
            userId: 'user-123',
          ),
          throwsException,
        );
      });
    });
    
    group('📊 Statistics', () {
      test('✅ Calculate workout statistics', () async {
        // Save completed workouts
        for (int i = 0; i < 3; i++) {
          final workout = createTestWorkout(
            id: 'workout-$i',
            status: WorkoutStatus.completed,
            startTime: DateTime.now().subtract(Duration(days: i, hours: 1)),
            endTime: DateTime.now().subtract(Duration(days: i)),
          );
          await repository.saveWorkout(workout: workout, userId: 'user-123');
        }
        
        final stats = await repository.getStatistics(userId: 'user-123');
        
        expect(stats.totalWorkouts, 3);
        expect(stats.totalExercises, 6); // 2 exercises per workout
        expect(stats.totalSets, 12); // 4 sets per workout
        expect(stats.averageDuration, 60); // 1 hour average
        expect(stats.favoriteExercise, isNotNull);
      });
      
      test('✅ Statistics with date range', () async {
        final now = DateTime.now();
        
        // Old workout
        await repository.saveWorkout(
          workout: createTestWorkout(
            id: 'old',
            startTime: now.subtract(const Duration(days: 30)),
            endTime: now.subtract(const Duration(days: 30, hours: -1)),
          ),
          userId: 'user-123',
        );
        
        // Recent workout
        await repository.saveWorkout(
          workout: createTestWorkout(
            id: 'recent',
            startTime: now.subtract(const Duration(days: 1)),
            endTime: now,
          ),
          userId: 'user-123',
        );
        
        final stats = await repository.getStatistics(
          userId: 'user-123',
          startDate: now.subtract(const Duration(days: 7)),
        );
        
        expect(stats.totalWorkouts, 1); // Only recent workout
      });
      
      test('✅ Empty statistics', () async {
        final stats = await repository.getStatistics(userId: 'user-123');
        
        expect(stats.totalWorkouts, 0);
        expect(stats.totalExercises, 0);
        expect(stats.totalSets, 0);
        expect(stats.totalReps, 0);
        expect(stats.totalVolume, 0);
        expect(stats.favoriteExercise, isNull);
        expect(stats.lastWorkout, isNull);
      });
    });
    
    group('🔍 Search', () {
      setUp(() async {
        await repository.saveWorkout(
          workout: createTestWorkout(
            id: 'chest-workout',
            name: 'Chest Day',
            exercises: [
              Exercise(
                name: 'Bench Press',
                type: ExerciseType.single,
                category: ExerciseCategory.chest,
              ),
            ],
          ),
          userId: 'user-123',
        );
        
        await repository.saveWorkout(
          workout: createTestWorkout(
            id: 'leg-workout',
            name: 'Leg Day',
            exercises: [
              Exercise(
                name: 'Squat',
                type: ExerciseType.single,
                category: ExerciseCategory.legs,
              ),
            ],
          ),
          userId: 'user-123',
        );
      });
      
      test('✅ Search by workout name', () async {
        final results = await repository.searchWorkouts(
          userId: 'user-123',
          query: 'chest',
        );
        
        expect(results.length, 1);
        expect(results[0].name, 'Chest Day');
      });
      
      test('✅ Search by exercise name', () async {
        final results = await repository.searchWorkouts(
          userId: 'user-123',
          query: 'squat',
        );
        
        expect(results.length, 1);
        expect(results[0].name, 'Leg Day');
      });
      
      test('✅ Search by category', () async {
        final results = await repository.searchWorkouts(
          userId: 'user-123',
          category: ExerciseCategory.legs,
        );
        
        expect(results.length, 1);
        expect(results[0].exercises[0].category, ExerciseCategory.legs);
      });
      
      test('✅ Combined search', () async {
        final results = await repository.searchWorkouts(
          userId: 'user-123',
          query: 'day',
          category: ExerciseCategory.chest,
        );
        
        expect(results.length, 1);
        expect(results[0].name, 'Chest Day');
      });
      
      test('✅ No results', () async {
        final results = await repository.searchWorkouts(
          userId: 'user-123',
          query: 'non-existent',
        );
        
        expect(results, isEmpty);
      });
    });
    
    group('👥 Multi-user Support', () {
      test('✅ Separate workouts per user', () async {
        // User 1
        await repository.saveWorkout(
          workout: createTestWorkout(id: 'user1-workout'),
          userId: 'user-1',
        );
        
        // User 2
        await repository.saveWorkout(
          workout: createTestWorkout(id: 'user2-workout'),
          userId: 'user-2',
        );
        
        final user1Workouts = await repository.getUserWorkouts(userId: 'user-1');
        final user2Workouts = await repository.getUserWorkouts(userId: 'user-2');
        
        expect(user1Workouts.length, 1);
        expect(user1Workouts[0].id, 'user1-workout');
        
        expect(user2Workouts.length, 1);
        expect(user2Workouts[0].id, 'user2-workout');
      });
      
      test('✅ Separate templates per user', () async {
        await repository.saveTemplate(
          template: createTestTemplate(id: 'user1-template'),
          userId: 'user-1',
        );
        
        await repository.saveTemplate(
          template: createTestTemplate(id: 'user2-template'),
          userId: 'user-2',
        );
        
        final user1Templates = await repository.getUserTemplates('user-1');
        final user2Templates = await repository.getUserTemplates('user-2');
        
        expect(user1Templates.length, 1);
        expect(user1Templates[0].id, 'user1-template');
        
        expect(user2Templates.length, 1);
        expect(user2Templates[0].id, 'user2-template');
      });
    });
  });
}

// Helper functions
Workout createTestWorkout({
  String? id,
  String? name,
  WorkoutStatus? status,
  DateTime? startTime,
  DateTime? endTime,
  List<Exercise>? exercises,
}) {
  return Workout(
    id: id ?? 'workout-test',
    name: name ?? 'Test Workout',
    status: status ?? WorkoutStatus.completed,
    startTime: startTime ?? DateTime.now().subtract(const Duration(hours: 1)),
    endTime: endTime ?? DateTime.now(),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    exercises: exercises ?? [
      Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 60.0, isCompleted: true),
          ExerciseSet(setNumber: 2, reps: 10, weight: 60.0, isCompleted: true),
        ],
      ),
      Exercise(
        name: 'Incline Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 50.0, isCompleted: true),
          ExerciseSet(setNumber: 2, reps: 10, weight: 50.0, isCompleted: true),
        ],
      ),
    ],
  );
}

Workout createTestTemplate({
  String? id,
  String? name,
}) {
  return Workout(
    id: id ?? 'template-test',
    name: name ?? 'Test Template',
    status: WorkoutStatus.planned,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    exercises: [
      Exercise(
        name: 'Exercise 1',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, reps: 10),
          ExerciseSet(setNumber: 2, reps: 10),
        ],
      ),
    ],
  );
}