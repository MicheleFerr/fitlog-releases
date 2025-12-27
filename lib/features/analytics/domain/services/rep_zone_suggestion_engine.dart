/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Rep Zone Suggestion Engine v2 - Generates exercise suggestions with scoring
///
/// **Scientific Basis**:
/// - 80/20 rule: If >80% of training is in one zone, variety is low
/// - Schoenfeld et al. (2021): Variety in rep ranges optimizes adaptation
/// - Periodization research: 22% faster gains with varied training
///
/// **v2 Improvements**:
/// - Multi-criteria scoring system (0-100)
/// - Detailed motivations explaining why each exercise
/// - Alternative exercises for each suggestion
/// - More suggestions (10 instead of 5)
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart'
    show ExerciseCategory;
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Rep Zone Suggestion Engine v2
///
/// Analyzes training distribution and generates suggestions with scoring.
class RepZoneSuggestionEngine {
  /// Threshold for "dominant zone" - above this triggers suggestions
  static const double dominantThreshold = 80.0;

  /// Threshold for "very dominant" - critical imbalance
  static const double veryDominantThreshold = 90.0;

  /// Minimum sets needed for meaningful analysis
  static const int minimumSetsForAnalysis = 10;

  /// Maximum suggestions to generate (v2: increased from 5)
  static const int maxSuggestions = 10;

  /// Maximum alternatives per suggestion
  static const int maxAlternatives = 4;

  /// Analyze rep zone distribution from exercise histories
  RepZoneAnalysis analyzeDistribution(List<ExerciseHistory> histories) {
    int strengthSets = 0;
    int hypertrophySets = 0;
    int enduranceSets = 0;
    int totalSets = 0;

    for (final history in histories) {
      for (final session in history.sessions) {
        for (final set in session.sets) {
          totalSets++;
          if (set.reps <= 5) {
            strengthSets++;
          } else if (set.reps <= 15) {
            hypertrophySets++;
          } else {
            enduranceSets++;
          }
        }
      }
    }

    // Calculate percentages
    final strengthPct = totalSets > 0 ? (strengthSets / totalSets * 100) : 0.0;
    final hypertrophyPct =
        totalSets > 0 ? (hypertrophySets / totalSets * 100) : 0.0;
    final endurancePct =
        totalSets > 0 ? (enduranceSets / totalSets * 100) : 0.0;

    // Determine variety level and dominant zone
    final varietyLevel = _calculateVarietyLevel(
      strengthPct,
      hypertrophyPct,
      endurancePct,
    );

    final dominantZone = _findDominantZone(
      strengthPct,
      hypertrophyPct,
      endurancePct,
    );

    final neglectedZones = _findNeglectedZones(
      strengthPct,
      hypertrophyPct,
      endurancePct,
    );

    return RepZoneAnalysis(
      strengthPercentage: strengthPct,
      hypertrophyPercentage: hypertrophyPct,
      endurancePercentage: endurancePct,
      strengthSets: strengthSets,
      hypertrophySets: hypertrophySets,
      enduranceSets: enduranceSets,
      totalSets: totalSets,
      varietyLevel: varietyLevel,
      dominantZone: dominantZone,
      neglectedZones: neglectedZones,
    );
  }

  /// Calculate variety level based on distribution
  VarietyLevel _calculateVarietyLevel(
    double strength,
    double hypertrophy,
    double endurance,
  ) {
    final maxPercentage =
        [strength, hypertrophy, endurance].reduce((a, b) => a > b ? a : b);

    if (maxPercentage > veryDominantThreshold) {
      return VarietyLevel.veryLow;
    } else if (maxPercentage > dominantThreshold) {
      return VarietyLevel.low;
    } else if (maxPercentage > 70) {
      return VarietyLevel.good;
    } else {
      return VarietyLevel.excellent;
    }
  }

  /// Find the dominant zone (if any)
  RepZone? _findDominantZone(
    double strength,
    double hypertrophy,
    double endurance,
  ) {
    if (strength > dominantThreshold) return RepZone.strength;
    if (hypertrophy > dominantThreshold) return RepZone.hypertrophy;
    if (endurance > dominantThreshold) return RepZone.endurance;
    return null;
  }

  /// Find neglected zones (< 10% or 0 sets)
  List<RepZone> _findNeglectedZones(
    double strength,
    double hypertrophy,
    double endurance,
  ) {
    final neglected = <RepZone>[];

    if (strength < 10) neglected.add(RepZone.strength);
    if (hypertrophy < 10) neglected.add(RepZone.hypertrophy);
    if (endurance < 10) neglected.add(RepZone.endurance);

    return neglected;
  }

