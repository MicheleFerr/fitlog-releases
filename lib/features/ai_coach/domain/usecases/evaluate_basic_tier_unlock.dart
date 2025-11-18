/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/usecases
/// 🎯 Feature: ai_coach
/// 🔧 Type: use_case
///
/// Evaluate Basic Tier Unlock - Calculate readiness score for Basic tier
///
/// **Requirements**:
/// - Minimum 6 workouts logged
/// - Minimum 14 days of data
///
/// **Readiness Score Calculation** (0-100):
/// - **Workout Frequency Score** (40% weight): Recent training volume vs baseline
/// - **Recovery Time Score** (30% weight): Days since last workout
/// - **Training Consistency Score** (30% weight): Adherence to workout schedule
///
/// **Returns**:
/// - `ReadinessScore.locked` if requirements not met
/// - `ReadinessScore` with calculated score, category, and recommendation if unlocked
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/readiness_score.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Evaluate Basic Tier unlock and calculate readiness score
///
/// **Usage**:
/// ```dart
/// final useCase = EvaluateBasicTierUnlock();
/// final score = await useCase.call(
///   workouts: userWorkouts,
///   accountCreatedAt: userCreatedDate,
/// );
///
/// if (score.category == ReadinessCategory.locked) {
///   // Show lock screen
/// } else {
///   // Show readiness score: ${score.emoji} ${score.score}/100
/// }
/// ```
class EvaluateBasicTierUnlock {
  /// Evaluate if user meets Basic tier requirements and calculate readiness
  ///
  /// **Parameters**:
  /// - `workouts`: List of completed workouts
  /// - `accountCreatedAt`: Date when user account was created
  ///
  /// **Returns**: ReadinessScore with calculated values or locked state
  Future<ReadinessScore> call({
    required List<Workout> workouts,
    required DateTime accountCreatedAt,
  }) async {
    // Check if user meets Basic tier unlock criteria
    const config = RecoveryTierConfig.basic;
    final daysSinceCreation =
        DateTime.now().difference(accountCreatedAt).inDays;

    if (workouts.length < config.minWorkouts ||
        daysSinceCreation < config.minDays) {
      // Return locked state with progress info
      return ReadinessScore.locked;
    }

    // User has unlocked Basic tier - calculate readiness score
    return _calculateReadinessScore(workouts, accountCreatedAt);
  }

