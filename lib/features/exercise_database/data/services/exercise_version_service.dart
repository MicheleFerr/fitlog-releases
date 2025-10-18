/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service
///
/// Service per gestione versioning e aggiornamenti del database esercizi
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ExerciseVersionService {

  ExerciseVersionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  static const String _metadataCollection = 'exercises_metadata';
  static const String _versionDocId = 'version_info';
  static const String _cacheBoxName = 'exercise_version_cache';

  late Box<Map> _cacheBox;
  bool _initialized = false;

  /// Inizializza il servizio
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _cacheBox = await Hive.openBox<Map>(_cacheBoxName);
      _initialized = true;
      debugPrint('✅ ExerciseVersionService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize ExerciseVersionService: $e');
      rethrow;
    }
  }

  /// Controlla se sono disponibili aggiornamenti
  Future<VersionCheckResult> checkForUpdates() async {
    await _ensureInitialized();

    try {
      // 1. Ottieni versione locale
      final localVersion = await getLocalVersion();

      // 2. Ottieni versione remota da Firebase
      final remoteVersion = await getRemoteVersion();

      if (remoteVersion == null) {
        return VersionCheckResult(
          hasUpdates: false,
          localVersion: localVersion,
          remoteVersion: null,
          status: VersionStatus.noRemoteVersion,
        );
      }

      // 3. Confronta versioni
      final hasUpdates = _isNewerVersion(remoteVersion.version, localVersion);

      debugPrint('🔍 Version check: Local=$localVersion, Remote=${remoteVersion.version}, HasUpdates=$hasUpdates');

      return VersionCheckResult(
        hasUpdates: hasUpdates,
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        status: hasUpdates ? VersionStatus.updateAvailable : VersionStatus.upToDate,
      );

    } catch (e) {
      debugPrint('❌ Failed to check for updates: $e');
      return VersionCheckResult(
        hasUpdates: false,
        localVersion: await getLocalVersion(),
        remoteVersion: null,
        status: VersionStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Ottiene la versione locale salvata
  Future<String> getLocalVersion() async {
    await _ensureInitialized();

    try {
      final cached = _cacheBox.get('local_version');
      if (cached != null && cached['version'] != null) {
        return cached['version'] as String;
      }

      // Se non c'è versione locale, usa la versione dell'app come fallback
      final packageInfo = await PackageInfo.fromPlatform();
      final fallbackVersion = '${packageInfo.version}-local';

      // Salva la versione di fallback
      await setLocalVersion(fallbackVersion);
      return fallbackVersion;

    } catch (e) {
      debugPrint('❌ Failed to get local version: $e');
      return '1.0.0-local';
    }
  }

  /// Imposta la versione locale
  Future<void> setLocalVersion(String version) async {
    await _ensureInitialized();

    try {
      await _cacheBox.put('local_version', {
        'version': version,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('📝 Local version set to: $version');
    } catch (e) {
      debugPrint('❌ Failed to set local version: $e');
    }
  }

  /// Ottiene la versione remota da Firebase
  Future<ExerciseVersionInfo?> getRemoteVersion() async {
    try {
      final doc = await _firestore
          .collection(_metadataCollection)
          .doc(_versionDocId)
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('⚠️ No remote version info found');
        return null;
      }

      final data = doc.data()!;
      return ExerciseVersionInfo.fromFirestore(data);

    } catch (e) {
      debugPrint('❌ Failed to get remote version: $e');
      return null;
    }
  }

  /// Stream per monitorare cambiamenti di versione
  Stream<VersionCheckResult> watchVersionChanges() async* {
    await _ensureInitialized();

    yield* _firestore
        .collection(_metadataCollection)
        .doc(_versionDocId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) {
        return VersionCheckResult(
          hasUpdates: false,
          localVersion: await getLocalVersion(),
          remoteVersion: null,
          status: VersionStatus.noRemoteVersion,
        );
      }

      final remoteVersion = ExerciseVersionInfo.fromFirestore(snapshot.data()!);
      final localVersion = await getLocalVersion();
      final hasUpdates = _isNewerVersion(remoteVersion.version, localVersion);

      return VersionCheckResult(
        hasUpdates: hasUpdates,
        localVersion: localVersion,
        remoteVersion: remoteVersion,
        status: hasUpdates ? VersionStatus.updateAvailable : VersionStatus.upToDate,
      );
    });
  }

  /// Salva metadata dopo un aggiornamento completato
  Future<void> markUpdateCompleted(String version, int exerciseCount) async {
    await _ensureInitialized();

    try {
      await setLocalVersion(version);

      await _cacheBox.put('last_update', {
        'version': version,
        'exercise_count': exerciseCount,
        'completed_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Update completed: v$version ($exerciseCount exercises)');
    } catch (e) {
      debugPrint('❌ Failed to mark update completed: $e');
    }
  }

  /// Ottiene informazioni sull'ultimo aggiornamento
  Future<Map<String, dynamic>?> getLastUpdateInfo() async {
    await _ensureInitialized();

    try {
      final data = _cacheBox.get('last_update');
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('❌ Failed to get last update info: $e');
      return null;
    }
  }

  /// Confronta due versioni (formato: "1.2.3")
  bool _isNewerVersion(String remoteVersion, String localVersion) {
    try {
      final remoteParts = remoteVersion.split('.').map(int.parse).toList();
      final localParts = localVersion.split('-')[0].split('.').map(int.parse).toList();

      // Assicura che entrambe abbiano 3 parti
      while (remoteParts.length < 3) {
        remoteParts.add(0);
      }
      while (localParts.length < 3) {
        localParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > localParts[i]) return true;
        if (remoteParts[i] < localParts[i]) return false;
      }

      return false; // Versioni uguali
    } catch (e) {
      debugPrint('❌ Failed to compare versions: $e');
      return false;
    }
  }

  /// Assicura che il servizio sia inizializzato
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Cleanup delle risorse
  Future<void> dispose() async {
    if (_initialized) {
      await _cacheBox.close();
      _initialized = false;
    }
  }
}

/// Informazioni sulla versione degli esercizi
class ExerciseVersionInfo {

  const ExerciseVersionInfo({
    required this.version,
    required this.lastUpdated,
    required this.totalExercises,
    required this.changelog,
  });

  factory ExerciseVersionInfo.fromFirestore(Map<String, dynamic> data) {
    return ExerciseVersionInfo(
      version: data['current_version'] as String? ?? '1.0.0',
      lastUpdated: (data['last_updated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalExercises: data['total_exercises'] as int? ?? 0,
      changelog: List<String>.from(data['changelog'] as List? ?? []),
    );
  }
  final String version;
  final DateTime lastUpdated;
  final int totalExercises;
  final List<String> changelog;

  Map<String, dynamic> toFirestore() {
    return {
      'current_version': version,
      'last_updated': Timestamp.fromDate(lastUpdated),
      'total_exercises': totalExercises,
      'changelog': changelog,
    };
  }
}

/// Risultato del controllo versione
class VersionCheckResult {

  const VersionCheckResult({
    required this.hasUpdates,
    required this.localVersion,
    required this.remoteVersion,
    required this.status,
    this.error,
  });
  final bool hasUpdates;
  final String localVersion;
  final ExerciseVersionInfo? remoteVersion;
  final VersionStatus status;
  final String? error;
}

/// Stato del controllo versione
enum VersionStatus {
  upToDate,
  updateAvailable,
  noRemoteVersion,
  error,
}