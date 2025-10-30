import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/percentage_conversion_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_import_export.dart';

void main() {
  group('PercentageConversionService', () {
    late PercentageConversionService service;

    setUp(() {
      service = PercentageConversionService();
    });

    test('processPercentageConversions returns empty list', () async {
      const template = WorkoutTemplateImportData(
        name: 'Test',
        exercises: [],
        category: 'strength',
      );

      final result = await service.processPercentageConversions(template, 'userId');

      expect(result, isEmpty);
    });

    test('applyPercentageConversions returns template unchanged', () async {
      const template = WorkoutTemplateImportData(
        name: 'Test',
        exercises: [],
        category: 'strength',
      );

      final result = service.applyPercentageConversions(template, []);

      expect(result.name, equals('Test'));
    });
  });
}
