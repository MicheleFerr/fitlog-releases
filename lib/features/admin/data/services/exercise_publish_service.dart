/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/data/services
/// 🎯 Feature: admin
/// 🔧 Type: service
///
/// Service per pubblicazione nuove versioni del database esercizi su Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/utils/exercise_json_loader.dart';

class ExercisePublishService {
  ExercisePublishService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _exercisesEnCollection = 'exercises_en';
  static const String _exercisesItCollection = 'exercises_it';
  static const String _metadataCollection = 'exercises_metadata';
  static const String _versionDocId = 'version_info';

  /// Pubblica nuova versione del database esercizi da asset JSON (EN + IT)
  Future<void> publishNewVersion({
    required String version,
    required List<String> changelogEntries,
    required bool isRequired,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 Publishing new exercise database version: $version');
      }

      // 1. Carica esercizi usando ExerciseJsonLoader (nuova struttura folder-based)
      final exercisesEn = await ExerciseJsonLoader.loadExercises('en');
      final exercisesIt = await ExerciseJsonLoader.loadExercises('it');
      if (kDebugMode) {
        debugPrint('📋 Loaded ${exercisesEn.length} EN exercises, ${exercisesIt.length} IT exercises');
      }

      // 2. Upload esercizi in batch paralleli per ENTRAMBE le lingue
      await Future.wait([
        _uploadExercisesToFirestore(exercisesEn, _exercisesEnCollection),
        _uploadExercisesToFirestore(exercisesIt, _exercisesItCollection),
      ]);
      if (kDebugMode) {
        debugPrint('✅ Uploaded exercises to Firestore (EN + IT collections)');
      }

      // 3. Aggiorna metadata versione (shared per entrambe le lingue)
      await _updateVersionMetadata(
        version: version,
        totalExercisesEn: exercisesEn.length,
        totalExercisesIt: exercisesIt.length,
        changelogEntries: changelogEntries,
        isRequired: isRequired,
      );
      if (kDebugMode) {
        debugPrint('✅ Updated version metadata');
      }

      if (kDebugMode) {
        debugPrint('🎉 Successfully published version $version (EN: ${exercisesEn.length}, IT: ${exercisesIt.length})');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to publish version: $e');
      }
      rethrow;
    }
  }

  /// Upload esercizi a Firestore in batch paralleli (performance ottimale)
  Future<void> _uploadExercisesToFirestore(
    List<Map<String, dynamic>> exercises,
    String collectionName,
  ) async {
    try {
      const int batchSize = 100; // Safe batch size (well under 10 MiB limit)
      final List<WriteBatch> batches = [];

      // Crea batch da 100 documenti ciascuno
      for (int i = 0; i < exercises.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize < exercises.length) ? i + batchSize : exercises.length;

        for (int j = i; j < end; j++) {
          final exercise = exercises[j];
          final docId = exercise['id'] as String? ?? 'ex_${j.toString().padLeft(4, '0')}';

          batch.set(
            _firestore.collection(collectionName).doc(docId),
            exercise,
            SetOptions(merge: true), // Merge per non sovrascrivere custom fields
          );
        }

        batches.add(batch);
      }

      if (kDebugMode) {
        debugPrint('📦 Created ${batches.length} batches for ${exercises.length} exercises ($collectionName)');
      }

      // Commit tutti i batch IN PARALLELO (13x più veloce che sequenziale)
      await Future.wait(
        batches.map((batch) => batch.commit()),
      );

      if (kDebugMode) {
        debugPrint('✅ Committed ${batches.length} batches to $collectionName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to upload exercises to $collectionName: $e');
      }
      rethrow;
    }
  }

  /// Aggiorna metadata versione con changelog (shared per EN + IT)
  Future<void> _updateVersionMetadata({
    required String version,
    required int totalExercisesEn,
    required int totalExercisesIt,
    required List<String> changelogEntries,
    required bool isRequired,
  }) async {
    try {
      final docRef = _firestore.collection(_metadataCollection).doc(_versionDocId);

      // Ottieni documento esistente per preservare changelog precedente
      final existingDoc = await docRef.get();
      final List<dynamic> existingChangelog = existingDoc.exists
          ? (existingDoc.data()?['changelog'] as List<dynamic>? ?? [])
          : [];

      // Crea nuovo entry changelog
      // NOTA: Usa Timestamp.now() invece di FieldValue.serverTimestamp()
      // perché serverTimestamp() non è supportato dentro array
      final newChangelogEntry = {
        'version': version,
        'date': Timestamp.now(),
        'changes': changelogEntries,
        'is_required': isRequired,
      };

      // Prepend nuovo changelog (newest first)
      final updatedChangelog = [newChangelogEntry, ...existingChangelog];

      // Calcola bundle size approssimativo (per UI)
      final bundleSizeMbEn = (totalExercisesEn * 2) / 1000; // ~2KB per exercise
      final bundleSizeMbIt = (totalExercisesIt * 2) / 1000;

      // Update metadata document (con info per entrambe le lingue)
      await docRef.set(
        {
          'current_version': version,
          'last_updated': FieldValue.serverTimestamp(),
          'total_exercises_en': totalExercisesEn,
          'total_exercises_it': totalExercisesIt,
          'bundle_size_mb_en': bundleSizeMbEn,
          'bundle_size_mb_it': bundleSizeMbIt,
          'changelog': updatedChangelog,
          'status': 'published',
        },
        SetOptions(merge: true),
      );

      if (kDebugMode) {
        debugPrint('✅ Version metadata updated to $version (EN: $totalExercisesEn, IT: $totalExercisesIt)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to update version metadata: $e');
      }
      rethrow;
    }
  }

  /// Ottiene versione corrente da Firestore
  /// Restituisce '1.0.0' come default per prima pubblicazione
  Future<String> getCurrentVersion() async {
    try {
      final doc = await _firestore
          .collection(_metadataCollection)
          .doc(_versionDocId)
          .get();

      if (!doc.exists) return '1.0.0'; // Default per prima pubblicazione

      return doc.data()?['current_version'] as String? ?? '1.0.0';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get current version: $e');
      }
      return '1.0.0'; // Fallback sicuro
    }
  }

  /// Ottiene metadata completo della versione
  Future<Map<String, dynamic>?> getVersionMetadata() async {
    try {
      final doc = await _firestore
          .collection(_metadataCollection)
          .doc(_versionDocId)
          .get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get version metadata: $e');
      }
      return null;
    }
  }

  /// Stream per monitorare cambiamenti metadata in real-time
  Stream<Map<String, dynamic>?> watchVersionMetadata() {
    return _firestore
        .collection(_metadataCollection)
        .doc(_versionDocId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  /// Auto-increment versione (1.0.0 → 1.0.1, 1.0.9 → 1.1.0, etc.)
  String incrementVersion(String currentVersion) {
    try {
      final parts = currentVersion.split('.').map(int.parse).toList();
      if (parts.length != 3) throw const FormatException('Invalid version format');

      // Increment patch version
      parts[2] += 1;

      // Handle overflow (1.0.9 → 1.1.0)
      if (parts[2] >= 10) {
        parts[2] = 0;
        parts[1] += 1;
      }

      // Handle minor overflow (1.9.0 → 2.0.0)
      if (parts[1] >= 10) {
        parts[1] = 0;
        parts[0] += 1;
      }

      return parts.join('.');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to increment version: $e');
      }
      return '1.0.0'; // Fallback
    }
  }
}
