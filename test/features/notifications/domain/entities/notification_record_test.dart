library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';

void main() {
  group('NotificationRecord', () {
    final now = DateTime(2026, 2, 15, 10, 30);

    NotificationRecord createRecord({
      String id = 'test-id',
      NotificationType type = NotificationType.inactivity,
      DateTime? sentAt,
      DateTime? openedAt,
      String messageKey = 'msg_1',
      String? context,
      int? inactivityDay,
      bool wasCanceled = false,
    }) {
      return NotificationRecord(
        id: id,
        type: type,
        sentAt: sentAt ?? now,
        openedAt: openedAt,
        messageKey: messageKey,
        context: context,
        inactivityDay: inactivityDay,
        wasCanceled: wasCanceled,
      );
    }

    test('factory creates with required fields', () {
      final record = createRecord();
      expect(record.id, 'test-id');
      expect(record.type, NotificationType.inactivity);
      expect(record.sentAt, now);
      expect(record.openedAt, isNull);
      expect(record.messageKey, 'msg_1');
      expect(record.context, isNull);
      expect(record.inactivityDay, isNull);
      expect(record.wasCanceled, isFalse);
    });

    test('factory creates with all optional fields', () {
      final openedTime = DateTime(2026, 2, 15, 11, 0);
      final record = createRecord(
        openedAt: openedTime,
        context: 'Bench Press',
        inactivityDay: 7,
        wasCanceled: true,
      );
      expect(record.openedAt, openedTime);
      expect(record.context, 'Bench Press');
      expect(record.inactivityDay, 7);
      expect(record.wasCanceled, isTrue);
    });

    test('copyWith creates new object with updated fields', () {
      final record = createRecord();
      final updated = record.copyWith(
        openedAt: DateTime(2026, 2, 15, 12, 0),
        wasCanceled: true,
      );

      expect(updated.id, record.id);
      expect(updated.type, record.type);
      expect(updated.sentAt, record.sentAt);
      expect(updated.openedAt, DateTime(2026, 2, 15, 12, 0));
      expect(updated.wasCanceled, isTrue);
      // Original unchanged
      expect(record.openedAt, isNull);
      expect(record.wasCanceled, isFalse);
    });

    test('equality works for identical values', () {
      final a = createRecord();
      final b = createRecord();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality fails for different values', () {
      final a = createRecord(id: 'a');
      final b = createRecord(id: 'b');
      expect(a, isNot(equals(b)));
    });

    group('JSON round-trip', () {
      test('serializes and deserializes with required fields', () {
        final record = createRecord();
        final json = record.toJson();
        final restored = NotificationRecord.fromJson(json);
        expect(restored, record);
      });

      test('serializes and deserializes with all fields', () {
        final record = createRecord(
          openedAt: DateTime(2026, 2, 15, 11, 0),
          context: 'Squat',
          inactivityDay: 3,
          wasCanceled: true,
        );
        final json = record.toJson();
        final restored = NotificationRecord.fromJson(json);
        expect(restored, record);
      });

      test('toJson contains expected keys', () {
        final record = createRecord();
        final json = record.toJson();
        expect(json, containsPair('id', 'test-id'));
        expect(json, containsPair('messageKey', 'msg_1'));
        expect(json, containsPair('wasCanceled', false));
        expect(json, contains('type'));
        expect(json, contains('sentAt'));
      });
    });

    group('computed properties', () {
      test('wasOpened returns true when openedAt is set', () {
        final record = createRecord(
          openedAt: DateTime(2026, 2, 15, 11, 0),
        );
        expect(record.wasOpened, isTrue);
      });

      test('wasOpened returns false when openedAt is null', () {
        final record = createRecord();
        expect(record.wasOpened, isFalse);
      });

      test('wasIgnored returns true when not canceled and not opened', () {
        final record = createRecord();
        expect(record.wasIgnored, isTrue);
      });

      test('wasIgnored returns false when opened', () {
        final record = createRecord(
          openedAt: DateTime(2026, 2, 15, 11, 0),
        );
        expect(record.wasIgnored, isFalse);
      });

      test('wasIgnored returns false when canceled', () {
        final record = createRecord(wasCanceled: true);
        expect(record.wasIgnored, isFalse);
      });

      test('wasIgnored returns false when canceled AND opened', () {
        final record = createRecord(
          openedAt: DateTime(2026, 2, 15, 11, 0),
          wasCanceled: true,
        );
        expect(record.wasIgnored, isFalse);
      });
    });
  });

  group('NotificationStats', () {
    NotificationStats createStats({
      int totalSent = 10,
      int totalOpened = 5,
      int consecutiveIgnores = 0,
      DateTime? lastSentAt,
      String? lastMessageKey,
    }) {
      return NotificationStats(
        totalSent: totalSent,
        totalOpened: totalOpened,
        consecutiveIgnores: consecutiveIgnores,
        lastSentAt: lastSentAt,
        lastMessageKey: lastMessageKey,
      );
    }

    test('factory creates with required fields', () {
      final stats = createStats();
      expect(stats.totalSent, 10);
      expect(stats.totalOpened, 5);
      expect(stats.consecutiveIgnores, 0);
      expect(stats.lastSentAt, isNull);
      expect(stats.lastMessageKey, isNull);
    });

    test('factory creates with all fields', () {
      final time = DateTime(2026, 2, 15);
      final stats = createStats(
        lastSentAt: time,
        lastMessageKey: 'pr_1',
      );
      expect(stats.lastSentAt, time);
      expect(stats.lastMessageKey, 'pr_1');
    });

    test('copyWith creates new object', () {
      final stats = createStats();
      final updated = stats.copyWith(totalSent: 20, consecutiveIgnores: 3);
      expect(updated.totalSent, 20);
      expect(updated.consecutiveIgnores, 3);
      expect(updated.totalOpened, 5);
    });

    test('equality works', () {
      final a = createStats();
      final b = createStats();
      expect(a, equals(b));
    });

    group('JSON round-trip', () {
      test('serializes and deserializes with required fields', () {
        final stats = createStats();
        final json = stats.toJson();
        final restored = NotificationStats.fromJson(json);
        expect(restored, stats);
      });

      test('serializes and deserializes with all fields', () {
        final stats = createStats(
          lastSentAt: DateTime(2026, 2, 15),
          lastMessageKey: 'streak_2',
        );
        final json = stats.toJson();
        final restored = NotificationStats.fromJson(json);
        expect(restored, stats);
      });
    });

    group('openRate', () {
      test('returns 0.0 when no notifications sent', () {
        final stats = createStats(totalSent: 0, totalOpened: 0);
        expect(stats.openRate, 0.0);
      });

      test('returns 0.5 when half opened', () {
        final stats = createStats(totalSent: 10, totalOpened: 5);
        expect(stats.openRate, 0.5);
      });

      test('returns 1.0 when all opened', () {
        final stats = createStats(totalSent: 10, totalOpened: 10);
        expect(stats.openRate, 1.0);
      });

      test('returns correct rate for partial opens', () {
        final stats = createStats(totalSent: 3, totalOpened: 1);
        expect(stats.openRate, closeTo(0.333, 0.01));
      });
    });

    group('shouldStopSending', () {
      test('returns false when ignores below threshold', () {
        final stats = createStats(consecutiveIgnores: 2);
        expect(stats.shouldStopSending(3), isFalse);
      });

      test('returns true when ignores at threshold', () {
        final stats = createStats(consecutiveIgnores: 3);
        expect(stats.shouldStopSending(3), isTrue);
      });

      test('returns true when ignores above threshold', () {
        final stats = createStats(consecutiveIgnores: 5);
        expect(stats.shouldStopSending(3), isTrue);
      });

      test('returns false when zero ignores', () {
        final stats = createStats(consecutiveIgnores: 0);
        expect(stats.shouldStopSending(3), isFalse);
      });

      test('returns true when maxIgnores is 0', () {
        final stats = createStats(consecutiveIgnores: 0);
        expect(stats.shouldStopSending(0), isTrue);
      });
    });
  });
}
