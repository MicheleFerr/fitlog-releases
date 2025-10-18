/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 *
 * 📁 Layer: features/home/domain/entities
 * 🎯 Feature: home
 * 🔧 Type: entity
 *
 * Entità che rappresenta un'anomalia rilevata nei dati di allenamento
 * Usata per identificare e correggere dati potenzialmente errati
 */

/// Tipo di anomalia rilevata nei dati
enum AnomalyType {
  impossibleWeight,    // Peso irrealistico (es. 500kg squat)
  impossibleReps,      // Ripetizioni impossibili (es. 100 reps)
  negativeValues,      // Valori negativi
  futureDate,          // Data nel futuro
  extremeWeightJump,   // Salto di peso >40% (già rilevato ma serve UI)
  zeroValues,          // Valori a zero quando non dovrebbero
  outlierVolume,       // Volume totale outlier rispetto alla media
  duplicateEntry,      // Entry duplicata (stesso esercizio, peso, reps nello stesso minuto)
}

/// Severità dell'anomalia (per prioritizzazione UI)
enum AnomalySeverity {
  critical,  // 🔴 Dati certamente errati (es. peso negativo)
  warning,   // 🟠 Dati probabilmente errati (es. weight jump eccessivo)
  info,      // 🔵 Dati sospetti ma possibili (es. outlier volume)
}

/// Azione suggerita per risolvere l'anomalia
enum AnomalyAction {
  correct,   // Correggere il valore
  remove,    // Rimuovere l'entry
  dismiss,   // Dismissare il warning
  verify,    // Verificare manualmente
}

/// Entità che rappresenta un'anomalia rilevata nei dati
class DataAnomaly { // Insights basati su questi dati

  const DataAnomaly({
    required this.id,
    required this.type,
    required this.severity,
    required this.exerciseName,
    required this.activityId,
    required this.detectedAt,
    required this.anomalousData,
    required this.description,
    required this.recommendation,
    this.suggestedCorrection,
    required this.suggestedAction,
    this.resolved = false,
    this.resolvedAt,
    this.resolutionAction,
    this.affectedInsightHashes,
  });

  /// Deserializzazione da storage
  factory DataAnomaly.fromJson(Map<String, dynamic> json) {
    return DataAnomaly(
      id: json['id'] as String,
      type: AnomalyType.values.firstWhere((e) => e.name == json['type']),
      severity: AnomalySeverity.values.firstWhere((e) => e.name == json['severity']),
      exerciseName: json['exerciseName'] as String,
      activityId: json['activityId'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      anomalousData: Map<String, dynamic>.from(json['anomalousData'] as Map),
      description: json['description'] as String,
      recommendation: json['recommendation'] as String,
      suggestedCorrection: json['suggestedCorrection'] != null
          ? Map<String, dynamic>.from(json['suggestedCorrection'] as Map)
          : null,
      suggestedAction: AnomalyAction.values.firstWhere((e) => e.name == json['suggestedAction']),
      resolved: json['resolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      resolutionAction: json['resolutionAction'] as String?,
      affectedInsightHashes: json['affectedInsightHashes'] != null
          ? List<String>.from(json['affectedInsightHashes'] as List)
          : null,
    );
  }
  final String id;
  final AnomalyType type;
  final AnomalySeverity severity;
  final String exerciseName;
  final String activityId;
  final DateTime detectedAt;

  // Dati dell'anomalia
  final Map<String, dynamic> anomalousData;
  final String description;
  final String recommendation;

  // Valori suggeriti per correzione
  final Map<String, dynamic>? suggestedCorrection;

  // Azione consigliata
  final AnomalyAction suggestedAction;

  // Stato di risoluzione
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolutionAction; // 'corrected', 'removed', 'dismissed'

  // Impatto sugli insights
  final List<String>? affectedInsightHashes;

  /// Copy with for updates
  DataAnomaly copyWith({
    String? id,
    AnomalyType? type,
    AnomalySeverity? severity,
    String? exerciseName,
    String? activityId,
    DateTime? detectedAt,
    Map<String, dynamic>? anomalousData,
    String? description,
    String? recommendation,
    Map<String, dynamic>? suggestedCorrection,
    AnomalyAction? suggestedAction,
    bool? resolved,
    DateTime? resolvedAt,
    String? resolutionAction,
    List<String>? affectedInsightHashes,
  }) {
    return DataAnomaly(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      exerciseName: exerciseName ?? this.exerciseName,
      activityId: activityId ?? this.activityId,
      detectedAt: detectedAt ?? this.detectedAt,
      anomalousData: anomalousData ?? this.anomalousData,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      suggestedCorrection: suggestedCorrection ?? this.suggestedCorrection,
      suggestedAction: suggestedAction ?? this.suggestedAction,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionAction: resolutionAction ?? this.resolutionAction,
      affectedInsightHashes: affectedInsightHashes ?? this.affectedInsightHashes,
    );
  }

  /// Serializzazione per storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'exerciseName': exerciseName,
      'activityId': activityId,
      'detectedAt': detectedAt.toIso8601String(),
      'anomalousData': anomalousData,
      'description': description,
      'recommendation': recommendation,
      'suggestedCorrection': suggestedCorrection,
      'suggestedAction': suggestedAction.name,
      'resolved': resolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionAction': resolutionAction,
      'affectedInsightHashes': affectedInsightHashes,
    };
  }
}
