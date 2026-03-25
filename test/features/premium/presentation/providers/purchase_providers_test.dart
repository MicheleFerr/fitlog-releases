import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_sync_client.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/domain/repositories/purchase_repository.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';

class _FakePurchaseRepository implements PurchaseRepository {
  int initializeCalls = 0;
  int logoutCalls = 0;
  final List<String> loggedInUserIds = <String>[];
  SubscriptionStatus status = const SubscriptionStatus(isActive: true);

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async => const [];

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async => status;

  @override
  Stream<SubscriptionStatus> watchSubscriptionStatus() async* {
    yield status;
  }

  @override
  Future<PurchaseResult> purchase(SubscriptionPlan plan) async {
    return const PurchaseSuccess();
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    return const PurchaseSuccess();
  }

  @override
  Future<void> setUserId(String userId) async {
    loggedInUserIds.add(userId);
  }

  @override
  Future<void> logout() async {
    logoutCalls += 1;
  }
}

class _FakePremiumEntitlementSyncClient
    implements PremiumEntitlementSyncClient {
  final List<String> syncedUserIds = <String>[];

  @override
  Future<void> syncEntitlements(String userId) async {
    syncedUserIds.add(userId);
  }
}

void main() {
  group('revenueCatInitProvider', () {
    test(
      'initializes, logs in, and syncs premium entitlements for authenticated users',
      () async {
        final repository = _FakePurchaseRepository();
        final syncClient = _FakePremiumEntitlementSyncClient();

        final container = ProviderContainer(
          overrides: [
            currentUserIdProvider.overrideWith((ref) => 'user-1'),
            purchaseRepositoryProvider.overrideWithValue(repository),
            premiumEntitlementSyncClientProvider.overrideWithValue(syncClient),
          ],
        );
        addTearDown(container.dispose);

        await container.read(revenueCatInitProvider.future);

        expect(repository.initializeCalls, 1);
        expect(repository.loggedInUserIds, ['user-1']);
        expect(repository.logoutCalls, 0);
        expect(syncClient.syncedUserIds, ['user-1']);
      },
    );

    test('logs out RevenueCat when there is no authenticated user', () async {
      final repository = _FakePurchaseRepository();
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => null),
          purchaseRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(revenueCatInitProvider.future);

      expect(repository.initializeCalls, 1);
      expect(repository.loggedInUserIds, isEmpty);
      expect(repository.logoutCalls, 1);
    });
  });
}
