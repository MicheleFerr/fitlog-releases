/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Provider per gestire l'inizializzazione Firebase degli esercizi
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/firebase_init_service.dart';
import 'package:gymbro_flutter_new/features/admin/domain/entities/firebase_init_result.dart';

/// Provider per il servizio di inizializzazione Firebase
final firebaseInitServiceProvider = Provider<FirebaseInitService>((ref) {
  return FirebaseInitService();
});

/// Provider per lo stato dell'inizializzazione
final firebaseInitStateProvider = StateNotifierProvider<FirebaseInitNotifier, FirebaseInitState>((ref) {
  final service = ref.watch(firebaseInitServiceProvider);
  return FirebaseInitNotifier(service);
});

/// Provider per le statistiche della collection
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final collectionStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.watch(firebaseInitServiceProvider);
  return service.getCollectionStats();
});

/// Notifier per gestire lo stato dell'inizializzazione
class FirebaseInitNotifier extends StateNotifier<FirebaseInitState> {

  FirebaseInitNotifier(this._service) : super(const FirebaseInitState.idle());
  final FirebaseInitService _service;

  /// Inizializza la collection exercises con i dati dal JSON
  Future<void> initializeExercises({
    bool overwriteExisting = false,
    String? specificVersion,
  }) async {
    state = const FirebaseInitState.loading();

    try {
      final result = await _service.initializeExercisesCollection(
        overwriteExisting: overwriteExisting,
        specificVersion: specificVersion,
      );

      if (result.success) {
        state = FirebaseInitState.success(result);
      } else {
        state = FirebaseInitState.error(result.error ?? 'Unknown error');
      }
    } catch (e) {
      state = FirebaseInitState.error(e.toString());
    }
  }

  /// Aggiorna esercizi specifici
  Future<void> updateSpecificExercises({
    required List<String> exerciseIds,
    String? newVersion,
  }) async {
    state = const FirebaseInitState.loading();

    try {
      final result = await _service.updateSpecificExercises(
        exerciseIds: exerciseIds,
        newVersion: newVersion,
      );

      if (result.success) {
        state = FirebaseInitState.success(result);
      } else {
        state = FirebaseInitState.error(result.error ?? 'Update failed');
      }
    } catch (e) {
      state = FirebaseInitState.error(e.toString());
    }
  }

  /// Verifica l'integrità dei dati
  Future<void> verifyDataIntegrity() async {
    state = const FirebaseInitState.loading();

    try {
      final result = await _service.verifyDataIntegrity();

      if (result.success) {
        state = FirebaseInitState.success(result);
      } else {
        state = FirebaseInitState.error(result.error ?? 'Verification failed');
      }
    } catch (e) {
      state = FirebaseInitState.error(e.toString());
    }
  }

  /// Risolve i dati mancanti
  Future<void> fixMissingData() async {
    state = const FirebaseInitState.loading();

    try {
      final result = await _service.fixMissingData();

      if (result.success) {
        state = FirebaseInitState.success(result);
      } else {
        state = FirebaseInitState.error(result.error ?? 'Fix failed');
      }
    } catch (e) {
      state = FirebaseInitState.error(e.toString());
    }
  }

  /// Reset dello stato
  void resetState() {
    state = const FirebaseInitState.idle();
  }
}

/// Stati possibili dell'inizializzazione Firebase
sealed class FirebaseInitState {
  const FirebaseInitState();

  const factory FirebaseInitState.idle() = FirebaseInitIdle;
  const factory FirebaseInitState.loading() = FirebaseInitLoading;
  const factory FirebaseInitState.success(FirebaseInitResult result) = FirebaseInitSuccess;
  const factory FirebaseInitState.error(String message) = FirebaseInitError;
}

class FirebaseInitIdle extends FirebaseInitState {
  const FirebaseInitIdle();
}

class FirebaseInitLoading extends FirebaseInitState {
  const FirebaseInitLoading();
}

class FirebaseInitSuccess extends FirebaseInitState {
  const FirebaseInitSuccess(this.result);
  final FirebaseInitResult result;
}

class FirebaseInitError extends FirebaseInitState {
  const FirebaseInitError(this.message);
  final String message;
}

/// Provider helper per controllare se Firebase è già inizializzato
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final isFirebaseInitializedProvider = FutureProvider.autoDispose<bool>((ref) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Controlla se esiste la collection exercise_metadata
    final versionDoc = await firestore
        .collection('exercise_metadata')
        .doc('version_info')
        .get();

    if (!versionDoc.exists) return false;

    // Controlla se ci sono esercizi
    final exerciseSnapshot = await firestore
        .collection('exercises')
        .limit(1)
        .get();

    return exerciseSnapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
});

/// Provider per ottenere la versione corrente
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final currentFirebaseVersionProvider = FutureProvider.autoDispose<String?>((ref) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final versionDoc = await firestore
        .collection('exercise_metadata')
        .doc('version_info')
        .get();

    if (!versionDoc.exists) return null;

    final data = versionDoc.data();
    return data?['version'] as String?;
  } catch (e) {
    return null;
  }
});