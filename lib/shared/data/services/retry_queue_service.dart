// ignore_for_file: sort_constructors_first

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/data/services
/// 🎯 Feature: shared
/// 🔧 Type: service
///
/// Servizio di retry queue con exponential backoff per gestire fallimenti
/// temporanei delle operazioni Firestore (es: offline, rate limits).
///
/// **BENEFICI**:
/// - Resilienza: Auto-retry su errori temporanei (network, rate limits)
/// - Affidabilità: Garantisce eventual consistency dei dati
/// - UX: Sync automatico quando torna online senza intervento utente
///
/// **ALGORITMO EXPONENTIAL BACKOFF**:
/// - Retry 1: 1 secondo
/// - Retry 2: 2 secondi
/// - Retry 3: 4 secondi
/// - Retry 4: 8 secondi
/// - Retry 5: 16 secondi (ultimo tentativo)
/// - Max backoff: 16 secondi
/// - Max retry attempts: 5
///
/// **ESEMPIO UTILIZZO**:
/// ```dart
/// final retryQueue = ref.read(retryQueueServiceProvider.notifier);
///
/// // Aggiungi operazione per retry automatico
/// await retryQueue.enqueueForRetry(
///   operation: batchOperation,
///   error: error,
/// );
///
/// // Il retry avverrà automaticamente con backoff esponenziale
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:gymbro_flutter_new/shared/data/services/firestore_batch_writer.dart';

/// Metadata per operazione in retry
///
/// Traccia tentativi, errori e timing per retry con exponential backoff.
class RetryMetadata {
  /// Operazione batch da ritentare
  final BatchOperation operation;

  /// Numero di tentativi effettuati
  final int attemptCount;

  /// Ultimo errore incontrato
  final Object lastError;

  /// Timestamp del prossimo retry
  final DateTime nextRetryAt;

  /// Timestamp della prima aggiunta alla queue
  final DateTime firstQueuedAt;

  RetryMetadata({
    required this.operation,
    required this.attemptCount,
    required this.lastError,
    required this.nextRetryAt,
    DateTime? firstQueuedAt,
  }) : firstQueuedAt = firstQueuedAt ?? DateTime.now();

  /// Copia con incremento tentativo e backoff esponenziale
  RetryMetadata withIncrementedAttempt({
    required Object error,
    required int backoffSeconds,
  }) {
    return RetryMetadata(
      operation: operation,
      attemptCount: attemptCount + 1,
      lastError: error,
      nextRetryAt: DateTime.now().add(Duration(seconds: backoffSeconds)),
      firstQueuedAt: firstQueuedAt,
    );
  }

  @override
  String toString() {
    return 'RetryMetadata('
        '${operation.collection}/${operation.documentId}, '
        'attempt: $attemptCount, '
        'nextRetry: $nextRetryAt'
        ')';
  }
}

/// Notifier per RetryQueueService
///
/// Gestisce una coda di operazioni fallite che vengono ritentate
/// automaticamente con exponential backoff.
class RetryQueueService extends Notifier<void> {
  /// Max retry attempts prima di dichiarare fallimento permanente
  static const int _maxRetryAttempts = 5;

  /// Backoff base (1 secondo) per exponential backoff
  static const int _baseBackoffSeconds = 1;

  /// Max backoff (16 secondi) per evitare attese troppo lunghe
  static const int _maxBackoffSeconds = 16;

  /// Check intervallo per processing della queue (ogni 5 secondi)
  static const Duration _checkInterval = Duration(seconds: 5);

  /// Queue di operazioni in retry (key: collection/documentId)
  final Map<String, RetryMetadata> _retryQueue = {};

  /// Timer per periodic check della queue
  Timer? _checkTimer;

  /// Flag per prevenire processing concorrenti
  bool _processingInProgress = false;

  @override
  void build() {
    // Start periodic check timer
    _checkTimer = Timer.periodic(_checkInterval, (_) {
      if (kDebugMode) {
        debugPrint('⏰ [RetryQueue] Periodic check triggered (${_checkInterval.inSeconds}s)');
      }
      processRetryQueue();
    });

    // Cleanup quando il provider viene disposed
    ref.onDispose(() {
      _checkTimer?.cancel();

      if (kDebugMode && _retryQueue.isNotEmpty) {
        debugPrint(
          '⚠️ [RetryQueue] Disposing with ${_retryQueue.length} pending retries',
        );
      }
    });
  }

  /// Accoda operazione per retry automatico
  ///
  /// L'operazione verrà ritentata con exponential backoff fino a
  /// max 5 tentativi. Se tutti i tentativi falliscono, l'operazione
  /// viene rimossa dalla queue (fail permanently).
  ///
  /// **Esempio**:
  /// ```dart
  /// await retryQueue.enqueueForRetry(
  ///   operation: BatchOperation(
  ///     collection: 'workouts',
  ///     documentId: 'workout-123',
  ///     type: BatchOperationType.set,
  ///     data: {'name': 'Upper Body'},
  ///   ),
  ///   error: NetworkException(),
  /// );
  /// ```
  Future<void> enqueueForRetry({
    required BatchOperation operation,
    required Object error,
    int attemptCount = 0,
  }) async {
    final key = '${operation.collection}/${operation.documentId}';

    // Calcola backoff esponenziale: 1s, 2s, 4s, 8s, 16s
    final backoffSeconds = _calculateBackoff(attemptCount);

    final metadata = RetryMetadata(
      operation: operation,
      attemptCount: attemptCount,
      lastError: error,
      nextRetryAt: DateTime.now().add(Duration(seconds: backoffSeconds)),
    );

    _retryQueue[key] = metadata;

    if (kDebugMode) {
      debugPrint(
        '🔁 [RetryQueue] Enqueued $key for retry '
        '(attempt ${attemptCount + 1}/$_maxRetryAttempts, '
        'next retry in ${backoffSeconds}s)',
      );
    }
  }

