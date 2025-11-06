import 'package:flutter/foundation.dart';

/// Risultato dell'analisi di pattern detection
@immutable
class PatternResult {
  const PatternResult({
    required this.pattern,
    required this.occurrences,
    required this.confidence,
  });

  /// Factory per creare un pattern result vuoto/fallback
  factory PatternResult.empty() {
    return const PatternResult(
      pattern: [],
      occurrences: 0,
      confidence: 0.0,
    );
  }

  /// Factory per creare da JSON (per caching)
  factory PatternResult.fromJson(Map<String, dynamic> json) {
    return PatternResult(
      pattern: List<String>.from(json['pattern'] as List),
      occurrences: json['occurrences'] as int,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// La sequenza del pattern identificato
  /// Es: ["PUSH", "PULL", "LEGS"] o ["UPPER", "LOWER", "REST"]
  final List<String> pattern;

  /// Numero di volte che il pattern si è ripetuto nella sequenza
  final int occurrences;

  /// Confidence score del pattern (0.0 - 1.0)
  /// Indica quanto accuratamente il pattern matcha la sequenza
  final double confidence;

  /// Predice il prossimo workout basato sul pattern
  ///
  /// [recentWorkouts] deve essere la sequenza recente di workout normalizzati
  String predictNext(List<String> recentWorkouts) {
    if (pattern.isEmpty) {
      throw ArgumentError('Pattern is empty');
    }

    // Trova la posizione corrente nel pattern
    // Usiamo modulo per gestire pattern ciclici
    final position = recentWorkouts.length % pattern.length;
    return pattern[position];
  }

  /// Predice i prossimi N workout basati sul pattern
  List<String> predictNextN(List<String> recentWorkouts, int n) {
    if (pattern.isEmpty) {
      throw ArgumentError('Pattern is empty');
    }

    final predictions = <String>[];
    final startPosition = recentWorkouts.length % pattern.length;

    for (int i = 0; i < n; i++) {
      final position = (startPosition + i) % pattern.length;
      predictions.add(pattern[position]);
    }

    return predictions;
  }

  /// Calcola quanti giorni mancano fino al prossimo workout di un tipo specifico
  int daysUntilWorkoutType(List<String> recentWorkouts, String workoutType) {
    if (!pattern.contains(workoutType)) {
      return -1; // Tipo non presente nel pattern
    }

    final currentPosition = recentWorkouts.length % pattern.length;

    // Cerca il prossimo occurrence del tipo richiesto
    for (int i = 1; i <= pattern.length; i++) {
      final checkPosition = (currentPosition + i) % pattern.length;
      if (pattern[checkPosition] == workoutType) {
        return i;
      }
    }

    return -1; // Non dovrebbe mai arrivare qui se il tipo è nel pattern
  }

  /// Verifica se il pattern include giorni di riposo
  bool get includesRest => pattern.contains('REST');

  /// Calcola la frequenza di allenamento settimanale basata sul pattern
  double get weeklyFrequency {
    if (pattern.isEmpty) return 0.0;

    final workoutDays = pattern.where((day) => day != 'REST').length;
    final totalDays = pattern.length;

    // Assumiamo che il pattern si ripete, quindi scala a settimana
    return (workoutDays / totalDays) * 7;
  }

  /// Ottiene una descrizione human-readable del pattern
  String get description {
    if (pattern.isEmpty) return 'No pattern';

    // Rimuovi duplicati consecutivi per descrizione più pulita
    final simplified = <String>[];
    String? last;

    for (final workout in pattern) {
      if (workout != last) {
        simplified.add(workout);
        last = workout;
      }
    }

    return simplified.join(' → ');
  }

  /// Ottiene una descrizione localizzata del pattern
  String getLocalizedDescription(Map<String, String> translations) {
    if (pattern.isEmpty) return translations['no_pattern'] ?? 'No pattern';

    final localizedPattern = pattern.map((type) {
      return translations[type.toLowerCase()] ?? type;
    }).toList();

    return localizedPattern.join(' → ');
  }

  /// Verifica se un workout suggerito è coerente con il pattern
  bool isConsistentWithPattern(List<String> recentWorkouts, String suggestedWorkout) {
    final predicted = predictNext(recentWorkouts);
    return predicted == suggestedWorkout;
  }

  /// Calcola il "pattern adherence score" basato sugli ultimi workout
  ///
  /// Verifica quanto l'utente ha seguito il pattern recentemente
  double calculateAdherenceScore(List<String> actualWorkouts) {
    if (pattern.isEmpty || actualWorkouts.isEmpty) return 0.0;

    int matches = 0;
    int comparisons = 0;

    for (int i = 0; i < actualWorkouts.length; i++) {
      final expectedPosition = i % pattern.length;
      final expected = pattern[expectedPosition];
      final actual = actualWorkouts[i];

      // Skip REST days nel calcolo adherence
      if (expected != 'REST') {
        if (expected == actual) {
          matches++;
        }
        comparisons++;
      }
    }

    return comparisons > 0 ? matches / comparisons : 0.0;
  }

  @override
  String toString() {
    return 'PatternResult(pattern: ${pattern.join("→")}, occurrences: $occurrences, confidence: ${confidence.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatternResult &&
        listEquals(other.pattern, pattern) &&
        other.occurrences == occurrences &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return pattern.hashCode ^ occurrences.hashCode ^ confidence.hashCode;
  }

  /// Converte a JSON (per caching)
  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern,
      'occurrences': occurrences,
      'confidence': confidence,
    };
  }
}