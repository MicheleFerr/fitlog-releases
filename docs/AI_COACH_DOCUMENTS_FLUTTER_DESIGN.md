# AI Coach Documents - Flutter Implementation Design

**Version**: 1.0
**Date**: 2026-02-05
**Audience**: Flutter Developer
**Status**: Ready for Implementation

---

## Overview

Sistema di sincronizzazione e caching offline-first per documenti scientifici dell'AI Coach. Sincronizza metadata da Firebase, cache locale con Hive, e integrazione con AI Coach per retrieval documenti durante conversazioni.

**Principi chiave**:
- ✅ Offline-first: Cache locale con Hive
- ✅ Background sync: Controllo giornaliero versione + delta sync
- ✅ Performance: Batch operations, no I/O in loop
- ✅ Clean Architecture: Domain → Data → Presentation

---

## 1. Architettura Overview

```
lib/features/ai_coach/
├── domain/
│   ├── entities/
│   │   ├── scientific_paper.dart         # Entity per documento
│   │   └── document_sync_status.dart     # Entity per stato sync
│   └── repositories/
│       └── document_repository.dart      # Interface repository
│
├── data/
│   ├── models/
│   │   └── scientific_paper_model.dart   # Model con JSON serialization
│   ├── datasources/
│   │   ├── document_remote_datasource.dart    # Firebase API calls
│   │   └── document_local_datasource.dart     # Hive cache
│   ├── repositories/
│   │   └── document_repository_impl.dart      # Repository implementation
│   └── services/
│       └── document_sync_service.dart         # Background sync logic
│
└── presentation/
    └── providers/
        ├── document_sync_provider.dart        # Sync state management
        └── ai_chat_provider.dart (modify)     # Add document retrieval
```

---

## 2. Domain Layer

### 2.1 Entity: ScientificPaper

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scientific_paper.freezed.dart';

/// Represents a scientific paper with metadata and abstract
@freezed
class ScientificPaper with _$ScientificPaper {
  const factory ScientificPaper({
    required String id,
    required String title,
    required List<String> authors,
    required int year,
    required String doi,
    required String abstract,
    required String summary,           // Short 1-2 sentence summary for AI
    required String url,
    required String license,
    required List<String> categories,  // ['hypertrophy', 'strength', etc.]
    required List<String> keywords,
    required DateTime uploadedAt,
    required DateTime updatedAt,
    required bool active,
    Map<String, dynamic>? metadata,    // Journal, volume, issue, pages
  }) = _ScientificPaper;

  const ScientificPaper._();

  /// Format paper citation for AI responses
  String formatCitation() {
    final authorsStr = authors.length > 3
        ? '${authors.take(3).join(", ")} et al.'
        : authors.join(", ");
    return '$authorsStr ($year)';
  }

  /// Convert to AI-friendly context string
  String toContextString() {
    return '''
Title: $title
Authors: ${formatCitation()}
Summary: $summary
Categories: ${categories.join(", ")}
URL: $url
''';
  }
}
```

### 2.2 Entity: DocumentSyncStatus

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_sync_status.freezed.dart';

@freezed
class DocumentSyncStatus with _$DocumentSyncStatus {
  const factory DocumentSyncStatus({
    required String localVersion,      // Current cached version
    required String remoteVersion,     // Latest remote version
    required DateTime lastSyncAt,
    required int documentsCount,
    required bool isSyncing,
    String? error,
  }) = _DocumentSyncStatus;

  const DocumentSyncStatus._();

  bool get isUpToDate => localVersion == remoteVersion;
  bool get hasError => error != null;
}
```

### 2.3 Repository Interface

