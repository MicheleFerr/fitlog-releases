/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/services
/// 🎯 Feature: Trigram Index for Fast Fuzzy Search
/// 🔧 Type: Service
///
/// Trigram-based index for O(1) candidate lookup in fuzzy search.
///
/// **How it works**:
/// 1. Build phase: Extract 3-char substrings from each exercise name
/// 2. Index phase: Map each trigram → list of exercise IDs
/// 3. Search phase: Get candidates by overlapping trigrams, then rank
///
/// **Performance**:
/// - Build: O(n * m) where n = exercises, m = avg name length
/// - Search: O(1) lookup + O(k) filtering where k = candidates
/// - Memory: O(n * m) for the inverted index
///
/// **Usage**:
/// ```dart
/// final index = TrigramIndex<Exercise>(
///   items: exercises,
///   getId: (e) => e.id,
///   getText: (e) => e.nome,
/// );
///
/// // Fast candidate lookup
/// final candidates = index.getCandidates('bench press');
/// ```
library;

import 'dart:collection';

/// Trigram-based inverted index for fast fuzzy search pre-filtering
///
/// Uses n-gram (specifically trigram) indexing to quickly find
/// candidate matches before expensive fuzzy matching.
class TrigramIndex<T> {
  /// Creates and builds the trigram index
  ///
  /// [items] - List of items to index
  /// [getId] - Function to extract unique ID from item
  /// [getText] - Function to extract searchable text from item
  /// [minTrigramLength] - Minimum query length to use trigrams (default: 3)
  TrigramIndex({
    required List<T> items,
    required String Function(T) getId,
    required String Function(T) getText,
    this.minTrigramLength = 3,
  })  : _getId = getId,
        _getText = getText {
    _buildIndex(items);
  }

  final String Function(T) _getId;
  final String Function(T) _getText;

  /// Minimum query length to use trigram matching
  final int minTrigramLength;

  /// Inverted index: trigram → set of item IDs
  final Map<String, Set<String>> _trigramToIds = {};

  /// Forward index: ID → item (for fast retrieval)
  final Map<String, T> _idToItem = {};

  /// All items for fallback full scan
  final List<T> _allItems = [];

  /// Build the trigram index from items
  void _buildIndex(List<T> items) {
    _allItems.clear();
    _allItems.addAll(items);

    for (final item in items) {
      final id = _getId(item);
      final text = _getText(item);

      _idToItem[id] = item;

      final trigrams = _extractTrigrams(text);
      for (final trigram in trigrams) {
        _trigramToIds.putIfAbsent(trigram, () => <String>{}).add(id);
      }
    }
  }

  /// Extract all trigrams from text
  ///
  /// Normalizes text first (lowercase, accents removed)
  Set<String> _extractTrigrams(String text) {
    final normalized = _normalize(text);
    final trigrams = <String>{};

    if (normalized.length < 3) {
      // For short texts, use the whole thing
      trigrams.add(normalized);
      return trigrams;
    }

    // Sliding window of 3 characters
    for (var i = 0; i <= normalized.length - 3; i++) {
      trigrams.add(normalized.substring(i, i + 3));
    }

    return trigrams;
  }

