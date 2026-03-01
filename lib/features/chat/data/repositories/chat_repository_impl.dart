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

import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/features/chat/domain/repositories/chat_repository.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/services/photo_compression_service.dart';

/// Firestore implementation of ChatRepository
class ChatRepositoryImpl
    with FirebaseErrorMapperMixin
    implements ChatRepository {
  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    PhotoCompressionService? compressionService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
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
  CollectionReference<Map<String, dynamic>> _messagesRef(
    String conversationId,
  ) => _conversationsRef.doc(conversationId).collection('messages');

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
    final getResult = await handleFirebaseOperation(
      () => _conversationsRef
          .doc(conversationId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Firestore getConversation timed out'),
          ),
      operationName: 'getOrCreateConversation',
    );

    final doc = getResult.fold(
      (failure) => throw failure,
      (doc) => doc,
    );

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
    final createResult = await handleFirebaseVoidOperation(
      () => _conversationsRef
          .doc(conversationId)
          .set({
            ...conversation.toFirestore(),
            'participants': [coachId, athleteId],
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'Firestore createConversation timed out',
            ),
          ),
      operationName: 'createConversation',
    );

    createResult.fold((failure) => throw failure, (_) {
      if (kDebugMode) {
        debugPrint('💬 [ChatRepo] Created conversation: $conversationId');
      }
    });

    return conversation;
  }

  @override
  Future<ChatConversation?> getConversation(String conversationId) async {
    final result = await handleFirebaseOperation(
      () => _conversationsRef
          .doc(conversationId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Firestore getConversation timed out'),
          ),
      operationName: 'getConversation',
    );

    return result.fold(
      (failure) => throw failure,
      (doc) => doc.exists ? ChatConversation.fromFirestore(doc) : null,
    );
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
    var query = _messagesRef(
      conversationId,
    ).orderBy('createdAt', descending: true).limit(limit);

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
    batch.set(
      _messagesRef(conversationId).doc(messageId),
      message.toFirestore(),
    );

    // Update conversation metadata
    batch.update(_conversationsRef.doc(conversationId), {
      'lastMessage': text.length > 100 ? '${text.substring(0, 97)}...' : text,
      'lastMessageAt': Timestamp.fromDate(now),
      'lastMessageSenderId': userId,
      'updatedAt': Timestamp.fromDate(now),
      // Increment unread count for other participant
      ..._incrementUnreadCount(conversationId, userId),
    });

    final result = await handleFirebaseVoidOperation(
      () => batch.commit().timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Firestore sendTextMessage timed out'),
      ),
      operationName: 'sendTextMessage',
    );

    result.fold((failure) => throw failure, (_) {
      if (kDebugMode) {
        debugPrint('💬 [ChatRepo] Sent message: $messageId');
      }
    });

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

    // Compress image
    final compressed = await _compressionService.compressAndSaveToTemp(
      imageFile,
    );

    // Upload to Firebase Storage
    final imagePath = '$messageId.webp';
    final thumbPath = '${messageId}_thumb.webp';

    final imageRef = _chatStorageRef(conversationId).child(imagePath);
    final thumbRef = _chatStorageRef(conversationId).child(thumbPath);

    // Upload full image
    final uploadResult = await handleFirebaseVoidOperation(() async {
      await imageRef.putData(
        compressed.fullPhotoBytes,
        SettableMetadata(contentType: 'image/webp'),
      );
    }, operationName: 'uploadFullImage');

    uploadResult.fold((failure) => throw failure, (_) {});

    final imageUrlResult = await handleFirebaseOperation(
      () => imageRef.getDownloadURL(),
      operationName: 'getImageUrl',
    );

    final imageUrl = imageUrlResult.fold(
      (failure) => throw failure,
      (url) => url,
    );

    // Upload thumbnail
    final thumbUploadResult = await handleFirebaseVoidOperation(() async {
      await thumbRef.putData(
        compressed.thumbnailBytes,
        SettableMetadata(contentType: 'image/webp'),
      );
    }, operationName: 'uploadThumbnail');

    thumbUploadResult.fold(
      (failure) => throw failure,
      (_) {},
    );

    final thumbUrlResult = await handleFirebaseOperation(
      () => thumbRef.getDownloadURL(),
      operationName: 'getThumbUrl',
    );

    final thumbUrl = thumbUrlResult.fold(
      (failure) => throw failure,
      (url) => url,
    );

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
    batch.set(
      _messagesRef(conversationId).doc(messageId),
      message.toFirestore(),
    );

    // Update conversation metadata
    final preview = caption?.isNotEmpty == true ? caption! : '📷 Photo';
    batch.update(_conversationsRef.doc(conversationId), {
      'lastMessage': preview.length > 100
          ? '${preview.substring(0, 97)}...'
          : preview,
      'lastMessageAt': Timestamp.fromDate(now),
      'lastMessageSenderId': userId,
      'updatedAt': Timestamp.fromDate(now),
      ..._incrementUnreadCount(conversationId, userId),
    });

    final commitResult = await handleFirebaseVoidOperation(
      () => batch.commit().timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw TimeoutException('Firestore sendImageMessage timed out'),
      ),
      operationName: 'sendImageMessage',
    );

    commitResult.fold((failure) => throw failure, (_) {
      if (kDebugMode) {
        debugPrint('💬 [ChatRepo] Sent image message: $messageId');
      }
    });

    return message;
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
    var totalVolume = 0.0;
    final exerciseCount = workout.exercises.length;
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
    batch.set(
      _messagesRef(conversationId).doc(messageId),
      message.toFirestore(),
    );

    // Update conversation metadata
    final preview = '🏋️ ${workout.name}';
    batch.update(_conversationsRef.doc(conversationId), {
      'lastMessage': preview.length > 100
          ? '${preview.substring(0, 97)}...'
          : preview,
      'lastMessageAt': Timestamp.fromDate(now),
      'lastMessageSenderId': userId,
      'updatedAt': Timestamp.fromDate(now),
      ..._incrementUnreadCount(conversationId, userId),
    });

    final result = await handleFirebaseVoidOperation(
      () => batch.commit().timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Firestore sendWorkoutLink timed out'),
      ),
      operationName: 'sendWorkoutLink',
    );

    result.fold((failure) => throw failure, (_) {
      if (kDebugMode) {
        debugPrint(
          '💬 [ChatRepo] Sent workout link: $messageId (${workout.name})',
        );
      }
    });

    return message;
  }

  /// Helper to generate unread count increment for the other participant
  Map<String, dynamic> _incrementUnreadCount(
    String conversationId,
    String senderId,
  ) {
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
      batch.update(_messagesRef(conversationId).doc(messageId), {
        'readAt': Timestamp.fromDate(now),
      });
    }

    // Reset unread count for this user
    final parts = ChatConversation.parseId(conversationId);
    if (parts != null) {
      final (coachId, _) = parts;
      final unreadField = userId == coachId
          ? 'coachUnreadCount'
          : 'athleteUnreadCount';
      batch.update(_conversationsRef.doc(conversationId), {unreadField: 0});
    }

    final result = await handleFirebaseVoidOperation(
      () => batch.commit().timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Firestore markAsRead timed out'),
      ),
      operationName: 'markAsRead',
    );

    result.fold((failure) => throw failure, (_) {
      if (kDebugMode) {
        debugPrint(
          '💬 [ChatRepo] Marked ${messageIds.length} messages as read',
        );
      }
    });
  }

  @override
  Future<void> markAllAsRead(String conversationId) async {
    final userId = _currentUserId;

    // Get unread messages
    final result = await handleFirebaseOperation(
      () => _messagesRef(conversationId)
          .where('readAt', isNull: true)
          .where('senderId', isNotEqualTo: userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Firestore markAllAsRead timed out'),
          ),
      operationName: 'markAllAsRead',
    );

    final snapshot = result.fold(
      (failure) => throw failure,
      (snapshot) => snapshot,
    );

    final messageIds = snapshot.docs.map((doc) => doc.id).toList();

    if (messageIds.isNotEmpty) {
      await markAsRead(conversationId: conversationId, messageIds: messageIds);
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
    final result = await handleFirebaseVoidOperation(
      () => _messagesRef(conversationId)
          .doc(messageId)
          .update({
            'isDeleted': true,
            'deletedAt': Timestamp.fromDate(DateTime.now()),
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Firestore deleteMessage timed out'),
          ),
      operationName: 'deleteMessage',
    );

    result.fold((failure) => throw failure, (_) {
      if (kDebugMode) {
        debugPrint('💬 [ChatRepo] Soft deleted message: $messageId');
      }
    });
  }
}
