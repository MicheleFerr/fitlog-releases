// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/i_unified_feedback_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UnifiedFeedback _baseFeedback({
  String id = 'feedback-001',
  String userId = 'user-001',
  UnifiedFeedbackType type = UnifiedFeedbackType.general,
  UnifiedFeedbackStatus status = UnifiedFeedbackStatus.open,
  FeedbackSeverity severity = FeedbackSeverity.medium,
  String message = 'Test feedback message that is long enough',
  DateTime? createdAt,
}) {
  return UnifiedFeedback(
    id: id,
    userId: userId,
    type: type,
    status: status,
    severity: severity,
    message: message,
    createdAt: createdAt ?? DateTime(2024, 1, 15, 12),
  );
}

Map<String, dynamic> _baseJson({
  String id = 'feedback-001',
  String userId = 'user-001',
  // The .g.dart uses enum name (aiInsight), not .value (ai_insight).
  // For simple types that match, use the name directly.
  String type = 'general',
  String status = 'open',
  String severity = 'medium',
  String message = 'Test feedback message',
  String createdAt = '2024-01-15T12:00:00.000',
}) {
  return {
    'id': id,
    'userId': userId,
    'type': type,
    'status': status,
    'severity': severity,
    'message': message,
    'createdAt': createdAt,
    'updatedAt': null,
    'resolvedAt': null,
    'reviewedBy': null,
    'adminNotes': null,
    'metadata': <String, dynamic>{},
    'userEmail': null,
    'userDisplayName': null,
  };
}