  /// Normalize text for consistent matching
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
  }

  /// Get candidate items matching the query
  ///
  /// Uses trigram overlap to quickly find potential matches.
  /// Returns items sorted by trigram overlap score (descending).
  ///
  /// [query] - Search query
  /// [minOverlap] - Minimum trigram overlap ratio (0.0-1.0). Default: 0.3
  /// [maxCandidates] - Maximum candidates to return. Default: 50
  List<TrigramCandidate<T>> getCandidates(
    String query, {
    double minOverlap = 0.3,
    int maxCandidates = 50,
  }) {
    final normalizedQuery = _normalize(query);

    // For very short queries, return all items
    if (normalizedQuery.length < minTrigramLength) {
      return _allItems
          .take(maxCandidates)
          .map((item) => TrigramCandidate(item: item, overlapScore: 0.0))
          .toList();
    }

    final queryTrigrams = _extractTrigrams(normalizedQuery);
    if (queryTrigrams.isEmpty) return [];

    // Count how many query trigrams match each item
    final candidateScores = <String, int>{};

    for (final trigram in queryTrigrams) {
      final matchingIds = _trigramToIds[trigram];
      if (matchingIds != null) {
        for (final id in matchingIds) {
          candidateScores[id] = (candidateScores[id] ?? 0) + 1;
        }
      }
    }

    // Calculate overlap score and filter
    final candidates = <TrigramCandidate<T>>[];
    final queryTrigramCount = queryTrigrams.length;

    for (final entry in candidateScores.entries) {
      final overlapScore = entry.value / queryTrigramCount;

      if (overlapScore >= minOverlap) {
        final item = _idToItem[entry.key];
        if (item != null) {
          candidates.add(TrigramCandidate(
            item: item,
            overlapScore: overlapScore,
          ));
        }
      }
    }

    // Sort by overlap score (descending)
    candidates.sort((a, b) => b.overlapScore.compareTo(a.overlapScore));

    return candidates.take(maxCandidates).toList();
  }

  /// Get all items (for fallback full scan)
  List<T> get allItems => UnmodifiableListView(_allItems);

  /// Get index statistics
  TrigramIndexStats get stats => TrigramIndexStats(
        totalItems: _allItems.length,
        totalTrigrams: _trigramToIds.length,
        avgTrigramsPerItem: _allItems.isEmpty
            ? 0.0
            : _trigramToIds.values.fold<int>(
                    0, (sum, set) => sum + set.length) /
                _allItems.length,
      );

  /// Rebuild index with new items
  void rebuild(List<T> items) {
    _trigramToIds.clear();
    _idToItem.clear();
    _buildIndex(items);
  }

  /// Add a single item to the index
  void addItem(T item) {
    final id = _getId(item);
    final text = _getText(item);

    _allItems.add(item);
    _idToItem[id] = item;

    final trigrams = _extractTrigrams(text);
    for (final trigram in trigrams) {
      _trigramToIds.putIfAbsent(trigram, () => <String>{}).add(id);
    }
  }

  /// Remove a single item from the index
  void removeItem(String id) {
    final item = _idToItem.remove(id);
    if (item == null) return;

    _allItems.removeWhere((i) => _getId(i) == id);

    final text = _getText(item);
    final trigrams = _extractTrigrams(text);
    for (final trigram in trigrams) {
      _trigramToIds[trigram]?.remove(id);
      if (_trigramToIds[trigram]?.isEmpty ?? false) {
        _trigramToIds.remove(trigram);
      }
    }
  }
}

/// Candidate result from trigram pre-filtering
class TrigramCandidate<T> {
  /// Creates a trigram candidate
  const TrigramCandidate({
    required this.item,
    required this.overlapScore,
  });

  /// The candidate item
  final T item;

  /// Trigram overlap score (0.0 - 1.0)
  ///
  /// Higher score means more query trigrams matched
  final double overlapScore;

  @override
  String toString() =>
      'TrigramCandidate(overlapScore: ${(overlapScore * 100).toStringAsFixed(1)}%)';
}

/// Statistics about the trigram index
class TrigramIndexStats {
  /// Creates index statistics
  const TrigramIndexStats({
    required this.totalItems,
    required this.totalTrigrams,
    required this.avgTrigramsPerItem,
  });

  /// Total items indexed
  final int totalItems;

  /// Total unique trigrams
  final int totalTrigrams;

  /// Average trigram references per item
  final double avgTrigramsPerItem;

  @override
  String toString() =>
      'TrigramIndexStats(items: $totalItems, trigrams: $totalTrigrams, avg: ${avgTrigramsPerItem.toStringAsFixed(1)})';
}