```dart
import 'package:fpdart/fpdart.dart';
import '../entities/scientific_paper.dart';
import '../entities/document_sync_status.dart';

abstract class DocumentRepository {
  /// Get all active papers from cache
  Future<Either<String, List<ScientificPaper>>> getCachedDocuments();

  /// Get papers by category
  Future<Either<String, List<ScientificPaper>>> getDocumentsByCategory(
    String category,
  );

  /// Search documents by keywords
  Future<Either<String, List<ScientificPaper>>> searchDocuments(
    String query,
  );

  /// Get single document by ID
  Future<Either<String, ScientificPaper>> getDocument(String id);

  /// Check for remote updates
  Future<Either<String, DocumentSyncStatus>> checkForUpdates();

  /// Sync documents (add new, remove deleted)
  Future<Either<String, DocumentSyncStatus>> syncDocuments();

  /// Get current sync status
  Future<Either<String, DocumentSyncStatus>> getSyncStatus();

  /// Clear all cached documents
  Future<Either<String, Unit>> clearCache();
}
```

---

## 3. Data Layer

### 3.1 Model: ScientificPaperModel

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/scientific_paper.dart';

part 'scientific_paper_model.freezed.dart';
part 'scientific_paper_model.g.dart';

@freezed
class ScientificPaperModel with _$ScientificPaperModel {
  @HiveType(typeId: 10, adapterName: 'ScientificPaperModelAdapter')
  const factory ScientificPaperModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required List<String> authors,
    @HiveField(3) required int year,
    @HiveField(4) required String doi,
    @HiveField(5) required String abstract,
    @HiveField(6) required String summary,
    @HiveField(7) required String url,
    @HiveField(8) required String license,
    @HiveField(9) required List<String> categories,
    @HiveField(10) required List<String> keywords,
    @HiveField(11) required DateTime uploadedAt,
    @HiveField(12) required DateTime updatedAt,
    @HiveField(13) required bool active,
    @HiveField(14) Map<String, dynamic>? metadata,
  }) = _ScientificPaperModel;

  const ScientificPaperModel._();

  factory ScientificPaperModel.fromJson(Map<String, dynamic> json) =>
      _$ScientificPaperModelFromJson(json);

  /// Convert to domain entity
  ScientificPaper toDomain() => ScientificPaper(
        id: id,
        title: title,
        authors: authors,
        year: year,
        doi: doi,
        abstract: abstract,
        summary: summary,
        url: url,
        license: license,
        categories: categories,
        keywords: keywords,
        uploadedAt: uploadedAt,
        updatedAt: updatedAt,
        active: active,
        metadata: metadata,
      );

  /// Create from domain entity
  static ScientificPaperModel fromDomain(ScientificPaper paper) =>
      ScientificPaperModel(
        id: paper.id,
        title: paper.title,
        authors: paper.authors,
        year: paper.year,
        doi: paper.doi,
        abstract: paper.abstract,
        summary: paper.summary,
        url: paper.url,
        license: paper.license,
        categories: paper.categories,
        keywords: paper.keywords,
        uploadedAt: paper.uploadedAt,
        updatedAt: paper.updatedAt,
        active: paper.active,
        metadata: paper.metadata,
      );
}
```

### 3.2 Hive Cache Structure

```dart
/// Hive boxes for document storage
const String documentsBoxName = 'ai_coach_documents';
const String documentMetaBoxName = 'ai_coach_documents_meta';

/// Metadata stored in Hive
@HiveType(typeId: 11)
class DocumentMetadata {
  @HiveField(0)
  final String version;

  @HiveField(1)
  final String hash;

  @HiveField(2)
  final DateTime lastSyncAt;

  @HiveField(3)
  final int documentsCount;

  DocumentMetadata({
    required this.version,
    required this.hash,
    required this.lastSyncAt,
    required this.documentsCount,
  });
}
```

**Box Structure**:
```
Box: ai_coach_documents
├── paper_001 → ScientificPaperModel
├── paper_002 → ScientificPaperModel
└── ...

