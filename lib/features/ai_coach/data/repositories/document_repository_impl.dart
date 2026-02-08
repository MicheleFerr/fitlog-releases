/// Document Repository Implementation
///
/// Hybrid repository combining local cache (Hive) and remote API (Firebase).
/// Implements offline-first strategy with background sync.
///
/// **Layer**: Data - Repository
/// **Feature**: AI Coach
library;

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/scientific_paper.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/document_sync_status.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/document_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/document_local_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/document_remote_datasource.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/models/scientific_paper_model.dart';

/// Repository implementation for AI Coach documents
class DocumentRepositoryImpl implements DocumentRepository {

  DocumentRepositoryImpl({
    required DocumentLocalDataSource localDataSource,
    required DocumentRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;
  final DocumentLocalDataSource _localDataSource;
  final DocumentRemoteDataSource _remoteDataSource;

  @override
  Future<Either<String, List<ScientificPaper>>> getCachedDocuments() async {
    try {
      final models = await _localDataSource.getAll();
      final papers = models.map((m) => m.toDomain()).toList();
      debugPrint('[DOCUMENT_REPO] ✅ Retrieved ${papers.length} cached documents');
      return right(papers);
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Failed to get cached documents: $e');
      return left('Failed to get cached documents: $e');
    }
  }

  @override
  Future<Either<String, List<ScientificPaper>>> getDocumentsByCategory(
    String category,
  ) async {
    try {
      final models = await _localDataSource.getByCategory(category);
      final papers = models.map((m) => m.toDomain()).toList();
      debugPrint(
        '[DOCUMENT_REPO] ✅ Retrieved ${papers.length} documents for category: $category',
      );
      return right(papers);
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Failed to get documents by category: $e');
      return left('Failed to get documents by category: $e');
    }
  }

  @override
  Future<Either<String, List<ScientificPaper>>> searchDocuments(
    String query,
  ) async {
    try {
      final models = await _localDataSource.search(query);
      final papers = models.map((m) => m.toDomain()).toList();
      debugPrint(
        '[DOCUMENT_REPO] ✅ Search "$query" returned ${papers.length} results',
      );
      return right(papers);
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Search failed: $e');
      return left('Failed to search documents: $e');
    }
  }

  @override
  Future<Either<String, ScientificPaper>> getDocument(String id) async {
    try {
      final model = await _localDataSource.getById(id);
      if (model == null) {
        return left('Document not found: $id');
      }
      return right(model.toDomain());
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Failed to get document: $e');
      return left('Failed to get document: $e');
    }
  }

  @override
  Future<Either<String, DocumentSyncStatus>> checkForUpdates() async {
    try {
      final metadata = await _localDataSource.getMetadata();
      final localVersion = metadata?.version ?? 'v0.0';

      debugPrint('[DOCUMENT_REPO] 🔍 Checking for updates (local: $localVersion)');

      final response = await _remoteDataSource.checkForUpdates(localVersion);

      final status = DocumentSyncStatus(
        localVersion: localVersion,
        remoteVersion: response['version'] as String,
        lastSyncAt: metadata?.lastSyncAt ?? DateTime.now(),
        documentsCount: metadata?.documentsCount ?? 0,
        isSyncing: false,
      );

      if (status.needsSync) {
        debugPrint(
          '[DOCUMENT_REPO] ⚠️ Update available: ${status.remoteVersion}',
        );
      } else {
        debugPrint('[DOCUMENT_REPO] ✅ Cache is up to date');
      }

      return right(status);
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Failed to check for updates: $e');
      return left('Failed to check for updates: $e');
    }
  }

  @override
  Future<Either<String, DocumentSyncStatus>> syncDocuments() async {
    try {
      final metadata = await _localDataSource.getMetadata();
      final localVersion = metadata?.version ?? 'v0.0';

      debugPrint('[DOCUMENT_REPO] 🔄 Starting sync (local: $localVersion)');

      final response = await _remoteDataSource.checkForUpdates(localVersion);

      final remoteVersion = response['version'] as String;
      final documentsToAdd = response['documentsToAdd'] as List<dynamic>? ?? [];
      final documentsToRemove =
          (response['documentsToRemove'] as List<dynamic>? ?? [])
              .cast<String>();

      // Fetch new documents (BATCH - PERFORMANCE)
      if (documentsToAdd.isNotEmpty) {
        debugPrint(
          '[DOCUMENT_REPO] 📥 Downloading ${documentsToAdd.length} new documents',
        );
        final ids = documentsToAdd.map((d) => d['id'] as String).toList();
        final newPapers = await _remoteDataSource.fetchDocuments(ids);
        await _localDataSource.saveAll(newPapers); // BATCH SAVE
      }

      // Remove deleted documents (BATCH - PERFORMANCE)
      if (documentsToRemove.isNotEmpty) {
        debugPrint(
          '[DOCUMENT_REPO] 🗑️ Removing ${documentsToRemove.length} deleted documents',
        );
        await _localDataSource.removeAll(documentsToRemove); // BATCH DELETE
      }

      // Update metadata
      final newMetadata = DocumentMetadata(
        version: remoteVersion,
        hash: response['hash'] as String,
        lastSyncAt: DateTime.now(),
        documentsCount: response['documentsCount'] as int,
      );
      await _localDataSource.saveMetadata(newMetadata);

      final status = DocumentSyncStatus(
        localVersion: remoteVersion,
        remoteVersion: remoteVersion,
        lastSyncAt: DateTime.now(),
        documentsCount: newMetadata.documentsCount,
        isSyncing: false,
      );

      debugPrint('[DOCUMENT_REPO] ✅ Sync complete: ${status.documentsCount} documents');

      return right(status);
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Sync failed: $e');
      return left('Failed to sync documents: $e');
    }
  }

  @override
  Future<Either<String, DocumentSyncStatus>> getSyncStatus() async {
    try {
      final metadata = await _localDataSource.getMetadata();

      if (metadata == null) {
        return right(DocumentSyncStatus(
          localVersion: 'v0.0',
          remoteVersion: 'v0.0',
          lastSyncAt: DateTime.now(),
          documentsCount: 0,
          isSyncing: false,
        ));
      }

      // Check remote for latest version (no download)
      final checkResult = await checkForUpdates();
      return checkResult;
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Failed to get sync status: $e');
      return left('Failed to get sync status: $e');
    }
  }

  @override
  Future<Either<String, Unit>> clearCache() async {
    try {
      await _localDataSource.clear();
      debugPrint('[DOCUMENT_REPO] ✅ Cache cleared');
      return right(unit);
    } catch (e) {
      debugPrint('[DOCUMENT_REPO] ❌ Failed to clear cache: $e');
      return left('Failed to clear cache: $e');
    }
  }
}
