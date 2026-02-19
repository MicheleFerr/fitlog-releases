/// Document Sync Providers
///
/// Riverpod providers for AI Coach document management.
/// Connects repository and sync service to UI.
///
/// **Layer**: Presentation - Providers
/// **Feature**: AI Coach
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/scientific_paper.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/document_sync_status.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/document_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/document_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/document_local_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/document_remote_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/document_sync_service.dart';
import 'package:gymbro_flutter_new/core/services/firebase_service.dart';

/// Provider for local datasource
final _documentLocalDataSourceProvider = Provider<DocumentLocalDataSource>((ref) {
  return DocumentLocalDataSource();
});

/// Provider for remote datasource
final _documentRemoteDataSourceProvider = Provider<DocumentRemoteDataSource>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final baseUrl = firebaseService.functionsBaseUrl;

  final client = http.Client();
  ref.onDispose(client.close); // Previene connection leak al dispose del provider

  return DocumentRemoteDataSource(
    client: client,
    baseUrl: baseUrl,
  );
});

/// Provider for document repository
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final localDataSource = ref.watch(_documentLocalDataSourceProvider);
  final remoteDataSource = ref.watch(_documentRemoteDataSourceProvider);

  return DocumentRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

/// Provider for document sync service (singleton)
/// Auto-initializes background sync on first access
final documentSyncServiceProvider = Provider<DocumentSyncService>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final service = DocumentSyncService(repository: repository);

  // Auto-initialize background sync (24h interval + initial sync)
  // This runs only once when provider is first accessed
  service.initialize().catchError((error) {
    // Log error but don't crash app if sync fails
    if (kDebugMode) {
      debugPrint('❌ [AI Coach] Failed to initialize document sync: $error');
    }
  });

  // Cleanup on dispose
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for cached documents (all active papers)
final cachedDocumentsProvider = FutureProvider<List<ScientificPaper>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  final result = await repository.getCachedDocuments();

  return result.fold(
    (error) => throw Exception(error),
    (papers) => papers,
  );
});

/// Provider for documents by category (family)
final documentsByCategoryProvider = FutureProvider.family<List<ScientificPaper>, String>(
  (ref, category) async {
    final repository = ref.watch(documentRepositoryProvider);
    final result = await repository.getDocumentsByCategory(category);

    return result.fold(
      (error) => throw Exception(error),
      (papers) => papers,
    );
  },
);

/// Provider for document search (family)
final searchDocumentsProvider = FutureProvider.family<List<ScientificPaper>, String>(
  (ref, query) async {
    if (query.trim().isEmpty) return [];

    final repository = ref.watch(documentRepositoryProvider);
    final result = await repository.searchDocuments(query);

    return result.fold(
      (error) => throw Exception(error),
      (papers) => papers,
    );
  },
);

/// Provider for single document by ID (family)
final documentByIdProvider = FutureProvider.family<ScientificPaper, String>(
  (ref, id) async {
    final repository = ref.watch(documentRepositoryProvider);
    final result = await repository.getDocument(id);

    return result.fold(
      (error) => throw Exception(error),
      (paper) => paper,
    );
  },
);

/// Notifier for document sync status
class DocumentSyncNotifier extends AsyncNotifier<DocumentSyncStatus> {
  @override
  Future<DocumentSyncStatus> build() async {
    // Load initial status
    return _loadStatus();
  }

  DocumentRepository get _repository => ref.read(documentRepositoryProvider);

  /// Load current sync status
  Future<DocumentSyncStatus> _loadStatus() async {
    final result = await _repository.getSyncStatus();

    return result.fold(
      (error) => throw Exception(error),
      (status) => status,
    );
  }

  /// Trigger manual sync
  Future<void> syncNow() async {
    state = const AsyncValue.loading();

    final result = await _repository.syncDocuments();

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (status) => AsyncValue.data(status),
    );
  }

  /// Check for updates without downloading
  Future<bool> checkForUpdates() async {
    final result = await _repository.checkForUpdates();

    return result.fold(
      (error) => false,
      (status) => status.needsSync,
    );
  }

  /// Clear cache (admin only)
  Future<void> clearCache() async {
    final result = await _repository.clearCache();

    result.fold(
      (error) => throw Exception(error),
      (_) async {
        // Invalida tutti i provider che dipendono dalla cache documenti
        ref.invalidate(cachedDocumentsProvider);
        ref.invalidate(documentCategoriesProvider);
        // Reload status after clearing
        state = AsyncValue.data(await _loadStatus());
      },
    );
  }

  /// Refresh status
  Future<void> refresh() async {
    state = AsyncValue.data(await _loadStatus());
  }
}

/// Provider for document sync status notifier
final documentSyncNotifierProvider = AsyncNotifierProvider<DocumentSyncNotifier, DocumentSyncStatus>(() {
  return DocumentSyncNotifier();
});

/// Provider to check if sync is needed
final syncNeededProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  final result = await repository.checkForUpdates();

  return result.fold(
    (error) => false,
    (status) => status.needsSync,
  );
});

/// Provider for document categories (extracted from cached documents)
final documentCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final papers = await ref.watch(cachedDocumentsProvider.future);

  final categories = <String>{};
  for (final paper in papers) {
    categories.addAll(paper.categories);
  }

  return categories.toList()..sort();
});

/// Provider for document count by category
final documentCountByCategoryProvider = FutureProvider.family<int, String>(
  (ref, category) async {
    final papers = await ref.watch(documentsByCategoryProvider(category).future);
    return papers.length;
  },
);
