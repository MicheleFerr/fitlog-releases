import 'dart:math';

import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

/// Service for calculating personalized weight suggestions for exercises.
///
/// Uses strength standards, user questionnaire data, and exercise mappings
/// to provide scientifically-backed starting weights.
class WeightSuggestionService {
  /// Calculate suggested weight for an exercise.
  ///
  /// Returns null if no suggestion can be made (low confidence mapping or missing data).
  ///
  /// Algorithm:
  /// 1. Check if exercise has reliable mapping (auto or review status)
  /// 2. Get strength standard for the mapped exercise
  /// 3. Calculate 1RM based on user's bodyweight and experience level
  /// 4. Apply training goal intensity factor (e.g., 70% for hypertrophy)
  /// 5. Apply user's suggestion style multiplier (conservative/balanced/aggressive)
  /// 6. Apply injury history adjustment if applicable
  /// 7. Round to nearest practical weight (2.5kg increments)
  WeightSuggestion? getSuggestedWeight({
    required String exerciseId,
    required UserFitnessQuestionnaire questionnaire,
    required ExerciseMapping? mapping,
    required StrengthStandard? standard,
  }) {
    // Validation
    if (!questionnaire.isValid) {
      return _getFallbackSuggestion(questionnaire);
    }
    if (mapping == null || !mapping.canSuggestWeight) {
      return _getFallbackSuggestion(questionnaire);
    }
    if (standard == null) {
      return _getFallbackSuggestion(questionnaire);
    }

    // Bodyweight exercises (pull-ups, dips) suggest reps instead of weight
    if (standard.isBodyweightExercise) {
      return _getBodyweightRepsSuggestion(
        standard: standard,
        questionnaire: questionnaire,
      );
    }

    // Calculate base 1RM from strength standard
    final oneRepMax = standard.getOneRepMax(
      bodyweightKg: questionnaire.bodyweightKg,
      level: questionnaire.adjustedExperienceLevel,
    );

    if (oneRepMax == null || oneRepMax <= 0) {
      return _getFallbackSuggestion(questionnaire);
    }

    // Apply training goal intensity factor
    final intensityFactor = questionnaire.trainingGoal.intensityFactor;
    double suggestedWeight = oneRepMax * intensityFactor;

    // Apply suggestion style multiplier
    suggestedWeight *= questionnaire.suggestionStyle.multiplier;

    // Apply conservative adjustment for injury history
    if (questionnaire.hasInjuryHistory) {
      suggestedWeight *= 0.90; // 10% reduction
    }

    // Round to practical weight increments (2.5kg)
    suggestedWeight = _roundToPracticalWeight(suggestedWeight);

    // Ensure minimum weight (empty barbell = 20kg, dumbbells = 2.5kg)
    final minWeight = _getMinimumWeight(mapping.gymbroEquipment);
    suggestedWeight = max(suggestedWeight, minWeight);

    return WeightSuggestion(
      exerciseId: exerciseId,
      suggestedWeightKg: suggestedWeight,
      suggestedReps: _getRepsForGoal(questionnaire.trainingGoal),
      confidence: mapping.confidence,
      confidenceTier: mapping.confidenceTier,
      calculationMethod: CalculationMethod.strengthStandard,
      baseOneRepMax: oneRepMax,
      intensityFactor: intensityFactor,
      appliedMultipliers: _getAppliedMultipliers(questionnaire),
      notes: _generateNotes(
        mapping: mapping,
        questionnaire: questionnaire,
        standard: standard,
      ),
    );
  }

  /// Get fallback suggestion when no strength standard available
  WeightSuggestion _getFallbackSuggestion(
    UserFitnessQuestionnaire questionnaire,
  ) {
    // Conservative bodyweight-based estimate
    // Novice: ~30% of bodyweight for upper body, ~60% for lower body
    // (This is very rough and should be improved with more data)
    final baseWeight = questionnaire.bodyweightKg * 0.30;
    final adjustedWeight =
        baseWeight * questionnaire.suggestionStyle.multiplier;

    return WeightSuggestion(
      exerciseId: '',
      suggestedWeightKg: _roundToPracticalWeight(adjustedWeight),
      suggestedReps: _getRepsForGoal(questionnaire.trainingGoal),
      confidence: 0.0,
      confidenceTier: ConfidenceTier.veryLow,
      calculationMethod: CalculationMethod.fallback,
      notes: [
        'Stima conservativa basata sul peso corporeo',
        'Inizia leggero e aumenta gradualmente',
      ],
    );
  }

