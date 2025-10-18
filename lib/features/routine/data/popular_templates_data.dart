/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data
/// 🎯 Feature: flexible_routine
/// 🔧 Type: data
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// POPULAR TEMPLATES DATA - Predefined workout templates for quick start
library;

import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Popular templates data provider
class PopularTemplatesData {
  static const _uuid = Uuid();

  /// Get all popular templates
  static List<WorkoutTemplate> getPopularTemplates() {
    return [
      _createClassicPushTemplate(),
      _createClassicPullTemplate(),
      _createLegDayTemplate(),
      _createUpperBodyTemplate(),
      _createLowerBodyTemplate(),
      _createFullBodyTemplate(),
    ];
  }

  /// Classic Push Day (Chest, Shoulders, Triceps)
  static WorkoutTemplate _createClassicPushTemplate() {
    return WorkoutTemplate(
      id: 'popular_push_${_uuid.v4()}',
      name: 'Classic Push Day',
      description: 'Chest, Shoulders & Triceps workout for push days',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'bench_press',
          exerciseName: 'Barbell Bench Press',
          category: ExerciseCategory.chest,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 4, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'incline_dumbbell_press',
          exerciseName: 'Incline Dumbbell Press',
          category: ExerciseCategory.chest,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'overhead_press',
          exerciseName: 'Overhead Press',
          category: ExerciseCategory.shoulders,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'lateral_raise',
          exerciseName: 'Lateral Raises',
          category: ExerciseCategory.shoulders,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 12, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'tricep_pushdown',
          exerciseName: 'Tricep Pushdowns',
          category: ExerciseCategory.arms,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 12, targetWeight: 0, targetRpe: 9),
          ],
        ),
      ],
      usageCount: 0,
      tags: ['Push', 'Chest', 'Shoulders', 'Triceps', 'PPL'],
    );
  }

  /// Classic Pull Day (Back, Biceps, Rear Delts)
  static WorkoutTemplate _createClassicPullTemplate() {
    return WorkoutTemplate(
      id: 'popular_pull_${_uuid.v4()}',
      name: 'Classic Pull Day',
      description: 'Back & Biceps workout for pull days',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          category: ExerciseCategory.back,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 5, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 5, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 5, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'pullups',
          exerciseName: 'Pull-ups',
          category: ExerciseCategory.back,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'barbell_row',
          exerciseName: 'Barbell Row',
          category: ExerciseCategory.back,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'face_pulls',
          exerciseName: 'Face Pulls',
          category: ExerciseCategory.shoulders,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 15, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 15, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 3, targetReps: 15, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'barbell_curl',
          exerciseName: 'Barbell Curl',
          category: ExerciseCategory.arms,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 0, targetRpe: 9),
          ],
        ),
      ],
      usageCount: 0,
      tags: ['Pull', 'Back', 'Biceps', 'PPL'],
    );
  }

  /// Leg Day (Quads, Hamstrings, Calves, Glutes)
  static WorkoutTemplate _createLegDayTemplate() {
    return WorkoutTemplate(
      id: 'popular_legs_${_uuid.v4()}',
      name: 'Leg Day',
      description: 'Complete lower body workout',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
            SetTemplate(setNumber: 4, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'romanian_deadlift',
          exerciseName: 'Romanian Deadlift',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'leg_press',
          exerciseName: 'Leg Press',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 12, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'leg_curl',
          exerciseName: 'Leg Curl',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 12, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'calf_raise',
          exerciseName: 'Standing Calf Raises',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 15, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 15, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 15, targetWeight: 0, targetRpe: 9),
          ],
        ),
      ],
      usageCount: 0,
      tags: ['Legs', 'Lower Body', 'PPL'],
    );
  }

  /// Upper Body (All upper muscle groups)
  static WorkoutTemplate _createUpperBodyTemplate() {
    return WorkoutTemplate(
      id: 'popular_upper_${_uuid.v4()}',
      name: 'Upper Body',
      description: 'Complete upper body workout for Upper/Lower split',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'bench_press',
          exerciseName: 'Barbell Bench Press',
          category: ExerciseCategory.chest,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'barbell_row',
          exerciseName: 'Barbell Row',
          category: ExerciseCategory.back,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'overhead_press',
          exerciseName: 'Overhead Press',
          category: ExerciseCategory.shoulders,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'dumbbell_curl',
          exerciseName: 'Dumbbell Curl',
          category: ExerciseCategory.arms,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'tricep_extension',
          exerciseName: 'Overhead Tricep Extension',
          category: ExerciseCategory.arms,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
          ],
        ),
      ],
      usageCount: 0,
      tags: ['Upper Body', 'Upper/Lower Split'],
    );
  }

  /// Lower Body (All lower muscle groups)
  static WorkoutTemplate _createLowerBodyTemplate() {
    return WorkoutTemplate(
      id: 'popular_lower_${_uuid.v4()}',
      name: 'Lower Body',
      description: 'Complete lower body workout for Upper/Lower split',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'romanian_deadlift',
          exerciseName: 'Romanian Deadlift',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'bulgarian_split_squat',
          exerciseName: 'Bulgarian Split Squat',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'leg_curl',
          exerciseName: 'Leg Curl',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 12, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 12, targetWeight: 0, targetRpe: 8),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'calf_raise',
          exerciseName: 'Standing Calf Raises',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 15, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 15, targetWeight: 0, targetRpe: 9),
          ],
        ),
      ],
      usageCount: 0,
      tags: ['Lower Body', 'Upper/Lower Split'],
    );
  }

  /// Full Body Compound (Major lifts)
  static WorkoutTemplate _createFullBodyTemplate() {
    return WorkoutTemplate(
      id: 'popular_fullbody_${_uuid.v4()}',
      name: 'Full Body Compound',
      description: 'Complete full body workout with major compound lifts',
      exercises: [
        const ExerciseTemplate(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          category: ExerciseCategory.legs,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 9),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'bench_press',
          exerciseName: 'Barbell Bench Press',
          category: ExerciseCategory.chest,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 3, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          category: ExerciseCategory.back,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 5, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 5, targetWeight: 0, targetRpe: 9),
            SetTemplate(setNumber: 3, targetReps: 5, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'overhead_press',
          exerciseName: 'Overhead Press',
          category: ExerciseCategory.shoulders,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 8),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 9),
          ],
        ),
        const ExerciseTemplate(
          exerciseId: 'pullups',
          exerciseName: 'Pull-ups',
          category: ExerciseCategory.back,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 8, targetWeight: 0, targetRpe: 7),
            SetTemplate(setNumber: 2, targetReps: 8, targetWeight: 0, targetRpe: 8),
          ],
        ),
      ],
      usageCount: 0,
      tags: ['Full Body', 'Compound'],
    );
  }
}
