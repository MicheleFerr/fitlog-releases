/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/home/data/repositories
/// 🎯 Feature: insight_feedback
/// 🔧 Type: repository_test
///
/// INSIGHT FEEDBACK REPOSITORY TESTS
///
/// Tests per InsightFeedbackRepository - Gestione feedback utente su AI Coach insights
/// Coverage target: 217 lines di implementazione
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/home/data/repositories/insight_feedback_repository.dart';
import 'package:gymbro_flutter_new/features/home/domain/entities/insight_feedback.dart';
import 'package:mocktail/mocktail.dart';

// ============================================================
// MOCKS
// ============================================================

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

// ============================================================
// FAKES for fallback values
// ============================================================

class FakeSetOptions extends Fake implements SetOptions {}

class FakeTimestamp extends Fake implements Timestamp {}

// ============================================================
// TEST DATA FACTORIES
// ============================================================

InsightFeedback createTestFeedback({
  String userId = 'user-123',
  String insightType = 'workout_streak',
  String insightHash = 'hash123',
  bool isHelpful = true,
}) {
  return InsightFeedback(
    id: '${userId}_${insightHash}_${DateTime.now().millisecondsSinceEpoch}',
    userId: userId,
    insightType: insightType,
    insightHash: insightHash,
    isHelpful: isHelpful,
    comment: isHelpful ? 'Very useful!' : 'Not helpful',
    timestamp: DateTime.now(),
  );
}

// ============================================================
// MAIN TEST SUITE
// ============================================================

