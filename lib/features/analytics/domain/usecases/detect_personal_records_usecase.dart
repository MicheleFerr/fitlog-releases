/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain
 * 🎯 Feature: analytics
 * 🔧 Type: usecase
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - workout/domain/entities: Workout, Exercise, ExerciseSet
 * - analytics/domain/entities: PersonalRecordAchieved
 * - analytics/domain/services: PRTracker
 */

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

/// Use case for detecting personal records in real-time during workout
class DetectPersonalRecordsUseCase {
  final PRTracker _prTracker;

  DetectPersonalRecordsUseCase(this._prTracker);

  /// Detect potential PRs from current workout state
  Future<List<PersonalRecordAchieved>> execute(
    String userId,
    Workout workout,
  ) async {
    final potentialPRs = <PersonalRecordAchieved>[];

    // Check each exercise for potential PRs
    for (final exercise in workout.exercises) {
      final exercisePRs = await _detectExercisePRs(userId, exercise);
      potentialPRs.addAll(exercisePRs);
    }

    return potentialPRs;
  }

  /// Detect PRs for a specific exercise set completion
  Future<List<PersonalRecordAchieved>> executeForSet(
    String userId,
    Exercise exercise,
    ExerciseSet completedSet,
  ) async {
    final potentialPRs = <PersonalRecordAchieved>[];

    // Get existing PRs for this exercise
    final existingPRs = await _prTracker.getExercisePRs(userId, exercise.id);
    
    // Check weight PR
    final weightPR = _checkWeightPR(exercise, completedSet, existingPRs);
    if (weightPR != null) potentialPRs.add(weightPR);

    // Check reps PR
    final repsPR = _checkRepsPR(exercise, completedSet, existingPRs);
    if (repsPR != null) potentialPRs.add(repsPR);

    // Check 1RM PR
    final oneRMPR = _checkOneRMPR(exercise, completedSet, existingPRs);
    if (oneRMPR != null) potentialPRs.add(oneRMPR);

    return potentialPRs;
  }

  /// Get PR predictions based on current performance
  Future<List<PRPrediction>> getPRPredictions(
    String userId,
    Exercise exercise,
  ) async {
    final predictions = <PRPrediction>[];
    final existingPRs = await _prTracker.getExercisePRs(userId, exercise.id);
    
    // Analyze current sets to predict potential PRs
    for (final set in exercise.sets.where((s) => !s.isCompleted)) {
      if (set.weight > 0 && set.reps > 0) {
        // Predict if this set could be a PR
        final weightPR = existingPRs[PRType.weight];
        if (weightPR == null || set.weight > weightPR.value) {
          predictions.add(PRPrediction(
            type: PRType.weight,
            predictedValue: set.weight,
            currentRecord: weightPR?.value,
            confidence: _calculatePRConfidence(set, weightPR?.value),
            setIndex: exercise.sets.indexOf(set),
          ));
        }

        // Predict 1RM PR
        final estimated1RM = OneRMCalculator.calculateAverage(set.weight, set.reps);
        final oneRMPR = existingPRs[PRType.oneRM];
        if (oneRMPR == null || estimated1RM > oneRMPR.value) {
          predictions.add(PRPrediction(
            type: PRType.oneRM,
            predictedValue: estimated1RM,
            currentRecord: oneRMPR?.value,
            confidence: _calculate1RMConfidence(set.weight, set.reps),
            setIndex: exercise.sets.indexOf(set),
          ));
        }
      }
    }

    return predictions;
  }

  // Private helper methods

  Future<List<PersonalRecordAchieved>> _detectExercisePRs(
    String userId,
    Exercise exercise,
  ) async {
    final prs = <PersonalRecordAchieved>[];
    final existingPRs = await _prTracker.getExercisePRs(userId, exercise.id);
    
    final completedSets = exercise.sets.where((s) => s.isCompleted).toList();
    if (completedSets.isEmpty) return prs;

    // Check volume PR for entire exercise
    final volumePR = _checkVolumePR(exercise, existingPRs);
    if (volumePR != null) prs.add(volumePR);

    // Check total sets PR
    final setsPR = _checkTotalSetsPR(exercise, existingPRs);
    if (setsPR != null) prs.add(setsPR);

    // Check individual set PRs
    for (final set in completedSets.where((s) => !s.isWarmup)) {
      final setPRs = await executeForSet(userId, exercise, set);
      prs.addAll(setPRs);
    }

    return prs;
  }

  PersonalRecordAchieved? _checkWeightPR(
    Exercise exercise,
    ExerciseSet set,
    Map<PRType, PersonalRecord> existingPRs,
  ) {
    if (set.isWarmup || set.weight <= 0) return null;

    final currentRecord = existingPRs[PRType.weight];
    if (currentRecord != null && set.weight <= currentRecord.value) return null;

    return PersonalRecordAchieved(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      type: PRType.weight,
      newValue: set.weight,
      previousValue: currentRecord?.value,
      achievedAt: DateTime.now(),
      context: {
        'reps': set.reps,
        'actualReps': set.actualReps,
        'rpe': set.rpe,
        'setNumber': set.setNumber,
      },
    );
  }

