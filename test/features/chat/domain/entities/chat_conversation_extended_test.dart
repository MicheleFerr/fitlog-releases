/// Extended tests for ChatConversation - covering fromFirestore, toFirestore,
/// fromJson/toJson, and edge cases not covered by chat_entities_test.dart.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/chat/domain/entities/chat_conversation.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ---------------------------------------------------------------------------
  // fromJson / toJson via freezed-generated code
  // ---------------------------------------------------------------------------
  group('ChatConversation fromJson / toJson', () {
    test('round-trip with minimal data', () {
      final original = ChatConversation(
        id: 'conv-1',
        coachId: 'coach-1',
        athleteId: 'athlete-1',
        coachName: 'Coach Mike',
        athleteName: 'John Doe',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );

      final json = original.toJson();
      final restored = ChatConversation.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.coachId, original.coachId);
      expect(restored.athleteId, original.athleteId);
      expect(restored.coachName, original.coachName);
      expect(restored.athleteName, original.athleteName);
      expect(restored.coachUnreadCount, 0);
      expect(restored.athleteUnreadCount, 0);
      expect(restored.lastMessage, isNull);
    });

    test('round-trip with all optional fields set', () {
      final original = ChatConversation(
        id: 'conv-2',
        coachId: 'coach-1',
        athleteId: 'athlete-1',
        coachName: 'Coach',
        athleteName: 'Athlete',
        lastMessage: 'See you tomorrow!',
        lastMessageAt: DateTime(2025, 3, 1, 15, 0),
        lastMessageSenderId: 'coach-1',
        coachUnreadCount: 3,
        athleteUnreadCount: 1,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );

      final json = original.toJson();
      final restored = ChatConversation.fromJson(json);

      expect(restored.lastMessage, 'See you tomorrow!');
      expect(restored.lastMessageSenderId, 'coach-1');
      expect(restored.coachUnreadCount, 3);
      expect(restored.athleteUnreadCount, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // toFirestore
  // ---------------------------------------------------------------------------
  group('ChatConversation toFirestore', () {
    test('minimal conversation contains required keys', () {
      final conv = ChatConversation(
        id: 'conv-1',
        coachId: 'coach-1',
        athleteId: 'athlete-1',
        coachName: 'Coach Mike',
        athleteName: 'John Doe',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );

      final data = conv.toFirestore();

      expect(data['coachId'], 'coach-1');
      expect(data['athleteId'], 'athlete-1');
      expect(data['coachName'], 'Coach Mike');
      expect(data['athleteName'], 'John Doe');
      expect(data['coachUnreadCount'], 0);
      expect(data['athleteUnreadCount'], 0);
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['updatedAt'], isA<Timestamp>());
      // Optional fields not set - should not be present
      expect(data.containsKey('lastMessage'), isFalse);
      expect(data.containsKey('lastMessageAt'), isFalse);
      expect(data.containsKey('lastMessageSenderId'), isFalse);
    });

    test('conversation with optional fields includes them in output', () {
      final conv = ChatConversation(
        id: 'conv-2',
        coachId: 'coach-1',
        athleteId: 'athlete-1',
        coachName: 'Coach',
        athleteName: 'Athlete',
        lastMessage: 'Great session!',
        lastMessageAt: DateTime(2025, 3, 1, 16, 0),
        lastMessageSenderId: 'coach-1',
        coachUnreadCount: 2,
        athleteUnreadCount: 0,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );

      final data = conv.toFirestore();

      expect(data['lastMessage'], 'Great session!');
      expect(data['lastMessageAt'], isA<Timestamp>());
      expect(data['lastMessageSenderId'], 'coach-1');
      expect(data['coachUnreadCount'], 2);
      expect(data['athleteUnreadCount'], 0);
    });
  });

  // ---------------------------------------------------------------------------
  // fromFirestore
  // ---------------------------------------------------------------------------
  group('ChatConversation fromFirestore', () {
    test('parses full conversation from Firestore', () async {
      final createdAt = DateTime(2025, 1, 1);
      final updatedAt = DateTime(2025, 3, 1);
      final lastMessageAt = DateTime(2025, 3, 1, 14, 0);

      final ref = fakeFirestore.collection('conversations').doc('conv-1');
      await ref.set({
        'coachId': 'coach-abc',
        'athleteId': 'athlete-xyz',
        'coachName': 'Coach Sarah',
        'athleteName': 'Mike Jones',
        'lastMessage': 'Great session today!',
        'lastMessageAt': Timestamp.fromDate(lastMessageAt),
        'lastMessageSenderId': 'coach-abc',
        'coachUnreadCount': 0,
        'athleteUnreadCount': 2,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      final snap = await ref.get();
      final conv = ChatConversation.fromFirestore(snap);

      expect(conv.id, 'conv-1');
      expect(conv.coachId, 'coach-abc');
      expect(conv.athleteId, 'athlete-xyz');
      expect(conv.coachName, 'Coach Sarah');
      expect(conv.athleteName, 'Mike Jones');
      expect(conv.lastMessage, 'Great session today!');
      expect(conv.lastMessageSenderId, 'coach-abc');
      expect(conv.coachUnreadCount, 0);
      expect(conv.athleteUnreadCount, 2);
    });

    test('parses conversation without optional fields', () async {
      final ref = fakeFirestore.collection('conversations').doc('conv-2');
      await ref.set({
        'coachId': 'coach-1',
        'athleteId': 'athlete-1',
        'coachName': 'Coach',
        'athleteName': 'Athlete',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
      });

      final snap = await ref.get();
      final conv = ChatConversation.fromFirestore(snap);

      expect(conv.lastMessage, isNull);
      expect(conv.lastMessageAt, isNull);
      expect(conv.lastMessageSenderId, isNull);
      expect(conv.coachUnreadCount, 0);
      expect(conv.athleteUnreadCount, 0);
    });

    test('parses lastMessageAt from ISO string fallback', () async {
      final ref = fakeFirestore.collection('conversations').doc('conv-3');
      await ref.set({
        'coachId': 'coach-1',
        'athleteId': 'athlete-1',
        'coachName': 'Coach',
        'athleteName': 'Athlete',
        'lastMessage': 'Hello',
        'lastMessageAt': '2025-03-01T14:00:00.000',
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2025, 3, 1)),
      });

      final snap = await ref.get();
      final conv = ChatConversation.fromFirestore(snap);

      expect(conv.lastMessageAt, isNotNull);
    });

    test('handles missing fields gracefully with defaults', () async {
      final ref = fakeFirestore.collection('conversations').doc('conv-4');
      await ref.set({
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
      });

      final snap = await ref.get();
      final conv = ChatConversation.fromFirestore(snap);

      expect(conv.coachId, '');
      expect(conv.athleteId, '');
      expect(conv.coachName, '');
      expect(conv.athleteName, '');
    });

    test('createdAt falls back to now when missing', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final ref = fakeFirestore.collection('conversations').doc('conv-5');
      await ref.set({
        'coachId': 'c1',
        'athleteId': 'a1',
        'coachName': 'Coach',
        'athleteName': 'Athlete',
        // no createdAt / updatedAt
      });

      final snap = await ref.get();
      final conv = ChatConversation.fromFirestore(snap);
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(conv.createdAt.isAfter(before), isTrue);
      expect(conv.createdAt.isBefore(after), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------
  group('ChatConversation copyWith', () {
    test('updates individual fields without changing others', () {
      final original = ChatConversation(
        id: 'conv-1',
        coachId: 'coach-1',
        athleteId: 'athlete-1',
        coachName: 'Coach Mike',
        athleteName: 'John',
        coachUnreadCount: 0,
        athleteUnreadCount: 0,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );

      final updated = original.copyWith(
        lastMessage: 'New message',
        coachUnreadCount: 5,
      );

      expect(updated.lastMessage, 'New message');
      expect(updated.coachUnreadCount, 5);
      expect(updated.id, 'conv-1'); // unchanged
      expect(updated.coachId, 'coach-1'); // unchanged
    });
  });
}