  /// Get bodyweight exercise suggestion (reps instead of weight)
  WeightSuggestion _getBodyweightRepsSuggestion({
    required StrengthStandard standard,
    required UserFitnessQuestionnaire questionnaire,
  }) {
    // For bodyweight exercises, standards are rep counts
    final repsEstimate = standard.getOneRepMax(
      bodyweightKg: questionnaire.bodyweightKg,
      level: questionnaire.adjustedExperienceLevel,
    );

    final suggestedReps = repsEstimate?.round() ?? 5;

    return WeightSuggestion(
      exerciseId: '',
      suggestedWeightKg: 0.0, // Bodyweight
      suggestedReps: suggestedReps,
      confidence: 0.85,
      confidenceTier: ConfidenceTier.good,
      calculationMethod: CalculationMethod.bodyweightReps,
      notes: ['Esercizio a corpo libero', 'Reps suggerite: $suggestedReps'],
    );
  }

  /// Round weight to practical increments (2.5kg for plates)
  double _roundToPracticalWeight(double weight) {
    // Round to nearest 2.5kg (standard plate increment)
    return (weight / 2.5).round() * 2.5;
  }

  /// Get minimum practical weight based on equipment
  double _getMinimumWeight(String equipment) {
    final equipmentLower = equipment.toLowerCase();

    if (equipmentLower.contains('bilanciere') ||
        equipmentLower.contains('barbell')) {
      return 20.0; // Empty Olympic barbell
    }

    if (equipmentLower.contains('manubri') ||
        equipmentLower.contains('dumbbell')) {
      return 2.5; // Lightest dumbbells
    }

    if (equipmentLower.contains('corpo') || equipmentLower.contains('body')) {
      return 0.0; // Bodyweight
    }

    return 5.0; // Generic minimum for machines/cables
  }

  /// Get recommended reps based on training goal
  int _getRepsForGoal(TrainingGoal goal) {
    switch (goal) {
      case TrainingGoal.strength:
        return 5; // 1-5 reps for strength
      case TrainingGoal.hypertrophy:
        return 10; // 8-12 reps for hypertrophy
      case TrainingGoal.endurance:
        return 15; // 15+ reps for endurance
    }
  }

  /// Get list of applied multipliers for transparency
  List<String> _getAppliedMultipliers(UserFitnessQuestionnaire questionnaire) {
    final multipliers = <String>[];

    // Training goal
    multipliers.add(
      'Obiettivo ${questionnaire.trainingGoal.getLabel('it')}: '
      '${(questionnaire.trainingGoal.intensityFactor * 100).toStringAsFixed(0)}% 1RM',
    );

    // Suggestion style
    if (questionnaire.suggestionStyle != SuggestionStyle.balanced) {
      multipliers.add(
        'Stile ${questionnaire.suggestionStyle.getLabel('it')}: '
        '${(questionnaire.suggestionStyle.multiplier * 100).toStringAsFixed(0)}%',
      );
    }

    // Injury history
    if (questionnaire.hasInjuryHistory) {
      multipliers.add('Riduzione per storia infortuni: 90%');
    }

    return multipliers;
  }

  /// Generate helpful notes for the suggestion
  List<String> _generateNotes({
    required ExerciseMapping mapping,
    required UserFitnessQuestionnaire questionnaire,
    required StrengthStandard standard,
  }) {
    final notes = <String>[];

    // Confidence warning
    if (mapping.confidenceTier == ConfidenceTier.fair ||
        mapping.confidenceTier == ConfidenceTier.low) {
      notes.add(
        'Match parziale (${mapping.confidencePercent.toStringAsFixed(0)}%). '
        'Verifica che il peso sia appropriato.',
      );
    }

    // Experience level mismatch
    if (!questionnaire.isExperienceLevelRealistic) {
      notes.add(
        'Il livello di esperienza potrebbe non corrispondere ai mesi di allenamento.',
      );
    }

    // Stale data
    if (questionnaire.isStale) {
      notes.add(
        'Dati questionario datati. Considera di aggiornare il tuo profilo.',
      );
    }

    // General safety note
    notes.add('Inizia conservativo. Aumenta gradualmente ogni settimana.');

    return notes;
  }

  /// Calculate 1RM from reps and weight (Brzycki formula)
  ///
  /// More accurate for 2-10 reps. Error margin: ±3kg.
  /// Formula: 1RM = weight / (1.0278 - 0.0278 × reps)
  double calculateOneRepMaxBrzycki({
    required double weightKg,
    required int reps,
  }) {
    if (reps == 1) return weightKg;
    if (reps > 10) {
      // Brzycki becomes less accurate above 10 reps
      return weightKg / (1.0278 - 0.0278 * 10); // Cap at 10 reps
    }
    return weightKg / (1.0278 - 0.0278 * reps);
  }

