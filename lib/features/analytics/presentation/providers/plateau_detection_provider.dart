/// Plateau Detection Provider for Pro Analytics
///
/// Analyzes exercise activities to detect training plateaus
/// using volume trend analysis.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';

/// Represents a detected plateau for an exercise
class PlateauData {
  const PlateauData({
    required this.exerciseName,
    required this.trendPercent,
    required this.sessionsAnalyzed,
    required this.avgVolume,
    required this.lastSessionDate,
  });

  final String exerciseName;
  final double trendPercent; // Negative = declining, positive = increasing
  final int sessionsAnalyzed;
  final double avgVolume;
  final DateTime lastSessionDate;

  /// Whether this represents a plateau (trend < 10% change)
  bool get isPlateau => trendPercent.abs() < 10;

  /// Whether this is a declining trend
  bool get isDeclining => trendPercent < -5;

  /// Whether this is progressing well
  bool get isProgressing => trendPercent > 5;
}

/// Provider for plateau detection analysis
final plateauDetectionProvider = FutureProvider.autoDispose<List<PlateauData>>((
  ref,
) async {
  final userAsync = ref.watch(currentUserProvider);
  final currentUser = userAsync.value;

  if (currentUser?.email == null) {
    return [];
  }

  try {
    final repository = ref.watch(hybridExerciseActivityRepositoryProvider);
    final activities = await repository.getUserActivities(
      userEmail: currentUser!.email!,
    );

    return _detectPlateaus(activities);
  } catch (e) {
    return [];
  }
});

/// Detect plateaus from exercise activities
List<PlateauData> _detectPlateaus(List<ExerciseActivity> activities) {
  final plateaus = <PlateauData>[];

  if (activities.length < 5) return plateaus;

  // Group by exercise
  final exerciseGroups = <String, List<ExerciseActivity>>{};
  for (final activity in activities) {
    exerciseGroups.putIfAbsent(activity.exerciseName, () => []).add(activity);
  }

  // Analyze each exercise
  for (final entry in exerciseGroups.entries) {
    final exerciseName = entry.key;
    final exerciseActivities = entry.value
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Need at least 5 sessions for meaningful analysis
    if (exerciseActivities.length < 5) continue;

    // Get recent activities (last 30 days)
    final recentActivities = exerciseActivities
        .where(
          (a) => a.createdAt.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        )
        .toList();

    if (recentActivities.length < 3) continue;

    // Calculate volumes
    final volumes = recentActivities.map(_calculateActivityVolume).toList();
    final trend = _calculateTrend(volumes);
    final avgVolume = volumes.isEmpty
        ? 0.0
        : volumes.reduce((a, b) => a + b) / volumes.length;

    plateaus.add(
      PlateauData(
        exerciseName: exerciseName,
        trendPercent: trend * 100,
        sessionsAnalyzed: recentActivities.length,
        avgVolume: avgVolume,
        lastSessionDate: recentActivities.last.createdAt,
      ),
    );
  }

  // Sort by trend (plateaus first, then declining)
  plateaus.sort((a, b) {
    // Priority: plateau > declining > progressing
    if (a.isPlateau && !b.isPlateau) return -1;
    if (!a.isPlateau && b.isPlateau) return 1;
    if (a.isDeclining && !b.isDeclining) return -1;
    if (!a.isDeclining && b.isDeclining) return 1;
    return a.trendPercent.compareTo(b.trendPercent);
  });

  return plateaus;
}

/// Calculate total volume for an activity
///
/// For weighted exercises: volume = weight × reps
/// For bodyweight exercises (weight = 0): volume = reps only
/// This ensures bodyweight exercises like push-ups, pull-ups, dips
/// are properly tracked for plateau detection.
double _calculateActivityVolume(ExerciseActivity activity) {
  double volume = 0;
  for (final set in activity.sets) {
    final weight = double.tryParse(set.weight) ?? 0;
    final reps = int.tryParse(set.reps) ?? 0;

    if (weight > 0) {
      // Weighted exercise: use traditional volume calculation
      volume += weight * reps;
    } else if (reps > 0) {
      // Bodyweight exercise: use reps as volume proxy
      volume += reps.toDouble();
    }
  }
  return volume;
}

/// Calculate trend as percentage change
/// Uses linear regression for more accurate trend detection
double _calculateTrend(List<double> values) {
  if (values.length < 2) return 0;

  final n = values.length;
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

  for (var i = 0; i < n; i++) {
    sumX += i.toDouble();
    sumY += values[i];
    sumXY += i * values[i];
    sumX2 += i * i;
  }

  final denominator = n * sumX2 - sumX * sumX;
  if (denominator == 0) return 0;

  final slope = (n * sumXY - sumX * sumY) / denominator;
  final avgY = sumY / n;

  if (avgY == 0) return 0;
  return slope / avgY;
}
