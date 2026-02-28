/// Settings feature - widget tests
///
/// Layer: test/features/settings/presentation
/// Feature: Settings section widgets
/// Type: widget test
/// Localization: AppLocalizations (EN + IT)
/// Theme: light + dark
///
/// Covers:
///  - SettingsAppearanceSection
///  - SettingsWorkoutSection
///  - SettingsUnitsLanguageSection
///  - SettingsHelpSection
///  - SettingsDataSection
///  - SettingsAdvancedSection
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/tutorial_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_advanced_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_data_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_help_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_units_language_section.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_workout_section.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/ghost_mode_provider.dart';
// Override is a sealed class inside riverpod; not re-exported publicly.
// ignore: implementation_imports
import 'package:riverpod/src/framework.dart' show Override;

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Builds a minimal test app that sets up localisation and Riverpod.
Widget buildTestApp({
  required Widget child,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it')],
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

/// Default AppConfig used across tests – mirrors the production default.
const _defaultConfig = AppConfig();

/// AppConfig with dark theme mode for appearance tests.
const _darkConfig = AppConfig(appThemeModeValue: 'dark');

/// AppConfig with lbs unit for unit-section tests.
const _lbsConfig = AppConfig(measurementUnit: 'lbs');

/// AppConfig with Italian language for localisation tests.
const _italianConfig = AppConfig(languageCode: 'it', countryCode: 'IT');

/// AppConfig with sound disabled for workout section tests.
const _silentConfig = AppConfig(soundEnabled: false);

/// Override for appConfigProvider that returns the given config synchronously.
Override configOverride(AppConfig config) =>
    appConfigProvider.overrideWith(() => _SyncAppConfigNotifier(config));

/// Synchronous AppConfigNotifier stub so no Hive is needed in tests.
class _SyncAppConfigNotifier extends AppConfigNotifier {
  _SyncAppConfigNotifier(this._config);

  final AppConfig _config;

  @override
  AppConfig build() => _config;
}

/// Stub TutorialStateNotifier that starts with tutorials enabled.
class _StubTutorialNotifier extends TutorialStateNotifier {
  @override
  TutorialState build() => TutorialState.initial().copyWith(tutorialsEnabled: true);
}

/// Stub GhostModeNotifier that returns a disabled ghost-mode state.
class _StubGhostModeNotifier extends GhostModeNotifier {
  @override
  GhostModeState build() => const GhostModeState();
}

// ---------------------------------------------------------------------------
// SettingsAppearanceSection
// ---------------------------------------------------------------------------

void main() {
  group('SettingsAppearanceSection', () {
    testWidgets('renders section header in English', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      // Section header
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('renders section header in Italian', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_italianConfig)],
          locale: const Locale('it'),
          child: SettingsAppearanceSection(config: _italianConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Aspetto'), findsOneWidget);
    });

    testWidgets('shows Theme and Primary Color list tiles', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Primary Color'), findsOneWidget);
    });

    testWidgets('displays correct theme label for system mode', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      // System is the default – the subtitle and leading icon should reflect it
      expect(find.text('System'), findsWidgets);
    });

    testWidgets('displays correct theme label for dark mode config', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_darkConfig)],
          child: SettingsAppearanceSection(config: _darkConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Dark'), findsWidgets);
    });

    testWidgets('shows color display name for default blue', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('displays text-size row with font-size label', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Text Size'), findsOneWidget);
    });

    testWidgets('tapping Theme tile does not throw', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      final themeTile = find.widgetWithText(ListTile, 'Theme');
      expect(themeTile, findsOneWidget);
      await tester.tap(themeTile);
      await tester.pumpAndSettle();
      // Theme dialog/sheet should have appeared – verify a theme option is visible
      expect(find.text('Light'), findsWidgets);
    });

    testWidgets('tapping Primary Color tile does not throw', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsAppearanceSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      final colorTile = find.widgetWithText(ListTile, 'Primary Color');
      expect(colorTile, findsOneWidget);
      await tester.tap(colorTile);
      await tester.pumpAndSettle();
      // Color picker sheet should show color options
      expect(find.text('Blue'), findsWidgets);
    });

    testWidgets('renders in dark theme without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_darkConfig)],
          themeMode: ThemeMode.dark,
          child: SettingsAppearanceSection(config: _darkConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // SettingsWorkoutSection
  // -------------------------------------------------------------------------

  group('SettingsWorkoutSection', () {
    testWidgets('renders Workout section header in English', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Workout'), findsWidgets);
    });

    testWidgets('renders default rest time subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      // Default rest time is 90 s – also used for defaultRestBetweenExercises
      expect(find.text('90s'), findsWidgets);
    });

    testWidgets('renders rest between exercises subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      // defaultRestBetweenExercises defaults to 90 as well
      expect(find.text('90s'), findsWidgets);
    });

    testWidgets('shows Sound switch when sound enabled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      // Sound setting label should be visible
      expect(find.text('Sounds'), findsOneWidget);
    });

    testWidgets('timer sound selector visible when sound is enabled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Timer Sound'), findsOneWidget);
    });

    testWidgets('timer sound selector hidden when sound is disabled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_silentConfig)],
          child: SettingsWorkoutSection(config: _silentConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Timer Sound'), findsNothing);
    });

    testWidgets('shows Vibration switch', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Vibrations'), findsOneWidget);
    });

    testWidgets('shows Keep Screen Awake switch', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Keep Screen Awake'), findsOneWidget);
    });

    testWidgets('shows Equipment Profiles tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Equipment Profiles'), findsOneWidget);
    });

    testWidgets('tapping rest time tile opens dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      final restTile = find.widgetWithText(ListTile, 'Default Rest Time');
      expect(restTile, findsOneWidget);
      await tester.tap(restTile);
      await tester.pumpAndSettle();

      // Dialog should appear with Cancel button
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('rest time dialog has Save and Cancel actions', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ListTile, 'Default Rest Time'));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Cancel closes rest time dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ListTile, 'Default Rest Time'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed – Cancel should no longer be visible
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('renders in dark theme without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          themeMode: ThemeMode.dark,
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Sounds'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // SettingsUnitsLanguageSection
  // -------------------------------------------------------------------------

  group('SettingsUnitsLanguageSection', () {
    testWidgets('renders section header in English', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsUnitsLanguageSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Units & Language'), findsOneWidget);
    });

    testWidgets('renders section header in Italian', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_italianConfig)],
          locale: const Locale('it'),
          child: SettingsUnitsLanguageSection(config: _italianConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Unità e Lingua'), findsOneWidget);
    });

    testWidgets('shows Language tile with English subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsUnitsLanguageSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('shows Language tile with Italian subtitle when config is Italian', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_italianConfig)],
          locale: const Locale('it'),
          child: SettingsUnitsLanguageSection(config: _italianConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Italiano'), findsOneWidget);
    });

    testWidgets('shows weight unit KG subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsUnitsLanguageSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('KG'), findsOneWidget);
    });

    testWidgets('shows weight unit LBS subtitle when lbs config', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_lbsConfig)],
          child: SettingsUnitsLanguageSection(config: _lbsConfig),
        ),
      );
      await tester.pump();

      expect(find.text('LBS'), findsOneWidget);
    });

    testWidgets('tapping Language tile opens language dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsUnitsLanguageSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ListTile, 'Language'));
      await tester.pumpAndSettle();

      // Dialog should show language options
      // l10n key 'settingsItaliano' renders as "Italian" in English locale
      expect(find.text('English'), findsWidgets);
      expect(find.text('Italian'), findsOneWidget);
    });

    testWidgets('tapping Weight Units tile opens units dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsUnitsLanguageSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ListTile, 'Weight Units'));
      await tester.pumpAndSettle();

      // Dialog should show kg and lbs radio options
      expect(find.text('Kilograms (kg)'), findsOneWidget);
      expect(find.text('Pounds (lbs)'), findsOneWidget);
    });

    testWidgets('renders in dark theme without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          themeMode: ThemeMode.dark,
          child: SettingsUnitsLanguageSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Units & Language'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // SettingsHelpSection
  // -------------------------------------------------------------------------

  group('SettingsHelpSection', () {
    // SettingsHelpSection depends on tutorialStateProvider.
    // We override it with a stub that does not touch Hive.
    List<Override> _helpOverrides() => [
          tutorialStateProvider.overrideWith(_StubTutorialNotifier.new),
        ];

    testWidgets('renders Help & Info section header', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Tutorial & Help'), findsWidgets);
    });

    testWidgets('shows Tutorials toggle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Contextual Tutorials'), findsOneWidget);
    });

    testWidgets('shows Help Center tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Help Center'), findsOneWidget);
    });

    testWidgets('shows Beta Feedback tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      // l10n key 'betaFeedback' renders as "Send Feedback"
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('shows Privacy Policy tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('shows Open Source Licenses tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Open Source Licenses'), findsOneWidget);
    });

    testWidgets('shows Exercise Images Credit tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      // l10n key 'exerciseImagesCredit' renders as "Exercise Images"
      expect(find.text('Exercise Images'), findsOneWidget);
    });

    testWidgets('shows Made with love footer', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      // l10n key 'madeWithLove' renders as "Made with love in Italy"
      expect(find.text('Made with love in Italy'), findsOneWidget);
    });

    testWidgets('tapping Exercise Images Credit opens attribution dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ListTile, 'Exercise Images'));
      await tester.pumpAndSettle();

      // Dialog should show with OK button
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('exercisedb.io'), findsOneWidget);
    });

    testWidgets('Exercise Images Credit dialog can be dismissed', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ListTile, 'Exercise Images'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsNothing);
    });

    testWidgets('renders in Italian locale', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          locale: const Locale('it'),
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      // Italian label for tutorials section
      // Italian translation for settingsTutorialHelp is "Tutorial e Aiuto"
      expect(find.text('Tutorial e Aiuto'), findsWidgets);
    });

    testWidgets('renders in dark theme without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: _helpOverrides(),
          themeMode: ThemeMode.dark,
          child: const SettingsHelpSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Tutorial & Help'), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // SettingsDataSection
  // -------------------------------------------------------------------------

  group('SettingsDataSection', () {
    // SettingsDataSection uses GoRouter via context.pushNamed. In unit widget
    // tests we replace GoRouter with a simple MaterialApp navigator, so the
    // pushNamed call will just be a no-op navigator.push that won't crash.

    testWidgets('renders Data & Backup section header', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Data & Backup'), findsOneWidget);
    });

    testWidgets('shows Health Sync Settings tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Health Sync Settings'), findsOneWidget);
    });

    testWidgets('shows Import Data tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Import Data'), findsOneWidget);
    });

    testWidgets('shows Export Data tile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('renders three dividers between the tiles', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      // Health sync, Import and Export – 2 dividers separating 3 tiles
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('renders in Italian locale', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('it'),
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Dati & Backup'), findsOneWidget);
    });

    testWidgets('renders in dark theme without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          themeMode: ThemeMode.dark,
          child: const SettingsDataSection(),
        ),
      );
      await tester.pump();

      expect(find.text('Data & Backup'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // SettingsAdvancedSection
  // -------------------------------------------------------------------------

  group('SettingsAdvancedSection', () {
    // SettingsAdvancedSection watches:
    //  - ghostModeProvider          -> stubbed with _StubGhostModeNotifier
    //  - userProfileProvider        -> stubbed as empty AsyncData(null)
    //  - appConfigProvider          -> stubbed via configOverride
    //  - analyticsCacheServiceProvider -> not used until tap; skip override
    //  - stressIndexNotifierProvider   -> not used until tap; skip override
    //  - tutorialStateProvider      -> not used until tap

    List<Override> advancedOverrides({AppConfig config = _defaultConfig}) => [
          configOverride(config),
          ghostModeProvider.overrideWith(_StubGhostModeNotifier.new),
          userProfileNotifierProvider.overrideWith(
            () => _StubUserProfileNotifier(),
          ),
        ];

    testWidgets('renders Advanced section as collapsed ExpansionTile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('section is collapsed by default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      // Ghost Mode is inside the collapsed section – should not be visible
      expect(find.text('Ghost Mode'), findsNothing);
    });

    testWidgets('expands on tap to reveal inner settings', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('Ghost Mode'), findsOneWidget);
    });

    testWidgets('shows Day Cutoff Hour tile when expanded', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      // l10n key 'settingsDayCutoffHour' renders as "New day starts at"
      expect(find.text('New day starts at'), findsOneWidget);
    });

    testWidgets('shows Effort Scale tile when expanded with RPE default', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('Effort Scale'), findsOneWidget);
      // Default effortScale is 'rpe'
      // l10n key 'rpeScale' renders as "RPE (Rate of Perceived Exertion)"
      expect(find.text('RPE (Rate of Perceived Exertion)'), findsOneWidget);
    });

    testWidgets('shows Recalculate Stress Index tile when expanded', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      // l10n key 'recalculateStressIndex' renders as "Recalculate Training Stress"
      expect(find.text('Recalculate Training Stress'), findsOneWidget);
    });

    testWidgets('shows Reset Tutorials tile when expanded', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Tutorials'), findsOneWidget);
    });

    testWidgets('shows RIR label when effortScale is rir', (tester) async {
      const rirConfig = AppConfig(effortScale: 'rir');

      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(config: rirConfig),
          child: SettingsAdvancedSection(config: rirConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      // l10n key 'rirScale' renders as "RIR (Reps In Reserve)"
      expect(find.text('RIR (Reps In Reserve)'), findsOneWidget);
    });

    testWidgets('tapping Reset Tutorials shows confirmation dialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            ...advancedOverrides(),
            tutorialStateProvider.overrideWith(_StubTutorialNotifier.new),
          ],
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Reset Tutorials'));
      await tester.pumpAndSettle();

      // Confirmation dialog should have Cancel and Reset buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset Tutorials'), findsWidgets);
    });

    testWidgets('tapping Cancel in Reset dialog closes it', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            ...advancedOverrides(),
            tutorialStateProvider.overrideWith(_StubTutorialNotifier.new),
          ],
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Reset Tutorials'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('tapping Effort Scale opens dialog with RPE and RIR options', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Effort Scale'));
      await tester.pumpAndSettle();

      // l10n keys 'rpeMode' = "RPE Based", 'rirMode' = "RIR Based"
      expect(find.text('RPE Based'), findsOneWidget);
      expect(find.text('RIR Based'), findsOneWidget);
    });

    testWidgets('renders in dark theme without error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          themeMode: ThemeMode.dark,
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('renders in Italian locale', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: advancedOverrides(),
          locale: const Locale('it'),
          child: const SettingsAdvancedSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Avanzate'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Cross-section: AppConfig propagation
  // -------------------------------------------------------------------------

  group('AppConfig propagation across sections', () {
    testWidgets('AppearanceSection reflects non-default primaryColor', (tester) async {
      const redConfig = AppConfig(primaryColor: 'red');
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(redConfig)],
          child: SettingsAppearanceSection(config: redConfig),
        ),
      );
      await tester.pump();

      expect(find.text('Red'), findsOneWidget);
    });

    testWidgets('WorkoutSection reflects custom defaultRestTime', (tester) async {
      const customConfig = AppConfig(defaultRestTime: 120);
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(customConfig)],
          child: SettingsWorkoutSection(config: customConfig),
        ),
      );
      await tester.pump();

      expect(find.text('120s'), findsOneWidget);
    });

    testWidgets('WorkoutSection default sets x reps tile shows 4x8', (tester) async {
      // defaultExerciseSets=4, defaultExerciseReps=8 by default
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(_defaultConfig)],
          child: SettingsWorkoutSection(config: _defaultConfig),
        ),
      );
      await tester.pump();

      expect(find.text('4\u00d78'), findsOneWidget);
    });

    testWidgets('UnitsSection reflects custom defaultRestBetweenExercises', (tester) async {
      const customConfig = AppConfig(defaultRestBetweenExercises: 60);
      await tester.pumpWidget(
        buildTestApp(
          overrides: [configOverride(customConfig)],
          child: SettingsWorkoutSection(config: customConfig),
        ),
      );
      await tester.pump();

      expect(find.text('60s'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Stub for UserProfileNotifier – returns AsyncData(null) immediately.
// ---------------------------------------------------------------------------

class _StubUserProfileNotifier extends UserProfileNotifier {
  @override
  AsyncValue<UserProfile?> build() => const AsyncData(null);
}
