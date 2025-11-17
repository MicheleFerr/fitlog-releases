import 'package:fpdart/fpdart.dart' hide Either, Right, Left;
import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/insight.dart';

/// Repository interface for insight engagement tracking
///
/// Tracks user interactions with insights (view, dismiss, action taken)
/// for measuring feature effectiveness and A/B testing via Firebase Remote Config.
abstract class InsightEngagementRepository {
  /// Track when a user views an insight
  ///
  /// Records timestamp and updates Insight entity with viewedAt field.
  /// Used for calculating CTR (click-through rate) and engagement metrics.
  ///
  /// [userId] - User who viewed the insight
  /// [insightId] - Insight identifier
  ///
  /// Returns void on success or Failure if tracking fails.
  Future<fpdart.Either<Failure, void>> trackView(
    String userId,
    String insightId,
  );

  /// Track when a user dismisses an insight without taking action
  ///
  /// Stores dismissal in Hive (local) to prevent showing the same insight
  /// repeatedly. Updates Firebase Analytics for effectiveness measurement.
  ///
  /// [userId] - User who dismissed the insight
  /// [insightId] - Insight identifier
  ///
  /// Returns void on success or Failure if tracking fails.
  Future<fpdart.Either<Failure, void>> trackDismissal(
    String userId,
    String insightId,
  );

  /// Track when a user takes the recommended action from an insight
  ///
  /// Records specific action type (e.g., "started_workout", "adjusted_volume")
  /// for measuring actionability and insight quality.
  ///
  /// Evidence: +40% perceived app intelligence when insights are actionable.
  ///
  /// [userId] - User who took action
  /// [insightId] - Insight identifier
  /// [actionType] - Specific action taken (e.g., "started_workout")
  ///
  /// Returns void on success or Failure if tracking fails.
  Future<fpdart.Either<Failure, void>> trackAction(
    String userId,
    String insightId,
    String actionType,
  );

  /// Get engagement metrics for insights within a date range
  ///
  /// Calculates metrics for A/B testing and feature effectiveness:
  /// - Total insights shown
  /// - Views count
  /// - Dismissals count
  /// - Actions taken count
  /// - CTR (click-through rate): actionTaken / (viewed + dismissed) × 100
  ///
  /// Target CTR: 60%+ (evidence-based from consultant response)
  ///
  /// [userId] - User to calculate metrics for
  /// [startDate] - Start of date range (inclusive)
  /// [endDate] - End of date range (inclusive)
  ///
  /// Returns Map with metric keys:
  /// - 'shown': Total insights shown
  /// - 'viewed': Insights viewed
  /// - 'dismissed': Insights dismissed
  /// - 'actions': Actions taken
  /// - 'ctr': Click-through rate (0-100)
  Future<fpdart.Either<Failure, Map<String, int>>> getEngagementMetrics(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get all dismissed insight IDs for a user
  ///
  /// Used to filter out previously dismissed insights from home screen display.
  ///
  /// [userId] - User whose dismissed insights to fetch
  ///
  /// Returns List<String> of insight IDs dismissed by user.
  Future<fpdart.Either<Failure, List<String>>> getDismissedInsightIds(
    String userId,
  );

  /// Clear dismissed insights older than specified days
  ///
  /// Allows re-showing stale insights after a grace period (e.g., 30 days).
  ///
  /// [userId] - User whose dismissed insights to clean
  /// [olderThanDays] - Days threshold (default: 30)
  ///
  /// Returns void on success or Failure if cleanup fails.
  Future<fpdart.Either<Failure, void>> clearOldDismissals(
    String userId, {
    int olderThanDays = 30,
  });
}
