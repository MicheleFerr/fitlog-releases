/// 🏋️‍♂️ GymBro TrackLog - Smart Workout Suggestion
///
/// 📁 Layer: features/workout/domain/entities
/// 🎯 Feature: Smart Workout Suggestion
/// 🔧 Type: entity
///
/// Entity per il feedback utente sulle suggestions
/// Usato per tracking delle rejection e learning algorithm
///
/// Reference: Fitbod feedback system, JMIR 2024

/// Motivo del rifiuto della suggestion
///
/// Ogni motivo ha un comportamento diverso nell'algoritmo:
/// - `tooTired`: Skip template per oggi, suggerisci più leggero
/// - `noTime`: Skip template per oggi, nessuna penalità
/// - `injury`: Blocca gruppo muscolare da suggestions future
/// - `notInMood`: Leggera penalità temporanea
/// - `other`: Log per analytics, nessuna azione automatica
enum RejectionReason {
  /// Troppo stanco - suggeriamo workout più leggero
  tooTired,

  /// Non ho tempo - skip senza penalità
  noTime,

  /// Infortunio - blocca gruppo muscolare
  injury,

  /// Non sono in vena - leggera penalità
  notInMood,

  /// Altro motivo (richiede customReason)
  other,
}

/// Extension per RejectionReason con metadata e comportamento
extension RejectionReasonExtension on RejectionReason {
  /// Nome human-readable (English)
  String get displayNameEN => switch (this) {
    RejectionReason.tooTired => 'Too tired',
    RejectionReason.noTime => 'No time',
    RejectionReason.injury => 'Injury',
    RejectionReason.notInMood => 'Not in the mood',
    RejectionReason.other => 'Other reason',
  };

  /// Nome human-readable (Italian)
  String get displayNameIT => switch (this) {
    RejectionReason.tooTired => 'Troppo stanco',
    RejectionReason.noTime => 'Non ho tempo',
    RejectionReason.injury => 'Infortunio',
    RejectionReason.notInMood => 'Non sono in vena',
    RejectionReason.other => 'Altro motivo',
  };

  /// Fattore di penalità per il template suggerito (0.0 - 1.0)
  /// 0.0 = nessuna penalità, 1.0 = penalità massima
  double get penaltyFactor => switch (this) {
    RejectionReason.tooTired => 0.3,   // 30% penalty per oggi
    RejectionReason.noTime => 0.0,     // Nessuna penalità
    RejectionReason.injury => 1.0,     // Blocco completo
    RejectionReason.notInMood => 0.1,  // 10% penalty leggera
    RejectionReason.other => 0.0,      // Nessuna azione automatica
  };

  /// Durata della penalità in ore (0 = nessuna, -1 = permanente fino a reset)
  int get penaltyDurationHours => switch (this) {
    RejectionReason.tooTired => 24,    // Skip per oggi
    RejectionReason.noTime => 0,       // Nessuna durata
    RejectionReason.injury => -1,      // Permanente (manuale reset)
    RejectionReason.notInMood => 12,   // Mezza giornata
    RejectionReason.other => 0,        // Nessuna durata
  };

  /// Se true, blocca l'intero gruppo muscolare (non solo il template)
  bool get blocksMusleGroup => switch (this) {
    RejectionReason.tooTired => false,
    RejectionReason.noTime => false,
    RejectionReason.injury => true,    // Blocca gruppo muscolare
    RejectionReason.notInMood => false,
    RejectionReason.other => false,
  };

  /// Se true, suggerisce alternativa più leggera
  bool get suggestLighterAlternative => switch (this) {
    RejectionReason.tooTired => true,  // Suggerisci più leggero
    RejectionReason.noTime => false,
    RejectionReason.injury => false,
    RejectionReason.notInMood => true, // Suggerisci più leggero
    RejectionReason.other => false,
  };

  /// Richiede customReason obbligatorio
  bool get requiresCustomReason => this == RejectionReason.other;
}

/// Feedback utente su una suggestion
///
/// Traccia:
/// - Se suggestion è stata accettata/rifiutata
/// - Motivo del rifiuto (con custom reason opzionale)
/// - Quale template è stato scelto invece
/// - Timestamp per analytics temporali
class SuggestionFeedback {
  const SuggestionFeedback({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.templateSuggested,
    required this.accepted,
    this.rejectionReason,
    this.customReason,
    this.templateChosen,
    this.muscleGroupAffected,
    this.confidenceAtSuggestion,
  });

