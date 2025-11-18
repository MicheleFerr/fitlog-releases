import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

enum AutoAdjustmentType {
  apre,     // APRE protocol
  rpe,      // RPE/RIR based
}

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

class Exercise {         // Target RIR if using RIR-based

  Exercise({
    String? id,
    required this.name,
    required this.type,
    required this.category,
    List<ExerciseSet>? sets,
    this.notes,
    this.restTime,
    this.tut,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.autoAdjustmentType,
    this.useAPRE = false,
    this.apreProtocol,
    this.apreBaseWeight,
    this.calculated1RM,
    this.calculated3RM,
    this.calculated6RM,
    this.calculated10RM,
    this.lastCalculationDate,
    this.calculationMetadata,
    this.targetRPEMin,
    this.targetRPEMax,
    this.targetRIR,
    this.countingMode = ExerciseCountingMode.weighted, // ✅ NUOVO
  }) :
    id = id ?? const Uuid().v4(),
    sets = sets ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      type: ExerciseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExerciseType.single, // Safe default
      ),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExerciseCategory.other, // Safe default
      ),
      sets: (json['sets'] as List?)
          ?.map((setJson) => ExerciseSet.fromJson(setJson))
          .toList() ?? [],
      notes: json['notes'],
      restTime: json['restTime'],
      tut: json['tut'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      autoAdjustmentType: json['autoAdjustmentType'] != null
          ? AutoAdjustmentType.values.firstWhere(
              (e) => e.name == json['autoAdjustmentType'],
              orElse: () => AutoAdjustmentType.rpe, // Safe default
            )
          : null,
      useAPRE: json['useAPRE'] ?? false,
      apreProtocol: json['apreProtocol'],
      apreBaseWeight: json['apreBaseWeight']?.toDouble(),
      calculated1RM: json['calculated1RM']?.toDouble(),
      calculated3RM: json['calculated3RM']?.toDouble(),
      calculated6RM: json['calculated6RM']?.toDouble(),
      calculated10RM: json['calculated10RM']?.toDouble(),
      lastCalculationDate: json['lastCalculationDate'] != null
          ? DateTime.parse(json['lastCalculationDate'])
          : null,
      calculationMetadata: json['calculationMetadata'],
      targetRPEMin: json['targetRPEMin']?.toDouble(),
      targetRPEMax: json['targetRPEMax']?.toDouble(),
      targetRIR: json['targetRIR'],
      countingMode: ExerciseCountingMode.fromString(json['countingMode']), // ✅ NUOVO
    );
  }
  final String id;
  final String name;
  final ExerciseType type;
  final ExerciseCategory category;
  final List<ExerciseSet> sets;
  final String? notes;
  final int? restTime; // Rest time in seconds for this specific exercise
  final String? tut; // Time Under Tension (e.g., "3-1-2-0")
  final DateTime createdAt;
  final DateTime updatedAt;

  // Auto Adjustment fields
  final AutoAdjustmentType? autoAdjustmentType; // Type of auto adjustment (APRE or RPE)

  // APRE Autoregulation fields
  final bool useAPRE;          // Whether to use APRE for this exercise
  final int? apreProtocol;     // 3, 6, or 10 (reps)
  final double? apreBaseWeight; // Base weight for APRE calculation

  // APRE Cached Calculations (for performance)
  final double? calculated1RM;  // Cached 1RM calculation
  final double? calculated3RM;  // Cached 3RM calculation
  final double? calculated6RM;  // Cached 6RM calculation
  final double? calculated10RM; // Cached 10RM calculation
  final DateTime? lastCalculationDate; // When calculations were last updated
  final String? calculationMetadata; // Info about calculation (e.g., "Based on 10 sets, High confidence")

  // RPE/RIR Autoregulation fields
  final double? targetRPEMin;   // Minimum target RPE (e.g., 7)
  final double? targetRPEMax;   // Maximum target RPE (e.g., 9)
  final int? targetRIR;

  // ✅ Exercise Counting Mode
  final ExerciseCountingMode countingMode; // How this exercise is counted (weighted/reps/time)

  Exercise copyWith({
    String? name,
    ExerciseType? type,
    ExerciseCategory? category,
    List<ExerciseSet>? sets,
    String? notes,
    int? restTime,
    String? tut,
    DateTime? updatedAt,
    AutoAdjustmentType? autoAdjustmentType,
    bool? useAPRE,
    int? apreProtocol,
    double? apreBaseWeight,
    double? calculated1RM,
    double? calculated3RM,
    double? calculated6RM,
    double? calculated10RM,
    DateTime? lastCalculationDate,
    String? calculationMetadata,
    double? targetRPEMin,
    double? targetRPEMax,
    int? targetRIR,
    ExerciseCountingMode? countingMode, // ✅ NUOVO
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
      tut: tut ?? this.tut,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      autoAdjustmentType: autoAdjustmentType ?? this.autoAdjustmentType,
      useAPRE: useAPRE ?? this.useAPRE,
      apreProtocol: apreProtocol ?? this.apreProtocol,
      apreBaseWeight: apreBaseWeight ?? this.apreBaseWeight,
      calculated1RM: calculated1RM ?? this.calculated1RM,
      calculated3RM: calculated3RM ?? this.calculated3RM,
      calculated6RM: calculated6RM ?? this.calculated6RM,
      calculated10RM: calculated10RM ?? this.calculated10RM,
      lastCalculationDate: lastCalculationDate ?? this.lastCalculationDate,
      calculationMetadata: calculationMetadata ?? this.calculationMetadata,
      targetRPEMin: targetRPEMin ?? this.targetRPEMin,
      targetRPEMax: targetRPEMax ?? this.targetRPEMax,
      targetRIR: targetRIR ?? this.targetRIR,
      countingMode: countingMode ?? this.countingMode, // ✅ NUOVO
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
      'tut': tut,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'autoAdjustmentType': autoAdjustmentType?.name,
      'useAPRE': useAPRE,
      'apreProtocol': apreProtocol,
      'apreBaseWeight': apreBaseWeight,
      'calculated1RM': calculated1RM,
      'calculated3RM': calculated3RM,
      'calculated6RM': calculated6RM,
      'calculated10RM': calculated10RM,
      'lastCalculationDate': lastCalculationDate?.toIso8601String(),
      'calculationMetadata': calculationMetadata,
      'targetRPEMin': targetRPEMin,
      'targetRPEMax': targetRPEMax,
      'targetRIR': targetRIR,
      'countingMode': countingMode.name, // ✅ NUOVO
    };
  }

  /// Indica se l'esercizio è completato (tutti i set sono completati)
  bool get isCompleted => sets.isNotEmpty && sets.every((set) => set.isCompleted);

  /// Volume totale dell'esercizio (somma dei volumi di tutti i set)
  double get totalVolume => sets.fold(0.0, (sum, set) => sum + set.volume);

  /// Data di completamento dell'esercizio (ultima data di completamento dei set)
  DateTime? get completedAt {
    final completedSets = sets.where((set) => set.isCompleted && set.completedAt != null);
    if (completedSets.isEmpty) return null;
    
    return completedSets
        .map((set) => set.completedAt!)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

class ExerciseSet { // Rest time in seconds after this set

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
    this.restTime,         // ✅ Rest time for this set
  }) : id = id ?? const Uuid().v4();

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
      restTime: json['restTime'] as int?, // ✅ Rest time in seconds
    );
  }
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
  final int? restTime;

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
    int? restTime,   // ✅ Rest time
  }) {
    return ExerciseSet(
      id: id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      actualReps: actualReps ?? this.actualReps,     // ✅ Nuovo
      rpe: rpe ?? this.rpe,                         // ✅ Nuovo
      restTime: restTime ?? this.restTime,           // ✅ Rest time
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
      if (restTime != null) 'restTime': restTime, // ✅ Rest time in seconds
    };
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

  /// Volume del set (peso × reps effettive o target)
  double get volume {
    final effectiveReps = actualReps ?? reps ?? 0;
    final effectiveWeight = weight ?? 0.0;
    return effectiveWeight * effectiveReps;
  }

  // ========== COUNTING MODE VALIDATION ==========

  /// Valida che il set abbia i campi richiesti in base al counting mode
  bool isValid(ExerciseCountingMode countingMode) {
    switch (countingMode) {
      case ExerciseCountingMode.weighted:
        // Weighted exercises require weight + reps
        return weight != null && weight! > 0 && reps != null && reps! > 0;

      case ExerciseCountingMode.reps:
        // Bodyweight exercises require only reps
        return reps != null && reps! > 0;

      case ExerciseCountingMode.time:
        // Time-based exercises require seconds
        return seconds != null && seconds! > 0;
    }
  }

  /// Restituisce i campi mancanti in base al counting mode
  List<String> getMissingFields(ExerciseCountingMode countingMode) {
    final missing = <String>[];

    switch (countingMode) {
      case ExerciseCountingMode.weighted:
        if (weight == null || weight! <= 0) missing.add('weight');
        if (reps == null || reps! <= 0) missing.add('reps');
        break;

      case ExerciseCountingMode.reps:
        if (reps == null || reps! <= 0) missing.add('reps');
        break;

      case ExerciseCountingMode.time:
        if (seconds == null || seconds! <= 0) missing.add('seconds');
        break;
    }

    return missing;
  }

  /// Restituisce una stringa descrittiva del set in base al counting mode
  String getDisplayText(ExerciseCountingMode countingMode) {
    switch (countingMode) {
      case ExerciseCountingMode.weighted:
        final w = weight?.toStringAsFixed(1) ?? '?';
        final r = actualReps ?? reps ?? '?';
        return '$w kg × $r reps';

      case ExerciseCountingMode.reps:
        final r = actualReps ?? reps ?? '?';
        return '$r reps';

      case ExerciseCountingMode.time:
        final s = seconds ?? 0;
        final minutes = s ~/ 60;
        final secs = s % 60;
        if (minutes > 0) {
          return '${minutes}m ${secs}s';
        }
        return '${secs}s';
    }
  }
}

