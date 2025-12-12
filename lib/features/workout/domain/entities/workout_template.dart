import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Template per workout riutilizzabili
class WorkoutTemplate { // 3, 6, o 10

  WorkoutTemplate({
    String? id,
    required this.name,
    required this.description,
    this.imageUrl,
    List<ExerciseTemplate>? exercises,
    this.estimatedDuration = 45,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCustom = true,
    this.usageCount = 0,
    this.isPublic = false,
    this.userId,
    this.authorName,
    this.downloadCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.difficulty,
    this.defaultAutoAdjustmentType,
    this.defaultApreProtocol,
  })  : id = id ?? const Uuid().v4(),
        exercises = exercises ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    // Parse exercises with enhanced error handling
    final List<ExerciseTemplate> exercises = [];
    if (json['exercises'] != null) {
      if (json['exercises'] is List) {
        final exercisesList = json['exercises'] as List;
        
        for (int i = 0; i < exercisesList.length; i++) {
          try {
            final exerciseJson = exercisesList[i];
            if (exerciseJson is Map<String, dynamic>) {
              final exerciseTemplate = ExerciseTemplate.fromJson(exerciseJson);
              exercises.add(exerciseTemplate);
            }
          } catch (e) {
          }
        }
      } else {
      }
    }
    

    // Parse auto-adjustment type
    AutoAdjustmentType? defaultAutoAdjustmentType;
    if (json['defaultAutoAdjustmentType'] != null) {
      try {
        defaultAutoAdjustmentType = AutoAdjustmentType.values.firstWhere(
          (e) => e.name == json['defaultAutoAdjustmentType'],
        );
      } catch (e) {
        defaultAutoAdjustmentType = null;
      }
    }

    return WorkoutTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      exercises: exercises,
      estimatedDuration: json['estimatedDuration'] is int ? json['estimatedDuration'] : 45,
      tags: json['tags'] is List ? List<String>.from(json['tags'].map((t) => t.toString())) : [],
      createdAt: json['createdAt'] is String ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] is String ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      isCustom: json['isCustom'] is bool ? json['isCustom'] : true,
      usageCount: json['usageCount'] is int ? json['usageCount'] : 0,
      isPublic: json['isPublic'] is bool ? json['isPublic'] : false,
      userId: json['userId']?.toString(),
      authorName: json['authorName']?.toString(),
      downloadCount: json['downloadCount'] is int ? json['downloadCount'] : 0,
      averageRating: json['averageRating'] is num ? json['averageRating'].toDouble() : 0.0,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] : 0,
      difficulty: json['difficulty']?.toString(),
      defaultAutoAdjustmentType: defaultAutoAdjustmentType,
      defaultApreProtocol: json['defaultApreProtocol'] is int ? json['defaultApreProtocol'] : null,
    );
  }
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<ExerciseTemplate> exercises;
  final int estimatedDuration; // in minutes
  final List<String> tags; // es: ["upper", "strength", "beginner"]
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCustom; // true se creato dall'utente, false se predefinito
  final int usageCount; // quante volte è stato utilizzato
  
  // Campi per condivisione pubblica
  final bool isPublic; // true se condiviso pubblicamente
  final String? userId; // ID dell'utente creatore
  final String? authorName; // Nome dell'autore per template pubblici
  final int downloadCount; // Numero di download (per template pubblici)
  final double averageRating; // Rating medio (1-5)
  final int reviewCount; // Numero di recensioni
  final String? difficulty; // beginner, intermediate, advanced, expert

  // Auto-regolazione predefinita
  final AutoAdjustmentType? defaultAutoAdjustmentType; // APRE o RPE
  final int? defaultApreProtocol;

  WorkoutTemplate copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<ExerciseTemplate>? exercises,
    int? estimatedDuration,
    List<String>? tags,
    DateTime? updatedAt,
    bool? isCustom,
    int? usageCount,
    bool? isPublic,
    String? userId,
    String? authorName,
    int? downloadCount,
    double? averageRating,
    int? reviewCount,
    String? difficulty,
    AutoAdjustmentType? defaultAutoAdjustmentType,
    int? defaultApreProtocol,
  }) {
    return WorkoutTemplate(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      exercises: exercises ?? this.exercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isCustom: isCustom ?? this.isCustom,
      usageCount: usageCount ?? this.usageCount,
      isPublic: isPublic ?? this.isPublic,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      downloadCount: downloadCount ?? this.downloadCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      difficulty: difficulty ?? this.difficulty,
      defaultAutoAdjustmentType: defaultAutoAdjustmentType ?? this.defaultAutoAdjustmentType,
      defaultApreProtocol: defaultApreProtocol ?? this.defaultApreProtocol,
    );
  }

  /// Incrementa il contatore di utilizzo
  WorkoutTemplate incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedDuration': estimatedDuration,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCustom': isCustom,
      'usageCount': usageCount,
      'isPublic': isPublic,
      'userId': userId,
      'authorName': authorName,
      'downloadCount': downloadCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'difficulty': difficulty,
      'defaultAutoAdjustmentType': defaultAutoAdjustmentType?.name,
      'defaultApreProtocol': defaultApreProtocol,
    };
  }

  /// Crea un workout dal template
  List<Exercise> toWorkoutExercises() {
    return exercises.map((template) => template.toWorkoutExercise()).toList();
  }
}

