/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/data/services
/// 🎯 Feature: admin
/// 🔧 Type: service
///
/// Servizio per gestione completa database esercizi con editing veloce
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Enum per tipologia attrezzatura con flag peso richiesto
enum EquipmentType {
  bodyweight('Corpo Libero', false),
  barbell('Bilanciere', true),
  dumbbells('Manubri', true),
  cables('Cavi', true),
  machine('Macchina', true),
  kettlebell('Kettlebell', true),
  bands('Elastici', false),
  trx('TRX', false),
  various('Vario', true);

  final String displayName;
  final bool requiresWeight;

  const EquipmentType(this.displayName, this.requiresWeight);

  static EquipmentType fromString(String value) {
    return EquipmentType.values.firstWhere(
      (e) => e.displayName == value,
      orElse: () => EquipmentType.various,
    );
  }
}

/// Risultato operazione database
class DatabaseOperationResult {

  DatabaseOperationResult({
    required this.success,
    required this.message,
    this.data,
    this.affectedCount,
  });
  final bool success;
  final String message;
  final dynamic data;
  final int? affectedCount;
}

class DatabaseManagerService {

  DatabaseManagerService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  // Cache per performance
  List<Exercise>? _cachedExercises;
  DateTime? _lastCacheUpdate;
  static const _cacheValidityDuration = Duration(minutes: 5);

