import '../entities/smart_training_metrics.dart';
import '../entities/progressive_overload_analysis.dart';

/// Service for detecting when deload periods are needed
class DeloadDetectionService {
  
  /// Analyze fatigue and recovery indicators to determine deload need
  static DeloadAnalysis analyzeDeloadNeed(
    List<SmartTrainingMetrics> recentMetrics,
    {int analysisWeeks = 4}
  ) {
    if (recentMetrics.length < analysisWeeks) {
      return DeloadAnalysis(
        needsDeload: false,
        confidence: 0.0,
        indicators: [],
        recommendedDeloadType: DeloadType.maintenance,
        estimatedDurationWeeks: 1,
        reasoning: 'Insufficient data for analysis',
      );
    }
    
    final analysisMetrics = recentMetrics.take(analysisWeeks).toList();
    final indicators = _calculateDeloadIndicators(analysisMetrics);
    
    // Calculate overall deload score (0-10)
    double deloadScore = 0.0;
    for (final indicator in indicators) {
      deloadScore += indicator.severity * indicator.weight;
    }
    
    final needsDeload = deloadScore >= 6.0;
    final confidence = (deloadScore / 10.0).clamp(0.0, 1.0);
    
    return DeloadAnalysis(
      needsDeload: needsDeload,
      confidence: confidence,
      indicators: indicators,
      recommendedDeloadType: _getRecommendedDeloadType(indicators, deloadScore),
      estimatedDurationWeeks: _calculateDeloadDuration(indicators, deloadScore),
      reasoning: _generateReasoningText(indicators, deloadScore),
    );
  }
  
  /// Calculate various deload indicators
  static List<DeloadIndicator> _calculateDeloadIndicators(
    List<SmartTrainingMetrics> metrics
  ) {
    final indicators = <DeloadIndicator>[];
    
    // 1. Fatigue Score Trend
    final fatigueIndicator = _analyzeFatigueTrend(metrics);
    if (fatigueIndicator != null) indicators.add(fatigueIndicator);
    
    // 2. Readiness Score Decline
    final readinessIndicator = _analyzeReadinessTrend(metrics);
    if (readinessIndicator != null) indicators.add(readinessIndicator);
    
    // 3. Volume Decline Despite Intent
    final volumeIndicator = _analyzeVolumeDecline(metrics);
    if (volumeIndicator != null) indicators.add(volumeIndicator);
    
    // 4. Performance Plateau/Decline
    final performanceIndicator = _analyzePerformanceDecline(metrics);
    if (performanceIndicator != null) indicators.add(performanceIndicator);
    
    // 5. RPE Inflation
    final rpeIndicator = _analyzeRPEInflation(metrics);
    if (rpeIndicator != null) indicators.add(rpeIndicator);
    
    // 6. Recovery Time Extension
    final recoveryIndicator = _analyzeRecoveryTime(metrics);
    if (recoveryIndicator != null) indicators.add(recoveryIndicator);
    
    return indicators;
  }
  
  /// Analyze fatigue score trend
  static DeloadIndicator? _analyzeFatigueTrend(List<SmartTrainingMetrics> metrics) {
    final fatigueScores = metrics.map((m) => m.fatigueScore).toList();
    final avgRecent = fatigueScores.take(2).reduce((a, b) => a + b) / 2;
    final avgPrevious = fatigueScores.skip(2).take(2).reduce((a, b) => a + b) / 2;
    
    final fatigueIncrease = avgRecent - avgPrevious;
    
    if (fatigueIncrease > 1.5 || avgRecent >= 8.0) {
      return DeloadIndicator(
        name: 'High Fatigue',
        value: avgRecent,
        threshold: 7.0,
        severity: (avgRecent / 10.0).clamp(0.0, 1.0),
        weight: 0.25,
        description: 'Fatigue levels are elevated and trending upward',
      );
    }
    
    return null;
  }
  
  /// Analyze readiness score trend
  static DeloadIndicator? _analyzeReadinessTrend(List<SmartTrainingMetrics> metrics) {
    final readinessScores = metrics.map((m) => m.readinessScore).toList();
    final avgRecent = readinessScores.take(2).reduce((a, b) => a + b) / 2;
    final avgPrevious = readinessScores.skip(2).take(2).reduce((a, b) => a + b) / 2;
    
    final readinessDecline = avgPrevious - avgRecent;
    
    if (readinessDecline > 1.0 || avgRecent <= 6.0) {
      return DeloadIndicator(
        name: 'Low Readiness',
        value: avgRecent,
        threshold: 7.0,
        severity: (1.0 - avgRecent / 10.0).clamp(0.0, 1.0),
        weight: 0.20,
        description: 'Training readiness has declined significantly',
      );
    }
    
    return null;
  }
  
