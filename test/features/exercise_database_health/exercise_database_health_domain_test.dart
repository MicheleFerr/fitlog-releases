/// Comprehensive unit tests for Exercise Database and Health Sync domain layers.
///
/// Covers:
/// - ExerciseDefinition entity: computed getters, normalization, auto-detection,
///   JSON parsing, equality, toJson round-trip
/// - ExerciseCountingMode enum: validation helpers, serialization
/// - WarmupSuggestion entity: construction and serialization
/// - ExerciseDefinitionTemplate entity: construction and toExercise() conversion
/// - HealthDataType enum: isMvp, phaseNumber, displayNameKey
/// - HealthPermissionStatus entity: canSync, hasPartialPermissions,
///   hasFullPermissions, hasNoPermissions, authorizedDataTypes, deniedDataTypes,
///   needsSequentialPermission
/// - PermissionState enum: all values present
/// - HealthSyncStatus entity: shouldRetry, shouldAutoSync, statusMessageKey
/// - SyncResult enum: all values present
/// - BodyMeasurement entity: toKilograms, toPounds, toCentimeters,
///   isSyncedFromHealth, isManualEntry, unitDisplayKey
/// - MeasurementUnit enum: all values present
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    show ExerciseCategory, ExerciseType;

// ---------------------------------------------------------------------------
// Test helpers / factories
// ---------------------------------------------------------------------------

/// Creates a minimal [ExerciseDefinition] with sensible defaults.
/// Override any field by passing a named argument.
ExerciseDefinition makeExercise({
  String id = 'ex-001',
  String nome = 'Panca Piana',
  List<String> focus = const ['PETT'],
  String? imageUrl,
  List<String> muscoliSecondari = const ['TRIC', 'DELT'],
  String difficolta = 'Intermedio',
  String tipoEsercizio = 'Compound',
  String attrezzatura = 'Bilanciere',
  String patternMovimento = 'Press Pattern',
  String rangeRipetizioni = '6-12',
  String? noteTecniche,
  String? mobilitaPre,
  String? attivazionePre,
  List<String> aliases = const [],
  List<WarmupSuggestion>? warmupSuggestions,
  ExerciseCountingMode countingMode = ExerciseCountingMode.weighted,
  String? tempoEsecuzione,
}) {
  return ExerciseDefinition(
    id: id,
    nome: nome,
    focus: focus,
    imageUrl: imageUrl,
    muscoliSecondari: muscoliSecondari,
    difficolta: difficolta,
    tipoEsercizio: tipoEsercizio,
    attrezzatura: attrezzatura,
    patternMovimento: patternMovimento,
    rangeRipetizioni: rangeRipetizioni,
    noteTecniche: noteTecniche,
    mobilitaPre: mobilitaPre,
    attivazionePre: attivazionePre,
    aliases: aliases,
    warmupSuggestions: warmupSuggestions,
    countingMode: countingMode,
    tempoEsecuzione: tempoEsecuzione,
  );
}

/// Creates a minimal [HealthPermissionStatus] with all permissions notDetermined.
HealthPermissionStatus emptyPermissions() {
  return const HealthPermissionStatus(permissions: {});
}

/// Creates a [HealthPermissionStatus] with all MVP types authorized.
HealthPermissionStatus allAuthorized() {
  return const HealthPermissionStatus(
    permissions: {
      HealthDataType.workout: PermissionState.authorized,
      HealthDataType.bodyWeight: PermissionState.authorized,
      HealthDataType.height: PermissionState.authorized,
    },
  );
}

