import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/volume_range.dart';

/// Smart workout template with adaptive parameters
class SmartWorkoutTemplate {

  SmartWorkoutTemplate({
    String? id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.style,
    required this.estimatedDuration,
    required this.exercises,
    required this.muscleGroupVolume,
    required this.tags,
    this.imageUrl,
    this.isPremium = false,
    this.popularityScore = 0,
    this.averageRating = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory SmartWorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return SmartWorkoutTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: WorkoutCategory.values.firstWhere((c) => c.name == json['category']),
      difficulty: DifficultyLevel.values.firstWhere((d) => d.name == json['difficulty']),
      style: TrainingStyle.values.firstWhere((s) => s.name == json['style']),
      estimatedDuration: json['estimatedDuration'],
      exercises: (json['exercises'] as List)
          .map((e) => TemplateExercise.fromJson(e))
          .toList(),
      muscleGroupVolume: Map<String, int>.from(json['muscleGroupVolume']),
      tags: List<String>.from(json['tags']),
      imageUrl: json['imageUrl'],
      isPremium: json['isPremium'] ?? false,
      popularityScore: json['popularityScore'] ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  final String id;
  final String name;
  final String description;
  final WorkoutCategory category;
  final DifficultyLevel difficulty;
  final TrainingStyle style;
  final int estimatedDuration; // minutes
  final List<TemplateExercise> exercises;
  final Map<String, int> muscleGroupVolume; // sets per muscle group
  final List<String> tags;
  final String? imageUrl;
  final bool isPremium;
  final int popularityScore;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Generate actual workout from template with user adaptations
  Workout generateWorkout({
    required String userId,
    TrainingExperience? experience,
    Map<String, double>? personalBests,
    int? availableTime,
  }) {
    final adaptedExercises = exercises.map((templateEx) =>
      templateEx.generateExercise(
        experience: experience ?? TrainingExperience.intermediate,
        personalBest: personalBests?[templateEx.name],
        timeConstraint: availableTime,
      )
    ).toList();

    final now = DateTime.now();
    return Workout(
      id: const Uuid().v4(),
      name: name,
      exercises: adaptedExercises,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'style': style.name,
      'estimatedDuration': estimatedDuration,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'muscleGroupVolume': muscleGroupVolume,
      'tags': tags,
      'imageUrl': imageUrl,
      'isPremium': isPremium,
      'popularityScore': popularityScore,
      'averageRating': averageRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Template exercise with adaptive parameters
class TemplateExercise { // 1-10, higher = more important

  TemplateExercise({
    required this.name,
    required this.category,
    required this.type,
    required this.setTemplate,
    this.restTimeSeconds,
    required this.alternatives,
    required this.adaptiveParameters,
    this.notes,
    this.isOptional = false,
    this.priority = 5,
  });

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      name: json['name'],
      category: ExerciseCategory.values.firstWhere((c) => c.name == json['category']),
      type: ExerciseType.values.firstWhere((t) => t.name == json['type']),
      setTemplate: SetTemplate.fromJson(json['setTemplate']),
      restTimeSeconds: json['restTimeSeconds'],
      alternatives: List<String>.from(json['alternatives']),
      adaptiveParameters: Map<String, dynamic>.from(json['adaptiveParameters']),
      notes: json['notes'],
      isOptional: json['isOptional'] ?? false,
      priority: json['priority'] ?? 5,
    );
  }
  final String name;
  final ExerciseCategory category;
  final ExerciseType type;
  final SetTemplate setTemplate;
  final int? restTimeSeconds;
  final List<String> alternatives; // Alternative exercises
  final Map<String, dynamic> adaptiveParameters;
  final String? notes;
  final bool isOptional;
  final int priority;

  /// Generate actual exercise from template
  Exercise generateExercise({
    required TrainingExperience experience,
    double? personalBest,
    int? timeConstraint,
  }) {
    final adaptedSets = setTemplate.generateSets(
      experience: experience,
      personalBest: personalBest,
      timeConstraint: timeConstraint,
    );

    return Exercise(
      name: name,
      type: type,
      category: category,
      sets: adaptedSets,
      restTime: restTimeSeconds,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name,
      'type': type.name,
      'setTemplate': setTemplate.toJson(),
      'restTimeSeconds': restTimeSeconds,
      'alternatives': alternatives,
      'adaptiveParameters': adaptiveParameters,
      'notes': notes,
      'isOptional': isOptional,
      'priority': priority,
    };
  }
}

/// Template for generating sets
class SetTemplate {

  SetTemplate({
    required this.progressionType,
    required this.experienceParameters,
    required this.intensityRange,
    required this.volumeRange,
  });

  factory SetTemplate.fromJson(Map<String, dynamic> json) {
    return SetTemplate(
      progressionType: SetProgressionType.values.firstWhere(
        (p) => p.name == json['progressionType']
      ),
      experienceParameters: (json['experienceParameters'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(
            TrainingExperience.values.firstWhere((e) => e.name == k),
            SetParameters.fromJson(v)
          )),
      intensityRange: IntensityRange.fromJson(json['intensityRange']),
      volumeRange: VolumeRange.fromJson(json['volumeRange']),
    );
  }
  final SetProgressionType progressionType;
  final Map<TrainingExperience, SetParameters> experienceParameters;
  final IntensityRange intensityRange;
  final VolumeRange volumeRange;

  /// Generate actual sets based on parameters
  List<ExerciseSet> generateSets({
    required TrainingExperience experience,
    double? personalBest,
    int? timeConstraint,
  }) {
    final params = experienceParameters[experience] ?? 
                   experienceParameters[TrainingExperience.intermediate]!;
    
    final sets = <ExerciseSet>[];
    
    // Generate warmup sets if needed
    if (params.warmupSets > 0) {
      sets.addAll(_generateWarmupSets(params, personalBest));
    }
    
    // Generate working sets
    sets.addAll(_generateWorkingSets(params, personalBest, timeConstraint));
    
    return sets;
  }

  List<ExerciseSet> _generateWarmupSets(SetParameters params, double? personalBest) {
    final sets = <ExerciseSet>[];
    final workingWeight = _calculateWorkingWeight(params, personalBest);
    
    for (int i = 0; i < params.warmupSets; i++) {
      final warmupIntensity = 0.5 + (i * 0.1); // 50%, 60%, 70%
      final weight = workingWeight * warmupIntensity;
      
      sets.add(ExerciseSet(
        setNumber: i + 1,
        weight: weight,
        reps: params.repsRange.min + 2, // Higher reps for warmup
        isWarmup: true,
      ));
    }
    
    return sets;
  }

  List<ExerciseSet> _generateWorkingSets(
    SetParameters params,
    double? personalBest,
    int? timeConstraint,
  ) {
    final sets = <ExerciseSet>[];
    final workingWeight = _calculateWorkingWeight(params, personalBest);
    
    int targetSets = params.workingSets;
    
    // Adjust for time constraint
    if (timeConstraint != null && timeConstraint < 60) {
      targetSets = (targetSets * 0.8).round().clamp(1, targetSets);
    }
    
    for (int i = 0; i < targetSets; i++) {
      final setNumber = params.warmupSets + i + 1;
      
      // Progressive overload within session
      double setWeight = workingWeight;
      int setReps = params.repsRange.optimal;
      
      switch (progressionType) {
        case SetProgressionType.straight:
          // Same weight/reps all sets
          break;
        case SetProgressionType.pyramid:
          // Increase weight, decrease reps
          setWeight *= (1.0 + i * 0.05);
          setReps = (setReps - i).clamp(params.repsRange.min, params.repsRange.max);
          break;
        case SetProgressionType.reverse:
          // Decrease weight, increase reps
          setWeight *= (1.0 - i * 0.05);
          setReps = (setReps + i).clamp(params.repsRange.min, params.repsRange.max);
          break;
        case SetProgressionType.cluster:
          // Higher total reps with mini-rests
          setReps = (setReps * 1.5).round();
          break;
      }
      
      sets.add(ExerciseSet(
        setNumber: setNumber,
        weight: setWeight,
        reps: setReps,
        isWarmup: false,
      ));
    }
    
    return sets;
  }

  double _calculateWorkingWeight(SetParameters params, double? personalBest) {
    if (personalBest == null) {
      // Default weight estimation
      return params.defaultWeight;
    }
    
    // Calculate weight based on intensity and reps
    final targetIntensity = intensityRange.optimal / 100.0;
    return personalBest * targetIntensity;
  }

  Map<String, dynamic> toJson() {
    return {
      'progressionType': progressionType.name,
      'experienceParameters': experienceParameters.map(
        (k, v) => MapEntry(k.name, v.toJson())
      ),
      'intensityRange': intensityRange.toJson(),
      'volumeRange': volumeRange.toJson(),
    };
  }
}

/// Parameters for generating sets at different experience levels
class SetParameters {

  SetParameters({
    required this.warmupSets,
    required this.workingSets,
    required this.repsRange,
    required this.defaultWeight,
    required this.restSeconds,
  });

  factory SetParameters.fromJson(Map<String, dynamic> json) {
    return SetParameters(
      warmupSets: json['warmupSets'],
      workingSets: json['workingSets'],
      repsRange: RepsRange.fromJson(json['repsRange']),
      defaultWeight: (json['defaultWeight'] as num).toDouble(),
      restSeconds: json['restSeconds'],
    );
  }
  final int warmupSets;
  final int workingSets;
  final RepsRange repsRange;
  final double defaultWeight;
  final int restSeconds;

  Map<String, dynamic> toJson() {
    return {
      'warmupSets': warmupSets,
      'workingSets': workingSets,
      'repsRange': repsRange.toJson(),
      'defaultWeight': defaultWeight,
      'restSeconds': restSeconds,
    };
  }
}

/// Range classes
class RepsRange {

  const RepsRange({required this.min, required this.optimal, required this.max});

  factory RepsRange.fromJson(Map<String, dynamic> json) {
    return RepsRange(
      min: json['min'],
      optimal: json['optimal'],
      max: json['max'],
    );
  }
  final int min;
  final int optimal;
  final int max;

  Map<String, dynamic> toJson() => {'min': min, 'optimal': optimal, 'max': max};
}

class IntensityRange {

  const IntensityRange({required this.min, required this.optimal, required this.max});

  factory IntensityRange.fromJson(Map<String, dynamic> json) {
    return IntensityRange(
      min: (json['min'] as num).toDouble(),
      optimal: (json['optimal'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
  final double min;
  final double optimal;
  final double max;

  Map<String, dynamic> toJson() => {'min': min, 'optimal': optimal, 'max': max};
}

/// Enums
enum WorkoutCategory {
  push,
  pull,
  legs,
  upperBody,
  lowerBody,
  fullBody,
  strength,
  hypertrophy,
  endurance,
  powerlifting,
  bodybuilding,
  functional,
  rehabilitation,
  sport,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum TrainingStyle {
  powerlifting,
  bodybuilding,
  olympic,
  crossfit,
  calisthenics,
  strongman,
  powerbuilding,
  functional,
  rehabilitation,
  sport,
}

enum TrainingExperience {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum SetProgressionType {
  straight,
  pyramid,
  reverse,
  cluster,
}