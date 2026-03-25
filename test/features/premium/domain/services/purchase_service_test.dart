import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_sync_client.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/domain/repositories/purchase_repository.dart';
import 'package:gymbro_flutter_new/features/premium/domain/services/purchase_service.dart';

class _FakePurchaseRepository implements PurchaseRepository {
  PurchaseResult purchaseResult = const PurchaseSuccess();
  PurchaseResult restoreResult = const PurchaseSuccess();

  @override
  Future<void> initialize() async {}

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async => const [];

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async =>
      SubscriptionStatus.free();

  @override
  Stream<SubscriptionStatus> watchSubscriptionStatus() async* {
    yield SubscriptionStatus.free();
  }

  @override
  Future<PurchaseResult> purchase(SubscriptionPlan plan) async =>
      purchaseResult;

  @override
  Future<PurchaseResult> restorePurchases() async => restoreResult;

  @override
  Future<void> setUserId(String userId) async {}

  @override
  Future<void> logout() async {}
}

class _FakePremiumEntitlementSyncClient
    implements PremiumEntitlementSyncClient {
  final List<String> syncedUserIds = <String>[];
  Object? syncError;

  @override
  Future<void> syncEntitlements(String userId) async {
    if (syncError != null) {
      throw syncError!;
    }
    syncedUserIds.add(userId);
  }
}

void main() {
  group('PurchaseService', () {
    late _FakePurchaseRepository repository;
    late _FakePremiumEntitlementSyncClient syncClient;
    late PurchaseService service;

    const plan = SubscriptionPlan(
      id: 'fitlog_pro_yearly',
      priceString: '39.99',
      period: SubscriptionPeriod.yearly,
    );

    setUp(() {
      repository = _FakePurchaseRepository();
      syncClient = _FakePremiumEntitlementSyncClient();
      service = PurchaseService(
        repository: repository,
        entitlementSyncClient: syncClient,
      );
    });

    test(
      'purchasePlan syncs entitlements after a successful purchase',
      () async {
        final result = await service.purchasePlan(plan, 'user-1');

        expect(result, isA<PurchaseSuccess>());
        expect(syncClient.syncedUserIds, ['user-1']);
      },
    );

    test(
      'purchasePlan preserves purchase success when server sync fails',
      () async {
        syncClient.syncError = StateError('sync unavailable');

        final result = await service.purchasePlan(plan, 'user-2');

        expect(result, isA<PurchaseSuccess>());
        expect(syncClient.syncedUserIds, isEmpty);
      },
    );

    test(
      'restorePurchases syncs entitlements after a successful restore',
      () async {
        final result = await service.restorePurchases('user-3');

        expect(result, isA<PurchaseSuccess>());
        expect(syncClient.syncedUserIds, ['user-3']);
      },
    );

    test(
      'restorePurchases preserves restore success when server sync fails',
      () async {
        syncClient.syncError = StateError('sync unavailable');

        final result = await service.restorePurchases('user-5');

        expect(result, isA<PurchaseSuccess>());
        expect(syncClient.syncedUserIds, isEmpty);
      },
    );

    test(
      'checkAndSyncStatus preserves current access when server sync fails',
      () async {
        syncClient.syncError = StateError('RevenueCat unavailable');

        await expectLater(service.checkAndSyncStatus('user-4'), completes);
        expect(syncClient.syncedUserIds, isEmpty);
      },
    );
  });
}
