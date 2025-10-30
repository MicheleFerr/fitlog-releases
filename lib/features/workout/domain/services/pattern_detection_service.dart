import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/domain/models/pattern_result.dart';

/// Service per detectare pattern sequenziali nei workout dell'utente
///
/// Analizza la storia dei workout per identificare pattern ripetitivi
/// come Push→Pull→Legs o Upper→Lower, permettendo predizioni intelligenti
class PatternDetectionService {
  PatternDetectionService({
    required HiveWorkoutDataSource hiveDataSource,
  }) : _hiveDataSource = hiveDataSource;

  final HiveWorkoutDataSource _hiveDataSource;

  /// Estrae sequenze di workout dagli ultimi N giorni
  ///
  /// Se [normalizeNames] = true, normalizza i nomi in categorie (es: "Pull Strong" → "PULL")
  /// Se [normalizeNames] = false, usa i nomi esatti dei workout (es: "Pippo", "Giovanni")
  ///
  /// Returns una lista di nomi workout (normalizzati o raw)
  Future<List<String>> extractSequences({
    required String userId,
    int lookbackDays = 21, // 3 settimane per default
    bool normalizeNames = true, // NUOVO: permette di usare nomi custom
  }) async {
    final startDate = DateTime.now().subtract(Duration(days: lookbackDays));

    final workouts = await _hiveDataSource.getWorkouts(
      userId,
      startDate: startDate,
      limit: 100, // Max workouts da analizzare
    );

    if (workouts.isEmpty) {
      if (kDebugMode) {
        debugPrint('🔍 Pattern Detection: No workouts found in last $lookbackDays days');
      }
      return [];
    }

    // Ordina per data (più vecchio prima) - gestisci startTime nullable
    workouts.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    // Estrai nomi (normalizzati o raw)
    final sequence = <String>[];
    for (final workout in workouts) {
      if (workout.name.isEmpty) continue;

      if (normalizeNames) {
        // Usa normalizzazione per categorie standard
        final normalized = normalizeWorkoutType(workout.name);
        if (normalized != null) {
          sequence.add(normalized);
        }
      } else {
        // Usa il nome esatto del workout (supporto per nomi custom)
        sequence.add(workout.name.trim());
      }
    }

    if (kDebugMode) {
      final mode = normalizeNames ? 'normalized' : 'raw names';
      debugPrint('🔍 Pattern Detection ($mode): Extracted sequence of ${sequence.length} workouts');
      if (sequence.length <= 10) {
        debugPrint('   Sequence: ${sequence.join(" → ")}');
      }
    }

    return sequence;
  }

