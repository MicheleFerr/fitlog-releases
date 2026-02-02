/// Fix Legacy Muscle Names in ALL Exercise JSON Files
///
/// Normalizza tutti i vecchi nomi muscolari ai nuovi standard canonici
/// in tutti i file JSON degli esercizi (upper_push, upper_pull, lower, core, other).
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Fix Legacy Muscle Names in ALL Exercise Files\n');
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

  // Files to process
  final filesToFix = [
    'upper_push.json',
    'upper_pull.json',
    'lower.json',
    'core.json',
    'other.json',
  ];

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
  var totalFixed = 0;

  for (final filename in filesToFix) {
    final file = File('assets/data/exercises/$filename');

    if (!await file.exists()) {
      print('⚠️  File non trovato: $filename (skip)');
      continue;
    }

    print('\n📁 Processing: $filename');

    // Backup
    final backupFile = File('assets/data/exercises/${filename.replaceAll('.json', '_backup_muscle_fix_$timestamp.json')}');
    await file.copy(backupFile.path);

    // Read JSON
    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    var fixedInFile = 0;
    final stats = <String, int>{};

    // Process each exercise
    for (final exercise in exercises) {
      if (exercise is! Map<String, dynamic>) continue;

      // Fix focus (single string)
      if (exercise.containsKey('focus')) {
        final focus = exercise['focus'];
        if (focus is String) {
          final newFocus = muscleMapping[focus] ?? focus;
          if (newFocus != focus) {
            exercise['focus'] = newFocus;
            stats[focus] = (stats[focus] ?? 0) + 1;
            fixedInFile++;

          }
        }
      }

      // Fix muscoliSecondari (array)
      if (exercise.containsKey('muscoliSecondari')) {
        final secondary = exercise['muscoliSecondari'];
        if (secondary is List) {
          final newSecondary = secondary.map((muscle) {
            final muscleStr = muscle.toString();
            final newMuscle = muscleMapping[muscleStr] ?? muscleStr;
            if (newMuscle != muscleStr) {
              stats[muscleStr] = (stats[muscleStr] ?? 0) + 1;
              fixedInFile++;
  
            }
            return newMuscle;
          }).toList();
          exercise['muscoliSecondari'] = newSecondary;
        }
      }
    }

    if (fixedInFile > 0) {
      // Write updated JSON
      final encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(exercises);
      await file.writeAsString(prettyJson);

      print('   ✅ Fixati: $fixedInFile');
      if (stats.isNotEmpty) {
        for (final stat in stats.entries) {
          final canonical = muscleMapping[stat.key] ?? stat.key;
          print('      ${stat.key} → $canonical: ${stat.value}x');
        }
      }
      totalFixed += fixedInFile;
    } else {
      print('   ✓ Nessun fix necessario');
      // Delete backup if no changes
      await backupFile.delete();
    }
  }

  print('\n' + '=' * 70);
  print('📊 TOTALE ESERCIZI FIXATI: $totalFixed');
  print('=' * 70);
}
