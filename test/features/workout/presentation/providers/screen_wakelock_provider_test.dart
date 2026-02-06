import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/screen_wakelock_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';

void main() {
  group('ScreenWakelockProvider', () {
    test('initial state should be false (wakelock not active)', () {
      final container = ProviderContainer(
        overrides: [
          // Override appConfigProvider to avoid Hive initialization
          appConfigProvider.overrideWith(
            () => _TestAppConfigNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final isActive = container.read(screenWakelockProvider);

      expect(isActive, isFalse);
    });

    test('provider should exist and be accessible', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWith(
            () => _TestAppConfigNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Should not throw
      expect(
        () => container.read(screenWakelockProvider.notifier),
        returnsNormally,
      );
    });
  });
}

/// Test notifier that provides a default AppConfig without Hive
class _TestAppConfigNotifier extends AppConfigNotifier {
  @override
  AppConfig build() {
    return const AppConfig(keepScreenAwakeDuringWorkout: true);
  }
}
