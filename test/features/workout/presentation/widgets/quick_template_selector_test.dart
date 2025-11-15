import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_template_selector.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('should display template suggestions', (tester) async {
    final templates = [
      const ExerciseTemplate(
        exerciseName: 'Squat',
        defaultWeight: 80,
        defaultReps: 5,
        defaultSets: 5,
      ),
      const ExerciseTemplate(
        exerciseName: 'Bench',
        defaultWeight: 60,
        defaultReps: 8,
        defaultSets: 4,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: QuickTemplateSelector(
              templates: templates,
              onTemplateSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('80kg × 5'), findsOneWidget);
  });
}
