import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

/// Modello per salvare le attività degli esercizi completati in Firestore
/// Corrisponde alla struttura /exerciseActivities della vecchia app
class ExerciseActivity {
  final String id;
  final String email;
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImage;
  final String schedaName; // Nome del workout/scheda
  final List<ExerciseActivitySet> sets;
  final DateTime createdAt;
  final DateTime lastModified;

  ExerciseActivity({
    required this.id,
    required this.email,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImage,
    required this.schedaName,
    required this.sets,
    required this.createdAt,
    required this.lastModified,
  });

  /// Crea ExerciseActivity da un Exercise completato
  factory ExerciseActivity.fromExercise({
    required Exercise exercise,
    required String userEmail,
    required String workoutName,
    String? exerciseImageUrl,
  }) {
    // Filtra solo i set completati
    final completedSets = exercise.sets
        .where((set) => set.isCompleted)
        .toList();

    // Converte i set in ExerciseActivitySet
    final activitySets = completedSets.asMap().entries.map((entry) {
      final index = entry.key;
      final set = entry.value;
      
      // Calculate RIR from RPE if available
      int? rir;
      if (set.rpe != null && set.actualReps != null && set.reps != null) {
        // Approximation: RIR = (10 - RPE) for standard sets
        rir = 10 - set.rpe!;
      }
      
      return ExerciseActivitySet(
        set: index + 1, // Numerazione da 1
        weight: set.weight?.toString() ?? "0",
        reps: set.reps?.toString() ?? "0",
        actualReps: set.actualReps?.toString(),
        rpe: set.rpe,
        rir: rir,
        done: set.isCompleted,
        effort: set.rpe != null ? _calculateEffortFromRPE(set.rpe!) : _calculateEffort(set),
        setDurationMillis: set.setDurationMillis, // Include duration if tracked
        isWarmup: set.isWarmup, // Include warmup flag
      );
    }).toList();

    final now = DateTime.now();
    
    return ExerciseActivity(
      id: '${exercise.id}-${now.millisecondsSinceEpoch}',
      email: userEmail,
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      exerciseImage: exerciseImageUrl ?? _getDefaultExerciseImage(exercise.category),
      schedaName: workoutName,
      sets: activitySets,
      createdAt: now,
      lastModified: now,
    );
  }

  /// Calcola l'effort basato su reps e peso (1-5 scale)
  static int _calculateEffort(ExerciseSet set) {
    final reps = set.reps ?? 0;
    final weight = set.weight ?? 0;
    
    // Logica semplificata per calcolare effort
    if (reps >= 15 || weight >= 20) return 5; // Molto intenso
    if (reps >= 12 || weight >= 15) return 4; // Intenso
    if (reps >= 8 || weight >= 10) return 3;  // Moderato
    if (reps >= 5 || weight >= 5) return 2;   // Leggero
    return 1; // Molto leggero
  }

  /// Calcola effort basato su RPE (1-5 scale from 6-10 RPE)
  static int _calculateEffortFromRPE(int rpe) {
    // RPE 6-7 = effort 1-2 (easy)
    // RPE 8 = effort 3 (moderate)
    // RPE 9 = effort 4 (hard)
    // RPE 10 = effort 5 (maximal)
    if (rpe >= 10) return 5;
    if (rpe >= 9) return 4;
    if (rpe >= 8) return 3;
    if (rpe >= 7) return 2;
    return 1;
  }

