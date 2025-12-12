/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/migration
/// 🎯 Feature: Data Migration from exerciseActivities to workouts
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Script per migrare i dati da exerciseActivities alla nuova struttura workouts
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';

/// Funzione di callback per aggiornamenti di progresso
typedef ProgressCallback = void Function(String message, double progress);

/// Opzioni per la migrazione
class MigrationOptions {

  const MigrationOptions({
    this.timeWindowHours = 3,
    this.minExercisesPerWorkout = 1,
    this.createBackup = true,
    this.deleteOriginals = false,
    this.dryRun = true,
    this.batchSize = 500,
  });
  final int timeWindowHours;
  final int minExercisesPerWorkout;
  final bool createBackup;
  final bool deleteOriginals;
  final bool dryRun;
  final int batchSize;
}

/// Risultato della migrazione
class MigrationResult {

  MigrationResult({
    required this.totalExercises,
    required this.totalWorkouts,
    required this.migratedWorkouts,
    required this.skippedExercises,
    required this.errors,
    required this.workoutGroups,
    required this.success,
    this.backupCollectionName,
  });
  final int totalExercises;
  final int totalWorkouts;
  final int migratedWorkouts;
  final int skippedExercises;
  final List<String> errors;
  final List<WorkoutGroup> workoutGroups;
  final bool success;
  final String? backupCollectionName;
}

/// Gruppo di esercizi che formano un allenamento
class WorkoutGroup {

  WorkoutGroup({
    required this.schedaName,
    required this.startTime,
    required this.endTime,
    required this.exercises,
    required this.generatedId,
  });
  final String schedaName;
  final DateTime startTime;
  final DateTime endTime;
  final List<ExerciseActivity> exercises;
  final String generatedId;

  Duration get duration => endTime.difference(startTime);
  int get exerciseCount => exercises.length;
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
}