  /// Generate suggestions to balance rep zones (v2 with scoring)
  ///
  /// [analysis] - The current rep zone analysis
  /// [templates] - User's workout templates (for auto-detect)
  /// [allExercises] - Exercise database
  /// [existingExerciseIds] - Exercises already in templates (to avoid duplicates)
  /// [exerciseHistories] - User's exercise history (for variety scoring)
  /// [userExperienceLevel] - User's experience level (for difficulty matching)
  List<RepZoneSuggestion> generateSuggestions({
    required RepZoneAnalysis analysis,
    required List<WorkoutTemplate> templates,
    required List<ExerciseDefinition> allExercises,
    Set<String>? existingExerciseIds,
    List<ExerciseHistory>? exerciseHistories,
    ExperienceLevel? userExperienceLevel,
  }) {
    if (!analysis.needsSuggestions || templates.isEmpty) {
      return [];
    }

    final excludeIds = existingExerciseIds ?? <String>{};
    final histories = exerciseHistories ?? [];
    final userLevel = userExperienceLevel ?? ExperienceLevel.intermediate;

    // Build equipment set from templates
    final templateEquipment = _extractEquipmentFromTemplates(templates);

    // Build muscle coverage map from templates
    final templateMuscles = _extractMusclesFromTemplates(templates);

    // Score all exercises for each neglected zone
    final allScoredExercises = <_ScoredExercise>[];

    for (final zone in analysis.neglectedZones) {
      final scored = _scoreExercisesForZone(
        zone: zone,
        allExercises: allExercises,
        excludeIds: excludeIds,
        histories: histories,
        userLevel: userLevel,
        templateEquipment: templateEquipment,
        templateMuscles: templateMuscles,
        analysis: analysis,
      );
      allScoredExercises.addAll(scored);
    }

    // Sort by score descending
    allScoredExercises.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // Take top exercises, ensuring variety across zones
    final selectedExercises = _selectDiverseExercises(
      allScoredExercises,
      maxSuggestions,
    );

    // Convert to suggestions with alternatives
    final suggestions = <RepZoneSuggestion>[];

    for (final scored in selectedExercises) {
      final targetTemplate = _findBestTemplate(
        exercise: scored.exercise,
        templates: templates,
        targetZone: scored.zone,
      );

      if (targetTemplate != null) {
        // Find alternatives (same zone, similar score, different exercise)
        final alternatives = _findAlternatives(
          mainExercise: scored,
          allScored: allScoredExercises,
          excludeIds: {...excludeIds, scored.exercise.id},
        );

        // Build motivations
        final motivations = _buildMotivations(
          scored: scored,
          analysis: analysis,
        );

        suggestions.add(
          RepZoneSuggestion(
            exerciseId: scored.exercise.id,
            exerciseName: scored.exercise.nome,
            targetZone: scored.zone,
            targetTemplate: targetTemplate.name,
            targetTemplateId: targetTemplate.id,
            recommendedSets: scored.zone.recommendedSets,
            recommendedReps: scored.zone.recommendedReps,
            recommendedRestSeconds: scored.zone.recommendedRestSeconds,
            difficulty:
                ExerciseDifficulty.fromItalianString(scored.exercise.difficolta),
            equipment: scored.exercise.attrezzatura,
            reasonKey: _getReasonKey(scored.zone, analysis),
            countingMode: scored.exercise.countingMode,
            // v2 fields
            score: scored.breakdown.normalizedScore,
            scoreBreakdown: scored.breakdown,
            motivations: motivations,
            alternatives: alternatives,
            exerciseType: scored.exercise.tipoEsercizio,
            musclesFocus: scored.exercise.focus,
            patternMovimento: scored.exercise.patternMovimento,
            rangeRipetizioni: scored.exercise.rangeRipetizioni,
            daysSinceLastDone: scored.daysSinceLastDone,
          ),
        );
      }
    }

    debugPrint(
        '🎯 [SUGGESTION ENGINE v2] Generated ${suggestions.length} suggestions');
    return suggestions;
  }

