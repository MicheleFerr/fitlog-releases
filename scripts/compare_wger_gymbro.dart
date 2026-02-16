import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Script per confrontare database wger con GymBro e identificare esercizi mancanti
///
/// Usage:
/// dart run scripts/compare_wger_gymbro.dart
///
/// Output:
/// - report_wger_comparison.md con analisi dettagliata
/// - wger_missing_exercises.json con esercizi da considerare

void main() async {
  print('🔍 Avvio confronto wger vs GymBro...\n');

  // 1. Carica esercizi GymBro
  print('📚 Caricamento database GymBro...');
  final gymbroExercises = await loadGymBroExercises();
  print('   ✅ ${gymbroExercises.length} esercizi caricati\n');

  // 2. Scarica esercizi wger (IT)
  print('🌐 Download esercizi wger (italiano)...');
  final wgerExercises = await fetchWgerExercises();
  print('   ✅ ${wgerExercises.length} esercizi scaricati\n');

  // 3. Normalizza nomi per matching
  print('🔧 Normalizzazione nomi per confronto...');
  final gymbroNormalized = normalizeExerciseNames(gymbroExercises);
  final wgerNormalized = normalizeExerciseNames(
    wgerExercises.map((e) => {'nome': e['name']}).toList(),
  );
  print('   ✅ Normalizzazione completata\n');

  // 4. Identifica gap
  print('🔎 Identificazione esercizi mancanti...');
  final missingExercises = findMissingExercises(
    wgerExercises,
    wgerNormalized,
    gymbroNormalized,
  );
  print('   ✅ ${missingExercises.length} esercizi potenzialmente mancanti\n');

  // 5. Categorizza per muscle group
  print('📊 Categorizzazione per gruppi muscolari...');
  final categorized = categorizeByMuscleGroup(missingExercises);
  print('   ✅ Categorizzazione completata\n');

  // 6. Genera report
  print('📝 Generazione report...');
  await generateReport(
    gymbroExercises.length,
    wgerExercises.length,
    missingExercises,
    categorized,
  );
  print('   ✅ Report salvato: report_wger_comparison.md\n');

  // 7. Salva JSON esercizi mancanti
  await saveMissingExercisesJson(missingExercises);
  print('   ✅ JSON salvato: wger_missing_exercises.json\n');

  print('🎉 Analisi completata!');
  print('📄 Controlla report_wger_comparison.md per dettagli');
}

/// Carica tutti gli esercizi dai file JSON di GymBro
Future<List<Map<String, dynamic>>> loadGymBroExercises() async {
  final exercises = <Map<String, dynamic>>[];
  final files = [
    'assets/data/exercises/upper_push.json',
    'assets/data/exercises/upper_pull.json',
    'assets/data/exercises/lower.json',
    'assets/data/exercises/core.json',
    'assets/data/exercises/other.json',
  ];

  for (final file in files) {
    try {
      final content = await File(file).readAsString();
      final List<dynamic> data = jsonDecode(content);
      exercises.addAll(data.cast<Map<String, dynamic>>());
    } catch (e) {
      print('   ⚠️  Errore caricamento $file: $e');
    }
  }

  return exercises;
}

/// Scarica esercizi da wger API (solo traduzione italiana)
Future<List<Map<String, dynamic>>> fetchWgerExercises() async {
  final exercises = <Map<String, dynamic>>[];
  var offset = 0;
  const limit = 100;
  const maxExercises = 832; // Totale da API

  while (offset < maxExercises) {
    try {
      final url = Uri.parse(
        'https://wger.de/api/v2/exerciseinfo/?language=13&limit=$limit&offset=$offset',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        for (final exercise in results) {
          // Cerca traduzione italiana
          final translations = exercise['translations'] as List;
          final italianTranslation = translations.firstWhere(
            (t) => t['language'] == 13,
            orElse: () => null,
          );

          if (italianTranslation != null) {
            exercises.add({
              'id': exercise['id'],
              'name': italianTranslation['name'],
              'description': italianTranslation['description'],
              'category': exercise['category']?['name'] ?? 'Unknown',
              'muscles': (exercise['muscles'] as List?)
                      ?.map((m) => m['name_en'] ?? m['name'])
                      .toList() ??
                  [],
              'equipment': (exercise['equipment'] as List?)
                      ?.map((e) => e['name'])
                      .toList() ??
                  [],
            });
          }
        }

        print('   ... scaricati ${exercises.length} esercizi');
        offset += limit;
      } else {
        print('   ⚠️  Errore API: ${response.statusCode}');
        break;
      }
    } catch (e) {
      print('   ⚠️  Errore download: $e');
      break;
    }
  }

  return exercises;
}

