/// 🏋️‍♂️ GymBro TrackLog - Smart Workout Suggestion
///
/// 📁 Layer: features/workout/domain/entities
/// 🎯 Feature: Smart Workout Suggestion
/// 🔧 Type: entity
///
/// Entity per la gestione dei conflitti muscoli antagonisti
/// Previene suggestioni quando l'antagonista è ancora affaticato
///
/// Reference: Bartolomei 2017, principi di bilanciamento muscolare

import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_distribution_data.dart';

/// Coppie di muscoli antagonisti
///
/// I muscoli antagonisti lavorano in coppia:
/// - Quando uno si contrae, l'altro si rilassa
/// - Allenare uno quando l'altro è affaticato può causare
///   squilibri posturali o aumentare rischio infortuni
///
/// Reference: Fitbod muscle pairing, JMIR 2024
enum AntagonistPair {
  /// Petto ↔ Schiena (push/pull orizzontale)
  chestBack,

  /// Quadricipiti ↔ Femorali (estensori/flessori ginocchio)
  quadsHamstrings,

  /// Bicipiti ↔ Tricipiti (flessori/estensori gomito)
  bicepsTriceps,

  /// Deltoide Anteriore ↔ Deltoide Posteriore
  anteriorPosteriorDelt,
}

/// Extension per AntagonistPair con metadata
extension AntagonistPairExtension on AntagonistPair {
  /// Nome del muscolo primario (English)
  String get primaryMuscleEN => switch (this) {
    AntagonistPair.chestBack => 'Chest',
    AntagonistPair.quadsHamstrings => 'Quadriceps',
    AntagonistPair.bicepsTriceps => 'Biceps',
    AntagonistPair.anteriorPosteriorDelt => 'Front Shoulders',
  };

  /// Nome del muscolo antagonista (English)
  String get antagonistMuscleEN => switch (this) {
    AntagonistPair.chestBack => 'Back',
    AntagonistPair.quadsHamstrings => 'Hamstrings',
    AntagonistPair.bicepsTriceps => 'Triceps',
    AntagonistPair.anteriorPosteriorDelt => 'Rear Shoulders',
  };

  /// Nome del muscolo primario (Italian)
  String get primaryMuscleIT => switch (this) {
    AntagonistPair.chestBack => 'Petto',
    AntagonistPair.quadsHamstrings => 'Quadricipiti',
    AntagonistPair.bicepsTriceps => 'Bicipiti',
    AntagonistPair.anteriorPosteriorDelt => 'Deltoide Anteriore',
  };

  /// Nome del muscolo antagonista (Italian)
  String get antagonistMuscleIT => switch (this) {
    AntagonistPair.chestBack => 'Schiena',
    AntagonistPair.quadsHamstrings => 'Femorali',
    AntagonistPair.bicepsTriceps => 'Tricipiti',
    AntagonistPair.anteriorPosteriorDelt => 'Deltoide Posteriore',
  };

  /// MuscleGroup corrispondente al muscolo primario
  MuscleGroup? get primaryMuscleGroup => switch (this) {
    AntagonistPair.chestBack => MuscleGroup.petto,
    AntagonistPair.quadsHamstrings => MuscleGroup.gambe,
    AntagonistPair.bicepsTriceps => MuscleGroup.braccia,
    AntagonistPair.anteriorPosteriorDelt => MuscleGroup.spalle,
  };

  /// MuscleGroup corrispondente all'antagonista
  MuscleGroup? get antagonistMuscleGroup => switch (this) {
    AntagonistPair.chestBack => MuscleGroup.schiena,
    AntagonistPair.quadsHamstrings => MuscleGroup.gambe, // Same group, different muscles
    AntagonistPair.bicepsTriceps => MuscleGroup.braccia, // Same group, different muscles
    AntagonistPair.anteriorPosteriorDelt => MuscleGroup.spalle, // Same group, different muscles
  };

  /// Soglia di readiness minima per l'antagonista (sotto = warning)
  double get minAntagonistReadiness => 0.60; // 60%

