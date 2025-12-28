/// Chat Repository Implementation
///
/// Firebase Firestore implementation of chat repository.
/// Handles real-time messaging between coach and athlete.
///
/// **Layer**: Data
/// **Feature**: Chat
library;

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/features/chat/domain/repositories/chat_repository.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/services/photo_compression_service.dart';

/// Firestore implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    PhotoCompressionService? compressionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _compressionService = compressionService ?? PhotoCompressionService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final PhotoCompressionService _compressionService;
  static const _uuid = Uuid();

  /// Get current user ID
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not authenticated');
    return user.uid;
  }

  /// Get conversations collection reference
  CollectionReference<Map<String, dynamic>> get _conversationsRef =>
      _firestore.collection('conversations');

  /// Get messages subcollection for a conversation
  CollectionReference<Map<String, dynamic>> _messagesRef(String conversationId) =>
      _conversationsRef.doc(conversationId).collection('messages');

  /// Get storage reference for chat images
  Reference _chatStorageRef(String conversationId) =>
      _storage.ref().child('chat').child(conversationId);

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  @override
  Stream<List<ChatConversation>> watchConversations() {
    final userId = _currentUserId;

    // Query conversations where user is coach OR athlete
    // Using array-contains with participants array
    return _conversationsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatConversation.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<ChatConversation> getOrCreateConversation({
    required String coachId,
    required String athleteId,
    required String coachName,
    required String athleteName,
  }) async {
    final conversationId = ChatConversation.generateId(coachId, athleteId);

    // Check if conversation exists
    final doc = await _conversationsRef.doc(conversationId).get();

    if (doc.exists) {
      return ChatConversation.fromFirestore(doc);
    }

    // Create new conversation
    final now = DateTime.now();
    final conversation = ChatConversation(
      id: conversationId,
      coachId: coachId,
      athleteId: athleteId,
      coachName: coachName,
      athleteName: athleteName,
      createdAt: now,
      updatedAt: now,
    );

    // Save with participants array for querying
    await _conversationsRef.doc(conversationId).set({
      ...conversation.toFirestore(),
      'participants': [coachId, athleteId],
    });

    if (kDebugMode) {
      debugPrint('💬 [ChatRepo] Created conversation: $conversationId');
    }

    return conversation;
  }

  @override
  Future<ChatConversation?> getConversation(String conversationId) async {
    final doc = await _conversationsRef.doc(conversationId).get();
    if (!doc.exists) return null;
    return ChatConversation.fromFirestore(doc);
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String conversationId,
    int limit = 50,
    DateTime? before,
  }) {
    var query = _messagesRef(conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (before != null) {
      query = query.endBefore([Timestamp.fromDate(before)]);
    }

    return query.snapshots().map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .where((m) => !m.isDeleted)
          .toList();

      // Return in chronological order for display
      return messages.reversed.toList();
    });
  }

  @override
  Future<ChatMessage> sendTextMessage({
    required String conversationId,
    required String text,
  }) async {
    final userId = _currentUserId;
    final user = _auth.currentUser;
    final senderName = user?.displayName ?? 'Unknown';

    final messageId = _uuid.v4();
    final now = DateTime.now();

    final message = ChatMessage(
      id: messageId,
      senderId: userId,
      senderName: senderName,
      text: text,
      type: MessageType.text,
      createdAt: now,
    );

    // Use batch for atomic update
    final batch = _firestore.batch();

    // Add message
    batch.set(_messagesRef(conversationId).doc(messageId), message.toFirestore());

    // Update conversation metadata
    batch.update(_conversationsRef.doc(conversationId), {
      'lastMessage': text.length > 100 ? '${text.substring(0, 97)}...' : text,
      'lastMessageAt': Timestamp.fromDate(now),
      'lastMessageSenderId': userId,
      'updatedAt': Timestamp.fromDate(now),
      // Increment unread count for other participant
      ..._incrementUnreadCount(conversationId, userId),
    });

    await batch.commit();

    if (kDebugMode) {
      debugPrint('💬 [ChatRepo] Sent message: $messageId');
    }

    return message;
  }

  @override
  Future<ChatMessage> sendImageMessage({
    required String conversationId,
    required File imageFile,
    String? caption,
  }) async {
    final userId = _currentUserId;
    final user = _auth.currentUser;
    final senderName = user?.displayName ?? 'Unknown';

    final messageId = _uuid.v4();
    final now = DateTime.now();

    try {
      // Compress image
      final compressed =
          await _compressionService.compressAndSaveToTemp(imageFile);

      // Upload to Firebase Storage
      final imagePath = '$messageId.webp';
      final thumbPath = '${messageId}_thumb.webp';

      final imageRef = _chatStorageRef(conversationId).child(imagePath);
      final thumbRef = _chatStorageRef(conversationId).child(thumbPath);

      // Upload full image
      await imageRef.putData(
        compressed.fullPhotoBytes,
        SettableMetadata(contentType: 'image/webp'),
      );
      final imageUrl = await imageRef.getDownloadURL();

      // Upload thumbnail
      await thumbRef.putData(
        compressed.thumbnailBytes,
        SettableMetadata(contentType: 'image/webp'),
      );
      final thumbUrl = await thumbRef.getDownloadURL();

      // Cleanup temp files
      await compressed.cleanup();

      final message = ChatMessage(
        id: messageId,
        senderId: userId,
        senderName: senderName,
        text: caption ?? '',
        type: MessageType.image,
        imageMetadata: ImageMetadata(
          imageUrl: imageUrl,
          thumbnailUrl: thumbUrl,
          storagePath: imagePath,
          fileSizeBytes: compressed.compressedSize,
        ),
        createdAt: now,
      );

      // Use batch for atomic update
      final batch = _firestore.batch();

      // Add message
      batch.set(_messagesRef(conversationId).doc(messageId), message.toFirestore());

      // Update conversation metadata
      final preview = caption?.isNotEmpty == true ? caption! : '📷 Photo';
      batch.update(_conversationsRef.doc(conversationId), {
        'lastMessage': preview.length > 100 ? '${preview.substring(0, 97)}...' : preview,
        'lastMessageAt': Timestamp.fromDate(now),
        'lastMessageSenderId': userId,
        'updatedAt': Timestamp.fromDate(now),
        ..._incrementUnreadCount(conversationId, userId),
      });

      await batch.commit();

      if (kDebugMode) {
        debugPrint('💬 [ChatRepo] Sent image message: $messageId');
      }

      return message;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ChatRepo] Failed to send image: $e');
      }
      rethrow;
    }
  }

  @override
  Future<ChatMessage> sendWorkoutLink({
    required String conversationId,
    required WorkoutHistoryDetail workout,
    String? comment,
  }) async {
    final userId = _currentUserId;
    final user = _auth.currentUser;
    final senderName = user?.displayName ?? 'Unknown';

    final messageId = _uuid.v4();
    final now = DateTime.now();

    // Calculate total volume
    double totalVolume = 0;
    int exerciseCount = workout.exercises.length;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        totalVolume += set.weight * set.reps;
      }
    }

    final message = ChatMessage(
      id: messageId,
      senderId: userId,
      senderName: senderName,
      text: comment ?? '',
      type: MessageType.workoutLink,
      workoutMetadata: WorkoutLinkMetadata(
        workoutId: workout.id,
        workoutName: workout.name,
        durationMinutes: workout.duration.inMinutes,
        completedAt: workout.completedAt,
        exerciseCount: exerciseCount,
        totalVolumeKg: totalVolume,
      ),
      createdAt: now,
    );

    // Use batch for atomic update
    final batch = _firestore.batch();

    // Add message
    batch.set(_messagesRef(conversationId).doc(messageId), message.toFirestore());

    // Update conversation metadata
    final preview = '🏋️ ${workout.name}';
    batch.update(_conversationsRef.doc(conversationId), {
      'lastMessage': preview.length > 100 ? '${preview.substring(0, 97)}...' : preview,
      'lastMessageAt': Timestamp.fromDate(now),
      'lastMessageSenderId': userId,
      'updatedAt': Timestamp.fromDate(now),
      ..._incrementUnreadCount(conversationId, userId),
    });

    await batch.commit();

    if (kDebugMode) {
      debugPrint('💬 [ChatRepo] Sent workout link: $messageId (${workout.name})');
    }

    return message;
  }

  /// Helper to generate unread count increment for the other participant
  Map<String, dynamic> _incrementUnreadCount(String conversationId, String senderId) {
    final parts = ChatConversation.parseId(conversationId);
    if (parts == null) return {};

    final (coachId, athleteId) = parts;

    if (senderId == coachId) {
      // Coach sent message, increment athlete's unread
      return {'athleteUnreadCount': FieldValue.increment(1)};
    } else {
      // Athlete sent message, increment coach's unread
      return {'coachUnreadCount': FieldValue.increment(1)};
    }
  }

  // ============================================================
  // READ RECEIPTS
  // ============================================================

  @override
  Future<void> markAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    final userId = _currentUserId;
    final now = DateTime.now();

    final batch = _firestore.batch();

    // Update each message's readAt
    for (final messageId in messageIds) {
      batch.update(
        _messagesRef(conversationId).doc(messageId),
        {'readAt': Timestamp.fromDate(now)},
      );
    }

    // Reset unread count for this user
    final parts = ChatConversation.parseId(conversationId);
    if (parts != null) {
      final (coachId, _) = parts;
      final unreadField = userId == coachId ? 'coachUnreadCount' : 'athleteUnreadCount';
      batch.update(_conversationsRef.doc(conversationId), {unreadField: 0});
    }

    await batch.commit();

    if (kDebugMode) {
      debugPrint('💬 [ChatRepo] Marked ${messageIds.length} messages as read');
    }
  }

  @override
  Future<void> markAllAsRead(String conversationId) async {
    final userId = _currentUserId;

    // Get unread messages
    final snapshot = await _messagesRef(conversationId)
        .where('readAt', isNull: true)
        .where('senderId', isNotEqualTo: userId)
        .get();

    final messageIds = snapshot.docs.map((doc) => doc.id).toList();

    if (messageIds.isNotEmpty) {
      await markAsRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );
    }
  }

  // ============================================================
  // UNREAD COUNTS
  // ============================================================

  @override
  Stream<int> watchTotalUnreadCount() {
    final userId = _currentUserId;

    return _conversationsRef
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final conversation = ChatConversation.fromFirestore(doc);
        total += conversation.unreadCountFor(userId);
      }
      return total;
    });
  }

  // ============================================================
  // DELETION
  // ============================================================

  @override
  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    // Soft delete only
    await _messagesRef(conversationId).doc(messageId).update({
      'isDeleted': true,
      'deletedAt': Timestamp.fromDate(DateTime.now()),
    });

    if (kDebugMode) {
      debugPrint('💬 [ChatRepo] Soft deleted message: $messageId');
    }
  }
}
