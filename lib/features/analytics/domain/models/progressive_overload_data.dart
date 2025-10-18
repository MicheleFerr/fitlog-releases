import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Progressive Overload tracking and cloud sync
class ProgressiveOverloadData {

  ProgressiveOverloadData({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.weekNumber,
    required this.year,
    required this.totalVolume,
    required this.avgIntensity,
    required this.progressiveOverloadScore,
    required this.previousWeekScore,
    required this.e1RMProgression,
    required this.effectiveVolume,
    this.bestSet,
    required this.fatigueRatings,
    required this.avgMuscleEfficiency,
    required this.createdAt,
    this.syncedAt,
    this.isPremiumData = false,
  });

  /// Create from Firestore document
  factory ProgressiveOverloadData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ProgressiveOverloadData(
      userId: data['userId'] as String,
      weekStart: (data['weekStart'] as Timestamp).toDate(),
      weekEnd: (data['weekEnd'] as Timestamp).toDate(),
      weekNumber: data['weekNumber'] as int,
      year: data['year'] as int,
      totalVolume: (data['totalVolume'] as num).toDouble(),
      avgIntensity: (data['avgIntensity'] as num).toDouble(),
      progressiveOverloadScore: (data['progressiveOverloadScore'] as num).toDouble(),
      previousWeekScore: (data['previousWeekScore'] as num).toDouble(),
      e1RMProgression: Map<String, double>.from(data['e1RMProgression'] as Map),
      effectiveVolume: (data['effectiveVolume'] as num).toDouble(),
      bestSet: data['bestSet'] != null 
          ? BestSetPerformance.fromMap(data['bestSet'] as Map<String, dynamic>)
          : null,
      fatigueRatings: (data['fatigueRatings'] as List)
          .map((e) => FatigueEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      avgMuscleEfficiency: (data['avgMuscleEfficiency'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      syncedAt: data['syncedAt'] != null 
          ? (data['syncedAt'] as Timestamp).toDate()
          : null,
      isPremiumData: data['isPremiumData'] as bool? ?? false,
    );
  }

  /// Create from JSON (local storage)
  factory ProgressiveOverloadData.fromJson(Map<String, dynamic> json) {
    return ProgressiveOverloadData(
      userId: json['userId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      weekNumber: json['weekNumber'] as int,
      year: json['year'] as int,
      totalVolume: (json['totalVolume'] as num).toDouble(),
      avgIntensity: (json['avgIntensity'] as num).toDouble(),
      progressiveOverloadScore: (json['progressiveOverloadScore'] as num).toDouble(),
      previousWeekScore: (json['previousWeekScore'] as num).toDouble(),
      e1RMProgression: Map<String, double>.from(json['e1RMProgression'] as Map),
      effectiveVolume: (json['effectiveVolume'] as num).toDouble(),
      bestSet: json['bestSet'] != null 
          ? BestSetPerformance.fromMap(json['bestSet'] as Map<String, dynamic>)
          : null,
      fatigueRatings: (json['fatigueRatings'] as List)
          .map((e) => FatigueEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      avgMuscleEfficiency: (json['avgMuscleEfficiency'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] != null 
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      isPremiumData: json['isPremiumData'] as bool? ?? false,
    );
  }
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int weekNumber;
  final int year;
  
  // Core metrics
  final double totalVolume;
  final double avgIntensity; // 1-10 scale based on RPE/effort
  final double progressiveOverloadScore;
  final double previousWeekScore;
  
  // Weekly dashboard metrics
  final Map<String, double> e1RMProgression; // Exercise -> estimated 1RM
  final double effectiveVolume; // Volume that actually counts for growth
  final BestSetPerformance? bestSet;
  
  // Fatigue and efficiency data
  final List<FatigueEntry> fatigueRatings;
  final double avgMuscleEfficiency;
  
  // Metadata
  final DateTime createdAt;
  final DateTime? syncedAt;
  final bool isPremiumData;

  /// Calculate Progressive Overload Score
  /// PO Score = (Volume_Week × Avg_Intensity) / Previous_Week_Score
  static double calculatePOScore({
    required double currentVolume,
    required double currentIntensity,
    required double previousScore,
  }) {
    if (previousScore == 0) return 1.0; // First week baseline
    
    final currentScore = currentVolume * currentIntensity;
    return currentScore / previousScore;
  }

  /// Interpret the PO Score
  String get progressInterpretation {
    if (progressiveOverloadScore > 1.05) {
      return '🔥 Excellent Progress! (+${((progressiveOverloadScore - 1) * 100).toStringAsFixed(1)}%)';
    } else if (progressiveOverloadScore >= 1.02) {
      return '✅ Optimal Progress (+${((progressiveOverloadScore - 1) * 100).toStringAsFixed(1)}%)';
    } else if (progressiveOverloadScore >= 1.0) {
      return '📈 Slight Progress (+${((progressiveOverloadScore - 1) * 100).toStringAsFixed(1)}%)';
    } else if (progressiveOverloadScore >= 0.95) {
      return '⚠️ Minor Regression (${((progressiveOverloadScore - 1) * 100).toStringAsFixed(1)}%)';
    } else {
      return '🔴 Deload Needed (${((progressiveOverloadScore - 1) * 100).toStringAsFixed(1)}%)';
    }
  }

  /// Get color based on score
  String get scoreColor {
    if (progressiveOverloadScore >= 1.02) return 'green';
    if (progressiveOverloadScore >= 1.0) return 'orange';
    return 'red';
  }

  /// Convert to Firestore document (for premium users)
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'weekStart': Timestamp.fromDate(weekStart),
    'weekEnd': Timestamp.fromDate(weekEnd),
    'weekNumber': weekNumber,
    'year': year,
    'totalVolume': totalVolume,
    'avgIntensity': avgIntensity,
    'progressiveOverloadScore': progressiveOverloadScore,
    'previousWeekScore': previousWeekScore,
    'e1RMProgression': e1RMProgression,
    'effectiveVolume': effectiveVolume,
    'bestSet': bestSet?.toMap(),
    'fatigueRatings': fatigueRatings.map((e) => e.toMap()).toList(),
    'avgMuscleEfficiency': avgMuscleEfficiency,
    'createdAt': Timestamp.fromDate(createdAt),
    'syncedAt': syncedAt != null ? Timestamp.fromDate(syncedAt!) : null,
    'isPremiumData': isPremiumData,
  };

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'weekStart': weekStart.toIso8601String(),
    'weekEnd': weekEnd.toIso8601String(),
    'weekNumber': weekNumber,
    'year': year,
    'totalVolume': totalVolume,
    'avgIntensity': avgIntensity,
    'progressiveOverloadScore': progressiveOverloadScore,
    'previousWeekScore': previousWeekScore,
    'e1RMProgression': e1RMProgression,
    'effectiveVolume': effectiveVolume,
    'bestSet': bestSet?.toMap(),
    'fatigueRatings': fatigueRatings.map((e) => e.toMap()).toList(),
    'avgMuscleEfficiency': avgMuscleEfficiency,
    'createdAt': createdAt.toIso8601String(),
    'syncedAt': syncedAt?.toIso8601String(),
    'isPremiumData': isPremiumData,
  };
}

/// Best set performance of the week
class BestSetPerformance {

  BestSetPerformance({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.e1RM,
    required this.performedAt,
    this.isPR = false,
  });

  factory BestSetPerformance.fromMap(Map<String, dynamic> map) {
    return BestSetPerformance(
      exerciseName: map['exerciseName'] as String,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      e1RM: (map['e1RM'] as num).toDouble(),
      performedAt: DateTime.parse(map['performedAt'] as String),
      isPR: map['isPR'] as bool? ?? false,
    );
  }
  final String exerciseName;
  final double weight;
  final int reps;
  final double e1RM; // Estimated 1 Rep Max
  final DateTime performedAt;
  final bool isPR;

  /// Calculate estimated 1RM using Epley formula
  static double calculateE1RM(double weight, int reps) {
    if (reps == 1) return weight;
    if (reps >= 30) return weight * 1.5; // Cap for high reps
    
    // Epley Formula: 1RM = weight × (1 + reps/30)
    return weight * (1 + reps / 30.0);
  }

  Map<String, dynamic> toMap() => {
    'exerciseName': exerciseName,
    'weight': weight,
    'reps': reps,
    'e1RM': e1RM,
    'performedAt': performedAt.toIso8601String(),
    'isPR': isPR,
  };
}

/// Fatigue entry for a specific day
class FatigueEntry {

  FatigueEntry({
    required this.date,
    required this.fatigueLevel,
    required this.volume,
    required this.muscleEfficiency,
    this.notes,
  });

  factory FatigueEntry.fromMap(Map<String, dynamic> map) {
    return FatigueEntry(
      date: DateTime.parse(map['date'] as String),
      fatigueLevel: map['fatigueLevel'] as int,
      volume: (map['volume'] as num).toDouble(),
      muscleEfficiency: (map['muscleEfficiency'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }
  final DateTime date;
  final int fatigueLevel;
  final double volume;
  final double muscleEfficiency;
  final String? notes;

  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'fatigueLevel': fatigueLevel,
    'volume': volume,
    'muscleEfficiency': muscleEfficiency,
    'notes': notes,
  };
}

/// Effective Volume calculation
class EffectiveVolume {
  /// Calculate effective volume (volume that actually counts for hypertrophy)
  /// Excludes warm-up sets and very light sets
  static double calculate(List<SetData> sets) {
    double effectiveVolume = 0.0;
    
    for (final set in sets) {
      final weight = set.weight;
      final reps = set.reps;
      final rpe = set.rpe ?? 5; // Default RPE if not provided
      
      // Only count sets with RPE >= 6 (close to failure)
      if (rpe >= 6) {
        // Apply effectiveness multiplier based on RPE
        double effectiveness = 1.0;
        if (rpe >= 9) {
          effectiveness = 1.0; // Maximum effectiveness
        } else if (rpe >= 7) {
          effectiveness = 0.85; // Good effectiveness
        } else {
          effectiveness = 0.7; // Moderate effectiveness
        }
        
        effectiveVolume += weight * reps * effectiveness;
      }
    }
    
    return effectiveVolume;
  }
}

/// Placeholder for set data
class SetData {

  SetData({required this.weight, required this.reps, this.rpe});
  final double weight;
  final int reps;
  final int? rpe;
}