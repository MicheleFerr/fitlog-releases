library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_store.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/premium_entitlement.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';

final premiumEntitlementStoreProvider = Provider<PremiumEntitlementStore>((
  ref,
) {
  return PremiumEntitlementStore();
});

final premiumEntitlementProvider = StreamProvider<PremiumEntitlement?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }

  final store = ref.watch(premiumEntitlementStoreProvider);
  return store.watch(userId);
});
