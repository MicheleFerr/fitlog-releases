import 'dart:math';

/// Calculator for One Rep Max (1RM) estimations
/// Implements multiple formulas for accuracy across different rep ranges
class OneRMCalculator {
  /// Calculate 1RM using Brzycki formula
  /// Best for: 2-10 reps
  /// Formula: Weight × (36 / (37 - reps))
  static double calculateBrzycki(double weight, int reps) {
    if (weight <= 0) return 0;
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    if (reps > 36) return 0; // Formula breaks down above 36 reps
    
    return weight * (36 / (37 - reps));
  }

  /// Calculate 1RM using Epley formula
  /// Best for: 1-10 reps
  /// Formula: Weight × (1 + reps/30)
  static double calculateEpley(double weight, int reps) {
    if (weight <= 0) return 0;
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    
    return weight * (1 + reps / 30);
  }

  /// Calculate 1RM using Lombardi formula
  /// Best for: All rep ranges
  /// Formula: Weight × reps^0.10
  static double calculateLombardi(double weight, int reps) {
    if (weight <= 0) return 0;
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    
    return weight * pow(reps, 0.10);
  }

  /// Calculate 1RM using O'Conner formula
  /// Best for: Under 10 reps
  /// Formula: Weight × (1 + reps/40)
  static double calculateOConner(double weight, int reps) {
    if (weight <= 0) return 0;
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    
    return weight * (1 + reps / 40);
  }

  /// Calculate 1RM using Wathan formula
  /// Best for: All rep ranges
  /// Formula: (100 × weight) / (48.8 + 53.8 × e^(-0.075 × reps))
  static double calculateWathan(double weight, int reps) {
    if (weight <= 0) return 0;
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    
    return (100 * weight) / (48.8 + 53.8 * exp(-0.075 * reps));
  }

  /// Calculate weighted average 1RM from multiple formulas
  /// Weights are adjusted based on rep range for optimal accuracy
  static double calculateAverage(double weight, int reps) {
    if (weight <= 0) return 0;
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    
    final brzycki = calculateBrzycki(weight, reps);
    final epley = calculateEpley(weight, reps);
    final lombardi = calculateLombardi(weight, reps);
    final oconner = calculateOConner(weight, reps);
    final wathan = calculateWathan(weight, reps);
    
    // Adjust weights based on rep range
    if (reps <= 5) {
      // Low reps: Brzycki and Epley are most accurate
      return (brzycki * 0.35 + 
              epley * 0.35 + 
              lombardi * 0.10 + 
              oconner * 0.10 + 
              wathan * 0.10);
    } else if (reps <= 10) {
      // Medium reps: Balanced weights
      return (brzycki * 0.25 + 
              epley * 0.25 + 
              lombardi * 0.20 + 
              oconner * 0.15 + 
              wathan * 0.15);
    } else {
      // High reps: Lombardi and Wathan are more reliable
      return (brzycki * 0.15 + 
              epley * 0.15 + 
              lombardi * 0.30 + 
              oconner * 0.10 + 
              wathan * 0.30);
    }
  }

  /// Calculate weight needed for specific reps based on 1RM
  /// Inverse of 1RM calculation
  static double calculateWeightForReps(double oneRM, int targetReps) {
    if (oneRM <= 0) return 0;
    if (targetReps <= 0) return 0;
    if (targetReps == 1) return oneRM;
    
    // Using inverse Brzycki formula for consistency
    return oneRM * (37 - targetReps) / 36;
  }

  /// Calculate training percentages based on 1RM
  static Map<String, double> calculateTrainingPercentages(double oneRM) {
    if (oneRM <= 0) {
      return {
        'max_strength': 0,
        'strength': 0,
        'hypertrophy': 0,
        'endurance': 0,
        'warmup': 0,
      };
    }
    
    return {
      'max_strength': oneRM * 0.90, // 90% - Max strength training
      'strength': oneRM * 0.85,     // 85% - Strength building
      'hypertrophy': oneRM * 0.75,  // 75% - Muscle building
      'endurance': oneRM * 0.60,    // 60% - Muscular endurance
      'warmup': oneRM * 0.50,       // 50% - Warm-up weight
    };
  }

  /// Calculate RPE-based 1RM estimation
  /// Uses RPE scale (6-10) to adjust 1RM calculation
  static double calculateWithRPE(double weight, int reps, int rpe) {
    if (weight <= 0 || reps <= 0 || rpe < 6 || rpe > 10) return 0;
    
    // Estimate reps in reserve based on RPE
    final repsInReserve = 10 - rpe;
    
    // Adjust total reps capability
    final totalRepsCapability = reps + repsInReserve;
    
    // Calculate 1RM based on total capability
    return calculateAverage(weight, totalRepsCapability);
  }

  /// Calculate confidence interval for 1RM estimation
  /// Returns lower and upper bounds based on formula variance
  static Map<String, double> calculateConfidenceInterval(double weight, int reps) {
    if (weight <= 0 || reps <= 0) {
      return {'lower': 0, 'average': 0, 'upper': 0};
    }
    
    final results = [
      calculateBrzycki(weight, reps),
      calculateEpley(weight, reps),
      calculateLombardi(weight, reps),
      calculateOConner(weight, reps),
      calculateWathan(weight, reps),
    ];
    
    results.sort();
    
    return {
      'lower': results.first,
      'average': calculateAverage(weight, reps),
      'upper': results.last,
    };
  }

  /// Validate if a weight/reps combination is realistic for given 1RM
  static bool isRealisticLift(double weight, int reps, double estimated1RM) {
    if (weight <= 0 || reps <= 0 || estimated1RM <= 0) return false;
    
    final percentage = (weight / estimated1RM) * 100;
    
    // Based on strength training standards
    if (reps == 1 && percentage > 100) return percentage <= 105; // Allow 5% variance
    if (reps <= 3 && percentage > 93) return false;
    if (reps <= 5 && percentage > 87) return false;
    if (reps <= 8 && percentage > 80) return false;
    if (reps <= 12 && percentage > 70) return false;
    if (reps <= 15 && percentage > 65) return false;
    if (reps <= 20 && percentage > 60) return false;
    
    return true;
  }
}

/// Extension methods for common calculations
extension OneRMExtensions on double {
  /// Convert weight to different unit
  double toKg() => this * 0.453592; // From lbs
  double toLbs() => this * 2.20462; // From kg
  
  /// Round to nearest 2.5 (for kg plates)
  double roundToPlate({double increment = 2.5}) {
    return (this / increment).round() * increment;
  }
}