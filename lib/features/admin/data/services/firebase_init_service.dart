/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/data/services
/// 🎯 Feature: admin
/// 🔧 Type: service
///
/// Servizio per inizializzare Firebase con i dati degli esercizi
library;

import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/admin/domain/entities/firebase_init_result.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

class FirebaseInitService {

  FirebaseInitService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Inizializza Firebase con i dati degli esercizi dal JSON locale
  Future<FirebaseInitResult> initializeExercisesCollection({
    bool overwriteExisting = false,
    String? specificVersion,
  }) async {
    try {
      debugPrint('🔥 Starting Firebase initialization...');
      final startTime = DateTime.now();

      // 1. Carica esercizi dal JSON locale
      final exercises = await _loadExercisesFromAssets();
      if (exercises.isEmpty) {
        return FirebaseInitResult.failure(
          'No exercises found in local JSON file',
          Duration.zero,
        );
      }

      debugPrint('📚 Loaded ${exercises.length} exercises from assets');

      // 2. Controlla se la collection esiste già
      final existingCount = await _getExercisesCount();
      if (existingCount > 0 && !overwriteExisting) {
        return FirebaseInitResult.failure(
          'Exercises collection already exists with $existingCount documents. Use overwriteExisting=true to replace.',
          DateTime.now().difference(startTime),
        );
      }

      // 3. Prepara batch write per performance ottimali
      final batchResults = await _writeBatchExercises(exercises, overwriteExisting);

      // 4. Imposta metadata della versione
      await _setVersionMetadata(specificVersion ?? '1.0.0', exercises.length);

      // 5. Crea indici per ricerca ottimizzata
      await _createSearchMetadata(exercises);

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ Firebase initialization completed in ${duration.inSeconds}s');

      return FirebaseInitResult.success(
        exerciseCount: exercises.length,
        batchCount: batchResults.batchCount,
        duration: duration,
        message: 'Successfully initialized ${exercises.length} exercises in ${batchResults.batchCount} batches',
      );

    } catch (e, stackTrace) {
      debugPrint('❌ Firebase initialization failed: $e');
      log('Firebase init error', error: e, stackTrace: stackTrace);

      return FirebaseInitResult.failure(
        'Initialization failed: $e',
        Duration.zero,
      );
    }
  }

  /// Aggiorna solo esercizi specifici
  Future<FirebaseInitResult> updateSpecificExercises({
    required List<String> exerciseIds,
    String? newVersion,
  }) async {
    try {
      debugPrint('🔄 Updating specific exercises: ${exerciseIds.join(", ")}');
      final startTime = DateTime.now();

      // Carica tutti gli esercizi dal JSON
      final allExercises = await _loadExercisesFromAssets();

      // Filtra solo quelli richiesti
      final exercisesToUpdate = allExercises
          .where((exercise) => exerciseIds.contains(exercise.id))
          .toList();

      if (exercisesToUpdate.isEmpty) {
        return FirebaseInitResult.failure(
          'No exercises found with IDs: ${exerciseIds.join(", ")}',
          Duration.zero,
        );
      }

      // Update batch
      final batch = _firestore.batch();
      for (final exercise in exercisesToUpdate) {
        final docRef = _firestore.collection('exercises').doc(exercise.id);
        batch.set(docRef, _exerciseToFirestoreData(exercise), SetOptions(merge: true));
      }

      await batch.commit();

      // Aggiorna metadata se fornita nuova versione
      if (newVersion != null) {
        await _updateVersionMetadata(newVersion, exercisesToUpdate.length);
      }

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ Updated ${exercisesToUpdate.length} exercises');

      return FirebaseInitResult.success(
        exerciseCount: exercisesToUpdate.length,
        batchCount: 1,
        duration: duration,
        message: 'Successfully updated ${exercisesToUpdate.length} exercises',
      );

    } catch (e) {
      debugPrint('❌ Exercise update failed: $e');
      return FirebaseInitResult.failure(
        'Update failed: $e',
        Duration.zero,
      );
    }
  }

