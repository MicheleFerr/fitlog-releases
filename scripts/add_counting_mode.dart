/// Script per aggiungere countingMode agli esercizi nei file JSON
///
/// Regole:
/// - time: esercizi isometrici (plank, wall sit, dead hang, etc.)
/// - reps: esercizi corpo libero (attrezzatura = "Corpo Libero")
/// - weighted: tutto il resto
///
/// Esegui con: dart run scripts/add_counting_mode.dart

import 'dart:convert';
import 'dart:io';

// Esercizi che sono sempre time-based (isometrici)
final timeBasedExercises = [
  'plank',
  'side plank',
  'wall sit',
  'dead hang',
  'hollow hold',
  'l-sit',
  'farmer walk',
  'farmer\'s walk',
  'suitcase carry',
  'overhead carry',
  'isometric',
  'static hold',
  'hang',
  'tenuta',
  'isometrico',
  'isometrica',
  'mantenimento',
];

// Esercizi corpo libero che hanno anche peso (devono essere weighted)
final weightedBodyweight = [
  'weighted',
  'con zavorra',
  'con peso',
  'kettlebell',
  'dumbbell',
  'manubrio',
  'manubri',
  'bilanciere',
  'barbell',
];

/// Determina il countingMode per un esercizio
String getCountingMode(Map<String, dynamic> exercise) {
  final nome = (exercise['nome'] as String? ?? '').toLowerCase();
  final attrezzatura = (exercise['attrezzatura'] as String? ?? '').toLowerCase();
  final patternMovimento = (exercise['patternMovimento'] as String? ?? '').toLowerCase();

  // 1. Check se è un esercizio time-based (isometrico)
  for (final keyword in timeBasedExercises) {
    if (nome.contains(keyword) || patternMovimento.contains(keyword)) {
      return 'time';
    }
  }

  // 2. Check se è corpo libero MA con peso aggiunto
  for (final keyword in weightedBodyweight) {
    if (nome.contains(keyword) || attrezzatura.contains(keyword)) {
      return 'weighted';
    }
  }

  // 3. Se è corpo libero puro → reps
  if (attrezzatura == 'corpo libero' || attrezzatura == 'bodyweight') {
    return 'reps';
  }

  // 4. Default → weighted
  return 'weighted';
}

Future<void> processFile(String inputPath) async {
  final file = File(inputPath);

  if (!await file.exists()) {
    print('⚠️ File non trovato: $inputPath');
    return;
  }

  print('📖 Leggendo $inputPath...');
  final content = await file.readAsString();
  final exercises = jsonDecode(content) as List<dynamic>;

  // Statistiche
  var timeCount = 0;
  var repsCount = 0;
  var weightedCount = 0;

  // Aggiungi countingMode a ogni esercizio
  for (final exercise in exercises) {
    final ex = exercise as Map<String, dynamic>;
    final mode = getCountingMode(ex);
    ex['countingMode'] = mode;

    switch (mode) {
      case 'time':
        timeCount++;
      case 'reps':
        repsCount++;
      case 'weighted':
        weightedCount++;
    }
  }

  // Scrivi il file aggiornato
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(exercises));

  print('✅ Aggiornato $inputPath:');
  print('   - time: $timeCount');
  print('   - reps: $repsCount');
  print('   - weighted: $weightedCount');
  print('   - totale: ${exercises.length}');
}

void main(List<String> args) async {
  print('🏋️ Aggiunta countingMode agli esercizi\n');

  // Directory da processare
  final directories = [
    'assets/data/exercises',      // Italian
    'assets/data/exercises_en',   // English
  ];

  for (final dirPath in directories) {
    final dir = Directory(dirPath);

    if (!await dir.exists()) {
      print('⚠️ Directory non trovata: $dirPath');
      continue;
    }

    print('\n📁 Processing $dirPath:');

    // Processa tutti i file JSON (escluso _index.json)
    await for (final entity in dir.list()) {
      if (entity is File &&
          entity.path.endsWith('.json') &&
          !entity.path.endsWith('_index.json')) {
        await processFile(entity.path);
      }
    }
  }

  print('\n✨ Done! countingMode aggiunto a tutti gli esercizi.');
  print('\nProssimi passi:');
  print('1. Aggiungere countingMode a ExerciseDefinition entity');
  print('2. Aggiornare fromJson() per leggere countingMode');
  print('3. Rigenerare Hive adapters con: dart run build_runner build');
}
