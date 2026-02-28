import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/weight_update_nudge_provider.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // WeightUpdateNudgeConfig
  // ═══════════════════════════════════════════════════════════════
  group('WeightUpdateNudgeConfig', () {
    test('reminderIntervalDays is 28', () {
      expect(WeightUpdateNudgeConfig.reminderIntervalDays, 28);
    });

    test('dismissalCooldownDays is 7', () {
      expect(WeightUpdateNudgeConfig.dismissalCooldownDays, 7);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // WeightNudgeState Data Class
  // ═══════════════════════════════════════════════════════════════
  group('WeightNudgeState', () {
    test('constructor stores all fields', () {
      final now = DateTime(2026, 2, 28);
      final state = WeightNudgeState(
        shouldShowNudge: true,
        daysSinceLastUpdate: 30,
        lastUpdateDate: now,
        isDismissed: false,
      );

      expect(state.shouldShowNudge, true);
      expect(state.daysSinceLastUpdate, 30);
      expect(state.lastUpdateDate, now);
      expect(state.isDismissed, false);
    });

    test('hidden static constant has correct defaults', () {
      expect(WeightNudgeState.hidden.shouldShowNudge, false);
      expect(WeightNudgeState.hidden.daysSinceLastUpdate, 0);
      expect(WeightNudgeState.hidden.lastUpdateDate, isNull);
      expect(WeightNudgeState.hidden.isDismissed, false);
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        const original = WeightNudgeState(
          shouldShowNudge: false,
          daysSinceLastUpdate: 10,
          lastUpdateDate: null,
          isDismissed: false,
        );

        final newDate = DateTime(2026, 3, 1);
        final copy = original.copyWith(
          shouldShowNudge: true,
          daysSinceLastUpdate: 30,
          lastUpdateDate: newDate,
          isDismissed: true,
        );

        expect(copy.shouldShowNudge, true);
        expect(copy.daysSinceLastUpdate, 30);
        expect(copy.lastUpdateDate, newDate);
        expect(copy.isDismissed, true);
      });

      test('preserves original values when no fields specified', () {
        final date = DateTime(2026, 1, 15);
        final original = WeightNudgeState(
          shouldShowNudge: true,
          daysSinceLastUpdate: 44,
          lastUpdateDate: date,
          isDismissed: true,
        );

        final copy = original.copyWith();

        expect(copy.shouldShowNudge, true);
        expect(copy.daysSinceLastUpdate, 44);
        expect(copy.lastUpdateDate, date);
        expect(copy.isDismissed, true);
      });

      test('updates only shouldShowNudge', () {
        const original = WeightNudgeState(
          shouldShowNudge: true,
          daysSinceLastUpdate: 30,
          lastUpdateDate: null,
          isDismissed: false,
        );

        final copy = original.copyWith(shouldShowNudge: false);

        expect(copy.shouldShowNudge, false);
        expect(copy.daysSinceLastUpdate, 30);
        expect(copy.isDismissed, false);
      });

      test('updates only isDismissed', () {
        const original = WeightNudgeState(
          shouldShowNudge: true,
          daysSinceLastUpdate: 30,
          lastUpdateDate: null,
          isDismissed: false,
        );

        final copy = original.copyWith(isDismissed: true);

        expect(copy.isDismissed, true);
        expect(copy.shouldShowNudge, true);
        expect(copy.daysSinceLastUpdate, 30);
      });

      test('updates only daysSinceLastUpdate', () {
        const original = WeightNudgeState(
          shouldShowNudge: false,
          daysSinceLastUpdate: 5,
          lastUpdateDate: null,
          isDismissed: false,
        );

        final copy = original.copyWith(daysSinceLastUpdate: 50);

        expect(copy.daysSinceLastUpdate, 50);
        expect(copy.shouldShowNudge, false);
      });

      test('does not mutate original', () {
        const original = WeightNudgeState(
          shouldShowNudge: false,
          daysSinceLastUpdate: 10,
          lastUpdateDate: null,
          isDismissed: false,
        );

        original.copyWith(
          shouldShowNudge: true,
          daysSinceLastUpdate: 99,
          isDismissed: true,
        );

        expect(original.shouldShowNudge, false);
        expect(original.daysSinceLastUpdate, 10);
        expect(original.isDismissed, false);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Nudge Logic (unit testable conditions)
  // ═══════════════════════════════════════════════════════════════
  group('Nudge display logic', () {
    test('should show nudge when not dismissed and days >= interval', () {
      const isDismissed = false;
      const daysSinceLastUpdate = 28;

      final shouldShow =
          !isDismissed &&
          daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

      expect(shouldShow, true);
    });

    test('should not show nudge when dismissed recently', () {
      const isDismissed = true;
      const daysSinceLastUpdate = 30;

      final shouldShow =
          !isDismissed &&
          daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

      expect(shouldShow, false);
    });

    test('should not show nudge when days < interval', () {
      const isDismissed = false;
      const daysSinceLastUpdate = 20;

      final shouldShow =
          !isDismissed &&
          daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

      expect(shouldShow, false);
    });

    test('should not show nudge when both dismissed and days < interval', () {
      const isDismissed = true;
      const daysSinceLastUpdate = 10;

      final shouldShow =
          !isDismissed &&
          daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

      expect(shouldShow, false);
    });

    test('exactly at interval boundary shows nudge', () {
      const isDismissed = false;
      const daysSinceLastUpdate = 28;

      final shouldShow =
          !isDismissed &&
          daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

      expect(shouldShow, true);
    });

    test('one day before interval does not show nudge', () {
      const isDismissed = false;
      const daysSinceLastUpdate = 27;

      final shouldShow =
          !isDismissed &&
          daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

      expect(shouldShow, false);
    });

    test('dismissal cooldown logic - within cooldown', () {
      const daysSinceDismissal = 3;
      final isDismissed =
          daysSinceDismissal < WeightUpdateNudgeConfig.dismissalCooldownDays;

      expect(isDismissed, true);
    });

    test('dismissal cooldown logic - after cooldown', () {
      const daysSinceDismissal = 7;
      final isDismissed =
          daysSinceDismissal < WeightUpdateNudgeConfig.dismissalCooldownDays;

      expect(isDismissed, false);
    });

    test('dismissal cooldown logic - exactly at boundary', () {
      const daysSinceDismissal = 7;
      final isDismissed =
          daysSinceDismissal < WeightUpdateNudgeConfig.dismissalCooldownDays;

      expect(isDismissed, false);
    });
  });
}
