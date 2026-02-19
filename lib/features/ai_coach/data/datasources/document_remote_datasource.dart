/// Document Remote DataSource
///
/// Fetches scientific papers from Firebase API.
/// Handles API calls with proper error handling.
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/models/scientific_paper_model.dart';

/// Remote data source for AI Coach documents using Firebase API
class DocumentRemoteDataSource {

  DocumentRemoteDataSource({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;
  final http.Client _client;
  final String _baseUrl;

  /// Check for updates (compare versions)
  /// Returns metadata with list of documents to add/remove
  Future<Map<String, dynamic>> checkForUpdates(String localVersion) async {
    try {
      debugPrint(
        '[DOCUMENTS_REMOTE] 🔍 Checking for updates (local: $localVersion)',
      );

      final uri = Uri.parse('$_baseUrl/api/v1/ai-coach/documents/metadata');
      final response = await _client.get(
        uri,
        headers: {
          'X-Local-Version': localVersion,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        _handleHttpError(response);
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      debugPrint(
        '[DOCUMENTS_REMOTE] ✅ Update check complete: ${data['version']}',
      );

      return data;
    } catch (e) {
      debugPrint('[DOCUMENTS_REMOTE] ❌ Update check failed: $e');
      rethrow;
    }
  }

  /// Fetch document metadata by ID
  Future<ScientificPaperModel> fetchDocument(String docId) async {
    try {
      debugPrint('[DOCUMENTS_REMOTE] 📥 Fetching document: $docId');

      final uri =
          Uri.parse('$_baseUrl/api/v1/ai-coach/documents/$docId/metadata');
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        _handleHttpError(response);
      }

      return ScientificPaperModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('[DOCUMENTS_REMOTE] ❌ Fetch failed for $docId: $e');
      rethrow;
    }
  }

  /// Batch fetch documents by IDs (PERFORMANCE)
  /// Usa chunk da 5 per evitare di aprire centinaia di connessioni simultanee
  Future<List<ScientificPaperModel>> fetchDocuments(List<String> ids) async {
    debugPrint('[DOCUMENTS_REMOTE] 📥 Batch fetching ${ids.length} documents');

    try {
      const chunkSize = 5;
      final results = <ScientificPaperModel>[];

      for (var i = 0; i < ids.length; i += chunkSize) {
        final chunk = ids.sublist(i, min(i + chunkSize, ids.length));
        final chunkResults = await Future.wait(chunk.map(fetchDocument));
        results.addAll(chunkResults);
        debugPrint('[DOCUMENTS_REMOTE] 📦 Chunk ${(i ~/ chunkSize) + 1}: ${chunkResults.length} docs');
      }

      debugPrint(
        '[DOCUMENTS_REMOTE] ✅ Batch fetch complete: ${results.length} documents',
      );

      return results;
    } catch (e) {
      debugPrint('[DOCUMENTS_REMOTE] ❌ Batch fetch failed: $e');
      rethrow;
    }
  }

  /// Handle HTTP errors with proper messages
  Never _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw Exception('Authentication failed - login again');
      case 404:
        throw Exception('Document not found');
      case 408:
        throw Exception('Request timeout - check internet');
      case 500:
      case 502:
      case 503:
        throw Exception('Server error - try again later');
      default:
        throw Exception('HTTP error ${response.statusCode}: ${response.body}');
    }
  }
}
