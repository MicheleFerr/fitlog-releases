// ignore_for_file: avoid_print
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/feedback/data/repositories/firebase_feedback_repository.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';

/// UNIT TEST for FirebaseFeedbackRepository using fake_cloud_firestore
///
/// ✅ Fast execution (no emulator needed)
/// ✅ No platform channels required
/// ✅ In-memory Firestore simulation
///
/// This test suite verifies:
/// - ✅ submitFeedback() writes to Firestore
/// - ✅ getUserFeedback() reads user's feedback
/// - ✅ getAllFeedback() reads all feedback
/// - ✅ getFeedbackByStatus() filters by status
/// - ✅ Repository logic (not real Firebase operations)
void main() {
  late FirebaseFeedbackRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    // Create fresh fake Firestore instance for each test
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirebaseFeedbackRepository(firestore: fakeFirestore);
  });

  group('FirebaseFeedbackRepository - Unit Tests', () {
    test('submitFeedback() should store feedback in Firestore', () async {
      // Arrange
      final feedback = UserFeedback(
        id: 'test_feedback_1',
        userId: 'user_123',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
        rating: 5,
      );

      // Act
      await repository.submitFeedback(feedback);

      // Assert - Verify in Firestore
      final doc = await fakeFirestore
          .collection('userFeedback')
          .doc('test_feedback_1')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()?['userId'], 'user_123');
      expect(doc.data()?['message'], 'Great app!');
      expect(doc.data()?['rating'], 5);
    });

    test('getUserFeedback() should return user-specific feedback', () async {
      // Arrange - Create feedback for 2 users
      final feedback1 = UserFeedback(
        id: 'feedback_1',
        userId: 'user_A',
        message: 'User A feedback',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        id: 'feedback_2',
        userId: 'user_B',
        message: 'User B feedback',
        category: FeedbackCategory.feature,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      await repository.submitFeedback(feedback1);
      await repository.submitFeedback(feedback2);

      // Act
      final userAFeedback = await repository.getUserFeedback('user_A');

      // Assert
      expect(userAFeedback, hasLength(1));
      expect(userAFeedback.first.id, 'feedback_1');
      expect(userAFeedback.first.message, 'User A feedback');
    });

    test('getAllFeedback() should return all feedback', () async {
      // Arrange - Create 3 feedback items
      final feedbacks = [
        UserFeedback(
          id: 'fb_1',
          userId: 'user_1',
          message: 'Feedback 1',
          category: FeedbackCategory.bug,
          status: FeedbackStatus.newFeedback,
          createdAt: DateTime.now(),
        ),
        UserFeedback(
          id: 'fb_2',
          userId: 'user_2',
          message: 'Feedback 2',
          category: FeedbackCategory.feature,
          status: FeedbackStatus.newFeedback,
          createdAt: DateTime.now(),
        ),
        UserFeedback(
          id: 'fb_3',
          userId: 'user_3',
          message: 'Feedback 3',
          category: FeedbackCategory.praise,
          status: FeedbackStatus.reviewed,
          createdAt: DateTime.now(),
        ),
      ];

      for (final feedback in feedbacks) {
        await repository.submitFeedback(feedback);
      }

      // Act
      final allFeedback = await repository.getAllFeedback();

      // Assert
      expect(allFeedback, hasLength(3));
      expect(allFeedback.map((f) => f.id).toSet(), {'fb_1', 'fb_2', 'fb_3'});
    });

    test('getFeedbackByStatus() should filter by status', () async {
      // Arrange - Create feedback with different statuses
      final newFeedback = UserFeedback(
        id: 'new_fb',
        userId: 'user_1',
        message: 'New feedback',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      final reviewedFeedback = UserFeedback(
        id: 'reviewed_fb',
        userId: 'user_2',
        message: 'Reviewed feedback',
        category: FeedbackCategory.feature,
        status: FeedbackStatus.reviewed,
        createdAt: DateTime.now(),
      );

      final resolvedFeedback = UserFeedback(
        id: 'resolved_fb',
        userId: 'user_3',
        message: 'Resolved feedback',
        category: FeedbackCategory.improvement,
        status: FeedbackStatus.resolved,
        createdAt: DateTime.now(),
      );

      await repository.submitFeedback(newFeedback);
      await repository.submitFeedback(reviewedFeedback);
      await repository.submitFeedback(resolvedFeedback);

      // Act
      final newFeedbackList =
          await repository.getFeedbackByStatus(FeedbackStatus.newFeedback);
      final reviewedFeedbackList =
          await repository.getFeedbackByStatus(FeedbackStatus.reviewed);

      // Assert
      expect(newFeedbackList, hasLength(1));
      expect(newFeedbackList.first.id, 'new_fb');

      expect(reviewedFeedbackList, hasLength(1));
      expect(reviewedFeedbackList.first.id, 'reviewed_fb');
    });

    test('getUserFeedback() should return empty list for non-existent user',
        () async {
      // Act
      final feedback = await repository.getUserFeedback('nonexistent_user');

      // Assert
      expect(feedback, isEmpty);
    });

    test('getAllFeedback() should return empty list when no feedback exists',
        () async {
      // Act
      final allFeedback = await repository.getAllFeedback();

      // Assert
      expect(allFeedback, isEmpty);
    });

    test('feedback should be ordered by createdAt descending', () async {
      // Arrange - Create feedback with different timestamps
      final feedback1 = UserFeedback(
        id: 'fb_old',
        userId: 'user_1',
        message: 'Old feedback',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      final feedback2 = UserFeedback(
        id: 'fb_new',
        userId: 'user_1',
        message: 'New feedback',
        category: FeedbackCategory.feature,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      await repository.submitFeedback(feedback1);
      await repository.submitFeedback(feedback2);

      // Act
      final allFeedback = await repository.getAllFeedback();

      // Assert - Most recent first
      expect(allFeedback.first.id, 'fb_new');
      expect(allFeedback.last.id, 'fb_old');
    });

    test('feedback with all optional fields should be stored correctly',
        () async {
      // Arrange
      final feedback = UserFeedback(
        id: 'full_feedback',
        userId: 'user_123',
        message: 'Complete feedback',
        category: FeedbackCategory.feature,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
        rating: 4,
        userEmail: 'user@example.com',
        userDisplayName: 'John Doe',
        deviceInfo: 'iPhone 14 Pro, iOS 17',
        appVersion: '1.2.3',
      );

      // Act
      await repository.submitFeedback(feedback);

      // Assert
      final userFeedback = await repository.getUserFeedback('user_123');

      expect(userFeedback, hasLength(1));
      final retrieved = userFeedback.first;
      expect(retrieved.rating, 4);
      expect(retrieved.userEmail, 'user@example.com');
      expect(retrieved.userDisplayName, 'John Doe');
      expect(retrieved.deviceInfo, 'iPhone 14 Pro, iOS 17');
      expect(retrieved.appVersion, '1.2.3');
    });
  });
}