  /// Analyze volume decline patterns
  static DeloadIndicator? _analyzeVolumeDecline(List<SmartTrainingMetrics> metrics) {
    final volumes = metrics.map((m) => m.volume).toList();
    final avgRecent = volumes.take(2).reduce((a, b) => a + b) / 2;
    final avgPrevious = volumes.skip(2).take(2).reduce((a, b) => a + b) / 2;
    
    final volumeDecline = (avgPrevious - avgRecent) / avgPrevious;
    
    if (volumeDecline > 0.15) { // 15% volume decline
      return DeloadIndicator(
        name: 'Volume Decline',
        value: volumeDecline * 100,
        threshold: 10.0,
        severity: (volumeDecline * 2).clamp(0.0, 1.0),
        weight: 0.20,
        description: 'Training volume has declined despite maintenance intent',
      );
    }
    
    return null;
  }
  
  /// Analyze performance decline (1RM estimates)
  static DeloadIndicator? _analyzePerformanceDecline(List<SmartTrainingMetrics> metrics) {
    // Calculate average estimated 1RM across all exercises
    double calculateAvgOneRM(SmartTrainingMetrics metric) {
      if (metric.exerciseMetrics.isEmpty) return 0.0;
      return metric.exerciseMetrics
          .map((e) => e.estimatedOneRM)
          .reduce((a, b) => a + b) / metric.exerciseMetrics.length;
    }
    
    final recent1RM = calculateAvgOneRM(metrics.first);
    final previous1RM = calculateAvgOneRM(metrics[2]);
    
    if (previous1RM > 0) {
      final performanceDecline = (previous1RM - recent1RM) / previous1RM;
      
      if (performanceDecline > 0.05) { // 5% performance decline
        return DeloadIndicator(
          name: 'Performance Decline',
          value: performanceDecline * 100,
          threshold: 3.0,
          severity: (performanceDecline * 4).clamp(0.0, 1.0),
          weight: 0.15,
          description: 'Estimated 1RM has declined across exercises',
        );
      }
    }
    
    return null;
  }
  
  /// Analyze RPE inflation (same loads feeling harder)
  static DeloadIndicator? _analyzeRPEInflation(List<SmartTrainingMetrics> metrics) {
    double calculateAvgRPE(SmartTrainingMetrics metric) {
      if (metric.exerciseMetrics.isEmpty) return 0.0;
      return metric.exerciseMetrics
          .map((e) => e.averageRPE)
          .reduce((a, b) => a + b) / metric.exerciseMetrics.length;
    }
    
    final recentRPE = calculateAvgRPE(metrics.first);
    final previousRPE = calculateAvgRPE(metrics[2]);
    
    final rpeIncrease = recentRPE - previousRPE;
    
    if (rpeIncrease > 0.8 || recentRPE >= 8.5) {
      return DeloadIndicator(
        name: 'RPE Inflation',
        value: recentRPE,
        threshold: 8.0,
        severity: (recentRPE / 10.0).clamp(0.0, 1.0),
        weight: 0.10,
        description: 'Same loads are feeling significantly harder',
      );
    }
    
    return null;
  }
  
  /// Analyze recovery time patterns
  static DeloadIndicator? _analyzeRecoveryTime(List<SmartTrainingMetrics> metrics) {
    // Look at session duration increases as proxy for recovery issues
    final durations = metrics.map((m) => m.sessionDuration).toList();
    final avgRecent = durations.take(2).reduce((a, b) => a + b) / 2;
    final avgPrevious = durations.skip(2).take(2).reduce((a, b) => a + b) / 2;
    
    final durationIncrease = (avgRecent - avgPrevious) / avgPrevious;
    
    if (durationIncrease > 0.20) { // 20% session duration increase
      return DeloadIndicator(
        name: 'Extended Sessions',
        value: durationIncrease * 100,
        threshold: 15.0,
        severity: (durationIncrease * 2).clamp(0.0, 1.0),
        weight: 0.10,
        description: 'Sessions are taking significantly longer to complete',
      );
    }
    
    return null;
  }
  
