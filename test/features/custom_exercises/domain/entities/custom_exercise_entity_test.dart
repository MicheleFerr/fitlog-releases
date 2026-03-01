/// CustomExercise entity tests - JSON round-trip, computed properties,
/// factory constructors, copyWith, Equatable, Hive adapter.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';

void main() {
  CustomExercise buildExercise({
    String id = 'ex1',
    String nome = 'Bench Press Stretta',
    String? baseExerciseId,
    List<String> focus = const ['PETT', 'DELT ANT'],
    List<String> muscoliSecondari = const ['TRIC'],
    String tipoEsercizio = 'Compound',
    String patternMovimento = 'Push',
    String attrezzatura = 'Bilanciere',
    DateTime? createdAt,
    DateTime? unlockedUntil,
    bool isModifiedFromBase = false,
    String? userId,
  }) {
    return CustomExercise(
      id: id,
      nome: nome,
      baseExerciseId: baseExerciseId,
      focus: focus,
      muscoliSecondari: muscoliSecondari,
      tipoEsercizio: tipoEsercizio,
      patternMovimento: patternMovimento,
      attrezzatura: attrezzatura,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      unlockedUntil: unlockedUntil,
      isModifiedFromBase: isModifiedFromBase,
      userId: userId,
    );
  }

  group('CustomExercise constructor', () {
    test('stores all fields', () {
      final e = buildExercise(
        baseExerciseId: 'base1',
        unlockedUntil: DateTime(2025, 7, 1),
        isModifiedFromBase: true,
        userId: 'user1',
      );
      expect(e.id, 'ex1');
      expect(e.nome, 'Bench Press Stretta');
      expect(e.baseExerciseId, 'base1');
      expect(e.focus, ['PETT', 'DELT ANT']);
      expect(e.muscoliSecondari, ['TRIC']);
      expect(e.tipoEsercizio, 'Compound');
      expect(e.patternMovimento, 'Push');
      expect(e.attrezzatura, 'Bilanciere');
      expect(e.unlockedUntil, DateTime(2025, 7, 1));
      expect(e.isModifiedFromBase, isTrue);
      expect(e.userId, 'user1');
    });

    test('null optional fields', () {
      final e = buildExercise();
      expect(e.baseExerciseId, isNull);
      expect(e.unlockedUntil, isNull);
      expect(e.userId, isNull);
      expect(e.isModifiedFromBase, isFalse);
    });
  });

  group('JSON round-trip', () {
    test('all fields', () {
      final original = buildExercise(
        baseExerciseId: 'base1',
        unlockedUntil: DateTime(2025, 7, 1),
        isModifiedFromBase: true,
        userId: 'user1',
      );
      final json = original.toJson();
      final restored = CustomExercise.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.nome, original.nome);
      expect(restored.baseExerciseId, original.baseExerciseId);
      expect(restored.focus, original.focus);
      expect(restored.muscoliSecondari, original.muscoliSecondari);
      expect(restored.tipoEsercizio, original.tipoEsercizio);
      expect(restored.patternMovimento, original.patternMovimento);
      expect(restored.attrezzatura, original.attrezzatura);
      expect(restored.createdAt, original.createdAt);
      expect(restored.unlockedUntil, original.unlockedUntil);
      expect(restored.isModifiedFromBase, original.isModifiedFromBase);
      expect(restored.userId, original.userId);
    });

    test('null optional fields', () {
      final original = buildExercise();
      final json = original.toJson();
      final restored = CustomExercise.fromJson(json);
      expect(restored.baseExerciseId, isNull);
      expect(restored.unlockedUntil, isNull);
      expect(restored.userId, isNull);
    });

    test('fromJson with raw map', () {
      final json = {
        'id': 'test1',
        'nome': 'Custom Curl',
        'baseExerciseId': null,
        'focus': ['BIC'],
        'muscoliSecondari': <String>[],
        'tipoEsercizio': 'Isolamento',
        'patternMovimento': 'Pull',
        'attrezzatura': 'Manubri',
        'createdAt': '2025-03-01T00:00:00.000',
        'unlockedUntil': null,
        'isModifiedFromBase': false,
        'userId': null,
      };
      final e = CustomExercise.fromJson(json);
      expect(e.id, 'test1');
      expect(e.nome, 'Custom Curl');
      expect(e.focus, ['BIC']);
      expect(e.muscoliSecondari, isEmpty);
    });

    test('fromJson with missing isModifiedFromBase defaults to false', () {
      final json = {
        'id': 'test2',
        'nome': 'Test',
        'focus': ['QUAD'],
        'muscoliSecondari': ['GLUT'],
        'tipoEsercizio': 'Compound',
        'patternMovimento': 'Squat',
        'attrezzatura': 'Bilanciere',
        'createdAt': '2025-01-01T00:00:00.000',
      };
      final e = CustomExercise.fromJson(json);
      expect(e.isModifiedFromBase, isFalse);
    });
  });

  group('computed properties', () {
    test('isPureCustom when no baseExerciseId', () {
      expect(buildExercise().isPureCustom, isTrue);
      expect(buildExercise().isVariant, isFalse);
    });

    test('isVariant when baseExerciseId set', () {
      expect(buildExercise(baseExerciseId: 'base1').isVariant, isTrue);
      expect(buildExercise(baseExerciseId: 'base1').isPureCustom, isFalse);
    });

    test('isPermanent and isTemporary', () {
      expect(buildExercise().isPermanent, isTrue);
      expect(buildExercise().isTemporary, isFalse);
      expect(buildExercise(unlockedUntil: DateTime(2099, 1, 1)).isPermanent, isFalse);
      expect(buildExercise(unlockedUntil: DateTime(2099, 1, 1)).isTemporary, isTrue);
    });

    test('isActive for permanent', () {
      expect(buildExercise().isActive, isTrue);
    });

    test('isActive for future unlock', () {
      expect(buildExercise(unlockedUntil: DateTime(2099, 12, 31)).isActive, isTrue);
    });

    test('isExpired for past unlock', () {
      expect(buildExercise(unlockedUntil: DateTime(2020, 1, 1)).isExpired, isTrue);
      expect(buildExercise(unlockedUntil: DateTime(2020, 1, 1)).isActive, isFalse);
    });

    test('isExpired is false for permanent', () {
      expect(buildExercise().isExpired, isFalse);
    });

    test('daysRemaining null for permanent', () {
      expect(buildExercise().daysRemaining, isNull);
    });

    test('daysRemaining positive for future', () {
      final future = DateTime.now().add(const Duration(days: 10));
      final result = buildExercise(unlockedUntil: future).daysRemaining;
      expect(result, greaterThanOrEqualTo(9));
      expect(result, lessThanOrEqualTo(10));
    });

    test('daysRemaining 0 for past', () {
      expect(buildExercise(unlockedUntil: DateTime(2020, 1, 1)).daysRemaining, 0);
    });

    test('focusDisplayName joins with comma', () {
      expect(buildExercise(focus: ['PETT', 'DELT ANT']).focusDisplayName, 'PETT, DELT ANT');
      expect(buildExercise(focus: ['BIC']).focusDisplayName, 'BIC');
    });

    test('muscoliSecondariDisplayName', () {
      expect(buildExercise(muscoliSecondari: ['TRIC', 'DELT']).muscoliSecondariDisplayName, 'TRIC, DELT');
    });

    test('attrezzaturaIcon all equipment types', () {
      expect(buildExercise(attrezzatura: 'Bilanciere').attrezzaturaIcon, isNotEmpty);
      expect(buildExercise(attrezzatura: 'Manubri').attrezzaturaIcon, isNotEmpty);
      expect(buildExercise(attrezzatura: 'Cavi').attrezzaturaIcon, isNotEmpty);
      expect(buildExercise(attrezzatura: 'Macchina').attrezzaturaIcon, isNotEmpty);
      expect(buildExercise(attrezzatura: 'Corpo Libero').attrezzaturaIcon, isNotEmpty);
      expect(buildExercise(attrezzatura: 'Unknown').attrezzaturaIcon, isNotEmpty);
    });
  });

  group('factory constructors', () {
    test('createNew generates UUID and sets createdAt', () {
      final e = CustomExercise.createNew(
        nome: 'New Exercise',
        focus: ['QUAD'],
        muscoliSecondari: ['GLUT'],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Squat',
        attrezzatura: 'Bilanciere',
      );
      expect(e.id, isNotEmpty);
      expect(e.id.length, 36); // UUID v4
      expect(e.nome, 'New Exercise');
      expect(e.baseExerciseId, isNull);
      expect(e.isModifiedFromBase, isFalse);
      expect(e.createdAt.difference(DateTime.now()).inSeconds.abs(), lessThan(5));
    });

    test('createNew with unlockedUntil and userId', () {
      final unlock = DateTime(2025, 12, 31);
      final e = CustomExercise.createNew(
        nome: 'Temp Exercise',
        focus: ['BIC'],
        muscoliSecondari: [],
        tipoEsercizio: 'Isolamento',
        patternMovimento: 'Pull',
        attrezzatura: 'Manubri',
        unlockedUntil: unlock,
        userId: 'user1',
      );
      expect(e.unlockedUntil, unlock);
      expect(e.userId, 'user1');
    });

    test('fromBase sets baseExerciseId and isModifiedFromBase', () {
      final e = CustomExercise.fromBase(
        baseExerciseId: 'bench-press',
        nome: 'Bench Stretta',
        focus: ['PETT'],
        muscoliSecondari: ['TRIC'],
        tipoEsercizio: 'Compound',
        patternMovimento: 'Push',
        attrezzatura: 'Bilanciere',
        isModifiedFromBase: true,
      );
      expect(e.baseExerciseId, 'bench-press');
      expect(e.isModifiedFromBase, isTrue);
      expect(e.id.length, 36);
    });
  });

  group('copyWith', () {
    test('changes specified fields', () {
      final e = buildExercise();
      final copy = e.copyWith(nome: 'New Name', userId: 'u2');
      expect(copy.nome, 'New Name');
      expect(copy.userId, 'u2');
      expect(copy.id, e.id); // unchanged
    });

    test('preserves all fields when no args', () {
      final e = buildExercise(baseExerciseId: 'b1', userId: 'u1');
      final copy = e.copyWith();
      expect(copy, equals(e));
    });
  });

  group('Equatable', () {
    test('equal with same fields', () {
      final a = buildExercise();
      final b = buildExercise();
      expect(a, equals(b));
    });

    test('not equal with different id', () {
      final a = buildExercise(id: 'a');
      final b = buildExercise(id: 'b');
      expect(a, isNot(equals(b)));
    });

    test('not equal with different nome', () {
      final a = buildExercise(nome: 'A');
      final b = buildExercise(nome: 'B');
      expect(a, isNot(equals(b)));
    });
  });

  group('CustomExerciseAdapter', () {
    test('typeId is 75', () {
      final adapter = CustomExerciseAdapter();
      expect(adapter.typeId, 75);
    });

    test('equality', () {
      final a = CustomExerciseAdapter();
      final b = CustomExerciseAdapter();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