  /// Risolve i dati mancanti identificando e reinserendo gli esercizi mancanti
  Future<FirebaseInitResult> fixMissingData() async {
    try {
      debugPrint('🔧 Fixing missing data...');
      final startTime = DateTime.now();

      // 1. Carica esercizi dal JSON
      final allExercises = await _loadExercisesFromAssets();
      debugPrint('📚 Loaded ${allExercises.length} exercises from JSON');

      // 2. Ottieni tutti gli ID esistenti nel database
      final existingDocs = await _firestore.collection('exercises').get();
      final existingIds = existingDocs.docs.map((doc) => doc.id).toSet();
      debugPrint('💾 Found ${existingIds.length} exercises in database');

      // 3. Trova esercizi mancanti
      final missingExercises = allExercises
          .where((exercise) => !existingIds.contains(exercise.id))
          .toList();

      debugPrint('🔍 Found ${missingExercises.length} missing exercises');

      if (missingExercises.isEmpty) {
        return FirebaseInitResult.success(
          message: 'All exercises are present in database',
          exerciseCount: allExercises.length,
          batchCount: 0,
          duration: DateTime.now().difference(startTime),
          details: {'missingCount': 0, 'totalCount': allExercises.length},
        );
      }

      // 4. Inserisci esercizi mancanti
      final batchResult = await _writeBatchExercises(missingExercises, false);

      // 5. Aggiorna metadata versione
      await _setVersionMetadata('1.0.1-fixed', allExercises.length);

      final summary = 'Fixed ${missingExercises.length} missing exercises';
      debugPrint('✅ Missing data fix completed');

      return FirebaseInitResult.success(
        message: summary,
        exerciseCount: allExercises.length,
        batchCount: batchResult.batchCount,
        duration: DateTime.now().difference(startTime),
        details: {
          'missingFixed': missingExercises.length,
          'totalCount': allExercises.length,
          'batchesProcessed': batchResult.batchCount,
        },
      );
    } catch (e) {
      debugPrint('❌ Fix missing data failed: $e');
      return FirebaseInitResult.failure(
        'Fix failed: $e',
        Duration.zero,
      );
    }
  }

  /// Verifica integrità dei dati
  Future<FirebaseInitResult> verifyDataIntegrity() async {
    try {
      debugPrint('🔍 Verifying data integrity...');
      final startTime = DateTime.now();

      // 1. Controlla metadata versione
      final versionDoc = await _firestore
          .collection('exercise_metadata')
          .doc('version_info')
          .get();

      if (!versionDoc.exists) {
        return FirebaseInitResult.failure(
          'Version metadata not found',
          DateTime.now().difference(startTime),
        );
      }

      final versionData = versionDoc.data()!;
      final expectedCount = versionData['totalExercises'] as int;

      // 2. Conta esercizi effettivi
      final actualCount = await _getExercisesCount();

      if (actualCount != expectedCount) {
        return FirebaseInitResult.failure(
          'Data mismatch: expected $expectedCount exercises, found $actualCount',
          DateTime.now().difference(startTime),
        );
      }

      // 3. Verifica integrità campione di documenti
      final sampleDocs = await _firestore
          .collection('exercises')
          .limit(10)
          .get();

      for (final doc in sampleDocs.docs) {
        final data = doc.data();
        if (!_isValidExerciseData(data)) {
          return FirebaseInitResult.failure(
            'Invalid exercise data found in document: ${doc.id}',
            DateTime.now().difference(startTime),
          );
        }
      }

      final duration = DateTime.now().difference(startTime);
      debugPrint('✅ Data integrity verified');

      return FirebaseInitResult.success(
        exerciseCount: actualCount,
        batchCount: 0,
        duration: duration,
        message: 'Data integrity verified: $actualCount exercises',
      );

    } catch (e) {
      debugPrint('❌ Integrity verification failed: $e');
      return FirebaseInitResult.failure(
        'Verification failed: $e',
        Duration.zero,
      );
    }
  }

