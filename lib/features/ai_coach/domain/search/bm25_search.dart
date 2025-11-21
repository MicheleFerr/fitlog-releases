/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/search
/// 🎯 Feature: ai_coach
/// 🔧 Type: search_algorithm
///
/// BM25 Search Algorithm - Probabilistic ranking for information retrieval
///
/// **Features**:
/// - BM25 scoring algorithm (best match 25)
/// - Term frequency saturation
/// - Document length normalization
/// - Inverse document frequency weighting
/// - Optimized for fitness domain vocabulary
library;

import 'dart:math' as math;

/// BM25 parameters for fitness domain
class BM25Parameters {
  /// Term frequency saturation parameter (typically 1.2-2.0)
  final double k1;

  /// Document length normalization (typically 0.75)
  final double b;

  const BM25Parameters({
    this.k1 = 1.5, // Slightly higher for fitness terms importance
    this.b = 0.75,  // Standard normalization
  });

  /// Optimized parameters for short queries (1-3 words)
  static const BM25Parameters shortQuery = BM25Parameters(
    k1: 1.2,
    b: 0.5, // Less length normalization for short docs
  );

  /// Optimized parameters for long queries (4+ words)
  static const BM25Parameters longQuery = BM25Parameters(
    k1: 2.0,
    b: 0.75,
  );
}

/// Document representation for BM25 scoring
class BM25Document {
  final String id;
  final String content;
  final Map<String, int> termFrequencies;
  final int documentLength;
  final DateTime? timestamp;
  final double? boost; // Optional relevance boost

  BM25Document({
    required this.id,
    required this.content,
    Map<String, int>? termFrequencies,
    this.timestamp,
    this.boost,
  })  : termFrequencies = termFrequencies ?? _computeTermFrequencies(content),
        documentLength = content.split(' ').length;

  static Map<String, int> _computeTermFrequencies(String content) {
    final terms = _tokenize(content);
    final frequencies = <String, int>{};

    for (final term in terms) {
      frequencies[term] = (frequencies[term] ?? 0) + 1;
    }

    return frequencies;
  }

  static List<String> _tokenize(String text) {
    // Fitness-aware tokenization
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty && term.length > 1)
        .toList();
  }
}

/// BM25 search engine for fitness data
class BM25SearchEngine {
  final List<BM25Document> documents = [];
  final BM25Parameters parameters;

  // Cached values for performance
  late double _averageDocumentLength;
  late Map<String, double> _inverseDocumentFrequencies;
  bool _needsReindex = true;

  // Fitness-specific term weights
  static final Map<String, double> _domainWeights = {
    // Exercise names get higher weight
    'squat': 1.5,
    'bench': 1.5,
    'deadlift': 1.5,
    'press': 1.3,
    'curl': 1.3,
    'row': 1.3,

    // Important metrics
    'pr': 2.0, // Personal record very important
    'personal': 1.5,
    'record': 1.5,
    'max': 1.5,
    'volume': 1.3,
    'weight': 1.3,
    'reps': 1.2,
    'sets': 1.2,

    // Time-related terms
    'today': 1.5,
    'yesterday': 1.3,
    'week': 1.2,
    'month': 1.1,

    // Stop words (lower weight)
    'the': 0.3,
    'a': 0.3,
    'an': 0.3,
    'and': 0.3,
    'or': 0.3,
    'but': 0.3,
  };

  BM25SearchEngine({
    this.parameters = const BM25Parameters(),
  });

  /// Add a document to the search index
  void addDocument(BM25Document document) {
    documents.add(document);
    _needsReindex = true;
  }

  /// Add multiple documents
  void addDocuments(List<BM25Document> newDocuments) {
    documents.addAll(newDocuments);
    _needsReindex = true;
  }

  /// Clear all documents
  void clear() {
    documents.clear();
    _needsReindex = true;
  }

  /// Reindex documents (compute IDF and average length)
  void _reindex() {
    if (!_needsReindex || documents.isEmpty) return;

    // Calculate average document length
    final totalLength = documents.fold<int>(
      0,
      (sum, doc) => sum + doc.documentLength,
    );
    _averageDocumentLength = totalLength / documents.length;

    // Calculate IDF for all terms
    _inverseDocumentFrequencies = {};
    final documentCount = documents.length;

    // Count documents containing each term
    final termDocumentCounts = <String, int>{};
    for (final doc in documents) {
      for (final term in doc.termFrequencies.keys) {
        termDocumentCounts[term] = (termDocumentCounts[term] ?? 0) + 1;
      }
    }

    // Calculate IDF using BM25 formula
    for (final entry in termDocumentCounts.entries) {
      final term = entry.key;
      final docFreq = entry.value;

      // IDF = log((N - df + 0.5) / (df + 0.5))
      // Where N = total documents, df = documents containing term
      _inverseDocumentFrequencies[term] = math.log(
        (documentCount - docFreq + 0.5) / (docFreq + 0.5),
      );
    }

    _needsReindex = false;
  }