/// Servizio per la migrazione dei dati da exerciseActivities a workouts
class WorkoutMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _sourceCollection = 'exerciseActivities';
  static const String _targetCollection = 'workouts';

  /// Anteprima della migrazione senza eseguire modifiche
  Future<MigrationResult> previewMigration({
    MigrationOptions options = const MigrationOptions(),
    ProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call('🔍 Analisi dei dati in corso...', 0.1);

      // Leggi tutti i dati da exerciseActivities
      final exerciseActivities = await _fetchExerciseActivities();
      onProgress?.call('📊 Trovati ${exerciseActivities.length} esercizi', 0.3);

      if (exerciseActivities.isEmpty) {
        return MigrationResult(
          totalExercises: 0,
          totalWorkouts: 0,
          migratedWorkouts: 0,
          skippedExercises: 0,
          errors: [],
          workoutGroups: [],
          success: true,
        );
      }

      // Raggruppa in allenamenti
      onProgress?.call('🔄 Raggruppamento in allenamenti...', 0.5);
      final workoutGroups = _groupExercisesIntoWorkouts(
        exerciseActivities,
        options,
      );

      onProgress?.call('✅ Analisi completata', 1.0);

      return MigrationResult(
        totalExercises: exerciseActivities.length,
        totalWorkouts: workoutGroups.length,
        migratedWorkouts: 0, // Anteprima, non migrato ancora
        skippedExercises: exerciseActivities.length -
            workoutGroups.fold(0, (sum, group) => sum + group.exerciseCount),
        errors: [],
        workoutGroups: workoutGroups,
        success: true,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Errore durante l\'anteprima: $e');
      debugPrint('Stack: $stackTrace');

      return MigrationResult(
        totalExercises: 0,
        totalWorkouts: 0,
        migratedWorkouts: 0,
        skippedExercises: 0,
        errors: [e.toString()],
        workoutGroups: [],
        success: false,
      );
    }
  }

  /// Esegue la migrazione effettiva
  Future<MigrationResult> executeMigration({
    MigrationOptions options = const MigrationOptions(dryRun: false),
    ProgressCallback? onProgress,
  }) async {
    if (options.dryRun) {
      return previewMigration(options: options, onProgress: onProgress);
    }

    try {
      onProgress?.call('🚀 Avvio migrazione...', 0.05);

      // Step 1: Fetch data
      final exerciseActivities = await _fetchExerciseActivities();
      if (exerciseActivities.isEmpty) {
        return MigrationResult(
          totalExercises: 0,
          totalWorkouts: 0,
          migratedWorkouts: 0,
          skippedExercises: 0,
          errors: [],
          workoutGroups: [],
          success: true,
        );
      }

      onProgress?.call('📊 Elaborazione ${exerciseActivities.length} esercizi', 0.1);

      // Step 2: Group exercises
      final workoutGroups = _groupExercisesIntoWorkouts(exerciseActivities, options);
      onProgress?.call('🔄 Identificati ${workoutGroups.length} allenamenti', 0.2);

      String? backupCollectionName;

      // Step 3: Create backup if requested
      if (options.createBackup) {
        onProgress?.call('💾 Creazione backup...', 0.3);
        backupCollectionName = await _createBackup(exerciseActivities);
        onProgress?.call('✅ Backup creato: $backupCollectionName', 0.4);
      }

      // Step 4: Convert and save workouts
      onProgress?.call('📝 Conversione allenamenti...', 0.5);
      int migratedCount = 0;
      final errors = <String>[];

      for (int i = 0; i < workoutGroups.length; i++) {
        try {
          final group = workoutGroups[i];
          final progress = 0.5 + (0.4 * (i + 1) / workoutGroups.length);

          onProgress?.call(
            '💾 Migrazione allenamento ${i + 1}/${workoutGroups.length}: "${group.schedaName}"',
            progress,
          );

          // Non verifichiamo l'esistenza, Firestore gestirà automaticamente la sovrascrittura
          // se necessario. Questo evita problemi di permessi per documenti inesistenti.

          // Converti e salva
          final workoutDetail = _convertGroupToWorkoutDetail(group);

          // Debug: verifica userId

          await _firestore
              .collection(_targetCollection)
              .doc(group.generatedId)
              .set(workoutDetail.toFirestoreMap());

          migratedCount++;
          debugPrint('✅ Migrato allenamento: ${group.schedaName} (${group.exerciseCount} esercizi)');

        } catch (e) {
          final errorMsg = 'Errore migrazione allenamento ${i + 1}: $e';
          errors.add(errorMsg);
          debugPrint('❌ $errorMsg');
        }
      }

      // Step 5: Delete originals if requested
      if (options.deleteOriginals && migratedCount > 0) {
        onProgress?.call('🗑️ Rimozione dati originali...', 0.9);
        // TODO: Implementare cancellazione con cautela
        debugPrint('⚠️ Cancellazione dati originali non implementata per sicurezza');
      }

      onProgress?.call('🎉 Migrazione completata!', 1.0);

      return MigrationResult(
        totalExercises: exerciseActivities.length,
        totalWorkouts: workoutGroups.length,
        migratedWorkouts: migratedCount,
        skippedExercises: exerciseActivities.length -
            workoutGroups.fold(0, (sum, group) => sum + group.exerciseCount),
        errors: errors,
        workoutGroups: workoutGroups,
        success: errors.length < workoutGroups.length * 0.1, // < 10% errori = successo
        backupCollectionName: backupCollectionName,
      );

    } catch (e, stackTrace) {
      debugPrint('❌ Errore critico durante migrazione: $e');
      debugPrint('Stack: $stackTrace');

      return MigrationResult(
        totalExercises: 0,
        totalWorkouts: 0,
        migratedWorkouts: 0,
        skippedExercises: 0,
        errors: [e.toString()],
        workoutGroups: [],
        success: false,
      );
    }
  }

  /// Legge tutti gli esercizi da exerciseActivities per l'utente corrente
  Future<List<ExerciseActivity>> _fetchExerciseActivities() async {
    final currentUser = _auth.currentUser;
    if (currentUser?.email == null) {
      throw Exception('Utente non autenticato');
    }

    final normalizedEmail = currentUser!.email!.toLowerCase().trim();

    final querySnapshot = await _firestore
        .collection(_sourceCollection)
        .where('email', isEqualTo: normalizedEmail)
        .orderBy('createdAt', descending: false) // Ordine cronologico
        .get();

    return querySnapshot.docs
        .map((doc) => ExerciseActivity.fromFirestore(doc))
        .toList();
  }

  /// Raggruppa gli esercizi in allenamenti basandosi su schedaName e timestamp
  List<WorkoutGroup> _groupExercisesIntoWorkouts(
    List<ExerciseActivity> exercises,
    MigrationOptions options,
  ) {
    if (exercises.isEmpty) return [];

    final groups = <WorkoutGroup>[];
    List<ExerciseActivity> currentGroup = [];
    String? currentSchedaName;
    DateTime? lastTimestamp;

    for (final exercise in exercises) {
      final shouldStartNewGroup = currentGroup.isEmpty ||
          exercise.schedaName != currentSchedaName ||
          (lastTimestamp != null &&
              exercise.createdAt.difference(lastTimestamp).inHours > options.timeWindowHours);

      if (shouldStartNewGroup) {
        // Salva il gruppo precedente se valido
        if (currentGroup.isNotEmpty &&
            currentGroup.length >= options.minExercisesPerWorkout) {
          groups.add(_createWorkoutGroup(currentGroup));
        }

        // Inizia nuovo gruppo
        currentGroup = [exercise];
        currentSchedaName = exercise.schedaName;
      } else {
        currentGroup.add(exercise);
      }

      lastTimestamp = exercise.createdAt;
    }

    // Salva l'ultimo gruppo
    if (currentGroup.isNotEmpty &&
        currentGroup.length >= options.minExercisesPerWorkout) {
      groups.add(_createWorkoutGroup(currentGroup));
    }

    return groups;
  }

  /// Crea un WorkoutGroup da una lista di esercizi
  WorkoutGroup _createWorkoutGroup(List<ExerciseActivity> exercises) {
    exercises.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final startTime = exercises.first.createdAt;
    final lastExercise = exercises.last;

    // Calcola endTime considerando la durata dell'ultimo set
    final lastSetDuration = lastExercise.sets.isNotEmpty
        ? (lastExercise.sets.last.setDurationMillis ?? 30000) / 1000 // Default 30 sec
        : 30.0;
    final endTime = lastExercise.createdAt.add(Duration(seconds: lastSetDuration.round()));

    // Genera ID unico basato su nome scheda e timestamp
    final generatedId = '${exercises.first.schedaName.toLowerCase().replaceAll(' ', '_')}_${startTime.millisecondsSinceEpoch}';

    return WorkoutGroup(
      schedaName: exercises.first.schedaName,
      startTime: startTime,
      endTime: endTime,
      exercises: exercises,
      generatedId: generatedId,
    );
  }

  /// Converte un WorkoutGroup in WorkoutHistoryDetail
  WorkoutHistoryDetail _convertGroupToWorkoutDetail(WorkoutGroup group) {
    final currentUser = _auth.currentUser!;

    // Converte esercizi
    final exercisesHistory = group.exercises.map((activity) {
      final setsHistory = activity.sets.map((set) {
        return SetHistoryDetail(
          setNumber: set.set,
          weight: double.tryParse(set.weight) ?? 0.0,
          reps: int.tryParse(set.actualReps ?? set.reps) ?? 0,
          rpe: set.rpe ?? 0,
          notes: null,
          isWarmup: set.isWarmup,
        );
      }).toList();

      return ExerciseHistoryDetail(
        id: activity.exerciseId,
        name: activity.exerciseName,
        category: 'Other', // Category non disponibile in ExerciseActivity
        notes: null,
        sets: setsHistory,
        exerciseData: {
          'image': activity.exerciseImage,
        },
      );
    }).toList();

    return WorkoutHistoryDetail(
      id: group.generatedId,
      userId: currentUser.uid,
      name: group.schedaName,
      description: 'Allenamento migrato da exerciseActivities',
      createdAt: group.startTime,
      startedAt: group.startTime,
      completedAt: group.endTime,
      updatedAt: DateTime.now(),
      duration: group.duration,
      exercises: exercisesHistory,
      metadata: {
        'source': 'migration_from_exercise_activities',
        'migration_date': DateTime.now().toIso8601String(),
        'original_exercise_count': group.exerciseCount,
      },
    );
  }

  /// Crea backup dei dati originali
  Future<String> _createBackup(List<ExerciseActivity> exercises) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupCollectionName = 'exerciseActivities_backup_$timestamp';

    final batch = _firestore.batch();

    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      final docRef = _firestore.collection(backupCollectionName).doc(exercise.id);
      batch.set(docRef, exercise.toFirestore());
    }

    await batch.commit();
    debugPrint('✅ Backup creato: $backupCollectionName (${exercises.length} documenti)');

    return backupCollectionName;
  }

  /// Verifica se ci sono dati da migrare
  Future<bool> hasDataToMigrate() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.email == null) return false;

      final normalizedEmail = currentUser!.email!.toLowerCase().trim();

      final exerciseCount = await _firestore
          .collection(_sourceCollection)
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      return exerciseCount.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Errore verifica dati da migrare: $e');
      return false;
    }
  }

  /// Rollback da backup (da implementare se necessario)
  Future<bool> rollbackFromBackup(String backupCollectionName) async {
    // TODO: Implementare rollback se necessario
    debugPrint('⚠️ Rollback non ancora implementato');
    return false;
  }
}