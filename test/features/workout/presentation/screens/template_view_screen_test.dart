import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/screens/template_view_screen.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  group('TemplateViewScreen', () {
    testWidgets(
      'navigates to workout start route when start button is pressed',
      (tester) async {
        const templateId = 'template-1';
        final template = WorkoutTemplate(
          id: templateId,
          name: 'Upper Power',
          description: 'Workout di test',
          exercises: const [
            ExerciseTemplate(
              exerciseId: 'bench-press',
              exerciseName: 'Bench Press',
              category: ExerciseCategory.chest,
              sets: [SetTemplate(setNumber: 1, targetReps: 8)],
            ),
          ],
        );

        final router = GoRouter(
          initialLocation: '/templates/detail?id=$templateId',
          routes: [
            GoRoute(
              path: '/templates/detail',
              builder: (context, state) => TemplateViewScreen(
                templateId: state.uri.queryParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: '/workout/start/:templateId',
              builder: (context, state) => Scaffold(
                body: Text('start:${state.pathParameters['templateId']}'),
              ),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              allWorkoutTemplatesProvider.overrideWith(
                (ref) async => [template],
              ),
            ],
            child: MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
              routerConfig: router,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        expect(find.text('start:$templateId'), findsOneWidget);
      },
    );
  });
}
