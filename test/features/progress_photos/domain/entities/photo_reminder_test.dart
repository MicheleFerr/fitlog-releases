import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';

void main() {
  // ---------------------------------------------------------------------------
  // PhotoReminderFrequency enum + extension
  // ---------------------------------------------------------------------------

  group('PhotoReminderFrequency', () {
    group('days', () {
      test('biweekly returns 14 days', () {
        expect(PhotoReminderFrequency.biweekly.days, equals(14));
      });

      test('monthly returns 28 days', () {
        expect(PhotoReminderFrequency.monthly.days, equals(28));
      });

      test('sixWeeks returns 42 days', () {
        expect(PhotoReminderFrequency.sixWeeks.days, equals(42));
      });

      test('custom returns default 28 days', () {
        expect(PhotoReminderFrequency.custom.days, equals(28));
      });
    });

    group('labelKey', () {
      test('biweekly returns everyTwoWeeks', () {
        expect(PhotoReminderFrequency.biweekly.labelKey, equals('everyTwoWeeks'));
      });

      test('monthly returns everyFourWeeks', () {
        expect(PhotoReminderFrequency.monthly.labelKey, equals('everyFourWeeks'));
      });

      test('sixWeeks returns everySixWeeks', () {
        expect(PhotoReminderFrequency.sixWeeks.labelKey, equals('everySixWeeks'));
      });

      test('custom returns customInterval', () {
        expect(PhotoReminderFrequency.custom.labelKey, equals('customInterval'));
      });

      test('all frequency values have non-empty label keys', () {
        for (final freq in PhotoReminderFrequency.values) {
          expect(freq.labelKey, isNotEmpty,
              reason: '${freq.name} labelKey should not be empty');
        }
      });
    });

    group('isRecommended', () {
      test('monthly is the recommended frequency', () {
        expect(PhotoReminderFrequency.monthly.isRecommended, isTrue);
      });

      test('other frequencies are not recommended', () {
        expect(PhotoReminderFrequency.biweekly.isRecommended, isFalse);
        expect(PhotoReminderFrequency.sixWeeks.isRecommended, isFalse);
        expect(PhotoReminderFrequency.custom.isRecommended, isFalse);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // PhotoReminderSettings entity
  // ---------------------------------------------------------------------------

  group('PhotoReminderSettings', () {
    group('defaults factory', () {
      test('creates disabled settings with default values', () {
        final settings = PhotoReminderSettings.defaults();

        expect(settings.isEnabled, isFalse);
        expect(settings.frequency, equals(PhotoReminderFrequency.monthly));
        expect(settings.customIntervalDays, equals(28));
        expect(settings.reminderHour, equals(9));
        expect(settings.reminderMinute, equals(0));
        expect(settings.suggestPose, isTrue);
        expect(settings.consecutiveIgnores, equals(0));
        expect(settings.maxIgnoresBeforeDisable, equals(3));
        expect(settings.disabledByAntiSpam, isFalse);
        expect(settings.lastReminderSent, isNull);
        expect(settings.nextReminderScheduled, isNull);
        expect(settings.notificationId, isNull);
      });
    });

    group('recommended factory', () {
      test('creates enabled settings with monthly frequency', () {
        final settings = PhotoReminderSettings.recommended();

        expect(settings.isEnabled, isTrue);
        expect(settings.frequency, equals(PhotoReminderFrequency.monthly));
        expect(settings.reminderHour, equals(9));
        expect(settings.reminderMinute, equals(0));
      });

      test('accepts custom hour and minute', () {
        final settings =
            PhotoReminderSettings.recommended(hour: 18, minute: 30);

        expect(settings.reminderHour, equals(18));
        expect(settings.reminderMinute, equals(30));
      });
    });

    group('reminderTime', () {
      test('returns TimeOfDay with correct hour and minute', () {
        const settings = PhotoReminderSettings(
          reminderHour: 8,
          reminderMinute: 45,
        );

        final time = settings.reminderTime;
        expect(time.hour, equals(8));
        expect(time.minute, equals(45));
      });

      test('returns TimeOfDay(9, 0) for defaults', () {
        final settings = PhotoReminderSettings.defaults();
        expect(settings.reminderTime, equals(const TimeOfDay(hour: 9, minute: 0)));
      });
    });

    group('effectiveIntervalDays', () {
      test('uses frequency days when not custom', () {
        const biweekly = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.biweekly,
        );
        expect(biweekly.effectiveIntervalDays, equals(14));

        const monthly = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.monthly,
        );
        expect(monthly.effectiveIntervalDays, equals(28));

        const sixWeeks = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.sixWeeks,
        );
        expect(sixWeeks.effectiveIntervalDays, equals(42));
      });

      test('uses customIntervalDays when frequency is custom', () {
        const settings = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.custom,
          customIntervalDays: 21,
        );

        expect(settings.effectiveIntervalDays, equals(21));
      });

      test('custom frequency with default customIntervalDays returns 28', () {
        const settings = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.custom,
        );

        expect(settings.effectiveIntervalDays, equals(28));
      });
    });

    group('calculateNextReminder', () {
      test('adds interval days to given date', () {
        const settings = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.monthly,
          reminderHour: 9,
          reminderMinute: 0,
        );

        final from = DateTime(2025, 6, 1);
        final next = settings.calculateNextReminder(from);

        // 28 days after June 1 = June 29
        expect(next.year, equals(2025));
        expect(next.month, equals(6));
        expect(next.day, equals(29));
        expect(next.hour, equals(9));
        expect(next.minute, equals(0));
      });

      test('sets time component to reminderHour and reminderMinute', () {
        const settings = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.biweekly,
          reminderHour: 18,
          reminderMinute: 30,
        );

        final from = DateTime(2025, 6, 1, 12, 0);
        final next = settings.calculateNextReminder(from);

        expect(next.hour, equals(18));
        expect(next.minute, equals(30));
        expect(next.second, equals(0));
      });

      test('works across month boundaries', () {
        const settings = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.monthly,
          reminderHour: 9,
          reminderMinute: 0,
        );

        final from = DateTime(2025, 12, 15);
        final next = settings.calculateNextReminder(from);

        // 28 days after Dec 15 = Jan 12, 2026
        expect(next.year, equals(2026));
        expect(next.month, equals(1));
        expect(next.day, equals(12));
      });

      test('works with custom interval', () {
        const settings = PhotoReminderSettings(
          frequency: PhotoReminderFrequency.custom,
          customIntervalDays: 10,
          reminderHour: 8,
          reminderMinute: 0,
        );

        final from = DateTime(2025, 6, 1);
        final next = settings.calculateNextReminder(from);

        expect(next.day, equals(11));
        expect(next.month, equals(6));
      });
    });

    group('shouldDisableForAntiSpam', () {
      test('returns false when consecutiveIgnores is below limit', () {
        const settings = PhotoReminderSettings(
          consecutiveIgnores: 2,
          maxIgnoresBeforeDisable: 3,
        );

        expect(settings.shouldDisableForAntiSpam, isFalse);
      });

      test('returns true when consecutiveIgnores reaches limit', () {
        const settings = PhotoReminderSettings(
          consecutiveIgnores: 3,
          maxIgnoresBeforeDisable: 3,
        );

        expect(settings.shouldDisableForAntiSpam, isTrue);
      });

      test('returns true when consecutiveIgnores exceeds limit', () {
        const settings = PhotoReminderSettings(
          consecutiveIgnores: 5,
          maxIgnoresBeforeDisable: 3,
        );

        expect(settings.shouldDisableForAntiSpam, isTrue);
      });

      test('returns false when maxIgnoresBeforeDisable is 0 (no limit)', () {
        const settings = PhotoReminderSettings(
          consecutiveIgnores: 100,
          maxIgnoresBeforeDisable: 0,
        );

        expect(settings.shouldDisableForAntiSpam, isFalse);
      });
    });

    group('formattedReminderTime', () {
      test('formats 9:00 as 09:00', () {
        const settings = PhotoReminderSettings(
          reminderHour: 9,
          reminderMinute: 0,
        );

        expect(settings.formattedReminderTime, equals('09:00'));
      });

      test('formats 18:30 correctly', () {
        const settings = PhotoReminderSettings(
          reminderHour: 18,
          reminderMinute: 30,
        );

        expect(settings.formattedReminderTime, equals('18:30'));
      });

      test('pads single digit hour and minute with zero', () {
        const settings = PhotoReminderSettings(
          reminderHour: 7,
          reminderMinute: 5,
        );

        expect(settings.formattedReminderTime, equals('07:05'));
      });

      test('formats midnight (0:00) as 00:00', () {
        const settings = PhotoReminderSettings(
          reminderHour: 0,
          reminderMinute: 0,
        );

        expect(settings.formattedReminderTime, equals('00:00'));
      });

      test('formats 23:59 correctly', () {
        const settings = PhotoReminderSettings(
          reminderHour: 23,
          reminderMinute: 59,
        );

        expect(settings.formattedReminderTime, equals('23:59'));
      });
    });

    group('copyWith', () {
      test('creates updated copy without mutating original', () {
        const original = PhotoReminderSettings(
          isEnabled: false,
          frequency: PhotoReminderFrequency.monthly,
        );

        final enabled = original.copyWith(isEnabled: true);

        expect(enabled.isEnabled, isTrue);
        expect(original.isEnabled, isFalse);
        expect(enabled.frequency, equals(PhotoReminderFrequency.monthly));
      });

      test('can update multiple fields at once', () {
        const original = PhotoReminderSettings();
        final updated = original.copyWith(
          isEnabled: true,
          frequency: PhotoReminderFrequency.biweekly,
          reminderHour: 20,
          reminderMinute: 30,
          consecutiveIgnores: 1,
        );

        expect(updated.isEnabled, isTrue);
        expect(updated.frequency, equals(PhotoReminderFrequency.biweekly));
        expect(updated.reminderHour, equals(20));
        expect(updated.reminderMinute, equals(30));
        expect(updated.consecutiveIgnores, equals(1));
      });
    });

    group('equality', () {
      test('two default settings are equal', () {
        final a = PhotoReminderSettings.defaults();
        final b = PhotoReminderSettings.defaults();

        expect(a, equals(b));
      });

      test('settings differing in isEnabled are not equal', () {
        const a = PhotoReminderSettings(isEnabled: true);
        const b = PhotoReminderSettings(isEnabled: false);

        expect(a, isNot(equals(b)));
      });

      test('settings differing in frequency are not equal', () {
        const a = PhotoReminderSettings(frequency: PhotoReminderFrequency.biweekly);
        const b = PhotoReminderSettings(frequency: PhotoReminderFrequency.monthly);

        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('round-trips through JSON', () {
        const original = PhotoReminderSettings(
          isEnabled: true,
          frequency: PhotoReminderFrequency.sixWeeks,
          customIntervalDays: 42,
          reminderHour: 18,
          reminderMinute: 30,
          suggestPose: false,
          consecutiveIgnores: 1,
          maxIgnoresBeforeDisable: 5,
          disabledByAntiSpam: false,
        );

        final json = original.toJson();
        final restored = PhotoReminderSettings.fromJson(json);

        expect(restored.isEnabled, equals(original.isEnabled));
        expect(restored.frequency, equals(original.frequency));
        expect(restored.customIntervalDays, equals(original.customIntervalDays));
        expect(restored.reminderHour, equals(original.reminderHour));
        expect(restored.reminderMinute, equals(original.reminderMinute));
        expect(restored.suggestPose, equals(original.suggestPose));
        expect(restored.consecutiveIgnores, equals(original.consecutiveIgnores));
        expect(restored.maxIgnoresBeforeDisable,
            equals(original.maxIgnoresBeforeDisable));
        expect(restored.disabledByAntiSpam, equals(original.disabledByAntiSpam));
      });

      test('serializes lastReminderSent and nextReminderScheduled', () {
        final sentAt = DateTime(2025, 6, 1, 9, 0);
        final nextAt = DateTime(2025, 6, 29, 9, 0);
        final original = PhotoReminderSettings(
          lastReminderSent: sentAt,
          nextReminderScheduled: nextAt,
          notificationId: 42,
        );

        final json = original.toJson();
        final restored = PhotoReminderSettings.fromJson(json);

        expect(restored.lastReminderSent, equals(sentAt));
        expect(restored.nextReminderScheduled, equals(nextAt));
        expect(restored.notificationId, equals(42));
      });

      test('uses defaults when fields missing from JSON', () {
        final json = <String, dynamic>{};
        final settings = PhotoReminderSettings.fromJson(json);

        expect(settings.isEnabled, isFalse);
        expect(settings.frequency, equals(PhotoReminderFrequency.monthly));
        expect(settings.reminderHour, equals(9));
        expect(settings.reminderMinute, equals(0));
        expect(settings.consecutiveIgnores, equals(0));
        expect(settings.maxIgnoresBeforeDisable, equals(3));
      });

      test('serializes all PhotoReminderFrequency enum values', () {
        for (final freq in PhotoReminderFrequency.values) {
          final settings = PhotoReminderSettings(frequency: freq);
          final json = settings.toJson();
          final restored = PhotoReminderSettings.fromJson(json);
          expect(restored.frequency, equals(freq));
        }
      });
    });
  });

  // ---------------------------------------------------------------------------
  // PhotoReminderRecord entity
  // ---------------------------------------------------------------------------

  group('PhotoReminderRecord', () {
    final sentAt = DateTime(2025, 6, 1, 9, 0);
    final openedAt = DateTime(2025, 6, 1, 10, 0);
    final photoTakenAt = DateTime(2025, 6, 1, 10, 30);

    group('factory constructor', () {
      test('creates record with required fields', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(record.id, equals('record-001'));
        expect(record.sentAt, equals(sentAt));
        expect(record.messageVariation, equals(0));
        expect(record.openedAt, isNull);
        expect(record.photoTakenAt, isNull);
        expect(record.wasCanceled, isFalse);
      });

      test('stores optional timestamps when provided', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          openedAt: openedAt,
          photoTakenAt: photoTakenAt,
          messageVariation: 1,
        );

        expect(record.openedAt, equals(openedAt));
        expect(record.photoTakenAt, equals(photoTakenAt));
      });
    });

    group('wasOpened computed property', () {
      test('returns true when openedAt is set', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          openedAt: openedAt,
          messageVariation: 0,
        );

        expect(record.wasOpened, isTrue);
      });

      test('returns false when openedAt is null', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(record.wasOpened, isFalse);
      });
    });

    group('photoWasTaken computed property', () {
      test('returns true when photoTakenAt is set', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          photoTakenAt: photoTakenAt,
          messageVariation: 0,
        );

        expect(record.photoWasTaken, isTrue);
      });

      test('returns false when photoTakenAt is null', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(record.photoWasTaken, isFalse);
      });
    });

    group('wasSuccessful computed property', () {
      test('returns true when photo was taken', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          photoTakenAt: photoTakenAt,
          messageVariation: 0,
        );

        expect(record.wasSuccessful, isTrue);
      });

      test('returns false when no photo was taken', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(record.wasSuccessful, isFalse);
      });
    });

    group('wasIgnored computed property', () {
      test('returns true when not canceled and not opened', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(record.wasIgnored, isTrue);
      });

      test('returns false when reminder was opened', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          openedAt: openedAt,
          messageVariation: 0,
        );

        expect(record.wasIgnored, isFalse);
      });

      test('returns false when reminder was canceled', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          wasCanceled: true,
          messageVariation: 0,
        );

        expect(record.wasIgnored, isFalse);
      });
    });

    group('equality', () {
      test('two records with same fields are equal', () {
        final a = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );
        final b = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(a, equals(b));
      });

      test('records with different ids are not equal', () {
        final a = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 0,
        );
        final b = PhotoReminderRecord(
          id: 'record-002',
          sentAt: sentAt,
          messageVariation: 0,
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('round-trips through JSON', () {
        final original = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          openedAt: openedAt,
          photoTakenAt: photoTakenAt,
          messageVariation: 2,
          wasCanceled: false,
        );

        final json = original.toJson();
        final restored = PhotoReminderRecord.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.sentAt, equals(original.sentAt));
        expect(restored.openedAt, equals(original.openedAt));
        expect(restored.photoTakenAt, equals(original.photoTakenAt));
        expect(restored.messageVariation, equals(original.messageVariation));
        expect(restored.wasCanceled, equals(original.wasCanceled));
      });

      test('serializes canceled record correctly', () {
        final original = PhotoReminderRecord(
          id: 'record-canceled',
          sentAt: sentAt,
          messageVariation: 0,
          wasCanceled: true,
        );

        final json = original.toJson();
        final restored = PhotoReminderRecord.fromJson(json);

        expect(restored.wasCanceled, isTrue);
        expect(restored.openedAt, isNull);
        expect(restored.photoTakenAt, isNull);
      });

      test('includes all required keys in JSON output', () {
        final record = PhotoReminderRecord(
          id: 'record-001',
          sentAt: sentAt,
          messageVariation: 1,
        );

        final json = record.toJson();

        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('sentAt'), isTrue);
        expect(json.containsKey('messageVariation'), isTrue);
        expect(json.containsKey('wasCanceled'), isTrue);
      });
    });
  });
}