  PersonalRecordAchieved? _checkRepsPR(
    Exercise exercise,
    ExerciseSet set,
    Map<PRType, PersonalRecord> existingPRs,
  ) {
    if (set.isWarmup || set.weight <= 0) return null;

    final actualReps = set.actualReps ?? set.reps;
    if (actualReps <= 0) return null;

    final currentRecord = existingPRs[PRType.reps];
    
    // For reps PR, need to consider both reps and weight
    if (currentRecord != null) {
      final currentWeight = currentRecord.metadata['weight'] as double? ?? 0;
      
      // Only PR if more reps at same or higher weight
      if (set.weight < currentWeight || 
          (set.weight == currentWeight && actualReps <= currentRecord.value)) {
        return null;
      }
    }

    return PersonalRecordAchieved(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      type: PRType.reps,
      newValue: actualReps.toDouble(),
      previousValue: currentRecord?.value,
      achievedAt: DateTime.now(),
      context: {
        'weight': set.weight,
        'rpe': set.rpe,
        'setNumber': set.setNumber,
      },
    );
  }

  PersonalRecordAchieved? _checkOneRMPR(
    Exercise exercise,
    ExerciseSet set,
    Map<PRType, PersonalRecord> existingPRs,
  ) {
    if (set.isWarmup || set.weight <= 0) return null;

    final actualReps = set.actualReps ?? set.reps;
    if (actualReps <= 0) return null;

    final estimated1RM = OneRMCalculator.calculateAverage(set.weight, actualReps);
    final currentRecord = existingPRs[PRType.oneRM];
    
    if (currentRecord != null && estimated1RM <= currentRecord.value) return null;

    return PersonalRecordAchieved(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      type: PRType.oneRM,
      newValue: estimated1RM,
      previousValue: currentRecord?.value,
      achievedAt: DateTime.now(),
      context: {
        'weight': set.weight,
        'reps': actualReps,
        'rpe': set.rpe,
        'setNumber': set.setNumber,
        'formula': 'Average',
      },
    );
  }

  PersonalRecordAchieved? _checkVolumePR(
    Exercise exercise,
    Map<PRType, PersonalRecord> existingPRs,
  ) {
    final completedSets = exercise.sets.where((s) => s.isCompleted && !s.isWarmup).toList();
    if (completedSets.isEmpty) return null;

    final totalVolume = completedSets.fold(0.0, (sum, set) => sum + set.volume);
    final currentRecord = existingPRs[PRType.volume];
    
    if (currentRecord != null && totalVolume <= currentRecord.value) return null;

    return PersonalRecordAchieved(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      type: PRType.volume,
      newValue: totalVolume,
      previousValue: currentRecord?.value,
      achievedAt: DateTime.now(),
      context: {
        'sets': completedSets.length,
        'averageWeight': completedSets.fold(0.0, (sum, s) => sum + s.weight) / completedSets.length,
        'totalReps': completedSets.fold(0, (sum, s) => sum + (s.actualReps ?? s.reps)),
      },
    );
  }

  PersonalRecordAchieved? _checkTotalSetsPR(
    Exercise exercise,
    Map<PRType, PersonalRecord> existingPRs,
  ) {
    final completedSets = exercise.sets.where((s) => s.isCompleted && !s.isWarmup).length;
    if (completedSets <= 0) return null;

    final currentRecord = existingPRs[PRType.totalSets];
    if (currentRecord != null && completedSets <= currentRecord.value) return null;

    return PersonalRecordAchieved(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      type: PRType.totalSets,
      newValue: completedSets.toDouble(),
      previousValue: currentRecord?.value,
      achievedAt: DateTime.now(),
      context: {
        'totalVolume': exercise.sets.where((s) => s.isCompleted).fold(0.0, (sum, s) => sum + s.volume),
      },
    );
  }

  double _calculatePRConfidence(ExerciseSet set, double? currentRecord) {
    if (currentRecord == null) return 0.9; // High confidence for first PR
    
    final improvement = (set.weight - currentRecord) / currentRecord;
    
    // Lower confidence for very large improvements (might be input error)
    if (improvement > 0.2) return 0.3;
    if (improvement > 0.1) return 0.6;
    if (improvement > 0.05) return 0.8;
    
    return 0.9;
  }

  double _calculate1RMConfidence(double weight, int reps) {
    // Higher confidence for lower rep ranges (more accurate 1RM estimation)
    if (reps <= 3) return 0.9;
    if (reps <= 6) return 0.8;
    if (reps <= 10) return 0.6;
    if (reps <= 15) return 0.4;
    
    return 0.2; // Low confidence for high rep estimates
  }
}

/// Prediction for potential personal record
class PRPrediction {
  final PRType type;
  final double predictedValue;
  final double? currentRecord;
  final double confidence; // 0.0 to 1.0
  final int setIndex;

  const PRPrediction({
    required this.type,
    required this.predictedValue,
    this.currentRecord,
    required this.confidence,
    required this.setIndex,
  });

  /// Get improvement percentage if this PR is achieved
  double get improvementPercentage {
    if (currentRecord == null || currentRecord == 0) return 100;
    return ((predictedValue - currentRecord!) / currentRecord!) * 100;
  }

  /// Check if this would be a significant PR
  bool get isSignificant => improvementPercentage > 2.5;

  /// Get confidence level description
  String get confidenceLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    if (confidence >= 0.4) return 'Low';
    return 'Very Low';
  }
}