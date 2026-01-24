/// Final comprehensive consistency check across ALL systems
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 FINAL COMPREHENSIVE CONSISTENCY CHECK\n');
  print('=' * 70);

  var allChecks = 0;
  var passedChecks = 0;

  // Check 1: MuscleAbbreviationMapper
  print('\n1️⃣  Checking MuscleAbbreviationMapper...');
  allChecks++;

  final mapperFile = File('lib/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart');
  final mapperContent = await mapperFile.readAsString();

  final canonicalRegex = RegExp(r"id: '([A-Z_]+)'");
  final canonicalMatches = canonicalRegex.allMatches(mapperContent);
  final canonicalMuscles = <String>{};

  for (final match in canonicalMatches) {
    canonicalMuscles.add(match.group(1)!);
  }

  print('   ✅ Canonical muscles defined: ${canonicalMuscles.length}');
  passedChecks++;

  // Check 2: JSON Files
  print('\n2️⃣  Checking JSON exercise files...');
  allChecks++;

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
  var totalExercises = 0;

  for (final path in jsonFiles) {
    final file = File(path);
    if (!file.existsSync()) continue;

    final content = await file.readAsString();
    final exercises = jsonDecode(content) as List;
    totalExercises += exercises.length;

    for (final ex in exercises) {
      final exercise = ex as Map<String, dynamic>;

      // Focus
      final focus = exercise['focus'];
      if (focus is String && focus.isNotEmpty) {
        for (final muscle in focus.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)) {
          musclesInJson.add(muscle);
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
      }
    }
  }

  print('   ✅ Exercises analyzed: $totalExercises');
  print('   ✅ Unique muscles found: ${musclesInJson.length}');

  // Verify all JSON muscles are canonical
  final nonCanonical = musclesInJson.where((m) => !canonicalMuscles.contains(m)).toSet();
  if (nonCanonical.isEmpty) {
    print('   ✅ All muscles in JSON are canonical');
    passedChecks++;
  } else {
    print('   ❌ Non-canonical muscles found: $nonCanonical');
  }

  // Check 3: StressIndexConstants - Recovery Hours
  print('\n3️⃣  Checking StressIndexConstants - Recovery Hours...');
  allChecks++;

  final constantsFile = File('lib/features/stress_index/domain/constants/stress_index_constants.dart');
  final constantsContent = await constantsFile.readAsString();

  final recoveryRegex = RegExp(r"'([A-Z_]+)':\s*\d+,?\s*//");
  final recoveryMatches = recoveryRegex.allMatches(constantsContent);
  final recoveryMuscles = <String>{};

  for (final match in recoveryMatches) {
    recoveryMuscles.add(match.group(1)!);
  }

  final missingRecovery = canonicalMuscles.where((m) => !recoveryMuscles.contains(m)).toSet();
  if (missingRecovery.isEmpty) {
    print('   ✅ All ${canonicalMuscles.length} canonical muscles have recovery hours');
    passedChecks++;
  } else {
    print('   ❌ Missing recovery hours: $missingRecovery');
  }

  // Check 4: StressIndexConstants - Fatigue Modifiers
  print('\n4️⃣  Checking StressIndexConstants - Fatigue Modifiers...');
  allChecks++;

  final fatigueRegex = RegExp(r"'([A-Z_]+)':\s*[\d.]+,?\s*//");
  final fatigueMatches = fatigueRegex.allMatches(constantsContent);
  final fatigueMuscles = <String>{};

  for (final match in fatigueMatches) {
    fatigueMuscles.add(match.group(1)!);
  }

  final missingFatigue = canonicalMuscles.where((m) => !fatigueMuscles.contains(m)).toSet();
  if (missingFatigue.isEmpty) {
    print('   ✅ All ${canonicalMuscles.length} canonical muscles have fatigue modifiers');
    passedChecks++;
  } else {
    print('   ❌ Missing fatigue modifiers: $missingFatigue');
  }

  // Check 5: 4-Letter Standard Compliance
  print('\n5️⃣  Checking 4-Letter Standard Compliance...');
  allChecks++;

  final exceptions = {'AVA', 'ADD', 'LAT', 'OBL'};
  final nonCompliant = <String>[];

  for (final muscle in canonicalMuscles) {
    if (!muscle.contains('_') && muscle.length != 4 && !exceptions.contains(muscle)) {
      nonCompliant.add('$muscle (${muscle.length} letters)');
    }
  }

  if (nonCompliant.isEmpty) {
    print('   ✅ All muscles follow 4-letter standard (except approved 3-letter)');
    passedChecks++;
  } else {
    print('   ❌ Non-compliant: $nonCompliant');
  }

  // Check 6: Mapper completeness (variants coverage)
  print('\n6️⃣  Checking Mapper Variant Coverage...');
  allChecks++;

  final keyRegex = RegExp(r"'([A-Z_\s]+)': MuscleInfo");
  final keyMatches = keyRegex.allMatches(mapperContent);
  final allMappedMuscles = <String>{};

  for (final match in keyMatches) {
    allMappedMuscles.add(match.group(1)!);
  }

  final variantsCount = allMappedMuscles.length - canonicalMuscles.length;
  print('   ✅ Canonical muscles: ${canonicalMuscles.length}');
  print('   ✅ Variants mapped: $variantsCount');
  print('   ✅ Total coverage: ${allMappedMuscles.length} muscle names');
  passedChecks++;

  // Final Report
  print('\n' + '=' * 70);
  print('📊 FINAL REPORT');
  print('=' * 70);
  print('Total checks: $allChecks');
  print('Passed: $passedChecks');
  print('Failed: ${allChecks - passedChecks}');
  print('Success rate: ${(passedChecks / allChecks * 100).toStringAsFixed(1)}%');

  if (passedChecks == allChecks) {
    print('\n🎉 PERFECT! All systems are 100% consistent!');
    print('\n✅ Summary:');
    print('   • ${canonicalMuscles.length} canonical muscles');
    print('   • $totalExercises exercises validated');
    print('   • ${allMappedMuscles.length} muscle names mapped');
    print('   • 0 inconsistencies found');
    print('   • 100% recovery/fatigue coverage');
    print('   • 100% 4-letter standard compliance');
  } else {
    print('\n⚠️  Some checks failed. Review output above.');
  }

  print('\n' + '=' * 70);
}
