/// Quick check for any remaining non-canonical muscle abbreviations
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking for any remaining variants or unknown muscles\n');

  // All known canonical from MuscleAbbreviationMapper
  final canonical = {
    'TRIC', 'BICI', 'AVA',
    'LAT', 'TRAP', 'LOMB', 'ROMB',
    'PETT',
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLL',
    'GLUT', 'QUAD', 'FEMO', 'POLP', 'ADD', 'ABDU',
    'CORE', 'OBL',
  };

  final files = [
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',
  ];

  final allMuscles = <String>{};
  final nonCanonical = <String, int>{};

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath\n');
      continue;
    }

    print('📄 Analyzing: $filePath');

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;

      // Check focus
      final focus = ex['focus'] as String? ?? '';
      if (focus.isNotEmpty) {
        final muscles = focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final muscle in muscles) {
          allMuscles.add(muscle);
          if (!canonical.contains(muscle)) {
            nonCanonical[muscle] = (nonCanonical[muscle] ?? 0) + 1;
          }
        }
      }

      // Check secondary
      final secondary = ex['muscoliSecondari'] as String? ?? '';
      if (secondary.isNotEmpty) {
        final muscles = secondary.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final muscle in muscles) {
          allMuscles.add(muscle);
          if (!canonical.contains(muscle)) {
            nonCanonical[muscle] = (nonCanonical[muscle] ?? 0) + 1;
          }
        }
      }
    }
  }

  print('\n' + '=' * 70);
  print('📊 RESULTS');
  print('=' * 70);

  print('\n✅ Total unique muscle values found: ${allMuscles.length}');
  
  if (nonCanonical.isEmpty) {
    print('\n✅ Perfect! Only canonical abbreviations are used.');
    print('   All ${allMuscles.length} values are canonical: ${allMuscles.toList()..sort()}');
  } else {
    print('\n⚠️  Non-canonical values found (${nonCanonical.length}):');
    final sorted = nonCanonical.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sorted) {
      print('   - ${entry.key}: ${entry.value} occurrences');
    }
    print('\n   These should be added to the standardization script!');
  }
}
