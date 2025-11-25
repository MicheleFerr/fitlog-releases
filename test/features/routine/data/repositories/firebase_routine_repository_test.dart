/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/routine/data/repositories
/// 🎯 Feature: flexible_routine
/// 🔧 Type: integration test
/// 📱 Platform: Universal
///
/// FIREBASE ROUTINE REPOSITORY INTEGRATION TESTS - v2.0
///
/// Tests:
/// - createRoutine (auto-deactivates existing, creates new as active)
/// - updateRoutine (auto-updates updatedAt timestamp)
/// - deleteRoutine (auto-activates most recent inactive if deleted was active)
/// - getActiveRoutine (one-time read)
/// - watchActiveRoutine (real-time stream)
/// - watchUserRoutines (real-time stream with sorting)
/// - deactivateAllRoutines (batch operation)
/// - activateRoutine (batch operation with deactivation)
///
/// Uses FakeFirebaseFirestore for isolated testing.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/data/repositories/firebase_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';

void main() {
  group('FirebaseRoutineRepository Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseRoutineRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = FirebaseRoutineRepository(firestore: fakeFirestore);
    });

    // Helper: Create sample routine
    FlexibleRoutine createSampleRoutine({
      required String id,
      required String userId,
      required String name,
      bool isActive = true,
      DateTime? createdAt,
    }) {
      final now = createdAt ?? DateTime(2025, 1, 15, 10, 30);
      return FlexibleRoutine(
        id: id,
        userId: userId,
        name: name,
        description: 'Test routine',
        presetType: RoutinePreset.ppl6Day,
        trainingDays: const {1, 2, 3, 4, 5, 6},
        workoutSchedule: const {
          1: 'template-push',
          2: 'template-pull',
          3: 'template-legs',
        },
        isActive: isActive,
        completedDays: const {},
        totalWorkouts: 0,
        createdAt: now,
        updatedAt: now,
      );
    }

    // ──────────────────────────────────────────────────────────────────────────
    // CREATE
    // ──────────────────────────────────────────────────────────────────────────

    group('createRoutine', () {
      test('creates routine in Firestore', () async {
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'PPL 6-Day',
        );

        await repository.createRoutine(routine);

        // Verify document exists
        final doc = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        expect(doc.exists, true);
        expect(doc.data()!['name'], 'PPL 6-Day');
        expect(doc.data()!['userId'], 'user-123');
        expect(doc.data()!['isActive'], true);
      });

      test('deactivates existing active routines when creating new routine',
          () async {
        // Step 1: Create first routine
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'First Routine',
        );
        await repository.createRoutine(routine1);

        // Step 2: Create second routine (should deactivate first)
        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-123',
          name: 'Second Routine',
        );
        await repository.createRoutine(routine2);

        // Step 3: Verify first routine is now inactive
        final doc1 = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        expect(doc1.data()!['isActive'], false);

        // Step 4: Verify second routine is active
        final doc2 = await fakeFirestore
            .collection('routines')
            .doc('routine-2')
            .get();

        expect(doc2.data()!['isActive'], true);
      });

      test('only deactivates routines for same user (isolation)', () async {
        // Step 1: Create routine for user-123
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'User 123 Routine',
        );
        await repository.createRoutine(routine1);

        // Step 2: Create routine for user-456 (should NOT affect user-123)
        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-456',
          name: 'User 456 Routine',
        );
        await repository.createRoutine(routine2);

        // Step 3: Verify user-123 routine still active
        final doc1 = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        expect(doc1.data()!['isActive'], true);
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // UPDATE
    // ──────────────────────────────────────────────────────────────────────────

    group('updateRoutine', () {
      test('updates routine fields in Firestore', () async {
        // Step 1: Create routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Original Name',
        );
        await repository.createRoutine(routine);

        // Step 2: Update routine
        final updatedRoutine = routine.copyWith(
          name: 'Updated Name',
          description: 'Updated description',
        );
        await repository.updateRoutine(updatedRoutine);

        // Step 3: Verify changes
        final doc = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        expect(doc.data()!['name'], 'Updated Name');
        expect(doc.data()!['description'], 'Updated description');
      });

      test('automatically updates updatedAt timestamp', () async {
        // Step 1: Create routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Test Routine',
          createdAt: DateTime(2025, 1, 1), // Old timestamp
        );
        await repository.createRoutine(routine);

        // Step 2: Update routine
        await repository.updateRoutine(routine.copyWith(name: 'New Name'));

        // Step 3: Verify updatedAt is newer than createdAt
        final doc = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        final createdAt = (doc.data()!['createdAt'] as Timestamp).toDate();
        final updatedAt = (doc.data()!['updatedAt'] as Timestamp).toDate();

        expect(updatedAt.isAfter(createdAt), true);
      });

      test('throws exception when updating non-existent routine', () async {
        final nonExistentRoutine = createSampleRoutine(
          id: 'non-existent',
          userId: 'user-123',
          name: 'Ghost Routine',
        );

        expect(
          () => repository.updateRoutine(nonExistentRoutine),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // DELETE
    // ──────────────────────────────────────────────────────────────────────────

    group('deleteRoutine', () {
      test('deletes routine from Firestore', () async {
        // Step 1: Create routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'To Be Deleted',
        );
        await repository.createRoutine(routine);

        // Step 2: Delete routine
        await repository.deleteRoutine('routine-1');

        // Step 3: Verify document deleted
        final doc = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        expect(doc.exists, false);
      });

      test(
          'auto-activates most recent inactive routine when deleting active routine',
          () async {
        // Step 1: Create two routines (second will be active)
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'First Routine',
          createdAt: DateTime(2025, 1, 10),
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-123',
          name: 'Second Routine (Active)',
          createdAt: DateTime(2025, 1, 15),
        );
        await repository.createRoutine(routine2); // This deactivates routine-1

        // Step 2: Delete active routine (routine-2)
        await repository.deleteRoutine('routine-2');

        // Step 3: Verify routine-1 is now active again
        final doc1 = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        expect(doc1.data()!['isActive'], true);
      });

      test(
          'does nothing when deleting inactive routine (no auto-activation needed)',
          () async {
        // Step 1: Create two routines (second is active)
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Inactive',
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-123',
          name: 'Active',
        );
        await repository.createRoutine(routine2); // This deactivates routine-1

        // Step 2: Delete inactive routine (routine-1)
        await repository.deleteRoutine('routine-1');

        // Step 3: Verify routine-2 still active (unchanged)
        final doc2 = await fakeFirestore
            .collection('routines')
            .doc('routine-2')
            .get();

        expect(doc2.data()!['isActive'], true);
      });

      test('throws exception when deleting non-existent routine', () async {
        expect(
          () => repository.deleteRoutine('non-existent'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // READ (One-time)
    // ──────────────────────────────────────────────────────────────────────────

    group('getActiveRoutine', () {
      test('returns active routine for user', () async {
        // Step 1: Create active routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Active Routine',
        );
        await repository.createRoutine(routine);

        // Step 2: Get active routine
        final result = await repository.getActiveRoutine('user-123');

        // Step 3: Verify result
        expect(result, isNotNull);
        expect(result!.id, 'routine-1');
        expect(result.name, 'Active Routine');
        expect(result.isActive, true);
      });

      test('returns null when no active routine exists', () async {
        // No routines created
        final result = await repository.getActiveRoutine('user-123');

        expect(result, isNull);
      });

      test('returns null when user has only inactive routines', () async {
        // Step 1: Create inactive routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Inactive Routine',
          isActive: false,
        );
        await repository.createRoutine(routine);

        // Step 2: Manually deactivate it (create already makes it active)
        await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .update({'isActive': false});

        // Step 3: Get active routine (should be null)
        final result = await repository.getActiveRoutine('user-123');

        expect(result, isNull);
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // WATCH (Real-time Streams)
    // ──────────────────────────────────────────────────────────────────────────

    group('watchActiveRoutine', () {
      test('emits active routine when it exists', () async {
        // Step 1: Create active routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Active Routine',
        );
        await repository.createRoutine(routine);

        // Step 2: Watch active routine
        final stream = repository.watchActiveRoutine('user-123');

        // Step 3: Verify emission
        await expectLater(
          stream,
          emits(predicate<FlexibleRoutine?>(
            (r) => r != null && r.id == 'routine-1' && r.isActive == true,
          )),
        );
      });

      test('emits null when no active routine exists', () async {
        // No routines created
        final stream = repository.watchActiveRoutine('user-123');

        await expectLater(stream, emits(null));
      });

      test('emits updates when active routine changes', () async {
        // Step 1: Create active routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Original Name',
        );
        await repository.createRoutine(routine);

        // Step 2: Watch active routine
        final stream = repository.watchActiveRoutine('user-123');

        // Step 3: Update routine after short delay
        Future.delayed(const Duration(milliseconds: 100), () async {
          await repository.updateRoutine(routine.copyWith(name: 'Updated Name'));
        });

        // Step 4: Verify stream emits both original and updated
        await expectLater(
          stream,
          emitsInOrder([
            predicate<FlexibleRoutine?>(
                (r) => r != null && r.name == 'Original Name'),
            predicate<FlexibleRoutine?>(
                (r) => r != null && r.name == 'Updated Name'),
          ]),
        );
      });
    });

    group('watchUserRoutines', () {
      test('emits empty list when user has no routines', () async {
        final stream = repository.watchUserRoutines('user-123');

        await expectLater(stream, emits([]));
      });

      test('emits all user routines sorted by createdAt descending', () async {
        // Step 1: Create 3 routines with different timestamps
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'First',
          createdAt: DateTime(2025, 1, 10),
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-123',
          name: 'Second',
          createdAt: DateTime(2025, 1, 15),
        );
        await repository.createRoutine(routine2);

        final routine3 = createSampleRoutine(
          id: 'routine-3',
          userId: 'user-123',
          name: 'Third',
          createdAt: DateTime(2025, 1, 20),
        );
        await repository.createRoutine(routine3);

        // Step 2: Watch user routines
        final stream = repository.watchUserRoutines('user-123');

        // Step 3: Verify emission (descending order: Third, Second, First)
        await expectLater(
          stream,
          emits(predicate<List<FlexibleRoutine>>((list) {
            return list.length == 3 &&
                list[0].name == 'Third' &&
                list[1].name == 'Second' &&
                list[2].name == 'First';
          })),
        );
      });

      test('only emits routines for specified user (isolation)', () async {
        // Step 1: Create routines for two users
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'User 123 Routine',
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-456',
          name: 'User 456 Routine',
        );
        await repository.createRoutine(routine2);

        // Step 2: Watch user-123 routines
        final stream = repository.watchUserRoutines('user-123');

        // Step 3: Verify only user-123 routine emitted
        await expectLater(
          stream,
          emits(predicate<List<FlexibleRoutine>>(
            (list) => list.length == 1 && list.first.userId == 'user-123',
          )),
        );
      });

      test('emits updates when routines are added/removed', () async {
        // Step 1: Watch user routines (initially empty)
        final stream = repository.watchUserRoutines('user-123');

        // Step 2: Create routine after short delay
        Future.delayed(const Duration(milliseconds: 100), () async {
          final routine = createSampleRoutine(
            id: 'routine-1',
            userId: 'user-123',
            name: 'New Routine',
          );
          await repository.createRoutine(routine);
        });

        // Step 3: Verify stream emits empty list then list with 1 routine
        await expectLater(
          stream,
          emitsInOrder([
            [], // Initial empty
            predicate<List<FlexibleRoutine>>(
                (list) => list.length == 1 && list.first.name == 'New Routine'),
          ]),
        );
      });
    });

    // ──────────────────────────────────────────────────────────────────────────
    // BATCH OPERATIONS
    // ──────────────────────────────────────────────────────────────────────────

    group('deactivateAllRoutines', () {
      test('deactivates all active routines for user', () async {
        // Step 1: Create 3 active routines (third will be active due to create logic)
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'First',
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-123',
          name: 'Second',
        );
        await repository.createRoutine(routine2);

        final routine3 = createSampleRoutine(
          id: 'routine-3',
          userId: 'user-123',
          name: 'Third',
        );
        await repository.createRoutine(routine3);

        // Step 2: Manually reactivate all (for testing)
        await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .update({'isActive': true});
        await fakeFirestore
            .collection('routines')
            .doc('routine-2')
            .update({'isActive': true});

        // Step 3: Deactivate all
        await repository.deactivateAllRoutines('user-123');

        // Step 4: Verify all routines are inactive
        final doc1 = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();
        final doc2 = await fakeFirestore
            .collection('routines')
            .doc('routine-2')
            .get();
        final doc3 = await fakeFirestore
            .collection('routines')
            .doc('routine-3')
            .get();

        expect(doc1.data()!['isActive'], false);
        expect(doc2.data()!['isActive'], false);
        expect(doc3.data()!['isActive'], false);
      });

      test('only deactivates routines for specified user', () async {
        // Step 1: Create routines for two users
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'User 123',
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-456',
          name: 'User 456',
        );
        await repository.createRoutine(routine2);

        // Step 2: Deactivate all for user-123
        await repository.deactivateAllRoutines('user-123');

        // Step 3: Verify user-123 inactive, user-456 still active
        final doc1 = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();
        final doc2 = await fakeFirestore
            .collection('routines')
            .doc('routine-2')
            .get();

        expect(doc1.data()!['isActive'], false);
        expect(doc2.data()!['isActive'], true);
      });

      test('does nothing when user has no active routines', () async {
        // No routines created - should not throw
        expect(
          () => repository.deactivateAllRoutines('user-123'),
          returnsNormally,
        );
      });
    });

    group('activateRoutine', () {
      test('activates specified routine and deactivates others', () async {
        // Step 1: Create two routines (second is active)
        final routine1 = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'First',
        );
        await repository.createRoutine(routine1);

        final routine2 = createSampleRoutine(
          id: 'routine-2',
          userId: 'user-123',
          name: 'Second (Active)',
        );
        await repository.createRoutine(routine2); // This deactivates routine-1

        // Step 2: Activate routine-1
        await repository.activateRoutine('routine-1');

        // Step 3: Verify routine-1 active, routine-2 inactive
        final doc1 = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();
        final doc2 = await fakeFirestore
            .collection('routines')
            .doc('routine-2')
            .get();

        expect(doc1.data()!['isActive'], true);
        expect(doc2.data()!['isActive'], false);
      });

      test('updates updatedAt timestamp when activating', () async {
        // Step 1: Create routine
        final routine = createSampleRoutine(
          id: 'routine-1',
          userId: 'user-123',
          name: 'Test',
          createdAt: DateTime(2025, 1, 1), // Old timestamp
        );
        await repository.createRoutine(routine);

        // Step 2: Activate routine
        await repository.activateRoutine('routine-1');

        // Step 3: Verify updatedAt is newer
        final doc = await fakeFirestore
            .collection('routines')
            .doc('routine-1')
            .get();

        final createdAt = (doc.data()!['createdAt'] as Timestamp).toDate();
        final updatedAt = (doc.data()!['updatedAt'] as Timestamp).toDate();

        expect(updatedAt.isAfter(createdAt), true);
      });

      test('throws exception when activating non-existent routine', () async {
        expect(
          () => repository.activateRoutine('non-existent'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