/// Normalizza nomi esercizi per matching (lowercase, no accenti, no spazi extra)
Set<String> normalizeExerciseNames(List<Map<String, dynamic>> exercises) {
  final normalized = <String>{};

  for (final exercise in exercises) {
    final name = exercise['nome'] as String? ?? exercise['name'] as String?;
    if (name != null) {
      normalized.add(_normalize(name));

      // Aggiungi anche aliases se presenti
      final aliases = exercise['aliases'] as List?;
      if (aliases != null) {
        for (final alias in aliases) {
          normalized.add(_normalize(alias.toString()));
        }
      }
    }
  }

  return normalized;
}

/// Normalizzazione stringa: lowercase, rimuovi accenti, trim, rimuovi caratteri speciali
String _normalize(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâã]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõ]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Trova esercizi wger non presenti in GymBro
List<Map<String, dynamic>> findMissingExercises(
  List<Map<String, dynamic>> wgerExercises,
  Set<String> wgerNormalized,
  Set<String> gymbroNormalized,
) {
  final missing = <Map<String, dynamic>>[];

  for (var i = 0; i < wgerExercises.length; i++) {
    final exercise = wgerExercises[i];
    final normalizedName = _normalize(exercise['name'] as String);

    // Check se esiste in GymBro (exact match o similar)
    var found = false;

    // 1. Exact match
    if (gymbroNormalized.contains(normalizedName)) {
      found = true;
    }

    // 2. Partial match (contiene/è contenuto)
    if (!found) {
      for (final gymbroName in gymbroNormalized) {
        if (_isSimilar(normalizedName, gymbroName)) {
          found = true;
          break;
        }
      }
    }

    if (!found) {
      missing.add(exercise);
    }
  }

  return missing;
}

/// Verifica similarità tra due nomi (per evitare duplicati con nomi leggermente diversi)
bool _isSimilar(String name1, String name2) {
  // Se uno contiene l'altro (almeno 80% overlap)
  if (name1.contains(name2) || name2.contains(name1)) {
    return true;
  }

  // Calcola Levenshtein distance ratio
  final distance = _levenshteinDistance(name1, name2);
  final maxLength = name1.length > name2.length ? name1.length : name2.length;
  final similarity = 1 - (distance / maxLength);

  return similarity > 0.85; // 85% similarità
}

