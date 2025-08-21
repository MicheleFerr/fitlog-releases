import 'package:uuid/uuid.dart';

enum ExerciseType {
  single,
  superset,
  dropset,
  restPause,
}

enum ExerciseCategory {
  chest,
  back,
  shoulders,
  arms,
  legs,
  abs,
  cardio,
  other,
}

class Exercise {
  final String id;
  final String name;
  final ExerciseType type;
  final ExerciseCategory category;
  final List<ExerciseSet> sets;
  final String? notes;
  final int? restTime; // Rest time in seconds for this specific exercise
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    String? id,
    required this.name,
    required this.type,
    required this.category,
    List<ExerciseSet>? sets,
    this.notes,
    this.restTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    sets = sets ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Exercise copyWith({
    String? name,
    ExerciseType? type,
    ExerciseCategory? category,
    List<ExerciseSet>? sets,
    String? notes,
    int? restTime,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category.name,
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
      'restTime': restTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      type: ExerciseType.values.firstWhere((e) => e.name == json['type']),
      category: ExerciseCategory.values.firstWhere((e) => e.name == json['category']),
      sets: (json['sets'] as List?)
          ?.map((setJson) => ExerciseSet.fromJson(setJson))
          .toList() ?? [],
      notes: json['notes'],
      restTime: json['restTime'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ExerciseSet {
  final String id;
  final int setNumber;
  final double? weight;
  final int? reps;             // Target reps
  final int? actualReps;       // ✅ Reps effettive completate
  final int? rpe;             // ✅ RPE (Rate of Perceived Exertion) 5-10
  final int? seconds;         // For time-based exercises
  final double? distance;     // For cardio
  final bool isCompleted;
  final String? notes;
  final DateTime? completedAt; // ✅ Timestamp completamento
  final double? setDurationMillis; // ✅ Duration in milliseconds (from rest end to set completion)
  final DateTime? setStartedAt; // ✅ Timestamp when set started (after rest timer)
  final bool isWarmup; // ✅ Indica se è un set di riscaldamento

  ExerciseSet({
    String? id,
    required this.setNumber,
    this.weight,
    this.reps,
    this.actualReps,        // ✅ Nuovo
    this.rpe,              // ✅ Nuovo  
    this.seconds,
    this.distance,
    this.isCompleted = false,
    this.notes,
    this.completedAt,      // ✅ Nuovo
    this.setDurationMillis, // ✅ Nuovo
    this.setStartedAt,     // ✅ Nuovo
    this.isWarmup = false, // ✅ Nuovo (default false)
  }) : id = id ?? const Uuid().v4();

  ExerciseSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    int? actualReps,      // ✅ Nuovo
    int? rpe,            // ✅ Nuovo
    int? seconds,  
    double? distance,
    bool? isCompleted,
    String? notes,
    DateTime? completedAt, // ✅ Nuovo
    double? setDurationMillis, // ✅ Nuovo
    DateTime? setStartedAt, // ✅ Nuovo
    bool? isWarmup, // ✅ Nuovo
  }) {
    return ExerciseSet(
      id: id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      actualReps: actualReps ?? this.actualReps,     // ✅ Nuovo
      rpe: rpe ?? this.rpe,                         // ✅ Nuovo
      seconds: seconds ?? this.seconds,
      distance: distance ?? this.distance,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt, // ✅ Nuovo
      setDurationMillis: setDurationMillis ?? this.setDurationMillis, // ✅ Nuovo
      setStartedAt: setStartedAt ?? this.setStartedAt, // ✅ Nuovo
      isWarmup: isWarmup ?? this.isWarmup, // ✅ Nuovo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'actualReps': actualReps,           // ✅ Nuovo
      'rpe': rpe,                        // ✅ Nuovo
      'seconds': seconds,
      'distance': distance,
      'isCompleted': isCompleted,
      'notes': notes,
      'completedAt': completedAt?.toIso8601String(), // ✅ Nuovo
      'setDurationMillis': setDurationMillis, // ✅ Nuovo
      'setStartedAt': setStartedAt?.toIso8601String(), // ✅ Nuovo
      'isWarmup': isWarmup, // ✅ Nuovo
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'],
      setNumber: json['setNumber'],
      weight: json['weight']?.toDouble(),
      reps: json['reps'],
      actualReps: json['actualReps'],                        // ✅ Nuovo
      rpe: json['rpe'],                                     // ✅ Nuovo
      seconds: json['seconds'],
      distance: json['distance']?.toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
      completedAt: json['completedAt'] != null              // ✅ Nuovo
          ? DateTime.parse(json['completedAt'])
          : null,
      setDurationMillis: json['setDurationMillis']?.toDouble(), // ✅ Nuovo
      setStartedAt: json['setStartedAt'] != null              // ✅ Nuovo
          ? DateTime.parse(json['setStartedAt'])
          : null,
      isWarmup: json['isWarmup'] ?? false, // ✅ Nuovo
    );
  }

  // ✅ Helper methods per RPE workflow
  
  /// Completa il set con RPE e reps effettive
  /// Duration is now calculated externally (set-to-set tracking)
  ExerciseSet completeWithRPE({
    required int actualReps,
    required int rpe,
    String? notes,
  }) {
    return copyWith(
      actualReps: actualReps,
      rpe: rpe,
      isCompleted: true,
      completedAt: DateTime.now(),
      notes: notes,
    );
  }

  /// Verifica se RPE è valido (5-10)
  bool get hasValidRPE => rpe != null && rpe! >= 5 && rpe! <= 10;

  /// Restituisce il testo RPE formattato
  String get rpeText => rpe != null ? 'RPE: $rpe/10' : '';

  /// Restituisce le reps completate vs target
  String get repsText {
    if (actualReps != null && reps != null) {
      return '$actualReps/$reps reps';
    } else if (actualReps != null) {
      return '$actualReps reps';
    } else if (reps != null) {
      return '$reps reps (target)';
    }
    return '';
  }

  /// Indica se il set è stato completato con successo (tutte le target reps)
  bool get isFullyCompleted => 
      isCompleted && 
      actualReps != null && 
      reps != null && 
      actualReps! >= reps!;

  /// Indica se sono state completate meno reps del target
  bool get isPartiallyCompleted => 
      isCompleted && 
      actualReps != null && 
      reps != null && 
      actualReps! < reps!;
}

// Superset specific data
class SupersetExercise extends Exercise {
  final List<Exercise> exercises; // Multiple exercises in superset

  SupersetExercise({
    String? id,
    required String name,
    required List<Exercise> exercises,
    String? notes,
  }) : 
    exercises = exercises,
    super(
      id: id,
      name: name,
      type: ExerciseType.superset,
      category: exercises.isNotEmpty ? exercises.first.category : ExerciseCategory.other,
      notes: notes,
    );
}

// DropSet specific data
class DropSetExercise extends Exercise {
  final List<DropSetStage> stages;

  DropSetExercise({
    String? id,
    required String name,
    required ExerciseCategory category,
    required List<DropSetStage> stages,
    String? notes,
  }) : 
    stages = stages,
    super(
      id: id,
      name: name,
      type: ExerciseType.dropset,
      category: category,
      notes: notes,
    );
}

class DropSetStage {
  final double weight;
  final int reps;
  final bool isCompleted;

  DropSetStage({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  DropSetStage copyWith({
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return DropSetStage(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// RestPause specific data  
class RestPauseExercise extends Exercise {
  final double weight;
  final int targetReps;
  final List<RestPauseSet> restPauseSets;

  RestPauseExercise({
    String? id,
    required String name,
    required ExerciseCategory category,
    required this.weight,
    required this.targetReps,
    required this.restPauseSets,
    String? notes,
  }) : super(
      id: id,
      name: name,
      type: ExerciseType.restPause,
      category: category,
      notes: notes,
    );
}

class RestPauseSet {
  final int reps;
  final int restSeconds;
  final bool isCompleted;

  RestPauseSet({
    required this.reps,
    required this.restSeconds,
    this.isCompleted = false,
  });

  RestPauseSet copyWith({
    int? reps,
    int? restSeconds,
    bool? isCompleted,
  }) {
    return RestPauseSet(
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}