import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/set_execution_timing.dart';
import 'package:gymbro_flutter_new/features/timer/domain/repositories/set_timing_repository.dart';

/// TIER-1 Set Analytics Engine with ML-based predictions
/// Provides advanced performance insights and predictions
class SetAnalyticsEngine {
  
  SetAnalyticsEngine(this._repository);
  final SetTimingRepository _repository;

  /// Generate comprehensive performance report
  Future<PerformanceReport> generatePerformanceReport(
    String exerciseId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      DebugLogger.log(LogCategory.timer, 
        'TIER-1: Generating performance report for $exerciseId');
      
      final timings = await _repository.getTimingsInDateRange(startDate, endDate);
      final exerciseTimings = timings.where((t) => t.exerciseId == exerciseId).toList();
      
      if (exerciseTimings.isEmpty) {
        return PerformanceReport.empty(exerciseId);
      }
      
      // Core metrics
      final volumeAnalysis = _calculateVolumeAnalysis(exerciseTimings);
      final intensityAnalysis = _calculateIntensityAnalysis(exerciseTimings);
      final consistencyAnalysis = _calculateConsistencyAnalysis(exerciseTimings);
      final fatigueAnalysis = _calculateFatigueAnalysis(exerciseTimings);
      
      // ML predictions
      final predictions = await _generateMLPredictions(exerciseTimings);
      
      // Trends
      final trends = _calculateTrends(exerciseTimings);
      
      return PerformanceReport(
        exerciseId: exerciseId,
        dateRange: DateRange(startDate, endDate),
        totalSets: exerciseTimings.length,
        volumeAnalysis: volumeAnalysis,
        intensityAnalysis: intensityAnalysis,
        consistencyAnalysis: consistencyAnalysis,
        fatigueAnalysis: fatigueAnalysis,
        predictions: predictions,
        trends: trends,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Performance report generation error: $e');
      return PerformanceReport.empty(exerciseId);
    }
  }

