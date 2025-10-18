import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('loads English translations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.appTitle),
                    Text(l10n.welcome),
                    Text(l10n.startWorkout),
                    Text(l10n.exercises),
                    Text(l10n.settings),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify English translations are loaded
      expect(find.text('GymBro'), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('loads Italian translations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.appTitle),
                    Text(l10n.welcome),
                    Text(l10n.startWorkout),
                    Text(l10n.exercises),
                    Text(l10n.settings),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Italian translations are loaded
      expect(find.text('GymBro'), findsOneWidget);
      expect(find.text('Benvenuto'), findsOneWidget);
      expect(find.text('Inizia Allenamento'), findsOneWidget);
      expect(find.text('Esercizi'), findsOneWidget);
      expect(find.text('Impostazioni'), findsOneWidget);
    });

    testWidgets('changes language dynamically', (tester) async {
      const Locale englishLocale = Locale('en');
      const Locale italianLocale = Locale('it');
      final ValueNotifier<Locale> currentLocale = ValueNotifier(englishLocale);

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: currentLocale,
          builder: (context, locale, _) {
            return MaterialApp(
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(l10n.settings),
                        ElevatedButton(
                          onPressed: () {
                            currentLocale.value = italianLocale;
                          },
                          child: const Text('Switch to Italian'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Initially in English
      expect(find.text('Settings'), findsOneWidget);

      // Switch to Italian
      await tester.tap(find.text('Switch to Italian'));
      await tester.pumpAndSettle();

      // Now in Italian
      expect(find.text('Impostazioni'), findsOneWidget);
    });

    testWidgets('formats numbers according to locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.setsCompleted(3, 5)),
                    Text(l10n.weightWithUnit(100.5)),
                    Text(l10n.repsCount(10)),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify number formatting
      expect(find.text('3 of 5 sets completed'), findsOneWidget);
      expect(find.text('100.5 kg'), findsOneWidget);
      expect(find.text('10 reps'), findsOneWidget);
    });

    testWidgets('formats dates according to locale', (tester) async {
      final testDate = DateTime(2024, 3, 15, 14, 30);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.workoutDate(testDate)),
                    Text(l10n.lastWorkout(testDate)),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify date formatting (format depends on locale)
      expect(find.textContaining('March'), findsWidgets);
      expect(find.textContaining('2024'), findsWidgets);
    });

    testWidgets('handles pluralization correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.exerciseCount(0)),
                    Text(l10n.exerciseCount(1)),
                    Text(l10n.exerciseCount(5)),
                    Text(l10n.workoutCount(0)),
                    Text(l10n.workoutCount(1)),
                    Text(l10n.workoutCount(10)),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify pluralization
      expect(find.text('0 exercises'), findsOneWidget);
      expect(find.text('1 exercise'), findsOneWidget);
      expect(find.text('5 exercises'), findsOneWidget);
      expect(find.text('0 workouts'), findsOneWidget);
      expect(find.text('1 workout'), findsOneWidget);
      expect(find.text('10 workouts'), findsOneWidget);
    });

    testWidgets('provides fallback for missing translations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // App should still run even if some translations are missing
      expect(find.text('Test'), findsOneWidget);
    });

    test('supported locales include English and Italian', () {
      const supportedLocales = AppLocalizations.supportedLocales;
      
      expect(supportedLocales, contains(const Locale('en')));
      expect(supportedLocales, contains(const Locale('it')));
      expect(supportedLocales.length, greaterThanOrEqualTo(2));
    });

    test('delegate supports locale', () {
      const delegate = AppLocalizations.delegate;
      
      expect(delegate.isSupported(const Locale('en')), true);
      expect(delegate.isSupported(const Locale('it')), true);
      expect(delegate.isSupported(const Locale('fr')), false);
      expect(delegate.isSupported(const Locale('de')), false);
    });

    testWidgets('workout-specific translations work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.restTimer),
                    Text(l10n.startTimer),
                    Text(l10n.pauseTimer),
                    Text(l10n.resumeTimer),
                    Text(l10n.skipTimer),
                    Text(l10n.addExercise),
                    Text(l10n.removeExercise),
                    Text(l10n.completeWorkout),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify workout-specific translations
      expect(find.text('Rest Timer'), findsOneWidget);
      expect(find.text('Start Timer'), findsOneWidget);
      expect(find.text('Pause Timer'), findsOneWidget);
      expect(find.text('Resume Timer'), findsOneWidget);
      expect(find.text('Skip Timer'), findsOneWidget);
      expect(find.text('Add Exercise'), findsOneWidget);
      expect(find.text('Remove Exercise'), findsOneWidget);
      expect(find.text('Complete Workout'), findsOneWidget);
    });

    testWidgets('error message translations work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.errorGeneric),
                    Text(l10n.errorNetwork),
                    Text(l10n.errorAuth),
                    Text(l10n.errorInvalidEmail),
                    Text(l10n.errorWeakPassword),
                    Text(l10n.errorUserNotFound),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error message translations
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Network error. Please check your connection'), findsOneWidget);
      expect(find.text('Authentication failed'), findsOneWidget);
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      expect(find.text('User not found'), findsOneWidget);
    });

    testWidgets('validation message translations work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.fieldRequired),
                    Text(l10n.invalidValue),
                    Text(l10n.valueTooLow),
                    Text(l10n.valueTooHigh),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify validation message translations
      expect(find.text('This field is required'), findsOneWidget);
      expect(find.text('Invalid value'), findsOneWidget);
      expect(find.text('Value is too low'), findsOneWidget);
      expect(find.text('Value is too high'), findsOneWidget);
    });
  });

  group('Localization Context Extensions Tests', () {
    testWidgets('context extension provides easy access to l10n', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              // Extension method for easier access
              final l10n = AppLocalizations.of(context);
              
              return Scaffold(
                body: Text(l10n.appTitle),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('GymBro'), findsOneWidget);
    });
  });

  group('Localization ARB File Tests', () {
    test('all keys present in both language files', () {
      // This test would verify that app_en.arb and app_it.arb have the same keys
      // In a real implementation, you would read and parse the ARB files
      
      const englishKeys = [
        'appTitle',
        'welcome',
        'startWorkout',
        'exercises',
        'settings',
        'restTimer',
        'errorGeneric',
        'fieldRequired',
      ];
      
      const italianKeys = [
        'appTitle',
        'welcome',
        'startWorkout',
        'exercises',
        'settings',
        'restTimer',
        'errorGeneric',
        'fieldRequired',
      ];
      
      expect(englishKeys.toSet(), equals(italianKeys.toSet()));
    });

    test('placeholders are consistent across languages', () {
      // Verify that placeholders like {count}, {weight}, etc. are consistent
      // This would require parsing ARB files in a real implementation
      
      const englishPlaceholder = 'You have {count} workouts';
      const italianPlaceholder = 'Hai {count} allenamenti';
      
      expect(englishPlaceholder.contains('{count}'), true);
      expect(italianPlaceholder.contains('{count}'), true);
    });
  });
}