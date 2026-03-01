library;

import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';

abstract class PurchaseRepository {
  Future<void> initialize();
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<SubscriptionStatus> getSubscriptionStatus();
  Stream<SubscriptionStatus> watchSubscriptionStatus();
  Future<PurchaseResult> purchase(SubscriptionPlan plan);
  Future<PurchaseResult> restorePurchases();
  Future<void> setUserId(String userId);
  Future<void> logout();
}
