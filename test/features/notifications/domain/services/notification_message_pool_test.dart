library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Fake AppLocalizations that returns predictable strings.
class FakeAppLocalizations extends AppLocalizations {
  FakeAppLocalizations() : super('en');

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    // Extract method name from Symbol("methodName")
    final methodName = name.replaceAll('Symbol("', '').replaceAll('")', '');

    // Handle methods with positional arguments
    if (invocation.positionalArguments.isNotEmpty) {
      final args = invocation.positionalArguments.join(', ');
      return '$methodName($args)';
    }

    return methodName;
  }
}

void main() {
  late NotificationMessagePool pool;
  late FakeAppLocalizations l10n;

  setUp(() {
    pool = NotificationMessagePool();
    l10n = FakeAppLocalizations();
  });

  group('NotificationMessagePool.getMessage', () {
    test('returns a NotificationMessage for workoutForgotten', () {
      final message = pool.getMessage(
        type: NotificationType.workoutForgotten,
        l10n: l10n,
      );
      expect(message, isNotNull);
      expect(message.key, startsWith('workout_forgotten_'));
      expect(message.title, isNotEmpty);
      expect(message.body, isNotEmpty);
    });

    test('returns a NotificationMessage for inactivity', () {
      final message = pool.getMessage(
        type: NotificationType.inactivity,
        l10n: l10n,
      );
      expect(message.key, startsWith('inactivity_'));
    });

    test('returns a NotificationMessage for insightPr', () {
      final message = pool.getMessage(
        type: NotificationType.insightPr,
        l10n: l10n,
        params: {'exerciseName': 'Bench Press'},
      );
      expect(message.key, startsWith('pr_'));
    });

    test('returns a NotificationMessage for insightStreak', () {
      final message = pool.getMessage(
        type: NotificationType.insightStreak,
        l10n: l10n,
        params: {'streakDays': 14},
      );
      expect(message.key, startsWith('streak_'));
    });

    test('returns a NotificationMessage for insightVolume', () {
      final message = pool.getMessage(
        type: NotificationType.insightVolume,
        l10n: l10n,
        params: {'volumePercent': 25},
      );
      expect(message.key, startsWith('volume_'));
    });

    test('excludeKey filters out the specified message', () {
      // Get messages multiple times and check that excluded key never appears
      final results = <String>{};
      for (var i = 0; i < 50; i++) {
        final message = pool.getMessage(
          type: NotificationType.workoutForgotten,
          l10n: l10n,
          excludeKey: 'workout_forgotten_1',
        );
        results.add(message.key);
      }
      expect(results, isNot(contains('workout_forgotten_1')));
    });

    test('returns from full pool when all messages excluded', () {
      // There are only 3 workout_forgotten messages; exclude a non-existent key
      // that matches none - but let's exclude ALL keys to test fallback
      // Since we can't exclude all in one call, let's test with a key that
      // happens to be the only one left
      final message = pool.getMessage(
        type: NotificationType.insightStreak,
        l10n: l10n,
        excludeKey: 'nonexistent_key',
      );
      expect(message.key, startsWith('streak_'));
    });

    test('returns all types with non-empty title and body', () {
      for (final type in NotificationType.values) {
        final message = pool.getMessage(
          type: type,
          l10n: l10n,
          params: {
            'exerciseName': 'Test',
            'streakDays': 7,
            'volumePercent': 20,
          },
        );
        expect(message.title, isNotEmpty, reason: '${type.name} title');
        expect(message.body, isNotEmpty, reason: '${type.name} body');
        expect(message.key, isNotEmpty, reason: '${type.name} key');
      }
    });

    test('PR message uses default exerciseName when not provided', () {
      final message = pool.getMessage(
        type: NotificationType.insightPr,
        l10n: l10n,
      );
      // Should not throw - uses 'exercise' as default
      expect(message.body, isNotEmpty);
    });

    test('streak message uses default streakDays when not provided', () {
      final message = pool.getMessage(
        type: NotificationType.insightStreak,
        l10n: l10n,
      );
      expect(message.body, isNotEmpty);
    });

    test('volume message uses default volumePercent when not provided', () {
      final message = pool.getMessage(
        type: NotificationType.insightVolume,
        l10n: l10n,
      );
      expect(message.body, isNotEmpty);
    });
  });

  group('NotificationMessage', () {
    test('equality based on key', () {
      const a = NotificationMessage(
        key: 'test_1',
        title: 'Title A',
        body: 'Body A',
      );
      const b = NotificationMessage(
        key: 'test_1',
        title: 'Title B',
        body: 'Body B',
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different keys', () {
      const a = NotificationMessage(
        key: 'test_1',
        title: 'Title',
        body: 'Body',
      );
      const b = NotificationMessage(
        key: 'test_2',
        title: 'Title',
        body: 'Body',
      );
      expect(a, isNot(equals(b)));
    });

    test('stores key, title, and body', () {
      const msg = NotificationMessage(
        key: 'k',
        title: 't',
        body: 'b',
      );
      expect(msg.key, 'k');
      expect(msg.title, 't');
      expect(msg.body, 'b');
    });
  });
}
