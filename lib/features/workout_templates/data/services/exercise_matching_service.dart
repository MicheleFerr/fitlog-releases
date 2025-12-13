/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data
/// 🎯 Feature: workout_templates
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Dart: string_similarity algorithms
/// - Flutter: asset loading
library;

import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';

class LocalExercise {
  
  LocalExercise({
    required this.id,
    required this.nome,
    required this.focus,
    this.muscoliSecondari,
    required this.difficolta,
    required this.tipoEsercizio,
    required this.attrezzatura,
  });
  
  factory LocalExercise.fromJson(Map<String, dynamic> json) {
    return LocalExercise(
      id: json['id'],
      nome: json['nome'],
      focus: json['focus'],
      muscoliSecondari: json['muscoliSecondari'],
      difficolta: json['difficolta'],
      tipoEsercizio: json['tipoEsercizio'],
      attrezzatura: json['attrezzatura'],
    );
  }
  final String id;
  final String nome;
  final String focus;
  final String? muscoliSecondari;
  final String difficolta;
  final String tipoEsercizio;
  final String attrezzatura;
}

class ExerciseMatch {
  
  ExerciseMatch({
    required this.exercise,
    required this.similarity,
    required this.matchReason,
  });
  final LocalExercise exercise;
  final double similarity;
  final String matchReason;
}

class ExerciseMatchingService {
  ExerciseMatchingService._();
  static ExerciseMatchingService? _instance;
  static ExerciseMatchingService get instance => _instance ??= ExerciseMatchingService._();

  List<LocalExercise>? _exercises;
  String? _cachedLanguageCode;

  // Carica il database degli esercizi in base alla lingua
  Future<void> loadExerciseDatabase({String languageCode = 'en'}) async {
    // Ricarica se la lingua è cambiata
    if (_exercises != null && _cachedLanguageCode == languageCode) return;

    try {
      // Usa nuova struttura a cartelle con fallback
      final jsonList = await ExerciseJsonLoader.loadExercises(languageCode);

      _exercises = jsonList
          .map((json) => LocalExercise.fromJson(json))
          .toList();

      _cachedLanguageCode = languageCode;
    } catch (e) {
      // Fallback: se non trova il file, usa lista vuota
      _exercises = [];
    }
  }
  
  // Trova i migliori match per un nome di esercizio
  Future<List<ExerciseMatch>> findMatches(String exerciseName, {int maxResults = 5, String languageCode = 'en'}) async {
    await loadExerciseDatabase(languageCode: languageCode);

    if (_exercises == null || _exercises!.isEmpty) {
      return [];
    }

    final normalizedInput = _normalizeString(exerciseName);
    final matches = <ExerciseMatch>[];

    for (final exercise in _exercises!) {
      final similarity = _calculateSimilarity(normalizedInput, exercise);

      if (similarity.similarity > 0.3) { // Soglia minima di similarità
        matches.add(similarity);
      }
    }

    // Ordina per similarità decrescente
    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    return matches.take(maxResults).toList();
  }

  // Trova match esatto
  Future<LocalExercise?> findExactMatch(String exerciseName, {String languageCode = 'en'}) async {
    await loadExerciseDatabase(languageCode: languageCode);

    if (_exercises == null || _exercises!.isEmpty) {
      return null;
    }

    final normalizedInput = _normalizeString(exerciseName);

    // Prima prova match esatto
    for (final exercise in _exercises!) {
      if (_normalizeString(exercise.nome) == normalizedInput) {
        return exercise;
      }
    }

    // Prova match ad alta similarità (>95%)
    for (final exercise in _exercises!) {
      final similarity = _calculateSimilarity(normalizedInput, exercise);
      if (similarity.similarity > 0.95) {
        return exercise;
      }
    }

    return null;
  }
  
  // Calcola similarità tra input e esercizio locale con algoritmi avanzati
  ExerciseMatch _calculateSimilarity(String normalizedInput, LocalExercise exercise) {
    final normalizedExerciseName = _normalizeString(exercise.nome);
    
    // Usa l'algoritmo avanzato di similarità
    double similarity = _calculateAdvancedStringSimilarity(normalizedInput, normalizedExerciseName);
    
    // Determina il motivo del match basato su diversi criteri
    String matchReason = _determineMatchReason(normalizedInput, normalizedExerciseName, similarity);
    
    // Bonus per match exact dopo normalizzazione
    if (normalizedInput == normalizedExerciseName) {
      similarity = 1.0;
      matchReason = 'Match esatto';
    }
    
    // Bonus aggiuntivo per match di focus muscolare se specificato
    if (exercise.focus.isNotEmpty) {
      final normalizedFocus = _normalizeString(exercise.focus);
      if (normalizedInput.contains(normalizedFocus) || normalizedFocus.contains(normalizedInput)) {
        similarity = (similarity + 0.1).clamp(0.0, 1.0);
        matchReason = 'Focus muscolare + $matchReason';
      }
    }
    
    return ExerciseMatch(
      exercise: exercise,
      similarity: similarity,
      matchReason: matchReason,
    );
  }
  