  /// Score all exercises for a specific zone
  List<_ScoredExercise> _scoreExercisesForZone({
    required RepZone zone,
    required List<ExerciseDefinition> allExercises,
    required Set<String> excludeIds,
    required List<ExerciseHistory> histories,
    required ExperienceLevel userLevel,
    required Set<String> templateEquipment,
    required Set<String> templateMuscles,
    required RepZoneAnalysis analysis,
  }) {
    final scored = <_ScoredExercise>[];

    for (final exercise in allExercises) {
      // Skip excluded
      if (excludeIds.contains(exercise.id)) continue;

      // Calculate score breakdown
      final breakdown = _calculateScore(
        exercise: exercise,
        zone: zone,
        userLevel: userLevel,
        templateEquipment: templateEquipment,
        templateMuscles: templateMuscles,
        histories: histories,
      );

      // Skip very low scores
      if (breakdown.total < 20) continue;

      // Find days since last done
      final daysSince = _daysSinceLastDone(exercise.id, histories);

      scored.add(_ScoredExercise(
        exercise: exercise,
        zone: zone,
        breakdown: breakdown,
        daysSinceLastDone: daysSince,
      ));
    }

    return scored;
  }

  /// Calculate score breakdown for an exercise
  ScoreBreakdown _calculateScore({
    required ExerciseDefinition exercise,
    required RepZone zone,
    required ExperienceLevel userLevel,
    required Set<String> templateEquipment,
    required Set<String> templateMuscles,
    required List<ExerciseHistory> histories,
  }) {
    // 1. MUSCLE RELEVANCE (0-30)
    int muscleRelevance = 0;
    final exerciseMuscles = {...exercise.focus, ...exercise.muscoliSecondari};

    // Check if targets muscles NOT in templates (filling gaps)
    final missingMuscles =
        exerciseMuscles.where((m) => !templateMuscles.contains(m));
    if (missingMuscles.isNotEmpty) {
      muscleRelevance = 30; // High relevance - fills gap
    } else if (exerciseMuscles.any((m) => templateMuscles.contains(m))) {
      muscleRelevance = 15; // Medium - complements existing
    }

    // 2. EXERCISE TYPE (0-20)
    int exerciseType = 0;
    final isCompound = exercise.tipoEsercizio.toLowerCase() == 'compound';

    switch (zone) {
      case RepZone.strength:
        exerciseType = isCompound ? 20 : 5; // Compound is best for strength
      case RepZone.hypertrophy:
        exerciseType = 15; // Both work for hypertrophy
      case RepZone.endurance:
        exerciseType = isCompound ? 10 : 15; // Isolation slightly better
    }

    // Bonus: check if exercise natural rep range matches zone
    if (_repRangeMatchesZone(exercise.rangeRipetizioni, zone)) {
      exerciseType += 5;
    }

    // 3. EQUIPMENT (0-15)
    int equipment = 0;
    final exerciseEquip = exercise.attrezzatura.toLowerCase();

    if (templateEquipment.any((e) => exerciseEquip.contains(e.toLowerCase()))) {
      equipment = 15; // Already have this equipment
    } else if (_isBasicEquipment(exerciseEquip)) {
      equipment = 10; // Basic equipment most people have
    }

    // 4. DIFFICULTY MATCH (0-10)
    int difficultyMatch = 0;
    final exerciseDiff = _difficultyToLevel(exercise.difficolta);

    if (exerciseDiff == userLevel) {
      difficultyMatch = 10;
    } else if ((exerciseDiff.index - userLevel.index).abs() == 1) {
      difficultyMatch = 5;
    }

    // 5. VARIETY (0-10)
    int variety = 0;
    final daysSince = _daysSinceLastDone(exercise.id, histories);

    if (daysSince == null) {
      variety = 10; // Never done - max variety
    } else if (daysSince > 30) {
      variety = 8;
    } else if (daysSince > 14) {
      variety = 5;
    } else {
      variety = 2;
    }

    return ScoreBreakdown(
      muscleRelevance: muscleRelevance,
      exerciseType: exerciseType.clamp(0, 20),
      equipment: equipment,
      difficultyMatch: difficultyMatch,
      variety: variety,
    );
  }

