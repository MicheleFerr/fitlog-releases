import 'package:gymbro_flutter_new/features/smart_training/domain/entities/smart_workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/volume_range.dart';

/// Service for managing and generating smart workout templates
class SmartWorkoutTemplatesService {
  
  /// Get all predefined workout templates
  static List<SmartWorkoutTemplate> getAllTemplates() {
    return [
      // STRENGTH TEMPLATES
      ..._getStrengthTemplates(),
      
      // HYPERTROPHY TEMPLATES
      ..._getHypertrophyTemplates(),
      
      // POWERLIFTING TEMPLATES
      ..._getPowerliftingTemplates(),
      
      // BODYBUILDING TEMPLATES
      ..._getBodybuildingTemplates(),
      
      // FUNCTIONAL TEMPLATES
      ..._getFunctionalTemplates(),
      
      // BEGINNER TEMPLATES
      ..._getBeginnerTemplates(),
      
      // SPORT-SPECIFIC TEMPLATES
      ..._getSportTemplates(),
    ];
  }
  
  /// Filter templates by criteria
  static List<SmartWorkoutTemplate> filterTemplates({
    WorkoutCategory? category,
    DifficultyLevel? difficulty,
    TrainingStyle? style,
    int? maxDuration,
    List<String>? requiredTags,
    bool? premiumOnly,
  }) {
    var templates = getAllTemplates();
    
    if (category != null) {
      templates = templates.where((t) => t.category == category).toList();
    }
    
    if (difficulty != null) {
      templates = templates.where((t) => t.difficulty == difficulty).toList();
    }
    
    if (style != null) {
      templates = templates.where((t) => t.style == style).toList();
    }
    
    if (maxDuration != null) {
      templates = templates.where((t) => t.estimatedDuration <= maxDuration).toList();
    }
    
    if (requiredTags != null && requiredTags.isNotEmpty) {
      templates = templates.where((t) => 
        requiredTags.every((tag) => t.tags.contains(tag))
      ).toList();
    }
    
    if (premiumOnly == true) {
      templates = templates.where((t) => t.isPremium).toList();
    } else if (premiumOnly == false) {
      templates = templates.where((t) => !t.isPremium).toList();
    }
    
    return templates;
  }
  
