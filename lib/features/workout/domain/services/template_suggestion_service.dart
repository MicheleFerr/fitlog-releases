/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: domain/services
/// Feature: workout
/// Type: service
///
/// Template suggestion service that recommends predefined workout templates
/// based on user context (time, level, gender, category).
///
/// Template matching logic:
/// - Time: 5min (quick), 15min (express), 30min (standard), 45min (full)
/// - Level: beginner, intermediate, advanced
/// - Category: chest, back, legs, shoulders, arms, abs, cardio, fullBody
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Service for suggesting workout templates based on user context
class TemplateSuggestionService {
  /// Get suggested template based on user context and category
  ///
  /// Returns the best matching template or null if no match found.
  /// Matching priority:
  /// 1. Exact time + level + category match
  /// 2. Time range + level + category match
  /// 3. Level + category match (ignore time)
  /// 4. Category only match (fallback)
  WorkoutTemplate? getSuggestedTemplate({
    required WorkoutContext context,
    required String category,
  }) {
    final templates = _getPredefinedTemplates();

    // Filter by category first
    final categoryTemplates = templates
        .where((t) => t.tags.contains(category.toLowerCase()))
        .toList();

    if (categoryTemplates.isEmpty) {
      return null;
    }

    // Try exact time match
    final exactTimeMatch = categoryTemplates.where((t) {
      final estimatedDuration = t.estimatedDuration;
      return _matchesTimeRange(estimatedDuration, context.timeAvailable) &&
          _matchesLevel(t.tags, context.experienceLevel);
    }).toList();

    if (exactTimeMatch.isNotEmpty) {
      return exactTimeMatch.first;
    }

    // Try level match only
    final levelMatch = categoryTemplates.where((t) {
      return _matchesLevel(t.tags, context.experienceLevel);
    }).toList();

    if (levelMatch.isNotEmpty) {
      return levelMatch.first;
    }

    // Fallback to first category match
    return categoryTemplates.first;
  }

  /// Get all suggested templates for a category (for showing multiple options)
  List<WorkoutTemplate> getSuggestedTemplates({
    required WorkoutContext context,
    required String category,
    int maxResults = 3,
  }) {
    final templates = _getPredefinedTemplates();

    // Score each template based on match quality
    final scored = templates.map((t) {
      final score = _calculateMatchScore(t, context, category);
      return (template: t, score: score);
    }).where((r) => r.score > 0).toList();

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(maxResults).map((r) => r.template).toList();
  }

  /// Calculate match score for a template
  int _calculateMatchScore(
    WorkoutTemplate template,
    WorkoutContext context,
    String category,
  ) {
    int score = 0;

    // Category match (required)
    if (!template.tags.contains(category.toLowerCase())) {
      return 0;
    }
    score += 10;

    // Time match
    if (_matchesTimeRange(template.estimatedDuration, context.timeAvailable)) {
      score += 5;
    }

    // Level match
    if (_matchesLevel(template.tags, context.experienceLevel)) {
      score += 5;
    }

    // Gender match (if applicable)
    if (context.gender != null) {
      if (template.tags.contains(context.gender!)) {
        score += 2;
      } else if (!template.tags.contains('male') &&
          !template.tags.contains('female')) {
        // Template is gender-neutral, minor bonus
        score += 1;
      }
    }

    return score;
  }

  bool _matchesTimeRange(int templateDuration, int availableTime) {
    // Allow some flexibility in matching
    // 5min -> 0-10min, 15min -> 10-20min, 30min -> 20-40min, 45min -> 35-60min
    switch (availableTime) {
      case 5:
        return templateDuration <= 10;
      case 15:
        return templateDuration > 10 && templateDuration <= 20;
      case 30:
        return templateDuration > 20 && templateDuration <= 40;
      case 45:
        return templateDuration > 35;
      default:
        return templateDuration <= availableTime + 10;
    }
  }

  bool _matchesLevel(List<String> tags, ExperienceLevel? level) {
    if (level == null) return true; // No preference
    return tags.contains(level.name.toLowerCase());
  }

