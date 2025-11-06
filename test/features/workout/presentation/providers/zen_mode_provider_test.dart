import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/zen_mode_provider.dart';

void main() {
  group('ZenConfig', () {
    test('should create with default values', () {
      const config = ZenConfig();

      expect(config.hideCommunitySuggestions, isTrue);
      expect(config.hideWarmupCards, isTrue);
      expect(config.hideExerciseChips, isFalse); // False by default
      expect(config.hideXPAnimations, isTrue);
      expect(config.hideTutorials, isTrue);
      expect(config.hideSmartSuggestions, isTrue);
      expect(config.keepScreenOn, isTrue);
      expect(config.showTUT, isFalse);
      expect(config.showVelocity, isFalse);
      expect(config.showVolume, isTrue);
    });

    test('should create with custom values', () {
      const config = ZenConfig(
        hideCommunitySuggestions: false,
        hideWarmupCards: false,
        hideExerciseChips: true,
        hideXPAnimations: false,
        hideTutorials: false,
        hideSmartSuggestions: false,
        keepScreenOn: false,
        showTUT: true,
        showVelocity: true,
        showVolume: false,
      );

      expect(config.hideCommunitySuggestions, isFalse);
      expect(config.hideWarmupCards, isFalse);
      expect(config.hideExerciseChips, isTrue);
      expect(config.hideXPAnimations, isFalse);
      expect(config.hideTutorials, isFalse);
      expect(config.hideSmartSuggestions, isFalse);
      expect(config.keepScreenOn, isFalse);
      expect(config.showTUT, isTrue);
      expect(config.showVelocity, isTrue);
      expect(config.showVolume, isFalse);
    });

    test('copyWith should update specific fields', () {
      const original = ZenConfig();

      final updated = original.copyWith(
        hideCommunitySuggestions: false,
        showTUT: true,
      );

      expect(updated.hideCommunitySuggestions, isFalse);
      expect(updated.showTUT, isTrue);
      // Other fields unchanged
      expect(updated.hideWarmupCards, isTrue);
      expect(updated.hideXPAnimations, isTrue);
    });

    test('fromJson should create config from map with all fields', () {
      final json = {
        'hideCommunitySuggestions': false,
        'hideWarmupCards': false,
        'hideExerciseChips': true,
        'hideXPAnimations': false,
        'hideTutorials': false,
        'hideSmartSuggestions': false,
        'keepScreenOn': false,
        'showTUT': true,
        'showVelocity': true,
        'showVolume': false,
      };

      final config = ZenConfig.fromJson(json);

      expect(config.hideCommunitySuggestions, isFalse);
      expect(config.hideWarmupCards, isFalse);
      expect(config.hideExerciseChips, isTrue);
      expect(config.hideXPAnimations, isFalse);
      expect(config.hideTutorials, isFalse);
      expect(config.hideSmartSuggestions, isFalse);
      expect(config.keepScreenOn, isFalse);
      expect(config.showTUT, isTrue);
      expect(config.showVelocity, isTrue);
      expect(config.showVolume, isFalse);
    });

    test('fromJson should use default values for missing fields', () {
      final json = <String, dynamic>{};

      final config = ZenConfig.fromJson(json);

      // Should use constructor defaults
      expect(config.hideCommunitySuggestions, isTrue);
      expect(config.hideWarmupCards, isTrue);
      expect(config.hideExerciseChips, isFalse);
      expect(config.hideXPAnimations, isTrue);
      expect(config.hideTutorials, isTrue);
      expect(config.hideSmartSuggestions, isTrue);
      expect(config.keepScreenOn, isTrue);
      expect(config.showTUT, isFalse);
      expect(config.showVelocity, isFalse);
      expect(config.showVolume, isTrue);
    });

    test('toJson should convert to map with all fields', () {
      const config = ZenConfig(
        hideCommunitySuggestions: false,
        showTUT: true,
        showVolume: false,
      );

      final json = config.toJson();

      expect(json['hideCommunitySuggestions'], isFalse);
      expect(json['hideWarmupCards'], isTrue); // default
      expect(json['hideExerciseChips'], isFalse); // default
      expect(json['hideXPAnimations'], isTrue); // default
      expect(json['hideTutorials'], isTrue); // default
      expect(json['hideSmartSuggestions'], isTrue); // default
      expect(json['keepScreenOn'], isTrue); // default
      expect(json['showTUT'], isTrue);
      expect(json['showVelocity'], isFalse); // default
      expect(json['showVolume'], isFalse);
    });

    test('toJson/fromJson should be symmetric', () {
      const original = ZenConfig(
        hideCommunitySuggestions: false,
        hideWarmupCards: false,
        hideExerciseChips: true,
        showTUT: true,
        showVelocity: true,
        showVolume: false,
      );

      final json = original.toJson();
      final restored = ZenConfig.fromJson(json);

      expect(restored.hideCommunitySuggestions, equals(original.hideCommunitySuggestions));
      expect(restored.hideWarmupCards, equals(original.hideWarmupCards));
      expect(restored.hideExerciseChips, equals(original.hideExerciseChips));
      expect(restored.hideXPAnimations, equals(original.hideXPAnimations));
      expect(restored.hideTutorials, equals(original.hideTutorials));
      expect(restored.hideSmartSuggestions, equals(original.hideSmartSuggestions));
      expect(restored.keepScreenOn, equals(original.keepScreenOn));
      expect(restored.showTUT, equals(original.showTUT));
      expect(restored.showVelocity, equals(original.showVelocity));
      expect(restored.showVolume, equals(original.showVolume));
    });
  });
}