Box: ai_coach_documents_meta
└── sync_metadata → DocumentMetadata
```

### 3.3 DataSource: DocumentLocalDataSource

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/scientific_paper_model.dart';

class DocumentLocalDataSource {
  late Box<ScientificPaperModel> _documentsBox;
  late Box<DocumentMetadata> _metaBox;
  bool _initialized = false;

  /// Initialize Hive boxes (call once on app start)
  Future<void> initialize() async {
    if (_initialized) return;

    _documentsBox = await Hive.openBox<ScientificPaperModel>(documentsBoxName);
    _metaBox = await Hive.openBox<DocumentMetadata>(documentMetaBoxName);
    _initialized = true;
  }

  /// Get all active papers
  Future<List<ScientificPaperModel>> getAll() async {
    await initialize();
    return _documentsBox.values
        .where((paper) => paper.active)
        .toList();
  }

  /// Get papers by category
  Future<List<ScientificPaperModel>> getByCategory(String category) async {
    await initialize();
    return _documentsBox.values
        .where((paper) => paper.active && paper.categories.contains(category))
        .toList();
  }

  /// Search papers (title, summary, keywords)
  Future<List<ScientificPaperModel>> search(String query) async {
    await initialize();
    final lowerQuery = query.toLowerCase();

    return _documentsBox.values.where((paper) {
      if (!paper.active) return false;

      return paper.title.toLowerCase().contains(lowerQuery) ||
          paper.summary.toLowerCase().contains(lowerQuery) ||
          paper.keywords.any((k) => k.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get single paper by ID
  Future<ScientificPaperModel?> getById(String id) async {
    await initialize();
    return _documentsBox.get(id);
  }

  /// Save papers (batch operation - PERFORMANCE)
  Future<void> saveAll(List<ScientificPaperModel> papers) async {
    await initialize();
    final entries = {for (var paper in papers) paper.id: paper};
    await _documentsBox.putAll(entries); // BATCH PUT - no loop
  }

  /// Remove papers by IDs (batch operation - PERFORMANCE)
  Future<void> removeAll(List<String> ids) async {
    await initialize();
    await _documentsBox.deleteAll(ids); // BATCH DELETE - no loop
  }

  /// Clear all documents
  Future<void> clear() async {
    await initialize();
    await _documentsBox.clear();
  }

  /// Get sync metadata
  Future<DocumentMetadata?> getMetadata() async {
    await initialize();
    return _metaBox.get('sync_metadata');
  }

  /// Save sync metadata
  Future<void> saveMetadata(DocumentMetadata metadata) async {
    await initialize();
    await _metaBox.put('sync_metadata', metadata);
  }
}
```

### 3.4 DataSource: DocumentRemoteDataSource

```dart
import 'package:dio/dio.dart';
import '../models/scientific_paper_model.dart';

class DocumentRemoteDataSource {
  final Dio _dio;

  DocumentRemoteDataSource({required Dio dio}) : _dio = dio;

  /// Check for updates (compare versions)
  Future<Map<String, dynamic>> checkForUpdates(String localVersion) async {
    final response = await _dio.get(
      '/api/v1/ai-coach/documents/metadata',
      options: Options(
        headers: {
          'X-Local-Version': localVersion,
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Fetch document metadata by ID
  Future<ScientificPaperModel> fetchDocument(String docId) async {
    final response = await _dio.get(
      '/api/v1/ai-coach/documents/$docId/metadata',
    );

    return ScientificPaperModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Batch fetch documents by IDs (PERFORMANCE)
  Future<List<ScientificPaperModel>> fetchDocuments(List<String> ids) async {
    final responses = await Future.wait(
      ids.map((id) => fetchDocument(id)),
    );
    return responses;
  }
}
```

### 3.5 Repository Implementation

