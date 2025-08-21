import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'exercise.dart';

/// Template per workout riutilizzabili
class WorkoutTemplate {
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
  })  : id = id ?? const Uuid().v4(),
        exercises = exercises ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

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
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    // Parse exercises with enhanced error handling
    List<ExerciseTemplate> exercises = [];
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
          } catch (e, stackTrace) {
          }
        }
      } else {
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
    );
  }

  /// Crea un workout dal template
  List<Exercise> toWorkoutExercises() {
    return exercises.map((template) => template.toWorkoutExercise()).toList();
  }
}

/// Template per esercizio all'interno di un workout template
class ExerciseTemplate {
  final String exerciseId; // ID dell'esercizio nel database
  final String exerciseName;
  final ExerciseCategory category;
  final ExerciseType type;
  final List<SetTemplate> sets;
  final String? notes;
  final int? restTime;

  const ExerciseTemplate({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    this.type = ExerciseType.single,
    List<SetTemplate>? sets,
    this.notes,
    this.restTime,
  }) : sets = sets ?? const [];

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category.name,
      'type': type.name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
      'restTime': restTime,
    };
  }

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    
    // Validate required fields
    if (json['exerciseId'] == null || json['exerciseId'].toString().isEmpty) {
    }
    if (json['exerciseName'] == null || json['exerciseName'].toString().isEmpty) {
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
    
    final exerciseTemplate = ExerciseTemplate(
      exerciseId: json['exerciseId']?.toString() ?? '',
      exerciseName: json['exerciseName']?.toString() ?? '',
      category: category,
      type: type,
      sets: sets,
      notes: json['notes']?.toString(),
      restTime: json['restTime'] is int ? json['restTime'] : null,
    );
    
    return exerciseTemplate;
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
  }) {
    return ExerciseTemplate(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      type: type ?? this.type,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
    );
  }

  /// Converte il template in un esercizio per il workout
  Exercise toWorkoutExercise() {
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
  final int setNumber;
  final double? targetWeight;
  final int? targetReps;
  final int? targetRpe; // Rate of Perceived Exertion
  final String? notes;

  const SetTemplate({
    required this.setNumber,
    this.targetWeight,
    this.targetReps,
    this.targetRpe,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetWeight': targetWeight,
      'targetReps': targetReps,
      'targetRpe': targetRpe,
      'notes': notes,
    };
  }

  factory SetTemplate.fromJson(Map<String, dynamic> json) {
    // Enhanced validation for SetTemplate deserialization
    final setNumber = json['setNumber'] is int ? json['setNumber'] : (json['setNumber'] is String ? int.tryParse(json['setNumber']) ?? 1 : 1);
    final targetWeight = json['targetWeight'] != null ? (json['targetWeight'] is num ? json['targetWeight'].toDouble() : double.tryParse(json['targetWeight'].toString())) : null;
    final targetReps = json['targetReps'] is int ? json['targetReps'] : (json['targetReps'] is String ? int.tryParse(json['targetReps']) : null);
    final targetRpe = json['targetRpe'] is int ? json['targetRpe'] : (json['targetRpe'] is String ? int.tryParse(json['targetRpe']) : null);
    
    return SetTemplate(
      setNumber: setNumber,
      targetWeight: targetWeight,
      targetReps: targetReps,
      targetRpe: targetRpe,
      notes: json['notes']?.toString(),
    );
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