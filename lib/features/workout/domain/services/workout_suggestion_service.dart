/// 🏋️‍♂️ GymBro TrackLog - Smart Workout Suggestion Service
///
/// 📁 Layer: features/workout/domain/services
/// 🎯 Feature: Smart Workout Suggestion
/// 🔧 Type: service
///
/// Core service per l'algoritmo di Smart Workout Suggestion
/// Implementa il calcolo muscle readiness + antagonist detection
///
/// Reference: Fitbod algorithm, Bartolomei 2017, JMIR 2024

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_distribution_data.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/antagonist_conflict.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_feedback.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_state.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Service per il calcolo delle Smart Workout Suggestions
///
/// Algorithm overview:
/// 1. Check if user worked out today → REST_MODE
/// 2. Check if enough history (<3 workouts) → INSUFFICIENT_DATA
/// 3. Calculate muscle readiness scores per MuscleGroup
/// 4. Apply CNS fatigue factor
/// 5. Check for antagonist conflicts → WARNING
/// 6. Apply feedback penalties (rejection history)
/// 7. Score templates and pick best → READY
class WorkoutSuggestionService {
  WorkoutSuggestionService({
    this.minWorkoutsRequired = 3,
    this.lookbackDays = 14,
    this.antagonistWarningThreshold = 0.60,
  });

  /// Minimo workouts richiesti per abilitare suggestions
  final int minWorkoutsRequired;

  /// Giorni di history da considerare per readiness
  final int lookbackDays;

  /// Soglia sotto la quale l'antagonista genera warning (60%)
  final double antagonistWarningThreshold;

