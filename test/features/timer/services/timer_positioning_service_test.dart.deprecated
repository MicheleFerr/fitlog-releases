import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/services/timer_positioning_service.dart';

void main() {
  group('TimerPositioningService', () {
    const screenSize = Size(375, 812); // iPhone 12 Pro size
    const widgetSize = Size(280, 120); // Normal timer size
    const screenPadding = EdgeInsets.only(top: 44, bottom: 34); // iPhone safe areas
    const minVisibleArea = Size(48, 48); // Standard tap target
    
    group('getConstrainedPosition', () {
      test('should keep position within screen bounds', () {
        // Test position that would go outside screen
        const position = Offset(400, 900); // Outside screen
        
        final result = TimerPositioningService.getConstrainedPosition(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
          minVisibleArea: minVisibleArea,
        );
        
        // Should be constrained within screen
        expect(result.dx, lessThanOrEqualTo(screenSize.width));
        expect(result.dy, lessThanOrEqualTo(screenSize.height));
        expect(result.dx, greaterThanOrEqualTo(0));
        expect(result.dy, greaterThanOrEqualTo(0));
      });
      
      test('should maintain minimum visible area', () {
        // Test position that would hide most of widget
        const position = Offset(-250, 50); // Most of widget off-screen left
        
        final result = TimerPositioningService.getConstrainedPosition(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
          minVisibleArea: minVisibleArea,
        );
        
        // Should ensure minimum visible area remains on screen
        final visibleWidth = screenSize.width - result.dx;
        expect(visibleWidth, greaterThanOrEqualTo(minVisibleArea.width));
      });
      
      test('should respect safe area insets', () {
        const position = Offset(50, 10); // Would overlap with status bar
        
        final result = TimerPositioningService.getConstrainedPosition(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
          minVisibleArea: minVisibleArea,
        );
        
        // Should be below safe area
        expect(result.dy, greaterThanOrEqualTo(screenPadding.top));
      });
    });
    
    group('isNearScreenEdge', () {
      test('should detect proximity to left edge', () {
        const position = Offset(30, 200); // Close to left edge
        
        final result = TimerPositioningService.isNearScreenEdge(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          threshold: 50.0,
        );
        
        expect(result, isTrue);
      });
      
      test('should detect proximity to right edge', () {
        const position = Offset(150, 200); // Close to right edge for 280px widget
        
        final result = TimerPositioningService.isNearScreenEdge(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          threshold: 50.0,
        );
        
        expect(result, isTrue);
      });
      
      test('should not detect when far from edges', () {
        const position = Offset(100, 200); // Center of screen
        
        final result = TimerPositioningService.isNearScreenEdge(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          threshold: 30.0,
        );
        
        expect(result, isFalse);
      });
    });
    
    group('getNearestEdgePosition', () {
      test('should snap to left edge when closer', () {
        const position = Offset(30, 200);
        const edgeMargin = 16.0;
        
        final result = TimerPositioningService.getNearestEdgePosition(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          padding: screenPadding,
          edgeMargin: edgeMargin,
        );
        
        // Should snap to left edge with margin
        expect(result.dx, equals(screenPadding.left + edgeMargin));
        expect(result.dy, equals(position.dy)); // Y should remain same
      });
      
      test('should snap to right edge when closer', () {
        const position = Offset(200, 200);
        const edgeMargin = 16.0;
        
        final result = TimerPositioningService.getNearestEdgePosition(
          position: position,
          screenSize: screenSize,
          widgetSize: widgetSize,
          padding: screenPadding,
          edgeMargin: edgeMargin,
        );
        
        // Should snap to right edge with margin
        final expectedX = screenSize.width - widgetSize.width - screenPadding.right - edgeMargin;
        expect(result.dx, equals(expectedX));
      });
    });
    
    group('isPositionFullyVisible', () {
      test('should return true for fully visible position', () {
        const position = Offset(50, 100);
        
        final result = TimerPositioningService.isPositionFullyVisible(
          position: position,
          widgetSize: widgetSize,
          screenSize: screenSize,
          screenPadding: screenPadding,
          minVisibleThreshold: 0.8,
        );
        
        expect(result, isTrue);
      });
      
      test('should return false for mostly hidden position', () {
        const position = Offset(-200, 100); // Mostly off-screen
        
        final result = TimerPositioningService.isPositionFullyVisible(
          position: position,
          widgetSize: widgetSize,
          screenSize: screenSize,
          screenPadding: screenPadding,
          minVisibleThreshold: 0.8,
        );
        
        expect(result, isFalse);
      });
      
      test('should respect visibility threshold', () {
        const position = Offset(-100, 100); // Partially hidden
        
        // With high threshold (80%), should be false
        final resultHigh = TimerPositioningService.isPositionFullyVisible(
          position: position,
          widgetSize: widgetSize,
          screenSize: screenSize,
          screenPadding: screenPadding,
          minVisibleThreshold: 0.8,
        );
        
        // With low threshold (30%), should be true
        final resultLow = TimerPositioningService.isPositionFullyVisible(
          position: position,
          widgetSize: widgetSize,
          screenSize: screenSize,
          screenPadding: screenPadding,
          minVisibleThreshold: 0.3,
        );
        
        expect(resultHigh, isFalse);
        expect(resultLow, isTrue);
      });
    });
    
    group('getSafeCenterPosition', () {
      test('should return centered position within safe area', () {
        final result = TimerPositioningService.getSafeCenterPosition(
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
        );
        
        // Should be centered horizontally
        final expectedX = screenPadding.left + 
            (screenSize.width - screenPadding.horizontal - widgetSize.width) / 2;
        expect(result.dx, closeTo(expectedX, 0.1));
        
        // Should be centered vertically
        final expectedY = screenPadding.top + 
            (screenSize.height - screenPadding.vertical - widgetSize.height) / 2;
        expect(result.dy, closeTo(expectedY, 0.1));
      });
    });
    
    group('getDefaultPosition', () {
      test('should return top-right position by default', () {
        final result = TimerPositioningService.getDefaultPosition(
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
        );
        
        // Should be in top-right corner with margin
        const margin = 16.0;
        final expectedX = screenSize.width - widgetSize.width - screenPadding.right - margin;
        final expectedY = screenPadding.top + margin;
        
        expect(result.dx, equals(expectedX));
        expect(result.dy, equals(expectedY));
      });
      
      test('should respect preferred position', () {
        final result = TimerPositioningService.getDefaultPosition(
          screenSize: screenSize,
          widgetSize: widgetSize,
          screenPadding: screenPadding,
          preferredPosition: TimerDefaultPosition.bottomLeft,
        );
        
        // Should be in bottom-left corner
        const margin = 16.0;
        final expectedX = screenPadding.left + margin;
        final expectedY = screenSize.height - widgetSize.height - screenPadding.bottom - margin;
        
        expect(result.dx, equals(expectedX));
        expect(result.dy, equals(expectedY));
      });
    });
    
    group('getDeadZones', () {
      test('should include keyboard dead zone when visible', () {
        const keyboardHeight = 300.0;
        
        final deadZones = TimerPositioningService.getDeadZones(
          screenSize: screenSize,
          screenPadding: screenPadding,
          keyboardVisible: true,
          keyboardHeight: keyboardHeight,
        );
        
        expect(deadZones, isNotEmpty);
        
        // Should contain keyboard area
        final keyboardZone = deadZones.firstWhere(
          (zone) => zone.height == keyboardHeight,
        );
        expect(keyboardZone.top, equals(screenSize.height - keyboardHeight));
      });
      
      test('should include notch dead zone for devices with notch', () {
        const notchPadding = EdgeInsets.only(top: 44, bottom: 34); // iPhone X+ style
        
        final deadZones = TimerPositioningService.getDeadZones(
          screenSize: screenSize,
          screenPadding: notchPadding,
        );
        
        // Should include notch area
        expect(deadZones, isNotEmpty);
        final notchZone = deadZones.firstWhere(
          (zone) => zone.top == 0,
        );
        expect(notchZone.height, equals(notchPadding.top));
      });
    });
    
    group('isPositionInDeadZone', () {
      test('should detect overlap with dead zones', () {
        const position = Offset(50, 700); // Near bottom where keyboard might be
        const keyboardZone = Rect.fromLTWH(0, 650, 375, 162); // Keyboard area
        
        final result = TimerPositioningService.isPositionInDeadZone(
          position: position,
          widgetSize: widgetSize,
          deadZones: [keyboardZone],
        );
        
        expect(result, isTrue);
      });
      
      test('should not detect overlap when clear of dead zones', () {
        const position = Offset(50, 200); // Safe middle area
        const keyboardZone = Rect.fromLTWH(0, 650, 375, 162); // Keyboard area
        
        final result = TimerPositioningService.isPositionInDeadZone(
          position: position,
          widgetSize: widgetSize,
          deadZones: [keyboardZone],
        );
        
        expect(result, isFalse);
      });
    });
  });
}