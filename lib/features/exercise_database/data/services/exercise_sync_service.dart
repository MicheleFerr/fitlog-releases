/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/services
/// 🎯 Feature: exercise_database
/// 🔧 Type: service
///
/// Servizio per sincronizzazione automatica e gestione aggiornamenti esercizi
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_version_service.dart';

class ExerciseSyncService {

  ExerciseSyncService({
    required HybridExerciseRepository repository,
    required ExerciseVersionService versionService,
  }) : _repository = repository,
       _versionService = versionService;
  final HybridExerciseRepository _repository;
  final ExerciseVersionService _versionService;

  static const String _lastSyncKey = 'exercise_last_sync';
  static const String _autoSyncEnabledKey = 'exercise_auto_sync_enabled';
  static const String _syncFrequencyKey = 'exercise_sync_frequency';

  static const Duration _defaultSyncInterval = Duration(hours: 6);
  static const Duration _retryDelay = Duration(minutes: 5);
  static const int _maxRetries = 3;

  Timer? _syncTimer;
  Timer? _retryTimer;
  StreamSubscription? _connectivitySubscription;

  final StreamController<SyncEvent> _syncEventController = StreamController.broadcast();
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  bool _isInitialized = false;
  bool _isSyncing = false;
  int _retryCount = 0;

  /// Inizializza il servizio di sincronizzazione
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _versionService.initialize();

      // Controlla se auto-sync è abilitato
      final autoSyncEnabled = await isAutoSyncEnabled();
      if (autoSyncEnabled) {
        await _startAutoSync();
      }

