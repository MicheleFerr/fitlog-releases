/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/notifications/domain/entities
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: unit_test
///
/// NOTIFICATION SETTINGS V2.0 ENTITY TESTS
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/quiet_hours.dart';

void main() {
  group('NotificationSettings v2.0', () {
    test('defaults() creates correct v2.0 defaults', () {
      final settings = NotificationSettings.defaults();

      // v1.0 defaults
      expect(settings.enableWorkoutReminders, true);
      expect(settings.enableRecoveryAlerts, true);
      expect(settings.enableStreakMotivation, false);
      expect(settings.enableSmartScheduling, true);
      expect(settings.reminderMinutesBefore, 60);

      // v2.0 defaults
      expect(settings.settingsVersion, 2);
      expect(settings.frequencyCapPreferences?.maxPerDay, 3);
      expect(settings.frequencyCapPreferences?.maxPerWeek, 5);
      expect(settings.frequencyCapPreferences?.minIntervalHours, 2);
      expect(settings.enableAnalytics, false);
      expect(settings.dataRetentionDays, 90);
    });

    test('hasValidConsent returns correct status', () {
      final withConsent = NotificationSettings.defaults().copyWith(
        consentTimestamp: DateTime.now(),
      );
      expect(withConsent.hasValidConsent, true);

      final withoutConsent = NotificationSettings.defaults().copyWith(
        consentTimestamp: null,
      );
      expect(withoutConsent.hasValidConsent, false);
    });

    test('canCollectAnalytics requires consent AND enableAnalytics', () {
      final consentOnly = NotificationSettings.defaults().copyWith(
        consentTimestamp: DateTime.now(),
        enableAnalytics: false,
      );
      expect(consentOnly.canCollectAnalytics, false);

      final analyticsOnly = NotificationSettings.defaults().copyWith(
        consentTimestamp: null,
        enableAnalytics: true,
      );
      expect(analyticsOnly.canCollectAnalytics, false);

      final both = NotificationSettings.defaults().copyWith(
        consentTimestamp: DateTime.now(),
        enableAnalytics: true,
      );
      expect(both.canCollectAnalytics, true);
    });

    test('needsMigration returns correct status', () {
      final v1 = NotificationSettings.defaults().copyWith(settingsVersion: 1);
      expect(v1.needsMigration, true);

      final v2 = NotificationSettings.defaults().copyWith(settingsVersion: 2);
      expect(v2.needsMigration, false);
    });

    test('getDataRetentionCutoffDate calculates correct cutoff', () {
      final settings = NotificationSettings.defaults().copyWith(
        dataRetentionDays: 90,
      );

      final cutoff = settings.getDataRetentionCutoffDate();
      final expected = DateTime.now().subtract(const Duration(days: 90));

      expect(cutoff.day, expected.day);
      expect(cutoff.month, expected.month);
      expect(cutoff.year, expected.year);
    });
  });

  group('FrequencyCap', () {
    test('defaults match research-backed values', () {
      const cap = FrequencyCap();

      expect(cap.maxPerDay, 3);
      expect(cap.maxPerWeek, 5); // Research: >5 → 64% quit risk
      expect(cap.minIntervalHours, 2);
    });

    test('presets provide correct configurations', () {
      final conservative = FrequencyCap.conservative();
      expect(conservative.maxPerDay, 2);
      expect(conservative.maxPerWeek, 3);

      final balanced = FrequencyCap.balanced();
      expect(balanced.maxPerDay, 3);
      expect(balanced.maxPerWeek, 5);

      final aggressive = FrequencyCap.aggressive();
      expect(aggressive.maxPerDay, 5);
      expect(aggressive.maxPerWeek, 10);
    });

    test('exceedsResearchLimit detects dangerous frequency', () {
      const safe = FrequencyCap(maxPerWeek: 5);
      expect(safe.exceedsResearchLimit, false);

      const dangerous = FrequencyCap(maxPerWeek: 6);
      expect(dangerous.exceedsResearchLimit, true);
    });
  });

  group('QuietHours', () {
    test('isTimeInWindow correctly identifies time in window', () {
      final overnight = QuietHours.overnight();

      final midnight = DateTime(2025, 1, 1, 0, 0);
      expect(overnight.isTimeInWindow(midnight), true);

      final morning = DateTime(2025, 1, 1, 10, 0);
      expect(overnight.isTimeInWindow(morning), false);
    });

    test('presets create correct windows', () {
      final overnight = QuietHours.overnight();
      expect(overnight.startTime.hour, 22);
      expect(overnight.endTime.hour, 8);

      final workHours = QuietHours.workHours();
      expect(workHours.startTime.hour, 9);
      expect(workHours.endTime.hour, 17);
    });
  });
}
