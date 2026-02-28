// ignore_for_file: avoid_dynamic_calls, subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/achievement_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// ---------------------------------------------------------------------------
// Mocktail mocks for Firestore chain
// ---------------------------------------------------------------------------

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// ---------------------------------------------------------------------------
// Manual fake Hive box — no real Hive initialization required
// ---------------------------------------------------------------------------

class FakeHiveBox extends Fake implements Box<Map<dynamic, dynamic>> {
  final Map<String, Map<dynamic, dynamic>> _store = {};

  /// Errors to inject per operation
  Exception? getError;
  Exception? putError;

  @override
  bool get isOpen => true;

  @override
  Map<dynamic, dynamic>? get(dynamic key, {Map<dynamic, dynamic>? defaultValue}) {
    if (getError != null) throw getError!;
    return _store[key as String];
  }

  @override
  Future<void> put(dynamic key, Map<dynamic, dynamic> value) async {
    if (putError != null) throw putError!;
    _store[key as String] = value;
  }

  /// Seed helpers
  void seed(String key, Map<dynamic, dynamic> value) => _store[key] = value;

  /// Resets the in-memory store between tests (NOT an override of BoxBase.clear)
  void reset() => _store.clear();

  @override
  bool containsKey(dynamic key) => _store.containsKey(key as String);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Achievement buildAchievement({
  String id = 'user1_firstPR_1000',
  String userId = 'user1',
  BadgeType badgeType = BadgeType.firstPR,
  DateTime? unlockedAt,
  Map<String, dynamic>? evidence,
}) {
  return Achievement(
    id: id,
    userId: userId,
    badgeType: badgeType,
    unlockedAt: unlockedAt ?? DateTime(2025, 6, 1, 12),
    evidence: evidence ?? {},
  );
}

WorkoutMetrics buildMetrics({String workoutId = 'w1'}) {
  return WorkoutMetrics.empty(workoutId);
}

// ---------------------------------------------------------------------------
// Test subject factory
// ---------------------------------------------------------------------------

// Subclass that injects a pre-opened FakeHiveBox so the real Hive singleton
// is never touched during tests.
class TestableAchievementRepository extends AchievementRepositoryImpl {
  TestableAchievementRepository({
    required FirebaseFirestore firestore,
    required FakeHiveBox fakeBox,
    super.cacheBoxName = 'test_achievements',
  })  : _fakeBox = fakeBox,
        super(firestore: firestore);

  final FakeHiveBox _fakeBox;

