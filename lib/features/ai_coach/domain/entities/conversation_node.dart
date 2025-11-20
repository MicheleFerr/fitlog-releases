/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// ConversationNode - Single node in conversation tree
///
/// **Purpose**: Enable branching conversations with back navigation
///
/// **Features**:
/// - Parent/child relationships
/// - Multiple children per node (branching)
/// - Message data at each node
/// - Timestamp for ordering
///
/// **Usage**:
/// ```dart
/// final root = ConversationNode(
///   id: 'node-1',
///   parentId: null, // Root has no parent
///   childrenIds: ['node-2', 'node-3'],
///   message: AIMessage(...),
/// );
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';

part 'conversation_node.freezed.dart';
part 'conversation_node.g.dart';

@freezed
class ConversationNode with _$ConversationNode {
  const ConversationNode._();

  const factory ConversationNode({
    /// Unique node ID (UUID)
    required String id,

    /// Parent node ID (null for root)
    String? parentId,

    /// Child node IDs (branches)
    @Default([]) List<String> childrenIds,

    /// Message at this node
    required AIMessage message,

    /// Node creation timestamp
    required DateTime timestamp,

    /// Whether this node is the current active node
    @Default(false) bool isCurrent,
  }) = _ConversationNode;

  /// Create from JSON (Hive deserialization)
  factory ConversationNode.fromJson(Map<String, dynamic> json) =>
      _$ConversationNodeFromJson(json);

  /// Check if this node is root (no parent)
  bool get isRoot => parentId == null;

  /// Check if this node is leaf (no children)
  bool get isLeaf => childrenIds.isEmpty;

  /// Get depth in tree (root = 0, children = 1, etc.)
  ///
  /// **Note**: This requires tree context to calculate.
  /// Use ConversationTree.getNodeDepth() instead.
}
