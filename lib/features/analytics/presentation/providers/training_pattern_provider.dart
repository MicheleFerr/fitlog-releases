/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/providers
/// Feature: analytics
/// Type: provider
///
/// TrainingPattern Provider - Computes and caches training pattern detection results
///
/// **Design Decision (UX Best Practices 2024-2025)**:
/// - Uses FutureProvider.family for exercise-specific pattern detection
/// - Results are cached (computed once per exercise, not on each view)
/// - Depends on exerciseAnalyticsProvider for underlying data
/// - Runs pattern detection asynchronously to prevent UI jank
///
/// **Usage**:
/// ```dart
/// final patterns = ref.watch(trainingPatternProvider(exerciseId));
/// patterns.when(
///   data: (results) => _buildPatternCards(results),
///   loading: () => const SizedBox.shrink(),
///   error: (e, _) => const SizedBox.shrink(),
/// );
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/training_pattern.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/training_pattern_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_analytics_provider.dart';

/// Provider for training pattern detection results
///
/// Uses FutureProvider.family to compute patterns per exercise.
/// Patterns are detected ONCE when the provider is first accessed,
/// preventing recalculation on each view open.
final trainingPatternProvider =
    FutureProvider.family<TrainingPatternResults, String>((ref, exerciseId) async {
  // Wait for analytics data to be available
  final analyticsAsync = ref.watch(exerciseAnalyticsProvider(exerciseId));

  // If analytics is still loading or errored, return empty
  if (analyticsAsync.isLoading || analyticsAsync.hasError) {
    return TrainingPatternResults.empty();
  }

  final analyticsData = analyticsAsync.valueOrNull;
  if (analyticsData == null) {
    return TrainingPatternResults.empty();
  }

  // Detect patterns using the service
  // This runs synchronously but is wrapped in FutureProvider for
  // consistent async handling and caching
  final result = TrainingPatternDetector.detect(
    analyticsData: analyticsData,
    minSessions: 3, // Need at least 3 sessions for meaningful patterns
  );

  // 🔧 PERF FIX: Keep alive to cache pattern detection between screen visits
  // Patterns don't change frequently, prevents 5-10 recalculations per session
  ref.keepAlive();

  return result;
});

/// Provider to check if an exercise has any actionable patterns
///
/// Useful for showing/hiding pattern indicators in lists
final hasActionablePatternProvider =
    Provider.family<bool, String>((ref, exerciseId) {
  final patternsAsync = ref.watch(trainingPatternProvider(exerciseId));

  return patternsAsync.maybeWhen(
    data: (results) => results.hasPatterns && results.primaryPattern != null,
    orElse: () => false,
  );
});

/// Provider to check if an exercise has warnings
///
/// Useful for showing warning indicators in lists
final hasPatternWarningProvider =
    Provider.family<bool, String>((ref, exerciseId) {
  final patternsAsync = ref.watch(trainingPatternProvider(exerciseId));

  return patternsAsync.maybeWhen(
    data: (results) => results.hasWarnings,
    orElse: () => false,
  );
});