  /// Get strength-focused templates
  static List<SmartWorkoutTemplate> _getStrengthTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'Starting Strength A',
        description: 'Classic novice strength program - Day A',
        category: WorkoutCategory.strength,
        difficulty: DifficultyLevel.beginner,
        style: TrainingStyle.powerlifting,
        estimatedDuration: 60,
        exercises: [
          TemplateExercise(
            name: 'Squat',
            category: ExerciseCategory.legs,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.beginner: SetParameters(
                  warmupSets: 2,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 5, optimal: 5, max: 5),
                  defaultWeight: 20.0,
                  restSeconds: 180,
                ),
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 3,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 5, optimal: 5, max: 5),
                  defaultWeight: 40.0,
                  restSeconds: 240,
                ),
              },
              intensityRange: const IntensityRange(min: 80, optimal: 85, max: 90),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 5),
            ),
            restTimeSeconds: 180,
            alternatives: ['Front Squat', 'Goblet Squat'],
            adaptiveParameters: {'progression_kg': 2.5},
            priority: 10,
          ),
          TemplateExercise(
            name: 'Bench Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.beginner: SetParameters(
                  warmupSets: 2,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 5, optimal: 5, max: 5),
                  defaultWeight: 20.0,
                  restSeconds: 180,
                ),
              },
              intensityRange: const IntensityRange(min: 80, optimal: 85, max: 90),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 5),
            ),
            restTimeSeconds: 180,
            alternatives: ['Dumbbell Press', 'Incline Press'],
            adaptiveParameters: {'progression_kg': 2.5},
            priority: 9,
          ),
          TemplateExercise(
            name: 'Deadlift',
            category: ExerciseCategory.back,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.beginner: SetParameters(
                  warmupSets: 2,
                  workingSets: 1,
                  repsRange: const RepsRange(min: 5, optimal: 5, max: 5),
                  defaultWeight: 40.0,
                  restSeconds: 240,
                ),
              },
              intensityRange: const IntensityRange(min: 85, optimal: 90, max: 95),
              volumeRange: const VolumeRange(min: 1, optimal: 1, max: 3),
            ),
            restTimeSeconds: 240,
            alternatives: ['Sumo Deadlift', 'Trap Bar Deadlift'],
            adaptiveParameters: {'progression_kg': 5.0},
            priority: 10,
          ),
        ],
        muscleGroupVolume: {
          'legs': 3,
          'chest': 3,
          'back': 1,
        },
        tags: ['strength', 'novice', 'compound'],
        isPremium: false,
        popularityScore: 95,
        averageRating: 4.8,
      ),
      
      SmartWorkoutTemplate(
        name: '5/3/1 Bench Focus',
        description: 'Jim Wendler\'s 5/3/1 program focused on bench press',
        category: WorkoutCategory.strength,
        difficulty: DifficultyLevel.intermediate,
        style: TrainingStyle.powerlifting,
        estimatedDuration: 75,
        exercises: [
          TemplateExercise(
            name: 'Bench Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.pyramid,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 3,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 3, optimal: 5, max: 8),
                  defaultWeight: 60.0,
                  restSeconds: 180,
                ),
              },
              intensityRange: const IntensityRange(min: 65, optimal: 85, max: 95),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 5),
            ),
            restTimeSeconds: 180,
            alternatives: ['Close Grip Bench', 'Incline Bench'],
            adaptiveParameters: {'wave_progression': true},
            priority: 10,
          ),
          TemplateExercise(
            name: 'Overhead Press',
            category: ExerciseCategory.shoulders,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 2,
                  workingSets: 5,
                  repsRange: const RepsRange(min: 5, optimal: 8, max: 10),
                  defaultWeight: 30.0,
                  restSeconds: 120,
                ),
              },
              intensityRange: const IntensityRange(min: 65, optimal: 75, max: 80),
              volumeRange: const VolumeRange(min: 5, optimal: 5, max: 8),
            ),
            restTimeSeconds: 120,
            alternatives: ['Dumbbell Press', 'Push Press'],
            adaptiveParameters: {},
            priority: 8,
          ),
        ],
        muscleGroupVolume: {
          'chest': 3,
          'shoulders': 5,
          'arms': 3,
        },
        tags: ['531', 'intermediate', 'bench'],
        isPremium: true,
        popularityScore: 88,
        averageRating: 4.6,
      ),
    ];
  }
  
  /// Get hypertrophy-focused templates
  static List<SmartWorkoutTemplate> _getHypertrophyTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'Push Day',
        description: 'Upper body push muscles - chest, shoulders, triceps',
        category: WorkoutCategory.push,
        difficulty: DifficultyLevel.intermediate,
        style: TrainingStyle.bodybuilding,
        estimatedDuration: 70,
        exercises: [
          TemplateExercise(
            name: 'Bench Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 2,
                  workingSets: 4,
                  repsRange: const RepsRange(min: 6, optimal: 8, max: 10),
                  defaultWeight: 60.0,
                  restSeconds: 120,
                ),
              },
              intensityRange: const IntensityRange(min: 70, optimal: 80, max: 85),
              volumeRange: const VolumeRange(min: 4, optimal: 4, max: 6),
            ),
            restTimeSeconds: 120,
            alternatives: ['Dumbbell Press', 'Incline Press'],
            adaptiveParameters: {},
            priority: 10,
          ),
          TemplateExercise(
            name: 'Overhead Press',
            category: ExerciseCategory.shoulders,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 1,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 8, optimal: 10, max: 12),
                  defaultWeight: 30.0,
                  restSeconds: 90,
                ),
              },
              intensityRange: const IntensityRange(min: 65, optimal: 75, max: 80),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 4),
            ),
            restTimeSeconds: 90,
            alternatives: ['Dumbbell Press', 'Machine Press'],
            adaptiveParameters: {},
            priority: 9,
          ),
          TemplateExercise(
            name: 'Lateral Raises',
            category: ExerciseCategory.shoulders,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 0,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 12, optimal: 15, max: 20),
                  defaultWeight: 5.0,
                  restSeconds: 60,
                ),
              },
              intensityRange: const IntensityRange(min: 60, optimal: 70, max: 75),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 4),
            ),
            restTimeSeconds: 60,
            alternatives: ['Cable Lateral Raises', 'Machine Lateral Raises'],
            adaptiveParameters: {},
            priority: 7,
          ),
          TemplateExercise(
            name: 'Tricep Dips',
            category: ExerciseCategory.arms,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 0,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 8, optimal: 12, max: 15),
                  defaultWeight: 0.0,
                  restSeconds: 75,
                ),
              },
              intensityRange: const IntensityRange(min: 65, optimal: 75, max: 80),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 4),
            ),
            restTimeSeconds: 75,
            alternatives: ['Close Grip Bench', 'Tricep Pushdown'],
            adaptiveParameters: {},
            priority: 6,
          ),
        ],
        muscleGroupVolume: {
          'chest': 4,
          'shoulders': 6,
          'arms': 3,
        },
        tags: ['push', 'hypertrophy', 'volume'],
        isPremium: false,
        popularityScore: 92,
        averageRating: 4.7,
      ),
      
      SmartWorkoutTemplate(
        name: 'Pull Day',
        description: 'Upper body pull muscles - back, biceps, rear delts',
        category: WorkoutCategory.pull,
        difficulty: DifficultyLevel.intermediate,
        style: TrainingStyle.bodybuilding,
        estimatedDuration: 65,
        exercises: [
          TemplateExercise(
            name: 'Pull-ups',
            category: ExerciseCategory.back,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 1,
                  workingSets: 4,
                  repsRange: const RepsRange(min: 5, optimal: 8, max: 12),
                  defaultWeight: 0.0,
                  restSeconds: 120,
                ),
              },
              intensityRange: const IntensityRange(min: 70, optimal: 80, max: 85),
              volumeRange: const VolumeRange(min: 4, optimal: 4, max: 6),
            ),
            restTimeSeconds: 120,
            alternatives: ['Lat Pulldown', 'Assisted Pull-ups'],
            adaptiveParameters: {},
            priority: 10,
          ),
          TemplateExercise(
            name: 'Barbell Rows',
            category: ExerciseCategory.back,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 2,
                  workingSets: 4,
                  repsRange: const RepsRange(min: 6, optimal: 8, max: 10),
                  defaultWeight: 40.0,
                  restSeconds: 120,
                ),
              },
              intensityRange: const IntensityRange(min: 70, optimal: 80, max: 85),
              volumeRange: const VolumeRange(min: 4, optimal: 4, max: 6),
            ),
            restTimeSeconds: 120,
            alternatives: ['T-Bar Row', 'Dumbbell Rows'],
            adaptiveParameters: {},
            priority: 9,
          ),
        ],
        muscleGroupVolume: {
          'back': 8,
          'arms': 4,
        },
        tags: ['pull', 'hypertrophy', 'back'],
        isPremium: false,
        popularityScore: 89,
        averageRating: 4.6,
      ),
    ];
  }
  
  /// Get powerlifting templates
  static List<SmartWorkoutTemplate> _getPowerliftingTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'Smolov Jr Bench',
        description: 'High-frequency bench press specialization program',
        category: WorkoutCategory.strength,
        difficulty: DifficultyLevel.advanced,
        style: TrainingStyle.powerlifting,
        estimatedDuration: 45,
        exercises: [
          TemplateExercise(
            name: 'Bench Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.advanced: SetParameters(
                  warmupSets: 3,
                  workingSets: 6,
                  repsRange: const RepsRange(min: 6, optimal: 6, max: 6),
                  defaultWeight: 80.0,
                  restSeconds: 180,
                ),
              },
              intensityRange: const IntensityRange(min: 80, optimal: 85, max: 90),
              volumeRange: const VolumeRange(min: 6, optimal: 6, max: 10),
            ),
            restTimeSeconds: 180,
            alternatives: ['Close Grip Bench'],
            adaptiveParameters: {'weekly_progression': 2.5},
            priority: 10,
          ),
        ],
        muscleGroupVolume: {
          'chest': 6,
          'arms': 6,
          'shoulders': 3,
        },
        tags: ['smolov', 'bench', 'intensity'],
        isPremium: true,
        popularityScore: 75,
        averageRating: 4.3,
      ),
    ];
  }
  
  /// Get bodybuilding templates
  static List<SmartWorkoutTemplate> _getBodybuildingTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'German Volume Training',
        description: '10x10 high-volume muscle building protocol',
        category: WorkoutCategory.hypertrophy,
        difficulty: DifficultyLevel.advanced,
        style: TrainingStyle.bodybuilding,
        estimatedDuration: 90,
        exercises: [
          TemplateExercise(
            name: 'Incline Dumbbell Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.advanced: SetParameters(
                  warmupSets: 2,
                  workingSets: 10,
                  repsRange: const RepsRange(min: 10, optimal: 10, max: 10),
                  defaultWeight: 25.0,
                  restSeconds: 90,
                ),
              },
              intensityRange: const IntensityRange(min: 60, optimal: 65, max: 70),
              volumeRange: const VolumeRange(min: 10, optimal: 10, max: 10),
            ),
            restTimeSeconds: 90,
            alternatives: ['Barbell Incline Press'],
            adaptiveParameters: {'tempo': '4-1-2-1'},
            priority: 10,
          ),
          TemplateExercise(
            name: 'Dumbbell Flyes',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.advanced: SetParameters(
                  warmupSets: 1,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 10, optimal: 12, max: 15),
                  defaultWeight: 12.0,
                  restSeconds: 60,
                ),
              },
              intensityRange: const IntensityRange(min: 60, optimal: 70, max: 75),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 4),
            ),
            restTimeSeconds: 60,
            alternatives: ['Cable Flyes', 'Pec Deck'],
            adaptiveParameters: {},
            priority: 7,
          ),
        ],
        muscleGroupVolume: {
          'chest': 13,
        },
        tags: ['GVT', 'volume', 'hypertrophy'],
        isPremium: true,
        popularityScore: 68,
        averageRating: 4.1,
      ),
    ];
  }
  
  /// Get functional training templates
  static List<SmartWorkoutTemplate> _getFunctionalTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'Movement Prep',
        description: 'Dynamic warm-up and movement preparation',
        category: WorkoutCategory.functional,
        difficulty: DifficultyLevel.beginner,
        style: TrainingStyle.functional,
        estimatedDuration: 20,
        exercises: [
          TemplateExercise(
            name: 'Bodyweight Squats',
            category: ExerciseCategory.legs,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.beginner: SetParameters(
                  warmupSets: 0,
                  workingSets: 2,
                  repsRange: const RepsRange(min: 10, optimal: 15, max: 20),
                  defaultWeight: 0.0,
                  restSeconds: 30,
                ),
              },
              intensityRange: const IntensityRange(min: 50, optimal: 60, max: 70),
              volumeRange: const VolumeRange(min: 2, optimal: 2, max: 3),
            ),
            restTimeSeconds: 30,
            alternatives: ['Box Squats', 'Wall Squats'],
            adaptiveParameters: {},
            priority: 8,
          ),
        ],
        muscleGroupVolume: {
          'legs': 2,
        },
        tags: ['warmup', 'mobility', 'functional'],
        isPremium: false,
        popularityScore: 85,
        averageRating: 4.4,
      ),
    ];
  }
  
  /// Get beginner-friendly templates
  static List<SmartWorkoutTemplate> _getBeginnerTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'Beginner Full Body',
        description: 'Complete body workout for training novices',
        category: WorkoutCategory.fullBody,
        difficulty: DifficultyLevel.beginner,
        style: TrainingStyle.functional,
        estimatedDuration: 45,
        exercises: [
          TemplateExercise(
            name: 'Goblet Squats',
            category: ExerciseCategory.legs,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.beginner: SetParameters(
                  warmupSets: 1,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 8, optimal: 12, max: 15),
                  defaultWeight: 8.0,
                  restSeconds: 60,
                ),
              },
              intensityRange: const IntensityRange(min: 60, optimal: 70, max: 75),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 4),
            ),
            restTimeSeconds: 60,
            alternatives: ['Bodyweight Squats', 'Box Squats'],
            adaptiveParameters: {},
            priority: 9,
          ),
          TemplateExercise(
            name: 'Push-ups',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.beginner: SetParameters(
                  warmupSets: 0,
                  workingSets: 3,
                  repsRange: const RepsRange(min: 5, optimal: 10, max: 15),
                  defaultWeight: 0.0,
                  restSeconds: 60,
                ),
              },
              intensityRange: const IntensityRange(min: 60, optimal: 70, max: 75),
              volumeRange: const VolumeRange(min: 3, optimal: 3, max: 4),
            ),
            restTimeSeconds: 60,
            alternatives: ['Incline Push-ups', 'Knee Push-ups'],
            adaptiveParameters: {},
            priority: 8,
          ),
        ],
        muscleGroupVolume: {
          'legs': 3,
          'chest': 3,
          'arms': 3,
        },
        tags: ['beginner', 'fullbody', 'bodyweight'],
        isPremium: false,
        popularityScore: 94,
        averageRating: 4.8,
      ),
    ];
  }
  
  /// Get sport-specific templates
  static List<SmartWorkoutTemplate> _getSportTemplates() {
    return [
      SmartWorkoutTemplate(
        name: 'Athletic Power',
        description: 'Power development for sports performance',
        category: WorkoutCategory.sport,
        difficulty: DifficultyLevel.intermediate,
        style: TrainingStyle.sport,
        estimatedDuration: 60,
        exercises: [
          TemplateExercise(
            name: 'Jump Squats',
            category: ExerciseCategory.legs,
            type: ExerciseType.single,
            setTemplate: SetTemplate(
              progressionType: SetProgressionType.straight,
              experienceParameters: {
                TrainingExperience.intermediate: SetParameters(
                  warmupSets: 1,
                  workingSets: 5,
                  repsRange: const RepsRange(min: 3, optimal: 5, max: 8),
                  defaultWeight: 0.0,
                  restSeconds: 120,
                ),
              },
              intensityRange: const IntensityRange(min: 70, optimal: 80, max: 90),
              volumeRange: const VolumeRange(min: 5, optimal: 5, max: 6),
            ),
            restTimeSeconds: 120,
            alternatives: ['Box Jumps', 'Weighted Jump Squats'],
            adaptiveParameters: {'explosive': true},
            priority: 10,
          ),
        ],
        muscleGroupVolume: {
          'legs': 5,
        },
        tags: ['power', 'athletic', 'explosive'],
        isPremium: true,
        popularityScore: 72,
        averageRating: 4.2,
      ),
    ];
  }
  
  /// Search templates by name or description
  static List<SmartWorkoutTemplate> searchTemplates(String query) {
    final allTemplates = getAllTemplates();
    final lowerQuery = query.toLowerCase();
    
    return allTemplates.where((template) =>
      template.name.toLowerCase().contains(lowerQuery) ||
      template.description.toLowerCase().contains(lowerQuery) ||
      template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }
  
  /// Get recommended templates based on user preferences
  static List<SmartWorkoutTemplate> getRecommendedTemplates({
    required TrainingExperience experience,
    required List<String> goals,
    required int availableTime,
    List<String>? preferredStyles,
  }) {
    var templates = getAllTemplates();
    
    // Filter by experience level
    templates = templates.where((t) => 
      _isAppropriateForExperience(t.difficulty, experience)
    ).toList();
    
    // Filter by time constraints
    templates = templates.where((t) => 
      t.estimatedDuration <= availableTime + 10 // 10 min buffer
    ).toList();
    
    // Score templates based on goals and preferences
    templates.sort((a, b) {
      final scoreA = _calculateRecommendationScore(a, goals, preferredStyles);
      final scoreB = _calculateRecommendationScore(b, goals, preferredStyles);
      return scoreB.compareTo(scoreA);
    });
    
    return templates.take(6).toList();
  }
  
  /// Check if difficulty is appropriate for experience
  static bool _isAppropriateForExperience(
    DifficultyLevel difficulty,
    TrainingExperience experience
  ) {
    switch (experience) {
      case TrainingExperience.beginner:
        return difficulty == DifficultyLevel.beginner;
      case TrainingExperience.intermediate:
        return difficulty == DifficultyLevel.beginner || 
               difficulty == DifficultyLevel.intermediate;
      case TrainingExperience.advanced:
        return difficulty != DifficultyLevel.expert;
      case TrainingExperience.expert:
        return true;
    }
  }
  
  /// Calculate recommendation score for template
  static double _calculateRecommendationScore(
    SmartWorkoutTemplate template,
    List<String> goals,
    List<String>? preferredStyles,
  ) {
    double score = 0.0;
    
    // Base score from popularity and rating
    score += template.popularityScore * 0.01;
    score += template.averageRating * 2;
    
    // Goal alignment
    for (final goal in goals) {
      if (template.tags.contains(goal.toLowerCase()) ||
          template.category.name.contains(goal.toLowerCase()) ||
          template.style.name.contains(goal.toLowerCase())) {
        score += 5.0;
      }
    }
    
    // Style preferences
    if (preferredStyles != null) {
      for (final style in preferredStyles) {
        if (template.style.name.contains(style.toLowerCase()) ||
            template.tags.contains(style.toLowerCase())) {
          score += 3.0;
        }
      }
    }
    
    return score;
  }
}