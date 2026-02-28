// ignore_for_file: avoid_dynamic_calls, subtype_of_sealed_class
/// Unit tests for MuscleCorrectionRepositoryImpl
///
/// Strategy:
/// - Hive: FakeHiveBox injected via TestableMuscleCorrectionRepository (no real Hive)
/// - Firestore: mocktail mocks (same pattern as pr_celebration_repository_impl_test)
/// - FirebaseAuth: currentUserId getter overridden in test subclass
///
/// Covered behaviours:
/// 1. saveLocalCorrection – success, error, one-per-exercise overwrite
/// 2. getLocalCorrections – empty box, multiple entries, malformed entry skipped,
///    sorted newest-first, Hive error
/// 3. submitFeedbackToAdmin – success, unauthenticated user, FirebaseException,
///    generic exception
/// 4. watchFeedbackStatus – document not found, null data, missing status field,
///    known statuses (pending/approved/rejected), unknown status falls back to pending,
///    stream creation error
/// 5. deleteLocalCorrection – success, non-existent key succeeds, Hive error
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/analytics/data/local/hive_muscle_correction_adapter.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/muscle_correction_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/muscle_correction_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// =============================================================================
// Mocktail mocks – Firestore chain
// =============================================================================

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockStreamController extends Mock
    implements Stream<DocumentSnapshot<Map<String, dynamic>>> {}

// =============================================================================
// FakeHiveBox – in-memory replacement for Box<Map<String, dynamic>>
// =============================================================================

class FakeHiveBox extends Fake implements Box<Map<String, dynamic>> {
  final Map<String, Map<String, dynamic>> _store = {};

  /// Inject to simulate errors from specific operations.
  Exception? putError;
  Exception? deleteError;
  Exception? valuesError;

  // ---- helpers ---------------------------------------------------------------

  void seed(String key, Map<String, dynamic> value) => _store[key] = value;

  void reset() {
    _store.clear();
    putError = null;
    deleteError = null;
    valuesError = null;
  }

  // ---- Box<Map<String,dynamic>> interface ------------------------------------

  @override
  bool get isOpen => true;

  @override
  Iterable<Map<String, dynamic>> get values {
    if (valuesError != null) throw valuesError!;
    return List.unmodifiable(_store.values);
  }

  @override
  Future<void> put(dynamic key, Map<String, dynamic> value) async {
    if (putError != null) throw putError!;
    _store[key as String] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    if (deleteError != null) throw deleteError!;
    _store.remove(key as String);
  }

  @override
  bool containsKey(dynamic key) => _store.containsKey(key as String);

  /// Number of stored entries.
  @override
  int get length => _store.length;
}

// =============================================================================
// TestableMuscleCorrectionRepository
//
// Overrides both:
//   1. openCorrectionsBox() so no real Hive file system is required.
//   2. currentUserId so we can control auth state without Firebase.
// =============================================================================

class TestableMuscleCorrectionRepository
    extends MuscleCorrectionRepositoryImpl {
  TestableMuscleCorrectionRepository({
    required super.hiveBoxManager,
    required super.firestore,
    required this.stubbedUserId,
    required this.fakeBox,
  });

  /// Pass `null` to simulate an unauthenticated user.
  final String? stubbedUserId;

  /// Pre-built fake box returned instead of opening a real Hive box.
  final FakeHiveBox fakeBox;

  /// Error to inject for the box-opening step (simulates init failure).
  Exception? openBoxError;

  @override
  String? get currentUserId => stubbedUserId;

  @override
  Future<Box<Map<String, dynamic>>> openCorrectionsBox() async {
    if (openBoxError != null) throw openBoxError!;
    return fakeBox;
  }
}

// =============================================================================
// Test data helpers
// =============================================================================

MuscleCorrection makeCorrection({
  String exerciseName = 'Bench Press',
  String oldMuscleGroup = 'Back',
  String newMuscleGroup = 'Chest',
  DateTime? timestamp,
}) {
  return MuscleCorrection(
    exerciseName: exerciseName,
    oldMuscleGroup: oldMuscleGroup,
    newMuscleGroup: newMuscleGroup,
    timestamp: timestamp ?? DateTime(2025, 6, 1, 12),
  );
}

Map<String, dynamic> correctionToHiveJson(MuscleCorrection c) =>
    c.toHiveJson();

