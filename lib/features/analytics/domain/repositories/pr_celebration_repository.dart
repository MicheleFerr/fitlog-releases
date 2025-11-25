import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart';

/// Repository interface for PR celebration tracking
///
/// Handles recording personal record celebrations, engagement tracking,
/// and notification timing logic for retention-driving features.
abstract class PRCelebrationRepository {
  /// Record a PR celebration event
  ///
  /// Called immediately after a personal record is detected during
  /// workout completion. Stores celebration metadata including PR details
  /// and initial engagement status.
  ///
  /// [userId] - User who achieved the PR
  /// [pr] - Personal record that was achieved
  ///
  /// Returns void on success or Failure if:
  /// - Persistence failed
  /// - Invalid PR data
  /// - User not authenticated
  Future<fpdart.Either<Failure, void>> recordCelebration(
    String userId,
    PersonalRecord pr,
  );

  /// Track user engagement with a PR celebration
  ///
  /// Updates engagement metrics when user:
  /// - Views celebration modal
  /// - Shares celebration
  /// - Dismisses celebration
  ///
  /// Used for analytics to measure feature effectiveness (retention impact).
  ///
  /// [userId] - User interacting with celebration
  /// [prId] - Personal record identifier
  /// [engagement] - Type of engagement (viewed, shared, dismissed)
  ///
  /// Returns void on success or Failure if update fails.
  Future<fpdart.Either<Failure, void>> trackEngagement(
    String userId,
    String prId,
    CelebrationEngagement engagement,
  );

  /// Determine if user should receive a push notification for PR
  ///
  /// Implements 5-minute post-workout window logic:
  /// - Notification sent 5 minutes after workout completion
  /// - Only if user opted into PR notifications (GDPR compliant)
  /// - Checks if notification was already sent for this PR
  ///
  /// Evidence: Strava +22% retention with delayed PR notifications.
  ///
  /// [userId] - User to check notification eligibility
  /// [workoutEndTime] - When the workout was completed
  ///
  /// Returns true if notification should be sent, false otherwise.
  Future<fpdart.Either<Failure, bool>> shouldNotifyUser(
    String userId,
    DateTime workoutEndTime,
  );

  /// Get recent PR celebrations for a user
  ///
  /// Retrieves most recent celebrations for display in analytics screens
  /// or celebration history views.
  ///
  /// [userId] - User whose celebrations to fetch
  /// [limit] - Maximum number of celebrations to return (default: 10)
  ///
  /// Returns List<PRCelebration> ordered by celebratedAt DESC.
  Future<fpdart.Either<Failure, List<PRCelebration>>> getRecentCelebrations(
    String userId, {
    int limit = 10,
  });

  /// Check if a specific PR has already been celebrated
  ///
  /// Prevents duplicate celebration modals/notifications for the same PR.
  ///
  /// [userId] - User to check
  /// [prId] - Personal record identifier
  ///
  /// Returns true if already celebrated, false otherwise.
  Future<fpdart.Either<Failure, bool>> isCelebrationRecorded(
    String userId,
    String prId,
  );
}
