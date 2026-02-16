import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/timer/domain/entities/rest_timer.dart';

void main() {
  group('⏱️ Timer Logic Tests', () {
    
    test('✅ TEST 1: Timer creation with correct duration', () {
      // Create a 60 second timer
      final timer = RestTimer(
        id: 'test-timer',
        type: TimerType.rest,
        totalDurationSeconds: 60,
        remainingSeconds: 60,
        exerciseName: 'Bench Press',
        currentSet: 1,
        totalSets: 3,
        status: TimerStatus.idle,
      );
      
      expect(timer.totalDurationSeconds, 60);
      expect(timer.remainingSeconds, 60);
      expect(timer.status, TimerStatus.idle);
      expect(timer.isCompleted, false);
    });
    
    test('✅ TEST 2: Timer countdown logic', () {
      // Create timer with 10 seconds
      var timer = RestTimer(
        id: 'test-timer',
        type: TimerType.rest,
        totalDurationSeconds: 10,
        remainingSeconds: 10,
        exerciseName: 'Squat',
        currentSet: 2,
        totalSets: 4,
        status: TimerStatus.running,
      );
      
      // Simulate countdown
      timer = timer.copyWith(remainingSeconds: 5);
      expect(timer.remainingSeconds, 5);
      expect(timer.isCompleted, false);
      
      // Complete timer
      timer = timer.copyWith(remainingSeconds: 0);
      expect(timer.remainingSeconds, 0);
      expect(timer.isCompleted, true);
    });
    
    test('✅ TEST 3: Timer pause and resume', () {
      var timer = RestTimer(
        id: 'test-timer',
        type: TimerType.rest,
        totalDurationSeconds: 30,
        remainingSeconds: 20,
        exerciseName: 'Deadlift',
        currentSet: 3,
        totalSets: 5,
        status: TimerStatus.running,
      );
      
      // Pause timer
      timer = timer.copyWith(
        status: TimerStatus.paused,
      );
      expect(timer.status, TimerStatus.paused);
      expect(timer.isPaused, true);
      
      // Resume timer
      timer = timer.copyWith(
        status: TimerStatus.running,
      );
      expect(timer.status, TimerStatus.running);
      expect(timer.isPaused, false);
    });
    
    test('✅ TEST 4: Timer completion triggers', () {
      var timer = RestTimer(
        id: 'test-timer',
        type: TimerType.rest,
        totalDurationSeconds: 5,
        remainingSeconds: 1,
        exerciseName: 'Pull-ups',
        currentSet: 4,
        totalSets: 4,
        status: TimerStatus.running,
      );
      
      // Complete timer
      timer = timer.copyWith(
        remainingSeconds: 0,
        status: TimerStatus.completed,
      );
      
      expect(timer.remainingSeconds, 0);
      expect(timer.status, TimerStatus.completed);
      expect(timer.isCompleted, true);
    });
    
    test('✅ TEST 5: Timer progress calculation', () {
      final timer = RestTimer(
        id: 'test-timer',
        type: TimerType.rest,
        totalDurationSeconds: 100,
        remainingSeconds: 25,
        exerciseName: 'Plank',
        currentSet: 1,
        totalSets: 1,
        status: TimerStatus.running,
      );
      
      // Calculate progress
      final progress = timer.progress;
      expect(progress, 0.75); // 75% complete (75 seconds elapsed out of 100)
      
      // Check elapsed time
      final elapsed = timer.elapsedSeconds;
      expect(elapsed, 75);
    });
    
    test('✅ TEST 6: Timer time formatting', () {
      final timer = RestTimer(
        id: 'test-timer',
        type: TimerType.rest,
        totalDurationSeconds: 125, // 2:05
        remainingSeconds: 65, // 1:05
        exerciseName: 'Rest',
        currentSet: 1,
        totalSets: 1,
        status: TimerStatus.running,
      );
      
      // Format remaining time (usando il metodo esistente formattedTime)
      final formatted = timer.formattedTime;
      expect(formatted, '01:05'); // Il formato è MM:SS con padding
      
      // Test del progresso
      final progress = timer.progress;
      expect(progress, 0.48); // (125-65)/125 = 0.48
      
      // Test elapsed seconds
      final elapsed = timer.elapsedSeconds;
      expect(elapsed, 60); // 125 - 65 = 60
    });
  });
}