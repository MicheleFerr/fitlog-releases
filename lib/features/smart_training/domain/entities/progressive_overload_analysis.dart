import 'package:uuid/uuid.dart';
import 'smart_training_metrics.dart';

/// Progressive overload analysis and recommendations
class ProgressiveOverloadAnalysis {
  final String id;
  final String userId;
  final String exerciseName;
  final DateTime analysisDate;
  final List<OverloadRecommendation> recommendations;
  final OverloadTrend trend;
  final double progressRate; // Progress per week (0-1 scale)
  final int stallWeeks; // Weeks since last progress
  final bool isProgressing;
  final bool needsDeload;
  final DateTime nextProgressionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressiveOverloadAnalysis({
    String? id,
    required this.userId,
    required this.exerciseName,
    required this.analysisDate,
    required this.recommendations,
    required this.trend,
    required this.progressRate,
    required this.stallWeeks,
    required this.isProgressing,
    required this.needsDeload,
    required this.nextProgressionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'analysisDate': analysisDate.toIso8601String(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'trend': trend.toJson(),
      'progressRate': progressRate,
      'stallWeeks': stallWeeks,
      'isProgressing': isProgressing,
      'needsDeload': needsDeload,
      'nextProgressionDate': nextProgressionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProgressiveOverloadAnalysis.fromJson(Map<String, dynamic> json) {
    return ProgressiveOverloadAnalysis(
      id: json['id'],
      userId: json['userId'],
      exerciseName: json['exerciseName'],
      analysisDate: DateTime.parse(json['analysisDate']),
      recommendations: (json['recommendations'] as List)
          .map((r) => OverloadRecommendation.fromJson(r))
          .toList(),
      trend: OverloadTrend.fromJson(json['trend']),
      progressRate: (json['progressRate'] as num).toDouble(),
      stallWeeks: json['stallWeeks'],
      isProgressing: json['isProgressing'],
      needsDeload: json['needsDeload'],
      nextProgressionDate: DateTime.parse(json['nextProgressionDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// Specific overload recommendation
class OverloadRecommendation {
  final OverloadMethod method;
  final String description;
  final Map<String, dynamic> parameters;
  final double confidence; // 0-1 scale
  final int priority; // 1-5 scale
  final String reasoning;
  final List<String> preconditions;

  OverloadRecommendation({
    required this.method,
    required this.description,
    required this.parameters,
    required this.confidence,
    required this.priority,
    required this.reasoning,
    required this.preconditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method.name,
      'description': description,
      'parameters': parameters,
      'confidence': confidence,
      'priority': priority,
      'reasoning': reasoning,
      'preconditions': preconditions,
    };
  }

  factory OverloadRecommendation.fromJson(Map<String, dynamic> json) {
    return OverloadRecommendation(
      method: OverloadMethod.values.firstWhere(
        (m) => m.name == json['method'],
      ),
      description: json['description'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      confidence: (json['confidence'] as num).toDouble(),
      priority: json['priority'],
      reasoning: json['reasoning'],
      preconditions: List<String>.from(json['preconditions']),
    );
  }
}

/// Trend analysis for progression
class OverloadTrend {
  final double volumeTrend; // Weekly volume change (%)
  final double intensityTrend; // Weekly intensity change (%)
  final double oneRMTrend; // Estimated 1RM progression
  final double fatigueIndex; // Accumulated fatigue
  final int consistencyScore; // 1-10 scale
  final List<TrendDataPoint> volumeHistory;
  final List<TrendDataPoint> intensityHistory;
  final List<TrendDataPoint> oneRMHistory;

  OverloadTrend({
    required this.volumeTrend,
    required this.intensityTrend,
    required this.oneRMTrend,
    required this.fatigueIndex,
    required this.consistencyScore,
    required this.volumeHistory,
    required this.intensityHistory,
    required this.oneRMHistory,
  });

  Map<String, dynamic> toJson() {
    return {
      'volumeTrend': volumeTrend,
      'intensityTrend': intensityTrend,
      'oneRMTrend': oneRMTrend,
      'fatigueIndex': fatigueIndex,
      'consistencyScore': consistencyScore,
      'volumeHistory': volumeHistory.map((p) => p.toJson()).toList(),
      'intensityHistory': intensityHistory.map((p) => p.toJson()).toList(),
      'oneRMHistory': oneRMHistory.map((p) => p.toJson()).toList(),
    };
  }

  factory OverloadTrend.fromJson(Map<String, dynamic> json) {
    return OverloadTrend(
      volumeTrend: (json['volumeTrend'] as num).toDouble(),
      intensityTrend: (json['intensityTrend'] as num).toDouble(),
      oneRMTrend: (json['oneRMTrend'] as num).toDouble(),
      fatigueIndex: (json['fatigueIndex'] as num).toDouble(),
      consistencyScore: json['consistencyScore'],
      volumeHistory: (json['volumeHistory'] as List)
          .map((p) => TrendDataPoint.fromJson(p))
          .toList(),
      intensityHistory: (json['intensityHistory'] as List)
          .map((p) => TrendDataPoint.fromJson(p))
          .toList(),
      oneRMHistory: (json['oneRMHistory'] as List)
          .map((p) => TrendDataPoint.fromJson(p))
          .toList(),
    );
  }
}

/// Data point for trend analysis
class TrendDataPoint {
  final DateTime date;
  final double value;
  final String? annotation;

  TrendDataPoint({
    required this.date,
    required this.value,
    this.annotation,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'annotation': annotation,
    };
  }

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: DateTime.parse(json['date']),
      value: (json['value'] as num).toDouble(),
      annotation: json['annotation'],
    );
  }
}

/// Plateau detection results
class PlateauDetection {
  final bool isPlateaued;
  final int plateauWeeks;
  final PlateauType type;
  final double confidenceScore;
  final List<PlateauIndicator> indicators;
  final List<PlateauBreaker> recommendations;

  PlateauDetection({
    required this.isPlateaued,
    required this.plateauWeeks,
    required this.type,
    required this.confidenceScore,
    required this.indicators,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'isPlateaued': isPlateaued,
      'plateauWeeks': plateauWeeks,
      'type': type.name,
      'confidenceScore': confidenceScore,
      'indicators': indicators.map((i) => i.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
    };
  }

  factory PlateauDetection.fromJson(Map<String, dynamic> json) {
    return PlateauDetection(
      isPlateaued: json['isPlateaued'],
      plateauWeeks: json['plateauWeeks'],
      type: PlateauType.values.firstWhere(
        (t) => t.name == json['type'],
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      indicators: (json['indicators'] as List)
          .map((i) => PlateauIndicator.fromJson(i))
          .toList(),
      recommendations: (json['recommendations'] as List)
          .map((r) => PlateauBreaker.fromJson(r))
          .toList(),
    );
  }
}

/// Types of plateaus
enum PlateauType {
  volume,
  intensity,
  strength,
  technique,
  recovery,
}

/// Plateau indicator
class PlateauIndicator {
  final String name;
  final double value;
  final double threshold;
  final bool isTriggered;
  final String description;

  PlateauIndicator({
    required this.name,
    required this.value,
    required this.threshold,
    required this.isTriggered,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'threshold': threshold,
      'isTriggered': isTriggered,
      'description': description,
    };
  }

  factory PlateauIndicator.fromJson(Map<String, dynamic> json) {
    return PlateauIndicator(
      name: json['name'],
      value: (json['value'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      isTriggered: json['isTriggered'],
      description: json['description'],
    );
  }
}

/// Plateau breaking strategy
class PlateauBreaker {
  final String strategy;
  final String description;
  final Map<String, dynamic> implementation;
  final int durationWeeks;
  final double expectedImprovement;
  final List<String> requirements;

  PlateauBreaker({
    required this.strategy,
    required this.description,
    required this.implementation,
    required this.durationWeeks,
    required this.expectedImprovement,
    required this.requirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      'description': description,
      'implementation': implementation,
      'durationWeeks': durationWeeks,
      'expectedImprovement': expectedImprovement,
      'requirements': requirements,
    };
  }

  factory PlateauBreaker.fromJson(Map<String, dynamic> json) {
    return PlateauBreaker(
      strategy: json['strategy'],
      description: json['description'],
      implementation: Map<String, dynamic>.from(json['implementation']),
      durationWeeks: json['durationWeeks'],
      expectedImprovement: (json['expectedImprovement'] as num).toDouble(),
      requirements: List<String>.from(json['requirements']),
    );
  }
}