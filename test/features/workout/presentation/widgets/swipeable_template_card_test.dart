import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/swipeable_template_card.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

Widget _buildTestApp({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it')],
      locale: const Locale('en'),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

WorkoutTemplate _makeTemplate() {
  return WorkoutTemplate(
    id: 'template-1',
    name: 'Push Day',
    description: 'Chest and shoulders',
    isCustom: false,
  );
}

void main() {
  // flutter_slidable leaves internal ValueNotifiers registered in tests.
  LeakTesting.settings = LeakTesting.settings.withIgnoredAll();

  testWidgets('configures full-swipe scheduling through dismissible pane', (
    tester,
  ) async {
    var scheduleCalls = 0;

    await tester.pumpWidget(
      _buildTestApp(
        child: SizedBox(
          width: 400,
          height: 240,
          child: SwipeableTemplateCard(
            template: _makeTemplate(),
            onTap: () {},
            onShare: () {},
            onDuplicate: () {},
            onEdit: () {},
            onDelete: () {},
            onSchedule: () => scheduleCalls++,
            preloadedStats: TemplateStats.empty(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Slidable), const Offset(140, 0));
    await tester.pumpAndSettle();

    expect(find.byType(DismissiblePane), findsOneWidget);

    final dismissiblePane = tester.widget<DismissiblePane>(
      find.byType(DismissiblePane),
    );
    final shouldDismiss = await dismissiblePane.confirmDismiss?.call();

    expect(shouldDismiss, isFalse);
    expect(scheduleCalls, 1);
    expect(find.text('Push Day'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