  @override
  Future<Box<Map<dynamic, dynamic>>> getCacheBox() async => _fakeBox;
}

// ---------------------------------------------------------------------------
// Main test suite
// ---------------------------------------------------------------------------

void main() {
  late MockFirebaseFirestore mockFirestore;
  late FakeHiveBox fakeBox;
  late TestableAchievementRepository repository;

  // Firestore chain helpers
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockAchievementsCollection;

  // ------- setUp / tearDown -----------------------------------------------

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    fakeBox = FakeHiveBox();

    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockAchievementsCollection = MockCollectionReference();

    repository = TestableAchievementRepository(
      firestore: mockFirestore,
      fakeBox: fakeBox,
    );

    // Wire Firestore collection chain once for reuse in each test
    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(any()))
        .thenReturn(mockUserDoc);
    when(() => mockUserDoc.collection('achievements'))
        .thenReturn(mockAchievementsCollection);
  });

  tearDown(() {
    fakeBox.reset();
    fakeBox.getError = null;
    fakeBox.putError = null;
  });

  // =========================================================================
  // unlockAchievement
  // =========================================================================

  group('unlockAchievement –', () {
    test('returns Right(Achievement) on first unlock with evidence', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.firstPR;
      final evidence = {'exercise': 'Bench Press', 'value': 100.0};

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      // isAchievementUnlocked check
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      // set call
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.unlockAchievement(
        userId,
        badge,
        evidence: evidence,
      );

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (achievement) {
          expect(achievement.userId, userId);
          expect(achievement.badgeType, badge);
          expect(achievement.evidence, evidence);
        },
      );
      verify(() => mockDocRef.set(any())).called(1);
    });

    test('returns Right(Achievement) with empty evidence when none provided',
        () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.streakMaster7;

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.unlockAchievement(userId, badge);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (achievement) => expect(achievement.evidence, isEmpty),
      );
    });

    test('prevents double-unlock: returns Left when already unlocked',
        () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.firstPR;

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      // Already exists in Firestore
      when(() => mockDocSnapshot.exists).thenReturn(true);

      // Act
      final result = await repository.unlockAchievement(userId, badge);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        // ValidationFailure is thrown as a non-Firebase exception inside
        // handleFirebaseOperation, so it gets wrapped in UnexpectedFailure.
        // Both cases confirm the operation correctly prevented the double-unlock.
        (failure) {
          expect(
            failure is ValidationFailure || failure is UnexpectedFailure,
            true,
            reason: 'Expected a Failure indicating double-unlock was prevented',
          );
          expect(failure.message, contains('already unlocked'));
        },
        (_) => fail('Expected Left'),
      );
      // set should NOT be called
      verifyNever(() => mockDocRef.set(any()));
    });

    test('appends new achievement to existing cache on unlock', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.streakMaster7;

      // Seed cache with one pre-existing achievement
      final existingAchievement = buildAchievement(
        id: 'user1_firstPR_999',
        userId: userId,
        badgeType: BadgeType.firstPR,
      );
      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': [existingAchievement.toJson()],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.unlockAchievement(userId, badge);

      // Assert
      expect(result.isRight(), true);
      final cacheEntry = fakeBox.get('achievements:$userId:unlocked');
      expect(cacheEntry, isNotNull);
      final achievements = cacheEntry!['achievements'] as List;
      // Both old achievement and newly unlocked one should be in cache
      expect(achievements.length, 2);
    });

    test('returns Left when Firestore throws FirebaseException', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.volumeLegend10k;

      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', message: 'unavailable'),
      );

      // Act
      final result = await repository.unlockAchievement(userId, badge);

      // Assert
      expect(result.isLeft(), true);
    });

    test('generates unique id containing userId and badge name', () async {
      // Arrange
      const userId = 'user42';
      const badge = BadgeType.workoutCompletionist100;

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      // Act
      final result = await repository.unlockAchievement(userId, badge);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (achievement) {
          expect(achievement.id, contains(userId));
          expect(achievement.id, contains(badge.name));
        },
      );
    });
  });

  // =========================================================================
  // getUnlockedAchievements
  // =========================================================================

  group('getUnlockedAchievements –', () {
    test('returns cached achievements when cache is fresh (TTL not expired)',
        () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': [achievement.toJson()],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Act
      final result = await repository.getUnlockedAchievements(userId);

      // Assert – Firestore should NOT be called
      verifyNever(() => mockUsersCollection.doc(any()));
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) {
          expect(list.length, 1);
          expect(list.first.badgeType, BadgeType.firstPR);
        },
      );
    });

    test('fetches from Firestore when cache is expired (> 1 hour old)',
        () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      // Cache entry with timestamp older than 1 hour
      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': [achievement.toJson()],
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
      );

      final mockSnapshot = MockQuerySnapshot();
      final mockQDoc = MockQueryDocumentSnapshot();

      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockQDoc]);
      when(() => mockQDoc.data()).thenReturn(achievement.toJson());

      // Act
      final result = await repository.getUnlockedAchievements(userId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockAchievementsCollection.get()).called(1);
    });

    test('fetches from Firestore when cache is empty', () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      final mockSnapshot = MockQuerySnapshot();
      final mockQDoc = MockQueryDocumentSnapshot();

      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockQDoc]);
      when(() => mockQDoc.data()).thenReturn(achievement.toJson());

      // Act
      final result = await repository.getUnlockedAchievements(userId);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) => expect(list.length, 1),
      );
    });

    test('updates cache after successful Firestore fetch', () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      final mockSnapshot = MockQuerySnapshot();
      final mockQDoc = MockQueryDocumentSnapshot();

      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockQDoc]);
      when(() => mockQDoc.data()).thenReturn(achievement.toJson());

      // Act
      await repository.getUnlockedAchievements(userId);

      // Assert – cache entry should now exist
      expect(fakeBox.containsKey('achievements:$userId:unlocked'), true);
    });

    test('offline fallback: returns stale cache when Firestore fails', () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      // Stale (expired) cache
      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': [achievement.toJson()],
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 3))
              .toIso8601String(),
        },
      );

      when(() => mockAchievementsCollection.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'unavailable',
          code: 'unavailable',
        ),
      );

      // Act
      final result = await repository.getUnlockedAchievements(userId);

      // Assert – should return stale cached data rather than failure
      result.fold(
        (failure) => fail('Expected Right (offline fallback), got: $failure'),
        (list) {
          expect(list.length, 1);
          expect(list.first.badgeType, BadgeType.firstPR);
        },
      );
    });

    test('returns Left when Firestore fails and no cache exists', () async {
      // Arrange
      const userId = 'user1';

      when(() => mockAchievementsCollection.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'unavailable',
          code: 'unavailable',
        ),
      );

      // Act
      final result = await repository.getUnlockedAchievements(userId);

      // Assert
      expect(result.isLeft(), true);
    });

    test('returns empty list when user has no achievements', () async {
      // Arrange
      const userId = 'user_new';

      final mockSnapshot = MockQuerySnapshot();

      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getUnlockedAchievements(userId);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) => expect(list, isEmpty),
      );
    });
  });

  // =========================================================================
  // checkNewAchievements
  // =========================================================================

  group('checkNewAchievements –', () {
    test('returns Right with empty list (delegates to use-case layer)', () async {
      // Arrange
      const userId = 'user1';
      final metrics = buildMetrics();

      // Act
      final result = await repository.checkNewAchievements(userId, metrics);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) => expect(list, isEmpty),
      );
    });

    test('does not call Firestore', () async {
      // Arrange
      const userId = 'user1';
      final metrics = buildMetrics();

      // Act
      await repository.checkNewAchievements(userId, metrics);

      // Assert
      verifyNever(() => mockUsersCollection.doc(any()));
    });
  });

  // =========================================================================
  // isAchievementUnlocked
  // =========================================================================

  group('isAchievementUnlocked –', () {
    test('returns Right(true) when document exists in Firestore', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.firstPR;

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);

      // Act
      final result = await repository.isAchievementUnlocked(userId, badge);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (isUnlocked) => expect(isUnlocked, true),
      );
    });

    test('returns Right(false) when document does not exist', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.streakMaster30;

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.isAchievementUnlocked(userId, badge);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (isUnlocked) => expect(isUnlocked, false),
      );
    });

    test('returns Left when Firestore throws FirebaseException', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.volumeLegend100k;

      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'permission-denied',
          code: 'permission-denied',
        ),
      );

      // Act
      final result = await repository.isAchievementUnlocked(userId, badge);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<PermissionDeniedFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('checks correct Firestore document path for given badge', () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.consistencyChampion;

      final mockDocSnapshot = MockDocumentSnapshot();
      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);

      // Act
      await repository.isAchievementUnlocked(userId, badge);

      // Assert
      verify(() => mockAchievementsCollection.doc('consistencyChampion'))
          .called(1);
    });

    test('returns Left with UnexpectedFailure on non-Firebase exception',
        () async {
      // Arrange
      const userId = 'user1';
      const badge = BadgeType.balancedBuilder;

      final mockDocRef = MockDocumentReference();

      when(() => mockAchievementsCollection.doc(badge.name))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenThrow(Exception('unexpected socket error'));

      // Act
      final result = await repository.isAchievementUnlocked(userId, badge);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // =========================================================================
  // getRecentAchievements
  // =========================================================================

  group('getRecentAchievements –', () {
    test('returns ordered list of achievements with default limit 10', () async {
      // Arrange
      const userId = 'user1';

      final achievement1 = buildAchievement(
        id: 'a1',
        userId: userId,
        badgeType: BadgeType.firstPR,
        unlockedAt: DateTime(2025, 6, 1),
      );
      final achievement2 = buildAchievement(
        id: 'a2',
        userId: userId,
        badgeType: BadgeType.streakMaster7,
        unlockedAt: DateTime(2025, 6, 10),
      );

      final mockQuery = MockQuery();
      final mockQuery2 = MockQuery();
      final mockSnapshot = MockQuerySnapshot();
      final mockQDoc1 = MockQueryDocumentSnapshot();
      final mockQDoc2 = MockQueryDocumentSnapshot();

      when(() => mockAchievementsCollection.orderBy(
            'unlockedAt',
            descending: true,
          )).thenReturn(mockQuery);
      when(() => mockQuery.limit(10)).thenReturn(mockQuery2);
      when(() => mockQuery2.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockQDoc1, mockQDoc2]);
      when(() => mockQDoc1.data()).thenReturn(achievement1.toJson());
      when(() => mockQDoc2.data()).thenReturn(achievement2.toJson());

      // Act
      final result = await repository.getRecentAchievements(userId);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) {
          expect(list.length, 2);
          expect(list.first.badgeType, BadgeType.firstPR);
          expect(list.last.badgeType, BadgeType.streakMaster7);
        },
      );
    });

    test('respects custom limit parameter', () async {
      // Arrange
      const userId = 'user1';

      final mockQuery = MockQuery();
      final mockQuery2 = MockQuery();
      final mockSnapshot = MockQuerySnapshot();

      when(() => mockAchievementsCollection.orderBy(
            'unlockedAt',
            descending: true,
          )).thenReturn(mockQuery);
      when(() => mockQuery.limit(5)).thenReturn(mockQuery2);
      when(() => mockQuery2.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getRecentAchievements(userId, limit: 5);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockQuery.limit(5)).called(1);
    });

    test('returns empty list when user has no recent achievements', () async {
      // Arrange
      const userId = 'user_new';

      final mockQuery = MockQuery();
      final mockQuery2 = MockQuery();
      final mockSnapshot = MockQuerySnapshot();

      when(() => mockAchievementsCollection.orderBy(
            'unlockedAt',
            descending: true,
          )).thenReturn(mockQuery);
      when(() => mockQuery.limit(10)).thenReturn(mockQuery2);
      when(() => mockQuery2.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getRecentAchievements(userId);

      // Assert
      result.fold(
        (failure) => fail('Expected Right, got: $failure'),
        (list) => expect(list, isEmpty),
      );
    });

    test('returns Left when Firestore throws FirebaseException', () async {
      // Arrange
      const userId = 'user1';

      final mockQuery = MockQuery();

      when(() => mockAchievementsCollection.orderBy(
            'unlockedAt',
            descending: true,
          )).thenReturn(mockQuery);
      when(() => mockQuery.limit(10)).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          message: 'unavailable',
          code: 'unavailable',
        ),
      );

      // Act
      final result = await repository.getRecentAchievements(userId);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  // =========================================================================
  // Cache strategy
  // =========================================================================

  group('Cache strategy –', () {
    test('cache TTL: fresh cache (59 min old) is used without Firestore call',
        () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      // 59 minutes old — still fresh
      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': [achievement.toJson()],
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 59))
              .toIso8601String(),
        },
      );

      // Act
      await repository.getUnlockedAchievements(userId);

      // Assert – Firestore get() should NOT be called
      verifyNever(() => mockAchievementsCollection.get());
    });

    test('cache TTL: expired cache (61 min old) triggers Firestore fetch',
        () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      // 61 minutes old — expired
      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': [achievement.toJson()],
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 61))
              .toIso8601String(),
        },
      );

      final mockSnapshot = MockQuerySnapshot();
      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act
      await repository.getUnlockedAchievements(userId);

      // Assert
      verify(() => mockAchievementsCollection.get()).called(1);
    });

    test('cache write error is silently ignored (non-critical)', () async {
      // Arrange
      const userId = 'user1';
      final achievement = buildAchievement(userId: userId);

      final mockSnapshot = MockQuerySnapshot();
      final mockQDoc = MockQueryDocumentSnapshot();

      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockQDoc]);
      when(() => mockQDoc.data()).thenReturn(achievement.toJson());

      // Inject cache write failure
      fakeBox.putError = Exception('hive write error');

      // Act — should NOT throw
      final result = await repository.getUnlockedAchievements(userId);

      // Assert — result still contains Firestore data
      expect(result.isRight(), true);
    });

    test('corrupt cache entry (bad timestamp) falls back to Firestore', () async {
      // Arrange
      const userId = 'user1';

      fakeBox.seed(
        'achievements:$userId:unlocked',
        {
          'achievements': <dynamic>[],
          'timestamp': 'NOT_A_DATE', // corrupt
        },
      );

      final mockSnapshot = MockQuerySnapshot();
      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act — should not throw
      final result = await repository.getUnlockedAchievements(userId);

      // Assert — Firestore was queried as fallback
      expect(result.isRight(), true);
      verify(() => mockAchievementsCollection.get()).called(1);
    });

    test('cache key is scoped per userId to prevent cross-user leakage',
        () async {
      // Arrange — seed cache for user2, not user1
      const userId1 = 'user1';
      const userId2 = 'user2';
      final achievementUser2 = buildAchievement(
        id: 'user2_firstPR_1',
        userId: userId2,
      );

      fakeBox.seed(
        'achievements:$userId2:unlocked',
        {
          'achievements': [achievementUser2.toJson()],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final mockSnapshot = MockQuerySnapshot();
      when(() => mockAchievementsCollection.get())
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]);

      // Act — fetching for user1
      await repository.getUnlockedAchievements(userId1);

      // Assert — Firestore was called (no cache hit for user1)
      verify(() => mockAchievementsCollection.get()).called(1);
    });
  });
}