  // Cache per performance
  Map<MuscleGroup, double>? _cachedReadinessScores;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);

  /// Genera lo stato della suggestion
  ///
  /// Flow:
  /// 1. REST_MODE check → todayWorkout non null
  /// 2. INSUFFICIENT_DATA check → workoutCount < 3
  /// 3. Calculate readiness → READY o WARNING
  Future<SuggestionState> generateSuggestion({
    required List<Workout> workoutHistory,
    required List<WorkoutTemplate> availableTemplates,
    Workout? todayWorkout,
    List<SuggestionFeedback>? feedbackHistory,
  }) async {
    try {
      // ========== STEP 1: REST MODE CHECK ==========
      if (todayWorkout != null) {
        return SuggestionRestMode(todayWorkout: todayWorkout);
      }

      // ========== STEP 2: INSUFFICIENT DATA CHECK ==========
      if (workoutHistory.length < minWorkoutsRequired) {
        return SuggestionInsufficientData(
          workoutCount: workoutHistory.length,
          requiredCount: minWorkoutsRequired,
        );
      }

      // ========== STEP 3: CALCULATE MUSCLE READINESS ==========
      final readinessScores = await _calculateMuscleReadiness(workoutHistory);

      // ========== STEP 4: GET LAST WORKOUT DATES PER MUSCLE ==========
      final lastWorkoutDates = _getLastWorkoutDates(workoutHistory);

      // ========== STEP 5: SCORE TEMPLATES ==========
      final scoredTemplates = _scoreTemplates(
        templates: availableTemplates,
        readinessScores: readinessScores,
        feedbackHistory: feedbackHistory ?? [],
        lastWorkoutDates: lastWorkoutDates,
      );

      if (scoredTemplates.isEmpty) {
        return const SuggestionError(
          message: 'No templates available',
        );
      }

      // Best template = highest score
      final bestTemplate = scoredTemplates.first;

      // ========== STEP 6: CHECK ANTAGONIST CONFLICT ==========
      final primaryMuscle = _getPrimaryMuscleGroup(bestTemplate.template);
      AntagonistConflict? conflict;

      if (primaryMuscle != null) {
        conflict = AntagonistConflictDetector.detectConflict(
          primaryGroup: primaryMuscle,
          readinessScores: readinessScores,
          templateName: bestTemplate.template.name,
          suggestedAlternative: scoredTemplates.length > 1
              ? scoredTemplates[1].template.name
              : null,
          lastWorkoutDates: lastWorkoutDates,
        );
      }

      // ========== STEP 7: BUILD SUGGESTION ==========
      final suggestion = WorkoutSuggestion(
        level: SuggestionLevel.routine, // Will be enhanced later
        workoutName: bestTemplate.template.name,
        confidence: bestTemplate.score,
        reason: _buildReason(bestTemplate, readinessScores, primaryMuscle),
        generatedAt: DateTime.now(),
      );

      // Return WARNING or READY based on conflict
      if (conflict != null && conflict.shouldShowWarning) {
        return SuggestionWarning(
          suggestion: suggestion,
          conflict: conflict,
        );
      }

      return SuggestionReady(suggestion: suggestion);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [SUGGESTION_SERVICE] Error: $e');
        debugPrint('$stack');
      }
      return SuggestionError(
        message: 'Failed to generate suggestion',
        error: e,
      );
    }
  }

  /// Calcola readiness score per ogni gruppo muscolare
  ///
  /// Formula: readiness = (daysSince / optimalRecovery) × volumeDecay × cnsFactor
  ///
  /// - daysSince: giorni dall'ultimo allenamento del gruppo
  /// - optimalRecovery: dipende dal MovementType (48-96h)
  /// - volumeDecay: penalità se volume era alto
  /// - cnsFactor: penalità per compound heavy
  Future<Map<MuscleGroup, double>> _calculateMuscleReadiness(
    List<Workout> workoutHistory,
  ) async {
    // Check cache
    if (_isCacheValid()) {
      return _cachedReadinessScores!;
    }

    final now = DateTime.now();
    final lookbackDate = now.subtract(Duration(days: lookbackDays));

    // Filter recent workouts
    final recentWorkouts = workoutHistory.where((w) {
      return w.startTime != null && w.startTime!.isAfter(lookbackDate);
    }).toList();

    // Initialize all muscles at 100% (fully recovered)
    final readiness = <MuscleGroup, double>{
      for (var muscle in MuscleGroup.values) muscle: 1.0,
    };

    // Track last workout and volume per muscle
    final lastWorkout = <MuscleGroup, DateTime>{};
    final totalVolume = <MuscleGroup, double>{};
    final maxCnsStress = <MuscleGroup, double>{};

    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        final muscleGroup = _categoryToMuscleGroup(exercise.category);
        if (muscleGroup == null) continue;

        // Track last workout date
        final workoutDate = workout.startTime ?? now;
        if (!lastWorkout.containsKey(muscleGroup) ||
            workoutDate.isAfter(lastWorkout[muscleGroup]!)) {
          lastWorkout[muscleGroup] = workoutDate;
        }

        // Accumulate volume
        totalVolume[muscleGroup] = (totalVolume[muscleGroup] ?? 0) + exercise.totalVolume;

        // Track highest CNS stress factor
        final cnsStress = exercise.movementType?.cnsStressFactor ?? 1.0;
        if (!maxCnsStress.containsKey(muscleGroup) ||
            cnsStress < maxCnsStress[muscleGroup]!) {
          maxCnsStress[muscleGroup] = cnsStress;
        }
      }
    }

    // Calculate readiness for each muscle group
    for (final muscle in MuscleGroup.values) {
      if (!lastWorkout.containsKey(muscle)) {
        // Never trained this muscle → fully ready
        readiness[muscle] = 1.0;
        continue;
      }

      // Days since last workout
      final daysSince = now.difference(lastWorkout[muscle]!).inHours / 24.0;

      // Optimal recovery (default 72h if no movementType data)
      const optimalRecoveryDays = 3.0; // 72 hours

      // Base readiness from time
      final baseReadiness = (daysSince / optimalRecoveryDays).clamp(0.0, 1.0);

      // Apply volume decay (high volume = slower recovery)
      final volume = totalVolume[muscle] ?? 0;
      const avgVolume = 5000.0; // kg - baseline
      final volumeFactor = volume > avgVolume
          ? 1.0 - ((volume - avgVolume) / avgVolume * 0.2).clamp(0.0, 0.3)
          : 1.0;

      // Apply CNS stress factor
      final cnsFactor = maxCnsStress[muscle] ?? 1.0;

      // Final readiness
      readiness[muscle] = (baseReadiness * volumeFactor * cnsFactor).clamp(0.0, 1.0);
    }

    // Cache results
    _cachedReadinessScores = readiness;
    _cacheTimestamp = now;

    if (kDebugMode) {
      debugPrint('📊 [READINESS] Calculated scores:');
      for (final entry in readiness.entries) {
        debugPrint('   ${entry.key.name}: ${(entry.value * 100).round()}%');
      }
    }

    return readiness;
  }

  /// Get last workout date per muscle group
  Map<MuscleGroup, DateTime> _getLastWorkoutDates(List<Workout> workoutHistory) {
    final lastDates = <MuscleGroup, DateTime>{};

    for (final workout in workoutHistory) {
      for (final exercise in workout.exercises) {
        final muscleGroup = _categoryToMuscleGroup(exercise.category);
        if (muscleGroup == null) continue;

        final workoutDate = workout.startTime ?? DateTime.now();
        if (!lastDates.containsKey(muscleGroup) ||
            workoutDate.isAfter(lastDates[muscleGroup]!)) {
          lastDates[muscleGroup] = workoutDate;
        }
      }
    }

    return lastDates;
  }

  /// Score all templates based on readiness and feedback
  List<_ScoredTemplate> _scoreTemplates({
    required List<WorkoutTemplate> templates,
    required Map<MuscleGroup, double> readinessScores,
    required List<SuggestionFeedback> feedbackHistory,
    required Map<MuscleGroup, DateTime> lastWorkoutDates,
  }) {
    final scored = <_ScoredTemplate>[];

    if (kDebugMode) {
      debugPrint('🎯 [SCORING] Scoring ${templates.length} templates...');
    }

    for (final template in templates) {
      var score = 0.0;
      var muscleCount = 0;

      if (kDebugMode) {
        debugPrint('📋 [SCORING] Template "${template.name}": ${template.exercises.length} exercises');
        for (final ex in template.exercises) {
          debugPrint('   - ${ex.exerciseName} (${ex.category.name})');
        }
      }

      // Score based on muscle readiness (using ExerciseTemplate.category)
      for (final exerciseTemplate in template.exercises) {
        final muscleGroup = _categoryToMuscleGroup(exerciseTemplate.category);
        if (muscleGroup != null) {
          final readiness = readinessScores[muscleGroup] ?? 1.0;
          score += readiness;
          muscleCount++;
          if (kDebugMode) {
            debugPrint('   → ${muscleGroup.name}: ${(readiness * 100).round()}%');
          }
        }
      }

      // Average readiness across all muscles in template
      if (muscleCount > 0) {
        score = score / muscleCount;
      } else {
        // BUG FIX: Empty templates should not be suggested
        if (kDebugMode) {
          debugPrint('⚠️ [SCORING] Template "${template.name}" has NO valid exercises! Skipping.');
        }
        continue; // Skip empty templates
      }

      // Apply feedback penalty
      final penalty = _calculateFeedbackPenalty(
        templateName: template.name,
        feedbackHistory: feedbackHistory,
      );
      score = score * (1.0 - penalty);

      // Boost for variety (prefer least recently done)
      final primaryMuscle = _getPrimaryMuscleGroup(template);
      if (primaryMuscle != null && lastWorkoutDates.containsKey(primaryMuscle)) {
        final daysSince = DateTime.now()
            .difference(lastWorkoutDates[primaryMuscle]!)
            .inDays;
        // Small variety boost (max 10%)
        score = score * (1.0 + (daysSince / 30.0 * 0.1).clamp(0.0, 0.1));
      }

      if (kDebugMode) {
        debugPrint('✅ [SCORING] "${template.name}" final score: ${(score * 100).round()}%');
      }

      scored.add(_ScoredTemplate(template: template, score: score.clamp(0.0, 1.0)));
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    if (kDebugMode && scored.isNotEmpty) {
      debugPrint('🏆 [SCORING] Best template: "${scored.first.template.name}" (${(scored.first.score * 100).round()}%)');
    }

    return scored;
  }

  /// Calculate penalty from rejection history
  double _calculateFeedbackPenalty({
    required String templateName,
    required List<SuggestionFeedback> feedbackHistory,
  }) {
    var totalPenalty = 0.0;

    // Only consider recent feedback (last 7 days)
    final recentCutoff = DateTime.now().subtract(const Duration(days: 7));

    for (final feedback in feedbackHistory) {
      if (feedback.timestamp.isBefore(recentCutoff)) continue;
      if (feedback.templateSuggested != templateName) continue;
      if (feedback.accepted) continue; // No penalty for acceptance

      // Apply penalty based on rejection reason
      final reason = feedback.rejectionReason;
      if (reason != null) {
        totalPenalty += reason.penaltyFactor;
      }
    }

    return totalPenalty.clamp(0.0, 0.8); // Max 80% penalty
  }

  /// Build human-readable reason for suggestion
  String _buildReason(
    _ScoredTemplate scored,
    Map<MuscleGroup, double> readinessScores,
    MuscleGroup? primaryMuscle,
  ) {
    if (primaryMuscle == null) {
      return 'Based on your workout history';
    }

    final readiness = readinessScores[primaryMuscle] ?? 1.0;
    final readinessPercent = (readiness * 100).round();

    if (readinessPercent >= 90) {
      return '${primaryMuscle.displayNameEN} fully recovered ($readinessPercent%)';
    } else if (readinessPercent >= 70) {
      return '${primaryMuscle.displayNameEN} ready ($readinessPercent%)';
    } else {
      return '${primaryMuscle.displayNameEN} recovering ($readinessPercent%)';
    }
  }

  /// Get primary muscle group from template
  MuscleGroup? _getPrimaryMuscleGroup(WorkoutTemplate template) {
    if (template.exercises.isEmpty) return null;

    // Count exercises per muscle group (using ExerciseTemplate)
    final counts = <MuscleGroup, int>{};
    for (final exerciseTemplate in template.exercises) {
      final muscle = _categoryToMuscleGroup(exerciseTemplate.category);
      if (muscle != null) {
        counts[muscle] = (counts[muscle] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return null;

    // Return most common muscle group
    return counts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Map ExerciseCategory to MuscleGroup
  MuscleGroup? _categoryToMuscleGroup(ExerciseCategory category) {
    return switch (category) {
      ExerciseCategory.chest => MuscleGroup.petto,
      ExerciseCategory.back => MuscleGroup.schiena,
      ExerciseCategory.shoulders => MuscleGroup.spalle,
      ExerciseCategory.arms => MuscleGroup.braccia,
      ExerciseCategory.legs => MuscleGroup.gambe,
      ExerciseCategory.abs => MuscleGroup.addome,
      ExerciseCategory.cardio => null,
      ExerciseCategory.other => null,
    };
  }

  /// Check if readiness cache is valid
  bool _isCacheValid() {
    if (_cachedReadinessScores == null || _cacheTimestamp == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Clear cache (e.g., after new workout completed)
  void clearCache() {
    _cachedReadinessScores = null;
    _cacheTimestamp = null;
  }

  /// Check if there's enough data for suggestions
  bool hasInsufficientData(List<Workout> workoutHistory) {
    return workoutHistory.length < minWorkoutsRequired;
  }

  /// Check if there's an antagonist conflict for a template
  AntagonistConflict? checkAntagonistConflict({
    required WorkoutTemplate template,
    required Map<MuscleGroup, double> readinessScores,
    Map<MuscleGroup, DateTime>? lastWorkoutDates,
  }) {
    final primaryMuscle = _getPrimaryMuscleGroup(template);
    if (primaryMuscle == null) return null;

    return AntagonistConflictDetector.detectConflict(
      primaryGroup: primaryMuscle,
      readinessScores: readinessScores,
      templateName: template.name,
      lastWorkoutDates: lastWorkoutDates,
    );
  }

  /// Apply rejection penalty and return updated state
  Future<SuggestionState> applyRejectionPenalty({
    required SuggestionState currentState,
    required SuggestionFeedback feedback,
    required List<Workout> workoutHistory,
    required List<WorkoutTemplate> availableTemplates,
    List<SuggestionFeedback>? feedbackHistory,
  }) async {
    // Clear cache to force recalculation
    clearCache();

    // Regenerate with updated feedback
    final updatedFeedback = [
      ...?feedbackHistory,
      feedback,
    ];

    return generateSuggestion(
      workoutHistory: workoutHistory,
      availableTemplates: availableTemplates,
      feedbackHistory: updatedFeedback,
    );
  }
}

/// Internal class for template scoring
class _ScoredTemplate {
  const _ScoredTemplate({
    required this.template,
    required this.score,
  });

  final WorkoutTemplate template;
  final double score;
}
