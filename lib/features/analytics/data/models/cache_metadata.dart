/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/models
/// 🎯 Feature: Cache Metadata Model
/// 🔧 Type: Data Model
///
/// Metadata wrapper for cached items with TTL support.
///
/// **Features**:
/// - TTL (Time-To-Live) expiration
/// - Creation timestamp tracking
/// - JSON serialization/deserialization
/// - Type-safe value wrapping
///
/// **Usage**:
/// ```dart
/// final metadata = CacheMetadata<UserData>(
///   value: userData,
///   createdAt: DateTime.now(),
///   ttl: const Duration(hours: 1),
/// );
///
/// if (metadata.isExpired) {
///   // Refresh cache
/// }
/// ```
library;

import 'package:flutter/foundation.dart';

/// Metadata wrapper for cached items
///
/// Wraps any cached value with TTL and timestamp information
/// to support automatic expiration.
@immutable
class CacheMetadata<T> {
  /// Creates a cache metadata wrapper
  const CacheMetadata({
    required this.value,
    required this.createdAt,
    this.ttl,
    this.key,
  });

  /// Create from JSON with a value converter
  ///
  /// [json] - The JSON map containing metadata
  /// [valueFromJson] - Converter function for the value
  factory CacheMetadata.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) valueFromJson,
  ) {
    return CacheMetadata<T>(
      value: valueFromJson(json['value']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      ttl: json['ttlMs'] != null
          ? Duration(milliseconds: json['ttlMs'] as int)
          : null,
      key: json['key'] as String?,
    );
  }

  /// The cached value
  final T value;

  /// When the cache entry was created
  final DateTime createdAt;

  /// Time-to-live duration (null = never expires)
  final Duration? ttl;

  /// Optional cache key for debugging
  final String? key;

  /// Check if the cache entry has expired
  bool get isExpired {
    if (ttl == null) return false;
    final expiresAt = createdAt.add(ttl!);
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if the cache entry is still valid
  bool get isValid => !isExpired;

  /// Time until expiration (null if never expires, negative if already expired)
  Duration? get timeUntilExpiration {
    if (ttl == null) return null;
    final expiresAt = createdAt.add(ttl!);
    return expiresAt.difference(DateTime.now());
  }

  /// Expiration timestamp (null if never expires)
  DateTime? get expiresAt => ttl != null ? createdAt.add(ttl!) : null;

  /// Age of the cache entry
  Duration get age => DateTime.now().difference(createdAt);

  /// Convert to JSON with a value converter
  ///
  /// [valueToJson] - Converter function for the value (optional for primitives)
  Map<String, dynamic> toJson([dynamic Function(T)? valueToJson]) {
    return {
      'value': valueToJson != null ? valueToJson(value) : value,
      'createdAt': createdAt.toIso8601String(),
      'ttlMs': ttl?.inMilliseconds,
      'key': key,
    };
  }

  /// Create a copy with updated fields
  CacheMetadata<T> copyWith({
    T? value,
    DateTime? createdAt,
    Duration? ttl,
    String? key,
    bool clearTtl = false,
  }) {
    return CacheMetadata<T>(
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      ttl: clearTtl ? null : (ttl ?? this.ttl),
      key: key ?? this.key,
    );
  }

  /// Create a refreshed entry with new timestamp
  CacheMetadata<T> refresh() {
    return copyWith(createdAt: DateTime.now());
  }

  @override
  String toString() {
    return 'CacheMetadata(key: $key, createdAt: $createdAt, ttl: $ttl, isExpired: $isExpired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheMetadata<T> &&
        other.value == value &&
        other.createdAt == createdAt &&
        other.ttl == ttl &&
        other.key == key;
  }

  @override
  int get hashCode => Object.hash(value, createdAt, ttl, key);
}

/// Cache statistics for monitoring and debugging
@immutable
class CacheStatistics {
  /// Creates cache statistics
  const CacheStatistics({
    this.totalKeys = 0,
    this.totalHits = 0,
    this.totalMisses = 0,
    this.totalSize = 0,
    this.oldestEntry,
    this.newestEntry,
    this.expiredKeys = 0,
  });

  /// Total number of keys in cache
  final int totalKeys;

  /// Total cache hits
  final int totalHits;

  /// Total cache misses
  final int totalMisses;

  /// Approximate total size in bytes
  final int totalSize;

  /// Timestamp of oldest cache entry
  final DateTime? oldestEntry;

  /// Timestamp of newest cache entry
  final DateTime? newestEntry;

  /// Number of expired keys (pending cleanup)
  final int expiredKeys;

  /// Cache hit rate (0.0 - 1.0)
  double get hitRate {
    final total = totalHits + totalMisses;
    if (total == 0) return 0.0;
    return totalHits / total;
  }

  /// Convert to JSON map for logging/debugging
  Map<String, dynamic> toJson() {
    return {
      'totalKeys': totalKeys,
      'totalHits': totalHits,
      'totalMisses': totalMisses,
      'hitRate': hitRate,
      'totalSize': totalSize,
      'oldestEntry': oldestEntry?.toIso8601String(),
      'newestEntry': newestEntry?.toIso8601String(),
      'expiredKeys': expiredKeys,
    };
  }

  /// Create updated statistics
  CacheStatistics copyWith({
    int? totalKeys,
    int? totalHits,
    int? totalMisses,
    int? totalSize,
    DateTime? oldestEntry,
    DateTime? newestEntry,
    int? expiredKeys,
  }) {
    return CacheStatistics(
      totalKeys: totalKeys ?? this.totalKeys,
      totalHits: totalHits ?? this.totalHits,
      totalMisses: totalMisses ?? this.totalMisses,
      totalSize: totalSize ?? this.totalSize,
      oldestEntry: oldestEntry ?? this.oldestEntry,
      newestEntry: newestEntry ?? this.newestEntry,
      expiredKeys: expiredKeys ?? this.expiredKeys,
    );
  }

  /// Increment hits counter
  CacheStatistics recordHit() => copyWith(totalHits: totalHits + 1);

  /// Increment misses counter
  CacheStatistics recordMiss() => copyWith(totalMisses: totalMisses + 1);

  @override
  String toString() {
    return 'CacheStatistics(keys: $totalKeys, hits: $totalHits, misses: $totalMisses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}
