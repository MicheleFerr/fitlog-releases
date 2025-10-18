/// Test script to verify the enhanced exercise matching functionality
/// 
/// This script demonstrates how the intelligent exercise matching system works
/// with various exercise names and similarity algorithms.
library;

import 'lib/features/workout_templates/data/services/exercise_matching_service.dart';

Future<void> main() async {
  print('🏋️‍♂️ Testing Enhanced Exercise Matching System');
  print('=' * 50);
  
  final service = ExerciseMatchingService.instance;
  
  // Load the exercise database
  await service.loadExerciseDatabase();
  print('✅ Exercise database loaded\n');
  
  // Test cases with various exercise names
  final testCases = [
    'Bench Press',
    'bench press',
    'BENCH PRESS',
    'Panca Piana',
    'Push Up',
    'Piegamenti',
    'Squat',
    'Pull Up',
    'Trazioni',
    'Deadlift',
    'Stacco',
    'Shoulder Press',
    'Spinte Spalle',
    'Bicep Curl',
    'Curl Bicipiti',
    'Leg Press',
    'Pressa',
    'Calf Raise',
    'Alzate Polpacci',
    'Dumbbell Row',
    'Rematore Manubri',
    // Typos and variations
    'Bensh Press',
    'Skuat',
    'Ded lift',
    'Pusup',
    'Pull-up',
    // Partial matches
    'Bench',
    'Press',
    'Curl',
    // Unknown exercises
    'Dragon Flag',
    'Turkish Get Up',
    'Burpees',
  ];
  
  for (final testCase in testCases) {
    print('🔍 Testing: "$testCase"');
    
    // Try exact match first
    final exactMatch = await service.findExactMatch(testCase);
    if (exactMatch != null) {
      print('  ✅ EXACT MATCH: ${exactMatch.nome} (${exactMatch.focus})');
      continue;
    }
    
    // Find similar matches
    final matches = await service.findMatches(testCase, maxResults: 3);
    if (matches.isNotEmpty) {
      print('  📊 SIMILAR MATCHES:');
      for (final match in matches) {
        final percentage = (match.similarity * 100).round();
        print('    • ${match.exercise.nome} ($percentage% - ${match.matchReason})');
        print('      Focus: ${match.exercise.focus}');
      }
    } else {
      print('  ❌ NO MATCHES FOUND');
    }
    
    print('');
  }
  
  print('🎯 Exercise Matching Test Complete!');
  print('📈 Enhanced features demonstrated:');
  print('  • Multi-algorithm similarity (Levenshtein + Jaccard + Substring + Initials)');
  print('  • Italian/English translation normalization');
  print('  • Fuzzy matching with typo tolerance');
  print('  • Muscle focus bonus matching');
  print('  • Match reason explanations');
  print('  • Configurable similarity thresholds');
}