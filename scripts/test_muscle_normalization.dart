/// Test Muscle Normalization (Simple Version)
///
/// Testa solo MuscleAbbreviationMapper.normalizeToCanonicalId()
/// senza dipendenze Flutter
library;

import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';

void main() {
  print('🧪 Testing Muscle Normalization\n');
  print('=' * 70);

  final testCases = {
    // Legacy variants → Canonical
    'FEMOR': 'FEMO',
    'BIC': 'BICI',
    'LOMBAR': 'LOMB',
    'LOM': 'LOMB',
    'AVAMB': 'AVA',
    'DORSO': 'LAT',
    'POLL': 'POLP',
    'ADDO': 'ADD',
    'COLLO': 'COLL',
    'ADDOM': 'CORE',
    'ADDUT': 'ADD',
    'ABDUT': 'ABDU',
    // Already canonical → Should stay same
    'BICI': 'BICI',
    'TRIC': 'TRIC',
    'AVA': 'AVA',
    'DELT': 'DELT',
    'GLUT': 'GLUT',
    'QUAD': 'QUAD',
    'PETT': 'PETT',
    'LAT': 'LAT',
    'TRAP': 'TRAP',
    'LOMB': 'LOMB',
    'FEMO': 'FEMO',
    'POLP': 'POLP',
    'ADD': 'ADD',
    'ABDU': 'ABDU',
    'CORE': 'CORE',
    'COLL': 'COLL',
    'ROMB': 'ROMB',
    'OBL': 'OBL',
    // Delta variants
    'DELT_ANT': 'DELT_ANT',
    'DELT_LAT': 'DELT_LAT',
    'DELT_POST': 'DELT_POST',
  };

  var passed = 0;
  var failed = 0;

  for (final entry in testCases.entries) {
    final input = entry.key;
    final expected = entry.value;
    final result = MuscleAbbreviationMapper.normalizeToCanonicalId(input);

    if (result == expected) {
      print('✅ $input → $result (OK)');
      passed++;
    } else {
      print('❌ $input → $result (Expected: $expected)');
      failed++;
    }
  }

  print('\n' + '=' * 70);
  print('📊 TEST RESULTS');
  print('=' * 70);
  print('Total tests: ${testCases.length}');
  print('Passed: $passed');
  print('Failed: $failed');
  print('Success rate: ${(passed / testCases.length * 100).toStringAsFixed(1)}%');

  if (failed == 0) {
    print('\n🎉 ALL TESTS PASSED!');
    print('\n✅ Runtime conversion will work correctly for legacy workout data');
  } else {
    print('\n⚠️  Some tests failed. Review mapping in MuscleAbbreviationMapper');
  }

  print('\n' + '=' * 70);
}
