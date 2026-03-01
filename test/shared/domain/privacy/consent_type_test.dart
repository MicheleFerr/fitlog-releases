/// ConsentType tests - displayName, description, isRequired, isSpecialCategory, legal.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/consent_type.dart';

void main() {
  group('ConsentType', () {
    test('has 8 values', () {
      expect(ConsentType.values.length, 8);
    });
  });

  group('ConsentType.displayName', () {
    test('essential', () {
      expect(ConsentType.essential.displayName, 'Essential');
    });

    test('analytics', () {
      expect(ConsentType.analytics.displayName, 'Analytics');
    });

    test('marketing', () {
      expect(ConsentType.marketing.displayName, 'Marketing');
    });

    test('personalization', () {
      expect(ConsentType.personalization.displayName, 'Personalization');
    });

    test('social', () {
      expect(ConsentType.social.displayName, 'Social Features');
    });

    test('healthKitData', () {
      expect(ConsentType.healthKitData.displayName, 'Health Data Sync');
    });

    test('progressPhotos', () {
      expect(ConsentType.progressPhotos.displayName, 'Progress Photos');
    });

    test('healthData', () {
      expect(ConsentType.healthData.displayName, 'Body Measurements');
    });
  });

  group('ConsentType.description', () {
    test('all have non-empty descriptions', () {
      for (final type in ConsentType.values) {
        expect(type.description, isNotEmpty,
            reason: '${type.name} should have a description');
      }
    });
  });

  group('ConsentType.isRequired', () {
    test('only essential is required', () {
      expect(ConsentType.essential.isRequired, isTrue);
      for (final type in ConsentType.values) {
        if (type != ConsentType.essential) {
          expect(type.isRequired, isFalse,
              reason: '${type.name} should not be required');
        }
      }
    });
  });

  group('ConsentType.isSpecialCategory', () {
    test('healthKitData is special', () {
      expect(ConsentType.healthKitData.isSpecialCategory, isTrue);
    });

    test('progressPhotos is special', () {
      expect(ConsentType.progressPhotos.isSpecialCategory, isTrue);
    });

    test('healthData is special', () {
      expect(ConsentType.healthData.isSpecialCategory, isTrue);
    });

    test('analytics is not special', () {
      expect(ConsentType.analytics.isSpecialCategory, isFalse);
    });

    test('marketing is not special', () {
      expect(ConsentType.marketing.isSpecialCategory, isFalse);
    });

    test('essential is not special', () {
      expect(ConsentType.essential.isSpecialCategory, isFalse);
    });
  });

  group('ConsentType.legalBasis', () {
    test('essential uses legitimate interest', () {
      expect(ConsentType.essential.legalBasis,
          contains('Legitimate Interest'));
    });

    test('healthKitData uses explicit consent Art 9', () {
      expect(ConsentType.healthKitData.legalBasis,
          contains('Art. 9(2)(a)'));
    });

    test('analytics uses standard consent', () {
      expect(ConsentType.analytics.legalBasis,
          contains('Art. 6(1)(a)'));
    });
  });

  group('ConsentType.gdprArticle', () {
    test('essential references Art. 6(1)(f)', () {
      expect(ConsentType.essential.gdprArticle, 'Art. 6(1)(f)');
    });

    test('health data references Art. 9(2)(a)', () {
      expect(ConsentType.healthKitData.gdprArticle, 'Art. 9(2)(a)');
      expect(ConsentType.progressPhotos.gdprArticle, 'Art. 9(2)(a)');
      expect(ConsentType.healthData.gdprArticle, 'Art. 9(2)(a)');
    });

    test('standard consent references Art. 6(1)(a)', () {
      expect(ConsentType.analytics.gdprArticle, 'Art. 6(1)(a)');
      expect(ConsentType.marketing.gdprArticle, 'Art. 6(1)(a)');
      expect(ConsentType.personalization.gdprArticle, 'Art. 6(1)(a)');
      expect(ConsentType.social.gdprArticle, 'Art. 6(1)(a)');
    });
  });
}