  /// Ottieni tutti gli esercizi con opzioni di filtro
  Future<List<Exercise>> getAllExercises({
    String? searchQuery,
    String? difficulty,
    String? equipment,
    List<String>? focusMuscles,
    String? exerciseType,
    bool forceRefresh = false,
  }) async {
    try {
      // Usa cache se valida e non forzato refresh
      if (!forceRefresh && _isCacheValid()) {
        debugPrint('📦 Using cached exercises');
        return _filterExercises(
          _cachedExercises!,
          searchQuery: searchQuery,
          difficulty: difficulty,
          equipment: equipment,
          focusMuscles: focusMuscles,
          exerciseType: exerciseType,
        );
      }

      debugPrint('🔄 Fetching exercises from Firebase (exercises_it)');
      Query<Map<String, dynamic>> query = _firestore.collection('exercises_it');

      // Applica filtri Firebase dove possibile per performance
      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.where('difficolta', isEqualTo: difficulty);
      }
      if (equipment != null && equipment.isNotEmpty) {
        query = query.where('attrezzatura', isEqualTo: equipment);
      }

      final snapshot = await query.get();
      final exercises = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Assicura che l'ID sia presente
        return Exercise.fromJson(data);
      }).toList();

      // Aggiorna cache
      _cachedExercises = exercises;
      _lastCacheUpdate = DateTime.now();

      // Applica filtri locali aggiuntivi
      return _filterExercises(
        exercises,
        searchQuery: searchQuery,
        focusMuscles: focusMuscles,
        exerciseType: exerciseType,
      );

    } catch (e) {
      debugPrint('❌ Error fetching exercises: $e');
      return [];
    }
  }

  /// Filtra esercizi localmente
  List<Exercise> _filterExercises(
    List<Exercise> exercises, {
    String? searchQuery,
    String? difficulty,
    String? equipment,
    List<String>? focusMuscles,
    String? exerciseType,
  }) {
    var filtered = exercises;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
        e.nome.toLowerCase().contains(query) ||
        e.focus.any((f) => f.toLowerCase().contains(query)) ||
        e.muscoliSecondari.any((m) => m.toLowerCase().contains(query))
      ).toList();
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      filtered = filtered.where((e) => e.difficolta == difficulty).toList();
    }

    if (equipment != null && equipment.isNotEmpty) {
      filtered = filtered.where((e) => e.attrezzatura == equipment).toList();
    }

    if (focusMuscles != null && focusMuscles.isNotEmpty) {
      filtered = filtered.where((e) =>
        e.focus.any((f) => focusMuscles.contains(f))
      ).toList();
    }

    if (exerciseType != null && exerciseType.isNotEmpty) {
      filtered = filtered.where((e) => e.tipoEsercizio == exerciseType).toList();
    }

    return filtered;
  }

  /// Update veloce di un singolo campo
  Future<DatabaseOperationResult> quickUpdateField({
    required String exerciseId,
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      debugPrint('⚡ Quick update: $exerciseId.$fieldName = $value');

      await _firestore.collection('exercises_it').doc(exerciseId).update({
        fieldName: value,
        'lastModified': FieldValue.serverTimestamp(),
      });

      // Invalida cache
      _invalidateCache();

      // Se è stato cambiato attrezzatura a corpo libero, logga per tracking
      if (fieldName == 'attrezzatura' && value == 'Corpo Libero') {
        debugPrint('🏃 Exercise $exerciseId set to bodyweight - weights disabled');
      }

      return DatabaseOperationResult(
        success: true,
        message: 'Campo aggiornato',
        affectedCount: 1,
      );

    } catch (e) {
      debugPrint('❌ Quick update failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore aggiornamento: $e',
      );
    }
  }

  /// Update multiplo (bulk edit)
  Future<DatabaseOperationResult> bulkUpdateField({
    required List<String> exerciseIds,
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      debugPrint('📦 Bulk update: ${exerciseIds.length} exercises');

      final batch = _firestore.batch();

      for (final id in exerciseIds) {
        final docRef = _firestore.collection('exercises').doc(id);
        batch.update(docRef, {
          fieldName: value,
          'lastModified': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _invalidateCache();

      return DatabaseOperationResult(
        success: true,
        message: 'Aggiornati ${exerciseIds.length} esercizi',
        affectedCount: exerciseIds.length,
      );

    } catch (e) {
      debugPrint('❌ Bulk update failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore bulk update: $e',
      );
    }
  }

  /// Update completo esercizio
  Future<DatabaseOperationResult> updateExercise(Exercise exercise) async {
    try {
      debugPrint('📝 Updating exercise: ${exercise.id}');

      final data = exercise.toJson();
      data['lastModified'] = FieldValue.serverTimestamp();

      await _firestore.collection('exercises').doc(exercise.id).set(data);
      _invalidateCache();

      return DatabaseOperationResult(
        success: true,
        message: 'Esercizio aggiornato',
        data: exercise,
      );

    } catch (e) {
      debugPrint('❌ Update exercise failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore aggiornamento: $e',
      );
    }
  }

  /// Aggiungi nuovo esercizio
  Future<DatabaseOperationResult> addExercise(Exercise exercise) async {
    try {
      debugPrint('➕ Adding new exercise: ${exercise.nome}');

      final data = exercise.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['lastModified'] = FieldValue.serverTimestamp();

      await _firestore.collection('exercises').add(data);
      _invalidateCache();

      return DatabaseOperationResult(
        success: true,
        message: 'Esercizio aggiunto',
        data: exercise,
      );

    } catch (e) {
      debugPrint('❌ Add exercise failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore aggiunta: $e',
      );
    }
  }

  /// Elimina esercizio
  Future<DatabaseOperationResult> deleteExercise(String exerciseId) async {
    try {
      debugPrint('🗑️ Deleting exercise: $exerciseId');

      await _firestore.collection('exercises').doc(exerciseId).delete();
      _invalidateCache();

      return DatabaseOperationResult(
        success: true,
        message: 'Esercizio eliminato',
        affectedCount: 1,
      );

    } catch (e) {
      debugPrint('❌ Delete exercise failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore eliminazione: $e',
      );
    }
  }

  /// Elimina multipli esercizi
  Future<DatabaseOperationResult> bulkDeleteExercises(List<String> exerciseIds) async {
    try {
      debugPrint('🗑️ Bulk deleting: ${exerciseIds.length} exercises');

      final batch = _firestore.batch();

      for (final id in exerciseIds) {
        final docRef = _firestore.collection('exercises').doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
      _invalidateCache();

      return DatabaseOperationResult(
        success: true,
        message: 'Eliminati ${exerciseIds.length} esercizi',
        affectedCount: exerciseIds.length,
      );

    } catch (e) {
      debugPrint('❌ Bulk delete failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore eliminazione multipla: $e',
      );
    }
  }

  /// Export esercizi in JSON
  Future<String> exportToJson({List<String>? exerciseIds}) async {
    try {
      debugPrint('📤 Exporting exercises to JSON');

      List<Exercise> exercises;

      if (exerciseIds != null && exerciseIds.isNotEmpty) {
        // Export solo selezionati
        exercises = [];
        for (final id in exerciseIds) {
          final doc = await _firestore.collection('exercises').doc(id).get();
          if (doc.exists) {
            final data = doc.data()!;
            data['id'] = doc.id;
            exercises.add(Exercise.fromJson(data));
          }
        }
      } else {
        // Export tutti
        exercises = await getAllExercises(forceRefresh: true);
      }

      final jsonData = {
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'metadata': {
          'version': '2.0.0',
          'exportDate': DateTime.now().toIso8601String(),
          'totalExercises': exercises.length,
          'bodyweightExercises': exercises.where((e) =>
            e.attrezzatura == 'Corpo Libero'
          ).length,
          'weightedExercises': exercises.where((e) =>
            e.attrezzatura != 'Corpo Libero' &&
            e.attrezzatura != 'Elastici' &&
            e.attrezzatura != 'TRX'
          ).length,
        },
      };

      return const JsonEncoder.withIndent('  ').convert(jsonData);

    } catch (e) {
      debugPrint('❌ Export failed: $e');
      throw Exception('Export fallito: $e');
    }
  }

  /// Import esercizi da JSON
  Future<DatabaseOperationResult> importFromJson(String jsonString) async {
    try {
      debugPrint('📥 Importing exercises from JSON');

      final jsonData = json.decode(jsonString);
      final exercisesList = jsonData['exercises'] as List;

      final batch = _firestore.batch();
      int importCount = 0;

      for (final exerciseJson in exercisesList) {
        final exercise = Exercise.fromJson(exerciseJson as Map<String, dynamic>);
        final docRef = _firestore.collection('exercises').doc(exercise.id);
        batch.set(docRef, exercise.toJson(), SetOptions(merge: true));
        importCount++;

        // Firestore batch limit
        if (importCount % 500 == 0) {
          await batch.commit();
        }
      }

      await batch.commit();
      _invalidateCache();

      return DatabaseOperationResult(
        success: true,
        message: 'Importati $importCount esercizi',
        affectedCount: importCount,
      );

    } catch (e) {
      debugPrint('❌ Import failed: $e');
      return DatabaseOperationResult(
        success: false,
        message: 'Errore import: $e',
      );
    }
  }

  /// Ottieni statistiche database
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final exercises = await getAllExercises(forceRefresh: true);

      return {
        'totalExercises': exercises.length,
        'byDifficulty': {
          'Principiante': exercises.where((e) => e.difficolta == 'Principiante').length,
          'Intermedio': exercises.where((e) => e.difficolta == 'Intermedio').length,
          'Avanzato': exercises.where((e) => e.difficolta == 'Avanzato').length,
        },
        'byEquipment': {
          for (var eq in EquipmentType.values)
            eq.displayName: exercises.where((e) => e.attrezzatura == eq.displayName).length,
        },
        'bodyweightCount': exercises.where((e) =>
          e.attrezzatura == 'Corpo Libero'
        ).length,
        'uniqueMuscles': exercises
          .expand((e) => e.focus)
          .toSet()
          .length,
      };
    } catch (e) {
      debugPrint('❌ Stats failed: $e');
      return {};
    }
  }

  /// Controlla se un esercizio richiede peso
  bool requiresWeight(String equipment) {
    final type = EquipmentType.fromString(equipment);
    return type.requiresWeight;
  }

  /// Invalida cache
  void _invalidateCache() {
    _cachedExercises = null;
    _lastCacheUpdate = null;
  }

  /// Controlla se cache è valida
  bool _isCacheValid() {
    if (_cachedExercises == null || _lastCacheUpdate == null) {
      return false;
    }
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidityDuration;
  }

  /// Ottieni valori unici per dropdown
  Future<ExerciseDropdownValues> getDropdownValues() async {
    final exercises = await getAllExercises();

    return ExerciseDropdownValues(
      difficulties: ['Principiante', 'Intermedio', 'Avanzato'],
      equipments: EquipmentType.values.map((e) => e.displayName).toList(),
      exerciseTypes: exercises.map((e) => e.tipoEsercizio).toSet().toList()..sort(),
      movementPatterns: exercises.map((e) => e.patternMovimento).toSet().toList()..sort(),
      muscles: exercises.expand((e) => e.focus).toSet().toList()..sort(),
      repRanges: ['1-5', '6-8', '8-12', '12-15', '15-20', '20+'],
      tutOptions: ['1-0-1-0', '2-0-1-0', '2-1-2-0', '3-0-1-0', '3-1-2-0', '4-0-1-0', 'ISO', 'EXP'],
    );
  }
}

/// Valori per dropdown
class ExerciseDropdownValues {

  ExerciseDropdownValues({
    required this.difficulties,
    required this.equipments,
    required this.exerciseTypes,
    required this.movementPatterns,
    required this.muscles,
    required this.repRanges,
    required this.tutOptions,
  });
  final List<String> difficulties;
  final List<String> equipments;
  final List<String> exerciseTypes;
  final List<String> movementPatterns;
  final List<String> muscles;
  final List<String> repRanges;
  final List<String> tutOptions;
}