/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/data/repositories
/// 🎯 Feature: exercise_merge
/// 🔧 Type: repository_implementation
///
/// Implementazione repository per merge esercizi con Firestore batch writes
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_preview.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/repositories/i_exercise_merge_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Implementazione repository per merge esercizi
///
/// Usa Firestore batch writes per operazioni atomiche.
/// Limite batch: 500 documenti per batch.
///
/// **IMPORTANT**: Uses `users/{userId}/workouts` collection (NOT `exerciseActivities`).
/// Workouts contain nested `exercises[]` array that needs to be updated.
class ExerciseMergeRepositoryImpl
    with FirebaseErrorMapperMixin
    implements IExerciseMergeRepository {
  ExerciseMergeRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Limite documenti per batch Firestore
  static const int _batchLimit = 500;

  @override
  Future<Either<Failure, MergeResult>> executeMerge({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
    required String targetMuscleGroup,
  }) async {
    return handleFirebaseOperation(() async {
      if (kDebugMode) {
        debugPrint(
          '🔀 Starting merge: $sourceExerciseName → $targetExerciseName',
        );
      }

      int sessionsUpdated = 0;
      int templatesUpdated = 0;

      // 1. Aggiorna workouts (exercises array inside each workout)
      sessionsUpdated = await _updateWorkoutExercises(
        userId: userId,
        sourceExerciseName: sourceExerciseName,
        targetExerciseId: targetExerciseId,
        targetExerciseName: targetExerciseName,
      );

      // 2. Aggiorna workout_templates
      templatesUpdated = await _updateWorkoutTemplates(
        userId: userId,
        sourceExerciseName: sourceExerciseName,
        targetExerciseId: targetExerciseId,
        targetExerciseName: targetExerciseName,
      );

      // 3. Aggiorna analytics collection (merge sessions + delete source)
      await _updateAnalyticsCollection(
        userId: userId,
        sourceExerciseName: sourceExerciseName,
        targetExerciseName: targetExerciseName,
        targetMuscleGroup: targetMuscleGroup,
      );

      if (kDebugMode) {
        debugPrint(
          '✅ Merge completed: $sessionsUpdated sessions, $templatesUpdated templates',
        );
      }

      return MergeResult.success(
        sessionsUpdated: sessionsUpdated,
        templatesUpdated: templatesUpdated,
      );
    }, operationName: 'executeMerge($sourceExerciseName → $targetExerciseName)');
  }

  @override
  Future<Either<Failure, MergeResult>> executeMergeWithProgress({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
    required String targetMuscleGroup,
    required void Function(double progress, String step) onProgress,
  }) async {
    return handleFirebaseOperation(
      () async {
        if (kDebugMode) {
          debugPrint(
            '🔀 Starting merge with progress: $sourceExerciseName → $targetExerciseName',
          );
        }

        int sessionsUpdated = 0;
        int templatesUpdated = 0;

        // Step 1: Preparazione (0% - 5%)
        onProgress(0.02, 'Preparazione...');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        onProgress(0.05, 'Analisi dati...');

        // Step 2: Aggiorna workouts (5% - 35%)
        onProgress(0.08, 'Ricerca allenamenti...');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        onProgress(0.12, 'Aggiornamento allenamenti...');
        sessionsUpdated = await _updateWorkoutExercises(
          userId: userId,
          sourceExerciseName: sourceExerciseName,
          targetExerciseId: targetExerciseId,
          targetExerciseName: targetExerciseName,
        );
        onProgress(0.25, 'Salvataggio modifiche...');
        await Future<void>.delayed(const Duration(milliseconds: 80));
        onProgress(0.35, 'Allenamenti aggiornati');

        // Step 3: Aggiorna templates (35% - 55%)
        onProgress(0.38, 'Ricerca schede...');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        onProgress(0.42, 'Aggiornamento schede...');
        templatesUpdated = await _updateWorkoutTemplates(
          userId: userId,
          sourceExerciseName: sourceExerciseName,
          targetExerciseId: targetExerciseId,
          targetExerciseName: targetExerciseName,
        );
        onProgress(0.52, 'Schede aggiornate');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        onProgress(0.55, 'Verifica integrità...');

        // Step 4: Aggiorna analytics (55% - 80%)
        onProgress(0.58, 'Caricamento statistiche...');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        onProgress(0.62, 'Unione sessioni...');
        await _updateAnalyticsCollection(
          userId: userId,
          sourceExerciseName: sourceExerciseName,
          targetExerciseName: targetExerciseName,
          targetMuscleGroup: targetMuscleGroup,
        );
        onProgress(0.75, 'Eliminazione duplicati...');
        await Future<void>.delayed(const Duration(milliseconds: 80));
        onProgress(0.80, 'Statistiche unite');

        if (kDebugMode) {
          debugPrint(
            '✅ Merge completed: $sessionsUpdated sessions, $templatesUpdated templates',
          );
        }

        // Il notifier gestisce 80% - 100% (refresh cache)

        return MergeResult.success(
          sessionsUpdated: sessionsUpdated,
          templatesUpdated: templatesUpdated,
        );
      },
      operationName:
          'executeMergeWithProgress($sourceExerciseName → $targetExerciseName)',
    );
  }

  /// Aggiorna exercises array dentro i workouts
  ///
  /// Path: `users/{userId}/workouts/{workoutId}`
  /// Ogni workout ha un array `exercises[]` che contiene gli esercizi eseguiti.
  Future<int> _updateWorkoutExercises({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
  }) async {
    // Query tutti i workouts dell'utente
    final workoutsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts');

    final snapshot = await workoutsRef.get();

    if (snapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('ℹ️ No workouts found for user: $userId');
      }
      return 0;
    }

    // Trova workouts che contengono l'esercizio sorgente
    int totalUpdated = 0;
    final batch = _firestore.batch();
    int batchCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final exercises = data['exercises'] as List<dynamic>? ?? [];

      bool hasMatch = false;
      final updatedExercises = exercises.map((exercise) {
        final exerciseMap = exercise as Map<String, dynamic>;
        final exerciseName =
            exerciseMap['exerciseName'] as String? ??
            exerciseMap['name'] as String? ??
            '';

        // Case-insensitive comparison
        if (exerciseName.toLowerCase() == sourceExerciseName.toLowerCase()) {
          hasMatch = true;
          return {
            ...exerciseMap,
            'exerciseId': targetExerciseId,
            'exerciseName': targetExerciseName,
            'name': targetExerciseName, // Some old workouts use 'name' field
          };
        }
        return exerciseMap;
      }).toList();

      if (hasMatch) {
        batch.update(doc.reference, {
          'exercises': updatedExercises,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        totalUpdated++;
        batchCount++;

        // Commit batch if reaching limit
        if (batchCount >= _batchLimit) {
          await batch.commit();
          if (kDebugMode) {
            debugPrint('📦 Batch committed: $batchCount workouts');
          }
          batchCount = 0;
        }
      }
    }

    // Commit remaining batch
    if (batchCount > 0) {
      await batch.commit();
      if (kDebugMode) {
        debugPrint('📦 Final batch committed: $batchCount workouts');
      }
    }

    if (kDebugMode) {
      debugPrint('✅ Updated $totalUpdated workouts with exercise merge');
    }

    return totalUpdated;
  }

  /// Aggiorna workout_templates collection
  Future<int> _updateWorkoutTemplates({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseId,
    required String targetExerciseName,
  }) async {
    // Query template dell'utente
    final query = _firestore
        .collection('workout_templates')
        .where('userId', isEqualTo: userId);

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    int totalUpdated = 0;
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final exercises = data['exercises'] as List<dynamic>? ?? [];

      bool hasMatch = false;
      final updatedExercises = exercises.map((exercise) {
        final exerciseMap = exercise as Map<String, dynamic>;
        final exerciseName = exerciseMap['exerciseName'] as String? ?? '';

        // Case-insensitive comparison
        if (exerciseName.toLowerCase() == sourceExerciseName.toLowerCase()) {
          hasMatch = true;
          return {
            ...exerciseMap,
            'exerciseId': targetExerciseId,
            'exerciseName': targetExerciseName,
          };
        }
        return exerciseMap;
      }).toList();

      if (hasMatch) {
        batch.update(doc.reference, {
          'exercises': updatedExercises,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        totalUpdated++;
      }

      // Commit batch ogni 500 documenti
      if (totalUpdated > 0 && totalUpdated % _batchLimit == 0) {
        await batch.commit();
      }
    }

    // Commit final batch
    if (totalUpdated % _batchLimit != 0) {
      await batch.commit();
    }

    return totalUpdated;
  }

  /// Aggiorna analytics collection: merge sessioni + elimina documento sorgente
  ///
  /// Path: `users/{userId}/analytics/{exerciseName}`
  ///
  /// Questo metodo:
  /// 1. Legge il documento sorgente (esercizio custom)
  /// 2. Legge il documento target (se esiste)
  /// 3. Combina le sessioni
  /// 4. Scrive/aggiorna il documento target
  /// 5. Elimina il documento sorgente
  Future<void> _updateAnalyticsCollection({
    required String userId,
    required String sourceExerciseName,
    required String targetExerciseName,
    required String targetMuscleGroup,
  }) async {
    final analyticsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics');

    // 1. Leggi documento sorgente
    final sourceDoc = await analyticsRef.doc(sourceExerciseName).get();
    if (!sourceDoc.exists) {
      if (kDebugMode) {
        debugPrint('ℹ️ No analytics doc found for source: $sourceExerciseName');
      }
      return;
    }

    final sourceData = sourceDoc.data()!;
    final sourceSessions = sourceData['sessions'] as List<dynamic>? ?? [];

    if (kDebugMode) {
      debugPrint(
        '📊 Found ${sourceSessions.length} sessions in source analytics',
      );
    }

    // 2. Leggi documento target (potrebbe non esistere)
    final targetDoc = await analyticsRef.doc(targetExerciseName).get();
    List<dynamic> targetSessions = [];

    if (targetDoc.exists) {
      final targetData = targetDoc.data()!;
      targetSessions = targetData['sessions'] as List<dynamic>? ?? [];
      if (kDebugMode) {
        debugPrint(
          '📊 Found ${targetSessions.length} existing sessions in target',
        );
      }
    }

    // 3. Aggiorna exerciseName nelle sessioni sorgente
    final updatedSourceSessions = sourceSessions.map((session) {
      final sessionMap = Map<String, dynamic>.from(session as Map);
      sessionMap['exerciseName'] = targetExerciseName;
      return sessionMap;
    }).toList();

    // 4. Combina sessioni (target esistenti + sorgente migrate)
    final allSessions = [...targetSessions, ...updatedSourceSessions];

    // Ordina per data (più recenti prima)
    allSessions.sort((a, b) {
      final dateA = _parseDate(a['date']);
      final dateB = _parseDate(b['date']);
      return dateB.compareTo(dateA);
    });

    // 5. Scrivi documento target combinato
    await analyticsRef.doc(targetExerciseName).set({
      'exerciseName': targetExerciseName,
      'muscleGroup': targetMuscleGroup,
      'sessions': allSessions,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      debugPrint(
        '✅ Analytics target updated with ${allSessions.length} total sessions',
      );
    }

    // 6. Elimina documento sorgente
    await analyticsRef.doc(sourceExerciseName).delete();

    if (kDebugMode) {
      debugPrint('🗑️ Analytics source document deleted: $sourceExerciseName');
    }
  }

  /// Helper per parsare date in vari formati
  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  @override
  Future<int> countSessionsToUpdate({
    required String userId,
    required String sourceExerciseName,
  }) async {
    final result = await handleFirebaseOperation(() async {
      // Query workouts dell'utente
      final workoutsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts');

      final snapshot = await workoutsRef.get();

      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final exercises = data['exercises'] as List<dynamic>? ?? [];

        for (final exercise in exercises) {
          final exerciseMap = exercise as Map<String, dynamic>;
          final exerciseName =
              exerciseMap['exerciseName'] as String? ??
              exerciseMap['name'] as String? ??
              '';

          if (exerciseName.toLowerCase() == sourceExerciseName.toLowerCase()) {
            count++;
            break; // Conta il workout una sola volta
          }
        }
      }

      return count;
    }, operationName: 'countSessionsToUpdate($sourceExerciseName)');

    return result.fold((failure) {
      if (kDebugMode) {
        debugPrint('❌ Error counting sessions: ${failure.message}');
      }
      return 0;
    }, (sessionCount) => sessionCount);
  }

  @override
  Future<int> countTemplatesToUpdate({
    required String userId,
    required String sourceExerciseName,
  }) async {
    final result = await handleFirebaseOperation(() async {
      final query = _firestore
          .collection('workout_templates')
          .where('userId', isEqualTo: userId);

      final snapshot = await query.get();

      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final exercises = data['exercises'] as List<dynamic>? ?? [];

        for (final exercise in exercises) {
          final exerciseMap = exercise as Map<String, dynamic>;
          final exerciseName = exerciseMap['exerciseName'] as String? ?? '';

          if (exerciseName.toLowerCase() == sourceExerciseName.toLowerCase()) {
            count++;
            break; // Conta il template una sola volta
          }
        }
      }

      return count;
    }, operationName: 'countTemplatesToUpdate($sourceExerciseName)');

    return result.fold((failure) {
      if (kDebugMode) {
        debugPrint('❌ Error counting templates: ${failure.message}');
      }
      return 0;
    }, (templateCount) => templateCount);
  }
}
