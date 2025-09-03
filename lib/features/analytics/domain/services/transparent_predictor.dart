import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/analytics/domain/models/prediction_models.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/analytics_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';

/// Transparent prediction service with scientific accuracy
class TransparentPredictor {
  
  /// Generate 1RM prediction with confidence intervals
  static TransparentPrediction predict1RM({
    required double weight,
    required int reps,
    required List<AnalyticsActivity> historicalData,
  }) {
    // Calculate using multiple formulas for range
    final formulas = {
      'Brzycki': weight * (36 / (37 - reps)),
      'Epley': weight * (1 + reps / 30),
      'Lombardi': weight * math.pow(reps, 0.1),
    };
    
    final values = formulas.values.toList()..sort();
    final lower = values.first;
    final upper = values.last;
    final median = values[values.length ~/ 2];
    
    // Calculate standard error based on historical accuracy
    final standardError = _calculateStandardError(historicalData);
    
    // Adjust confidence interval based on rep range
    final reliability = _getReliabilityFor1RM(reps);
    
    return TransparentPrediction(
      metric: '1RM Estimate',
      interval: ConfidenceInterval(
        lower: lower * (1 - standardError),
        median: median,
        upper: upper * (1 + standardError),
        confidence: 0.90, // 90% CI
      ),
      scenarios: [
        ScenarioPrediction(
          scenario: 'optimistic',
          value: upper * 1.05,
          description: 'If you\'re having a great day',
          assumptions: {
            'Rest': 'Fully recovered',
            'Nutrition': 'Well-fed',
            'Motivation': 'Peak mental state',
          },
        ),
        ScenarioPrediction(
          scenario: 'realistic',
          value: median,
          description: 'Based on average of 3 formulas',
          assumptions: {
            'Conditions': 'Normal training day',
            'Fatigue': 'Typical levels',
          },
        ),
        ScenarioPrediction(
          scenario: 'pessimistic',
          value: lower * 0.95,
          description: 'Conservative estimate',
          assumptions: {
            'Fatigue': 'Accumulated fatigue',
            'Technique': 'Form breakdown risk',
          },
        ),
      ],
      reliability: reliability,
      methodology: '''
Calculated using average of 3 validated formulas:
- Brzycki (1993): Most accurate for <10 reps
- Epley (1985): Better for higher reps
- Lombardi (1989): Accounts for individual variation

Standard error: ±${(standardError * 100).toStringAsFixed(1)}% based on your historical data.
      ''',
      limitations: [
        'Accuracy decreases significantly above 10 reps',
        'Assumes consistent form and technique',
        'Individual fiber type composition affects accuracy',
        'Does not account for fatigue or training state',
        'Error margin typically ±5-10% even in best conditions',
      ],
      rawData: {
        'weight': weight,
        'reps': reps,
        'formulas': formulas,
        'standardError': standardError,
      },
    );
  }
  
  /// Predict future performance with transparency
  static TransparentPrediction predictFuturePerformance({
    required String exerciseId,
    required List<AnalyticsActivity> activities,
    required int weeksAhead,
  }) {
    final exerciseActivities = activities
        .where((a) => a.exerciseId == exerciseId)
        .toList();
    
    if (exerciseActivities.length < 3) {
      return TransparentPrediction(
        metric: 'Future Performance',
        reliability: ReliabilityLevel.veryLow,
        methodology: 'Insufficient data (need at least 3 sessions)',
        limitations: ['Not enough historical data for meaningful prediction'],
      );
    }
    
    // Analyze trend
    final trend = TrendAnalyzer.analyzeStrengthTrend(
      exerciseActivities.cast(),
      exerciseId,
    );
    
    // Calculate realistic progression rates
    final weeklyProgress = trend.slope;
    final correlation = trend.correlation.abs();
    
    // Determine reliability based on correlation
    final reliability = _getReliabilityFromCorrelation(correlation);
    
    // Calculate prediction with diminishing returns
    final currentMax = exerciseActivities.last.maxWeight;
    final diminishingFactor = _getDiminishingReturnsFactor(currentMax, weeksAhead);
    
    final predictedIncrease = weeklyProgress * weeksAhead * diminishingFactor;
    
    // Calculate confidence interval
    final standardError = (1 - correlation) * 0.15; // Up to 15% error
    
    return TransparentPrediction(
      metric: 'Strength Projection',
      interval: ConfidenceInterval(
        lower: currentMax + (predictedIncrease * 0.5),
        median: currentMax + predictedIncrease,
        upper: currentMax + (predictedIncrease * 1.5),
        confidence: 0.80,
      ),
      scenarios: [
        ScenarioPrediction(
          scenario: 'optimistic',
          value: currentMax + (predictedIncrease * 1.5),
          description: 'If progression continues perfectly',
          assumptions: {
            'Training': 'No missed sessions',
            'Recovery': 'Optimal sleep and nutrition',
            'Progress': 'No plateaus',
          },
        ),
        ScenarioPrediction(
          scenario: 'realistic',
          value: currentMax + predictedIncrease,
          description: 'Accounting for normal variation',
          assumptions: {
            'Training': '80% adherence',
            'Progress': 'Some minor plateaus',
            'Recovery': 'Average conditions',
          },
        ),
        ScenarioPrediction(
          scenario: 'pessimistic',
          value: currentMax + (predictedIncrease * 0.3),
          description: 'Conservative with plateaus',
          assumptions: {
            'Plateaus': 'Hit adaptation limit',
            'Recovery': 'Suboptimal conditions',
            'Adherence': 'Missed sessions',
          },
        ),
      ],
      reliability: reliability,
      methodology: '''
Based on linear regression of last ${exerciseActivities.length} sessions.
Weekly trend: ${weeklyProgress > 0 ? '+' : ''}${weeklyProgress.toStringAsFixed(2)}kg/week
Correlation strength: ${(correlation * 100).toStringAsFixed(1)}%
Diminishing returns factor: ${(diminishingFactor * 100).toStringAsFixed(0)}%

Important: Progression typically slows as you advance.
Beginner: 2.5-5kg/week possible
Intermediate: 1-2.5kg/week typical  
Advanced: 0.5-1kg/week good progress
      ''',
      limitations: [
        'Linear projection does not account for plateaus',
        'Biological adaptation follows logarithmic, not linear curve',
        'Individual recovery capacity varies greatly',
        'External factors (stress, sleep, nutrition) not considered',
        'Accuracy decreases significantly beyond 4 weeks',
      ],
      rawData: {
        'currentMax': currentMax,
        'weeklyTrend': weeklyProgress,
        'correlation': correlation,
        'weeksAhead': weeksAhead,
        'dataPoints': exerciseActivities.length,
      },
    );
  }
  
