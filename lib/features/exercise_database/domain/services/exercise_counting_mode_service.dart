/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/services
/// 🎯 Feature: Exercise Counting Mode Service (STUB)
/// 🔧 Type: Service
///
/// Temporary stub to prevent compilation errors
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

class ExerciseCountingModeService {
  static ExerciseCountingMode getModeFromWorkoutExercise(Exercise exercise) {
    // ✅ FIX: Read counting mode from exercise instead of always returning weighted
    // Previous stub always returned weighted, causing UI to never update when changing mode
    return exercise.countingMode;
  }
}
