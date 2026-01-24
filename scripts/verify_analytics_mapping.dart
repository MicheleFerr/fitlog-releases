/// Verifica matching tra muscoli nei JSON e MuscleAbbreviationMapper
///
/// Checks:
/// 1. Tutti i muscoli nei JSON sono mappati nel mapper
/// 2. Tutti i muscoli canonical nel mapper esistono nei JSON
/// 3. Nessuna discrepanza tra sistema analytics e dati reali
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Verifying Analytics Mapping Consistency\n');

  // Step 1: Extract ALL muscle IDs from MuscleAbbreviationMapper
  print('📖 Reading MuscleAbbreviationMapper...');
  final mapperFile = File('lib/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart');
  final mapperContent = await mapperFile.readAsString();

  // Extract canonical muscle IDs (those that appear as 'id: ')
  final canonicalRegex = RegExp(r"id: '([A-Z_]+)'");
  final canonicalMatches = canonicalRegex.allMatches(mapperContent);
  final canonicalMuscles = <String>{};

  for (final match in canonicalMatches) {
    canonicalMuscles.add(match.group(1)!);
  }

  // Extract ALL mapped muscles (keys in the map)
  final keyRegex = RegExp(r"'([A-Z_\s]+)': MuscleInfo");
  final keyMatches = keyRegex.allMatches(mapperContent);
  final allMappedMuscles = <String>{};

  for (final match in keyMatches) {
    allMappedMuscles.add(match.group(1)!);
  }

  print('  ✅ Canonical muscles in mapper: ${canonicalMuscles.length}');
  print('  ✅ Total mapped muscles (incl. variants): ${allMappedMuscles.length}');
  print('');

  // Step 2: Extract ALL muscles from JSON files
  print('📄 Reading all exercise JSON files...');
  final jsonFiles = [
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

  final musclesInJson = <String>{};
  final muscleUsageCount = <String, int>{};

  for (final path in jsonFiles) {
    final file = File(path);
    if (!file.existsSync()) continue;

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List;

    for (final ex in exercises) {
      final exercise = ex as Map<String, dynamic>;

      // Focus (primary)
      final focus = exercise['focus'];
      if (focus is String && focus.isNotEmpty) {
        for (final muscle in focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)) {
          musclesInJson.add(muscle);
          muscleUsageCount[muscle] = (muscleUsageCount[muscle] ?? 0) + 1;
        }
      }

      // Secondary
      final secondary = exercise['muscoliSecondari'];
      List<String> muscles = [];

      if (secondary is List) {
        muscles = secondary.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      } else if (secondary is String && secondary.isNotEmpty) {
        muscles = secondary.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      for (final muscle in muscles) {
        musclesInJson.add(muscle);
        muscleUsageCount[muscle] = (muscleUsageCount[muscle] ?? 0) + 1;
      }
    }
  }

  print('  ✅ Unique muscles in JSON files: ${musclesInJson.length}');
  print('');

  // Step 3: Cross-reference analysis
  print('=' * 70);
  print('🔍 CROSS-REFERENCE ANALYSIS');
  print('=' * 70);

  // Check 1: Muscles in JSON but NOT mapped
  final unmappedMuscles = musclesInJson.where((m) => !allMappedMuscles.contains(m)).toSet();

  if (unmappedMuscles.isEmpty) {
    print('\n✅ All muscles in JSON are mapped in MuscleAbbreviationMapper');
  } else {
    print('\n❌ Muscles in JSON but NOT mapped (${unmappedMuscles.length}):');
    for (final muscle in unmappedMuscles.toList()..sort()) {
      final count = muscleUsageCount[muscle] ?? 0;
      print('   - $muscle ($count occurrences)');
    }
  }

  // Check 2: Canonical muscles in mapper but NEVER used in JSON
  final unusedCanonical = canonicalMuscles.where((m) => !musclesInJson.contains(m)).toSet();

  if (unusedCanonical.isEmpty) {
    print('\n✅ All canonical muscles are used in JSON files');
  } else {
    print('\n⚠️  Canonical muscles in mapper but NEVER used (${unusedCanonical.length}):');
    for (final muscle in unusedCanonical.toList()..sort()) {
      print('   - $muscle');
    }
  }

  // Check 3: Verify consistency for each muscle in JSON
  print('\n✅ Consistency check for JSON muscles:');
  final inconsistencies = <String>[];

  for (final muscle in musclesInJson.toList()..sort()) {
    if (!allMappedMuscles.contains(muscle)) {
      inconsistencies.add(muscle);
    }
  }

  if (inconsistencies.isEmpty) {
    print('   ✅ All ${musclesInJson.length} muscles are properly mapped');
  } else {
    print('   ❌ ${inconsistencies.length} inconsistencies found');
  }

  // Step 4: Usage statistics
  print('\n📊 Top 10 most used muscles:');
  final sorted = muscleUsageCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sorted.take(10)) {
    final isCanonical = canonicalMuscles.contains(entry.key);
    final marker = isCanonical ? '✅' : '⚠️ ';
    print('   $marker ${entry.key}: ${entry.value} occurrences');
  }

  // Final summary
  print('\n' + '=' * 70);
  print('📋 SUMMARY');
  print('=' * 70);
  print('Canonical muscles in mapper: ${canonicalMuscles.length}');
  print('Total mapped (incl. variants): ${allMappedMuscles.length}');
  print('Unique muscles in JSON: ${musclesInJson.length}');
  print('Unmapped muscles: ${unmappedMuscles.length}');
  print('Unused canonical muscles: ${unusedCanonical.length}');

  if (unmappedMuscles.isEmpty && unusedCanonical.isEmpty) {
    print('\n✅ PERFECT MATCH! Analytics mapping is 100% consistent with JSON data.');
  } else {
    print('\n⚠️  Inconsistencies found. Review needed:');
    if (unmappedMuscles.isNotEmpty) {
      print('   - Add ${unmappedMuscles.length} muscles to MuscleAbbreviationMapper');
    }
    if (unusedCanonical.isNotEmpty) {
      print('   - ${unusedCanonical.length} canonical muscles are defined but never used');
    }
  }
}
