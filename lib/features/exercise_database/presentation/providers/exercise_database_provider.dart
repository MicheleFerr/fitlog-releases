import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise_database.dart';

final exerciseDatabaseProvider = FutureProvider<List<ExerciseDatabase>>((ref) async {
  // TODO: Implement actual database fetch
  // For now, return mock data
  return [
    const ExerciseDatabase(
      id: '1',
      name: 'Bench Press',
      category: 'Chest',
      equipment: 'Barbell',
      primaryMuscleGroups: ['Chest'],
      secondaryMuscleGroups: ['Triceps', 'Shoulders'],
      difficulty: 'Intermediate',
    ),
    const ExerciseDatabase(
      id: '2',
      name: 'Squat',
      category: 'Legs',
      equipment: 'Barbell',
      primaryMuscleGroups: ['Quadriceps'],
      secondaryMuscleGroups: ['Glutes', 'Hamstrings'],
      difficulty: 'Intermediate',
    ),
    const ExerciseDatabase(
      id: '3',
      name: 'Deadlift',
      category: 'Back',
      equipment: 'Barbell',
      primaryMuscleGroups: ['Back'],
      secondaryMuscleGroups: ['Glutes', 'Hamstrings'],
      difficulty: 'Advanced',
    ),
  ];
});