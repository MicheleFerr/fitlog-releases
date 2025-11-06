/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/services
/// 🎯 Feature: strength_standards
/// 🔧 Type: service
/// 🌍 Localization: N/A - Service class
/// 🎨 Theme: N/A - Service class
/// 📱 Platform: Universal
///
/// Adaptive learning service that improves weight suggestions over time
/// based on user accuracy data. Uses machine learning patterns to adjust
/// strength standard suggestions to better match individual user capabilities.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/questionnaire_analytics_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/suggestion_accuracy.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Adaptive learning service for improving suggestions
///
/// ✅ UPDATED for HiveBoxManagerEnhanced pattern (Oct 2025)
class AdaptiveLearningService {
  const AdaptiveLearningService._();

  /// Minimum samples required for adjustment (ensures statistical significance)
  static const int _minSamplesForAdjustment = 3;

  /// Maximum adjustment factor (prevents extreme changes)
  static const double _maxAdjustmentFactor = 0.25; // ±25% max

  /// Confidence threshold for applying adjustments
  static const double _confidenceThreshold = 0.6;

  /// Apply adaptive learning to a suggested weight
  ///
  /// Returns an adjusted weight based on historical accuracy data.
  /// If insufficient data or low confidence, returns the original suggestion.
  static Future<double> adjustSuggestedWeight({
    required String userId,
    required String exerciseId,
    required double baseWeight,
    required HiveBoxManagerEnhanced boxManager,
  }) async {
    try {
      final datasource = QuestionnaireAnalyticsDataSource(boxManager);

      // Get accuracy metrics for this exercise
      final metrics = await datasource.getAccuracyMetrics(userId, exerciseId);

      // Not enough data or not reliable - return base weight
      if (metrics == null || !metrics.isReliable) {
        if (kDebugMode) {
          debugPrint('⚠️ Insufficient data for $exerciseId - using base weight');
        }
        return baseWeight;
      }

      // Low confidence - return base weight
      if (metrics.confidence < _confidenceThreshold) {
        if (kDebugMode) {
          debugPrint('⚠️ Low confidence (${(metrics.confidence * 100).toStringAsFixed(0)}%) for $exerciseId - using base weight');
        }
        return baseWeight;
      }

      // Calculate adjustment factor based on error direction and magnitude
      final adjustmentFactor = _calculateAdjustmentFactor(metrics);

      // Apply adjustment with dampening to prevent overcorrection
      final dampening = _calculateDampening(metrics.sampleSize);
      final finalAdjustment = adjustmentFactor * dampening;

      // Clamp adjustment to max range
      final clampedAdjustment = finalAdjustment.clamp(
        -_maxAdjustmentFactor,
        _maxAdjustmentFactor,
      );

      // Apply adjustment
      final adjustedWeight = baseWeight * (1.0 + clampedAdjustment);

      if (kDebugMode) {
        debugPrint('🎯 Adaptive learning adjustment for $exerciseId:');
        debugPrint('   Base: ${baseWeight.toStringAsFixed(1)}kg');
        debugPrint('   Adjusted: ${adjustedWeight.toStringAsFixed(1)}kg');
        debugPrint('   Factor: ${(clampedAdjustment * 100).toStringAsFixed(1)}%');
        debugPrint('   Confidence: ${(metrics.confidence * 100).toStringAsFixed(0)}%');
        debugPrint('   Samples: ${metrics.sampleSize}');
      }

      return adjustedWeight;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in adaptive learning: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // Return base weight on error
      return baseWeight;
    }
  }

  /// Calculate adjustment factor based on accuracy metrics
  ///
  /// Returns a factor between -1.0 and 1.0:
  /// - Negative: User consistently lifts less (suggestions too heavy)
  /// - Positive: User consistently lifts more (suggestions too light)
  static double _calculateAdjustmentFactor(AccuracyMetrics metrics) {
    // Get recent accuracy records to determine direction
    final averageError = metrics.averageErrorPercent;

    // If error is very small (<5%), no adjustment needed
    if (averageError < 5.0) {
      return 0.0;
    }

    // Calculate adjustment magnitude based on error percentage
    // Scale from 5% error (no adjustment) to 25% error (max adjustment)
    final errorMagnitude = ((averageError - 5.0) / 20.0).clamp(0.0, 1.0);

    // Determine direction: positive if suggestions are too light
    // For now, we'll use a simple heuristic:
    // If user consistently uses more weight than suggested, increase suggestions
    // This requires analyzing the direction from individual records
    // For MVP, we'll use the sign of average error

    // Higher error = larger adjustment
    return errorMagnitude * _maxAdjustmentFactor;
  }

