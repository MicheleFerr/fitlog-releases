import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/progress_photos/data/repositories/photo_reminder_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';

/// Helper: create a real SharedPreferences backed by in-memory mock storage.
Future<SharedPreferences> makeFakePrefs([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhotoReminderRepository repository;
  late SharedPreferences prefs;

  setUp(() async {
    prefs = await makeFakePrefs();
    repository = PhotoReminderRepository(prefs: prefs);
  });

  // ---------------------------------------------------------------------------
  // getSettings
  // ---------------------------------------------------------------------------

  group('getSettings', () {
    test('returns defaults when no data has been stored', () {
      final settings = repository.getSettings();

      expect(settings.isEnabled, isFalse);
      expect(settings.frequency, equals(PhotoReminderFrequency.monthly));
      expect(settings.reminderHour, equals(9));
      expect(settings.reminderMinute, equals(0));
      expect(settings.consecutiveIgnores, equals(0));
    });

    test('returns stored settings after save', () async {
      const saved = PhotoReminderSettings(
        isEnabled: true,
        frequency: PhotoReminderFrequency.biweekly,
        reminderHour: 18,
        reminderMinute: 45,
      );

      await repository.saveSettings(saved);
      final retrieved = repository.getSettings();

      expect(retrieved.isEnabled, isTrue);
      expect(retrieved.frequency, equals(PhotoReminderFrequency.biweekly));
      expect(retrieved.reminderHour, equals(18));
      expect(retrieved.reminderMinute, equals(45));
    });

    test('returns defaults when stored JSON is corrupted', () async {
      await prefs.setString('photo_reminder_settings', 'not valid json!!!!');
      final settings = repository.getSettings();

      expect(settings.isEnabled, isFalse);
      expect(settings.frequency, equals(PhotoReminderFrequency.monthly));
    });
  });

  // ---------------------------------------------------------------------------
  // saveSettings
  // ---------------------------------------------------------------------------

  group('saveSettings', () {
    test('returns true on successful save', () async {
      const settings = PhotoReminderSettings(isEnabled: true);
      final result = await repository.saveSettings(settings);
      expect(result, isTrue);
    });

    test('persists all frequency values correctly', () async {
      for (final freq in PhotoReminderFrequency.values) {
        final settings = PhotoReminderSettings(frequency: freq);
        await repository.saveSettings(settings);
        final retrieved = repository.getSettings();
        expect(retrieved.frequency, equals(freq),
            reason: 'Frequency ${freq.name} should be saved and retrieved');
      }
    });

    test('overwrites previously saved settings', () async {
      await repository.saveSettings(
        const PhotoReminderSettings(isEnabled: true, reminderHour: 9),
      );
      await repository.saveSettings(
        const PhotoReminderSettings(isEnabled: false, reminderHour: 20),
      );

      final retrieved = repository.getSettings();
      expect(retrieved.isEnabled, isFalse);
      expect(retrieved.reminderHour, equals(20));
    });
  });

  // ---------------------------------------------------------------------------
  // updateSettings
  // ---------------------------------------------------------------------------

  group('updateSettings', () {
    test('applies modifier function to current settings', () async {
      await repository.saveSettings(
        const PhotoReminderSettings(isEnabled: false, reminderHour: 9),
      );

      final updated = await repository.updateSettings(
        (current) => current.copyWith(isEnabled: true, reminderHour: 12),
      );

      expect(updated.isEnabled, isTrue);
      expect(updated.reminderHour, equals(12));
    });

    test('persists the result of the modifier', () async {
      await repository.updateSettings(
        (current) => current.copyWith(consecutiveIgnores: 2),
      );

      final retrieved = repository.getSettings();
      expect(retrieved.consecutiveIgnores, equals(2));
    });

    test('modifier receives default settings when nothing was previously saved',
        () async {
      PhotoReminderSettings? receivedSettings;

      await repository.updateSettings((current) {
        receivedSettings = current;
        return current;
      });

      expect(receivedSettings, isNotNull);
      expect(receivedSettings!.isEnabled, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // enableReminders
  // ---------------------------------------------------------------------------

  group('enableReminders', () {
    test('enables reminders with default monthly frequency', () async {
      final settings = await repository.enableReminders();

      expect(settings.isEnabled, isTrue);
      expect(settings.frequency, equals(PhotoReminderFrequency.monthly));
      expect(settings.reminderHour, equals(9));
      expect(settings.reminderMinute, equals(0));
    });

    test('enables reminders with custom frequency', () async {
      final settings = await repository.enableReminders(
        frequency: PhotoReminderFrequency.biweekly,
        hour: 18,
        minute: 30,
      );

      expect(settings.isEnabled, isTrue);
      expect(settings.frequency, equals(PhotoReminderFrequency.biweekly));
      expect(settings.reminderHour, equals(18));
      expect(settings.reminderMinute, equals(30));
    });

    test('resets consecutiveIgnores to zero', () async {
      // First simulate some ignores
      await repository.updateSettings(
        (current) => current.copyWith(consecutiveIgnores: 2),
      );

      final settings = await repository.enableReminders();
      expect(settings.consecutiveIgnores, equals(0));
    });

    test('clears disabledByAntiSpam flag', () async {
      await repository.updateSettings(
        (current) => current.copyWith(disabledByAntiSpam: true),
      );

      final settings = await repository.enableReminders();
      expect(settings.disabledByAntiSpam, isFalse);
    });

    test('persists enabled state to storage', () async {
      await repository.enableReminders();
      final retrieved = repository.getSettings();
      expect(retrieved.isEnabled, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // disableReminders
  // ---------------------------------------------------------------------------

  group('disableReminders', () {
    setUp(() async {
      await repository.enableReminders();
    });

    test('disables reminders', () async {
      final settings = await repository.disableReminders();
      expect(settings.isEnabled, isFalse);
    });

    test('clears notificationId', () async {
      await repository.updateSettings(
        (current) => current.copyWith(notificationId: 123),
      );

      final settings = await repository.disableReminders();
      expect(settings.notificationId, isNull);
    });

    test('sets disabledByAntiSpam flag when byAntiSpam is true', () async {
      final settings = await repository.disableReminders(byAntiSpam: true);
      expect(settings.disabledByAntiSpam, isTrue);
    });

    test('does not set disabledByAntiSpam by default', () async {
      final settings = await repository.disableReminders();
      expect(settings.disabledByAntiSpam, isFalse);
    });

    test('persists disabled state to storage', () async {
      await repository.disableReminders();
      final retrieved = repository.getSettings();
      expect(retrieved.isEnabled, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // updateNextReminder
  // ---------------------------------------------------------------------------

  group('updateNextReminder', () {
    test('stores next reminder date', () async {
      final nextDate = DateTime(2025, 7, 1, 9, 0);
      final settings = await repository.updateNextReminder(nextDate);

      expect(settings.nextReminderScheduled, equals(nextDate));
    });

    test('persists next reminder date across reads', () async {
      final nextDate = DateTime(2025, 8, 15, 18, 30);
      await repository.updateNextReminder(nextDate);

      final retrieved = repository.getSettings();
      expect(retrieved.nextReminderScheduled, equals(nextDate));
    });
  });

  // ---------------------------------------------------------------------------
  // recordReminderSent
  // ---------------------------------------------------------------------------

  group('recordReminderSent', () {
    test('stores lastReminderSent and notificationId', () async {
      final sentAt = DateTime(2025, 6, 1, 9, 0);
      final settings = await repository.recordReminderSent(
        sentAt: sentAt,
        notificationId: 42,
      );

      expect(settings.lastReminderSent, equals(sentAt));
      expect(settings.notificationId, equals(42));
    });

    test('persists values across reads', () async {
      final sentAt = DateTime(2025, 6, 15);
      await repository.recordReminderSent(sentAt: sentAt, notificationId: 99);

      final retrieved = repository.getSettings();
      expect(retrieved.lastReminderSent, equals(sentAt));
      expect(retrieved.notificationId, equals(99));
    });
  });

  // ---------------------------------------------------------------------------
  // recordReminderOpened
  // ---------------------------------------------------------------------------

  group('recordReminderOpened', () {
    test('resets consecutiveIgnores to zero', () async {
      await repository.updateSettings(
        (current) => current.copyWith(consecutiveIgnores: 2),
      );

      final settings = await repository.recordReminderOpened();
      expect(settings.consecutiveIgnores, equals(0));
    });

    test('persists reset across reads', () async {
      await repository.updateSettings(
        (current) => current.copyWith(consecutiveIgnores: 3),
      );
      await repository.recordReminderOpened();

      final retrieved = repository.getSettings();
      expect(retrieved.consecutiveIgnores, equals(0));
    });
  });

  // ---------------------------------------------------------------------------
  // recordReminderIgnored
  // ---------------------------------------------------------------------------

  group('recordReminderIgnored', () {
    test('increments consecutiveIgnores by 1', () async {
      await repository.updateSettings(
        (current) => current.copyWith(consecutiveIgnores: 1),
      );

      final settings = await repository.recordReminderIgnored();
      expect(settings.consecutiveIgnores, equals(2));
    });

    test('increments from zero to one', () async {
      final settings = await repository.recordReminderIgnored();
      expect(settings.consecutiveIgnores, equals(1));
    });

    test('auto-disables when consecutiveIgnores reaches maxIgnoresBeforeDisable',
        () async {
      // Set up settings near the limit: maxIgnoresBeforeDisable = 3, currently at 2
      await repository.updateSettings(
        (current) => current.copyWith(
          isEnabled: true,
          consecutiveIgnores: 2,
          maxIgnoresBeforeDisable: 3,
        ),
      );

      final settings = await repository.recordReminderIgnored();

      // Should auto-disable
      expect(settings.isEnabled, isFalse);
      expect(settings.disabledByAntiSpam, isTrue);
    });

    test('does not auto-disable when limit not reached', () async {
      await repository.updateSettings(
        (current) => current.copyWith(
          isEnabled: true,
          consecutiveIgnores: 1,
          maxIgnoresBeforeDisable: 3,
        ),
      );

      final settings = await repository.recordReminderIgnored();

      expect(settings.isEnabled, isTrue);
      expect(settings.disabledByAntiSpam, isFalse);
      expect(settings.consecutiveIgnores, equals(2));
    });

    test('does not auto-disable when maxIgnoresBeforeDisable is 0', () async {
      await repository.updateSettings(
        (current) => current.copyWith(
          isEnabled: true,
          consecutiveIgnores: 100,
          maxIgnoresBeforeDisable: 0,
        ),
      );

      final settings = await repository.recordReminderIgnored();

      // limit is 0 = no limit, so still enabled
      expect(settings.isEnabled, isTrue);
      expect(settings.disabledByAntiSpam, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // getHistory
  // ---------------------------------------------------------------------------

  group('getHistory', () {
    test('returns empty list when no history stored', () {
      final history = repository.getHistory();
      expect(history, isEmpty);
    });

    test('returns empty list when stored JSON is invalid', () async {
      await prefs.setString('photo_reminder_history', 'not json');
      final history = repository.getHistory();
      expect(history, isEmpty);
    });

    test('returns records after addToHistory', () async {
      final record = PhotoReminderRecord(
        id: 'rec-001',
        sentAt: DateTime(2025, 6, 1),
        messageVariation: 0,
      );

      await repository.addToHistory(record);
      final history = repository.getHistory();

      expect(history, hasLength(1));
      expect(history.first.id, equals('rec-001'));
    });
  });

  // ---------------------------------------------------------------------------
  // addToHistory
  // ---------------------------------------------------------------------------

  group('addToHistory', () {
    test('inserts most recent record first', () async {
      final older = PhotoReminderRecord(
        id: 'rec-001',
        sentAt: DateTime(2025, 6, 1),
        messageVariation: 0,
      );
      final newer = PhotoReminderRecord(
        id: 'rec-002',
        sentAt: DateTime(2025, 6, 15),
        messageVariation: 1,
      );

      await repository.addToHistory(older);
      await repository.addToHistory(newer);

      final history = repository.getHistory();
      expect(history.first.id, equals('rec-002'));
      expect(history.last.id, equals('rec-001'));
    });

    test('keeps only the last 50 records', () async {
      for (var i = 0; i < 55; i++) {
        await repository.addToHistory(
          PhotoReminderRecord(
            id: 'rec-$i',
            sentAt: DateTime(2025, 1, 1).add(Duration(days: i)),
            messageVariation: i % 3,
          ),
        );
      }

      final history = repository.getHistory();
      expect(history.length, equals(50));
    });

    test('preserves record fields through storage', () async {
      final sentAt = DateTime(2025, 6, 1, 9, 0);
      final openedAt = DateTime(2025, 6, 1, 10, 0);
      final record = PhotoReminderRecord(
        id: 'rec-full',
        sentAt: sentAt,
        openedAt: openedAt,
        messageVariation: 2,
        wasCanceled: false,
      );

      await repository.addToHistory(record);
      final retrieved = repository.getHistory().first;

      expect(retrieved.id, equals('rec-full'));
      expect(retrieved.sentAt, equals(sentAt));
      expect(retrieved.openedAt, equals(openedAt));
      expect(retrieved.messageVariation, equals(2));
    });

    test('multiple records are all stored and retrievable', () async {
      final records = List.generate(
        5,
        (i) => PhotoReminderRecord(
          id: 'rec-$i',
          sentAt: DateTime(2025, 1, i + 1),
          messageVariation: i,
        ),
      );

      for (final r in records) {
        await repository.addToHistory(r);
      }

      final history = repository.getHistory();
      expect(history, hasLength(5));
      // Most recent first
      expect(history.first.id, equals('rec-4'));
    });
  });

  // ---------------------------------------------------------------------------
  // clearAll
  // ---------------------------------------------------------------------------

  group('clearAll', () {
    test('removes stored settings, returning defaults afterwards', () async {
      await repository.saveSettings(
        const PhotoReminderSettings(isEnabled: true, reminderHour: 18),
      );

      await repository.clearAll();
      final settings = repository.getSettings();

      expect(settings.isEnabled, isFalse);
      expect(settings.reminderHour, equals(9));
    });

    test('clears history', () async {
      await repository.addToHistory(
        PhotoReminderRecord(
          id: 'rec-001',
          sentAt: DateTime(2025, 6, 1),
          messageVariation: 0,
        ),
      );

      await repository.clearAll();
      final history = repository.getHistory();

      expect(history, isEmpty);
    });

    test('clearAll is idempotent - calling twice does not throw', () async {
      await repository.clearAll();
      expect(() async => repository.clearAll(), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // Integration: full workflow
  // ---------------------------------------------------------------------------

  group('full reminder workflow', () {
    test('enable, record sent, record ignored, auto-disable', () async {
      // Enable with limit of 2 ignores
      await repository.saveSettings(
        const PhotoReminderSettings(
          isEnabled: true,
          frequency: PhotoReminderFrequency.monthly,
          maxIgnoresBeforeDisable: 2,
        ),
      );

      // Record a reminder sent
      await repository.recordReminderSent(
        sentAt: DateTime(2025, 6, 1),
        notificationId: 1,
      );

      // First ignore - should not disable
      var settings = await repository.recordReminderIgnored();
      expect(settings.isEnabled, isTrue);
      expect(settings.consecutiveIgnores, equals(1));

      // Second ignore - should auto-disable
      settings = await repository.recordReminderIgnored();
      expect(settings.isEnabled, isFalse);
      expect(settings.disabledByAntiSpam, isTrue);
    });

    test('enable, record opened, ignore counter resets', () async {
      await repository.saveSettings(
        const PhotoReminderSettings(
          isEnabled: true,
          consecutiveIgnores: 2,
          maxIgnoresBeforeDisable: 3,
        ),
      );

      // Opening a reminder resets the counter
      final settings = await repository.recordReminderOpened();
      expect(settings.consecutiveIgnores, equals(0));
    });

    test('re-enabling after anti-spam disable clears flags', () async {
      // Simulate anti-spam disabled state
      await repository.updateSettings(
        (current) => current.copyWith(
          isEnabled: false,
          disabledByAntiSpam: true,
          consecutiveIgnores: 3,
        ),
      );

      // Re-enable should clear anti-spam state
      final settings = await repository.enableReminders();
      expect(settings.isEnabled, isTrue);
      expect(settings.disabledByAntiSpam, isFalse);
      expect(settings.consecutiveIgnores, equals(0));
    });
  });
}