// Superset specific data

/// Dati per un singolo esercizio all'interno di un set di superset
class SupersetExerciseData {

  const SupersetExerciseData({
    required this.exerciseId,
    required this.exerciseName,
    this.targetWeight,
    this.targetReps,
    this.actualWeight,
    this.actualReps,
    this.rpe,
    this.isCompleted = false,
    this.notes,
  });

  factory SupersetExerciseData.fromJson(Map<String, dynamic> json) {
    return SupersetExerciseData(
      exerciseId: json['exerciseId'] ?? '',
      exerciseName: json['exerciseName'] ?? '',
      targetWeight: json['targetWeight']?.toDouble(),
      targetReps: json['targetReps'],
      actualWeight: json['actualWeight']?.toDouble(),
      actualReps: json['actualReps'],
      rpe: json['rpe'],
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }
  final String exerciseId;
  final String exerciseName;
  final double? targetWeight;
  final int? targetReps;
  final double? actualWeight;
  final int? actualReps;
  final int? rpe;
  final bool isCompleted;
  final String? notes;

  SupersetExerciseData copyWith({
    String? exerciseId,
    String? exerciseName,
    double? targetWeight,
    int? targetReps,
    double? actualWeight,
    int? actualReps,
    int? rpe,
    bool? isCompleted,
    String? notes,
  }) {
    return SupersetExerciseData(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      targetWeight: targetWeight ?? this.targetWeight,
      targetReps: targetReps ?? this.targetReps,
      actualWeight: actualWeight ?? this.actualWeight,
      actualReps: actualReps ?? this.actualReps,
      rpe: rpe ?? this.rpe,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetWeight': targetWeight,
      'targetReps': targetReps,
      'actualWeight': actualWeight,
      'actualReps': actualReps,
      'rpe': rpe,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }
}

/// Set di un superset - contiene dati per tutti gli esercizi del round
class SupersetSet {

  SupersetSet({
    String? id,
    required this.setNumber,
    required this.exerciseData,
    this.isCompleted = false,
    this.completedAt,
    this.setDurationMillis,
    this.setStartedAt,
    this.isWarmup = false,
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory SupersetSet.fromJson(Map<String, dynamic> json) {
    return SupersetSet(
      id: json['id'],
      setNumber: json['setNumber'],
      exerciseData: (json['exerciseData'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, SupersetExerciseData.fromJson(value)))
          ?? {},
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      setDurationMillis: json['setDurationMillis']?.toDouble(),
      setStartedAt: json['setStartedAt'] != null 
          ? DateTime.parse(json['setStartedAt']) 
          : null,
      isWarmup: json['isWarmup'] ?? false,
      notes: json['notes'],
    );
  }
  final String id;
  final int setNumber;
  final Map<String, SupersetExerciseData> exerciseData;
  final bool isCompleted;
  final DateTime? completedAt;
  final double? setDurationMillis;
  final DateTime? setStartedAt;
  final bool isWarmup;
  final String? notes;

  /// Verifica se tutti gli esercizi del set sono completati
  bool get isFullyCompleted => 
      exerciseData.values.every((data) => data.isCompleted);

  /// Conta quanti esercizi sono completati
  int get completedExercisesCount => 
      exerciseData.values.where((data) => data.isCompleted).length;

  SupersetSet copyWith({
    String? id,
    int? setNumber,
    Map<String, SupersetExerciseData>? exerciseData,
    bool? isCompleted,
    DateTime? completedAt,
    double? setDurationMillis,
    DateTime? setStartedAt,
    bool? isWarmup,
    String? notes,
  }) {
    return SupersetSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      exerciseData: exerciseData ?? Map.from(this.exerciseData),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      setDurationMillis: setDurationMillis ?? this.setDurationMillis,
      setStartedAt: setStartedAt ?? this.setStartedAt,
      isWarmup: isWarmup ?? this.isWarmup,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'exerciseData': exerciseData.map((key, value) => MapEntry(key, value.toJson())),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'setDurationMillis': setDurationMillis,
      'setStartedAt': setStartedAt?.toIso8601String(),
      'isWarmup': isWarmup,
      'notes': notes,
    };
  }
}

class SupersetExercise extends Exercise { // I set del superset

  SupersetExercise({
    super.id,
    required super.name,
    required List<Exercise> exercises,
    List<SupersetSet>? supersetSets,
    super.notes,
    super.restTime,
  }) : 
    exercises = exercises,
    supersetSets = supersetSets ?? [],
    super(
      type: ExerciseType.superset,
      category: exercises.isNotEmpty ? exercises.first.category : ExerciseCategory.other,
      sets: [],
    );
  final List<Exercise> exercises; // Gli esercizi del superset (senza set propri)
  final List<SupersetSet> supersetSets;

  /// Crea una copia del superset con modifiche
  @override
  SupersetExercise copyWith({
    String? id,
    String? name,
    ExerciseType? type,
    ExerciseCategory? category,
    List<ExerciseSet>? sets, // Ignored for superset
    String? notes,
    int? restTime,
    String? tut,
    DateTime? createdAt,
    DateTime? updatedAt,
    AutoAdjustmentType? autoAdjustmentType,
    bool? useAPRE,
    int? apreProtocol,
    double? apreBaseWeight,
    double? calculated1RM,
    double? calculated3RM,
    double? calculated6RM,
    double? calculated10RM,
    DateTime? lastCalculationDate,
    String? calculationMetadata,
    double? targetRPEMin,
    double? targetRPEMax,
    int? targetRIR,
    ExerciseCountingMode? countingMode, // ✅ Added to match Exercise.copyWith
    List<Exercise>? exercises,
    List<SupersetSet>? supersetSets,
  }) {
    return SupersetExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      supersetSets: supersetSets ?? this.supersetSets,
      notes: notes ?? this.notes,
      restTime: restTime ?? this.restTime,
    );
  }

  /// Override per il completamento - usa supersetSets invece di sets
  @override
  bool get isCompleted => 
      supersetSets.isNotEmpty && supersetSets.every((set) => set.isCompleted);

  /// Override per la data di completamento
  @override
  DateTime? get completedAt {
    final completedSets = supersetSets.where((set) => set.isCompleted && set.completedAt != null);
    if (completedSets.isEmpty) return null;
    
    return completedSets
        .map((set) => set.completedAt!)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Override per il volume totale
  @override
  double get totalVolume {
    double total = 0.0;
    for (final supersetSet in supersetSets) {
      for (final exerciseData in supersetSet.exerciseData.values) {
        final weight = exerciseData.actualWeight ?? exerciseData.targetWeight ?? 0.0;
        final reps = exerciseData.actualReps ?? exerciseData.targetReps ?? 0;
        total += weight * reps;
      }
    }
    return total;
  }

  /// Valida che tutti i SupersetSet contengano dati per tutti gli esercizi
  bool get isDataConsistent {
    for (final set in supersetSets) {
      for (final exercise in exercises) {
        if (!set.exerciseData.containsKey(exercise.id)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Sincronizza tutti i SupersetSet con la lista corrente di esercizi
  /// Rimuove esercizi non più presenti e aggiunge quelli mancanti
  SupersetExercise ensureConsistency() {
    if (isDataConsistent) return this;

    final syncedSets = supersetSets.map((set) {
      final updatedExerciseData = <String, SupersetExerciseData>{};

      // Copia i dati esistenti per gli esercizi ancora presenti
      for (final exercise in exercises) {
        if (set.exerciseData.containsKey(exercise.id)) {
          updatedExerciseData[exercise.id] = set.exerciseData[exercise.id]!;
        } else {
          // Aggiungi dati di default per nuovi esercizi
          updatedExerciseData[exercise.id] = SupersetExerciseData(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            targetWeight: 0.0,
            targetReps: 10,
            actualWeight: null,
            actualReps: null,
            rpe: null,
            isCompleted: false,
            notes: null,
          );
        }
      }

      return set.copyWith(
        exerciseData: updatedExerciseData,
        // Se erano tutti completati e abbiamo aggiunto esercizi, non è più completato
        isCompleted: set.isCompleted &&
                     updatedExerciseData.length == set.exerciseData.length,
      );
    }).toList();

    return copyWith(supersetSets: syncedSets);
  }

  /// Conta il numero totale di round completati
  int get completedRoundsCount =>
      supersetSets.where((set) => set.isFullyCompleted).length;

  /// Calcola la percentuale di completamento del superset (0-100)
  double get completionPercentage {
    if (supersetSets.isEmpty) return 0.0;
    return (completedRoundsCount / supersetSets.length) * 100;
  }
}

// DropSet specific data
class DropSetExercise extends Exercise {

  DropSetExercise({
    super.id,
    required super.name,
    required super.category,
    required List<DropSetStage> stages,
    super.notes,
  }) : 
    stages = stages,
    super(
      type: ExerciseType.dropset,
    );
  final List<DropSetStage> stages;
}

class DropSetStage {

  DropSetStage({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });
  final double weight;
  final int reps;
  final bool isCompleted;

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

  RestPauseExercise({
    super.id,
    required super.name,
    required super.category,
    required this.weight,
    required this.targetReps,
    required this.restPauseSets,
    super.notes,
  }) : super(
      type: ExerciseType.restPause,
    );
  final double weight;
  final int targetReps;
  final List<RestPauseSet> restPauseSets;
}

class RestPauseSet {

  RestPauseSet({
    required this.reps,
    required this.restSeconds,
    this.isCompleted = false,
  });
  final int reps;
  final int restSeconds;
  final bool isCompleted;

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