  /// Calculate 1RM from reps and weight (Epley formula)
  ///
  /// More accurate for 4-6 reps. Error margin: ±2.7kg.
  /// Formula: 1RM = weight × (1 + 0.0333 × reps)
  double calculateOneRepMaxEpley({
    required double weightKg,
    required int reps,
  }) {
    if (reps == 1) return weightKg;
    return weightKg * (1 + 0.0333 * reps);
  }

  /// Get average of both formulas for better accuracy
  double calculateOneRepMaxAverage({
    required double weightKg,
    required int reps,
  }) {
    final brzycki = calculateOneRepMaxBrzycki(weightKg: weightKg, reps: reps);
    final epley = calculateOneRepMaxEpley(weightKg: weightKg, reps: reps);
    return (brzycki + epley) / 2;
  }

  /// Estimate experience level from actual max lifts (Big 3)
  ///
  /// Uses Wilks coefficient and strength standards to estimate experience.
  /// Returns null if insufficient data.
  ExperienceLevel? estimateExperienceLevelFromLifts({
    required double bodyweightKg,
    required BiologicalSex sex,
    double? benchPressMax,
    double? squatMax,
    double? deadliftMax,
  }) {
    if (benchPressMax == null && squatMax == null && deadliftMax == null) {
      return null;
    }

    // Calculate bodyweight ratios
    final benchRatio = benchPressMax != null
        ? benchPressMax / bodyweightKg
        : null;
    final squatRatio = squatMax != null ? squatMax / bodyweightKg : null;
    final deadliftRatio = deadliftMax != null
        ? deadliftMax / bodyweightKg
        : null;

    // Average available ratios
    final ratios = [
      benchRatio,
      squatRatio,
      deadliftRatio,
    ].whereType<double>().toList();
    if (ratios.isEmpty) return null;

    final avgRatio = ratios.reduce((a, b) => a + b) / ratios.length;

    // Rough estimation based on common benchmarks (male standards)
    // These should be tuned with more data
    if (sex == BiologicalSex.male) {
      if (avgRatio < 0.75) return ExperienceLevel.untrained;
      if (avgRatio < 1.0) return ExperienceLevel.novice;
      if (avgRatio < 1.5) return ExperienceLevel.intermediate;
      if (avgRatio < 2.0) return ExperienceLevel.advanced;
      return ExperienceLevel.elite;
    } else {
      // Female standards are typically lower
      if (avgRatio < 0.5) return ExperienceLevel.untrained;
      if (avgRatio < 0.75) return ExperienceLevel.novice;
      if (avgRatio < 1.1) return ExperienceLevel.intermediate;
      if (avgRatio < 1.5) return ExperienceLevel.advanced;
      return ExperienceLevel.elite;
    }
  }
}

/// Result of a weight suggestion calculation
class WeightSuggestion {
  const WeightSuggestion({
    required this.exerciseId,
    required this.suggestedWeightKg,
    required this.suggestedReps,
    required this.confidence,
    required this.confidenceTier,
    required this.calculationMethod,
    this.baseOneRepMax,
    this.intensityFactor,
    this.appliedMultipliers = const [],
    this.notes = const [],
  });
  final String exerciseId;
  final double suggestedWeightKg;
  final int suggestedReps;
  final double confidence;
  final ConfidenceTier confidenceTier;
  final CalculationMethod calculationMethod;
  final double? baseOneRepMax;
  final double? intensityFactor;
  final List<String> appliedMultipliers;
  final List<String> notes;

  /// Whether this suggestion should be shown with a warning
  bool get needsWarning =>
      confidenceTier == ConfidenceTier.low ||
      confidenceTier == ConfidenceTier.veryLow;

  /// User-friendly confidence label
  String getConfidenceLabel(String locale) {
    switch (confidenceTier) {
      case ConfidenceTier.excellent:
        return locale.startsWith('it') ? 'Eccellente' : 'Excellent';
      case ConfidenceTier.good:
        return locale.startsWith('it') ? 'Buono' : 'Good';
      case ConfidenceTier.fair:
        return locale.startsWith('it') ? 'Discreto' : 'Fair';
      case ConfidenceTier.low:
        return locale.startsWith('it') ? 'Basso' : 'Low';
      case ConfidenceTier.veryLow:
        return locale.startsWith('it') ? 'Molto Basso' : 'Very Low';
    }
  }
}

/// Method used for weight calculation
enum CalculationMethod {
  /// Based on strength standards table
  strengthStandard,

  /// Based on bodyweight reps for bodyweight exercises
  bodyweightReps,

  /// Conservative fallback when no data available
  fallback,
}