  // Determina il motivo del match
  String _determineMatchReason(String input, String exerciseName, double similarity) {
    // Check exact substring match
    if (exerciseName.contains(input) || input.contains(exerciseName)) {
      return 'Sottostringa';
    }
    
    // Check word overlap
    final Set<String> inputWords = input.split(' ').where((w) => w.length > 2).toSet();
    final Set<String> exerciseWords = exerciseName.split(' ').where((w) => w.length > 2).toSet();
    
    final int commonWords = inputWords.intersection(exerciseWords).length;
    if (commonWords > 0) {
      return commonWords == inputWords.length ? 'Parole comuni' : 'Parole parziali';
    }
    
    // Check initials match (for acronyms)
    if (input.length <= 4 && exerciseName.split(' ').length > 1) {
      final String initials = exerciseName.split(' ').map((w) => w[0]).join().toLowerCase();
      if (input == initials) {
        return 'Acronimo';
      }
    }
    
    // Default based on similarity level
    if (similarity > 0.8) {
      return 'Alta similarità';
    } else if (similarity > 0.6) {
      return 'Media similarità';
    } else {
      return 'Bassa similarità';
    }
  }
  
  // Calcola similarità tra due stringhe usando Levenshtein distance
  double _calculateStringSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;
    
    final int distance = _levenshteinDistance(s1, s2);
    final int maxLength = s1.length > s2.length ? s1.length : s2.length;
    
