/// LogCategory entity tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/log_category.dart';

void main() {
  group('LogCategory', () {
    test('has 6 values', () {
      expect(LogCategory.values.length, 6);
      expect(LogCategory.values, contains(LogCategory.workout));
      expect(LogCategory.values, contains(LogCategory.analytics));
      expect(LogCategory.values, contains(LogCategory.auth));
      expect(LogCategory.values, contains(LogCategory.network));
      expect(LogCategory.values, contains(LogCategory.cache));
      expect(LogCategory.values, contains(LogCategory.general));
    });
  });
}
