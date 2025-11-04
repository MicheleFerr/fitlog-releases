import 'package:hive_flutter/hive_flutter.dart';

part 'onboarding_state.g.dart';

@HiveType(typeId: 3)
class OnboardingState {

  const OnboardingState({
    this.hasSeenGlobalOnboarding = false,
    this.currentStep = 0,
    this.completedSteps = const [],
    this.canResume = false,
    this.onboardingVersion = 1,
    this.lastInteraction,
    this.stepData = const {},
    this.userExperienceLevel,
    this.seenOverlays = const [],
    this.overlayVersionSeen = 1,
    this.quickStartCompletedAt,
    this.hasCompletedFirstWorkout = false,
    this.firstExerciseAddedAt,
    this.firstSetCompletedAt,
    this.hasSeenRestTimerExplanation = false,
  });

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      hasSeenGlobalOnboarding: json['hasSeenGlobalOnboarding'] ?? false,
      currentStep: json['currentStep'] ?? 0,
      completedSteps: List<int>.from(json['completedSteps'] ?? []),
      canResume: json['canResume'] ?? false,
      onboardingVersion: json['onboardingVersion'] ?? 1,
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.parse(json['lastInteraction'])
          : null,
      stepData: Map<String, dynamic>.from(json['stepData'] ?? {}),
      userExperienceLevel: json['userExperienceLevel'],
      seenOverlays: List<String>.from(json['seenOverlays'] ?? []),
      overlayVersionSeen: json['overlayVersionSeen'] ?? 1,
      quickStartCompletedAt: json['quickStartCompletedAt'] != null
          ? DateTime.parse(json['quickStartCompletedAt'])
          : null,
      hasCompletedFirstWorkout: json['hasCompletedFirstWorkout'] ?? false,
      firstExerciseAddedAt: json['firstExerciseAddedAt'] != null
          ? DateTime.parse(json['firstExerciseAddedAt'])
          : null,
      firstSetCompletedAt: json['firstSetCompletedAt'] != null
          ? DateTime.parse(json['firstSetCompletedAt'])
          : null,
      hasSeenRestTimerExplanation: json['hasSeenRestTimerExplanation'] ?? false,
    );
  }
  @HiveField(0)
  final bool hasSeenGlobalOnboarding;

  @HiveField(1)
  final int currentStep;

  @HiveField(2)
  final List<int> completedSteps;

  @HiveField(3)
  final bool canResume;

  @HiveField(4)
  final int onboardingVersion;

  @HiveField(5)
  final DateTime? lastInteraction;

  @HiveField(6)
  final Map<String, dynamic> stepData;

  // NEW FIELDS for new onboarding system
  @HiveField(10)
  final String? userExperienceLevel; // 'beginner' | 'expert' | null

  @HiveField(11)
  final List<String> seenOverlays; // ['createWorkoutCTA', 'addExerciseHelp', ...]

  @HiveField(12)
  final int overlayVersionSeen; // v1, v2 (for deprecation)

  @HiveField(13)
  final DateTime? quickStartCompletedAt;

  @HiveField(14)
  final bool hasCompletedFirstWorkout; // trigger for Phase 2

  // PHASE 2: Guided First Workout tracking
  @HiveField(15)
  final DateTime? firstExerciseAddedAt; // when user adds first exercise

  @HiveField(16)
  final DateTime? firstSetCompletedAt; // when user completes first set

  @HiveField(17)
  final bool hasSeenRestTimerExplanation; // rest timer overlay shown

  static const int totalSteps = 8;

  bool get isCompleted => completedSteps.length >= totalSteps;

  bool get hasStarted => completedSteps.isNotEmpty || currentStep > 0;

  bool isStepCompleted(int step) => completedSteps.contains(step);

  double get progress => completedSteps.length / totalSteps;

  // NEW HELPER METHODS for new onboarding system
  bool get hasCompletedQuickStart => quickStartCompletedAt != null || userExperienceLevel != null;

  bool get isBeginner => userExperienceLevel == 'beginner';

  bool get isExpert => userExperienceLevel == 'expert';

  bool hasSeenOverlay(String overlayId) => seenOverlays.contains(overlayId);

  // PHASE 2 HELPER METHODS
  bool get hasAddedFirstExercise => firstExerciseAddedAt != null;

  bool get hasCompletedFirstSet => firstSetCompletedAt != null;

  /// Check if beginner is in first workout flow (needs guidance)
  bool get isInGuidedFirstWorkout => isBeginner && !hasCompletedFirstWorkout;

  /// Check if should show "Add First Exercise" overlay
  bool get shouldShowAddFirstExercise =>
      isInGuidedFirstWorkout && !hasAddedFirstExercise && !hasSeenOverlay('addFirstExercise');

  /// Check if should show "Complete Workout" overlay (after 1+ set)
  bool get shouldShowCompleteWorkout =>
      isInGuidedFirstWorkout && hasCompletedFirstSet && !hasSeenOverlay('completeFirstWorkout');

  OnboardingState copyWith({
    bool? hasSeenGlobalOnboarding,
    int? currentStep,
    List<int>? completedSteps,
    bool? canResume,
    int? onboardingVersion,
    DateTime? lastInteraction,
    Map<String, dynamic>? stepData,
    String? userExperienceLevel,
    List<String>? seenOverlays,
    int? overlayVersionSeen,
    DateTime? quickStartCompletedAt,
    bool? hasCompletedFirstWorkout,
    DateTime? firstExerciseAddedAt,
    DateTime? firstSetCompletedAt,
    bool? hasSeenRestTimerExplanation,
  }) {
    return OnboardingState(
      hasSeenGlobalOnboarding: hasSeenGlobalOnboarding ?? this.hasSeenGlobalOnboarding,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      canResume: canResume ?? this.canResume,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      stepData: stepData ?? this.stepData,
      userExperienceLevel: userExperienceLevel ?? this.userExperienceLevel,
      seenOverlays: seenOverlays ?? this.seenOverlays,
      overlayVersionSeen: overlayVersionSeen ?? this.overlayVersionSeen,
      quickStartCompletedAt: quickStartCompletedAt ?? this.quickStartCompletedAt,
      hasCompletedFirstWorkout: hasCompletedFirstWorkout ?? this.hasCompletedFirstWorkout,
      firstExerciseAddedAt: firstExerciseAddedAt ?? this.firstExerciseAddedAt,
      firstSetCompletedAt: firstSetCompletedAt ?? this.firstSetCompletedAt,
      hasSeenRestTimerExplanation: hasSeenRestTimerExplanation ?? this.hasSeenRestTimerExplanation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasSeenGlobalOnboarding': hasSeenGlobalOnboarding,
      'currentStep': currentStep,
      'completedSteps': completedSteps,
      'canResume': canResume,
      'onboardingVersion': onboardingVersion,
      'lastInteraction': lastInteraction?.toIso8601String(),
      'stepData': stepData,
      'userExperienceLevel': userExperienceLevel,
      'seenOverlays': seenOverlays,
      'overlayVersionSeen': overlayVersionSeen,
      'quickStartCompletedAt': quickStartCompletedAt?.toIso8601String(),
      'hasCompletedFirstWorkout': hasCompletedFirstWorkout,
      'firstExerciseAddedAt': firstExerciseAddedAt?.toIso8601String(),
      'firstSetCompletedAt': firstSetCompletedAt?.toIso8601String(),
      'hasSeenRestTimerExplanation': hasSeenRestTimerExplanation,
    };
  }

  @override
  String toString() {
    return 'OnboardingState{hasSeenGlobalOnboarding: $hasSeenGlobalOnboarding, currentStep: $currentStep, completedSteps: $completedSteps, progress: ${(progress * 100).toStringAsFixed(1)}%}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.hasSeenGlobalOnboarding == hasSeenGlobalOnboarding &&
        other.currentStep == currentStep &&
        other.completedSteps.length == completedSteps.length &&
        other.canResume == canResume &&
        other.onboardingVersion == onboardingVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasSeenGlobalOnboarding,
      currentStep,
      completedSteps.length,
      canResume,
      onboardingVersion,
    );
  }
}

// Step definitions
enum OnboardingStep {
  welcome(0, 'Welcome'),
  modeSelection(1, 'Mode Selection'),
  togglePanorama(2, 'Toggle Overview'),
  createWorkout(3, 'Create Workout'),
  addExercise(4, 'Add Exercise'),
  executeSet(5, 'Execute Set'),
  timerRest(6, 'Timer & Rest'),
  advancedFeatures(7, 'Advanced Features');

  const OnboardingStep(this.stepIndex, this.title);

  final int stepIndex;
  final String title;

  static OnboardingStep fromIndex(int index) {
    return OnboardingStep.values.firstWhere(
      (step) => step.stepIndex == index,
      orElse: () => OnboardingStep.welcome,
    );
  }
}