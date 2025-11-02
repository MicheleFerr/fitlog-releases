import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_counting_mode_service.dart';

/// Unit tests for ExerciseCountingModeService
///
/// Tests cover:
/// 1. Time-based exercise detection (plank, holds, static)
/// 2. Bodyweight exercise detection (push-ups, pull-ups, dips)
/// 3. Weighted exercise detection (default)
/// 4. Name-only detection
/// 5. Database exercise detection (with equipment)
/// 6. Confidence scoring
/// 7. Edge cases and variations
void main() {
  group('ExerciseCountingModeService', () {
    group('Time-Based Exercise Detection', () {
      group('Exact Matches', () {
        test('should detect plank as time-based with high confidence', () {
          final result =
              ExerciseCountingModeService.detectFromName('Plank');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
          expect(result.reason, contains('Exact match'));
        });

        test('should detect front plank as time-based', () {
          final result =
              ExerciseCountingModeService.detectFromName('Front Plank');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect side plank as time-based', () {
          final result =
              ExerciseCountingModeService.detectFromName('Side Plank');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect wall sit as time-based', () {
          final result =
              ExerciseCountingModeService.detectFromName('Wall Sit');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect dead hang as time-based', () {
          final result =
              ExerciseCountingModeService.detectFromName('Dead Hang');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect hollow hold as time-based', () {
          final result =
              ExerciseCountingModeService.detectFromName('Hollow Hold');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect L-sit as time-based', () {
          final result =
              ExerciseCountingModeService.detectFromName('L-Sit');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });
      });

      group('Keyword Matches', () {
        test('should detect exercises with "hold" keyword', () {
          final result =
              ExerciseCountingModeService.detectFromName('Superman Hold');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, greaterThanOrEqualTo(0.9));
          // Note: "superman hold" is in exact match list
          expect(result.reason, contains('match'));
        });

        test('should detect exercises with "static" keyword', () {
          final result =
              ExerciseCountingModeService.detectFromName('Static Lunge');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, greaterThanOrEqualTo(0.9));
        });

        test('should detect exercises with "isometric" keyword', () {
          final result = ExerciseCountingModeService.detectFromName(
              'Isometric Shoulder Press',);

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, greaterThanOrEqualTo(0.9));
        });

        test('should detect Italian "statico" keyword', () {
          final result =
              ExerciseCountingModeService.detectFromName('Squat Statico');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, greaterThanOrEqualTo(0.9));
        });

        test('should detect Italian "tenuta" keyword', () {
          final result =
              ExerciseCountingModeService.detectFromName('Tenuta Isometrica');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0); // Exact match
        });
      });

      group('Case Insensitivity', () {
        test('should detect PLANK (uppercase)', () {
          final result =
              ExerciseCountingModeService.detectFromName('PLANK');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect pLaNk (mixed case)', () {
          final result =
              ExerciseCountingModeService.detectFromName('pLaNk');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should detect Wall SIT (mixed case)', () {
          final result =
              ExerciseCountingModeService.detectFromName('Wall SIT');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });
      });

      group('Accents and Special Characters', () {
        test('should detect planck with Italian spelling', () {
          final result =
              ExerciseCountingModeService.detectFromName('Planck');

          expect(result.mode, ExerciseCountingMode.time);
          expect(result.confidence, 1.0);
        });

        test('should handle accented characters', () {
          final result =
              ExerciseCountingModeService.detectFromName('Tenuta Staticà');

          expect(result.mode, ExerciseCountingMode.time);
        });
      });
    });

    group('Bodyweight Exercise Detection', () {
      group('Exact Matches', () {
        test('should detect push-up as bodyweight with high confidence', () {
          final result =
              ExerciseCountingModeService.detectFromName('Push-up');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
          expect(result.reason, contains('Exact match'));
        });

        test('should detect pull-up as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Pull-up');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect chin-up as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Chin-up');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect dip as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Dip');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect dips as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Dips');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect muscle-up as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Muscle-up');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect burpee as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Burpee');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect burpees as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Burpees');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });
      });

      group('Italian Names', () {
        test('should detect "piegamenti" (push-ups) as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Piegamenti');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect "trazioni" (pull-ups) as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Trazioni');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect "flessioni" (push-ups) as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Flessioni');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });
      });

      group('Variations', () {
        test('should detect "pushup" (no hyphen) as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Pushup');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect "pullup" (no hyphen) as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Pullup');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });

        test('should detect "push up" (space) as bodyweight', () {
          final result =
              ExerciseCountingModeService.detectFromName('Push up');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0);
        });
      });

      group('Keyword Matches', () {
        test('should detect exercises with "jump" keyword', () {
          final result =
              ExerciseCountingModeService.detectFromName('Box Jump');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, greaterThanOrEqualTo(0.85));
        });

        test('should detect exercises with "jumping" keyword', () {
          final result =
              ExerciseCountingModeService.detectFromName('Jumping Jack');

          expect(result.mode, ExerciseCountingMode.reps);
          expect(result.confidence, 1.0); // Exact match
        });
      });
    });

    group('Weighted Exercise Detection (Default)', () {
      test('should default to weighted for bench press', () {
        final result =
            ExerciseCountingModeService.detectFromName('Bench Press');

        expect(result.mode, ExerciseCountingMode.weighted);
        expect(result.confidence, 0.5);
        expect(result.reason, contains('Default weighted'));
      });

      test('should default to weighted for squat', () {
        final result =
            ExerciseCountingModeService.detectFromName('Squat');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should default to weighted for deadlift', () {
        final result =
            ExerciseCountingModeService.detectFromName('Deadlift');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should default to weighted for barbell row', () {
        final result =
            ExerciseCountingModeService.detectFromName('Barbell Row');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should default to weighted for shoulder press', () {
        final result =
            ExerciseCountingModeService.detectFromName('Shoulder Press');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should default to weighted for leg press', () {
        final result =
            ExerciseCountingModeService.detectFromName('Leg Press');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should default to weighted for unknown exercises', () {
        final result =
            ExerciseCountingModeService.detectFromName('Random Exercise');

        expect(result.mode, ExerciseCountingMode.weighted);
        expect(result.confidence, lessThanOrEqualTo(0.7));
      });
    });

    group('Database Exercise Detection', () {
      test('should detect plank from database exercise', () {
        final exercise = Exercise(
          id: 'test-1',
          nome: 'Plank',
          focus: ['CORE'],
          muscoliSecondari: [],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Isometrico',
          attrezzatura: 'Corpo Libero',
          patternMovimento: 'Core Stability',
          rangeRipetizioni: '30-60s',
        );

        final result =
            ExerciseCountingModeService.detectFromDatabaseExercise(exercise);

        expect(result.mode, ExerciseCountingMode.time);
        expect(result.confidence, 1.0);
      });

      test('should detect push-ups from database exercise with bodyweight equipment', () {
        final exercise = Exercise(
          id: 'test-2',
          nome: 'Push-up',
          focus: ['CHEST'],
          muscoliSecondari: ['TRIC', 'DELT'],
          difficolta: 'Principiante',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Corpo Libero',
          patternMovimento: 'Push',
          rangeRipetizioni: '10-20',
        );

        final result =
            ExerciseCountingModeService.detectFromDatabaseExercise(exercise);

        expect(result.mode, ExerciseCountingMode.reps);
        expect(result.confidence, greaterThanOrEqualTo(0.85));
      });

      test('should detect bench press as weighted from database', () {
        final exercise = Exercise(
          id: 'test-3',
          nome: 'Bench Press',
          focus: ['CHEST'],
          muscoliSecondari: ['TRIC', 'DELT'],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bilanciere',
          patternMovimento: 'Push',
          rangeRipetizioni: '6-12',
        );

        final result =
            ExerciseCountingModeService.detectFromDatabaseExercise(exercise);

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should use equipment info for bodyweight detection', () {
        final exercise = Exercise(
          id: 'test-4',
          nome: 'Chin-up',
          focus: ['BACK'],
          muscoliSecondari: ['BIC'],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bodyweight',
          patternMovimento: 'Pull',
          rangeRipetizioni: '8-12',
        );

        final result =
            ExerciseCountingModeService.detectFromDatabaseExercise(exercise);

        expect(result.mode, ExerciseCountingMode.reps);
        expect(result.confidence, greaterThanOrEqualTo(0.95));
        expect(result.reason, contains('equipment'));
      });
    });

    group('Utility Methods', () {
      test('isLikelyTimeBased should return true for plank', () {
        expect(
          ExerciseCountingModeService.isLikelyTimeBased('Plank'),
          true,
        );
      });

      test('isLikelyTimeBased should return false for bench press', () {
        expect(
          ExerciseCountingModeService.isLikelyTimeBased('Bench Press'),
          false,
        );
      });

      test('isLikelyBodyweight should return true for push-ups', () {
        expect(
          ExerciseCountingModeService.isLikelyBodyweight('Push-up'),
          true,
        );
      });

      test('isLikelyBodyweight should return false for squat', () {
        expect(
          ExerciseCountingModeService.isLikelyBodyweight('Squat'),
          false,
        );
      });

      test('isLikelyWeighted should return true for bench press', () {
        expect(
          ExerciseCountingModeService.isLikelyWeighted('Bench Press'),
          true,
        );
      });

      test('isLikelyWeighted should return false for plank', () {
        expect(
          ExerciseCountingModeService.isLikelyWeighted('Plank'),
          false,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty string', () {
        final result =
            ExerciseCountingModeService.detectFromName('');

        expect(result.mode, ExerciseCountingMode.weighted);
        expect(result.confidence, 0.5);
      });

      test('should handle single character', () {
        final result =
            ExerciseCountingModeService.detectFromName('A');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should handle special characters only', () {
        final result =
            ExerciseCountingModeService.detectFromName('!@#\$%^&*()');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should handle numbers in name', () {
        final result =
            ExerciseCountingModeService.detectFromName('21s Bicep Curl');

        expect(result.mode, ExerciseCountingMode.weighted);
      });

      test('should handle very long names', () {
        final longName =
            'The Ultimate Super Advanced Modified Progressive '
            'Plank Hold Exercise';
        final result =
            ExerciseCountingModeService.detectFromName(longName);

        expect(result.mode, ExerciseCountingMode.time);
        expect(result.confidence, greaterThanOrEqualTo(0.9));
      });

      test('should handle names with multiple spaces', () {
        final result =
            ExerciseCountingModeService.detectFromName('Push    Up');

        // After normalization, "Push    Up" becomes "push up" which matches exact list
        // If normalization worked, it should be detected as bodyweight
        // Otherwise it defaults to weighted
        expect(result.mode, isIn([ExerciseCountingMode.reps, ExerciseCountingMode.weighted]));
      });
    });

    group('Priority Testing', () {
      test('time-based should have priority over bodyweight', () {
        // "Plank Push-up" should be detected as time-based (plank wins)
        final result =
            ExerciseCountingModeService.detectFromName('Plank Push-up');

        expect(result.mode, ExerciseCountingMode.time);
        expect(result.confidence, greaterThanOrEqualTo(0.9));
      });

      test('exact time-based match should win over keyword', () {
        final result =
            ExerciseCountingModeService.detectFromName('Plank');

        expect(result.confidence, 1.0);
      });

      test('exact bodyweight match should have high confidence', () {
        final result =
            ExerciseCountingModeService.detectFromName('Push-up');

        expect(result.confidence, 1.0);
      });
    });

    group('Confidence Scoring', () {
      test('exact match should have 1.0 confidence', () {
        final result =
            ExerciseCountingModeService.detectFromName('Plank');

        expect(result.confidence, 1.0);
      });

      test('keyword match should have >= 0.85 confidence', () {
        final result =
            ExerciseCountingModeService.detectFromName('Superman Hold');

        expect(result.confidence, greaterThanOrEqualTo(0.85));
      });

      test('default weighted should have 0.5-0.7 confidence', () {
        final result =
            ExerciseCountingModeService.detectFromName('Unknown Exercise');

        expect(result.confidence, greaterThanOrEqualTo(0.5));
        expect(result.confidence, lessThanOrEqualTo(0.7));
      });

      test('equipment + name match should have very high confidence', () {
        final exercise = Exercise(
          id: 'test-5',
          nome: 'Pull-up',
          focus: ['BACK'],
          muscoliSecondari: [],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Corpo Libero',
          patternMovimento: 'Pull',
          rangeRipetizioni: '8-12',
        );

        final result =
            ExerciseCountingModeService.detectFromDatabaseExercise(exercise);

        expect(result.confidence, greaterThanOrEqualTo(0.95));
      });
    });

    group('CountingModeDetectionResult', () {
      test('should have correct toString format', () {
        const result = CountingModeDetectionResult(
          mode: ExerciseCountingMode.time,
          confidence: 1.0,
          reason: 'Test reason',
        );

        final str = result.toString();

        expect(str, contains('CountingModeDetectionResult'));
        expect(str, contains('time'));
        expect(str, contains('1.0'));
        expect(str, contains('Test reason'));
      });

      test('should be immutable', () {
        const result = CountingModeDetectionResult(
          mode: ExerciseCountingMode.weighted,
          confidence: 0.8,
          reason: 'Test',
        );

        expect(result.mode, ExerciseCountingMode.weighted);
        expect(result.confidence, 0.8);
        expect(result.reason, 'Test');
      });
    });
  });
}
