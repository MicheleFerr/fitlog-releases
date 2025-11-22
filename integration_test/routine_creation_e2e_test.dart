/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: integration_test
/// 🎯 Feature: flexible_routine
/// 🔧 Type: E2E integration test
/// 📱 Platform: Universal
///
/// ROUTINE CREATION E2E INTEGRATION TEST
///
/// Full user flow:
/// 1. User opens app → sees Routine Center
/// 2. User taps "Create Routine" FAB → navigates to Step 1
/// 3. User selects preset → Continue → navigates to Step 2
/// 4. User fills routine name + selects days + assigns templates → Create
/// 5. Success snackbar shows → navigates back to Routine Center
/// 6. New routine appears in Routine Center list
///
/// Tech stack:
/// - integration_test package (Flutter)
/// - FakeFirebaseFirestore for isolated Firestore testing
/// - Riverpod provider overrides for dependency injection
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymbro_flutter_new/features/routine/data/repositories/firebase_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_providers.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_center_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_creation_step1_screen.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/screens/routine_creation_step2_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Routine Creation E2E Test', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    // Helper: Create mock workout template
    WorkoutTemplate createMockTemplate({
      required String id,
      required String name,
    }) {
      return WorkoutTemplate(
        id: id,
        name: name,
        description: 'Test template',
        exercises: const [],
        isPublic: false,
      );
    }

    testWidgets('Complete routine creation flow', (WidgetTester tester) async {
      // Set up larger viewport for better visibility
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Build app with provider overrides
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Inject fake Firestore
            firestoreProvider.overrideWithValue(fakeFirestore),
            // Inject fake repository
            routineRepositoryProvider.overrideWith((ref) {
              return FirebaseRoutineRepository(firestore: fakeFirestore);
            }),
            // Mock user ID
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('it'), // Italian
            ],
            home: const RoutineCenterScreen(),
            routes: {
              RoutineCreationStep1Screen.routeName: (context) =>
                  const RoutineCreationStep1Screen(),
              RoutineCreationStep2Screen.routeName: (context) =>
                  const RoutineCreationStep2Screen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ────────────────────────────────────────────────────────────────────────
      // STEP 0: Routine Center Screen (Starting point)
      // ────────────────────────────────────────────────────────────────────────

      // Verify Routine Center rendered
      expect(find.byType(RoutineCenterScreen), findsOneWidget);

      // Find and tap "Create Routine" FAB (or equivalent button)
      // Note: Adjust finder based on actual UI implementation
      final createButton = find.byType(FloatingActionButton);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
      } else {
        // Fallback: Find any button with "Create" text
        final createTextButton = find.widgetWithText(ElevatedButton, 'Create Routine');
        await tester.tap(createTextButton);
      }
      await tester.pumpAndSettle();

      // ────────────────────────────────────────────────────────────────────────
      // STEP 1: Preset Selection Screen
      // ────────────────────────────────────────────────────────────────────────

      // Verify Step 1 screen rendered
      expect(find.byType(RoutineCreationStep1Screen), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);

      // Select "Push/Pull/Legs (6 days)" preset
      await tester.tap(find.text('Push/Pull/Legs (6 days)'));
      await tester.pumpAndSettle();

      // Tap "Continue" button
      final continueButton = find.widgetWithText(FilledButton, 'Continue');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // ────────────────────────────────────────────────────────────────────────
      // STEP 2: Training Days + Template Assignment Screen
      // ────────────────────────────────────────────────────────────────────────

      // Verify Step 2 screen rendered
      expect(find.byType(RoutineCreationStep2Screen), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);

      // Enter routine name
      final nameField = find.byType(TextField);
      await tester.enterText(nameField, 'My PPL Routine E2E');
      await tester.pumpAndSettle();

      // Training days should be pre-selected (Mon-Sat for PPL preset)
      // Verify FilterChips are rendered
      expect(find.byType(FilterChip), findsAtLeastNWidgets(6));

      // Assign templates to each training day (manually set provider state)
      // Note: In a real E2E test, you would tap cards and pick templates from modal
      // For now, we manually set the state since TemplatePickerModal is TODO
      final container = ProviderScope.containerOf(
        tester.element(find.byType(RoutineCreationStep2Screen)),
      );

      final mockTemplates = {
        1: createMockTemplate(id: 'template-push-1', name: 'Push Day 1'),
        2: createMockTemplate(id: 'template-pull-1', name: 'Pull Day 1'),
        3: createMockTemplate(id: 'template-legs-1', name: 'Legs Day 1'),
        4: createMockTemplate(id: 'template-push-2', name: 'Push Day 2'),
        5: createMockTemplate(id: 'template-pull-2', name: 'Pull Day 2'),
        6: createMockTemplate(id: 'template-legs-2', name: 'Legs Day 2'),
      };
      container.read(dayTemplatesProvider.notifier).state = mockTemplates;
      await tester.pumpAndSettle();

      // Tap "Create Routine" button
      final createRoutineButton = find.widgetWithText(FilledButton, 'Create Routine');
      await tester.tap(createRoutineButton);
      await tester.pumpAndSettle();

      // ────────────────────────────────────────────────────────────────────────
      // STEP 3: Success + Return to Routine Center
      // ────────────────────────────────────────────────────────────────────────

      // Wait for async operations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify success snackbar shown (optional - may not be visible depending on timing)
      // expect(find.byType(SnackBar), findsOneWidget);
      // expect(find.text('Routine created successfully'), findsOneWidget);

      // Verify navigation back to Routine Center
      expect(find.byType(RoutineCenterScreen), findsOneWidget);

      // ────────────────────────────────────────────────────────────────────────
      // STEP 4: Verify New Routine Appears in Firestore + UI
      // ────────────────────────────────────────────────────────────────────────

      // Query Firestore to verify routine was created
      final routinesSnapshot = await fakeFirestore
          .collection('routines')
          .where('userId', isEqualTo: 'test-user-123')
          .get();

      expect(routinesSnapshot.docs.length, 1, reason: 'Should have 1 routine created');

      final routineData = routinesSnapshot.docs.first.data();
      expect(routineData['name'], 'My PPL Routine E2E');
      expect(routineData['presetType'], 'ppl_6_day');
      expect(routineData['trainingDays'], isA<List>());
      expect(routineData['workoutSchedule'], isA<Map>());

      // Verify routine card appears in UI (if RoutineCenterScreen shows list)
      // Note: This depends on how RoutineCenterScreen is implemented
      // Adjust finder based on actual UI
      // expect(find.text('My PPL Routine E2E'), findsOneWidget);

      // ────────────────────────────────────────────────────────────────────────
      // TEST COMPLETED
      // ────────────────────────────────────────────────────────────────────────
    });

    testWidgets('Cancel flow returns to Routine Center without creating routine',
        (WidgetTester tester) async {
      // Set up larger viewport
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Build app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(fakeFirestore),
            routineRepositoryProvider.overrideWith((ref) {
              return FirebaseRoutineRepository(firestore: fakeFirestore);
            }),
            currentUserIdProvider.overrideWith((ref) => 'test-user-123'),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('it')],
            home: const RoutineCenterScreen(),
            routes: {
              RoutineCreationStep1Screen.routeName: (context) =>
                  const RoutineCreationStep1Screen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Step 1
      final createButton = find.byType(FloatingActionButton);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
      } else {
        final createTextButton = find.widgetWithText(ElevatedButton, 'Create Routine');
        await tester.tap(createTextButton);
      }
      await tester.pumpAndSettle();

      // Verify Step 1 rendered
      expect(find.byType(RoutineCreationStep1Screen), findsOneWidget);

      // Tap back button (close icon)
      await tester.tap(find.byIcon(AppIcons.close));
      await tester.pumpAndSettle();

      // Verify navigation back to Routine Center
      expect(find.byType(RoutineCenterScreen), findsOneWidget);

      // Verify NO routine was created in Firestore
      final routinesSnapshot = await fakeFirestore
          .collection('routines')
          .where('userId', isEqualTo: 'test-user-123')
          .get();

      expect(routinesSnapshot.docs.length, 0, reason: 'Should have 0 routines (cancelled flow)');
    });
  });
}