  /// Determine recommended deload type based on indicators
  static DeloadType _getRecommendedDeloadType(
    List<DeloadIndicator> indicators,
    double deloadScore
  ) {
    // High fatigue or readiness issues -> Active recovery
    if (indicators.any((i) => i.name == 'High Fatigue' && i.severity > 0.7) ||
        indicators.any((i) => i.name == 'Low Readiness' && i.severity > 0.7)) {
      return DeloadType.activeRecovery;
    }
    
    // Performance decline -> Technique focus
    if (indicators.any((i) => i.name == 'Performance Decline')) {
      return DeloadType.techniqueFocus;
    }
    
    // Volume issues -> Volume reduction
    if (indicators.any((i) => i.name == 'Volume Decline')) {
      return DeloadType.volumeReduction;
    }
    
    // RPE inflation -> Intensity reduction
    if (indicators.any((i) => i.name == 'RPE Inflation')) {
      return DeloadType.intensityReduction;
    }
    
    return DeloadType.maintenance;
  }
  
  /// Calculate recommended deload duration
  static int _calculateDeloadDuration(
    List<DeloadIndicator> indicators,
    double deloadScore
  ) {
    // High severity indicators need longer deload
    final maxSeverity = indicators.isEmpty ? 0.0 : 
        indicators.map((i) => i.severity).reduce((a, b) => a > b ? a : b);
    
    if (maxSeverity >= 0.8 || deloadScore >= 8.0) return 2;
    if (maxSeverity >= 0.6 || deloadScore >= 7.0) return 1;
    
    return 1;
  }
  
  /// Generate reasoning text for deload recommendation
  static String _generateReasoningText(
    List<DeloadIndicator> indicators,
    double deloadScore
  ) {
    if (indicators.isEmpty) {
      return 'No significant fatigue indicators detected. Continue current training.';
    }
    
    final primaryIndicators = indicators
        .where((i) => i.severity > 0.5)
        .map((i) => i.name)
        .toList();
    
    if (primaryIndicators.isEmpty) {
      return 'Minor fatigue indicators present. Monitor closely and consider light deload.';
    }
    
    final indicatorText = primaryIndicators.join(', ');
    
    if (deloadScore >= 8.0) {
      return 'Multiple severe indicators ($indicatorText) suggest immediate deload is needed.';
    } else if (deloadScore >= 6.0) {
      return 'Moderate indicators ($indicatorText) suggest a deload period would be beneficial.';
    } else {
      return 'Mild indicators ($indicatorText) detected. Light deload or maintenance recommended.';
    }
  }
}

/// Deload analysis results
class DeloadAnalysis {
  final bool needsDeload;
  final double confidence;
  final List<DeloadIndicator> indicators;
  final DeloadType recommendedDeloadType;
  final int estimatedDurationWeeks;
  final String reasoning;

  DeloadAnalysis({
    required this.needsDeload,
    required this.confidence,
    required this.indicators,
    required this.recommendedDeloadType,
    required this.estimatedDurationWeeks,
    required this.reasoning,
  });

  Map<String, dynamic> toJson() {
    return {
      'needsDeload': needsDeload,
      'confidence': confidence,
      'indicators': indicators.map((i) => i.toJson()).toList(),
      'recommendedDeloadType': recommendedDeloadType.name,
      'estimatedDurationWeeks': estimatedDurationWeeks,
      'reasoning': reasoning,
    };
  }

  factory DeloadAnalysis.fromJson(Map<String, dynamic> json) {
    return DeloadAnalysis(
      needsDeload: json['needsDeload'],
      confidence: (json['confidence'] as num).toDouble(),
      indicators: (json['indicators'] as List)
          .map((i) => DeloadIndicator.fromJson(i))
          .toList(),
      recommendedDeloadType: DeloadType.values.firstWhere(
        (t) => t.name == json['recommendedDeloadType'],
      ),
      estimatedDurationWeeks: json['estimatedDurationWeeks'],
      reasoning: json['reasoning'],
    );
  }
}

/// Individual deload indicator
class DeloadIndicator {
  final String name;
  final double value;
  final double threshold;
  final double severity; // 0-1 scale
  final double weight; // Relative importance
  final String description;

  DeloadIndicator({
    required this.name,
    required this.value,
    required this.threshold,
    required this.severity,
    required this.weight,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'threshold': threshold,
      'severity': severity,
      'weight': weight,
      'description': description,
    };
  }

  factory DeloadIndicator.fromJson(Map<String, dynamic> json) {
    return DeloadIndicator(
      name: json['name'],
      value: (json['value'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      severity: (json['severity'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      description: json['description'],
    );
  }
}

/// Types of deload protocols
enum DeloadType {
  activeRecovery,     // Light cardio, mobility, technique work
  volumeReduction,    // Reduce sets by 40-50%
  intensityReduction, // Reduce weight by 40-50%
  techniqueFocus,     // Focus on technique with lighter weights
  maintenance,        // Maintain current training
}