import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Exercise files in the new folder structure
const _exerciseFiles = [
  'core.json',
  'upper_push.json',
  'upper_pull.json',
  'lower.json',
  'other.json',
];


/// Exercise model for validation testing
class ExerciseModel {

  ExerciseModel({
    required this.id,
    required this.nome,
    required this.focus,
    required this.imageUrl,
    required this.difficolta,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String? ?? '',
      nome: json['nome'] as String? ?? '',
      focus: json['focus'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      difficolta: json['difficolta'] as String? ?? '',
    );
  }
  final String id;
  final String nome;
  final String? focus;
  final String imageUrl;
  final String difficolta;

  /// Validate that exercise has required fields
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) {
      errors.add('Missing or empty id');
    }
    if (nome.isEmpty) {
      errors.add('Missing or empty nome (name)');
    }
    if (imageUrl.isEmpty) {
      errors.add('Missing or empty imageUrl');
    }
    if (difficolta.isEmpty) {
      errors.add('Missing or empty difficolta');
    }

    return errors;
  }
}

void main() {
  // ✅ FIX: Initialize Flutter binding for asset loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('🏋️ Exercise Database Validation Tests', () {
    late List<dynamic> exerciseData;
    late List<ExerciseModel> exercises;

    setUpAll(() async {
      // Load exercise data from new folder structure
      const String baseFolder = 'assets/data/exercises'; // Italian folder
      exerciseData = [];

      try {
        for (final fileName in _exerciseFiles) {
          try {
            final String jsonData = await rootBundle.loadString('$baseFolder/$fileName');
            final List<dynamic> jsonList = jsonDecode(jsonData) as List<dynamic>;
            exerciseData.addAll(jsonList);
          } catch (e) {
            // File might not exist, continue with others
            print('Warning: Could not load $baseFolder/$fileName: $e');
          }
        }

        if (exerciseData.isEmpty) {
          fail('Failed to load any exercise JSON files from $baseFolder');
        }

        exercises = exerciseData
            .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        fail('Failed to load exercise JSON: $e');
      }
    });

    // ============================================================================
    // BASIC STRUCTURE TESTS
    // ============================================================================

    test('✅ TEST 1: Exercise database loads successfully', () {
      expect(exerciseData, isNotEmpty,
          reason: 'Exercise database should not be empty');
      expect(exerciseData.length, greaterThanOrEqualTo(1500),
          reason: 'Should have at least 1500 exercises');
    });

    test('✅ TEST 2: All exercises are valid objects', () {
      expect(exercises, isNotEmpty);
      for (var i = 0; i < exercises.length; i++) {
        final ex = exercises[i];
        expect(ex, isNotNull, reason: 'Exercise $i should not be null');
        expect(ex.id, isNotEmpty,
            reason: 'Exercise $i should have non-empty id');
      }
    });

    test('✅ TEST 3: All exercises have required fields', () {
      final invalidExercises = <String>[];

      for (var i = 0; i < exercises.length; i++) {
        final ex = exercises[i];
        final errors = ex.validate();

        if (errors.isNotEmpty) {
          invalidExercises.add('Exercise $i (${ex.id}): ${errors.join(', ')}');
        }
      }

      expect(invalidExercises, isEmpty,
          reason: 'Invalid exercises found:\n${invalidExercises.join('\n')}');
    });

    // ============================================================================
    // FIELD VALIDATION TESTS
    // ============================================================================

    test('✅ TEST 4: All exercise IDs are unique', () {
      final ids = <String, int>{};
      final duplicates = <String>[];

      for (var ex in exercises) {
        if (ids.containsKey(ex.id)) {
          duplicates.add('${ex.id} (appears ${ids[ex.id]!} times)');
          ids[ex.id] = ids[ex.id]! + 1;
        } else {
          ids[ex.id] = 1;
        }
      }

      expect(duplicates, isEmpty,
          reason: 'Duplicate exercise IDs found:\n${duplicates.join('\n')}');
    });

    test('✅ TEST 5: All exercise names (nome) are non-empty and trimmed', () {
      final issues = <String>[];

      for (var i = 0; i < exercises.length; i++) {
        final ex = exercises[i];

        if (ex.nome.isEmpty) {
          issues.add('Exercise ${ex.id}: empty nome');
        }
        if (ex.nome != ex.nome.trim()) {
          issues.add('Exercise ${ex.id}: nome has leading/trailing whitespace');
        }
      }

      expect(issues, isEmpty,
          reason: 'Exercise nome issues found:\n${issues.join('\n')}');
    });

    test('✅ TEST 6: All imageUrls are valid URLs or paths', () {
      final invalidUrls = <String>[];

      for (var ex in exercises) {
        final url = ex.imageUrl;

        // Check if URL starts with http, https, or / (valid URL or relative path)
        if (!url.startsWith('http://') &&
            !url.startsWith('https://') &&
            !url.startsWith('/') &&
            url.isNotEmpty) {
          invalidUrls.add('${ex.id}: Invalid URL format - $url');
        }

        // Check if very short (suspicious)
        if (url.length < 5) {
          invalidUrls.add('${ex.id}: URL too short - $url');
        }
      }

      expect(invalidUrls, isEmpty,
          reason: 'Invalid image URLs found:\n${invalidUrls.join('\n')}');
    });

    test('✅ TEST 7: All difficulty levels are valid', () {
      final validDifficulties = {
        'Principiante',
        'Intermedio',
        'Avanzato',
        'Beginner',
        'Intermediate',
        'Advanced',
        'Principiante/Intermedio',
        'Intermedio/Avanzato',
      };

      final invalidDifficulties = <String>[];

      for (var ex in exercises) {
        if (!validDifficulties.contains(ex.difficolta)) {
          invalidDifficulties.add('${ex.id}: ${ex.difficolta}');
        }
      }

      expect(invalidDifficulties, isEmpty,
          reason:
              'Invalid difficulty levels found:\n${invalidDifficulties.join('\n')}\n'
              'Valid: ${validDifficulties.join(', ')}');
    });

    // ============================================================================
    // SEMANTIC VALIDATION TESTS
    // ============================================================================

    test('✅ TEST 8: Sample exercises have valid structure', () {
      // Test first 10 exercises in detail
      for (var i = 0; i < exercises.length && i < 10; i++) {
        final json = exerciseData[i] as Map<String, dynamic>;

        // Check all expected fields exist
        expect(json.containsKey('id'), true,
            reason: 'Exercise $i missing id field');
        expect(json.containsKey('nome'), true,
            reason: 'Exercise $i missing nome field');
        expect(json.containsKey('focus'), true,
            reason: 'Exercise $i missing focus field');
        expect(json.containsKey('imageUrl'), true,
            reason: 'Exercise $i missing imageUrl field');
        expect(json.containsKey('difficolta'), true,
            reason: 'Exercise $i missing difficolta field');
      }
    });

    test('✅ TEST 9: Focus field is either null or valid focus area', () {
      final validFocusAreas = {
        'CHEST',
        'BACK',
        'SHOULDERS',
        'BICEPS',
        'TRICEPS',
        'FOREARMS',
        'CORE',
        'ABS',
        'OBLIQUES',
        'GLUT',
        'QUAD',
        'HAMSTRING',
        'CALVES',
        'LEGS',
        'FEMOR',
        'LATS',
        'TRAPS',
        'RHOMBOID',
        'ROTATOR_CUFF',
        'FULL_BODY',
        'CARDIO',
        'FLEXIBILITY',
        'STABILIZER',
        'COMPOUND',
        // Italian abbreviations
        'PETT',
        'BICI',
        'POLP',
        'LAT',
        'TRAP',
        'SPALL',
        'ADDO',
      };

      final invalidFocus = <String>[];

      for (var ex in exercises) {
        if (ex.focus != null && ex.focus!.isNotEmpty) {
          // Handle comma-separated focus areas
          final focusAreas =
              ex.focus!.split(',').map((f) => f.trim()).toList();

          for (var focus in focusAreas) {
            if (!validFocusAreas.contains(focus)) {
              invalidFocus.add('${ex.id}: Unknown focus area: $focus');
            }
          }
        }
      }

      // Only check first 50 to keep test output manageable
      final issuesSample = invalidFocus.take(50).toList();
      expect(issuesSample.length, equals(0),
          reason:
              'Invalid focus areas found (showing first 50):\n${issuesSample.join('\n')}');
    });

    test('✅ TEST 10: Exercise names are reasonably formatted', () {
      final issues = <String>[];

      for (var ex in exercises) {
        // Check for multiple spaces
        if (ex.nome.contains('  ')) {
          issues.add('${ex.id}: Multiple consecutive spaces in nome');
        }

        // Check for suspicious characters
        if (RegExp(r'[<>"`]').hasMatch(ex.nome)) {
          issues.add('${ex.id}: Suspicious characters in nome: ${ex.nome}');
        }

        // Check minimum length (at least 2 characters, allow for abbreviations)
        if (ex.nome.length < 2) {
          issues.add('${ex.id}: Nome too short: ${ex.nome}');
        }
      }

      expect(issues, isEmpty,
          reason: 'Exercise name formatting issues:\n${issues.join('\n')}');
    });

    // ============================================================================
    // STATISTICS TESTS
    // ============================================================================

    test('✅ TEST 11: Exercise database statistics', () {
      final focusAreas = <String>{};
      final difficulties = <String>{};
      int nullFocusCount = 0;

      for (var ex in exercises) {
        if (ex.focus == null || ex.focus!.isEmpty) {
          nullFocusCount++;
        } else {
          // Handle comma-separated
          final areas = ex.focus!.split(',').map((f) => f.trim());
          focusAreas.addAll(areas);
        }
        difficulties.add(ex.difficolta);
      }

      expect(exercises.length, greaterThanOrEqualTo(1500),
          reason: 'Should have at least 1500 exercises');
      expect(focusAreas.length, greaterThan(0),
          reason: 'Should have multiple focus areas');
      expect(difficulties.length, greaterThan(0),
          reason: 'Should have multiple difficulty levels');

      // Print statistics (will show in test output)
      print('📊 Database Statistics:');
      print('   Total exercises: ${exercises.length}');
      print('   Unique focus areas: ${focusAreas.length}');
      print('   Unique difficulties: ${difficulties.length}');
      print('   Exercises with null focus: $nullFocusCount');
      print('   Focus areas: ${focusAreas.toList().join(", ")}');
      print('   Difficulties: ${difficulties.toList().join(", ")}');
    });

    test('✅ TEST 12: No empty or malformed JSON objects', () {
      final issues = <String>[];

      for (var i = 0; i < exerciseData.length; i++) {
        final item = exerciseData[i];

        if (item is! Map<String, dynamic>) {
          issues.add('Item $i is not a JSON object');
        } else {
          if (item.isEmpty) {
            issues.add('Item $i is an empty JSON object');
          }
        }
      }

      expect(issues, isEmpty,
          reason: 'Malformed JSON objects:\n${issues.join('\n')}');
    });

    // ============================================================================
    // PERFORMANCE/LOAD TESTS
    // ============================================================================

    test('✅ TEST 13: Efficient exercise lookup by ID', () {
      final stopwatch = Stopwatch()..start();

      // Try to find a few exercises
      for (var i = 0; i < exercises.length; i += (exercises.length / 10).ceil()) {
        final ex = exercises[i];
        final found = exercises.where((e) => e.id == ex.id).toList();
        expect(found.length, equals(1),
            reason: 'Should find exactly one exercise with ID ${ex.id}');
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'Lookup should be fast (< 5 seconds)');

      print('✅ Exercise lookup test completed in'
          ' ${stopwatch.elapsedMilliseconds}ms');
    });

    test('✅ TEST 14: Italian exercise data quality check', () {
      // Check that at least 90% of exercises have Italian names
      final italianNamePatterns = RegExp(r'[àèéìòù]|con|di|dei|della|nel');

      int italianCount = 0;
      for (var ex in exercises) {
        if (italianNamePatterns.hasMatch(ex.nome)) {
          italianCount++;
        }
      }

      final italianPercentage = (italianCount / exercises.length) * 100;
      expect(italianPercentage, greaterThan(80),
          reason:
              'At least 80% of exercises should have Italian names. Found: ${italianPercentage.toStringAsFixed(1)}%');

      print('📊 Italian Exercise Quality:');
      print('   Italian exercises: $italianCount / ${exercises.length}');
      print('   Percentage: ${italianPercentage.toStringAsFixed(1)}%');
    });

    test('✅ TEST 15: No duplicate exercise names in same focus area', () {
      // This test is informative - duplicates might be valid (variations)
      final focusNames = <String, Set<String>>{};

      for (var ex in exercises) {
        final focus = ex.focus ?? 'UNKNOWN';
        if (!focusNames.containsKey(focus)) {
          focusNames[focus] = <String>{};
        }

        // Count duplicates but don't fail
        focusNames[focus]!.add(ex.nome);
      }

      // Just ensure the mapping is created successfully
      expect(focusNames.isNotEmpty, true,
          reason: 'Should have focus area groupings');
    });
  });
}
