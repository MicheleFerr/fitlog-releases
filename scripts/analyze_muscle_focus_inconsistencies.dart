/// Script to analyze muscle focus inconsistencies in exercise JSON files
///
/// Identifies:
/// - Invalid abbreviations (QUAD vs QUA, ADD vs ADDO, ADDU)
/// - Missing muscle groups
/// - Inconsistent naming
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Analyzing Muscle Focus Inconsistencies\n');

  // Valid muscle abbreviations according to MuscleAbbreviationMapper
  final validAbbreviations = {
    // Arms
    'TRIC', 'BICI', 'BIC', 'AVA', 'AVAMB',
    // Back
    'LAT', 'TRAP', 'LOMBAR', 'LOMB', 'LOM', 'DORSO',
    // Chest
    'PETT',
    // Shoulders
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLLO',
    // Legs
    'GLUT', 'QUAD', 'FEMOR', 'FEMO', 'POLP', 'POLL',
    'ADD', 'ADDO', 'ADDUT', 'ADDU', 'ABDUT', 'ABDU',
    // Core
    'CORE', 'ADDOM',
  };

  // Canonical/preferred abbreviations
  final canonicalMap = {
    'BIC': 'BICI',
    'AVAMB': 'AVA',
    'LOMB': 'LOMBAR',
    'LOM': 'LOMBAR',
    'DORSO': 'LAT',
    'FEMO': 'FEMOR',
    'POLL': 'POLP',
    'ADDO': 'ADD',
    'ADDUT': 'ADD',
    'ADDU': 'ADD',  // INVALID - should not exist
    'ABDUT': 'ABDU',
    'ADDOM': 'CORE',
  };

  // Check multiple exercise files
  final filesToCheck = [
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',
  ];

  final allIssues = <String, List<Map<String, dynamic>>>{};
  final focusStats = <String, int>{};

  for (final filePath in filesToCheck) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath\n');
      continue;
    }

    print('📄 Analyzing: $filePath');
    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    print('   Found ${exercises.length} exercises\n');

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final nome = ex['nome'] as String? ?? 'Unknown';
      final focusRaw = ex['focus'];

      if (focusRaw == null || focusRaw.toString().isEmpty) {
        continue;
      }

      final focusList = focusRaw.toString().split(',').map((e) => e.trim()).toList();

      for (final focus in focusList) {
        if (focus.isEmpty) continue;

        // Count occurrences
        focusStats[focus] = (focusStats[focus] ?? 0) + 1;

        // Check if invalid
        if (!validAbbreviations.contains(focus)) {
          allIssues.putIfAbsent('INVALID', () => []).add({
            'exercise': nome,
            'focus': focus,
            'file': filePath,
          });
        }

        // Check if should be replaced with canonical
        if (canonicalMap.containsKey(focus)) {
          final canonical = canonicalMap[focus]!;
          allIssues.putIfAbsent('NON_CANONICAL', () => []).add({
            'exercise': nome,
            'current': focus,
            'should_be': canonical,
            'file': filePath,
          });
        }
      }
    }
  }

  // Print results
  print('\n' + '=' * 70);
  print('📊 FOCUS ABBREVIATION STATISTICS');
  print('=' * 70);

  final sortedStats = focusStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sortedStats) {
    final isValid = validAbbreviations.contains(entry.key);
    final canonical = canonicalMap[entry.key];
    final marker = !isValid
        ? '❌ INVALID'
        : canonical != null
            ? '⚠️  → $canonical'
            : '✅';

    print('${entry.key.padRight(15)} ${entry.value.toString().padLeft(4)} occurrences $marker');
  }

  // Print issues
  print('\n' + '=' * 70);
  print('🚨 ISSUES FOUND');
  print('=' * 70);

  if (allIssues['INVALID']?.isNotEmpty == true) {
    print('\n❌ INVALID ABBREVIATIONS (${allIssues['INVALID']!.length} cases):');
    final grouped = <String, List<String>>{};
    for (final issue in allIssues['INVALID']!) {
      final focus = issue['focus'] as String;
      grouped.putIfAbsent(focus, () => []).add(issue['exercise'] as String);
    }
    for (final entry in grouped.entries) {
      print('  • ${entry.key}: ${entry.value.length} exercises');
      if (entry.value.length <= 5) {
        for (final ex in entry.value) {
          print('      - $ex');
        }
      } else {
        print('      - ${entry.value.take(3).join(", ")}, ...');
      }
    }
  }

  if (allIssues['NON_CANONICAL']?.isNotEmpty == true) {
    print('\n⚠️  NON-CANONICAL ABBREVIATIONS (${allIssues['NON_CANONICAL']!.length} cases):');
    final grouped = <String, Map<String, List<String>>>{};
    for (final issue in allIssues['NON_CANONICAL']!) {
      final current = issue['current'] as String;
      final shouldBe = issue['should_be'] as String;
      grouped
          .putIfAbsent(current, () => {})
          .putIfAbsent(shouldBe, () => [])
          .add(issue['exercise'] as String);
    }
    for (final entry in grouped.entries) {
      for (final replacement in entry.value.entries) {
        print('  • ${entry.key} → ${replacement.key}: ${replacement.value.length} exercises');
        if (replacement.value.length <= 3) {
          for (final ex in replacement.value) {
            print('      - $ex');
          }
        }
      }
    }
  }

  // Summary
  print('\n' + '=' * 70);
  print('📋 SUMMARY');
  print('=' * 70);
  print('Total unique focus values: ${focusStats.length}');
  print('Invalid abbreviations: ${allIssues['INVALID']?.map((e) => e['focus']).toSet().length ?? 0}');
  print('Non-canonical (need replacement): ${allIssues['NON_CANONICAL']?.map((e) => e['current']).toSet().length ?? 0}');

  print('\n✅ Analysis complete!\n');
}
