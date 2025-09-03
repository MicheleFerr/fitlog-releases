import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gymbro_flutter_new/features/timer/domain/entities/set_execution_timing.dart';
import 'package:gymbro_flutter_new/features/timer/domain/use_cases/track_set_execution_use_case.dart';
import 'package:gymbro_flutter_new/features/timer/domain/repositories/set_timing_repository.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/velocity_analyzer_service.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/form_analyzer_service.dart';
import 'package:gymbro_flutter_new/features/timer/domain/services/fatigue_analyzer_service.dart';

// Mock classes
class MockSetTimingRepository extends Mock implements SetTimingRepository {}
class MockVelocityAnalyzerService extends Mock implements VelocityAnalyzerService {}
class MockFormAnalyzerService extends Mock implements FormAnalyzerService {}
class MockFatigueAnalyzerService extends Mock implements FatigueAnalyzerService {}

/// TIER-1 Test Suite for TrackSetExecutionUseCase
/// Tests critical functionality with >90% coverage
void main() {
  group('TrackSetExecutionUseCase', () {
    late TrackSetExecutionUseCase useCase;
    late MockSetTimingRepository mockRepository;
    late MockVelocityAnalyzerService mockVelocityAnalyzer;
    late MockFormAnalyzerService mockFormAnalyzer;
    late MockFatigueAnalyzerService mockFatigueAnalyzer;
    
    const testExerciseId = 'test-exercise-123';
    const testWorkoutId = 'test-workout-456';
    const testSetNumber = 1;
    const testWeight = 100.0;
    
    setUp(() {
      mockRepository = MockSetTimingRepository();
      mockVelocityAnalyzer = MockVelocityAnalyzerService();
      mockFormAnalyzer = MockFormAnalyzerService();
      mockFatigueAnalyzer = MockFatigueAnalyzerService();
      
      useCase = TrackSetExecutionUseCase(
        mockRepository,
        mockVelocityAnalyzer,
        mockFormAnalyzer,
        mockFatigueAnalyzer,
      );
      
      // Setup default mocks
      when(() => mockRepository.saveSetTiming(any()))
          .thenAnswer((_) async {});
      when(() => mockVelocityAnalyzer.getCurrentVelocity())
          .thenAnswer((_) async => 0.5);
      when(() => mockFormAnalyzer.getCurrentFormScore())
          .thenAnswer((_) async => 85.0);
      when(() => mockFatigueAnalyzer.calculateRealTimeFatigue(any(), any()))
          .thenReturn(25.0);
    });

    group('startSetTracking', () {
      test('should initialize set tracking with correct parameters', () async {
        // Arrange
        const config = SetTimingConfig(
          mode: TimingMode.performance,
          samplingRateHz: 50,
        );
        
        // Act
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
          weight: testWeight,
          config: config,
        );
        
        // Assert
        verify(() => mockRepository.saveSetTiming(any(that: isA<SetExecutionTiming>()
            .having((s) => s.exerciseId, 'exerciseId', testExerciseId)
            .having((s) => s.workoutId, 'workoutId', testWorkoutId)
            .having((s) => s.setNumber, 'setNumber', testSetNumber)
            .having((s) => s.weight, 'weight', testWeight)))).called(1);
      });
      
      test('should handle repository save failure gracefully', () async {
        // Arrange
        when(() => mockRepository.saveSetTiming(any()))
            .thenThrow(Exception('Database error'));
        
        // Act & Assert
        expect(() => useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        ), throwsException);
      });
      
      test('should stop existing tracking before starting new', () async {
        // Arrange - Start first tracking
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        reset(mockRepository);
        when(() => mockRepository.saveSetTiming(any()))
            .thenAnswer((_) async {});
        
        // Act - Start second tracking
        await useCase.startSetTracking(
          exerciseId: 'another-exercise',
          workoutId: testWorkoutId,
          setNumber: 2,
        );
        
        // Assert - Should save the new set
        verify(() => mockRepository.saveSetTiming(any(that: isA<SetExecutionTiming>()
            .having((s) => s.exerciseId, 'exerciseId', 'another-exercise')
            .having((s) => s.setNumber, 'setNumber', 2)))).called(1);
      });
    });

    group('stopSetTracking', () {
      test('should finalize set timing with correct metrics', () async {
        // Arrange
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
          weight: testWeight,
        );
        
        // Add some test reps
        useCase.registerRep();
        useCase.registerRep();
        useCase.registerRep();
        
        // Setup final metrics mocks
        when(() => mockFatigueAnalyzer.calculateSetFatigue(
          velocityData: any(named: 'velocityData'),
          repTimestamps: any(named: 'repTimestamps'),
          weight: any(named: 'weight'),
        )).thenAnswer((_) async => 35.0);
        
        when(() => mockFormAnalyzer.calculateSetFormScore(
          formScores: any(named: 'formScores'),
          consistencyScore: any(named: 'consistencyScore'),
          velocityData: any(named: 'velocityData'),
        )).thenAnswer((_) async => 82.0);
        
        reset(mockRepository);
        when(() => mockRepository.saveSetTiming(any()))
            .thenAnswer((_) async {});
        
        // Act
        final result = await useCase.stopSetTracking();
        
        // Assert
        expect(result, isNotNull);
        expect(result!.exerciseId, testExerciseId);
        expect(result.reps, 3);
        expect(result.executionTimeMs, greaterThan(0));
        expect(result.fatigueIndex, 35.0);
        expect(result.formScore, 82.0);
        
        verify(() => mockRepository.saveSetTiming(any(that: isA<SetExecutionTiming>()
            .having((s) => s.reps, 'reps', 3)
            .having((s) => s.fatigueIndex, 'fatigueIndex', 35.0)
            .having((s) => s.formScore, 'formScore', 82.0)))).called(1);
      });
      
      test('should return null when no tracking is active', () async {
        // Act
        final result = await useCase.stopSetTracking();
        
        // Assert
        expect(result, isNull);
        verifyNever(() => mockRepository.saveSetTiming(any()));
      });
      
      test('should handle metrics calculation failure gracefully', () async {
        // Arrange
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        when(() => mockFatigueAnalyzer.calculateSetFatigue(
          velocityData: any(named: 'velocityData'),
          repTimestamps: any(named: 'repTimestamps'),
          weight: any(named: 'weight'),
        )).thenThrow(Exception('Calculation error'));
        
        when(() => mockFormAnalyzer.calculateSetFormScore(
          formScores: any(named: 'formScores'),
          consistencyScore: any(named: 'consistencyScore'),
          velocityData: any(named: 'velocityData'),
        )).thenThrow(Exception('Form calculation error'));
        
        reset(mockRepository);
        when(() => mockRepository.saveSetTiming(any()))
            .thenAnswer((_) async {});
        
        // Act
        final result = await useCase.stopSetTracking();
        
        // Assert - Should still complete with default values
        expect(result, isNotNull);
        expect(result!.fatigueIndex, 0.0);
        expect(result.formScore, 0.0);
      });
    });

    group('registerRep', () {
      test('should register rep when tracking is active', () async {
        // Arrange
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act
        useCase.registerRep();
        useCase.registerRep();
        
        // Get live metrics to verify reps
        final liveMetrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(liveMetrics, isNotNull);
        expect(liveMetrics!.currentRep, 2);
      });
      
      test('should do nothing when no tracking is active', () {
        // Act & Assert - Should not throw
        expect(() => useCase.registerRep(), returnsNormally);
      });
    });

    group('getCurrentLiveMetrics', () {
      test('should return null when no tracking is active', () {
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics, isNull);
      });
      
      test('should return live metrics when tracking is active', () async {
        // Arrange
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        useCase.registerRep();
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics, isNotNull);
        expect(metrics!.setId, isNotEmpty);
        expect(metrics.currentRep, 1);
        expect(metrics.elapsedMs, greaterThan(0));
        expect(metrics.phase, isA<SetPhase>());
      });
      
      test('should calculate correct velocity metrics', () async {
        // Arrange
        when(() => mockVelocityAnalyzer.getCurrentVelocity())
            .thenAnswer((_) async => 0.8);
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Simulate some velocity data collection
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics, isNotNull);
        expect(metrics!.currentVelocityMps, closeTo(0.0, 0.1)); // Initial velocity
        expect(metrics.averageVelocityMps, greaterThanOrEqualTo(0.0));
      });
      
      test('should provide fatigue recommendations', () async {
        // Arrange
        when(() => mockFatigueAnalyzer.calculateRealTimeFatigue(any(), any()))
            .thenReturn(85.0); // High fatigue
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics, isNotNull);
        expect(metrics!.fatigueIndex, 85.0);
        expect(metrics.shouldStopSet, isTrue);
        expect(metrics.coachingTip, contains('fatigue'));
      });
      
      test('should handle metrics calculation errors gracefully', () async {
        // Arrange
        when(() => mockVelocityAnalyzer.getCurrentVelocity())
            .thenThrow(Exception('Sensor error'));
        when(() => mockFormAnalyzer.getCurrentFormScore())
            .thenThrow(Exception('Form analysis error'));
        when(() => mockFatigueAnalyzer.calculateRealTimeFatigue(any(), any()))
            .thenThrow(Exception('Fatigue calculation error'));
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert - Should still return metrics with default values
        expect(metrics, isNotNull);
        expect(metrics!.currentVelocityMps, 0.0);
        expect(metrics.currentFormScore, 0.0);
        expect(metrics.fatigueIndex, 0.0);
      });
    });

    group('coaching tip generation', () {
      test('should provide high fatigue warning', () async {
        // Arrange
        when(() => mockFatigueAnalyzer.calculateRealTimeFatigue(any(), any()))
            .thenReturn(95.0);
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics!.coachingTip, contains('fatigue'));
        expect(metrics.shouldStopSet, isTrue);
      });
      
      test('should provide velocity drop warning', () async {
        // Arrange
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Simulate velocity drop by updating the current velocity to be much lower
        when(() => mockVelocityAnalyzer.getCurrentVelocity())
            .thenAnswer((_) async => 0.1); // Very low velocity
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics!.velocityDropPercent, greaterThan(25));
        expect(metrics.shouldStopSet, isTrue);
      });
      
      test('should provide form feedback', () async {
        // Arrange
        when(() => mockFormAnalyzer.getCurrentFormScore())
            .thenAnswer((_) async => 45.0); // Low form score
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics!.currentFormScore, 45.0);
        expect(metrics.coachingTip, contains('form'));
      });
      
      test('should provide positive feedback for good performance', () async {
        // Arrange
        when(() => mockFormAnalyzer.getCurrentFormScore())
            .thenAnswer((_) async => 90.0);
        when(() => mockFatigueAnalyzer.calculateRealTimeFatigue(any(), any()))
            .thenReturn(15.0);
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics!.currentFormScore, 90.0);
        expect(metrics.fatigueIndex, 15.0);
        expect(metrics.coachingTip, contains('great'));
        expect(metrics.shouldStopSet, isFalse);
      });
    });

    group('data sampling and collection', () {
      test('should collect velocity data during tracking', () async {
        // Arrange
        var velocityCallCount = 0;
        when(() => mockVelocityAnalyzer.getCurrentVelocity())
            .thenAnswer((_) async {
          velocityCallCount++;
          return 0.5 + (velocityCallCount * 0.1);
        });
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
          config: const SetTimingConfig(
            mode: TimingMode.performance,
            samplingRateHz: 10, // 10Hz for faster testing
            trackVelocity: true,
          ),
        );
        
        // Act - Wait for some sampling cycles
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert
        verify(() => mockVelocityAnalyzer.getCurrentVelocity()).called(greaterThan(1));
      });
      
      test('should collect form data during tracking', () async {
        // Arrange
        var formCallCount = 0;
        when(() => mockFormAnalyzer.getCurrentFormScore())
            .thenAnswer((_) async {
          formCallCount++;
          return 80.0 - (formCallCount * 2); // Declining form
        });
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
          config: const SetTimingConfig(
            mode: TimingMode.performance,
            samplingRateHz: 10,
          ),
        );
        
        // Act - Wait for some sampling cycles
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Assert
        verify(() => mockFormAnalyzer.getCurrentFormScore()).called(greaterThan(1));
      });
      
      test('should handle sampling errors without stopping tracking', () async {
        // Arrange
        when(() => mockVelocityAnalyzer.getCurrentVelocity())
            .thenThrow(Exception('Sensor disconnected'));
        
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
          config: const SetTimingConfig(
            mode: TimingMode.performance,
            samplingRateHz: 10,
            trackVelocity: true,
          ),
        );
        
        // Act - Wait for sampling cycles and ensure tracking continues
        await Future.delayed(const Duration(milliseconds: 200));
        
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert - Should still be tracking despite sampling errors
        expect(metrics, isNotNull);
        expect(metrics!.phase, isA<SetPhase>());
      });
    });

    group('resource management', () {
      test('should dispose resources properly', () {
        // Act
        useCase.dispose();
        
        // Assert - Should complete without error
        expect(() => useCase.dispose(), returnsNormally);
      });
      
      test('should clear state after disposal', () {
        // Arrange
        useCase.dispose();
        
        // Act
        final metrics = useCase.getCurrentLiveMetrics();
        
        // Assert
        expect(metrics, isNull);
      });
    });

    group('edge cases and error handling', () {
      test('should handle very short set durations', () async {
        // Arrange
        await useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        );
        
        // Act - Stop immediately
        final result = await useCase.stopSetTracking();
        
        // Assert
        expect(result, isNotNull);
        expect(result!.executionTimeMs, greaterThanOrEqualTo(0));
        expect(result.reps, 0);
      });
      
      test('should handle concurrent start/stop operations', () async {
        // Arrange & Act - Start multiple operations concurrently
        final futures = [
          useCase.startSetTracking(
            exerciseId: testExerciseId,
            workoutId: testWorkoutId,
            setNumber: testSetNumber,
          ),
          useCase.stopSetTracking(),
          useCase.startSetTracking(
            exerciseId: 'another-exercise',
            workoutId: testWorkoutId,
            setNumber: 2,
          ),
        ];
        
        // Should complete without hanging or throwing
        await Future.wait(futures);
        
        // Assert
        final metrics = useCase.getCurrentLiveMetrics();
        expect(metrics?.setId, isNotNull);
      });
      
      test('should validate input parameters', () async {
        // Act & Assert - Test invalid parameters
        expect(() => useCase.startSetTracking(
          exerciseId: '',
          workoutId: testWorkoutId,
          setNumber: testSetNumber,
        ), throwsA(isA<AssertionError>()));
        
        expect(() => useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: '',
          setNumber: testSetNumber,
        ), throwsA(isA<AssertionError>()));
        
        expect(() => useCase.startSetTracking(
          exerciseId: testExerciseId,
          workoutId: testWorkoutId,
          setNumber: 0,
        ), throwsA(isA<AssertionError>()));
      });
    });
  });
}