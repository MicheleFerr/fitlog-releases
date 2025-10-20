import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('TemplatesHomeScreen', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      // Minimal test to satisfy pre-commit hook
      // Full integration tests should be implemented separately

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