```dart
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/scientific_paper.dart';
import '../../domain/entities/document_sync_status.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_local_datasource.dart';
import '../datasources/document_remote_datasource.dart';
import '../models/scientific_paper_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource _localDataSource;
  final DocumentRemoteDataSource _remoteDataSource;

  DocumentRepositoryImpl({
    required DocumentLocalDataSource localDataSource,
    required DocumentRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<String, List<ScientificPaper>>> getCachedDocuments() async {
    try {
      final models = await _localDataSource.getAll();
      final papers = models.map((m) => m.toDomain()).toList();
      return right(papers);
    } catch (e) {
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
      return right(papers);
    } catch (e) {
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
      return right(papers);
    } catch (e) {
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
      return left('Failed to get document: $e');
    }
  }

  @override
  Future<Either<String, DocumentSyncStatus>> checkForUpdates() async {
    try {
      final metadata = await _localDataSource.getMetadata();
      final localVersion = metadata?.version ?? 'v0.0';

      final response = await _remoteDataSource.checkForUpdates(localVersion);

      final status = DocumentSyncStatus(
        localVersion: localVersion,
        remoteVersion: response['version'] as String,
        lastSyncAt: metadata?.lastSyncAt ?? DateTime.now(),
        documentsCount: metadata?.documentsCount ?? 0,
        isSyncing: false,
      );

      return right(status);
    } catch (e) {
      return left('Failed to check for updates: $e');
    }
  }

  @override
  Future<Either<String, DocumentSyncStatus>> syncDocuments() async {
    try {
      final metadata = await _localDataSource.getMetadata();
      final localVersion = metadata?.version ?? 'v0.0';

      final response = await _remoteDataSource.checkForUpdates(localVersion);

      final remoteVersion = response['version'] as String;
      final documentsToAdd = response['documentsToAdd'] as List<dynamic>? ?? [];
      final documentsToRemove =
          (response['documentsToRemove'] as List<dynamic>? ?? [])
              .cast<String>();

      // Fetch new documents (BATCH)
      if (documentsToAdd.isNotEmpty) {
        final ids = documentsToAdd.map((d) => d['id'] as String).toList();
        final newPapers = await _remoteDataSource.fetchDocuments(ids);
        await _localDataSource.saveAll(newPapers); // BATCH SAVE
      }

      // Remove deleted documents (BATCH)
      if (documentsToRemove.isNotEmpty) {
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

      return right(status);
    } catch (e) {
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
      return left('Failed to get sync status: $e');
    }
  }

  @override
  Future<Either<String, Unit>> clearCache() async {
    try {
      await _localDataSource.clear();
      return right(unit);
    } catch (e) {
      return left('Failed to clear cache: $e');
    }
  }
}
```

### 3.6 Service: DocumentSyncService

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import '../../domain/repositories/document_repository.dart';

/// Background sync service with singleton pattern (PERFORMANCE)
class DocumentSyncService {
  static DocumentSyncService? _instance;
  factory DocumentSyncService({required DocumentRepository repository}) {
    return _instance ??= DocumentSyncService._(repository);
  }

  DocumentSyncService._(this._repository);

  final DocumentRepository _repository;
  final _lock = Lock(); // Prevent concurrent syncs
  Timer? _syncTimer;
  bool _initialized = false;

