/// Verifica che StressIndexConstants abbia recovery/fatigue per TUTTI i muscoli canonici
library;

import 'dart:io';

void main() async {
  print('🔍 Verifying StressIndexConstants Consistency\n');

  // Step 1: Extract canonical muscles from mapper
  final mapperFile = File('lib/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart');
  final mapperContent = await mapperFile.readAsString();

  final canonicalRegex = RegExp(r"id: '([A-Z_]+)'");
  final canonicalMatches = canonicalRegex.allMatches(mapperContent);
  final canonicalMuscles = <String>{};

  for (final match in canonicalMatches) {
    canonicalMuscles.add(match.group(1)!);
  }

  print('📖 Canonical muscles from mapper: ${canonicalMuscles.length}');
  print('   ${canonicalMuscles.toList()..sort()}\n');

  // Step 2: Extract muscles from StressIndexConstants
  final constantsFile = File('lib/features/stress_index/domain/constants/stress_index_constants.dart');
  final constantsContent = await constantsFile.readAsString();

  // Extract recovery hours map
  final recoveryRegex = RegExp(r"'([A-Z_]+)':\s*\d+,?\s*//");
  final recoveryMatches = recoveryRegex.allMatches(constantsContent);
  final recoveryMuscles = <String>{};

  for (final match in recoveryMatches) {
    recoveryMuscles.add(match.group(1)!);
  }

  // Extract fatigue modifiers map
  final fatigueRegex = RegExp(r"'([A-Z_]+)':\s*[\d.]+,?\s*//");
  final fatigueMatches = fatigueRegex.allMatches(constantsContent);
  final fatigueMuscles = <String>{};

  for (final match in fatigueMatches) {
    fatigueMuscles.add(match.group(1)!);
  }

  print('📊 Muscles in StressIndexConstants:');
  print('   Recovery hours map: ${recoveryMuscles.length}');
  print('   Fatigue modifiers map: ${fatigueMuscles.length}\n');

  // Step 3: Cross-reference
  print('=' * 70);
  print('🔍 CROSS-REFERENCE ANALYSIS');
  print('=' * 70);

  // Check 1: Missing recovery hours
  final missingRecovery = canonicalMuscles.where((m) => !recoveryMuscles.contains(m)).toSet();

  if (missingRecovery.isEmpty) {
    print('\n✅ All canonical muscles have recovery hours');
  } else {
    print('\n❌ Muscles missing recovery hours (${missingRecovery.length}):');
    for (final muscle in missingRecovery.toList()..sort()) {
      print('   - $muscle');
    }
  }

  // Check 2: Missing fatigue modifiers
  final missingFatigue = canonicalMuscles.where((m) => !fatigueMuscles.contains(m)).toSet();

  if (missingFatigue.isEmpty) {
    print('\n✅ All canonical muscles have fatigue modifiers');
  } else {
    print('\n❌ Muscles missing fatigue modifiers (${missingFatigue.length}):');
    for (final muscle in missingFatigue.toList()..sort()) {
      print('   - $muscle');
    }
  }

  // Check 3: Extra muscles in constants (not canonical)
  final extraRecovery = recoveryMuscles.where((m) => !canonicalMuscles.contains(m)).toSet();
  final extraFatigue = fatigueMuscles.where((m) => !canonicalMuscles.contains(m)).toSet();

  if (extraRecovery.isEmpty && extraFatigue.isEmpty) {
    print('\n✅ No extra muscles in constants (all are canonical)');
  } else {
    if (extraRecovery.isNotEmpty) {
      print('\n⚠️  Extra muscles in recovery hours (${extraRecovery.length}):');
      for (final muscle in extraRecovery.toList()..sort()) {
        print('   - $muscle (not canonical, should be removed or mapped)');
      }
    }

    if (extraFatigue.isNotEmpty) {
      print('\n⚠️  Extra muscles in fatigue modifiers (${extraFatigue.length}):');
      for (final muscle in extraFatigue.toList()..sort()) {
        print('   - $muscle (not canonical, should be removed or mapped)');
      }
    }
  }

  // Summary
  print('\n' + '=' * 70);
  print('📋 SUMMARY');
  print('=' * 70);
  print('Canonical muscles: ${canonicalMuscles.length}');
  print('Recovery hours defined: ${recoveryMuscles.length}');
  print('Fatigue modifiers defined: ${fatigueMuscles.length}');
  print('Missing recovery: ${missingRecovery.length}');
  print('Missing fatigue: ${missingFatigue.length}');
  print('Extra (non-canonical): ${extraRecovery.length + extraFatigue.length}');

  if (missingRecovery.isEmpty && missingFatigue.isEmpty && extraRecovery.isEmpty && extraFatigue.isEmpty) {
    print('\n✅ PERFECT! StressIndexConstants is 100% aligned with canonical muscles.');
  } else {
    print('\n⚠️  Inconsistencies found:');
    if (missingRecovery.isNotEmpty || missingFatigue.isNotEmpty) {
      print('   - Add missing muscles to StressIndexConstants');
    }
    if (extraRecovery.isNotEmpty || extraFatigue.isNotEmpty) {
      print('   - Remove or update non-canonical muscles');
    }
  }
}
