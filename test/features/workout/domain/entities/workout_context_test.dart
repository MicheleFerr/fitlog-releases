import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_context.dart';

void main() {
  final timestamp = DateTime(2026, 2, 15, 10, 30);

  group('WorkoutContext', () {
    group('constructor', () {
      test('creates instance with required fields only', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
        );

        expect(ctx.timeAvailable, 30);
        expect(ctx.timestamp, timestamp);
        expect(ctx.experienceLevel, isNull);
        expect(ctx.gender, isNull);
        expect(ctx.completionTimeMs, isNull);
      });

      test('creates instance with all fields', () {
        final ctx = WorkoutContext(
          timeAvailable: 45,
          experienceLevel: ExperienceLevel.advanced,
          gender: 'male',
          timestamp: timestamp,
          completionTimeMs: 8000,
        );

        expect(ctx.timeAvailable, 45);
        expect(ctx.experienceLevel, ExperienceLevel.advanced);
        expect(ctx.gender, 'male');
        expect(ctx.timestamp, timestamp);
        expect(ctx.completionTimeMs, 8000);
      });
    });

    group('needsExperienceLevel', () {
      test('true when timeAvailable is 30', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx.needsExperienceLevel, isTrue);
      });

      test('true when timeAvailable is 45', () {
        final ctx = WorkoutContext(timeAvailable: 45, timestamp: timestamp);
        expect(ctx.needsExperienceLevel, isTrue);
      });

      test('false when timeAvailable is 15', () {
        final ctx = WorkoutContext(timeAvailable: 15, timestamp: timestamp);
        expect(ctx.needsExperienceLevel, isFalse);
      });

      test('false when timeAvailable is 5', () {
        final ctx = WorkoutContext(timeAvailable: 5, timestamp: timestamp);
        expect(ctx.needsExperienceLevel, isFalse);
      });

      test('boundary: exactly 30 returns true', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx.needsExperienceLevel, isTrue);
      });

      test('boundary: 29 returns false', () {
        final ctx = WorkoutContext(timeAvailable: 29, timestamp: timestamp);
        expect(ctx.needsExperienceLevel, isFalse);
      });
    });

    group('suggestedExerciseCount', () {
      test('returns 2 for time < 30', () {
        final ctx = WorkoutContext(timeAvailable: 15, timestamp: timestamp);
        expect(ctx.suggestedExerciseCount, 2);
      });

      test('returns 2 for time 5', () {
        final ctx = WorkoutContext(timeAvailable: 5, timestamp: timestamp);
        expect(ctx.suggestedExerciseCount, 2);
      });

      test('returns 3 for time >= 30 with no experience level', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx.suggestedExerciseCount, 3);
      });

      test('returns 3 for beginner with time >= 30', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          timestamp: timestamp,
        );
        expect(ctx.suggestedExerciseCount, 3);
      });

      test('returns 4 for intermediate with time >= 30', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.intermediate,
          timestamp: timestamp,
        );
        expect(ctx.suggestedExerciseCount, 4);
      });

      test('returns 5 for advanced with time >= 30', () {
        final ctx = WorkoutContext(
          timeAvailable: 45,
          experienceLevel: ExperienceLevel.advanced,
          timestamp: timestamp,
        );
        expect(ctx.suggestedExerciseCount, 5);
      });

      test('ignores experience level when time < 30', () {
        final ctx = WorkoutContext(
          timeAvailable: 15,
          experienceLevel: ExperienceLevel.advanced,
          timestamp: timestamp,
        );
        expect(ctx.suggestedExerciseCount, 2);
      });
    });

    group('hasFullContext', () {
      test('true when both experienceLevel and gender are set', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          gender: 'female',
          timestamp: timestamp,
        );
        expect(ctx.hasFullContext, isTrue);
      });

      test('false when experienceLevel is null', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          gender: 'male',
          timestamp: timestamp,
        );
        expect(ctx.hasFullContext, isFalse);
      });

      test('false when gender is null', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.intermediate,
          timestamp: timestamp,
        );
        expect(ctx.hasFullContext, isFalse);
      });

      test('false when both are null', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx.hasFullContext, isFalse);
      });
    });

    group('hasMinimalContext', () {
      test('true when experienceLevel is set', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          timestamp: timestamp,
        );
        expect(ctx.hasMinimalContext, isTrue);
      });

      test('false when experienceLevel is null', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx.hasMinimalContext, isFalse);
      });

      test('true even without gender', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.advanced,
          timestamp: timestamp,
        );
        expect(ctx.hasMinimalContext, isTrue);
        expect(ctx.hasFullContext, isFalse);
      });
    });

    group('completionSpeedCategory', () {
      test('returns unknown when completionTimeMs is null', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx.completionSpeedCategory, 'unknown');
      });

      test('returns turbo for < 6000ms', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 3000,
        );
        expect(ctx.completionSpeedCategory, 'turbo');
      });

      test('returns turbo for 0ms', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 0,
        );
        expect(ctx.completionSpeedCategory, 'turbo');
      });

      test('returns turbo for 5999ms', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 5999,
        );
        expect(ctx.completionSpeedCategory, 'turbo');
      });

      test('returns normal for 6000ms (boundary)', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 6000,
        );
        expect(ctx.completionSpeedCategory, 'normal');
      });

      test('returns normal for 10000ms', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 10000,
        );
        expect(ctx.completionSpeedCategory, 'normal');
      });

      test('returns normal for 15000ms (boundary)', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 15000,
        );
        expect(ctx.completionSpeedCategory, 'normal');
      });

      test('returns slow for 15001ms', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 15001,
        );
        expect(ctx.completionSpeedCategory, 'slow');
      });

      test('returns slow for 30000ms', () {
        final ctx = WorkoutContext(
          timeAvailable: 30,
          timestamp: timestamp,
          completionTimeMs: 30000,
        );
        expect(ctx.completionSpeedCategory, 'slow');
      });
    });

    group('fromMap', () {
      test('parses all fields', () {
        final map = {
          'time_available': 45,
          'experience_level': 'advanced',
          'gender': 'male',
          'timestamp': '2026-02-15T10:30:00.000',
          'completion_time_ms': 8000,
        };

        final ctx = WorkoutContext.fromMap(map);

        expect(ctx.timeAvailable, 45);
        expect(ctx.experienceLevel, ExperienceLevel.advanced);
        expect(ctx.gender, 'male');
        expect(ctx.timestamp, DateTime(2026, 2, 15, 10, 30));
        expect(ctx.completionTimeMs, 8000);
      });

      test('handles null optional fields', () {
        final map = {
          'time_available': 15,
          'experience_level': null,
          'gender': null,
          'timestamp': '2026-02-15T10:30:00.000',
          'completion_time_ms': null,
        };

        final ctx = WorkoutContext.fromMap(map);

        expect(ctx.timeAvailable, 15);
        expect(ctx.experienceLevel, isNull);
        expect(ctx.gender, isNull);
        expect(ctx.completionTimeMs, isNull);
      });

      test('parses Italian experience levels', () {
        final map = {
          'time_available': 30,
          'experience_level': 'principiante',
          'timestamp': '2026-02-15T10:30:00.000',
        };

        final ctx = WorkoutContext.fromMap(map);
        expect(ctx.experienceLevel, ExperienceLevel.beginner);
      });

      test('parses intermedio as intermediate', () {
        final map = {
          'time_available': 30,
          'experience_level': 'intermedio',
          'timestamp': '2026-02-15T10:30:00.000',
        };

        final ctx = WorkoutContext.fromMap(map);
        expect(ctx.experienceLevel, ExperienceLevel.intermediate);
      });

      test('parses avanzato as advanced', () {
        final map = {
          'time_available': 30,
          'experience_level': 'avanzato',
          'timestamp': '2026-02-15T10:30:00.000',
        };

        final ctx = WorkoutContext.fromMap(map);
        expect(ctx.experienceLevel, ExperienceLevel.advanced);
      });
    });

    group('toMap', () {
      test('serializes all fields', () {
        final ctx = WorkoutContext(
          timeAvailable: 45,
          experienceLevel: ExperienceLevel.advanced,
          gender: 'male',
          timestamp: timestamp,
          completionTimeMs: 8000,
        );

        final map = ctx.toMap();

        expect(map['time_available'], 45);
        expect(map['experience_level'], 'advanced');
        expect(map['gender'], 'male');
        expect(map['timestamp'], timestamp.toIso8601String());
        expect(map['completion_time_ms'], 8000);
        expect(map['suggested_exercise_count'], 5);
        expect(map['has_full_context'], isTrue);
        expect(map['completion_speed_category'], 'normal');
      });

      test('serializes null fields', () {
        final ctx = WorkoutContext(
          timeAvailable: 15,
          timestamp: timestamp,
        );

        final map = ctx.toMap();

        expect(map['experience_level'], isNull);
        expect(map['gender'], isNull);
        expect(map['completion_time_ms'], isNull);
        expect(map['has_full_context'], isFalse);
        expect(map['completion_speed_category'], 'unknown');
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trips with full context', () {
        final original = WorkoutContext(
          timeAvailable: 45,
          experienceLevel: ExperienceLevel.intermediate,
          gender: 'female',
          timestamp: timestamp,
          completionTimeMs: 12000,
        );

        final map = original.toMap();
        final restored = WorkoutContext.fromMap(map);

        expect(restored.timeAvailable, original.timeAvailable);
        expect(restored.experienceLevel, original.experienceLevel);
        expect(restored.gender, original.gender);
        expect(restored.completionTimeMs, original.completionTimeMs);
      });

      test('round-trips with minimal context', () {
        final original = WorkoutContext(
          timeAvailable: 15,
          timestamp: timestamp,
        );

        final map = original.toMap();
        final restored = WorkoutContext.fromMap(map);

        expect(restored.timeAvailable, original.timeAvailable);
        expect(restored.experienceLevel, isNull);
        expect(restored.gender, isNull);
      });
    });

    group('copyWith', () {
      test('copies with new timeAvailable', () {
        final original = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        final copied = original.copyWith(timeAvailable: 45);

        expect(copied.timeAvailable, 45);
        expect(copied.timestamp, timestamp);
      });

      test('copies with new experienceLevel', () {
        final original = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        final copied = original.copyWith(experienceLevel: ExperienceLevel.beginner);

        expect(copied.experienceLevel, ExperienceLevel.beginner);
        expect(copied.timeAvailable, 30);
      });

      test('copies with new gender', () {
        final original = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        final copied = original.copyWith(gender: 'other');

        expect(copied.gender, 'other');
      });

      test('copies with new completionTimeMs', () {
        final original = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        final copied = original.copyWith(completionTimeMs: 5000);

        expect(copied.completionTimeMs, 5000);
      });

      test('preserves all unmodified fields', () {
        final original = WorkoutContext(
          timeAvailable: 45,
          experienceLevel: ExperienceLevel.advanced,
          gender: 'male',
          timestamp: timestamp,
          completionTimeMs: 8000,
        );

        final copied = original.copyWith(timeAvailable: 30);

        expect(copied.timeAvailable, 30);
        expect(copied.experienceLevel, ExperienceLevel.advanced);
        expect(copied.gender, 'male');
        expect(copied.timestamp, timestamp);
        expect(copied.completionTimeMs, 8000);
      });
    });

    group('equality', () {
      test('equal when timeAvailable, experienceLevel, and gender match', () {
        final a = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          gender: 'male',
          timestamp: DateTime(2026, 1, 1),
        );
        final b = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          gender: 'male',
          timestamp: DateTime(2026, 2, 2), // different timestamp
        );

        expect(a, equals(b));
      });

      test('not equal when timeAvailable differs', () {
        final a = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        final b = WorkoutContext(timeAvailable: 45, timestamp: timestamp);

        expect(a, isNot(equals(b)));
      });

      test('not equal when experienceLevel differs', () {
        final a = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          timestamp: timestamp,
        );
        final b = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.advanced,
          timestamp: timestamp,
        );

        expect(a, isNot(equals(b)));
      });

      test('not equal when gender differs', () {
        final a = WorkoutContext(
          timeAvailable: 30,
          gender: 'male',
          timestamp: timestamp,
        );
        final b = WorkoutContext(
          timeAvailable: 30,
          gender: 'female',
          timestamp: timestamp,
        );

        expect(a, isNot(equals(b)));
      });

      test('equal when both have null optionals', () {
        final a = WorkoutContext(timeAvailable: 15, timestamp: DateTime(2026, 1, 1));
        final b = WorkoutContext(timeAvailable: 15, timestamp: DateTime(2026, 3, 3));

        expect(a, equals(b));
      });

      test('identical instance is equal', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx, equals(ctx));
      });

      test('not equal to non-WorkoutContext', () {
        final ctx = WorkoutContext(timeAvailable: 30, timestamp: timestamp);
        expect(ctx == 'not a context', isFalse);
      });
    });

    group('hashCode', () {
      test('same for equal instances', () {
        final a = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          gender: 'male',
          timestamp: DateTime(2026, 1, 1),
        );
        final b = WorkoutContext(
          timeAvailable: 30,
          experienceLevel: ExperienceLevel.beginner,
          gender: 'male',
          timestamp: DateTime(2026, 5, 5),
        );

        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('toString', () {
      test('includes relevant fields', () {
        final ctx = WorkoutContext(
          timeAvailable: 45,
          experienceLevel: ExperienceLevel.advanced,
          gender: 'male',
          timestamp: timestamp,
          completionTimeMs: 10000,
        );

        final str = ctx.toString();

        expect(str, contains('WorkoutContext'));
        expect(str, contains('45min'));
        expect(str, contains('advanced'));
        expect(str, contains('male'));
        expect(str, contains('5')); // suggestedExerciseCount
        expect(str, contains('normal')); // completionSpeedCategory
      });

      test('shows none for null fields', () {
        final ctx = WorkoutContext(timeAvailable: 15, timestamp: timestamp);
        final str = ctx.toString();

        expect(str, contains('none'));
      });
    });

    group('ExperienceLevel.fromString', () {
      test('parses beginner', () {
        expect(ExperienceLevel.fromString('beginner'), ExperienceLevel.beginner);
      });

      test('parses intermediate', () {
        expect(ExperienceLevel.fromString('intermediate'), ExperienceLevel.intermediate);
      });

      test('parses advanced', () {
        expect(ExperienceLevel.fromString('advanced'), ExperienceLevel.advanced);
      });

      test('parses principiante (Italian)', () {
        expect(ExperienceLevel.fromString('principiante'), ExperienceLevel.beginner);
      });

      test('parses intermedio (Italian)', () {
        expect(ExperienceLevel.fromString('intermedio'), ExperienceLevel.intermediate);
      });

      test('parses avanzato (Italian)', () {
        expect(ExperienceLevel.fromString('avanzato'), ExperienceLevel.advanced);
      });

      test('is case-insensitive', () {
        expect(ExperienceLevel.fromString('BEGINNER'), ExperienceLevel.beginner);
        expect(ExperienceLevel.fromString('Intermediate'), ExperienceLevel.intermediate);
        expect(ExperienceLevel.fromString('ADVANCED'), ExperienceLevel.advanced);
      });

      test('trims whitespace', () {
        expect(ExperienceLevel.fromString('  beginner  '), ExperienceLevel.beginner);
      });

      test('returns null for invalid string', () {
        expect(ExperienceLevel.fromString('expert'), isNull);
        expect(ExperienceLevel.fromString('pro'), isNull);
      });

      test('returns null for null', () {
        expect(ExperienceLevel.fromString(null), isNull);
      });

      test('returns null for empty string', () {
        expect(ExperienceLevel.fromString(''), isNull);
      });
    });

    group('ExperienceLevel.suggestedExerciseCount', () {
      test('beginner returns 3', () {
        expect(ExperienceLevel.beginner.suggestedExerciseCount, 3);
      });

      test('intermediate returns 4', () {
        expect(ExperienceLevel.intermediate.suggestedExerciseCount, 4);
      });

      test('advanced returns 5', () {
        expect(ExperienceLevel.advanced.suggestedExerciseCount, 5);
      });
    });
  });
}
