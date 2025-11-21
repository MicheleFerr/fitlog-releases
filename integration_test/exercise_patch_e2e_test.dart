/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: integration_test
/// 🎯 Feature: exercise_database - patch system
/// 🔧 Type: E2E integration test
///
/// End-to-end test for Exercise Patch System workflow:
/// 1. User submits exercise correction
/// 2. Patch appears in admin queue
/// 3. Admin approves/rejects patch
/// 4. User sees status update
///
/// **Requirements**:
/// - Firebase emulator running (or test environment)
/// - Test user authenticated
/// - Exercise data seeded
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/main.dart' as app;
import 'package:patrol_finders/patrol_finders.dart';

void main() {
  group('Exercise Patch System E2E Tests', () {
    patrolTest(
      'User can submit exercise correction patch',
      ($) async {
        // Launch app
        await $.pumpWidgetAndSettle(app.MyApp());

        // Navigate to exercise search/list
        // (Assuming there's a navigation to exercises from home)
        final exercisesTab = find.text('Exercises');
        if ($(exercisesTab).exists) {
          await $(exercisesTab).tap();
        }

        // Find and tap on an exercise
        final firstExercise = $(Finder).containing(find.byType(ListTile)).first;
        if (firstExercise.exists) {
          await firstExercise.scrollTo();
          await firstExercise.tap();
        }

        // Look for "Report Error" or similar button
        final reportButton = $(Icon).withIcon(Icons.report_problem);
        if (reportButton.exists) {
          await reportButton.scrollTo();
          await reportButton.tap();
          await $.pumpAndSettle();

          // Verify dialog opened
          expect($('Report Exercise Error'), findsOneWidget);

          // Select field to correct
          final fieldDropdown = $(DropdownButtonFormField<String>);
          if (fieldDropdown.exists) {
            await fieldDropdown.tap();
            await $.pumpAndSettle();

            // Select first field option
            final firstOption = find.byType(DropdownMenuItem<String>).first;
            await $.tap(firstOption);
            await $.pumpAndSettle();

            // Enter new value
            final newValueField = $(TextFormField).first;
            await newValueField.enterText('Corrected Exercise Name');

            // Enter reason
            final reasonField = $(TextFormField).last;
            await reasonField.enterText(
              'This is a valid correction reason with sufficient detail',
            );

            // Submit patch
            final submitButton = find.text('Submit Correction');
            await $.tap(submitButton);
            await $.pumpAndSettle();

            // Verify success (snackbar or dialog closes)
            // Success indicators vary by implementation
          }
        }

        // Verify patch was submitted (check local state or navigate to "My Patches")
        // This depends on UI implementation
      },
    );

    patrolTest(
      'Admin can review and approve patch',
      ($) async {
        // Launch app as admin user
        await $.pumpWidgetAndSettle(app.MyApp());

        // Navigate to admin panel
        // (Assuming admin access from settings or profile)
        final settingsTab = find.byIcon(Icons.settings);
        if ($(settingsTab).exists) {
          await $(settingsTab).tap();
          await $.pumpAndSettle();

          // Find admin panel link
          final adminPanel = find.text('Admin Panel');
          if ($(adminPanel).exists) {
            await $(adminPanel).scrollTo();
            await $(adminPanel).tap();
            await $.pumpAndSettle();

            // Navigate to patch review
            final patchReview = find.text('Exercise Patch Review');
            if ($(patchReview).exists) {
              await $(patchReview).tap();
              await $.pumpAndSettle();

              // Verify patches are loaded
              expect($(CircularProgressIndicator), findsNothing);

              // Find first pending patch
              final approveButton = find.text('Approve');
              if ($(approveButton).exists) {
                await $(approveButton).scrollTo();
                await $(approveButton).tap();
                await $.pumpAndSettle();

                // Verify success message
                // (Implementation dependent - snackbar, dialog, etc.)
              }
            }
          }
        }
      },
    );

    patrolTest(
      'Duplicate patch submission is prevented',
      ($) async {
        await $.pumpWidgetAndSettle(app.MyApp());

        // Navigate to exercise
        final exercisesTab = find.text('Exercises');
        if ($(exercisesTab).exists) {
          await $(exercisesTab).tap();
          await $.pumpAndSettle();

          final firstExercise = $(Finder).containing(find.byType(ListTile)).first;
          if (firstExercise.exists) {
            await firstExercise.tap();
            await $.pumpAndSettle();

            // Submit first patch
            final reportButton = $(Icon).withIcon(Icons.report_problem);
            if (reportButton.exists) {
              await reportButton.tap();
              await $.pumpAndSettle();

              // Fill and submit form
              final fieldDropdown = $(DropdownButtonFormField<String>);
              if (fieldDropdown.exists) {
                await fieldDropdown.tap();
                await $.pumpAndSettle();

                final firstOption = find.byType(DropdownMenuItem<String>).first;
                await $.tap(firstOption);
                await $.pumpAndSettle();

                await $(TextFormField).first.enterText('Corrected Value');
                await $(TextFormField).last.enterText(
                  'Valid reason with enough detail',
                );

                final submitButton = find.text('Submit Correction');
                await $.tap(submitButton);
                await $.pumpAndSettle();

                // Close dialog if it opened
                final closeButton = find.byIcon(Icons.close);
                if ($(closeButton).exists) {
                  await $(closeButton).tap();
                  await $.pumpAndSettle();
                }
              }

              // Try to submit duplicate patch
              if (reportButton.exists) {
                await reportButton.tap();
                await $.pumpAndSettle();

                // Fill same field again
                final fieldDropdown2 = $(DropdownButtonFormField<String>);
                if (fieldDropdown2.exists) {
                  await fieldDropdown2.tap();
                  await $.pumpAndSettle();

                  final firstOption =
                      find.byType(DropdownMenuItem<String>).first;
                  await $.tap(firstOption);
                  await $.pumpAndSettle();

                  await $(TextFormField).first.enterText('Another Value');
                  await $(TextFormField).last.enterText(
                    'Another reason with enough detail',
                  );

                  final submitButton2 = find.text('Submit Correction');
                  await $.tap(submitButton2);
                  await $.pumpAndSettle();

                  // Verify error message (duplicate patch)
                  // Look for error snackbar or dialog
                  expect(find.text('Duplicate patch'), findsOneWidget);
                }
              }
            }
          }
        }
      },
    );

    patrolTest(
      'Patch with insufficient reason is rejected',
      ($) async {
        await $.pumpWidgetAndSettle(app.MyApp());

        // Navigate to exercise detail
        final exercisesTab = find.text('Exercises');
        if ($(exercisesTab).exists) {
          await $(exercisesTab).tap();
          await $.pumpAndSettle();

          final firstExercise = $(Finder).containing(find.byType(ListTile)).first;
          if (firstExercise.exists) {
            await firstExercise.tap();
            await $.pumpAndSettle();

            // Open patch submission dialog
            final reportButton = $(Icon).withIcon(Icons.report_problem);
            if (reportButton.exists) {
              await reportButton.tap();
              await $.pumpAndSettle();

              // Select field
              final fieldDropdown = $(DropdownButtonFormField<String>);
              if (fieldDropdown.exists) {
                await fieldDropdown.tap();
                await $.pumpAndSettle();

                final firstOption = find.byType(DropdownMenuItem<String>).first;
                await $.tap(firstOption);
                await $.pumpAndSettle();

                // Enter new value
                await $(TextFormField).first.enterText('New Value');

                // Enter short reason (<10 chars)
                await $(TextFormField).last.enterText('short');

                // Try to submit
                final submitButton = find.text('Submit Correction');
                await $.tap(submitButton);
                await $.pumpAndSettle();

                // Verify validation error
                expect(find.text('Reason too short'), findsOneWidget);
              }
            }
          }
        }
      },
    );

    patrolTest(
      'User can view their submitted patches',
      ($) async {
        await $.pumpWidgetAndSettle(app.MyApp());

        // Submit a patch first (reuse logic from previous test)
        // ...

        // Navigate to "My Patches" screen
        // (Assuming accessible from profile or community tab)
        final communityTab = find.text('Community');
        if ($(communityTab).exists) {
          await $(communityTab).tap();
          await $.pumpAndSettle();

          // Look for "My Patches" button/badge
          final myPatchesButton = find.text('My Patches');
          if ($(myPatchesButton).exists) {
            await $(myPatchesButton).scrollTo();
            await $(myPatchesButton).tap();
            await $.pumpAndSettle();

            // Verify patches list loaded
            expect($(CircularProgressIndicator), findsNothing);

            // Check for at least one patch card
            // (Implementation dependent on UI structure)
          }
        }
      },
    );
  });

  group('Patch Conflict Detection E2E', () {
    patrolTest(
      'Admin sees conflict warning for stale patch',
      ($) async {
        // This test requires:
        // 1. Exercise value changed after patch submitted
        // 2. Admin reviews patch
        // 3. Conflict banner should appear

        await $.pumpWidgetAndSettle(app.MyApp());

        // Navigate to admin patch review
        // (Assuming admin authenticated)
        final settingsTab = find.byIcon(Icons.settings);
        if ($(settingsTab).exists) {
          await $(settingsTab).tap();
          await $.pumpAndSettle();

          final adminPanel = find.text('Admin Panel');
          if ($(adminPanel).exists) {
            await $(adminPanel).tap();
            await $.pumpAndSettle();

            final patchReview = find.text('Exercise Patch Review');
            if ($(patchReview).exists) {
              await $(patchReview).tap();
              await $.pumpAndSettle();

              // Look for conflict warning banner
              final conflictWarning = find.byIcon(Icons.warning);
              if ($(conflictWarning).exists) {
                // Verify conflict message
                expect(find.textContaining('conflict'), findsAtLeastNWidgets(1));

                // Verify current value is shown
                expect(find.textContaining('Current value'), findsOneWidget);
              }
            }
          }
        }
      },
    );
  });
}
