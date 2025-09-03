import 'package:flutter/foundation.dart';

/// User Fitness Profile for personalized efficiency calculations
@immutable
class UserFitnessProfile {
  // Basic Demographics
  final int age;
  final Gender gender;
  final double bodyWeight; // kg
  final double height; // cm
  
  // Training Experience
  final ExperienceLevel experienceLevel;
  final int trainingYears;
  final TrainingGoal primaryGoal;
  
  // Lifestyle Factors
  final ActivityLevel dailyActivityLevel;
  final int averageSleepHours;
  final StressLevel stressLevel;
  final NutritionQuality nutritionQuality;
  
  // Recovery Factors
  final RecoveryCapacity recoveryCapacity;
  final bool hasInjuries;
  final List<String> injuredAreas;
  
  // Performance History
  final Map<String, double> personalRecords; // exercise -> max weight
  final double averageWorkoutDuration; // minutes
  final int weeklyWorkoutFrequency;
  
  // Adaptive Factors (learned over time)
  final Map<String, double> muscleRecoveryRates; // muscle -> days needed
  final double volumeTolerance; // multiplier for volume capacity
  final double intensityTolerance; // multiplier for high intensity capacity
  
  const UserFitnessProfile({
    required this.age,
    required this.gender,
    required this.bodyWeight,
    required this.height,
    required this.experienceLevel,
    required this.trainingYears,
    required this.primaryGoal,
    required this.dailyActivityLevel,
    required this.averageSleepHours,
    required this.stressLevel,
    required this.nutritionQuality,
    required this.recoveryCapacity,
    this.hasInjuries = false,
    this.injuredAreas = const [],
    this.personalRecords = const {},
    this.averageWorkoutDuration = 60,
    this.weeklyWorkoutFrequency = 3,
    this.muscleRecoveryRates = const {},
    this.volumeTolerance = 1.0,
    this.intensityTolerance = 1.0,
  });
  
  /// Calculate personalized recovery days for muscle group
  int getOptimalRecoveryDays(String muscleGroup) {
    // Check if we have learned data for this user
    if (muscleRecoveryRates.containsKey(muscleGroup)) {
      return muscleRecoveryRates[muscleGroup]!.round();
    }
    
    // Otherwise calculate based on profile
    double baseDays = 3.0;
    
    // Adjust for experience
    switch (experienceLevel) {
      case ExperienceLevel.beginner:
        baseDays += 1.0;
        break;
      case ExperienceLevel.intermediate:
        baseDays += 0.0;
        break;
      case ExperienceLevel.advanced:
        baseDays -= 0.5;
        break;
      case ExperienceLevel.elite:
        baseDays -= 1.0;
        break;
    }
    
    // Adjust for age
    if (age < 25) {
      baseDays -= 0.5;
    } else if (age > 40) {
      baseDays += 0.5;
    } else if (age > 50) {
      baseDays += 1.0;
    }
    
    // Adjust for recovery capacity
    switch (recoveryCapacity) {
      case RecoveryCapacity.poor:
        baseDays += 1.0;
        break;
      case RecoveryCapacity.average:
        baseDays += 0.0;
        break;
      case RecoveryCapacity.good:
        baseDays -= 0.5;
        break;
      case RecoveryCapacity.excellent:
        baseDays -= 1.0;
        break;
    }
    
    // Adjust for sleep
    if (averageSleepHours < 6) {
      baseDays += 1.0;
    } else if (averageSleepHours >= 8) {
      baseDays -= 0.5;
    }
    
    // Adjust for stress
    if (stressLevel == StressLevel.high) {
      baseDays += 0.5;
    }
    
    // Large muscle groups need more recovery
    if (muscleGroup == 'legs' || muscleGroup == 'back') {
      baseDays += 0.5;
    }
    
    return baseDays.clamp(1, 7).round();
  }
  
  /// Get personalized weekly volume progression rate
  double getOptimalProgressionRate() {
    double baseRate = 0.03; // 3% default
    
    // Adjust for experience
    switch (experienceLevel) {
      case ExperienceLevel.beginner:
        baseRate = 0.05; // 5% - newbie gains
        break;
      case ExperienceLevel.intermediate:
        baseRate = 0.03; // 3%
        break;
      case ExperienceLevel.advanced:
        baseRate = 0.02; // 2%
        break;
      case ExperienceLevel.elite:
        baseRate = 0.01; // 1% - near genetic limit
        break;
    }
    
    // Adjust for age
    if (age > 40) {
      baseRate *= 0.8; // Slower progression
    } else if (age < 25) {
      baseRate *= 1.2; // Faster progression
    }
    
    // Adjust for goal
    switch (primaryGoal) {
      case TrainingGoal.strength:
        baseRate *= 0.8; // Slower but steadier
        break;
      case TrainingGoal.hypertrophy:
        baseRate *= 1.0; // Normal
        break;
      case TrainingGoal.endurance:
        baseRate *= 1.2; // Can progress faster
        break;
      case TrainingGoal.weightLoss:
        baseRate *= 0.6; // Slower in deficit
        break;
      case TrainingGoal.maintenance:
        baseRate = 0; // No progression needed
        break;
    }
    
    // Apply learned tolerance
    baseRate *= volumeTolerance;
    
    return baseRate;
  }
  
