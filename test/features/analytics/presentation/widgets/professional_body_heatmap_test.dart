import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

Widget _buildTestWidget({required Locale locale}) {
  final svgString = File('assets/images/human_body.svg').readAsStringSync();

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 240,
          height: 400,
          child: ProfessionalBodyHeatmap(
            heatValues: MuscleHeatValues({'chest': 100, 'trapezius': 60}),
            showLegend: false,
            svgSourceLoader: () async => svgString,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfessionalBodyHeatmap', () {
    testWidgets(
      'shows localized muscle name in Italian without shrinking the canvas',
      (tester) async {
        await tester.pumpWidget(_buildTestWidget(locale: const Locale('it')));
        for (
          var i = 0;
          i < 20 &&
              find
                  .descendant(
                    of: find.byType(ProfessionalBodyHeatmap),
                    matching: find.byType(GestureDetector),
                  )
                  .evaluate()
                  .isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        final heatmapGestureDetector = find.descendant(
          of: find.byType(ProfessionalBodyHeatmap),
          matching: find.byType(GestureDetector),
        );
        expect(heatmapGestureDetector, findsOneWidget);

        final canvas = find.descendant(
          of: heatmapGestureDetector,
          matching: find.byType(CustomPaint),
        );
        expect(canvas, findsOneWidget);

        final sizeBefore = tester.getSize(canvas);
        final topLeft = tester.getTopLeft(canvas);
        final tapCandidates = <Offset>[
          for (final xFactor in [0.20, 0.24, 0.28, 0.32, 0.36, 0.40])
            for (final yFactor in [0.20, 0.24, 0.28, 0.32, 0.36])
              Offset(sizeBefore.width * xFactor, sizeBefore.height * yFactor),
        ];

        var selectedChest = false;
        for (final candidate in tapCandidates) {
          await tester.tapAt(topLeft + candidate);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 250));
          if (find.text('Pettorali').evaluate().isNotEmpty) {
            selectedChest = true;
            break;
          }
        }

        expect(selectedChest, isTrue);

        final sizeAfter = tester.getSize(canvas);
        expect(sizeAfter.width, sizeBefore.width);
        expect(sizeAfter.height, sizeBefore.height);
      },
    );
  });
}
