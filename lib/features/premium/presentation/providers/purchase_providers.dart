library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/config/revenuecat_config.dart';
import 'package:gymbro_flutter_new/features/premium/data/datasources/revenuecat_datasource.dart';
import 'package:gymbro_flutter_new/features/premium/data/repositories/purchase_repository_impl.dart';
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_sync_client.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/domain/repositories/purchase_repository.dart';
import 'package:gymbro_flutter_new/features/premium/domain/services/purchase_service.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';

final revenueCatDatasourceProvider = Provider<RevenueCatDatasource>((ref) {
  return RevenueCatDatasource();
});

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final datasource = ref.watch(revenueCatDatasourceProvider);
  return PurchaseRepositoryImpl(datasource: datasource);
});

final premiumEntitlementSyncClientProvider =
    Provider<PremiumEntitlementSyncClient>((ref) {
      return CloudFunctionPremiumEntitlementSyncClient();
    });

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  final entitlementSyncClient = ref.watch(premiumEntitlementSyncClientProvider);
  return PurchaseService(
    repository: repository,
    entitlementSyncClient: entitlementSyncClient,
  );
});

final revenueCatConfiguredProvider = Provider<bool>((ref) {
  final isConfigured = RevenueCatConfig.isConfigured;
  if (kDebugMode) {
    debugPrint(
      '[PurchaseProviders] revenueCatConfiguredProvider -> $isConfigured',
    );
  }
  return isConfigured;
});

final revenueCatInitProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (kDebugMode) {
    debugPrint(
      '[PurchaseProviders] revenueCatInitProvider start: '
      'rcConfigured=${RevenueCatConfig.isConfigured}, userId=${userId ?? '<null>'}',
    );
  }
  await repository.initialize();
  if (userId != null) {
    await repository.setUserId(userId);

    final service = ref.read(purchaseServiceProvider);
    await service.checkAndSyncStatus(userId);
    if (kDebugMode) {
      debugPrint(
        '[PurchaseProviders] revenueCatInitProvider complete for userId=$userId',
      );
    }
  } else {
    await repository.logout();
    if (kDebugMode) {
      debugPrint(
        '[PurchaseProviders] revenueCatInitProvider complete with anonymous user',
      );
    }
  }
});

final availablePlansProvider = FutureProvider<List<SubscriptionPlan>>((
  ref,
) async {
  // Ensure RevenueCat is initialized before fetching plans
  if (kDebugMode) {
    debugPrint('[PurchaseProviders] availablePlansProvider start');
  }
  await ref.watch(revenueCatInitProvider.future);
  final repository = ref.watch(purchaseRepositoryProvider);
  final plans = await repository.getAvailablePlans();
  if (kDebugMode) {
    debugPrint(
      '[PurchaseProviders] availablePlansProvider resolved ${plans.length} plan(s): '
      '${plans.map((plan) => '${plan.id}/${plan.period.name}@${plan.priceString}').toList()}',
    );
  }
  return plans;
});

final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((
  ref,
) async* {
  // Ensure RevenueCat is initialized before watching status
  if (kDebugMode) {
    debugPrint('[PurchaseProviders] subscriptionStatusProvider start');
  }
  await ref.watch(revenueCatInitProvider.future);
  final repository = ref.watch(purchaseRepositoryProvider);
  await for (final status in repository.watchSubscriptionStatus()) {
    if (kDebugMode) {
      debugPrint(
        '[PurchaseProviders] subscriptionStatusProvider -> '
        'active=${status.isActive}, productId=${status.productId ?? '<null>'}, '
        'willRenew=${status.willRenew}, isLifetime=${status.isLifetime}, '
        'expiration=${status.expirationDate?.toIso8601String() ?? '<none>'}',
      );
    }
    yield status;
  }
});
