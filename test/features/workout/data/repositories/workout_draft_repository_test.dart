import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_draft_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

// Mocks
class MockHiveBoxManagerEnhanced extends Mock implements HiveBoxManagerEnhanced {}
class MockBox<T> extends Mock implements Box<T> {}

// Fake for registerFallbackValue
class FakeWorkoutDraft extends Fake implements WorkoutDraft {}

void main() {
  late WorkoutDraftRepository repository;
  late MockHiveBoxManagerEnhanced mockBoxManager;
  late MockBox<WorkoutDraft> mockDraftBox;
  late MockBox<dynamic> mockRecoveredBox;

  setUpAll(() {
    registerFallbackValue(FakeWorkoutDraft());
  });

  setUp(() {
    mockBoxManager = MockHiveBoxManagerEnhanced();
    mockDraftBox = MockBox<WorkoutDraft>();
    mockRecoveredBox = MockBox<dynamic>();

    // Default Hive setup
    when(() => mockBoxManager.openBox<WorkoutDraft>('workout_drafts'))
        .thenAnswer((_) async => mockDraftBox);
    when(() => mockBoxManager.openBox('recovered_drafts'))
        .thenAnswer((_) async => mockRecoveredBox);

    // Default box behavior
    when(() => mockDraftBox.isOpen).thenReturn(true);
    when(() => mockDraftBox.get(any())).thenReturn(null);
    when(() => mockDraftBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockDraftBox.delete(any())).thenAnswer((_) async {});
    when(() => mockDraftBox.close()).thenAnswer((_) async {});

    when(() => mockRecoveredBox.isOpen).thenReturn(true);
    when(() => mockRecoveredBox.get(any())).thenReturn(null);
    when(() => mockRecoveredBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockRecoveredBox.close()).thenAnswer((_) async {});

    repository = WorkoutDraftRepository(mockBoxManager);
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('WorkoutDraftRepository - Initialization', () {
    test('should initialize draft box successfully', () async {
      // Act
      await repository.init();

      // Assert
      verify(() => mockBoxManager.openBox<WorkoutDraft>('workout_drafts')).called(1);
    });

    test('should initialize recovered drafts box', () async {
      // Act
      await repository.init();

      // Assert
      verify(() => mockBoxManager.openBox('recovered_drafts')).called(1);
    });
  });

  group('WorkoutDraftRepository - Save Current Draft', () {
    test('should save workout as draft', () async {
      // Arrange
      final workout = _createTestWorkout();

      // Act
      await repository.saveCurrentDraft(workout);

      // Assert
      verify(() => mockDraftBox.put('current_draft', any(
        that: isA<WorkoutDraft>().having(
          (d) => d.metadata?['workoutName'],
          'workoutName in metadata',
          'Test Workout'
        )
      ))).called(1);
    });

    test('should serialize workout as JSON string', () async {
      // Arrange
      final workout = _createTestWorkout();
      WorkoutDraft? savedDraft;

      when(() => mockDraftBox.put(any(), any())).thenAnswer((invocation) async {
        savedDraft = invocation.positionalArguments[1] as WorkoutDraft;
      });

      // Act
      await repository.saveCurrentDraft(workout);

      // Assert
      expect(savedDraft, isNotNull);
      expect(savedDraft!.workoutJson, isA<String>());
      expect(savedDraft!.workoutJson.contains('Test Workout'), isTrue);
    });

    test('should store metadata with workout info', () async {
      // Arrange
      final workout = _createTestWorkout();
      WorkoutDraft? savedDraft;

      when(() => mockDraftBox.put(any(), any())).thenAnswer((invocation) async {
        savedDraft = invocation.positionalArguments[1] as WorkoutDraft;
      });

      // Act
      await repository.saveCurrentDraft(workout);

      // Assert
      expect(savedDraft!.metadata, isNotNull);
      expect(savedDraft!.metadata!['workoutName'], equals('Test Workout'));
      expect(savedDraft!.metadata!['exerciseCount'], equals(1));
    });

    test('should auto-initialize if not initialized', () async {
      // Arrange
      final workout = _createTestWorkout();

      // Act
      await repository.saveCurrentDraft(workout);

      // Assert - Should auto-init
      verify(() => mockBoxManager.openBox<WorkoutDraft>('workout_drafts')).called(1);
    });

    test('should create draft with current timestamp', () async {
      // Arrange
      final workout = _createTestWorkout();
      WorkoutDraft? savedDraft;

      when(() => mockDraftBox.put(any(), any())).thenAnswer((invocation) async {
        savedDraft = invocation.positionalArguments[1] as WorkoutDraft;
      });

      // Act
      await repository.saveCurrentDraft(workout);

      // Assert
      expect(savedDraft, isNotNull);
      expect(savedDraft!.lastSaved, isA<DateTime>());
      expect(savedDraft!.lastSaved.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('should handle save errors gracefully', () async {
      // Arrange
      when(() => mockDraftBox.put(any(), any())).thenThrow(Exception('Hive error'));
      final workout = _createTestWorkout();

      // Act & Assert - Should not throw
      await repository.saveCurrentDraft(workout);
      expect(true, isTrue);
    });
  });

  group('WorkoutDraftRepository - Get Current Draft', () {
    test('should return current draft when exists', () async {
      // Arrange
      final draft = _createTestDraft();
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final result = await repository.getCurrentDraft();

      // Assert
      expect(result, isNotNull);
      expect(result!.metadata?['workoutName'], equals('Test Workout'));
    });

    test('should return null when no draft exists', () async {
      // Arrange
      when(() => mockDraftBox.get('current_draft')).thenReturn(null);

      // Act
      final result = await repository.getCurrentDraft();

      // Assert
      expect(result, isNull);
    });

    test('should auto-initialize if not initialized', () async {
      // Act
      await repository.getCurrentDraft();

      // Assert
      verify(() => mockBoxManager.openBox<WorkoutDraft>('workout_drafts')).called(1);
    });

    test('should handle get errors gracefully', () async {
      // Arrange
      when(() => mockDraftBox.get('current_draft')).thenThrow(Exception('Hive error'));

      // Act
      final result = await repository.getCurrentDraft();

      // Assert
      expect(result, isNull);
    });
  });

  group('WorkoutDraftRepository - Has Recoverable Draft', () {
    test('should return true for draft with completed sets', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final result = await repository.hasRecoverableDraft();

      // Assert
      expect(result, isTrue);
    });

    test('should return false for draft without completed sets', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: false);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final result = await repository.hasRecoverableDraft();

      // Assert
      expect(result, isFalse);
    });

    test('should return false when draft is already recovered', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true, isRecovered: true);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final result = await repository.hasRecoverableDraft();

      // Assert
      expect(result, isFalse);
    });

    test('should return false when draft is stale (>24 hours)', () async {
      // Arrange
      final draft = _createTestDraft(
        hasCompletedSets: true,
        lastSaved: DateTime.now().subtract(const Duration(hours: 25)),
      );
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final result = await repository.hasRecoverableDraft();

      // Assert
      expect(result, isFalse);
    });

    test('should return false when no draft exists', () async {
      // Arrange
      when(() => mockDraftBox.get('current_draft')).thenReturn(null);

      // Act
      final result = await repository.hasRecoverableDraft();

      // Assert
      expect(result, isFalse);
    });

    test('should check staleness at exactly 24 hours boundary', () async {
      // Arrange
      final draft = _createTestDraft(
        hasCompletedSets: true,
        lastSaved: DateTime.now().subtract(const Duration(hours: 24)),
      );
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final result = await repository.hasRecoverableDraft();

      // Assert - At exactly 24 hours, NOT stale yet (isStale uses > 24)
      // So should be recoverable
      expect(result, isTrue);
    });
  });

  group('WorkoutDraftRepository - Recover Draft', () {
    test('should recover draft and return workout', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final workout = await repository.recoverDraft();

      // Assert
      expect(workout, isNotNull);
      expect(workout!.name, equals('Test Workout'));
    });

    test('should mark draft as recovered', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      await repository.recoverDraft();

      // Assert
      verify(() => mockDraftBox.put('current_draft', any(
        that: isA<WorkoutDraft>().having((d) => d.isRecovered, 'isRecovered', isTrue)
      ))).called(1);
    });

    test('should add recovered draft to history', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn(null);

      // Act
      await repository.recoverDraft();

      // Assert
      verify(() => mockRecoveredBox.put('recovered_drafts', any(
        that: isA<List>().having((l) => l.length, 'length', 1)
      ))).called(1);
    });

    test('should append to existing recovered drafts history', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true);
      final existingDraft = _createTestDraft(hasCompletedSets: true);

      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn([existingDraft]);

      List<dynamic>? savedList;
      when(() => mockRecoveredBox.put('recovered_drafts', any())).thenAnswer((invocation) async {
        savedList = invocation.positionalArguments[1] as List<dynamic>;
      });

      // Act
      await repository.recoverDraft();

      // Assert
      expect(savedList, isNotNull);
      expect(savedList!.length, equals(2));
    });

    test('should return null when no draft exists', () async {
      // Arrange
      when(() => mockDraftBox.get('current_draft')).thenReturn(null);

      // Act
      final result = await repository.recoverDraft();

      // Assert
      expect(result, isNull);
    });

    test('should deserialize workout from JSON', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: true);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final workout = await repository.recoverDraft();

      // Assert
      expect(workout, isNotNull);
      expect(workout!.exercises.length, equals(1));
      expect(workout.exercises.first.name, equals('Bench Press'));
    });

    test('should handle recovery errors gracefully', () async {
      // Arrange
      when(() => mockDraftBox.get('current_draft')).thenThrow(Exception('Hive error'));

      // Act
      final result = await repository.recoverDraft();

      // Assert
      expect(result, isNull);
    });
  });

  group('WorkoutDraftRepository - Clear Current Draft', () {
    test('should delete current draft', () async {
      // Act
      await repository.clearCurrentDraft();

      // Assert
      verify(() => mockDraftBox.delete('current_draft')).called(1);
    });

    test('should auto-initialize if not initialized', () async {
      // Act
      await repository.clearCurrentDraft();

      // Assert
      verify(() => mockBoxManager.openBox<WorkoutDraft>('workout_drafts')).called(1);
    });

    test('should handle clear errors gracefully', () async {
      // Arrange
      when(() => mockDraftBox.delete('current_draft')).thenThrow(Exception('Hive error'));

      // Act & Assert - Should not throw
      await repository.clearCurrentDraft();
      expect(true, isTrue);
    });
  });

  group('WorkoutDraftRepository - Get Recovered Drafts', () {
    test('should return all recovered drafts', () async {
      // Arrange
      final drafts = [
        _createTestDraft(hasCompletedSets: true),
        _createTestDraft(hasCompletedSets: true),
      ];
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn(drafts);

      // Act
      final result = await repository.getRecoveredDrafts();

      // Assert
      expect(result.length, equals(2));
    });

    test('should return empty list when no recovered drafts', () async {
      // Arrange
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn(null);

      // Act
      final result = await repository.getRecoveredDrafts();

      // Assert
      expect(result, isEmpty);
    });

    test('should filter out non-WorkoutDraft items', () async {
      // Arrange
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn([
        _createTestDraft(hasCompletedSets: true),
        'invalid',
        123,
        _createTestDraft(hasCompletedSets: true),
      ]);

      // Act
      final result = await repository.getRecoveredDrafts();

      // Assert
      expect(result.length, equals(2));
    });

    test('should handle get errors gracefully', () async {
      // Arrange
      when(() => mockRecoveredBox.get('recovered_drafts')).thenThrow(Exception('Hive error'));

      // Act
      final result = await repository.getRecoveredDrafts();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('WorkoutDraftRepository - Clear Old Drafts', () {
    test('should clear stale current draft (>24 hours)', () async {
      // Arrange
      final staleDraft = _createTestDraft(
        hasCompletedSets: true,
        lastSaved: DateTime.now().subtract(const Duration(hours: 25)),
      );
      when(() => mockDraftBox.get('current_draft')).thenReturn(staleDraft);

      // Act
      await repository.clearOldDrafts();

      // Assert
      verify(() => mockDraftBox.delete('current_draft')).called(1);
    });

    test('should not clear current draft if not stale', () async {
      // Arrange
      final freshDraft = _createTestDraft(
        hasCompletedSets: true,
        lastSaved: DateTime.now().subtract(const Duration(hours: 12)),
      );
      when(() => mockDraftBox.get('current_draft')).thenReturn(freshDraft);

      // Act
      await repository.clearOldDrafts();

      // Assert
      verifyNever(() => mockDraftBox.delete('current_draft'));
    });

    test('should keep only last 5 recovered drafts', () async {
      // Arrange
      final drafts = List.generate(10, (_) => _createTestDraft(hasCompletedSets: true));
      when(() => mockDraftBox.get('current_draft')).thenReturn(null);
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn(drafts);

      List<dynamic>? savedList;
      when(() => mockRecoveredBox.put('recovered_drafts', any())).thenAnswer((invocation) async {
        savedList = invocation.positionalArguments[1] as List<dynamic>;
      });

      // Act
      await repository.clearOldDrafts();

      // Assert
      expect(savedList, isNotNull);
      expect(savedList!.length, equals(5));
    });

    test('should not modify recovered drafts if 5 or fewer', () async {
      // Arrange
      final drafts = List.generate(3, (_) => _createTestDraft(hasCompletedSets: true));
      when(() => mockDraftBox.get('current_draft')).thenReturn(null);
      when(() => mockRecoveredBox.get('recovered_drafts')).thenReturn(drafts);

      // Act
      await repository.clearOldDrafts();

      // Assert
      verifyNever(() => mockRecoveredBox.put('recovered_drafts', any()));
    });

    test('should handle clear errors gracefully', () async {
      // Arrange
      when(() => mockDraftBox.get('current_draft')).thenThrow(Exception('Hive error'));

      // Act & Assert - Should not throw
      await repository.clearOldDrafts();
      expect(true, isTrue);
    });
  });

  group('WorkoutDraftRepository - Disposal', () {
    test('should close draft box', () async {
      // Arrange
      await repository.init();

      // Act
      await repository.dispose();

      // Assert
      verify(() => mockDraftBox.close()).called(1);
    });

    test('should close recovered box', () async {
      // Arrange
      await repository.init();

      // Act
      await repository.dispose();

      // Assert
      verify(() => mockRecoveredBox.close()).called(1);
    });

    test('should not throw when boxes already closed', () async {
      // Arrange
      when(() => mockDraftBox.isOpen).thenReturn(false);
      when(() => mockRecoveredBox.isOpen).thenReturn(false);

      // Act & Assert - Should not throw
      await repository.dispose();
      expect(true, isTrue);
    });

    test('should handle disposal errors gracefully', () async {
      // Arrange
      when(() => mockDraftBox.close()).thenThrow(Exception('Close error'));

      // Act & Assert - Should not throw
      await repository.dispose();
      expect(true, isTrue);
    });
  });

  group('WorkoutDraftRepository - Edge Cases', () {
    test('should handle draft with empty exercises', () async {
      // Arrange
      final workout = Workout(
        id: 'workout-id',
        name: 'Empty Workout',
        exercises: [],
        status: WorkoutStatus.inProgress,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final draft = WorkoutDraft.fromWorkout(workout);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final hasRecoverable = await repository.hasRecoverableDraft();

      // Assert - No exercises means no completed sets = not recoverable
      expect(hasRecoverable, isFalse);
    });

    test('should handle draft with exercises but no completed sets', () async {
      // Arrange
      final draft = _createTestDraft(hasCompletedSets: false);
      when(() => mockDraftBox.get('current_draft')).thenReturn(draft);

      // Act
      final hasRecoverable = await repository.hasRecoverableDraft();

      // Assert
      expect(hasRecoverable, isFalse);
    });

    test('should handle concurrent save operations', () async {
      // Arrange
      final workout1 = _createTestWorkout(name: 'Workout 1');
      final workout2 = _createTestWorkout(name: 'Workout 2');
      final workout3 = _createTestWorkout(name: 'Workout 3');

      // Act - Save concurrently
      await Future.wait([
        repository.saveCurrentDraft(workout1),
        repository.saveCurrentDraft(workout2),
        repository.saveCurrentDraft(workout3),
      ]);

      // Assert - Should have called save 3 times
      verify(() => mockDraftBox.put('current_draft', any())).called(3);
    });

    test('should handle staleness at exactly 24 hours', () async {
      // Arrange
      final draft = _createTestDraft(
        hasCompletedSets: true,
        lastSaved: DateTime.now().subtract(const Duration(hours: 24)),
      );

      // Assert - At 24 hours exactly, isStale should be false (uses > 24)
      expect(draft.isStale, isFalse);
    });

    test('should handle staleness well over 24 hours', () async {
      // Arrange
      final draft = _createTestDraft(
        hasCompletedSets: true,
        lastSaved: DateTime.now().subtract(const Duration(hours: 25)),
      );

      // Assert - 25 hours is definitely stale
      expect(draft.isStale, isTrue);
    });

    test('should preserve workout structure during serialization/deserialization', () async {
      // Arrange
      final originalWorkout = _createTestWorkout();
      final draft = WorkoutDraft.fromWorkout(originalWorkout);

      // Act
      final restoredWorkout = draft.toWorkout();

      // Assert
      expect(restoredWorkout.name, equals(originalWorkout.name));
      expect(restoredWorkout.exercises.length, equals(originalWorkout.exercises.length));
      expect(restoredWorkout.exercises.first.name, equals(originalWorkout.exercises.first.name));
    });
  });
}

/// Helper function to create a test Workout
Workout _createTestWorkout({
  String name = 'Test Workout',
  bool hasCompletedSets = true,
}) {
  return Workout(
    id: 'workout-id',
    name: name,
    exercises: [
      Exercise(
        id: 'exercise-id',
        name: 'Bench Press',
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100.0,
            reps: 10,
            isCompleted: hasCompletedSets,
          ),
        ],
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      ),
    ],
    status: WorkoutStatus.inProgress,
    startTime: DateTime.now(),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

/// Helper function to create a test WorkoutDraft
WorkoutDraft _createTestDraft({
  bool hasCompletedSets = true,
  bool isRecovered = false,
  DateTime? lastSaved,
}) {
  final workout = _createTestWorkout(hasCompletedSets: hasCompletedSets);
  final draft = WorkoutDraft.fromWorkout(workout);

  // Return with custom lastSaved if provided
  if (lastSaved != null || isRecovered) {
    return draft.copyWith(
      lastSaved: lastSaved,
      isRecovered: isRecovered,
    );
  }

  return draft;
}
