/// Fix Legacy Muscle Names in _index.json
///
/// Normalizza tutti i vecchi nomi muscolari ai nuovi standard canonici
/// nell'_index.json usando il mapping di MuscleAbbreviationMapper.
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Fix Legacy Muscle Names in _index.json\n');
  print('=' * 70);

  // Mapping legacy → canonical (da MuscleAbbreviationMapper)
  final muscleMapping = {
    // Arms
    'BIC': 'BICI',
    'AVAMB': 'AVA',
    // Back
    'LOMBAR': 'LOMB',
    'LOM': 'LOMB',
    'DORSO': 'LAT',
    // Shoulders
    'COLLO': 'COLL',
    // Legs
    'FEMOR': 'FEMO',
    'POLL': 'POLP',
    'ADDO': 'ADD',
    'ADDUT': 'ADD',
    'ADDU': 'ADD',
    'ABDUT': 'ABDU',
    // Core
    'ADDOM': 'CORE',
  };

  // Paths
  final indexFile = File('assets/data/exercises/_index.json');

  if (!await indexFile.exists()) {
    print('❌ File _index.json non trovato!');
    print('   Path cercato: ${indexFile.absolute.path}');
    exit(1);
  }

  print('📁 File: ${indexFile.path}\n');

  // Backup
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
  final backupFile = File('assets/data/exercises/_index_backup_muscle_fix_$timestamp.json');
  await indexFile.copy(backupFile.path);
  print('💾 Backup creato: ${backupFile.path}\n');

  // Read JSON
  final content = await indexFile.readAsString();
  final json = jsonDecode(content) as Map<String, dynamic>;

  var fixedCount = 0;
  final fixedExercises = <String>[];
  final stats = <String, int>{};

  // Process each exercise
  for (final entry in json.entries) {
    final exerciseId = entry.key;
    final exercise = entry.value as Map<String, dynamic>;

    if (exercise.containsKey('focus')) {
      final focus = exercise['focus'];

      // Normalize focus (can be string or array in _index.json)
      if (focus is String) {
        final oldFocus = focus;
        final newFocus = muscleMapping[focus] ?? focus;

        if (newFocus != oldFocus) {
          exercise['focus'] = newFocus;
          fixedCount++;
          fixedExercises.add(exerciseId);
          stats[oldFocus] = (stats[oldFocus] ?? 0) + 1;

          // Log single change
          print('✅ $exerciseId: $oldFocus → $newFocus');
        }
      }
    }
  }

  // Write updated JSON
  if (fixedCount > 0) {
    final encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(json);
    await indexFile.writeAsString(prettyJson);

    print('\n' + '=' * 70);
    print('📊 STATISTICHE FIX');
    print('=' * 70);
    print('Esercizi fixati: $fixedCount');
    print('\nBreakdown per vecchio nome:');

    final sortedStats = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final stat in sortedStats) {
      final canonical = muscleMapping[stat.key] ?? stat.key;
      print('  ${stat.key.padRight(10)} → ${canonical.padRight(6)}: ${stat.value} esercizi');
    }

    print('\n✅ File aggiornato con successo!');
    print('   Path: ${indexFile.absolute.path}');
  } else {
    print('\n✅ Nessun fix necessario - tutti i nomi sono già canonici!');
    // Delete backup if no changes
    await backupFile.delete();
  }

  print('\n' + '=' * 70);
}
