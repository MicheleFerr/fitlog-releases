/// Fixes fake array strings like "[BIC, AVA]" to real arrays ["BIC", "AVA"]
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

  final files = [
    'assets/data/exercises/upper_pull.json',
    'assets/data/exercises/upper_push.json',
    'assets/data/exercises/lower.json',
    'assets/data/exercises/core.json',
    'assets/data/exercises/other.json',
    'assets/data/exercises_en/upper_pull.json',
    'assets/data/exercises_en/upper_push.json',
    'assets/data/exercises_en/lower.json',
    'assets/data/exercises_en/core.json',
    'assets/data/exercises_en/other.json',
  ];

  var totalFiles = 0;
  var totalFixes = 0;

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath\n');
      continue;
    }

    print('📄 Processing: $filePath');

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    var fileFixes = 0;

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final secondaryRaw = ex['muscoliSecondari'];

      // Check if it's a fake array string
      if (secondaryRaw is String &&
          secondaryRaw.startsWith('[') &&
          secondaryRaw.endsWith(']')) {

        // Extract content between brackets
        final content = secondaryRaw.substring(1, secondaryRaw.length - 1);

        // Split by comma and trim
        final muscles = content
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Replace with real array
        ex['muscoliSecondari'] = muscles;
        fileFixes++;

        if (dryRun) {
          print('  • ${ex['nome']}: "$secondaryRaw" → ${jsonEncode(muscles)}');
        }
      }
    }

    if (fileFixes == 0) {
      print('  ✅ No fake arrays found\n');
      continue;
    }

    totalFiles++;
    totalFixes += fileFixes;

    print('  📊 Fixed: $fileFixes fake arrays');

    if (!dryRun) {
      // Create backup
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = filePath.replaceAll('.json', '_backup_fix_arrays_$timestamp.json');
      await file.copy(backupPath);
      print('  💾 Backup: $backupPath');

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
    print('✅ Dry run complete!');
    print('   Files with fake arrays: $totalFiles');
    print('   Total fake arrays found: $totalFixes');
    print('\n   Run without --dry-run to fix them');
  } else {
    print('✅ Fix complete!');
    print('   Files fixed: $totalFiles');
    print('   Total fake arrays converted: $totalFixes');
  }
  print('=' * 70);
}
