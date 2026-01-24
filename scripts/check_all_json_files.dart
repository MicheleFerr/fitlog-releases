/// Check ALL JSON files in the project for muscle focus inconsistencies
library;

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Scanning ALL exercise JSON files for muscle focus\n');

  final canonical = {
    'TRIC', 'BICI', 'AVA',
    'LAT', 'TRAP', 'LOMB', 'ROMB',
    'PETT',
    'DELT', 'DELT_ANT', 'DELT_LAT', 'DELT_POST', 'COLL',
    'GLUT', 'QUAD', 'FEMO', 'POLP', 'ADD', 'ABDU',
    'CORE', 'OBL',
  };

  // Known variants that should be standardized
  final knownVariants = {
    'BIC', 'AVAMB', 'LOMBAR', 'LOM', 'DORSO', 'COLLO',
    'FEMOR', 'POLL', 'ADDO', 'ADDUT', 'ADDU', 'ABDUT',
    'ADDOM', 'ROMBOIDI', 'OBLIQUI', 'ANCA',
  };

  final filesToCheck = [
    // Main files (already checked)
    'assets/data/exercises_it.json',
    'assets/data/exercises_it_complete.json',

    // Other potential files
    'assets/data/exercises.json',
    'assets/data/exercises_it_nomi.json',
    'assets/data/exercises_with_tut.json',

    // English versions
    'assets/data/exercises_en/upper_pull.json',
    'assets/data/exercises_en/upper_push.json',
    'assets/data/exercises_en/lower.json',
    'assets/data/exercises_en/core.json',
    'assets/data/exercises_en/other.json',

    // Split by category
    'assets/data/exercises/upper_pull.json',
    'assets/data/exercises/upper_push.json',
    'assets/data/exercises/lower.json',
    'assets/data/exercises/core.json',
    'assets/data/exercises/other.json',
  ];

  final results = <String, Map<String, dynamic>>{};

  for (final filePath in filesToCheck) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);

      final muscles = <String>{};
      final nonCanonical = <String, int>{};
      var exerciseCount = 0;

      List<dynamic> exercises = [];

      // Handle different JSON structures
      if (data is List) {
        exercises = data;
      } else if (data is Map) {
        // Could be wrapped in a key like "exercises"
        if (data.containsKey('exercises') && data['exercises'] is List) {
          exercises = data['exercises'] as List;
        }
      }

      for (final exercise in exercises) {
        if (exercise is! Map<String, dynamic>) continue;
        exerciseCount++;

        // Check all possible field names for focus
        final focusFields = ['focus', 'primaryMuscles', 'targetMuscles', 'muscleGroup'];
        final secondaryFields = ['muscoliSecondari', 'secondaryMuscles', 'synergistMuscles'];

        for (final field in [...focusFields, ...secondaryFields]) {
          final value = exercise[field];
          if (value == null) continue;

          List<String> muscleList;

          // Handle both string CSV and JSON array formats
          if (value is List) {
            muscleList = value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          } else if (value is String && value.isNotEmpty) {
            muscleList = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          } else {
            continue;
          }

          for (final muscle in muscleList) {
            muscles.add(muscle);
            if (!canonical.contains(muscle)) {
              nonCanonical[muscle] = (nonCanonical[muscle] ?? 0) + 1;
            }
          }
        }
      }

      if (muscles.isNotEmpty) {
        results[filePath] = {
          'exerciseCount': exerciseCount,
          'totalMuscles': muscles.length,
          'uniqueMuscles': muscles.toList()..sort(),
          'nonCanonical': nonCanonical,
        };
      }
    } catch (e) {
      print('⚠️  Error reading $filePath: $e');
    }
  }

  print('=' * 70);
  print('📊 RESULTS BY FILE');
  print('=' * 70);

  var filesWithIssues = 0;
  var totalIssues = 0;

  for (final entry in results.entries) {
    final path = entry.key;
    final data = entry.value;
    final nonCanonical = data['nonCanonical'] as Map<String, int>;

    print('\n📄 ${path}');
    print('   Exercises: ${data['exerciseCount']}');
    print('   Unique muscles: ${data['totalMuscles']}');

    if (nonCanonical.isEmpty) {
      print('   ✅ All canonical');
    } else {
      filesWithIssues++;
      print('   ⚠️  Non-canonical values found:');
      final sorted = nonCanonical.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final variant in sorted) {
        totalIssues += variant.value;
        final isKnown = knownVariants.contains(variant.key);
        final marker = isKnown ? '🔧' : '❓';
        print('      $marker ${variant.key}: ${variant.value} occurrences');
      }
    }
  }

  print('\n' + '=' * 70);
  print('📋 SUMMARY');
  print('=' * 70);
  print('Files checked: ${filesToCheck.length}');
  print('Files with data: ${results.length}');
  print('Files with issues: $filesWithIssues');
  print('Total non-canonical occurrences: $totalIssues');

  if (filesWithIssues == 0) {
    print('\n✅ Perfect! All files use canonical abbreviations.');
  } else {
    print('\n⚠️  $filesWithIssues file(s) need standardization.');
    print('   🔧 = Known variant (add to standardization script)');
    print('   ❓ = Unknown (investigate manually)');
  }
}