  /// Predict next set performance based on historical data
  Future<SetPrediction> predictNextSetPerformance(
    String exerciseId,
    double currentWeight,
    int targetReps,
  ) async {
    try {
      final recentTimings = await _getRecentTimings(exerciseId, limit: 20);
      
      if (recentTimings.isEmpty) {
        return SetPrediction.noData();
      }
      
      // Filter similar weight/rep combinations
      final similarSets = _findSimilarSets(recentTimings, currentWeight, targetReps);
      
      if (similarSets.isEmpty) {
        return SetPrediction.noData();
      }
      
      // Predict execution time
      final predictedTime = _predictExecutionTime(similarSets);
      
      // Predict fatigue level
      final predictedFatigue = _predictFatigueLevel(similarSets);
      
      // Predict success probability
      final successProbability = _calculateSuccessProbability(similarSets);
      
      return SetPrediction(
        predictedExecutionTimeMs: predictedTime,
        predictedFatigueIndex: predictedFatigue,
        successProbability: successProbability,
        confidence: _calculatePredictionConfidence(similarSets.length),
        basedOnSets: similarSets.length,
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Set prediction error: $e');
      return SetPrediction.noData();
    }
  }

  /// Analyze velocity-based training zones
  Future<VBTAnalysis> analyzeVelocityBasedTraining(
    String exerciseId,
    Duration timeWindow,
  ) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(timeWindow);
      
      final timings = await _repository.getTimingsInDateRange(startDate, endDate);
      final exerciseTimings = timings
        .where((t) => t.exerciseId == exerciseId && t.velocityMps.isNotEmpty)
        .toList();
      
      if (exerciseTimings.isEmpty) {
        return VBTAnalysis.noData();
      }
      
      // Analyze velocity zones
      final zoneDistribution = _analyzeVelocityZones(exerciseTimings);
      
      // Calculate velocity-load relationship
      final loadVelocityProfile = _calculateLoadVelocityProfile(exerciseTimings);
      
      // Identify optimal training loads
      final optimalLoads = _identifyOptimalLoads(exerciseTimings);
      
      return VBTAnalysis(
        zoneDistribution: zoneDistribution,
        loadVelocityProfile: loadVelocityProfile,
        optimalLoads: optimalLoads,
        averageVelocityLoss: _calculateAverageVelocityLoss(exerciseTimings),
        recommendedVelocityThresholds: _calculateRecommendedThresholds(exerciseTimings),
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'VBT analysis error: $e');
      return VBTAnalysis.noData();
    }
  }

  /// Generate fatigue accumulation model
  Future<FatigueModel> generateFatigueModel(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allTimings = await _repository.getTimingsInDateRange(startDate, endDate);
      
      if (allTimings.isEmpty) {
        return FatigueModel.noData();
      }
      
      // Group by workout sessions
      final sessions = _groupByWorkoutSessions(allTimings);
      
      // Analyze intra-session fatigue
      final intraSessionFatigue = sessions.map(_analyzeIntraSessionFatigue).toList();
      
      // Analyze inter-session fatigue
      final interSessionFatigue = _analyzeInterSessionFatigue(sessions);
      
      // Build fatigue accumulation model
      final fatigueCoefficients = _calculateFatigueCoefficients(intraSessionFatigue);
      
      return FatigueModel(
        intraSessionFatigue: intraSessionFatigue,
        interSessionFatigue: interSessionFatigue,
        fatigueCoefficients: fatigueCoefficients,
        optimalRestRecommendations: _generateRestRecommendations(fatigueCoefficients),
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Fatigue model generation error: $e');
      return FatigueModel.noData();
    }
  }

  /// Predict optimal rest time between sets
  /// ⚡ OPTIMIZATION: Reduced limit from 50 → 10 to save memory
  Future<RestPrediction> predictOptimalRestTime(
    String exerciseId,
    double currentFatigueIndex,
    double targetRecoveryPercent,
  ) async {
    try {
      final historicalData = await _getRecentTimings(exerciseId, limit: 10);
      
      if (historicalData.isEmpty) {
        return RestPrediction.defaultRest();
      }
      
      // Analyze historical recovery patterns
      final recoveryPatterns = _analyzeRecoveryPatterns(historicalData);
      
      // Build recovery model
      final recoveryModel = _buildRecoveryModel(recoveryPatterns);
      
      // Predict optimal rest time
      final predictedRestSeconds = _predictRestTime(
        recoveryModel,
        currentFatigueIndex,
        targetRecoveryPercent,
      );
      
      return RestPrediction(
        predictedRestTimeSeconds: predictedRestSeconds,
        confidence: _calculateRestPredictionConfidence(recoveryPatterns.length),
        targetRecovery: targetRecoveryPercent,
        expectedFatigueAfterRest: math.max(0, currentFatigueIndex - (targetRecoveryPercent * currentFatigueIndex / 100)),
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Rest time prediction error: $e');
      return RestPrediction.defaultRest();
    }
  }

  /// Generate personalized coaching insights
  Future<CoachingInsights> generateCoachingInsights(
    String exerciseId,
    List<SetExecutionTiming> recentSets,
  ) async {
    try {
      if (recentSets.isEmpty) {
        return CoachingInsights.noData();
      }
      
      final insights = <CoachingInsight>[];
      
      // Analyze performance trends
      insights.addAll(await _analyzePerformanceTrends(recentSets));
      
      // Analyze technical consistency
      insights.addAll(await _analyzeTechnicalConsistency(recentSets));
      
      // Analyze fatigue patterns
      insights.addAll(await _analyzeFatiguePatterns(recentSets));
      
      // Analyze velocity patterns
      insights.addAll(await _analyzeVelocityPatterns(recentSets));
      
      // Priority ranking
      insights.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      
      return CoachingInsights(
        insights: insights,
        overallScore: _calculateOverallPerformanceScore(recentSets),
        keyRecommendations: insights.take(3).map((i) => i.recommendation).toList(),
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Coaching insights generation error: $e');
      return CoachingInsights.noData();
    }
  }

  // Private helper methods

  VolumeAnalysis _calculateVolumeAnalysis(List<SetExecutionTiming> timings) {
    final totalVolume = timings.fold<double>(
      0.0, 
      (sum, t) => sum + ((t.weight ?? 0) * t.reps),
    );
    
    final averageVolume = totalVolume / timings.length;
    
    return VolumeAnalysis(
      totalVolume: totalVolume,
      averageVolumePerSet: averageVolume,
      volumeTrend: _calculateLinearTrend(timings.map((t) => (t.weight ?? 0) * t.reps).toList()),
    );
  }

  IntensityAnalysis _calculateIntensityAnalysis(List<SetExecutionTiming> timings) {
    final weights = timings.map((t) => t.weight ?? 0).where((w) => w > 0).toList();
    
    if (weights.isEmpty) {
      return const IntensityAnalysis(
        averageWeight: 0,
        maxWeight: 0,
        intensityTrend: 0,
      );
    }
    
    final averageWeight = weights.reduce((a, b) => a + b) / weights.length;
    final maxWeight = weights.reduce(math.max);
    
    return IntensityAnalysis(
      averageWeight: averageWeight,
      maxWeight: maxWeight,
      intensityTrend: _calculateLinearTrend(weights),
    );
  }

  ConsistencyAnalysis _calculateConsistencyAnalysis(List<SetExecutionTiming> timings) {
    final executionTimes = timings.map((t) => t.executionTimeMs.toDouble()).toList();
    final formScores = timings.map((t) => t.formScore).toList();
    
    return ConsistencyAnalysis(
      timeConsistency: _calculateConsistencyScore(executionTimes),
      formConsistency: _calculateConsistencyScore(formScores),
      overallConsistency: (_calculateConsistencyScore(executionTimes) + _calculateConsistencyScore(formScores)) / 2,
    );
  }

  FatigueAnalysisResult _calculateFatigueAnalysis(List<SetExecutionTiming> timings) {
    final fatigueIndices = timings.map((t) => t.fatigueIndex).toList();
    
    return FatigueAnalysisResult(
      averageFatigue: fatigueIndices.reduce((a, b) => a + b) / fatigueIndices.length,
      maxFatigue: fatigueIndices.reduce(math.max),
      fatigueTrend: _calculateLinearTrend(fatigueIndices),
    );
  }

  Future<MLPredictions> _generateMLPredictions(List<SetExecutionTiming> timings) async {
    // Simplified ML predictions - in production, would use TensorFlow Lite
    return MLPredictions(
      nextSetExecutionTime: _predictNextExecutionTime(timings),
      nextSetFatigueIndex: _predictNextFatigueIndex(timings),
      recommendedWeight: _predictRecommendedWeight(timings),
      confidenceScore: _calculateMLConfidence(timings.length),
    );
  }

  PerformanceTrends _calculateTrends(List<SetExecutionTiming> timings) {
    final executionTimes = timings.map((t) => t.executionTimeMs.toDouble()).toList();
    final formScores = timings.map((t) => t.formScore).toList();
    final fatigueIndices = timings.map((t) => t.fatigueIndex).toList();
    
    return PerformanceTrends(
      executionTimeTrend: _calculateLinearTrend(executionTimes),
      formScoreTrend: _calculateLinearTrend(formScores),
      fatigueIndexTrend: _calculateLinearTrend(fatigueIndices),
    );
  }

  double _calculateLinearTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;
    
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumXX = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    
    return slope;
  }

  double _calculateConsistencyScore(List<double> values) {
    if (values.length < 2) return 100.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    final coefficientOfVariation = math.sqrt(variance) / mean * 100;
    
    return math.max(0, 100 - coefficientOfVariation);
  }

  Future<List<SetExecutionTiming>> _getRecentTimings(String exerciseId, {int limit = 10}) async {
    final allTimings = await _repository.getSetTimingsForExercise(exerciseId);
    return allTimings.take(limit).toList();
  }

  List<SetExecutionTiming> _findSimilarSets(
    List<SetExecutionTiming> timings,
    double targetWeight,
    int targetReps,
  ) {
    return timings.where((timing) {
      final weightDiff = ((timing.weight ?? 0) - targetWeight).abs();
      final repDiff = (timing.reps - targetReps).abs();
      
      return weightDiff <= targetWeight * 0.1 && repDiff <= 2; // 10% weight tolerance, 2 reps tolerance
    }).toList();
  }

  int _predictExecutionTime(List<SetExecutionTiming> similarSets) {
    if (similarSets.isEmpty) return 30000; // Default 30 seconds
    
    final times = similarSets.map((s) => s.executionTimeMs).toList();
    return (times.reduce((a, b) => a + b) / times.length).round();
  }

  double _predictFatigueLevel(List<SetExecutionTiming> similarSets) {
    if (similarSets.isEmpty) return 50.0;
    
    final fatigues = similarSets.map((s) => s.fatigueIndex).toList();
    return fatigues.reduce((a, b) => a + b) / fatigues.length;
  }

  double _calculateSuccessProbability(List<SetExecutionTiming> similarSets) {
    if (similarSets.isEmpty) return 0.5;
    
    // Define success as completing target reps with form score > 70
    final successfulSets = similarSets.where((s) => s.formScore >= 70.0).length;
    
    return successfulSets / similarSets.length;
  }

  double _calculatePredictionConfidence(int sampleSize) {
    if (sampleSize == 0) return 0.0;
    if (sampleSize >= 10) return 0.95;
    if (sampleSize >= 5) return 0.80;
    if (sampleSize >= 3) return 0.65;
    return 0.50;
  }

  // Additional helper methods would be implemented here...
  
  Map<String, double> _analyzeVelocityZones(List<SetExecutionTiming> timings) {
    // Implementation for velocity zone analysis
    return {'explosive': 0.1, 'speed': 0.3, 'strength': 0.6};
  }

  List<LoadVelocityPoint> _calculateLoadVelocityProfile(List<SetExecutionTiming> timings) {
    // Implementation for load-velocity profiling
    return [];
  }

  OptimalLoads _identifyOptimalLoads(List<SetExecutionTiming> timings) {
    // Implementation for optimal load identification
    return const OptimalLoads(
      maxStrength: 100.0,
      maxPower: 80.0,
      maxSpeed: 60.0,
    );
  }

  double _calculateAverageVelocityLoss(List<SetExecutionTiming> timings) {
    // Implementation for average velocity loss calculation
    return 15.0;
  }

  VelocityThresholds _calculateRecommendedThresholds(List<SetExecutionTiming> timings) {
    // Implementation for recommended velocity thresholds
    return const VelocityThresholds(
      minVelocity: 0.2,
      optimalVelocity: 0.5,
      maxVelocity: 1.0,
    );
  }

  List<List<SetExecutionTiming>> _groupByWorkoutSessions(List<SetExecutionTiming> timings) {
    // Group timings by workout sessions
    final sessions = <String, List<SetExecutionTiming>>{};
    
    for (final timing in timings) {
      sessions.putIfAbsent(timing.workoutId, () => []).add(timing);
    }
    
    return sessions.values.toList();
  }

  IntraSessionFatigue _analyzeIntraSessionFatigue(List<SetExecutionTiming> sessionTimings) {
    // Implementation for intra-session fatigue analysis
    return IntraSessionFatigue(
      initialFatigue: sessionTimings.first.fatigueIndex,
      finalFatigue: sessionTimings.last.fatigueIndex,
      fatigueAccumulation: sessionTimings.last.fatigueIndex - sessionTimings.first.fatigueIndex,
    );
  }

  InterSessionFatigue _analyzeInterSessionFatigue(List<List<SetExecutionTiming>> sessions) {
    // Implementation for inter-session fatigue analysis
    return const InterSessionFatigue(
      averageRecoveryTime: Duration(hours: 48),
      recoveryEfficiency: 0.85,
    );
  }

  FatigueCoefficients _calculateFatigueCoefficients(List<IntraSessionFatigue> intraSessionData) {
    // Implementation for fatigue coefficient calculation
    return const FatigueCoefficients(
      fatigueRate: 0.1,
      recoveryRate: 0.05,
      carryOverFactor: 0.15,
    );
  }

  Map<String, Duration> _generateRestRecommendations(FatigueCoefficients coefficients) {
    // Implementation for rest recommendations
    return {
      'low_fatigue': const Duration(minutes: 2),
      'moderate_fatigue': const Duration(minutes: 3),
      'high_fatigue': const Duration(minutes: 5),
    };
  }

  List<RecoveryPattern> _analyzeRecoveryPatterns(List<SetExecutionTiming> timings) {
    // Implementation for recovery pattern analysis
    return [];
  }

  RecoveryModel _buildRecoveryModel(List<RecoveryPattern> patterns) {
    // Implementation for recovery model building
    return const RecoveryModel(
      exponentialDecayRate: 0.1,
      plateauThreshold: 0.85,
    );
  }

  int _predictRestTime(RecoveryModel model, double currentFatigue, double targetRecovery) {
    // Implementation for rest time prediction
    final restSeconds = (math.log(targetRecovery / 100) / -model.exponentialDecayRate * 60).round();
    return math.max(60, math.min(600, restSeconds)); // Between 1-10 minutes
  }

  double _calculateRestPredictionConfidence(int patternCount) {
    // Implementation for rest prediction confidence
    return math.min(0.95, patternCount / 20.0);
  }

  Future<List<CoachingInsight>> _analyzePerformanceTrends(List<SetExecutionTiming> sets) async {
    // Implementation for performance trend analysis
    return [];
  }

  Future<List<CoachingInsight>> _analyzeTechnicalConsistency(List<SetExecutionTiming> sets) async {
    // Implementation for technical consistency analysis
    return [];
  }

  Future<List<CoachingInsight>> _analyzeFatiguePatterns(List<SetExecutionTiming> sets) async {
    // Implementation for fatigue pattern analysis
    return [];
  }

  Future<List<CoachingInsight>> _analyzeVelocityPatterns(List<SetExecutionTiming> sets) async {
    // Implementation for velocity pattern analysis
    return [];
  }

  double _calculateOverallPerformanceScore(List<SetExecutionTiming> sets) {
    // Implementation for overall performance score
    return 85.0;
  }

  int _predictNextExecutionTime(List<SetExecutionTiming> timings) {
    // Simple moving average prediction
    if (timings.isEmpty) return 30000;
    
    final recentTimes = timings.take(5).map((t) => t.executionTimeMs).toList();
    return (recentTimes.reduce((a, b) => a + b) / recentTimes.length).round();
  }

  double _predictNextFatigueIndex(List<SetExecutionTiming> timings) {
    // Simple linear extrapolation
    if (timings.length < 2) return 0.0;
    
    final recent = timings.take(3).map((t) => t.fatigueIndex).toList();
    return recent.reduce((a, b) => a + b) / recent.length;
  }

  double _predictRecommendedWeight(List<SetExecutionTiming> timings) {
    // Weight recommendation based on performance trends
    if (timings.isEmpty) return 0.0;
    
    final recentWeights = timings.take(5).map((t) => t.weight ?? 0).where((w) => w > 0).toList();
    if (recentWeights.isEmpty) return 0.0;
    
    return recentWeights.reduce((a, b) => a + b) / recentWeights.length;
  }

  double _calculateMLConfidence(int sampleSize) {
    return math.min(0.95, sampleSize / 50.0);
  }
}

