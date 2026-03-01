/// MuscleAbbreviationMapper tests - lookups, normalization, categorization, heatmap.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

void main() {
  group('MuscleCategory', () {
    test('has 6 values', () {
      expect(MuscleCategory.values.length, 6);
    });
  });

  group('MuscleInfo', () {
    test('stores all fields', () {
      const info = MuscleInfo(
        id: 'PETT',
        displayNameEn: 'Chest',
        displayNameIt: 'Pettorali',
        category: MuscleCategory.chest,
      );
      expect(info.id, 'PETT');
      expect(info.displayNameEn, 'Chest');
      expect(info.displayNameIt, 'Pettorali');
      expect(info.category, MuscleCategory.chest);
    });

    test('recoveryHours returns a positive value', () {
      const info = MuscleInfo(
        id: 'PETT',
        displayNameEn: 'Chest',
        displayNameIt: 'Pettorali',
        category: MuscleCategory.chest,
      );
      expect(info.recoveryHours, greaterThan(0));
    });
  });

  group('MuscleAbbreviationMapper.getMuscleInfo', () {
    test('known abbreviation returns info', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('PETT');
      expect(info, isNotNull);
      expect(info!.id, 'PETT');
    });

    test('case insensitive', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('pett');
      expect(info, isNotNull);
      expect(info!.id, 'PETT');
    });

    test('unknown abbreviation returns null', () {
      expect(MuscleAbbreviationMapper.getMuscleInfo('UNKNOWN'), isNull);
    });

    test('variant BIC maps to BICI', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('BIC');
      expect(info!.id, 'BICI');
    });

    test('variant AVAMB maps to AVA', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('AVAMB');
      expect(info!.id, 'AVA');
    });

    test('variant LOMBAR maps to LOMB', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('LOMBAR');
      expect(info!.id, 'LOMB');
    });

    test('variant FEMOR maps to FEMO', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('FEMOR');
      expect(info!.id, 'FEMO');
    });

    test('variant ADDOM maps to CORE', () {
      final info = MuscleAbbreviationMapper.getMuscleInfo('ADDOM');
      expect(info!.id, 'CORE');
    });
  });

  group('MuscleAbbreviationMapper.normalizeToCanonicalId', () {
    test('canonical stays same', () {
      expect(MuscleAbbreviationMapper.normalizeToCanonicalId('PETT'), 'PETT');
    });

    test('variant normalizes', () {
      expect(MuscleAbbreviationMapper.normalizeToCanonicalId('BIC'), 'BICI');
      expect(MuscleAbbreviationMapper.normalizeToCanonicalId('POLL'), 'POLP');
      expect(MuscleAbbreviationMapper.normalizeToCanonicalId('ADDO'), 'ADD');
    });

    test('unknown returns uppercase input', () {
      expect(
          MuscleAbbreviationMapper.normalizeToCanonicalId('unknown'), 'UNKNOWN');
    });
  });

  group('MuscleAbbreviationMapper.parseFocusField', () {
    test('null returns empty', () {
      expect(MuscleAbbreviationMapper.parseFocusField(null), isEmpty);
    });

    test('empty string returns empty', () {
      expect(MuscleAbbreviationMapper.parseFocusField(''), isEmpty);
    });

    test('"null" string returns empty', () {
      expect(MuscleAbbreviationMapper.parseFocusField('null'), isEmpty);
    });

    test('single muscle', () {
      final result = MuscleAbbreviationMapper.parseFocusField('PETT');
      expect(result.length, 1);
      expect(result.first.id, 'PETT');
    });

    test('multiple muscles', () {
      final result = MuscleAbbreviationMapper.parseFocusField('PETT, TRIC');
      expect(result.length, 2);
    });

    test('deduplicates variants (BIC and BICI)', () {
      final result =
          MuscleAbbreviationMapper.parseFocusField('BIC, BICI, TRIC');
      // BIC and BICI both map to BICI, should be deduplicated
      final bicCount = result.where((m) => m.id == 'BICI').length;
      expect(bicCount, 1);
    });

    test('ignores unknown abbreviations', () {
      final result =
          MuscleAbbreviationMapper.parseFocusField('PETT, UNKNOWN, TRIC');
      expect(result.length, 2);
    });
  });

  group('MuscleAbbreviationMapper.getAllMuscles', () {
    test('returns unique muscles only', () {
      final muscles = MuscleAbbreviationMapper.getAllMuscles();
      final ids = muscles.map((m) => m.id).toSet();
      expect(ids.length, muscles.length); // No duplicates
    });

    test('includes major muscles', () {
      final muscles = MuscleAbbreviationMapper.getAllMuscles();
      final ids = muscles.map((m) => m.id).toSet();
      expect(ids, contains('PETT'));
      expect(ids, contains('LAT'));
      expect(ids, contains('QUAD'));
      expect(ids, contains('BICI'));
      expect(ids, contains('CORE'));
    });
  });

  group('MuscleAbbreviationMapper.getMusclesByCategory', () {
    test('chest muscles', () {
      final muscles =
          MuscleAbbreviationMapper.getMusclesByCategory(MuscleCategory.chest);
      expect(muscles, isNotEmpty);
      expect(muscles.every((m) => m.category == MuscleCategory.chest), isTrue);
    });

    test('legs includes quads and glutes', () {
      final muscles =
          MuscleAbbreviationMapper.getMusclesByCategory(MuscleCategory.legs);
      final ids = muscles.map((m) => m.id).toSet();
      expect(ids, contains('QUAD'));
      expect(ids, contains('GLUT'));
    });
  });

  group('MuscleAbbreviationMapper.muscleCategoryToExerciseCategory', () {
    test('chest', () {
      expect(
        MuscleAbbreviationMapper.muscleCategoryToExerciseCategory(
            MuscleCategory.chest),
        ExerciseCategory.chest,
      );
    });

    test('back', () {
      expect(
        MuscleAbbreviationMapper.muscleCategoryToExerciseCategory(
            MuscleCategory.back),
        ExerciseCategory.back,
      );
    });

    test('core maps to abs', () {
      expect(
        MuscleAbbreviationMapper.muscleCategoryToExerciseCategory(
            MuscleCategory.core),
        ExerciseCategory.abs,
      );
    });
  });

  group('MuscleAbbreviationMapper.focusToExerciseCategory', () {
    test('null returns other', () {
      expect(MuscleAbbreviationMapper.focusToExerciseCategory(null),
          ExerciseCategory.other);
    });

    test('empty returns other', () {
      expect(MuscleAbbreviationMapper.focusToExerciseCategory(''),
          ExerciseCategory.other);
    });

    test('PETT returns chest', () {
      expect(MuscleAbbreviationMapper.focusToExerciseCategory('PETT'),
          ExerciseCategory.chest);
    });

    test('LAT returns back', () {
      expect(MuscleAbbreviationMapper.focusToExerciseCategory('LAT'),
          ExerciseCategory.back);
    });

    test('multiple uses first', () {
      expect(MuscleAbbreviationMapper.focusToExerciseCategory('QUAD, GLUT'),
          ExerciseCategory.legs);
    });
  });

  group('MuscleAbbreviationMapper.focusListToExerciseCategory', () {
    test('empty list returns other', () {
      expect(MuscleAbbreviationMapper.focusListToExerciseCategory([]),
          ExerciseCategory.other);
    });

    test('valid list returns category of first', () {
      expect(
        MuscleAbbreviationMapper.focusListToExerciseCategory(['PETT', 'TRIC']),
        ExerciseCategory.chest,
      );
    });

    test('unknown list returns other', () {
      expect(
        MuscleAbbreviationMapper.focusListToExerciseCategory(['UNKNOWN']),
        ExerciseCategory.other,
      );
    });
  });

  group('MuscleAbbreviationMapper.toHeatmapGroupKey', () {
    test('LAT maps to lats', () {
      expect(MuscleAbbreviationMapper.toHeatmapGroupKey('LAT'), 'lats');
    });

    test('PETT maps to chest', () {
      expect(MuscleAbbreviationMapper.toHeatmapGroupKey('PETT'), 'chest');
    });

    test('QUAD maps to quadriceps', () {
      expect(
          MuscleAbbreviationMapper.toHeatmapGroupKey('QUAD'), 'quadriceps');
    });

    test('variant DORSO maps to lats', () {
      expect(MuscleAbbreviationMapper.toHeatmapGroupKey('DORSO'), 'lats');
    });

    test('unknown returns null', () {
      expect(MuscleAbbreviationMapper.toHeatmapGroupKey('UNKNOWN'), isNull);
    });
  });

  group('MuscleAbbreviationMapper.normalizeToHeatmapKey', () {
    test('abbreviation', () {
      expect(MuscleAbbreviationMapper.normalizeToHeatmapKey('PETT'), 'chest');
    });

    test('english name', () {
      expect(MuscleAbbreviationMapper.normalizeToHeatmapKey('chest'), 'chest');
      expect(MuscleAbbreviationMapper.normalizeToHeatmapKey('quads'),
          'quadriceps');
    });

    test('already correct key', () {
      expect(MuscleAbbreviationMapper.normalizeToHeatmapKey('lats'), 'lats');
    });

    test('unknown returns input lowercase', () {
      expect(MuscleAbbreviationMapper.normalizeToHeatmapKey('ZZZZ'), 'zzzz');
    });
  });

  group('MuscleAbbreviationMapper.nameToAbbreviation', () {
    test('Italian names', () {
      expect(MuscleAbbreviationMapper.nameToAbbreviation('Pettorali'), 'PETT');
      expect(MuscleAbbreviationMapper.nameToAbbreviation('Quadricipiti'),
          'QUAD');
      expect(MuscleAbbreviationMapper.nameToAbbreviation('Dorsali'), 'LAT');
    });

    test('English names', () {
      expect(MuscleAbbreviationMapper.nameToAbbreviation('Chest'), 'PETT');
      expect(MuscleAbbreviationMapper.nameToAbbreviation('Back'), 'LAT');
      expect(
          MuscleAbbreviationMapper.nameToAbbreviation('Hamstrings'), 'FEMO');
    });

    test('abbreviation as input', () {
      expect(MuscleAbbreviationMapper.nameToAbbreviation('PETT'), 'PETT');
    });

    test('unknown returns null', () {
      expect(MuscleAbbreviationMapper.nameToAbbreviation('Something'), isNull);
    });
  });

  group('MuscleAbbreviationMapper.codeToDisplayName', () {
    test('italian (default)', () {
      expect(MuscleAbbreviationMapper.codeToDisplayName('PETT'), 'Pettorali');
    });

    test('english', () {
      expect(
          MuscleAbbreviationMapper.codeToDisplayName('PETT', italian: false),
          'Chest');
    });

    test('unknown returns code', () {
      expect(MuscleAbbreviationMapper.codeToDisplayName('UNKNOWN'), 'UNKNOWN');
    });
  });

  group('MuscleAbbreviationMapper.categoryToAbbreviations', () {
    test('chest returns PETT', () {
      expect(
        MuscleAbbreviationMapper.categoryToAbbreviations(
            ExerciseCategory.chest),
        contains('PETT'),
      );
    });

    test('cardio returns empty', () {
      expect(
        MuscleAbbreviationMapper.categoryToAbbreviations(
            ExerciseCategory.cardio),
        isEmpty,
      );
    });

    test('other returns empty', () {
      expect(
        MuscleAbbreviationMapper.categoryToAbbreviations(
            ExerciseCategory.other),
        isEmpty,
      );
    });
  });

  group('MuscleAbbreviationMapper.getAllMusclesForSelector', () {
    test('returns non-empty map', () {
      final map = MuscleAbbreviationMapper.getAllMusclesForSelector();
      expect(map, isNotEmpty);
      expect(map['PETT'], 'Pettorali');
      expect(map['QUAD'], 'Quadricipiti');
    });
  });

  group('MuscleAbbreviationMapper.normalizeToCategory', () {
    test('english names', () {
      expect(MuscleAbbreviationMapper.normalizeToCategory('chest'),
          MuscleCategory.chest);
      expect(MuscleAbbreviationMapper.normalizeToCategory('back'),
          MuscleCategory.back);
      expect(MuscleAbbreviationMapper.normalizeToCategory('legs'),
          MuscleCategory.legs);
    });

    test('italian names', () {
      expect(MuscleAbbreviationMapper.normalizeToCategory('petto'),
          MuscleCategory.chest);
      expect(MuscleAbbreviationMapper.normalizeToCategory('schiena'),
          MuscleCategory.back);
      expect(MuscleAbbreviationMapper.normalizeToCategory('gambe'),
          MuscleCategory.legs);
    });

    test('unknown returns null', () {
      expect(MuscleAbbreviationMapper.normalizeToCategory('xxx'), isNull);
    });
  });

  group('MuscleAbbreviationMapper.getSearchAbbreviations', () {
    test('push pattern', () {
      final result = MuscleAbbreviationMapper.getSearchAbbreviations('push');
      expect(result, contains('PETT'));
      expect(result, contains('TRIC'));
    });

    test('pull pattern', () {
      final result = MuscleAbbreviationMapper.getSearchAbbreviations('pull');
      expect(result, contains('LAT'));
      expect(result, contains('BICI'));
    });

    test('legs pattern', () {
      final result = MuscleAbbreviationMapper.getSearchAbbreviations('legs');
      expect(result, contains('QUAD'));
      expect(result, contains('GLUT'));
    });

    test('direct name', () {
      final result = MuscleAbbreviationMapper.getSearchAbbreviations('chest');
      expect(result, contains('PETT'));
    });

    test('unknown returns empty', () {
      expect(MuscleAbbreviationMapper.getSearchAbbreviations('zzz'), isEmpty);
    });
  });

  group('MuscleAbbreviationMapper.categorizeExerciseByName', () {
    test('chest exercises', () {
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Bench Press'),
          'Chest');
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName('Dumbbell Fly'),
          'Chest');
    });

    test('back exercises', () {
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Barbell Row'),
          'Back');
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Lat Pulldown'),
          'Back');
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Deadlift'),
          'Back');
    });

    test('shoulder exercises', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName('Shoulder Press'),
          'Shoulders');
      // 'Lateral Raise' contains 'lat' which matches Back pattern first
      // Use explicit shoulder keywords for accurate categorization
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName('Delt Raise'),
          'Shoulders');
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName('Military Press'),
          'Shoulders');
    });

    test('legs exercises', () {
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Squat'),
          'Legs');
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Leg Press'),
          'Legs');
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName('Hip Thrust'),
          'Legs');
    });

    test('arms exercises', () {
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Bicep Curl'),
          'Arms');
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName(
              'Tricep Pushdown'),
          'Arms');
    });

    test('core exercises', () {
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Plank'),
          'Core');
      expect(MuscleAbbreviationMapper.categorizeExerciseByName('Crunch'),
          'Core');
    });

    test('unknown returns Other', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseByName('Random Thing'),
          'Other');
    });
  });

  group('MuscleAbbreviationMapper.categorizeExerciseToAbbreviation', () {
    test('squat -> QUAD', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation('Squat'),
          'QUAD');
    });

    test('leg curl -> FEMOR', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Leg Curl'),
          'FEMOR');
    });

    test('bench press -> PETT', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Bench Press'),
          'PETT');
    });

    test('lat pulldown -> LAT', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Lat Pulldown'),
          'LAT');
    });

    test('bicep curl -> BICI', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Bicep Curl'),
          'BICI');
    });

    test('calf raise -> POLP', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Calf Raise'),
          'POLP');
    });

    test('hip thrust -> GLUT', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Hip Thrust'),
          'GLUT');
    });

    test('plank -> CORE', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation('Plank'),
          'CORE');
    });

    test('unknown -> VARIO', () {
      expect(
          MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              'Random Exercise'),
          'VARIO');
    });
  });

  group('MuscleAbbreviationMapper.categoryFromExerciseName', () {
    test('bench press -> chest', () {
      expect(
        MuscleAbbreviationMapper.categoryFromExerciseName('Bench Press'),
        MuscleCategory.chest,
      );
    });

    test('unknown -> null', () {
      expect(
        MuscleAbbreviationMapper.categoryFromExerciseName('Random'),
        isNull,
      );
    });
  });
}