  /// Carica esercizi dal file JSON assets
  Future<List<Exercise>> _loadExercisesFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to load exercises from assets: $e');
      rethrow;
    }
  }

  /// Conta documenti nella collection exercises
  Future<int> _getExercisesCount() async {
    final snapshot = await _firestore.collection('exercises').count().get();
    return snapshot.count ?? 0;
  }

  /// Scrive esercizi in batch per performance ottimali
  Future<BatchWriteResult> _writeBatchExercises(
    List<Exercise> exercises,
    bool overwriteExisting,
  ) async {
    const batchSize = 500; // Limite Firestore
    int batchCount = 0;

    // Se stiamo sovrascrivendo, cancelliamo prima tutto
    if (overwriteExisting) {
      await _clearExercisesCollection();
    }

    for (int i = 0; i < exercises.length; i += batchSize) {
      final batch = _firestore.batch();
      final endIndex = (i + batchSize < exercises.length) ? i + batchSize : exercises.length;

      for (int j = i; j < endIndex; j++) {
        final exercise = exercises[j];
        final docRef = _firestore.collection('exercises').doc(exercise.id);
        batch.set(docRef, _exerciseToFirestoreData(exercise));
      }

      await batch.commit();
      batchCount++;

      debugPrint('📦 Batch $batchCount completed: ${endIndex - i} exercises');
    }

    return BatchWriteResult(batchCount: batchCount);
  }

  /// Converte Exercise in formato Firestore
  Map<String, dynamic> _exerciseToFirestoreData(Exercise exercise) {
    final data = exercise.toJson();

    // Aggiungi metadati per ricerca e gestione
    data.addAll({
      'searchTerms': _generateSearchTerms(exercise),
      'lastModified': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'version': '1.0.0',
    });

    return data;
  }

  /// Genera termini di ricerca per l'esercizio
  List<String> _generateSearchTerms(Exercise exercise) {
    final terms = <String>{};

    // Nome dell'esercizio
    terms.add(exercise.nome.toLowerCase());
    terms.addAll(exercise.nome.toLowerCase().split(' '));

    // Focus muscoli
    terms.addAll(exercise.focus.map((f) => f.toLowerCase()));

    // Muscoli secondari
    terms.addAll(exercise.muscoliSecondari.map((m) => m.toLowerCase()));

    // Attrezzatura e pattern
    terms.add(exercise.attrezzatura.toLowerCase());
    terms.add(exercise.patternMovimento.toLowerCase());

    return terms.toList();
  }

  /// Cancella completamente la collection exercises
  Future<void> _clearExercisesCollection() async {
    debugPrint('🗑️ Clearing existing exercises collection...');

    const batchSize = 500;
    final Query query = _firestore.collection('exercises').limit(batchSize);

    QuerySnapshot snapshot = await query.get();

    while (snapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      snapshot = await query.get();
    }

    debugPrint('✅ Exercises collection cleared');
  }

  /// Imposta metadata della versione
  Future<void> _setVersionMetadata(String version, int exerciseCount) async {
    await _firestore.collection('exercise_metadata').doc('version_info').set({
      'version': version,
      'totalExercises': exerciseCount,
      'lastUpdated': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'format': 'hybrid_v1',
    });

    debugPrint('📋 Version metadata set: v$version ($exerciseCount exercises)');
  }

  /// Aggiorna metadata della versione
  Future<void> _updateVersionMetadata(String version, int updatedCount) async {
    await _firestore.collection('exercise_metadata').doc('version_info').update({
      'version': version,
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastPartialUpdate': {
        'exerciseCount': updatedCount,
        'timestamp': FieldValue.serverTimestamp(),
      },
    });

    debugPrint('📋 Version metadata updated: v$version ($updatedCount exercises updated)');
  }

  /// Crea metadata per ricerca ottimizzata
  Future<void> _createSearchMetadata(List<Exercise> exercises) async {
    // Analizza i dati per creare indici
    final focusGroups = <String, int>{};
    final equipmentTypes = <String, int>{};
    final difficultyLevels = <String, int>{};

    for (final exercise in exercises) {
      // Conta focus
      for (final focus in exercise.focus) {
        focusGroups[focus] = (focusGroups[focus] ?? 0) + 1;
      }

      // Conta attrezzature
      equipmentTypes[exercise.attrezzatura] = (equipmentTypes[exercise.attrezzatura] ?? 0) + 1;

      // Conta difficoltà
      difficultyLevels[exercise.difficolta] = (difficultyLevels[exercise.difficolta] ?? 0) + 1;
    }

    await _firestore.collection('exercise_metadata').doc('search_index').set({
      'focusGroups': focusGroups,
      'equipmentTypes': equipmentTypes,
      'difficultyLevels': difficultyLevels,
      'totalExercises': exercises.length,
      'lastIndexed': FieldValue.serverTimestamp(),
    });

    debugPrint('🔍 Search metadata created');
  }

  /// Verifica se i dati dell'esercizio sono validi
  bool _isValidExerciseData(Map<String, dynamic> data) {
    final requiredFields = ['id', 'nome', 'focus', 'difficolta', 'attrezzatura'];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return false;
      }
    }

    return true;
  }

  /// Ottieni statistiche della collection
  Future<Map<String, dynamic>> getCollectionStats() async {
    try {
      final exerciseCount = await _getExercisesCount();

      final versionDoc = await _firestore
          .collection('exercise_metadata')
          .doc('version_info')
          .get();

      final searchDoc = await _firestore
          .collection('exercise_metadata')
          .doc('search_index')
          .get();

      return {
        'exerciseCount': exerciseCount,
        'hasVersionMetadata': versionDoc.exists,
        'hasSearchIndex': searchDoc.exists,
        'versionInfo': versionDoc.exists ? versionDoc.data() : null,
        'searchIndex': searchDoc.exists ? searchDoc.data() : null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

/// Risultato delle operazioni batch
class BatchWriteResult {

  BatchWriteResult({required this.batchCount});
  final int batchCount;
}