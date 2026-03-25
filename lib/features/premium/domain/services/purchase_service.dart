library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_sync_client.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/repositories/purchase_repository.dart';

class PurchaseService {
  PurchaseService({
    required PurchaseRepository repository,
    required PremiumEntitlementSyncClient entitlementSyncClient,
  }) : _repository = repository,
       _entitlementSyncClient = entitlementSyncClient;

  static const premiumSyncFailedMessage = 'premiumSyncFailed';

  final PurchaseRepository _repository;
  final PremiumEntitlementSyncClient _entitlementSyncClient;

  Future<PurchaseResult> purchasePlan(
    SubscriptionPlan plan,
    String userId,
  ) async {
    final result = await _repository.purchase(plan);
    if (result is PurchaseSuccess) {
      await _syncAfterSuccess(userId, context: 'purchase');
    }
    return result;
  }

  Future<PurchaseResult> restorePurchases(String userId) async {
    final result = await _repository.restorePurchases();
    if (result is PurchaseSuccess) {
      await _syncAfterSuccess(userId, context: 'restore');
    }
    return result;
  }

  Future<void> checkAndSyncStatus(String userId) async {
    try {
      await _entitlementSyncClient.syncEntitlements(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PurchaseService] Skipping entitlement sync for $userId, preserving current access: $e',
        );
      }
    }
  }

  Future<void> _syncAfterSuccess(
    String userId, {
    required String context,
  }) async {
    try {
      await _entitlementSyncClient.syncEntitlements(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PurchaseService] Failed to finalize $context sync; preserving RevenueCat access and retrying later: $e',
        );
      }
    }
  }
}
