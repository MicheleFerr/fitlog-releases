/// Quick check for any remaining non-canonical muscle abbreviations
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking for any remaining variants or unknown muscles\n');

  // All known canonical + variants from MuscleAbbreviationMapper
  final knownMuscles = {
    // Canonical
    'TRIC', 'BICI', 'AVA',
    'LAT', 'TRAP', 'LOMB', 'ROMB',
    'PETT',
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLL',
    'GLUT', 'QUAD', 'FEMO', 'POLP', 'ADD', 'ABDU',
    'CORE', 'OBL',

    // Known variants (should have been converted)
    'BIC', 'AVAMB',
    'LOMBAR', 'LOM', 'DORSO',
    'COLLO',
    'FEMOR', 'POLL',
    'ADDO', 'ADDUT', 'ADDU', 'ABDUT',
    'ADDOM',
    'ROMBOIDI', 'OBLIQUI',
    'ANCA', // Old variant
  };

  final files = [
    'exercises_it.json',
    'exercises_it_complete.json',
  ];

  final allMuscles = <String>{};
  final unknownMuscles = <String>{};
  final variantsFound = <String, int>{};

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    print('📄 Analyzing: $filePath');

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List<dynamic>;

    for (final exercise in exercises) {
      final ex = exercise as Map<String, dynamic>;

      // Check focus
      final focus = ex['focus'] as String? ?? '';
      if (focus.isNotEmpty) {
        final muscles = focus.split(',').map((e) => e.trim().toUpperCase()).where((e) => e.isNotEmpty);
        allMuscles.addAll(muscles);

        for (final muscle in muscles) {
          if (!knownMuscles.contains(muscle)) {
            unknownMuscles.add(muscle);
          } else if (muscle != muscle && knownMuscles.contains(muscle)) {
            // It's a variant, not canonical
            variantsFound[muscle] = (variantsFound[muscle] ?? 0) + 1;
          }
        }
      }

      // Check secondary
      final secondary = ex['muscoliSecondari'] as String? ?? '';
      if (secondary.isNotEmpty) {
        final muscles = secondary.split(',').map((e) => e.trim().toUpperCase()).where((e) => e.isNotEmpty);
        allMuscles.addAll(muscles);

        for (final muscle in muscles) {
          if (!knownMuscles.contains(muscle)) {
            unknownMuscles.add(muscle);
          }
        }
      }
    }
  }

  print('\n' + '=' * 70);
  print('📊 RESULTS');
  print('=' * 70);

  print('\n✅ Total unique muscle values found: ${allMuscles.length}');
  print('   All values: ${allMuscles.toList()..sort()}');

  if (unknownMuscles.isEmpty) {
    print('\n✅ No unknown muscles found! All values are in the mapper.');
  } else {
    print('\n❌ Unknown muscles found (${unknownMuscles.length}):');
    for (final muscle in unknownMuscles.toList()..sort()) {
      print('   - $muscle');
    }
  }

  // Check if any variants are still present
  final canonicalOnly = {
    'TRIC', 'BICI', 'AVA',
    'LAT', 'TRAP', 'LOMB', 'ROMB',
    'PETT',
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLL',
    'GLUT', 'QUAD', 'FEMO', 'POLP', 'ADD', 'ABDU',
    'CORE', 'OBL',
  };

  final remainingVariants = allMuscles.where((m) => !canonicalOnly.contains(m)).toSet();

  if (remainingVariants.isEmpty) {
    print('\n✅ Perfect! Only canonical abbreviations are used.');
  } else {
    print('\n⚠️  Non-canonical values still present (${remainingVariants.length}):');
    for (final variant in remainingVariants.toList()..sort()) {
      print('   - $variant');
    }
  }
}
