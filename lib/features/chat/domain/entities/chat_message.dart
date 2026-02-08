import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Type of message content
enum MessageType {
  /// Plain text message
  text,

  /// Image message (form check, progress photo)
  image,

  /// Link to a completed workout
  workoutLink,
}

/// Metadata for workout link messages
@freezed
abstract class WorkoutLinkMetadata with _$WorkoutLinkMetadata {
  const factory WorkoutLinkMetadata({
    required String workoutId,
    required String workoutName,
    required int durationMinutes,
    required DateTime completedAt,
    int? exerciseCount,
    double? totalVolumeKg,
  }) = _WorkoutLinkMetadata;

  factory WorkoutLinkMetadata.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLinkMetadataFromJson(json);
}

/// Metadata for image messages
@freezed
abstract class ImageMetadata with _$ImageMetadata {
  const factory ImageMetadata({
    required String imageUrl,
    required String thumbnailUrl,
    required String storagePath,
    int? fileSizeBytes,
    int? width,
    int? height,
  }) = _ImageMetadata;

  factory ImageMetadata.fromJson(Map<String, dynamic> json) =>
      _$ImageMetadataFromJson(json);
}

/// A single chat message
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    /// Unique message ID
    required String id,

    /// ID of the sender (coach or athlete)
    required String senderId,

    /// Display name of sender (denormalized for performance)
    required String senderName,

    /// Message text content
    required String text,

    /// Type of message
    @Default(MessageType.text) MessageType type,

    /// Workout link metadata (only for workoutLink type)
    WorkoutLinkMetadata? workoutMetadata,

    /// Image metadata (only for image type)
    ImageMetadata? imageMetadata,

    /// When the message was created
    required DateTime createdAt,

    /// When the message was read by recipient (null = unread)
    DateTime? readAt,

    /// Soft delete flag
    @Default(false) bool isDeleted,
  }) = _ChatMessage;

  /// Create from Firestore document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse message type
    final typeStr = data['type'] as String? ?? 'text';
    final type = MessageType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => MessageType.text,
    );

    // Parse workout metadata if present
    WorkoutLinkMetadata? workoutMetadata;
    if (data['workoutMetadata'] != null) {
      final wm = data['workoutMetadata'] as Map<String, dynamic>;
      workoutMetadata = WorkoutLinkMetadata(
        workoutId: wm['workoutId'] as String? ?? '',
        workoutName: wm['workoutName'] as String? ?? '',
        durationMinutes: wm['durationMinutes'] as int? ?? 0,
        completedAt: wm['completedAt'] is Timestamp
            ? (wm['completedAt'] as Timestamp).toDate()
            : DateTime.tryParse(wm['completedAt'] as String? ?? '') ??
                  DateTime.now(),
        exerciseCount: wm['exerciseCount'] as int?,
        totalVolumeKg: (wm['totalVolumeKg'] as num?)?.toDouble(),
      );
    }

    // Parse image metadata if present
    ImageMetadata? imageMetadata;
    if (data['imageMetadata'] != null) {
      final im = data['imageMetadata'] as Map<String, dynamic>;
      imageMetadata = ImageMetadata(
        imageUrl: im['imageUrl'] as String? ?? '',
        thumbnailUrl: im['thumbnailUrl'] as String? ?? '',
        storagePath: im['storagePath'] as String? ?? '',
        fileSizeBytes: im['fileSizeBytes'] as int?,
        width: im['width'] as int?,
        height: im['height'] as int?,
      );
    }

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: type,
      workoutMetadata: workoutMetadata,
      imageMetadata: imageMetadata,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'] as String? ?? '') ??
                DateTime.now(),
      readAt: data['readAt'] is Timestamp
          ? (data['readAt'] as Timestamp).toDate()
          : data['readAt'] != null
          ? DateTime.tryParse(data['readAt'] as String? ?? '')
          : null,
      isDeleted: data['isDeleted'] as bool? ?? false,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Private constructor for instance methods
  const ChatMessage._();

  /// Check if message is from current user
  bool isFromMe(String myUserId) => senderId == myUserId;

  /// Check if message has been read
  bool get isRead => readAt != null;

  /// Check if message has workout link
  bool get hasWorkoutLink =>
      type == MessageType.workoutLink && workoutMetadata != null;

  /// Check if message has image
  bool get hasImage => type == MessageType.image && imageMetadata != null;

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type.name,
      if (workoutMetadata != null)
        'workoutMetadata': {
          'workoutId': workoutMetadata!.workoutId,
          'workoutName': workoutMetadata!.workoutName,
          'durationMinutes': workoutMetadata!.durationMinutes,
          'completedAt': Timestamp.fromDate(workoutMetadata!.completedAt),
          if (workoutMetadata!.exerciseCount != null)
            'exerciseCount': workoutMetadata!.exerciseCount,
          if (workoutMetadata!.totalVolumeKg != null)
            'totalVolumeKg': workoutMetadata!.totalVolumeKg,
        },
      if (imageMetadata != null)
        'imageMetadata': {
          'imageUrl': imageMetadata!.imageUrl,
          'thumbnailUrl': imageMetadata!.thumbnailUrl,
          'storagePath': imageMetadata!.storagePath,
          if (imageMetadata!.fileSizeBytes != null)
            'fileSizeBytes': imageMetadata!.fileSizeBytes,
          if (imageMetadata!.width != null) 'width': imageMetadata!.width,
          if (imageMetadata!.height != null) 'height': imageMetadata!.height,
        },
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isDeleted': isDeleted,
    };
  }
}
