import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';

/// Integration test per verificare che il mapping MuscleAbbreviationMapper
/// funzioni correttamente per i nomi normalizzati dal detector
void main() {
  group('MuscleAbbreviationMapper - normalized detector keys', () {
    test('quads → QUAD', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'quads',
      );
      expect(searchCodes, ['QUAD']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation('quads');
      expect(nameToAbbr, 'QUAD');
    });

    test('hamstrings → FEMO', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'hamstrings',
      );
      expect(searchCodes, ['FEMO']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation(
        'hamstrings',
      );
      expect(nameToAbbr, 'FEMO');
    });

    test('glutes → GLUT', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'glutes',
      );
      expect(searchCodes, ['GLUT']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation('glutes');
      expect(nameToAbbr, 'GLUT');
    });

    test('chest → PETT', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'chest',
      );
      expect(searchCodes, ['PETT']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation('chest');
      expect(nameToAbbr, 'PETT');
    });

    test('back → LAT (fallback)', () {
      // "back" non è in nameToAbbreviation, quindi deve usare fallback
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'back',
      );
      // Fallback case in _getFocusCodesForMuscle dovrebbe restituire ['LAT', 'TRAP', 'LOMBAR']
      expect(searchCodes.isNotEmpty, isTrue);
    });

    test('shoulders → DELT', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'shoulders',
      );
      expect(searchCodes, ['DELT']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation(
        'shoulders',
      );
      expect(nameToAbbr, 'DELT');
    });

    test('rear_delts non mappato (problema!)', () {
      // rear_delts con underscore non è mappato!
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'rear_delts',
      );

      if (searchCodes.isEmpty) {
        // Questo è un problema - rear_delts dovrebbe mappare a DELT_POST
        fail(
          'rear_delts non ha mapping! Dovrebbe mappare a DELT_POST',
        );
      }
    });

    test('calves → POLP', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'calves',
      );
      expect(searchCodes, ['POLP']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation('calves');
      expect(nameToAbbr, 'POLP');
    });

    test('biceps → BICI', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'biceps',
      );
      expect(searchCodes, ['BICI']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation('biceps');
      expect(nameToAbbr, 'BICI');
    });

    test('triceps → TRIC', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'triceps',
      );
      expect(searchCodes, ['TRIC']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation(
        'triceps',
      );
      expect(nameToAbbr, 'TRIC');
    });

    test('forearms → AVA', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'forearms',
      );
      expect(searchCodes, ['AVA']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation(
        'forearms',
      );
      expect(nameToAbbr, 'AVA');
    });

    test('abs → CORE', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'abs',
      );
      expect(searchCodes, ['CORE']);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation('abs');
      expect(nameToAbbr, 'CORE');
    });

    test('lower_back → LOMB', () {
      final searchCodes = MuscleAbbreviationMapper.getSearchAbbreviations(
        'lower_back',
      );
      // lower_back con underscore dovrebbe essere mappato
      expect(searchCodes.isNotEmpty, isTrue);

      final nameToAbbr = MuscleAbbreviationMapper.nameToAbbreviation(
        'lower_back',
      );
      expect(nameToAbbr, 'LOMB');
    });
  });
}
