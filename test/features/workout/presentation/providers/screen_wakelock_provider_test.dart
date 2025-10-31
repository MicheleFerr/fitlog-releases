import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/screen_wakelock_provider.dart';

void main() {
  group('ScreenWakelockState', () {
    test('should create with both fields', () {
      const state = ScreenWakelockState(
        isEnabled: true,
        isActive: false,
      );

      expect(state.isEnabled, isTrue);
      expect(state.isActive, isFalse);
    });

    test('copyWith should update isEnabled only', () {
      const original = ScreenWakelockState(
        isEnabled: false,
        isActive: false,
      );

      final updated = original.copyWith(isEnabled: true);

      expect(updated.isEnabled, isTrue);
      expect(updated.isActive, isFalse);
    });

    test('copyWith should update isActive only', () {
      const original = ScreenWakelockState(
        isEnabled: true,
        isActive: false,
      );

      final updated = original.copyWith(isActive: true);

      expect(updated.isEnabled, isTrue);
      expect(updated.isActive, isTrue);
    });

    test('copyWith should update both fields', () {
      const original = ScreenWakelockState(
        isEnabled: false,
        isActive: false,
      );

      final updated = original.copyWith(
        isEnabled: true,
        isActive: true,
      );

      expect(updated.isEnabled, isTrue);
      expect(updated.isActive, isTrue);
    });

    test('copyWith should return new instance with unchanged values when no params', () {
      const original = ScreenWakelockState(
        isEnabled: true,
        isActive: true,
      );

      final updated = original.copyWith();

      expect(updated.isEnabled, equals(original.isEnabled));
      expect(updated.isActive, equals(original.isActive));
    });
  });
}
