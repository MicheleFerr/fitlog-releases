/// ExerciseCardSettings entity tests - enums, JSON round-trip, presets, computed.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart';

void main() {
  group('ExerciseGifSize', () {
    test('has 4 values', () {
      expect(ExerciseGifSize.values.length, 4);
    });

    test('size values', () {
      expect(ExerciseGifSize.small.size, 40);
      expect(ExerciseGifSize.medium.size, 56);
      expect(ExerciseGifSize.large.size, 72);
      expect(ExerciseGifSize.hidden.size, 0);
    });

    test('fromJson valid', () {
      expect(ExerciseGifSize.fromJson('small'), ExerciseGifSize.small);
      expect(ExerciseGifSize.fromJson('large'), ExerciseGifSize.large);
    });

    test('fromJson fallback', () {
      expect(ExerciseGifSize.fromJson('unknown'), ExerciseGifSize.medium);
    });

    test('toJson round-trip', () {
      for (final size in ExerciseGifSize.values) {
        expect(ExerciseGifSize.fromJson(size.toJson()), size);
      }
    });
  });

  group('ExerciseCardDensity', () {
    test('has 3 values', () {
      expect(ExerciseCardDensity.values.length, 3);
    });

    test('padding increases with density', () {
      expect(
        ExerciseCardDensity.compact.verticalPadding,
        lessThan(ExerciseCardDensity.standard.verticalPadding),
      );
      expect(
        ExerciseCardDensity.standard.verticalPadding,
        lessThan(ExerciseCardDensity.extended.verticalPadding),
      );
    });

    test('fromJson valid', () {
      expect(ExerciseCardDensity.fromJson('compact'), ExerciseCardDensity.compact);
    });

    test('fromJson fallback', () {
      expect(ExerciseCardDensity.fromJson('xyz'), ExerciseCardDensity.standard);
    });

    test('toJson round-trip', () {
      for (final d in ExerciseCardDensity.values) {
        expect(ExerciseCardDensity.fromJson(d.toJson()), d);
      }
    });
  });

  group('ExerciseFooterElement', () {
    test('has 3 values', () {
      expect(ExerciseFooterElement.values.length, 3);
    });

    test('fromJson fallback', () {
      expect(ExerciseFooterElement.fromJson('bad'), ExerciseFooterElement.notes);
    });

    test('toJson round-trip', () {
      for (final e in ExerciseFooterElement.values) {
        expect(ExerciseFooterElement.fromJson(e.toJson()), e);
      }
    });
  });

  group('ExerciseCardSettings', () {
    test('default constructor values', () {
      const settings = ExerciseCardSettings();
      expect(settings.gifSize, ExerciseGifSize.medium);
      expect(settings.density, ExerciseCardDensity.standard);
      expect(settings.showInsight, isTrue);
      expect(settings.showTimer, isTrue);
      expect(settings.showPlates, isTrue);
      expect(settings.showRpe, isTrue);
      expect(settings.footerElements.length, 3);
      expect(settings.footerExpanded, isFalse);
    });

    test('showGif computed', () {
      const visible = ExerciseCardSettings(gifSize: ExerciseGifSize.medium);
      expect(visible.showGif, isTrue);

      const hidden = ExerciseCardSettings(gifSize: ExerciseGifSize.hidden);
      expect(hidden.showGif, isFalse);
    });

    test('hasFooter computed', () {
      const withFooter = ExerciseCardSettings();
      expect(withFooter.hasFooter, isTrue);

      const noFooter = ExerciseCardSettings(footerElements: []);
      expect(noFooter.hasFooter, isFalse);
    });

    test('JSON round-trip', () {
      const original = ExerciseCardSettings();
      final json = original.toJson();
      final restored = ExerciseCardSettings.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson with missing fields uses defaults', () {
      final settings = ExerciseCardSettings.fromJson({});
      expect(settings.gifSize, ExerciseGifSize.medium);
      expect(settings.density, ExerciseCardDensity.standard);
      expect(settings.showInsight, isTrue);
    });

    test('copyWith', () {
      const original = ExerciseCardSettings();
      final updated = original.copyWith(
        gifSize: ExerciseGifSize.small,
        showRpe: false,
      );
      expect(updated.gifSize, ExerciseGifSize.small);
      expect(updated.showRpe, isFalse);
      expect(updated.showInsight, isTrue); // unchanged
    });

    test('equality', () {
      const a = ExerciseCardSettings();
      const b = ExerciseCardSettings();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality', () {
      const a = ExerciseCardSettings();
      final b = a.copyWith(showPlates: false);
      expect(a, isNot(equals(b)));
    });
  });

  group('ExerciseCardPresets', () {
    test('defaultSettings matches constructor defaults', () {
      expect(ExerciseCardPresets.defaultSettings, const ExerciseCardSettings());
    });

    test('beginnerSettings hides insight and RPE', () {
      expect(ExerciseCardPresets.beginnerSettings.showInsight, isFalse);
      expect(ExerciseCardPresets.beginnerSettings.showRpe, isFalse);
      expect(ExerciseCardPresets.beginnerSettings.gifSize, ExerciseGifSize.large);
      expect(ExerciseCardPresets.beginnerSettings.footerExpanded, isTrue);
    });

    test('efficientSettings uses compact and hidden GIF', () {
      expect(ExerciseCardPresets.efficientSettings.gifSize, ExerciseGifSize.hidden);
      expect(ExerciseCardPresets.efficientSettings.density, ExerciseCardDensity.compact);
      expect(ExerciseCardPresets.efficientSettings.showPlates, isFalse);
      expect(ExerciseCardPresets.efficientSettings.hasFooter, isFalse);
    });

    test('powerUserSettings shows everything', () {
      expect(ExerciseCardPresets.powerUserSettings.showInsight, isTrue);
      expect(ExerciseCardPresets.powerUserSettings.showRpe, isTrue);
      expect(ExerciseCardPresets.powerUserSettings.showPlates, isTrue);
      expect(ExerciseCardPresets.powerUserSettings.footerElements.length, 3);
    });

    test('minimalSettings hides most', () {
      expect(ExerciseCardPresets.minimalSettings.showInsight, isFalse);
      expect(ExerciseCardPresets.minimalSettings.showRpe, isFalse);
      expect(ExerciseCardPresets.minimalSettings.showPlates, isFalse);
      expect(ExerciseCardPresets.minimalSettings.footerElements.length, 1);
    });
  });
}