  factory SuggestionFeedback.fromJson(Map<String, dynamic> json) {
    return SuggestionFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      templateSuggested: json['templateSuggested'] as String,
      accepted: json['accepted'] as bool,
      rejectionReason: json['rejectionReason'] != null
          ? RejectionReason.values.firstWhere(
              (e) => e.name == json['rejectionReason'],
              orElse: () => RejectionReason.other,
            )
          : null,
      customReason: json['customReason'] as String?,
      templateChosen: json['templateChosen'] as String?,
      muscleGroupAffected: json['muscleGroupAffected'] as String?,
      confidenceAtSuggestion: (json['confidenceAtSuggestion'] as num?)?.toDouble(),
    );
  }

  /// ID univoco del feedback
  final String id;

  /// ID utente (per Firebase)
  final String userId;

  /// Timestamp della decisione
  final DateTime timestamp;

  /// Template che era stato suggerito
  final String templateSuggested;

  /// Se l'utente ha accettato la suggestion
  final bool accepted;

  /// Motivo del rifiuto (null se accepted = true)
  final RejectionReason? rejectionReason;

  /// Motivo custom (richiesto se rejectionReason = other)
  final String? customReason;

  /// Template scelto dall'utente invece (null se accepted o nessuna scelta)
  final String? templateChosen;

  /// Gruppo muscolare principale del template suggerito
  final String? muscleGroupAffected;

  /// Confidence score della suggestion al momento del feedback
  final double? confidenceAtSuggestion;

  /// Crea feedback per acceptance
  factory SuggestionFeedback.accepted({
    required String id,
    required String userId,
    required String templateSuggested,
    String? muscleGroupAffected,
    double? confidenceAtSuggestion,
  }) {
    return SuggestionFeedback(
      id: id,
      userId: userId,
      timestamp: DateTime.now(),
      templateSuggested: templateSuggested,
      accepted: true,
      muscleGroupAffected: muscleGroupAffected,
      confidenceAtSuggestion: confidenceAtSuggestion,
    );
  }

  /// Crea feedback per rejection
  factory SuggestionFeedback.rejected({
    required String id,
    required String userId,
    required String templateSuggested,
    required RejectionReason reason,
    String? customReason,
    String? templateChosen,
    String? muscleGroupAffected,
    double? confidenceAtSuggestion,
  }) {
    return SuggestionFeedback(
      id: id,
      userId: userId,
      timestamp: DateTime.now(),
      templateSuggested: templateSuggested,
      accepted: false,
      rejectionReason: reason,
      customReason: customReason,
      templateChosen: templateChosen,
      muscleGroupAffected: muscleGroupAffected,
      confidenceAtSuggestion: confidenceAtSuggestion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'templateSuggested': templateSuggested,
      'accepted': accepted,
      'rejectionReason': rejectionReason?.name,
      'customReason': customReason,
      'templateChosen': templateChosen,
      'muscleGroupAffected': muscleGroupAffected,
      'confidenceAtSuggestion': confidenceAtSuggestion,
    };
  }

  SuggestionFeedback copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? templateSuggested,
    bool? accepted,
    RejectionReason? rejectionReason,
    String? customReason,
    String? templateChosen,
    String? muscleGroupAffected,
    double? confidenceAtSuggestion,
  }) {
    return SuggestionFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      templateSuggested: templateSuggested ?? this.templateSuggested,
      accepted: accepted ?? this.accepted,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      customReason: customReason ?? this.customReason,
      templateChosen: templateChosen ?? this.templateChosen,
      muscleGroupAffected: muscleGroupAffected ?? this.muscleGroupAffected,
      confidenceAtSuggestion: confidenceAtSuggestion ?? this.confidenceAtSuggestion,
    );
  }

  @override
  String toString() {
    return 'SuggestionFeedback('
        'id: $id, '
        'accepted: $accepted, '
        'template: $templateSuggested, '
        'reason: ${rejectionReason?.name ?? "N/A"}'
        ')';
  }
}
