// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/models/exercise_model.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseModel _baseModel({
  String id = 'panca_01',
  String nome = 'Panca Piana',
  String focus = 'PET, TRIC',
  String? imageUrl,
  String muscoliSecondari = 'DELT',
  String difficolta = 'Intermedio',
  String tipoEsercizio = 'Compound',
  String attrezzatura = 'Bilanciere',
  String patternMovimento = 'Push',
  String rangeRipetizioni = '6-12',
  String? noteTecniche,
  String? mobilitaPre,
  String? attivazionePre,
}) {
  return ExerciseModel(
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
  );
}

ExerciseDefinition _baseEntity({
  String id = 'squat_01',
  String nome = 'Squat con Bilanciere',
  List<String> focus = const ['QUAD', 'GLUT'],
  List<String> muscoliSecondari = const ['CORE'],
  String difficolta = 'Avanzato',
  String tipoEsercizio = 'Compound',
  String attrezzatura = 'Bilanciere',
  String patternMovimento = 'Squat',
  String rangeRipetizioni = '5-8',
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
  );
}

void main() {
  // ================================================================
  // ExerciseModel constructor
  // ================================================================
  group('ExerciseModel constructor', () {
    test('stores all fields', () {
      final model = _baseModel();
      expect(model.id, 'panca_01');
      expect(model.nome, 'Panca Piana');
      expect(model.focus, 'PET, TRIC');
      expect(model.muscoliSecondari, 'DELT');
      expect(model.difficolta, 'Intermedio');
      expect(model.tipoEsercizio, 'Compound');
      expect(model.attrezzatura, 'Bilanciere');
      expect(model.patternMovimento, 'Push');
      expect(model.rangeRipetizioni, '6-12');
    });

    test('imageUrl defaults to null', () {
      expect(_baseModel().imageUrl, isNull);
    });

    test('noteTecniche defaults to null', () {
      expect(_baseModel().noteTecniche, isNull);
    });
  });

  // ================================================================
  // ExerciseModel.fromJson
  // ================================================================
  group('ExerciseModel.fromJson', () {
    test('parses required string fields', () {
      final json = {
        'id': 'rdl',
        'nome': 'Stacco Rumeno',
        'focus': 'FEMOR, GLUT',
        'muscoliSecondari': 'LOM',
        'difficolta': 'Avanzato',
        'tipoEsercizio': 'Compound',
        'attrezzatura': 'Bilanciere',
        'patternMovimento': 'Hinge',
        'rangeRipetizioni': '6-10',
      };
      final model = ExerciseModel.fromJson(json);
      expect(model.id, 'rdl');
      expect(model.nome, 'Stacco Rumeno');
      expect(model.focus, 'FEMOR, GLUT');
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
      final model = ExerciseModel.fromJson(json);
      expect(model.imageUrl, isNull);
    });

    test('non-empty imageUrl is preserved', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'imageUrl': 'https://example.com/img.gif',
        'focus': '',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final model = ExerciseModel.fromJson(json);
      expect(model.imageUrl, 'https://example.com/img.gif');
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
      final model = ExerciseModel.fromJson(json);
      expect(model.noteTecniche, isNull);
    });

    test('focus as List is converted to comma-separated string', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': ['QUAD', 'GLUT'],
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final model = ExerciseModel.fromJson(json);
      expect(model.focus, 'QUAD, GLUT');
    });

    test('focus as String is preserved as-is', () {
      final json = {
        'id': 't1',
        'nome': 'Test',
        'focus': 'PET',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      };
      final model = ExerciseModel.fromJson(json);
      expect(model.focus, 'PET');
    });

    test('null focus produces empty string', () {
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
      final model = ExerciseModel.fromJson(json);
      expect(model.focus, '');
    });

    test('missing fields default to empty string', () {
      final json = <String, dynamic>{};
      final model = ExerciseModel.fromJson(json);
      expect(model.id, '');
      expect(model.nome, '');
    });
  });

  // ================================================================
  // ExerciseModel.fromEntity
  // ================================================================
  group('ExerciseModel.fromEntity', () {
    test('id is preserved', () {
      final entity = _baseEntity(id: 'squat_barbell');
      final model = ExerciseModel.fromEntity(entity);
      expect(model.id, 'squat_barbell');
    });

    test('nome is preserved', () {
      final entity = _baseEntity(nome: 'Squat con Bilanciere');
      final model = ExerciseModel.fromEntity(entity);
      expect(model.nome, 'Squat con Bilanciere');
    });

    test('focus list is joined with comma-space', () {
      final entity = _baseEntity(focus: ['QUAD', 'GLUT']);
      final model = ExerciseModel.fromEntity(entity);
      expect(model.focus, 'QUAD, GLUT');
    });

    test('muscoliSecondari list is joined with comma-space', () {
      final entity = _baseEntity(muscoliSecondari: ['CORE', 'LOM']);
      final model = ExerciseModel.fromEntity(entity);
      expect(model.muscoliSecondari, 'CORE, LOM');
    });

    test('difficolta is preserved', () {
      final entity = _baseEntity(difficolta: 'Principiante');
      final model = ExerciseModel.fromEntity(entity);
      expect(model.difficolta, 'Principiante');
    });

    test('single muscle in focus produces no trailing comma', () {
      final entity = _baseEntity(focus: ['PET']);
      final model = ExerciseModel.fromEntity(entity);
      expect(model.focus, 'PET');
    });
  });

  // ================================================================
  // ExerciseModel.toEntity
  // ================================================================
  group('ExerciseModel.toEntity', () {
    test('returns ExerciseDefinition', () {
      final model = _baseModel();
      final entity = model.toEntity();
      expect(entity, isA<ExerciseDefinition>());
    });

    test('id is preserved', () {
      final model = _baseModel(id: 'bench_01');
      expect(model.toEntity().id, 'bench_01');
    });

    test('nome is preserved', () {
      final model = _baseModel(nome: 'Panca Piana');
      expect(model.toEntity().nome, 'Panca Piana');
    });

    test('focus string is parsed to list', () {
      final model = _baseModel(focus: 'QUAD, GLUT');
      final entity = model.toEntity();
      expect(entity.focus, ['QUAD', 'GLUT']);
    });

    test('muscoliSecondari string is parsed to list', () {
      final model = _baseModel(muscoliSecondari: 'CORE, LOM');
      final entity = model.toEntity();
      expect(entity.muscoliSecondari, ['CORE', 'LOM']);
    });

    test('empty focus produces empty list', () {
      final model = _baseModel(focus: '');
      final entity = model.toEntity();
      expect(entity.focus, isEmpty);
    });

    test('imageUrl null is preserved', () {
      final model = _baseModel(imageUrl: null);
      expect(model.toEntity().imageUrl, isNull);
    });

    test('noteTecniche null is preserved', () {
      final model = _baseModel(noteTecniche: null);
      expect(model.toEntity().noteTecniche, isNull);
    });
  });

  // ================================================================
  // ExerciseModel.toJson
  // ================================================================
  group('ExerciseModel.toJson', () {
    test('contains all required keys', () {
      final json = _baseModel().toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('nome'), isTrue);
      expect(json.containsKey('focus'), isTrue);
      expect(json.containsKey('muscoliSecondari'), isTrue);
      expect(json.containsKey('difficolta'), isTrue);
      expect(json.containsKey('tipoEsercizio'), isTrue);
      expect(json.containsKey('attrezzatura'), isTrue);
      expect(json.containsKey('patternMovimento'), isTrue);
      expect(json.containsKey('rangeRipetizioni'), isTrue);
    });

    test('values match model fields', () {
      final model = _baseModel(id: 'test_id', nome: 'Test Nome');
      final json = model.toJson();
      expect(json['id'], 'test_id');
      expect(json['nome'], 'Test Nome');
    });

    test('imageUrl null is in json', () {
      final json = _baseModel(imageUrl: null).toJson();
      expect(json['imageUrl'], isNull);
    });

    test('noteTecniche null is in json', () {
      final json = _baseModel(noteTecniche: null).toJson();
      expect(json['noteTecniche'], isNull);
    });
  });

  // ================================================================
  // Round-trip: fromEntity -> toEntity
  // ================================================================
  group('ExerciseModel round-trip fromEntity/toEntity', () {
    test('id survives round-trip', () {
      final entity = _baseEntity(id: 'roundtrip_01');
      final model = ExerciseModel.fromEntity(entity);
      final recovered = model.toEntity();
      expect(recovered.id, entity.id);
    });

    test('focus list survives round-trip', () {
      final entity = _baseEntity(focus: ['QUAD', 'GLUT', 'CORE']);
      final model = ExerciseModel.fromEntity(entity);
      final recovered = model.toEntity();
      expect(recovered.focus, entity.focus);
    });

    test('muscoliSecondari survives round-trip', () {
      final entity = _baseEntity(muscoliSecondari: ['LOM', 'CORE']);
      final model = ExerciseModel.fromEntity(entity);
      final recovered = model.toEntity();
      expect(recovered.muscoliSecondari, entity.muscoliSecondari);
    });
  });

  // ================================================================
  // _toCommaSeparatedString (via fromJson)
  // ================================================================
  group('_toCommaSeparatedString via fromJson', () {
    test('null produces empty string', () {
      final model = ExerciseModel.fromJson({
        'id': '',
        'nome': '',
        'focus': null,
        'muscoliSecondari': null,
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      });
      expect(model.focus, '');
    });

    test('String value is returned as-is', () {
      final model = ExerciseModel.fromJson({
        'id': '',
        'nome': '',
        'focus': 'QUAD',
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      });
      expect(model.focus, 'QUAD');
    });

    test('List is joined by comma-space', () {
      final model = ExerciseModel.fromJson({
        'id': '',
        'nome': '',
        'focus': ['A', 'B', 'C'],
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      });
      expect(model.focus, 'A, B, C');
    });

    test('integer value uses toString fallback', () {
      final model = ExerciseModel.fromJson({
        'id': '',
        'nome': '',
        'focus': 42,
        'muscoliSecondari': '',
        'difficolta': '',
        'tipoEsercizio': '',
        'attrezzatura': '',
        'patternMovimento': '',
        'rangeRipetizioni': '',
      });
      expect(model.focus, '42');
    });
  });
}
