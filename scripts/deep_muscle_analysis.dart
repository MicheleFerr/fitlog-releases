/// Deep analysis of muscle groups across all exercise JSON files
///
/// Checks for:
/// - Abbreviation inconsistencies
/// - Missing muscle groups
/// - Suspicious patterns
/// - Data quality issues
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔬 Deep Muscle Focus Analysis\n');

  // Valid canonical abbreviations
  final canonical = {
    'TRIC', 'BICI', 'AVA',          // Arms
    'LAT', 'TRAP', 'LOMBAR',        // Back
    'PETT',                          // Chest
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLLO',  // Shoulders
    'GLUT', 'QUAD', 'FEMOR', 'POLP', 'ADD', 'ABDU',        // Legs
    'CORE',                          // Core
  };

  // All valid (including variants)
  final allValid = {
    ...canonical,
    'BIC', 'AVAMB',                 // Arms variants
    'LOMB', 'LOM', 'DORSO',         // Back variants
    'FEMO', 'POLL', 'ADDO', 'ADDUT', 'ABDUT',  // Legs variants
    'ADDOM',                         // Core variants
  };

  final files = [
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',
  ];

  // Collect data
  final allFocusValues = <String>{};
  final focusStats = <String, int>{};
  final exercisesByFocus = <String, List<String>>{};
  final secondaryMuscles = <String>{};
  final suspiciousExercises = <Map<String, dynamic>>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;
      final nome = ex['nome'] as String? ?? 'Unknown';
      final focusRaw = ex['focus'];
      final muscoliSecondari = ex['muscoliSecondari'];

      // Analyze primary focus
      if (focusRaw != null && focusRaw.toString().isNotEmpty) {
        final focusList = focusRaw.toString().split(',').map((e) => e.trim()).toList();

        for (final focus in focusList) {
          if (focus.isEmpty) continue;

          allFocusValues.add(focus);
          focusStats[focus] = (focusStats[focus] ?? 0) + 1;
          exercisesByFocus.putIfAbsent(focus, () => []).add(nome);

          // Check for suspicious patterns
          if (focus.length == 3 && focus != focus.toUpperCase()) {
            suspiciousExercises.add({
              'exercise': nome,
              'issue': 'Mixed case focus',
              'value': focus,
            });
          }

          if (focus.contains(' ')) {
            suspiciousExercises.add({
              'exercise': nome,
              'issue': 'Focus contains spaces',
              'value': focus,
            });
          }

          if (focus.length > 10) {
            suspiciousExercises.add({
              'exercise': nome,
              'issue': 'Focus too long',
              'value': focus,
            });
          }
        }
      }

      // Analyze secondary muscles
      if (muscoliSecondari != null && muscoliSecondari.toString().isNotEmpty) {
        final secondaryList = muscoliSecondari.toString().split(',').map((e) => e.trim()).toList();
        secondaryMuscles.addAll(secondaryList);
      }
    }
  }

  // Print results
  print('=' * 70);
  print('📊 COMPLETE MUSCLE FOCUS INVENTORY');
  print('=' * 70);
  print('\n🎯 Primary Focus Muscles (${allFocusValues.length} unique values):');

  final sortedByCount = focusStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sortedByCount) {
    final isCanonical = canonical.contains(entry.key);
    final isValid = allValid.contains(entry.key);
    final status = !isValid
        ? '❌ INVALID'
        : isCanonical
            ? '✅ CANONICAL'
            : '⚠️  VARIANT';

    print('${entry.key.padRight(15)} ${entry.value.toString().padLeft(4)} uses  $status');
  }

  // Missing canonical muscles
  print('\n🔍 Missing Canonical Muscles:');
  final unusedCanonical = canonical.where((c) => !allFocusValues.contains(c)).toList();
  if (unusedCanonical.isEmpty) {
    print('✅ All canonical muscles are used!');
  } else {
    for (final missing in unusedCanonical) {
      print('  ⚠️  $missing - not used in any exercise');
    }
  }

  // Invalid muscles
  print('\n❌ Invalid Muscles:');
  final invalid = allFocusValues.where((f) => !allValid.contains(f)).toList();
  if (invalid.isEmpty) {
    print('✅ No invalid muscles found!');
  } else {
    for (final inv in invalid) {
      print('  • $inv (${focusStats[inv]} uses)');
      final exercises = exercisesByFocus[inv]!;
      if (exercises.length <= 3) {
        for (final ex in exercises) {
          print('      - $ex');
        }
      } else {
        print('      - ${exercises.take(2).join(", ")}, ... (${exercises.length} total)');
      }
    }
  }

  // Suspicious patterns
  if (suspiciousExercises.isNotEmpty) {
    print('\n⚠️  Suspicious Patterns Found:');
    for (final issue in suspiciousExercises) {
      print('  • ${issue['exercise']}: ${issue['issue']} ("${issue['value']}")');
    }
  }

  // Secondary muscles analysis
  print('\n📊 Secondary Muscles (${secondaryMuscles.length} unique values):');
  final sortedSecondary = secondaryMuscles.toList()..sort();
  for (final muscle in sortedSecondary) {
    if (muscle.isEmpty) continue;
    final isValid = allValid.contains(muscle);
    final status = isValid ? '✅' : '❌';
    print('  $status $muscle');
  }

  // Coverage analysis
  print('\n' + '=' * 70);
  print('📈 COVERAGE ANALYSIS');
  print('=' * 70);
  print('Total unique primary focus: ${allFocusValues.length}');
  print('Canonical muscles: ${canonical.length}');
  print('Used canonical: ${canonical.where((c) => allFocusValues.contains(c)).length}');
  print('Invalid muscles: ${invalid.length}');
  print('Suspicious patterns: ${suspiciousExercises.length}');

  print('\n✅ Deep analysis complete!\n');
}
