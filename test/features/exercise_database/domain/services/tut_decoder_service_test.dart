// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/tut_decoder_service.dart';

void main() {
  // ================================================================
  // TutDecoderService.decode
  // ================================================================
  group('TutDecoderService.decode', () {
    test('null returns empty string', () {
      expect(TutDecoderService.decode(null), '');
    });

    test('empty string returns empty string', () {
      expect(TutDecoderService.decode(''), '');
    });

    test('EXP returns movimento esplosivo', () {
      expect(TutDecoderService.decode('EXP'), 'Movimento esplosivo');
    });

    test('exp (lowercase) returns movimento esplosivo', () {
      expect(TutDecoderService.decode('exp'), 'Movimento esplosivo');
    });

    test('ISO returns mantieni posizione isometrica', () {
      expect(TutDecoderService.decode('ISO'), 'Mantieni posizione isometrica');
    });

    test('iso (lowercase) returns mantieni posizione isometrica', () {
      expect(TutDecoderService.decode('iso'), 'Mantieni posizione isometrica');
    });

    test('2-1-2-0 decodes correctly', () {
      final result = TutDecoderService.decode('2-1-2-0');
      expect(result, contains('2s discesa'));
      expect(result, contains('1s pausa in basso'));
      expect(result, contains('2s salita'));
    });

    test('3-0-1-0 has explosive concentric (concentric <= 1)', () {
      final result = TutDecoderService.decode('3-0-1-0');
      expect(result, contains('3s discesa'));
      expect(result, contains('esplosivo su'));
      expect(result, isNot(contains('pausa in alto')));
    });

    test('4-1-2-1 includes all four phases', () {
      final result = TutDecoderService.decode('4-1-2-1');
      expect(result, contains('4s discesa'));
      expect(result, contains('1s pausa in basso'));
      expect(result, contains('2s salita'));
      expect(result, contains('1s pausa in alto'));
    });

    test('0-0-0-0 returns only explosive su (concentric 0 <= 1)', () {
      final result = TutDecoderService.decode('0-0-0-0');
      expect(result, 'esplosivo su');
    });

    test('2-0-3-0 skips zero-second phases', () {
      final result = TutDecoderService.decode('2-0-3-0');
      expect(result, contains('2s discesa'));
      expect(result, isNot(contains('pausa in basso')));
      expect(result, contains('3s salita'));
      expect(result, isNot(contains('pausa in alto')));
    });

    test('invalid format (3 parts) returns original code', () {
      expect(TutDecoderService.decode('2-1-2'), '2-1-2');
    });

    test('invalid format (5 parts) returns original code', () {
      expect(TutDecoderService.decode('2-1-2-0-0'), '2-1-2-0-0');
    });

    test('non-numeric parts return original code', () {
      expect(TutDecoderService.decode('a-b-c-d'), 'a-b-c-d');
    });
  });

  // ================================================================
  // TutDecoderService.decodeShort
  // ================================================================
  group('TutDecoderService.decodeShort', () {
    test('null returns empty string', () {
      expect(TutDecoderService.decodeShort(null), '');
    });

    test('empty string returns empty string', () {
      expect(TutDecoderService.decodeShort(''), '');
    });

    test('EXP returns EXP', () {
      expect(TutDecoderService.decodeShort('EXP'), 'EXP');
    });

    test('ISO returns ISO', () {
      expect(TutDecoderService.decodeShort('ISO'), 'ISO');
    });

    test('2-1-2-0 short format contains arrows', () {
      final result = TutDecoderService.decodeShort('2-1-2-0');
      expect(result, contains('2↓'));
      expect(result, contains('1⏸'));
      expect(result, contains('2↑'));
    });

    test('3-0-1-0 shows lightning for explosive', () {
      final result = TutDecoderService.decodeShort('3-0-1-0');
      expect(result, contains('3↓'));
      expect(result, contains('⚡'));
    });

    test('0-0-0-0 shows only lightning (all zeros)', () {
      final result = TutDecoderService.decodeShort('0-0-0-0');
      expect(result, '⚡');
    });

    test('4-1-2-1 includes all four symbols', () {
      final result = TutDecoderService.decodeShort('4-1-2-1');
      expect(result, contains('4↓'));
      expect(result, contains('1⏸'));
      expect(result, contains('2↑'));
    });

    test('invalid format returns original code', () {
      expect(TutDecoderService.decodeShort('2-1'), '2-1');
    });
  });

  // ================================================================
  // TutDecoderService.decodeComplete
  // ================================================================
  group('TutDecoderService.decodeComplete', () {
    test('null returns null', () {
      expect(TutDecoderService.decodeComplete(null), isNull);
    });

    test('empty string returns null', () {
      expect(TutDecoderService.decodeComplete(''), isNull);
    });

    test('EXP returns TutDecoded with EXP data', () {
      final result = TutDecoderService.decodeComplete('EXP');
      expect(result, isNotNull);
      expect(result!.code, 'EXP');
      expect(result.description, 'Movimento esplosivo');
      expect(result.shortDescription, 'EXP');
      expect(result.totalSeconds, 1);
      expect(result.phases, hasLength(1));
      expect(result.phases.first.isExplosive, isTrue);
    });

    test('ISO returns TutDecoded with ISO data', () {
      final result = TutDecoderService.decodeComplete('ISO');
      expect(result, isNotNull);
      expect(result!.code, 'ISO');
      expect(result.description, 'Mantieni posizione isometrica');
      expect(result.shortDescription, 'ISO');
      expect(result.totalSeconds, 0);
    });

    test('2-1-2-0 returns 4 phases', () {
      final result = TutDecoderService.decodeComplete('2-1-2-0');
      expect(result, isNotNull);
      expect(result!.phases, hasLength(4));
    });

    test('2-1-2-0 phase names are correct', () {
      final result = TutDecoderService.decodeComplete('2-1-2-0');
      expect(result!.phases[0].name, 'Discesa');
      expect(result.phases[1].name, 'Pausa basso');
      expect(result.phases[2].name, 'Salita');
      expect(result.phases[3].name, 'Pausa alto');
    });

    test('2-1-2-0 totalSeconds is sum of all parts', () {
      final result = TutDecoderService.decodeComplete('2-1-2-0');
      expect(result!.totalSeconds, 5); // 2+1+2+0
    });

    test('4-2-3-1 totalSeconds is 10', () {
      final result = TutDecoderService.decodeComplete('4-2-3-1');
      expect(result!.totalSeconds, 10);
    });

    test('concentric 1 is marked explosive in phase', () {
      final result = TutDecoderService.decodeComplete('2-0-1-0');
      expect(result!.phases[2].isExplosive, isTrue);
    });

    test('concentric 2+ is not explosive', () {
      final result = TutDecoderService.decodeComplete('2-0-2-0');
      expect(result!.phases[2].isExplosive, isFalse);
    });

    test('invalid format (wrong parts) returns null', () {
      expect(TutDecoderService.decodeComplete('2-1'), isNull);
    });

    test('non-numeric parts returns null', () {
      expect(TutDecoderService.decodeComplete('a-b-c-d'), isNull);
    });

    test('code field preserves original input', () {
      final result = TutDecoderService.decodeComplete('3-1-3-0');
      expect(result!.code, '3-1-3-0');
    });
  });

  // ================================================================
  // TutDecoderService.calculateRepTime
  // ================================================================
  group('TutDecoderService.calculateRepTime', () {
    test('null returns 0', () {
      expect(TutDecoderService.calculateRepTime(null), 0);
    });

    test('empty string returns 0', () {
      expect(TutDecoderService.calculateRepTime(''), 0);
    });

    test('EXP returns 1', () {
      expect(TutDecoderService.calculateRepTime('EXP'), 1);
    });

    test('ISO returns 0', () {
      expect(TutDecoderService.calculateRepTime('ISO'), 0);
    });

    test('2-1-2-0 returns 5', () {
      expect(TutDecoderService.calculateRepTime('2-1-2-0'), 5);
    });

    test('4-2-3-1 returns 10', () {
      expect(TutDecoderService.calculateRepTime('4-2-3-1'), 10);
    });

    test('0-0-0-0 returns 0', () {
      expect(TutDecoderService.calculateRepTime('0-0-0-0'), 0);
    });

    test('invalid format returns 0', () {
      expect(TutDecoderService.calculateRepTime('invalid'), 0);
    });
  });

  // ================================================================
  // TutDecoderService.calculateSetTime
  // ================================================================
  group('TutDecoderService.calculateSetTime', () {
    test('2-1-2-0 with 10 reps = 50 seconds', () {
      expect(TutDecoderService.calculateSetTime('2-1-2-0', 10), 50);
    });

    test('4-0-2-0 with 5 reps = 30 seconds', () {
      expect(TutDecoderService.calculateSetTime('4-0-2-0', 5), 30);
    });

    test('EXP with 8 reps = 8 seconds', () {
      expect(TutDecoderService.calculateSetTime('EXP', 8), 8);
    });

    test('null tut with any reps = 0', () {
      expect(TutDecoderService.calculateSetTime(null, 10), 0);
    });

    test('0 reps always returns 0', () {
      expect(TutDecoderService.calculateSetTime('2-1-2-0', 0), 0);
    });
  });

  // ================================================================
  // TutDecoderService.isValidTut
  // ================================================================
  group('TutDecoderService.isValidTut', () {
    test('null returns false', () {
      expect(TutDecoderService.isValidTut(null), isFalse);
    });

    test('empty string returns false', () {
      expect(TutDecoderService.isValidTut(''), isFalse);
    });

    test('EXP is valid', () {
      expect(TutDecoderService.isValidTut('EXP'), isTrue);
    });

    test('exp (lowercase) is valid', () {
      expect(TutDecoderService.isValidTut('exp'), isTrue);
    });

    test('ISO is valid', () {
      expect(TutDecoderService.isValidTut('ISO'), isTrue);
    });

    test('2-1-2-0 is valid', () {
      expect(TutDecoderService.isValidTut('2-1-2-0'), isTrue);
    });

    test('4-2-3-1 is valid', () {
      expect(TutDecoderService.isValidTut('4-2-3-1'), isTrue);
    });

    test('0-0-0-0 is valid', () {
      expect(TutDecoderService.isValidTut('0-0-0-0'), isTrue);
    });

    test('three parts is invalid', () {
      expect(TutDecoderService.isValidTut('2-1-2'), isFalse);
    });

    test('five parts is invalid', () {
      expect(TutDecoderService.isValidTut('2-1-2-0-0'), isFalse);
    });

    test('non-numeric parts are invalid', () {
      expect(TutDecoderService.isValidTut('a-b-c-d'), isFalse);
    });

    test('mixed numeric/non-numeric is invalid', () {
      expect(TutDecoderService.isValidTut('2-x-2-0'), isFalse);
    });

    test('plain string without dashes is invalid', () {
      expect(TutDecoderService.isValidTut('fast'), isFalse);
    });
  });

  // ================================================================
  // TutPhase.displayText
  // ================================================================
  group('TutPhase.displayText', () {
    test('explosive phase shows Esplosivo', () {
      const phase = TutPhase(name: 'Salita', seconds: 0, isExplosive: true);
      expect(phase.displayText, 'Esplosivo');
    });

    test('zero seconds non-explosive shows dash', () {
      const phase = TutPhase(name: 'Pausa', seconds: 0, isExplosive: false);
      expect(phase.displayText, '-');
    });

    test('positive seconds shows seconds label', () {
      const phase = TutPhase(name: 'Discesa', seconds: 3, isExplosive: false);
      expect(phase.displayText, '3s');
    });

    test('2 seconds shows 2s', () {
      const phase = TutPhase(name: 'Salita', seconds: 2, isExplosive: false);
      expect(phase.displayText, '2s');
    });
  });
}
