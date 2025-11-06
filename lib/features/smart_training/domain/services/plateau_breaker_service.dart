import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_training_metrics.dart';
import 'package:gymbro_flutter_new/features/smart_training/domain/entities/progressive_overload_analysis.dart';

/// Service for detecting plateaus and providing breakthrough strategies
class PlateauBreakerService {
  
  /// Detect plateau and generate breaking strategies
  static PlateauDetection detectPlateau(
    String exerciseName,
    List<SmartTrainingMetrics> recentMetrics,
    {int analysisWeeks = 6}
  ) {
    if (recentMetrics.length < analysisWeeks) {
      return PlateauDetection(
        isPlateaued: false,
        plateauWeeks: 0,
        type: PlateauType.volume,
        confidenceScore: 0.0,
        indicators: [],
        recommendations: [],
      );
    }
    
    final analysisMetrics = recentMetrics.take(analysisWeeks).toList();
    final indicators = _calculatePlateauIndicators(exerciseName, analysisMetrics);
    
    // Determine plateau type and confidence
    final plateauType = _determinePlateauType(indicators);
    final isPlateaued = indicators.any((i) => i.isTriggered);
    final confidenceScore = _calculateConfidenceScore(indicators);
    final plateauWeeks = _calculatePlateauDuration(analysisMetrics);
    
    // Generate breakthrough strategies
    final recommendations = isPlateaued ? 
        _generateBreakthroughStrategies(plateauType, exerciseName, plateauWeeks) : 
        <PlateauBreaker>[];
    
    return PlateauDetection(
      isPlateaued: isPlateaued,
      plateauWeeks: plateauWeeks,
      type: plateauType,
      confidenceScore: confidenceScore,
      indicators: indicators,
      recommendations: recommendations,
    );
  }
  
  /// Calculate various plateau indicators
  static List<PlateauIndicator> _calculatePlateauIndicators(
    String exerciseName,
    List<SmartTrainingMetrics> metrics
  ) {
    final indicators = <PlateauIndicator>[];
    
    // Extract exercise-specific metrics
    final exerciseMetrics = metrics
        .map((m) => m.exerciseMetrics.where((e) => e.exerciseName == exerciseName).firstOrNull)
        .where((e) => e != null)
        .cast<ExerciseMetrics>()
        .toList();
    
    if (exerciseMetrics.length < 4) return indicators;
    
    // 1. Volume Stagnation
    final volumeIndicator = _analyzeVolumeStagnation(exerciseMetrics);
    if (volumeIndicator != null) indicators.add(volumeIndicator);
    
    // 2. Strength Plateau
    final strengthIndicator = _analyzeStrengthPlateau(exerciseMetrics);
    if (strengthIndicator != null) indicators.add(strengthIndicator);
    
    // 3. Load Progression Stall
    final loadIndicator = _analyzeLoadProgression(exerciseMetrics);
    if (loadIndicator != null) indicators.add(loadIndicator);
    
    // 4. RPE Ceiling
    final rpeIndicator = _analyzeRPECeiling(exerciseMetrics);
    if (rpeIndicator != null) indicators.add(rpeIndicator);
    
    // 5. Technique Degradation
    final techniqueIndicator = _analyzeTechniqueRegression(exerciseMetrics);
    if (techniqueIndicator != null) indicators.add(techniqueIndicator);
    
    return indicators;
  }
  
  /// Analyze volume stagnation over time
  static PlateauIndicator? _analyzeVolumeStagnation(List<ExerciseMetrics> metrics) {
    final volumes = metrics.map((m) => m.volume).toList();
    final recentVolume = volumes.take(2).reduce((a, b) => a + b) / 2;
    final previousVolume = volumes.skip(2).take(2).reduce((a, b) => a + b) / 2;
    
    final volumeChange = (recentVolume - previousVolume) / previousVolume;
    const threshold = 0.02; // 2% improvement threshold
    
    return PlateauIndicator(
      name: 'Volume Stagnation',
      value: volumeChange * 100,
      threshold: threshold * 100,
      isTriggered: volumeChange < threshold,
      description: 'Training volume has not progressed in recent sessions',
    );
  }
  
