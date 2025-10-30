import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/validation/input_validation_service.dart';

void main() {
  group('InputValidationService - Double Parsing', () {
    test('parses valid double correctly', () {
      expect(
        InputValidationService.parseDoubleInRange(
          '75.5',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        75.5,
      );
    });

    test('parses integer as double', () {
      expect(
        InputValidationService.parseDoubleInRange(
          '100',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        100.0,
      );
    });

    test('trims whitespace', () {
      expect(
        InputValidationService.parseDoubleInRange(
          '  75.5  ',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        75.5,
      );
    });

    test('throws ValidationException on invalid input', () {
      expect(
        () => InputValidationService.parseDoubleInRange(
          'abc',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException on out-of-range (too high)', () {
      expect(
        () => InputValidationService.parseDoubleInRange(
          '1500',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException on out-of-range (too low)', () {
      expect(
        () => InputValidationService.parseDoubleInRange(
          '-50',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('uses default value when invalid input provided', () {
      expect(
        InputValidationService.parseDoubleInRange(
          'abc',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
          defaultValue: 80.0,
        ),
        80.0,
      );
    });

    test('parseWeight validates 0-1000 range', () {
      expect(InputValidationService.parseWeight('75.5'), 75.5);
      expect(InputValidationService.parseWeight('0'), 0.0);
      expect(InputValidationService.parseWeight('1000'), 1000.0);

      expect(
        () => InputValidationService.parseWeight('-1'),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidationService.parseWeight('1001'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('parseDuration validates 0-86400 range', () {
      expect(InputValidationService.parseDuration('3600'), 3600.0);
      expect(InputValidationService.parseDuration('0'), 0.0);
      expect(InputValidationService.parseDuration('86400'), 86400.0);

      expect(
        () => InputValidationService.parseDuration('86401'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidationService - Integer Parsing', () {
    test('parses valid integer correctly', () {
      expect(
        InputValidationService.parseIntInRange(
          '10',
          min: 1,
          max: 100,
          fieldName: 'Reps',
        ),
        10,
      );
    });

    test('throws ValidationException on decimal input', () {
      expect(
        () => InputValidationService.parseIntInRange(
          '10.5',
          min: 1,
          max: 100,
          fieldName: 'Reps',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws ValidationException on out-of-range', () {
      expect(
        () => InputValidationService.parseIntInRange(
          '101',
          min: 1,
          max: 100,
          fieldName: 'Reps',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('parseReps validates 1-100 range', () {
      expect(InputValidationService.parseReps('10'), 10);
      expect(InputValidationService.parseReps('1'), 1);
      expect(InputValidationService.parseReps('100'), 100);

      expect(
        () => InputValidationService.parseReps('0'),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidationService.parseReps('101'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('parseSets validates 1-20 range', () {
      expect(InputValidationService.parseSets('5'), 5);
      expect(InputValidationService.parseSets('1'), 1);
      expect(InputValidationService.parseSets('20'), 20);

      expect(
        () => InputValidationService.parseSets('0'),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidationService.parseSets('21'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('parseRPE validates 1-10 range', () {
      expect(InputValidationService.parseRPE('7'), 7);
      expect(InputValidationService.parseRPE('1'), 1);
      expect(InputValidationService.parseRPE('10'), 10);

      expect(
        () => InputValidationService.parseRPE('0'),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => InputValidationService.parseRPE('11'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('parseRestTime validates 0-3600 range', () {
      expect(InputValidationService.parseRestTime('90'), 90);
      expect(InputValidationService.parseRestTime('0'), 0);
      expect(InputValidationService.parseRestTime('3600'), 3600);

      expect(
        () => InputValidationService.parseRestTime('3601'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidationService - String Sanitization', () {
    test('trims whitespace', () {
      expect(
        InputValidationService.sanitizeString('  hello  '),
        'hello',
      );
    });

    test('removes control characters', () {
      expect(
        InputValidationService.sanitizeString('hello\x00world'),
        'helloworld',
      );
    });

    test('limits length', () {
      final longString = 'a' * 1000;
      final sanitized = InputValidationService.sanitizeString(
        longString,
        maxLength: 100,
      );

      expect(sanitized.length, 100);
    });

    test('preserves newlines when allowed', () {
      expect(
        InputValidationService.sanitizeString('line1\nline2', allowNewlines: true),
        'line1\nline2',
      );
    });

    test('removes newlines when not allowed', () {
      expect(
        InputValidationService.sanitizeString('line1\nline2', allowNewlines: false),
        'line1line2',
      );
    });
  });

  group('InputValidationService - Email Validation', () {
    test('validates correct email', () {
      expect(InputValidationService.isValidEmail('test@example.com'), true);
      expect(InputValidationService.isValidEmail('user.name@domain.co.uk'), true);
    });

    test('rejects invalid email', () {
      expect(InputValidationService.isValidEmail('invalid'), false);
      expect(InputValidationService.isValidEmail('missing@domain'), false);
      expect(InputValidationService.isValidEmail('@domain.com'), false);
    });
  });

  group('ValidationException', () {
    test('contains error message', () {
      const exception = ValidationException('Invalid input');
      expect(exception.message, 'Invalid input');
    });

    test('contains field name', () {
      const exception = ValidationException(
        'Invalid input',
        field: 'Weight',
      );
      expect(exception.field, 'Weight');
    });

    test('contains invalid value', () {
      const exception = ValidationException(
        'Invalid input',
        invalidValue: 'abc',
      );
      expect(exception.invalidValue, 'abc');
    });

    test('contains min/max range', () {
      const exception = ValidationException(
        'Out of range',
        min: 0,
        max: 1000,
      );
      expect(exception.min, 0);
      expect(exception.max, 1000);
    });

    test('toString includes all details', () {
      const exception = ValidationException(
        'Weight must be between 0 and 1000',
        field: 'Weight',
        invalidValue: '1500',
        min: 0,
        max: 1000,
      );

      final str = exception.toString();
      expect(str, contains('Weight must be between 0 and 1000'));
      expect(str, contains('field: Weight'));
      expect(str, contains('invalid value: "1500"'));
      expect(str, contains('valid range: 0.0 - 1000.0'));
    });
  });

  group('InputValidationService - Nullable Parsing', () {
    test('returns null for empty string', () {
      expect(
        InputValidationService.parseDoubleInRangeNullable(
          '',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        null,
      );
    });

    test('returns null for whitespace-only string', () {
      expect(
        InputValidationService.parseDoubleInRangeNullable(
          '   ',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        null,
      );
    });

    test('parses valid value when provided', () {
      expect(
        InputValidationService.parseDoubleInRangeNullable(
          '75.5',
          min: 0,
          max: 1000,
          fieldName: 'Weight',
        ),
        75.5,
      );
    });
  });
}
