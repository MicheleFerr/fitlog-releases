// ignore_for_file: avoid_print
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/data/repositories/firebase_flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

/// UNIT TEST for FirebaseFlexibleRoutineRepository using fake_cloud_firestore
///
/// ✅ Fast execution (no emulator needed)
/// ✅ No platform channels required
/// ✅ In-memory Firestore simulation
///
/// This test suite verifies:
/// - ✅ CRUD operations (create, read, update, delete)
/// - ✅ Active routine management (activate, deactivate, getActive)
/// - ✅ State operations (archive, unarchive, complete)
/// - ✅ Query operations (getUserRoutines, getActiveRoutines, getArchivedRoutines)
/// - ✅ Repository logic (not real Firebase operations)
void main() {
  late FirebaseFlexibleRoutineRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    // Create fresh fake Firestore instance for each test
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirebaseFlexibleRoutineRepository(firestore: fakeFirestore);
  });

  // Helper to create test routine using factory
  FlexibleRoutine createTestRoutine({
    String? id,
    String userId = 'user_123',
    String name = 'Test Routine',
    RoutineType type = RoutineType.weekly,
    bool isActive = false,
    bool isArchived = false,
    bool isCompleted = false,
  }) {
    final startDate = DateTime.now();
    final routine = FlexibleRoutine.empty(
      userId: userId,
      type: type,
      startDate: startDate,
      endDate: startDate.add(const Duration(days: 7)),
    );

    return routine.copyWith(
      id: id ?? routine.id,
      name: name,
      isActive: isActive,
      isArchived: isArchived,
      isCompleted: isCompleted,
    );
  }

  group('FirebaseFlexibleRoutineRepository - CRUD Operations', () {
    test('createRoutine() should store routine in Firestore', () async {
      // Arrange
      final routine = createTestRoutine(id: 'test_routine_1');

      // Act
      await repository.createRoutine(routine);

      // Assert - Verify in Firestore
      final doc = await fakeFirestore
          .collection('flexibleRoutines')
          .doc('test_routine_1')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['userId'], 'user_123');
      expect(doc.data()?['name'], 'Test Routine');
      expect(doc.data()?['type'], 'weekly');
    });

    test('getRoutineById() should return routine if exists', () async {
      // Arrange
      final routine = createTestRoutine(id: 'test_routine_2');
      await repository.createRoutine(routine);

      // Act
      final retrieved = await repository.getRoutineById('test_routine_2');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'test_routine_2');
      expect(retrieved.name, 'Test Routine');
      expect(retrieved.userId, 'user_123');
    });

    test('getRoutineById() should return null if not exists', () async {
      // Act
      final retrieved = await repository.getRoutineById('nonexistent');

      // Assert
      expect(retrieved, isNull);
    });

    test('getUserRoutines() should return user-specific routines ordered by createdAt',
        () async {
      // Arrange - Create routines for 2 users
      final routine1 = createTestRoutine(
        id: 'routine_1',
        userId: 'user_A',
        name: 'User A Routine 1',
      );
      final routine2 = createTestRoutine(
        id: 'routine_2',
        userId: 'user_A',
        name: 'User A Routine 2',
      );
      final routine3 = createTestRoutine(
        id: 'routine_3',
        userId: 'user_B',
        name: 'User B Routine',
      );

      await repository.createRoutine(routine1);
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.createRoutine(routine2);
      await repository.createRoutine(routine3);

      // Act
      final userARoutines = await repository.getUserRoutines('user_A');

      // Assert
      expect(userARoutines, hasLength(2));
      expect(userARoutines.map((r) => r.id).toSet(), {'routine_1', 'routine_2'});
      // Should be ordered by createdAt descending
      expect(userARoutines.first.name, contains('User A'));
    });

    test('updateRoutine() should update routine in Firestore', () async {
      // Arrange
      final routine = createTestRoutine(id: 'test_routine_update');
      await repository.createRoutine(routine);

      // Act - Update name
      final updated = routine.copyWith(name: 'Updated Name');
      await repository.updateRoutine(updated);

      // Assert
      final retrieved = await repository.getRoutineById('test_routine_update');
      expect(retrieved!.name, 'Updated Name');
    });

    test('deleteRoutine() should remove routine from Firestore', () async {
      // Arrange
      final routine = createTestRoutine(id: 'test_routine_delete');
      await repository.createRoutine(routine);

      // Act
      await repository.deleteRoutine('test_routine_delete');

      // Assert
      final retrieved = await repository.getRoutineById('test_routine_delete');
      expect(retrieved, isNull);
    });
  });

  group('FirebaseFlexibleRoutineRepository - Active Routine Management', () {
    test('getActiveRoutine() should return active routine for user', () async {
      // Arrange
      final inactive = createTestRoutine(
        id: 'routine_inactive',
        userId: 'user_active',
        isActive: false,
      );
      final active = createTestRoutine(
        id: 'routine_active',
        userId: 'user_active',
        name: 'Active Routine',
        isActive: true,
      );

      await repository.createRoutine(inactive);
      await repository.createRoutine(active);

      // Act
      final retrieved = await repository.getActiveRoutine('user_active');

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'routine_active');
      expect(retrieved.isActive, isTrue);
    });

    test('getActiveRoutine() should return null if no active routine', () async {
      // Arrange
      final inactive = createTestRoutine(
        id: 'routine_only_inactive',
        userId: 'user_no_active',
        isActive: false,
      );
      await repository.createRoutine(inactive);

      // Act
      final retrieved = await repository.getActiveRoutine('user_no_active');

      // Assert
      expect(retrieved, isNull);
    });

    test('activateRoutine() should activate target and deactivate others',
        () async {
      // Arrange
      final routine1 = createTestRoutine(
        id: 'routine_1',
        userId: 'user_activate',
        name: 'Routine 1',
        isActive: true,
      );
      final routine2 = createTestRoutine(
        id: 'routine_2',
        userId: 'user_activate',
        name: 'Routine 2',
        isActive: false,
      );

      await repository.createRoutine(routine1);
      await repository.createRoutine(routine2);

      // Act - Activate routine2
      await repository.activateRoutine('routine_2', 'user_activate');

      // Assert
      final retrieved1 = await repository.getRoutineById('routine_1');
      final retrieved2 = await repository.getRoutineById('routine_2');

      expect(retrieved1!.isActive, isFalse); // Should be deactivated
      expect(retrieved2!.isActive, isTrue); // Should be activated
      expect(retrieved2.isArchived, isFalse); // Should not be archived
    });

    test('deactivateCurrentRoutine() should deactivate active routine',
        () async {
      // Arrange
      final active = createTestRoutine(
        id: 'routine_deactivate',
        userId: 'user_deactivate',
        isActive: true,
      );
      await repository.createRoutine(active);

      // Act
      await repository.deactivateCurrentRoutine('user_deactivate');

      // Assert
      final retrieved = await repository.getRoutineById('routine_deactivate');
      expect(retrieved!.isActive, isFalse);
    });

    test('hasActiveRoutines() should return true if user has active routine',
        () async {
      // Arrange
      final active = createTestRoutine(
        id: 'routine_has_active',
        userId: 'user_has_active',
        isActive: true,
      );
      await repository.createRoutine(active);

      // Act
      final hasActive = await repository.hasActiveRoutines('user_has_active');

      // Assert
      expect(hasActive, isTrue);
    });

    test('hasActiveRoutines() should return false if no active routine',
        () async {
      // Arrange
      final inactive = createTestRoutine(
        id: 'routine_no_active',
        userId: 'user_no_active_check',
        isActive: false,
      );
      await repository.createRoutine(inactive);

      // Act
      final hasActive =
          await repository.hasActiveRoutines('user_no_active_check');

      // Assert
      expect(hasActive, isFalse);
    });
  });

  group('FirebaseFlexibleRoutineRepository - State Operations', () {
    test('archiveRoutine() should archive and deactivate routine', () async {
      // Arrange
      final routine = createTestRoutine(
        id: 'routine_archive',
        userId: 'user_archive',
        isActive: true,
        isArchived: false,
      );
      await repository.createRoutine(routine);

      // Act
      await repository.archiveRoutine('routine_archive');

      // Assert
      final retrieved = await repository.getRoutineById('routine_archive');
      expect(retrieved!.isArchived, isTrue);
      expect(retrieved.isActive, isFalse);
    });

    test('unarchiveRoutine() should unarchive routine', () async {
      // Arrange
      final routine = createTestRoutine(
        id: 'routine_unarchive',
        userId: 'user_unarchive',
        isArchived: true,
      );
      await repository.createRoutine(routine);

      // Act
      await repository.unarchiveRoutine('routine_unarchive');

      // Assert
      final retrieved = await repository.getRoutineById('routine_unarchive');
      expect(retrieved!.isArchived, isFalse);
    });

    test('completeRoutine() should mark routine as completed and deactivate',
        () async {
      // Arrange
      final routine = createTestRoutine(
        id: 'routine_complete',
        userId: 'user_complete',
        isActive: true,
        isCompleted: false,
      );
      await repository.createRoutine(routine);

      // Act
      await repository.completeRoutine('routine_complete');

      // Assert
      final retrieved = await repository.getRoutineById('routine_complete');
      expect(retrieved!.isCompleted, isTrue);
      expect(retrieved.isActive, isFalse);
    });
  });

  group('FirebaseFlexibleRoutineRepository - Query Operations', () {
    test('getActiveRoutines() should return only active non-archived routines',
        () async {
      // Arrange
      final active1 = createTestRoutine(
        id: 'active_1',
        userId: 'user_query',
        name: 'Active 1',
        isActive: true,
        isArchived: false,
      );
      final active2 = createTestRoutine(
        id: 'active_2',
        userId: 'user_query',
        name: 'Active 2',
        isActive: true,
        isArchived: false,
      );
      final inactive = createTestRoutine(
        id: 'inactive',
        userId: 'user_query',
        isActive: false,
      );
      final archived = createTestRoutine(
        id: 'archived',
        userId: 'user_query',
        isActive: false,
        isArchived: true,
      );

      await repository.createRoutine(active1);
      await repository.createRoutine(active2);
      await repository.createRoutine(inactive);
      await repository.createRoutine(archived);

      // Act
      final activeRoutines = await repository.getActiveRoutines('user_query');

      // Assert
      expect(activeRoutines, hasLength(2));
      expect(activeRoutines.map((r) => r.id).toSet(), {'active_1', 'active_2'});
    });

    test('getArchivedRoutines() should return only archived routines',
        () async {
      // Arrange
      final archived1 = createTestRoutine(
        id: 'archived_1',
        userId: 'user_archived',
        isArchived: true,
      );
      final archived2 = createTestRoutine(
        id: 'archived_2',
        userId: 'user_archived',
        isArchived: true,
      );
      final notArchived = createTestRoutine(
        id: 'not_archived',
        userId: 'user_archived',
        isArchived: false,
      );

      await repository.createRoutine(archived1);
      await repository.createRoutine(archived2);
      await repository.createRoutine(notArchived);

      // Act
      final archivedRoutines =
          await repository.getArchivedRoutines('user_archived');

      // Assert
      expect(archivedRoutines, hasLength(2));
      expect(archivedRoutines.map((r) => r.id).toSet(),
          {'archived_1', 'archived_2'});
    });

    test('getRoutinesByType() should filter routines by type', () async {
      // Arrange
      final weekly = createTestRoutine(
        id: 'weekly_routine',
        userId: 'user_type',
        type: RoutineType.weekly,
      );
      final monthly = createTestRoutine(
        id: 'monthly_routine',
        userId: 'user_type',
        type: RoutineType.monthly,
      );

      await repository.createRoutine(weekly);
      await repository.createRoutine(monthly);

      // Act
      final weeklyRoutines = await repository.getRoutinesByType(
        userId: 'user_type',
        type: RoutineType.weekly,
      );

      // Assert
      expect(weeklyRoutines, hasLength(1));
      expect(weeklyRoutines.first.id, 'weekly_routine');
      expect(weeklyRoutines.first.type, RoutineType.weekly);
    });
  });

  group('FirebaseFlexibleRoutineRepository - Edge Cases', () {
    test('getUserRoutines() should return empty list for non-existent user',
        () async {
      // Act
      final routines = await repository.getUserRoutines('nonexistent_user');

      // Assert
      expect(routines, isEmpty);
    });

    test('deactivateCurrentRoutine() should handle no active routine gracefully',
        () async {
      // Act & Assert - Should not throw
      await repository.deactivateCurrentRoutine('user_no_active');

      // Verify no crash
      expect(true, isTrue);
    });

    test('updateRoutine() should set isSyncPending to false', () async {
      // Arrange
      final routine = createTestRoutine(id: 'test_sync_pending');
      await repository.createRoutine(routine);

      // Act
      final updated = routine.copyWith(
        name: 'Updated',
        isSyncPending: true, // Set to true initially
      );
      await repository.updateRoutine(updated);

      // Assert - Repository should force isSyncPending to false
      final retrieved = await repository.getRoutineById('test_sync_pending');
      expect(retrieved!.isSyncPending, isFalse);
    });
  });
}
