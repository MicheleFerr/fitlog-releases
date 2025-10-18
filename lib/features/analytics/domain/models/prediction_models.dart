import 'package:equatable/equatable.dart';

/// Reliability level for predictions and insights
enum ReliabilityLevel {
  veryLow(0.2, '⚠️ Very Low', 'Based on insufficient data or assumptions'),
  low(0.4, '🟡 Low', 'Limited data, high variability expected'),
  moderate(0.6, '🟢 Moderate', 'Based on observable trends'),
  high(0.8, '✅ High', 'Strong correlation in historical data'),
  factual(1.0, '✓ Factual', 'Objective measurement, not prediction');

  final double score;
  final String label;
  final String description;

  const ReliabilityLevel(this.score, this.label, this.description);
}

/// Confidence interval for predictions
class ConfidenceInterval extends Equatable {

  const ConfidenceInterval({
    required this.lower,
    required this.median,
    required this.upper,
    this.confidence = 0.95,
    this.unit = 'kg',
  });
  final double lower;
  final double median;
  final double upper;
  final double confidence; // e.g., 0.95 for 95% CI
  final String unit;

  @override
  List<Object?> get props => [lower, median, upper, confidence, unit];

  String toRangeString() {
    return '${lower.toStringAsFixed(1)}-${upper.toStringAsFixed(1)} $unit';
  }

  String toDetailedString() {
    return 'Expected: ${median.toStringAsFixed(1)} $unit\n'
           'Range (${(confidence * 100).toInt()}% CI): ${toRangeString()}';
  }
}

/// Scenario-based prediction
class ScenarioPrediction extends Equatable {

  const ScenarioPrediction({
    required this.scenario,
    required this.value,
    required this.description,
    this.assumptions = const {},
  });
  final String scenario;
  final double value;
  final String description;
  final Map<String, String> assumptions;

  @override
  List<Object?> get props => [scenario, value, description, assumptions];
}

/// Enhanced prediction with transparency
class TransparentPrediction extends Equatable {

  TransparentPrediction({
    required this.metric,
    this.interval,
    this.scenarios = const [],
    required this.reliability,
    required this.methodology,
    this.limitations = const [],
    this.rawData = const {},
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
  final String metric;
  final ConfidenceInterval? interval;
  final List<ScenarioPrediction> scenarios;
  final ReliabilityLevel reliability;
  final String methodology;
  final List<String> limitations;
  final Map<String, dynamic> rawData;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [
    metric,
    interval,
    scenarios,
    reliability,
    methodology,
    limitations,
    rawData,
    generatedAt,
  ];

  /// Get best case scenario
  ScenarioPrediction? get optimistic => 
    scenarios.firstWhere(
      (s) => s.scenario == 'optimistic',
      orElse: () => scenarios.isNotEmpty ? scenarios.first : const ScenarioPrediction(
        scenario: 'unknown',
        value: 0,
        description: 'No data',
      ),
    );

  /// Get worst case scenario  
  ScenarioPrediction? get pessimistic =>
    scenarios.firstWhere(
      (s) => s.scenario == 'pessimistic',
      orElse: () => scenarios.isNotEmpty ? scenarios.last : const ScenarioPrediction(
        scenario: 'unknown',
        value: 0,
        description: 'No data',
      ),
    );

  /// Get realistic scenario
  ScenarioPrediction? get realistic =>
    scenarios.firstWhere(
      (s) => s.scenario == 'realistic',
      orElse: () => ScenarioPrediction(
        scenario: 'realistic',
        value: interval?.median ?? 0,
        description: 'Based on current trend',
      ),
    );
}

/// Educational information for users
class EducationalInfo extends Equatable {

  const EducationalInfo({
    required this.title,
    required this.explanation,
    this.formula = '',
    this.factors = const [],
    required this.disclaimer,
    this.references = const [],
  });
  final String title;
  final String explanation;
  final String formula;
  final List<String> factors;
  final String disclaimer;
  final List<String> references;

  @override
  List<Object?> get props => [
    title,
    explanation,
    formula,
    factors,
    disclaimer,
    references,
  ];
}

/// Enhanced insight with transparency
class TransparentInsight extends Equatable {

  TransparentInsight({
    String? id,
    required this.title,
    required this.message,
    required this.recommendation,
    required this.reliability,
    required this.reasoning,
    this.education,
    this.supportingData = const {},
    DateTime? generatedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       generatedAt = generatedAt ?? DateTime.now();
  final String id;
  final String title;
  final String message;
  final String recommendation;
  final ReliabilityLevel reliability;
  final String reasoning;
  final EducationalInfo? education;
  final Map<String, dynamic> supportingData;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    recommendation,
    reliability,
    reasoning,
    education,
    supportingData,
    generatedAt,
  ];

  /// Check if insight is based on sufficient data
  bool get hasStrongEvidence => reliability.score >= 0.6;

  /// Get disclaimer text
  String get disclaimer {
    if (reliability == ReliabilityLevel.factual) {
      return 'Based on your recorded data.';
    }
    
    return 'This is ${reliability.label.toLowerCase()} reliability insight. '
           '${reliability.description}. '
           'Individual results may vary significantly.';
  }
}

/// Science-based recommendations
class EvidenceBasedRecommendation extends Equatable {

  const EvidenceBasedRecommendation({
    required this.topic,
    required this.recommendation,
    required this.evidence,
    required this.source,
    required this.yearPublished,
    this.effectSize = 0,
    required this.applicability,
  });
  final String topic;
  final String recommendation;
  final String evidence;
  final String source;
  final int yearPublished;
  final double effectSize; // Cohen's d or similar
  final String applicability;

  @override
  List<Object?> get props => [
    topic,
    recommendation,
    evidence,
    source,
    yearPublished,
    effectSize,
    applicability,
  ];

  String get citation => '$source ($yearPublished)';
  
  String get effectSizeInterpretation {
    if (effectSize < 0.2) return 'Negligible effect';
    if (effectSize < 0.5) return 'Small effect';
    if (effectSize < 0.8) return 'Medium effect';
    return 'Large effect';
  }
}