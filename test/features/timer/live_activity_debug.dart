import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Debug test per Live Activities
/// Questo test aiuta a diagnosticare problemi con le Live Activities
void main() {
  group('Live Activity Debug Tests', () {
    late MethodChannel unifiedChannel;
    final List<MethodCall> methodCalls = [];

    setUp(() {
      unifiedChannel = const MethodChannel('com.gymbro.timer/unified');
      methodCalls.clear();
      
      // Mock del canale per catturare le chiamate
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(unifiedChannel, (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        print('🔍 Mock received method: ${methodCall.method}');
        print('🔍 Mock received arguments: ${methodCall.arguments}');
        
        switch (methodCall.method) {
          case 'startLiveActivity':
            // Simula successo per ora
            return 'activity_id_123';
          case 'updateLiveActivity':
            return true;
          case 'endLiveActivity':
            return true;
          case 'getActiveLiveActivities':
            return {'remainingSeconds': 120, 'isRunning': true};
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(unifiedChannel, null);
    });

    test('should call startLiveActivity with correct parameters', () async {
      // Arrange
      final testArgs = {
        'exerciseName': 'Bench Press',
        'timerType': 'rest',
        'totalSeconds': 120,
        'remainingSeconds': 120,
        'isRunning': true,
        'currentSet': 2,
        'totalSets': 4,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'workoutName': 'Push Day',
      };

      // Act
      final result = await unifiedChannel.invokeMethod('startLiveActivity', testArgs);

      // Assert
      expect(methodCalls.length, 1);
      expect(methodCalls.first.method, 'startLiveActivity');
      expect(methodCalls.first.arguments, testArgs);
      expect(result, 'activity_id_123');

      print('✅ startLiveActivity test passed');
      print('✅ Method call captured: ${methodCalls.first.method}');
      print('✅ Arguments captured: ${methodCalls.first.arguments}');
    });

    test('should handle Live Activity errors gracefully', () async {
      // Arrange - modifica il mock per simulare un errore
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(unifiedChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'startLiveActivity') {
          throw PlatformException(
            code: 'DISABLED',
            message: 'Live Activities are disabled',
            details: null,
          );
        }
        return null;
      });

      // Act & Assert
      expect(
        () => unifiedChannel.invokeMethod('startLiveActivity', {}),
        throwsA(isA<PlatformException>()),
      );

      print('✅ Error handling test passed');
    });

    test('should simulate real timer flow', () async {
      // Arrange
      final startArgs = {
        'exerciseName': 'Rest Timer',
        'timerType': 'rest',
        'totalSeconds': 60,
        'remainingSeconds': 60,
        'isRunning': true,
        'currentSet': 1,
        'totalSets': 3,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'workoutName': null,
      };

      // Act 1: Start Live Activity
      final startResult = await unifiedChannel.invokeMethod('startLiveActivity', startArgs);
      expect(startResult, 'activity_id_123');

      // Act 2: Update Live Activity (simula tick del timer)
      final updateArgs = {
        'activityId': 'current',
        'remainingSeconds': 45,
        'totalSeconds': 60,
        'isRunning': true,
        'currentSet': 1,
        'totalSets': 3,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      final updateResult = await unifiedChannel.invokeMethod('updateLiveActivity', updateArgs);
      expect(updateResult, true);

      // Act 3: End Live Activity
      final endArgs = {
        'activityId': 'current',
        'dismissalPolicy': 'immediate',
      };

      final endResult = await unifiedChannel.invokeMethod('endLiveActivity', endArgs);
      expect(endResult, true);

      // Assert
      expect(methodCalls.length, 3);
      expect(methodCalls[0].method, 'startLiveActivity');
      expect(methodCalls[1].method, 'updateLiveActivity');
      expect(methodCalls[2].method, 'endLiveActivity');

      print('✅ Full timer flow test passed');
      print('✅ Called methods: ${methodCalls.map((c) => c.method).toList()}');
    });

    test('should validate Live Activity arguments', () async {
      // Test con argomenti mancanti
      final invalidArgs = {
        'exerciseName': 'Test',
        // Mancano parametri richiesti
      };

      // Modifica il mock per validare argomenti
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(unifiedChannel, (MethodCall methodCall) async {
        final args = methodCall.arguments as Map<String, dynamic>?;
        
        if (methodCall.method == 'startLiveActivity') {
          // Controlla parametri richiesti
          final required = ['exerciseName', 'timerType', 'totalSeconds', 'remainingSeconds'];
          for (final param in required) {
            if (args?[param] == null) {
              throw PlatformException(
                code: 'INVALID_ARGUMENTS',
                message: 'Missing required parameter: $param',
                details: null,
              );
            }
          }
        }
        
        return 'success';
      });

      // Act & Assert
      expect(
        () => unifiedChannel.invokeMethod('startLiveActivity', invalidArgs),
        throwsA(isA<PlatformException>()),
      );

      print('✅ Argument validation test passed');
    });
  });
}

/// Helper per debug logging manuale
void debugLiveActivityFlow() {
  print('=== LIVE ACTIVITY DEBUG FLOW ===');
  print('1. Flutter calls: _unifiedChannel.invokeMethod("startLiveActivity", args)');
  print('2. UnifiedTimerCoordinator.handleStartLiveActivity() receives call');
  print('3. UnifiedTimerCoordinator forwards to LiveActivityHandler.startLiveActivityDirectly()');
  print('4. LiveActivityHandler.startLiveActivity() creates Activity<GymBroTimerAttributes>');
  print('5. Live Activity should appear on lock screen/Dynamic Island');
  print('');
  print('🔍 Check logs for:');
  print('   - "📱 Starting Live Activity..." (Flutter)');
  print('   - "📱 Live Activity start requested via unified channel" (Coordinator)');
  print('   - "🔄 LiveActivityHandler: startLiveActivityDirectly called" (Handler)');
  print('   - "✅ Live Activities are enabled" (Handler)');
  print('   - Activity.request() success/failure (Handler)');
  print('================================');
}