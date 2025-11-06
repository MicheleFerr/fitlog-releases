/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/analytics/data/repositories
/// 🎯 Feature: analytics_feedback
/// 🔧 Type: repository_test
///
/// ANALYTICS FEEDBACK REPOSITORY TESTS
///
/// Tests per AnalyticsFeedbackRepository - Gestione feedback utente su Analytics
/// Coverage target: 270 lines di implementazione
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/analytics_feedback_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_page_feedback.dart';
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

AnalyticsPageFeedback createTestFeedback({
  String userId = 'user-123',
  bool isHelpful = true,
  String lastViewedSection = 'overview',
}) {
  final now = DateTime.now();
  return AnalyticsPageFeedback(
    id: '${userId}_${now.millisecondsSinceEpoch}',
    userId: userId,
    isHelpful: isHelpful,
    lastViewedSection: lastViewedSection,
    timestamp: now,
    comment: isHelpful ? 'Great features!' : 'Needs improvement',
  );
}

// ============================================================
// MAIN TEST SUITE
// ============================================================

void main() {
  late AnalyticsFeedbackRepository repository;
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
    when(() => mockFirestore.collection('analytics_page_feedback'))
        .thenReturn(mockCollection);

    repository = AnalyticsFeedbackRepository(
      firestore: mockFirestore,
    );
  });

  group('Initialization', () {
    test('repository initializes with firestore instance', () {
      expect(repository, isNotNull);
    });

    test('repository uses default firestore instance when none provided', () {
      // Skip: requires Firebase.initializeApp() in test environment
      // Repository with default firestore is tested via DI in integration tests
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

    test('throws exception on save error', () async {
      // Arrange
      final testFeedback = createTestFeedback();
      when(() => mockCollection.doc(testFeedback.id)).thenReturn(mockDocRef);
      when(() => mockDocRef.set(any(), any()))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => repository.saveFeedback(testFeedback),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getUserLastFeedback', () {
    const userId = 'user-123';

    test('returns last feedback when exists', () async {
      // Arrange
      final testFeedback = createTestFeedback(userId: userId);
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(() => mockQueryDoc.data()).thenReturn(testFeedback.toJson());

      // Act
      final result = await repository.getUserLastFeedback(userId);

      // Assert
      expect(result, isNotNull);
      expect(result!.userId, userId);
      verify(() => mockQuery.limit(1)).called(1);
    });

    test('returns null when no feedback exists', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getUserLastFeedback(userId);

      // Assert
      expect(result, isNull);
    });

    test('throws exception on query error', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(1)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act & Assert
      expect(
        () => repository.getUserLastFeedback(userId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getUserFeedbackHistory', () {
    const userId = 'user-123';

    test('returns all feedback for user ordered by timestamp', () async {
      // Arrange
      final feedback1 = createTestFeedback(userId: userId, isHelpful: true);
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
      final result = await repository.getUserFeedbackHistory(userId);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].userId, userId);
      expect(result[1].userId, userId);
    });

    test('returns empty list when no history', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getUserFeedbackHistory(userId);

      // Assert
      expect(result, isEmpty);
    });

    test('throws exception on history query error', () async {
      // Arrange
      when(() => mockCollection.where('userId', isEqualTo: userId))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act & Assert
      expect(
        () => repository.getUserFeedbackHistory(userId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteFeedback', () {
    const feedbackId = 'user-123_1234567890';

    test('deletes feedback successfully', () async {
      // Arrange
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenAnswer((_) async {});

      // Act
      await repository.deleteFeedback(feedbackId);

      // Assert
      verify(() => mockDocRef.delete()).called(1);
    });

    test('throws exception on delete error', () async {
      // Arrange
      when(() => mockCollection.doc(feedbackId)).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenThrow(Exception('Delete error'));

      // Act & Assert
      expect(
        () => repository.deleteFeedback(feedbackId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getAllFeedback (ADMIN)', () {
    test('returns all feedback with default limit', () async {
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

      // Assert
      expect(result, hasLength(2));
    });

    test('applies isHelpful filter when specified', () async {
      // Arrange
      final feedback = createTestFeedback(isHelpful: true);

      when(() => mockCollection.where('isHelpful', isEqualTo: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(() => mockQueryDoc.data()).thenReturn(feedback.toJson());

      // Act
      final result = await repository.getAllFeedback(isHelpful: true);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].isHelpful, true);
      verify(() => mockCollection.where('isHelpful', isEqualTo: true)).called(1);
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

    test('throws exception on getAllFeedback error', () async {
      // Arrange
      when(() => mockCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act & Assert
      expect(
        () => repository.getAllFeedback(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getOverallStats (ADMIN)', () {
    test('returns correct statistics with data', () async {
      // Arrange
      final feedback1 = createTestFeedback(
        userId: 'user-1',
        isHelpful: true,
        lastViewedSection: 'overview',
      );
      final feedback2 = createTestFeedback(
        userId: 'user-1',
        isHelpful: false,
        lastViewedSection: 'progress',
      );
      final feedback3 = createTestFeedback(
        userId: 'user-2',
        isHelpful: true,
        lastViewedSection: 'overview',
      );

      // Create separate mock docs for each feedback
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

      // Assert
      expect(result['totalFeedback'], 3);
      expect(result['totalHelpful'], 2);
      expect(result['totalNotHelpful'], 1);
      expect(result['helpfulPercentage'], closeTo(66.67, 0.01));
      expect(result['uniqueUsers'], 2);

      final bySection = result['bySection'] as Map<String, dynamic>;
      expect(bySection.containsKey('overview'), true);
      expect(bySection.containsKey('progress'), true);
    });

    test('returns zero stats when no feedback', () async {
      // Arrange
      when(() => mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await repository.getOverallStats();

      // Assert
      expect(result['totalFeedback'], 0);
      expect(result['totalHelpful'], 0);
      expect(result['totalNotHelpful'], 0);
      expect(result['helpfulPercentage'], 0.0);
      expect(result['uniqueUsers'], 0);
    });

    test('throws exception on stats query error', () async {
      // Arrange
      when(() => mockCollection.get()).thenThrow(Exception('Query error'));

      // Act & Assert
      expect(
        () => repository.getOverallStats(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getFeedbackBySection (ADMIN)', () {
    const section = 'overview';

    test('returns feedback for specific section', () async {
      // Arrange
      final feedback = createTestFeedback(lastViewedSection: section);

      when(() => mockCollection.where('lastViewedSection', isEqualTo: section))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
      when(() => mockQueryDoc.data()).thenReturn(feedback.toJson());

      // Act
      final result = await repository.getFeedbackBySection(section);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].lastViewedSection, section);
    });

    test('applies limit when specified', () async {
      // Arrange
      when(() => mockCollection.where('lastViewedSection', isEqualTo: section))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(5)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      // Act
      await repository.getFeedbackBySection(section, limit: 5);

      // Assert
      verify(() => mockQuery.limit(5)).called(1);
    });

    test('throws exception on section query error', () async {
      // Arrange
      when(() => mockCollection.where('lastViewedSection', isEqualTo: section))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act & Assert
      expect(
        () => repository.getFeedbackBySection(section),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getFeedbackCountInRange (ADMIN)', () {
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 1, 31);

    test('returns count for date range', () async {
      // Arrange
      when(() => mockCollection.where(
            'timestamp',
            isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
          )).thenReturn(mockQuery);
      when(() => mockQuery.where(
            'timestamp',
            isLessThanOrEqualTo: any(named: 'isLessThanOrEqualTo'),
          )).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([
        mockQueryDoc,
        mockQueryDoc,
        mockQueryDoc,
      ]);

      // Act
      final result = await repository.getFeedbackCountInRange(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result, 3);
    });

    test('applies isHelpful filter when specified', () async {
      // Arrange
      when(() => mockCollection.where(
            'timestamp',
            isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
          )).thenReturn(mockQuery);
      when(() => mockQuery.where(
            'timestamp',
            isLessThanOrEqualTo: any(named: 'isLessThanOrEqualTo'),
          )).thenReturn(mockQuery);
      when(() => mockQuery.where('isHelpful', isEqualTo: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);

      // Act
      final result = await repository.getFeedbackCountInRange(
        startDate: startDate,
        endDate: endDate,
        isHelpful: true,
      );

      // Assert
      expect(result, 1);
      verify(() => mockQuery.where('isHelpful', isEqualTo: true)).called(1);
    });

    test('throws exception on count query error', () async {
      // Arrange
      when(() => mockCollection.where(
            'timestamp',
            isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
          )).thenReturn(mockQuery);
      when(() => mockQuery.where(
            'timestamp',
            isLessThanOrEqualTo: any(named: 'isLessThanOrEqualTo'),
          )).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Query error'));

      // Act & Assert
      expect(
        () => repository.getFeedbackCountInRange(
          startDate: startDate,
          endDate: endDate,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
