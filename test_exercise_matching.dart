/// Test script to verify the enhanced exercise matching functionality
///
/// This script demonstrates how the intelligent exercise matching system works
/// with various exercise names and similarity algorithms.
library;

import 'package:flutter/foundation.dart';
import 'lib/features/workout_templates/data/services/exercise_matching_service.dart';

Future<void> main() async {
  debugPrint('🏋️‍♂️ Testing Enhanced Exercise Matching System');
  debugPrint('=' * 50);
  
  final service = ExerciseMatchingService.instance;
  
  // Load the exercise database
  await service.loadExerciseDatabase();
  debugPrint('✅ Exercise database loaded\n');
  
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
    debugPrint('🔍 Testing: "$testCase"');

    // Try exact match first
    final exactMatch = await service.findExactMatch(testCase);
    if (exactMatch != null) {
      debugPrint('  ✅ EXACT MATCH: ${exactMatch.nome} (${exactMatch.focus})');
      continue;
    }

    // Find similar matches
    final matches = await service.findMatches(testCase, maxResults: 3);
    if (matches.isNotEmpty) {
      debugPrint('  📊 SIMILAR MATCHES:');
      for (final match in matches) {
        final percentage = (match.similarity * 100).round();
        debugPrint('    • ${match.exercise.nome} ($percentage% - ${match.matchReason})');
        debugPrint('      Focus: ${match.exercise.focus}');
      }
    } else {
      debugPrint('  ❌ NO MATCHES FOUND');
    }

    debugPrint('');
  }
  
  debugPrint('🎯 Exercise Matching Test Complete!');
  debugPrint('📈 Enhanced features demonstrated:');
  debugPrint('  • Multi-algorithm similarity (Levenshtein + Jaccard + Substring + Initials)');
  debugPrint('  • Italian/English translation normalization');
  debugPrint('  • Fuzzy matching with typo tolerance');
  debugPrint('  • Muscle focus bonus matching');
  debugPrint('  • Match reason explanations');
  debugPrint('  • Configurable similarity thresholds');
}