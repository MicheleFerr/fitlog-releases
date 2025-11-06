import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/strength_standards_local_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/repositories/strength_standards_repository_impl.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

@GenerateMocks([StrengthStandardsLocalDataSource])
import 'strength_standards_repository_impl_test.mocks.dart';

void main() {
  late StrengthStandardsRepositoryImpl repository;
  late MockStrengthStandardsLocalDataSource mockDataSource;

  // Test data
  const testStandard1 = StrengthStandard(
    id: 'barbell_bench_press',
    name: 'Barbell Bench Press',
    keywords: ['bench press', 'panca piana'],
    equipment: 'Barbell',
    muscleGroups: ['PETT', 'Pectorals', 'TRIC', 'Triceps'],
    dataSource: 'exrx_net',
    bodyweightTable: {
      '60': {'novice': 57.5, 'intermediate': 70.0},
      '70': {'novice': 67.5, 'intermediate': 82.5},
    },
    bodyweightMultipliers: {
      'novice': 0.93,
      'intermediate': 1.13,
    },
    isBodyweightExercise: false,
  );

  const testStandard2 = StrengthStandard(
    id: 'barbell_squat',
    name: 'Barbell Squat',
    keywords: ['squat', 'squat'],
    equipment: 'Barbell',
    muscleGroups: ['QUAD', 'Quadriceps', 'GLUT', 'Glutes'],
    dataSource: 'exrx_net',
    bodyweightTable: {
      '60': {'novice': 75.0, 'intermediate': 97.5},
      '70': {'novice': 87.5, 'intermediate': 113.5},
    },
    bodyweightMultipliers: {
      'novice': 1.21,
      'intermediate': 1.58,
    },
    isBodyweightExercise: false,
  );

  const testMapping1 = ExerciseMapping(
    gymbroId: 'ex123',
    gymbroName: 'Bench Press',
    gymbroEquipment: 'Barbell',
    gymbroFocus: 'PETT',
    confidence: 0.95,
    status: MappingStatus.auto,
    standardId: 'barbell_bench_press',
    standardName: 'Barbell Bench Press',
    standardEquipment: 'Barbell',
    dataSource: 'exrx_net',
    fallbackReason: null,
  );

  const testMapping2 = ExerciseMapping(
    gymbroId: 'ex456',
    gymbroName: 'Incline Bench',
    gymbroEquipment: 'Barbell',
    gymbroFocus: 'PETT',
    confidence: 0.72,
    status: MappingStatus.review,
    standardId: 'barbell_bench_press',
    standardName: 'Barbell Bench Press',
    standardEquipment: 'Barbell',
    dataSource: 'exrx_net',
    fallbackReason: null,
  );

  const testMapping3 = ExerciseMapping(
    gymbroId: 'ex789',
    gymbroName: 'Cable Fly',
    gymbroEquipment: 'Cable',
    gymbroFocus: 'PETT',
    confidence: 0.45,
    status: MappingStatus.fallback,
    standardId: null,
    standardName: null,
    standardEquipment: null,
    dataSource: null,
    fallbackReason: 'No suitable match',
  );

  setUp(() {
    mockDataSource = MockStrengthStandardsLocalDataSource();
    repository = StrengthStandardsRepositoryImpl(mockDataSource);
  });

  group('getStrengthStandards', () {
    test('should load standards from datasource on first call', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result = await repository.getStrengthStandards();

      // Assert
      expect(result, [testStandard1, testStandard2]);
      verify(mockDataSource.loadStrengthStandards()).called(1);
    });

    test('should return cached standards on subsequent calls', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      await repository.getStrengthStandards();
      final result = await repository.getStrengthStandards();

      // Assert
      expect(result, [testStandard1, testStandard2]);
      verify(mockDataSource.loadStrengthStandards()).called(1); // Only once
    });

    test('should reload standards when forceRefresh is true', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      await repository.getStrengthStandards();
      final result = await repository.getStrengthStandards(forceRefresh: true);

      // Assert
      expect(result, [testStandard1, testStandard2]);
      verify(mockDataSource.loadStrengthStandards()).called(2); // Called twice
    });
  });

  group('getExerciseMappings', () {
    test('should load mappings from datasource on first call', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result = await repository.getExerciseMappings();

      // Assert
      expect(result, [testMapping1, testMapping2, testMapping3]);
      verify(mockDataSource.loadExerciseMappings()).called(1);
    });

    test('should return cached mappings on subsequent calls', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      await repository.getExerciseMappings();
      final result = await repository.getExerciseMappings();

      // Assert
      expect(result, [testMapping1, testMapping2, testMapping3]);
      verify(mockDataSource.loadExerciseMappings()).called(1); // Only once
    });

    test('should reload mappings when forceRefresh is true', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      await repository.getExerciseMappings();
      final result = await repository.getExerciseMappings(forceRefresh: true);

      // Assert
      expect(result, [testMapping1, testMapping2, testMapping3]);
      verify(mockDataSource.loadExerciseMappings()).called(2); // Called twice
    });
  });

  group('getStrengthStandardById', () {
    test('should return correct standard by id', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardById('barbell_bench_press');

      // Assert
      expect(result, testStandard1);
    });

    test('should return null for non-existent id', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result = await repository.getStrengthStandardById('non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should use cached data when available', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      await repository.getStrengthStandards(); // Load cache
      final result =
          await repository.getStrengthStandardById('barbell_squat');

      // Assert
      expect(result, testStandard2);
      verify(mockDataSource.loadStrengthStandards()).called(1); // Only once
    });
  });

  group('getMappingForExercise', () {
    test('should return correct mapping by exercise id', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result = await repository.getMappingForExercise('ex123');

      // Assert
      expect(result, testMapping1);
    });

    test('should return null for non-existent exercise id', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result = await repository.getMappingForExercise('non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should use cached data when available', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      await repository.getExerciseMappings(); // Load cache
      final result = await repository.getMappingForExercise('ex456');

      // Assert
      expect(result, testMapping2);
      verify(mockDataSource.loadExerciseMappings()).called(1); // Only once
    });
  });

  group('getMappingsByStatus', () {
    test('should return only auto mappings', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result = await repository.getMappingsByStatus(MappingStatus.auto);

      // Assert
      expect(result, [testMapping1]);
    });

    test('should return only review mappings', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result =
          await repository.getMappingsByStatus(MappingStatus.review);

      // Assert
      expect(result, [testMapping2]);
    });

    test('should return only fallback mappings', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result =
          await repository.getMappingsByStatus(MappingStatus.fallback);

      // Assert
      expect(result, [testMapping3]);
    });

    test('should return empty list when no mappings match status', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1]); // Only auto

      // Act
      final result =
          await repository.getMappingsByStatus(MappingStatus.fallback);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('getHighConfidenceMappings', () {
    test('should return mappings with confidence >= 0.80 by default', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result = await repository.getHighConfidenceMappings();

      // Assert
      expect(result, [testMapping1]); // Only 0.95
    });

    test('should return mappings with custom min confidence', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1, testMapping2, testMapping3]);

      // Act
      final result =
          await repository.getHighConfidenceMappings(minConfidence: 0.70);

      // Assert
      expect(result, [testMapping1, testMapping2]); // 0.95 and 0.72
    });

    test('should return empty list when no mappings meet threshold', () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping3]); // Only 0.45

      // Act
      final result = await repository.getHighConfidenceMappings();

      // Assert
      expect(result, isEmpty);
    });

    test('should include mappings exactly at threshold', () async {
      // Arrange
      const exactMapping = ExerciseMapping(
        gymbroId: 'ex_exact',
        gymbroName: 'Test',
        gymbroEquipment: 'Barbell',
        confidence: 0.80,
        status: MappingStatus.auto,
        standardId: 'test',
      );

      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [exactMapping]);

      // Act
      final result = await repository.getHighConfidenceMappings();

      // Assert
      expect(result, [exactMapping]);
    });
  });

  group('getStrengthStandardsByEquipment', () {
    test('should return standards matching equipment (case-insensitive)',
        () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardsByEquipment('barbell');

      // Assert
      expect(result, [testStandard1, testStandard2]);
    });

    test('should return empty list when no standards match equipment',
        () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardsByEquipment('Dumbbells');

      // Assert
      expect(result, isEmpty);
    });

    test('should handle equipment with different case', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardsByEquipment('BARBELL');

      // Assert
      expect(result, [testStandard1, testStandard2]);
    });
  });

  group('getStrengthStandardsByMuscleGroup', () {
    test('should return standards matching muscle group (case-insensitive)',
        () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardsByMuscleGroup('pett');

      // Assert
      expect(result, [testStandard1]);
    });

    test('should return standards matching muscle group substring', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardsByMuscleGroup('Pectoral');

      // Assert
      expect(result, [testStandard1]); // Contains "Pectorals"
    });

    test('should return empty list when no standards match muscle group',
        () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result =
          await repository.getStrengthStandardsByMuscleGroup('Biceps');

      // Assert
      expect(result, isEmpty);
    });

    test('should handle partial matches', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1, testStandard2]);

      // Act
      final result = await repository.getStrengthStandardsByMuscleGroup('quad');

      // Assert
      expect(result, [testStandard2]); // Contains "Quadriceps"
    });
  });

  group('getMetadata', () {
    test('should return combined metadata from both datasources', () async {
      // Arrange
      final standardsMetadata = {'version': '1.0', 'count': 100};
      final mappingsMetadata = {'version': '2.0', 'count': 50};

      when(mockDataSource.loadStrengthStandardsMetadata())
          .thenAnswer((_) async => standardsMetadata);
      when(mockDataSource.loadExerciseMappingsMetadata())
          .thenAnswer((_) async => mappingsMetadata);

      // Act
      final result = await repository.getMetadata();

      // Assert
      expect(result, {
        'strengthStandards': standardsMetadata,
        'exerciseMappings': mappingsMetadata,
      });
      verify(mockDataSource.loadStrengthStandardsMetadata()).called(1);
      verify(mockDataSource.loadExerciseMappingsMetadata()).called(1);
    });
  });

  group('clearCache', () {
    test('should clear all cached data', () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1]);
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1]);

      // Act
      await repository.getStrengthStandards(); // Load cache
      await repository.getExerciseMappings(); // Load cache
      repository.clearCache();
      await repository.getStrengthStandards(); // Should reload

      // Assert
      verify(mockDataSource.loadStrengthStandards()).called(2); // Before and after clear
    });

    test('should allow getStrengthStandardById to work after clearCache',
        () async {
      // Arrange
      when(mockDataSource.loadStrengthStandards())
          .thenAnswer((_) async => [testStandard1]);

      // Act
      await repository.getStrengthStandards();
      repository.clearCache();
      final result =
          await repository.getStrengthStandardById('barbell_bench_press');

      // Assert
      expect(result, testStandard1);
      verify(mockDataSource.loadStrengthStandards()).called(2);
    });

    test('should allow getMappingForExercise to work after clearCache',
        () async {
      // Arrange
      when(mockDataSource.loadExerciseMappings())
          .thenAnswer((_) async => [testMapping1]);

      // Act
      await repository.getExerciseMappings();
      repository.clearCache();
      final result = await repository.getMappingForExercise('ex123');

      // Assert
      expect(result, testMapping1);
      verify(mockDataSource.loadExerciseMappings()).called(2);
    });
  });
}
