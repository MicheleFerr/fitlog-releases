import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/legal_documents_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('LegalDocumentsScreen', () {
    testWidgets('displays 3 legal document options', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('displays Privacy Policy list item', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      // Find by text (localized strings will be used)
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('How we handle your data (GDPR compliant)'), findsOneWidget);
    });

    testWidgets('displays Terms of Service list item', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('User agreements and liability limitations'), findsOneWidget);
    });

    testWidgets('displays Medical Disclaimer list item', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      expect(find.text('Medical Disclaimer'), findsOneWidget);
      expect(find.text('Important safety information'), findsOneWidget);
    });

    testWidgets('all list items have trailing chevron icons', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      // Find all Icon widgets with chevronRight
      final chevronIcons = tester.widgetList<Icon>(find.byType(Icon)).where(
        (icon) => icon.icon == AppIcons.chevronRight,
      );

      expect(chevronIcons.length, greaterThanOrEqualTo(3));
    });

    testWidgets('list items are tappable', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      // Verify first ListTile can be tapped without crashing
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // If navigation works, no exception should be thrown
    });

    testWidgets('screen has correct title', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      expect(find.text('Legal Documents'), findsOneWidget);
    });

    testWidgets('Privacy Policy uses correct icon', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      // Find the first ListTile (Privacy Policy)
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      final firstListTile = listTiles.first;

      // Check leading icon
      final leadingIcon = firstListTile.leading as Icon;
      expect(
        leadingIcon.icon,
        anyOf([
          AppIcons.privacyTipRounded,
          AppIcons.security,
          AppIcons.shield,
        ]),
      );
    });

    testWidgets('Medical Disclaimer uses warning/health icon', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const LegalDocumentsScreen()));

      // Find the third ListTile (Medical Disclaimer)
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      final thirdListTile = listTiles.elementAt(2);

      // Check leading icon
      final leadingIcon = thirdListTile.leading as Icon;
      expect(
        leadingIcon.icon,
        anyOf([
          AppIcons.healthAndSafety,
          AppIcons.warning,
          AppIcons.warningAmber,
        ]),
      );
    });
  });
}
