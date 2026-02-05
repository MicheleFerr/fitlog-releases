/// Document Local DataSource
///
/// Manages Hive cache for scientific papers.
/// Provides batch operations for performance (no I/O in loops).
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/scientific_paper_model.dart';

/// Box names for Hive storage
const String documentsBoxName = 'ai_coach_documents';
const String documentMetaBoxName = 'ai_coach_documents_meta';

/// Local data source for AI Coach documents using Hive
class DocumentLocalDataSource {
  late Box<ScientificPaperModel> _documentsBox;
  late Box<Map<dynamic, dynamic>> _metaBox;
  bool _initialized = false;

  /// Initialize Hive boxes (call once on app start)
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _documentsBox =
          await Hive.openBox<ScientificPaperModel>(documentsBoxName);
      _metaBox = await Hive.openBox<Map<dynamic, dynamic>>(documentMetaBoxName);
      _initialized = true;
      debugPrint('[DOCUMENTS_LOCAL] ✅ Initialized Hive boxes');
    } catch (e) {
      debugPrint('[DOCUMENTS_LOCAL] ❌ Failed to initialize: $e');
      rethrow;
    }
  }

  /// Get all active papers
  /// Performance: Single box.values call, no loop I/O
  Future<List<ScientificPaperModel>> getAll() async {
    await initialize();
    return _documentsBox.values.where((paper) => paper.active).toList();
  }

  /// Get papers by category
  /// Performance: Single box.values call with filter
  Future<List<ScientificPaperModel>> getByCategory(String category) async {
    await initialize();
    return _documentsBox.values
        .where((paper) => paper.active && paper.categories.contains(category))
        .toList();
  }

  /// Search papers (title, summary, keywords)
  /// Performance: Single box.values call with filter
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
  /// Uses putAll instead of loop for efficiency
  Future<void> saveAll(List<ScientificPaperModel> papers) async {
    await initialize();
    final entries = {for (var paper in papers) paper.id: paper};
    await _documentsBox.putAll(entries); // BATCH PUT - no loop
    debugPrint('[DOCUMENTS_LOCAL] ✅ Saved ${papers.length} papers (batch)');
  }

  /// Remove papers by IDs (batch operation - PERFORMANCE)
  /// Uses deleteAll instead of loop for efficiency
  Future<void> removeAll(List<String> ids) async {
    await initialize();
    await _documentsBox.deleteAll(ids); // BATCH DELETE - no loop
    debugPrint('[DOCUMENTS_LOCAL] ✅ Removed ${ids.length} papers (batch)');
  }

  /// Clear all documents
  Future<void> clear() async {
    await initialize();
    await _documentsBox.clear();
    debugPrint('[DOCUMENTS_LOCAL] ✅ Cleared all documents');
  }

  /// Get sync metadata
  Future<DocumentMetadata?> getMetadata() async {
    await initialize();
    final map = _metaBox.get('sync_metadata');
    if (map == null) return null;

    return DocumentMetadata.fromMap(Map<String, dynamic>.from(map));
  }

  /// Save sync metadata
  Future<void> saveMetadata(DocumentMetadata metadata) async {
    await initialize();
    await _metaBox.put('sync_metadata', metadata.toMap());
    debugPrint(
      '[DOCUMENTS_LOCAL] ✅ Updated metadata: ${metadata.version} (${metadata.documentsCount} docs)',
    );
  }

  /// Close boxes (call on app dispose)
  Future<void> dispose() async {
    if (!_initialized) return;

    await _documentsBox.close();
    await _metaBox.close();
    _initialized = false;
    debugPrint('[DOCUMENTS_LOCAL] 🛑 Disposed');
  }
}
