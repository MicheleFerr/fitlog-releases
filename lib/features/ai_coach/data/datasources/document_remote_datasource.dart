/// Document Remote DataSource
///
/// Fetches scientific papers from Firebase API.
/// Handles API calls with proper error handling.
///
/// **Layer**: Data - DataSource
/// **Feature**: AI Coach
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/scientific_paper_model.dart';

/// Remote data source for AI Coach documents using Firebase API
class DocumentRemoteDataSource {
  final http.Client _client;
  final String _baseUrl;

  DocumentRemoteDataSource({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

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
      );

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
      );

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
  /// Uses Future.wait for parallel fetching
  Future<List<ScientificPaperModel>> fetchDocuments(List<String> ids) async {
    debugPrint('[DOCUMENTS_REMOTE] 📥 Batch fetching ${ids.length} documents');

    try {
      // Parallel fetch - PERFORMANCE
      final responses = await Future.wait(
        ids.map((id) => fetchDocument(id)),
      );

      debugPrint(
        '[DOCUMENTS_REMOTE] ✅ Batch fetch complete: ${responses.length} documents',
      );

      return responses;
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