/// Calcola Levenshtein distance tra due stringhe
int _levenshteinDistance(String s1, String s2) {
  final len1 = s1.length;
  final len2 = s2.length;
  final matrix = List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

  for (var i = 0; i <= len1; i++) {
    matrix[i][0] = i;
  }
  for (var j = 0; j <= len2; j++) {
    matrix[0][j] = j;
  }

  for (var i = 1; i <= len1; i++) {
    for (var j = 1; j <= len2; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return matrix[len1][len2];
}

/// Categorizza esercizi per gruppo muscolare
Map<String, List<Map<String, dynamic>>> categorizeByMuscleGroup(
  List<Map<String, dynamic>> exercises,
) {
  final categorized = <String, List<Map<String, dynamic>>>{
    'Chest': [],
    'Back': [],
    'Shoulders': [],
    'Arms': [],
    'Legs': [],
    'Abs': [],
    'Full Body': [],
    'Other': [],
  };

  for (final exercise in exercises) {
    final category = exercise['category'] as String;
    final muscles = exercise['muscles'] as List;

    // Map wger category to GymBro categories
    String targetCategory = 'Other';

    if (category == 'Chest' || muscles.any((m) => m.toString().contains('Chest'))) {
      targetCategory = 'Chest';
    } else if (category == 'Back' || muscles.any((m) => m.toString().contains('Lats') || m.toString().contains('Traps'))) {
      targetCategory = 'Back';
    } else if (category == 'Shoulders' || muscles.any((m) => m.toString().contains('Shoulders') || m.toString().contains('Deltoid'))) {
      targetCategory = 'Shoulders';
    } else if (category == 'Arms' || muscles.any((m) => m.toString().contains('Biceps') || m.toString().contains('Triceps'))) {
      targetCategory = 'Arms';
    } else if (category == 'Legs' || muscles.any((m) => m.toString().contains('Quads') || m.toString().contains('Hamstrings') || m.toString().contains('Glutes'))) {
      targetCategory = 'Legs';
    } else if (category == 'Abs' || muscles.any((m) => m.toString().contains('Abs'))) {
      targetCategory = 'Abs';
    }

    categorized[targetCategory]!.add(exercise);
  }

  return categorized;
}

/// Genera report markdown
Future<void> generateReport(
  int gymbroCount,
  int wgerCount,
  List<Map<String, dynamic>> missingExercises,
  Map<String, List<Map<String, dynamic>>> categorized,
) async {
  final buffer = StringBuffer();

  buffer.writeln('# 📊 Report Confronto wger vs GymBro');
  buffer.writeln();
  buffer.writeln('**Data analisi**: ${DateTime.now().toString().split('.')[0]}');
  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln();

  // Summary
  buffer.writeln('## 📈 Sommario');
  buffer.writeln();
  buffer.writeln('| Metrica | Valore |');
  buffer.writeln('|---------|--------|');
  buffer.writeln('| **Esercizi GymBro** | $gymbroCount |');
  buffer.writeln('| **Esercizi wger (IT)** | $wgerCount |');
  buffer.writeln('| **Esercizi mancanti** | ${missingExercises.length} |');
  buffer.writeln('| **% Coverage** | ${((gymbroCount / (gymbroCount + missingExercises.length)) * 100).toStringAsFixed(1)}% |');
  buffer.writeln();

  // Per categoria
  buffer.writeln('## 🎯 Esercizi Mancanti per Categoria');
  buffer.writeln();

  for (final entry in categorized.entries) {
    final category = entry.key;
    final exercises = entry.value;

    if (exercises.isEmpty) continue;

    buffer.writeln('### $category (${exercises.length} esercizi)');
    buffer.writeln();

    for (final exercise in exercises) {
      final name = exercise['name'];
      final muscles = (exercise['muscles'] as List).join(', ');
      final equipment = (exercise['equipment'] as List).join(', ');

      buffer.writeln('**$name**');
      buffer.writeln('- Muscoli: ${muscles.isNotEmpty ? muscles : 'N/A'}');
      buffer.writeln('- Attrezzatura: ${equipment.isNotEmpty ? equipment : 'N/A'}');
      buffer.writeln();
    }
  }

  // Raccomandazioni
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('## 💡 Raccomandazioni');
  buffer.writeln();
  buffer.writeln('### ✅ Da Considerare per Import');
  buffer.writeln();

  // Top picks per categoria
  for (final entry in categorized.entries) {
    final category = entry.key;
    final exercises = entry.value;

    if (exercises.isEmpty) continue;

    buffer.writeln('**$category**:');
    final topPicks = exercises.take(3).toList();
    for (final exercise in topPicks) {
      buffer.writeln('- ${exercise['name']}');
    }
    buffer.writeln();
  }

  buffer.writeln('### ⚠️ Note');
  buffer.writeln();
  buffer.writeln('- Questo report identifica esercizi **potenzialmente mancanti**');
  buffer.writeln('- Alcuni potrebbero essere duplicati con nomi diversi');
  buffer.writeln('- Valuta manualmente prima di importare');
  buffer.writeln('- Priorità: esercizi compound e attrezzatura comune (bilanciere, manubri)');

  await File('report_wger_comparison.md').writeAsString(buffer.toString());
}

/// Salva JSON con esercizi mancanti
Future<void> saveMissingExercisesJson(
  List<Map<String, dynamic>> exercises,
) async {
  final output = {
    'count': exercises.length,
    'exercises': exercises,
    'generated_at': DateTime.now().toIso8601String(),
  };

  await File('wger_missing_exercises.json').writeAsString(
    const JsonEncoder.withIndent('  ').convert(output),
  );
}
