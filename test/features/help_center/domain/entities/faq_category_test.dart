/// FAQCategory entity tests - FAQCategory, FAQItem, FAQCategoryType.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/help_center/domain/entities/faq_category.dart';

void main() {
  group('FAQCategoryType', () {
    test('has 4 values', () {
      expect(FAQCategoryType.values.length, 4);
      expect(FAQCategoryType.values, contains(FAQCategoryType.appUsage));
      expect(FAQCategoryType.values, contains(FAQCategoryType.workouts));
      expect(FAQCategoryType.values, contains(FAQCategoryType.progress));
      expect(FAQCategoryType.values, contains(FAQCategoryType.settings));
    });
  });

  group('FAQItem', () {
    test('stores all fields', () {
      const item = FAQItem(
        id: 'faq1',
        questionKey: 'questionKey1',
        answerKey: 'answerKey1',
      );
      expect(item.id, 'faq1');
      expect(item.questionKey, 'questionKey1');
      expect(item.answerKey, 'answerKey1');
    });
  });

  group('FAQCategory', () {
    test('stores all fields', () {
      const items = [
        FAQItem(id: 'q1', questionKey: 'qk1', answerKey: 'ak1'),
        FAQItem(id: 'q2', questionKey: 'qk2', answerKey: 'ak2'),
      ];
      const category = FAQCategory(
        id: 'cat1',
        titleKey: 'title1',
        descriptionKey: 'desc1',
        icon: Icons.help,
        items: items,
      );
      expect(category.id, 'cat1');
      expect(category.titleKey, 'title1');
      expect(category.descriptionKey, 'desc1');
      expect(category.icon, Icons.help);
      expect(category.items.length, 2);
    });
  });
}