  /// Analyze strength plateau (1RM estimates)
  static PlateauIndicator? _analyzeStrengthPlateau(List<ExerciseMetrics> metrics) {
    final oneRMs = metrics.map((m) => m.estimatedOneRM).toList();
    final recentOneRM = oneRMs.take(2).reduce((a, b) => math.max(a, b));
    final previousOneRM = oneRMs.skip(2).take(2).reduce((a, b) => math.max(a, b));
    
    final strengthChange = (recentOneRM - previousOneRM) / previousOneRM;
    const threshold = 0.01; // 1% strength improvement threshold
    
    return PlateauIndicator(
      name: 'Strength Plateau',
      value: strengthChange * 100,
      threshold: threshold * 100,
      isTriggered: strengthChange < threshold,
      description: 'Estimated 1RM has not improved in recent sessions',
    );
  }
  
  /// Analyze load progression patterns
  static PlateauIndicator? _analyzeLoadProgression(List<ExerciseMetrics> metrics) {
    final maxWeights = metrics.map((m) => m.maxWeight).toList();
    
    // Check if max weight has increased in last 4 sessions
    final hasProgressed = maxWeights.take(4).any((w) =>
        (w ?? 0) > (maxWeights.skip(4).firstOrNull ?? 0));
    
    final recentMax = maxWeights.first;
    final oldMax = maxWeights.length > 4 ? maxWeights[4] : maxWeights.last;
    final weightChange = (recentMax - oldMax) / oldMax;
    
    return PlateauIndicator(
      name: 'Load Progression Stall',
      value: weightChange * 100,
      threshold: 0.0,
      isTriggered: !hasProgressed,
      description: 'Maximum weight used has not increased',
    );
  }
  
  /// Analyze RPE ceiling issues
  static PlateauIndicator? _analyzeRPECeiling(List<ExerciseMetrics> metrics) {
    final avgRPEs = metrics.map((m) => m.averageRPE).toList();
    final recentRPE = avgRPEs.take(2).reduce((a, b) => a + b) / 2;
    
    const threshold = 8.5; // High RPE threshold
    
    return PlateauIndicator(
      name: 'RPE Ceiling',
      value: recentRPE,
      threshold: threshold,
      isTriggered: recentRPE >= threshold,
      description: 'Training at consistently high RPE with no load progression',
    );
  }
  
  /// Analyze technique regression indicators
  static PlateauIndicator? _analyzeTechniqueRegression(List<ExerciseMetrics> metrics) {
    // Proxy: Increasing RPE with same or decreasing weight
    final recentMetric = metrics.first;
    final previousMetric = metrics.length > 2 ? metrics[2] : metrics.last;
    
    final rpeIncrease = recentMetric.averageRPE - previousMetric.averageRPE;
    final weightChange = (recentMetric.maxWeight - previousMetric.maxWeight) / previousMetric.maxWeight;
    
    // Technique issues if RPE increased while weight stayed same or decreased
    final techniqueIssue = rpeIncrease > 0.5 && weightChange <= 0.02;
    
    return PlateauIndicator(
      name: 'Technique Regression',
      value: rpeIncrease,
      threshold: 0.5,
      isTriggered: techniqueIssue,
      description: 'RPE increasing without corresponding load increases',
    );
  }
  
  /// Determine primary plateau type
  static PlateauType _determinePlateauType(List<PlateauIndicator> indicators) {
    final triggeredIndicators = indicators.where((i) => i.isTriggered).toList();
    
    if (triggeredIndicators.isEmpty) return PlateauType.volume;
    
    // Prioritize by impact
    for (final indicator in triggeredIndicators) {
      switch (indicator.name) {
        case 'Strength Plateau':
          return PlateauType.strength;
        case 'Technique Regression':
          return PlateauType.technique;
        case 'RPE Ceiling':
          return PlateauType.recovery;
        case 'Load Progression Stall':
          return PlateauType.intensity;
        case 'Volume Stagnation':
          return PlateauType.volume;
      }
    }
    
    return PlateauType.volume;
  }
  
  /// Calculate confidence score for plateau detection
  static double _calculateConfidenceScore(List<PlateauIndicator> indicators) {
    if (indicators.isEmpty) return 0.0;
    
    final triggeredCount = indicators.where((i) => i.isTriggered).length;
    final baseConfidence = triggeredCount / indicators.length;
    
    // Boost confidence for multiple triggered indicators
    final multiplier = 1.0 + (triggeredCount - 1) * 0.2;
    
    return (baseConfidence * multiplier).clamp(0.0, 1.0);
  }
  
