import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';

void main() {
  group('UserFeedback', () {
    late DateTime testCreatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 0, 0);
    });

    test('should create instance with required fields', () {
      // Act
      final feedback = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
      );

      // Assert
      expect(feedback.id, equals('feedback1'));
      expect(feedback.userId, equals('user1'));
      expect(feedback.message, equals('Great app!'));
      expect(feedback.category, equals(FeedbackCategory.praise));
      expect(feedback.status, equals(FeedbackStatus.newFeedback));
      expect(feedback.createdAt, equals(testCreatedAt));
    });

    test('should have null optional fields by default', () {
      // Act
      final feedback = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
      );

      // Assert
      expect(feedback.rating, isNull);
      expect(feedback.userEmail, isNull);
      expect(feedback.userDisplayName, isNull);
      expect(feedback.deviceInfo, isNull);
      expect(feedback.appVersion, isNull);
      expect(feedback.screenshotUrl, isNull);
      expect(feedback.reviewedAt, isNull);
      expect(feedback.reviewedBy, isNull);
      expect(feedback.adminNotes, isNull);
    });

    test('should create instance with all optional fields', () {
      // Arrange
      final reviewedAt = DateTime(2024, 1, 16, 10, 0, 0);

      // Act
      final feedback = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.reviewed,
        createdAt: testCreatedAt,
        rating: 5,
        userEmail: 'user@example.com',
        userDisplayName: 'John Doe',
        deviceInfo: 'iOS 18.1',
        appVersion: '1.0.0',
        screenshotUrl: 'https://example.com/screenshot.png',
        reviewedAt: reviewedAt,
        reviewedBy: 'admin1',
        adminNotes: 'Positive feedback noted',
      );

      // Assert
      expect(feedback.rating, equals(5));
      expect(feedback.userEmail, equals('user@example.com'));
      expect(feedback.userDisplayName, equals('John Doe'));
      expect(feedback.deviceInfo, equals('iOS 18.1'));
      expect(feedback.appVersion, equals('1.0.0'));
      expect(feedback.screenshotUrl, equals('https://example.com/screenshot.png'));
      expect(feedback.reviewedAt, equals(reviewedAt));
      expect(feedback.reviewedBy, equals('admin1'));
      expect(feedback.adminNotes, equals('Positive feedback noted'));
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final feedback = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
        rating: 5,
        userEmail: 'user@example.com',
      );

      // Act
      final json = feedback.toJson();

      // Assert
      expect(json['id'], equals('feedback1'));
      expect(json['userId'], equals('user1'));
      expect(json['message'], equals('Great app!'));
      expect(json['category'], equals('praise'));
      expect(json['status'], equals('newFeedback'));
      expect(json['createdAt'], equals(testCreatedAt.toIso8601String()));
      expect(json['rating'], equals(5));
      expect(json['userEmail'], equals('user@example.com'));
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'feedback1',
        'userId': 'user1',
        'message': 'Great app!',
        'category': 'praise',
        'status': 'newFeedback',
        'createdAt': testCreatedAt.toIso8601String(),
        'rating': 5,
        'userEmail': 'user@example.com',
        'userDisplayName': 'John Doe',
        'deviceInfo': 'iOS 18.1',
      };

      // Act
      final feedback = UserFeedback.fromJson(json);

      // Assert
      expect(feedback.id, equals('feedback1'));
      expect(feedback.userId, equals('user1'));
      expect(feedback.message, equals('Great app!'));
      expect(feedback.category, equals(FeedbackCategory.praise));
      expect(feedback.status, equals(FeedbackStatus.newFeedback));
      expect(feedback.rating, equals(5));
      expect(feedback.userEmail, equals('user@example.com'));
      expect(feedback.userDisplayName, equals('John Doe'));
      expect(feedback.deviceInfo, equals('iOS 18.1'));
    });

    test('should support copyWith for immutability', () {
      // Arrange
      final feedback = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
        rating: 4,
      );

      // Act
      final updated = feedback.copyWith(
        rating: 5,
        status: FeedbackStatus.reviewed,
      );

      // Assert
      expect(updated.rating, equals(5));
      expect(updated.status, equals(FeedbackStatus.reviewed));
      expect(updated.id, equals('feedback1'));
      expect(updated.message, equals('Great app!'));
      expect(feedback.rating, equals(4));
      expect(feedback.status, equals(FeedbackStatus.newFeedback));
    });

    test('should handle JSON serialization roundtrip', () {
      // Arrange
      final reviewedAt = DateTime(2024, 1, 16, 10, 0, 0);
      final original = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.reviewed,
        createdAt: testCreatedAt,
        rating: 5,
        userEmail: 'user@example.com',
        userDisplayName: 'John Doe',
        deviceInfo: 'iOS 18.1',
        appVersion: '1.0.0',
        reviewedAt: reviewedAt,
        reviewedBy: 'admin1',
      );

      // Act
      final json = original.toJson();
      final deserialized = UserFeedback.fromJson(json);

      // Assert
      expect(deserialized.id, equals(original.id));
      expect(deserialized.userId, equals(original.userId));
      expect(deserialized.message, equals(original.message));
      expect(deserialized.category, equals(original.category));
      expect(deserialized.status, equals(original.status));
      expect(deserialized.rating, equals(original.rating));
      expect(deserialized.userEmail, equals(original.userEmail));
      expect(deserialized.userDisplayName, equals(original.userDisplayName));
      expect(deserialized.deviceInfo, equals(original.deviceInfo));
      expect(deserialized.appVersion, equals(original.appVersion));
    });

    test('should support equality comparison', () {
      // Arrange
      final feedback1 = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
      );

      final feedback2 = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
      );

      final feedback3 = UserFeedback(
        id: 'feedback2',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
      );

      // Assert
      expect(feedback1, equals(feedback2));
      expect(feedback1, isNot(equals(feedback3)));
    });
  });

  group('UserFeedbackFactory', () {
    test('should create new feedback with auto-generated ID', () {
      // Act
      final feedback = UserFeedbackFactory.create(
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
      );

      // Assert
      expect(feedback.id, isNotEmpty);
      expect(feedback.userId, equals('user1'));
      expect(feedback.message, equals('Great app!'));
      expect(feedback.category, equals(FeedbackCategory.praise));
      expect(feedback.status, equals(FeedbackStatus.newFeedback));
      expect(feedback.createdAt, isNotNull);
    });

    test('should create feedback with all optional fields', () {
      // Act
      final feedback = UserFeedbackFactory.create(
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        rating: 5,
        userEmail: 'user@example.com',
        userDisplayName: 'John Doe',
        deviceInfo: 'iOS 18.1',
        appVersion: '1.0.0',
      );

      // Assert
      expect(feedback.rating, equals(5));
      expect(feedback.userEmail, equals('user@example.com'));
      expect(feedback.userDisplayName, equals('John Doe'));
      expect(feedback.deviceInfo, equals('iOS 18.1'));
      expect(feedback.appVersion, equals('1.0.0'));
      expect(feedback.status, equals(FeedbackStatus.newFeedback));
    });

  });

  group('UserFeedbackExtensions - Status Operations', () {
    late UserFeedback feedback;
    late DateTime testCreatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 1, 15, 10, 0, 0);
      feedback = UserFeedback(
        id: 'feedback1',
        userId: 'user1',
        message: 'Great app!',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: testCreatedAt,
      );
    });

    test('markAsReviewed should update status and metadata', () {
      // Act
      final reviewed = feedback.markAsReviewed('admin1');

      // Assert
      expect(reviewed.status, equals(FeedbackStatus.reviewed));
      expect(reviewed.reviewedBy, equals('admin1'));
      expect(reviewed.reviewedAt, isNotNull);
      expect(reviewed.id, equals(feedback.id));
      expect(reviewed.message, equals(feedback.message));
    });

    test('markAsResolved should update status with notes', () {
      // Act
      final resolved = feedback.markAsResolved('admin1', 'Feature implemented');

      // Assert
      expect(resolved.status, equals(FeedbackStatus.resolved));
      expect(resolved.reviewedBy, equals('admin1'));
      expect(resolved.adminNotes, equals('Feature implemented'));
      expect(resolved.reviewedAt, isNotNull);
    });

    test('dismiss should update status with reason', () {
      // Act
      final dismissed = feedback.dismiss('admin1', 'Not actionable');

      // Assert
      expect(dismissed.status, equals(FeedbackStatus.dismissed));
      expect(dismissed.reviewedBy, equals('admin1'));
      expect(dismissed.adminNotes, equals('Not actionable'));
      expect(dismissed.reviewedAt, isNotNull);
    });
  });

  group('UserFeedbackExtensions - Category Icons', () {
    test('categoryIcon should return non-empty icon for all categories', () {
      final categories = FeedbackCategory.values;

      for (final category in categories) {
        final feedback = UserFeedback(
          id: 'f1',
          userId: 'u1',
          message: 'Test',
          category: category,
          status: FeedbackStatus.newFeedback,
          createdAt: DateTime.now(),
        );

        expect(feedback.categoryIcon, isNotEmpty);
        expect(feedback.categoryIcon.length, greaterThan(0));
      }
    });

    test('categoryLabel should return correct labels', () {
      final feedback1 = UserFeedback(
        id: 'f1',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        id: 'f2',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.feature,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      expect(feedback1.categoryLabel, equals('Bug Report'));
      expect(feedback2.categoryLabel, equals('Feature Request'));
    });
  });

  group('UserFeedbackExtensions - Status Icons', () {
    test('statusIcon should return non-empty icon for all statuses', () {
      final statuses = FeedbackStatus.values;

      for (final status in statuses) {
        final feedback = UserFeedback(
          id: 'f1',
          userId: 'u1',
          message: 'Test',
          category: FeedbackCategory.bug,
          status: status,
          createdAt: DateTime.now(),
        );

        expect(feedback.statusIcon, isNotEmpty);
        expect(feedback.statusIcon.length, greaterThan(0));
      }
    });

    test('statusLabel should return correct labels', () {
      final feedback1 = UserFeedback(
        id: 'f1',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        id: 'f2',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.reviewed,
        createdAt: DateTime.now(),
      );

      expect(feedback1.statusLabel, equals('New'));
      expect(feedback2.statusLabel, equals('Reviewed'));
    });
  });

  group('UserFeedbackExtensions - isActionable', () {
    test('isActionable should return true for newFeedback and reviewed', () {
      final feedback1 = UserFeedback(
        id: 'f1',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        id: 'f2',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.reviewed,
        createdAt: DateTime.now(),
      );

      expect(feedback1.isActionable, isTrue);
      expect(feedback2.isActionable, isTrue);
    });

    test('isActionable should return false for resolved and dismissed', () {
      final feedback1 = UserFeedback(
        id: 'f1',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.resolved,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        id: 'f2',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.dismissed,
        createdAt: DateTime.now(),
      );

      expect(feedback1.isActionable, isFalse);
      expect(feedback2.isActionable, isFalse);
    });
  });

  group('UserFeedbackExtensions - ratingStars', () {
    test('ratingStars should return "No rating" when rating is null', () {
      final feedback = UserFeedback(
        id: 'f1',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.bug,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
      );

      expect(feedback.ratingStars, equals('No rating'));
    });

    test('ratingStars should return stars for valid ratings', () {
      final feedback1 = UserFeedback(
        id: 'f1',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
        rating: 1,
      );

      final feedback5 = UserFeedback(
        id: 'f2',
        userId: 'u1',
        message: 'Test',
        category: FeedbackCategory.praise,
        status: FeedbackStatus.newFeedback,
        createdAt: DateTime.now(),
        rating: 5,
      );

      expect(feedback1.ratingStars, isNotEmpty);
      expect(feedback1.ratingStars.length, greaterThan(0));
      expect(feedback5.ratingStars, isNotEmpty);
      expect(feedback5.ratingStars.length, greaterThan(feedback1.ratingStars.length));
    });
  });

  group('FeedbackCategory enum', () {
    test('should have all expected values', () {
      expect(FeedbackCategory.values, contains(FeedbackCategory.bug));
      expect(FeedbackCategory.values, contains(FeedbackCategory.feature));
      expect(FeedbackCategory.values, contains(FeedbackCategory.improvement));
      expect(FeedbackCategory.values, contains(FeedbackCategory.praise));
      expect(FeedbackCategory.values, contains(FeedbackCategory.other));
      expect(FeedbackCategory.values.length, equals(5));
    });
  });

  group('FeedbackStatus enum', () {
    test('should have all expected values', () {
      expect(FeedbackStatus.values, contains(FeedbackStatus.newFeedback));
      expect(FeedbackStatus.values, contains(FeedbackStatus.reviewed));
      expect(FeedbackStatus.values, contains(FeedbackStatus.resolved));
      expect(FeedbackStatus.values, contains(FeedbackStatus.dismissed));
      expect(FeedbackStatus.values.length, equals(4));
    });
  });
}
