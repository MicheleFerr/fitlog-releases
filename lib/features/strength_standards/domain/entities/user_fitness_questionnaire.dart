import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

part 'user_fitness_questionnaire.freezed.dart';
part 'user_fitness_questionnaire.g.dart';

/// User fitness questionnaire data for personalized weight suggestions.
///
/// Evidence-based design incorporating:
/// - McKay AKA et al. (2022) "Defining Training and Performance Caliber" (6-level system)
/// - Aandstad A et al. (2023) "Self-reported vs objective fitness" (bias awareness)
/// - Sciascia A et al. (2015) "Injury history screening" (detailed injury assessment)
///
/// Collected through a 6-step onboarding flow to determine appropriate
/// starting weights based on experience, bodyweight, and optional max lifts.
@freezed
abstract class UserFitnessQuestionnaire with _$UserFitnessQuestionnaire {
  const factory UserFitnessQuestionnaire({
    // Step 1: Demographics
    /// User's bodyweight in kg
    required double bodyweightKg,

    /// User's age
    required int age,

    /// User's height in cm
    required double heightCm,

    /// User's biological sex (affects strength standards)
    required BiologicalSex sex,

    // Step 2: Experience Level
    /// Self-reported experience level
    required ExperienceLevel experienceLevel,

    /// Months of consistent training (optional, helps validate experience level)
    int? monthsOfTraining,

    // Step 3: Max Lifts (Optional - improves accuracy)
    /// Bench press 1RM or estimated from reps (kg)
    double? benchPressMax,

    /// Squat 1RM or estimated from reps (kg)
    double? squatMax,

    /// Deadlift 1RM or estimated from reps (kg)
    double? deadliftMax,

    /// Overhead press 1RM or estimated from reps (kg)
    double? overheadPressMax,

    // Step 4: Lifestyle Factors
    /// Training goal affects weight suggestion (hypertrophy, strength, endurance)
    @Default(TrainingGoal.hypertrophy) TrainingGoal trainingGoal,

    /// Injury history or limitations (affects conservative suggestions)
    @Default(false) bool hasInjuryHistory,

    /// Specific injury details (Sciascia 2015: detailed screening recommended)
    InjuryDetails? injuryDetails,

    /// Current pain or discomfort during training (0-10 scale)
    @Default(0) int currentPainLevel,

    // Step 5: Preferences
    /// Prefer conservative or aggressive weight suggestions
    @Default(SuggestionStyle.balanced) SuggestionStyle suggestionStyle,

    /// Timestamp when questionnaire was completed
    DateTime? completedAt,

    /// Whether user wants to update suggestions periodically
    @Default(true) bool allowPeriodicUpdates,

    /// Self-reported accuracy calibration (Aandstad 2023: over-reporting bias)
    /// User's honesty about their actual performance vs perceived
    @Default(SelfReportCalibration.realistic)
    SelfReportCalibration selfReportCalibration,
  }) = _UserFitnessQuestionnaire;

  factory UserFitnessQuestionnaire.fromJson(Map<String, dynamic> json) =>
      _$UserFitnessQuestionnaireFromJson(json);
}

/// Biological sex (affects strength standards significantly)
enum BiologicalSex {
  @JsonValue('male')
  male('Uomo', 'Male'),

  @JsonValue('female')
  female('Donna', 'Female');

  const BiologicalSex(this.labelIT, this.labelEN);

  final String labelIT;
  final String labelEN;

  String getLabel(String locale) => locale.startsWith('it') ? labelIT : labelEN;
}

/// Training goal affects intensity factor for weight suggestions
enum TrainingGoal {
  /// Strength: 85-95% of 1RM, 1-5 reps
  @JsonValue('strength')
  strength('Forza', 'Strength', 0.85),

  /// Hypertrophy: 65-75% of 1RM, 8-12 reps
  @JsonValue('hypertrophy')
  hypertrophy('Ipertrofia', 'Hypertrophy', 0.70),

  /// Endurance: 50-60% of 1RM, 15+ reps
  @JsonValue('endurance')
  endurance('Resistenza', 'Endurance', 0.55);

  const TrainingGoal(this.labelIT, this.labelEN, this.intensityFactor);

  final String labelIT;
  final String labelEN;

