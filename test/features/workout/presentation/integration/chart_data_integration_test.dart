/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/presentation/integration
/// 🎯 Feature: workout
/// 🔧 Type: integration test (Chart Data Flow)
///
/// Dependencies:
/// - flutter_test: Integration testing
/// - mockito: Mocking Riverpod providers
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/chart_data_point.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_chart_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_metric_chart.dart';

void main() {
  group('Chart Data Integration Tests', () {
    testWidgets('should load and display chart data for Peso metric', (tester) async {
      // Arrange - Mock data
      final mockChartData = [
        ChartDataPoint(date: DateTime(2024, 1, 1), value: 80.0),
        ChartDataPoint(date: DateTime(2024, 1, 8), value: 85.0),
        ChartDataPoint(date: DateTime(2024, 1, 15), value: 90.0),
      ];

      // Create container with overridden provider
      final container = ProviderContainer(
        overrides: [
          exerciseChartCleanProvider.overrideWith((ref, params) async {
            // Simulate data loading delay
            await Future.delayed(const Duration(milliseconds: 100));
            return mockChartData;
          }),
        ],
      );

      // Act - Build widget with provider
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final chartDataAsync = ref.watch(
                    exerciseChartCleanProvider(
                      const ChartDataParams(
                        exerciseName: 'Bench Press',
                        metric: 'Peso',
                        days: 90,
                      ),
                    ),
                  );

                  return chartDataAsync.when(
                    data: (dataPoints) => ExerciseMetricChart(
                      dataPoints: dataPoints,
                      metric: 'Peso',
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Assert - Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async data to load
      await tester.pumpAndSettle();

      // Assert - Chart should be visible
      expect(find.byType(ExerciseMetricChart), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsOneWidget);

      // Should NOT show loading or error
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Error'), findsNothing);
    });

    testWidgets('should show empty state when no data available', (tester) async {
      // Arrange - Empty data
      final container = ProviderContainer(
        overrides: [
          exerciseChartCleanProvider.overrideWith((ref, params) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return []; // Empty list
          }),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final chartDataAsync = ref.watch(
                    exerciseChartCleanProvider(
                      const ChartDataParams(
                        exerciseName: 'Bench Press',
                        metric: 'Peso',
                        days: 90,
                      ),
                    ),
                  );

                  return chartDataAsync.when(
                    data: (dataPoints) => ExerciseMetricChart(
                      dataPoints: dataPoints,
                      metric: 'Peso',
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Wait for loading
      await tester.pumpAndSettle();

      // Assert - Empty state should be visible
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
      expect(find.text('No data available for this period'), findsOneWidget);
    });

    testWidgets('should handle error state gracefully', (tester) async {
      // Arrange - Simulate error
      final container = ProviderContainer(
        overrides: [
          exerciseChartCleanProvider.overrideWith((ref, params) async {
            await Future.delayed(const Duration(milliseconds: 100));
            throw Exception('Network error');
          }),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final chartDataAsync = ref.watch(
                    exerciseChartCleanProvider(
                      const ChartDataParams(
                        exerciseName: 'Bench Press',
                        metric: 'Peso',
                        days: 90,
                      ),
                    ),
                  );

                  return chartDataAsync.when(
                    data: (dataPoints) => ExerciseMetricChart(
                      dataPoints: dataPoints,
                      metric: 'Peso',
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text('Error loading chart'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Wait for error
      await tester.pumpAndSettle();

      // Assert - Error state should be visible
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Error loading chart'), findsOneWidget);
    });

    testWidgets('should update chart when metric changes', (tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          exerciseChartCleanProvider.overrideWith((ref, params) async {
            await Future.delayed(const Duration(milliseconds: 50));

            // Different data based on metric
            if (params.metric == 'Peso') {
              return [
                ChartDataPoint(date: DateTime(2024, 1, 1), value: 80.0),
                ChartDataPoint(date: DateTime(2024, 1, 8), value: 85.0),
              ];
            } else {
              return [
                ChartDataPoint(date: DateTime(2024, 1, 1), value: 10.0),
                ChartDataPoint(date: DateTime(2024, 1, 8), value: 12.0),
              ];
            }
          }),
        ],
      );

      String selectedMetric = 'Peso';

      // Act - Initial render with Peso
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  appBar: AppBar(
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedMetric = 'Reps';
                          });
                        },
                        child: const Text('Switch to Reps'),
                      ),
                    ],
                  ),
                  body: Consumer(
                    builder: (context, ref, child) {
                      final chartDataAsync = ref.watch(
                        exerciseChartCleanProvider(
                          ChartDataParams(
                            exerciseName: 'Bench Press',
                            metric: selectedMetric,
                            days: 90,
                          ),
                        ),
                      );

                      return chartDataAsync.when(
                        data: (dataPoints) => ExerciseMetricChart(
                          dataPoints: dataPoints,
                          metric: selectedMetric,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Wait for initial data
      await tester.pumpAndSettle();

      // Assert - Chart for Peso visible
      expect(find.byType(ExerciseMetricChart), findsOneWidget);

      // Act - Switch to Reps
      await tester.tap(find.text('Switch to Reps'));
      await tester.pump(); // Trigger rebuild

      // Should show loading briefly
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for new data
      await tester.pumpAndSettle();

      // Assert - Chart updated for Reps
      expect(find.byType(ExerciseMetricChart), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should cache data and avoid unnecessary rebuilds', (tester) async {
      int fetchCount = 0;

      final container = ProviderContainer(
        overrides: [
          exerciseChartCleanProvider.overrideWith((ref, params) async {
            fetchCount++;
            await Future.delayed(const Duration(milliseconds: 50));
            return [
              ChartDataPoint(date: DateTime(2024, 1, 1), value: 80.0),
            ];
          }),
        ],
      );

      // Act - First render
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final chartDataAsync = ref.watch(
                    exerciseChartCleanProvider(
                      const ChartDataParams(
                        exerciseName: 'Bench Press',
                        metric: 'Peso',
                        days: 90,
                      ),
                    ),
                  );

                  return chartDataAsync.when(
                    data: (dataPoints) => ExerciseMetricChart(
                      dataPoints: dataPoints,
                      metric: 'Peso',
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Data fetched once
      expect(fetchCount, 1);

      // Act - Rebuild same widget (should use cache)
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final chartDataAsync = ref.watch(
                    exerciseChartCleanProvider(
                      const ChartDataParams(
                        exerciseName: 'Bench Press',
                        metric: 'Peso',
                        days: 90,
                      ),
                    ),
                  );

                  return chartDataAsync.when(
                    data: (dataPoints) => ExerciseMetricChart(
                      dataPoints: dataPoints,
                      metric: 'Peso',
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Still fetched only once (cached)
      expect(fetchCount, 1);
    });
  });
}