  /// Get all predefined templates
  ///
  /// Organized by category and level for comprehensive coverage.
  List<WorkoutTemplate> _getPredefinedTemplates() {
    return [
      // ===== CHEST WORKOUTS =====

      // Quick chest (5-15 min)
      WorkoutTemplate(
        id: 'chest_quick_beginner',
        name: 'Chest Express',
        description: 'Quick chest pump with push-ups and dumbbell press',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'push_ups',
            exerciseName: 'Push Ups',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'dumbbell_press',
            exerciseName: 'Dumbbell Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['chest', 'beginner', 'quick'],
        estimatedDuration: 10,
        isCustom: false,
      ),

      // Standard chest (30 min)
      WorkoutTemplate(
        id: 'chest_standard_intermediate',
        name: 'Chest Builder',
        description: 'Complete chest workout with compound and isolation',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'bench_press',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'incline_dumbbell_press',
            exerciseName: 'Incline Dumbbell Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'cable_fly',
            exerciseName: 'Cable Fly',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
        ],
        tags: ['chest', 'intermediate', 'strength'],
        estimatedDuration: 35,
        isCustom: false,
      ),

      // Advanced chest (45 min)
      WorkoutTemplate(
        id: 'chest_full_advanced',
        name: 'Chest Destroyer',
        description: 'High-volume chest for advanced lifters',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'bench_press',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 6),
              SetTemplate(setNumber: 3, targetReps: 4),
              SetTemplate(setNumber: 4, targetReps: 4),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'incline_bench_press',
            exerciseName: 'Incline Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'dips',
            exerciseName: 'Chest Dips',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'pec_deck',
            exerciseName: 'Pec Deck',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
        ],
        tags: ['chest', 'advanced', 'hypertrophy'],
        estimatedDuration: 50,
        isCustom: false,
      ),

      // ===== BACK WORKOUTS =====

      // Quick back (15 min)
      WorkoutTemplate(
        id: 'back_quick_beginner',
        name: 'Back Express',
        description: 'Quick back workout with rows and pulldowns',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'lat_pulldown',
            exerciseName: 'Lat Pulldown',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'seated_row',
            exerciseName: 'Seated Cable Row',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['back', 'beginner', 'quick'],
        estimatedDuration: 15,
        isCustom: false,
      ),

      // Standard back (30 min)
      WorkoutTemplate(
        id: 'back_standard_intermediate',
        name: 'Back Builder',
        description: 'Complete back workout for thickness and width',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'pull_ups',
            exerciseName: 'Pull Ups',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'barbell_row',
            exerciseName: 'Barbell Row',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'face_pull',
            exerciseName: 'Face Pull',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 15),
            ],
          ),
        ],
        tags: ['back', 'intermediate', 'strength'],
        estimatedDuration: 35,
        isCustom: false,
      ),

      // ===== LEG WORKOUTS =====

      // Quick legs (15 min)
      WorkoutTemplate(
        id: 'legs_quick_beginner',
        name: 'Leg Express',
        description: 'Quick lower body circuit',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'goblet_squat',
            exerciseName: 'Goblet Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'lunges',
            exerciseName: 'Walking Lunges',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['legs', 'beginner', 'quick'],
        estimatedDuration: 15,
        isCustom: false,
      ),

      // Standard legs (30 min)
      WorkoutTemplate(
        id: 'legs_standard_intermediate',
        name: 'Leg Day',
        description: 'Complete lower body workout',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'squat',
            exerciseName: 'Barbell Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'leg_press',
            exerciseName: 'Leg Press',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'leg_curl',
            exerciseName: 'Lying Leg Curl',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['legs', 'intermediate', 'strength'],
        estimatedDuration: 40,
        isCustom: false,
      ),

      // Full legs (45 min)
      WorkoutTemplate(
        id: 'legs_full_advanced',
        name: 'Leg Destroyer',
        description: 'High-volume leg workout for growth',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'squat',
            exerciseName: 'Barbell Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 6),
              SetTemplate(setNumber: 3, targetReps: 6),
              SetTemplate(setNumber: 4, targetReps: 4),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'romanian_deadlift',
            exerciseName: 'Romanian Deadlift',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'leg_press',
            exerciseName: 'Leg Press',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'calf_raise',
            exerciseName: 'Standing Calf Raise',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 15),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
        ],
        tags: ['legs', 'advanced', 'hypertrophy'],
        estimatedDuration: 55,
        isCustom: false,
      ),

      // ===== SHOULDERS WORKOUTS =====

      // Quick shoulders (15 min)
      WorkoutTemplate(
        id: 'shoulders_quick_beginner',
        name: 'Shoulder Express',
        description: 'Quick shoulder pump',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'dumbbell_shoulder_press',
            exerciseName: 'Dumbbell Shoulder Press',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'lateral_raise',
            exerciseName: 'Lateral Raise',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
            ],
          ),
        ],
        tags: ['shoulders', 'beginner', 'quick'],
        estimatedDuration: 15,
        isCustom: false,
      ),

      // Standard shoulders (30 min)
      WorkoutTemplate(
        id: 'shoulders_standard_intermediate',
        name: 'Boulder Shoulders',
        description: 'Complete shoulder workout all heads',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'overhead_press',
            exerciseName: 'Overhead Press',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'lateral_raise',
            exerciseName: 'Lateral Raise',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'rear_delt_fly',
            exerciseName: 'Rear Delt Fly',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
            ],
          ),
        ],
        tags: ['shoulders', 'intermediate', 'strength'],
        estimatedDuration: 35,
        isCustom: false,
      ),

      // ===== ARMS WORKOUTS =====

      // Quick arms (15 min)
      WorkoutTemplate(
        id: 'arms_quick_beginner',
        name: 'Arm Express',
        description: 'Quick bicep and tricep pump',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'dumbbell_curl',
            exerciseName: 'Dumbbell Curl',
            category: ExerciseCategory.arms,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'tricep_pushdown',
            exerciseName: 'Tricep Pushdown',
            category: ExerciseCategory.arms,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['arms', 'beginner', 'quick'],
        estimatedDuration: 12,
        isCustom: false,
      ),

      // Standard arms (30 min)
      WorkoutTemplate(
        id: 'arms_standard_intermediate',
        name: 'Gun Show',
        description: 'Complete arm workout for peaks and horseshoes',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'barbell_curl',
            exerciseName: 'Barbell Curl',
            category: ExerciseCategory.arms,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'skull_crusher',
            exerciseName: 'Skull Crusher',
            category: ExerciseCategory.arms,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'hammer_curl',
            exerciseName: 'Hammer Curl',
            category: ExerciseCategory.arms,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'tricep_dip',
            exerciseName: 'Tricep Dip',
            category: ExerciseCategory.arms,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['arms', 'intermediate', 'hypertrophy'],
        estimatedDuration: 35,
        isCustom: false,
      ),

      // ===== ABS WORKOUTS =====

      // Quick abs (10 min)
      WorkoutTemplate(
        id: 'abs_quick_beginner',
        name: 'Core Express',
        description: 'Quick core circuit',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'plank',
            exerciseName: 'Plank',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 30),
              SetTemplate(setNumber: 2, targetReps: 30),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'crunches',
            exerciseName: 'Crunches',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 20),
              SetTemplate(setNumber: 2, targetReps: 20),
            ],
          ),
        ],
        tags: ['abs', 'beginner', 'quick'],
        estimatedDuration: 10,
        isCustom: false,
      ),

      // Standard abs (20 min)
      WorkoutTemplate(
        id: 'abs_standard_intermediate',
        name: 'Core Crusher',
        description: 'Complete core workout',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'hanging_leg_raise',
            exerciseName: 'Hanging Leg Raise',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'cable_crunch',
            exerciseName: 'Cable Crunch',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'russian_twist',
            exerciseName: 'Russian Twist',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 20),
              SetTemplate(setNumber: 2, targetReps: 20),
            ],
          ),
        ],
        tags: ['abs', 'intermediate', 'strength'],
        estimatedDuration: 20,
        isCustom: false,
      ),

      // ===== CARDIO / HIIT WORKOUTS =====

      // Quick HIIT (15 min)
      WorkoutTemplate(
        id: 'cardio_quick_beginner',
        name: 'HIIT Express',
        description: 'Quick high-intensity cardio',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'jumping_jacks',
            exerciseName: 'Jumping Jacks',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 30),
              SetTemplate(setNumber: 2, targetReps: 30),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'burpees',
            exerciseName: 'Burpees',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'mountain_climbers',
            exerciseName: 'Mountain Climbers',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 20),
              SetTemplate(setNumber: 2, targetReps: 20),
            ],
          ),
        ],
        tags: ['cardio', 'hiit', 'beginner', 'quick'],
        estimatedDuration: 15,
        isCustom: false,
      ),

      // Standard HIIT (30 min)
      WorkoutTemplate(
        id: 'cardio_standard_intermediate',
        name: 'HIIT Inferno',
        description: 'Intense cardio circuit for fat burn',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'burpees',
            exerciseName: 'Burpees',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 15),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'box_jumps',
            exerciseName: 'Box Jumps',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'kettlebell_swings',
            exerciseName: 'Kettlebell Swings',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 20),
              SetTemplate(setNumber: 2, targetReps: 20),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'battle_ropes',
            exerciseName: 'Battle Ropes',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 30),
              SetTemplate(setNumber: 2, targetReps: 30),
            ],
          ),
        ],
        tags: ['cardio', 'hiit', 'intermediate', 'fat_burn'],
        estimatedDuration: 30,
        isCustom: false,
      ),

      // ===== FULL BODY WORKOUTS =====

      // Quick full body (15 min)
      WorkoutTemplate(
        id: 'fullbody_quick_beginner',
        name: 'Total Body Express',
        description: 'Quick full body circuit',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'goblet_squat',
            exerciseName: 'Goblet Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'push_ups',
            exerciseName: 'Push Ups',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'dumbbell_row',
            exerciseName: 'Dumbbell Row',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 10),
            ],
          ),
        ],
        tags: ['fullbody', 'beginner', 'quick'],
        estimatedDuration: 15,
        isCustom: false,
      ),

      // Standard full body (45 min)
      WorkoutTemplate(
        id: 'fullbody_standard_intermediate',
        name: 'Total Body Strength',
        description: 'Complete full body workout',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'squat',
            exerciseName: 'Barbell Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'bench_press',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'barbell_row',
            exerciseName: 'Barbell Row',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'overhead_press',
            exerciseName: 'Overhead Press',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10),
              SetTemplate(setNumber: 2, targetReps: 8),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'plank',
            exerciseName: 'Plank',
            category: ExerciseCategory.abs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 60),
              SetTemplate(setNumber: 2, targetReps: 45),
            ],
          ),
        ],
        tags: ['fullbody', 'intermediate', 'strength'],
        estimatedDuration: 50,
        isCustom: false,
      ),

      // ===== FEMALE-FOCUSED WORKOUTS =====

      // Glutes focus (30 min)
      WorkoutTemplate(
        id: 'glutes_standard_female',
        name: 'Glute Builder',
        description: 'Targeted glute workout',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'hip_thrust',
            exerciseName: 'Hip Thrust',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
              SetTemplate(setNumber: 3, targetReps: 12),
              SetTemplate(setNumber: 4, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'romanian_deadlift',
            exerciseName: 'Romanian Deadlift',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 10),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'cable_kickback',
            exerciseName: 'Cable Kickback',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 12),
            ],
          ),
        ],
        tags: ['legs', 'glutes', 'female', 'intermediate'],
        estimatedDuration: 35,
        isCustom: false,
      ),
    ];
  }
}
