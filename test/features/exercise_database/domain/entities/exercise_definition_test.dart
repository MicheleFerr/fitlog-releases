// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseDefinition _baseExercise({
  String id = 'panca_piana',
  String nome = 'Panca Piana con Bilanciere',
  List<String> focus = const ['PET'],
  List<String> muscoliSecondari = const ['TRIC', 'DELT'],
  String difficolta = 'Intermedio',
  String tipoEsercizio = 'Compound',
  String attrezzatura = 'Bilanciere',
  String patternMovimento = 'Push',
  String rangeRipetizioni = '6-12',
  String? imageUrl,
  String? noteTecniche,
  List<String> aliases = const [],
  ExerciseCountingMode countingMode = ExerciseCountingMode.weighted,
  String? tempoEsecuzione,
  List<WarmupSuggestion>? warmupSuggestions,
}) {
  return ExerciseDefinition(
    id: id,
    nome: nome,
    focus: focus,
    muscoliSecondari: muscoliSecondari,
    difficolta: difficolta,
    tipoEsercizio: tipoEsercizio,
    attrezzatura: attrezzatura,
    patternMovimento: patternMovimento,
    rangeRipetizioni: rangeRipetizioni,
    imageUrl: imageUrl,
    noteTecniche: noteTecniche,
    aliases: aliases,
    countingMode: countingMode,
    tempoEsecuzione: tempoEsecuzione,
    warmupSuggestions: warmupSuggestions,
  );
}

