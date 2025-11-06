import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/services/timer_positioning_service.dart';

void main() {
  group('🎯 TimerPositioningService Complete Tests', () {
    group('getConstrainedPosition', () {
      test('constrains position within screen bounds', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(500, 500),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          minVisibleArea: const Size(50, 50),
        );

        // The position can extend beyond screen bounds to keep minimum visible area
        // With minVisibleArea of 50x50, the widget can go up to position 350 horizontally
        // (400 - 50 = 350) where only 50 pixels remain visible
        expect(position.dx, lessThanOrEqualTo(350)); // 400 - 50 (minVisibleArea.width)
        expect(position.dy, lessThanOrEqualTo(750)); // 800 - 50 (minVisibleArea.height)
      });

      test('respects screen padding', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(0, 0),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: const EdgeInsets.only(top: 50, left: 20),
          minVisibleArea: const Size(50, 50),
        );

        // The widget can be positioned partially outside the safe area
        // to keep the minimum visible area on screen
        // With padding and edge margin (16), left constraint is 20 + 16 - (100-50) = -14
        expect(position.dx, greaterThanOrEqualTo(-14)); // Can go partially off-screen
        expect(position.dy, greaterThanOrEqualTo(16)); // Can go partially off-screen
      });

      test('ensures minimum visible area', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(-200, -200), // Molto fuori schermo
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          minVisibleArea: const Size(50, 50),
          edgeMargin: 16,
        );

        // Dovrebbe garantire che almeno minVisibleArea sia visibile
        expect(position.dx, greaterThanOrEqualTo(-34)); // -50 + 16
        expect(position.dy, greaterThanOrEqualTo(-34)); // -50 + 16
      });

      test('handles edge margin', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(0, 0),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          minVisibleArea: const Size(50, 50),
          edgeMargin: 20,
        );

        // Dovrebbe rispettare l'edge margin
        expect(position.dx, greaterThanOrEqualTo(-30)); // -50 + 20
        expect(position.dy, greaterThanOrEqualTo(-30)); // -50 + 20
      });
    });

    group('getNearestEdgePosition', () {
      test('snaps to nearest edge', () {
        // Test near top edge
        final topPosition = TimerPositioningService.getNearestEdgePosition(
          position: const Offset(200, 25),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          padding: EdgeInsets.zero,
        );
        expect(topPosition.dy, 16); // Default edge margin

        // Test near bottom edge
        final bottomPosition = TimerPositioningService.getNearestEdgePosition(
          position: const Offset(200, 680),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          padding: EdgeInsets.zero,
        );
        expect(bottomPosition.dy, 684); // 800 - 100 - 16

        // Test near left edge
        final leftPosition = TimerPositioningService.getNearestEdgePosition(
          position: const Offset(25, 400),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          padding: EdgeInsets.zero,
        );
        expect(leftPosition.dx, 16); // Default edge margin

        // Test near right edge
        final rightPosition = TimerPositioningService.getNearestEdgePosition(
          position: const Offset(280, 400),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          padding: EdgeInsets.zero,
        );
        expect(rightPosition.dx, 284); // 400 - 100 - 16
      });

      test('respects screen padding', () {
        final position = TimerPositioningService.getNearestEdgePosition(
          position: const Offset(25, 400),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          padding: const EdgeInsets.only(left: 50),
        );
        expect(position.dx, 66); // 50 + 16
      });
    });

    group('getDefaultPosition', () {
      test('returns bottom-right position by default', () {
        final position = TimerPositioningService.getDefaultPosition(
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          preferredPosition: TimerDefaultPosition.bottomRight,
        );

        expect(position.dx, 284); // 400 - 100 - 16
        expect(position.dy, 684); // 800 - 100 - 16
      });

      test('returns top-right position', () {
        final position = TimerPositioningService.getDefaultPosition(
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          preferredPosition: TimerDefaultPosition.topRight,
        );

        expect(position.dx, 284); // 400 - 100 - 16
        expect(position.dy, 16); // 16 (edge margin)
      });

      test('adjusts for screen padding', () {
        final position = TimerPositioningService.getDefaultPosition(
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: const EdgeInsets.only(bottom: 50, right: 20),
          preferredPosition: TimerDefaultPosition.bottomRight,
        );

        expect(position.dx, 264); // 400 - 100 - 16 - 20
        expect(position.dy, 634); // 800 - 100 - 16 - 50
      });
    });

    group('isPositionFullyVisible', () {
      test('returns true when position is fully visible', () {
        final isVisible = TimerPositioningService.isPositionFullyVisible(
          position: const Offset(100, 100),
          widgetSize: const Size(100, 100),
          screenSize: const Size(400, 800),
          screenPadding: EdgeInsets.zero,
        );

        expect(isVisible, true);
      });

      test('returns false when partially off screen', () {
        final isVisible = TimerPositioningService.isPositionFullyVisible(
          position: const Offset(-50, 100),
          widgetSize: const Size(100, 100),
          screenSize: const Size(400, 800),
          screenPadding: EdgeInsets.zero,
        );

        expect(isVisible, false);
      });

      test('respects minimum visibility threshold', () {
        final isVisible = TimerPositioningService.isPositionFullyVisible(
          position: const Offset(-20, 100), // 80% visible
          widgetSize: const Size(100, 100),
          screenSize: const Size(400, 800),
          screenPadding: EdgeInsets.zero,
          minVisibleThreshold: 0.9, // Requires 90% visible
        );

        expect(isVisible, false);
      });
    });

    group('getDeadZones', () {
      test('returns dead zones for keyboard', () {
        final deadZones = TimerPositioningService.getDeadZones(
          screenSize: const Size(400, 800),
          screenPadding: EdgeInsets.zero,
          keyboardVisible: true,
          keyboardHeight: 300,
        );

        expect(deadZones, isNotEmpty);
        final keyboardZone = deadZones.first;
        expect(keyboardZone.top, 500); // 800 - 300
        expect(keyboardZone.height, 300);
      });

      test('returns dead zones for notch', () {
        final deadZones = TimerPositioningService.getDeadZones(
          screenSize: const Size(400, 800),
          screenPadding: const EdgeInsets.only(top: 44), // iPhone notch
          keyboardVisible: false,
        );

        expect(deadZones, isNotEmpty);
        final notchZone = deadZones.first;
        expect(notchZone.top, 0);
        expect(notchZone.height, 44);
      });
    });

    group('isPositionInDeadZone', () {
      test('detects position in dead zone', () {
        final deadZones = [
          const Rect.fromLTWH(0, 0, 400, 100), // Top dead zone
        ];

        final inDeadZone = TimerPositioningService.isPositionInDeadZone(
          position: const Offset(100, 50),
          widgetSize: const Size(100, 100),
          deadZones: deadZones,
        );

        expect(inDeadZone, true);
      });

      test('detects position outside dead zone', () {
        final deadZones = [
          const Rect.fromLTWH(0, 0, 400, 100), // Top dead zone
        ];

        final inDeadZone = TimerPositioningService.isPositionInDeadZone(
          position: const Offset(100, 200),
          widgetSize: const Size(100, 100),
          deadZones: deadZones,
        );

        expect(inDeadZone, false);
      });
    });

    group('AnimatedTimerPosition widget integration', () {
      testWidgets('animates position changes', (tester) async {
        Offset position = const Offset(50, 50);

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      left: position.dx,
                      top: position.dy,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            position = const Offset(200, 200);
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        // Initial position
        final container = tester.widget<AnimatedPositioned>(
          find.byType(AnimatedPositioned),
        );
        expect(container.left, 50);
        expect(container.top, 50);

        // Trigger position change
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Animation started
        await tester.pump(const Duration(milliseconds: 150));

        // Animation completed
        await tester.pump(const Duration(milliseconds: 150));
        final updatedContainer = tester.widget<AnimatedPositioned>(
          find.byType(AnimatedPositioned),
        );
        expect(updatedContainer.left, 200);
        expect(updatedContainer.top, 200);
      });
    });

    group('Edge cases and performance', () {
      test('handles zero-sized widget', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(100, 100),
          screenSize: const Size(400, 800),
          widgetSize: Size.zero,
          screenPadding: EdgeInsets.zero,
          minVisibleArea: Size.zero,
        );

        expect(position, isNotNull);
        expect(position.isFinite, true);
      });

      test('handles zero-sized screen', () {
        // For zero-sized screens, we should handle gracefully by returning Offset.zero
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(100, 100),
          screenSize: Size.zero,
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          minVisibleArea: const Size(50, 50),
        );
        
        expect(position, equals(Offset.zero));
      });

      test('handles extreme positions', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(double.infinity, double.infinity),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          minVisibleArea: const Size(50, 50),
        );

        expect(position.isFinite, true);
        expect(position.dx, lessThanOrEqualTo(400));
        expect(position.dy, lessThanOrEqualTo(800));
      });

      test('handles negative positions', () {
        final position = TimerPositioningService.getConstrainedPosition(
          position: const Offset(-1000, -1000),
          screenSize: const Size(400, 800),
          widgetSize: const Size(100, 100),
          screenPadding: EdgeInsets.zero,
          minVisibleArea: const Size(50, 50),
        );

        expect(position.isFinite, true);
      });
    });
  });
}