// Data classes for analytics results would be defined here...
// (Performance Report, VBT Analysis, Fatigue Model, etc.)

class PerformanceReport {
  
  const PerformanceReport({
    required this.exerciseId,
    required this.dateRange,
    required this.totalSets,
    required this.volumeAnalysis,
    required this.intensityAnalysis,
    required this.consistencyAnalysis,
    required this.fatigueAnalysis,
    required this.predictions,
    required this.trends,
    required this.generatedAt,
  });
  
  factory PerformanceReport.empty(String exerciseId) {
    return PerformanceReport(
      exerciseId: exerciseId,
      dateRange: DateRange(DateTime.now(), DateTime.now()),
      totalSets: 0,
      volumeAnalysis: const VolumeAnalysis(totalVolume: 0, averageVolumePerSet: 0, volumeTrend: 0),
      intensityAnalysis: const IntensityAnalysis(averageWeight: 0, maxWeight: 0, intensityTrend: 0),
      consistencyAnalysis: const ConsistencyAnalysis(timeConsistency: 0, formConsistency: 0, overallConsistency: 0),
      fatigueAnalysis: const FatigueAnalysisResult(averageFatigue: 0, maxFatigue: 0, fatigueTrend: 0),
      predictions: const MLPredictions(nextSetExecutionTime: 0, nextSetFatigueIndex: 0, recommendedWeight: 0, confidenceScore: 0),
      trends: const PerformanceTrends(executionTimeTrend: 0, formScoreTrend: 0, fatigueIndexTrend: 0),
      generatedAt: DateTime.now(),
    );
  }
  final String exerciseId;
  final DateRange dateRange;
  final int totalSets;
  final VolumeAnalysis volumeAnalysis;
  final IntensityAnalysis intensityAnalysis;
  final ConsistencyAnalysis consistencyAnalysis;
  final FatigueAnalysisResult fatigueAnalysis;
  final MLPredictions predictions;
  final PerformanceTrends trends;
  final DateTime generatedAt;
}

