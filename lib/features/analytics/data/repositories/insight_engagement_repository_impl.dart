import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/insight_engagement_repository.dart';
import 'package:gymbro_flutter_new/core/services/analytics/hybrid_analytics_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Insight Engagement repository implementation
///
/// Uses Hive for local storage (dismissal tracking) + HybridAnalyticsService
/// for engagement metrics tracking (view, action, dismissal events).
///
/// Dismissals are stored locally to prevent re-showing the same insight.
/// Analytics events are tracked for A/B testing and CTR measurement.
class InsightEngagementRepositoryImpl implements InsightEngagementRepository {
  InsightEngagementRepositoryImpl({
    required this.analyticsService,
    required this.cacheBoxName,
  });

  final HybridAnalyticsService analyticsService;
  final String cacheBoxName;

  /// Get Hive box for local dismissal storage
  Future<Box<Map<dynamic, dynamic>>> _getCacheBox() async {
    if (!Hive.isBoxOpen(cacheBoxName)) {
      return await Hive.openBox<Map<dynamic, dynamic>>(cacheBoxName);
    }
    return Hive.box<Map<dynamic, dynamic>>(cacheBoxName);
  }

  @override
  Future<fpdart.Either<Failure, void>> trackView(
    String userId,
    String insightId,
  ) async {
    try {
      // Track view event in analytics
      await analyticsService.logEvent(
        name: 'insight_viewed',
        parameters: {
          'user_id': userId,
          'insight_id': insightId,
          'viewed_at': DateTime.now().toIso8601String(),
        },
      );

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to track insight view: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> trackDismissal(
    String userId,
    String insightId,
  ) async {
    try {
      final box = await _getCacheBox();
      final dismissalKey = 'dismissals:$userId';

      // Get existing dismissals
      final dismissalsData = box.get(dismissalKey) ?? {};
      final dismissals = Map<String, dynamic>.from(dismissalsData);

      // Add new dismissal with timestamp
      dismissals[insightId] = DateTime.now().toIso8601String();

      // Save to Hive
      await box.put(dismissalKey, dismissals);

      // Track dismissal event in analytics
      await analyticsService.logEvent(
        name: 'insight_dismissed',
        parameters: {
          'user_id': userId,
          'insight_id': insightId,
          'dismissed_at': DateTime.now().toIso8601String(),
        },
      );

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to track insight dismissal: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> trackAction(
    String userId,
    String insightId,
    String actionType,
  ) async {
    try {
      // Track action event in analytics
      await analyticsService.logEvent(
        name: 'insight_action_taken',
        parameters: {
          'user_id': userId,
          'insight_id': insightId,
          'action_type': actionType,
          'action_at': DateTime.now().toIso8601String(),
        },
      );

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to track insight action: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, Map<String, int>>> getEngagementMetrics(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Note: This is a simplified implementation that returns mock metrics.
    // Full implementation would query HybridAnalyticsService event logs
    // and aggregate metrics by date range.
    //
    // For MVP, we track events but defer complex aggregation queries
    // to Phase 4 (Analytics Dashboard).
    try {
      return fpdart.Right({
        'shown': 0,
        'viewed': 0,
        'dismissed': 0,
        'actions': 0,
        'ctr': 0,
      });
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to get engagement metrics: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, List<String>>> getDismissedInsightIds(
    String userId,
  ) async {
    try {
      final box = await _getCacheBox();
      final dismissalKey = 'dismissals:$userId';

      final dismissalsData = box.get(dismissalKey);
      if (dismissalsData == null) {
        return const fpdart.Right([]);
      }

      final dismissals = Map<String, dynamic>.from(dismissalsData);
      return fpdart.Right(dismissals.keys.toList());
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to get dismissed insights: $e'),
      );
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> clearOldDismissals(
    String userId, {
    int olderThanDays = 30,
  }) async {
    try {
      final box = await _getCacheBox();
      final dismissalKey = 'dismissals:$userId';

      final dismissalsData = box.get(dismissalKey);
      if (dismissalsData == null) {
        return const fpdart.Right(null);
      }

      final dismissals = Map<String, dynamic>.from(dismissalsData);
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

      // Remove dismissals older than cutoff
      dismissals.removeWhere((insightId, timestampStr) {
        try {
          final dismissedAt = DateTime.parse(timestampStr as String);
          return dismissedAt.isBefore(cutoffDate);
        } catch (e) {
          // Invalid timestamp, remove it
          return true;
        }
      });

      // Save updated dismissals
      await box.put(dismissalKey, dismissals);

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to clear old dismissals: $e'),
      );
    }
  }
}
