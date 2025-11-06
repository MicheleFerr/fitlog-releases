import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';

/// Creates mock historical sets with specified data quality
///
/// [count]: Number of historical sets to generate
/// [daysOld]: How many days ago the oldest set was performed
/// [baseWeight]: Base weight for calculations
/// [weightVariation]: Amount of variation in weights (SD simulation)
List<Map<String, dynamic>> createMockHistoricalSets({
  required int count,
  required int daysOld,
  required double baseWeight,
  required double weightVariation,
}) {
  final now = DateTime.now();
  final random = Random(42); // Deterministic for testing

  return List.generate(count, (i) {
    final variation = (random.nextDouble() - 0.5) * weightVariation * 2;
    final completedDate = now.subtract(Duration(days: daysOld - i)); // Most recent first
    return {
      'weight': baseWeight + variation,
      'reps': 5 + random.nextInt(3), // 5-7 reps
      'completedAt': completedDate.toIso8601String(), // DateTime as string for JSON
      'setNumber': i + 1,
      'isCompleted': true,
    };
  });
}

/// Creates historical sets with very high confidence
/// (12 points, 1 day old, low variation)
List<Map<String, dynamic>> createVeryHighConfidenceSets() {
  return createMockHistoricalSets(
    count: 12,
    daysOld: 1,
    baseWeight: 100.0,
    weightVariation: 2.5, // Low SD (2.5% of 100kg)
  );
}

/// Creates historical sets with medium confidence
/// (5 points, 20 days old, medium variation)
List<Map<String, dynamic>> createMediumConfidenceSets() {
  return createMockHistoricalSets(
    count: 5,
    daysOld: 20,
    baseWeight: 100.0,
    weightVariation: 7.5, // Medium SD (7.5% of 100kg)
  );
}

/// Creates historical sets with low confidence
/// (3 points, 50 days old, high variation)
List<Map<String, dynamic>> createLowConfidenceSets() {
  return createMockHistoricalSets(
    count: 3,
    daysOld: 50,
    baseWeight: 100.0,
    weightVariation: 15.0, // High SD (15% of 100kg)
  );
}

/// Wraps widget with MaterialApp + Riverpod for integration testing
Widget wrapForIntegrationTest(
  Widget child, {
  List<Override>? overrides,
  ThemeMode? themeMode,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode ?? ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Creates a mock workout for testing
Workout createMockWorkout({
  String? id,
  String? name,
  DateTime? startTime,
  DateTime? endTime,
  WorkoutStatus? status,
}) {
  final now = DateTime.now();
  return Workout(
    id: id ?? 'test_workout_id',
    name: name ?? 'Test Workout',
    startTime: startTime ?? now,
    endTime: endTime,
    status: status ?? WorkoutStatus.inProgress,
    createdAt: now,
    updatedAt: now,
  );
}

/// Extension for easier test assertions
extension IntegrationTestExtensions on WidgetTester {
  /// Waits for widget to appear with timeout
  Future<void> waitForWidget(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      await pump();
      if (finder.evaluate().isNotEmpty) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    throw Exception('Widget not found: $finder');
  }

  /// Waits for text to appear with timeout
  Future<void> waitForText(
    String text, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitForWidget(find.text(text), timeout: timeout);
  }

  /// Pumps and settles with timeout
  Future<void> pumpAndSettleWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      await pumpAndSettle(timeout);
    } catch (e) {
      // If timeout, just pump once
      await pump();
    }
  }
}

/// Mock data for APRE-6 expected weights
class APRE6ExpectedWeights {
  static const set1PercentageOfMax = 0.50; // 50% for Set 1
  static const set2PercentageOfMax = 0.75; // 75% for Set 2
  static const set3PercentageOfMax = 1.00; // 100% for Set 3

  static double getSet1Weight(double oneRM) => oneRM * set1PercentageOfMax;
  static double getSet2Weight(double oneRM) => oneRM * set2PercentageOfMax;
  static double getSet3Weight(double oneRM) => oneRM * set3PercentageOfMax;
}

/// Mock data for APRE-10 expected weights
class APRE10ExpectedWeights {
  static const set1PercentageOfMax = 0.50; // 50% for Set 1
  static const set2PercentageOfMax = 0.75; // 75% for Set 2
  static const set3PercentageOfMax = 1.00; // 100% for Set 3

  static double getSet1Weight(double oneRM) => oneRM * set1PercentageOfMax;
  static double getSet2Weight(double oneRM) => oneRM * set2PercentageOfMax;
  static double getSet3Weight(double oneRM) => oneRM * set3PercentageOfMax;
}

/// Helper to verify APRE weight calculations
class APREWeightVerifier {
  /// Verifies weights match expected APRE-6 protocol
  static void verifyAPRE6Weights(
    List<double> actualWeights,
    double oneRM, {
    double tolerance = 0.5,
  }) {
    expect(actualWeights.length, greaterThanOrEqualTo(3));

    expect(
      actualWeights[0],
      closeTo(APRE6ExpectedWeights.getSet1Weight(oneRM), tolerance),
    );
    expect(
      actualWeights[1],
      closeTo(APRE6ExpectedWeights.getSet2Weight(oneRM), tolerance),
    );
    expect(
      actualWeights[2],
      closeTo(APRE6ExpectedWeights.getSet3Weight(oneRM), tolerance),
    );
  }

  /// Verifies weights match expected APRE-10 protocol
  static void verifyAPRE10Weights(
    List<double> actualWeights,
    double oneRM, {
    double tolerance = 0.5,
  }) {
    expect(actualWeights.length, greaterThanOrEqualTo(3));

    expect(
      actualWeights[0],
      closeTo(APRE10ExpectedWeights.getSet1Weight(oneRM), tolerance),
    );
    expect(
      actualWeights[1],
      closeTo(APRE10ExpectedWeights.getSet2Weight(oneRM), tolerance),
    );
    expect(
      actualWeights[2],
      closeTo(APRE10ExpectedWeights.getSet3Weight(oneRM), tolerance),
    );
  }

  /// Verifies confidence level matches expected quality metrics
  static void verifyConfidenceLevel({
    required CalculationConfidence actual,
    required CalculationConfidence expected,
  }) {
    expect(actual, expected,
        reason:
            'Expected confidence $expected but got $actual. This indicates data quality metrics do not match expected thresholds.');
  }
}