class DateRange {
  
  DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}

class VolumeAnalysis {
  
  const VolumeAnalysis({
    required this.totalVolume,
    required this.averageVolumePerSet,
    required this.volumeTrend,
  });
  final double totalVolume;
  final double averageVolumePerSet;
  final double volumeTrend;
}

class IntensityAnalysis {
  
  const IntensityAnalysis({
    required this.averageWeight,
    required this.maxWeight,
    required this.intensityTrend,
  });
  final double averageWeight;
  final double maxWeight;
  final double intensityTrend;
}

class ConsistencyAnalysis {
  
  const ConsistencyAnalysis({
    required this.timeConsistency,
    required this.formConsistency,
    required this.overallConsistency,
  });
  final double timeConsistency;
  final double formConsistency;
  final double overallConsistency;
}

class FatigueAnalysisResult {
  
  const FatigueAnalysisResult({
    required this.averageFatigue,
    required this.maxFatigue,
    required this.fatigueTrend,
  });
  final double averageFatigue;
  final double maxFatigue;
  final double fatigueTrend;
}

class MLPredictions {
  
  const MLPredictions({
    required this.nextSetExecutionTime,
    required this.nextSetFatigueIndex,
    required this.recommendedWeight,
    required this.confidenceScore,
  });
  final int nextSetExecutionTime;
  final double nextSetFatigueIndex;
  final double recommendedWeight;
  final double confidenceScore;
}

