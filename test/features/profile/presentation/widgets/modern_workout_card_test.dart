import 'package:flutter_test/flutter_test.dart';

/// Tests for pure logic extracted from ModernWorkoutCard
/// We test the helper methods as pure functions to avoid widget complexity.
void main() {
  // ═══════════════════════════════════════════════════════════════
  // Workout Emoji Logic
  // ═══════════════════════════════════════════════════════════════
  group('getWorkoutEmoji logic', () {
    String getWorkoutEmoji(String workoutName) {
      final nameLower = workoutName.toLowerCase();
      if (nameLower.contains('push') ||
          nameLower.contains('chest') ||
          nameLower.contains('petto')) {
        return '🏋️';
      } else if (nameLower.contains('pull') ||
          nameLower.contains('back') ||
          nameLower.contains('schiena')) {
        return '🔙';
      } else if (nameLower.contains('leg') || nameLower.contains('gamb')) {
        return '🦵';
      } else if (nameLower.contains('arm') || nameLower.contains('bracc')) {
        return '💪';
      } else if (nameLower.contains('shoulder') ||
          nameLower.contains('spall')) {
        return '🤷';
      } else if (nameLower.contains('core') ||
          nameLower.contains('abs') ||
          nameLower.contains('addom')) {
        return '🎯';
      } else if (nameLower.contains('full') || nameLower.contains('total')) {
        return '⚡';
      } else if (nameLower.contains('cardio')) {
        return '🏃';
      }
      return '🏋️';
    }

    test('push → 🏋️', () => expect(getWorkoutEmoji('Push Day'), '🏋️'));
    test('chest → 🏋️', () => expect(getWorkoutEmoji('Chest Press'), '🏋️'));
    test('petto → 🏋️', () => expect(getWorkoutEmoji('Petto'), '🏋️'));
    test('pull → 🔙', () => expect(getWorkoutEmoji('Pull Day'), '🔙'));
    test('back → 🔙', () => expect(getWorkoutEmoji('Back Workout'), '🔙'));
    test('schiena → 🔙', () => expect(getWorkoutEmoji('Schiena'), '🔙'));
    test('leg → 🦵', () => expect(getWorkoutEmoji('Leg Day'), '🦵'));
    test('gamb → 🦵', () => expect(getWorkoutEmoji('Gambe'), '🦵'));
    test('arm → 💪', () => expect(getWorkoutEmoji('Arm Workout'), '💪'));
    test('bracc → 💪', () => expect(getWorkoutEmoji('Braccia'), '💪'));
    test('shoulder → 🤷', () => expect(getWorkoutEmoji('Shoulder Press'), '🤷'));
    test('spall → 🤷', () => expect(getWorkoutEmoji('Spalle'), '🤷'));
    test('core → 🎯', () => expect(getWorkoutEmoji('Core Training'), '🎯'));
    test('abs → 🎯', () => expect(getWorkoutEmoji('Abs Workout'), '🎯'));
    test('addom → 🎯', () => expect(getWorkoutEmoji('Addominali'), '🎯'));
    test('full → ⚡', () => expect(getWorkoutEmoji('Full Body'), '⚡'));
    test('total → ⚡', () => expect(getWorkoutEmoji('Total Body'), '⚡'));
    test('cardio → 🏃', () => expect(getWorkoutEmoji('Cardio Session'), '🏃'));
    test('unknown → 🏋️ default', () => expect(getWorkoutEmoji('Unknown'), '🏋️'));
    test('empty name → 🏋️ default', () => expect(getWorkoutEmoji(''), '🏋️'));
    test('case insensitive PUSH → 🏋️', () => expect(getWorkoutEmoji('PUSH'), '🏋️'));
  });

  // ═══════════════════════════════════════════════════════════════
  // Time Of Day Emoji Logic
  // ═══════════════════════════════════════════════════════════════
  group('getTimeOfDayEmoji logic', () {
    String getTimeOfDayEmoji(int hour) {
      if (hour >= 5 && hour < 12) return '🌅';
      if (hour >= 12 && hour < 17) return '☀️';
      if (hour >= 17 && hour < 21) return '🌆';
      return '🌙';
    }

    test('hour 5 → morning 🌅', () => expect(getTimeOfDayEmoji(5), '🌅'));
    test('hour 11 → morning 🌅', () => expect(getTimeOfDayEmoji(11), '🌅'));
    test('hour 12 → afternoon ☀️', () => expect(getTimeOfDayEmoji(12), '☀️'));
    test('hour 16 → afternoon ☀️', () => expect(getTimeOfDayEmoji(16), '☀️'));
    test('hour 17 → evening 🌆', () => expect(getTimeOfDayEmoji(17), '🌆'));
    test('hour 20 → evening 🌆', () => expect(getTimeOfDayEmoji(20), '🌆'));
    test('hour 21 → night 🌙', () => expect(getTimeOfDayEmoji(21), '🌙'));
    test('hour 0 → night 🌙', () => expect(getTimeOfDayEmoji(0), '🌙'));
    test('hour 4 → night 🌙', () => expect(getTimeOfDayEmoji(4), '🌙'));
    test('hour 23 → night 🌙', () => expect(getTimeOfDayEmoji(23), '🌙'));
  });

  // ═══════════════════════════════════════════════════════════════
  // Intensity Calculation Logic
  // ═══════════════════════════════════════════════════════════════
  group('calculateIntensity logic', () {
    double calculateIntensity({
      required int totalSets,
      required int durationMinutes,
    }) {
      if (durationMinutes == 0) return 0.5;
      final setsPerMinute = totalSets / durationMinutes;
      return (setsPerMinute * 2).clamp(0.0, 1.0);
    }

    test('zero duration returns 0.5', () {
      expect(calculateIntensity(totalSets: 10, durationMinutes: 0), 0.5);
    });

    test('1 set per 2 minutes = 0.5 intensity (average)', () {
      // 10 sets / 20 min = 0.5 sets/min → 0.5 * 2 = 1.0
      expect(calculateIntensity(totalSets: 10, durationMinutes: 20), 1.0);
    });

    test('high intensity: 1 set per minute = 1.0', () {
      expect(calculateIntensity(totalSets: 30, durationMinutes: 30), 1.0);
    });

    test('low intensity: 1 set per 4 minutes = 0.5', () {
      // 5 sets / 20 min = 0.25 sets/min → 0.25 * 2 = 0.5
      expect(calculateIntensity(totalSets: 5, durationMinutes: 20), 0.5);
    });

    test('intensity is clamped to 1.0 max', () {
      // 100 sets in 10 min = 10 sets/min → 20.0, clamped to 1.0
      expect(calculateIntensity(totalSets: 100, durationMinutes: 10), 1.0);
    });

    test('intensity is clamped to 0.0 min', () {
      expect(calculateIntensity(totalSets: 0, durationMinutes: 60), 0.0);
    });

    test('very long workout with few sets = low intensity', () {
      // 3 sets / 90 min = 0.0333 sets/min → 0.0667
      final result = calculateIntensity(totalSets: 3, durationMinutes: 90);
      expect(result, closeTo(0.0667, 0.001));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Intensity Badge Logic
  // ═══════════════════════════════════════════════════════════════
  group('getIntensityBadge logic', () {
    String getIntensityBadge(double intensity) {
      if (intensity > 0.8) return '🔥';
      if (intensity > 0.6) return '⚡';
      return '💪';
    }

    test('intensity > 0.8 → 🔥', () => expect(getIntensityBadge(0.9), '🔥'));
    test('intensity = 1.0 → 🔥', () => expect(getIntensityBadge(1.0), '🔥'));
    test('intensity = 0.81 → 🔥', () => expect(getIntensityBadge(0.81), '🔥'));
    test('intensity = 0.8 → ⚡ (not > 0.8)', () => expect(getIntensityBadge(0.8), '⚡'));
    test('intensity = 0.7 → ⚡', () => expect(getIntensityBadge(0.7), '⚡'));
    test('intensity = 0.61 → ⚡', () => expect(getIntensityBadge(0.61), '⚡'));
    test('intensity = 0.6 → 💪 (not > 0.6)', () => expect(getIntensityBadge(0.6), '💪'));
    test('intensity = 0.5 → 💪', () => expect(getIntensityBadge(0.5), '💪'));
    test('intensity = 0.0 → 💪', () => expect(getIntensityBadge(0.0), '💪'));
  });

  // ═══════════════════════════════════════════════════════════════
  // Exercise Chip Abbreviation Logic
  // ═══════════════════════════════════════════════════════════════
  group('exercise chip display name logic', () {
    String getDisplayName(String name) {
      return name.length > 8 ? '${name.substring(0, 7)}…' : name;
    }

    test('short name preserved', () => expect(getDisplayName('Squat'), 'Squat'));
    test('8 chars preserved', () => expect(getDisplayName('Deadlift'), 'Deadlift'));
    test('9 chars truncated to 7 + ellipsis', () {
      expect(getDisplayName('BenchPress'), 'BenchPr…');
    });
    test('long name truncated', () {
      expect(getDisplayName('Romanian Deadlift'), 'Romania…');
    });
    test('empty string preserved', () => expect(getDisplayName(''), ''));
    test('exactly 8 chars preserved (boundary)', () => expect(getDisplayName('LegPress'), 'LegPress'));
    test('9 chars truncated to 7 + ellipsis variant', () => expect(getDisplayName('PullDown9'), 'PullDow…'));
  });

  // ═══════════════════════════════════════════════════════════════
  // Weekly Progress Bar percentage logic
  // ═══════════════════════════════════════════════════════════════
  group('weekly progress bar percentage logic', () {
    double calculatePercentage(int completed, int total) {
      return total > 0 ? completed / total : 0.0;
    }

    test('0/7 = 0.0', () => expect(calculatePercentage(0, 7), 0.0));
    test('7/7 = 1.0', () => expect(calculatePercentage(7, 7), 1.0));
    test('3/7 ≈ 0.428', () => expect(calculatePercentage(3, 7), closeTo(3 / 7, 0.001)));
    test('zero total returns 0.0', () => expect(calculatePercentage(5, 0), 0.0));
    test('1/7 ≈ 0.142', () => expect(calculatePercentage(1, 7), closeTo(1 / 7, 0.001)));
  });
}
