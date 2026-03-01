/// StrengthStandardsLocalDataSource Tests
///
/// Tests the exception types, static cache clearing, and error path behaviours.
/// Asset loading is not tested directly as it requires rootBundle (widget test context).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/strength_standards_local_datasource.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Exception types
  // ---------------------------------------------------------------------------

  group('StrengthStandardsLoadException', () {
    test('toString includes class name and message', () {
      final exception = StrengthStandardsLoadException('File not found');

      final str = exception.toString();
      expect(str, contains('StrengthStandardsLoadException'));
      expect(str, contains('File not found'));
    });

    test('implements Exception interface', () {
      final exception = StrengthStandardsLoadException('Error');
      expect(exception, isA<Exception>());
    });

    test('preserves message', () {
      const msg = 'Specific error message';
      final exception = StrengthStandardsLoadException(msg);
      expect(exception.message, equals(msg));
    });
  });

  group('ExerciseMappingsLoadException', () {
    test('toString includes class name and message', () {
      final exception = ExerciseMappingsLoadException('Parsing failed');

      final str = exception.toString();
      expect(str, contains('ExerciseMappingsLoadException'));
      expect(str, contains('Parsing failed'));
    });

    test('implements Exception interface', () {
      final exception = ExerciseMappingsLoadException('Error');
      expect(exception, isA<Exception>());
    });

    test('preserves message', () {
      const msg = 'JSON decode error';
      final exception = ExerciseMappingsLoadException(msg);
      expect(exception.message, equals(msg));
    });
  });

  // ---------------------------------------------------------------------------
  // Static cache
  // ---------------------------------------------------------------------------

  group('StrengthStandardsLocalDataSource.clearCache', () {
    test('clearCache can be called without errors', () {
      expect(
        () => StrengthStandardsLocalDataSource.clearCache(),
        returnsNormally,
      );
    });

    test('clearCache can be called multiple times without errors', () {
      expect(() {
        StrengthStandardsLocalDataSource.clearCache();
        StrengthStandardsLocalDataSource.clearCache();
        StrengthStandardsLocalDataSource.clearCache();
      }, returnsNormally);
    });

    test('datasource can be instantiated', () {
      final datasource = StrengthStandardsLocalDataSource();
      expect(datasource, isNotNull);
      expect(datasource, isA<StrengthStandardsLocalDataSource>());
    });
  });

  // ---------------------------------------------------------------------------
  // Exception message format tests
  // ---------------------------------------------------------------------------

  group('Exception edge cases', () {
    test('StrengthStandardsLoadException with empty message', () {
      final exception = StrengthStandardsLoadException('');
      expect(exception.message, equals(''));
      expect(exception.toString(), contains('StrengthStandardsLoadException'));
    });

    test('ExerciseMappingsLoadException with long message', () {
      const longMsg =
          'Failed to load exercise mappings from assets/data/exercise_mappings.json: '
          'FormatException: Unexpected character at position 0';
      final exception = ExerciseMappingsLoadException(longMsg);
      expect(exception.message, equals(longMsg));
      expect(exception.toString(), contains('ExerciseMappingsLoadException'));
    });
  });
}
