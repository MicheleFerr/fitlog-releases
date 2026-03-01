/// PdfDetailLevel entity tests - enum values, fromString parsing.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/pdf_detail_level.dart';

void main() {
  group('PdfDetailLevel', () {
    test('has 3 values', () {
      expect(PdfDetailLevel.values.length, 3);
    });
  });

  group('PdfDetailLevelExtension.fromString', () {
    test('parses all values', () {
      expect(PdfDetailLevelExtension.fromString('compact'),
          PdfDetailLevel.compact);
      expect(PdfDetailLevelExtension.fromString('detailedWithWeight'),
          PdfDetailLevel.detailedWithWeight);
      expect(PdfDetailLevelExtension.fromString('detailedWithoutWeight'),
          PdfDetailLevel.detailedWithoutWeight);
    });

    test('defaults to compact for unknown', () {
      expect(PdfDetailLevelExtension.fromString('unknown'),
          PdfDetailLevel.compact);
      expect(
          PdfDetailLevelExtension.fromString(''), PdfDetailLevel.compact);
    });
  });
}
