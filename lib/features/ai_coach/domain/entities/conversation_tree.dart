/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// ConversationTree - Manages branching conversation state
///
/// **Purpose**: Track conversation history as tree for back navigation
///
/// **Features**:
/// - Root node tracking
/// - Current node pointer
/// - Parent/child navigation
/// - Branch exploration
///
/// **Usage**:
/// ```dart
/// final tree = ConversationTree.empty(userId: 'user-123');
/// final updatedTree = tree.addNode(message, parentId: tree.currentNodeId);
/// final parent = updatedTree.getParentNode();
/// final children = updatedTree.getChildrenNodes();
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/conversation_node.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';

part 'conversation_tree.freezed.dart';
part 'conversation_tree.g.dart';

@freezed
class ConversationTree with _$ConversationTree {

  const factory ConversationTree({
    /// User ID who owns this tree
    required String userId,

    /// Root node ID (first message in conversation)
    String? rootNodeId,

    /// Current active node ID (where user is in tree)
    String? currentNodeId,

    /// All nodes in tree (keyed by node ID)
    @Default({}) Map<String, ConversationNode> nodes,

    /// Last update timestamp
    required DateTime lastUpdated,
  }) = _ConversationTree;
  const ConversationTree._();

  /// Create empty tree
  factory ConversationTree.empty({required String userId}) {
    return ConversationTree(
      userId: userId,
      rootNodeId: null,
      currentNodeId: null,
      nodes: {},
      lastUpdated: DateTime.now(),
    );
  }

  /// Create from JSON (Hive deserialization)
  factory ConversationTree.fromJson(Map<String, dynamic> json) =>
      _$ConversationTreeFromJson(json);

  /// Check if tree is empty (no nodes)
  bool get isEmpty => nodes.isEmpty;

  /// Check if tree has nodes
  bool get isNotEmpty => nodes.isNotEmpty;

  /// Get current node (where user is in tree)
  ConversationNode? get currentNode {
    if (currentNodeId == null) return null;
    return nodes[currentNodeId];
  }

  /// Get root node (first message)
  ConversationNode? get rootNode {
    if (rootNodeId == null) return null;
    return nodes[rootNodeId];
  }

  /// Get parent of current node (for back navigation)
  ConversationNode? getParentNode() {
    final current = currentNode;
    if (current == null || current.parentId == null) return null;
    return nodes[current.parentId];
  }

  /// Get children of current node (for branch exploration)
  List<ConversationNode> getChildrenNodes() {
    final current = currentNode;
    if (current == null) return [];
    return current.childrenIds
        .map((id) => nodes[id])
        .whereType<ConversationNode>()
        .toList();
  }

  /// Get all messages in current path (root to current)
  ///
  /// **Purpose**: Display conversation history up to current node
  ///
  /// **Example**:
  /// ```
  /// Root (id: 'A')
  ///   └─→ Child (id: 'B')
  ///       └─→ Current (id: 'C')
  ///
  /// getCurrentPath() → [A, B, C]
  /// ```
  List<AIMessage> getCurrentPath() {
    if (currentNode == null) return [];

    final path = <ConversationNode>[];
    var node = currentNode;

    // Walk backwards from current to root
    while (node != null) {
      path.insert(0, node); // Prepend to maintain order
      node = node.parentId != null ? nodes[node.parentId] : null;
    }

    return path.map((n) => n.message).toList();
  }

  /// Add new node to tree
  ///
  /// **Parameters**:
  /// - `message`: AIMessage to add
  /// - `parentId`: Parent node ID (null for root)
  ///
  /// **Returns**: Updated tree with new node added
  ConversationTree addNode(AIMessage message, {String? parentId}) {
    final nodeId = message.id;
    final newNode = ConversationNode(
      id: nodeId,
      parentId: parentId,
      childrenIds: [],
      message: message,
      timestamp: message.timestamp,
      isCurrent: true, // New node becomes current
    );

    // Update parent's children list if parent exists
    final updatedNodes = Map<String, ConversationNode>.from(nodes);
    if (parentId != null && nodes.containsKey(parentId)) {
      final parent = nodes[parentId]!;
      final updatedParent = parent.copyWith(
        childrenIds: [...parent.childrenIds, nodeId],
      );
      updatedNodes[parentId] = updatedParent;
    }

    // Mark previous current node as non-current
    if (currentNodeId != null && nodes.containsKey(currentNodeId)) {
      final oldCurrent = nodes[currentNodeId]!;
      updatedNodes[currentNodeId!] = oldCurrent.copyWith(isCurrent: false);
    }

    // Add new node
    updatedNodes[nodeId] = newNode;

    return copyWith(
      rootNodeId: rootNodeId ?? nodeId, // Set root if first node
      currentNodeId: nodeId,
      nodes: updatedNodes,
      lastUpdated: DateTime.now(),
    );
  }

  /// Navigate to parent node (back button)
  ///
  /// **Returns**: Updated tree with parent as current node (null if at root)
  ConversationTree? navigateToParent() {
    final parent = getParentNode();
    if (parent == null) return null; // Already at root

    // Update current markers
    final updatedNodes = Map<String, ConversationNode>.from(nodes);

    // Mark old current as non-current
    if (currentNodeId != null) {
      final oldCurrent = nodes[currentNodeId]!;
      updatedNodes[currentNodeId!] = oldCurrent.copyWith(isCurrent: false);
    }

    // Mark parent as current
    updatedNodes[parent.id] = parent.copyWith(isCurrent: true);

    return copyWith(
      currentNodeId: parent.id,
      nodes: updatedNodes,
      lastUpdated: DateTime.now(),
    );
  }

  /// Navigate to specific node (tree view selection)
  ///
  /// **Returns**: Updated tree with specified node as current
  ConversationTree navigateToNode(String nodeId) {
    if (!nodes.containsKey(nodeId)) {
      throw ArgumentError('Node $nodeId not found in tree');
    }

    // Update current markers
    final updatedNodes = Map<String, ConversationNode>.from(nodes);

    // Mark old current as non-current
    if (currentNodeId != null) {
      final oldCurrent = nodes[currentNodeId]!;
      updatedNodes[currentNodeId!] = oldCurrent.copyWith(isCurrent: false);
    }

    // Mark new node as current
    final newCurrent = nodes[nodeId]!;
    updatedNodes[nodeId] = newCurrent.copyWith(isCurrent: true);

    return copyWith(
      currentNodeId: nodeId,
      nodes: updatedNodes,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get node depth in tree (root = 0, children = 1, etc.)
  int getNodeDepth(String nodeId) {
    if (!nodes.containsKey(nodeId)) return -1;

    var depth = 0;
    var node = nodes[nodeId];

    while (node != null && node.parentId != null) {
      depth++;
      node = nodes[node.parentId];
    }

    return depth;
  }

  /// Clear entire tree (start fresh)
  ConversationTree clear() {
    return ConversationTree.empty(userId: userId);
  }
}
