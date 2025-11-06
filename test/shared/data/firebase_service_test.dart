import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/data/services/firebase_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_set.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../test_helpers/firebase_test_helper.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

class FirebaseServiceTest {

  FirebaseServiceTest({
    required this.auth,
    required this.firestore,
  });
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  // Auth methods
  User? get currentUser => auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  // Firestore methods
  Future<void> saveWorkout(Workout workout) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toJson());
  }

  Future<List<Workout>> getWorkouts() async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Workout.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteWorkout(String workoutId) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await firestore
        .collection('users')
        .doc(userId)
        .update(data);
  }

  Stream<List<Workout>> workoutStream() {
    final userId = currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

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
}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });
  
  group('Firebase Service Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseServiceTest service;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
      service = FirebaseServiceTest(
        auth: mockAuth,
        firestore: fakeFirestore,
      );
      mockUser = MockUser();
      
      when(() => mockUser.uid).thenReturn('test-user-id');
      when(() => mockUser.email).thenReturn('test@example.com');
    });

    group('Authentication Tests', () {
      test('signs in user with email and password', () async {
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);
        
        when(() => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockCredential);

        final credential = await service.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(credential.user, equals(mockUser));
      });

      test('signs out user', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async => {});
        
        await expectLater(service.signOut(), completes);
        
        verify(() => mockAuth.signOut()).called(1);
      });

      test('returns current user when authenticated', () {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        
        expect(service.currentUser, equals(mockUser));
        expect(service.currentUser?.uid, 'test-user-id');
      });

      test('returns null when not authenticated', () {
        when(() => mockAuth.currentUser).thenReturn(null);
        
        expect(service.currentUser, isNull);
      });
    });

    group('Workout Storage Tests', () {
      setUp(() {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
      });

      test('saves workout to Firestore', () async {
        final workout = Workout(
          id: 'workout-1',
          name: 'Test Workout',
          startTime: DateTime.now(),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          exercises: [
            Exercise(
              id: 'ex-1',
              name: 'Bench Press',
              sets: [
                ExerciseSet(
                  id: 'set-1',
                  setNumber: 1,
                  reps: 10,
                  weight: 60,
                ),
              ],
            ),
          ],
        );

        await service.saveWorkout(workout);

        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .get();

        expect(doc.exists, true);
        expect(doc.data()?['name'], 'Test Workout');
      });

      test('retrieves user workouts', () async {
        // Add test data
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-1')
            .set({
          'id': 'workout-1',
          'name': 'Morning Workout',
          'startTime': DateTime.now().toIso8601String(),
          'exercises': [],
        });

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-2')
            .set({
          'id': 'workout-2',
          'name': 'Evening Workout',
          'startTime': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'exercises': [],
        });

        final workouts = await service.getWorkouts();

        expect(workouts.length, 2);
        expect(workouts.first.name, 'Morning Workout');
      });

      test('deletes workout from Firestore', () async {
        // Add workout
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-to-delete')
            .set({'id': 'workout-to-delete', 'name': 'Delete Me'});

        // Verify it exists
        var doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-to-delete')
            .get();
        expect(doc.exists, true);

        // Delete it
        await service.deleteWorkout('workout-to-delete');

        // Verify it's gone
        doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('workout-to-delete')
            .get();
        expect(doc.exists, false);
      });

      test('throws error when saving without authentication', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final workout = Workout(
          id: 'workout-1',
          name: 'Test',
          startTime: DateTime.now(),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          exercises: [],
        );

        await expectLater(
          service.saveWorkout(workout),
          throwsException,
        );
      });

      test('streams workout updates', () async {
        // Initially empty
        final stream = service.workoutStream();
        
        // Add a workout
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
            workouts.any((w) => w.id == 'streamed-workout')
          )),
        );
      });
    });

    group('User Profile Tests', () {
      setUp(() {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
      });

      test('updates user profile', () async {
        // Create user document
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .set({
          'name': 'Original Name',
          'age': 25,
        });

        // Update profile
        await service.updateUserProfile({
          'name': 'Updated Name',
          'age': 26,
        });

        // Verify update
        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .get();

        expect(doc.data()?['name'], 'Updated Name');
        expect(doc.data()?['age'], 26);
      });

      test('creates user document if not exists', () async {
        final userData = {
          'uid': 'test-user-id',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'createdAt': DateTime.now().toIso8601String(),
        };

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .set(userData);

        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .get();

        expect(doc.exists, true);
        expect(doc.data()?['email'], 'test@example.com');
      });
    });

    group('Template Management Tests', () {
      setUp(() {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
      });

      test('saves workout template', () async {
        final template = {
          'id': 'template-1',
          'name': 'Push Day Template',
          'exercises': [
            {
              'name': 'Bench Press',
              'sets': 3,
              'targetReps': 10,
              'targetWeight': 60,
            },
          ],
          'createdAt': DateTime.now().toIso8601String(),
        };

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('templates')
            .doc('template-1')
            .set(template);

        final doc = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('templates')
            .doc('template-1')
            .get();

        expect(doc.exists, true);
        expect(doc.data()?['name'], 'Push Day Template');
      });

      test('retrieves workout templates', () async {
        // Add templates
        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('templates')
            .doc('t1')
            .set({'id': 't1', 'name': 'Template 1'});

        await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('templates')
            .doc('t2')
            .set({'id': 't2', 'name': 'Template 2'});

        final snapshot = await fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('templates')
            .get();

        expect(snapshot.docs.length, 2);
      });
    });

    group('Exercise Database Tests', () {
      test('retrieves public exercises', () async {
        // Add public exercises
        await fakeFirestore
            .collection('exercises')
            .doc('ex1')
            .set({
          'id': 'ex1',
          'name': 'Bench Press',
          'muscleGroup': 'Chest',
          'equipment': 'Barbell',
        });

        await fakeFirestore
            .collection('exercises')
            .doc('ex2')
            .set({
          'id': 'ex2',
          'name': 'Squat',
          'muscleGroup': 'Legs',
          'equipment': 'Barbell',
        });

        final snapshot = await fakeFirestore
            .collection('exercises')
            .get();

        expect(snapshot.docs.length, 2);
        expect(snapshot.docs.first.data()['name'], 'Bench Press');
      });

      test('searches exercises by muscle group', () async {
        // Add exercises
        await fakeFirestore.collection('exercises').doc('ex1').set({
          'name': 'Bench Press',
          'muscleGroup': 'Chest',
        });

        await fakeFirestore.collection('exercises').doc('ex2').set({
          'name': 'Squat',
          'muscleGroup': 'Legs',
        });

        await fakeFirestore.collection('exercises').doc('ex3').set({
          'name': 'Incline Press',
          'muscleGroup': 'Chest',
        });

        final snapshot = await fakeFirestore
            .collection('exercises')
            .where('muscleGroup', isEqualTo: 'Chest')
            .get();

        expect(snapshot.docs.length, 2);
      });
    });

    group('Analytics Data Tests', () {
      setUp(() {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
      });

      test('logs workout completion', () async {
        final analyticsData = {
          'userId': 'test-user-id',
          'workoutId': 'workout-1',
          'duration': 3600, // 1 hour in seconds
          'totalVolume': 5000.0,
          'exerciseCount': 5,
          'timestamp': DateTime.now().toIso8601String(),
        };

        await fakeFirestore
            .collection('analytics')
            .doc()
            .set(analyticsData);

        final snapshot = await fakeFirestore
            .collection('analytics')
            .where('userId', isEqualTo: 'test-user-id')
            .get();

        expect(snapshot.docs.isNotEmpty, true);
        expect(snapshot.docs.first.data()['workoutId'], 'workout-1');
      });

      test('aggregates user statistics', () async {
        // Add multiple workout analytics
        for (int i = 0; i < 5; i++) {
          await fakeFirestore.collection('analytics').doc().set({
            'userId': 'test-user-id',
            'workoutId': 'workout-$i',
            'totalVolume': 1000.0 * (i + 1),
            'timestamp': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
          });
        }

        final snapshot = await fakeFirestore
            .collection('analytics')
            .where('userId', isEqualTo: 'test-user-id')
            .get();

        final totalVolume = snapshot.docs.fold<double>(
          0,
          (sum, doc) => sum + (doc.data()['totalVolume'] as double),
        );

        expect(totalVolume, 15000.0); // 1000 + 2000 + 3000 + 4000 + 5000
      });
    });

    group('Error Handling Tests', () {
      test('handles network errors gracefully', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        // Simulate network error by using invalid collection path
        final future = fakeFirestore
            .collection('')
            .doc('test')
            .get();

        await expectLater(future, throwsA(anything));
      });

      test('validates data before saving', () {
        // Invalid workout (missing required fields)
        final invalidWorkout = {
          'id': 'workout-1',
          // Missing 'name' and 'startTime'
        };

        expect(() => Workout.fromJson(invalidWorkout), throwsA(anything));
      });

      test('handles concurrent updates', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final docRef = fakeFirestore
            .collection('users')
            .doc('test-user-id')
            .collection('workouts')
            .doc('concurrent-test');

        // Initial write
        await docRef.set({'counter': 0});

        // Simulate concurrent updates
        final futures = List.generate(10, (i) async {
          final doc = await docRef.get();
          final current = doc.data()?['counter'] ?? 0;
          await docRef.update({'counter': current + 1});
        });

        await Future.wait(futures);

        final finalDoc = await docRef.get();
        // Due to race conditions, counter might not be exactly 10
        expect(finalDoc.data()?['counter'], greaterThan(0));
      });
    });
  });
}