/// Standardizes ALL muscle variants across ALL JSON files in the project
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

  // Complete mapping: ALL variants → canonical
  final replacements = {
    // Previously fixed variants
    'ADDO': 'ADD',
    'ADDUT': 'ADD',
    'ADDU': 'ADD',
    'BIC': 'BICI',
    'ANCA': 'GLUT',
    'FEMOR': 'FEMO',
    'LOMBAR': 'LOMB',
    'LOM': 'LOMB',
    'COLLO': 'COLL',
    'AVAMB': 'AVA',
    'DORSO': 'LAT',
    'POLL': 'POLP',
    'ABDUT': 'ABDU',
    'ADDOM': 'CORE',
    'ROMBOIDI': 'ROMB',
    'OBLIQUI': 'OBL',

    // New variants from exercises_with_tut.json
    'PET': 'PETT',
    'DELT ANT': 'DELT_ANT',
    'DELT POST': 'DELT_POST',
    'DELT LAT': 'DELT_LAT',
    'SCH': 'LAT', // Schiena = Dorsali
    'DORS': 'LAT', // Abbreviation of DORSO
    'SPALLA': 'DELT',
    'OBLIQ': 'OBL',
    'GLUTEI': 'GLUT',
    'DEL': 'DELT',
    'ABD': 'ABDU',
    'PET SUP': 'PETT', // Petto superiore → generic chest
    'DORSO SUP': 'LAT', // Upper back → lats

    // Keep RISCALDAMENTO as-is (warmup, not a muscle)
    // It will be ignored in muscle analysis
  };

  final filesToProcess = [
    // Fallback files (used only if exercises/ folder is empty)
    'assets/data/exercises_it.json',
    'assets/data/exercises.json',

    // Main files (italiano) - actually used by the app
    'assets/data/exercises/upper_pull.json',
    'assets/data/exercises/upper_push.json',
    'assets/data/exercises/lower.json',
    'assets/data/exercises/core.json',
    'assets/data/exercises/other.json',

    // Main files (english) - actually used by the app
    'assets/data/exercises_en/upper_pull.json',
    'assets/data/exercises_en/upper_push.json',
    'assets/data/exercises_en/lower.json',
    'assets/data/exercises_en/core.json',
    'assets/data/exercises_en/other.json',
  ];

  var totalFiles = 0;
  var totalChanges = 0;

  for (final filePath in filesToProcess) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath\n');
      continue;
    }

    print('📄 Processing: $filePath');

    final content = await file.readAsString();
    List<dynamic> exercises;

    try {
      final data = jsonDecode(content);
      if (data is List) {
        exercises = data;
      } else {
        print('  ⚠️  Unexpected JSON structure, skipping\n');
        continue;
      }
    } catch (e) {
      print('  ⚠️  JSON parse error: $e\n');
      continue;
    }

    var fileChanges = 0;
    final changesDetail = <String, int>{};

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;

      // Process focus (primary muscles)
      final focusRaw = ex['focus'];
      if (focusRaw != null && focusRaw.toString().isNotEmpty) {
        final focusList = focusRaw.toString().split(',').map((e) => e.trim()).toList();
        var modified = false;

        for (var i = 0; i < focusList.length; i++) {
          final original = focusList[i];
          if (replacements.containsKey(original)) {
            final replacement = replacements[original]!;
            focusList[i] = replacement;
            modified = true;
            fileChanges++;
            changesDetail['$original→$replacement'] = (changesDetail['$original→$replacement'] ?? 0) + 1;
          }
        }

        if (modified) {
          ex['focus'] = focusList.join(', ');
        }
      }

      // Process muscoliSecondari (secondary muscles)
      final secondaryFields = ['muscoliSecondari', 'secondaryMuscles'];
      for (final field in secondaryFields) {
        final muscoliSecondari = ex[field];
        if (muscoliSecondari == null) continue;

        List<String> secondaryList;
        bool wasArray = false;

        // Handle both string CSV and JSON array formats
        if (muscoliSecondari is List) {
          wasArray = true;
          secondaryList = muscoliSecondari.map((e) => e.toString().trim()).toList();
        } else if (muscoliSecondari.toString().isNotEmpty) {
          secondaryList = muscoliSecondari.toString().split(',').map((e) => e.trim()).toList();
        } else {
          continue;
        }

        var modified = false;

        for (var i = 0; i < secondaryList.length; i++) {
          final original = secondaryList[i];
          if (replacements.containsKey(original)) {
            final replacement = replacements[original]!;
            secondaryList[i] = replacement;
            modified = true;
            fileChanges++;
            changesDetail['$original→$replacement'] = (changesDetail['$original→$replacement'] ?? 0) + 1;
          }
        }

        if (modified) {
          // Keep original format (array or CSV string)
          if (wasArray) {
            ex[field] = secondaryList;
          } else {
            ex[field] = secondaryList.join(', ');
          }
        }
      }
    }

    if (fileChanges == 0) {
      print('  ✅ No changes needed\n');
      continue;
    }

    totalFiles++;
    totalChanges += fileChanges;

    print('  📊 Changes: $fileChanges');

    if (changesDetail.isNotEmpty) {
      print('  Breakdown:');
      final sorted = changesDetail.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sorted.take(5)) {
        print('     - ${entry.key}: ${entry.value} occurrences');
      }
      if (sorted.length > 5) {
        print('     ... and ${sorted.length - 5} more');
      }
    }

    if (!dryRun) {
      // Create backup
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = filePath.replaceAll('.json', '_backup_std_$timestamp.json');
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
    print('✅ Dry run complete!');
    print('   Files that need changes: $totalFiles');
    print('   Total changes needed: $totalChanges');
    print('\n   Run without --dry-run to apply changes');
  } else {
    print('✅ Standardization complete!');
    print('   Files modified: $totalFiles');
    print('   Total changes applied: $totalChanges');
  }
  print('=' * 70);
}
