import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_theme_mode.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // AppConfig.locale getter
  // ═══════════════════════════════════════════════════════════════
  group('AppConfig.locale', () {
    test('default locale is en_US', () {
      const config = AppConfig();
      expect(config.locale.languageCode, 'en');
      expect(config.locale.countryCode, 'US');
    });

    test('italian locale it_IT', () {
      const config = AppConfig(languageCode: 'it', countryCode: 'IT');
      expect(config.locale.languageCode, 'it');
      expect(config.locale.countryCode, 'IT');
    });

    test('locale reflects copyWith language change', () {
      const original = AppConfig();
      final updated = original.copyWith(languageCode: 'fr', countryCode: 'FR');
      expect(updated.locale.languageCode, 'fr');
      expect(updated.locale.countryCode, 'FR');
    });

    test('locale does not change original after copyWith', () {
      const original = AppConfig();
      original.copyWith(languageCode: 'de', countryCode: 'DE');
      expect(original.locale.languageCode, 'en');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // AppConfig.appThemeMode computed property
  // ═══════════════════════════════════════════════════════════════
  group('AppConfig.appThemeMode', () {
    test('returns system when appThemeModeValue is null and themeMode is system', () {
      const config = AppConfig(themeMode: ThemeMode.system);
      expect(config.appThemeMode, AppThemeMode.system);
    });

    test('returns light when appThemeModeValue is null and themeMode is light', () {
      const config = AppConfig(themeMode: ThemeMode.light);
      expect(config.appThemeMode, AppThemeMode.light);
    });

    test('returns dark when appThemeModeValue is null and themeMode is dark', () {
      const config = AppConfig(themeMode: ThemeMode.dark);
      expect(config.appThemeMode, AppThemeMode.dark);
    });

    test('returns ultraDark when appThemeModeValue is ultraDark', () {
      const config = AppConfig(appThemeModeValue: 'ultraDark');
      expect(config.appThemeMode, AppThemeMode.ultraDark);
    });

    test('returns pink when appThemeModeValue is pink', () {
      const config = AppConfig(appThemeModeValue: 'pink');
      expect(config.appThemeMode, AppThemeMode.pink);
    });

    test('returns darkPink when appThemeModeValue is darkPink', () {
      const config = AppConfig(appThemeModeValue: 'darkPink');
      expect(config.appThemeMode, AppThemeMode.darkPink);
    });

    test('appThemeModeValue overrides themeMode when both set', () {
      const config = AppConfig(
        themeMode: ThemeMode.light,
        appThemeModeValue: 'ultraDark',
      );
      expect(config.appThemeMode, AppThemeMode.ultraDark);
    });

    test('unknown appThemeModeValue falls back to system', () {
      const config = AppConfig(appThemeModeValue: 'unknownValue');
      expect(config.appThemeMode, AppThemeMode.system);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // AppConfig.fromJson – edge cases and defaults
  // ═══════════════════════════════════════════════════════════════
  group('AppConfig.fromJson', () {
    test('unknown themeMode string falls back to system', () {
      final config = AppConfig.fromJson({'themeMode': 'invalidMode'});
      expect(config.themeMode, ThemeMode.system);
    });

    test('themeMode "light" parsed correctly', () {
      final config = AppConfig.fromJson({'themeMode': 'light'});
      expect(config.themeMode, ThemeMode.light);
    });

    test('themeMode "dark" parsed correctly', () {
      final config = AppConfig.fromJson({'themeMode': 'dark'});
      expect(config.themeMode, ThemeMode.dark);
    });

    test('missing keys use defaults', () {
      final config = AppConfig.fromJson({});
      expect(config.languageCode, 'en');
      expect(config.countryCode, 'US');
      expect(config.measurementUnit, 'kg');
      expect(config.soundEnabled, true);
      expect(config.vibrationsEnabled, true);
      expect(config.defaultRestTime, 90);
      expect(config.autoStartTimer, true);
      expect(config.effortScale, 'rpe');
      expect(config.simpleMode, false);
      expect(config.keepScreenAwakeDuringWorkout, true);
      expect(config.defaultExerciseSets, 4);
      expect(config.defaultExerciseReps, 8);
      expect(config.metronomeEnabled, false);
    });

    test('appThemeModeValue null when not in json', () {
      final config = AppConfig.fromJson({});
      expect(config.appThemeModeValue, isNull);
    });

    test('appThemeModeValue stored from json', () {
      final config = AppConfig.fromJson({'appThemeModeValue': 'pink'});
      expect(config.appThemeModeValue, 'pink');
    });

    test('defaultWeightedPresets uses default when missing', () {
      final config = AppConfig.fromJson({});
      expect(config.defaultWeightedPresets, '3x10,4x8,5x5');
    });

    test('defaultWeightedPresets parsed from json', () {
      final config = AppConfig.fromJson({'defaultWeightedPresets': '5x5,3x8'});
      expect(config.defaultWeightedPresets, '5x5,3x8');
    });

    test('initialOnboardingCompleted defaults to false', () {
      final config = AppConfig.fromJson({});
      expect(config.initialOnboardingCompleted, false);
    });

    test('skipExerciseDeleteConfirmation defaults to false', () {
      final config = AppConfig.fromJson({});
      expect(config.skipExerciseDeleteConfirmation, false);
    });

    test('full round-trip: toJson then fromJson preserves values', () {
      const original = AppConfig(
        languageCode: 'it',
        countryCode: 'IT',
        themeMode: ThemeMode.dark,
        measurementUnit: 'lbs',
        soundEnabled: false,
        defaultRestTime: 120,
        effortScale: 'rir',
        simpleMode: true,
        keepScreenAwakeDuringWorkout: false,
        defaultExerciseSets: 5,
        defaultExerciseReps: 5,
        metronomeEnabled: true,
        appThemeModeValue: 'ultraDark',
      );
      final json = original.toJson();
      final restored = AppConfig.fromJson(json);

      expect(restored.languageCode, 'it');
      expect(restored.countryCode, 'IT');
      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.measurementUnit, 'lbs');
      expect(restored.soundEnabled, false);
      expect(restored.defaultRestTime, 120);
      expect(restored.effortScale, 'rir');
      expect(restored.simpleMode, true);
      expect(restored.keepScreenAwakeDuringWorkout, false);
      expect(restored.defaultExerciseSets, 5);
      expect(restored.defaultExerciseReps, 5);
      expect(restored.metronomeEnabled, true);
      expect(restored.appThemeModeValue, 'ultraDark');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // AppConfig.toJson – field presence
  // ═══════════════════════════════════════════════════════════════
  group('AppConfig.toJson', () {
    test('themeMode serialized as name string', () {
      const config = AppConfig(themeMode: ThemeMode.dark);
      expect(config.toJson()['themeMode'], 'dark');
    });

    test('effortScale included', () {
      const config = AppConfig(effortScale: 'rir');
      expect(config.toJson()['effortScale'], 'rir');
    });

    test('metronomeEnabled included', () {
      const config = AppConfig(metronomeEnabled: true);
      expect(config.toJson()['metronomeEnabled'], true);
    });

    test('appThemeModeValue null when not set', () {
      const config = AppConfig();
      expect(config.toJson()['appThemeModeValue'], isNull);
    });

    test('appThemeModeValue included when set', () {
      const config = AppConfig(appThemeModeValue: 'pink');
      expect(config.toJson()['appThemeModeValue'], 'pink');
    });

    test('interfaceSize null when not set', () {
      const config = AppConfig();
      expect(config.toJson()['interfaceSize'], isNull);
    });

    test('preset strings serialized correctly', () {
      const config = AppConfig(
        defaultWeightedPresets: '5x5,3x12',
        defaultRepsPresets: '3x20,4x15',
        defaultTimePresets: '3x45,4x30',
      );
      final json = config.toJson();
      expect(json['defaultWeightedPresets'], '5x5,3x12');
      expect(json['defaultRepsPresets'], '3x20,4x15');
      expect(json['defaultTimePresets'], '3x45,4x30');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // AppConfig.copyWith – fields not covered by existing tests
  // ═══════════════════════════════════════════════════════════════
  group('AppConfig.copyWith – additional fields', () {
    test('effortScale updated', () {
      const config = AppConfig(effortScale: 'rpe');
      final updated = config.copyWith(effortScale: 'rir');
      expect(updated.effortScale, 'rir');
      expect(config.effortScale, 'rpe'); // original unchanged
    });

    test('simpleMode toggled', () {
      const config = AppConfig(simpleMode: false);
      final updated = config.copyWith(simpleMode: true);
      expect(updated.simpleMode, true);
    });

    test('keepScreenAwakeDuringWorkout toggled', () {
      const config = AppConfig(keepScreenAwakeDuringWorkout: true);
      final updated = config.copyWith(keepScreenAwakeDuringWorkout: false);
      expect(updated.keepScreenAwakeDuringWorkout, false);
    });

    test('defaultExerciseSets updated', () {
      const config = AppConfig(defaultExerciseSets: 4);
      final updated = config.copyWith(defaultExerciseSets: 5);
      expect(updated.defaultExerciseSets, 5);
    });

    test('defaultExerciseReps updated', () {
      const config = AppConfig(defaultExerciseReps: 8);
      final updated = config.copyWith(defaultExerciseReps: 12);
      expect(updated.defaultExerciseReps, 12);
    });

    test('metronomeEnabled toggled', () {
      const config = AppConfig(metronomeEnabled: false);
      final updated = config.copyWith(metronomeEnabled: true);
      expect(updated.metronomeEnabled, true);
    });

    test('appThemeModeValue updated', () {
      const config = AppConfig();
      final updated = config.copyWith(appThemeModeValue: 'ultraDark');
      expect(updated.appThemeModeValue, 'ultraDark');
    });

    test('strengthRestTime updated', () {
      const config = AppConfig(strengthRestTime: 180);
      final updated = config.copyWith(strengthRestTime: 240);
      expect(updated.strengthRestTime, 240);
    });

    test('hypertrophyRestTime updated', () {
      const config = AppConfig(hypertrophyRestTime: 90);
      final updated = config.copyWith(hypertrophyRestTime: 60);
      expect(updated.hypertrophyRestTime, 60);
    });

    test('skipExerciseDeleteConfirmation updated', () {
      const config = AppConfig(skipExerciseDeleteConfirmation: false);
      final updated = config.copyWith(skipExerciseDeleteConfirmation: true);
      expect(updated.skipExerciseDeleteConfirmation, true);
    });

    test('initialOnboardingCompleted updated', () {
      const config = AppConfig(initialOnboardingCompleted: false);
      final updated = config.copyWith(initialOnboardingCompleted: true);
      expect(updated.initialOnboardingCompleted, true);
    });

    test('defaultWeightedPresets updated', () {
      const config = AppConfig(defaultWeightedPresets: '3x10,4x8,5x5');
      final updated = config.copyWith(defaultWeightedPresets: '5x5,3x3');
      expect(updated.defaultWeightedPresets, '5x5,3x3');
    });

    test('no-arg copyWith preserves all changed fields', () {
      const config = AppConfig(
        effortScale: 'rir',
        simpleMode: true,
        metronomeEnabled: true,
        defaultExerciseSets: 5,
      );
      final copy = config.copyWith();
      expect(copy.effortScale, 'rir');
      expect(copy.simpleMode, true);
      expect(copy.metronomeEnabled, true);
      expect(copy.defaultExerciseSets, 5);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // AppConfigPresets – predefined configurations
  // ═══════════════════════════════════════════════════════════════
  group('AppConfigPresets', () {
    test('defaultConfig has en_US with kg', () {
      expect(AppConfigPresets.defaultConfig.languageCode, 'en');
      expect(AppConfigPresets.defaultConfig.countryCode, 'US');
      expect(AppConfigPresets.defaultConfig.measurementUnit, 'kg');
    });

    test('italianConfig has it_IT with kg and 120s rest', () {
      expect(AppConfigPresets.italianConfig.languageCode, 'it');
      expect(AppConfigPresets.italianConfig.countryCode, 'IT');
      expect(AppConfigPresets.italianConfig.measurementUnit, 'kg');
      expect(AppConfigPresets.italianConfig.defaultRestTime, 120);
    });

    test('americanConfig has en_US with lbs', () {
      expect(AppConfigPresets.americanConfig.languageCode, 'en');
      expect(AppConfigPresets.americanConfig.countryCode, 'US');
      expect(AppConfigPresets.americanConfig.measurementUnit, 'lbs');
    });

    test('powerlifterConfig has 180s rest and autoStartTimer false', () {
      expect(AppConfigPresets.powerlifterConfig.defaultRestTime, 180);
      expect(AppConfigPresets.powerlifterConfig.autoStartTimer, false);
    });

    test('bodybuilderConfig has 75s rest and intensity techniques', () {
      expect(AppConfigPresets.bodybuilderConfig.defaultRestTime, 75);
      expect(AppConfigPresets.bodybuilderConfig.showIntensityTechniques, true);
      expect(AppConfigPresets.bodybuilderConfig.autoStartTimer, true);
    });

    test('simpleModeConfig has simpleMode = true', () {
      expect(AppConfigPresets.simpleModeConfig.simpleMode, true);
    });

    test('simpleModeConfig has rpeTracking = false', () {
      expect(AppConfigPresets.simpleModeConfig.rpeTracking, false);
    });

    test('simpleModeConfig has simplifiedAnimations = true', () {
      expect(AppConfigPresets.simpleModeConfig.simplifiedAnimations, true);
    });

    test('simpleModeConfig has showIntensityTechniques = false', () {
      expect(AppConfigPresets.simpleModeConfig.showIntensityTechniques, false);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // AppThemeMode helpers
  // ═══════════════════════════════════════════════════════════════
  group('AppThemeMode', () {
    test('ultraDark isDark = true', () {
      expect(AppThemeMode.ultraDark.isDark, true);
    });

    test('pink isDark = false', () {
      expect(AppThemeMode.pink.isDark, false);
    });

    test('darkPink isDark = true', () {
      expect(AppThemeMode.darkPink.isDark, true);
    });

    test('ultraDark isCustomTheme = true', () {
      expect(AppThemeMode.ultraDark.isCustomTheme, true);
    });

    test('system isCustomTheme = false', () {
      expect(AppThemeMode.system.isCustomTheme, false);
    });

    test('flutterThemeMode: pink → ThemeMode.light', () {
      expect(AppThemeMode.pink.flutterThemeMode, ThemeMode.light);
    });

    test('flutterThemeMode: ultraDark → ThemeMode.dark', () {
      expect(AppThemeMode.ultraDark.flutterThemeMode, ThemeMode.dark);
    });

    test('flutterThemeMode: darkPink → ThemeMode.dark', () {
      expect(AppThemeMode.darkPink.flutterThemeMode, ThemeMode.dark);
    });

    test('fromString null returns system', () {
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
    });

    test('fromString unknown returns system', () {
      expect(AppThemeMode.fromString('bogus'), AppThemeMode.system);
    });

    test('fromString "pink" returns pink', () {
      expect(AppThemeMode.fromString('pink'), AppThemeMode.pink);
    });

    test('fromThemeMode system → system', () {
      expect(AppThemeMode.fromThemeMode(ThemeMode.system), AppThemeMode.system);
    });

    test('fromThemeMode light → light', () {
      expect(AppThemeMode.fromThemeMode(ThemeMode.light), AppThemeMode.light);
    });

    test('fromThemeMode dark → dark', () {
      expect(AppThemeMode.fromThemeMode(ThemeMode.dark), AppThemeMode.dark);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Preset strings parsing logic (pure)
  // ═══════════════════════════════════════════════════════════════
  group('Preset strings parsing logic', () {
    List<String> parsePresets(String csv) =>
        csv.split(',').map((s) => s.trim()).toList();

    test('default weighted presets parse to 3 entries', () {
      const config = AppConfig();
      final presets = parsePresets(config.defaultWeightedPresets);
      expect(presets.length, 3);
      expect(presets, ['3x10', '4x8', '5x5']);
    });

    test('default reps presets parse to 3 entries', () {
      const config = AppConfig();
      final presets = parsePresets(config.defaultRepsPresets);
      expect(presets.length, 3);
      expect(presets, ['3x15', '4x12', '2x20']);
    });

    test('default time presets parse to 3 entries', () {
      const config = AppConfig();
      final presets = parsePresets(config.defaultTimePresets);
      expect(presets.length, 3);
      expect(presets, ['3x30', '3x60', '4x45']);
    });

    test('custom preset CSV with 2 entries parses correctly', () {
      final presets = parsePresets('5x5,3x3');
      expect(presets.length, 2);
      expect(presets.first, '5x5');
      expect(presets.last, '3x3');
    });
  });
}
