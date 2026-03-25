import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

class _TestNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount++;
    super.didPush(route, previousRoute);
  }
}

class _NestedNavigatorHost extends StatelessWidget {
  const _NestedNavigatorHost({
    required this.observer,
    required this.useRootNavigator,
  });

  final NavigatorObserver observer;
  final bool useRootNavigator;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [observer],
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (nestedContext) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                ModalService.showSheet<void>(
                  nestedContext,
                  useRootNavigator: useRootNavigator,
                  builder: (sheetContext) => Material(
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Sheet content'),
                          TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open sheet'),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUp(() {
    ModalService.openSheetCount.value = 0;
  });

  testWidgets('showSheet pushes on nested navigator by default', (
    tester,
  ) async {
    final rootObserver = _TestNavigatorObserver();
    final nestedObserver = _TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [rootObserver],
        home: _NestedNavigatorHost(
          observer: nestedObserver,
          useRootNavigator: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final initialRootPushes = rootObserver.pushCount;
    final initialNestedPushes = nestedObserver.pushCount;

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsOneWidget);
    expect(rootObserver.pushCount, initialRootPushes);
    expect(nestedObserver.pushCount, initialNestedPushes + 1);
    expect(ModalService.openSheetCount.value, 1);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(ModalService.openSheetCount.value, 0);
  });

  testWidgets('showSheet can push on root navigator when requested', (
    tester,
  ) async {
    final rootObserver = _TestNavigatorObserver();
    final nestedObserver = _TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [rootObserver],
        home: _NestedNavigatorHost(
          observer: nestedObserver,
          useRootNavigator: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final initialRootPushes = rootObserver.pushCount;
    final initialNestedPushes = nestedObserver.pushCount;

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsOneWidget);
    expect(rootObserver.pushCount, initialRootPushes + 1);
    expect(nestedObserver.pushCount, initialNestedPushes);
    expect(ModalService.openSheetCount.value, 1);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(ModalService.openSheetCount.value, 0);
  });
}
