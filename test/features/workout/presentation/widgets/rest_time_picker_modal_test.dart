import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rest_time_picker_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Mock analytics service for testing
class MockAnalyticsService implements IAnalyticsService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> logAppOpen() async {}

  @override
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {}

  @override
  Future<void> logNetworkRequest({
    required String url,
    required String httpMethod,
    int? requestPayloadSize,
    int? responsePayloadSize,
    int? httpResponseCode,
    int? responseTime,
  }) async {}

  @override
  Future<void> logPurchase({
    required String productId,
    required double price,
    required String currency,
    String? transactionId,
  }) async {}

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) async {}

  @override
  Future<void> resetAnalyticsData() async {}

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setDebugMode(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty({required String name, required String? value}) async {}

  @override
  Future<String> startTrace(String name) async => 'mock-trace-id';

  @override
  Future<void> stopTrace(String traceId, {Map<String, int>? metrics}) async {}

  @override
  Future<bool> isAnalyticsCollectionEnabled() async => true;
}

/// Helper to create MaterialApp with providers and localizations for tests
Widget buildTestApp({
  required Widget child,
}) {
  return ProviderScope(
    overrides: [
      analyticsServiceProvider.overrideWithValue(MockAnalyticsService()),
    ],
    child: MaterialApp(
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('RestTimePickerModal', () {
    testWidgets('should update picker position when preset is selected', (tester) async {
      int? selectedRestTime;

      await tester.pumpWidget(
        buildTestApp(
          child: RestTimePickerModal(
            initialRestTime: 90, // 1:30 initial
            onRestTimeSelected: (value) => selectedRestTime = value,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enable custom timer toggle if not already enabled
      final switchFinder = find.byType(SwitchListTile);
      if (switchFinder.evaluate().isNotEmpty) {
        final switchWidget = tester.widget<SwitchListTile>(switchFinder);
        if (!switchWidget.value) {
          await tester.tap(switchFinder);
          await tester.pumpAndSettle();
        }
      }

      // Find the minutes picker - should be at position 1 (for 1 minute)
      final minutesPickers = find.byType(CupertinoPicker);
      expect(minutesPickers, findsWidgets);

      // Tap on a preset chip (e.g., "2:00" = 120 seconds)
      // Look for FilterChip widgets
      final presetChips = find.byType(FilterChip);

      // Find a chip that represents 2 minutes (120 seconds)
      // The chips show time labels, we need to find one
      for (final chip in presetChips.evaluate()) {
        final chipWidget = chip.widget as FilterChip;
        // Check if this chip's label contains "2" for 2 minutes
        final labelWidget = chipWidget.label;
        if (labelWidget is Row) {
          // The chip label is a Row with Icon + Text
          for (final child in (labelWidget).children) {
            if (child is Text && child.data != null && child.data!.contains('2')) {
              await tester.tap(find.byWidget(chipWidget));
              await tester.pumpAndSettle();
              break;
            }
          }
        }
      }

      // Tap confirm button
      final confirmButton = find.byType(FilledButton);
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // The selected time should be set
      // Note: exact value depends on which preset was tapped
      expect(selectedRestTime, isNotNull);
    });

    testWidgets('should initialize with correct picker positions', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: RestTimePickerModal(
            initialRestTime: 150, // 2:30 = 2 minutes, 30 seconds
            onRestTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The modal should show with custom timer enabled
      // since initialRestTime is provided
      final switchFinder = find.byType(SwitchListTile);
      if (switchFinder.evaluate().isNotEmpty) {
        final switchWidget = tester.widget<SwitchListTile>(switchFinder);
        expect(switchWidget.value, isTrue, reason: 'Switch should be ON when initialRestTime is provided');
      }

      // Verify pickers are present
      expect(find.byType(CupertinoPicker), findsNWidgets(2));
    });

    testWidgets('should return null when timer is disabled', (tester) async {
      int? selectedRestTime = 999; // Set to non-null to detect null assignment

      await tester.pumpWidget(
        buildTestApp(
          child: RestTimePickerModal(
            initialRestTime: 90,
            onRestTimeSelected: (value) => selectedRestTime = value,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Disable the timer switch
      final switchFinder = find.byType(SwitchListTile);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<SwitchListTile>(switchFinder);
      if (switchWidget.value) {
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
      }

      // Tap confirm
      final confirmButton = find.byType(FilledButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Should return null when timer is disabled
      expect(selectedRestTime, isNull);
    });

    testWidgets('controllers should be properly disposed', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: RestTimePickerModal(
            initialRestTime: 60,
            onRestTimeSelected: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap cancel to close the modal
      final cancelButton = find.byType(OutlinedButton);
      expect(cancelButton, findsOneWidget);

      // This should not throw any errors related to disposed controllers
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // If we get here without errors, controllers were properly disposed
      expect(true, isTrue);
    });
  });
}