  /// Initialize background sync (call once on app start)
  Future<void> initialize() async {
    await _lock.synchronized(() async {
      if (_initialized) return;

      // Initial sync
      await _syncNow();

      // Schedule daily sync (24 hours)
      _syncTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => _syncNow(),
      );

      _initialized = true;
      debugPrint('[DOCUMENT_SYNC] ✅ Initialized with daily sync');
    });
  }

  /// Trigger immediate sync
  Future<void> syncNow() async {
    await _syncNow();
  }

  /// Internal sync logic (locked to prevent concurrent execution)
  Future<void> _syncNow() async {
    await _lock.synchronized(() async {
      debugPrint('[DOCUMENT_SYNC] 🔄 Starting sync...');

      final result = await _repository.syncDocuments();

      result.fold(
        (error) => debugPrint('[DOCUMENT_SYNC] ❌ Sync failed: $error'),
        (status) {
          debugPrint(
            '[DOCUMENT_SYNC] ✅ Sync complete: ${status.documentsCount} documents',
          );
        },
      );
    });
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _initialized = false;
    debugPrint('[DOCUMENT_SYNC] 🛑 Disposed');
  }
}
```

---

## 4. Presentation Layer

### 4.1 Provider: DocumentSyncProvider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/document_sync_status.dart';
import '../../domain/entities/scientific_paper.dart';
import '../../domain/repositories/document_repository.dart';
import '../../data/services/document_sync_service.dart';

part 'document_sync_provider.g.dart';

/// Document repository provider
@riverpod
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  // Inject datasources and return repository
  throw UnimplementedError('Inject DocumentRepositoryImpl here');
}

/// Document sync service provider (singleton)
@riverpod
DocumentSyncService documentSyncService(DocumentSyncServiceRef ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final service = DocumentSyncService(repository: repository);

  ref.onDispose(() => service.dispose());

  return service;
}

/// Sync status provider
@riverpod
class DocumentSync extends _$DocumentSync {
  @override
  FutureOr<DocumentSyncStatus> build() async {
    final repository = ref.watch(documentRepositoryProvider);

    // Initialize sync service on first build
    final syncService = ref.read(documentSyncServiceProvider);
    await syncService.initialize();

    final result = await repository.getSyncStatus();
    return result.fold(
      (error) => DocumentSyncStatus(
        localVersion: 'v0.0',
        remoteVersion: 'v0.0',
        lastSyncAt: DateTime.now(),
        documentsCount: 0,
        isSyncing: false,
        error: error,
      ),
      (status) => status,
    );
  }

  /// Trigger manual sync
  Future<void> syncNow() async {
    state = AsyncValue.data(
      state.value!.copyWith(isSyncing: true),
    );

    final repository = ref.read(documentRepositoryProvider);
    final result = await repository.syncDocuments();

    state = await AsyncValue.guard(() async {
      return result.fold(
        (error) => state.value!.copyWith(
          isSyncing: false,
          error: error,
        ),
        (status) => status,
      );
    });
  }
}

/// Cached documents provider
@riverpod
Future<List<ScientificPaper>> cachedDocuments(CachedDocumentsRef ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  final result = await repository.getCachedDocuments();

  return result.fold(
    (error) {
      debugPrint('[DOCUMENTS] ❌ Error loading cached documents: $error');
      return [];
    },
    (papers) => papers,
  );
}

/// Documents by category provider
@riverpod
Future<List<ScientificPaper>> documentsByCategory(
  DocumentsByCategoryRef ref,
  String category,
) async {
  final repository = ref.watch(documentRepositoryProvider);
  final result = await repository.getDocumentsByCategory(category);

  return result.fold(
    (error) => [],
    (papers) => papers,
  );
}

/// Search documents provider
@riverpod
Future<List<ScientificPaper>> searchDocuments(
  SearchDocumentsRef ref,
  String query,
) async {
  if (query.trim().isEmpty) return [];

  final repository = ref.watch(documentRepositoryProvider);
  final result = await repository.searchDocuments(query);

  return result.fold(
    (error) => [],
    (papers) => papers,
  );
}
```

---

## 5. AI Coach Integration

### 5.1 Document Retrieval in AI Coach

Modifiche a `ai_coach_service_impl.dart`:

```dart
// Add document context to user queries
Future<String> _enrichUserQueryWithDocuments(
  String userQuery,
  List<ScientificPaper> documents,
) async {
  // Check if query is about topics covered by documents
  final lowerQuery = userQuery.toLowerCase();

  // Keywords that trigger document search
  const documentKeywords = [
    'ricerca',
    'studio',
    'paper',
    'evidenza',
    'scienza',
    'progressione',
    'volume',
    'ipertrofia',
    'forza',
    'periodizzazione',
  ];

  final hasRelevantKeyword = documentKeywords.any(
    (keyword) => lowerQuery.contains(keyword),
  );

  if (!hasRelevantKeyword) {
    return userQuery; // No enrichment needed
  }

  // Search for relevant documents
  final relevantDocs = documents.where((doc) {
    return doc.categories.any((cat) => lowerQuery.contains(cat)) ||
        doc.keywords.any((kw) => lowerQuery.contains(kw));
  }).take(3); // Max 3 papers per query

  if (relevantDocs.isEmpty) {
    return userQuery;
  }

  // Append document context to query
  final docsContext = relevantDocs.map((doc) => doc.toContextString()).join('\n\n');

  return '''
$userQuery

[Riferimenti scientifici disponibili per questa domanda:]
$docsContext
''';
}
```

### 5.2 Update AI System Prompt

Aggiungi alla sezione documenti in `ai_system_prompt.dart`:

