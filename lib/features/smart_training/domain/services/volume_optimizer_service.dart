import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_training_metrics.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_workout_template.dart';

/// Service for optimizing training volume based on scientific principles
class VolumeOptimizerService {
  
  /// Calculate optimal volume recommendations
  static VolumeOptimization optimizeVolume(
    String userId,
    TrainingGoal goal,
    TrainingExperience experience,
    List<SmartTrainingMetrics> recentMetrics,
    Map<String, MuscleGroupData> currentVolumes,
  ) {
    final recommendations = <String, VolumeRecommendation>{};
    
    for (final entry in currentVolumes.entries) {
      final muscleGroup = entry.key;
      final data = entry.value;
      
      final recommendation = _calculateMuscleGroupVolume(
        muscleGroup,
        goal,
        experience,
        data,
        recentMetrics,
      );
      
      recommendations[muscleGroup] = recommendation;
    }
    
    return VolumeOptimization(
      userId: userId,
      goal: goal,
      experience: experience,
      recommendations: recommendations,
      totalWeeklyVolume: _calculateTotalVolume(recommendations),
      analysisDate: DateTime.now(),
    );
  }
  
  /// Calculate volume recommendation for specific muscle group
  static VolumeRecommendation _calculateMuscleGroupVolume(
    String muscleGroup,
    TrainingGoal goal,
    TrainingExperience experience,
    MuscleGroupData currentData,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    // Get evidence-based volume ranges
    final ranges = _getVolumeRanges(muscleGroup, goal, experience);
    
    // Analyze current performance
    final analysis = _analyzeVolumePerformance(muscleGroup, recentMetrics);
    
    // Calculate optimal volume
    final optimalVolume = _calculateOptimalVolume(
      currentData.weeklyVolume,
      ranges,
      analysis,
      goal,
    );
    
    // Generate specific recommendations
    final adjustments = _generateVolumeAdjustments(
      currentData.weeklyVolume,
      optimalVolume,
      analysis,
    );
    
    return VolumeRecommendation(
      muscleGroup: muscleGroup,
      currentVolume: currentData.weeklyVolume,
      optimalVolume: optimalVolume,
      volumeRange: ranges,
      adjustments: adjustments,
      reasoning: _generateReasoning(muscleGroup, analysis, adjustments),
      confidence: _calculateConfidence(analysis, currentData),
    );
  }
  
  /// Get evidence-based volume ranges for muscle group
  static VolumeRange _getVolumeRanges(
    String muscleGroup,
    TrainingGoal goal,
    TrainingExperience experience,
  ) {
    // Base volume ranges (sets per week) from research
    const Map<String, Map<TrainingGoal, VolumeRange>> baseRanges = {
      'chest': {
        TrainingGoal.hypertrophy: VolumeRange(min: 8, optimal: 14, max: 22),
        TrainingGoal.strength: VolumeRange(min: 6, optimal: 10, max: 16),
        TrainingGoal.endurance: VolumeRange(min: 12, optimal: 18, max: 25),
        TrainingGoal.maintenance: VolumeRange(min: 6, optimal: 10, max: 14),
      },
      'back': {
        TrainingGoal.hypertrophy: VolumeRange(min: 10, optimal: 16, max: 24),
        TrainingGoal.strength: VolumeRange(min: 8, optimal: 12, max: 18),
        TrainingGoal.endurance: VolumeRange(min: 14, optimal: 20, max: 28),
        TrainingGoal.maintenance: VolumeRange(min: 8, optimal: 12, max: 16),
      },
      'shoulders': {
        TrainingGoal.hypertrophy: VolumeRange(min: 8, optimal: 12, max: 20),
        TrainingGoal.strength: VolumeRange(min: 6, optimal: 10, max: 14),
        TrainingGoal.endurance: VolumeRange(min: 10, optimal: 16, max: 22),
        TrainingGoal.maintenance: VolumeRange(min: 6, optimal: 10, max: 14),
      },
      'arms': {
        TrainingGoal.hypertrophy: VolumeRange(min: 6, optimal: 10, max: 16),
        TrainingGoal.strength: VolumeRange(min: 4, optimal: 8, max: 12),
        TrainingGoal.endurance: VolumeRange(min: 8, optimal: 14, max: 20),
        TrainingGoal.maintenance: VolumeRange(min: 4, optimal: 8, max: 12),
      },
      'legs': {
        TrainingGoal.hypertrophy: VolumeRange(min: 12, optimal: 18, max: 26),
        TrainingGoal.strength: VolumeRange(min: 8, optimal: 14, max: 20),
        TrainingGoal.endurance: VolumeRange(min: 16, optimal: 22, max: 30),
        TrainingGoal.maintenance: VolumeRange(min: 10, optimal: 14, max: 18),
      },
    };
    
    var range = baseRanges[muscleGroup]?[goal] ?? 
                 const VolumeRange(min: 6, optimal: 10, max: 16);
    
    // Adjust for experience level
    final experienceMultiplier = _getExperienceMultiplier(experience);
    range = VolumeRange(
      min: (range.min * experienceMultiplier.min).round(),
      optimal: (range.optimal * experienceMultiplier.optimal).round(),
      max: (range.max * experienceMultiplier.max).round(),
    );
    
    return range;
  }
  