  /// Build motivation strings from score breakdown
  List<String> _buildMotivations({
    required _ScoredExercise scored,
    required RepZoneAnalysis analysis,
  }) {
    final motivations = <String>[];
    final exercise = scored.exercise;
    final breakdown = scored.breakdown;

    // Technical motivations
    if (exercise.tipoEsercizio.toLowerCase() == 'compound') {
      motivations.add('compoundActivates:${exercise.focus.join(", ")}');
    } else {
      motivations.add('isolationTargets:${exercise.focus.join(", ")}');
    }

    if (exercise.patternMovimento.isNotEmpty) {
      motivations.add('movementPattern:${exercise.patternMovimento}');
    }

    if (_repRangeMatchesZone(exercise.rangeRipetizioni, scored.zone)) {
      motivations.add('naturalRepRange:${exercise.rangeRipetizioni}');
    }

    // User data motivations
    final zonePercent = analysis.getPercentage(scored.zone);
    motivations.add('zonePercentLast30Days:${zonePercent.toStringAsFixed(0)}:${scored.zone.label}');

    if (scored.daysSinceLastDone != null) {
      motivations.add('notDoneSinceDays:${scored.daysSinceLastDone}');
    } else {
      motivations.add('neverDone');
    }

    if (breakdown.equipment >= 15) {
      motivations.add('equipmentAlreadyOwned:${exercise.attrezzatura}');
    }

    return motivations;
  }

  /// Find alternative exercises for a main suggestion
  List<AlternativeExercise> _findAlternatives({
    required _ScoredExercise mainExercise,
    required List<_ScoredExercise> allScored,
    required Set<String> excludeIds,
  }) {
    final alternatives = <AlternativeExercise>[];

    // Find same-zone exercises with decent scores
    final candidates = allScored
        .where((s) =>
            s.zone == mainExercise.zone &&
            !excludeIds.contains(s.exercise.id) &&
            s.exercise.id != mainExercise.exercise.id &&
            s.breakdown.normalizedScore >= 40)
        .toList();

    // Sort by score
    candidates.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    for (final candidate in candidates.take(maxAlternatives)) {
      final shortReason = _buildShortReason(candidate, mainExercise);
      alternatives.add(AlternativeExercise(
        exerciseId: candidate.exercise.id,
        exerciseName: candidate.exercise.nome,
        score: candidate.breakdown.normalizedScore,
        shortReason: shortReason,
        equipment: candidate.exercise.attrezzatura,
        countingMode: candidate.exercise.countingMode,
      ));
    }

    return alternatives;
  }

  /// Build short reason for alternative
  String _buildShortReason(
      _ScoredExercise alternative, _ScoredExercise main) {
    final parts = <String>[];

    // Same/different pattern
    if (alternative.exercise.patternMovimento == main.exercise.patternMovimento) {
      parts.add('Stesso pattern');
    }

    // Equipment
    if (alternative.exercise.attrezzatura != main.exercise.attrezzatura) {
      parts.add(alternative.exercise.attrezzatura);
    }

    // Type
    if (alternative.exercise.tipoEsercizio != main.exercise.tipoEsercizio) {
      parts.add(alternative.exercise.tipoEsercizio);
    }

    return parts.isEmpty ? 'Alternativa valida' : parts.join(', ');
  }

  /// Select diverse exercises across zones
  List<_ScoredExercise> _selectDiverseExercises(
    List<_ScoredExercise> all,
    int max,
  ) {
    final selected = <_ScoredExercise>[];
    final zoneCount = <RepZone, int>{};

    for (final exercise in all) {
      // Ensure diversity: max 4 per zone
      final currentCount = zoneCount[exercise.zone] ?? 0;
      if (currentCount >= 4) continue;

      selected.add(exercise);
      zoneCount[exercise.zone] = currentCount + 1;

      if (selected.length >= max) break;
    }

    return selected;
  }

  /// Extract equipment used in templates
  Set<String> _extractEquipmentFromTemplates(List<WorkoutTemplate> templates) {
    final equipment = <String>{};
    // Note: templates don't store equipment directly, but we can infer common ones
    // For now, assume basic equipment is available
    equipment.addAll(['bilanciere', 'manubri', 'corpo libero']);
    return equipment;
  }

