import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/widgets/auth_visual_scaffold.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// ─── Helper ─────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    ),
    home: child,
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('AuthHeroAssets', () {
    test('login constant is valid path', () {
      expect(AuthHeroAssets.login, isA<String>());
      expect(AuthHeroAssets.login, contains('auth_login_hero'));
    });

    test('register constant is valid path', () {
      expect(AuthHeroAssets.register, isA<String>());
      expect(AuthHeroAssets.register, contains('auth_register_hero'));
    });

    test('brandLogo constant is valid path', () {
      expect(AuthHeroAssets.brandLogo, isA<String>());
      expect(AuthHeroAssets.brandLogo, contains('splash_no_bkg'));
    });

    test('fallback constant is valid path', () {
      expect(AuthHeroAssets.fallback, isA<String>());
      expect(AuthHeroAssets.fallback, contains('splash_logo'));
    });

    test('loginVariants has 2 variants', () {
      expect(AuthHeroAssets.loginVariants, hasLength(2));
    });

    test('registerVariants has 2 variants', () {
      expect(AuthHeroAssets.registerVariants, hasLength(2));
    });

    test('randomLoginVariant returns a value from loginVariants', () {
      final result = AuthHeroAssets.randomLoginVariant();
      expect(AuthHeroAssets.loginVariants, contains(result));
    });

    test('randomLoginVariant uses provided Random', () {
      // With a fixed seed, results are deterministic
      final rng = Random(42);
      final result1 = AuthHeroAssets.randomLoginVariant(rng);
      expect(AuthHeroAssets.loginVariants, contains(result1));
    });

    test('randomRegisterVariant returns a value from registerVariants', () {
      final result = AuthHeroAssets.randomRegisterVariant();
      expect(AuthHeroAssets.registerVariants, contains(result));
    });

    test('randomLoginVariant returns both variants over many calls', () {
      final results = <String>{};
      for (var i = 0; i < 50; i++) {
        results.add(AuthHeroAssets.randomLoginVariant());
      }
      // With 50 random calls, we should see both variants
      expect(results.length, 2);
    });
  });

  group('AuthVisualScaffold', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Test Title',
            subtitle: 'Test Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const Text('Content'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'My Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const Text('Content'),
          ),
        ),
      );

      expect(find.text('My Subtitle'), findsOneWidget);
    });

    testWidgets('renders content widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const Text('Custom Content Widget'),
          ),
        ),
      );

      expect(find.text('Custom Content Widget'), findsOneWidget);
    });

    testWidgets('shows GymBro branding text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('GymBro'), findsOneWidget);
    });

    testWidgets('shows back button when onBackPressed is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const SizedBox.shrink(),
            onBackPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('hides back button when onBackPressed is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    });

    testWidgets('back button triggers onBackPressed callback', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const SizedBox.shrink(),
            onBackPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      expect(pressed, isTrue);
    });

    testWidgets('uses Scaffold as root', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const SizedBox.shrink(),
          ),
        ),
      );

      // AuthVisualScaffold wraps in a Scaffold
      expect(find.byType(Scaffold), findsAtLeast(1));
    });

    testWidgets('renders with gradient background', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AuthVisualScaffold(
            title: 'Title',
            subtitle: 'Subtitle',
            heroAssetPath: AuthHeroAssets.fallback,
            content: const SizedBox.shrink(),
          ),
        ),
      );

      // The DecoratedBox with gradient should be present
      expect(find.byType(DecoratedBox), findsAtLeast(1));
    });
  });
}
