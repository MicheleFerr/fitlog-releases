import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/toggle_dependency_validation.dart';

/// Mock class that uses the mixin for testing
class MockToggleDependencyWidget extends StatefulWidget {
  const MockToggleDependencyWidget({super.key});

  @override
  State<MockToggleDependencyWidget> createState() =>
      _MockToggleDependencyWidgetState();
}

class _MockToggleDependencyWidgetState extends State<MockToggleDependencyWidget>
    with ToggleDependencyValidation {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}

/// Helper to create MaterialApp with localizations for tests
Widget buildTestApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('it', 'IT'),
    ],
    home: child,
  );
}

void main() {
  group('ToggleDependencyValidation', () {
    group('validateAndEnableMaster', () {
      testWidgets('returns true when dependent enabled and master disabled',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.validateAndEnableMaster(
          dependent: true,
          master: false,
          masterName: 'RPE Tracking',
          context: context,
        );

        expect(result, true, reason: 'Master should be auto-enabled');
      });

      testWidgets('returns false when dependent disabled and master disabled',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.validateAndEnableMaster(
          dependent: false,
          master: false,
          masterName: 'RPE Tracking',
          context: context,
        );

        expect(result, false, reason: 'Master should stay disabled');
      });

      testWidgets('returns true when dependent enabled and master already enabled',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.validateAndEnableMaster(
          dependent: true,
          master: true,
          masterName: 'RPE Tracking',
          context: context,
        );

        expect(result, true, reason: 'Master should stay enabled');
      });

      testWidgets('returns false when both disabled', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.validateAndEnableMaster(
          dependent: false,
          master: false,
          masterName: 'RPE Tracking',
          context: context,
        );

        expect(result, false, reason: 'Master should stay disabled');
      });
    });

    group('autoDisableDependents', () {
      testWidgets('disables all dependents when master disabled',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.autoDisableDependents(
          master: false,
          dependents: {
            'autoAdjustWeightFromRpe': true,
            'autoAdjustRestFromRpe': true,
          },
          context: context,
        );

        expect(result['autoAdjustWeightFromRpe'], false,
            reason: 'Dependent 1 should be disabled');
        expect(result['autoAdjustRestFromRpe'], false,
            reason: 'Dependent 2 should be disabled');
      });

      testWidgets('keeps dependents unchanged when master enabled',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.autoDisableDependents(
          master: true,
          dependents: {
            'autoAdjustWeightFromRpe': true,
            'autoAdjustRestFromRpe': false,
          },
          context: context,
        );

        expect(result['autoAdjustWeightFromRpe'], true,
            reason: 'Dependent 1 should stay enabled');
        expect(result['autoAdjustRestFromRpe'], false,
            reason: 'Dependent 2 should stay disabled');
      });

      testWidgets('handles empty dependents map', (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.autoDisableDependents(
          master: false,
          dependents: {},
          context: context,
        );

        expect(result.isEmpty, true, reason: 'Empty map should stay empty');
      });

      testWidgets('disables all dependents when master disabled (mixed states)',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.autoDisableDependents(
          master: false,
          dependents: {
            'dep1': true,
            'dep2': false,
            'dep3': true,
          },
          context: context,
        );

        expect(result['dep1'], false);
        expect(result['dep2'], false);
        expect(result['dep3'], false);
      });
    });

    group('Edge Cases', () {
      testWidgets('validateAndEnableMaster handles null-like states',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        // Both false
        expect(
          state.validateAndEnableMaster(
            dependent: false,
            master: false,
            masterName: 'Test',
            context: context,
          ),
          false,
        );

        // Both true
        expect(
          state.validateAndEnableMaster(
            dependent: true,
            master: true,
            masterName: 'Test',
            context: context,
          ),
          true,
        );
      });

      testWidgets('autoDisableDependents handles single dependent',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            child: const MockToggleDependencyWidget(),
          ),
        );

        final context = tester.element(find.byType(MockToggleDependencyWidget));
        final state = tester.state<_MockToggleDependencyWidgetState>(
          find.byType(MockToggleDependencyWidget),
        );

        final result = state.autoDisableDependents(
          master: false,
          dependents: {'singleDep': true},
          context: context,
        );

        expect(result['singleDep'], false);
      });
    });
  });
}
