/// Script to fix muscle focus inconsistencies in exercise JSON files
///
/// Fixes:
/// - ADDO → ADD (canonical)
/// - BIC → BICI (canonical)
/// - ANCA → GLUT (hip circles primarily target glutes)
///
/// Creates backups before modifying
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

  // Replacements map
  final replacements = {
    'ADDO': 'ADD',
    'BIC': 'BICI',
    'ANCA': 'GLUT', // Hip circles = glute activation exercise
  };

  // Files to fix
  final filesToFix = [
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',
  ];

  for (final filePath in filesToFix) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath\n');
      continue;
    }

    print('📄 Processing: $filePath');

    // Read and parse
    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    var changesCount = 0;
    final changesDetail = <String, int>{};

    // Process exercises
    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final focusRaw = ex['focus'];

      if (focusRaw == null || focusRaw.toString().isEmpty) {
        continue;
      }

      final focusList = focusRaw.toString().split(',').map((e) => e.trim()).toList();
      var modified = false;

      for (var i = 0; i < focusList.length; i++) {
        final original = focusList[i];
        if (replacements.containsKey(original)) {
          final replacement = replacements[original]!;
          focusList[i] = replacement;
          modified = true;
          changesCount++;
          changesDetail[original] = (changesDetail[original] ?? 0) + 1;

          print('  • ${ex['nome']}: $original → $replacement');
        }
      }

      if (modified) {
        ex['focus'] = focusList.join(', ');
      }
    }

    if (changesCount == 0) {
      print('  ✅ No changes needed\n');
      continue;
    }

    print('  📊 Changes: $changesCount');
    for (final entry in changesDetail.entries) {
      print('     - ${entry.key} → ${replacements[entry.key]}: ${entry.value} occurrences');
    }

    if (!dryRun) {
      // Create backup
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = filePath.replaceAll('.json', '_backup_before_focus_fix_$timestamp.json');
      await file.copy(backupPath);
      print('  💾 Backup created: $backupPath');

      // Write fixed content
      final encoder = JsonEncoder.withIndent('  ');
      final fixedContent = encoder.convert(exercises);
      await file.writeAsString(fixedContent);
      print('  ✅ File updated!\n');
    } else {
      print('  🔍 DRY RUN - Skipping file write\n');
    }
  }

  print('=' * 70);
  if (dryRun) {
    print('✅ Dry run complete! Run without --dry-run to apply changes');
  } else {
    print('✅ Fix complete! All inconsistencies have been resolved');
  }
  print('=' * 70);
}