    return 1.0 - (distance / maxLength);
  }
  
  // Implementazione Levenshtein distance
  int _levenshteinDistance(String s1, String s2) {
    final int m = s1.length;
    final int n = s2.length;
    
    // Crea una matrice per memorizzare i risultati
    final List<List<int>> dp = List.generate(
      m + 1, 
      (i) => List.filled(n + 1, 0)
    );
    
    // Inizializza la prima riga e colonna
    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    
    // Riempi la matrice
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [
            dp[i - 1][j],     // deletion
            dp[i][j - 1],     // insertion
            dp[i - 1][j - 1], // substitution
          ].reduce((a, b) => a < b ? a : b);
        }
      }
    }
    
    return dp[m][n];
  }
  
  // Normalizza una stringa per il confronto con miglioramenti
  String _normalizeString(String input) {
    String normalized = input
        .toLowerCase()
        .trim()
        // Rimuovi caratteri speciali
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        // Rimuovi spazi multipli
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // Sostituzioni comuni italiano/inglese (più complete)
    final Map<String, String> translations = {
      // Esercizi principali
      'bench press': 'panca piana',
      'incline bench press': 'panca inclinata',
      'decline bench press': 'panca declinata',
      'dumbbell press': 'spinte manubri',
      'chest press': 'chest press',
      'push up': 'piegamenti',
      'pushup': 'piegamenti',
      'push ups': 'piegamenti',
      'pushups': 'piegamenti',
      
      // Schiena
      'pull up': 'trazioni',
      'pullup': 'trazioni',
      'pull ups': 'trazioni',
      'pullups': 'trazioni',
      'chin up': 'trazioni presa inversa',
      'lat pulldown': 'lat machine',
      'cable row': 'rematore cavo',
      'bent over row': 'rematore bilanciere',
      'deadlift': 'stacco da terra',
      'romanian deadlift': 'stacco rumeno',
      'sumo deadlift': 'stacco sumo',
      
      // Spalle
      'shoulder press': 'spinte spalle',
      'military press': 'spinte militari',
      'overhead press': 'spinte sopra testa',
      'lateral raise': 'alzate laterali',
      'front raise': 'alzate frontali',
      'rear delt fly': 'alzate posteriori',
      
      // Braccia
      'bicep curl': 'curl bicipiti',
      'biceps curl': 'curl bicipiti',
      'hammer curl': 'curl martello',
      'tricep extension': 'estensioni tricipiti',
      'triceps extension': 'estensioni tricipiti',
      'close grip bench press': 'panca presa stretta',
      'dips': 'dip',
      
      // Gambe
      'squat': 'squat',
      'front squat': 'squat frontale',
      'back squat': 'squat',
      'goblet squat': 'goblet squat',
      'leg press': 'pressa gambe',
      'leg extension': 'estensioni quadricipiti',
      'leg curl': 'curl femorali',
      'calf raise': 'alzate polpacci',
      'calf raises': 'alzate polpacci',
      'lunge': 'affondi',
      'lunges': 'affondi',
      'bulgarian split squat': 'squat bulgaro',
      'hip thrust': 'spinte anche',
      'glute bridge': 'ponte glutei',
      
      // Addominali
      'crunches': 'crunch',
      'sit up': 'sit up',
      'sit ups': 'sit up',
      'plank': 'plank',
      'leg raise': 'alzate gambe',
      'russian twist': 'twist russo',
      
      // Cardio
      'running': 'corsa',
      'jogging': 'jogging',
      'cycling': 'cyclette',
      'elliptical': 'ellittica',
      'rowing': 'vogatore',
      'treadmill': 'tapis roulant',
      
      // Attrezzature
      'dumbbell': 'manubri',
      'dumbbells': 'manubri',
      'barbell': 'bilanciere',
      'kettlebell': 'kettlebell',
      'cable': 'cavo',
      'machine': 'macchina',
      
      // Plurali e singolari
      'pettorali': 'petto',
      'bicipiti': 'bicipiti',
      'tricipiti': 'tricipiti',
      'quadricipiti': 'quadricipiti',
      'femorali': 'femorali',
      'polpacci': 'polpacci',
      'spalle': 'spalle',
      'gambe': 'gambe',
      
      // Varianti comuni
      'chest': 'petto',
      'back': 'schiena',
      'shoulders': 'spalle',
      'legs': 'gambe',
      'arms': 'braccia',
      'abs': 'addominali',
    };
    
    // Applica le sostituzioni
    for (final entry in translations.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    
    return normalized.trim();
  }
  
  // Calcola similarità con algoritmi multipli per migliori risultati
  double _calculateAdvancedStringSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;
    
    // 1. Levenshtein distance
    final double levenshteinSim = _calculateStringSimilarity(s1, s2);
    
    // 2. Jaccard similarity (parole in comune)
    final double jaccardSim = _calculateJaccardSimilarity(s1, s2);
    
    // 3. Substring similarity
    final double substringSim = _calculateSubstringSimilarity(s1, s2);
    
    // 4. Iniziali delle parole
    final double initialsSim = _calculateInitialsSimilarity(s1, s2);
    
    // Combinazione pesata dei risultati
    final double finalSimilarity = (levenshteinSim * 0.4) + 
                            (jaccardSim * 0.3) + 
                            (substringSim * 0.2) + 
                            (initialsSim * 0.1);
    
    return finalSimilarity.clamp(0.0, 1.0);
  }
  
  // Jaccard similarity: parole in comune / parole totali
  double _calculateJaccardSimilarity(String s1, String s2) {
    final Set<String> words1 = s1.split(' ').where((w) => w.isNotEmpty).toSet();
    final Set<String> words2 = s2.split(' ').where((w) => w.isNotEmpty).toSet();
    
    if (words1.isEmpty && words2.isEmpty) return 1.0;
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    final int intersection = words1.intersection(words2).length;
    final int union = words1.union(words2).length;
    
    return intersection / union;
  }
  
  // Similarity basata su sottostringhe
  double _calculateSubstringSimilarity(String s1, String s2) {
    if (s1.contains(s2) || s2.contains(s1)) return 0.8;
    
    // Controlla sottostringhe più lunghe
    int maxLength = 0;
    for (int i = 0; i < s1.length; i++) {
      for (int j = i + 1; j <= s1.length; j++) {
        final String substring = s1.substring(i, j);
        if (substring.length > 2 && s2.contains(substring)) {
          maxLength = substring.length > maxLength ? substring.length : maxLength;
        }
      }
    }
    
    if (maxLength == 0) return 0.0;
    
    final double similarity = maxLength / (s1.length > s2.length ? s1.length : s2.length);
    return similarity.clamp(0.0, 0.8);
  }
  
  // Similarity delle iniziali delle parole (per acronimi)
  double _calculateInitialsSimilarity(String s1, String s2) {
    final List<String> words1 = s1.split(' ').where((w) => w.isNotEmpty).toList();
    final List<String> words2 = s2.split(' ').where((w) => w.isNotEmpty).toList();
    
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    final String initials1 = words1.map((w) => w[0]).join();
    final String initials2 = words2.map((w) => w[0]).join();
    
    return _calculateStringSimilarity(initials1, initials2) * 0.5; // Peso ridotto
  }
}