  /// Get experience-based volume multipliers
  static ExperienceMultiplier _getExperienceMultiplier(TrainingExperience experience) {
    switch (experience) {
      case TrainingExperience.beginner:
        return const ExperienceMultiplier(min: 0.7, optimal: 0.8, max: 0.9);
      case TrainingExperience.intermediate:
        return const ExperienceMultiplier(min: 1.0, optimal: 1.0, max: 1.0);
      case TrainingExperience.advanced:
        return const ExperienceMultiplier(min: 1.1, optimal: 1.2, max: 1.3);
      case TrainingExperience.expert:
        return const ExperienceMultiplier(min: 1.2, optimal: 1.3, max: 1.4);
    }
  }
  
  /// Analyze volume performance indicators
  static VolumePerformanceAnalysis _analyzeVolumePerformance(
    String muscleGroup,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    if (recentMetrics.length < 3) {
      return VolumePerformanceAnalysis(
        volumeTrend: 0.0,
        performanceTrend: 0.0,
        fatigueLevel: 5.0,
        readinessLevel: 7.0,
        adaptationRate: 0.5,
        sustainabilityScore: 0.7,
      );
    }
    
    // Extract muscle group specific data
    final volumes = recentMetrics
        .map((m) => m.muscleGroupVolume[muscleGroup] ?? 0.0)
        .toList();
    
    final fatigueScores = recentMetrics.map((m) => m.fatigueScore).toList();
    final readinessScores = recentMetrics.map((m) => m.readinessScore).toList();
    
    // Calculate trends
    final volumeTrend = _calculateTrend(volumes);
    final performanceTrend = _calculatePerformanceTrend(recentMetrics, muscleGroup);
    
    // Current levels
    final avgFatigue = fatigueScores.take(2).reduce((a, b) => a + b) / 2;
    final avgReadiness = readinessScores.take(2).reduce((a, b) => a + b) / 2;
    
    // Calculate adaptation and sustainability
    final adaptationRate = _calculateAdaptationRate(volumes, performanceTrend);
    final sustainabilityScore = _calculateSustainabilityScore(avgFatigue, avgReadiness, volumeTrend);
    
    return VolumePerformanceAnalysis(
      volumeTrend: volumeTrend,
      performanceTrend: performanceTrend,
      fatigueLevel: avgFatigue,
      readinessLevel: avgReadiness,
      adaptationRate: adaptationRate,
      sustainabilityScore: sustainabilityScore,
    );
  }
  
  /// Calculate trend from data points
  static double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final recent = values.take(2).reduce((a, b) => a + b) / 2;
    final previous = values.skip(2).take(2).reduce((a, b) => a + b) / 2;
    