/// Template per esercizio all'interno di un workout template
class ExerciseTemplate { // For superset, dropset, etc.

  const ExerciseTemplate({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    this.type = ExerciseType.single,
    List<SetTemplate>? sets,
    this.notes,
    this.restTime,
    this.subExercises,
  }) : sets = sets ?? const [];

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    // FIX: Support both old format ('id', 'name') and new format ('exerciseId', 'exerciseName')
    // for backward compatibility with templates saved via Cloud Function
    final exerciseId = json['exerciseId']?.toString() ?? json['id']?.toString() ?? '';
    final exerciseName = json['exerciseName']?.toString() ?? json['name']?.toString() ?? '';

    // Validate required fields (after fallback)
    if (exerciseId.isEmpty) {
      // Silent - will use empty string
    }
    if (exerciseName.isEmpty) {
      // Silent - will use empty string
    }
    
    // Parse category with better error handling
    ExerciseCategory category;
    try {
      category = ExerciseCategory.values.firstWhere(
        (e) => e.name == json['category'],
      );
    } catch (e) {
      category = ExerciseCategory.other;
    }
    
    // Parse type with better error handling
    ExerciseType type;
    try {
      type = ExerciseType.values.firstWhere(
        (e) => e.name == json['type'],
      );
    } catch (e) {
      type = ExerciseType.single;
    }
    
    // Parse sets with validation
    List<SetTemplate> sets = [];
    if (json['sets'] != null) {
      try {
        sets = (json['sets'] as List)
            .map((s) => SetTemplate.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (e) {
        sets = [];
      }
    }

    // ✅ FIX: For supersets, also check supersetSets to determine round count
    // If sets is empty but supersetSets exists, create sets from supersetSets
    if (sets.isEmpty && type == ExerciseType.superset && json['supersetSets'] != null) {
      try {
        final supersetSetsJson = json['supersetSets'] as List;
        sets = supersetSetsJson.asMap().entries.map((entry) {
          final index = entry.key;
          final roundJson = entry.value as Map<String, dynamic>;

          // Try to extract target values from exerciseData if available
          double? targetWeight;
          int? targetReps;

          if (roundJson['exerciseData'] != null) {
            final exerciseDataMap = roundJson['exerciseData'] as Map;
            if (exerciseDataMap.isNotEmpty) {
              final firstExerciseData = exerciseDataMap.values.first;
              if (firstExerciseData is Map) {
                targetWeight = (firstExerciseData['targetWeight'] as num?)?.toDouble();
                targetReps = firstExerciseData['targetReps'] as int?;
              }
            }
          }

          return SetTemplate(
            setNumber: roundJson['setNumber'] as int? ?? index + 1,
            targetWeight: targetWeight,
            targetReps: targetReps,
          );
        }).toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing supersetSets: $e');
        }
      }
    }

    // Parse sub-exercises for superset/dropset
    List<ExerciseTemplate>? subExercises;
    if (json['exercises'] != null && json['exercises'] is List) {
      try {
        subExercises = (json['exercises'] as List)
            .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing sub-exercises: $e');
        }
        subExercises = null;
      }
    }
    