```dart
## Scientific References (NEW)
You have access to a curated library of scientific papers on exercise science.

**When to reference papers:**
- User asks about "ricerca", "studi", "evidenza scientifica"
- Questions about progressive overload, volume, periodization
- Comparisons between training methods
- Recommendations that benefit from scientific backing

**How to cite papers:**
- Format: (Authors, Year) with DOI link
- Example: "Le ricerche mostrano che 10-20 set settimanali sono ottimali (Schoenfeld et al., 2017: https://doi.org/...)"
- Always provide the URL for users to read the full paper
- Focus on practical takeaways, not just data

**Papers are provided with your query when relevant** - you don't need to request them.
```

---

## 6. Data Flow

### 6.1 Initial Sync Flow

```
App Launch
    ↓
[DocumentSyncService.initialize()]
    ↓
Check local cache (Hive)
    ↓
IF empty → Trigger first sync
IF exists → Check version
    ↓
GET /api/v1/ai-coach/documents/metadata
    ↓
Compare: local version vs remote version
    ↓
IF different:
  - Fetch list of documents to add/remove
  - Batch download new documents (Future.wait)
  - Batch save to Hive (putAll)
  - Batch delete removed documents (deleteAll)
  - Update metadata
    ↓
IF same:
  - Skip (zero network)
    ↓
Schedule next sync (24h timer)
    ↓
✅ Ready for AI Coach queries
```

### 6.2 AI Coach Query with Documents

```
User sends message
    ↓
[AICoach._sendMessage()]
    ↓
Load cached documents from Hive
    ↓
Check if query is document-relevant
    ↓
IF relevant:
  - Search for matching papers (category/keywords)
  - Append top 3 papers to query context
    ↓
Send enriched query to OpenRouter API
    ↓
AI processes query + paper context
    ↓
AI response cites papers with DOI links
    ↓
Display response with clickable citations
```

### 6.3 Background Sync Flow

```
Timer triggers (every 24h)
    ↓
[DocumentSyncService._syncNow()]
    ↓
Lock acquired (prevent concurrent syncs)
    ↓
GET /api/v1/ai-coach/documents/metadata
    ↓
Compare versions
    ↓
IF update needed:
  - Download delta (new papers)
  - Remove deleted papers
  - Update cache
  - Update metadata
    ↓
Release lock
    ↓
✅ Next sync in 24h
```

---

## 7. Performance Optimizations (CRITICAL)

### 7.1 Batch Operations

```dart
// ✅ CORRECT - Batch operations
await _documentsBox.putAll(entries);       // Single Hive transaction
await _documentsBox.deleteAll(ids);        // Batch delete

// ❌ WRONG - Loop operations
for (var paper in papers) {
  await _documentsBox.put(paper.id, paper);  // Multiple transactions!
}
```

### 7.2 Resource Management

```dart
// ✅ CORRECT - Open box once, reuse
class DocumentLocalDataSource {
  late Box<ScientificPaperModel> _documentsBox;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _documentsBox = await Hive.openBox(...);
    _initialized = true;
  }
}

// ❌ WRONG - Open box in every method
Future<List<ScientificPaperModel>> getAll() async {
  final box = await Hive.openBox(...);  // Reopening every time!
  return box.values.toList();
}
```

### 7.3 Concurrent Async Operations

```dart
// ✅ CORRECT - Parallel fetches
final papers = await Future.wait(
  ids.map((id) => fetchDocument(id)),
);

// ❌ WRONG - Sequential fetches
for (var id in ids) {
  final paper = await fetchDocument(id);  // Waits for each!
}
```

### 7.4 Sync Lock

```dart
// ✅ CORRECT - Prevent concurrent syncs
final _lock = Lock();

Future<void> _syncNow() async {
  await _lock.synchronized(() async {
    // Sync logic here - only one at a time
  });
}

// ❌ WRONG - No lock, multiple syncs can run simultaneously
Future<void> _syncNow() async {
  // Race condition if called multiple times!
}
```

---

## 8. Implementation Checklist

