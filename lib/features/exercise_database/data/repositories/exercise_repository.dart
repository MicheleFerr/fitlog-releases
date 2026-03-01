import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return MockExerciseRepository(); // Temporarily using mock implementation
});

abstract class ExerciseRepository {
  Stream<List<ExerciseTemplate>> getAllExercises();
  Stream<List<ExerciseTemplate>> getExercisesByCategory(
    ExerciseCategory category,
  );
  Stream<List<ExerciseTemplate>> searchExercises(String query);
  Future<ExerciseTemplate?> getExerciseById(String id);
  Future<List<ExerciseTemplate>> getExercisesByMuscleGroup(String muscleGroup);
}

// Temporary mock implementation for iOS build compatibility
class MockExerciseRepository implements ExerciseRepository {
  final List<ExerciseTemplate> _mockExercises = [
    const ExerciseTemplate(
      id: '1',
      name: 'Push-up',
      description: 'Basic bodyweight chest exercise',
      category: ExerciseCategory.chest,
      type: ExerciseType.single,
      muscleGroups: ['chest', 'triceps', 'shoulders'],
      equipment: ['bodyweight'],
      instructions: [
        'Start in plank position',
        'Lower chest to ground',
        'Push back up',
      ],
      isActive: true,
    ),
  ];

  @override
  Stream<List<ExerciseTemplate>> getAllExercises() {
    return Stream.value(_mockExercises);
  }

  @override
  Stream<List<ExerciseTemplate>> getExercisesByCategory(
    ExerciseCategory category,
  ) {
    return Stream.value(
      _mockExercises.where((e) => e.category == category).toList(),
    );
  }

  @override
  Stream<List<ExerciseTemplate>> searchExercises(String query) {
    if (query.isEmpty) return getAllExercises();
    return Stream.value(
      _mockExercises
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList(),
    );
  }

  @override
  Future<ExerciseTemplate?> getExerciseById(String id) async {
    try {
      return _mockExercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExerciseTemplate>> getExercisesByMuscleGroup(
    String muscleGroup,
  ) async {
    return _mockExercises
        .where(
          (e) => e.muscleGroups.any(
            (m) => m.toLowerCase().contains(muscleGroup.toLowerCase()),
          ),
        )
        .toList();
  }
}