    final exerciseTemplate = ExerciseTemplate(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      category: category,
      type: type,
      sets: sets,
      notes: json['notes']?.toString(),
      // FIX: Firebase may return restTime as double, use num to handle both int and double
      restTime: json['restTime'] is num ? (json['restTime'] as num).toInt() : null,
      subExercises: subExercises,
    );
    
    return exerciseTemplate;
  }

  /// ✅ FIX: Factory method to create ExerciseTemplate from Exercise
  /// Properly handles SupersetExercise by extracting supersetSets and child exercises
  factory ExerciseTemplate.fromExercise(Exercise exercise) {
    // Handle SupersetExercise specially
    if (exercise is SupersetExercise) {
      // Create sets from supersetSets (one per round)
      final sets = exercise.supersetSets.asMap().entries.map((entry) {
        final index = entry.key;
        final supersetSet = entry.value;

        // Get target values from first exercise in round
        double? targetWeight;
        int? targetReps;
        if (supersetSet.exerciseData.isNotEmpty) {
          final firstData = supersetSet.exerciseData.values.first;
          targetWeight = firstData.targetWeight;
          targetReps = firstData.targetReps;
        }

        return SetTemplate(
          setNumber: index + 1,
          targetWeight: targetWeight,
          targetReps: targetReps,
        );
      }).toList();

      // Create subExercises from the child exercises
      final subExercises = exercise.exercises.map((childExercise) {
        return ExerciseTemplate.fromExercise(childExercise);
      }).toList();

      return ExerciseTemplate(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: sets,
        notes: exercise.notes,
        restTime: exercise.restTime,
        subExercises: subExercises,
      );
    }

    // Handle DropSetExercise
    if (exercise is DropSetExercise) {
      final sets = exercise.stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        return SetTemplate(
          setNumber: index + 1,
          targetWeight: stage.weight,
          targetReps: stage.reps,
        );
      }).toList();

      return ExerciseTemplate(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: sets,
        notes: exercise.notes,
        restTime: exercise.restTime,
      );
    }

    // Handle RestPauseExercise
    if (exercise is RestPauseExercise) {
      final sets = exercise.restPauseSets.asMap().entries.map((entry) {
        final index = entry.key;
        final rpSet = entry.value;
        return SetTemplate(
          setNumber: index + 1,
          targetReps: rpSet.reps,
        );
      }).toList();

      return ExerciseTemplate(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        category: exercise.category,
        type: exercise.type,
        sets: sets,
        notes: exercise.notes,
        restTime: exercise.restTime,
      );
    }

    // Standard exercise - use the regular sets
    return ExerciseTemplate(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      category: exercise.category,
      type: exercise.type,
      sets: exercise.sets.map((set) {
        return SetTemplate(
          setNumber: set.setNumber,
          targetWeight: set.weight,
          targetReps: set.reps,
          targetRpe: set.rpe,
          notes: set.notes,
        );
      }).toList(),
      notes: exercise.notes,
      restTime: exercise.restTime,
    );
  }

  final String exerciseId; // ID dell'esercizio nel database
  final String exerciseName;
  final ExerciseCategory category;
  final ExerciseType type;
  final List<SetTemplate> sets;
  final String? notes;
  final int? restTime;
  final List<ExerciseTemplate>? subExercises;

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category.name,
      'type': type.name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
      'restTime': restTime,
      if (subExercises != null && subExercises!.isNotEmpty) 
        'exercises': subExercises!.map((e) => e.toJson()).toList(),
    };
  }

  /// Crea una copia con modifiche
  ExerciseTemplate copyWith({
    String? exerciseId,
    String? exerciseName,
    ExerciseCategory? category,
    ExerciseType? type,
    List<SetTemplate>? sets,
    String? notes,
    int? restTime,
    List<ExerciseTemplate>? subExercises,
  }) {
    return ExerciseTemplate(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
      subExercises: subExercises ?? this.subExercises,
    );
  }

  /// Converte il template in un esercizio per il workout
  Exercise toWorkoutExercise() {
    // If it's a superset and has sub-exercises, create a SupersetExercise
    if (type == ExerciseType.superset && subExercises != null && subExercises!.isNotEmpty) {
      final exercises = subExercises!.map((subTemplate) => 
        Exercise(
          name: subTemplate.exerciseName,
          type: ExerciseType.single, // Sub-exercises are singles
          category: subTemplate.category,
          sets: subTemplate.sets.map((s) => s.toExerciseSet()).toList(),
          notes: subTemplate.notes,
          restTime: subTemplate.restTime,
        )
      ).toList();
      
      // Create SupersetSets with shared data for all exercises
      final supersetSets = <SupersetSet>[];
      
      for (int setIndex = 0; setIndex < sets.length; setIndex++) {
        final setTemplate = sets[setIndex];
        final exerciseData = <String, SupersetExerciseData>{};
        
        // Create data for each exercise in this superset set
        for (final exercise in exercises) {
          exerciseData[exercise.name] = SupersetExerciseData(
            exerciseId: exercise.name, // Using exercise name as ID for now
            exerciseName: exercise.name,
            targetWeight: setTemplate.targetWeight,
            targetReps: setTemplate.targetReps,
            actualWeight: null,
            actualReps: null,
            rpe: null,
            isCompleted: false,
          );
        }
        
        // ✅ FIX: Aggiungi timestamp per ID univoco
        supersetSets.add(SupersetSet(
          id: 'superset_set_${DateTime.now().millisecondsSinceEpoch}_$setIndex',
          setNumber: setIndex + 1,
          exerciseData: exerciseData,
          isCompleted: false,
        ));
      }
      
      return SupersetExercise(
        name: exerciseName,
        exercises: exercises,
        supersetSets: supersetSets,
        notes: notes,
        restTime: restTime,
      );
    }
    
    // For normal exercises or superset without sub-exercises
    final exercise = Exercise(
      name: exerciseName,
      type: type,
      category: category,
      sets: sets.map((setTemplate) => setTemplate.toExerciseSet()).toList(),
      notes: notes,
      restTime: restTime,
    );
    
    return exercise;
  }
}

