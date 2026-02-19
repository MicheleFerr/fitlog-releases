/// Document Sync Service
///
/// Background sync service with singleton pattern.
/// Syncs AI Coach documents every 24 hours automatically.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
/// **Performance**: Singleton + Lock pattern (CLAUDE.md compliant)
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/document_repository.dart';

/// Background sync service with singleton pattern (PERFORMANCE)
class DocumentSyncService {

  /// Factory constructor for singleton
  factory DocumentSyncService({required DocumentRepository repository}) {
    return _instance ??= DocumentSyncService._(repository);
  }

  DocumentSyncService._(this._repository);
  // Singleton instance
  static DocumentSyncService? _instance;

  final DocumentRepository _repository;
  final _lock = Lock(); // Prevent concurrent syncs (PERFORMANCE)
  Timer? _syncTimer;
  bool _initialized = false;

  /// Initialize background sync (call once on app start)
  Future<void> initialize() async {
    await _lock.synchronized(() async {
      if (_initialized) {
        debugPrint('[DOCUMENT_SYNC] ⚠️ Already initialized, skipping');
        return;
      }

      debugPrint('[DOCUMENT_SYNC] 🚀 Initializing background sync');

      // Initial sync — chiamata diretta senza lock (già dentro _lock.synchronized)
      await _doSync();

      // Schedule daily sync (24 hours)
      _syncTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => syncNow(),
      );

      _initialized = true;
      debugPrint('[DOCUMENT_SYNC] ✅ Initialized with daily sync (24h)');
    });
  }

  /// Trigger immediate sync (manual refresh)
  Future<void> syncNow() async {
    await _lock.synchronized(_doSync);
  }

  /// Core sync logic — NON acquisisce _lock, deve essere chiamata dall'interno di un lock.
  /// Questo previene il deadlock: initialize() e syncNow() acquisiscono il lock,
  /// poi chiamano questo metodo che non tenta di riacquisirlo.
  Future<void> _doSync() async {
    debugPrint('[DOCUMENT_SYNC] 🔄 Starting sync...');

    final result = await _repository.syncDocuments();

    result.fold(
      (error) {
        debugPrint('[DOCUMENT_SYNC] ❌ Sync failed: $error');
      },
      (status) {
        debugPrint(
          '[DOCUMENT_SYNC] ✅ Sync complete: ${status.documentsCount} documents (${status.localVersion})',
        );
      },
    );
  }

  /// Check if sync is needed without downloading
  Future<bool> needsSync() async {
    final result = await _repository.checkForUpdates();

    return result.fold(
      (error) {
        debugPrint('[DOCUMENT_SYNC] ❌ Update check failed: $error');
        return false;
      },
      (status) => status.needsSync,
    );
  }

  /// Get current sync status
  Future<void> getStatus() async {
    final result = await _repository.getSyncStatus();

    result.fold(
      (error) {
        debugPrint('[DOCUMENT_SYNC] ❌ Status check failed: $error');
      },
      (status) {
        debugPrint(
          '[DOCUMENT_SYNC] 📊 Status: ${status.localVersion} (${status.documentsCount} docs, last sync: ${status.lastSyncAt})',
        );
      },
    );
  }

  /// Dispose resources (call on app dispose)
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _initialized = false;
    _instance = null; // permette di creare una nuova istanza dopo il dispose
    debugPrint('[DOCUMENT_SYNC] 🛑 Disposed');
  }
}
