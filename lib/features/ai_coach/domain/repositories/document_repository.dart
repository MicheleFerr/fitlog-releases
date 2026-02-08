/// Document Repository Interface
///
/// Contract for accessing scientific papers from cache and remote.
/// Provides methods for CRUD operations and synchronization.
///
/// **Layer**: Domain - Repository Interface
/// **Feature**: AI Coach
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/scientific_paper.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/document_sync_status.dart';

/// Repository interface for AI Coach documents
abstract class DocumentRepository {
  /// Get all active papers from cache
  Future<Either<String, List<ScientificPaper>>> getCachedDocuments();

  /// Get papers by category
  /// @param category - Category filter (e.g., 'hypertrophy', 'strength')
  Future<Either<String, List<ScientificPaper>>> getDocumentsByCategory(
    String category,
  );

  /// Search documents by keywords
  /// @param query - Search query (searches title, summary, keywords)
  Future<Either<String, List<ScientificPaper>>> searchDocuments(
    String query,
  );

  /// Get single document by ID
  /// @param id - Document ID
  Future<Either<String, ScientificPaper>> getDocument(String id);

  /// Check for remote updates
  /// Compares local version with remote version without downloading
  Future<Either<String, DocumentSyncStatus>> checkForUpdates();

  /// Sync documents (add new, remove deleted)
  /// Downloads delta (new papers) and removes inactive ones
  Future<Either<String, DocumentSyncStatus>> syncDocuments();

  /// Get current sync status
  /// Returns local cache status and metadata
  Future<Either<String, DocumentSyncStatus>> getSyncStatus();

  /// Clear all cached documents
  /// Used for testing or reset scenarios
  Future<Either<String, Unit>> clearCache();
}
