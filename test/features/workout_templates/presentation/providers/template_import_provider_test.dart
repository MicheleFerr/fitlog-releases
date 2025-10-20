import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/presentation/providers/template_import_provider.dart';

void main() {
  group('TemplateImportProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      final state = container.read(templateImportProvider);

      expect(state.parsingResults, isEmpty);
      expect(state.errors, isEmpty);
      expect(state.progress, equals(0.0));
    });

    test('reset clears state', () {
      container.read(templateImportProvider.notifier).reset();
      final state = container.read(templateImportProvider);

      expect(state.parsingResults, isEmpty);
      expect(state.errors, isEmpty);
    });
  });
}