  /// Search documents with BM25 ranking
  List<SearchResult> search(
    String query, {
    int limit = 10,
    double minScore = 0.0,
  }) {
    if (documents.isEmpty) return [];

    // Ensure index is up to date
    _reindex();

    // Tokenize and weight query terms
    final queryTerms = BM25Document._tokenize(query);
    final queryWeights = _calculateQueryWeights(queryTerms);

    // Score all documents
    final scores = <BM25Document, double>{};

    for (final doc in documents) {
      final score = _scoreDocument(doc, queryWeights);

      // Apply document boost if present
      final boostedScore = score * (doc.boost ?? 1.0);

      // Apply recency boost (optional)
      final recencyBoost = _calculateRecencyBoost(doc.timestamp);
      final finalScore = boostedScore * recencyBoost;

      if (finalScore > minScore) {
        scores[doc] = finalScore;
      }
    }

    // Sort by score and return top results
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .take(limit)
        .map((entry) => SearchResult(
              document: entry.key,
              score: entry.value,
              matchedTerms: _getMatchedTerms(entry.key, queryWeights.keys),
            ))
        .toList();
  }

  /// Calculate weights for query terms
  Map<String, double> _calculateQueryWeights(List<String> queryTerms) {
    final weights = <String, double>{};

    for (final term in queryTerms) {
      // Apply domain-specific weight
      final domainWeight = _domainWeights[term] ?? 1.0;

      // Count term frequency in query
      final queryTermFreq = queryTerms.where((t) => t == term).length;

      weights[term] = (weights[term] ?? 0) + (queryTermFreq * domainWeight);
    }

    return weights;
  }

  /// Score a document against weighted query terms
  double _scoreDocument(
    BM25Document document,
    Map<String, double> queryWeights,
  ) {
    double score = 0.0;

    for (final entry in queryWeights.entries) {
      final term = entry.key;
      final queryWeight = entry.value;

      // Skip if term not in document
      final termFreq = document.termFrequencies[term];
      if (termFreq == null || termFreq == 0) continue;

      // Get IDF (or use default for unknown terms)
      final idf = _inverseDocumentFrequencies[term] ?? 0.0;

      // BM25 formula
      // score = IDF * (f(qi, D) * (k1 + 1)) / (f(qi, D) + k1 * (1 - b + b * |D| / avgdl))
      final numerator = termFreq * (parameters.k1 + 1);
      final denominator = termFreq +
          parameters.k1 *
              (1 -
                  parameters.b +
                  parameters.b * document.documentLength / _averageDocumentLength);

      score += idf * queryWeight * (numerator / denominator);
    }

    return score;
  }

  /// Calculate recency boost for time-sensitive queries
  double _calculateRecencyBoost(DateTime? timestamp) {
    if (timestamp == null) return 1.0;

    final now = DateTime.now();
    final age = now.difference(timestamp);

    // Exponential decay over 30 days
    if (age.inDays <= 1) return 1.5; // Today/yesterday boost
    if (age.inDays <= 7) return 1.3; // This week boost
    if (age.inDays <= 30) return 1.1; // This month boost

    // Slow decay after 30 days
    return 1.0 - (age.inDays / 365).clamp(0.0, 0.5);
  }

  /// Get terms from document that match query
  Set<String> _getMatchedTerms(BM25Document document, Iterable<String> queryTerms) {
    final matched = <String>{};

    for (final term in queryTerms) {
      if (document.termFrequencies.containsKey(term)) {
        matched.add(term);
      }
    }

    return matched;
  }
}

/// Search result with relevance information
class SearchResult {
  final BM25Document document;
  final double score;
  final Set<String> matchedTerms;

  const SearchResult({
    required this.document,
    required this.score,
    required this.matchedTerms,
  });

  /// Normalized score (0-1 range)
  double get normalizedScore => (score / 100).clamp(0.0, 1.0);

  /// Confidence level based on score
  String get confidence {
    if (normalizedScore > 0.8) return 'high';
    if (normalizedScore > 0.5) return 'medium';
    return 'low';
  }
}