  /// Normalizza il nome di un workout in una categoria standard
  ///
  /// Es: "Pull Strong", "Tirata Dorsali" → "PULL"
  static String? normalizeWorkoutType(String? workoutName) {
    if (workoutName == null || workoutName.isEmpty) return null;

    final name = workoutName.toLowerCase();

    // Pattern matching per Push/Pull/Legs (PPL)
    if (_matchesPush(name)) return 'PUSH';
    if (_matchesPull(name)) return 'PULL';
    if (_matchesLegs(name)) return 'LEGS';

    // Pattern matching per Upper/Lower
    if (_matchesUpper(name)) return 'UPPER';
    if (_matchesLower(name)) return 'LOWER';

    // Pattern matching per Full Body
    if (_matchesFullBody(name)) return 'FULL_BODY';

    // Pattern matching per body parts specifici
    if (_matchesChest(name)) return 'CHEST';
    if (_matchesBack(name)) return 'BACK';
    if (_matchesShoulders(name)) return 'SHOULDERS';
    if (_matchesArms(name)) return 'ARMS';
    if (_matchesCore(name)) return 'CORE';

    // Se non matcha nessuna categoria, usa il nome originale uppercase
    // Questo permette di detectare pattern anche per workout custom
    return workoutName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '_');
  }

  // Pattern matching methods
  static bool _matchesPush(String name) {
    final pushKeywords = [
      'push', 'spinta', 'petto', 'chest', 'pectoral',
      'tricep', 'tricipiti', 'shoulder', 'spalle', 'deltoidi',
      'bench', 'panca', 'press', 'dip',
      // Variazioni creative/giocose
      'pushiamo', 'spingiamo', 'premi', 'spingi'
    ];
    return pushKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesPull(String name) {
    final pullKeywords = [
      'pull', 'tirata', 'schiena', 'back', 'dorsal',
      'lat', 'bicep', 'bicipiti', 'row', 'rematore',
      'trazioni', 'pullup', 'pulldown', 'deadlift', 'stacco',
      // Variazioni creative/giocose
      'pulliamo', 'tiriamo', 'tira', 'tirare'
    ];
    return pullKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesLegs(String name) {
    final legsKeywords = [
      'leg', 'gamb', 'quad', 'hamstring', 'femorali',
      'glute', 'glutei', 'squat', 'accosciata', 'affondi',
      'lunge', 'calf', 'polpacci', 'lower body',
      // Variazioni creative/giocose
      'legghiamo', 'gambizziamo', 'gambettoni', 'squat day'
    ];
    return legsKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesUpper(String name) {
    final upperKeywords = [
      'upper', 'superiore', 'upper body', 'parte alta',
      'torso', 'busto'
    ];
    return upperKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesLower(String name) {
    final lowerKeywords = [
      'lower', 'inferiore', 'lower body', 'parte bassa',
      'legs', 'gambe'
    ];
    return lowerKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesFullBody(String name) {
    final fullBodyKeywords = [
      'full', 'total', 'completo', 'tutto', 'whole',
      'full body', 'total body', 'corpo libero', 'circuit',
      'circuito', 'hiit', 'crossfit', 'functional', 'funzionale'
    ];
    return fullBodyKeywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesChest(String name) {
    final keywords = ['chest', 'petto', 'pectoral', 'pettorali'];
    return keywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesBack(String name) {
    final keywords = ['back', 'schiena', 'dorsal', 'dorsali'];
    return keywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesShoulders(String name) {
    final keywords = ['shoulder', 'spalle', 'deltoid', 'deltoidi'];
    return keywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesArms(String name) {
    final keywords = ['arm', 'braccia', 'bicep', 'tricep', 'bicipiti', 'tricipiti'];
    return keywords.any((keyword) => name.contains(keyword));
  }

  static bool _matchesCore(String name) {
    final keywords = ['core', 'abs', 'addome', 'addominali', 'plank'];
    return keywords.any((keyword) => name.contains(keyword));
  }
}

/// Simple pattern detector che trova sequenze ripetitive
class SimplePatternDetector {
  /// Detecta un pattern ripetitivo in una sequenza di workout
  ///
  /// Prova pattern di lunghezza 2-7 e ritorna quello con confidence più alta
  PatternResult? detectRepeatingPattern(List<String> sequence) {
    if (sequence.isEmpty) return null;

    // Serve almeno 6 workout per detectare un pattern minimo (2 cicli di 3)
    if (sequence.length < 6) {
      if (kDebugMode) {
        debugPrint('🔍 Pattern Detection: Sequence too short (${sequence.length} workouts)');
      }
      return null;
    }

    PatternResult? bestPattern;
    double bestConfidence = 0.0;

    // Prova pattern di lunghezza diversa (da 2 a 7 giorni)
    for (int patternLength = 2; patternLength <= 7 && patternLength <= sequence.length / 2; patternLength++) {
      final pattern = sequence.take(patternLength).toList();

      // Calcola quanto bene il pattern matcha la sequenza
      final confidence = _calculatePatternConfidence(sequence, pattern);

      // Richiediamo almeno 75% match per considerare valido il pattern
      if (confidence >= 0.75 && confidence > bestConfidence) {
        final occurrences = (sequence.length / patternLength).floor();
        bestPattern = PatternResult(
          pattern: pattern,
          occurrences: occurrences,
          confidence: confidence,
        );
        bestConfidence = confidence;

        if (kDebugMode) {
          debugPrint('🔍 Pattern found: ${pattern.join(" → ")} (confidence: ${confidence.toStringAsFixed(2)})');
        }
      }
    }

    return bestPattern;
  }

  /// Calcola quanto bene un pattern matcha una sequenza
  ///
  /// Returns confidence score tra 0.0 e 1.0
  double _calculatePatternConfidence(List<String> sequence, List<String> pattern) {
    if (pattern.isEmpty || sequence.isEmpty) return 0.0;

    int matches = 0;
    int totalComparisons = 0;

    for (int i = 0; i < sequence.length; i++) {
      final expectedIndex = i % pattern.length;
      final expected = pattern[expectedIndex];
      final actual = sequence[i];

      if (expected == actual) {
        matches++;
      }
      totalComparisons++;
    }

    return totalComparisons > 0 ? matches / totalComparisons : 0.0;
  }

  /// Detecta pattern più complessi che includono giorni di riposo
  ///
  /// Es: PUSH, PULL, REST, LEGS, REST → ["PUSH", "PULL", "REST", "LEGS", "REST"]
  PatternResult? detectPatternWithRest(
    List<String> workoutSequence,
    List<DateTime> workoutDates,
  ) {
    if (workoutSequence.length != workoutDates.length) {
      return null;
    }

    // Costruisci sequenza con giorni di riposo inclusi
    final sequenceWithRest = <String>[];

    for (int i = 0; i < workoutDates.length; i++) {
      // Aggiungi il workout
      sequenceWithRest.add(workoutSequence[i]);

      // Se non è l'ultimo, controlla giorni di riposo
      if (i < workoutDates.length - 1) {
        final daysBetween = workoutDates[i + 1].difference(workoutDates[i]).inDays;

        // Aggiungi REST per ogni giorno di riposo (max 3 per evitare pattern troppo lunghi)
        for (int j = 1; j < daysBetween && j <= 3; j++) {
          sequenceWithRest.add('REST');
        }
      }
    }

    // Ora detecta pattern nella sequenza con riposi
    return detectRepeatingPattern(sequenceWithRest);
  }
}