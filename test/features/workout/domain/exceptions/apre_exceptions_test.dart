import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/exceptions/apre_exceptions.dart';

void main() {
  group('APRENoHistoryException', () {
    test('can be instantiated with message', () {
      const message = 'No historical data available';
      const exception = APRENoHistoryException(message);

      expect(exception, isA<APRENoHistoryException>());
      expect(exception.message, equals(message));
    });

    test('message contains expected information', () {
      const message = 'No historical data available for exercise Bench Press';
      const exception = APRENoHistoryException(message);

      expect(exception.message, contains('No historical data'));
      expect(exception.message, contains('Bench Press'));
    });

    test('toString() includes exception type and message', () {
      const message = 'No historical data available';
      const exception = APRENoHistoryException(message);
      final stringRepresentation = exception.toString();

      expect(stringRepresentation, contains('APRENoHistoryException'));
      expect(stringRepresentation, contains(message));
    });
  });

  group('APREStaleDataException', () {
    test('can be instantiated with message', () {
      const message = 'Cached calculations are too old';
      const exception = APREStaleDataException(message);

      expect(exception, isA<APREStaleDataException>());
      expect(exception.message, equals(message));
    });

    test('message contains expected information about age', () {
      const message = 'Cached calculations are 14 days old (>7 days threshold)';
      const exception = APREStaleDataException(message);

      expect(exception.message, contains('days old'));
      expect(exception.message, contains('7 days'));
    });

    test('toString() includes exception type and message', () {
      const message = 'Data is stale';
      const exception = APREStaleDataException(message);
      final stringRepresentation = exception.toString();

      expect(stringRepresentation, contains('APREStaleDataException'));
      expect(stringRepresentation, contains(message));
    });
  });

  group('APREWorkoutInProgressException', () {
    test('can be instantiated with message', () {
      const message = 'Cannot change protocol during active workout';
      const exception = APREWorkoutInProgressException(message);

      expect(exception, isA<APREWorkoutInProgressException>());
      expect(exception.message, equals(message));
    });

    test('message contains expected information about workout state', () {
      const message =
          'Cannot change protocol during active workout. Finish workout first.';
      const exception = APREWorkoutInProgressException(message);

      expect(exception.message, contains('Cannot change protocol'));
      expect(exception.message, contains('active workout'));
    });

    test('toString() includes exception type and message', () {
      const message = 'Workout in progress';
      const exception = APREWorkoutInProgressException(message);
      final stringRepresentation = exception.toString();

      expect(stringRepresentation, contains('APREWorkoutInProgressException'));
      expect(stringRepresentation, contains(message));
    });
  });

  group('APREInvalidProtocolException', () {
    test('can be instantiated with message', () {
      const message = 'Invalid protocol number: 5';
      const exception = APREInvalidProtocolException(message);

      expect(exception, isA<APREInvalidProtocolException>());
      expect(exception.message, equals(message));
    });

    test('message contains expected information about valid protocols', () {
      const message =
          'Invalid protocol number: 5. Valid protocols are: 3, 6, 10';
      const exception = APREInvalidProtocolException(message);

      expect(exception.message, contains('Invalid protocol'));
      expect(exception.message, contains('3, 6, 10'));
    });

    test('toString() includes exception type and message', () {
      const message = 'Invalid protocol';
      const exception = APREInvalidProtocolException(message);
      final stringRepresentation = exception.toString();

      expect(stringRepresentation, contains('APREInvalidProtocolException'));
      expect(stringRepresentation, contains(message));
    });

    test('message can include protocol number that failed', () {
      const invalidProtocol = 7;
      const message = 'Invalid protocol number: $invalidProtocol';
      const exception = APREInvalidProtocolException(message);

      expect(exception.message, contains('7'));
    });
  });

  group('Exception hierarchy', () {
    test('all exceptions implement Exception interface', () {
      expect(const APRENoHistoryException('test'), isA<Exception>());
      expect(const APREStaleDataException('test'), isA<Exception>());
      expect(const APREWorkoutInProgressException('test'), isA<Exception>());
      expect(const APREInvalidProtocolException('test'), isA<Exception>());
    });

    test('exceptions can be caught as generic Exception', () {
      void throwException() {
        throw const APRENoHistoryException('test');
      }

      expect(() => throwException(), throwsA(isA<Exception>()));
    });

    test('exceptions can be caught by specific type', () {
      void throwSpecific() {
        throw const APREInvalidProtocolException('Invalid protocol: 5');
      }

      expect(
        () => throwSpecific(),
        throwsA(isA<APREInvalidProtocolException>()),
      );
    });
  });

  group('Exception usage patterns', () {
    test('can be used in try-catch blocks', () {
      String? caughtMessage;

      try {
        throw const APRENoHistoryException('No data available');
      } on APRENoHistoryException catch (e) {
        caughtMessage = e.message;
      }

      expect(caughtMessage, equals('No data available'));
    });

    test('can differentiate between exception types', () {
      String? exceptionType;

      try {
        throw const APREStaleDataException('Data too old');
      } on APRENoHistoryException {
        exceptionType = 'no_history';
      } on APREStaleDataException {
        exceptionType = 'stale_data';
      }

      expect(exceptionType, equals('stale_data'));
    });

    test('can handle multiple exception types in order', () {
      final caughtExceptions = <String>[];

      void testException(Exception e) {
        try {
          throw e;
        } on APREInvalidProtocolException {
          caughtExceptions.add('invalid_protocol');
        } on APREWorkoutInProgressException {
          caughtExceptions.add('workout_in_progress');
        } on Exception {
          caughtExceptions.add('generic');
        }
      }

      testException(const APREInvalidProtocolException('test'));
      testException(const APREWorkoutInProgressException('test'));
      testException(Exception());

      expect(caughtExceptions, const [
        'invalid_protocol',
        'workout_in_progress',
        'generic',
      ]);
    });
  });
}