void main() {
  late InsightFeedbackRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDoc;
  late MockQuery<Map<String, dynamic>> mockQuery;

  setUpAll(() {
    registerFallbackValue(FakeSetOptions());
    registerFallbackValue(FakeTimestamp());
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDoc = MockQueryDocumentSnapshot();
    mockQuery = MockQuery();

    // Setup Firestore collection
    when(() => mockFirestore.collection('insight_feedback'))
        .thenReturn(mockCollection);

    repository = InsightFeedbackRepository(
      firestore: mockFirestore,
    );
  });

  group('Initialization', () {
    test('repository initializes with firestore instance', () {
      expect(repository, isNotNull);
    });

    test('repository uses default firestore instance when none provided', () {
      // Skip: requires Firebase.initializeApp() in test environment
    }, skip: 'Requires Firebase initialization');
  });

  group('saveFeedback', () {
    test('saves feedback successfully', () async {
      // Arrange
      final testFeedback = createTestFeedback();
      when(() => mockCollection.doc(testFeedback.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any(), any())).thenAnswer((_) async {});

      // Act
      await repository.saveFeedback(testFeedback);

      // Assert
      verify(() => mockCollection.doc(testFeedback.id)).called(1);
      verify(() => mockDocRef.set(any(), any())).called(1);
    });

    test('returns failure on save error', () async {
      // Arrange
      final testFeedback = createTestFeedback();
      when(() => mockCollection.doc(testFeedback.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any(), any()))
          .thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.saveFeedback(testFeedback);

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('getFeedback', () {
    const feedbackId = 'feedback-123';

    test('returns feedback when exists', () async {
      // Arrange
      final testFeedback = createTestFeedback();
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn(testFeedback.toJson());

      // Act
      final result = await repository.getFeedback(feedbackId);

      // Assert - result is now Either<Failure, InsightFeedback?>
      expect(result.isRight(), isTrue);
      final feedback = result.getOrElse((_) => null);
      expect(feedback, isNotNull);
      expect(feedback!.id, testFeedback.id);
    });

    test('returns null when feedback does not exist', () async {
      // Arrange
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.getFeedback(feedbackId);

      // Assert - result is Either with null value (not found)
      expect(result.isRight(), isTrue);
      final feedback = result.getOrElse((_) => null);
      expect(feedback, isNull);
    });

    test('returns failure on get error', () async {
      // Arrange
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenThrow(Exception('Firestore error'));

      // Act
      final result = await repository.getFeedback(feedbackId);

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('getUserFeedback', () {
    const userId = 'user-123';

    test('returns all feedback for user', () async {
      // Arrange
      final feedback1 = createTestFeedback(userId: userId);
      final feedback2 = createTestFeedback(userId: userId, isHelpful: false);

      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc, mockQueryDoc]);

      var callCount = 0;
      when(() => mockQueryDoc.data()).thenAnswer((_) {
        callCount++;
        if (callCount == 1) return feedback1.toJson();
        return feedback2.toJson();
      });

      // Act
      final result = await repository.getUserFeedback(userId);

      // Assert - result is Either<Failure, List<InsightFeedback>>
      expect(result.isRight(), isTrue);
      final feedbackList = result.getOrElse((_) => []);
      expect(feedbackList, hasLength(2));
      expect(feedbackList[0].userId, userId);
      expect(feedbackList[1].userId, userId);
    });

    test('returns empty list when no feedback', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getUserFeedback(userId);

      // Assert - result is Either<Failure, List<InsightFeedback>>
      expect(result.isRight(), isTrue);
      final feedbackList = result.getOrElse((_) => []);
      expect(feedbackList, isEmpty);
    });

    test('returns failure on query error', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act
      final result = await repository.getUserFeedback(userId);

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('getFeedbackByHash', () {
    const userId = 'user-123';
    const insightHash = 'hash123';

    test('returns feedback when exists', () async {
      // Arrange
      final testFeedback = createTestFeedback(
        userId: userId,
        insightHash: insightHash,
      );

      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('insightHash', isEqualTo: insightHash))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(() => mockQueryDoc.data()).thenReturn(testFeedback.toJson());

      // Act
      final result = await repository.getFeedbackByHash(
        userId: userId,
        insightHash: insightHash,
      );

      // Assert - result is Either<Failure, InsightFeedback?>
      expect(result.isRight(), isTrue);
      final feedback = result.getOrElse((_) => null);
      expect(feedback, isNotNull);
      expect(feedback!.userId, userId);
      expect(feedback.insightHash, insightHash);
    });

    test('returns null when no feedback for hash', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('insightHash', isEqualTo: insightHash))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getFeedbackByHash(
        userId: userId,
        insightHash: insightHash,
      );

      // Assert - result is Either<Failure, InsightFeedback?>
      expect(result.isRight(), isTrue);
      final feedback = result.getOrElse((_) => null);
      expect(feedback, isNull);
    });

    test('returns failure on query error', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.where('insightHash', isEqualTo: insightHash))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act
      final result = await repository.getFeedbackByHash(
        userId: userId,
        insightHash: insightHash,
      );

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteFeedback', () {
    const feedbackId = 'feedback-123';

    test('deletes feedback successfully', () async {
      // Arrange
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenAnswer((_) async {});

      // Act
      await repository.deleteFeedback(feedbackId);

      // Assert
      verify(() => mockDocRef.delete()).called(1);
    });

    test('returns failure on delete error', () async {
      // Arrange
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenThrow(Exception('Delete error'));

      // Act
      final result = await repository.deleteFeedback(feedbackId);

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('getFeedbackStats', () {
    const insightType = 'workout_streak';

    test('returns correct stats for insight type', () async {
      // Arrange
      final feedback1 = createTestFeedback(
        insightType: insightType,
        isHelpful: true,
      );
      final feedback2 = createTestFeedback(
        insightType: insightType,
        isHelpful: false,
      );
      final feedback3 = createTestFeedback(
        insightType: insightType,
        isHelpful: true,
      );

      final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockDoc3 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(() => mockDoc1.data()).thenReturn(feedback1.toJson());
      when(() => mockDoc2.data()).thenReturn(feedback2.toJson());
      when(() => mockDoc3.data()).thenReturn(feedback3.toJson());

      when(() => mockCollection.where('insightType', isEqualTo: insightType))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2, mockDoc3]);

      // Act
      final result = await repository.getFeedbackStats(insightType);

      // Assert - result is Either<Failure, Map<String, dynamic>>
      expect(result.isRight(), isTrue);
      final stats = result.getOrElse((_) => <String, dynamic>{});
      expect(stats['total'], 3);
      expect(stats['helpful'], 2);
      expect(stats['notHelpful'], 1);
      expect(stats['helpfulPercentage'], closeTo(66.67, 0.01));
    });

    test('returns zero stats when no feedback', () async {
      // Arrange
      when(() => mockCollection.where('insightType', isEqualTo: insightType))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getFeedbackStats(insightType);

      // Assert - result is Either<Failure, Map<String, dynamic>>
      expect(result.isRight(), isTrue);
      final stats = result.getOrElse((_) => <String, dynamic>{});
      expect(stats['total'], 0);
      expect(stats['helpful'], 0);
      expect(stats['notHelpful'], 0);
      expect(stats['helpfulPercentage'], 0.0);
    });

    test('returns failure on stats query error', () async {
      // Arrange
      when(() => mockCollection.where('insightType', isEqualTo: insightType))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act
      final result = await repository.getFeedbackStats(insightType);

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('getAllFeedback (ADMIN)', () {
    test('returns all feedback ordered by timestamp', () async {
      // Arrange
      final feedback1 = createTestFeedback(isHelpful: true);
      final feedback2 = createTestFeedback(isHelpful: false);

      when(() => mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc, mockQueryDoc]);

      var callCount = 0;
      when(() => mockQueryDoc.data()).thenAnswer((_) {
        callCount++;
        if (callCount == 1) return feedback1.toJson();
        return feedback2.toJson();
      });

      // Act
      final result = await repository.getAllFeedback();

      // Assert - result is Either<Failure, List<InsightFeedback>>
      expect(result.isRight(), isTrue);
      final feedbackList = result.getOrElse((_) => []);
      expect(feedbackList, hasLength(2));
    });

    test('applies limit when specified', () async {
      // Arrange
      when(() => mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(10)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      await repository.getAllFeedback(limit: 10);

      // Assert
      verify(() => mockQuery.limit(10)).called(1);
    });

    test('returns failure on query error', () async {
      // Arrange
      when(() => mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act
      final result = await repository.getAllFeedback();

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });

  group('getOverallStats (ADMIN)', () {
    test('returns correct overall statistics', () async {
      // Arrange
      final feedback1 = createTestFeedback(
        userId: 'user-1',
        insightType: 'workout_streak',
        isHelpful: true,
      );
      final feedback2 = createTestFeedback(
        userId: 'user-1',
        insightType: 'rest_day',
        isHelpful: false,
      );
      final feedback3 = createTestFeedback(
        userId: 'user-2',
        insightType: 'workout_streak',
        isHelpful: true,
      );

      final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockDoc3 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(() => mockDoc1.data()).thenReturn(feedback1.toJson());
      when(() => mockDoc2.data()).thenReturn(feedback2.toJson());
      when(() => mockDoc3.data()).thenReturn(feedback3.toJson());

      when(() => mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2, mockDoc3]);

      // Act
      final result = await repository.getOverallStats();

      // Assert - result is Either<Failure, Map<String, dynamic>>
      expect(result.isRight(), isTrue);
      final stats = result.getOrElse((_) => <String, dynamic>{});
      expect(stats['totalFeedback'], 3);
      expect(stats['totalHelpful'], 2);
      expect(stats['totalNotHelpful'], 1);
      expect(stats['helpfulPercentage'], closeTo(66.67, 0.01));
      expect(stats['uniqueUsers'], 2);

      final byType = stats['byType'] as Map<String, dynamic>;
      expect(byType.containsKey('workout_streak'), true);
      expect(byType.containsKey('rest_day'), true);
    });

    test('returns zero stats when no feedback', () async {
      // Arrange
      when(() => mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getOverallStats();

      // Assert - result is Either<Failure, Map<String, dynamic>>
      expect(result.isRight(), isTrue);
      final stats = result.getOrElse((_) => <String, dynamic>{});
      expect(stats['totalFeedback'], 0);
      expect(stats['totalHelpful'], 0);
      expect(stats['totalNotHelpful'], 0);
      expect(stats['helpfulPercentage'], 0.0);
      expect(stats['uniqueUsers'], 0);
    });

    test('returns failure on stats query error', () async {
      // Arrange
      when(() => mockCollection.get()).thenThrow(Exception('Query error'));

      // Act
      final result = await repository.getOverallStats();

      // Assert - result is Left (failure)
      expect(result.isLeft(), isTrue);
    });
  });
}