void main() {
  // ================================================================
  // Constructor
  // ================================================================
  group('ExerciseDefinition constructor', () {
    test('stores all required fields', () {
      final ex = _baseExercise();
      expect(ex.id, 'panca_piana');
      expect(ex.nome, 'Panca Piana con Bilanciere');
      expect(ex.focus, ['PET']);
      expect(ex.muscoliSecondari, ['TRIC', 'DELT']);
      expect(ex.difficolta, 'Intermedio');
      expect(ex.tipoEsercizio, 'Compound');
      expect(ex.attrezzatura, 'Bilanciere');
      expect(ex.patternMovimento, 'Push');
      expect(ex.rangeRipetizioni, '6-12');
    });

    test('imageUrl defaults to null', () {
      expect(_baseExercise().imageUrl, isNull);
    });

    test('noteTecniche defaults to null', () {
      expect(_baseExercise().noteTecniche, isNull);
    });

    test('aliases defaults to empty list', () {
      expect(_baseExercise().aliases, isEmpty);
    });

    test('countingMode defaults to weighted', () {
      expect(_baseExercise().countingMode, ExerciseCountingMode.weighted);
    });

    test('tempoEsecuzione defaults to null', () {
      expect(_baseExercise().tempoEsecuzione, isNull);
    });

    test('warmupSuggestions defaults to null', () {
      expect(_baseExercise().warmupSuggestions, isNull);
    });
  });

  // ================================================================
  // normalizedNome (auto-computed)
  // ================================================================
  group('normalizedNome auto-computation', () {
    test('lowercases the name', () {
      final ex = _baseExercise(nome: 'Panca Piana');
      expect(ex.normalizedNome, 'panca piana');
    });

    test('removes Italian accents', () {
      final ex = _baseExercise(nome: 'Estensioni Piedi');
      expect(ex.normalizedNome, isNot(contains('è')));
    });

    test('removes grave accent on a', () {
      final ex = _baseExercise(nome: 'Àllenamento');
      expect(ex.normalizedNome, startsWith('a'));
    });

    test('removes accent on e (é)', () {
      final ex = _baseExercise(nome: 'Éxtension');
      expect(ex.normalizedNome, startsWith('e'));
    });

    test('removes accent on o (ò)', () {
      final ex = _baseExercise(nome: 'Polpaccio');
      expect(ex.normalizedNome, 'polpaccio');
    });

    test('trims whitespace', () {
      final ex = _baseExercise(nome: '  Squat  ');
      expect(ex.normalizedNome, 'squat');
    });

    test('can provide explicit normalizedNome override', () {
      final ex = ExerciseDefinition(
        id: 'test',
        nome: 'Panca Piana',
        focus: const [],
        muscoliSecondari: const [],
        difficolta: 'Intermedio',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Bilanciere',
        patternMovimento: 'Push',
        rangeRipetizioni: '6-12',
        normalizedNome: 'custom_normalized',
      );
      expect(ex.normalizedNome, 'custom_normalized');
    });
  });

  // ================================================================
  // searchableFields (auto-computed)
  // ================================================================
  group('searchableFields auto-computation', () {
    test('includes normalized nome', () {
      final ex = _baseExercise(nome: 'Panca Piana');
      expect(ex.searchableFields, contains('panca piana'));
    });

    test('includes normalized aliases', () {
      final ex = _baseExercise(
        nome: 'Panca Piana',
        aliases: ['bench press', 'BP'],
      );
      expect(ex.searchableFields, contains('bench press'));
      expect(ex.searchableFields, contains('bp'));
    });

    test('no duplicates (Set-based)', () {
      final ex = _baseExercise(
        nome: 'Squat',
        aliases: ['squat'],
      );
      // nome and alias normalize to the same value: deduplicated
      expect(ex.searchableFields.where((f) => f == 'squat').length, 1);
    });
  });

  // ================================================================
  // focusDisplayName getter
  // ================================================================
  group('focusDisplayName', () {
    test('single focus joins correctly', () {
      final ex = _baseExercise(focus: ['PET']);
      expect(ex.focusDisplayName, 'PET');
    });

    test('multiple focus joined with comma+space', () {
      final ex = _baseExercise(focus: ['PET', 'TRIC']);
      expect(ex.focusDisplayName, 'PET, TRIC');
    });

    test('empty focus returns empty string', () {
      final ex = _baseExercise(focus: []);
      expect(ex.focusDisplayName, '');
    });
  });

  // ================================================================
  // muscoliSecondariDisplayName getter
  // ================================================================
  group('muscoliSecondariDisplayName', () {
    test('multiple muscles joined with comma+space', () {
      final ex = _baseExercise(muscoliSecondari: ['TRIC', 'DELT', 'CORE']);
      expect(ex.muscoliSecondariDisplayName, 'TRIC, DELT, CORE');
    });

    test('empty list returns empty string', () {
      final ex = _baseExercise(muscoliSecondari: []);
      expect(ex.muscoliSecondariDisplayName, '');
    });
  });

  // ================================================================
  // difficoltaLevel getter
  // ================================================================
  group('difficoltaLevel', () {
    test('principiante returns 1', () {
      expect(_baseExercise(difficolta: 'Principiante').difficoltaLevel, 1);
    });

    test('intermedio returns 2', () {
      expect(_baseExercise(difficolta: 'Intermedio').difficoltaLevel, 2);
    });

    test('avanzato returns 3', () {
      expect(_baseExercise(difficolta: 'Avanzato').difficoltaLevel, 3);
    });

    test('unknown defaults to 2', () {
      expect(_baseExercise(difficolta: 'Expert').difficoltaLevel, 2);
    });

    test('case insensitive matching', () {
      expect(_baseExercise(difficolta: 'PRINCIPIANTE').difficoltaLevel, 1);
      expect(_baseExercise(difficolta: 'AVANZATO').difficoltaLevel, 3);
    });
  });

  // ================================================================
  // attrezzaturaIcon getter
  // ================================================================
  group('attrezzaturaIcon', () {
    test('bilanciere returns barbell icon', () {
      expect(_baseExercise(attrezzatura: 'Bilanciere').attrezzaturaIcon, '🏋️');
    });

    test('manubri returns muscle icon', () {
      expect(_baseExercise(attrezzatura: 'Manubri').attrezzaturaIcon, '💪');
    });

    test('cavi returns link icon', () {
      expect(_baseExercise(attrezzatura: 'Cavi').attrezzaturaIcon, '🔗');
    });

    test('macchina returns gear icon', () {
      expect(_baseExercise(attrezzatura: 'Macchina').attrezzaturaIcon, '⚙️');
    });

    test('vario returns target icon', () {
      expect(_baseExercise(attrezzatura: 'Vario').attrezzaturaIcon, '🎯');
    });

    test('unknown returns question icon', () {
      expect(_baseExercise(attrezzatura: 'Elastico').attrezzaturaIcon, '❓');
    });

    test('case insensitive matching', () {
      expect(_baseExercise(attrezzatura: 'BILANCIERE').attrezzaturaIcon, '🏋️');
    });
  });

  // ================================================================
  // _autoDetectCountingMode (via fromJson)
  // ================================================================
  group('auto-detect counting mode (via fromJson)', () {
    ExerciseDefinition fromJsonMap(Map<String, dynamic> json) =>
        ExerciseDefinition.fromJson(json);

    Map<String, dynamic> baseJson({
      String nome = 'Panca Piana',
      String attrezzatura = 'Bilanciere',
      String tipoEsercizio = 'Compound',
    }) => {
          'id': 'test',
          'nome': nome,
          'attrezzatura': attrezzatura,
          'tipoEsercizio': tipoEsercizio,
          'focus': '',
          'muscoliSecondari': '',
          'difficolta': 'Intermedio',
          'patternMovimento': 'Push',
          'rangeRipetizioni': '6-12',
        };

    test('explicit countingMode in JSON takes precedence', () {
      final json = baseJson()..['countingMode'] = 'time';
      final ex = fromJsonMap(json);
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('plank name detects time mode', () {
      final ex = fromJsonMap(baseJson(nome: 'Plank Laterale'));
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('hold keyword detects time mode', () {
      final ex = fromJsonMap(baseJson(nome: 'Overhead Hold'));
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('tenuta keyword detects time mode', () {
      final ex = fromJsonMap(baseJson(nome: 'Tenuta Isometrica'));
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('wall sit detects time mode', () {
      final ex = fromJsonMap(baseJson(nome: 'Wall Sit'));
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('l-sit detects time mode', () {
      final ex = fromJsonMap(baseJson(nome: 'L-Sit Hold'));
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('dead hang detects time mode', () {
      final ex = fromJsonMap(baseJson(nome: 'Dead Hang'));
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('stretching tipoEsercizio detects time mode', () {
      final ex = fromJsonMap(
        baseJson(tipoEsercizio: 'Stretching', attrezzatura: 'Bilanciere'),
      );
      expect(ex.countingMode, ExerciseCountingMode.time);
    });

    test('corpo libero attrezzatura detects reps mode', () {
      final ex = fromJsonMap(baseJson(attrezzatura: 'Corpo Libero'));
      expect(ex.countingMode, ExerciseCountingMode.reps);
    });

    test('bodyweight attrezzatura detects reps mode', () {
      final ex = fromJsonMap(baseJson(attrezzatura: 'Bodyweight'));
      expect(ex.countingMode, ExerciseCountingMode.reps);
    });

    test('nessuno attrezzatura detects reps mode', () {
      final ex = fromJsonMap(baseJson(attrezzatura: 'Nessuno'));
      expect(ex.countingMode, ExerciseCountingMode.reps);
    });

    test('none attrezzatura detects reps mode', () {
      final ex = fromJsonMap(baseJson(attrezzatura: 'None'));
      expect(ex.countingMode, ExerciseCountingMode.reps);
    });

    test('bilanciere defaults to weighted mode', () {
      final ex = fromJsonMap(baseJson(attrezzatura: 'Bilanciere'));
      expect(ex.countingMode, ExerciseCountingMode.weighted);
    });
  });

  // ================================================================
  // fromJson
  // ================================================================
  group('ExerciseDefinition.fromJson', () {
    test('parses all required fields', () {
      final json = {
        'id': 'squat_01',
        'nome': 'Squat con Bilanciere',
        'focus': 'QUAD, GLUT',
        'muscoliSecondari': 'CORE, LOM',
        'difficolta': 'Avanzato',
        'tipoEsercizio': 'Compound',
        'attrezzatura': 'Bilanciere',
        'patternMovimento': 'Squat',
        'rangeRipetizioni': '5-8',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.id, 'squat_01');
      expect(ex.nome, 'Squat con Bilanciere');
      expect(ex.focus, ['QUAD', 'GLUT']);
      expect(ex.muscoliSecondari, ['CORE', 'LOM']);
    });

    test('empty imageUrl becomes null', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'imageUrl': '',
        'focus': '',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.imageUrl, isNull);
    });

    test('empty noteTecniche becomes null', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'noteTecniche': '',
        'focus': '',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.noteTecniche, isNull);
    });

    test('focus as list is parsed correctly', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': ['QUAD', 'GLUT'],
        'muscoliSecondari': [],
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.focus, ['QUAD', 'GLUT']);
    });

    test('focus as comma-separated string is parsed correctly', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': 'QUAD, GLUT',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.focus, ['QUAD', 'GLUT']);
    });

    test('aliases are parsed from list', () {
      final json = {
        'id': 't1',
        'nome': 'Panca Piana',
        'aliases': ['bench press', 'bp'],
        'focus': '',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.aliases, ['bench press', 'bp']);
    });

    test('null focus returns empty list', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': null,
        'muscoliSecondari': null,
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.focus, isEmpty);
    });

    test('tempoEsecuzione empty becomes null', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': '',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
        'tempoEsecuzione': '',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.tempoEsecuzione, isNull);
    });

    test('tempoEsecuzione value is preserved', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': '',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
        'tempoEsecuzione': '3-1-2-0',
      };
      final ex = ExerciseDefinition.fromJson(json);
      expect(ex.tempoEsecuzione, '3-1-2-0');
    });
  });

  // ================================================================
  // toJson
  // ================================================================
  group('ExerciseDefinition.toJson', () {
    test('contains all required keys', () {
      final json = _baseExercise().toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('nome'), isTrue);
      expect(json.containsKey('focus'), isTrue);
      expect(json.containsKey('muscoliSecondari'), isTrue);
      expect(json.containsKey('difficolta'), isTrue);
      expect(json.containsKey('tipoEsercizio'), isTrue);
      expect(json.containsKey('attrezzatura'), isTrue);
      expect(json.containsKey('patternMovimento'), isTrue);
      expect(json.containsKey('rangeRipetizioni'), isTrue);
      expect(json.containsKey('aliases'), isTrue);
      expect(json.containsKey('countingMode'), isTrue);
    });

    test('focus is serialized as comma-separated string', () {
      final json = _baseExercise(focus: ['QUAD', 'GLUT']).toJson();
      expect(json['focus'], 'QUAD, GLUT');
    });

    test('muscoliSecondari is serialized as comma-separated string', () {
      final json = _baseExercise(muscoliSecondari: ['TRIC', 'DELT']).toJson();
      expect(json['muscoliSecondari'], 'TRIC, DELT');
    });

    test('countingMode is serialized to string', () {
      final json = _baseExercise(
        countingMode: ExerciseCountingMode.time,
      ).toJson();
      expect(json['countingMode'], 'time');
    });

    test('imageUrl null is preserved in json', () {
      final json = _baseExercise(imageUrl: null).toJson();
      expect(json['imageUrl'], isNull);
    });

    test('warmupSuggestions null produces null in json', () {
      final json = _baseExercise(warmupSuggestions: null).toJson();
      expect(json['warmupSuggestions'], isNull);
    });

    test('warmupSuggestions are serialized', () {
      final suggestions = [
        const WarmupSuggestion(
          exerciseId: 'ws1',
          exerciseName: 'Hip Circle',
          sets: 2,
          reps: 10,
          type: WarmupType.mobility,
        ),
      ];
      final json = _baseExercise(warmupSuggestions: suggestions).toJson();
      final ws = json['warmupSuggestions'] as List;
      expect(ws, hasLength(1));
      expect(ws.first['exerciseId'], 'ws1');
    });
  });

  // ================================================================
  // Equality (Equatable)
  // ================================================================
  group('ExerciseDefinition equality', () {
    test('identical instances are equal', () {
      final a = _baseExercise();
      final b = _baseExercise();
      expect(a, equals(b));
    });

    test('different id produces not-equal', () {
      final a = _baseExercise(id: 'id1');
      final b = _baseExercise(id: 'id2');
      expect(a, isNot(equals(b)));
    });

    test('different nome produces not-equal', () {
      final a = _baseExercise(nome: 'Squat');
      final b = _baseExercise(nome: 'Panca Piana');
      expect(a, isNot(equals(b)));
    });

    test('different countingMode produces not-equal', () {
      final a = _baseExercise(countingMode: ExerciseCountingMode.weighted);
      final b = _baseExercise(countingMode: ExerciseCountingMode.time);
      expect(a, isNot(equals(b)));
    });
  });

  // ================================================================
  // parseCommaSeparated public helper
  // ================================================================
  group('ExerciseDefinition.parseCommaSeparated', () {
    test('null returns empty list', () {
      expect(ExerciseDefinition.parseCommaSeparated(null), isEmpty);
    });

    test('empty string returns empty list', () {
      expect(ExerciseDefinition.parseCommaSeparated(''), isEmpty);
    });

    test('comma-separated string is split', () {
      expect(
        ExerciseDefinition.parseCommaSeparated('QUAD, GLUT, CORE'),
        ['QUAD', 'GLUT', 'CORE'],
      );
    });

    test('list is returned as-is (cast)', () {
      expect(
        ExerciseDefinition.parseCommaSeparated(['A', 'B']),
        ['A', 'B'],
      );
    });

    test('trims whitespace around items', () {
      expect(
        ExerciseDefinition.parseCommaSeparated('  QUAD ,  GLUT  '),
        ['QUAD', 'GLUT'],
      );
    });

    test('filters empty items after split', () {
      expect(
        ExerciseDefinition.parseCommaSeparated('QUAD,,GLUT'),
        ['QUAD', 'GLUT'],
      );
    });
  });
}
