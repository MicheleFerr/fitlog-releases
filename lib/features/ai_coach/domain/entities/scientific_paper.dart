/// Scientific Paper Entity
///
/// Represents a scientific paper with metadata and abstract.
/// Used by AI Coach to cite research in responses.
///
/// **Layer**: Domain - Entity
/// **Feature**: AI Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'scientific_paper.freezed.dart';

/// Represents a scientific paper with metadata and abstract
@freezed
sealed class ScientificPaper with _$ScientificPaper {
  const factory ScientificPaper({
    required String id,
    required String title,
    required List<String> authors,
    required int year,
    required String doi,
    required String abstract,
    required String summary, // Short 1-2 sentence summary for AI
    required String url,
    required String license,
    required List<String> categories, // ['hypertrophy', 'strength', etc.]
    required List<String> keywords,
    required DateTime uploadedAt,
    required DateTime updatedAt,
    required bool active,
    Map<String, dynamic>? metadata, // Journal, volume, issue, pages
  }) = _ScientificPaper;

  const ScientificPaper._();

  /// Format paper citation for AI responses
  /// Example: "Schoenfeld et al. (2017)"
  String formatCitation() {
    final authorsStr = authors.length > 3
        ? '${authors.take(3).join(", ")} et al.'
        : authors.join(', ');
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
