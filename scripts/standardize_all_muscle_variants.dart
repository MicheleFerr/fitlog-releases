/// Standardizes ALL muscle variants to canonical 4-letter abbreviations
///
/// Converts all variants to canonical in both focus and muscoliSecondari
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');

  if (dryRun) {
    print('🔍 DRY RUN MODE - No files will be modified\n');
  } else {
    print('⚠️  LIVE MODE - Files will be modified (backups created)\n');
  }

  // ALL variants → canonical mapping
  final replacements = {
    // Already fixed in previous scripts
    'ADDO': 'ADD',
    'ADDUT': 'ADD',
    'ADDU': 'ADD',
    'BIC': 'BICI',
    'ANCA': 'GLUT',

    // Need to standardize now
    'FEMOR': 'FEMO',
    'LOMBAR': 'LOMB',
    'LOM': 'LOMB',
    'COLLO': 'COLL',
    'AVAMB': 'AVA',
    'DORSO': 'LAT',
    'POLL': 'POLP',
    'ABDUT': 'ABDU',
    'ADDOM': 'CORE',

    // New muscles (secondary)
    'ROMBOIDI': 'ROMB',
    'OBLIQUI': 'OBL',

    // Edge cases (if any)
    'FEMO': 'FEMO', // Already canonical
    'LOMB': 'LOMB', // Already canonical
    'COLL': 'COLL', // Already canonical
    'ROMB': 'ROMB', // Already canonical
    'OBL': 'OBL',   // Already canonical
  };

  final files = [
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath\n');
      continue;
    }

    print('📄 Processing: $filePath');

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    var focusChanges = 0;
    var secondaryChanges = 0;
    final changesDetail = <String, int>{};

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final nome = ex['nome'] as String? ?? 'Unknown';

      // Process focus (primary muscles)
      final focusRaw = ex['focus'];
      if (focusRaw != null && focusRaw.toString().isNotEmpty) {
        final focusList = focusRaw.toString().split(',').map((e) => e.trim()).toList();
        var modified = false;

        for (var i = 0; i < focusList.length; i++) {
          final original = focusList[i];
          if (replacements.containsKey(original) && replacements[original] != original) {
            final replacement = replacements[original]!;
            focusList[i] = replacement;
            modified = true;
            focusChanges++;
            changesDetail['$original→$replacement'] = (changesDetail['$original→$replacement'] ?? 0) + 1;

            if (dryRun) {
              print('  • $nome: focus $original → $replacement');
            }
          }
        }

        if (modified) {
          ex['focus'] = focusList.join(', ');
        }
      }

      // Process muscoliSecondari (secondary muscles)
      final muscoliSecondari = ex['muscoliSecondari'];
      if (muscoliSecondari != null && muscoliSecondari.toString().isNotEmpty) {
        final secondaryList = muscoliSecondari.toString().split(',').map((e) => e.trim()).toList();
        var modified = false;

        for (var i = 0; i < secondaryList.length; i++) {
          final original = secondaryList[i];
          if (replacements.containsKey(original) && replacements[original] != original) {
            final replacement = replacements[original]!;
            secondaryList[i] = replacement;
            modified = true;
            secondaryChanges++;
            changesDetail['$original→$replacement'] = (changesDetail['$original→$replacement'] ?? 0) + 1;

            if (dryRun) {
              print('  • $nome: secondary $original → $replacement');
            }
          }
        }

        if (modified) {
          ex['muscoliSecondari'] = secondaryList.join(', ');
        }
      }
    }

    final totalChanges = focusChanges + secondaryChanges;

    if (totalChanges == 0) {
      print('  ✅ No changes needed\n');
      continue;
    }

    print('  📊 Changes:');
    print('     Focus (primary): $focusChanges');
    print('     Secondary: $secondaryChanges');
    print('     Total: $totalChanges');

    if (!dryRun && changesDetail.isNotEmpty) {
      print('\n  Breakdown:');
      for (final entry in changesDetail.entries) {
        print('     - ${entry.key}: ${entry.value} occurrences');
      }
    }

    if (!dryRun) {
      // Create backup
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = filePath.replaceAll('.json', '_backup_standardize_all_$timestamp.json');
      await file.copy(backupPath);
      print('  💾 Backup: $backupPath');

      // Write standardized content
      final encoder = JsonEncoder.withIndent('  ');
      final standardizedContent = encoder.convert(exercises);
      await file.writeAsString(standardizedContent);
      print('  ✅ File updated!\n');
    } else {
      print('  🔍 DRY RUN - Skipping file write\n');
    }
  }

  print('=' * 70);
  if (dryRun) {
    print('✅ Dry run complete! Run without --dry-run to apply changes');
  } else {
    print('✅ Standardization complete! All variants converted to canonical');
  }
  print('=' * 70);
}