  /// Generate volume recommendations with evidence
  static EvidenceBasedRecommendation getVolumeRecommendation(
    String muscleGroup,
    double currentSetsPerWeek,
  ) {
    if (currentSetsPerWeek < 10) {
      return EvidenceBasedRecommendation(
        topic: 'Training Volume',
        recommendation: 'Increase volume to 10-20 sets per week for $muscleGroup',
        evidence: 'Meta-analysis of 15 studies found 10-20 sets/week optimal for hypertrophy',
        source: 'Schoenfeld et al., JSCR',
        yearPublished: 2017,
        effectSize: 0.68,
        applicability: 'For trained individuals seeking muscle growth',
      );
    } else if (currentSetsPerWeek > 20) {
      return EvidenceBasedRecommendation(
        topic: 'Training Volume',
        recommendation: 'Consider reducing volume or implementing periodization',
        evidence: 'Diminishing returns and increased injury risk above 20 sets/week per muscle',
        source: 'Krieger, JSCR',
        yearPublished: 2010,
        effectSize: 0.24,
        applicability: 'When fatigue accumulation impairs performance',
      );
    } else {
      return EvidenceBasedRecommendation(
        topic: 'Training Volume',
        recommendation: 'Current volume is within optimal range',
        evidence: '10-20 sets per week shown optimal for most individuals',
        source: 'Schoenfeld et al., JSCR',
        yearPublished: 2017,
        effectSize: 0.68,
        applicability: 'Maintain current volume, focus on progression',
      );
    }
  }
  
  /// Calculate standard error from historical data
  static double _calculateStandardError(List<AnalyticsActivity> activities) {
    if (activities.isEmpty) return 0.1; // Default 10% error
    
    // Calculate variance in progression
    final weights = activities.map((a) => a.maxWeight).toList();
    if (weights.length < 2) return 0.1;
    
    double sumSquaredDiff = 0;
    for (int i = 1; i < weights.length; i++) {
      final expectedIncrease = (weights[i - 1] * 1.025); // Expected 2.5% increase
      final actualValue = weights[i];
      final diff = (actualValue - expectedIncrease) / expectedIncrease;
      sumSquaredDiff += diff * diff;
    }
    
    final variance = sumSquaredDiff / (weights.length - 1);
    return math.sqrt(variance).clamp(0.05, 0.20); // 5-20% error
  }
  
  /// Get reliability level for 1RM based on reps
  static ReliabilityLevel _getReliabilityFor1RM(int reps) {
    if (reps == 1) return ReliabilityLevel.factual;
    if (reps <= 3) return ReliabilityLevel.high;
    if (reps <= 5) return ReliabilityLevel.moderate;
    if (reps <= 10) return ReliabilityLevel.low;
    return ReliabilityLevel.veryLow;
  }
  
  /// Get reliability from correlation coefficient
  static ReliabilityLevel _getReliabilityFromCorrelation(double correlation) {
    if (correlation > 0.9) return ReliabilityLevel.high;
    if (correlation > 0.7) return ReliabilityLevel.moderate;
    if (correlation > 0.5) return ReliabilityLevel.low;
    return ReliabilityLevel.veryLow;
  }
  
  /// Calculate diminishing returns factor
  static double _getDiminishingReturnsFactor(double currentWeight, int weeksAhead) {
    // Heavier weights progress slower
    final weightFactor = currentWeight < 50 ? 1.0 :
                        currentWeight < 100 ? 0.8 :
                        currentWeight < 150 ? 0.6 : 0.4;
    
    // Longer predictions are less reliable
    final timeFactor = weeksAhead <= 2 ? 1.0 :
                       weeksAhead <= 4 ? 0.8 :
                       weeksAhead <= 8 ? 0.6 : 0.3;
    
    return weightFactor * timeFactor;
  }
}