  /// Get optimal workout frequency
  int getOptimalWeeklyFrequency() {
    int baseFrequency = 4;
    
    // Adjust for experience
    switch (experienceLevel) {
      case ExperienceLevel.beginner:
        baseFrequency = 3;
        break;
      case ExperienceLevel.intermediate:
        baseFrequency = 4;
        break;
      case ExperienceLevel.advanced:
        baseFrequency = 5;
        break;
      case ExperienceLevel.elite:
        baseFrequency = 6;
        break;
    }
    
    // Adjust for recovery capacity
    if (recoveryCapacity == RecoveryCapacity.poor) {
      baseFrequency -= 1;
    } else if (recoveryCapacity == RecoveryCapacity.excellent) {
      baseFrequency += 1;
    }
    
    // Adjust for lifestyle
    if (dailyActivityLevel == ActivityLevel.veryActive) {
      baseFrequency -= 1; // Already active
    }
    
    // Adjust for age
    if (age > 50) {
      baseFrequency = (baseFrequency * 0.8).round();
    }
    
    return baseFrequency.clamp(2, 7);
  }
  
  /// Get optimal intensity distribution
  IntensityDistribution getOptimalIntensityDistribution() {
    // Default distribution
    double high = 0.20;
    double medium = 0.60;
    double low = 0.20;
    
    // Adjust for experience
    switch (experienceLevel) {
      case ExperienceLevel.beginner:
        high = 0.10; // Less high intensity
        medium = 0.60;
        low = 0.30; // More low intensity
        break;
      case ExperienceLevel.intermediate:
        high = 0.20;
        medium = 0.60;
        low = 0.20;
        break;
      case ExperienceLevel.advanced:
        high = 0.25;
        medium = 0.55;
        low = 0.20;
        break;
      case ExperienceLevel.elite:
        high = 0.30;
        medium = 0.50;
        low = 0.20;
        break;
    }
    
    // Adjust for age
    if (age > 45) {
      high *= 0.7; // Less high intensity
      low = 1 - high - medium; // More low intensity
    }
    
    // Adjust for goal
    if (primaryGoal == TrainingGoal.strength) {
      high *= 1.3; // More high intensity for strength
      medium = 1 - high - low;
    } else if (primaryGoal == TrainingGoal.endurance) {
      low *= 1.5; // More low intensity for endurance
      high = 0.10;
      medium = 1 - high - low;
    }
    
    // Apply learned tolerance
    high *= intensityTolerance;
    
    // Normalize to ensure sum = 1
    final total = high + medium + low;
    
    return IntensityDistribution(
      high: high / total,
      medium: medium / total,
      low: low / total,
    );
  }
  
  /// Create default profile for new user
  factory UserFitnessProfile.createDefault({
    required int age,
    required Gender gender,
    required double bodyWeight,
    required double height,
  }) {
    // Estimate experience level based on age
    final experienceLevel = age < 20 ? ExperienceLevel.beginner
        : age < 30 ? ExperienceLevel.intermediate
        : ExperienceLevel.intermediate;
    
    return UserFitnessProfile(
      age: age,
      gender: gender,
      bodyWeight: bodyWeight,
      height: height,
      experienceLevel: experienceLevel,
      trainingYears: 0,
      primaryGoal: TrainingGoal.hypertrophy,
      dailyActivityLevel: ActivityLevel.moderate,
      averageSleepHours: 7,
      stressLevel: StressLevel.medium,
      nutritionQuality: NutritionQuality.average,
      recoveryCapacity: RecoveryCapacity.average,
    );
  }
  
  /// Update profile with learned data
  UserFitnessProfile updateWithLearnedData({
    Map<String, double>? muscleRecoveryRates,
    double? volumeTolerance,
    double? intensityTolerance,
  }) {
    return UserFitnessProfile(
      age: age,
      gender: gender,
      bodyWeight: bodyWeight,
      height: height,
      experienceLevel: experienceLevel,
      trainingYears: trainingYears,
      primaryGoal: primaryGoal,
      dailyActivityLevel: dailyActivityLevel,
      averageSleepHours: averageSleepHours,
      stressLevel: stressLevel,
      nutritionQuality: nutritionQuality,
      recoveryCapacity: recoveryCapacity,
      hasInjuries: hasInjuries,
      injuredAreas: injuredAreas,
      personalRecords: personalRecords,
      averageWorkoutDuration: averageWorkoutDuration,
      weeklyWorkoutFrequency: weeklyWorkoutFrequency,
      muscleRecoveryRates: muscleRecoveryRates ?? this.muscleRecoveryRates,
      volumeTolerance: volumeTolerance ?? this.volumeTolerance,
      intensityTolerance: intensityTolerance ?? this.intensityTolerance,
    );
  }
}

// Enums for profile properties
enum Gender { male, female, other }

enum ExperienceLevel {
  beginner, // < 1 year
  intermediate, // 1-3 years
  advanced, // 3-5 years
  elite // 5+ years
}

enum TrainingGoal {
  strength,
  hypertrophy,
  endurance,
  weightLoss,
  maintenance
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderate,
  veryActive,
  extremelyActive
}

enum StressLevel { low, medium, high }

enum NutritionQuality { poor, average, good, excellent }

enum RecoveryCapacity { poor, average, good, excellent }

class IntensityDistribution {
  final double high;
  final double medium;
  final double low;
  
  const IntensityDistribution({
    required this.high,
    required this.medium,
    required this.low,
  });
}