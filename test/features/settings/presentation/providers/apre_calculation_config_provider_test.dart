import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/apre_calculation_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/onerm_calculation_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('APRECalculationConfigProvider', () {
    late ProviderContainer container;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('default config is topFiveSets', () async {
      // Wait for provider to initialize
      await container.read(apreCalculationConfigProvider.future);

      final config = container.read(apreCalculationConfigProvider).value;

      expect(config, OneRMCalculationConfig.topFiveSets);
    });

    test('setConfig updates state', () async {
      // Wait for provider to initialize
      await container.read(apreCalculationConfigProvider.future);

      final notifier = container.read(apreCalculationConfigProvider.notifier);

      await notifier.setConfig(OneRMCalculationConfig.topThreeSets);

      final config = container.read(apreCalculationConfigProvider).value;
      expect(config, OneRMCalculationConfig.topThreeSets);
    });

    test('config persisted to SharedPreferences', () async {
      // Wait for provider to initialize
      await container.read(apreCalculationConfigProvider.future);

      final notifier = container.read(apreCalculationConfigProvider.notifier);

      await notifier.setConfig(OneRMCalculationConfig.allSetsInWindow);

      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getString('apre_calculation_config');

      expect(savedValue, 'allSetsInWindow');
    });

    test('config loaded from SharedPreferences on init', () async {
      // Setup: save config to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('apre_calculation_config', 'medianOfTop5');

      // Create new container to trigger initialization
      final newContainer = ProviderContainer();
      await newContainer.read(apreCalculationConfigProvider.future);

      final config = newContainer.read(apreCalculationConfigProvider).value;

      expect(config, OneRMCalculationConfig.medianOfTop5);

      newContainer.dispose();
    });

    test('resetToDefault restores topFiveSets', () async {
      // Wait for provider to initialize
      await container.read(apreCalculationConfigProvider.future);

      final notifier = container.read(apreCalculationConfigProvider.notifier);

      // Change config
      await notifier.setConfig(OneRMCalculationConfig.allSetsInWindow);
      expect(
        container.read(apreCalculationConfigProvider).value,
        OneRMCalculationConfig.allSetsInWindow,
      );

      // Reset to default
      await notifier.resetToDefault();

      final config = container.read(apreCalculationConfigProvider).value;
      expect(config, OneRMCalculationConfig.topFiveSets);
    });
  });
}
