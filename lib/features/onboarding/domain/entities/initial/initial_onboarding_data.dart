import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

part 'initial_onboarding_data.freezed.dart';
part 'initial_onboarding_data.g.dart';

/// Data collected during initial onboarding flow.
///
/// This is a UI-focused entity that maps to the underlying
/// [UserFitnessQuestionnaire] and [UserGoals] for persistence.
@freezed
abstract class InitialOnboardingData with _$InitialOnboardingData {
  const factory InitialOnboardingData({
    // Step 1: Goal
    required TrainingGoalUI goal,

    // Step 2: Personal Info
    required BiologicalSex sex,
    required int age,

    // Step 3: Body data
    required double heightCm,
    required double bodyweightKg,

    // Step 4: Experience
    required ExperienceLevelUI experience,

    // Step 5: HealthKit (tracking only, not persisted)
    @Default(false) bool healthKitConnected,
    @Default([]) List<String> healthKitPermissionsGranted,

    // Step 5: Frequency
    @Default(3) int workoutsPerWeek,

    // Meta
    DateTime? completedAt,
  }) = _InitialOnboardingData;

  const InitialOnboardingData._();

  factory InitialOnboardingData.fromJson(Map<String, dynamic> json) =>
      _$InitialOnboardingDataFromJson(json);

  /// Convert to UserFitnessQuestionnaire for persistence
  UserFitnessQuestionnaire toQuestionnaire() {
    return UserFitnessQuestionnaire(
      bodyweightKg: bodyweightKg,
      sex: sex,
      experienceLevel: experience.toExperienceLevel(),
      trainingGoal: goal.toTrainingGoal(),
      age: age,
      heightCm: heightCm,
      completedAt: completedAt ?? DateTime.now(),
    );
  }
}

/// UI-friendly goal enum with user-readable labels.
///
/// Maps to [TrainingGoal] for internal use.
enum TrainingGoalUI {
  /// "Aumentare i muscoli" - Build muscle mass
  buildMuscle,

  /// "Diventare più forte" - Get stronger
  getStronger,

  /// "Migliorare la resistenza" - Improve endurance
  endurance,

  /// "Mantenermi in forma" - Stay fit (general fitness)
  stayFit,
}

extension TrainingGoalUIExtension on TrainingGoalUI {
  /// Convert to internal TrainingGoal enum
  TrainingGoal toTrainingGoal() {
    switch (this) {
      case TrainingGoalUI.buildMuscle:
        return TrainingGoal.hypertrophy;
      case TrainingGoalUI.getStronger:
        return TrainingGoal.strength;
      case TrainingGoalUI.endurance:
        return TrainingGoal.endurance;
      case TrainingGoalUI.stayFit:
        return TrainingGoal.hypertrophy; // Default to hypertrophy
    }
  }

  /// Icon for UI display
  String get icon {
    switch (this) {
      case TrainingGoalUI.buildMuscle:
        return '\u{1F4AA}'; // 💪
      case TrainingGoalUI.getStronger:
        return '\u{1F9BE}'; // 🦾
      case TrainingGoalUI.endurance:
        return '\u{1F3C3}'; // 🏃
      case TrainingGoalUI.stayFit:
        return '\u{2764}'; // ❤️
    }
  }
}

/// UI-friendly experience level enum.
///
/// Maps to [ExperienceLevel] for internal use.
enum ExperienceLevelUI {
  /// "Principiante" - Never or rarely at gym (0-6 months)
  beginner,

  /// "Qualche esperienza" - Some experience (6-24 months)
  someExperience,

  /// "Esperto" - Experienced (2-5 years)
  experienced,

  /// "Atleta avanzato" - Advanced athlete (5+ years)
  athlete,
}

extension ExperienceLevelUIExtension on ExperienceLevelUI {
  /// Convert to internal ExperienceLevel enum
  ExperienceLevel toExperienceLevel() {
    switch (this) {
      case ExperienceLevelUI.beginner:
        return ExperienceLevel.novice;
      case ExperienceLevelUI.someExperience:
        return ExperienceLevel.intermediate;
      case ExperienceLevelUI.experienced:
        return ExperienceLevel.advanced;
      case ExperienceLevelUI.athlete:
        return ExperienceLevel.elite;
    }
  }

  /// Estimated months of training
  int get estimatedMonths {
    switch (this) {
      case ExperienceLevelUI.beginner:
        return 3;
      case ExperienceLevelUI.someExperience:
        return 12;
      case ExperienceLevelUI.experienced:
        return 36;
      case ExperienceLevelUI.athlete:
        return 72;
    }
  }

  /// Icon for UI display
  String get icon {
    switch (this) {
      case ExperienceLevelUI.beginner:
        return '\u{1F331}'; // 🌱
      case ExperienceLevelUI.someExperience:
        return '\u{1F4C8}'; // 📈
      case ExperienceLevelUI.experienced:
        return '\u{1F4AA}'; // 💪
      case ExperienceLevelUI.athlete:
        return '\u{1F3C6}'; // 🏆
    }
  }
}