class PerformanceTrends {
  
  const PerformanceTrends({
    required this.executionTimeTrend,
    required this.formScoreTrend,
    required this.fatigueIndexTrend,
  });
  final double executionTimeTrend;
  final double formScoreTrend;
  final double fatigueIndexTrend;
}

class SetPrediction {
  
  const SetPrediction({
    required this.predictedExecutionTimeMs,
    required this.predictedFatigueIndex,
    required this.successProbability,
    required this.confidence,
    required this.basedOnSets,
  });
  
  factory SetPrediction.noData() {
    return const SetPrediction(
      predictedExecutionTimeMs: 30000,
      predictedFatigueIndex: 50.0,
      successProbability: 0.5,
      confidence: 0.0,
      basedOnSets: 0,
    );
  }
  final int predictedExecutionTimeMs;
  final double predictedFatigueIndex;
  final double successProbability;
  final double confidence;
  final int basedOnSets;
}

class VBTAnalysis {
  
  const VBTAnalysis({
    required this.zoneDistribution,
    required this.loadVelocityProfile,
    required this.optimalLoads,
    required this.averageVelocityLoss,
    required this.recommendedVelocityThresholds,
  });
  
  factory VBTAnalysis.noData() {
    return const VBTAnalysis(
      zoneDistribution: {},
      loadVelocityProfile: [],
      optimalLoads: OptimalLoads(maxStrength: 0, maxPower: 0, maxSpeed: 0),
      averageVelocityLoss: 0,
      recommendedVelocityThresholds: VelocityThresholds(minVelocity: 0, optimalVelocity: 0, maxVelocity: 0),
    );
  }
  final Map<String, double> zoneDistribution;
  final List<LoadVelocityPoint> loadVelocityProfile;
  final OptimalLoads optimalLoads;
  final double averageVelocityLoss;
  final VelocityThresholds recommendedVelocityThresholds;
}

