import 'dart:math' as math;
import '../entities/smart_suggestion.dart';
import '../entities/smart_training_metrics.dart';
import '../entities/progressive_overload_analysis.dart';
import '../services/progressive_overload_engine.dart';
import '../services/deload_detection_service.dart';
import '../services/plateau_breaker_service.dart';
import '../../workout/domain/entities/workout.dart';
import '../../workout/domain/entities/exercise.dart';

/// Real-time smart suggestions engine
class SmartSuggestionsEngine {
  
  /// Generate contextual suggestions based on current training state
  static List<SmartSuggestion> generateSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    
    // Real-time workout suggestions
    if (context.currentWorkoutId != null) {
      suggestions.addAll(_generateWorkoutSuggestions(context, recentMetrics));
    }
    
    // Exercise-specific suggestions
    if (context.currentExerciseId != null) {
      suggestions.addAll(_generateExerciseSuggestions(context, recentMetrics));
    }
    
    // Set-level suggestions
    if (context.currentSetNumber != null) {
      suggestions.addAll(_generateSetSuggestions(context, recentMetrics));
    }
    
    // Progressive overload suggestions
    suggestions.addAll(_generateProgressionSuggestions(context, recentMetrics));
    
    // Recovery and deload suggestions
    suggestions.addAll(_generateRecoverySuggestions(context, recentMetrics));
    
    // Plateau breaking suggestions
    suggestions.addAll(_generatePlateauSuggestions(context, recentMetrics));
    
    // Motivational and educational suggestions
    suggestions.addAll(_generateMotivationalSuggestions(context, recentMetrics));
    
