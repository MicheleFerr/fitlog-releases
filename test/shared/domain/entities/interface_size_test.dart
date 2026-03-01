/// InterfaceSize entity tests - enum values, fromFontSize, fromJson, toJson.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/interface_size.dart';

void main() {
  group('InterfaceSize', () {
    test('has 5 values', () {
      expect(InterfaceSize.values.length, 5);
    });

    test('fontSize values', () {
      expect(InterfaceSize.extraSmall.fontSize, 0.8);
      expect(InterfaceSize.small.fontSize, 0.9);
      expect(InterfaceSize.medium.fontSize, 1.0);
      expect(InterfaceSize.mediumLarge.fontSize, 1.05);
      expect(InterfaceSize.large.fontSize, 1.1);
    });

    test('setRowMode', () {
      expect(InterfaceSize.extraSmall.setRowMode, 'compact');
      expect(InterfaceSize.small.setRowMode, 'compact');
      expect(InterfaceSize.medium.setRowMode, 'comfortable');
      expect(InterfaceSize.mediumLarge.setRowMode, 'comfortable');
      expect(InterfaceSize.large.setRowMode, 'comfortable');
    });

    test('fromFontSize', () {
      expect(InterfaceSize.fromFontSize(0.8), InterfaceSize.extraSmall);
      expect(InterfaceSize.fromFontSize(0.85), InterfaceSize.extraSmall);
      expect(InterfaceSize.fromFontSize(0.9), InterfaceSize.small);
      expect(InterfaceSize.fromFontSize(0.95), InterfaceSize.small);
      expect(InterfaceSize.fromFontSize(1.0), InterfaceSize.medium);
      expect(InterfaceSize.fromFontSize(1.025), InterfaceSize.medium);
      expect(InterfaceSize.fromFontSize(1.05), InterfaceSize.mediumLarge);
      expect(InterfaceSize.fromFontSize(1.075), InterfaceSize.mediumLarge);
      expect(InterfaceSize.fromFontSize(1.1), InterfaceSize.large);
      expect(InterfaceSize.fromFontSize(1.5), InterfaceSize.large);
    });

    test('fromJson valid', () {
      expect(InterfaceSize.fromJson('extraSmall'), InterfaceSize.extraSmall);
      expect(InterfaceSize.fromJson('medium'), InterfaceSize.medium);
      expect(InterfaceSize.fromJson('large'), InterfaceSize.large);
    });

    test('fromJson fallback', () {
      expect(InterfaceSize.fromJson('unknown'), InterfaceSize.medium);
    });

    test('toJson round-trip', () {
      for (final size in InterfaceSize.values) {
        expect(InterfaceSize.fromJson(size.toJson()), size);
      }
    });
  });
}
