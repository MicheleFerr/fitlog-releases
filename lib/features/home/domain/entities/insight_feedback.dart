import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain entity for user feedback on AI Coach insights
///
/// This allows users to rate insights (thumbs up/down) and helps
/// improve AI Coach recommendations over time.
class InsightFeedback {
  const InsightFeedback({
    required this.id,
    required this.userId,
    required this.insightType,
    required this.insightHash,
    required this.isHelpful,
    this.comment,
    required this.timestamp,
  });

  /// Create from Firestore JSON
  factory InsightFeedback.fromJson(Map<String, dynamic> json) {
    return InsightFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      insightType: json['insightType'] as String,
      insightHash: json['insightHash'] as String,
      isHelpful: json['isHelpful'] as bool,
      comment: json['comment'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Unique identifier for this feedback
  final String id;

  /// User ID who gave the feedback
  final String userId;

  /// Type of insight that was rated
  final String insightType;

  /// Hash of the insight content for identification
  /// Generated from: type + affected data (exercise names, muscle groups, etc.)
  final String insightHash;

  /// User's feedback: true = helpful, false = not helpful
  final bool isHelpful;

  /// Optional text feedback from user
  final String? comment;

  /// Timestamp when feedback was given
  final DateTime timestamp;

  /// Create a copy with modified fields
  InsightFeedback copyWith({
    String? id,
    String? userId,
    String? insightType,
    String? insightHash,
    bool? isHelpful,
    String? comment,
    DateTime? timestamp,
  }) {
    return InsightFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      insightType: insightType ?? this.insightType,
      insightHash: insightHash ?? this.insightHash,
      isHelpful: isHelpful ?? this.isHelpful,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'insightType': insightType,
      'insightHash': insightHash,
      'isHelpful': isHelpful,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InsightFeedback &&
        other.id == id &&
        other.userId == userId &&
        other.insightType == insightType &&
        other.insightHash == insightHash &&
        other.isHelpful == isHelpful &&
        other.comment == comment &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      insightType,
      insightHash,
      isHelpful,
      comment,
      timestamp,
    );
  }

  @override
  String toString() {
    return 'InsightFeedback(id: $id, userId: $userId, insightType: $insightType, '
        'isHelpful: $isHelpful, timestamp: $timestamp)';
  }
}
