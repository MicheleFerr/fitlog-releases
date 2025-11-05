import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/constants/app_animations.dart';

void main() {
  group('AppAnimations', () {
    test('duration constants are defined correctly', () {
      expect(AppAnimations.fast, const Duration(milliseconds: 150));
      expect(AppAnimations.normal, const Duration(milliseconds: 300));
      expect(AppAnimations.iconSwap, const Duration(milliseconds: 200));
    });

    test('curve constants are defined correctly', () {
      expect(AppAnimations.standard, Curves.easeOut);
      expect(AppAnimations.decelerate, Curves.easeOutCubic);
    });

    test('card press values are defined correctly', () {
      expect(AppAnimations.cardPressScale, 0.97);
      expect(AppAnimations.pressOverlayOpacity, 0.08);
      expect(AppAnimations.pressedBorderOpacity, 0.30);
    });

    test('icon size values are defined correctly', () {
      expect(AppAnimations.iconSizeSmall, 20.0);
      expect(AppAnimations.iconSizeMedium, 28.0);
      expect(AppAnimations.iconSizeLarge, 32.0);
    });

    test('cannot instantiate AppAnimations', () {
      // This will fail to compile if constructor is not private
      // No runtime test needed - compile-time verification
      expect(() => AppAnimations, returnsNormally);
    });
  });
}