  /// Percentage of 1RM to use for working sets
  final double intensityFactor;

  String getLabel(String locale) => locale.startsWith('it') ? labelIT : labelEN;
}

/// Suggestion style affects how conservative weight recommendations are
enum SuggestionStyle {
  /// 85% of calculated value (safest)
  @JsonValue('conservative')
  conservative('Conservativo', 'Conservative', 0.85),

  /// 100% of calculated value (recommended)
  @JsonValue('balanced')
  balanced('Bilanciato', 'Balanced', 1.00),

  /// 115% of calculated value (for experienced users)
  @JsonValue('aggressive')
  aggressive('Aggressivo', 'Aggressive', 1.15);

  const SuggestionStyle(this.labelIT, this.labelEN, this.multiplier);

  final String labelIT;
  final String labelEN;

  /// Multiplier applied to calculated weight
  final double multiplier;

  String getLabel(String locale) => locale.startsWith('it') ? labelIT : labelEN;
}

/// Extension for questionnaire validation and calculations
extension UserFitnessQuestionnaireExtension on UserFitnessQuestionnaire {
  /// Whether questionnaire is complete and valid
  bool get isValid {
    if (bodyweightKg < 40 || bodyweightKg > 200) return false;
    if (age < 13 || age > 100) return false;
    if (heightCm < 100 || heightCm > 250) return false;
    return true;
  }

  /// Whether user provided any max lift data
  bool get hasMaxLiftData =>
      benchPressMax != null ||
      squatMax != null ||
      deadliftMax != null ||
      overheadPressMax != null;

  /// Calculate conservative multiplier based on injury history and style
  double get conservativeMultiplier {
    double multiplier = suggestionStyle.multiplier;

    // Reduce by 10% if injury history
    if (hasInjuryHistory) {
      multiplier *= 0.90;
    }

    return multiplier;
  }

  /// Get experience level adjusted for injury history
  ExperienceLevel get adjustedExperienceLevel {
    if (hasInjuryHistory && experienceLevel != ExperienceLevel.untrained) {
      // Drop one level if injury history (conservative approach)
      final index = ExperienceLevel.values.indexOf(experienceLevel);
      return ExperienceLevel.values[index - 1];
    }
    return experienceLevel;
  }

  /// Validate experience level against months of training
  bool get isExperienceLevelRealistic {
    if (monthsOfTraining == null) return true;

    switch (experienceLevel) {
      case ExperienceLevel.untrained:
        return monthsOfTraining! < 2;
      case ExperienceLevel.novice:
        return monthsOfTraining! >= 2 && monthsOfTraining! <= 6;
      case ExperienceLevel.intermediate:
        return monthsOfTraining! >= 6 && monthsOfTraining! <= 24;
      case ExperienceLevel.advanced:
        return monthsOfTraining! >= 24 && monthsOfTraining! <= 60;
      case ExperienceLevel.elite:
        return monthsOfTraining! >= 60;
    }
  }

  /// Whether questionnaire data is stale (>6 months old)
  bool get isStale {
    if (completedAt == null) return true;
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return completedAt!.isBefore(sixMonthsAgo);
  }

  /// Cross-validate experience level with max lifts (Aandstad 2023: detect over-reporting)
  /// Returns true if max lifts are realistic for stated experience level
  bool get areMaxLiftsRealisticForLevel {
    if (!hasMaxLiftData) return true; // Can't validate without data

    // Use bench press as primary indicator (most reliable)
    if (benchPressMax == null) return true;

    final benchRatio = benchPressMax! / bodyweightKg;

    // Check if ratio matches experience level (with 20% tolerance for individual variation)
    switch (experienceLevel) {
      case ExperienceLevel.untrained:
        return benchRatio <= 0.90; // Should be <0.75x BW
      case ExperienceLevel.novice:
        return benchRatio >= 0.70 && benchRatio <= 1.15; // 0.93x ±20%
      case ExperienceLevel.intermediate:
        return benchRatio >= 0.90 && benchRatio <= 1.40; // 1.13x ±20%
      case ExperienceLevel.advanced:
        return benchRatio >= 1.20 && benchRatio <= 1.80; // 1.47x ±20%
      case ExperienceLevel.elite:
        return benchRatio >= 1.50; // 1.83x+ BW
    }
  }

