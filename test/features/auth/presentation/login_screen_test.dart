import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/login_screen.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

// ─── Fake Auth Controller ───────────────────────────────────────────────────

class _FakeAuthController extends AuthController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle({bool forceAccountSelection = false}) async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {}

  @override
  Future<bool> deleteAccount() async => true;
}

// ─── Helper ─────────────────────────────────────────────────────────────────

Widget _buildTestableLoginScreen() {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(_FakeAuthController.new),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: 'login',
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            builder: (_, __) => const Scaffold(body: Text('Register')),
          ),
        ],
      ),
    ),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // GoRouter creates GoRouterDelegate that is not disposed in tests
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();

  group('LoginScreen', () {
    group('initial view (bottom actions)', () {
      testWidgets('renders app title', (tester) async {
        await tester.pumpWidget(_buildTestableLoginScreen());
        await tester.pumpAndSettle();

        // App title "FitLog Pro"
        expect(find.text('FitLog Pro'), findsOneWidget);
      });

      testWidgets('renders Google sign-in button', (tester) async {
        await tester.pumpWidget(_buildTestableLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Sign in with Google'), findsOneWidget);
      });

      testWidgets('renders Apple sign-in button', (tester) async {
        await tester.pumpWidget(_buildTestableLoginScreen());
        await tester.pumpAndSettle();

        // Apple button is present but may be disabled (Platform.isIOS is false in test)
        expect(find.text('Sign in with Apple'), findsOneWidget);
      });

      testWidgets('renders email sign-in button', (tester) async {
        await tester.pumpWidget(_buildTestableLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Sign in with Email'), findsOneWidget);
      });

      testWidgets('renders register link', (tester) async {
        await tester.pumpWidget(_buildTestableLoginScreen());
        await tester.pumpAndSettle();

        expect(find.text('Registrati'), findsOneWidget);
      });
    });

    group('email form', () {
      Future<void> _openEmailForm(WidgetTester tester) async {
        await tester.pumpWidget(_buildTestableLoginScreen());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign in with Email'));
        await tester.pumpAndSettle();
      }

      testWidgets('opens when email button is tapped', (tester) async {
        await _openEmailForm(tester);

        // Email form header should be visible
        // The form title reuses the "Sign in with Email" text
        expect(find.text('Sign in with Email'), findsAtLeast(1));
      });

      testWidgets('has email text field', (tester) async {
        await _openEmailForm(tester);

        expect(find.byType(TextFormField), findsAtLeast(1));
      });

      testWidgets('has password text field', (tester) async {
        await _openEmailForm(tester);

        // Should have at least 2 TextFormField (email + password)
        expect(find.byType(TextFormField), findsNWidgets(2));
      });

      testWidgets('shows sign in button', (tester) async {
        await _openEmailForm(tester);

        expect(find.text('Sign In'), findsOneWidget);
      });

      testWidgets('shows back to options button', (tester) async {
        await _openEmailForm(tester);

        expect(find.text('Back to options'), findsOneWidget);
      });

      testWidgets('back to options returns to initial view', (tester) async {
        await _openEmailForm(tester);
        await tester.tap(find.text('Back to options'));
        await tester.pumpAndSettle();

        // Should see bottom actions again
        expect(find.text('Sign in with Google'), findsOneWidget);
        expect(find.text('Registrati'), findsOneWidget);
      });

      testWidgets('validates empty email', (tester) async {
        await _openEmailForm(tester);

        // Tap sign in without entering anything
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your email'), findsOneWidget);
      });

      testWidgets('validates invalid email format', (tester) async {
        await _openEmailForm(tester);

        // Enter invalid email
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'notanemail');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('validates empty password', (tester) async {
        await _openEmailForm(tester);

        // Enter valid email but no password
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'test@example.com');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('password visibility toggle works', (tester) async {
        await _openEmailForm(tester);

        // Initially password is obscured - check via TextField inside TextFormField
        final textField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).last,
            matching: find.byType(TextField),
          ),
        );
        expect(textField.obscureText, isTrue);

        // Find and tap the visibility toggle icon button
        final visibilityToggle = find.descendant(
          of: find.byType(TextFormField).last,
          matching: find.byType(IconButton),
        );
        await tester.tap(visibilityToggle);
        await tester.pumpAndSettle();

        // Now password should be visible
        final updatedTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TextFormField).last,
            matching: find.byType(TextField),
          ),
        );
        expect(updatedTextField.obscureText, isFalse);
      });

      testWidgets('accepts valid email format', (tester) async {
        await _openEmailForm(tester);

        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'user@example.com');

        final passwordField = find.byType(TextFormField).last;
        await tester.enterText(passwordField, 'password123');

        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // No validation errors should be shown
        expect(find.text('Please enter your email'), findsNothing);
        expect(find.text('Please enter a valid email'), findsNothing);
        expect(find.text('Please enter your password'), findsNothing);
      });
    });
  });
}