    return previous > 0 ? (recent - previous) / previous : 0.0;
  }
  
  /// Calculate performance trend for muscle group
  static double _calculatePerformanceTrend(
    List<SmartTrainingMetrics> metrics,
    String muscleGroup,
  ) {
    final recentPerf = _calculateMuscleGroupPerformance(metrics.first, muscleGroup);
    final previousPerf = metrics.length > 2 ? 
        _calculateMuscleGroupPerformance(metrics[2], muscleGroup) : recentPerf;
    
    return previousPerf > 0 ? (recentPerf - previousPerf) / previousPerf : 0.0;
  }
  
  /// Calculate muscle group performance score
  static double _calculateMuscleGroupPerformance(
    SmartTrainingMetrics metric,
    String muscleGroup,
  ) {
    final muscleGroupExercises = metric.exerciseMetrics
        .where((e) => _belongsToMuscleGroup(e.category, muscleGroup))
        .toList();
    
    if (muscleGroupExercises.isEmpty) return 0.0;
    
    // Weighted performance based on volume and intensity
    double totalPerformance = 0.0;
    double totalWeight = 0.0;
    
    for (final exercise in muscleGroupExercises) {
      final performance = exercise.estimatedOneRM * exercise.intensityScore;
      final weight = exercise.volume;
      
      totalPerformance += performance * weight;
      totalWeight += weight;
    }
    
    return totalWeight > 0 ? totalPerformance / totalWeight : 0.0;
  }
  
  /// Check if exercise category belongs to muscle group
  static bool _belongsToMuscleGroup(String category, String muscleGroup) {
    const Map<String, List<String>> muscleGroupMapping = {
      'chest': ['chest'],
      'back': ['back'],
      'shoulders': ['shoulders'],
      'arms': ['arms'],
      'legs': ['legs'],
    };
    
    return muscleGroupMapping[muscleGroup]?.contains(category) ?? false;
  }
  
  /// Calculate adaptation rate
  static double _calculateAdaptationRate(List<double> volumes, double performanceTrend) {
    if (volumes.isEmpty) return 0.5;
    
    final volumeStability = 1.0 - (_calculateVariability(volumes) / 0.5).clamp(0.0, 1.0);
    final performanceComponent = (performanceTrend + 0.1) / 0.2; // Normalize to 0-1
    
    return (volumeStability * 0.6 + performanceComponent * 0.4).clamp(0.0, 1.0);
  }
  
  /// Calculate volume variability
  static double _calculateVariability(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    
    return mean > 0 ? math.sqrt(variance) / mean : 0.0;
  }
  
  /// Calculate sustainability score
  static double _calculateSustainabilityScore(
    double fatigue,
    double readiness,
    double volumeTrend,
  ) {
    final fatigueScore = (10 - fatigue) / 10; // Invert fatigue (lower is better)
    final readinessScore = readiness / 10;
    final trendScore = volumeTrend < 0 ? 0.5 : (1.0 + volumeTrend).clamp(0.0, 1.0);
    
    return (fatigueScore * 0.4 + readinessScore * 0.4 + trendScore * 0.2).clamp(0.0, 1.0);
  }
  
  /// Calculate optimal volume
  static int _calculateOptimalVolume(
    double currentVolume,
    VolumeRange range,
    VolumePerformanceAnalysis analysis,
    TrainingGoal goal,
  ) {
    // Start with evidence-based optimal
    double optimal = range.optimal.toDouble();
    
    // Adjust based on current performance
    if (analysis.performanceTrend > 0.05) {
      // Good progress, can handle more volume
      optimal *= 1.1;
    } else if (analysis.performanceTrend < -0.05) {
      // Poor progress, reduce volume
      optimal *= 0.9;
    }
    
    // Adjust based on fatigue and readiness
    final recoveryScore = (analysis.readinessLevel - analysis.fatigueLevel + 10) / 20;
    if (recoveryScore > 0.7) {
      optimal *= 1.05;
    } else if (recoveryScore < 0.4) {
      optimal *= 0.85;
    }
    
    // Adjust based on adaptation rate
    if (analysis.adaptationRate > 0.7) {
      optimal *= 1.1;
    } else if (analysis.adaptationRate < 0.3) {
      optimal *= 0.9;
    }
    
    // Constrain to range
    return optimal.round().clamp(range.min, range.max);
  }
  
  /// Generate volume adjustments
  static List<VolumeAdjustment> _generateVolumeAdjustments(
    double currentVolume,
    int optimalVolume,
    VolumePerformanceAnalysis analysis,
  ) {
    final adjustments = <VolumeAdjustment>[];
    final difference = optimalVolume - currentVolume;
    
    if (difference.abs() < 1) {
      adjustments.add(VolumeAdjustment(
        type: VolumeAdjustmentType.maintain,
        description: 'Maintain current volume',
        setChange: 0,
        implementation: 'Continue current training approach',
        priority: 1,
      ));
    } else if (difference > 0) {
      // Need to increase volume
      adjustments.add(VolumeAdjustment(
        type: VolumeAdjustmentType.increase,
        description: 'Gradually increase volume',
        setChange: difference.round(),
        implementation: _getVolumeIncreaseStrategy(difference, analysis),
        priority: 1,
      ));
    } else {
      // Need to decrease volume
      adjustments.add(VolumeAdjustment(
        type: VolumeAdjustmentType.decrease,
        description: 'Reduce volume for recovery',
        setChange: difference.round(),
        implementation: _getVolumeDecreaseStrategy(difference.abs(), analysis),
        priority: 1,
      ));
    }
    
    return adjustments;
  }
  
  /// Get volume increase strategy
  static String _getVolumeIncreaseStrategy(double increase, VolumePerformanceAnalysis analysis) {
    if (increase <= 2) {
      return 'Add 1 set per exercise over 2 weeks';
    } else if (increase <= 4) {
      return 'Add 1-2 sets per session, spread over 3 weeks';
    } else {
      return 'Add new exercise or increase frequency over 4 weeks';
    }
  }
  
  /// Get volume decrease strategy
  static String _getVolumeDecreaseStrategy(double decrease, VolumePerformanceAnalysis analysis) {
    if (analysis.fatigueLevel > 7.5) {
      return 'Immediate volume reduction for recovery';
    } else if (decrease <= 2) {
      return 'Remove 1 set from least productive exercise';
    } else {
      return 'Reduce sets across all exercises by 20-30%';
    }
  }
  
  /// Generate reasoning text
  static String _generateReasoning(
    String muscleGroup,
    VolumePerformanceAnalysis analysis,
    List<VolumeAdjustment> adjustments,
  ) {
    final buffer = StringBuffer();
    
    buffer.write('$muscleGroup analysis: ');
    
    if (analysis.performanceTrend > 0.05) {
      buffer.write('Good progress trend. ');
    } else if (analysis.performanceTrend < -0.05) {
      buffer.write('Performance declining. ');
    } else {
      buffer.write('Stable performance. ');
    }
    
    if (analysis.fatigueLevel > 7.5) {
      buffer.write('High fatigue detected. ');
    } else if (analysis.readinessLevel < 6.0) {
      buffer.write('Low readiness. ');
    }
    
    if (adjustments.isNotEmpty) {
      buffer.write(adjustments.first.description);
    }
    
    return buffer.toString();
  }
  
  /// Calculate confidence score
  static double _calculateConfidence(
    VolumePerformanceAnalysis analysis,
    MuscleGroupData currentData,
  ) {
    double confidence = 0.7; // Base confidence
    
    // More data = higher confidence
    if (currentData.weeksOfData >= 4) confidence += 0.1;
    if (currentData.weeksOfData >= 8) confidence += 0.1;
    
    // Stable trends = higher confidence
    if (analysis.sustainabilityScore > 0.7) confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }
  
  /// Calculate total weekly volume
  static int _calculateTotalVolume(Map<String, VolumeRecommendation> recommendations) {
    return recommendations.values
        .map((r) => r.optimalVolume)
        .fold(0, (total, volume) => total + volume);
  }
}