  /// Suggested experience level based on actual max lifts (override self-report if unrealistic)
  ExperienceLevel? get suggestedExperienceLevelFromLifts {
    if (benchPressMax == null) return null;

    final benchRatio = benchPressMax! / bodyweightKg;

    if (benchRatio < 0.75) return ExperienceLevel.untrained;
    if (benchRatio < 1.0) return ExperienceLevel.novice;
    if (benchRatio < 1.3) return ExperienceLevel.intermediate;
    if (benchRatio < 1.7) return ExperienceLevel.advanced;
    return ExperienceLevel.elite;
  }

  /// Final experience level with bias correction (Aandstad 2023: compensate for over-reporting)
  ExperienceLevel get calibratedExperienceLevel {
    // If max lifts don't match self-report, use objective data
    if (hasMaxLiftData && !areMaxLiftsRealisticForLevel) {
      return suggestedExperienceLevelFromLifts ?? experienceLevel;
    }

    // Apply self-report calibration
    switch (selfReportCalibration) {
      case SelfReportCalibration.optimistic:
        // User tends to over-estimate, drop one level if not untrained
        final index = ExperienceLevel.values.indexOf(experienceLevel);
        return index > 0
            ? ExperienceLevel.values[index - 1]
            : ExperienceLevel.untrained;
      case SelfReportCalibration.realistic:
        return experienceLevel;
      case SelfReportCalibration.conservative:
        // User under-estimates, bump up one level if not elite
        final index = ExperienceLevel.values.indexOf(experienceLevel);
        return index < ExperienceLevel.values.length - 1
            ? ExperienceLevel.values[index + 1]
            : ExperienceLevel.elite;
    }
  }
}

/// Injury details for detailed screening (Sciascia 2015)
@freezed
abstract class InjuryDetails with _$InjuryDetails {
  const factory InjuryDetails({
    /// Type of injury (e.g., "Lower back strain", "Shoulder impingement")
    required String injuryType,

    /// Body region affected
    required InjuryRegion region,

    /// How long ago injury occurred (months)
    required int monthsSinceInjury,

    /// Whether fully recovered
    @Default(false) bool fullyRecovered,

    /// Whether currently in rehabilitation
    @Default(false) bool inRehabilitation,

    /// Activities that aggravate the injury
    @Default([]) List<String> aggravatingActivities,
  }) = _InjuryDetails;

  factory InjuryDetails.fromJson(Map<String, dynamic> json) =>
      _$InjuryDetailsFromJson(json);
}

/// Body regions for injury tracking
enum InjuryRegion {
  @JsonValue('lower_back')
  lowerBack('Lower Back', 'Lombare'),

  @JsonValue('shoulder')
  shoulder('Shoulder', 'Spalla'),

  @JsonValue('knee')
  knee('Knee', 'Ginocchio'),

  @JsonValue('elbow')
  elbow('Elbow', 'Gomito'),

  @JsonValue('wrist')
  wrist('Wrist', 'Polso'),

  @JsonValue('hip')
  hip('Hip', 'Anca'),

  @JsonValue('ankle')
  ankle('Ankle', 'Caviglia'),

  @JsonValue('neck')
  neck('Neck', 'Collo'),

  @JsonValue('other')
  other('Other', 'Altro');

  const InjuryRegion(this.labelEN, this.labelIT);

  final String labelEN;
  final String labelIT;

  String getLabel(String locale) => locale.startsWith('it') ? labelIT : labelEN;
}

/// Self-report calibration to compensate for bias (Aandstad 2023)
enum SelfReportCalibration {
  /// User tends to over-estimate abilities (most common)
  @JsonValue('optimistic')
  optimistic('Optimistic', 'Ottimista'),

  /// User is realistic in self-assessment
  @JsonValue('realistic')
  realistic('Realistic', 'Realista'),

  /// User tends to under-estimate abilities (rare)
  @JsonValue('conservative')
  conservative('Conservative', 'Conservativo');

  const SelfReportCalibration(this.labelEN, this.labelIT);

  final String labelEN;
  final String labelIT;

  String getLabel(String locale) => locale.startsWith('it') ? labelIT : labelEN;
}
