/// Coach Template Editor Screen Tests
///
/// Tests for the CoachTemplateEditorScreen widget that allows
/// coaches to create and edit workout templates for their athletes.
///
/// **Layer**: test/features/coach
/// **Feature**: Coach Template Editor
/// **Type**: Widget Test
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/screens/coach_template_editor_screen.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';

void main() {
  group('CoachTemplateEditorScreen', () {
    Widget createTestWidget({
      CoachTemplate? template,
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CoachTemplateEditorScreen(template: template),
        ),
      );
    }

    testWidgets('renders create mode when no template provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(CoachTemplateEditorScreen), findsOneWidget);
    });

    testWidgets('renders edit mode when template provided',
        (WidgetTester tester) async {
      final template = CoachTemplate(
        id: 'test-id',
        coachId: 'coach-id',
        name: 'Test Template',
        description: 'A test template',
        exercises: const [],
        estimatedDuration: 45,
        difficulty: 'intermediate',
        tags: const ['strength'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(template: template));
      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(CoachTemplateEditorScreen), findsOneWidget);

      // Should have pre-filled name in a text field
      expect(find.text('Test Template'), findsOneWidget);
    });

    testWidgets('shows name text field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the name text field
      final nameField = find.byType(TextField).first;
      expect(nameField, findsOneWidget);
    });

    testWidgets('can enter template name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the first text field (name)
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'My New Template');
      await tester.pump();

      expect(find.text('My New Template'), findsOneWidget);
    });

    testWidgets('shows duration slider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have a slider for duration
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows difficulty segmented button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have difficulty selector
      expect(find.byType(SegmentedButton<String?>), findsOneWidget);
    });

    testWidgets('shows save button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have a save TextButton
      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('shows add exercise button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the add exercise section with the add button
      expect(find.byIcon(AppIcons.add), findsWidgets);
    });

    testWidgets('shows empty exercises placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show "No exercises added" or similar
      expect(find.textContaining('exercise'), findsWidgets);
    });

    testWidgets('displays exercises when template has them',
        (WidgetTester tester) async {
      final template = CoachTemplate(
        id: 'test-id',
        coachId: 'coach-id',
        name: 'Test Template',
        description: 'A test template',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'ex1',
            exerciseName: 'Bench Press',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 10, targetWeight: 60),
              SetTemplate(setNumber: 2, targetReps: 10, targetWeight: 60),
              SetTemplate(setNumber: 3, targetReps: 10, targetWeight: 60),
            ],
          ),
        ],
        estimatedDuration: 45,
        difficulty: 'intermediate',
        tags: const ['strength'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(template: template));
      await tester.pumpAndSettle();

      // Should show the exercise name
      expect(find.text('Bench Press'), findsOneWidget);
    });

    testWidgets('tags section shows filter chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have FilterChip widgets for tags
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('can select a tag', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a filter chip
      final chips = find.byType(FilterChip);
      if (chips.evaluate().isNotEmpty) {
        await tester.tap(chips.first);
        await tester.pumpAndSettle();

        // Tag should now be selected (this test verifies the tap doesn't crash)
        expect(find.byType(FilterChip), findsWidgets);
      }
    });
  });

  group('CoachTemplateEditorScreen Form Validation', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CoachTemplateEditorScreen(),
        ),
      );
    }

    testWidgets('save button does nothing with empty name',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to tap save button (TextButton in app bar)
      final saveButtons = find.byType(TextButton);
      expect(saveButtons, findsWidgets);

      // After tapping save with empty name, should still be on the same screen
      if (saveButtons.evaluate().isNotEmpty) {
        await tester.tap(saveButtons.first);
        await tester.pumpAndSettle();
      }

      // Should still be on the same screen (editor still visible)
      expect(find.byType(CoachTemplateEditorScreen), findsOneWidget);
    });
  });

  group('CoachTemplate Entity', () {
    test('creates correctly with all fields', () {
      final now = DateTime.now();
      final template = CoachTemplate(
        id: 'test-123',
        coachId: 'coach-456',
        name: 'Push Day',
        description: 'Upper body pushing exercises',
        exercises: const [],
        estimatedDuration: 60,
        difficulty: 'advanced',
        tags: const ['push', 'upper'],
        coachNotes: 'Private notes',
        createdAt: now,
        updatedAt: now,
      );

      expect(template.id, 'test-123');
      expect(template.coachId, 'coach-456');
      expect(template.name, 'Push Day');
      expect(template.description, 'Upper body pushing exercises');
      expect(template.exercises, isEmpty);
      expect(template.estimatedDuration, 60);
      expect(template.difficulty, 'advanced');
      expect(template.tags, ['push', 'upper']);
      expect(template.coachNotes, 'Private notes');
    });

    test('copyWith creates new instance with updated fields', () {
      final original = CoachTemplate(
        id: 'test-123',
        coachId: 'coach-456',
        name: 'Original Name',
        description: 'Original description',
        exercises: const [],
        estimatedDuration: 45,
        difficulty: 'beginner',
        tags: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        estimatedDuration: 60,
      );

      expect(updated.name, 'Updated Name');
      expect(updated.estimatedDuration, 60);
      // Original fields preserved
      expect(updated.id, original.id);
      expect(updated.coachId, original.coachId);
      expect(updated.description, original.description);
    });

    test('hasAssignments returns false when empty', () {
      final template = CoachTemplate(
        id: 'test-123',
        coachId: 'coach-456',
        name: 'Test',
        description: '',
        exercises: const [],
        estimatedDuration: 45,
        difficulty: null,
        tags: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assignedTo: const [],
      );

      expect(template.hasAssignments, isFalse);
    });

    test('hasAssignments returns true when has athletes', () {
      final template = CoachTemplate(
        id: 'test-123',
        coachId: 'coach-456',
        name: 'Test',
        description: '',
        exercises: const [],
        estimatedDuration: 45,
        difficulty: null,
        tags: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assignedTo: const ['athlete-1', 'athlete-2'],
      );

      expect(template.hasAssignments, isTrue);
      expect(template.assignedCount, 2);
    });
  });
}
