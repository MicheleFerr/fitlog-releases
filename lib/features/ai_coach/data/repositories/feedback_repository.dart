/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository
///
/// Feedback Repository - Manages user feedback on AI insights
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feedback_data.dart';

/// Repository for managing user feedback on AI insights
///
/// Responsibilities:
/// - Store and retrieve feedback data
/// - Calculate effectiveness metrics by insight type/category
/// - Identify poorly performing insights to suppress
/// - Track engagement statistics
/// - Personalize insights based on feedback history
///
/// Effectiveness formula:
/// ```
/// effectiveness = (helpful + actedUpon) / (helpful + notHelpful + actedUpon)
/// ```
///
/// Suppression rules:
/// - Suppress if effectiveness < 30% with 10+ feedback samples
/// - Suppress if dismissed rate > 70% with 10+ samples
class FeedbackRepository {
  /// In-memory storage (replace with Firestore/Hive in production)
  final Map<String, FeedbackData> _feedbackStore = {};
  final Map<String, FeedbackStats> _statsCache = {};

  /// Effectiveness threshold for suppression (30%)
  static const double suppressionThreshold = 0.3;

  /// Minimum feedback count to make suppression decision
  static const int minFeedbackForSuppression = 10;

  /// Dismissed rate threshold for suppression (70%)
  static const double dismissalRateThreshold = 0.7;

  /// Submit feedback for an insight
  ///
  /// Returns feedback ID
  Future<String> submitFeedback(FeedbackData feedback) async {
    // TODO: Persist to Firestore
    // await _firestore.collection('feedback').doc(feedback.id).set(feedback.toJson());

    _feedbackStore[feedback.id] = feedback;

    // Invalidate stats cache for this insight type
    _statsCache.remove(feedback.insightType);
    _statsCache.remove('category_${feedback.insightCategory}');

    return feedback.id;
  }

  /// Get all feedback for a specific insight
  Future<List<FeedbackData>> getFeedbackForInsight(String insightId) async {
    // TODO: Fetch from Firestore
    // final snapshot = await _firestore.collection('feedback')
    //   .where('insightId', isEqualTo: insightId)
    //   .get();

    return _feedbackStore.values
        .where((f) => f.insightId == insightId)
        .toList();
  }

  /// Get feedback statistics for specific insight type
  ///
  /// Example: getStatsForInsightType('overtraining')
  Future<FeedbackStats> getStatsForInsightType(String insightType) async {
    // Return cached if available
    if (_statsCache.containsKey(insightType)) {
      return _statsCache[insightType]!;
    }

    // TODO: Fetch from Firestore
    // final snapshot = await _firestore.collection('feedback')
    //   .where('insightType', isEqualTo: insightType)
    //   .get();

    final feedbackList =
        _feedbackStore.values.where((f) => f.insightType == insightType);

    final stats = _calculateStats(
      identifier: insightType,
      feedbackList: feedbackList.toList(),
    );

    // Cache result
    _statsCache[insightType] = stats;

    return stats;
  }

  /// Get feedback statistics for specific insight category
  ///
  /// Example: getStatsForCategory('recovery')
  Future<FeedbackStats> getStatsForCategory(String category) async {
    final cacheKey = 'category_$category';

    // Return cached if available
    if (_statsCache.containsKey(cacheKey)) {
      return _statsCache[cacheKey]!;
    }

    // TODO: Fetch from Firestore

    final feedbackList =
        _feedbackStore.values.where((f) => f.insightCategory == category);

    final stats = _calculateStats(
      identifier: category,
      feedbackList: feedbackList.toList(),
    );

    // Cache result
    _statsCache[cacheKey] = stats;

    return stats;
  }