/// Volume optimization results
class VolumeOptimization {

  VolumeOptimization({
    required this.userId,
    required this.goal,
    required this.experience,
    required this.recommendations,
    required this.totalWeeklyVolume,
    required this.analysisDate,
  });

  factory VolumeOptimization.fromJson(Map<String, dynamic> json) {
    return VolumeOptimization(
      userId: json['userId'],
      goal: TrainingGoal.values.firstWhere((g) => g.name == json['goal']),
      experience: TrainingExperience.values.firstWhere((e) => e.name == json['experience']),
      recommendations: (json['recommendations'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, VolumeRecommendation.fromJson(v))),
      totalWeeklyVolume: json['totalWeeklyVolume'],
      analysisDate: DateTime.parse(json['analysisDate']),
    );
  }
  final String userId;
  final TrainingGoal goal;
  final TrainingExperience experience;
  final Map<String, VolumeRecommendation> recommendations;
  final int totalWeeklyVolume;
  final DateTime analysisDate;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'goal': goal.name,
      'experience': experience.name,
      'recommendations': recommendations.map((k, v) => MapEntry(k, v.toJson())),
      'totalWeeklyVolume': totalWeeklyVolume,
      'analysisDate': analysisDate.toIso8601String(),
    };
  }
}

/// Volume recommendation for specific muscle group
class VolumeRecommendation {

