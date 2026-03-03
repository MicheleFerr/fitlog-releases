library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/premium/data/datasources/revenuecat_datasource.dart';
import 'package:gymbro_flutter_new/features/premium/data/repositories/purchase_repository_impl.dart';
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

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final repository = ref.watch(purchaseRepositoryProvider);
  return PurchaseService(repository: repository);
});

final revenueCatInitProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(purchaseRepositoryProvider);
  await repository.initialize();

  final userId = ref.watch(currentUserIdProvider);
  if (userId != null) {
    await repository.setUserId(userId);

    final service = ref.read(purchaseServiceProvider);
    await service.checkAndSyncStatus(userId);
  }
});

final availablePlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  // Ensure RevenueCat is initialized before fetching plans
  await ref.watch(revenueCatInitProvider.future);
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getAvailablePlans();
});

final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) async* {
  // Ensure RevenueCat is initialized before watching status
  await ref.watch(revenueCatInitProvider.future);
  final repository = ref.watch(purchaseRepositoryProvider);
  yield* repository.watchSubscriptionStatus();
});