void main() {
  group('UnifiedFeedback entity', () {
    // ------------------------------------------------------------------
    // Factory constructor
    // ------------------------------------------------------------------
    group('factory constructor', () {
      test('creates instance with required fields', () {
        final feedback = _baseFeedback();

        expect(feedback.id, 'feedback-001');
        expect(feedback.userId, 'user-001');
        expect(feedback.type, UnifiedFeedbackType.general);
        expect(feedback.status, UnifiedFeedbackStatus.open);
        expect(feedback.severity, FeedbackSeverity.medium);
        expect(feedback.message, 'Test feedback message that is long enough');
        expect(feedback.createdAt, DateTime(2024, 1, 15, 12));
      });

      test('optional fields default to null', () {
        final feedback = _baseFeedback();

        expect(feedback.updatedAt, isNull);
        expect(feedback.resolvedAt, isNull);
        expect(feedback.reviewedBy, isNull);
        expect(feedback.adminNotes, isNull);
        expect(feedback.userEmail, isNull);
        expect(feedback.userDisplayName, isNull);
      });

      test('metadata defaults to empty map', () {
        final feedback = _baseFeedback();
        expect(feedback.metadata, isEmpty);
      });

      test('accepts optional fields', () {
        final createdAt = DateTime(2024, 1, 15, 12);
        final updatedAt = DateTime(2024, 1, 16, 10);
        final resolvedAt = DateTime(2024, 1, 17, 9);

        final feedback = UnifiedFeedback(
          id: 'id',
          userId: 'uid',
          type: UnifiedFeedbackType.exercise,
          status: UnifiedFeedbackStatus.resolved,
          severity: FeedbackSeverity.high,
          message: 'Detailed message here',
          createdAt: createdAt,
          updatedAt: updatedAt,
          resolvedAt: resolvedAt,
          reviewedBy: 'admin-001',
          adminNotes: 'Fixed in v1.2',
          metadata: {'exerciseId': 'ex-001'},
          userEmail: 'user@example.com',
          userDisplayName: 'Test User',
        );

        expect(feedback.updatedAt, updatedAt);
        expect(feedback.resolvedAt, resolvedAt);
        expect(feedback.reviewedBy, 'admin-001');
        expect(feedback.adminNotes, 'Fixed in v1.2');
        expect(feedback.metadata['exerciseId'], 'ex-001');
        expect(feedback.userEmail, 'user@example.com');
        expect(feedback.userDisplayName, 'Test User');
      });
    });

    // ------------------------------------------------------------------
    // Equality
    // ------------------------------------------------------------------
    group('equality', () {
      test('two identical instances are equal', () {
        final createdAt = DateTime(2024, 1, 15, 12);
        final a = _baseFeedback(createdAt: createdAt);
        final b = _baseFeedback(createdAt: createdAt);
        expect(a, equals(b));
      });

      test('instances with different ids are not equal', () {
        final createdAt = DateTime(2024, 1, 15, 12);
        final a = _baseFeedback(id: 'id-1', createdAt: createdAt);
        final b = _baseFeedback(id: 'id-2', createdAt: createdAt);
        expect(a, isNot(equals(b)));
      });

      test('instances with different messages are not equal', () {
        final createdAt = DateTime(2024, 1, 15, 12);
        final a = _baseFeedback(
          message: 'Message A that is long enough',
          createdAt: createdAt,
        );
        final b = _baseFeedback(
          message: 'Message B that is long enough',
          createdAt: createdAt,
        );
        expect(a, isNot(equals(b)));
      });
    });

    // ------------------------------------------------------------------
    // copyWith
    // ------------------------------------------------------------------
    group('copyWith', () {
      test('copies with no changes produces equal instance', () {
        final original = _baseFeedback();
        final copy = original.copyWith();
        expect(copy, equals(original));
      });

      test('can change status', () {
        final original = _baseFeedback(status: UnifiedFeedbackStatus.open);
        final updated = original.copyWith(
          status: UnifiedFeedbackStatus.resolved,
        );
        expect(updated.status, UnifiedFeedbackStatus.resolved);
        expect(updated.id, original.id);
      });

      test('can change severity', () {
        final original = _baseFeedback(severity: FeedbackSeverity.low);
        final updated = original.copyWith(severity: FeedbackSeverity.critical);
        expect(updated.severity, FeedbackSeverity.critical);
      });

      test('can set reviewedBy', () {
        final original = _baseFeedback();
        final updated = original.copyWith(reviewedBy: 'admin-xyz');
        expect(updated.reviewedBy, 'admin-xyz');
        expect(original.reviewedBy, isNull); // original is unchanged
      });

      test('original is not mutated', () {
        final original = _baseFeedback(status: UnifiedFeedbackStatus.open);
        // ignore: unused_result
        final _ = original.copyWith(status: UnifiedFeedbackStatus.closed);
        expect(original.status, UnifiedFeedbackStatus.open);
      });
    });

    // ------------------------------------------------------------------
    // JSON serialization
    // ------------------------------------------------------------------
    group('JSON serialization', () {
      test('toJson returns map with all required keys', () {
        final feedback = _baseFeedback();
        final json = feedback.toJson();

        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('userId'), isTrue);
        expect(json.containsKey('type'), isTrue);
        expect(json.containsKey('status'), isTrue);
        expect(json.containsKey('severity'), isTrue);
        expect(json.containsKey('message'), isTrue);
        expect(json.containsKey('createdAt'), isTrue);
        expect(json.containsKey('metadata'), isTrue);
      });

      test('fromJson round-trips correctly', () {
        final original = _baseFeedback();
        final json = original.toJson();
        final restored = UnifiedFeedback.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson parses required fields', () {
        final json = _baseJson();
        final feedback = UnifiedFeedback.fromJson(json);

        expect(feedback.id, 'feedback-001');
        expect(feedback.userId, 'user-001');
        expect(feedback.type, UnifiedFeedbackType.general);
        expect(feedback.status, UnifiedFeedbackStatus.open);
        expect(feedback.severity, FeedbackSeverity.medium);
        expect(feedback.message, 'Test feedback message');
      });

      test('fromJson handles null optional fields', () {
        final json = _baseJson();
        final feedback = UnifiedFeedback.fromJson(json);

        expect(feedback.updatedAt, isNull);
        expect(feedback.resolvedAt, isNull);
        expect(feedback.reviewedBy, isNull);
        expect(feedback.adminNotes, isNull);
        expect(feedback.userEmail, isNull);
        expect(feedback.userDisplayName, isNull);
      });

      test('toJson serializes metadata map', () {
        final feedback = _baseFeedback().copyWith(
          metadata: {'key': 'value', 'count': 42},
        );
        final json = feedback.toJson();
        expect(json['metadata'], {'key': 'value', 'count': 42});
      });
    });

    // ------------------------------------------------------------------
    // UnifiedFeedbackX extensions
    // ------------------------------------------------------------------
    group('UnifiedFeedbackX extensions', () {
      group('isActionable', () {
        test('true when status is open', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.open);
          expect(f.isActionable, isTrue);
        });

        test('true when status is reviewing', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.reviewing);
          expect(f.isActionable, isTrue);
        });

        test('false when status is resolved', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.resolved);
          expect(f.isActionable, isFalse);
        });

        test('false when status is dismissed', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.dismissed);
          expect(f.isActionable, isFalse);
        });

        test('false when status is closed', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.closed);
          expect(f.isActionable, isFalse);
        });
      });

      group('isCompleted', () {
        test('false when status is open', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.open);
          expect(f.isCompleted, isFalse);
        });

        test('true when status is resolved', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.resolved);
          expect(f.isCompleted, isTrue);
        });

        test('true when status is dismissed', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.dismissed);
          expect(f.isCompleted, isTrue);
        });

        test('true when status is closed', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.closed);
          expect(f.isCompleted, isTrue);
        });
      });

      group('typeDisplayTitle', () {
        test('exercise uses exerciseName from metadata', () {
          final f = _baseFeedback(type: UnifiedFeedbackType.exercise).copyWith(
            metadata: {'exerciseName': 'Bench Press'},
          );
          expect(f.typeDisplayTitle, 'Bench Press');
        });

        test('exercise falls back when no exerciseName', () {
          final f = _baseFeedback(type: UnifiedFeedbackType.exercise);
          expect(f.typeDisplayTitle, 'Exercise Feedback');
        });

        test('aiInsight shows insightType', () {
          final f = _baseFeedback(
            type: UnifiedFeedbackType.aiInsight,
          ).copyWith(metadata: {'insightType': 'overtraining'});
          expect(f.typeDisplayTitle, 'AI Insight: overtraining');
        });

        test('aiInsight falls back when no insightType', () {
          final f = _baseFeedback(type: UnifiedFeedbackType.aiInsight);
          expect(f.typeDisplayTitle, 'AI Insight: Unknown');
        });

        test('analytics positive when isHelpful is true', () {
          final f = _baseFeedback(
            type: UnifiedFeedbackType.analytics,
          ).copyWith(metadata: {'isHelpful': true});
          expect(f.typeDisplayTitle, 'Analytics: Positive Feedback');
        });

        test('analytics negative when isHelpful is false', () {
          final f = _baseFeedback(
            type: UnifiedFeedbackType.analytics,
          ).copyWith(metadata: {'isHelpful': false});
          expect(f.typeDisplayTitle, 'Analytics: Needs Improvement');
        });

        test('buddyReport shows targetUserName', () {
          final f = _baseFeedback(
            type: UnifiedFeedbackType.buddyReport,
          ).copyWith(metadata: {'targetUserName': 'BadUser'});
          expect(f.typeDisplayTitle, 'Report: BadUser');
        });

        test('general shows category uppercased', () {
          final f = _baseFeedback(type: UnifiedFeedbackType.general).copyWith(
            metadata: {'category': 'bug'},
          );
          expect(f.typeDisplayTitle, 'General: BUG');
        });

        test('exercisePatch shows fieldName', () {
          final f = _baseFeedback(
            type: UnifiedFeedbackType.exercisePatch,
          ).copyWith(metadata: {'fieldName': 'description'});
          expect(f.typeDisplayTitle, 'Exercise Patch: description');
        });
      });

      group('shortSummary', () {
        test('returns full message when <= 100 chars', () {
          const msg = 'Short message';
          final f = _baseFeedback(message: msg);
          expect(f.shortSummary, msg);
        });

        test('truncates to 97 chars + "..." for long messages', () {
          final longMsg = 'A' * 200;
          final f = _baseFeedback(message: longMsg);
          expect(f.shortSummary.length, 100);
          expect(f.shortSummary.endsWith('...'), isTrue);
        });

        test('message of exactly 100 chars is returned as-is', () {
          final msg = 'B' * 100;
          final f = _baseFeedback(message: msg);
          expect(f.shortSummary, msg);
          expect(f.shortSummary.length, 100);
        });
      });

      group('hasAdminReview', () {
        test('false when reviewedBy is null', () {
          final f = _baseFeedback();
          expect(f.hasAdminReview, isFalse);
        });

        test('true when reviewedBy is set', () {
          final f = _baseFeedback().copyWith(reviewedBy: 'admin-001');
          expect(f.hasAdminReview, isTrue);
        });
      });

      group('daysSinceCreated', () {
        test('returns 0 for feedback created today', () {
          final f = _baseFeedback(createdAt: DateTime.now());
          expect(f.daysSinceCreated, 0);
        });

        test('returns positive number for old feedback', () {
          final old = _baseFeedback(
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          );
          expect(old.daysSinceCreated, greaterThanOrEqualTo(5));
        });
      });

      group('daysSinceUpdated', () {
        test('returns null when updatedAt is null', () {
          final f = _baseFeedback();
          expect(f.daysSinceUpdated, isNull);
        });

        test('returns 0 when updatedAt is now', () {
          final f = _baseFeedback().copyWith(updatedAt: DateTime.now());
          expect(f.daysSinceUpdated, 0);
        });
      });

      group('markAsReviewed', () {
        test('sets status to reviewing', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.open);
          final reviewed = f.markAsReviewed('admin-001');
          expect(reviewed.status, UnifiedFeedbackStatus.reviewing);
        });

        test('sets reviewedBy to given adminUserId', () {
          final f = _baseFeedback();
          final reviewed = f.markAsReviewed('admin-xyz');
          expect(reviewed.reviewedBy, 'admin-xyz');
        });

        test('sets updatedAt', () {
          final f = _baseFeedback();
          final reviewed = f.markAsReviewed('admin-001');
          expect(reviewed.updatedAt, isNotNull);
        });

        test('original is not mutated', () {
          final f = _baseFeedback(status: UnifiedFeedbackStatus.open);
          f.markAsReviewed('admin-001');
          expect(f.status, UnifiedFeedbackStatus.open);
        });
      });

      group('markAsResolved', () {
        test('sets status to resolved', () {
          final f = _baseFeedback();
          final resolved = f.markAsResolved('admin-001');
          expect(resolved.status, UnifiedFeedbackStatus.resolved);
        });

        test('sets reviewedBy', () {
          final f = _baseFeedback();
          final resolved = f.markAsResolved('admin-abc');
          expect(resolved.reviewedBy, 'admin-abc');
        });

        test('sets adminNotes when notes provided', () {
          final f = _baseFeedback();
          final resolved = f.markAsResolved('admin-001', notes: 'Fixed it');
          expect(resolved.adminNotes, 'Fixed it');
        });

        test('sets resolvedAt', () {
          final f = _baseFeedback();
          final resolved = f.markAsResolved('admin-001');
          expect(resolved.resolvedAt, isNotNull);
        });
      });

      group('markAsDismissed', () {
        test('sets status to dismissed', () {
          final f = _baseFeedback();
          final dismissed = f.markAsDismissed('admin-001', reason: 'Duplicate');
          expect(dismissed.status, UnifiedFeedbackStatus.dismissed);
        });

        test('sets adminNotes to reason', () {
          final f = _baseFeedback();
          final dismissed = f.markAsDismissed(
            'admin-001',
            reason: 'Not reproducible',
          );
          expect(dismissed.adminNotes, 'Not reproducible');
        });

        test('sets resolvedAt', () {
          final f = _baseFeedback();
          final dismissed = f.markAsDismissed('admin-001', reason: 'Spam');
          expect(dismissed.resolvedAt, isNotNull);
        });
      });

      group('updateSeverity', () {
        test('changes severity to given value', () {
          final f = _baseFeedback(severity: FeedbackSeverity.low);
          final updated = f.updateSeverity(FeedbackSeverity.critical);
          expect(updated.severity, FeedbackSeverity.critical);
        });

        test('sets updatedAt', () {
          final f = _baseFeedback();
          final updated = f.updateSeverity(FeedbackSeverity.high);
          expect(updated.updatedAt, isNotNull);
        });
      });

      group('addAdminNote', () {
        test('sets adminNotes when previously null', () {
          final f = _baseFeedback();
          final updated = f.addAdminNote('First note');
          expect(updated.adminNotes, 'First note');
        });

        test('appends note to existing notes', () {
          final f = _baseFeedback().copyWith(adminNotes: 'Existing note');
          final updated = f.addAdminNote('New note');
          expect(updated.adminNotes, contains('Existing note'));
          expect(updated.adminNotes, contains('New note'));
        });

        test('sets updatedAt', () {
          final f = _baseFeedback();
          final updated = f.addAdminNote('Some note');
          expect(updated.updatedAt, isNotNull);
        });
      });
    });

    // ------------------------------------------------------------------
    // UnifiedFeedbackFactory static methods
    // ------------------------------------------------------------------
    group('UnifiedFeedbackFactory', () {
      group('createExerciseFeedback', () {
        test('creates feedback with exercise type', () {
          final f = UnifiedFeedbackFactory.createExerciseFeedback(
            userId: 'user-001',
            exerciseId: 'ex-001',
            exerciseName: 'Squat',
            feedbackType: 'BUG',
            message: 'This exercise description is wrong',
            severity: FeedbackSeverity.high,
          );

          expect(f.type, UnifiedFeedbackType.exercise);
          expect(f.status, UnifiedFeedbackStatus.open);
          expect(f.userId, 'user-001');
          expect(f.metadata['exerciseId'], 'ex-001');
          expect(f.metadata['exerciseName'], 'Squat');
          expect(f.metadata['feedbackType'], 'BUG');
        });

        test('includes fieldName in metadata when provided', () {
          final f = UnifiedFeedbackFactory.createExerciseFeedback(
            userId: 'user-001',
            exerciseId: 'ex-001',
            exerciseName: 'Squat',
            feedbackType: 'TYPO',
            message: 'Typo in description',
            severity: FeedbackSeverity.low,
            fieldName: 'description',
          );

          expect(f.metadata['fieldName'], 'description');
        });

        test('does not include fieldName when not provided', () {
          final f = UnifiedFeedbackFactory.createExerciseFeedback(
            userId: 'user-001',
            exerciseId: 'ex-001',
            exerciseName: 'Squat',
            feedbackType: 'BUG',
            message: 'Something is broken here',
            severity: FeedbackSeverity.medium,
          );

          expect(f.metadata.containsKey('fieldName'), isFalse);
        });
      });

      group('createAIInsightFeedback', () {
        test('creates feedback with aiInsight type and low severity', () {
          final f = UnifiedFeedbackFactory.createAIInsightFeedback(
            userId: 'user-001',
            insightId: 'insight-001',
            insightType: 'overtraining',
            insightCategory: 'recovery',
            feedbackType: 'helpful',
          );

          expect(f.type, UnifiedFeedbackType.aiInsight);
          expect(f.severity, FeedbackSeverity.low);
          expect(f.metadata['insightType'], 'overtraining');
          expect(f.metadata['insightCategory'], 'recovery');
        });

        test('includes dismissReason when provided', () {
          final f = UnifiedFeedbackFactory.createAIInsightFeedback(
            userId: 'user-001',
            insightId: 'insight-001',
            insightType: 'progression',
            insightCategory: 'performance',
            feedbackType: 'dismissed',
            dismissReason: 'alreadyKnow',
          );

          expect(f.metadata['dismissReason'], 'alreadyKnow');
        });

        test('uses provided comment as message', () {
          final f = UnifiedFeedbackFactory.createAIInsightFeedback(
            userId: 'user-001',
            insightId: 'i-001',
            insightType: 'load',
            insightCategory: 'performance',
            feedbackType: 'helpful',
            comment: 'Great insight!',
          );

          expect(f.message, 'Great insight!');
        });

        test('uses default message when comment is null', () {
          final f = UnifiedFeedbackFactory.createAIInsightFeedback(
            userId: 'user-001',
            insightId: 'i-001',
            insightType: 'load',
            insightCategory: 'performance',
            feedbackType: 'helpful',
          );

          expect(f.message, 'User feedback on AI insight');
        });
      });

      group('createAnalyticsFeedback', () {
        test('creates positive analytics feedback', () {
          final f = UnifiedFeedbackFactory.createAnalyticsFeedback(
            userId: 'user-001',
            isHelpful: true,
          );

          expect(f.type, UnifiedFeedbackType.analytics);
          expect(f.severity, FeedbackSeverity.medium);
          expect(f.metadata['isHelpful'], isTrue);
          expect(f.message, 'Positive feedback');
        });

        test('creates negative analytics feedback', () {
          final f = UnifiedFeedbackFactory.createAnalyticsFeedback(
            userId: 'user-001',
            isHelpful: false,
          );

          expect(f.metadata['isHelpful'], isFalse);
          expect(f.message, 'Needs improvement');
        });

        test('includes lastViewedSection when provided', () {
          final f = UnifiedFeedbackFactory.createAnalyticsFeedback(
            userId: 'user-001',
            isHelpful: true,
            lastViewedSection: 'progress',
          );

          expect(f.metadata['lastViewedSection'], 'progress');
        });

        test('includes totalWorkoutsViewed when provided', () {
          final f = UnifiedFeedbackFactory.createAnalyticsFeedback(
            userId: 'user-001',
            isHelpful: true,
            totalWorkoutsViewed: 50,
          );

          expect(f.metadata['totalWorkoutsViewed'], 50);
        });
      });

      group('createBuddyReport', () {
        test('creates feedback with buddyReport type and high severity', () {
          final f = UnifiedFeedbackFactory.createBuddyReport(
            reporterId: 'reporter-001',
            targetUserId: 'bad-user-001',
            targetUserName: 'BadUser',
            reportReason: 'HARASSMENT',
            description: 'This user is harassing me',
          );

          expect(f.type, UnifiedFeedbackType.buddyReport);
          expect(f.severity, FeedbackSeverity.high);
          expect(f.userId, 'reporter-001');
          expect(f.metadata['targetUserId'], 'bad-user-001');
          expect(f.metadata['targetUserName'], 'BadUser');
          expect(f.metadata['reportReason'], 'HARASSMENT');
          expect(f.message, 'This user is harassing me');
        });
      });

      group('createGeneralFeedback', () {
        test('creates bug feedback with high severity by default', () {
          final f = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'user-001',
            message: 'App crashes on startup',
            category: 'bug',
          );

          expect(f.type, UnifiedFeedbackType.general);
          expect(f.severity, FeedbackSeverity.high);
          expect(f.metadata['category'], 'bug');
        });

        test('creates feature feedback with medium severity', () {
          final f = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'user-001',
            message: 'Please add dark mode',
            category: 'feature',
          );

          expect(f.severity, FeedbackSeverity.medium);
        });

        test('creates praise feedback with low severity', () {
          final f = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'user-001',
            message: 'Love the app!',
            category: 'praise',
          );

          expect(f.severity, FeedbackSeverity.low);
        });

        test('allows explicit severity override', () {
          final f = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'user-001',
            message: 'Something is off',
            category: 'other',
            severity: FeedbackSeverity.critical,
          );

          expect(f.severity, FeedbackSeverity.critical);
        });

        test('includes optional fields in metadata', () {
          final f = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'user-001',
            message: 'App crashes',
            category: 'bug',
            rating: 2,
            deviceInfo: 'iPhone 15 Pro',
            appVersion: '1.2.3',
          );

          expect(f.metadata['rating'], 2);
          expect(f.metadata['deviceInfo'], 'iPhone 15 Pro');
          expect(f.metadata['appVersion'], '1.2.3');
        });

        test('does not include optional fields when not provided', () {
          final f = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'user-001',
            message: 'Nice app overall',
            category: 'praise',
          );

          expect(f.metadata.containsKey('rating'), isFalse);
          expect(f.metadata.containsKey('deviceInfo'), isFalse);
          expect(f.metadata.containsKey('appVersion'), isFalse);
        });

        test('all factory methods set status to open', () {
          final exercise = UnifiedFeedbackFactory.createExerciseFeedback(
            userId: 'u',
            exerciseId: 'e',
            exerciseName: 'Squat',
            feedbackType: 'BUG',
            message: 'This exercise description is wrong',
            severity: FeedbackSeverity.medium,
          );
          final ai = UnifiedFeedbackFactory.createAIInsightFeedback(
            userId: 'u',
            insightId: 'i',
            insightType: 't',
            insightCategory: 'c',
            feedbackType: 'helpful',
          );
          final analytics = UnifiedFeedbackFactory.createAnalyticsFeedback(
            userId: 'u',
            isHelpful: true,
          );
          final report = UnifiedFeedbackFactory.createBuddyReport(
            reporterId: 'u',
            targetUserId: 'bad',
            targetUserName: 'Bad',
            reportReason: 'SPAM',
            description: 'Spam behavior',
          );
          final general = UnifiedFeedbackFactory.createGeneralFeedback(
            userId: 'u',
            message: 'Some feedback',
            category: 'other',
          );

          expect(exercise.status, UnifiedFeedbackStatus.open);
          expect(ai.status, UnifiedFeedbackStatus.open);
          expect(analytics.status, UnifiedFeedbackStatus.open);
          expect(report.status, UnifiedFeedbackStatus.open);
          expect(general.status, UnifiedFeedbackStatus.open);
        });
      });
    });
  });

  // ------------------------------------------------------------------
  // FeedbackStatistics
  // ------------------------------------------------------------------
  group('FeedbackStatistics', () {
    FeedbackStatistics buildStats({
      int totalCount = 100,
      Map<UnifiedFeedbackType, int>? countsByType,
      Map<UnifiedFeedbackStatus, int>? countsByStatus,
      Map<FeedbackSeverity, int>? countsBySeverity,
      double avgResolutionTimeHours = 24.0,
      List<(String, int)>? mostActiveReporters,
    }) {
      return FeedbackStatistics(
        totalCount: totalCount,
        countsByType: countsByType ??
            {
              UnifiedFeedbackType.exercise: 50,
              UnifiedFeedbackType.general: 50,
            },
        countsByStatus: countsByStatus ??
            {
              UnifiedFeedbackStatus.open: 10,
              UnifiedFeedbackStatus.reviewing: 5,
              UnifiedFeedbackStatus.resolved: 80,
              UnifiedFeedbackStatus.dismissed: 5,
            },
        countsBySeverity: countsBySeverity ??
            {
              FeedbackSeverity.critical: 2,
              FeedbackSeverity.high: 8,
              FeedbackSeverity.medium: 40,
              FeedbackSeverity.low: 50,
            },
        avgResolutionTimeHours: avgResolutionTimeHours,
        mostActiveReporters:
            mostActiveReporters ?? [('user-001', 20), ('user-002', 10)],
      );
    }

    test('getTypePercentage returns 0 when totalCount is 0', () {
      final stats = buildStats(totalCount: 0, countsByType: {});
      expect(
        stats.getTypePercentage(UnifiedFeedbackType.general),
        0.0,
      );
    });

    test('getTypePercentage calculates correct percentage', () {
      final stats = buildStats(
        totalCount: 100,
        countsByType: {UnifiedFeedbackType.exercise: 50},
      );
      expect(
        stats.getTypePercentage(UnifiedFeedbackType.exercise),
        50.0,
      );
    });

    test('getTypePercentage returns 0 for missing type', () {
      final stats = buildStats(totalCount: 100, countsByType: {});
      expect(
        stats.getTypePercentage(UnifiedFeedbackType.analytics),
        0.0,
      );
    });

    test('getStatusPercentage returns correct percentage', () {
      final stats = buildStats(
        totalCount: 100,
        countsByStatus: {UnifiedFeedbackStatus.resolved: 80},
      );
      expect(
        stats.getStatusPercentage(UnifiedFeedbackStatus.resolved),
        80.0,
      );
    });

    test('getSeverityPercentage returns correct percentage', () {
      final stats = buildStats(
        totalCount: 100,
        countsBySeverity: {FeedbackSeverity.critical: 10},
      );
      expect(
        stats.getSeverityPercentage(FeedbackSeverity.critical),
        10.0,
      );
    });

    test('pendingCount sums open and reviewing', () {
      final stats = buildStats(
        countsByStatus: {
          UnifiedFeedbackStatus.open: 10,
          UnifiedFeedbackStatus.reviewing: 5,
          UnifiedFeedbackStatus.resolved: 80,
        },
      );
      expect(stats.pendingCount, 15);
    });

    test('completedCount sums resolved, dismissed and closed', () {
      final stats = buildStats(
        countsByStatus: {
          UnifiedFeedbackStatus.open: 5,
          UnifiedFeedbackStatus.resolved: 70,
          UnifiedFeedbackStatus.dismissed: 10,
          UnifiedFeedbackStatus.closed: 5,
        },
      );
      expect(stats.completedCount, 85);
    });

    test('highPriorityCount sums critical and high', () {
      final stats = buildStats(
        countsBySeverity: {
          FeedbackSeverity.critical: 3,
          FeedbackSeverity.high: 7,
          FeedbackSeverity.medium: 40,
        },
      );
      expect(stats.highPriorityCount, 10);
    });

    test('pendingCount returns 0 when no open/reviewing feedback', () {
      final stats = buildStats(
        countsByStatus: {UnifiedFeedbackStatus.resolved: 100},
      );
      expect(stats.pendingCount, 0);
    });
  });
}