  VolumeRecommendation({
    required this.muscleGroup,
    required this.currentVolume,
    required this.optimalVolume,
    required this.volumeRange,
    required this.adjustments,
    required this.reasoning,
    required this.confidence,
  });

  factory VolumeRecommendation.fromJson(Map<String, dynamic> json) {
    return VolumeRecommendation(
      muscleGroup: json['muscleGroup'],
      currentVolume: (json['currentVolume'] as num).toDouble(),
      optimalVolume: json['optimalVolume'],
      volumeRange: VolumeRange.fromJson(json['volumeRange']),
      adjustments: (json['adjustments'] as List)
          .map((a) => VolumeAdjustment.fromJson(a))
          .toList(),
      reasoning: json['reasoning'],
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
  final String muscleGroup;
  final double currentVolume;
  final int optimalVolume;
  final VolumeRange volumeRange;
  final List<VolumeAdjustment> adjustments;
  final String reasoning;
  final double confidence;

  Map<String, dynamic> toJson() {
    return {
      'muscleGroup': muscleGroup,
      'currentVolume': currentVolume,
      'optimalVolume': optimalVolume,
      'volumeRange': volumeRange.toJson(),
      'adjustments': adjustments.map((a) => a.toJson()).toList(),
      'reasoning': reasoning,
      'confidence': confidence,
    };
  }
}

/// Supporting classes and enums
class VolumeRange {

  const VolumeRange({required this.min, required this.optimal, required this.max});

  factory VolumeRange.fromJson(Map<String, dynamic> json) {
    return VolumeRange(
      min: json['min'],
      optimal: json['optimal'],
      max: json['max'],
    );
  }
  final int min;
  final int optimal;
  final int max;

  Map<String, dynamic> toJson() => {'min': min, 'optimal': optimal, 'max': max};
}

class ExperienceMultiplier {

  const ExperienceMultiplier({required this.min, required this.optimal, required this.max});
  final double min;
  final double optimal;
  final double max;
}

class VolumePerformanceAnalysis {

  VolumePerformanceAnalysis({
    required this.volumeTrend,
    required this.performanceTrend,
    required this.fatigueLevel,
    required this.readinessLevel,
    required this.adaptationRate,
    required this.sustainabilityScore,
  });
  final double volumeTrend;
  final double performanceTrend;
  final double fatigueLevel;
  final double readinessLevel;
  final double adaptationRate;
  final double sustainabilityScore;
}

class VolumeAdjustment {

  VolumeAdjustment({
    required this.type,
    required this.description,
    required this.setChange,
    required this.implementation,
    required this.priority,
  });

  factory VolumeAdjustment.fromJson(Map<String, dynamic> json) {
    return VolumeAdjustment(
      type: VolumeAdjustmentType.values.firstWhere((t) => t.name == json['type']),
      description: json['description'],
      setChange: json['setChange'],
      implementation: json['implementation'],
      priority: json['priority'],
    );
  }
  final VolumeAdjustmentType type;
  final String description;
  final int setChange;
  final String implementation;
  final int priority;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
      'setChange': setChange,
      'implementation': implementation,
      'priority': priority,
    };
  }
}

class MuscleGroupData {

  MuscleGroupData({
    required this.weeklyVolume,
    required this.weeksOfData,
    required this.averageIntensity,
  });
  final double weeklyVolume;
  final int weeksOfData;
  final double averageIntensity;
}

enum TrainingGoal { hypertrophy, strength, endurance, maintenance }
// TrainingExperience moved to shared location in smart_workout_template.dart
enum VolumeAdjustmentType { increase, decrease, maintain }