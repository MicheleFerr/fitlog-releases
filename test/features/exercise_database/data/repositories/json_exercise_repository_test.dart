import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';

void main() {
  late JsonExerciseRepository repository;

  // Sample test data matching Exercise entity structure
  final testExercisesJson = jsonEncode([
    {
      'id': 'ex1',
      'nome': 'Bench Press',
      'focus': ['PETT', 'TRIC'],
      'focusDisplayName': 'Chest, Triceps',
      'muscoliSecondari': ['DELT'],
      'muscoliSecondariDisplayName': 'Shoulders',
      'attrezzatura': 'Barbell',
      'difficolta': 'Intermediate',
      'img': '',
      'video': ''
    },
    {
      'id': 'ex2',
      'nome': 'Squat',
      'focus': ['QUAD', 'GLUT'],
      'focusDisplayName': 'Quadriceps, Glutes',
      'muscoliSecondari': ['HAMS'],
      'muscoliSecondariDisplayName': 'Hamstrings',
      'attrezzatura': 'Barbell',
      'difficolta': 'Advanced',
      'img': '',
      'video': ''
    },
    {
      'id': 'ex3',
      'nome': 'Bicep Curl',
      'focus': ['BICE'],
      'focusDisplayName': 'Biceps',
      'muscoliSecondari': ['FORE'],
      'muscoliSecondariDisplayName': 'Forearms',
      'attrezzatura': 'Dumbbell',
      'difficolta': 'Beginner',
      'img': '',
      'video': ''
    },
  ]);

  setUp(() {
    // Initialize Flutter test binding
    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup default locale
    repository = JsonExerciseRepository(locale: const Locale('en'));

    // Mock AssetBundle.loadString for exercises (new folder structure)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'load') {
          final String assetPath = methodCall.arguments as String;
          // New folder structure paths
          if (assetPath.startsWith('assets/data/exercises_en/') ||
              assetPath.startsWith('assets/data/exercises/')) {
            return ByteData.sublistView(utf8.encode(testExercisesJson));
          }
          // Legacy fallback paths (for backwards compatibility)
          if (assetPath == 'assets/data/exercises.json' ||
              assetPath == 'assets/data/exercises_it.json') {
            return ByteData.sublistView(utf8.encode(testExercisesJson));
          }
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      null,
    );
  });

  group('getAllExercises', () {
    test('should load exercises from JSON on first call', () async {
      // Act
      final result = await repository.getAllExercises();

      // Assert
      expect(result, hasLength(3));
      expect(result[0].nome, 'Bench Press');
      expect(result[1].nome, 'Squat');
      expect(result[2].nome, 'Bicep Curl');
    });

    test('should return cached exercises on subsequent calls', () async {
      // Act
      final result1 = await repository.getAllExercises();
      final result2 = await repository.getAllExercises();

      // Assert
      expect(result1, equals(result2));
      expect(result2, hasLength(3));
    });

    test('should clear cache when locale changes', () async {
      // Arrange
      await repository.getAllExercises(); // Load English

      // Act - Change to Italian locale
      final italianRepo = JsonExerciseRepository(locale: const Locale('it'));
      final result = await italianRepo.getAllExercises();

      // Assert
      expect(result, hasLength(3)); // Should load Italian version
    });
  });

  group('searchExercises', () {
    test('should return all exercises when query is empty', () async {
      // Act
      final result = await repository.searchExercises('');

      // Assert
      expect(result, hasLength(3));
    });

    test('should find exercises by nome', () async {
      // Act
      final result = await repository.searchExercises('bench');

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bench Press');
    });

    test('should find exercises by focusDisplayName', () async {
      // Act
      final result = await repository.searchExercises('chest');

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bench Press');
    });

    test('should find exercises by attrezzatura', () async {
      // Act
      final result = await repository.searchExercises('dumbbell');

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bicep Curl');
    });

    test('should find exercises by muscoliSecondariDisplayName', () async {
      // Act
      final result = await repository.searchExercises('hamstrings');

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Squat');
    });

    test('should be case insensitive', () async {
      // Act
      final result = await repository.searchExercises('BENCH');

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bench Press');
    });

    test('should return empty list when no matches found', () async {
      // Act
      final result = await repository.searchExercises('nonexistent');

      // Assert
      expect(result, isEmpty);
    });

    test('should find multiple exercises matching query', () async {
      // Act
      final result = await repository.searchExercises('barbell');

      // Assert
      expect(result, hasLength(2)); // Bench Press and Squat
    });
  });

  group('error handling', () {
    test('should throw exception when JSON file fails to load', () async {
      // Arrange - Setup mock to throw error
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'ASSET_NOT_FOUND');
        },
      );

      // Act & Assert
      expect(
        () => repository.getAllExercises(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
