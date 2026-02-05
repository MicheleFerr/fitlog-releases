/// Document Sync Status Entity
///
/// Tracks synchronization state for AI Coach documents.
/// Used to determine if local cache needs updating.
///
/// **Layer**: Domain - Entity
/// **Feature**: AI Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_sync_status.freezed.dart';

/// Represents the synchronization status of AI Coach documents
@freezed
class DocumentSyncStatus with _$DocumentSyncStatus {
  const factory DocumentSyncStatus({
    required String localVersion, // Current cached version
    required String remoteVersion, // Latest remote version
    required DateTime lastSyncAt,
    required int documentsCount,
    required bool isSyncing,
    String? error,
  }) = _DocumentSyncStatus;

  const DocumentSyncStatus._();

  /// Check if local cache is up to date
  bool get isUpToDate => localVersion == remoteVersion;

  /// Check if there's a sync error
  bool get hasError => error != null;

  /// Check if sync is needed
  bool get needsSync => !isUpToDate && !isSyncing;
}
