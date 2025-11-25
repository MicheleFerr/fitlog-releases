/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Data models per explainability AI Coach
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// 🔍 Spiegazione di come l'AI è arrivata a un insight
class InsightExplanation {
  const InsightExplanation({
    required this.insightType,
    required this.conclusion,
    required this.calculationSteps,
    required this.dataPoints,
    required this.thresholds,
    required this.scientificBasis,
  });

  final String insightType;
  final String conclusion;
  final List<CalculationStep> calculationSteps;
  final List<DataPointEvidence> dataPoints;
  final Map<String, dynamic> thresholds;
  final ScientificReference scientificBasis;
}

/// 🧮 Singolo step di calcolo
class CalculationStep {
  const CalculationStep({
    required this.stepNumber,
    required this.description,
    required this.formula,
    required this.result,
    this.interpretation,
  });

  final int stepNumber;
  final String description;
  final String formula;
  final String result;
  final String? interpretation;
}

/// 📌 Evidenza da dati utente
class DataPointEvidence {
  const DataPointEvidence({
    required this.label,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.isAnomaly = false,
  });

  final String label;
  final double value;
  final String unit;
  final DateTime timestamp;
  final bool isAnomaly;
}

/// 📚 Riferimento scientifico
class ScientificReference {
  const ScientificReference({
    required this.authors,
    required this.year,
    required this.title,
    required this.journal,
    this.doi,
  });

  final String authors;
  final int year;
  final String title;
  final String journal;
  final String? doi;

  String get citation => '$authors ($year). $title. $journal';
}

/// 📅 Timeline eventi rilevanti
class DataTimeline {
  const DataTimeline({
    required this.events,
  });

  final List<TimelineEvent> events;

  /// Filtra eventi per tipo
  List<TimelineEvent> filterByType(TimelineEventType type) {
    return events.where((e) => e.type == type).toList();
  }
}

enum TimelineEventType {
  weightIncrease,
  volumeSpike,
  plateau,
  injury,
  deload,
  achievement,
}

class TimelineEvent {
  const TimelineEvent({
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    this.impact,
  });

  final DateTime date;
  final TimelineEventType type;
  final String title;
  final String description;
  final String? impact;

  IconData get icon {
    switch (type) {
      case TimelineEventType.weightIncrease:
        return AppIcons.trendUp;
      case TimelineEventType.volumeSpike:
        return AppIcons.lineChart;
      case TimelineEventType.plateau:
        return AppIcons.trendFlat;
      case TimelineEventType.injury:
        return AppIcons.warning;
      case TimelineEventType.deload:
        return AppIcons.batteryChargingFull;
      case TimelineEventType.achievement:
        return AppIcons.achievement;
    }
  }

  Color get color {
    switch (type) {
      case TimelineEventType.weightIncrease:
      case TimelineEventType.achievement:
        return Colors.green;
      case TimelineEventType.volumeSpike:
        return Colors.blue;
      case TimelineEventType.plateau:
        return Colors.orange;
      case TimelineEventType.injury:
        return Colors.red;
      case TimelineEventType.deload:
        return Colors.purple;
    }
  }
}