  /// Ottiene immagine di default per categoria esercizio
  static String _getDefaultExerciseImage(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return "https://static.strengthlevel.com/images/illustrations/bench-press-1000x1000.jpg";
      case ExerciseCategory.back:
        return "https://static.strengthlevel.com/images/illustrations/pull-ups-1000x1000.jpg";
      case ExerciseCategory.shoulders:
        return "https://static.strengthlevel.com/images/illustrations/overhead-press-1000x1000.jpg";
      case ExerciseCategory.arms:
        return "https://static.strengthlevel.com/images/illustrations/hammer-curl-1000x1000.jpg";
      case ExerciseCategory.legs:
        return "https://static.strengthlevel.com/images/illustrations/squat-1000x1000.jpg";
      case ExerciseCategory.abs:
        return "https://static.strengthlevel.com/images/illustrations/plank-1000x1000.jpg";
      case ExerciseCategory.cardio:
        return "https://static.strengthlevel.com/images/illustrations/running-1000x1000.jpg";
      case ExerciseCategory.other:
        return "https://static.strengthlevel.com/images/illustrations/dumbbell-1000x1000.jpg";
    }
  }

  /// Converte in formato per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'exerciseImage': exerciseImage,
      'schedaName': schedaName,
      'sets': sets.map((set) => set.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }

  /// Crea da documento Firestore
  factory ExerciseActivity.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ExerciseActivity(
      id: doc.id,
      email: data['email'] ?? '',
      exerciseId: data['exerciseId'] ?? '',
      exerciseName: data['exerciseName'] ?? '',
      exerciseImage: data['exerciseImage'],
      schedaName: data['schedaName'] ?? '',
      sets: (data['sets'] as List?)
          ?.map((setData) => ExerciseActivitySet.fromFirestore(setData))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastModified: (data['lastModified'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ExerciseActivity copyWith({
    String? email,
    String? exerciseId,
    String? exerciseName,
    String? exerciseImage,
    String? schedaName,
    List<ExerciseActivitySet>? sets,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return ExerciseActivity(
      id: id,
      email: email ?? this.email,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseImage: exerciseImage ?? this.exerciseImage,
      schedaName: schedaName ?? this.schedaName,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

/// Singolo set dell'attività esercizio per Firestore
class ExerciseActivitySet {
  final int set;
  final String weight;
  final String reps;
  final String? actualReps; // Actual reps completed
  final int? rpe; // Rate of Perceived Exertion (6-10)
  final int? rir; // Reps in Reserve
  final bool done;
  final int effort; // 1-5 scale di intensità
  final double? setDurationMillis; // Duration in milliseconds from rest end to set completion
  final bool isWarmup; // Indicates if this is a warmup set

  ExerciseActivitySet({
    required this.set,
    required this.weight,
    required this.reps,
    this.actualReps,
    this.rpe,
    this.rir,
    required this.done,
    required this.effort,
    this.setDurationMillis,
    this.isWarmup = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'set': set,
      'weight': weight,
      'reps': reps,
      'actualReps': actualReps,
      'rpe': rpe,
      'rir': rir,
      'done': done,
      'effort': effort,
      'setDurationMillis': setDurationMillis,
      'isWarmup': isWarmup,
    };
  }

  factory ExerciseActivitySet.fromFirestore(Map<String, dynamic> data) {
    return ExerciseActivitySet(
      set: _parseInt(data['set']) ?? 0,
      weight: (data['weight'] ?? 0).toString(),  // Convert any type to String
      reps: (data['reps'] ?? 0).toString(),      // Convert any type to String
      actualReps: data['actualReps']?.toString(),
      rpe: _parseInt(data['rpe']),
      rir: _parseInt(data['rir']),
      done: data['done'] ?? false,
      effort: _parseInt(data['effort']) ?? 3,
      setDurationMillis: _parseDouble(data['setDurationMillis']),
      isWarmup: data['isWarmup'] ?? false,
    );
  }
  
  // Helper method to safely parse int from any type
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
  
  // Helper method to safely parse double from any type
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  ExerciseActivitySet copyWith({
    int? set,
    String? weight,
    String? reps,
    String? actualReps,
    int? rpe,
    int? rir,
    double? setDurationMillis,
    bool? done,
    int? effort,
    bool? isWarmup,
  }) {
    return ExerciseActivitySet(
      set: set ?? this.set,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      actualReps: actualReps ?? this.actualReps,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      done: done ?? this.done,
      effort: effort ?? this.effort,
      setDurationMillis: setDurationMillis ?? this.setDurationMillis,
      isWarmup: isWarmup ?? this.isWarmup,
    );
  }
}