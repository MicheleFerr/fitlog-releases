import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/failures/chart_failure.dart';

void main() {
  group('ChartFailure', () {
    group('ChartInvalidInputFailure', () {
      test('creates with message only', () {
        const failure = ChartInvalidInputFailure(message: 'Invalid date range');

        expect(failure.message, 'Invalid date range');
        expect(failure.details, isNull);
        expect(failure.error, isNull);
        expect(failure.stackTrace, isNull);
      });

      test('creates with message and details', () {
        const failure = ChartInvalidInputFailure(
          message: 'Invalid input',
          details: 'Start date must be before end date',
        );

        expect(failure.message, 'Invalid input');
        expect(failure.details, 'Start date must be before end date');
      });

      test('creates via named constructor on sealed class', () {
        const ChartFailure failure = ChartFailure.invalidInput(
          message: 'Bad input',
          details: 'Missing required field',
        );

        expect(failure, isA<ChartInvalidInputFailure>());
        expect(failure.message, 'Bad input');
        expect((failure as ChartInvalidInputFailure).details, 'Missing required field');
      });

      test('toString includes message and details', () {
        const failure = ChartInvalidInputFailure(
          message: 'Invalid input',
          details: 'Negative value',
        );

        final str = failure.toString();

        expect(str, contains('ChartInvalidInputFailure'));
        expect(str, contains('Invalid input'));
        expect(str, contains('Negative value'));
      });

      test('toString with null details', () {
        const failure = ChartInvalidInputFailure(message: 'Error');

        final str = failure.toString();

        expect(str, contains('ChartInvalidInputFailure'));
        expect(str, contains('Error'));
        expect(str, contains('null'));
      });
    });

    group('ChartServerFailure', () {
      test('creates with message only', () {
        const failure = ChartServerFailure(message: 'Server error');

        expect(failure.message, 'Server error');
        expect(failure.error, isNull);
        expect(failure.stackTrace, isNull);
      });

      test('creates with message and error', () {
        final error = Exception('Firebase timeout');
        final failure = ChartServerFailure(
          message: 'Server error',
          error: error,
        );

        expect(failure.message, 'Server error');
        expect(failure.error, error);
      });

      test('creates with message, error, and stackTrace', () {
        final error = Exception('Network error');
        final trace = StackTrace.current;
        final failure = ChartServerFailure(
          message: 'Server error',
          error: error,
          stackTrace: trace,
        );

        expect(failure.message, 'Server error');
        expect(failure.error, error);
        expect(failure.stackTrace, trace);
      });

      test('creates via named constructor on sealed class', () {
        const ChartFailure failure = ChartFailure.serverFailure(
          message: 'Firebase down',
        );

        expect(failure, isA<ChartServerFailure>());
        expect(failure.message, 'Firebase down');
      });

      test('toString includes message and error', () {
        final failure = ChartServerFailure(
          message: 'Server error',
          error: 'timeout',
        );

        final str = failure.toString();

        expect(str, contains('ChartServerFailure'));
        expect(str, contains('Server error'));
        expect(str, contains('timeout'));
      });
    });

    group('ChartUnknownFailure', () {
      test('creates with message only', () {
        const failure = ChartUnknownFailure(message: 'Unknown error');

        expect(failure.message, 'Unknown error');
        expect(failure.error, isNull);
        expect(failure.stackTrace, isNull);
      });

      test('creates with all fields', () {
        final error = StateError('unexpected');
        final trace = StackTrace.current;
        final failure = ChartUnknownFailure(
          message: 'Something went wrong',
          error: error,
          stackTrace: trace,
        );

        expect(failure.message, 'Something went wrong');
        expect(failure.error, error);
        expect(failure.stackTrace, trace);
      });

      test('creates via named constructor on sealed class', () {
        const ChartFailure failure = ChartFailure.unknown(
          message: 'Unexpected error',
        );

        expect(failure, isA<ChartUnknownFailure>());
        expect(failure.message, 'Unexpected error');
      });

      test('toString includes message and error', () {
        final failure = ChartUnknownFailure(
          message: 'Unknown',
          error: 'crash',
        );

        final str = failure.toString();

        expect(str, contains('ChartUnknownFailure'));
        expect(str, contains('Unknown'));
        expect(str, contains('crash'));
      });
    });

    group('pattern matching', () {
      test('switch expression matches all subtypes', () {
        final failures = <ChartFailure>[
          const ChartFailure.invalidInput(message: 'bad input'),
          const ChartFailure.serverFailure(message: 'server down'),
          const ChartFailure.unknown(message: 'mystery'),
        ];

        final results = failures.map((failure) {
          return switch (failure) {
            ChartInvalidInputFailure() => 'invalid',
            ChartServerFailure() => 'server',
            ChartUnknownFailure() => 'unknown',
          };
        }).toList();

        expect(results, ['invalid', 'server', 'unknown']);
      });

      test('is check works for ChartInvalidInputFailure', () {
        const ChartFailure failure = ChartFailure.invalidInput(
          message: 'test',
          details: 'detail',
        );

        expect(failure is ChartInvalidInputFailure, isTrue);
        expect(failure is ChartServerFailure, isFalse);
        expect(failure is ChartUnknownFailure, isFalse);
      });

      test('is check works for ChartServerFailure', () {
        const ChartFailure failure = ChartFailure.serverFailure(
          message: 'test',
        );

        expect(failure is ChartInvalidInputFailure, isFalse);
        expect(failure is ChartServerFailure, isTrue);
        expect(failure is ChartUnknownFailure, isFalse);
      });

      test('is check works for ChartUnknownFailure', () {
        const ChartFailure failure = ChartFailure.unknown(
          message: 'test',
        );

        expect(failure is ChartInvalidInputFailure, isFalse);
        expect(failure is ChartServerFailure, isFalse);
        expect(failure is ChartUnknownFailure, isTrue);
      });

      test('can access subtype-specific fields after cast', () {
        const ChartFailure failure = ChartFailure.invalidInput(
          message: 'err',
          details: 'specific detail',
        );

        if (failure case ChartInvalidInputFailure(:final details)) {
          expect(details, 'specific detail');
        } else {
          fail('Should have matched ChartInvalidInputFailure');
        }
      });
    });

    group('sealed class properties', () {
      test('all subtypes share message field', () {
        final failures = <ChartFailure>[
          const ChartFailure.invalidInput(message: 'msg1'),
          const ChartFailure.serverFailure(message: 'msg2'),
          const ChartFailure.unknown(message: 'msg3'),
        ];

        expect(failures.map((f) => f.message), ['msg1', 'msg2', 'msg3']);
      });

      test('all subtypes share error field', () {
        final error = Exception('test');
        final failures = <ChartFailure>[
          const ChartFailure.invalidInput(message: 'a'),
          ChartFailure.serverFailure(message: 'b', error: error),
          ChartFailure.unknown(message: 'c', error: error),
        ];

        expect(failures[0].error, isNull);
        expect(failures[1].error, error);
        expect(failures[2].error, error);
      });

      test('all subtypes share stackTrace field', () {
        final trace = StackTrace.current;
        final failures = <ChartFailure>[
          const ChartFailure.invalidInput(message: 'a'),
          ChartFailure.serverFailure(message: 'b', stackTrace: trace),
          ChartFailure.unknown(message: 'c', stackTrace: trace),
        ];

        expect(failures[0].stackTrace, isNull);
        expect(failures[1].stackTrace, trace);
        expect(failures[2].stackTrace, trace);
      });
    });
  });
}
