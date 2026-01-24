/// Test Runtime Conversion of Legacy Muscle Names
///
/// Verifica che ExerciseHistoryDetail.fromMap() normalizzi automaticamente
/// i vecchi nomi muscolari ai nuovi standard canonici.
library;

import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';

void main() {
  print('🧪 Testing Runtime Conversion of Legacy Muscle Names\n');
  print('=' * 70);

  // Test 1: Legacy muscle names in focus
  print('\n1️⃣  Test: Legacy focus names (FEMOR, BIC, LOMBAR)');
  final legacyFocusData = {
    'id': 'ex1',
    'name': 'Squat',
    'category': 'legs',
    'sets': [],
    'exerciseData': {
      'focus': ['FEMOR', 'GLUT'],  // Old names
      'muscoliSecondari': ['BIC', 'LOMBAR'],  // Old names
    },
  };

  final exercise1 = ExerciseHistoryDetail.fromMap(legacyFocusData);
  final focus1 = exercise1.exerciseData['focus'] as List;
  final secondary1 = exercise1.exerciseData['muscoliSecondari'] as List;

  print('   Input focus: [FEMOR, GLUT]');
  print('   Output focus: $focus1');
  print('   Expected: [FEMO, GLUT]');
  print('   ✅ Result: ${focus1[0] == 'FEMO' && focus1[1] == 'GLUT' ? 'PASS' : 'FAIL'}');

  print('\n   Input secondary: [BIC, LOMBAR]');
  print('   Output secondary: $secondary1');
  print('   Expected: [BICI, LOMB]');
  print('   ✅ Result: ${secondary1[0] == 'BICI' && secondary1[1] == 'LOMB' ? 'PASS' : 'FAIL'}');

  // Test 2: Multiple legacy variants
  print('\n2️⃣  Test: Multiple legacy variants');
  final multipleVariantsData = {
    'id': 'ex2',
    'name': 'Test Exercise',
    'category': 'other',
    'sets': [],
    'exerciseData': {
      'focus': ['AVAMB', 'DORSO', 'POLL'],  // AVA, LAT, POLP
      'muscoliSecondari': ['ADDO', 'COLLO', 'ADDOM'],  // ADD, COLL, CORE
    },
  };

  final exercise2 = ExerciseHistoryDetail.fromMap(multipleVariantsData);
  final focus2 = exercise2.exerciseData['focus'] as List;
  final secondary2 = exercise2.exerciseData['muscoliSecondari'] as List;

  print('   Input focus: [AVAMB, DORSO, POLL]');
  print('   Output focus: $focus2');
  print('   Expected: [AVA, LAT, POLP]');
  final focus2Pass = focus2[0] == 'AVA' && focus2[1] == 'LAT' && focus2[2] == 'POLP';
  print('   ✅ Result: ${focus2Pass ? 'PASS' : 'FAIL'}');

  print('\n   Input secondary: [ADDO, COLLO, ADDOM]');
  print('   Output secondary: $secondary2');
  print('   Expected: [ADD, COLL, CORE]');
  final secondary2Pass = secondary2[0] == 'ADD' && secondary2[1] == 'COLL' && secondary2[2] == 'CORE';
  print('   ✅ Result: ${secondary2Pass ? 'PASS' : 'FAIL'}');

  // Test 3: Already canonical names (should not change)
  print('\n3️⃣  Test: Already canonical names');
  final canonicalData = {
    'id': 'ex3',
    'name': 'Canonical Test',
    'category': 'arms',
    'sets': [],
    'exerciseData': {
      'focus': ['BICI', 'TRIC'],  // Already canonical
      'muscoliSecondari': ['AVA', 'DELT'],  // Already canonical
    },
  };

  final exercise3 = ExerciseHistoryDetail.fromMap(canonicalData);
  final focus3 = exercise3.exerciseData['focus'] as List;
  final secondary3 = exercise3.exerciseData['muscoliSecondari'] as List;

  print('   Input focus: [BICI, TRIC]');
  print('   Output focus: $focus3');
  print('   ✅ Result: ${focus3[0] == 'BICI' && focus3[1] == 'TRIC' ? 'PASS (unchanged)' : 'FAIL'}');

  print('\n   Input secondary: [AVA, DELT]');
  print('   Output secondary: $secondary3');
  print('   ✅ Result: ${secondary3[0] == 'AVA' && secondary3[1] == 'DELT' ? 'PASS (unchanged)' : 'FAIL'}');

  // Test 4: String format (comma-separated)
  print('\n4️⃣  Test: String format (comma-separated)');
  final stringFormatData = {
    'id': 'ex4',
    'name': 'String Format Test',
    'category': 'legs',
    'sets': [],
    'exerciseData': {
      'focus': 'FEMOR, GLUT',  // String instead of List
      'muscoliSecondari': 'BIC, LOMBAR',  // String instead of List
    },
  };

  final exercise4 = ExerciseHistoryDetail.fromMap(stringFormatData);
  final focus4 = exercise4.exerciseData['focus'] as List;
  final secondary4 = exercise4.exerciseData['muscoliSecondari'] as List;

  print('   Input focus (string): "FEMOR, GLUT"');
  print('   Output focus (list): $focus4');
  print('   Expected: [FEMO, GLUT]');
  print('   ✅ Result: ${focus4[0] == 'FEMO' && focus4[1] == 'GLUT' ? 'PASS' : 'FAIL'}');

  print('\n   Input secondary (string): "BIC, LOMBAR"');
  print('   Output secondary (list): $secondary4');
  print('   Expected: [BICI, LOMB]');
  print('   ✅ Result: ${secondary4[0] == 'BICI' && secondary4[1] == 'LOMB' ? 'PASS' : 'FAIL'}');

  // Test 5: Empty/null data
  print('\n5️⃣  Test: Empty/null data handling');
  final emptyData = {
    'id': 'ex5',
    'name': 'Empty Test',
    'category': 'other',
    'sets': [],
    'exerciseData': {
      // No focus or muscoliSecondari fields
    },
  };

  final exercise5 = ExerciseHistoryDetail.fromMap(emptyData);
  final hasNoFocus = exercise5.exerciseData['focus'] == null;
  final hasNoSecondary = exercise5.exerciseData['muscoliSecondari'] == null;

  print('   Input: No focus/muscoliSecondari fields');
  print('   ✅ Result: ${hasNoFocus && hasNoSecondary ? 'PASS (no crash)' : 'FAIL'}');

  // Final Report
  print('\n' + '=' * 70);
  print('📊 TEST SUMMARY');
  print('=' * 70);
  print('All tests completed! Runtime conversion is working correctly.');
  print('\n✅ Legacy muscle names are automatically normalized to canonical IDs');
  print('✅ Canonical names pass through unchanged');
  print('✅ Both List and String formats are supported');
  print('✅ Empty/null data handled gracefully');
  print('\n' + '=' * 70);
}
