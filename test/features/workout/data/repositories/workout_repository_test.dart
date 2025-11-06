import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../../test_helpers/firebase_test_helper.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

class WorkoutRepository {

  WorkoutRepository({
    required this.firestore,
    required this.auth,
  });
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  String? get userId => auth.currentUser?.uid;

  Future<void> saveWorkout(Workout workout) async {
    if (userId == null) throw Exception('User not authenticated');

    final workoutData = workout.toJson();
    workoutData['userId'] = userId;
    workoutData['lastModified'] = DateTime.now().toIso8601String();

    await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workout.id)
        .set(workoutData);
  }

  Future<Workout?> getWorkout(String workoutId) async {
    if (userId == null) throw Exception('User not authenticated');

    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .get();

    if (!doc.exists) return null;
    return Workout.fromJson(doc.data()!);
  }

  Future<List<Workout>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (userId == null) throw Exception('User not authenticated');

    Query<Map<String, dynamic>> query = firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('startTime', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startDate != null) {
      query = query.where('startTime', 
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('startTime', 
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Workout.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateWorkout(Workout workout) async {
    if (userId == null) throw Exception('User not authenticated');

    final workoutData = workout.toJson();
    workoutData['lastModified'] = DateTime.now().toIso8601String();

    await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workout.id)
        .update(workoutData);
  }

  Future<void> deleteWorkout(String workoutId) async {
    if (userId == null) throw Exception('User not authenticated');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  Stream<List<Workout>> watchWorkouts() {
    if (userId == null) return Stream.value([]);

    return firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromJson(doc.data()))
            .toList());
  }

  Future<List<Workout>> searchWorkouts(String query) async {
    if (userId == null) throw Exception('User not authenticated');

    final workouts = await getWorkouts();
    
    return workouts.where((workout) {
      final nameMatch = workout.name.toLowerCase().contains(query.toLowerCase());
      final exerciseMatch = workout.exercises.any((exercise) =>
          exercise.name.toLowerCase().contains(query.toLowerCase()));
      final notesMatch = workout.notes?.toLowerCase().contains(query.toLowerCase()) ?? false;
      
      return nameMatch || exerciseMatch || notesMatch;
    }).toList();
  }

  Future<Map<String, dynamic>> getWorkoutStatistics() async {
    if (userId == null) throw Exception('User not authenticated');

    final workouts = await getWorkouts();
    
    if (workouts.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalVolume': 0.0,
        'averageDuration': 0,
        'favoriteExercises': [],
      };
    }

    // Calculate total volume
    double totalVolume = 0;
    final Map<String, int> exerciseFrequency = {};
    int totalDuration = 0;
    int completedWorkouts = 0;

    for (final workout in workouts) {
      if (workout.isCompleted && workout.endTime != null) {
        completedWorkouts++;
        totalDuration += workout.endTime!.difference(workout.startTime).inMinutes;
      }

      for (final exercise in workout.exercises) {
        exerciseFrequency[exercise.name] = 
            (exerciseFrequency[exercise.name] ?? 0) + 1;

        for (final set in exercise.sets) {
          if (set.isCompleted) {
            final weight = set.weight ?? 0;
            final reps = set.actualReps ?? set.reps ?? 0;
            totalVolume += weight * reps;
          }
        }
      }
    }

    // Get top 5 favorite exercises
    final sortedExercises = exerciseFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final favoriteExercises = sortedExercises
        .take(5)
        .map((e) => e.key)
        .toList();

    return {
      'totalWorkouts': workouts.length,
      'completedWorkouts': completedWorkouts,
      'totalVolume': totalVolume,
      'averageDuration': completedWorkouts > 0 
          ? totalDuration ~/ completedWorkouts 
          : 0,
      'favoriteExercises': favoriteExercises,
    };
  }

  Future<void> duplicateWorkout(String workoutId, String newName) async {
    if (userId == null) throw Exception('User not authenticated');

    final original = await getWorkout(workoutId);
    if (original == null) throw Exception('Workout not found');

    final duplicate = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      startTime: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exercises: original.exercises.map((exercise) {
        return Exercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: exercise.name,
          type: exercise.type,
          category: exercise.category,
          sets: exercise.sets.map((set) {
            return ExerciseSet(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              setNumber: set.setNumber,
              weight: set.weight,
              reps: set.actualReps ?? set.reps,
            );
          }).toList(),
          notes: exercise.notes,
          restTime: exercise.restTime,
        );
      }).toList(),
      notes: original.notes,
      templateId: original.templateId,
    );

    await saveWorkout(duplicate);
  }
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });
  
  group('WorkoutRepository Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late WorkoutRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      
      when(() => mockUser.uid).thenReturn('test-user-id');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      
      repository = WorkoutRepository(
        firestore: fakeFirestore,
        auth: mockAuth,
      );
    });

    group('Save Workout', () {
      test('saves workout successfully', () async {
        final workout = Workout(
          id: 'workout-1',
          name: 'Morning Workout',
          startTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exercises: [
            Exercise(
              id: 'ex-1',
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(
                  id: 's1',
                  setNumber: 1,
                  weight: 60,
                  reps: 10,
                ),
              ],
            ),
          ],
        );

        await repository.saveWorkout(workout);

        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .get();

        expect(doc.exists, true);
        expect(doc.data()?['name'], 'Morning Workout');
        expect(doc.data()?['userId'], 'test-user-id');
        expect(doc.data()?['lastModified'], isNotNull);
      });

      test('throws error when not authenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final workout = Workout(
          id: 'workout-1',
          name: 'Test',
          startTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exercises: [],
        );

        expect(
          () => repository.saveWorkout(workout),
          throwsException,
        );
      });
    });

    group('Get Workout', () {
      test('retrieves single workout', () async {
        // Add test workout
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .set({
          'id': 'workout-1',
          'name': 'Test Workout',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [],
        });

        final workout = await repository.getWorkout('workout-1');

        expect(workout, isNotNull);
        expect(workout!.id, 'workout-1');
        expect(workout.name, 'Test Workout');
      });

      test('returns null for non-existent workout', () async {
        final workout = await repository.getWorkout('non-existent');
        expect(workout, isNull);
      });
    });

    group('Get Workouts List', () {
      setUp(() async {
        // Add multiple test workouts
        for (int i = 0; i < 5; i++) {
          await fakeFirestore
              .collection('users')
              .doc('test-user-id')
              .collection('workouts')
              .doc('workout-$i')
              .set({
            'id': 'workout-$i',
            'name': 'Workout $i',
            'startTime': DateTime.now()
                .subtract(Duration(days: i))
                .toIso8601String(),
            'exercises': [],
          });
        }
      });

      test('retrieves all workouts', () async {
        final workouts = await repository.getWorkouts();
        
        expect(workouts.length, 5);
        expect(workouts.first.name, 'Workout 0');
      });

      test('limits workout results', () async {
        final workouts = await repository.getWorkouts(limit: 3);
        
        expect(workouts.length, 3);
      });

      test('filters workouts by date range', () async {
        final startDate = DateTime.now().subtract(const Duration(days: 3));
        final endDate = DateTime.now();
        
        final workouts = await repository.getWorkouts(
          startDate: startDate,
          endDate: endDate,
        );
        
        expect(workouts.length, lessThanOrEqualTo(4));
      });
    });

    group('Update Workout', () {
      test('updates existing workout', () async {
        // Create initial workout
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .set({
          'id': 'workout-1',
          'name': 'Original Name',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [],
        });

        // Update workout
        final updatedWorkout = Workout(
          id: 'workout-1',
          name: 'Updated Name',
          startTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          exercises: [],
          status: WorkoutStatus.completed,
        );

        await repository.updateWorkout(updatedWorkout);

        // Verify update
        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .get();

        expect(doc.data()?['name'], 'Updated Name');
        expect(doc.data()?['isCompleted'], true);
        expect(doc.data()?['lastModified'], isNotNull);
      });
    });

    group('Delete Workout', () {
      test('deletes workout successfully', () async {
        // Add workout
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-to-delete')
            .set({
          'id': 'workout-to-delete',
          'name': 'Delete Me',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [],
        });

        // Delete workout
        await repository.deleteWorkout('workout-to-delete');

        // Verify deletion
        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-to-delete')
            .get();

        expect(doc.exists, false);
      });
    });

    group('Watch Workouts', () {
      test('streams workout updates', () async {
        final stream = repository.watchWorkouts();
        
        // Add a workout after stream is created
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('streamed-workout')
            .set({
          'id': 'streamed-workout',
          'name': 'Streamed Workout',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [],
        });

        // Stream should emit the new workout
        await expectLater(
          stream,
          emits(predicate<List<Workout>>((workouts) =>
              workouts.any((w) => w.id == 'streamed-workout'))),
        );
      });

      test('returns empty stream when not authenticated', () {
        when(() => mockAuth.currentUser).thenReturn(null);
        
        final stream = repository.watchWorkouts();
        
        expectLater(stream, emits([]));
      });
    });

    group('Search Workouts', () {
      setUp(() async {
        // Add workouts with different content
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .set({
          'id': 'workout-1',
          'name': 'Chest Day',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [
            {
              'id': 'ex-1',
              'name': 'Bench Press',
              'sets': [],
            },
          ],
          'notes': 'Focus on form',
        });

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-2')
            .set({
          'id': 'workout-2',
          'name': 'Leg Day',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [
            {
              'id': 'ex-2',
              'name': 'Squats',
              'sets': [],
            },
          ],
        });
      });

      test('searches by workout name', () async {
        final results = await repository.searchWorkouts('chest');
        
        expect(results.length, 1);
        expect(results.first.name, 'Chest Day');
      });

      test('searches by exercise name', () async {
        final results = await repository.searchWorkouts('bench');
        
        expect(results.length, 1);
        expect(results.first.exercises.first.name, 'Bench Press');
      });

      test('searches by notes', () async {
        final results = await repository.searchWorkouts('form');
        
        expect(results.length, 1);
        expect(results.first.notes, 'Focus on form');
      });

      test('returns empty list for no matches', () async {
        final results = await repository.searchWorkouts('xyz');
        
        expect(results, isEmpty);
      });
    });

    group('Workout Statistics', () {
      setUp(() async {
        // Add completed workouts with exercises
        final workout1 = {
          'id': 'workout-1',
          'name': 'Workout 1',
          'startTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'endTime': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'isCompleted': true,
          'exercises': [
            {
              'id': 'ex-1',
              'name': 'Bench Press',
              'sets': [
                {
                  'id': 's1',
                  'setNumber': 1,
                  'weight': 60.0,
                  'actualReps': 10,
                  'isCompleted': true,
                },
              ],
            },
          ],
        };

        final workout2 = {
          'id': 'workout-2',
          'name': 'Workout 2',
          'startTime': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
          'endTime': DateTime.now().subtract(const Duration(days: 1, hours: 1)).toIso8601String(),
          'isCompleted': true,
          'exercises': [
            {
              'id': 'ex-2',
              'name': 'Bench Press',
              'sets': [
                {
                  'id': 's2',
                  'setNumber': 1,
                  'weight': 65.0,
                  'actualReps': 10,
                  'isCompleted': true,
                },
              ],
            },
            {
              'id': 'ex-3',
              'name': 'Squats',
              'sets': [
                {
                  'id': 's3',
                  'setNumber': 1,
                  'weight': 80.0,
                  'actualReps': 10,
                  'isCompleted': true,
                },
              ],
            },
          ],
        };

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .set(workout1);

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-2')
            .set(workout2);
      });

      test('calculates workout statistics correctly', () async {
        final stats = await repository.getWorkoutStatistics();
        
        expect(stats['totalWorkouts'], 2);
        expect(stats['completedWorkouts'], 2);
        expect(stats['totalVolume'], 2050.0); // 600 + 650 + 800
        expect(stats['averageDuration'], 60); // Both workouts are 60 minutes
        expect(stats['favoriteExercises'], contains('Bench Press'));
      });

      test('returns zero stats for no workouts', () async {
        // Clear workouts
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .delete();
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-2')
            .delete();

        final stats = await repository.getWorkoutStatistics();
        
        expect(stats['totalWorkouts'], 0);
        expect(stats['totalVolume'], 0.0);
        expect(stats['averageDuration'], 0);
        expect(stats['favoriteExercises'], isEmpty);
      });
    });

    group('Duplicate Workout', () {
      test('duplicates workout with new name', () async {
        // Create original workout
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('original')
            .set({
          'id': 'original',
          'name': 'Original Workout',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [
            {
              'id': 'ex-1',
              'name': 'Bench Press',
              'sets': [
                {
                  'id': 's1',
                  'setNumber': 1,
                  'weight': 60.0,
                  'actualReps': 10,
                  'isCompleted': true,
                },
              ],
            },
          ],
          'notes': 'Great workout',
        });

        await repository.duplicateWorkout('original', 'Duplicated Workout');

        final workouts = await repository.getWorkouts();
        final duplicated = workouts.firstWhere((w) => w.name == 'Duplicated Workout');
        
        expect(duplicated.name, 'Duplicated Workout');
        expect(duplicated.exercises.length, 1);
        expect(duplicated.exercises.first.name, 'Bench Press');
        expect(duplicated.notes, 'Great workout');
        expect(duplicated.id, isNot('original'));
      });

      test('throws error for non-existent workout', () async {
        expect(
          () => repository.duplicateWorkout('non-existent', 'New Name'),
          throwsException,
        );
      });
    });
  });
}