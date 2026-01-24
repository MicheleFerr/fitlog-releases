/// Validates that exercises in JSON files use correct canonical muscle abbreviations
///
/// Checks:
/// 1. Uses canonical abbreviations (not deprecated variants)
/// 2. No invalid muscle codes
/// 3. Focus makes sense for exercise name (basic validation)
/// 4. Secondary muscles are valid
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final verbose = args.contains('--verbose');

  print('🔬 Exercise Muscle Focus Validation\n');

  // Canonical abbreviations (4-letter standard)
  final canonical = {
    'TRIC', 'BICI', 'AVA',          // Arms (AVA is 3-letter exception)
    'LAT', 'TRAP', 'LOMB', 'ROMB',  // Back (LAT is 3-letter exception)
    'PETT',                          // Chest
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLL',  // Shoulders
    'GLUT', 'QUAD', 'FEMO', 'POLP', 'ADD', 'ABDU',        // Legs (ADD is 3-letter)
    'CORE', 'OBL',                   // Core
  };

  // Valid variants that should be converted to canonical
  final variants = {
    'BIC': 'BICI',
    'AVAMB': 'AVA',
    'LOMBAR': 'LOMB',
    'LOM': 'LOMB',
    'DORSO': 'LAT',
    'COLLO': 'COLL',
    'FEMOR': 'FEMO',
    'FEMO': 'FEMO', // Already canonical but keeping for clarity
    'POLL': 'POLP',
    'ADDO': 'ADD',
    'ADDUT': 'ADD',
    'ADDU': 'ADD',
    'ABDUT': 'ABDU',
    'ADDOM': 'CORE',
    'ROMBOIDI': 'ROMB',
    'OBLIQUI': 'OBL',
  };

  final files = [
    // Main files actually used by the app
    'assets/data/exercises_it.json',
    'assets/data/exercises.json',
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

  final issues = <String, List<Map<String, dynamic>>>{
    'using_variants': [],
    'invalid_muscles': [],
    'suspicious_focus': [],
    'invalid_secondary': [],
  };

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    print('📄 Validating: $filePath\n');

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final nome = ex['nome'] as String? ?? 'Unknown';
      final focusRaw = ex['focus'] as String? ?? '';
      final muscoliSecondariRaw = ex['muscoliSecondari']; // Can be String or List

      if (focusRaw.isEmpty) continue;

      final focusList = focusRaw.split(',').map((e) => e.trim().toUpperCase()).toList();

      // Check each focus muscle
      for (final focus in focusList) {
        if (focus.isEmpty) continue;

        // Check if using variant instead of canonical
        if (variants.containsKey(focus) && variants[focus] != focus) {
          issues['using_variants']!.add({
            'exercise': nome,
            'current': focus,
            'should_be': variants[focus],
            'file': filePath,
          });
        }

        // Check if invalid (not canonical and not variant)
        if (!canonical.contains(focus) && !variants.containsKey(focus)) {
          issues['invalid_muscles']!.add({
            'exercise': nome,
            'invalid': focus,
            'file': filePath,
          });
        }

        // Basic sanity check: exercise name vs focus
        final nomeLower = nome.toLowerCase();
        final suspiciousCombos = <String, List<String>>{
          'squat': ['BICI', 'TRIC', 'PETT', 'LAT'],
          'bench': ['QUAD', 'FEMO', 'GLUT', 'POLP'],
          'curl': ['QUAD', 'FEMO', 'GLUT', 'PETT', 'LAT'],
          'deadlift': ['BICI', 'TRIC', 'PETT'],
          'pull': ['QUAD', 'FEMO', 'GLUT'],
          'leg': ['BICI', 'TRIC', 'PETT', 'LAT'],
        };

        for (final combo in suspiciousCombos.entries) {
          if (nomeLower.contains(combo.key) && combo.value.contains(focus)) {
            issues['suspicious_focus']!.add({
              'exercise': nome,
              'focus': focus,
              'reason': '${combo.key} exercise with ${focus} focus',
              'file': filePath,
            });
          }
        }
      }

      // Check secondary muscles (can be string CSV or array)
      if (muscoliSecondariRaw != null) {
        List<String> secondaryList;

        // Handle both formats
        if (muscoliSecondariRaw is List) {
          secondaryList = muscoliSecondariRaw.map((e) => e.toString().trim().toUpperCase()).where((e) => e.isNotEmpty).toList();
        } else if (muscoliSecondariRaw is String && muscoliSecondariRaw.isNotEmpty) {
          secondaryList = muscoliSecondariRaw.split(',').map((e) => e.trim().toUpperCase()).where((e) => e.isNotEmpty).toList();
        } else {
          continue;
        }

        for (final muscle in secondaryList) {
          if (muscle.isEmpty) continue;

          if (!canonical.contains(muscle) && !variants.containsKey(muscle)) {
            issues['invalid_secondary']!.add({
              'exercise': nome,
              'invalid': muscle,
              'file': filePath,
            });
          }
        }
      }
    }
  }

  // Print results
  print('=' * 70);
  print('📊 VALIDATION RESULTS');
  print('=' * 70);

  // Using variants instead of canonical
  if (issues['using_variants']!.isNotEmpty) {
    print('\n⚠️  Using Variants Instead of Canonical (${issues['using_variants']!.length} cases):');
    final grouped = <String, Map<String, List<String>>>{};

    for (final issue in issues['using_variants']!) {
      final current = issue['current'] as String;
      final shouldBe = issue['should_be'] as String;

      grouped
          .putIfAbsent(current, () => {})
          .putIfAbsent(shouldBe, () => [])
          .add(issue['exercise'] as String);
    }

    for (final entry in grouped.entries) {
      for (final replacement in entry.value.entries) {
        print('\n  ${entry.key} → ${replacement.key}: ${replacement.value.length} exercises');
        if (verbose || replacement.value.length <= 5) {
          for (final ex in replacement.value.take(5)) {
            print('    • $ex');
          }
          if (replacement.value.length > 5) {
            print('    ... and ${replacement.value.length - 5} more');
          }
        }
      }
    }
  } else {
    print('\n✅ All exercises use canonical abbreviations!');
  }

  // Invalid muscles
  if (issues['invalid_muscles']!.isNotEmpty) {
    print('\n❌ Invalid Muscles (${issues['invalid_muscles']!.length} cases):');
    final grouped = <String, List<String>>{};

    for (final issue in issues['invalid_muscles']!) {
      final invalid = issue['invalid'] as String;
      grouped.putIfAbsent(invalid, () => []).add(issue['exercise'] as String);
    }

    for (final entry in grouped.entries) {
      print('\n  ${entry.key}: ${entry.value.length} exercises');
      if (verbose || entry.value.length <= 3) {
        for (final ex in entry.value) {
          print('    • $ex');
        }
      }
    }
  } else {
    print('\n✅ No invalid muscles found!');
  }

  // Suspicious focus
  if (issues['suspicious_focus']!.isNotEmpty) {
    print('\n🤔 Suspicious Focus Combinations (${issues['suspicious_focus']!.length} cases):');
    print('   (These might be errors - please review manually)\n');

    for (final issue in issues['suspicious_focus']!.take(10)) {
      print('  • ${issue['exercise']}: ${issue['focus']} (${issue['reason']})');
    }

    if (issues['suspicious_focus']!.length > 10) {
      print('  ... and ${issues['suspicious_focus']!.length - 10} more (use --verbose)');
    }
  } else {
    print('\n✅ No obviously suspicious focus combinations found!');
  }

  // Invalid secondary muscles
  if (issues['invalid_secondary']!.isNotEmpty) {
    print('\n❌ Invalid Secondary Muscles (${issues['invalid_secondary']!.length} cases):');
    final grouped = <String, List<String>>{};

    for (final issue in issues['invalid_secondary']!) {
      final invalid = issue['invalid'] as String;
      grouped.putIfAbsent(invalid, () => []).add(issue['exercise'] as String);
    }

    for (final entry in grouped.entries) {
      print('\n  ${entry.key}: ${entry.value.length} exercises');
      if (verbose || entry.value.length <= 3) {
        for (final ex in entry.value) {
          print('    • $ex');
        }
      }
    }
  } else {
    print('\n✅ All secondary muscles are valid!');
  }

  // Summary
  print('\n' + '=' * 70);
  print('📋 SUMMARY');
  print('=' * 70);
  print('Using variants (need conversion): ${issues['using_variants']!.length}');
  print('Invalid muscles: ${issues['invalid_muscles']!.length}');
  print('Suspicious focus: ${issues['suspicious_focus']!.length}');
  print('Invalid secondary: ${issues['invalid_secondary']!.length}');

  final totalIssues = issues.values.fold(0, (sum, list) => sum + list.length);

  if (totalIssues == 0) {
    print('\n✅ All validations passed! JSON files are correct.');
  } else {
    print('\n⚠️  Found $totalIssues issues that need review.');
    print('\nRun with --verbose to see all exercises.');
  }
}
