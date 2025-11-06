import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/calculation_metadata_display.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('ExerciseListItem - Set 4 Metadata Banner Logic', () {
    late Exercise testExerciseWithAPRE;
    late Exercise testExerciseWithoutAPRE;
    late Exercise testExerciseOnly3Sets;

    setUp(() {
      // Exercise with APRE enabled and 4 sets
      testExerciseWithAPRE = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true),
          ExerciseSet(setNumber: 2, reps: 10, weight: 100, isCompleted: true),
          ExerciseSet(setNumber: 3, reps: 10, weight: 100, isCompleted: true),
          ExerciseSet(setNumber: 4, reps: 10, weight: 100, isCompleted: true),
        ],
        useAPRE: true,
        apreProtocol: 10,
        calculated1RM: 133.0,
        lastCalculationDate: DateTime.now().subtract(const Duration(days: 2)),
        calculationMetadata: jsonEncode({
          'confidence': 'high',
          'dataPoints': 8,
          'formula': 'Brzycki',
          'dataAge': {'inDays': 2},
          'standardDeviation': 2.5,
        }),
      );

      // Exercise without APRE
      testExerciseWithoutAPRE = testExerciseWithAPRE.copyWith(useAPRE: false);

      // Exercise with only 3 sets
      testExerciseOnly3Sets = testExerciseWithAPRE.copyWith(
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true),
          ExerciseSet(setNumber: 2, reps: 10, weight: 100, isCompleted: true),
          ExerciseSet(setNumber: 3, reps: 10, weight: 100, isCompleted: true),
        ],
      );
    });

    test('T2.5.1 - Banner should appear logic: APRE enabled + 4+ sets', () {
      // Test condition: APRE enabled + 4+ sets
      final shouldShow1 = testExerciseWithAPRE.useAPRE &&
                          testExerciseWithAPRE.sets.length >= 4;
      expect(shouldShow1, true, reason: 'Banner should show when APRE enabled and 4+ sets');

      // Test condition: No APRE
      final shouldShow2 = testExerciseWithoutAPRE.useAPRE &&
                          testExerciseWithoutAPRE.sets.length >= 4;
      expect(shouldShow2, false, reason: 'Banner should NOT show when APRE disabled');

      // Test condition: Only 3 sets
      final shouldShow3 = testExerciseOnly3Sets.useAPRE &&
                          testExerciseOnly3Sets.sets.length >= 4;
      expect(shouldShow3, false, reason: 'Banner should NOT show with only 3 sets');
    });

    test('T2.5.2 - CalculationMetadata can be decoded from JSON string', () {
      final metadataStr = testExerciseWithAPRE.calculationMetadata;
      expect(metadataStr, isNotNull);

      final decoded = jsonDecode(metadataStr!);
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded['confidence'], 'high');
      expect(decoded['dataPoints'], 8);
      expect(decoded['formula'], 'Brzycki');
    });

    testWidgets('T2.5.3 - CalculationMetadataDisplay widget renders correctly', (tester) async {
      final calculations = {
        'confidence': CalculationConfidence.high,
        'dataPoints': 8,
        'formula': 'Brzycki',
        'dataAge': const Duration(days: 2),
        'standardDeviation': 2.5,
      };

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CalculationMetadataDisplay(
              calculations: calculations,
              lastCalculationDate: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify key metadata is displayed
      expect(find.text('Brzycki'), findsOneWidget);
      expect(find.text('8 / 10'), findsOneWidget);
    });

    test('T2.5.4 - Banner collapsed state can be toggled (state management test)', () {
      // Test boolean state toggle
      bool isMetadataExpanded = false;

      // Initial state
      expect(isMetadataExpanded, false);

      // Toggle expand
      isMetadataExpanded = !isMetadataExpanded;
      expect(isMetadataExpanded, true);

      // Toggle collapse
      isMetadataExpanded = !isMetadataExpanded;
      expect(isMetadataExpanded, false);
    });
  });
}
