/// Script per splittare exercises_it.json in file più piccoli
/// e rimuovere i campi inutilizzati
///
/// Esegui con: dart run scripts/split_exercises_json.dart

import 'dart:convert';
import 'dart:io';

// Campi da rimuovere (quasi tutti vuoti)
const fieldsToRemove = [
  'warmupSets',
  'tempoWarmup',
  'drillTecnico',
  'prevenzioneInfortuni',
  'cooldownConsigliato',
  'spiegazioneTermini',
  'tempoEsecuzione',
  'tempoNote',
];

// Mapping focus -> file
String getFileForFocus(String focus) {
  final primary = focus.split(',').first.trim().toUpperCase();

  // Core exercises
  if (['CORE', 'ADD', 'ADDO'].contains(primary)) {
    return 'core.json';
  }

  // Upper push (chest, triceps, shoulders front)
  if (['PETT', 'TRIC'].contains(primary)) {
    return 'upper_push.json';
  }

  // Upper pull (back, biceps, traps)
  if (['LAT', 'BICI', 'TRAP'].contains(primary)) {
    return 'upper_pull.json';
  }

  // Shoulders (can be push or pull, put in upper_push)
  if (['DELT'].contains(primary)) {
    return 'upper_push.json';
  }

  // Lower body
  if (['QUAD', 'GLUT', 'FEMOR', 'POLP'].contains(primary)) {
    return 'lower.json';
  }

  // Everything else
  return 'other.json';
}

Map<String, dynamic> cleanExercise(Map<String, dynamic> exercise) {
  final cleaned = Map<String, dynamic>.from(exercise);

  // Rimuovi campi vuoti/inutilizzati
  for (final field in fieldsToRemove) {
    cleaned.remove(field);
  }

  // Rimuovi anche campi null o stringhe vuote per altri campi opzionali
  cleaned.removeWhere((key, value) => value == null || value == '');

  return cleaned;
}

void main(List<String> args) async {
  // Default paths, can override with arguments
  final inputPath = args.isNotEmpty ? args[0] : 'assets/data/exercises_it.json';
  final outputPath = args.length > 1 ? args[1] : 'assets/data/exercises';

  final inputFile = File(inputPath);
  final outputDir = Directory(outputPath);

  if (!await inputFile.exists()) {
    print('File non trovato: ${inputFile.path}');
    exit(1);
  }

  // Crea directory output
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  print('Leggendo ${inputFile.path}...');
  final content = await inputFile.readAsString();
  final exercises = jsonDecode(content) as List<dynamic>;

  print('Trovati ${exercises.length} esercizi');

  // Raggruppa per file
  final Map<String, List<Map<String, dynamic>>> grouped = {
    'core.json': [],
    'upper_push.json': [],
    'upper_pull.json': [],
    'lower.json': [],
    'other.json': [],
  };

  // Index per lookup veloce
  final Map<String, String> index = {};

  for (final exercise in exercises) {
    final ex = exercise as Map<String, dynamic>;
    final focus = ex['focus']?.toString() ?? '';
    final id = ex['id']?.toString() ?? '';
    final targetFile = getFileForFocus(focus);

    final cleaned = cleanExercise(ex);
    grouped[targetFile]!.add(cleaned);
    index[id] = targetFile;
  }

  // Scrivi i file
  const encoder = JsonEncoder.withIndent('  ');

  for (final entry in grouped.entries) {
    final filename = entry.key;
    final exerciseList = entry.value;

    // Ordina per nome per facilitare la ricerca
    exerciseList.sort((a, b) =>
      (a['nome'] as String).compareTo(b['nome'] as String));

    final outputPath = '${outputDir.path}/$filename';
    final outputFile = File(outputPath);
    await outputFile.writeAsString(encoder.convert(exerciseList));

    print('Scritto $filename: ${exerciseList.length} esercizi');
  }

  // Scrivi index
  final indexFile = File('${outputDir.path}/_index.json');
  await indexFile.writeAsString(encoder.convert(index));
  print('Scritto _index.json: ${index.length} entries');

  // Statistiche
  print('\n=== STATISTICHE ===');
  var totalSize = 0;
  for (final entry in grouped.entries) {
    final file = File('${outputDir.path}/${entry.key}');
    final size = await file.length();
    totalSize += size;
    print('${entry.key}: ${(size / 1024).toStringAsFixed(1)} KB');
  }
  final indexSize = await indexFile.length();
  totalSize += indexSize;
  print('_index.json: ${(indexSize / 1024).toStringAsFixed(1)} KB');
  print('Totale: ${(totalSize / 1024).toStringAsFixed(1)} KB');

  final originalSize = await inputFile.length();
  print('\nOriginale: ${(originalSize / 1024).toStringAsFixed(1)} KB');
  print('Riduzione: ${((1 - totalSize / originalSize) * 100).toStringAsFixed(1)}%');

  print('\nDone! Ora puoi:');
  print('1. Verificare i file in assets/data/exercises/');
  print('2. Aggiornare il codice per caricare dalla nuova struttura');
  print('3. Rimuovere assets/data/exercises_it.json');
}
