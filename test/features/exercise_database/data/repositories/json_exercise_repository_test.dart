import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

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

    // Mock AssetBundle.loadString for English exercises
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'load') {
          final String assetPath = methodCall.arguments as String;
          if (assetPath == 'assets/data/exercises.json') {
            return ByteData.sublistView(utf8.encode(testExercisesJson));
          }
          if (assetPath == 'assets/data/exercises_it.json') {
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

  group('getExercisesByFocus', () {
    test('should return exercises matching single focus group', () async {
      // Act
      final result = await repository.getExercisesByFocus(['PETT']);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bench Press');
    });

    test('should return exercises matching multiple focus groups', () async {
      // Act
      final result = await repository.getExercisesByFocus(['QUAD', 'BICE']);

      // Assert
      expect(result, hasLength(2)); // Squat and Bicep Curl
    });

    test('should return empty list when no exercises match focus', () async {
      // Act
      final result = await repository.getExercisesByFocus(['NONEXISTENT']);

      // Assert
      expect(result, isEmpty);
    });

    test('should match exercises with any of the provided focus groups',
        () async {
      // Act
      final result = await repository.getExercisesByFocus(['TRIC']);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bench Press');
    });
  });

  group('getExercisesByEquipment', () {
    test('should return exercises matching single equipment', () async {
      // Act
      final result = await repository.getExercisesByEquipment(['Barbell']);

      // Assert
      expect(result, hasLength(2)); // Bench Press and Squat
    });

    test('should return exercises matching multiple equipment types', () async {
      // Act
      final result =
          await repository.getExercisesByEquipment(['Barbell', 'Dumbbell']);

      // Assert
      expect(result, hasLength(3)); // All exercises
    });

    test('should return empty list when no exercises match equipment',
        () async {
      // Act
      final result = await repository.getExercisesByEquipment(['Machine']);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('getExercisesByDifficulty', () {
    test('should return exercises matching single difficulty', () async {
      // Act
      final result = await repository.getExercisesByDifficulty(['Beginner']);

      // Assert
      expect(result, hasLength(1));
      expect(result[0].nome, 'Bicep Curl');
    });

    test('should return exercises matching multiple difficulties', () async {
      // Act
      final result =
          await repository.getExercisesByDifficulty(['Beginner', 'Advanced']);

      // Assert
      expect(result, hasLength(2)); // Bicep Curl and Squat
    });

    test('should return empty list when no exercises match difficulty',
        () async {
      // Act
      final result = await repository.getExercisesByDifficulty(['Expert']);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('getExerciseById', () {
    test('should return exercise with matching id', () async {
      // Act
      final result = await repository.getExerciseById('ex1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'ex1');
      expect(result.nome, 'Bench Press');
    });

    test('should return null for non-existent id', () async {
      // Act
      final result = await repository.getExerciseById('nonexistent');

      // Assert
      expect(result, isNull);
    });
  });

  group('getUniqueFocusGroups', () {
    test('should return sorted unique focus groups', () async {
      // Act
      final result = await repository.getUniqueFocusGroups();

      // Assert
      expect(result, contains('PETT'));
      expect(result, contains('QUAD'));
      expect(result, contains('BICE'));
      expect(result, contains('TRIC'));
      expect(result, contains('GLUT'));
      // Should be sorted
      final sortedResult = List<String>.from(result)..sort();
      expect(result, equals(sortedResult));
    });

    test('should expand all focus groups from all exercises', () async {
      // Act
      final result = await repository.getUniqueFocusGroups();

      // Assert
      // ex1: PETT, TRIC (2)
      // ex2: QUAD, GLUT (2)
      // ex3: BICE (1)
      // Total unique: 5
      expect(result, hasLength(5));
    });
  });

  group('getUniqueEquipment', () {
    test('should return sorted unique equipment types', () async {
      // Act
      final result = await repository.getUniqueEquipment();

      // Assert
      expect(result, contains('Barbell'));
      expect(result, contains('Dumbbell'));
      // Should be sorted
      final sortedResult = List<String>.from(result)..sort();
      expect(result, equals(sortedResult));
    });

    test('should return only unique equipment', () async {
      // Act
      final result = await repository.getUniqueEquipment();

      // Assert
      expect(result, hasLength(2)); // Barbell (2x) and Dumbbell (1x)
    });
  });

  group('getUniqueDifficulties', () {
    test('should return sorted unique difficulties', () async {
      // Act
      final result = await repository.getUniqueDifficulties();

      // Assert
      expect(result, contains('Beginner'));
      expect(result, contains('Intermediate'));
      expect(result, contains('Advanced'));
      // Should be sorted
      final sortedResult = List<String>.from(result)..sort();
      expect(result, equals(sortedResult));
    });

    test('should return only unique difficulties', () async {
      // Act
      final result = await repository.getUniqueDifficulties();

      // Assert
      expect(result, hasLength(3));
    });
  });

  group('clearCache', () {
    test('should force reload after clearing cache', () async {
      // Arrange
      await repository.getAllExercises(); // Load and cache

      // Act
      repository.clearCache();
      final result = await repository.getAllExercises();

      // Assert
      expect(result, hasLength(3)); // Should reload
    });

    test('should allow locale change to work after cache clear', () async {
      // Arrange
      await repository.getAllExercises(); // Load English

      // Act
      repository.clearCache();
      final italianRepo = JsonExerciseRepository(locale: const Locale('it'));
      final result = await italianRepo.getAllExercises();

      // Assert
      expect(result, hasLength(3)); // Should load Italian
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