    // Filter and prioritize suggestions
    return _prioritizeSuggestions(suggestions, context);
  }
  
  /// Generate workout-level suggestions
  static List<SmartSuggestion> _generateWorkoutSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    final sessionData = context.sessionData;
    
    // Session duration optimization
    final elapsedMinutes = sessionData['elapsed_minutes'] as int? ?? 0;
    final estimatedTotalDuration = sessionData['estimated_duration'] as int? ?? 60;
    
    if (elapsedMinutes > estimatedTotalDuration * 1.3) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.workoutRecommendation,
        priority: SuggestionPriority.medium,
        title: 'Workout Running Long',
        description: 'Your session is 30% longer than estimated. Consider reducing rest times or skipping optional exercises.',
        reasoning: 'Extended sessions can lead to fatigue and decreased performance',
        category: SuggestionCategory.performance,
        parameters: {
          'elapsed_minutes': elapsedMinutes,
          'estimated_duration': estimatedTotalDuration,
          'overtime_percentage': ((elapsedMinutes / estimatedTotalDuration) - 1) * 100,
        },
        actions: [
          SuggestionAction(
            label: 'Reduce Rest Times',
            description: 'Cut rest periods by 15-30 seconds',
            type: SuggestionActionType.applyChange,
            payload: {'rest_reduction_seconds': 20},
            isPrimary: true,
          ),
          SuggestionAction(
            label: 'Skip Optional Exercises',
            description: 'Focus on compound movements only',
            type: SuggestionActionType.customizeWorkout,
            payload: {'remove_isolation': true},
          ),
        ],
        confidence: 0.8,
      ));
    }
    
    // Volume accumulation warning
    final currentVolume = sessionData['total_volume'] as double? ?? 0.0;
    final typicalVolume = recentMetrics.isNotEmpty ? 
        recentMetrics.map((m) => m.volume).reduce((a, b) => a + b) / recentMetrics.length : 
        1000.0;
    
    if (currentVolume > typicalVolume * 1.5) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.volumeAdjustment,
        priority: SuggestionPriority.high,
        title: 'High Volume Alert',
        description: 'You\'ve exceeded your typical training volume by 50%. Consider reducing remaining sets.',
        reasoning: 'Excessive volume can impair recovery and increase injury risk',
        category: SuggestionCategory.safety,
        parameters: {
          'current_volume': currentVolume,
          'typical_volume': typicalVolume,
          'excess_percentage': ((currentVolume / typicalVolume) - 1) * 100,
        },
        actions: [
          SuggestionAction(
            label: 'Reduce Remaining Sets',
            description: 'Cut remaining exercises by 1-2 sets each',
            type: SuggestionActionType.applyChange,
            payload: {'set_reduction': 1},
            isPrimary: true,
          ),
        ],
        confidence: 0.85,
      ));
    }
    
    return suggestions;
  }
  
  /// Generate exercise-specific suggestions
  static List<SmartSuggestion> _generateExerciseSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    final sessionData = context.sessionData;
    final exerciseData = sessionData['current_exercise'] as Map<String, dynamic>? ?? {};
    
    final exerciseName = exerciseData['name'] as String?;
    if (exerciseName == null) return suggestions;
    
    // Find historical performance for this exercise
    final historicalPerformance = _getExerciseHistory(exerciseName, recentMetrics);
    
    if (historicalPerformance.isNotEmpty) {
      // Weight progression suggestion
      final lastWeight = historicalPerformance.first.maxWeight;
      final currentWeight = exerciseData['current_weight'] as double? ?? 0.0;
      
      if (currentWeight == lastWeight) {
        final recommendedIncrease = ProgressiveOverloadEngine.calculateOneRM(
          currentWeight, 8
        ) * 0.025; // 2.5% increase
        
        suggestions.add(SmartSuggestion(
          type: SuggestionType.weightIncrease,
          priority: SuggestionPriority.medium,
          title: 'Progressive Overload Opportunity',
          description: 'Consider increasing weight by ${recommendedIncrease.toStringAsFixed(1)}kg based on your recent performance.',
          reasoning: 'You completed all sets last session, indicating readiness for progression',
          category: SuggestionCategory.progression,
          parameters: {
            'current_weight': currentWeight,
            'recommended_increase': recommendedIncrease,
            'exercise_name': exerciseName,
          },
          actions: [
            SuggestionAction(
              label: 'Increase Weight',
              description: 'Add ${recommendedIncrease.toStringAsFixed(1)}kg to current weight',
              type: SuggestionActionType.applyChange,
              payload: {'weight_increase': recommendedIncrease},
              isPrimary: true,
            ),
            SuggestionAction(
              label: 'Keep Current Weight',
              description: 'Focus on adding reps instead',
              type: SuggestionActionType.dismiss,
              payload: {},
            ),
          ],
          confidence: 0.75,
        ));
      }
      
      // Form degradation warning
      final avgRPE = historicalPerformance.first.averageRPE;
      final currentRPE = exerciseData['average_rpe'] as double? ?? 7.0;
      
      if (currentRPE > avgRPE + 1.5) {
        suggestions.add(SmartSuggestion(
          type: SuggestionType.formCorrection,
          priority: SuggestionPriority.high,
          title: 'Form Check Recommended',
          description: 'Your RPE is higher than usual for this weight. Focus on technique.',
          reasoning: 'Elevated RPE with same weight may indicate form breakdown',
          category: SuggestionCategory.safety,
          parameters: {
            'current_rpe': currentRPE,
            'typical_rpe': avgRPE,
            'exercise_name': exerciseName,
          },
          actions: [
            SuggestionAction(
              label: 'Form Tips',
              description: 'View technique reminders for $exerciseName',
              type: SuggestionActionType.learnMore,
              payload: {'exercise_name': exerciseName},
              isPrimary: true,
            ),
            SuggestionAction(
              label: 'Reduce Weight',
              description: 'Drop weight by 10% to focus on form',
              type: SuggestionActionType.applyChange,
              payload: {'weight_reduction': 0.10},
            ),
          ],
          confidence: 0.80,
        ));
      }
    }
    
    return suggestions;
  }
  
  /// Generate set-specific suggestions
  static List<SmartSuggestion> _generateSetSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    final sessionData = context.sessionData;
    final setData = sessionData['current_set'] as Map<String, dynamic>? ?? {};
    
    final setNumber = context.currentSetNumber!;
    final restTime = setData['rest_time_seconds'] as int? ?? 120;
    final targetReps = setData['target_reps'] as int? ?? 8;
    final actualReps = setData['actual_reps'] as int?;
    final rpe = setData['rpe'] as int?;
    
    // Rest time optimization
    if (rpe != null && actualReps != null) {
      int recommendedRest = _calculateOptimalRestTime(rpe, actualReps, targetReps, setNumber);
      
      if ((recommendedRest - restTime).abs() > 30) {
        final adjustment = recommendedRest > restTime ? 'increase' : 'decrease';
        final difference = (recommendedRest - restTime).abs();
        
        suggestions.add(SmartSuggestion(
          type: SuggestionType.restTimeOptimization,
          priority: SuggestionPriority.medium,
          title: 'Rest Time Optimization',
          description: 'Based on your RPE and performance, ${adjustment} rest by ${difference}s for optimal recovery.',
          reasoning: 'Optimized rest times improve performance and training efficiency',
          category: SuggestionCategory.performance,
          parameters: {
            'current_rest': restTime,
            'recommended_rest': recommendedRest,
            'adjustment_type': adjustment,
            'difference_seconds': difference,
          },
          actions: [
            SuggestionAction(
              label: 'Apply Rest Adjustment',
              description: '${adjustment.capitalize()} rest time to ${recommendedRest}s',
              type: SuggestionActionType.applyChange,
              payload: {'new_rest_time': recommendedRest},
              isPrimary: true,
            ),
          ],
          confidence: 0.70,
        ));
      }
    }
    
    // Cluster set suggestion for high RPE
    if (rpe != null && rpe >= 9 && setNumber < 3) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.workoutRecommendation,
        priority: SuggestionPriority.medium,
        title: 'Cluster Set Option',
        description: 'High RPE detected. Consider breaking remaining sets into clusters for better performance.',
        reasoning: 'Cluster sets maintain power output when fatigue is high',
        category: SuggestionCategory.performance,
        parameters: {
          'current_rpe': rpe,
          'remaining_sets': 5 - setNumber,
        },
        actions: [
          SuggestionAction(
            label: 'Use Cluster Sets',
            description: 'Break sets into 3-rep clusters with 15s rest',
            type: SuggestionActionType.applyChange,
            payload: {'cluster_reps': 3, 'micro_rest': 15},
            isPrimary: true,
          ),
        ],
        confidence: 0.65,
      ));
    }
    
    return suggestions;
  }
  
  /// Generate progression-focused suggestions
  static List<SmartSuggestion> _generateProgressionSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    
    if (recentMetrics.length < 3) return suggestions;
    
    // Analyze progression across recent sessions
    final volumeTrend = _calculateVolumeTrend(recentMetrics);
    final intensityTrend = _calculateIntensityTrend(recentMetrics);
    
    // Stagnation detection
    if (volumeTrend.abs() < 0.02 && intensityTrend.abs() < 0.02) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.workoutRecommendation,
        priority: SuggestionPriority.medium,
        title: 'Training Stagnation Detected',
        description: 'Your volume and intensity haven\'t progressed recently. Time to mix things up!',
        reasoning: 'Progressive overload is essential for continued adaptation',
        category: SuggestionCategory.progression,
        parameters: {
          'volume_trend': volumeTrend,
          'intensity_trend': intensityTrend,
          'stagnation_weeks': 2,
        },
        actions: [
          SuggestionAction(
            label: 'Explore New Templates',
            description: 'Try advanced training templates',
            type: SuggestionActionType.startTemplate,
            payload: {'difficulty': 'advanced'},
            isPrimary: true,
          ),
          SuggestionAction(
            label: 'Add Volume',
            description: 'Increase sets on key exercises',
            type: SuggestionActionType.applyChange,
            payload: {'volume_increase': 0.15},
          ),
        ],
        confidence: 0.75,
      ));
    }
    
    return suggestions;
  }
  
  /// Generate recovery-focused suggestions
  static List<SmartSuggestion> _generateRecoverySuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    
    if (recentMetrics.isNotEmpty) {
      final deloadAnalysis = DeloadDetectionService.analyzeDeloadNeed(recentMetrics);
      
      if (deloadAnalysis.needsDeload && deloadAnalysis.confidence > 0.7) {
        suggestions.add(SmartSuggestion(
          type: SuggestionType.deloadRecommendation,
          priority: SuggestionPriority.high,
          title: 'Deload Week Recommended',
          description: 'Multiple fatigue indicators suggest you need a recovery week.',
          reasoning: deloadAnalysis.reasoning,
          category: SuggestionCategory.recovery,
          parameters: {
            'confidence': deloadAnalysis.confidence,
            'deload_type': deloadAnalysis.recommendedDeloadType.name,
            'duration_weeks': deloadAnalysis.estimatedDurationWeeks,
          },
          actions: [
            SuggestionAction(
              label: 'Start Deload',
              description: 'Reduce volume by 40% for ${deloadAnalysis.estimatedDurationWeeks} week(s)',
              type: SuggestionActionType.applyChange,
              payload: {
                'deload_type': deloadAnalysis.recommendedDeloadType.name,
                'duration': deloadAnalysis.estimatedDurationWeeks,
              },
              isPrimary: true,
            ),
            SuggestionAction(
              label: 'Learn About Deloading',
              description: 'Understand the science of deload weeks',
              type: SuggestionActionType.learnMore,
              payload: {'topic': 'deload'},
            ),
          ],
          confidence: deloadAnalysis.confidence,
        ));
      }
    }
    
    return suggestions;
  }
  
  /// Generate plateau-breaking suggestions
  static List<SmartSuggestion> _generatePlateauSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    
    // Check for plateaus in key exercises
    final keyExercises = ['Squat', 'Bench Press', 'Deadlift', 'Overhead Press'];
    
    for (final exercise in keyExercises) {
      final plateauDetection = PlateauBreakerService.detectPlateau(exercise, recentMetrics);
      
      if (plateauDetection.isPlateaued && plateauDetection.confidenceScore > 0.6) {
        final primaryStrategy = plateauDetection.recommendations.isNotEmpty ? 
            plateauDetection.recommendations.first : null;
        
        if (primaryStrategy != null) {
          suggestions.add(SmartSuggestion(
            type: SuggestionType.plateauBreaker,
            priority: SuggestionPriority.medium,
            title: 'Plateau Detected: $exercise',
            description: 'Try ${primaryStrategy.strategy} to break through your plateau.',
            reasoning: 'You\'ve plateaued for ${plateauDetection.plateauWeeks} weeks',
            category: SuggestionCategory.progression,
            parameters: {
              'exercise': exercise,
              'plateau_weeks': plateauDetection.plateauWeeks,
              'strategy': primaryStrategy.strategy,
              'confidence': plateauDetection.confidenceScore,
            },
            actions: [
              SuggestionAction(
                label: 'Apply Strategy',
                description: primaryStrategy.description,
                type: SuggestionActionType.applyChange,
                payload: primaryStrategy.implementation,
                isPrimary: true,
              ),
              SuggestionAction(
                label: 'View All Options',
                description: 'See all plateau-breaking strategies',
                type: SuggestionActionType.viewDetails,
                payload: {'exercise': exercise},
              ),
            ],
            confidence: plateauDetection.confidenceScore,
          ));
        }
      }
    }
    
    return suggestions;
  }
  
  /// Generate motivational and educational suggestions
  static List<SmartSuggestion> _generateMotivationalSuggestions(
    SuggestionContext context,
    List<SmartTrainingMetrics> recentMetrics,
  ) {
    final suggestions = <SmartSuggestion>[];
    
    // Progress celebration
    if (recentMetrics.length >= 2) {
      final latest = recentMetrics.first;
      final previous = recentMetrics[1];
      
      final volumeIncrease = (latest.volume - previous.volume) / previous.volume;
      
      if (volumeIncrease > 0.1) {
        suggestions.add(SmartSuggestion(
          type: SuggestionType.progressCelebration,
          priority: SuggestionPriority.low,
          title: 'Great Progress!',
          description: 'You increased your training volume by ${(volumeIncrease * 100).toStringAsFixed(1)}% since last session.',
          reasoning: 'Celebrating progress maintains motivation and adherence',
          category: SuggestionCategory.motivation,
          parameters: {
            'volume_increase_percent': volumeIncrease * 100,
            'new_volume': latest.volume,
          },
          actions: [
            SuggestionAction(
              label: 'View Progress Chart',
              description: 'See your training progression over time',
              type: SuggestionActionType.viewDetails,
              payload: {'chart_type': 'volume_progression'},
              isPrimary: true,
            ),
          ],
          confidence: 1.0,
        ));
      }
    }
    
    // Educational tips
    final random = math.Random();
    if (random.nextDouble() < 0.3) { // 30% chance for educational tip
      final tips = [
        {
          'title': 'RPE Scale Tip',
          'description': 'RPE 7 = 3 reps in reserve, RPE 8 = 2 reps in reserve, RPE 9 = 1 rep in reserve.',
          'category': 'education',
        },
        {
          'title': 'Compound Movement Focus',
          'description': 'Prioritize squats, deadlifts, and presses for maximum strength and muscle gains.',
          'category': 'training',
        },
        {
          'title': 'Recovery Importance',
          'description': 'Muscle growth happens during rest. Aim for 7-9 hours of quality sleep.',
          'category': 'recovery',
        },
      ];
      
      final tip = tips[random.nextInt(tips.length)];
      
      suggestions.add(SmartSuggestion(
        type: SuggestionType.nutritionTip,
        priority: SuggestionPriority.low,
        title: tip['title'] as String,
        description: tip['description'] as String,
        reasoning: 'Knowledge is power in fitness',
        category: SuggestionCategory.education,
        parameters: {'tip_category': tip['category']},
        actions: [
          SuggestionAction(
            label: 'Learn More',
            description: 'Explore related topics',
            type: SuggestionActionType.learnMore,
            payload: {'category': tip['category']},
            isPrimary: true,
          ),
        ],
        confidence: 1.0,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ));
    }
    
    return suggestions;
  }
  
  /// Prioritize and filter suggestions
  static List<SmartSuggestion> _prioritizeSuggestions(
    List<SmartSuggestion> suggestions,
    SuggestionContext context,
  ) {
    // Filter out dismissed or applied suggestions
    var filtered = suggestions.where((s) => s.isValid).toList();
    
    // Sort by priority and confidence
    filtered.sort((a, b) {
      final priorityComparison = _getPriorityValue(b.priority)
          .compareTo(_getPriorityValue(a.priority));
      if (priorityComparison != 0) return priorityComparison;
      
      return b.confidence.compareTo(a.confidence);
    });
    
    // Limit to top 5 suggestions to avoid overwhelming user
    return filtered.take(5).toList();
  }
  
  /// Helper methods
  static int _getPriorityValue(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.critical: return 4;
      case SuggestionPriority.high: return 3;
      case SuggestionPriority.medium: return 2;
      case SuggestionPriority.low: return 1;
    }
  }
  
  static List<ExerciseMetrics> _getExerciseHistory(
    String exerciseName,
    List<SmartTrainingMetrics> metrics,
  ) {
    return metrics
        .expand((m) => m.exerciseMetrics)
        .where((e) => e.exerciseName == exerciseName)
        .toList();
  }
  
  static double _calculateVolumeTrend(List<SmartTrainingMetrics> metrics) {
    if (metrics.length < 2) return 0.0;
    
    final recent = metrics.take(2).map((m) => m.volume).reduce((a, b) => a + b) / 2;
    final previous = metrics.skip(2).take(2).map((m) => m.volume).reduce((a, b) => a + b) / 2;
    
    return previous > 0 ? (recent - previous) / previous : 0.0;
  }
  
  static double _calculateIntensityTrend(List<SmartTrainingMetrics> metrics) {
    if (metrics.length < 2) return 0.0;
    
    final recent = metrics.take(2).map((m) => m.averageIntensity).reduce((a, b) => a + b) / 2;
    final previous = metrics.skip(2).take(2).map((m) => m.averageIntensity).reduce((a, b) => a + b) / 2;
    
    return previous > 0 ? (recent - previous) / previous : 0.0;
  }
  
  static int _calculateOptimalRestTime(int rpe, int actualReps, int targetReps, int setNumber) {
    // Base rest time calculation
    int baseRest = 120; // 2 minutes default
    
    // Adjust for RPE
    if (rpe >= 9) baseRest += 60;
    else if (rpe >= 8) baseRest += 30;
    else if (rpe <= 6) baseRest -= 30;
    
    // Adjust for rep performance
    if (actualReps < targetReps) baseRest += 30;
    else if (actualReps > targetReps) baseRest -= 15;
    
    // Adjust for set number (later sets need more rest)
    baseRest += (setNumber - 1) * 15;
    
    return baseRest.clamp(60, 300); // 1-5 minutes range
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}