  /// Soglia di readiness minima per il primario (sopra = ready)
  double get minPrimaryReadiness => 0.70; // 70%
}

/// Rappresenta un conflitto tra muscolo primario e antagonista
///
/// Esempio:
/// - Vuoi allenare Petto (readiness 85%)
/// - Ma Schiena è ancora affaticata (readiness 45%)
/// - → Conflitto! Warning all'utente
class AntagonistConflict {
  const AntagonistConflict({
    required this.pair,
    required this.primaryReadiness,
    required this.antagonistReadiness,
    required this.templateName,
    this.suggestedAlternative,
    this.lastAntagonistWorkout,
    this.hoursUntilAntagonistReady,
  });

  factory AntagonistConflict.fromJson(Map<String, dynamic> json) {
    return AntagonistConflict(
      pair: AntagonistPair.values.firstWhere(
        (e) => e.name == json['pair'],
        orElse: () => AntagonistPair.chestBack,
      ),
      primaryReadiness: (json['primaryReadiness'] as num).toDouble(),
      antagonistReadiness: (json['antagonistReadiness'] as num).toDouble(),
      templateName: json['templateName'] as String,
      suggestedAlternative: json['suggestedAlternative'] as String?,
      lastAntagonistWorkout: json['lastAntagonistWorkout'] != null
          ? DateTime.parse(json['lastAntagonistWorkout'] as String)
          : null,
      hoursUntilAntagonistReady: json['hoursUntilAntagonistReady'] as int?,
    );
  }

  /// La coppia di muscoli coinvolta
  final AntagonistPair pair;

  /// Readiness del muscolo primario (0.0 - 1.0)
  final double primaryReadiness;

  /// Readiness dell'antagonista (0.0 - 1.0)
  final double antagonistReadiness;

  /// Nome del template che causa il conflitto
  final String templateName;

  /// Template alternativo suggerito (null se non disponibile)
  final String? suggestedAlternative;

  /// Ultimo allenamento dell'antagonista
  final DateTime? lastAntagonistWorkout;

  /// Ore rimanenti prima che l'antagonista sia pronto
  final int? hoursUntilAntagonistReady;

  /// Percentuale di readiness primario formattata
  String get primaryReadinessPercent => '${(primaryReadiness * 100).round()}%';

  /// Percentuale di readiness antagonista formattata
  String get antagonistReadinessPercent => '${(antagonistReadiness * 100).round()}%';

  /// Differenza tra readiness (quanto è sbilanciato)
  double get readinessDelta => primaryReadiness - antagonistReadiness;

  /// Severità del conflitto (0.0 = lieve, 1.0 = grave)
  double get severity {
    // Severity basata su quanto l'antagonista è sotto la soglia
    final threshold = pair.minAntagonistReadiness;
    if (antagonistReadiness >= threshold) return 0.0;

    final deficit = threshold - antagonistReadiness;
    return (deficit / threshold).clamp(0.0, 1.0);
  }

  /// Se il conflitto è abbastanza grave da mostrare warning
  bool get shouldShowWarning => severity > 0.2; // >20% severity

  /// Se il conflitto è abbastanza grave da bloccare la suggestion
  bool get shouldBlockSuggestion => severity > 0.5; // >50% severity

  Map<String, dynamic> toJson() {
    return {
      'pair': pair.name,
      'primaryReadiness': primaryReadiness,
      'antagonistReadiness': antagonistReadiness,
      'templateName': templateName,
      'suggestedAlternative': suggestedAlternative,
      'lastAntagonistWorkout': lastAntagonistWorkout?.toIso8601String(),
      'hoursUntilAntagonistReady': hoursUntilAntagonistReady,
    };
  }

