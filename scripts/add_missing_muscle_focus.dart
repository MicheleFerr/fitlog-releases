/// Script to identify exercises that should use missing muscle groups
///
/// Missing canonical muscles:
/// - LOMBAR (Lower Back) - critical for deadlifts, rows
/// - ABDU (Abductors) - critical for hip abduction exercises
/// - DELT_ANT/LAT/POST (Deltoid portions) - for specific shoulder work
/// - COLLO (Neck) - for neck-specific exercises
///
/// Invalid secondary muscles:
/// - ANCA → GLUT
/// - AVAM → AVA
/// - OBLIQUI → should be mapped or kept?
/// - ROMBOIDI → should be mapped or kept?
/// - SPALLE → DELT
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final dryRun = args.contains('--dry-run');

  if (dryRun) {
    print('🔍 DRY RUN MODE - Analysis only\n');
  } else {
    print('⚠️  LIVE MODE - Will apply changes\n');
  }

  final files = [
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',
  ];

  // Exercise name patterns for missing muscles
  final patterns = {
    'LOMBAR': [
      'stacco',
      'deadlift',
      'good morning',
      'iperestension',
      'hyperextension',
      'lower back',
      'lombar',
      'back extension',
    ],
    'ABDU': [
      'abduzione',
      'abduction',
      'hip abduction',
      'lateral',
      'laterale',
      'band walk',
      'clamshell',
    ],
    'DELT_ANT': [
      'front raise',
      'alzata frontale',
      'anteriore',
      'front delt',
    ],
    'DELT_LAT': [
      'lateral raise',
      'alzata laterale',
      'side raise',
      'laterale',
      'side delt',
    ],
    'DELT_POST': [
      'rear delt',
      'posteriore',
      'bent over',
      'face pull',
      'reverse fly',
    ],
    'COLLO': [
      'neck',
      'collo',
      'shrug',
      'scrollat',
    ],
  };

  // Secondary muscle fixes
  final secondaryFixes = {
    'ANCA': 'GLUT',
    'AVAM': 'AVA',
    'SPALLE': 'DELT',
  };

  final suggestions = <String, List<Map<String, dynamic>>>{};
  var secondaryFixCount = 0;

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    print('📄 Analyzing: $filePath\n');

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final nome = (ex['nome'] as String? ?? '').toLowerCase();
      final focusRaw = ex['focus'] as String? ?? '';
      final currentFocus = focusRaw.split(',').map((e) => e.trim()).toSet();

      // Check for missing focus muscles
      for (final entry in patterns.entries) {
        final muscle = entry.key;
        final keywords = entry.value;

        // Skip if already has this focus
        if (currentFocus.contains(muscle)) continue;

        // Check if exercise name matches any keyword
        for (final keyword in keywords) {
          if (nome.contains(keyword)) {
            suggestions.putIfAbsent(muscle, () => []).add({
              'exercise': ex['nome'],
              'current_focus': focusRaw,
              'keyword_matched': keyword,
              'suggestion': 'Add $muscle to focus',
            });
            break;
          }
        }
      }

      // Fix secondary muscles
      final muscoliSecondari = ex['muscoliSecondari'] as String? ?? '';
      if (muscoliSecondari.isNotEmpty) {
        var modified = false;
        var newSecondary = muscoliSecondari;

        for (final entry in secondaryFixes.entries) {
          if (muscoliSecondari.contains(entry.key)) {
            newSecondary = newSecondary.replaceAll(entry.key, entry.value);
            modified = true;
            secondaryFixCount++;
          }
        }

        if (modified && !dryRun) {
          ex['muscoliSecondari'] = newSecondary;
        }
      }
    }

    // Write fixed file
    if (!dryRun && secondaryFixCount > 0) {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupPath = filePath.replaceAll('.json', '_backup_secondary_fix_$timestamp.json');
      await file.copy(backupPath);

      final encoder = JsonEncoder.withIndent('  ');
      final fixedContent = encoder.convert(exercises);
      await file.writeAsString(fixedContent);
      print('  💾 Backup: $backupPath');
      print('  ✅ Fixed $secondaryFixCount secondary muscles\n');
    }
  }

  // Print suggestions
  print('\n' + '=' * 70);
  print('💡 SUGGESTIONS FOR MISSING MUSCLES');
  print('=' * 70);

  for (final entry in suggestions.entries) {
    final muscle = entry.key;
    final cases = entry.value;

    print('\n🎯 $muscle (${cases.length} potential exercises):');

    for (final suggestion in cases.take(10)) {
      print('  • ${suggestion['exercise']}');
      print('    Current: ${suggestion['current_focus']}');
      print('    Matched: "${suggestion['keyword_matched']}"');
      print('    → Suggestion: ${suggestion['suggestion']}');
    }

    if (cases.length > 10) {
      print('  ... and ${cases.length - 10} more');
    }
  }

  // Summary
  print('\n' + '=' * 70);
  print('📊 SUMMARY');
  print('=' * 70);
  for (final entry in suggestions.entries) {
    print('${entry.key}: ${entry.value.length} exercises need review');
  }
  print('\nSecondary muscle fixes: $secondaryFixCount');

  if (dryRun) {
    print('\n🔍 Run without --dry-run to apply secondary muscle fixes');
  } else {
    print('\n✅ Secondary muscle fixes applied!');
  }

  print('\n⚠️  NOTE: Focus muscle additions require manual review');
  print('   Review suggestions above and apply selectively');
}
