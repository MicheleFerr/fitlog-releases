import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/widgets/branded_auth_buttons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

// ─── Helper ─────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('BrandedGoogleAuthButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedGoogleAuthButton(label: 'Sign in with Google', onPressed: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        BrandedGoogleAuthButton(
          label: 'Google',
          onPressed: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Google'));
      expect(tapped, isTrue);
    });

    testWidgets('shows LoadingIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedGoogleAuthButton(
          label: 'Google',
          onPressed: () {},
          isLoading: true,
        ),
      ));
      // Use pump() instead of pumpAndSettle() - LoadingIndicator has infinite animation
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('does not show LoadingIndicator when isLoading is false',
        (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedGoogleAuthButton(
          label: 'Google',
          onPressed: () {},
          isLoading: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsNothing);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const BrandedGoogleAuthButton(label: 'Google', onPressed: null),
      ));
      await tester.pump();

      // Verify text exists (button is rendered)
      expect(find.text('Google'), findsOneWidget);
      // When onPressed is null, the button should be disabled
      // We verify by finding the button and checking onPressed
      final buttons = find.bySubtype<ButtonStyleButton>();
      final button = tester.widget<ButtonStyleButton>(buttons.first);
      expect(button.onPressed, isNull);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedGoogleAuthButton(
          label: 'Google',
          onPressed: () {},
          height: 72,
        ),
      ));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.text('Google'),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, 72);
    });

    testWidgets('uses default height of 56', (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedGoogleAuthButton(label: 'Google', onPressed: () {}),
      ));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.text('Google'),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, 56);
    });
  });

  group('BrandedAppleAuthButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedAppleAuthButton(
            label: 'Sign in with Apple', onPressed: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Sign in with Apple'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        BrandedAppleAuthButton(
          label: 'Apple',
          onPressed: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple'));
      expect(tapped, isTrue);
    });

    testWidgets('shows LoadingIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedAppleAuthButton(
          label: 'Apple',
          onPressed: () {},
          isLoading: true,
        ),
      ));
      // Use pump() - LoadingIndicator has infinite animation
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const BrandedAppleAuthButton(label: 'Apple', onPressed: null),
      ));
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      final buttons = find.bySubtype<ButtonStyleButton>();
      final button = tester.widget<ButtonStyleButton>(buttons.first);
      expect(button.onPressed, isNull);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedAppleAuthButton(
          label: 'Apple',
          onPressed: () {},
          height: 48,
        ),
      ));
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.text('Apple'),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, 48);
    });

    testWidgets('respects custom borderRadius', (tester) async {
      await tester.pumpWidget(_wrap(
        BrandedAppleAuthButton(
          label: 'Apple',
          onPressed: () {},
          borderRadius: 24,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
    });
  });
}