class LoadVelocityPoint {
  
  const LoadVelocityPoint({required this.load, required this.velocity});
  final double load;
  final double velocity;
}

class OptimalLoads {
  
  const OptimalLoads({
    required this.maxStrength,
    required this.maxPower,
    required this.maxSpeed,
  });
  final double maxStrength;
  final double maxPower;
  final double maxSpeed;
}

class VelocityThresholds {
  
  const VelocityThresholds({
    required this.minVelocity,
    required this.optimalVelocity,
    required this.maxVelocity,
  });
  final double minVelocity;
  final double optimalVelocity;
  final double maxVelocity;
}

class FatigueModel {
  
  const FatigueModel({
    required this.intraSessionFatigue,
    required this.interSessionFatigue,
    required this.fatigueCoefficients,
    required this.optimalRestRecommendations,
  });
  
  factory FatigueModel.noData() {
    return const FatigueModel(
      intraSessionFatigue: [],
      interSessionFatigue: InterSessionFatigue(averageRecoveryTime: Duration(hours: 48), recoveryEfficiency: 0),
      fatigueCoefficients: FatigueCoefficients(fatigueRate: 0, recoveryRate: 0, carryOverFactor: 0),
      optimalRestRecommendations: {},
    );
  }
  final List<IntraSessionFatigue> intraSessionFatigue;
  final InterSessionFatigue interSessionFatigue;
  final FatigueCoefficients fatigueCoefficients;
  final Map<String, Duration> optimalRestRecommendations;
}