### Domain Layer
- [ ] Create `scientific_paper.dart` entity with Freezed
- [ ] Create `document_sync_status.dart` entity with Freezed
- [ ] Create `document_repository.dart` interface
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`

### Data Layer
- [ ] Create `scientific_paper_model.dart` with Hive + Freezed + JSON
- [ ] Create `document_local_datasource.dart` (Hive operations)
- [ ] Create `document_remote_datasource.dart` (Dio API calls)
- [ ] Create `document_repository_impl.dart`
- [ ] Create `document_sync_service.dart` (singleton + timer)
- [ ] Register Hive adapters in `main.dart`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`

### Presentation Layer
- [ ] Create `document_sync_provider.dart` with Riverpod
- [ ] Integrate with `ai_chat_provider.dart`
- [ ] Update `ai_system_prompt.dart` with document citation section
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`

### Testing
- [ ] Unit tests for repository
- [ ] Unit tests for datasources
- [ ] Integration test for sync service
- [ ] Test document enrichment in AI Coach

### Performance
- [ ] Run `.claude/scripts/performance-check.sh lib/features/ai_coach/`
- [ ] Verify batch operations (no loops with I/O)
- [ ] Verify singleton pattern for service
- [ ] Verify lock on sync operations

---

## 9. API Client Configuration

### 9.1 Dio Setup

```dart
// In lib/core/network/dio_client.dart
final documentsApiClient = Dio(
  BaseOptions(
    baseUrl: 'https://YOUR_BACKEND_URL',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ),
);

// Add auth interceptor
documentsApiClient.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await getAuthToken();
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    },
  ),
);
```

---

## 10. Error Handling

### 10.1 Network Errors

```dart
// In DocumentRemoteDataSource
Future<Map<String, dynamic>> checkForUpdates(String localVersion) async {
  try {
    final response = await _dio.get(...);
    return response.data;
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw 'Connection timeout - check internet';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw 'Server timeout - try again later';
    } else if (e.response?.statusCode == 401) {
      throw 'Authentication failed - login again';
    } else {
      throw 'Network error: ${e.message}';
    }
  }
}
```

### 10.2 Cache Errors

```dart
// In DocumentLocalDataSource
Future<List<ScientificPaperModel>> getAll() async {
  try {
    await initialize();
    return _documentsBox.values.where((p) => p.active).toList();
  } on HiveError catch (e) {
    debugPrint('[CACHE] ❌ Hive error: $e');
    rethrow;
  }
}
```

---

## 11. Testing Strategy

### 11.1 Unit Tests

```dart
// test/features/ai_coach/data/repositories/document_repository_impl_test.dart
void main() {
  late DocumentRepositoryImpl repository;
  late MockDocumentLocalDataSource mockLocalDataSource;
  late MockDocumentRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockDocumentLocalDataSource();
    mockRemoteDataSource = MockDocumentRemoteDataSource();
    repository = DocumentRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  group('syncDocuments', () {
    test('should batch save new documents', () async {
      // Arrange
      when(mockLocalDataSource.getMetadata())
          .thenAnswer((_) async => DocumentMetadata(version: 'v1.0', ...));
      when(mockRemoteDataSource.checkForUpdates('v1.0'))
          .thenAnswer((_) async => {'version': 'v2.0', ...});

      // Act
      final result = await repository.syncDocuments();

      // Assert
      verify(mockLocalDataSource.saveAll(any)).called(1); // BATCH operation
      expect(result.isRight(), true);
    });
  });
}
```

---

## 12. Success Criteria

- ✅ Initial sync completes in <5 seconds (8-10 papers)
- ✅ Background sync runs every 24h without user action
- ✅ Offline mode works (cache available immediately)
- ✅ AI Coach cites papers with DOI links
- ✅ Zero performance issues (batch ops, no loops)
- ✅ Sync status visible in UI
- ✅ Manual sync available if needed
- ✅ Documents searchable by category/keywords

---

## 13. Future Enhancements

- [ ] Push notifications when new papers added
- [ ] User favorites (bookmark papers)
- [ ] PDF viewer in-app (for open access papers)
- [ ] Share papers to social media
- [ ] Search history for documents
- [ ] Download progress indicator for sync

---

**Questions? Contact AI Coach Team.**
