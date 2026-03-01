/// TemplateCategory entity tests - enum values, gradientColors.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';

void main() {
  group('TemplateCategory', () {
    test('has 4 values', () {
      expect(TemplateCategory.values.length, 4);
      expect(TemplateCategory.values, contains(TemplateCategory.strength));
      expect(TemplateCategory.values, contains(TemplateCategory.cardio));
      expect(TemplateCategory.values, contains(TemplateCategory.flexibility));
      expect(TemplateCategory.values, contains(TemplateCategory.hybrid));
    });

    test('gradientColors returns 2 colors for each category (dark)', () {
      for (final cat in TemplateCategory.values) {
        final colors = cat.gradientColors(true);
        expect(colors.length, 2, reason: '${cat.name} dark should have 2 gradient colors');
      }
    });

    test('gradientColors returns 2 colors for each category (light)', () {
      for (final cat in TemplateCategory.values) {
        final colors = cat.gradientColors(false);
        expect(colors.length, 2, reason: '${cat.name} light should have 2 gradient colors');
      }
    });

    test('gradientColors differ between dark and light', () {
      for (final cat in TemplateCategory.values) {
        final dark = cat.gradientColors(true);
        final light = cat.gradientColors(false);
        // At least one color should differ between themes
        expect(
          dark[0] != light[0] || dark[1] != light[1],
          isTrue,
          reason: '${cat.name} should have different colors for dark/light',
        );
      }
    });

    test('toGradient returns LinearGradient', () {
      final gradient = TemplateCategory.strength.toGradient(false);
      expect(gradient.colors.length, 2);
    });
  });
}
