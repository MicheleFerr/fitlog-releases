/// AIQuota tests - fields, isExhausted.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';

void main() {
  group('AIQuota', () {
    test('stores all fields', () {
      const quota = AIQuota(
        accountTier: 'free',
        usedToday: 3,
        limitPerDay: 10,
        remainingToday: 7,
      );
      expect(quota.accountTier, 'free');
      expect(quota.usedToday, 3);
      expect(quota.limitPerDay, 10);
      expect(quota.remainingToday, 7);
    });

    test('isExhausted false when remaining > 0', () {
      const quota = AIQuota(
        accountTier: 'free',
        usedToday: 5,
        limitPerDay: 10,
        remainingToday: 5,
      );
      expect(quota.isExhausted, isFalse);
    });

    test('isExhausted true when remaining == 0', () {
      const quota = AIQuota(
        accountTier: 'free',
        usedToday: 10,
        limitPerDay: 10,
        remainingToday: 0,
      );
      expect(quota.isExhausted, isTrue);
    });

    test('isExhausted true when remaining < 0', () {
      const quota = AIQuota(
        accountTier: 'premium',
        usedToday: 12,
        limitPerDay: 10,
        remainingToday: -2,
      );
      expect(quota.isExhausted, isTrue);
    });
  });
}
