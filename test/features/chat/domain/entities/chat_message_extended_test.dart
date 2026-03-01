/// Extended tests for ChatMessage - covering fromFirestore, toFirestore,
/// fromJson/toJson, WorkoutLinkMetadata, ImageMetadata serialization,
/// and edge cases not covered by chat_entities_test.dart.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_message.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ---------------------------------------------------------------------------
  // WorkoutLinkMetadata
  // ---------------------------------------------------------------------------
  group('WorkoutLinkMetadata', () {
    test('constructs with all fields', () {
      final meta = WorkoutLinkMetadata(
        workoutId: 'w1',
        workoutName: 'Push Day',
        durationMinutes: 60,
        completedAt: DateTime(2025, 3, 1),
        exerciseCount: 5,
        totalVolumeKg: 3500.0,
      );

      expect(meta.workoutId, 'w1');
      expect(meta.workoutName, 'Push Day');
      expect(meta.durationMinutes, 60);
      expect(meta.exerciseCount, 5);
      expect(meta.totalVolumeKg, 3500.0);
    });

    test('constructs with optional fields null', () {
      final meta = WorkoutLinkMetadata(
        workoutId: 'w2',
        workoutName: 'Pull Day',
        durationMinutes: 45,
        completedAt: DateTime(2025, 3, 2),
      );

      expect(meta.exerciseCount, isNull);
      expect(meta.totalVolumeKg, isNull);
    });

    test('fromJson round-trip preserves all fields', () {
      final original = WorkoutLinkMetadata(
        workoutId: 'w1',
        workoutName: 'Leg Day',
        durationMinutes: 75,
        completedAt: DateTime(2025, 1, 15, 10, 30),
        exerciseCount: 7,
        totalVolumeKg: 5000.0,
      );

      final json = original.toJson();
      final restored = WorkoutLinkMetadata.fromJson(json);

      expect(restored.workoutId, original.workoutId);
      expect(restored.workoutName, original.workoutName);
      expect(restored.durationMinutes, original.durationMinutes);
      expect(restored.exerciseCount, original.exerciseCount);
      expect(restored.totalVolumeKg, original.totalVolumeKg);
    });

    test('copyWith creates updated copy', () {
      final original = WorkoutLinkMetadata(
        workoutId: 'w1',
        workoutName: 'Push Day',
        durationMinutes: 45,
        completedAt: DateTime(2025, 3, 1),
      );

      final updated = original.copyWith(workoutName: 'Updated Push Day', exerciseCount: 6);
      expect(updated.workoutName, 'Updated Push Day');
      expect(updated.exerciseCount, 6);
      expect(updated.workoutId, 'w1'); // unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // ImageMetadata
  // ---------------------------------------------------------------------------
  group('ImageMetadata', () {
    test('constructs with all fields', () {
      const meta = ImageMetadata(
        imageUrl: 'https://example.com/img.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        storagePath: 'images/img.jpg',
        fileSizeBytes: 204800,
        width: 1920,
        height: 1080,
      );

      expect(meta.imageUrl, 'https://example.com/img.jpg');
      expect(meta.fileSizeBytes, 204800);
      expect(meta.width, 1920);
      expect(meta.height, 1080);
    });

    test('constructs with optional fields null', () {
      const meta = ImageMetadata(
        imageUrl: 'https://example.com/img.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        storagePath: 'images/img.jpg',
      );

      expect(meta.fileSizeBytes, isNull);
      expect(meta.width, isNull);
      expect(meta.height, isNull);
    });

    test('fromJson round-trip preserves all fields', () {
      const original = ImageMetadata(
        imageUrl: 'https://example.com/img.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        storagePath: 'images/img.jpg',
        fileSizeBytes: 204800,
        width: 1920,
        height: 1080,
      );

      final json = original.toJson();
      final restored = ImageMetadata.fromJson(json);

      expect(restored.imageUrl, original.imageUrl);
      expect(restored.thumbnailUrl, original.thumbnailUrl);
      expect(restored.storagePath, original.storagePath);
      expect(restored.fileSizeBytes, original.fileSizeBytes);
      expect(restored.width, original.width);
      expect(restored.height, original.height);
    });

    test('copyWith creates updated copy', () {
      const original = ImageMetadata(
        imageUrl: 'https://example.com/img.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        storagePath: 'images/img.jpg',
      );

      final updated = original.copyWith(fileSizeBytes: 512000, width: 800, height: 600);
      expect(updated.fileSizeBytes, 512000);
      expect(updated.width, 800);
      expect(updated.imageUrl, 'https://example.com/img.jpg'); // unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // ChatMessage fromJson / toJson
  // ---------------------------------------------------------------------------
  group('ChatMessage fromJson / toJson', () {
    test('fromJson text message round-trip', () {
      final original = ChatMessage(
        id: 'msg-1',
        senderId: 'user-1',
        senderName: 'Alice',
        text: 'Hello World',
        createdAt: DateTime(2025, 3, 1, 10, 0, 0),
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.senderId, original.senderId);
      expect(restored.senderName, original.senderName);
      expect(restored.text, original.text);
      expect(restored.type, MessageType.text);
      expect(restored.isDeleted, false);
    });

    test('fromJson workoutLink message with metadata round-trip', () {
      final original = ChatMessage(
        id: 'msg-2',
        senderId: 'athlete-1',
        senderName: 'Bob',
        text: 'Check out my workout!',
        type: MessageType.workoutLink,
        workoutMetadata: WorkoutLinkMetadata(
          workoutId: 'w-100',
          workoutName: 'Leg Day',
          durationMinutes: 60,
          completedAt: DateTime(2025, 3, 1),
          exerciseCount: 5,
          totalVolumeKg: 3000.0,
        ),
        createdAt: DateTime(2025, 3, 1, 11, 0, 0),
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.type, MessageType.workoutLink);
      expect(restored.workoutMetadata, isNotNull);
      expect(restored.workoutMetadata!.workoutId, 'w-100');
      expect(restored.workoutMetadata!.exerciseCount, 5);
      expect(restored.workoutMetadata!.totalVolumeKg, 3000.0);
    });

    test('fromJson image message with metadata round-trip', () {
      final original = ChatMessage(
        id: 'msg-3',
        senderId: 'user-2',
        senderName: 'Carol',
        text: '',
        type: MessageType.image,
        imageMetadata: const ImageMetadata(
          imageUrl: 'https://example.com/photo.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          storagePath: 'photos/photo.jpg',
          fileSizeBytes: 102400,
          width: 1080,
          height: 1920,
        ),
        createdAt: DateTime(2025, 3, 1, 12, 0, 0),
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.type, MessageType.image);
      expect(restored.imageMetadata, isNotNull);
      expect(restored.imageMetadata!.imageUrl, 'https://example.com/photo.jpg');
      expect(restored.imageMetadata!.fileSizeBytes, 102400);
      expect(restored.imageMetadata!.width, 1080);
    });

    test('fromJson with readAt set', () {
      final msg = ChatMessage(
        id: 'msg-4',
        senderId: 'u1',
        senderName: 'Dave',
        text: 'Hi',
        createdAt: DateTime(2025, 3, 1, 8, 0),
        readAt: DateTime(2025, 3, 1, 9, 0),
      );

      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.isRead, isTrue);
    });

    test('fromJson deleted message', () {
      final msg = ChatMessage(
        id: 'msg-5',
        senderId: 'u1',
        senderName: 'Eve',
        text: '[deleted]',
        createdAt: DateTime(2025, 3, 1),
        isDeleted: true,
      );

      final json = msg.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.isDeleted, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // ChatMessage toFirestore
  // ---------------------------------------------------------------------------
  group('ChatMessage toFirestore', () {
    test('text message - contains expected keys', () {
      final msg = ChatMessage(
        id: 'msg-1',
        senderId: 'user-1',
        senderName: 'Alice',
        text: 'Hello',
        createdAt: DateTime(2025, 3, 1, 10, 0, 0),
      );

      final data = msg.toFirestore();

      expect(data['senderId'], 'user-1');
      expect(data['senderName'], 'Alice');
      expect(data['text'], 'Hello');
      expect(data['type'], 'text');
      expect(data['isDeleted'], false);
      expect(data['createdAt'], isA<Timestamp>());
      expect(data.containsKey('workoutMetadata'), isFalse);
      expect(data.containsKey('imageMetadata'), isFalse);
      expect(data.containsKey('readAt'), isFalse);
    });

    test('workoutLink message - includes workoutMetadata with Timestamp', () {
      final msg = ChatMessage(
        id: 'msg-2',
        senderId: 'user-1',
        senderName: 'Alice',
        text: 'Workout complete',
        type: MessageType.workoutLink,
        workoutMetadata: WorkoutLinkMetadata(
          workoutId: 'w1',
          workoutName: 'Push Day',
          durationMinutes: 45,
          completedAt: DateTime(2025, 3, 1),
          exerciseCount: 4,
          totalVolumeKg: 2500.0,
        ),
        createdAt: DateTime(2025, 3, 1),
      );

      final data = msg.toFirestore();

      expect(data['type'], 'workoutLink');
      expect(data['workoutMetadata'], isNotNull);
      final wm = data['workoutMetadata'] as Map<String, dynamic>;
      expect(wm['workoutId'], 'w1');
      expect(wm['workoutName'], 'Push Day');
      expect(wm['durationMinutes'], 45);
      expect(wm['completedAt'], isA<Timestamp>());
      expect(wm['exerciseCount'], 4);
      expect(wm['totalVolumeKg'], 2500.0);
    });

    test('workoutLink without optional fields omits them', () {
      final msg = ChatMessage(
        id: 'msg-3',
        senderId: 'user-1',
        senderName: 'Alice',
        text: 'Done',
        type: MessageType.workoutLink,
        workoutMetadata: WorkoutLinkMetadata(
          workoutId: 'w1',
          workoutName: 'Pull Day',
          durationMinutes: 30,
          completedAt: DateTime(2025, 3, 1),
          // no exerciseCount, no totalVolumeKg
        ),
        createdAt: DateTime(2025, 3, 1),
      );

      final data = msg.toFirestore();
      final wm = data['workoutMetadata'] as Map<String, dynamic>;

      expect(wm.containsKey('exerciseCount'), isFalse);
      expect(wm.containsKey('totalVolumeKg'), isFalse);
    });

    test('image message - includes imageMetadata', () {
      final msg = ChatMessage(
        id: 'msg-4',
        senderId: 'user-1',
        senderName: 'Alice',
        text: '',
        type: MessageType.image,
        imageMetadata: const ImageMetadata(
          imageUrl: 'https://example.com/img.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          storagePath: 'images/img.jpg',
          fileSizeBytes: 204800,
          width: 1920,
          height: 1080,
        ),
        createdAt: DateTime(2025, 1, 1),
      );

      final data = msg.toFirestore();

      expect(data['type'], 'image');
      expect(data['imageMetadata'], isNotNull);
      final im = data['imageMetadata'] as Map<String, dynamic>;
      expect(im['imageUrl'], 'https://example.com/img.jpg');
      expect(im['fileSizeBytes'], 204800);
      expect(im['width'], 1920);
      expect(im['height'], 1080);
    });

    test('image message without optional fields omits them', () {
      final msg = ChatMessage(
        id: 'msg-5',
        senderId: 'user-1',
        senderName: 'Alice',
        text: '',
        type: MessageType.image,
        imageMetadata: const ImageMetadata(
          imageUrl: 'https://example.com/img.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          storagePath: 'images/img.jpg',
          // no fileSizeBytes, width, height
        ),
        createdAt: DateTime(2025, 1, 1),
      );

      final data = msg.toFirestore();
      final im = data['imageMetadata'] as Map<String, dynamic>;

      expect(im.containsKey('fileSizeBytes'), isFalse);
      expect(im.containsKey('width'), isFalse);
      expect(im.containsKey('height'), isFalse);
    });

    test('message with readAt includes readAt Timestamp', () {
      final msg = ChatMessage(
        id: 'msg-6',
        senderId: 'user-1',
        senderName: 'Alice',
        text: 'Hello',
        createdAt: DateTime(2025, 3, 1, 10, 0),
        readAt: DateTime(2025, 3, 1, 11, 0),
      );

      final data = msg.toFirestore();

      expect(data['readAt'], isA<Timestamp>());
    });
  });

  // ---------------------------------------------------------------------------
  // ChatMessage fromFirestore
  // ---------------------------------------------------------------------------
  group('ChatMessage fromFirestore', () {
    test('parses text message from Firestore', () async {
      final ref = fakeFirestore.collection('messages').doc('msg-1');
      await ref.set({
        'senderId': 'user-1',
        'senderName': 'Alice',
        'text': 'Hello from Firestore',
        'type': 'text',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1, 10, 0)),
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.id, 'msg-1');
      expect(msg.senderId, 'user-1');
      expect(msg.senderName, 'Alice');
      expect(msg.text, 'Hello from Firestore');
      expect(msg.type, MessageType.text);
      expect(msg.isDeleted, false);
      expect(msg.readAt, isNull);
    });

    test('parses unknown type as text', () async {
      final ref = fakeFirestore.collection('messages').doc('msg-2');
      await ref.set({
        'senderId': 'user-1',
        'senderName': 'Bob',
        'text': 'Unknown type',
        'type': 'unknown_future_type',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.type, MessageType.text);
    });

    test('parses workoutLink message with workoutMetadata from Timestamp', () async {
      final completedAt = DateTime(2025, 3, 1, 9, 0);
      final ref = fakeFirestore.collection('messages').doc('msg-3');
      await ref.set({
        'senderId': 'athlete-1',
        'senderName': 'Bob',
        'text': 'Workout done!',
        'type': 'workoutLink',
        'workoutMetadata': {
          'workoutId': 'w-50',
          'workoutName': 'Squat Day',
          'durationMinutes': 90,
          'completedAt': Timestamp.fromDate(completedAt),
          'exerciseCount': 6,
          'totalVolumeKg': 4500.0,
        },
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1, 10, 0)),
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.type, MessageType.workoutLink);
      expect(msg.hasWorkoutLink, isTrue);
      expect(msg.workoutMetadata!.workoutId, 'w-50');
      expect(msg.workoutMetadata!.exerciseCount, 6);
      expect(msg.workoutMetadata!.totalVolumeKg, 4500.0);
    });

    test('parses workoutMetadata completedAt from ISO string fallback', () async {
      final ref = fakeFirestore.collection('messages').doc('msg-4');
      await ref.set({
        'senderId': 'athlete-1',
        'senderName': 'Bob',
        'text': 'Done',
        'type': 'workoutLink',
        'workoutMetadata': {
          'workoutId': 'w-51',
          'workoutName': 'Bench Day',
          'durationMinutes': 45,
          'completedAt': '2025-03-01T09:00:00.000',
        },
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.workoutMetadata, isNotNull);
      expect(msg.workoutMetadata!.workoutId, 'w-51');
    });

    test('parses image message with imageMetadata', () async {
      final ref = fakeFirestore.collection('messages').doc('msg-5');
      await ref.set({
        'senderId': 'user-1',
        'senderName': 'Carol',
        'text': '',
        'type': 'image',
        'imageMetadata': {
          'imageUrl': 'https://storage.example.com/img.jpg',
          'thumbnailUrl': 'https://storage.example.com/thumb.jpg',
          'storagePath': 'form-checks/img.jpg',
          'fileSizeBytes': 512000,
          'width': 1080,
          'height': 1920,
        },
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.type, MessageType.image);
      expect(msg.hasImage, isTrue);
      expect(msg.imageMetadata!.imageUrl, 'https://storage.example.com/img.jpg');
      expect(msg.imageMetadata!.fileSizeBytes, 512000);
    });

    test('parses readAt as Timestamp', () async {
      final readAt = DateTime(2025, 3, 1, 12, 0);
      final ref = fakeFirestore.collection('messages').doc('msg-6');
      await ref.set({
        'senderId': 'user-1',
        'senderName': 'Alice',
        'text': 'Hello',
        'type': 'text',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1, 10, 0)),
        'readAt': Timestamp.fromDate(readAt),
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.isRead, isTrue);
    });

    test('parses readAt as ISO string fallback', () async {
      final ref = fakeFirestore.collection('messages').doc('msg-7');
      await ref.set({
        'senderId': 'user-1',
        'senderName': 'Alice',
        'text': 'Hello',
        'type': 'text',
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
        'readAt': '2025-03-01T12:00:00.000',
        'isDeleted': false,
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.isRead, isTrue);
    });

    test('handles missing optional fields gracefully', () async {
      final ref = fakeFirestore.collection('messages').doc('msg-8');
      await ref.set({
        'createdAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);

      expect(msg.senderId, '');
      expect(msg.senderName, '');
      expect(msg.text, '');
      expect(msg.type, MessageType.text);
      expect(msg.isDeleted, false);
      expect(msg.workoutMetadata, isNull);
      expect(msg.imageMetadata, isNull);
    });

    test('createdAt falls back to now when missing', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final ref = fakeFirestore.collection('messages').doc('msg-9');
      await ref.set({
        'senderId': 'user-1',
        'senderName': 'Alice',
        'text': 'Hello',
        'type': 'text',
        'isDeleted': false,
        // no createdAt
      });

      final snap = await ref.get();
      final msg = ChatMessage.fromFirestore(snap);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(msg.createdAt.isAfter(before), isTrue);
      expect(msg.createdAt.isBefore(after), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // ChatMessage copyWith
  // ---------------------------------------------------------------------------
  group('ChatMessage copyWith', () {
    test('copies and updates individual fields', () {
      final original = ChatMessage(
        id: 'msg-1',
        senderId: 'user-1',
        senderName: 'Alice',
        text: 'Hello',
        createdAt: DateTime(2025, 3, 1),
      );

      final updated = original.copyWith(text: 'Updated text', isDeleted: true);

      expect(updated.text, 'Updated text');
      expect(updated.isDeleted, true);
      expect(updated.id, 'msg-1'); // unchanged
      expect(updated.senderId, 'user-1'); // unchanged
    });
  });

  // ---------------------------------------------------------------------------
  // ChatMessage hasWorkoutLink / hasImage edge cases
  // ---------------------------------------------------------------------------
  group('ChatMessage computed properties edge cases', () {
    test('hasWorkoutLink false when type is workoutLink but metadata is null', () {
      final msg = ChatMessage(
        id: 'msg-1',
        senderId: 'u1',
        senderName: 'A',
        text: 'test',
        type: MessageType.workoutLink,
        // no workoutMetadata
        createdAt: DateTime(2025, 1, 1),
      );

      expect(msg.hasWorkoutLink, isFalse);
    });

    test('hasImage false when type is image but metadata is null', () {
      final msg = ChatMessage(
        id: 'msg-2',
        senderId: 'u1',
        senderName: 'A',
        text: 'test',
        type: MessageType.image,
        // no imageMetadata
        createdAt: DateTime(2025, 1, 1),
      );

      expect(msg.hasImage, isFalse);
    });

    test('hasWorkoutLink false for text type even with metadata', () {
      final msg = ChatMessage(
        id: 'msg-3',
        senderId: 'u1',
        senderName: 'A',
        text: 'test',
        type: MessageType.text,
        workoutMetadata: WorkoutLinkMetadata(
          workoutId: 'w1',
          workoutName: 'Test',
          durationMinutes: 30,
          completedAt: DateTime(2025, 1, 1),
        ),
        createdAt: DateTime(2025, 3, 1),
      );

      expect(msg.hasWorkoutLink, isFalse);
    });
  });
}
