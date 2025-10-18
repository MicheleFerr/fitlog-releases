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

  static const int totalSteps = 8;

  bool get isCompleted => completedSteps.length >= totalSteps;

  bool get hasStarted => completedSteps.isNotEmpty || currentStep > 0;

  bool isStepCompleted(int step) => completedSteps.contains(step);

  double get progress => completedSteps.length / totalSteps;

  OnboardingState copyWith({
    bool? hasSeenGlobalOnboarding,
    int? currentStep,
    List<int>? completedSteps,
    bool? canResume,
    int? onboardingVersion,
    DateTime? lastInteraction,
    Map<String, dynamic>? stepData,
  }) {
    return OnboardingState(
      hasSeenGlobalOnboarding: hasSeenGlobalOnboarding ?? this.hasSeenGlobalOnboarding,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      canResume: canResume ?? this.canResume,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      stepData: stepData ?? this.stepData,
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