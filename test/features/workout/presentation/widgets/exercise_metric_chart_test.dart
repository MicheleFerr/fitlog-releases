/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget test (ExerciseMetricChart)
///
/// Dependencies:
/// - flutter_test: Widget testing
/// - fl_chart: Chart widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_metric_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

void main() {
  // Helper to wrap widget with required localizations
  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
      ],
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ExerciseMetricChart Widget Tests', () {
    testWidgets('should show empty state when dataPoints is empty', (tester) async {
      // Arrange
      const widget = ExerciseMetricChart(
        dataPoints: [],
        metric: 'Peso',
      );

      // Act
      await tester.pumpWidget(wrapWithApp(widget));

      // Assert
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
      expect(find.text('No data available for this period'), findsOneWidget);
    });

    testWidgets('should render chart when dataPoints has data', (tester) async {
      // Arrange
      final dataPoints = [
        ChartDataPoint(date: DateTime(2024, 1, 1), value: 80.0),
        ChartDataPoint(date: DateTime(2024, 1, 8), value: 85.0),
        ChartDataPoint(date: DateTime(2024, 1, 15), value: 90.0),
      ];

      final widget = ExerciseMetricChart(
        dataPoints: dataPoints,
        metric: 'Peso',
      );

      // Act
      await tester.pumpWidget(wrapWithApp(widget));

      // Assert - Chart container should exist
      expect(find.byType(Container), findsWidgets);

      // Should NOT show empty state
      expect(find.text('No data available for this period'), findsNothing);
    });

    testWidgets('should wrap chart in RepaintBoundary for performance', (tester) async {
      // Arrange
      final dataPoints = [
        ChartDataPoint(date: DateTime(2024, 1, 1), value: 80.0),
      ];

      final widget = ExerciseMetricChart(
        dataPoints: dataPoints,
        metric: 'Peso',
      );

      // Act
      await tester.pumpWidget(wrapWithApp(widget));

      // Assert - Should have RepaintBoundary for performance
      expect(find.byType(RepaintBoundary), findsOneWidget);
    });

    testWidgets('should handle single data point', (tester) async {
      // Arrange
      final dataPoints = [
        ChartDataPoint(date: DateTime(2024, 1, 1), value: 100.0),
      ];

      final widget = ExerciseMetricChart(
        dataPoints: dataPoints,
        metric: 'Peso',
      );

      // Act
      await tester.pumpWidget(wrapWithApp(widget));

      // Assert - Should render without errors
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle many data points', (tester) async {
      // Arrange - 100 data points
      final dataPoints = List.generate(
        100,
        (i) => ChartDataPoint(
          date: DateTime(2024, 1, 1).add(Duration(days: i)),
          value: 80.0 + i * 0.5,
        ),
      );

      final widget = ExerciseMetricChart(
        dataPoints: dataPoints,
        metric: 'Peso',
      );

      // Act
      await tester.pumpWidget(wrapWithApp(widget));

      // Assert - Should render without errors
      expect(find.byType(RepaintBoundary), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state should be centered', (tester) async {
      // Arrange
      const widget = ExerciseMetricChart(
        dataPoints: [],
        metric: 'Peso',
      );

      // Act
      await tester.pumpWidget(wrapWithApp(widget));

      // Assert
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });
  });
}
