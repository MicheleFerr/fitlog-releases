/// Scientific Paper Model
///
/// Data model with Hive + JSON serialization for caching.
/// Converts between domain entity and persistent storage.
///
/// **Layer**: Data - Model
/// **Feature**: AI Coach
library;

import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/scientific_paper.dart';

part 'scientific_paper_model.g.dart';

@HiveType(typeId: 10)
class ScientificPaperModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> authors;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String doi;

  @HiveField(5)
  final String abstract;

  @HiveField(6)
  final String summary;

  @HiveField(7)
  final String url;

  @HiveField(8)
  final String license;

  @HiveField(9)
  final List<String> categories;

  @HiveField(10)
  final List<String> keywords;

  @HiveField(11)
  final DateTime uploadedAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final bool active;

  @HiveField(14)
  final Map<dynamic, dynamic> metadata;

  ScientificPaperModel({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.doi,
    required this.abstract,
    required this.summary,
    required this.url,
    required this.license,
    required this.categories,
    required this.keywords,
    required this.uploadedAt,
    required this.updatedAt,
    required this.active,
    this.metadata = const {},
  });

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
        metadata: metadata.isEmpty ? null : Map<String, dynamic>.from(metadata),
      );

  /// Create from domain entity
  factory ScientificPaperModel.fromDomain(ScientificPaper paper) =>
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
        metadata: paper.metadata ?? {},
      );

  /// Convert from JSON (from API response)
  factory ScientificPaperModel.fromJson(Map<String, dynamic> json) =>
      ScientificPaperModel(
        id: json['id'] as String,
        title: json['title'] as String,
        authors: List<String>.from(json['authors'] as List),
        year: json['year'] as int,
        doi: json['doi'] as String,
        abstract: json['abstract'] as String,
        summary: json['summary'] as String,
        url: json['url'] as String,
        license: json['license'] as String,
        categories: List<String>.from(json['categories'] as List),
        keywords: List<String>.from(json['keywords'] as List),
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        active: json['active'] as bool,
        metadata: json['metadata'] as Map<dynamic, dynamic>? ?? {},
      );

  /// Convert to JSON (for API requests)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'authors': authors,
        'year': year,
        'doi': doi,
        'abstract': abstract,
        'summary': summary,
        'url': url,
        'license': license,
        'categories': categories,
        'keywords': keywords,
        'uploadedAt': uploadedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'active': active,
        'metadata': metadata,
      };
}

/// Simple metadata for document sync status
/// Stored as Map in Hive (no type adapter needed)
class DocumentMetadata {
  final String version;
  final String hash;
  final DateTime lastSyncAt;
  final int documentsCount;

  DocumentMetadata({
    required this.version,
    required this.hash,
    required this.lastSyncAt,
    required this.documentsCount,
  });

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
        'version': version,
        'hash': hash,
        'lastSyncAt': lastSyncAt.toIso8601String(),
        'documentsCount': documentsCount,
      };

  /// Create from Map from Hive storage
  factory DocumentMetadata.fromMap(Map<String, dynamic> map) =>
      DocumentMetadata(
        version: map['version'] as String,
        hash: map['hash'] as String,
        lastSyncAt: DateTime.parse(map['lastSyncAt'] as String),
        documentsCount: map['documentsCount'] as int,
      );
}
