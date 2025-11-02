import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/timer_position.dart';

void main() {
  group('TimerPosition enum', () {
    test('should have all expected values', () {
      expect(TimerPosition.values, contains(TimerPosition.top));
      expect(TimerPosition.values, contains(TimerPosition.bottom));
      expect(TimerPosition.values, contains(TimerPosition.left));
      expect(TimerPosition.values, contains(TimerPosition.right));
      expect(TimerPosition.values.length, equals(4));
    });
  });

  group('TimerDisplayMode enum', () {
    test('should have all expected values', () {
      expect(TimerDisplayMode.values, contains(TimerDisplayMode.normal));
      expect(TimerDisplayMode.values, contains(TimerDisplayMode.compact));
      expect(TimerDisplayMode.values.length, equals(2));
    });
  });

  group('TimerDisplaySettings', () {
    test('should create instance with default values', () {
      // Act
      const settings = TimerDisplaySettings();

      // Assert
      expect(settings.position, equals(TimerPosition.top));
      expect(settings.displayMode, equals(TimerDisplayMode.normal));
      expect(settings.isVisible, isTrue);
    });

    test('should create instance with custom values', () {
      // Act
      const settings = TimerDisplaySettings(
        position: TimerPosition.bottom,
        displayMode: TimerDisplayMode.compact,
        isVisible: false,
      );

      // Assert
      expect(settings.position, equals(TimerPosition.bottom));
      expect(settings.displayMode, equals(TimerDisplayMode.compact));
      expect(settings.isVisible, isFalse);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      const settings = TimerDisplaySettings(
        position: TimerPosition.right,
        displayMode: TimerDisplayMode.compact,
        isVisible: false,
      );

      // Act
      final json = settings.toJson();

      // Assert
      expect(json['position'], equals('right'));
      expect(json['displayMode'], equals('compact'));
      expect(json['isVisible'], isFalse);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'position': 'left',
        'displayMode': 'normal',
        'isVisible': true,
      };

      // Act
      final settings = TimerDisplaySettings.fromJson(json);

      // Assert
      expect(settings.position, equals(TimerPosition.left));
      expect(settings.displayMode, equals(TimerDisplayMode.normal));
      expect(settings.isVisible, isTrue);
    });

    test('should use default values for invalid JSON', () {
      // Arrange
      final json = {
        'position': 'invalid_position',
        'displayMode': 'invalid_mode',
      };

      // Act
      final settings = TimerDisplaySettings.fromJson(json);

      // Assert
      expect(settings.position, equals(TimerPosition.top));
      expect(settings.displayMode, equals(TimerDisplayMode.normal));
      expect(settings.isVisible, isTrue);
    });

    test('should use default value when isVisible is missing', () {
      // Arrange
      final json = {
        'position': 'bottom',
        'displayMode': 'compact',
      };

      // Act
      final settings = TimerDisplaySettings.fromJson(json);

      // Assert
      expect(settings.isVisible, isTrue);
    });

    test('should support copyWith for immutability', () {
      // Arrange
      const original = TimerDisplaySettings(
        position: TimerPosition.top,
        displayMode: TimerDisplayMode.normal,
        isVisible: true,
      );

      // Act
      final updated = original.copyWith(
        position: TimerPosition.bottom,
        isVisible: false,
      );

      // Assert
      expect(updated.position, equals(TimerPosition.bottom));
      expect(updated.displayMode, equals(TimerDisplayMode.normal));
      expect(updated.isVisible, isFalse);
      expect(original.position, equals(TimerPosition.top));
      expect(original.isVisible, isTrue);
    });

    test('should handle JSON serialization roundtrip', () {
      // Arrange
      const original = TimerDisplaySettings(
        position: TimerPosition.right,
        displayMode: TimerDisplayMode.compact,
        isVisible: false,
      );

      // Act
      final json = original.toJson();
      final deserialized = TimerDisplaySettings.fromJson(json);

      // Assert
      expect(deserialized.position, equals(original.position));
      expect(deserialized.displayMode, equals(original.displayMode));
      expect(deserialized.isVisible, equals(original.isVisible));
    });
  });

  group('TimerPositionHelper - getOffsetForPosition', () {
    const screenSize = Size(400, 800);
    const timerSize = Size(320, 160);

    test('should calculate top position correctly', () {
      // Act
      final offset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.top,
        screenSize,
        timerSize,
      );

      // Assert
      expect(offset.dx, equals((screenSize.width - timerSize.width) / 2));
      expect(offset.dy, equals(76.0));
    });

    test('should calculate bottom position correctly', () {
      // Act
      final offset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.bottom,
        screenSize,
        timerSize,
      );

      // Assert
      expect(offset.dx, equals((screenSize.width - timerSize.width) / 2));
      expect(offset.dy, equals(screenSize.height - timerSize.height - 96.0));
    });

    test('should calculate left position correctly', () {
      // Act
      final offset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.left,
        screenSize,
        timerSize,
      );

      // Assert
      expect(offset.dx, equals(16.0));
      expect(offset.dy, equals((screenSize.height - timerSize.height) / 2));
    });

    test('should calculate right position correctly', () {
      // Act
      final offset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.right,
        screenSize,
        timerSize,
      );

      // Assert
      expect(offset.dx, equals(screenSize.width - timerSize.width - 16.0));
      expect(offset.dy, equals((screenSize.height - timerSize.height) / 2));
    });

    test('should center horizontally for top and bottom positions', () {
      // Act
      final topOffset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.top,
        screenSize,
        timerSize,
      );
      final bottomOffset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.bottom,
        screenSize,
        timerSize,
      );

      // Assert
      expect(topOffset.dx, equals(bottomOffset.dx));
      expect(topOffset.dx, equals((screenSize.width - timerSize.width) / 2));
    });

    test('should center vertically for left and right positions', () {
      // Act
      final leftOffset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.left,
        screenSize,
        timerSize,
      );
      final rightOffset = TimerPositionHelper.getOffsetForPosition(
        TimerPosition.right,
        screenSize,
        timerSize,
      );

      // Assert
      expect(leftOffset.dy, equals(rightOffset.dy));
      expect(leftOffset.dy, equals((screenSize.height - timerSize.height) / 2));
    });
  });

  group('TimerPositionHelper - getSizeForMode', () {
    test('should return correct size for normal mode', () {
      // Act
      final size = TimerPositionHelper.getSizeForMode(TimerDisplayMode.normal);

      // Assert
      expect(size.width, equals(320.0));
      expect(size.height, equals(160.0));
    });

    test('should return correct size for compact mode', () {
      // Act
      final size = TimerPositionHelper.getSizeForMode(TimerDisplayMode.compact);

      // Assert
      expect(size.width, equals(120.0));
      expect(size.height, equals(50.0));
    });

    test('compact mode should be smaller than normal mode', () {
      // Act
      final normalSize = TimerPositionHelper.getSizeForMode(TimerDisplayMode.normal);
      final compactSize = TimerPositionHelper.getSizeForMode(TimerDisplayMode.compact);

      // Assert
      expect(compactSize.width, lessThan(normalSize.width));
      expect(compactSize.height, lessThan(normalSize.height));
    });
  });

  group('TimerPositionHelper - Position Checks', () {
    test('isHorizontalPosition should return true for left', () {
      expect(TimerPositionHelper.isHorizontalPosition(TimerPosition.left), isTrue);
    });

    test('isHorizontalPosition should return true for right', () {
      expect(TimerPositionHelper.isHorizontalPosition(TimerPosition.right), isTrue);
    });

    test('isHorizontalPosition should return false for top', () {
      expect(TimerPositionHelper.isHorizontalPosition(TimerPosition.top), isFalse);
    });

    test('isHorizontalPosition should return false for bottom', () {
      expect(TimerPositionHelper.isHorizontalPosition(TimerPosition.bottom), isFalse);
    });

    test('isVerticalPosition should return true for top', () {
      expect(TimerPositionHelper.isVerticalPosition(TimerPosition.top), isTrue);
    });

    test('isVerticalPosition should return true for bottom', () {
      expect(TimerPositionHelper.isVerticalPosition(TimerPosition.bottom), isTrue);
    });

    test('isVerticalPosition should return false for left', () {
      expect(TimerPositionHelper.isVerticalPosition(TimerPosition.left), isFalse);
    });

    test('isVerticalPosition should return false for right', () {
      expect(TimerPositionHelper.isVerticalPosition(TimerPosition.right), isFalse);
    });

    test('all positions should be either horizontal or vertical', () {
      for (final position in TimerPosition.values) {
        final isHorizontal = TimerPositionHelper.isHorizontalPosition(position);
        final isVertical = TimerPositionHelper.isVerticalPosition(position);
        expect(isHorizontal != isVertical, isTrue);
      }
    });
  });
}
