/// Shared domain entities tests - WeightIncrement, FeedbackSettings,
/// WeightSettings, PlateOption, AppThemeMode, PRType.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_theme_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_increment.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';

void main() {
  group('WeightIncrement', () {
    test('isValid for positive values <= 50', () {
      expect(const WeightIncrement(2.5).isValid, isTrue);
      expect(const WeightIncrement(0).isValid, isFalse);
      expect(const WeightIncrement(-1).isValid, isFalse);
      expect(const WeightIncrement(50).isValid, isTrue);
      expect(const WeightIncrement(51).isValid, isFalse);
    });

    test('isFractional for values < 1', () {
      expect(const WeightIncrement(0.5).isFractional, isTrue);
      expect(const WeightIncrement(1.0).isFractional, isFalse);
    });

    test('isMicroloading for values < 2.5', () {
      expect(const WeightIncrement(1.25).isMicroloading, isTrue);
      expect(const WeightIncrement(2.5).isMicroloading, isFalse);
    });

    test('format integer', () {
      expect(const WeightIncrement(5.0).format('kg'), '5kg');
    });

    test('format decimal', () {
      expect(const WeightIncrement(1.25).format('kg'), '1.25kg');
    });

    test('equality', () {
      expect(
        const WeightIncrement(2.5),
        equals(WeightIncrement.kg_2_5),
      );
      expect(
        const WeightIncrement(2.5),
        isNot(equals(const WeightIncrement(5.0))),
      );
    });

    test('standard increments lists', () {
      expect(WeightIncrement.standardKgIncrements.length, 6);
      expect(WeightIncrement.standardLbsIncrements.length, 5);
    });
  });

  group('FeedbackSettings', () {
    test('defaults factory', () {
      final settings = FeedbackSettings.defaults();
      expect(settings.hapticEnabled, isTrue);
      expect(settings.hapticIntensity, HapticIntensity.light);
    });

    test('copyWith', () {
      final settings = FeedbackSettings.defaults();
      final updated = settings.copyWith(
        hapticEnabled: false,
        hapticIntensity: HapticIntensity.heavy,
      );
      expect(updated.hapticEnabled, isFalse);
      expect(updated.hapticIntensity, HapticIntensity.heavy);
    });

    test('equality', () {
      final a = FeedbackSettings.defaults();
      final b = FeedbackSettings.defaults();
      expect(a, equals(b));
    });
  });

  group('HapticIntensity', () {
    test('has 3 values', () {
      expect(HapticIntensity.values.length, 3);
    });
  });

  group('PlateOption', () {
    test('stores weight and count', () {
      const plate = PlateOption(weight: 25.0, count: 8);
      expect(plate.weight, 25.0);
      expect(plate.count, 8);
    });

    test('copyWith', () {
      const plate = PlateOption(weight: 25.0, count: 8);
      final updated = plate.copyWith(count: 4);
      expect(updated.weight, 25.0);
      expect(updated.count, 4);
    });

    test('standard kg plates has 8 entries', () {
      expect(PlateOption.standardKgPlates.length, 8);
    });

    test('standard lbs plates has 7 entries', () {
      expect(PlateOption.standardLbsPlates.length, 7);
    });

    test('equality', () {
      const a = PlateOption(weight: 10.0, count: 6);
      const b = PlateOption(weight: 10.0, count: 6);
      expect(a, equals(b));
    });
  });

  group('WeightSettings', () {
    test('defaultKg factory', () {
      final settings = WeightSettings.defaultKg();
      expect(settings.defaultIncrement, WeightIncrement.kg_2_5);
      expect(settings.useCustomIncrement, isFalse);
      expect(settings.availablePlates.length, 8);
    });

    test('defaultLbs factory', () {
      final settings = WeightSettings.defaultLbs();
      expect(settings.defaultIncrement, WeightIncrement.lbs_5_0);
      expect(settings.useCustomIncrement, isFalse);
      expect(settings.availablePlates.length, 7);
    });

    test('activeIncrement returns default when not custom', () {
      final settings = WeightSettings.defaultKg();
      expect(settings.activeIncrement, WeightIncrement.kg_2_5);
    });

    test('activeIncrement returns custom when enabled', () {
      final settings = WeightSettings.defaultKg().copyWith(
        useCustomIncrement: true,
        customIncrement: const WeightIncrement(1.25),
      );
      expect(settings.activeIncrement, const WeightIncrement(1.25));
    });

    test('copyWith', () {
      final settings = WeightSettings.defaultKg();
      final updated = settings.copyWith(useCustomIncrement: true);
      expect(updated.useCustomIncrement, isTrue);
      expect(updated.defaultIncrement, settings.defaultIncrement);
    });

    test('equality', () {
      final a = WeightSettings.defaultKg();
      final b = WeightSettings.defaultKg();
      expect(a, equals(b));
    });
  });

  group('AppThemeMode', () {
    test('has 6 values', () {
      expect(AppThemeMode.values.length, 6);
    });

    test('flutterThemeMode', () {
      expect(AppThemeMode.system.flutterThemeMode, ThemeMode.system);
      expect(AppThemeMode.light.flutterThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.flutterThemeMode, ThemeMode.dark);
      expect(AppThemeMode.ultraDark.flutterThemeMode, ThemeMode.dark);
      expect(AppThemeMode.pink.flutterThemeMode, ThemeMode.light);
      expect(AppThemeMode.darkPink.flutterThemeMode, ThemeMode.dark);
    });

    test('isDark', () {
      expect(AppThemeMode.dark.isDark, isTrue);
      expect(AppThemeMode.ultraDark.isDark, isTrue);
      expect(AppThemeMode.darkPink.isDark, isTrue);
      expect(AppThemeMode.light.isDark, isFalse);
      expect(AppThemeMode.system.isDark, isFalse);
      expect(AppThemeMode.pink.isDark, isFalse);
    });

    test('isCustomTheme', () {
      expect(AppThemeMode.ultraDark.isCustomTheme, isTrue);
      expect(AppThemeMode.pink.isCustomTheme, isTrue);
      expect(AppThemeMode.darkPink.isCustomTheme, isTrue);
      expect(AppThemeMode.system.isCustomTheme, isFalse);
      expect(AppThemeMode.light.isCustomTheme, isFalse);
      expect(AppThemeMode.dark.isCustomTheme, isFalse);
    });

    test('fromString', () {
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString('ultraDark'), AppThemeMode.ultraDark);
      expect(AppThemeMode.fromString('pink'), AppThemeMode.pink);
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
      expect(AppThemeMode.fromString('invalid'), AppThemeMode.system);
    });

    test('fromThemeMode', () {
      expect(AppThemeMode.fromThemeMode(ThemeMode.system), AppThemeMode.system);
      expect(AppThemeMode.fromThemeMode(ThemeMode.light), AppThemeMode.light);
      expect(AppThemeMode.fromThemeMode(ThemeMode.dark), AppThemeMode.dark);
    });
  });

  group('PRType', () {
    test('has 6 values', () {
      expect(PRType.values.length, 6);
    });

    test('all values exist', () {
      expect(PRType.values, contains(PRType.weight));
      expect(PRType.values, contains(PRType.volume));
      expect(PRType.values, contains(PRType.reps));
      expect(PRType.values, contains(PRType.duration));
      expect(PRType.values, contains(PRType.oneRM));
      expect(PRType.values, contains(PRType.totalSets));
    });
  });
}
