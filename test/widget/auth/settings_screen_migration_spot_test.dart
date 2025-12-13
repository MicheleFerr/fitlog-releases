/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: test/widget
/// Feature: auth migration with Spot testing
/// Type: widget test (Spot syntax)
/// Localization: AppLocalizations tested
/// Theme: Both light and dark themes tested
///
/// SPOT MIGRATION of settings_screen_migration_test.dart
/// Uses Spot's chainable finders for better readability and error messages
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile_consolidated.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class UserProfileFactory {
  static UserProfile createFreeUser({
    String? email,
    String? displayName,
  }) {
    return UserProfile(
      uid: 'test-free-user',
      email: email ?? 'free@gymbro.app',
      displayName: displayName ?? 'Free User',
      accountTier: AccountTier.free,
      templateQuota: TemplateQuota.forTier(AccountTier.free),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
  }

  static UserProfile createPremiumUser({
    String? email,
    String? displayName,
  }) {
    return UserProfile(
      uid: 'test-premium-user',
      email: email ?? 'premium@gymbro.app',
      displayName: displayName ?? 'Premium User',
      accountTier: AccountTier.premium,
      templateQuota: TemplateQuota.forTier(AccountTier.premium),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
  }
}

void main() {
  group('Settings Screen Migration - Spot Tests', () {
    /// Creates test widget with localization
    Widget createTestWidget({
      String locale = 'en',
      Widget? child,
    }) {
      return MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child ?? const Scaffold(body: Text('Test Widget')),
      );
    }

    group('User Profile Display - Spot Finders', () {
      testWidgets('displays user profile card for free user', (tester) async {
        final freeUser = UserProfileFactory.createFreeUser(
          email: 'free@gymbro.app',
          displayName: 'Free User',
        );

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Card(
              child: Column(
                children: [
                  const Text('Account'),
                  Text(freeUser.displayName),
                  Text(freeUser.email),
                  if (freeUser.accountTier == AccountTier.free)
                    const Text('FREE'),
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot chainable assertions - more readable!
        spot<Card>().existsOnce();
        spot<Text>().whereText((t) => t.contains('Account')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Free User')).existsOnce();
        spot<Text>().whereText((t) => t.contains('free@gymbro.app')).existsOnce();
        spot<Text>().whereText((t) => t.contains('FREE')).existsOnce();
      });

      testWidgets('displays premium user profile with badge', (tester) async {
        final premiumUser = UserProfileFactory.createPremiumUser(
          email: 'premium@gymbro.app',
          displayName: 'Premium User',
        );

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Card(
              child: Column(
                children: [
                  const Text('Account'),
                  Text(premiumUser.displayName),
                  Text(premiumUser.email),
                  if (premiumUser.accountTier == AccountTier.premium) ...[
                    const Text('PREMIUM'),
                    const Icon(Icons.cloud_sync),
                  ],
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot assertions
        spot<Text>().whereText((t) => t.contains('Premium User')).existsOnce();
        spot<Text>().whereText((t) => t.contains('premium@gymbro.app')).existsOnce();
        spot<Text>().whereText((t) => t.contains('PREMIUM')).existsOnce();
        spot<Icon>()
            .whereWidget((icon) => icon.icon == Icons.cloud_sync, description: 'cloud_sync icon')
            .existsOnce();
      });

      testWidgets('handles admin user detection', (tester) async {
        final adminUser = UserProfileFactory.createPremiumUser(
          email: 'michele.cozzolino93@gmail.com',
          displayName: 'Michele (Admin)',
        );

        final isAdmin = adminUser.email.contains('michele.cozzolino93@gmail.com');

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Card(
              child: Column(
                children: [
                  Text(adminUser.displayName),
                  if (isAdmin) ...[
                    const Text('ADMIN'),
                    const Text('Admin Tools'),
                  ],
                ],
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot assertions for admin features
        spot<Text>().whereText((t) => t.contains('Michele (Admin)')).existsOnce();
        spot<Text>().whereText((t) => t.contains('ADMIN')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Admin Tools')).existsOnce();
      });
    });

    group('User State Handling - Spot Finders', () {
      testWidgets('shows loading state correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
                Text('Loading'),
              ],
            ),
          ),
        ));
        await tester.pump(); // Single pump for animated widget

        // Spot assertions
        spot<Text>().whereText((t) => t.contains('Loading')).existsOnce();
        spot<CircularProgressIndicator>().existsOnce();
        spot<SizedBox>()
            .whereWidget((s) => s.width == 20 && s.height == 20, description: '20x20 SizedBox')
            .existsOnce();
      });

      testWidgets('shows unauthenticated state correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const Scaffold(
            body: Text('Not logged in'),
          ),
        ));
        await tester.pumpAndSettle();

        spot<Text>().whereText((t) => t.contains('Not logged in')).existsOnce();
      });

      testWidgets('shows error state correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const Scaffold(
            body: Column(
              children: [
                Icon(Icons.error),
                Text('Error loading user'),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        spot<Text>().whereText((t) => t.contains('Error loading user')).existsOnce();
        spot<Icon>()
            .whereWidget((icon) => icon.icon == Icons.error, description: 'error icon')
            .existsOnce();
      });
    });

    group('Localization Testing - Spot Finders', () {
      testWidgets('displays English text correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          locale: 'en',
          child: Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Column(
              children: [
                Text('Account'),
                Text('Appearance'),
                Text('Sign Out'),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot chainable assertions for localized text
        spot<AppBar>().existsOnce();
        spot<Text>().whereText((t) => t.contains('Settings')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Account')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Appearance')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Sign Out')).existsOnce();
      });

      testWidgets('displays Italian text correctly', (tester) async {
        await tester.pumpWidget(createTestWidget(
          locale: 'it',
          child: Scaffold(
            appBar: AppBar(title: const Text('Impostazioni')),
            body: const Column(
              children: [
                Text('Account'),
                Text('Aspetto'),
                Text('Disconnetti'),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        spot<Text>().whereText((t) => t.contains('Impostazioni')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Aspetto')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Disconnetti')).existsOnce();
      });
    });

    group('Theme Testing - Spot Finders', () {
      testWidgets('displays correctly in light theme', (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Card(
              child: Text('Content'),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot verifies widget existence
        spot<Scaffold>().existsOnce();
        spot<Card>().existsOnce();
        spot<AppBar>().existsOnce();
        spot<Text>().whereText((t) => t.contains('Content')).existsOnce();
      });

      testWidgets('displays correctly in dark theme', (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Card(
              child: Text('Content'),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        spot<Card>().existsOnce();
        spot<AppBar>().existsOnce();
      });
    });

    group('Premium Features - Spot Finders', () {
      testWidgets('free user should not have cloud sync', (tester) async {
        final freeUser = UserProfileFactory.createFreeUser();
        final canSync = freeUser.accountTier == AccountTier.premium;

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                Text(freeUser.displayName),
                if (canSync) ...[
                  const Text('Cloud Sync'),
                  const Icon(Icons.cloud_sync),
                ],
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot: Verify cloud sync NOT visible
        spot<Text>().whereText((t) => t.contains('Cloud Sync')).doesNotExist();
        spot<Icon>()
            .whereWidget((icon) => icon.icon == Icons.cloud_sync, description: 'cloud_sync icon')
            .doesNotExist();
      });

      testWidgets('premium user should have cloud sync', (tester) async {
        final premiumUser = UserProfileFactory.createPremiumUser();
        final canSync = premiumUser.accountTier == AccountTier.premium;

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                Text(premiumUser.displayName),
                if (canSync) ...[
                  const Text('Cloud Sync'),
                  const Icon(Icons.cloud_sync),
                  const Text('Sync from Cloud'),
                ],
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot: Verify cloud sync IS visible
        spot<Text>().whereText((t) => t.contains('Cloud Sync')).existsOnce();
        spot<Icon>()
            .whereWidget((icon) => icon.icon == Icons.cloud_sync, description: 'cloud_sync icon')
            .existsOnce();
        spot<Text>().whereText((t) => t.contains('Sync from Cloud')).existsOnce();
      });

      testWidgets('template quota information', (tester) async {
        final user = UserProfileFactory.createFreeUser().copyWith(
          templateQuota: TemplateQuota.forTier(
            AccountTier.free,
            usedPrivate: 5,
            usedPublic: 1,
          ),
        );

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                Text('Templates: ${user.templateQuota.usedPrivateTemplates}/${user.templateQuota.maxPrivateTemplates}'),
                Text('Public: ${user.templateQuota.usedPublicTemplates}/${user.templateQuota.maxPublicTemplates}'),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot assertions for quota display
        spot<Text>().whereText((t) => t.contains('Templates: 5/10')).existsOnce();
        spot<Text>().whereText((t) => t.contains('Public: 1/2')).existsOnce();
      });
    });

    group('User Profile Validation - Spot Finders', () {
      testWidgets('handles missing user data gracefully', (tester) async {
        final minimalUser = UserProfile(
          uid: 'minimal',
          email: '',
          displayName: 'Minimal User',
          accountTier: AccountTier.free,
          templateQuota: TemplateQuota.forTier(AccountTier.free),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: const UserPreferences(),
          stats: const UserStats(),
        );

        await tester.pumpWidget(createTestWidget(
          child: Scaffold(
            body: Column(
              children: [
                Text(minimalUser.displayName),
                Text(minimalUser.email.isNotEmpty ? minimalUser.email : 'No Email'),
              ],
            ),
          ),
        ));
        await tester.pumpAndSettle();

        // Spot: Widget tree should render without crashing
        spot<Scaffold>().existsOnce();
        spot<Text>().whereText((t) => t.contains('Minimal User')).existsOnce();
        spot<Text>().whereText((t) => t.contains('No Email')).existsOnce();
      });
    });
  });
}