// =============================================================================
// Main test suite
// =============================================================================

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockFeedbackCollection;
  late MockDocumentReference mockDocRef;
  late FakeHiveBox fakeBox;

  // ---- Helper to build a repository with a specific user state -------------

  TestableMuscleCorrectionRepository buildRepo({String? userId = 'user-123'}) {
    final repo = TestableMuscleCorrectionRepository(
      // hiveBoxManager is passed but never used – openCorrectionsBox() is
      // overridden to return fakeBox directly.
      hiveBoxManager: HiveBoxManagerEnhanced(),
      firestore: mockFirestore,
      stubbedUserId: userId,
      fakeBox: fakeBox,
    );
    return repo;
  }

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockFeedbackCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    fakeBox = FakeHiveBox();
  });

  tearDown(() {
    fakeBox.reset();
  });

  // =========================================================================
  // saveLocalCorrection
  // =========================================================================

  group('saveLocalCorrection –', () {
    test('returns Right(unit) and persists entry in Hive box', () async {
      // Arrange
      final repo = buildRepo();
      final correction = makeCorrection();

      // Act
      final result = await repo.saveLocalCorrection(correction);

      // Assert
      expect(result.isRight(), isTrue);
      expect(fakeBox.containsKey('Bench Press'), isTrue);
      final stored = fakeBox.values.first;
      expect(stored['exerciseName'], 'Bench Press');
      expect(stored['oldMuscleGroup'], 'Back');
      expect(stored['newMuscleGroup'], 'Chest');
    });

    test('overwrites previous correction for the same exercise (one per exercise)',
        () async {
      // Arrange – seed an existing correction for "Bench Press"
      final repo = buildRepo();
      fakeBox.seed('Bench Press', makeCorrection(newMuscleGroup: 'Shoulders').toHiveJson());

      final updated = makeCorrection(newMuscleGroup: 'Chest');

      // Act
      final result = await repo.saveLocalCorrection(updated);

      // Assert
      expect(result.isRight(), isTrue);
      // Still only one entry
      expect(fakeBox.values.length, 1);
      expect(fakeBox.values.first['newMuscleGroup'], 'Chest');
    });

    test('different exercises are stored with independent keys', () async {
      // Arrange
      final repo = buildRepo();
      final c1 = makeCorrection(exerciseName: 'Squat', newMuscleGroup: 'Legs');
      final c2 = makeCorrection(exerciseName: 'Deadlift', newMuscleGroup: 'Back');

      // Act
      await repo.saveLocalCorrection(c1);
      await repo.saveLocalCorrection(c2);

      // Assert
      expect(fakeBox.containsKey('Squat'), isTrue);
      expect(fakeBox.containsKey('Deadlift'), isTrue);
      expect(fakeBox.values.length, 2);
    });

    test('returns Left(CacheFailure) when Hive put throws', () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.putError = Exception('disk full');

      // Act
      final result = await repo.saveLocalCorrection(makeCorrection());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, contains('Failed to save correction locally'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(CacheFailure) when openBox itself throws', () async {
      // Arrange
      final repo = buildRepo();
      repo.openBoxError = Exception('hive init failed');

      // Act
      final result = await repo.saveLocalCorrection(makeCorrection());

      // Assert
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });

  // =========================================================================
  // getLocalCorrections
  // =========================================================================

  group('getLocalCorrections –', () {
    test('returns Right([]) when box is empty', () async {
      // Arrange
      final repo = buildRepo();

      // Act
      final result = await repo.getLocalCorrections();

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) => expect(list, isEmpty),
      );
    });

    test('returns all corrections in the box', () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.seed('Squat', makeCorrection(exerciseName: 'Squat').toHiveJson());
      fakeBox.seed(
          'Deadlift', makeCorrection(exerciseName: 'Deadlift').toHiveJson());

      // Act
      final result = await repo.getLocalCorrections();

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) => expect(list.length, 2),
      );
    });

    test('returns corrections sorted newest-first by timestamp', () async {
      // Arrange
      final repo = buildRepo();
      final older = makeCorrection(
        exerciseName: 'Squat',
        timestamp: DateTime(2025, 1, 1),
      );
      final newer = makeCorrection(
        exerciseName: 'Deadlift',
        timestamp: DateTime(2025, 6, 1),
      );
      fakeBox.seed('Squat', older.toHiveJson());
      fakeBox.seed('Deadlift', newer.toHiveJson());

      // Act
      final result = await repo.getLocalCorrections();

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) {
          expect(list.first.exerciseName, 'Deadlift');
          expect(list.last.exerciseName, 'Squat');
        },
      );
    });

    test('skips malformed entries without failing the call', () async {
      // Arrange – one valid + one malformed (missing required field)
      final repo = buildRepo();
      fakeBox.seed('Squat', makeCorrection(exerciseName: 'Squat').toHiveJson());
      // Malformed: missing 'newMuscleGroup'
      fakeBox.seed('BadEntry', {
        'exerciseName': 'BadEntry',
        'oldMuscleGroup': 'X',
        // 'newMuscleGroup' missing → MuscleCorrectionHiveExtension.fromHiveJson will throw
        'timestamp': DateTime(2025, 1, 1).toIso8601String(),
      });

      // Act
      final result = await repo.getLocalCorrections();

      // Assert – only the valid entry survives
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) {
          expect(list.length, 1);
          expect(list.first.exerciseName, 'Squat');
        },
      );
    });

    test('returns Left(CacheFailure) when box.values throws', () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.valuesError = Exception('storage error');

      // Act
      final result = await repo.getLocalCorrections();

      // Assert
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });

    test('returns Left(CacheFailure) when openBox throws', () async {
      // Arrange
      final repo = buildRepo();
      repo.openBoxError = Exception('cannot open box');

      // Act
      final result = await repo.getLocalCorrections();

      // Assert
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });

  // =========================================================================
  // submitFeedbackToAdmin
  // =========================================================================

  group('submitFeedbackToAdmin –', () {
    setUp(() {
      // Wire Firestore: collection('muscle_group_feedback').doc() -> mockDocRef
      when(() => mockFirestore.collection('muscle_group_feedback'))
          .thenReturn(mockFeedbackCollection);
      when(() => mockFeedbackCollection.doc()).thenReturn(mockDocRef);
    });

    test('returns Right(unit) and writes correct document to Firestore',
        () async {
      // Arrange
      final repo = buildRepo(userId: 'user-abc');
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      final correction = makeCorrection();

      // Act
      final result = await repo.submitFeedbackToAdmin(correction);

      // Assert
      expect(result.isRight(), isTrue);
      final captured = verify(() => mockDocRef.set(captureAny())).captured;
      final doc = captured.first as Map<String, dynamic>;
      expect(doc['exerciseName'], 'Bench Press');
      expect(doc['oldGroup'], 'Back');
      expect(doc['newGroup'], 'Chest');
      expect(doc['userId'], 'user-abc');
      expect(doc['status'], 'pending');
      expect(doc['notificationShown'], isFalse);
      expect(doc['pushSent'], isFalse);
    });

    test('returns Left(ServerFailure) when user is not authenticated', () async {
      // Arrange – no user logged in
      final repo = buildRepo(userId: null);

      // Act
      final result = await repo.submitFeedbackToAdmin(makeCorrection());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('not authenticated'));
        },
        (_) => fail('Expected Left'),
      );
      // Firestore should NOT have been called
      verifyNever(() => mockDocRef.set(any()));
    });

    test('returns Left(ServerFailure) on FirebaseException', () async {
      // Arrange
      final repo = buildRepo();
      when(() => mockDocRef.set(any())).thenThrow(
        FirebaseException(plugin: 'firestore', message: 'Permission denied'),
      );

      // Act
      final result = await repo.submitFeedbackToAdmin(makeCorrection());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Failed to submit feedback'));
          expect(failure.message, contains('Permission denied'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) on generic exception', () async {
      // Arrange
      final repo = buildRepo();
      when(() => mockDocRef.set(any())).thenThrow(Exception('network timeout'));

      // Act
      final result = await repo.submitFeedbackToAdmin(makeCorrection());

      // Assert
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });
  });

  // =========================================================================
  // watchFeedbackStatus
  // =========================================================================

  group('watchFeedbackStatus –', () {
    const correctionId = 'correction-doc-1';

    late MockDocumentReference mockWatchDocRef;

    setUp(() {
      mockWatchDocRef = MockDocumentReference();
      when(() => mockFirestore.collection('muscle_group_feedback'))
          .thenReturn(mockFeedbackCollection);
      when(() => mockFeedbackCollection.doc(correctionId))
          .thenReturn(mockWatchDocRef);
    });

    test('emits Left(ServerFailure) when document does not exist', () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final stream = repo.watchFeedbackStatus(correctionId);
      final result = await stream.first;

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('not found'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('emits Left(ServerFailure) when snapshot data is null', () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(null);
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final stream = repo.watchFeedbackStatus(correctionId);
      final result = await stream.first;

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('emits Left(ServerFailure) when status field is missing', () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({'exerciseName': 'Squat'});
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final stream = repo.watchFeedbackStatus(correctionId);
      final result = await stream.first;

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, contains('Status field missing')),
        (_) => fail('Expected Left'),
      );
    });

    test('emits Right(FeedbackStatus.pending) when status is "pending"',
        () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({'status': 'pending'});
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final stream = repo.watchFeedbackStatus(correctionId);
      final result = await stream.first;

      // Assert
      result.fold(
        (f) => fail('Expected Right, got: $f'),
        (status) => expect(status, FeedbackStatus.pending),
      );
    });

    test('emits Right(FeedbackStatus.approved) when status is "approved"',
        () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({'status': 'approved'});
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final result = await repo.watchFeedbackStatus(correctionId).first;

      // Assert
      result.fold(
        (f) => fail('Expected Right, got: $f'),
        (status) => expect(status, FeedbackStatus.approved),
      );
    });

    test('emits Right(FeedbackStatus.rejected) when status is "rejected"',
        () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({'status': 'rejected'});
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final result = await repo.watchFeedbackStatus(correctionId).first;

      // Assert
      result.fold(
        (f) => fail('Expected Right, got: $f'),
        (status) => expect(status, FeedbackStatus.rejected),
      );
    });

    test('unknown status string falls back to FeedbackStatus.pending', () async {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data())
          .thenReturn({'status': 'in_review'});
      when(() => mockWatchDocRef.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final repo = buildRepo();
      final result = await repo.watchFeedbackStatus(correctionId).first;

      // Assert – fallback to pending (orElse behaviour in impl)
      result.fold(
        (f) => fail('Expected Right, got: $f'),
        (status) => expect(status, FeedbackStatus.pending),
      );
    });

    test('emits multiple status updates over the stream lifetime', () async {
      // Arrange
      final snapshot1 = MockDocumentSnapshot();
      final snapshot2 = MockDocumentSnapshot();
      when(() => snapshot1.exists).thenReturn(true);
      when(() => snapshot1.data()).thenReturn({'status': 'pending'});
      when(() => snapshot2.exists).thenReturn(true);
      when(() => snapshot2.data()).thenReturn({'status': 'approved'});

      when(() => mockWatchDocRef.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([snapshot1, snapshot2]),
      );

      // Act
      final repo = buildRepo();
      final results = await repo.watchFeedbackStatus(correctionId).toList();

      // Assert
      expect(results.length, 2);
      expect(results[0].getRight().toNullable(), FeedbackStatus.pending);
      expect(results[1].getRight().toNullable(), FeedbackStatus.approved);
    });
  });

  // =========================================================================
  // deleteLocalCorrection
  // =========================================================================

  group('deleteLocalCorrection –', () {
    test('returns Right(unit) and removes entry from Hive box', () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.seed(
          'Bench Press', makeCorrection(exerciseName: 'Bench Press').toHiveJson());

      // Act
      final result = await repo.deleteLocalCorrection('Bench Press');

      // Assert
      expect(result.isRight(), isTrue);
      expect(fakeBox.containsKey('Bench Press'), isFalse);
    });

    test('returns Right(unit) when key does not exist (idempotent)', () async {
      // Arrange – box is empty
      final repo = buildRepo();

      // Act
      final result = await repo.deleteLocalCorrection('NonExistent');

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('does not affect other entries when deleting one', () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.seed('Squat', makeCorrection(exerciseName: 'Squat').toHiveJson());
      fakeBox.seed('Deadlift', makeCorrection(exerciseName: 'Deadlift').toHiveJson());

      // Act
      await repo.deleteLocalCorrection('Squat');

      // Assert
      expect(fakeBox.containsKey('Squat'), isFalse);
      expect(fakeBox.containsKey('Deadlift'), isTrue);
    });

    test('returns Left(CacheFailure) when box.delete throws', () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.deleteError = Exception('write protected');

      // Act
      final result = await repo.deleteLocalCorrection('Bench Press');

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, contains('Failed to delete correction'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(CacheFailure) when openBox throws', () async {
      // Arrange
      final repo = buildRepo();
      repo.openBoxError = Exception('box unavailable');

      // Act
      final result = await repo.deleteLocalCorrection('Bench Press');

      // Assert
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<CacheFailure>());
    });
  });

  // =========================================================================
  // Local ↔ Remote sync scenario
  // =========================================================================

  group('local ↔ remote sync scenario –', () {
    test('save locally then submit to admin succeeds independently', () async {
      // Arrange
      final repo = buildRepo(userId: 'user-sync');
      when(() => mockFirestore.collection('muscle_group_feedback'))
          .thenReturn(mockFeedbackCollection);
      when(() => mockFeedbackCollection.doc()).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      final correction = makeCorrection(exerciseName: 'Overhead Press');

      // Act – Step 1: save locally
      final localResult = await repo.saveLocalCorrection(correction);

      // Act – Step 2: submit to admin
      final remoteResult = await repo.submitFeedbackToAdmin(correction);

      // Assert
      expect(localResult.isRight(), isTrue,
          reason: 'Local save must succeed');
      expect(remoteResult.isRight(), isTrue,
          reason: 'Remote submit must succeed');

      // Local storage should contain the entry
      expect(fakeBox.containsKey('Overhead Press'), isTrue);
      // Firestore should have received the document
      verify(() => mockDocRef.set(any())).called(1);
    });

    test('local delete does not affect remote document (they are independent)',
        () async {
      // Arrange
      final repo = buildRepo();
      fakeBox.seed('Bench Press', makeCorrection().toHiveJson());

      // Act
      final deleteResult = await repo.deleteLocalCorrection('Bench Press');

      // Assert
      expect(deleteResult.isRight(), isTrue);
      // Remote Firestore collection must NOT have been touched
      verifyNever(() => mockFirestore.collection(any()));
    });
  });
}