      // Monitora cambiamenti di connettività
      _setupConnectivityListener();

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ ExerciseSyncService initialized');
      }

      // Sincronizzazione iniziale se necessario
      await _performInitialSyncIfNeeded();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize ExerciseSyncService: $e');
      }
      rethrow;
    }
  }

  /// Esegue sincronizzazione manuale
  Future<SyncResult> performManualSync() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        timestamp: DateTime.now(),
      );
    }

    return _performSync(isManual: true);
  }

  /// Verifica connettività e esegue sync se necessario
  Future<void> syncIfConnected() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    // connectivity_plus 7.x returns List<ConnectivityResult>
    if (connectivityResults.contains(ConnectivityResult.none) ||
        connectivityResults.isEmpty) {
      if (kDebugMode) {
        debugPrint('📵 No internet connection, skipping sync');
      }
      return;
    }

    await _performSync();
  }

  /// Abilita/disabilita sincronizzazione automatica
  Future<void> setAutoSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncEnabledKey, enabled);

    if (enabled) {
      await _startAutoSync();
    } else {
      await _stopAutoSync();
    }

    if (kDebugMode) {
      debugPrint('⚙️ Auto-sync ${enabled ? "enabled" : "disabled"}');
    }
  }

  /// Controlla se auto-sync è abilitato
  Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncEnabledKey) ?? true; // Default: abilitato
  }

  /// Imposta frequenza di sincronizzazione
  Future<void> setSyncFrequency(Duration frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncFrequencyKey, frequency.inHours);

    // Riavvia timer con nuova frequenza
    if (await isAutoSyncEnabled()) {
      await _stopAutoSync();
      await _startAutoSync();
    }

    if (kDebugMode) {
      debugPrint('⏱️ Sync frequency set to ${frequency.inHours} hours');
    }
  }

  /// Ottiene frequenza di sincronizzazione
  Future<Duration> getSyncFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final hours = prefs.getInt(_syncFrequencyKey) ?? _defaultSyncInterval.inHours;
    return Duration(hours: hours);
  }

  /// Ottiene timestamp dell'ultima sincronizzazione
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Controlla se è necessaria una sincronizzazione
  Future<bool> needsSync() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final frequency = await getSyncFrequency();
    final now = DateTime.now();

    return now.difference(lastSync) >= frequency;
  }

  /// Esegue sincronizzazione
  Future<SyncResult> _performSync({bool isManual = false}) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    final startTime = DateTime.now();

    try {
      _syncEventController.add(SyncEvent(
        type: SyncEventType.started,
        timestamp: startTime,
        isManual: isManual,
      ));

      if (kDebugMode) {
        debugPrint('🔄 Starting exercise sync${isManual ? " (manual)" : ""}...');
      }

      // 1. Controlla aggiornamenti disponibili
      final versionCheck = await _versionService.checkForUpdates();

      if (!versionCheck.hasUpdates && !isManual) {
        if (kDebugMode) {
          debugPrint('✅ No updates available');
        }

        await _updateLastSyncTime();
        _retryCount = 0;

        final result = SyncResult(
          success: true,
          timestamp: DateTime.now(),
          localVersion: versionCheck.localVersion,
          remoteVersion: versionCheck.remoteVersion?.version,
          hasUpdates: false,
        );

        _syncEventController.add(SyncEvent(
          type: SyncEventType.completed,
          timestamp: DateTime.now(),
          isManual: isManual,
          result: result,
        ));

        return result;
      }

      // 2. Esegue aggiornamento
      if (kDebugMode) {
        debugPrint('📥 Applying updates...');
      }
      final updateSuccess = await _repository.checkAndApplyUpdates();

      if (!updateSuccess) {
        throw Exception('Failed to apply updates');
      }

      // 3. Verifica successo
      final finalVersionCheck = await _versionService.checkForUpdates();

      await _updateLastSyncTime();
      _retryCount = 0;

      final result = SyncResult(
        success: true,
        timestamp: DateTime.now(),
        localVersion: finalVersionCheck.localVersion,
        remoteVersion: finalVersionCheck.remoteVersion?.version,
        hasUpdates: versionCheck.hasUpdates,
        exerciseCount: finalVersionCheck.remoteVersion?.totalExercises,
      );

      _syncEventController.add(SyncEvent(
        type: SyncEventType.completed,
        timestamp: DateTime.now(),
        isManual: isManual,
        result: result,
      ));

      if (kDebugMode) {
        debugPrint('✅ Sync completed successfully in ${DateTime.now().difference(startTime).inSeconds}s');
      }
      return result;

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sync failed: $e');
      }

      final result = SyncResult(
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );

      _syncEventController.add(SyncEvent(
        type: SyncEventType.failed,
        timestamp: DateTime.now(),
        isManual: isManual,
        result: result,
        error: e.toString(),
      ));

      // Programma retry automatico se non è sync manuale
      if (!isManual) {
        _scheduleRetry();
      }

      return result;

    } finally {
      _isSyncing = false;
    }
  }

  /// Esegue sincronizzazione iniziale se necessario
  Future<void> _performInitialSyncIfNeeded() async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) {
        if (kDebugMode) {
          debugPrint('🚀 Performing initial sync...');
        }
        await _performSync();
      } else if (await needsSync()) {
        if (kDebugMode) {
          debugPrint('⏰ Scheduled sync needed');
        }
        await _performSync();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Initial sync failed: $e');
      }
    }
  }

  /// Avvia sincronizzazione automatica
  Future<void> _startAutoSync() async {
    await _stopAutoSync(); // Ferma timer esistente

    final frequency = await getSyncFrequency();

    _syncTimer = Timer.periodic(frequency, (timer) async {
      if (await needsSync()) {
        await syncIfConnected();
      }
    });

    if (kDebugMode) {
      debugPrint('🔄 Auto-sync started (every ${frequency.inHours}h)');
    }
  }

  /// Ferma sincronizzazione automatica
  Future<void> _stopAutoSync() async {
    _syncTimer?.cancel();
    _syncTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    if (kDebugMode) {
      debugPrint('⏹️ Auto-sync stopped');
    }
  }

  /// Programma retry dopo errore
  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      if (kDebugMode) {
        debugPrint('❌ Max retries reached, giving up');
      }
      return;
    }

    _retryCount++;
    final delay = Duration(milliseconds: _retryDelay.inMilliseconds * _retryCount);

    if (kDebugMode) {
      debugPrint('🔄 Scheduling retry #$_retryCount in ${delay.inMinutes}m');
    }

    _retryTimer = Timer(delay, () async {
      await syncIfConnected();
    });
  }

  /// Setup listener per cambiamenti di connettività
  void _setupConnectivityListener() {
    // connectivity_plus 7.x: onConnectivityChanged emits List<ConnectivityResult>
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && results.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('📶 Connection restored, checking for sync');
        }
        Timer(const Duration(seconds: 2), () => syncIfConnected());
      }
    });
  }

  /// Aggiorna timestamp ultima sincronizzazione
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Cleanup delle risorse
  Future<void> dispose() async {
    await _stopAutoSync();
    await _connectivitySubscription?.cancel();
    await _syncEventController.close();
    _isInitialized = false;
    if (kDebugMode) {
      debugPrint('🗑️ ExerciseSyncService disposed');
    }
  }
}

/// Risultato di sincronizzazione
class SyncResult {

  const SyncResult({
    required this.success,
    this.error,
    required this.timestamp,
    this.localVersion,
    this.remoteVersion,
    this.hasUpdates = false,
    this.exerciseCount,
  });
  final bool success;
  final String? error;
  final DateTime timestamp;
  final String? localVersion;
  final String? remoteVersion;
  final bool hasUpdates;
  final int? exerciseCount;

  @override
  String toString() {
    return 'SyncResult(success: $success, hasUpdates: $hasUpdates, versions: $localVersion → $remoteVersion)';
  }
}

/// Evento di sincronizzazione
class SyncEvent {

  const SyncEvent({
    required this.type,
    required this.timestamp,
    this.isManual = false,
    this.result,
    this.error,
  });
  final SyncEventType type;
  final DateTime timestamp;
  final bool isManual;
  final SyncResult? result;
  final String? error;
}

/// Tipo di evento di sincronizzazione
enum SyncEventType {
  started,
  completed,
  failed,
}