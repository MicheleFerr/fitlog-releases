/// PRType enum tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

void main() {
  group('PRType', () {
    test('has 6 values', () {
      expect(PRType.values.length, 6);
    });

    test('contains all expected types', () {
      expect(PRType.values, contains(PRType.weight));
      expect(PRType.values, contains(PRType.volume));
      expect(PRType.values, contains(PRType.reps));
      expect(PRType.values, contains(PRType.duration));
      expect(PRType.values, contains(PRType.oneRM));
      expect(PRType.values, contains(PRType.totalSets));
    });
  });
}