  /// Calculate plateau duration in weeks
  static int _calculatePlateauDuration(List<SmartTrainingMetrics> metrics) {
    if (metrics.length < 2) return 0;
    
    // Simple approach: count sessions without improvement
    int plateauSessions = 0;
    double? previousBest;
    
    for (final metric in metrics.reversed) {
      final currentVolume = metric.volume;
      
      if (previousBest != null && currentVolume <= previousBest * 1.02) {
        plateauSessions++;
      } else {
        plateauSessions = 0; // Reset if improvement found
        previousBest = currentVolume;
      }
    }
    
    // Convert sessions to weeks (assuming 1-2 sessions per week)
    return (plateauSessions / 1.5).ceil();
  }
  
  /// Generate breakthrough strategies based on plateau type
  static List<PlateauBreaker> _generateBreakthroughStrategies(
    PlateauType plateauType,
    String exerciseName,
    int plateauWeeks
  ) {
    final strategies = <PlateauBreaker>[];
    
    switch (plateauType) {
      case PlateauType.volume:
        strategies.addAll(_getVolumeBreakthroughStrategies(exerciseName, plateauWeeks));
        break;
      case PlateauType.intensity:
        strategies.addAll(_getIntensityBreakthroughStrategies(exerciseName, plateauWeeks));
        break;
      case PlateauType.strength:
        strategies.addAll(_getStrengthBreakthroughStrategies(exerciseName, plateauWeeks));
        break;
      case PlateauType.technique:
        strategies.addAll(_getTechniqueBreakthroughStrategies(exerciseName, plateauWeeks));
        break;
      case PlateauType.recovery:
        strategies.addAll(_getRecoveryBreakthroughStrategies(exerciseName, plateauWeeks));
        break;
    }
    
    return strategies;
  }
  
  /// Volume-based breakthrough strategies
  static List<PlateauBreaker> _getVolumeBreakthroughStrategies(
    String exerciseName,
    int plateauWeeks
  ) {
    return [
      PlateauBreaker(
        strategy: 'Volume Cycling',
        description: 'Implement 3-week volume cycles: high, moderate, low',
        implementation: {
          'week1_volume_multiplier': 1.2,
          'week2_volume_multiplier': 1.0,
          'week3_volume_multiplier': 0.8,
          'progression_method': 'sets',
        },
        durationWeeks: 3,
        expectedImprovement: 0.15,
        requirements: ['Good recovery capacity', 'Proper nutrition'],
      ),
      PlateauBreaker(
        strategy: 'Cluster Sets',
        description: 'Break sets into smaller clusters with micro-rests',
        implementation: {
          'cluster_size': 3,
          'micro_rest_seconds': 15,
          'total_reps_increase': 1.25,
        },
        durationWeeks: 2,
        expectedImprovement: 0.10,
        requirements: ['Timer available', 'Focus on technique'],
      ),
    ];
  }
  
  /// Intensity-based breakthrough strategies
  static List<PlateauBreaker> _getIntensityBreakthroughStrategies(
    String exerciseName,
    int plateauWeeks
  ) {
    return [
      PlateauBreaker(
        strategy: 'Intensity Cycling',
        description: 'Alternate between high and moderate intensity weeks',
        implementation: {
          'high_intensity_percent': 0.90,
          'moderate_intensity_percent': 0.75,
          'cycle_length_weeks': 2,
        },
        durationWeeks: 4,
        expectedImprovement: 0.08,
        requirements: ['Accurate 1RM estimate', 'Spotter available'],
      ),
      PlateauBreaker(
        strategy: 'Mechanical Drop Sets',
        description: 'Use exercise variations with different leverage',
        implementation: {
          'primary_variation': exerciseName,
          'secondary_variation': _getEasierVariation(exerciseName),
          'drop_percentage': 0.85,
        },
        durationWeeks: 3,
        expectedImprovement: 0.12,
        requirements: ['Knowledge of variations', 'Equipment availability'],
      ),
    ];
  }
  