  /// Calculate statistics from feedback list
  FeedbackStats _calculateStats({
    required String identifier,
    required List<FeedbackData> feedbackList,
  }) {
    if (feedbackList.isEmpty) {
      return FeedbackStats(
        identifier: identifier,
        lastUpdated: DateTime.now(),
      );
    }

    int helpfulCount = 0;
    int notHelpfulCount = 0;
    int dismissedCount = 0;
    int actedUponCount = 0;
    double totalViewDuration = 0;

    for (final feedback in feedbackList) {
      switch (feedback.feedbackType) {
        case FeedbackType.helpful:
          helpfulCount++;
        case FeedbackType.notHelpful:
          notHelpfulCount++;
        case FeedbackType.dismissed:
          dismissedCount++;
        case FeedbackType.actedUpon:
          actedUponCount++;
      }

      totalViewDuration += feedback.viewDurationSeconds;
    }

    return FeedbackStats(
      identifier: identifier,
      totalFeedback: feedbackList.length,
      helpfulCount: helpfulCount,
      notHelpfulCount: notHelpfulCount,
      dismissedCount: dismissedCount,
      actedUponCount: actedUponCount,
      avgViewDuration: totalViewDuration / feedbackList.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check if insight type should be suppressed
  ///
  /// Suppression criteria:
  /// - Effectiveness < 30% with 10+ feedback samples
  /// OR
  /// - Dismissed rate > 70% with 10+ samples
  Future<bool> shouldSuppressInsightType(String insightType) async {
    final stats = await getStatsForInsightType(insightType);

    if (stats.totalFeedback < minFeedbackForSuppression) {
      return false; // Not enough data
    }

    // Check effectiveness threshold
    if (stats.effectivenessRate < suppressionThreshold) {
      return true;
    }

    // Check dismissal rate
    final dismissalRate = stats.dismissedCount / stats.totalFeedback;
    if (dismissalRate > dismissalRateThreshold) {
      return true;
    }

    return false;
  }

  /// Check if insight category should be suppressed
  Future<bool> shouldSuppressCategory(String category) async {
    final stats = await getStatsForCategory(category);

    if (stats.totalFeedback < minFeedbackForSuppression) {
      return false; // Not enough data
    }

    return stats.effectivenessRate < suppressionThreshold;
  }

  /// Get most common dismiss reason for insight type
  ///
  /// Helps understand why users dismiss specific insights
  Future<DismissReason?> getMostCommonDismissReason(String insightType) async {
    final feedbackList =
        _feedbackStore.values.where((f) => f.insightType == insightType);

    final dismissReasons =
        feedbackList.where((f) => f.dismissReason != null).toList();

    if (dismissReasons.isEmpty) return null;

    // Count occurrences
    final reasonCounts = <DismissReason, int>{};
    for (final feedback in dismissReasons) {
      reasonCounts[feedback.dismissReason!] =
          (reasonCounts[feedback.dismissReason!] ?? 0) + 1;
    }

    // Find most common
    DismissReason? mostCommon;
    int maxCount = 0;
    reasonCounts.forEach((reason, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = reason;
      }
    });

    return mostCommon;
  }

  /// Get all insight types sorted by effectiveness (best first)
  Future<List<String>> getInsightTypesByEffectiveness() async {
    // TODO: Fetch from Firestore

    final uniqueTypes = _feedbackStore.values.map((f) => f.insightType).toSet();

    final typeStats = <String, FeedbackStats>{};
    for (final type in uniqueTypes) {
      typeStats[type] = await getStatsForInsightType(type);
    }

    // Sort by effectiveness (descending)
    final sortedTypes = typeStats.entries.toList()
      ..sort((a, b) => b.value.effectivenessRate.compareTo(
            a.value.effectivenessRate,
          ));

    return sortedTypes.map((e) => e.key).toList();
  }

  /// Get user's feedback history
  ///
  /// Useful for personalizing insights based on past preferences
  Future<List<FeedbackData>> getUserFeedbackHistory(String userId) async {
    // TODO: Fetch from Firestore
    // final snapshot = await _firestore.collection('feedback')
    //   .where('userId', isEqualTo: userId)
    //   .orderBy('timestamp', descending: true)
    //   .limit(50)
    //   .get();

    return _feedbackStore.values
        .where((f) => f.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Clear all feedback (for testing)
  void clearAll() {
    _feedbackStore.clear();
    _statsCache.clear();
  }
}
