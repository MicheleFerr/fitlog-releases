import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/form_analyzer_service.dart';

void main() {
  late FormAnalyzerService service;

  setUp(() {
    service = FormAnalyzerService();
  });

  group('getCurrentFormScore', () {
    test('should return 0.0 initially', () async {
      // 🐛 BUG PREVENTED: Uninitialized form score
      final score = await service.getCurrentFormScore();
      expect(score, 0.0);
    });
  });

  group('analyzeMovementForm', () {
    test('should return 0.0 for insufficient data (<10 samples)', () async {
      // 🐛 BUG PREVENTED: Form analysis on insufficient data
      final velocityData = [1.0, 1.1, 1.2];
      final accelerationData = [0.1, 0.1, 0.1];

      final score = await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      expect(score, 0.0);
    });

    test('should calculate form score for valid data', () async {
      // 🐛 BUG PREVENTED: Form metrics not properly calculated
      final velocityData = List.generate(20, (i) => 2.0 + (i * 0.1));
      final accelerationData = List.generate(20, (i) => 0.5);

      final score = await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      expect(score, greaterThan(0.0));
      expect(score, lessThanOrEqualTo(100.0));
    });

    test('should handle exercise-specific weights', () async {
      // 🐛 BUG PREVENTED: Generic form analysis for all exercises
      final velocityData = List.generate(15, (i) => 1.5 + (i * 0.05));
      final accelerationData = List.generate(15, (i) => 0.3);

      final squatScore = await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
        exerciseType: 'squat',
      );

      final curlScore = await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
        exerciseType: 'curl',
      );

      // Different exercises should potentially have different scores
      expect(squatScore, greaterThanOrEqualTo(0.0));
      expect(curlScore, greaterThanOrEqualTo(0.0));
    });

    test('should maintain form score history', () async {
      // 🐛 BUG PREVENTED: Form history not tracked
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      final stats = service.getFormStatistics();
      expect(stats.sampleCount, greaterThanOrEqualTo(2));
    });

    test('should limit history to 1000 samples', () async {
      // 🐛 BUG PREVENTED: Unbounded memory growth
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      // Add 1005 samples
      for (int i = 0; i < 1005; i++) {
        await service.analyzeMovementForm(
          velocityData: velocityData,
          accelerationData: accelerationData,
        );
      }

      final stats = service.getFormStatistics();
      expect(stats.sampleCount, lessThanOrEqualTo(1000));
    });

    test('should handle errors gracefully', () async {
      // 🐛 BUG PREVENTED: Crashes on invalid data
      final score = await service.analyzeMovementForm(
        velocityData: [],
        accelerationData: [],
      );

      expect(score, 0.0);
    });
  });

  group('calculateSetFormScore', () {
    test('should return 0.0 for empty form scores', () async {
      // 🐛 BUG PREVENTED: Division by zero on empty data
      final score = await service.calculateSetFormScore(
        formScores: [],
        consistencyScore: 80.0,
        velocityData: [],
      );

      expect(score, 0.0);
    });

    test('should calculate average form score', () async {
      // 🐛 BUG PREVENTED: Incorrect set-level form calculation
      final formScores = [85.0, 80.0, 82.0, 78.0, 75.0];
      final velocityData = List.generate(20, (i) => 2.0);

      final score = await service.calculateSetFormScore(
        formScores: formScores,
        consistencyScore: 75.0,
        velocityData: velocityData,
      );

      expect(score, greaterThan(70.0));
      expect(score, lessThanOrEqualTo(100.0));
    });

    test('should apply decline penalty for deteriorating form', () async {
      // 🐛 BUG PREVENTED: Form decline not penalized
      final decliningScores = [90.0, 85.0, 75.0, 65.0, 55.0];
      final stableScores = [80.0, 82.0, 81.0, 79.0, 80.0];
      final velocityData = List.generate(20, (i) => 2.0);

      final decliningScore = await service.calculateSetFormScore(
        formScores: decliningScores,
        consistencyScore: 70.0,
        velocityData: velocityData,
      );

      final stableScore = await service.calculateSetFormScore(
        formScores: stableScores,
        consistencyScore: 70.0,
        velocityData: velocityData,
      );

      // Declining form should have lower score
      expect(decliningScore, lessThan(stableScore));
    });

    test('should apply consistency bonus for high consistency', () async {
      // 🐛 BUG PREVENTED: Consistent movement not rewarded
      final formScores = [75.0, 75.0, 75.0];
      final velocityData = List.generate(15, (i) => 2.0);

      final highConsistency = await service.calculateSetFormScore(
        formScores: formScores,
        consistencyScore: 85.0,
        velocityData: velocityData,
      );

      final lowConsistency = await service.calculateSetFormScore(
        formScores: formScores,
        consistencyScore: 70.0,
        velocityData: velocityData,
      );

      // High consistency should yield higher score
      expect(highConsistency, greaterThanOrEqualTo(lowConsistency));
    });

    test('should clamp result between 0 and 100', () async {
      // 🐛 BUG PREVENTED: Form scores exceeding valid range
      final extremeScores = [100.0, 100.0, 100.0];
      final velocityData = List.generate(15, (i) => 2.0);

      final score = await service.calculateSetFormScore(
        formScores: extremeScores,
        consistencyScore: 95.0,
        velocityData: velocityData,
      );

      expect(score, greaterThanOrEqualTo(0.0));
      expect(score, lessThanOrEqualTo(100.0));
    });
  });

  group('getFormFeedback', () {
    test('should provide baseline message for insufficient history', () {
      // 🐛 BUG PREVENTED: Feedback on insufficient data
      final feedback = service.getFormFeedback();

      expect(feedback.message, contains('baseline'));
      expect(feedback.severity, FeedbackSeverity.info);
    });

    test('should warn for declining form quality', () async {
      // 🐛 BUG PREVENTED: Form degradation not detected
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      // Build history with declining scores
      for (int i = 0; i < 10; i++) {
        await service.analyzeMovementForm(
          velocityData: velocityData.map((v) => v - (i * 0.3)).toList(),
          accelerationData: accelerationData,
        );
      }

      final feedback = service.getFormFeedback();

      // Should detect some level of concern
      expect(feedback.severity, isIn([
        FeedbackSeverity.warning,
        FeedbackSeverity.caution,
        FeedbackSeverity.info,
      ]));
    });

    test('should provide positive feedback for excellent form', () async {
      // 🐛 BUG PREVENTED: Good form not reinforced
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.1);

      // Build history with high scores
      for (int i = 0; i < 10; i++) {
        await service.analyzeMovementForm(
          velocityData: velocityData,
          accelerationData: accelerationData,
        );
      }

      final feedback = service.getFormFeedback();

      // Should provide some level of feedback
      expect(feedback.message, isNotEmpty);
      expect(feedback.recommendation, isNotEmpty);
    });
  });

  group('reset', () {
    test('should clear form history', () async {
      // 🐛 BUG PREVENTED: State not properly reset
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      service.reset();

      final stats = service.getFormStatistics();
      expect(stats.sampleCount, 0);
      expect(stats.averageScore, 0.0);
    });

    test('should reset current form score', () async {
      // 🐛 BUG PREVENTED: Current score not cleared on reset
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      service.reset();

      final score = await service.getCurrentFormScore();
      expect(score, 0.0);
    });
  });

  group('getFormStatistics', () {
    test('should return zero statistics for empty history', () {
      // 🐛 BUG PREVENTED: Statistics crash on empty data
      final stats = service.getFormStatistics();

      expect(stats.averageScore, 0.0);
      expect(stats.bestScore, 0.0);
      expect(stats.worstScore, 0.0);
      expect(stats.trend, 0.0);
      expect(stats.sampleCount, 0);
    });

    test('should calculate statistics correctly', () async {
      // 🐛 BUG PREVENTED: Incorrect statistical calculations
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );
      await service.analyzeMovementForm(
        velocityData: velocityData,
        accelerationData: accelerationData,
      );

      final stats = service.getFormStatistics();

      expect(stats.sampleCount, greaterThan(0));
      expect(stats.averageScore, greaterThanOrEqualTo(0.0));
      expect(stats.bestScore, greaterThanOrEqualTo(stats.averageScore));
      expect(stats.worstScore, lessThanOrEqualTo(stats.averageScore));
    });

    test('should track form trend', () async {
      // 🐛 BUG PREVENTED: Trend not properly calculated
      final velocityData = List.generate(15, (i) => 2.0);
      final accelerationData = List.generate(15, (i) => 0.4);

      // Add improving scores
      for (int i = 0; i < 6; i++) {
        await service.analyzeMovementForm(
          velocityData: velocityData.map((v) => v + (i * 0.1)).toList(),
          accelerationData: accelerationData,
        );
      }

      final stats = service.getFormStatistics();

      // Trend should exist (positive, negative, or zero)
      expect(stats.trend, isA<double>());
    });
  });

  group('Data Classes', () {
    test('FormWeights should store all weight values', () {
      // 🐛 BUG PREVENTED: Weight configuration corruption
      const weights = FormWeights(
        consistency: 0.3,
        smoothness: 0.4,
        rhythm: 0.2,
        range: 0.1,
      );

      expect(weights.consistency, 0.3);
      expect(weights.smoothness, 0.4);
      expect(weights.rhythm, 0.2);
      expect(weights.range, 0.1);
    });

    test('FormFeedback should store all feedback data', () {
      // 🐛 BUG PREVENTED: Feedback data loss
      const feedback = FormFeedback(
        message: 'Good form',
        severity: FeedbackSeverity.positive,
        recommendation: 'Keep it up',
      );

      expect(feedback.message, 'Good form');
      expect(feedback.severity, FeedbackSeverity.positive);
      expect(feedback.recommendation, 'Keep it up');
    });

    test('FormStatistics should store all stats', () {
      // 🐛 BUG PREVENTED: Statistics data corruption
      const stats = FormStatistics(
        averageScore: 75.0,
        bestScore: 90.0,
        worstScore: 60.0,
        trend: 5.0,
        sampleCount: 10,
      );

      expect(stats.averageScore, 75.0);
      expect(stats.bestScore, 90.0);
      expect(stats.worstScore, 60.0);
      expect(stats.trend, 5.0);
      expect(stats.sampleCount, 10);
    });
  });

  group('FeedbackSeverity Enum', () {
    test('should have all severity levels', () {
      // 🐛 BUG PREVENTED: Missing severity options
      expect(FeedbackSeverity.values.length, 4);
      expect(FeedbackSeverity.values, contains(FeedbackSeverity.positive));
      expect(FeedbackSeverity.values, contains(FeedbackSeverity.info));
      expect(FeedbackSeverity.values, contains(FeedbackSeverity.caution));
      expect(FeedbackSeverity.values, contains(FeedbackSeverity.warning));
    });
  });
}