/// Template per set all'interno di un esercizio template
class SetTemplate {

  const SetTemplate({
    required this.setNumber,
    this.targetWeight,
    this.targetReps,
    this.targetRpe,
    this.notes,
  });

  factory SetTemplate.fromJson(Map<String, dynamic> json) {
    // Enhanced validation for SetTemplate deserialization
    // FIX: Support both old format ('weight', 'reps', 'rpe') and new format ('targetWeight', 'targetReps', 'targetRpe')
    // for backward compatibility with templates saved via Cloud Function
    final setNumber = json['setNumber'] is int ? json['setNumber'] : (json['setNumber'] is String ? int.tryParse(json['setNumber']) ?? 1 : 1);

    // Fallback: targetWeight ?? weight
    final weightRaw = json['targetWeight'] ?? json['weight'];
    final targetWeight = weightRaw != null
        ? (weightRaw is num ? weightRaw.toDouble() : double.tryParse(weightRaw.toString()))
        : null;

    // Fallback: targetReps ?? reps
    final repsRaw = json['targetReps'] ?? json['reps'];
    final targetReps = repsRaw is int ? repsRaw : (repsRaw is String ? int.tryParse(repsRaw) : null);

    // Fallback: targetRpe ?? rpe
    final rpeRaw = json['targetRpe'] ?? json['rpe'];
    final targetRpe = rpeRaw is int ? rpeRaw : (rpeRaw is String ? int.tryParse(rpeRaw) : null);

    return SetTemplate(
      setNumber: setNumber,
      targetWeight: targetWeight,
      targetReps: targetReps,
      targetRpe: targetRpe,
      notes: json['notes']?.toString(),
    );
  }
  final int setNumber;
  final double? targetWeight;
  final int? targetReps;
  final int? targetRpe; // Rate of Perceived Exertion
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetWeight': targetWeight,
      'targetReps': targetReps,
      'targetRpe': targetRpe,
      'notes': notes,
    };
  }

  /// Converte il template in un set per l'esercizio
  ExerciseSet toExerciseSet() {
    return ExerciseSet(
      setNumber: setNumber,
      weight: targetWeight,
      reps: targetReps,
      notes: notes,
    );
  }
}