  /// Processa la retry queue
  ///
  /// Per ogni operazione nella queue:
  /// 1. Verifica se è arrivato il momento del retry (nextRetryAt)
  /// 2. Ritenta l'operazione usando FirestoreBatchWriter
  /// 3. Se successo → rimuovi dalla queue
  /// 4. Se fallimento → incrementa attempt e rischedula con backoff
  /// 5. Se max attempts raggiunto → rimuovi dalla queue (fail permanently)
  Future<void> processRetryQueue() async {
    if (_processingInProgress) {
      if (kDebugMode) {
        debugPrint('⚠️ [RetryQueue] Processing already in progress, skipping');
      }
      return;
    }

    if (_retryQueue.isEmpty) {
      return;
    }

    _processingInProgress = true;

    try {
      final now = DateTime.now();
      final readyForRetry = _retryQueue.entries
          .where((entry) => entry.value.nextRetryAt.isBefore(now))
          .toList();

      if (readyForRetry.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'ℹ️ [RetryQueue] ${_retryQueue.length} operations queued, '
            'none ready for retry yet',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '🔄 [RetryQueue] Processing ${readyForRetry.length} operations '
          'ready for retry',
        );
      }

      final batchWriter = ref.read(firestoreBatchWriterProvider.notifier);

      for (final entry in readyForRetry) {
        final key = entry.key;
        final metadata = entry.value;

        try {
          // Ritenta operazione tramite batch writer
          await batchWriter.addOperation(metadata.operation);

          // Successo → rimuovi dalla retry queue
          _retryQueue.remove(key);

          if (kDebugMode) {
            debugPrint(
              '✅ [RetryQueue] Retry successful for $key '
              '(after ${metadata.attemptCount + 1} attempts)',
            );
          }
        } catch (retryError) {
          // Fallimento → incrementa attempt count
          final newAttemptCount = metadata.attemptCount + 1;

          if (newAttemptCount >= _maxRetryAttempts) {
            // Max attempts raggiunto → fail permanently
            _retryQueue.remove(key);

            if (kDebugMode) {
              debugPrint(
                '❌ [RetryQueue] Max retry attempts reached for $key '
                '(${metadata.attemptCount + 1}/$_maxRetryAttempts). '
                'Operation failed permanently: $retryError',
              );
            }
            // TODO: FASE 4 - Notificare utente con SyncStatusToast
          } else {
            // Rischedula con backoff esponenziale
            final backoffSeconds = _calculateBackoff(newAttemptCount);
            _retryQueue[key] = metadata.withIncrementedAttempt(
              error: retryError,
              backoffSeconds: backoffSeconds,
            );

            if (kDebugMode) {
              debugPrint(
                '🔁 [RetryQueue] Retry failed for $key, '
                'will retry in ${backoffSeconds}s '
                '(attempt ${newAttemptCount + 1}/$_maxRetryAttempts)',
              );
            }
          }
        }
      }

      if (kDebugMode && _retryQueue.isNotEmpty) {
        debugPrint(
          'ℹ️ [RetryQueue] ${_retryQueue.length} operations still in queue',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [RetryQueue] Processing failed: $e');
        debugPrint('📍 [RetryQueue] Stack trace: $stackTrace');
      }
    } finally {
      _processingInProgress = false;
    }
  }

  /// Calcola backoff esponenziale: 2^attempt * baseBackoff
  ///
  /// **Esempio**:
  /// - attempt 0: 1s  (2^0 * 1s)
  /// - attempt 1: 2s  (2^1 * 1s)
  /// - attempt 2: 4s  (2^2 * 1s)
  /// - attempt 3: 8s  (2^3 * 1s)
  /// - attempt 4: 16s (2^4 * 1s)
  int _calculateBackoff(int attemptCount) {
    final backoff = (1 << attemptCount) * _baseBackoffSeconds; // 2^attempt
    return backoff > _maxBackoffSeconds ? _maxBackoffSeconds : backoff;
  }

  /// Forza processing immediato della retry queue (manuale)
  ///
  /// Utile per:
  /// - Retry manuale quando utente torna online
  /// - Testing e debugging
  Future<void> forceRetryAll() async {
    if (kDebugMode) {
      debugPrint('🔨 [RetryQueue] Force retry requested');
    }
    await processRetryQueue();
  }

  /// Numero di operazioni in retry queue
  int get queueSize => _retryQueue.length;

  /// Verifica se processing è in corso
  bool get isProcessing => _processingInProgress;

  /// Rimuovi operazione dalla retry queue (es: cancellazione manuale)
  void removeFromQueue(String collection, String documentId) {
    final key = '$collection/$documentId';
    _retryQueue.remove(key);

    if (kDebugMode) {
      debugPrint('🗑️ [RetryQueue] Removed $key from retry queue');
    }
  }

}

/// Provider per RetryQueueService
///
/// Usa keepAlive implicito per mantenere lo stato globale
/// anche quando non ci sono listener attivi.
final retryQueueServiceProvider = NotifierProvider<RetryQueueService, void>(
  RetryQueueService.new,
);