  AntagonistConflict copyWith({
    AntagonistPair? pair,
    double? primaryReadiness,
    double? antagonistReadiness,
    String? templateName,
    String? suggestedAlternative,
    DateTime? lastAntagonistWorkout,
    int? hoursUntilAntagonistReady,
  }) {
    return AntagonistConflict(
      pair: pair ?? this.pair,
      primaryReadiness: primaryReadiness ?? this.primaryReadiness,
      antagonistReadiness: antagonistReadiness ?? this.antagonistReadiness,
      templateName: templateName ?? this.templateName,
      suggestedAlternative: suggestedAlternative ?? this.suggestedAlternative,
      lastAntagonistWorkout: lastAntagonistWorkout ?? this.lastAntagonistWorkout,
      hoursUntilAntagonistReady: hoursUntilAntagonistReady ?? this.hoursUntilAntagonistReady,
    );
  }

  @override
  String toString() {
    return 'AntagonistConflict('
        'pair: ${pair.name}, '
        'primary: $primaryReadinessPercent, '
        'antagonist: $antagonistReadinessPercent, '
        'severity: ${(severity * 100).round()}%'
        ')';
  }
}

/// Helper per rilevare conflitti antagonisti
class AntagonistConflictDetector {
  const AntagonistConflictDetector._();

  /// Trova il pair antagonista per un dato MuscleGroup
  /// Nota: alcuni gruppi (gambe, braccia, spalle) hanno antagonisti interni
  static AntagonistPair? findPairForMuscleGroup(MuscleGroup group) {
    return switch (group) {
      MuscleGroup.petto => AntagonistPair.chestBack,
      MuscleGroup.schiena => AntagonistPair.chestBack,
      MuscleGroup.gambe => AntagonistPair.quadsHamstrings,
      MuscleGroup.braccia => AntagonistPair.bicepsTriceps,
      MuscleGroup.spalle => AntagonistPair.anteriorPosteriorDelt,
      MuscleGroup.addome => null, // Addome non ha antagonista diretto
    };
  }

  /// Verifica se c'è un conflitto antagonista
  ///
  /// [primaryGroup]: il gruppo muscolare che si vuole allenare
  /// [readinessScores]: mappa MuscleGroup → readiness (0.0 - 1.0)
  /// [templateName]: nome del template suggerito
  ///
  /// Returns: AntagonistConflict se c'è conflitto, null altrimenti
  static AntagonistConflict? detectConflict({
    required MuscleGroup primaryGroup,
    required Map<MuscleGroup, double> readinessScores,
    required String templateName,
    String? suggestedAlternative,
    Map<MuscleGroup, DateTime>? lastWorkoutDates,
  }) {
    final pair = findPairForMuscleGroup(primaryGroup);
    if (pair == null) return null;

    final primaryReadiness = readinessScores[primaryGroup] ?? 1.0;
    final antagonistGroup = pair.antagonistMuscleGroup;
    final antagonistReadiness = antagonistGroup != null
        ? (readinessScores[antagonistGroup] ?? 1.0)
        : 1.0;

    // Conflitto se: primario ready (>70%) MA antagonista fatigued (<60%)
    final isPrimaryReady = primaryReadiness >= pair.minPrimaryReadiness;
    final isAntagonistFatigued = antagonistReadiness < pair.minAntagonistReadiness;

    if (!isPrimaryReady || !isAntagonistFatigued) {
      return null; // Nessun conflitto
    }

    // Calcola ore rimanenti per antagonista
    int? hoursUntilReady;
    DateTime? lastAntagonistWorkout;
    if (antagonistGroup != null && lastWorkoutDates != null) {
      lastAntagonistWorkout = lastWorkoutDates[antagonistGroup];
      if (lastAntagonistWorkout != null) {
        // Stima basata su recovery standard (72h)
        const standardRecoveryHours = 72;
        final hoursSince = DateTime.now().difference(lastAntagonistWorkout).inHours;
        hoursUntilReady = (standardRecoveryHours - hoursSince).clamp(0, standardRecoveryHours);
      }
    }

    return AntagonistConflict(
      pair: pair,
      primaryReadiness: primaryReadiness,
      antagonistReadiness: antagonistReadiness,
      templateName: templateName,
      suggestedAlternative: suggestedAlternative,
      lastAntagonistWorkout: lastAntagonistWorkout,
      hoursUntilAntagonistReady: hoursUntilReady,
    );
  }
}
