// Buddy matching preferences entity

enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
}

enum FitnessGoal {
  muscleGain,
  weightLoss,
  strength,
  endurance,
  flexibility,
  generalFitness,
}

enum WorkoutTime {
  earlyMorning, // 5-7am
  morning,      // 7-11am
  lunch,        // 12-2pm
  afternoon,    // 2-6pm
  evening,      // 6-9pm
  lateEvening,  // 9-11pm
  weekend,      // Flexible weekend
}

enum PersonalityType {
  competitive,
  supportive,
  mixed,
}

enum GenderPreference {
  male,
  female,
  any,
}

class AgeRange {
  final int min;
  final int max;
  
  const AgeRange({required this.min, required this.max});
  
  Map<String, dynamic> toJson() => {
    'min': min,
    'max': max,
  };
  
  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(
      min: json['min'] ?? 18,
      max: json['max'] ?? 99,
    );
  }
}

class BuddyPreferences {
  List<WorkoutTime> workoutSchedule;
  FitnessLevel fitnessLevel;
  List<FitnessGoal> goals;
  List<String> preferredActivities;
  double maxDistance; // in km
  AgeRange ageRange;
  GenderPreference genderPreference;
  PersonalityType personalityType;
  bool isLookingForBuddy;

  BuddyPreferences({
    required this.workoutSchedule,
    required this.fitnessLevel,
    required this.goals,
    required this.preferredActivities,
    required this.maxDistance,
    required this.ageRange,
    required this.genderPreference,
    required this.personalityType,
    this.isLookingForBuddy = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'workoutSchedule': workoutSchedule.map((e) => e.toString()).toList(),
      'fitnessLevel': fitnessLevel.toString(),
      'goals': goals.map((e) => e.toString()).toList(),
      'preferredActivities': preferredActivities,
      'maxDistance': maxDistance,
      'ageRange': ageRange.toJson(),
      'genderPreference': genderPreference.toString(),
      'personalityType': personalityType.toString(),
      'isLookingForBuddy': isLookingForBuddy,
    };
  }

  factory BuddyPreferences.fromJson(Map<String, dynamic> json) {
    return BuddyPreferences(
      workoutSchedule: (json['workoutSchedule'] as List<dynamic>?)
          ?.map((e) => WorkoutTime.values.firstWhere(
                (t) => t.toString() == e,
                orElse: () => WorkoutTime.evening,
              ))
          .toList() ?? [],
      fitnessLevel: FitnessLevel.values.firstWhere(
        (l) => l.toString() == json['fitnessLevel'],
        orElse: () => FitnessLevel.intermediate,
      ),
      goals: (json['goals'] as List<dynamic>?)
          ?.map((e) => FitnessGoal.values.firstWhere(
                (g) => g.toString() == e,
                orElse: () => FitnessGoal.generalFitness,
              ))
          .toList() ?? [],
      preferredActivities: List<String>.from(json['preferredActivities'] ?? []),
      maxDistance: (json['maxDistance'] ?? 10).toDouble(),
      ageRange: AgeRange.fromJson(json['ageRange'] ?? {'min': 18, 'max': 99}),
      genderPreference: GenderPreference.values.firstWhere(
        (g) => g.toString() == json['genderPreference'],
        orElse: () => GenderPreference.any,
      ),
      personalityType: PersonalityType.values.firstWhere(
        (p) => p.toString() == json['personalityType'],
        orElse: () => PersonalityType.mixed,
      ),
      isLookingForBuddy: json['isLookingForBuddy'] ?? true,
    );
  }
}