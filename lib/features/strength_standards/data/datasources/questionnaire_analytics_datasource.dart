/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/datasources
/// 🎯 Feature: strength_standards
/// 🔧 Type: datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Hive datasource for storing questionnaire analytics and suggestion accuracy
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/questionnaire_analytics.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/suggestion_accuracy.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// Local Hive datasource for analytics storage
///
/// ✅ MIGRATED to HiveBoxManagerEnhanced pattern (Oct 2025)
/// - No direct Hive.openBox() calls
/// - Centralized box lifecycle management
class QuestionnaireAnalyticsDataSource {
  /// Constructor with dependency injection
  QuestionnaireAnalyticsDataSource(this._boxManager);
  final HiveBoxManagerEnhanced _boxManager;

  /// Get analytics box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getAnalyticsBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.questionnaireAnalytics);
  }

  /// Get accuracy box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getAccuracyBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.suggestionAccuracy);
  }

  // ============================================================================
  // QUESTIONNAIRE ANALYTICS
  // ============================================================================

  /// Save questionnaire analytics
  Future<void> saveQuestionnaireAnalytics(
    QuestionnaireAnalytics analytics,
  ) async {
    final box = await _getAnalyticsBox();
    final key =
        'analytics_${analytics.userId}_${analytics.startedAt.millisecondsSinceEpoch}';

    final data = analytics.toJson();
    await box.put(key, Map<String, dynamic>.from(data));

    if (kDebugMode) {
      debugPrint(
        '💾 Saved questionnaire analytics for user: ${analytics.userId}',
      );
    }
  }

  /// Get latest analytics for user
  Future<QuestionnaireAnalytics?> getLatestAnalytics(String userId) async {
    final box = await _getAnalyticsBox();

    // Find all entries for this user
    final userEntries = box.keys
        .where((key) => key.toString().startsWith('analytics_$userId'))
        .toList();

    if (userEntries.isEmpty) return null;

    // Sort by timestamp (newest first)
    userEntries.sort((a, b) {
      final timestampA = int.parse(a.toString().split('_').last);
      final timestampB = int.parse(b.toString().split('_').last);
      return timestampB.compareTo(timestampA);
    });

    final latest = box.get(userEntries.first);
    if (latest == null) return null;

    return QuestionnaireAnalytics.fromJson(Map<String, dynamic>.from(latest));
  }

  /// Get all analytics for user
  Future<List<QuestionnaireAnalytics>> getAllAnalytics(String userId) async {
    final box = await _getAnalyticsBox();

    final userEntries = box.keys
        .where((key) => key.toString().startsWith('analytics_$userId'))
        .toList();

    final analytics = <QuestionnaireAnalytics>[];
    for (final key in userEntries) {
      final data = box.get(key);
      if (data != null) {
        analytics.add(
          QuestionnaireAnalytics.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    }

    // Sort by timestamp (newest first)
    analytics.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return analytics;
  }

  /// Get aggregated analytics (admin/debug view)
  Future<QuestionnaireAnalyticsAggregated> getAggregatedAnalytics() async {
    final box = await _getAnalyticsBox();

    final allAnalytics = <QuestionnaireAnalytics>[];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        allAnalytics.add(
          QuestionnaireAnalytics.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    }

    if (allAnalytics.isEmpty) {
      return const QuestionnaireAnalyticsAggregated(
        totalAttempts: 0,
        totalCompletions: 0,
        averageCompletionTime: Duration.zero,
        dropOffByStep: {},
        averageFeedbackByStep: {},
      );
    }

    final completions = allAnalytics.where((a) => a.isCompleted).length;

    // Calculate drop-off by step
    final dropOffByStep = <int, int>{};
    for (final analytics in allAnalytics.where((a) => !a.isCompleted)) {
      final step = analytics.dropOffStep ?? 0;
      dropOffByStep[step] = (dropOffByStep[step] ?? 0) + 1;
    }

    // Calculate average completion time
    final completionTimes = allAnalytics
        .where((a) => a.totalDurationSeconds != null)
        .map((a) => a.totalDurationSeconds!)
        .toList();

    final avgCompletionTime = completionTimes.isEmpty
        ? Duration.zero
        : Duration(
            seconds:
                completionTimes.reduce((a, b) => a + b) ~/
                completionTimes.length,
          );

    // Calculate average feedback by step
    final feedbackByStep = <int, List<int>>{};
    for (final analytics in allAnalytics) {
      analytics.stepFeedback.forEach((step, rating) {
        if (rating != null) {
          feedbackByStep[step] = [...(feedbackByStep[step] ?? []), rating];
        }
      });
    }

    final avgFeedbackByStep = <int, double>{};
    feedbackByStep.forEach((step, ratings) {
      avgFeedbackByStep[step] =
          ratings.reduce((a, b) => a + b) / ratings.length;
    });

    return QuestionnaireAnalyticsAggregated(
      totalAttempts: allAnalytics.length,
      totalCompletions: completions,
      averageCompletionTime: avgCompletionTime,
      dropOffByStep: dropOffByStep,
      averageFeedbackByStep: avgFeedbackByStep,
    );
  }

  // ============================================================================
  // SUGGESTION ACCURACY
  // ============================================================================

  /// Save suggestion accuracy record
  Future<void> saveSuggestionAccuracy(SuggestionAccuracy accuracy) async {
    final box = await _getAccuracyBox();
    final key = 'accuracy_${accuracy.id}';

    final data = accuracy.toJson();
    await box.put(key, Map<String, dynamic>.from(data));

    if (kDebugMode) {
      debugPrint(
        '💾 Saved suggestion accuracy: ${accuracy.exerciseId} (${accuracy.weightErrorPercent.toStringAsFixed(1)}% error)',
      );
    }
  }

  /// Get accuracy records for exercise
  Future<List<SuggestionAccuracy>> getAccuracyForExercise(
    String userId,
    String exerciseId,
  ) async {
    final box = await _getAccuracyBox();

    final records = <SuggestionAccuracy>[];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final accuracy = SuggestionAccuracy.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (accuracy.userId == userId && accuracy.exerciseId == exerciseId) {
          records.add(accuracy);
        }
      }
    }

    // Sort by timestamp (newest first)
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  /// Get all accuracy records for user
  Future<List<SuggestionAccuracy>> getAllAccuracyForUser(String userId) async {
    final box = await _getAccuracyBox();

    final records = <SuggestionAccuracy>[];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final accuracy = SuggestionAccuracy.fromJson(
          Map<String, dynamic>.from(data),
        );

        if (accuracy.userId == userId) {
          records.add(accuracy);
        }
      }
    }

    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  /// Calculate accuracy metrics for exercise
  Future<AccuracyMetrics?> getAccuracyMetrics(
    String userId,
    String exerciseId,
  ) async {
    final records = await getAccuracyForExercise(userId, exerciseId);

    if (records.isEmpty) return null;
    if (records.length < 3) {
      // Not enough data for reliable metrics
      return AccuracyMetrics(
        exerciseId: exerciseId,
        sampleSize: records.length,
        averageErrorPercent: records.first.weightErrorPercent,
        standardDeviation: 0.0,
        trend: AccuracyTrend.insufficient,
        lastUpdated: records.first.timestamp,
      );
    }

    // Calculate average error
    final errors = records.map((r) => r.weightErrorPercent).toList();
    final avgError = errors.reduce((a, b) => a + b) / errors.length;

    // Calculate standard deviation
    final variance =
        errors
            .map((error) => (error - avgError) * (error - avgError))
            .reduce((a, b) => a + b) /
        errors.length;
    final stdDev = math.sqrt(variance);

    // Determine trend (compare first half vs second half)
    final trend = _calculateTrend(records);

    return AccuracyMetrics(
      exerciseId: exerciseId,
      sampleSize: records.length,
      averageErrorPercent: avgError,
      standardDeviation: stdDev,
      trend: trend,
      lastUpdated: records.first.timestamp,
    );
  }

  /// Calculate trend in accuracy over time
  AccuracyTrend _calculateTrend(List<SuggestionAccuracy> records) {
    if (records.length < 6) return AccuracyTrend.insufficient;

    final midpoint = records.length ~/ 2;
    final recentHalf = records.sublist(0, midpoint);
    final olderHalf = records.sublist(midpoint);

    final recentAvg =
        recentHalf.map((r) => r.weightErrorPercent).reduce((a, b) => a + b) /
        recentHalf.length;

    final olderAvg =
        olderHalf.map((r) => r.weightErrorPercent).reduce((a, b) => a + b) /
        olderHalf.length;

    final difference = recentAvg - olderAvg;

    if (difference < -2.0) {
      return AccuracyTrend.improving; // Error decreased by >2%
    }
    if (difference > 2.0) {
      return AccuracyTrend.worsening; // Error increased by >2%
    }
    return AccuracyTrend.stable;
  }

  /// Generate unique ID for accuracy record
  String generateId() {
    return const Uuid().v4();
  }

  /// Clear all data for user (logout/deletion)
  Future<void> clearAllUserData(String userId) async {
    final analyticsBox = await _getAnalyticsBox();
    final accuracyBox = await _getAccuracyBox();

    // Clear analytics
    final analyticsKeys = analyticsBox.keys
        .where((key) => key.toString().contains(userId))
        .toList();
    for (final key in analyticsKeys) {
      await analyticsBox.delete(key);
    }

    // Clear accuracy
    final accuracyKeys = <dynamic>[];
    for (final key in accuracyBox.keys) {
      final data = accuracyBox.get(key);
      if (data != null) {
        final accuracy = SuggestionAccuracy.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (accuracy.userId == userId) {
          accuracyKeys.add(key);
        }
      }
    }
    for (final key in accuracyKeys) {
      await accuracyBox.delete(key);
    }

    if (kDebugMode) {
      debugPrint('🗑️ Cleared all analytics data for user: $userId');
    }
  }
}