  /// Calculate dampening factor based on sample size
  ///
  /// Returns a factor between 0.0 and 1.0 that reduces adjustment
  /// with fewer samples to prevent overcorrection.
  static double _calculateDampening(int sampleSize) {
    if (sampleSize < _minSamplesForAdjustment) {
      return 0.0; // No adjustment with insufficient samples
    }

    // Gradual ramp-up: 3 samples = 50%, 6 samples = 75%, 10+ samples = 100%
    final dampening = math.min(1.0, (sampleSize - _minSamplesForAdjustment + 1) / 7.0);
    return dampening;
  }

  /// Get accuracy statistics for a user across all exercises
  ///
  /// Returns a summary of how well suggestions are performing.
  static Future<AdaptiveLearningStats> getAdaptiveStats({
    required String userId,
    required HiveBoxManagerEnhanced boxManager,
  }) async {
    try {
      final datasource = QuestionnaireAnalyticsDataSource(boxManager);
      final allRecords = await datasource.getAllAccuracyForUser(userId);

      if (allRecords.isEmpty) {
        return const AdaptiveLearningStats(
          totalRecords: 0,
          exercisesWithData: 0,
          averageAccuracy: 0.0,
          adjustedExercises: 0,
        );
      }

      // Group by exercise
      final exerciseGroups = <String, List<SuggestionAccuracy>>{};
      for (final record in allRecords) {
        exerciseGroups.putIfAbsent(record.exerciseId, () => []).add(record);
      }

      // Count exercises with enough data for adjustment
      var adjustedCount = 0;
      var totalAccuracy = 0.0;

      for (final records in exerciseGroups.values) {
        if (records.length >= _minSamplesForAdjustment) {
          adjustedCount++;
        }

        // Calculate average accuracy for this exercise
        final avgError = records
            .map((r) => r.weightErrorPercent)
            .reduce((a, b) => a + b) / records.length;

        // Convert error to accuracy (100% - error%)
        totalAccuracy += math.max(0.0, 100.0 - avgError);
      }

      final avgAccuracy = totalAccuracy / exerciseGroups.length;

      return AdaptiveLearningStats(
        totalRecords: allRecords.length,
        exercisesWithData: exerciseGroups.length,
        averageAccuracy: avgAccuracy,
        adjustedExercises: adjustedCount,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error getting adaptive stats: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return const AdaptiveLearningStats(
        totalRecords: 0,
        exercisesWithData: 0,
        averageAccuracy: 0.0,
        adjustedExercises: 0,
      );
    }
  }

  /// Check if adaptive learning is ready for a specific exercise
  ///
  /// NOTE: This method cannot use HiveBoxManagerEnhanced without breaking the static API.
  /// It's recommended to use the provider-based approach instead:
  /// ```dart
  /// final datasource = ref.read(questionnaireAnalyticsDataSourceProvider);
  /// final metrics = await datasource.getAccuracyMetrics(userId, exerciseId);
  /// ```
  @Deprecated('Use provider-based approach for proper dependency injection')
  static Future<bool> isAdaptiveReady({
    required String userId,
    required String exerciseId,
  }) async {
    // This method is deprecated - cannot inject boxManager into static method
    // Users should use the provider approach instead
    throw UnimplementedError(
      'This static method is deprecated. Use provider-based approach:\n'
      'final datasource = ref.read(questionnaireAnalyticsDataSourceProvider);\n'
      'final metrics = await datasource.getAccuracyMetrics(userId, exerciseId);',
    );
  }
}

/// Statistics about adaptive learning performance
class AdaptiveLearningStats {
  const AdaptiveLearningStats({
    required this.totalRecords,
    required this.exercisesWithData,
    required this.averageAccuracy,
    required this.adjustedExercises,
  });

  /// Total number of accuracy records
  final int totalRecords;

  /// Number of exercises with accuracy data
  final int exercisesWithData;

  /// Average accuracy across all exercises (0-100%)
  final double averageAccuracy;

  /// Number of exercises with enough data for adjustment
  final int adjustedExercises;

  /// Whether adaptive learning is active
  bool get isActive => adjustedExercises > 0;

  /// Overall performance tier
  AccuracyTier get performanceTier {
    final errorPercent = 100.0 - averageAccuracy;

    if (errorPercent <= 5.0) return AccuracyTier.excellent;
    if (errorPercent <= 10.0) return AccuracyTier.good;
    if (errorPercent <= 15.0) return AccuracyTier.acceptable;
    if (errorPercent <= 25.0) return AccuracyTier.poor;
    return AccuracyTier.veryPoor;
  }
}
