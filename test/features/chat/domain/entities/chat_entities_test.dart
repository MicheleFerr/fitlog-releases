/// Chat domain entities tests - ChatMessage, ChatConversation,
/// MessageType, WorkoutLinkMetadata, ImageMetadata.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';

void main() {
  group('MessageType', () {
    test('has 3 values', () {
      expect(MessageType.values.length, 3);
      expect(MessageType.values, contains(MessageType.text));
      expect(MessageType.values, contains(MessageType.image));
      expect(MessageType.values, contains(MessageType.workoutLink));
    });
  });

  group('ChatMessage', () {
    ChatMessage makeMessage({
      MessageType type = MessageType.text,
      String senderId = 'user1',
      WorkoutLinkMetadata? workoutMetadata,
      ImageMetadata? imageMetadata,
      DateTime? readAt,
      bool isDeleted = false,
    }) {
      return ChatMessage(
        id: 'msg1',
        senderId: senderId,
        senderName: 'Test User',
        text: 'Hello',
        type: type,
        workoutMetadata: workoutMetadata,
        imageMetadata: imageMetadata,
        createdAt: DateTime(2025, 3, 1),
        readAt: readAt,
        isDeleted: isDeleted,
      );
    }

    test('isFromMe', () {
      final msg = makeMessage(senderId: 'user1');
      expect(msg.isFromMe('user1'), isTrue);
      expect(msg.isFromMe('user2'), isFalse);
    });

    test('isRead', () {
      final unread = makeMessage();
      expect(unread.isRead, isFalse);

      final read = makeMessage(readAt: DateTime(2025, 3, 1, 12));
      expect(read.isRead, isTrue);
    });

    test('hasWorkoutLink', () {
      final withLink = makeMessage(
        type: MessageType.workoutLink,
        workoutMetadata: WorkoutLinkMetadata(
          workoutId: 'w1',
          workoutName: 'Push Day',
          durationMinutes: 45,
          completedAt: DateTime(2025, 3, 1),
        ),
      );
      expect(withLink.hasWorkoutLink, isTrue);

      final textMsg = makeMessage();
      expect(textMsg.hasWorkoutLink, isFalse);
    });

    test('hasImage', () {
      final withImage = makeMessage(
        type: MessageType.image,
        imageMetadata: const ImageMetadata(
          imageUrl: 'https://example.com/img.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          storagePath: 'images/img.jpg',
        ),
      );
      expect(withImage.hasImage, isTrue);

      final textMsg = makeMessage();
      expect(textMsg.hasImage, isFalse);
    });

    test('defaults', () {
      final msg = makeMessage();
      expect(msg.type, MessageType.text);
      expect(msg.isDeleted, isFalse);
    });
  });

  group('ChatConversation', () {
    ChatConversation makeConversation({
      int coachUnread = 0,
      int athleteUnread = 0,
      String? lastMessageSenderId,
    }) {
      return ChatConversation(
        id: 'conv1',
        coachId: 'coach1',
        athleteId: 'athlete1',
        coachName: 'Coach Mike',
        athleteName: 'John',
        coachUnreadCount: coachUnread,
        athleteUnreadCount: athleteUnread,
        lastMessageSenderId: lastMessageSenderId,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );
    }

    test('unreadCountFor', () {
      final conv = makeConversation(coachUnread: 3, athleteUnread: 5);
      expect(conv.unreadCountFor('coach1'), 3);
      expect(conv.unreadCountFor('athlete1'), 5);
      expect(conv.unreadCountFor('unknown'), 0);
    });

    test('isCoach / isAthlete / isParticipant', () {
      final conv = makeConversation();
      expect(conv.isCoach('coach1'), isTrue);
      expect(conv.isCoach('athlete1'), isFalse);
      expect(conv.isAthlete('athlete1'), isTrue);
      expect(conv.isAthlete('coach1'), isFalse);
      expect(conv.isParticipant('coach1'), isTrue);
      expect(conv.isParticipant('athlete1'), isTrue);
      expect(conv.isParticipant('unknown'), isFalse);
    });

    test('otherParticipantName', () {
      final conv = makeConversation();
      expect(conv.otherParticipantName('coach1'), 'John');
      expect(conv.otherParticipantName('athlete1'), 'Coach Mike');
    });

    test('otherParticipantId', () {
      final conv = makeConversation();
      expect(conv.otherParticipantId('coach1'), 'athlete1');
      expect(conv.otherParticipantId('athlete1'), 'coach1');
    });

    test('lastMessageFromMe', () {
      final conv = makeConversation(lastMessageSenderId: 'coach1');
      expect(conv.lastMessageFromMe('coach1'), isTrue);
      expect(conv.lastMessageFromMe('athlete1'), isFalse);
    });

    test('hasUnreadFor', () {
      final conv = makeConversation(coachUnread: 2, athleteUnread: 0);
      expect(conv.hasUnreadFor('coach1'), isTrue);
      expect(conv.hasUnreadFor('athlete1'), isFalse);
    });

    test('generateId', () {
      expect(
        ChatConversation.generateId('c1', 'a1'),
        'c1_a1',
      );
    });

    test('parseId valid', () {
      final result = ChatConversation.parseId('coach1_athlete1');
      expect(result, isNotNull);
      expect(result!.$1, 'coach1');
      expect(result.$2, 'athlete1');
    });

    test('parseId invalid', () {
      expect(ChatConversation.parseId('invalid'), isNull);
      expect(ChatConversation.parseId('a_b_c'), isNull);
    });
  });
}