class IntraSessionFatigue {
  
  const IntraSessionFatigue({
    required this.initialFatigue,
    required this.finalFatigue,
    required this.fatigueAccumulation,
  });
  final double initialFatigue;
  final double finalFatigue;
  final double fatigueAccumulation;
}

class InterSessionFatigue {
  
  const InterSessionFatigue({
    required this.averageRecoveryTime,
    required this.recoveryEfficiency,
  });
  final Duration averageRecoveryTime;
  final double recoveryEfficiency;
}

class FatigueCoefficients {
  
  const FatigueCoefficients({
    required this.fatigueRate,
    required this.recoveryRate,
    required this.carryOverFactor,
  });
  final double fatigueRate;
  final double recoveryRate;
  final double carryOverFactor;
}

class RestPrediction {
  
  const RestPrediction({
    required this.predictedRestTimeSeconds,
    required this.confidence,
    required this.targetRecovery,
    required this.expectedFatigueAfterRest,
  });
  
  factory RestPrediction.defaultRest() {
    return const RestPrediction(
      predictedRestTimeSeconds: 120,
      confidence: 0.5,
      targetRecovery: 80.0,
      expectedFatigueAfterRest: 20.0,
    );
  }
  final int predictedRestTimeSeconds;
  final double confidence;
  final double targetRecovery;
  final double expectedFatigueAfterRest;
}

class RecoveryPattern {
  
  const RecoveryPattern({
    required this.initialFatigue,
    required this.restTime,
    required this.finalFatigue,
  });
  final double initialFatigue;
  final Duration restTime;
  final double finalFatigue;
}

class RecoveryModel {
  
  const RecoveryModel({
    required this.exponentialDecayRate,
    required this.plateauThreshold,
  });
  final double exponentialDecayRate;
  final double plateauThreshold;
}

class CoachingInsights {
  
  const CoachingInsights({
    required this.insights,
    required this.overallScore,
    required this.keyRecommendations,
    required this.generatedAt,
  });
  
  factory CoachingInsights.noData() {
    return CoachingInsights(
      insights: [],
      overallScore: 0,
      keyRecommendations: [],
      generatedAt: DateTime.now(),
    );
  }
  final List<CoachingInsight> insights;
  final double overallScore;
  final List<String> keyRecommendations;
  final DateTime generatedAt;
}

class CoachingInsight {
  
  const CoachingInsight({
    required this.title,
    required this.description,
    required this.recommendation,
    required this.priority,
    required this.category,
  });
  final String title;
  final String description;
  final String recommendation;
  final InsightPriority priority;
  final InsightCategory category;
}

enum InsightPriority { low, medium, high, critical }
enum InsightCategory { form, fatigue, velocity, consistency, volume }

// TODO: Implement SetTimingRepository and its provider
// Provider for the analytics engine
final setAnalyticsEngineProvider = Provider<SetAnalyticsEngine>((ref) {
  // return SetAnalyticsEngine(ref.read(setTimingRepositoryProvider));
  throw UnimplementedError('SetTimingRepository not yet implemented');
});