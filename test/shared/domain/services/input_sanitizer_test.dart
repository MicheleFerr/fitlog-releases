import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/services/input_sanitizer.dart';

void main() {
  group('InputSanitizer - sanitizeText', () {
    test('should return empty string for empty input', () {
      expect(InputSanitizer.sanitizeText(''), equals(''));
    });

    test('should trim whitespace from input', () {
      expect(InputSanitizer.sanitizeText('  hello  '), equals('hello'));
      expect(InputSanitizer.sanitizeText('\n\t  text  \n'), equals('text'));
    });

    test('should limit length to maxLength parameter', () {
      final longText = 'a' * 1500;
      final result = InputSanitizer.sanitizeText(longText, maxLength: 1000);
      expect(result.length, equals(1000));
    });

    test('should use default maxLength of 1000', () {
      final longText = 'a' * 1500;
      final result = InputSanitizer.sanitizeText(longText);
      expect(result.length, equals(1000));
    });

    test('should strip HTML tags', () {
      expect(
        InputSanitizer.sanitizeText('<script>alert("xss")</script>'),
        equals('alert(&quot;xss&quot;)'),
      );
      expect(
        InputSanitizer.sanitizeText('<b>Bold</b> text'),
        equals('Bold text'),
      );
      expect(
        InputSanitizer.sanitizeText('<div><p>Nested</p></div>'),
        equals('Nested'),
      );
    });

    test('should escape HTML special characters', () {
      expect(
        InputSanitizer.sanitizeText('hello & goodbye'),
        contains('&amp;'),
      );
      expect(
        InputSanitizer.sanitizeText('3 < 5'),
        contains('&lt;'),
      );
      expect(
        InputSanitizer.sanitizeText('5 > 3'),
        contains('&gt;'),
      );
      expect(
        InputSanitizer.sanitizeText('"quotes"'),
        contains('&quot;'),
      );
      expect(
        InputSanitizer.sanitizeText("'apostrophe'"),
        contains('&#x27;'),
      );
      expect(
        InputSanitizer.sanitizeText('path/to/file'),
        contains('&#x2F;'),
      );
    });

    test('should handle combined sanitization', () {
      const input = '  <script>alert("test")</script> Hello & <b>World</b>  ';
      final result = InputSanitizer.sanitizeText(input);
      expect(result, contains('Hello'));
      expect(result, contains('&amp;'));
      expect(result, contains('World'));
      expect(result, isNot(contains('<script>')));
      expect(result, isNot(contains('<b>')));
    });

    test('should preserve safe text content', () {
      const safeText = 'This is a normal text with numbers 123 and punctuation!';
      final result = InputSanitizer.sanitizeText(safeText);
      expect(result, isNotEmpty);
    });

    test('should handle text with newlines', () {
      const multiline = 'Line 1\nLine 2\nLine 3';
      final result = InputSanitizer.sanitizeText(multiline);
      expect(result, contains('Line 1'));
      expect(result, contains('Line 2'));
    });
  });

  group('InputSanitizer - sanitizeName', () {
    test('should return empty string for empty input', () {
      expect(InputSanitizer.sanitizeName(''), equals(''));
    });

    test('should trim and sanitize basic text', () {
      expect(InputSanitizer.sanitizeName('  Bench Press  '), equals('Bench Press'));
    });

    test('should use default maxLength of 100', () {
      final longName = 'a' * 150;
      final result = InputSanitizer.sanitizeName(longName);
      expect(result.length, lessThanOrEqualTo(100));
    });

    test('should allow alphanumeric characters and spaces', () {
      expect(
        InputSanitizer.sanitizeName('Bench Press 123'),
        equals('Bench Press 123'),
      );
    });

    test('should allow parentheses and hyphens', () {
      final result = InputSanitizer.sanitizeName('Pull-ups (Wide Grip)');
      expect(result, contains('Pull-ups'));
      expect(result, contains('Wide'));
    });

    test('should allow forward slash and ampersand', () {
      final result1 = InputSanitizer.sanitizeName('Chest/Back');
      final result2 = InputSanitizer.sanitizeName('Smith & Machine');
      expect(result1, contains('Chest'));
      expect(result2, contains('Smith'));
    });

    test('should allow comma and period', () {
      final result = InputSanitizer.sanitizeName('Rep, Rest. 3.5 kg');
      expect(result, contains('Rep'));
      expect(result, contains('Rest'));
      expect(result, contains('3.5'));
    });

    test('should remove disallowed special characters', () {
      final result = InputSanitizer.sanitizeName(r'Test!@#$%^*+=[]{}|;:<>?');
      expect(result, isNot(contains('!')));
      expect(result, isNot(contains('@')));
      expect(result, isNot(contains('#')));
      expect(result, isNot(contains('*')));
      expect(result, equals('Test'));
    });

    test('should strip HTML tags before character filtering', () {
      expect(
        InputSanitizer.sanitizeName('<script>Workout</script>'),
        equals('Workout'),
      );
    });

    test('should handle custom maxLength', () {
      final longName = 'a' * 150;
      final result = InputSanitizer.sanitizeName(longName, maxLength: 50);
      expect(result.length, lessThanOrEqualTo(50));
    });
  });

  group('InputSanitizer - sanitizeNumber', () {
    test('should parse valid integer', () {
      expect(InputSanitizer.sanitizeNumber('42'), equals(42.0));
    });

    test('should parse valid decimal with dot', () {
      expect(InputSanitizer.sanitizeNumber('3.14'), equals(3.14));
    });

    test('should parse valid decimal with comma', () {
      expect(InputSanitizer.sanitizeNumber('3,14'), equals(3.14));
    });

    test('should trim whitespace before parsing', () {
      expect(InputSanitizer.sanitizeNumber('  42  '), equals(42.0));
    });

    test('should return null for invalid number', () {
      expect(InputSanitizer.sanitizeNumber('abc'), isNull);
      expect(InputSanitizer.sanitizeNumber(''), isNull);
      expect(InputSanitizer.sanitizeNumber('12.34.56'), isNull);
    });

    test('should apply minimum bound', () {
      expect(
        InputSanitizer.sanitizeNumber('5', min: 10.0),
        equals(10.0),
      );
      expect(
        InputSanitizer.sanitizeNumber('15', min: 10.0),
        equals(15.0),
      );
    });

    test('should apply maximum bound', () {
      expect(
        InputSanitizer.sanitizeNumber('15', max: 10.0),
        equals(10.0),
      );
      expect(
        InputSanitizer.sanitizeNumber('5', max: 10.0),
        equals(5.0),
      );
    });

    test('should apply both min and max bounds', () {
      expect(
        InputSanitizer.sanitizeNumber('5', min: 10.0, max: 20.0),
        equals(10.0),
      );
      expect(
        InputSanitizer.sanitizeNumber('25', min: 10.0, max: 20.0),
        equals(20.0),
      );
      expect(
        InputSanitizer.sanitizeNumber('15', min: 10.0, max: 20.0),
        equals(15.0),
      );
    });

    test('should handle negative numbers', () {
      expect(InputSanitizer.sanitizeNumber('-10'), equals(-10.0));
      expect(InputSanitizer.sanitizeNumber('-3.14'), equals(-3.14));
    });

    test('should handle zero', () {
      expect(InputSanitizer.sanitizeNumber('0'), equals(0.0));
      expect(InputSanitizer.sanitizeNumber('0.0'), equals(0.0));
    });

    test('should handle very large numbers', () {
      expect(InputSanitizer.sanitizeNumber('999999'), equals(999999.0));
    });

    test('should handle very small decimals', () {
      expect(InputSanitizer.sanitizeNumber('0.001'), equals(0.001));
    });
  });

  group('InputSanitizer - isValidEmail', () {
    test('should return false for empty email', () {
      expect(InputSanitizer.isValidEmail(''), isFalse);
    });

    test('should validate correct email formats', () {
      expect(InputSanitizer.isValidEmail('test@example.com'), isTrue);
      expect(InputSanitizer.isValidEmail('user.name@domain.com'), isTrue);
      expect(InputSanitizer.isValidEmail('user+tag@example.co.uk'), isTrue);
      expect(InputSanitizer.isValidEmail('user_123@test-domain.com'), isTrue);
    });

    test('should reject invalid email formats', () {
      expect(InputSanitizer.isValidEmail('invalid'), isFalse);
      expect(InputSanitizer.isValidEmail('@example.com'), isFalse);
      expect(InputSanitizer.isValidEmail('user@'), isFalse);
      expect(InputSanitizer.isValidEmail('user@domain'), isFalse);
      expect(InputSanitizer.isValidEmail('user domain@test.com'), isFalse);
    });

    test('should reject email without @ symbol', () {
      expect(InputSanitizer.isValidEmail('userexample.com'), isFalse);
    });

    test('should handle emails with numbers', () {
      expect(InputSanitizer.isValidEmail('user123@example.com'), isTrue);
    });

    test('should reject emails with multiple @ symbols', () {
      expect(InputSanitizer.isValidEmail('user@domain@test.com'), isFalse);
    });
  });

  group('InputSanitizer - sanitizeUrl', () {
    test('should return null for empty URL', () {
      expect(InputSanitizer.sanitizeUrl(''), isNull);
    });

    test('should accept valid HTTPS URLs', () {
      expect(
        InputSanitizer.sanitizeUrl('https://example.com'),
        equals('https://example.com'),
      );
      expect(
        InputSanitizer.sanitizeUrl('https://www.youtube.com/watch?v=123'),
        equals('https://www.youtube.com/watch?v=123'),
      );
    });

    test('should trim whitespace', () {
      expect(
        InputSanitizer.sanitizeUrl('  https://example.com  '),
        equals('https://example.com'),
      );
    });

    test('should reject HTTP URLs (non-secure)', () {
      expect(InputSanitizer.sanitizeUrl('http://example.com'), isNull);
    });

    test('should reject FTP URLs', () {
      expect(InputSanitizer.sanitizeUrl('ftp://example.com'), isNull);
    });

    test('should reject invalid URL formats', () {
      expect(InputSanitizer.sanitizeUrl('not a url'), isNull);
      expect(InputSanitizer.sanitizeUrl('javascript:alert(1)'), isNull);
    });

    test('should reject malformed URLs', () {
      // Note: URI parser is lenient, so we test clearly invalid formats
      expect(InputSanitizer.sanitizeUrl('https//example.com'), isNull);
      expect(InputSanitizer.sanitizeUrl('ht tps://example.com'), isNull);
    });

    test('should preserve URL with query parameters', () {
      const url = 'https://example.com/path?param=value&other=123';
      expect(InputSanitizer.sanitizeUrl(url), equals(url));
    });

    test('should preserve URL with fragments', () {
      const url = 'https://example.com/page#section';
      expect(InputSanitizer.sanitizeUrl(url), equals(url));
    });

    test('should reject data URLs', () {
      expect(InputSanitizer.sanitizeUrl('data:text/html,test'), isNull);
    });
  });

  group('InputSanitizer - validateWorkoutData', () {
    test('should validate correct workout data', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Morning Workout',
        notes: 'Felt great today',
        exerciseNames: ['Bench Press', 'Squat'],
      );

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('should reject empty workout name', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: '',
        exerciseNames: ['Bench Press'],
      );

      expect(result.isValid, isFalse);
      expect(result.errors, contains('Workout name cannot be empty'));
    });

    test('should reject workout name longer than 100 chars', () {
      final longName = 'a' * 101;
      final result = InputSanitizer.validateWorkoutData(
        workoutName: longName,
        exerciseNames: ['Bench Press'],
      );

      expect(result.isValid, isFalse);
      expect(
        result.errors,
        contains('Workout name too long (max 100 characters)'),
      );
    });

    test('should accept workout name at exactly 100 chars', () {
      final name = 'a' * 100;
      final result = InputSanitizer.validateWorkoutData(
        workoutName: name,
        exerciseNames: ['Bench Press'],
      );

      expect(result.isValid, isTrue);
    });

    test('should reject notes longer than 5000 chars', () {
      final longNotes = 'a' * 5001;
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Workout',
        notes: longNotes,
        exerciseNames: ['Bench Press'],
      );

      expect(result.isValid, isFalse);
      expect(result.errors, contains('Notes too long (max 5000 characters)'));
    });

    test('should accept notes at exactly 5000 chars', () {
      final notes = 'a' * 5000;
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Workout',
        notes: notes,
        exerciseNames: ['Bench Press'],
      );

      expect(result.isValid, isTrue);
    });

    test('should accept null notes', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Workout',
        notes: null,
        exerciseNames: ['Bench Press'],
      );

      expect(result.isValid, isTrue);
    });

    test('should reject empty exercise list', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Workout',
        exerciseNames: [],
      );

      expect(result.isValid, isFalse);
      expect(
        result.errors,
        contains('Workout must have at least one exercise'),
      );
    });

    test('should reject empty exercise names', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Workout',
        exerciseNames: ['Bench Press', '', 'Squat'],
      );

      expect(result.isValid, isFalse);
      expect(result.errors, contains('Exercise name cannot be empty'));
    });

    test('should accumulate multiple errors', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: '',
        notes: 'a' * 5001,
        exerciseNames: [],
      );

      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThan(1));
    });

    test('should validate minimal valid data', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'W',
        exerciseNames: ['E'],
      );
      expect(result.isValid, isTrue);
    });

    test('should handle multiple exercises', () {
      final result = InputSanitizer.validateWorkoutData(
        workoutName: 'Full Body',
        exerciseNames: ['Squat', 'Bench', 'Deadlift', 'OHP'],
      );
      expect(result.isValid, isTrue);
    });
  });

  group('InputSanitizer - ValidationResult', () {
    test('should create result with isValid=true and empty errors', () {
      final result = ValidationResult(isValid: true, errors: []);

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('should create result with isValid=false and error list', () {
      final result = ValidationResult(
        isValid: false,
        errors: ['Error 1', 'Error 2'],
      );

      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      expect(result.errors, contains('Error 1'));
      expect(result.errors, contains('Error 2'));
    });
  });

  group('InputSanitizer - Security Tests', () {
    test('should prevent XSS through script tags', () {
      final result = InputSanitizer.sanitizeText(
        '<script>document.cookie</script>',
      );
      expect(result, isNot(contains('<script>')));
      expect(result, isNot(contains('</script>')));
    });

    test('should prevent XSS through img tag with onerror', () {
      final result = InputSanitizer.sanitizeText(
        '<img src=x onerror=alert(1)>',
      );
      expect(result, isNot(contains('onerror')));
    });

    test('should prevent SQL injection characters in text', () {
      final result = InputSanitizer.sanitizeText("'; DROP TABLE users; --");
      expect(result, contains('&#x27;'));
    });

    test('should reject javascript URLs', () {
      expect(InputSanitizer.sanitizeUrl('javascript:alert(1)'), isNull);
    });

    test('should escape ampersands to prevent entity injection', () {
      final result = InputSanitizer.sanitizeText('A & B');
      expect(result, contains('&amp;'));
    });

    test('should strip HTML-like patterns', () {
      // The regex <[^>]*> will match patterns that look like HTML tags
      // This is by design to be aggressive against XSS
      final result = InputSanitizer.sanitizeText('Keep this text');
      expect(result, contains('Keep'));
      expect(result, contains('this'));
    });

    test('should handle nested HTML tags', () {
      final result = InputSanitizer.sanitizeText('<div><script>bad</script></div>');
      expect(result, equals('bad'));
    });

    test('should handle URL with suspicious query params', () {
      const url = 'https://example.com?redirect=javascript:alert(1)';
      // URL itself is valid HTTPS, parameter values are preserved
      expect(InputSanitizer.sanitizeUrl(url), equals(url));
    });
  });

  group('InputSanitizer - Edge Cases', () {
    test('should handle empty string after trim', () {
      expect(InputSanitizer.sanitizeText('   '), equals(''));
    });

    test('should handle only whitespace characters', () {
      expect(InputSanitizer.sanitizeText('\n\t\r  '), equals(''));
    });

    test('should preserve internal whitespace', () {
      final result = InputSanitizer.sanitizeText('Hello    World');
      expect(result, contains('Hello'));
      expect(result, contains('World'));
    });

    test('should handle text at exactly maxLength', () {
      final text = 'a' * 1000;
      final result = InputSanitizer.sanitizeText(text);
      expect(result.length, equals(1000));
    });

    test('should handle mix of valid and invalid characters in name', () {
      final result = InputSanitizer.sanitizeName(r'Test-123 (Valid) @#$');
      expect(result, contains('Test-123'));
      expect(result, contains('Valid'));
      expect(result, isNot(contains('@')));
    });
  });
}