  /// Extract muscles covered by templates
  Set<String> _extractMusclesFromTemplates(List<WorkoutTemplate> templates) {
    final muscles = <String>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        // Map category to muscle codes
        final categoryMuscles = _categoryToMuscles(exercise.category);
        muscles.addAll(categoryMuscles);
      }
    }
    return muscles;
  }

  /// Maps category to muscle abbreviation codes
  ///
  /// **SINGLE SOURCE OF TRUTH**: Delegates to MuscleAbbreviationMapper.
  List<String> _categoryToMuscles(ExerciseCategory category) {
    return MuscleAbbreviationMapper.categoryToAbbreviations(category);
  }

  /// Check if rep range matches zone
  bool _repRangeMatchesZone(String rangeRipetizioni, RepZone zone) {
    final lower = rangeRipetizioni.toLowerCase();

    switch (zone) {
      case RepZone.strength:
        return lower.contains('1-5') ||
            lower.contains('3-5') ||
            lower.contains('1-6');
      case RepZone.hypertrophy:
        return lower.contains('8-12') ||
            lower.contains('6-12') ||
            lower.contains('8-15');
      case RepZone.endurance:
        return lower.contains('15+') ||
            lower.contains('15-20') ||
            lower.contains('12-20');
    }
  }

  /// Check if equipment is basic
  bool _isBasicEquipment(String equipment) {
    final basic = ['bilanciere', 'manubri', 'corpo libero', 'sbarra', 'panca'];
    return basic.any((b) => equipment.toLowerCase().contains(b));
  }

  /// Convert difficulty string to ExperienceLevel
  ExperienceLevel _difficultyToLevel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return ExperienceLevel.novice;
      case 'intermedio':
        return ExperienceLevel.intermediate;
      case 'avanzato':
        return ExperienceLevel.advanced;
      default:
        return ExperienceLevel.intermediate;
    }
  }

  /// Calculate days since exercise was last performed
  int? _daysSinceLastDone(String exerciseId, List<ExerciseHistory> histories) {
    // Find history for this exercise
    final history = histories.where((h) {
      // Match by name (history uses exerciseName, not ID)
      return h.exerciseName.toLowerCase().contains(exerciseId.toLowerCase()) ||
          exerciseId.toLowerCase().contains(h.exerciseName.toLowerCase());
    }).firstOrNull;

    if (history == null || history.sessions.isEmpty) return null;

    // Find most recent session
    final sortedSessions = history.sessionsSortedByDate;
    if (sortedSessions.isEmpty) return null;

    final lastSession = sortedSessions.first;
    return DateTime.now().difference(lastSession.date).inDays;
  }

  /// Find the best template to add an exercise to
  WorkoutTemplate? _findBestTemplate({
    required ExerciseDefinition exercise,
    required List<WorkoutTemplate> templates,
    required RepZone targetZone,
  }) {
    if (templates.isEmpty) return null;

    WorkoutTemplate? bestTemplate;
    int bestScore = -1;

    for (final template in templates) {
      int score = 0;

      // Check if template has exercises targeting similar muscles
      final exerciseFocus = exercise.focus;
      for (final templateExercise in template.exercises) {
        if (_categoriesMatch(templateExercise.category, exerciseFocus)) {
          score += 10;
        }
      }

      // Prefer templates with fewer exercises (not overloaded)
      if (template.exercises.length < 6) {
        score += 5;
      }

      // Prefer templates with matching zone potential
      if (_templateMatchesZone(template, targetZone)) {
        score += 3;
      }

      if (score > bestScore) {
        bestScore = score;
        bestTemplate = template;
      }
    }

    return bestTemplate ?? templates.first;
  }

  /// Checks if exercise focus matches category
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper for category → abbreviations.
  bool _categoriesMatch(ExerciseCategory category, List<String> focus) {
    final expectedFocus = MuscleAbbreviationMapper.categoryToAbbreviations(category);
    return focus.any((f) => expectedFocus.contains(f));
  }

  bool _templateMatchesZone(WorkoutTemplate template, RepZone zone) {
    final nameLower = template.name.toLowerCase();

    switch (zone) {
      case RepZone.strength:
        return nameLower.contains('forza') ||
            nameLower.contains('strength') ||
            nameLower.contains('power');
      case RepZone.hypertrophy:
        return nameLower.contains('massa') ||
            nameLower.contains('hypertrophy') ||
            nameLower.contains('volume');
      case RepZone.endurance:
        return nameLower.contains('endurance') ||
            nameLower.contains('conditioning') ||
            nameLower.contains('circuit');
    }
  }

  String _getReasonKey(RepZone zone, RepZoneAnalysis analysis) {
    final percentage = analysis.getPercentage(zone);

    if (percentage == 0) {
      return 'zoneEmpty';
    } else if (percentage < 5) {
      return 'zoneNeglected';
    } else {
      return 'balanceZone';
    }
  }
}

/// Internal class for scored exercise during selection
class _ScoredExercise {
  const _ScoredExercise({
    required this.exercise,
    required this.zone,
    required this.breakdown,
    this.daysSinceLastDone,
  });

  final ExerciseDefinition exercise;
  final RepZone zone;
  final ScoreBreakdown breakdown;
  final int? daysSinceLastDone;

  int get totalScore => breakdown.total;
}