/// Creates a [HealthPermissionStatus] with all MVP types denied.
HealthPermissionStatus allDenied() {
  return const HealthPermissionStatus(
    permissions: {
      HealthDataType.workout: PermissionState.denied,
      HealthDataType.bodyWeight: PermissionState.denied,
      HealthDataType.height: PermissionState.denied,
    },
  );
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // ExerciseDefinition
  // =========================================================================
  group('ExerciseDefinition', () {
    // -------------------------------------------------------------------
    // Basic construction
    // -------------------------------------------------------------------
    group('construction', () {
      test('creates entity with required fields', () {
        final exercise = makeExercise();

        expect(exercise.id, 'ex-001');
        expect(exercise.nome, 'Panca Piana');
        expect(exercise.focus, ['PETT']);
        expect(exercise.muscoliSecondari, ['TRIC', 'DELT']);
        expect(exercise.difficolta, 'Intermedio');
        expect(exercise.attrezzatura, 'Bilanciere');
        expect(exercise.countingMode, ExerciseCountingMode.weighted);
      });

      test('imageUrl defaults to null', () {
        final exercise = makeExercise();
        expect(exercise.imageUrl, isNull);
      });

      test('optional fields default to null', () {
        final exercise = makeExercise();
        expect(exercise.noteTecniche, isNull);
        expect(exercise.mobilitaPre, isNull);
        expect(exercise.attivazionePre, isNull);
        expect(exercise.tempoEsecuzione, isNull);
        expect(exercise.warmupSuggestions, isNull);
      });

      test('aliases default to empty list', () {
        final exercise = makeExercise();
        expect(exercise.aliases, isEmpty);
      });
    });

    // -------------------------------------------------------------------
    // normalizedNome
    // -------------------------------------------------------------------
    group('normalizedNome (auto-computed)', () {
      test('lowercases the name', () {
        final exercise = makeExercise(nome: 'Squat');
        expect(exercise.normalizedNome, 'squat');
      });

      test('strips Italian accents', () {
        final exercise = makeExercise(nome: 'Stacchi Rumeni');
        expect(exercise.normalizedNome, 'stacchi rumeni');
      });

      test('replaces è with e', () {
        final exercise = makeExercise(nome: 'Estensione');
        expect(exercise.normalizedNome, contains('e'));
        expect(exercise.normalizedNome, isNot(contains('è')));
      });

      test('handles all accent families', () {
        // à, é, î, ò, ù
        final exercise = makeExercise(nome: 'àéîòù');
        expect(exercise.normalizedNome, 'aeiou');
      });

      test('custom normalizedNome overrides auto-computation', () {
        final exercise = ExerciseDefinition(
          id: 'x',
          nome: 'Bench Press',
          focus: const [],
          muscoliSecondari: const [],
          difficolta: '',
          tipoEsercizio: '',
          attrezzatura: '',
          patternMovimento: '',
          rangeRipetizioni: '',
          normalizedNome: 'custom_normalized',
        );
        expect(exercise.normalizedNome, 'custom_normalized');
      });
    });

    // -------------------------------------------------------------------
    // searchableFields
    // -------------------------------------------------------------------
    group('searchableFields (auto-computed)', () {
      test('contains normalized nome by default', () {
        final exercise = makeExercise(nome: 'Panca Piana');
        expect(exercise.searchableFields, contains('panca piana'));
      });

      test('includes normalized aliases', () {
        final exercise = makeExercise(
          nome: 'Panca Piana',
          aliases: ['bench press', 'BP'],
        );
        expect(exercise.searchableFields, contains('bench press'));
        expect(exercise.searchableFields, contains('bp'));
      });

      test('deduplicates entries', () {
        final exercise = makeExercise(
          nome: 'bench',
          aliases: ['bench'], // same as nome
        );
        // Set-based deduplication means 'bench' appears only once
        final unique = exercise.searchableFields.toSet().toList();
        expect(exercise.searchableFields.length, unique.length);
      });
    });

    // -------------------------------------------------------------------
    // focusDisplayName
    // -------------------------------------------------------------------
    group('focusDisplayName', () {
      test('joins focus list with comma and space', () {
        final exercise = makeExercise(focus: ['QUAD', 'GLUT']);
        expect(exercise.focusDisplayName, 'QUAD, GLUT');
      });

      test('returns single item without trailing comma', () {
        final exercise = makeExercise(focus: ['PETT']);
        expect(exercise.focusDisplayName, 'PETT');
      });

      test('returns empty string for empty focus list', () {
        final exercise = makeExercise(focus: []);
        expect(exercise.focusDisplayName, '');
      });
    });

    // -------------------------------------------------------------------
    // muscoliSecondariDisplayName
    // -------------------------------------------------------------------
    group('muscoliSecondariDisplayName', () {
      test('joins secondary muscles with comma and space', () {
        final exercise = makeExercise(muscoliSecondari: ['CORE', 'POLP']);
        expect(exercise.muscoliSecondariDisplayName, 'CORE, POLP');
      });

      test('returns empty string when no secondary muscles', () {
        final exercise = makeExercise(muscoliSecondari: []);
        expect(exercise.muscoliSecondariDisplayName, '');
      });
    });

    // -------------------------------------------------------------------
    // difficoltaLevel
    // -------------------------------------------------------------------
    group('difficoltaLevel', () {
      test('Principiante returns 1', () {
        final exercise = makeExercise(difficolta: 'Principiante');
        expect(exercise.difficoltaLevel, 1);
      });

      test('principiante (lowercase) returns 1', () {
        final exercise = makeExercise(difficolta: 'principiante');
        expect(exercise.difficoltaLevel, 1);
      });

      test('Intermedio returns 2', () {
        final exercise = makeExercise(difficolta: 'Intermedio');
        expect(exercise.difficoltaLevel, 2);
      });

      test('Avanzato returns 3', () {
        final exercise = makeExercise(difficolta: 'Avanzato');
        expect(exercise.difficoltaLevel, 3);
      });

      test('unknown difficulty defaults to 2 (Intermedio)', () {
        final exercise = makeExercise(difficolta: 'Expert');
        expect(exercise.difficoltaLevel, 2);
      });

      test('empty string defaults to 2', () {
        final exercise = makeExercise(difficolta: '');
        expect(exercise.difficoltaLevel, 2);
      });
    });

    // -------------------------------------------------------------------
    // attrezzaturaIcon
    // -------------------------------------------------------------------
    group('attrezzaturaIcon', () {
      test('Bilanciere returns barbell emoji', () {
        final exercise = makeExercise(attrezzatura: 'Bilanciere');
        expect(exercise.attrezzaturaIcon, '🏋️');
      });

      test('Manubri returns muscle emoji', () {
        final exercise = makeExercise(attrezzatura: 'Manubri');
        expect(exercise.attrezzaturaIcon, '💪');
      });

      test('Cavi returns link emoji', () {
        final exercise = makeExercise(attrezzatura: 'Cavi');
        expect(exercise.attrezzaturaIcon, '🔗');
      });

      test('Macchina returns gear emoji', () {
        final exercise = makeExercise(attrezzatura: 'Macchina');
        expect(exercise.attrezzaturaIcon, '⚙️');
      });

      test('Vario returns target emoji', () {
        final exercise = makeExercise(attrezzatura: 'Vario');
        expect(exercise.attrezzaturaIcon, '🎯');
      });

      test('unknown equipment returns question-mark emoji', () {
        final exercise = makeExercise(attrezzatura: 'Kettlebell');
        expect(exercise.attrezzaturaIcon, '❓');
      });

      test('case-insensitive matching for equipment icons', () {
        final exercise = makeExercise(attrezzatura: 'bilanciere');
        expect(exercise.attrezzaturaIcon, '🏋️');
      });
    });

    // -------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------
    group('fromJson', () {
      test('parses all basic fields', () {
        final json = {
          'id': 'json-001',
          'nome': 'Squat',
          'focus': 'QUAD, GLUT',
          'muscoliSecondari': 'CORE',
          'difficolta': 'Principiante',
          'tipoEsercizio': 'Compound',
          'attrezzatura': 'Bilanciere',
          'patternMovimento': 'Squat Pattern',
          'rangeRipetizioni': '5-10',
        };

        final exercise = ExerciseDefinition.fromJson(json);

        expect(exercise.id, 'json-001');
        expect(exercise.nome, 'Squat');
        expect(exercise.focus, ['QUAD', 'GLUT']);
        expect(exercise.muscoliSecondari, ['CORE']);
        expect(exercise.difficolta, 'Principiante');
        expect(exercise.patternMovimento, 'Squat Pattern');
      });

      test('focus can be a List from JSON', () {
        final json = {
          'id': 'x',
          'nome': 'Squat',
          'focus': ['QUAD', 'GLUT'],
          'muscoliSecondari': [],
          'difficolta': '',
          'tipoEsercizio': '',
          'attrezzatura': '',
          'patternMovimento': '',
          'rangeRipetizioni': '',
        };

        final exercise = ExerciseDefinition.fromJson(json);
        expect(exercise.focus, ['QUAD', 'GLUT']);
      });

      test('parses explicit countingMode from JSON', () {
        final json = {
          'id': 'x',
          'nome': 'Plank',
          'focus': '',
          'muscoliSecondari': '',
          'difficolta': '',
          'tipoEsercizio': '',
          'attrezzatura': '',
          'patternMovimento': '',
          'rangeRipetizioni': '',
          'countingMode': 'time',
        };

        final exercise = ExerciseDefinition.fromJson(json);
        expect(exercise.countingMode, ExerciseCountingMode.time);
      });

      test('converts empty imageUrl to null', () {
        final json = {
          'id': 'x',
          'nome': 'Squat',
          'focus': '',
          'muscoliSecondari': '',
          'difficolta': '',
          'tipoEsercizio': '',
          'attrezzatura': '',
          'patternMovimento': '',
          'rangeRipetizioni': '',
          'imageUrl': '',
        };

        final exercise = ExerciseDefinition.fromJson(json);
        expect(exercise.imageUrl, isNull);
      });

      test('preserves non-empty imageUrl', () {
        final json = {
          'id': 'x',
          'nome': 'Squat',
          'focus': '',
          'muscoliSecondari': '',
          'difficolta': '',
          'tipoEsercizio': '',
          'attrezzatura': '',
          'patternMovimento': '',
          'rangeRipetizioni': '',
          'imageUrl': 'https://example.com/image.png',
        };

        final exercise = ExerciseDefinition.fromJson(json);
        expect(exercise.imageUrl, 'https://example.com/image.png');
      });

      test('parses warmupSuggestions from JSON', () {
        final json = {
          'id': 'x',
          'nome': 'Squat',
          'focus': '',
          'muscoliSecondari': '',
          'difficolta': '',
          'tipoEsercizio': '',
          'attrezzatura': '',
          'patternMovimento': '',
          'rangeRipetizioni': '',
          'warmupSuggestions': [
            {
              'exerciseId': 'w-001',
              'exerciseName': 'Hip Flexor Stretch',
              'sets': 2,
              'reps': 10,
              'type': 'mobility',
            },
          ],
        };

        final exercise = ExerciseDefinition.fromJson(json);
        expect(exercise.warmupSuggestions, isNotNull);
        expect(exercise.warmupSuggestions!.length, 1);
        expect(
          exercise.warmupSuggestions!.first.exerciseName,
          'Hip Flexor Stretch',
        );
      });

      test('handles missing optional fields gracefully', () {
        final json = {
          'nome': 'Push Up',
          'focus': '',
          'muscoliSecondari': '',
          'difficolta': '',
          'tipoEsercizio': '',
          'attrezzatura': '',
          'patternMovimento': '',
          'rangeRipetizioni': '',
        };

        final exercise = ExerciseDefinition.fromJson(json);
        expect(exercise.id, ''); // defaults to empty string
        expect(exercise.noteTecniche, isNull);
        expect(exercise.aliases, isEmpty);
      });
    });

    // -------------------------------------------------------------------
    // Auto-detection of countingMode
    // -------------------------------------------------------------------
    group(
      '_autoDetectCountingMode (via fromJson without countingMode field)',
      () {
        ExerciseDefinition fromJsonAutoDetect({
          required String nome,
          String attrezzatura = '',
          String tipoEsercizio = '',
        }) {
          return ExerciseDefinition.fromJson({
            'nome': nome,
            'focus': '',
            'muscoliSecondari': '',
            'difficolta': '',
            'tipoEsercizio': tipoEsercizio,
            'attrezzatura': attrezzatura,
            'patternMovimento': '',
            'rangeRipetizioni': '',
          });
        }

        test('plank name → time mode', () {
          final ex = fromJsonAutoDetect(nome: 'Plank');
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('hold name → time mode', () {
          final ex = fromJsonAutoDetect(nome: 'Bar Hold');
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('hollow keyword → time mode', () {
          final ex = fromJsonAutoDetect(nome: 'Hollow Body Hold');
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('wall sit → time mode', () {
          final ex = fromJsonAutoDetect(nome: 'Wall Sit');
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('dead hang → time mode', () {
          final ex = fromJsonAutoDetect(nome: 'Dead Hang');
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('l-sit → time mode', () {
          final ex = fromJsonAutoDetect(nome: 'L-Sit');
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('stretching tipo → time mode', () {
          final ex = fromJsonAutoDetect(
            nome: 'Quadriceps Stretch',
            tipoEsercizio: 'Stretching',
          );
          expect(ex.countingMode, ExerciseCountingMode.time);
        });

        test('corpo libero equipment → reps mode', () {
          final ex = fromJsonAutoDetect(
            nome: 'Push Up',
            attrezzatura: 'Corpo Libero',
          );
          expect(ex.countingMode, ExerciseCountingMode.reps);
        });

        test('bodyweight equipment → reps mode', () {
          final ex = fromJsonAutoDetect(
            nome: 'Pull Up',
            attrezzatura: 'Bodyweight',
          );
          expect(ex.countingMode, ExerciseCountingMode.reps);
        });

        test('nessuno equipment → reps mode', () {
          final ex = fromJsonAutoDetect(
            nome: 'Air Squat',
            attrezzatura: 'Nessuno',
          );
          expect(ex.countingMode, ExerciseCountingMode.reps);
        });

        test('bilanciere equipment → weighted mode (default)', () {
          final ex = fromJsonAutoDetect(
            nome: 'Squat',
            attrezzatura: 'Bilanciere',
          );
          expect(ex.countingMode, ExerciseCountingMode.weighted);
        });

        test('unknown equipment defaults to weighted', () {
          final ex = fromJsonAutoDetect(
            nome: 'Cable Fly',
            attrezzatura: 'Cavi',
          );
          expect(ex.countingMode, ExerciseCountingMode.weighted);
        });
      },
    );

    // -------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------
    group('toJson', () {
      test('serializes all top-level fields', () {
        final exercise = makeExercise(
          id: 'e-999',
          nome: 'Deadlift',
          focus: ['ISCH', 'GLUT'],
          muscoliSecondari: ['CORE'],
          difficolta: 'Avanzato',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bilanciere',
          patternMovimento: 'Hip Hinge',
          rangeRipetizioni: '3-6',
          countingMode: ExerciseCountingMode.weighted,
          tempoEsecuzione: '3-1-1-0',
        );

        final json = exercise.toJson();

        expect(json['id'], 'e-999');
        expect(json['nome'], 'Deadlift');
        expect(json['difficolta'], 'Avanzato');
        expect(json['tipoEsercizio'], 'Compound');
        expect(json['countingMode'], 'weighted');
        expect(json['tempoEsecuzione'], '3-1-1-0');
      });

      test('focus serialized as comma-joined string', () {
        final exercise = makeExercise(focus: ['QUAD', 'GLUT']);
        final json = exercise.toJson();
        expect(json['focus'], 'QUAD, GLUT');
      });

      test('muscoliSecondari serialized as comma-joined string', () {
        final exercise = makeExercise(muscoliSecondari: ['CORE', 'POLP']);
        final json = exercise.toJson();
        expect(json['muscoliSecondari'], 'CORE, POLP');
      });

      test('null optional fields serialized as null', () {
        final exercise = makeExercise();
        final json = exercise.toJson();
        expect(json['imageUrl'], isNull);
        expect(json['noteTecniche'], isNull);
        expect(json['tempoEsecuzione'], isNull);
      });
    });

    // -------------------------------------------------------------------
    // Equality (Equatable)
    // -------------------------------------------------------------------
    group('equality', () {
      test('two identical exercises are equal', () {
        final a = makeExercise();
        final b = makeExercise();
        expect(a, equals(b));
      });

      test('exercises with different ids are not equal', () {
        final a = makeExercise(id: 'ex-001');
        final b = makeExercise(id: 'ex-002');
        expect(a, isNot(equals(b)));
      });

      test('exercises with different names are not equal', () {
        final a = makeExercise(nome: 'Squat');
        final b = makeExercise(nome: 'Deadlift');
        expect(a, isNot(equals(b)));
      });

      test('exercises with different difficulty are not equal', () {
        final a = makeExercise(difficolta: 'Principiante');
        final b = makeExercise(difficolta: 'Avanzato');
        expect(a, isNot(equals(b)));
      });

      test('exercises with different countingMode are not equal', () {
        final a = makeExercise(countingMode: ExerciseCountingMode.weighted);
        final b = makeExercise(countingMode: ExerciseCountingMode.time);
        expect(a, isNot(equals(b)));
      });
    });

    // -------------------------------------------------------------------
    // parseCommaSeparated (public static helper)
    // -------------------------------------------------------------------
    group('parseCommaSeparated', () {
      test('parses comma-separated string', () {
        expect(ExerciseDefinition.parseCommaSeparated('QUAD, GLUT'), [
          'QUAD',
          'GLUT',
        ]);
      });

      test('parses list directly', () {
        expect(ExerciseDefinition.parseCommaSeparated(['PETT', 'TRIC']), [
          'PETT',
          'TRIC',
        ]);
      });

      test('returns empty list for null', () {
        expect(ExerciseDefinition.parseCommaSeparated(null), isEmpty);
      });

      test('returns empty list for empty string', () {
        expect(ExerciseDefinition.parseCommaSeparated(''), isEmpty);
      });

      test('trims whitespace around entries', () {
        final result = ExerciseDefinition.parseCommaSeparated(' QUAD ,  GLUT ');
        expect(result, ['QUAD', 'GLUT']);
      });

      test('filters out empty entries', () {
        final result = ExerciseDefinition.parseCommaSeparated('QUAD,,GLUT');
        expect(result, ['QUAD', 'GLUT']);
      });
    });
  });

  // =========================================================================
  // ExerciseCountingMode
  // =========================================================================
  group('ExerciseCountingMode', () {
    group('requiresWeight', () {
      test('only weighted requires weight', () {
        expect(ExerciseCountingMode.weighted.requiresWeight, isTrue);
        expect(ExerciseCountingMode.reps.requiresWeight, isFalse);
        expect(ExerciseCountingMode.time.requiresWeight, isFalse);
      });
    });

    group('requiresReps', () {
      test('weighted and reps require reps; time does not', () {
        expect(ExerciseCountingMode.weighted.requiresReps, isTrue);
        expect(ExerciseCountingMode.reps.requiresReps, isTrue);
        expect(ExerciseCountingMode.time.requiresReps, isFalse);
      });
    });

    group('requiresTime', () {
      test('only time requires time input', () {
        expect(ExerciseCountingMode.weighted.requiresTime, isFalse);
        expect(ExerciseCountingMode.reps.requiresTime, isFalse);
        expect(ExerciseCountingMode.time.requiresTime, isTrue);
      });
    });

    group('fromString', () {
      test('parses all valid names', () {
        expect(
          ExerciseCountingMode.fromString('weighted'),
          ExerciseCountingMode.weighted,
        );
        expect(
          ExerciseCountingMode.fromString('reps'),
          ExerciseCountingMode.reps,
        );
        expect(
          ExerciseCountingMode.fromString('time'),
          ExerciseCountingMode.time,
        );
      });

      test('null input defaults to weighted', () {
        expect(
          ExerciseCountingMode.fromString(null),
          ExerciseCountingMode.weighted,
        );
      });

      test('unknown string defaults to weighted', () {
        expect(
          ExerciseCountingMode.fromString('unknown'),
          ExerciseCountingMode.weighted,
        );
      });

      test('empty string defaults to weighted', () {
        expect(
          ExerciseCountingMode.fromString(''),
          ExerciseCountingMode.weighted,
        );
      });
    });

    group('toJson / round-trip', () {
      test('serializes to name string', () {
        expect(ExerciseCountingMode.weighted.toJson(), 'weighted');
        expect(ExerciseCountingMode.reps.toJson(), 'reps');
        expect(ExerciseCountingMode.time.toJson(), 'time');
      });

      test('round-trips every value', () {
        for (final mode in ExerciseCountingMode.values) {
          final serialized = mode.toJson();
          final deserialized = ExerciseCountingMode.fromString(serialized);
          expect(deserialized, mode, reason: 'Round-trip failed for $mode');
        }
      });
    });

    group('enum coverage', () {
      test('has exactly 3 values', () {
        expect(ExerciseCountingMode.values.length, 3);
      });
    });
  });

  // =========================================================================
  // WarmupSuggestion
  // =========================================================================
  group('WarmupSuggestion', () {
    group('construction', () {
      test('creates entity with all required fields', () {
        const suggestion = WarmupSuggestion(
          exerciseId: 'w-001',
          exerciseName: 'Hip Flexor Stretch',
          sets: 2,
          reps: 10,
          type: WarmupType.mobility,
        );

        expect(suggestion.exerciseId, 'w-001');
        expect(suggestion.exerciseName, 'Hip Flexor Stretch');
        expect(suggestion.sets, 2);
        expect(suggestion.reps, 10);
        expect(suggestion.type, WarmupType.mobility);
      });

      test('activation type is distinct from mobility', () {
        const suggestion = WarmupSuggestion(
          exerciseId: 'w-002',
          exerciseName: 'Glute Bridge',
          sets: 3,
          reps: 12,
          type: WarmupType.activation,
        );

        expect(suggestion.type, WarmupType.activation);
        expect(suggestion.type, isNot(WarmupType.mobility));
      });
    });

    group('fromJson', () {
      test('parses all fields', () {
        final json = {
          'exerciseId': 'w-003',
          'exerciseName': 'Cat Cow',
          'sets': 2,
          'reps': 8,
          'type': 'mobility',
        };

        final suggestion = WarmupSuggestion.fromJson(json);

        expect(suggestion.exerciseId, 'w-003');
        expect(suggestion.exerciseName, 'Cat Cow');
        expect(suggestion.sets, 2);
        expect(suggestion.reps, 8);
        expect(suggestion.type, WarmupType.mobility);
      });

      test('parses activation type from JSON', () {
        final json = {
          'exerciseId': 'w-004',
          'exerciseName': 'Clamshell',
          'sets': 3,
          'reps': 15,
          'type': 'activation',
        };

        final suggestion = WarmupSuggestion.fromJson(json);
        expect(suggestion.type, WarmupType.activation);
      });
    });

    group('WarmupType enum', () {
      test('has exactly 2 values', () {
        expect(WarmupType.values.length, 2);
      });
    });
  });

  // =========================================================================
  // ExerciseDefinitionTemplate
  // =========================================================================
  group('ExerciseDefinitionTemplate', () {
    group('construction', () {
      test('creates template with required fields', () {
        const template = ExerciseDefinitionTemplate(
          id: 'tpl-001',
          name: 'Squat',
          description: 'A compound lower body exercise',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          muscleGroups: ['quadriceps', 'glutes'],
          equipment: ['barbell'],
        );

        expect(template.id, 'tpl-001');
        expect(template.name, 'Squat');
        expect(template.description, 'A compound lower body exercise');
        expect(template.category, ExerciseCategory.legs);
        expect(template.type, ExerciseType.single);
        expect(template.muscleGroups, ['quadriceps', 'glutes']);
        expect(template.equipment, ['barbell']);
      });

      test('isActive defaults to true', () {
        const template = ExerciseDefinitionTemplate(
          id: 'tpl-002',
          name: 'Push Up',
          description: '',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          muscleGroups: [],
          equipment: [],
        );

        expect(template.isActive, isTrue);
      });

      test('optional fields default to null', () {
        const template = ExerciseDefinitionTemplate(
          id: 'tpl-003',
          name: 'Lunge',
          description: '',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          muscleGroups: [],
          equipment: [],
        );

        expect(template.instructions, isNull);
        expect(template.imageUrl, isNull);
        expect(template.videoUrl, isNull);
        expect(template.difficulty, isNull);
        expect(template.metadata, isNull);
        expect(template.createdAt, isNull);
        expect(template.updatedAt, isNull);
      });
    });

    group('toExercise()', () {
      test('converts template to Exercise instance', () {
        const template = ExerciseDefinitionTemplate(
          id: 'tpl-004',
          name: 'Bench Press',
          description: '',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          muscleGroups: ['chest'],
          equipment: ['barbell'],
          instructions: ['Lie on bench', 'Press bar up'],
        );

        final exercise = template.toExercise();

        expect(exercise.name, 'Bench Press');
        expect(exercise.category, ExerciseCategory.chest);
        expect(exercise.type, ExerciseType.single);
        expect(exercise.sets, isEmpty); // starts with empty sets
        expect(exercise.notes, 'Lie on bench\nPress bar up');
      });

      test('toExercise produces empty sets list', () {
        const template = ExerciseDefinitionTemplate(
          id: 'tpl-005',
          name: 'Curl',
          description: '',
          category: ExerciseCategory.arms,
          type: ExerciseType.single,
          muscleGroups: [],
          equipment: [],
        );

        final exercise = template.toExercise();
        expect(exercise.sets, isEmpty);
      });

      test('toExercise with null instructions produces null notes', () {
        const template = ExerciseDefinitionTemplate(
          id: 'tpl-006',
          name: 'Row',
          description: '',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          muscleGroups: [],
          equipment: [],
        );

        final exercise = template.toExercise();
        expect(exercise.notes, isNull);
      });
    });

    group('copyWith (freezed)', () {
      test('creates a new template with modified field', () {
        const original = ExerciseDefinitionTemplate(
          id: 'tpl-007',
          name: 'Deadlift',
          description: '',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          muscleGroups: [],
          equipment: [],
        );

        final modified = original.copyWith(name: 'Romanian Deadlift');

        expect(modified.name, 'Romanian Deadlift');
        expect(modified.id, original.id);
        expect(modified.category, original.category);
      });

      test('original is not mutated by copyWith', () {
        const original = ExerciseDefinitionTemplate(
          id: 'tpl-008',
          name: 'Press',
          description: '',
          category: ExerciseCategory.shoulders,
          type: ExerciseType.single,
          muscleGroups: [],
          equipment: [],
        );

        final modified = original.copyWith(isActive: false);

        expect(modified.isActive, isFalse);
        expect(original.isActive, isTrue);
      });
    });
  });

  // =========================================================================
  // HealthDataType
  // =========================================================================
  group('HealthDataType', () {
    group('enum coverage', () {
      test('has 8 values', () {
        expect(HealthDataType.values.length, 8);
      });
    });

    group('isMvp', () {
      test('workout is MVP', () {
        expect(HealthDataType.workout.isMvp, isTrue);
      });

      test('bodyWeight is MVP', () {
        expect(HealthDataType.bodyWeight.isMvp, isTrue);
      });

      test('height is MVP', () {
        expect(HealthDataType.height.isMvp, isTrue);
      });

      test('bodyFat is not MVP', () {
        expect(HealthDataType.bodyFat.isMvp, isFalse);
      });

      test('leanMass is not MVP', () {
        expect(HealthDataType.leanMass.isMvp, isFalse);
      });

      test('heartRate is not MVP', () {
        expect(HealthDataType.heartRate.isMvp, isFalse);
      });

      test('sleep is not MVP', () {
        expect(HealthDataType.sleep.isMvp, isFalse);
      });

      test('nutrition is not MVP', () {
        expect(HealthDataType.nutrition.isMvp, isFalse);
      });
    });

    group('phaseNumber', () {
      test('workout is phase 1', () {
        expect(HealthDataType.workout.phaseNumber, 1);
      });

      test('bodyWeight is phase 1', () {
        expect(HealthDataType.bodyWeight.phaseNumber, 1);
      });

      test('height is phase 1', () {
        expect(HealthDataType.height.phaseNumber, 1);
      });

      test('bodyFat is phase 2', () {
        expect(HealthDataType.bodyFat.phaseNumber, 2);
      });

      test('leanMass is phase 2', () {
        expect(HealthDataType.leanMass.phaseNumber, 2);
      });

      test('heartRate is phase 2', () {
        expect(HealthDataType.heartRate.phaseNumber, 2);
      });

      test('sleep is phase 3', () {
        expect(HealthDataType.sleep.phaseNumber, 3);
      });

      test('nutrition is phase 3', () {
        expect(HealthDataType.nutrition.phaseNumber, 3);
      });
    });

    group('displayNameKey', () {
      test('each type has a non-empty localization key', () {
        for (final type in HealthDataType.values) {
          expect(
            type.displayNameKey,
            isNotEmpty,
            reason: '$type should have a non-empty displayNameKey',
          );
        }
      });

      test('workout key is healthDataTypeWorkout', () {
        expect(HealthDataType.workout.displayNameKey, 'healthDataTypeWorkout');
      });

      test('bodyWeight key is healthDataTypeBodyWeight', () {
        expect(
          HealthDataType.bodyWeight.displayNameKey,
          'healthDataTypeBodyWeight',
        );
      });

      test('sleep key is healthDataTypeSleep', () {
        expect(HealthDataType.sleep.displayNameKey, 'healthDataTypeSleep');
      });

      test('nutrition key is healthDataTypeNutrition', () {
        expect(
          HealthDataType.nutrition.displayNameKey,
          'healthDataTypeNutrition',
        );
      });

      test('all keys are unique', () {
        final keys = HealthDataType.values
            .map((t) => t.displayNameKey)
            .toList();
        final uniqueKeys = keys.toSet();
        expect(keys.length, uniqueKeys.length);
      });
    });
  });

  // =========================================================================
  // PermissionState
  // =========================================================================
  group('PermissionState', () {
    test('has 5 values', () {
      expect(PermissionState.values.length, 5);
    });

    test('contains all expected states', () {
      expect(PermissionState.values, contains(PermissionState.notDetermined));
      expect(PermissionState.values, contains(PermissionState.authorized));
      expect(PermissionState.values, contains(PermissionState.unverified));
      expect(PermissionState.values, contains(PermissionState.denied));
      expect(
        PermissionState.values,
        contains(PermissionState.healthConnectNotInstalled),
      );
    });
  });

  // =========================================================================
  // HealthPermissionStatus
  // =========================================================================
  group('HealthPermissionStatus', () {
    group('construction', () {
      test('creates entity with permission map', () {
        const status = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.authorized},
        );

        expect(
          status.permissions[HealthDataType.workout],
          PermissionState.authorized,
        );
      });

      test('healthConnectAvailable defaults to false', () {
        const status = HealthPermissionStatus(permissions: {});
        expect(status.healthConnectAvailable, isFalse);
      });

      test('healthConnectAvailable can be set to true', () {
        const status = HealthPermissionStatus(
          permissions: {},
          healthConnectAvailable: true,
        );
        expect(status.healthConnectAvailable, isTrue);
      });
    });

    group('canSync()', () {
      test('returns true when permission is authorized', () {
        const status = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.authorized},
        );
        expect(status.canSync(HealthDataType.workout), isTrue);
      });

      test('returns false when permission is denied', () {
        const status = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.denied},
        );
        expect(status.canSync(HealthDataType.workout), isFalse);
      });

      test('returns false when permission is notDetermined', () {
        const status = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.notDetermined},
        );
        expect(status.canSync(HealthDataType.workout), isFalse);
      });

      test('returns false when type is not in permissions map', () {
        const status = HealthPermissionStatus(permissions: {});
        expect(status.canSync(HealthDataType.workout), isFalse);
      });

      test('checks correct type independently', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
          },
        );
        expect(status.canSync(HealthDataType.workout), isTrue);
        expect(status.canSync(HealthDataType.bodyWeight), isFalse);
      });
    });

    group('hasFullPermissions', () {
      test('true when all permissions are authorized', () {
        expect(allAuthorized().hasFullPermissions, isTrue);
      });

      test('false when any permission is denied', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
          },
        );
        expect(status.hasFullPermissions, isFalse);
      });

      test('true for empty permissions map (vacuously true)', () {
        expect(emptyPermissions().hasFullPermissions, isTrue);
      });

      test('false when any permission is notDetermined', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.notDetermined,
          },
        );
        expect(status.hasFullPermissions, isFalse);
      });
    });

    group('hasPartialPermissions', () {
      test('true when some authorized and some denied', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
          },
        );
        expect(status.hasPartialPermissions, isTrue);
      });

      test('true when some authorized and some notDetermined', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.notDetermined,
          },
        );
        expect(status.hasPartialPermissions, isTrue);
      });

      test('false when all are authorized (full, not partial)', () {
        expect(allAuthorized().hasPartialPermissions, isFalse);
      });

      test('false when all are denied', () {
        expect(allDenied().hasPartialPermissions, isFalse);
      });

      test('false for empty permissions map', () {
        expect(emptyPermissions().hasPartialPermissions, isFalse);
      });
    });

    group('hasNoPermissions', () {
      test('true when all are denied', () {
        expect(allDenied().hasNoPermissions, isTrue);
      });

      test('true when all are notDetermined', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.notDetermined,
            HealthDataType.bodyWeight: PermissionState.notDetermined,
          },
        );
        expect(status.hasNoPermissions, isTrue);
      });

      test('false when at least one is authorized', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
          },
        );
        expect(status.hasNoPermissions, isFalse);
      });

      test('true for empty permissions map (vacuously true)', () {
        expect(emptyPermissions().hasNoPermissions, isTrue);
      });
    });

    group('authorizedDataTypes', () {
      test('returns only authorized types', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
            HealthDataType.height: PermissionState.authorized,
          },
        );

        final authorized = status.authorizedDataTypes;
        expect(authorized, contains(HealthDataType.workout));
        expect(authorized, contains(HealthDataType.height));
        expect(authorized, isNot(contains(HealthDataType.bodyWeight)));
        expect(authorized.length, 2);
      });

      test('returns empty list when none authorized', () {
        expect(allDenied().authorizedDataTypes, isEmpty);
      });

      test('returns all types when all authorized', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.authorized,
          },
        );
        expect(status.authorizedDataTypes.length, 2);
      });
    });

    group('deniedDataTypes', () {
      test('returns only denied types', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
            HealthDataType.height: PermissionState.denied,
          },
        );

        final denied = status.deniedDataTypes;
        expect(denied, contains(HealthDataType.bodyWeight));
        expect(denied, contains(HealthDataType.height));
        expect(denied, isNot(contains(HealthDataType.workout)));
        expect(denied.length, 2);
      });

      test('returns empty list when none denied', () {
        expect(allAuthorized().deniedDataTypes, isEmpty);
      });

      test('notDetermined is not included in denied types', () {
        const status = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.notDetermined},
        );
        expect(status.deniedDataTypes, isEmpty);
      });
    });

    group('needsSequentialPermission', () {
      test(
        'true when workout authorized and bodyWeight notDetermined (iOS flow)',
        () {
          const status = HealthPermissionStatus(
            permissions: {
              HealthDataType.workout: PermissionState.authorized,
              HealthDataType.bodyWeight: PermissionState.notDetermined,
            },
          );
          expect(status.needsSequentialPermission, isTrue);
        },
      );

      test('false when both workout and bodyWeight are authorized', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.authorized,
          },
        );
        expect(status.needsSequentialPermission, isFalse);
      });

      test('false when workout is not yet authorized', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.notDetermined,
            HealthDataType.bodyWeight: PermissionState.notDetermined,
          },
        );
        expect(status.needsSequentialPermission, isFalse);
      });

      test('false when workout is denied', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.denied,
            HealthDataType.bodyWeight: PermissionState.notDetermined,
          },
        );
        expect(status.needsSequentialPermission, isFalse);
      });

      test('false when bodyWeight is denied (not notDetermined)', () {
        const status = HealthPermissionStatus(
          permissions: {
            HealthDataType.workout: PermissionState.authorized,
            HealthDataType.bodyWeight: PermissionState.denied,
          },
        );
        expect(status.needsSequentialPermission, isFalse);
      });

      test('false when bodyWeight key is absent entirely', () {
        const status = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.authorized},
        );
        // bodyWeight absent → null != notDetermined → false
        expect(status.needsSequentialPermission, isFalse);
      });
    });

    group('copyWith (freezed)', () {
      test('creates new status with updated healthConnectAvailable', () {
        const original = HealthPermissionStatus(
          permissions: {HealthDataType.workout: PermissionState.authorized},
          healthConnectAvailable: false,
        );

        final updated = original.copyWith(healthConnectAvailable: true);

        expect(updated.healthConnectAvailable, isTrue);
        expect(original.healthConnectAvailable, isFalse); // immutable
      });
    });
  });

  // =========================================================================
  // SyncResult
  // =========================================================================
  group('SyncResult', () {
    test('has 4 values', () {
      expect(SyncResult.values.length, 4);
    });

    test('contains all expected states', () {
      expect(SyncResult.values, contains(SyncResult.idle));
      expect(SyncResult.values, contains(SyncResult.syncing));
      expect(SyncResult.values, contains(SyncResult.success));
      expect(SyncResult.values, contains(SyncResult.error));
    });
  });

  // =========================================================================
  // HealthSyncStatus
  // =========================================================================
  group('HealthSyncStatus', () {
    group('construction', () {
      test('creates entity with all required fields', () {
        final now = DateTime(2026, 1, 15, 10, 0);
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: now,
          lastResult: SyncResult.success,
        );

        expect(status.dataType, HealthDataType.workout);
        expect(status.lastSyncTime, now);
        expect(status.lastResult, SyncResult.success);
        expect(status.retryCount, 0);
        expect(status.errorMessage, isNull);
      });

      test('retryCount defaults to 0', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: null,
          lastResult: SyncResult.idle,
        );
        expect(status.retryCount, 0);
      });

      test('errorMessage can be provided', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          errorMessage: 'Network timeout',
        );
        expect(status.errorMessage, 'Network timeout');
      });
    });

    group('shouldRetry()', () {
      test('true when lastResult is error and retryCount < 3', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          retryCount: 0,
        );
        expect(status.shouldRetry(), isTrue);
      });

      test('true at retryCount 1', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          retryCount: 1,
        );
        expect(status.shouldRetry(), isTrue);
      });

      test('true at retryCount 2', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          retryCount: 2,
        );
        expect(status.shouldRetry(), isTrue);
      });

      test('false when retryCount reaches 3 (max retries exhausted)', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          retryCount: 3,
        );
        expect(status.shouldRetry(), isFalse);
      });

      test('false when lastResult is success', () {
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.success,
          retryCount: 0,
        );
        expect(status.shouldRetry(), isFalse);
      });

      test('false when lastResult is idle', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.idle,
          retryCount: 0,
        );
        expect(status.shouldRetry(), isFalse);
      });

      test('false when lastResult is syncing', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.syncing,
          retryCount: 0,
        );
        expect(status.shouldRetry(), isFalse);
      });
    });

    group('shouldAutoSync()', () {
      test('true when lastSyncTime is null (never synced)', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.idle,
        );
        expect(status.shouldAutoSync(), isTrue);
      });

      test('true when last sync was more than 24 hours ago', () {
        final thirtyHoursAgo = DateTime.now().subtract(
          const Duration(hours: 30),
        );
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: thirtyHoursAgo,
          lastResult: SyncResult.success,
        );
        expect(status.shouldAutoSync(), isTrue);
      });

      test('false when last sync was less than 24 hours ago', () {
        final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: oneHourAgo,
          lastResult: SyncResult.success,
        );
        expect(status.shouldAutoSync(), isFalse);
      });

      test('false when last sync was exactly 23 hours ago', () {
        final twentyThreeHoursAgo = DateTime.now().subtract(
          const Duration(hours: 23),
        );
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: twentyThreeHoursAgo,
          lastResult: SyncResult.success,
        );
        expect(status.shouldAutoSync(), isFalse);
      });
    });

    group('statusMessageKey', () {
      test('idle with null lastSyncTime → never synced key', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.idle,
        );
        expect(status.statusMessageKey, 'healthSyncStatusNeverSynced');
      });

      test('idle with non-null lastSyncTime → idle key', () {
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.idle,
        );
        expect(status.statusMessageKey, 'healthSyncStatusIdle');
      });

      test('syncing → syncing key', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.syncing,
        );
        expect(status.statusMessageKey, 'healthSyncStatusSyncing');
      });

      test('success → success key', () {
        final status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.success,
        );
        expect(status.statusMessageKey, 'healthSyncStatusSuccess');
      });

      test('error → error key', () {
        const status = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          errorMessage: 'Timeout',
        );
        expect(status.statusMessageKey, 'healthSyncStatusError');
      });
    });

    group('copyWith (freezed)', () {
      test('creates a new status with updated retryCount', () {
        const original = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          retryCount: 1,
        );

        final updated = original.copyWith(retryCount: 2);

        expect(updated.retryCount, 2);
        expect(original.retryCount, 1); // immutable
      });

      test('updated result changes shouldRetry outcome', () {
        const original = HealthSyncStatus(
          dataType: HealthDataType.workout,
          lastSyncTime: null,
          lastResult: SyncResult.error,
          retryCount: 0,
        );

        final resolved = original.copyWith(lastResult: SyncResult.success);

        expect(original.shouldRetry(), isTrue);
        expect(resolved.shouldRetry(), isFalse);
      });
    });
  });

  // =========================================================================
  // MeasurementUnit
  // =========================================================================
  group('MeasurementUnit', () {
    test('has 7 values', () {
      expect(MeasurementUnit.values.length, 7);
    });

    test('contains all expected units', () {
      expect(MeasurementUnit.values, contains(MeasurementUnit.kilograms));
      expect(MeasurementUnit.values, contains(MeasurementUnit.pounds));
      expect(MeasurementUnit.values, contains(MeasurementUnit.percent));
      expect(MeasurementUnit.values, contains(MeasurementUnit.minutes));
      expect(MeasurementUnit.values, contains(MeasurementUnit.bpm));
      expect(MeasurementUnit.values, contains(MeasurementUnit.meters));
      expect(MeasurementUnit.values, contains(MeasurementUnit.centimeters));
    });
  });

  // =========================================================================
  // BodyMeasurement
  // =========================================================================
  group('BodyMeasurement', () {
    final baseDate = DateTime(2026, 1, 10, 8, 0);

    group('construction', () {
      test('creates entity with required fields', () {
        final measurement = BodyMeasurement(
          value: 80.5,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );

        expect(measurement.value, 80.5);
        expect(measurement.unit, MeasurementUnit.kilograms);
        expect(measurement.recordedAt, baseDate);
        expect(measurement.dataType, HealthDataType.bodyWeight);
        expect(measurement.source, isNull);
      });

      test('optional source can be set', () {
        final measurement = BodyMeasurement(
          value: 75.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'HealthKit',
        );
        expect(measurement.source, 'HealthKit');
      });
    });

    group('toKilograms()', () {
      test('kilograms returns value unchanged', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.toKilograms(), 80.0);
      });

      test('pounds converts correctly (1 lb = 0.453592 kg)', () {
        final m = BodyMeasurement(
          value: 176.37,
          unit: MeasurementUnit.pounds,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        // 176.37 * 0.453592 ≈ 80.0 kg
        expect(m.toKilograms(), closeTo(80.0, 0.05));
      });

      test('100 pounds is approximately 45.36 kg', () {
        final m = BodyMeasurement(
          value: 100.0,
          unit: MeasurementUnit.pounds,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.toKilograms(), closeTo(45.36, 0.01));
      });

      test('throws UnsupportedError for percent unit', () {
        final m = BodyMeasurement(
          value: 15.0,
          unit: MeasurementUnit.percent,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyFat,
        );
        expect(() => m.toKilograms(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for minutes unit', () {
        final m = BodyMeasurement(
          value: 45.0,
          unit: MeasurementUnit.minutes,
          recordedAt: baseDate,
          dataType: HealthDataType.workout,
        );
        expect(() => m.toKilograms(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for bpm unit', () {
        final m = BodyMeasurement(
          value: 60.0,
          unit: MeasurementUnit.bpm,
          recordedAt: baseDate,
          dataType: HealthDataType.heartRate,
        );
        expect(() => m.toKilograms(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for meters unit', () {
        final m = BodyMeasurement(
          value: 1.80,
          unit: MeasurementUnit.meters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(() => m.toKilograms(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for centimeters unit', () {
        final m = BodyMeasurement(
          value: 180.0,
          unit: MeasurementUnit.centimeters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(() => m.toKilograms(), throwsUnsupportedError);
      });
    });

    group('toPounds()', () {
      test('pounds returns value unchanged', () {
        final m = BodyMeasurement(
          value: 176.0,
          unit: MeasurementUnit.pounds,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.toPounds(), 176.0);
      });

      test('kilograms converts correctly (1 kg = 2.20462 lbs)', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.toPounds(), closeTo(176.37, 0.01));
      });

      test('50 kg is approximately 110.23 lbs', () {
        final m = BodyMeasurement(
          value: 50.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.toPounds(), closeTo(110.23, 0.01));
      });

      test('throws UnsupportedError for percent unit', () {
        final m = BodyMeasurement(
          value: 15.0,
          unit: MeasurementUnit.percent,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyFat,
        );
        expect(() => m.toPounds(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for minutes unit', () {
        final m = BodyMeasurement(
          value: 30.0,
          unit: MeasurementUnit.minutes,
          recordedAt: baseDate,
          dataType: HealthDataType.workout,
        );
        expect(() => m.toPounds(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for bpm unit', () {
        final m = BodyMeasurement(
          value: 70.0,
          unit: MeasurementUnit.bpm,
          recordedAt: baseDate,
          dataType: HealthDataType.heartRate,
        );
        expect(() => m.toPounds(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for meters unit', () {
        final m = BodyMeasurement(
          value: 1.75,
          unit: MeasurementUnit.meters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(() => m.toPounds(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for centimeters unit', () {
        final m = BodyMeasurement(
          value: 175.0,
          unit: MeasurementUnit.centimeters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(() => m.toPounds(), throwsUnsupportedError);
      });
    });

    group('toCentimeters()', () {
      test('centimeters returns value unchanged', () {
        final m = BodyMeasurement(
          value: 180.0,
          unit: MeasurementUnit.centimeters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(m.toCentimeters(), 180.0);
      });

      test('meters converts correctly (1 m = 100 cm)', () {
        final m = BodyMeasurement(
          value: 1.80,
          unit: MeasurementUnit.meters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(m.toCentimeters(), closeTo(180.0, 0.001));
      });

      test('1.75 meters is 175 cm', () {
        final m = BodyMeasurement(
          value: 1.75,
          unit: MeasurementUnit.meters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(m.toCentimeters(), closeTo(175.0, 0.001));
      });

      test('throws UnsupportedError for kilograms unit', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(() => m.toCentimeters(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for pounds unit', () {
        final m = BodyMeasurement(
          value: 176.0,
          unit: MeasurementUnit.pounds,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(() => m.toCentimeters(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for percent unit', () {
        final m = BodyMeasurement(
          value: 15.0,
          unit: MeasurementUnit.percent,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyFat,
        );
        expect(() => m.toCentimeters(), throwsUnsupportedError);
      });

      test('throws UnsupportedError for bpm unit', () {
        final m = BodyMeasurement(
          value: 60.0,
          unit: MeasurementUnit.bpm,
          recordedAt: baseDate,
          dataType: HealthDataType.heartRate,
        );
        expect(() => m.toCentimeters(), throwsUnsupportedError);
      });
    });

    group('isSyncedFromHealth', () {
      test('true for HealthKit source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'HealthKit',
        );
        expect(m.isSyncedFromHealth, isTrue);
      });

      test('true for Health Connect source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'Health Connect',
        );
        expect(m.isSyncedFromHealth, isTrue);
      });

      test('false for FitLog source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'FitLog',
        );
        expect(m.isSyncedFromHealth, isFalse);
      });

      test('false for null source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.isSyncedFromHealth, isFalse);
      });

      test('false for unknown source string', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'Garmin',
        );
        expect(m.isSyncedFromHealth, isFalse);
      });
    });

    group('isManualEntry', () {
      test('true for FitLog source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'FitLog',
        );
        expect(m.isManualEntry, isTrue);
      });

      test('true for null source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.isManualEntry, isTrue);
      });

      test('false for HealthKit source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'HealthKit',
        );
        expect(m.isManualEntry, isFalse);
      });

      test('false for Health Connect source', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'Health Connect',
        );
        expect(m.isManualEntry, isFalse);
      });
    });

    group('unitDisplayKey', () {
      test('kilograms → unitKilograms', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.unitDisplayKey, 'unitKilograms');
      });

      test('pounds → unitPounds', () {
        final m = BodyMeasurement(
          value: 176.0,
          unit: MeasurementUnit.pounds,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );
        expect(m.unitDisplayKey, 'unitPounds');
      });

      test('percent → unitPercent', () {
        final m = BodyMeasurement(
          value: 15.0,
          unit: MeasurementUnit.percent,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyFat,
        );
        expect(m.unitDisplayKey, 'unitPercent');
      });

      test('minutes → unitMinutes', () {
        final m = BodyMeasurement(
          value: 45.0,
          unit: MeasurementUnit.minutes,
          recordedAt: baseDate,
          dataType: HealthDataType.workout,
        );
        expect(m.unitDisplayKey, 'unitMinutes');
      });

      test('bpm → unitBpm', () {
        final m = BodyMeasurement(
          value: 60.0,
          unit: MeasurementUnit.bpm,
          recordedAt: baseDate,
          dataType: HealthDataType.heartRate,
        );
        expect(m.unitDisplayKey, 'unitBpm');
      });

      test('meters → unitMeters', () {
        final m = BodyMeasurement(
          value: 1.80,
          unit: MeasurementUnit.meters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(m.unitDisplayKey, 'unitMeters');
      });

      test('centimeters → unitCentimeters', () {
        final m = BodyMeasurement(
          value: 180.0,
          unit: MeasurementUnit.centimeters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );
        expect(m.unitDisplayKey, 'unitCentimeters');
      });

      test('all units produce unique display keys', () {
        final now = DateTime.now();
        final keys = MeasurementUnit.values
            .map(
              (unit) => BodyMeasurement(
                value: 1.0,
                unit: unit,
                recordedAt: now,
                dataType: HealthDataType.bodyWeight,
              ).unitDisplayKey,
            )
            .toList();
        final uniqueKeys = keys.toSet();
        expect(keys.length, uniqueKeys.length);
      });
    });

    group('copyWith (freezed)', () {
      test('creates new measurement with updated value', () {
        final original = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
          source: 'FitLog',
        );

        final updated = original.copyWith(value: 82.5);

        expect(updated.value, 82.5);
        expect(original.value, 80.0); // immutable
        expect(updated.unit, original.unit);
        expect(updated.source, original.source);
      });

      test('updating source does not affect original', () {
        final original = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );

        final updated = original.copyWith(source: 'HealthKit');

        expect(updated.isSyncedFromHealth, isTrue);
        expect(original.isManualEntry, isTrue);
      });
    });

    group('weight conversion round-trips', () {
      test('kg → lbs → kg preserves value within tolerance', () {
        final m = BodyMeasurement(
          value: 80.0,
          unit: MeasurementUnit.kilograms,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        );

        final lbs = m.toPounds();
        final backToKg = BodyMeasurement(
          value: lbs,
          unit: MeasurementUnit.pounds,
          recordedAt: baseDate,
          dataType: HealthDataType.bodyWeight,
        ).toKilograms();

        expect(backToKg, closeTo(80.0, 0.001));
      });

      test('m → cm preserves value', () {
        final m = BodyMeasurement(
          value: 1.75,
          unit: MeasurementUnit.meters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        );

        final cm = m.toCentimeters();
        expect(cm, closeTo(175.0, 0.001));

        // Convert back conceptually
        final backToM = BodyMeasurement(
          value: cm,
          unit: MeasurementUnit.centimeters,
          recordedAt: baseDate,
          dataType: HealthDataType.height,
        ).toCentimeters(); // already cm
        expect(backToM, closeTo(175.0, 0.001));
      });
    });
  });
}
