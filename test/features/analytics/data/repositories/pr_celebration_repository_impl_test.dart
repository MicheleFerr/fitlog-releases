// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/pr_celebration_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockIAnalyticsService extends Mock implements IAnalyticsService {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

// Fakes for fallback values
class FakePersonalRecord extends Fake implements PersonalRecord {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePersonalRecord());
  });

  late PRCelebrationRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockIAnalyticsService mockAnalyticsService;
  late MockCollectionReference<Map<String, dynamic>> mockUserCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockCollectionReference<Map<String, dynamic>> mockCelebrationCollection;
  late MockDocumentReference<Map<String, dynamic>> mockCelebrationDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAnalyticsService = MockIAnalyticsService();
    mockUserCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
    mockCelebrationCollection = MockCollectionReference<Map<String, dynamic>>();
    mockCelebrationDoc = MockDocumentReference<Map<String, dynamic>>();

    repository = PRCelebrationRepositoryImpl(
      firestore: mockFirestore,
      analyticsService: mockAnalyticsService,
    );
  });

  // Test data factory
  PersonalRecord createTestPR({
    String id = 'pr-1',
    String exerciseName = 'Bench Press',
    String exerciseId = 'exercise-1',
    PRType type = PRType.weight,
    double value = 100.0,
    String workoutId = 'workout-1',
  }) {
    return PersonalRecord(
      id: id,
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      type: type,
      value: value,
      achievedAt: DateTime.now(),
      workoutId: workoutId,
    );
  }

  group('PRCelebrationRepositoryImpl -', () {
    group('recordCelebration', () {
      test('should record celebration with previous PR value', () async {
        // Arrange
        const userId = 'user-123';
        final pr = createTestPR();

        final mockPreviousPRQuery = MockQuery<Map<String, dynamic>>();
        final mockPreviousPRSnapshot =
            MockQuerySnapshot<Map<String, dynamic>>();
        final mockPreviousPRDoc =
            MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(
          () => mockFirestore.collection('users'),
        ).thenReturn(mockUserCollection);
        when(() => mockUserCollection.doc(userId)).thenReturn(mockUserDoc);
        when(
          () => mockUserDoc.collection('pr_celebrations'),
        ).thenReturn(mockCelebrationCollection);
        when(
          () => mockCelebrationCollection.where(
            'exerciseName',
            isEqualTo: pr.exerciseName,
          ),
        ).thenReturn(mockPreviousPRQuery);
        when(
          () => mockPreviousPRQuery.where(
            'prType',
            isEqualTo: any(named: 'isEqualTo'),
          ),
        ).thenReturn(mockPreviousPRQuery);
        when(
          () => mockPreviousPRQuery.orderBy('celebratedAt', descending: true),
        ).thenReturn(mockPreviousPRQuery);
        when(
          () => mockPreviousPRQuery.limit(1),
        ).thenReturn(mockPreviousPRQuery);
        when(
          () => mockPreviousPRQuery.get(),
        ).thenAnswer((_) async => mockPreviousPRSnapshot);
        when(() => mockPreviousPRSnapshot.docs).thenReturn([mockPreviousPRDoc]);
        when(() => mockPreviousPRDoc.data()).thenReturn({
          'newValue': 90.0, // Previous PR was 90kg
        });

        when(
          () => mockCelebrationCollection.doc(any()),
        ).thenReturn(mockCelebrationDoc);
        when(
          () => mockCelebrationDoc.set(any()),
        ).thenAnswer((_) async => Future.value());

        when(
          () => mockAnalyticsService.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.recordCelebration(userId, pr);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockCelebrationDoc.set(any())).called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'pr_celebration_recorded',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
      });

      test('should handle error when Firestore fails', () async {
        // Arrange
        const userId = 'user-123';
        final pr = createTestPR();

        when(() => mockFirestore.collection('users')).thenThrow(
          FirebaseException(plugin: 'firestore', message: 'Network error'),
        );

        // Act
        final result = await repository.recordCelebration(userId, pr);

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('shouldNotifyUser', () {
      test('should return true when within 5-minute window', () async {
        // Arrange
        const userId = 'user-123';
        final workoutEndTime = DateTime.now().subtract(
          const Duration(minutes: 3),
        );

        // Act
        final result = await repository.shouldNotifyUser(
          userId,
          workoutEndTime,
        );

        // Assert
        result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (shouldNotify) => expect(shouldNotify, true),
        );
      });

      test('should return false when outside 5-minute window', () async {
        // Arrange
        const userId = 'user-123';
        final workoutEndTime = DateTime.now().subtract(
          const Duration(minutes: 10),
        );

        // Act
        final result = await repository.shouldNotifyUser(
          userId,
          workoutEndTime,
        );

        // Assert
        result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (shouldNotify) => expect(shouldNotify, false),
        );
      });
    });

    group('trackEngagement', () {
      test('should update engagement status in Firestore', () async {
        // Arrange
        const userId = 'user-123';
        const prId = 'pr-1';
        const engagement = CelebrationEngagement.shared;

        final mockEngagementQuery = MockQuery<Map<String, dynamic>>();
        final mockEngagementSnapshot =
            MockQuerySnapshot<Map<String, dynamic>>();
        final mockEngagementDoc =
            MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(
          () => mockFirestore.collection('users'),
        ).thenReturn(mockUserCollection);
        when(() => mockUserCollection.doc(userId)).thenReturn(mockUserDoc);
        when(
          () => mockUserDoc.collection('pr_celebrations'),
        ).thenReturn(mockCelebrationCollection);
        when(
          () => mockCelebrationCollection.where('prId', isEqualTo: prId),
        ).thenReturn(mockEngagementQuery);
        when(
          () => mockEngagementQuery.orderBy('celebratedAt', descending: true),
        ).thenReturn(mockEngagementQuery);
        when(
          () => mockEngagementQuery.limit(1),
        ).thenReturn(mockEngagementQuery);
        when(
          () => mockEngagementQuery.get(),
        ).thenAnswer((_) async => mockEngagementSnapshot);
        when(() => mockEngagementSnapshot.docs).thenReturn([mockEngagementDoc]);
        when(() => mockEngagementDoc.reference).thenReturn(mockCelebrationDoc);
        when(
          () => mockCelebrationDoc.update(any()),
        ).thenAnswer((_) async => Future.value());

        when(
          () => mockAnalyticsService.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.trackEngagement(
          userId,
          prId,
          engagement,
        );

        // Assert
        expect(result.isRight(), true);
        verify(() => mockCelebrationDoc.update(any())).called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'pr_celebration_engagement',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
      });
    });

    group('getRecentCelebrations', () {
      test('should return recent celebrations ordered by date', () async {
        // Arrange
        const userId = 'user-123';
        final mockRecentQuery = MockQuery<Map<String, dynamic>>();
        final mockRecentSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockRecentDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(
          () => mockFirestore.collection('users'),
        ).thenReturn(mockUserCollection);
        when(() => mockUserCollection.doc(userId)).thenReturn(mockUserDoc);
        when(
          () => mockUserDoc.collection('pr_celebrations'),
        ).thenReturn(mockCelebrationCollection);
        when(
          () => mockCelebrationCollection.orderBy(
            'celebratedAt',
            descending: true,
          ),
        ).thenReturn(mockRecentQuery);
        when(() => mockRecentQuery.limit(10)).thenReturn(mockRecentQuery);
        when(
          () => mockRecentQuery.get(),
        ).thenAnswer((_) async => mockRecentSnapshot);
        when(() => mockRecentSnapshot.docs).thenReturn([mockRecentDoc]);
        when(() => mockRecentDoc.data()).thenReturn({
          'id': 'celebration-1',
          'userId': userId,
          'prId': 'pr-1',
          'prType': 'weight',
          'celebratedAt': DateTime.now().toIso8601String(),
          'engagement': 'viewed',
          'previousValue': 90.0,
          'newValue': 100.0,
          'exerciseName': 'Bench Press',
        });

        // Act
        final result = await repository.getRecentCelebrations(userId);

        // Assert
        result.fold((failure) => fail('Expected Right, got Left: $failure'), (
          celebrations,
        ) {
          expect(celebrations, isNotEmpty);
          expect(celebrations.length, 1);
        });
      });
    });
  });
}