  /// Calculate readiness score based on 3 factors (40% + 30% + 30%)
  ReadinessScore _calculateReadinessScore(
    List<Workout> workouts,
    DateTime accountCreatedAt,
  ) {
    // Calculate individual factor scores (0-100)
    final workoutFrequencyScore = _calculateWorkoutFrequencyScore(workouts);
    final recoveryTimeScore = _calculateRecoveryTimeScore(workouts);
    final consistencyScore =
        _calculateConsistencyScore(workouts, accountCreatedAt);

    // Calculate weighted overall score
    final overallScore = (
      (workoutFrequencyScore * 0.40) + // 40% weight
          (recoveryTimeScore * 0.30) + // 30% weight
          (consistencyScore * 0.30) // 30% weight
    ).round().clamp(0, 100);

    // Determine category based on score
    final category = _determineCategory(overallScore);

    // Generate recommendation text
    final recommendation = _generateRecommendation(category);

    // Create factors breakdown
    final factors = ReadinessFactors(
      workoutFrequencyScore: workoutFrequencyScore,
      recoveryTimeScore: recoveryTimeScore,
      consistencyScore: consistencyScore,
      daysSinceLastWorkout: _getDaysSinceLastWorkout(workouts),
      workoutsLast7Days: _getWorkoutsLast7Days(workouts),
      avgWorkoutsPerWeek: _calculateAvgWorkoutsPerWeek(
        workouts,
        accountCreatedAt,
      ),
    );

    return ReadinessScore(
      score: overallScore,
      category: category,
      recommendation: recommendation,
      factors: factors,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate workout frequency score (0-100)
  ///
  /// **Logic**: Recent training volume vs baseline
  /// - 0-2 workouts/week: 0-40 (Very Low)
  /// - 3 workouts/week: 50-60 (Low)
  /// - 4 workouts/week: 70-75 (Moderate)
  /// - 5 workouts/week: 80-85 (Good)
  /// - 6+ workouts/week: 90-100 (Optimal)
  int _calculateWorkoutFrequencyScore(List<Workout> workouts) {
    final last7Days = DateTime.now().subtract(const Duration(days: 7));
    final recentWorkouts = workouts
        .where((w) => w.startTime != null && w.startTime!.isAfter(last7Days))
        .length;

    // Map workout count to score (0-100)
    if (recentWorkouts == 0) return 0;
    if (recentWorkouts == 1) return 20;
    if (recentWorkouts == 2) return 40;
    if (recentWorkouts == 3) return 55;
    if (recentWorkouts == 4) return 72;
    if (recentWorkouts == 5) return 82;
    return 95; // 6+ workouts
  }

  /// Calculate recovery time score (0-100)
  ///
  /// **Logic**: Days since last workout
  /// - 0-1 days: 90-100 (Well recovered)
  /// - 2 days: 75-85 (Good recovery)
  /// - 3 days: 60-70 (Moderate recovery)
  /// - 4-5 days: 40-55 (Undertraining risk)
  /// - 6+ days: 0-35 (Detraining risk)
  int _calculateRecoveryTimeScore(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;

    final daysSinceLastWorkout = _getDaysSinceLastWorkout(workouts);

    // Map days to score (0-100)
    if (daysSinceLastWorkout == 0) return 100;
    if (daysSinceLastWorkout == 1) return 90;
    if (daysSinceLastWorkout == 2) return 80;
    if (daysSinceLastWorkout == 3) return 65;
    if (daysSinceLastWorkout == 4) return 50;
    if (daysSinceLastWorkout == 5) return 40;
    if (daysSinceLastWorkout <= 7) return 25;
    return 10; // 8+ days
  }

  /// Calculate training consistency score (0-100)
  ///
  /// **Logic**: Adherence to workout schedule
  /// - Measures variation in workouts per week over time
  /// - Low variation (consistent) = high score
  /// - High variation (inconsistent) = low score
  int _calculateConsistencyScore(
    List<Workout> workouts,
    DateTime accountCreatedAt,
  ) {
    if (workouts.length < 3) return 50; // Not enough data

    // Calculate average workouts per week
    final avgWorkoutsPerWeek =
        _calculateAvgWorkoutsPerWeek(workouts, accountCreatedAt);

    // Calculate standard deviation of workouts per week
    final weeklyWorkouts = _getWeeklyWorkoutCounts(workouts);
    if (weeklyWorkouts.length < 2) return 60;

    final variance = _calculateVariance(weeklyWorkouts, avgWorkoutsPerWeek);
    final stdDev = variance > 0 ? (variance).sqrt() : 0.0;

    // Map standard deviation to score (lower = more consistent = higher score)
    // stdDev 0-0.5: 90-100 (Very consistent)
    // stdDev 0.5-1.0: 75-85 (Good consistency)
    // stdDev 1.0-1.5: 60-70 (Moderate consistency)
    // stdDev 1.5-2.0: 40-55 (Low consistency)
    // stdDev 2.0+: 0-35 (Very inconsistent)
    if (stdDev <= 0.5) return 95;
    if (stdDev <= 1.0) return 80;
    if (stdDev <= 1.5) return 65;
    if (stdDev <= 2.0) return 47;
    return 20;
  }

  /// Determine readiness category from score
  ReadinessCategory _determineCategory(int score) {
    if (score >= 90) return ReadinessCategory.optimal; // 90-100
    if (score >= 75) return ReadinessCategory.good; // 75-89
    if (score >= 60) return ReadinessCategory.moderate; // 60-74
    if (score >= 40) return ReadinessCategory.low; // 40-59
    return ReadinessCategory.veryLow; // 0-39
  }

  /// Generate human-readable recommendation
  String _generateRecommendation(ReadinessCategory category) {
    switch (category) {
      case ReadinessCategory.optimal:
        return 'Great! Ready for a challenging workout.';
      case ReadinessCategory.good:
        return 'Good energy. Perfect for training today.';
      case ReadinessCategory.moderate:
        return 'Moderate energy. Consider a light workout.';
      case ReadinessCategory.low:
        return 'Low readiness. Active recovery or rest recommended.';
      case ReadinessCategory.veryLow:
        return 'Very low readiness. Rest day strongly recommended.';
      case ReadinessCategory.locked:
        return 'Unlock Basic tier by logging 6 workouts over 14 days';
    }
  }

  // ========================================================================
  // Helper Methods
  // ========================================================================

  /// Get days since last workout
  int _getDaysSinceLastWorkout(List<Workout> workouts) {
    if (workouts.isEmpty) return 999;

    // Filter out workouts with null startTime
    final validWorkouts = workouts.where((w) => w.startTime != null).toList();
    if (validWorkouts.isEmpty) return 999;

    final lastWorkout = validWorkouts.reduce((a, b) =>
        a.startTime!.isAfter(b.startTime!) ? a : b);
    return DateTime.now().difference(lastWorkout.startTime!).inDays;
  }

  /// Get workouts in last 7 days
  int _getWorkoutsLast7Days(List<Workout> workouts) {
    final last7Days = DateTime.now().subtract(const Duration(days: 7));
    return workouts
        .where((w) => w.startTime != null && w.startTime!.isAfter(last7Days))
        .length;
  }

  /// Calculate average workouts per week
  double _calculateAvgWorkoutsPerWeek(
    List<Workout> workouts,
    DateTime accountCreatedAt,
  ) {
    if (workouts.isEmpty) return 0.0;

    final daysSinceCreation =
        DateTime.now().difference(accountCreatedAt).inDays;
    final weeks = (daysSinceCreation / 7).clamp(1, double.infinity);

    return workouts.length / weeks;
  }

  /// Get weekly workout counts for consistency calculation
  List<int> _getWeeklyWorkoutCounts(List<Workout> workouts) {
    if (workouts.isEmpty) return [];

    // Filter out workouts with null startTime
    final validWorkouts = workouts.where((w) => w.startTime != null).toList();
    if (validWorkouts.isEmpty) return [];

    // Group workouts by week
    final weeklyMap = <int, int>{};

    for (final workout in validWorkouts) {
      final weekNumber = workout.startTime!.millisecondsSinceEpoch ~/
          (7 * 24 * 60 * 60 * 1000);
      weeklyMap[weekNumber] = (weeklyMap[weekNumber] ?? 0) + 1;
    }

    return weeklyMap.values.toList();
  }

  /// Calculate variance for consistency score
  double _calculateVariance(List<int> values, double mean) {
    if (values.isEmpty) return 0.0;

    final sumSquaredDiffs =
        values.fold(0.0, (sum, val) => sum + ((val - mean) * (val - mean)));

    return sumSquaredDiffs / values.length;
  }
}

/// Extension to add sqrt method to double
extension DoubleExtension on double {
  double sqrt() {
    if (this < 0) return 0;
    // Newton's method for square root
    double x = this;
    double y = 1.0;
    const epsilon = 0.00001;

    while ((x - y).abs() > epsilon) {
      x = (x + y) / 2;
      y = this / x;
    }

    return x;
  }
}
