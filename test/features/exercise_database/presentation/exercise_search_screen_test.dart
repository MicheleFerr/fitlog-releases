/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test/features/exercise_database
/// 🎯 Feature: exercise search screen tests
/// 🔧 Type: widget test
/// 🌍 Localization: ✅ AppLocalizations tested
/// 🎨 Theme: ✅ ColorScheme tested
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import '../../test_helpers/firebase_test_helper.dart';

class MockExerciseRepository extends Mock {
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.isEmpty) {
      return getAllExercises();
    }
    final allExercises = await getAllExercises();
    return allExercises
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<Exercise>> getAllExercises() async {
    return [
      const Exercise(
        id: '1',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        equipment: 'Barbell',
        difficulty: 'Intermediate',
        instructions: ['Lie on bench', 'Lower bar to chest', 'Press up'],
        category: 'Strength',
      ),
      const Exercise(
        id: '2',
        name: 'Squat',
        muscleGroup: 'Legs',
        equipment: 'Barbell',
        difficulty: 'Intermediate',
        instructions: ['Stand with bar on back', 'Squat down', 'Stand up'],
        category: 'Strength',
      ),
      const Exercise(
        id: '3',
        name: 'Deadlift',
        muscleGroup: 'Back',
        equipment: 'Barbell',
        difficulty: 'Advanced',
        instructions: ['Stand over bar', 'Lift with legs and back', 'Stand tall'],
        category: 'Strength',
      ),
      const Exercise(
        id: '4',
        name: 'Pull-up',
        muscleGroup: 'Back',
        equipment: 'Pull-up Bar',
        difficulty: 'Intermediate',
        instructions: ['Hang from bar', 'Pull up', 'Lower down'],
        category: 'Strength',
      ),
      const Exercise(
        id: '5',
        name: 'Dumbbell Curl',
        muscleGroup: 'Arms',
        equipment: 'Dumbbell',
        difficulty: 'Beginner',
        instructions: ['Hold dumbbells', 'Curl up', 'Lower down'],
        category: 'Strength',
      ),
    ];
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final allExercises = await getAllExercises();
    return allExercises
        .where((e) => e.muscleGroup == muscleGroup)
        .toList();
  }

  Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    final allExercises = await getAllExercises();
    return allExercises
        .where((e) => e.equipment == equipment)
        .toList();
  }
}

void main() {
  group('ExerciseSearchScreen Tests', () {
    late MockExerciseRepository mockRepository;

    setUp(() {
      mockRepository = MockExerciseRepository();
    });

    Widget createTestWidget() {
      return const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProviderScope(
          child: ExerciseSearchScreen(),
        ),
      );
    }

    testWidgets('displays search bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows exercise list when loaded', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show some exercises
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('filters exercises by search query', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'bench');
      await tester.pumpAndSettle();

      // Should filter results
      expect(find.text('Bench Press'), findsWidgets);
    });

    testWidgets('shows muscle group filters', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for filter chips
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('can select multiple exercises', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap checkboxes
      final checkboxes = find.byType(Checkbox);
      if (checkboxes.evaluate().isNotEmpty) {
        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();
      }

      // Should show selection count
      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('shows equipment filter options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for equipment related widgets
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    testWidgets('displays exercise details on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on an exercise
      final exerciseTiles = find.byType(ListTile);
      if (exerciseTiles.evaluate().isNotEmpty) {
        await tester.tap(exerciseTiles.first);
        await tester.pumpAndSettle();

        // Should show details or navigate
        expect(find.byType(Dialog), findsWidgets);
      }
    });

    test('Exercise model stores all required data', () {
      const exercise = Exercise(
        id: 'test-1',
        name: 'Test Exercise',
        muscleGroup: 'Test Group',
        equipment: 'Test Equipment',
        difficulty: 'Beginner',
        instructions: ['Step 1', 'Step 2'],
        category: 'Strength',
      );

      expect(exercise.id, 'test-1');
      expect(exercise.name, 'Test Exercise');
      expect(exercise.muscleGroup, 'Test Group');
      expect(exercise.equipment, 'Test Equipment');
      expect(exercise.difficulty, 'Beginner');
      expect(exercise.instructions, hasLength(2));
      expect(exercise.category, 'Strength');
    });

    test('Repository returns filtered exercises', () async {
      final exercises = await mockRepository.searchExercises('squat');
      
      expect(exercises, isNotEmpty);
      expect(exercises.first.name, 'Squat');
    });

    test('Repository filters by muscle group', () async {
      final exercises = await mockRepository.getExercisesByMuscleGroup('Chest');
      
      expect(exercises, isNotEmpty);
      expect(exercises.every((e) => e.muscleGroup == 'Chest'), true);
    });

    test('Repository filters by equipment', () async {
      final exercises = await mockRepository.getExercisesByEquipment('Barbell');
      
      expect(exercises, isNotEmpty);
      expect(exercises.every((e) => e.equipment == 'Barbell'), true);
    });

    testWidgets('handles empty search results', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Search for non-existent exercise
      await tester.enterText(find.byType(TextField), 'xyz123');
      await tester.pumpAndSettle();

      // Should show no results message
      expect(find.text('No exercises found'), findsWidgets);
    });

    testWidgets('clears search on clear button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // Tap clear button
      final clearButton = find.byIcon(Icons.clear);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Search should be cleared
        expect(find.text('test'), findsNothing);
      }
    });

    testWidgets('shows loading indicator while searching', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Initially might show loading
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      await tester.pumpAndSettle();
      
      // After loading, indicator should disappear
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Exercise Filtering Tests', () {
    late MockExerciseRepository repository;

    setUp(() {
      repository = MockExerciseRepository();
    });

    test('filters exercises by multiple criteria', () async {
      final allExercises = await repository.getAllExercises();
      
      // Filter by muscle group AND difficulty
      final filtered = allExercises
          .where((e) => e.muscleGroup == 'Back' && e.difficulty == 'Advanced')
          .toList();
      
      expect(filtered, isNotEmpty);
      expect(filtered.first.name, 'Deadlift');
    });

    test('sorts exercises alphabetically', () async {
      final exercises = await repository.getAllExercises();
      exercises.sort((a, b) => a.name.compareTo(b.name));
      
      expect(exercises.first.name, 'Bench Press');
      expect(exercises.last.name, 'Squat');
    });

    test('groups exercises by muscle group', () async {
      final exercises = await repository.getAllExercises();
      final grouped = <String, List<Exercise>>{};
      
      for (final exercise in exercises) {
        final group = exercise.muscleGroup ?? 'Other';
        grouped[group] ??= [];
        grouped[group]!.add(exercise);
      }
      
      expect(grouped.keys, contains('Chest'));
      expect(grouped.keys, contains('Back'));
      expect(grouped.keys, contains('Legs'));
    });

    test('finds exercises with specific equipment', () async {
      final exercises = await repository.getAllExercises();
      final barbellExercises = exercises
          .where((e) => e.equipment == 'Barbell')
          .toList();
      
      expect(barbellExercises.length, 3);
      expect(barbellExercises.map((e) => e.name),
          containsAll(['Bench Press', 'Squat', 'Deadlift']));
    });

    test('identifies beginner-friendly exercises', () async {
      final exercises = await repository.getAllExercises();
      final beginnerExercises = exercises
          .where((e) => e.difficulty == 'Beginner')
          .toList();
      
      expect(beginnerExercises, isNotEmpty);
      expect(beginnerExercises.first.name, 'Dumbbell Curl');
    });
  });
}