  /// Strength-based breakthrough strategies
  static List<PlateauBreaker> _getStrengthBreakthroughStrategies(
    String exerciseName,
    int plateauWeeks
  ) {
    return [
      PlateauBreaker(
        strategy: 'Contrast Loading',
        description: 'Alternate heavy and explosive work',
        implementation: {
          'heavy_percentage': 0.85,
          'explosive_percentage': 0.60,
          'rest_between_contrasts': 180,
        },
        durationWeeks: 3,
        expectedImprovement: 0.15,
        requirements: ['Power movement knowledge', 'Extended session time'],
      ),
      PlateauBreaker(
        strategy: 'Accommodating Resistance',
        description: 'Add bands or chains for variable resistance',
        implementation: {
          'base_weight_percentage': 0.70,
          'accommodating_resistance': 'bands',
          'peak_tension_percentage': 1.10,
        },
        durationWeeks: 4,
        expectedImprovement: 0.10,
        requirements: ['Bands or chains', 'Setup knowledge'],
      ),
    ];
  }
  
  /// Technique-based breakthrough strategies
  static List<PlateauBreaker> _getTechniqueBreakthroughStrategies(
    String exerciseName,
    int plateauWeeks
  ) {
    return [
      PlateauBreaker(
        strategy: 'Tempo Manipulation',
        description: 'Focus on controlled tempo to improve technique',
        implementation: {
          'eccentric_seconds': 3,
          'pause_seconds': 1,
          'concentric_tempo': 'explosive',
          'weight_reduction': 0.80,
        },
        durationWeeks: 2,
        expectedImprovement: 0.08,
        requirements: ['Timing discipline', 'Focus on form'],
      ),
      PlateauBreaker(
        strategy: 'Unilateral Training',
        description: 'Address imbalances with single-limb work',
        implementation: {
          'unilateral_exercise': _getUnilateralVariation(exerciseName),
          'bilateral_maintenance': true,
          'volume_split': 0.6,
        },
        durationWeeks: 3,
        expectedImprovement: 0.12,
        requirements: ['Balance and stability', 'Patience for lighter loads'],
      ),
    ];
  }
  
  /// Recovery-based breakthrough strategies
  static List<PlateauBreaker> _getRecoveryBreakthroughStrategies(
    String exerciseName,
    int plateauWeeks
  ) {
    return [
      PlateauBreaker(
        strategy: 'Autoregulated Training',
        description: 'Adjust volume/intensity based on daily readiness',
        implementation: {
          'readiness_scale': '1-10',
          'volume_adjustment_factor': 0.1,
          'intensity_adjustment_factor': 0.05,
        },
        durationWeeks: 4,
        expectedImprovement: 0.10,
        requirements: ['Honest self-assessment', 'Flexible planning'],
      ),
      PlateauBreaker(
        strategy: 'Frequency Manipulation',
        description: 'Reduce frequency while maintaining intensity',
        implementation: {
          'frequency_reduction': 0.67,
          'intensity_maintenance': 1.0,
          'volume_per_session_increase': 1.15,
        },
        durationWeeks: 3,
        expectedImprovement: 0.08,
        requirements: ['Longer sessions acceptable', 'Good work capacity'],
      ),
    ];
  }
  
  /// Get easier exercise variation for mechanical drop sets
  static String _getEasierVariation(String exerciseName) {
    final variations = {
      'bench press': 'incline bench press',
      'squat': 'front squat',
      'deadlift': 'sumo deadlift',
      'overhead press': 'seated press',
      'barbell row': 'chest-supported row',
    };
    
    final key = exerciseName.toLowerCase();
    for (final variation in variations.entries) {
      if (key.contains(variation.key)) {
        return variation.value;
      }
    }
    
    return '$exerciseName (lighter variation)';
  }
  
  /// Get unilateral variation for technique work
  static String _getUnilateralVariation(String exerciseName) {
    final variations = {
      'bench press': 'single-arm dumbbell press',
      'squat': 'bulgarian split squat',
      'deadlift': 'single-leg deadlift',
      'overhead press': 'single-arm press',
      'barbell row': 'single-arm row',
    };
    
    final key = exerciseName.toLowerCase();
    for (final variation in variations.entries) {
      if (key.contains(variation.key)) {
        return variation.value;
      }
    }
    
    return '$exerciseName (single-limb)';
  }
}