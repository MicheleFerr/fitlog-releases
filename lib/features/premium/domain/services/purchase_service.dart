library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/repositories/purchase_repository.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

class PurchaseService {
  PurchaseService({
    required PurchaseRepository repository,
    FirebaseFirestore? firestore,
  })  : _repository = repository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final PurchaseRepository _repository;
  final FirebaseFirestore _firestore;

  Future<PurchaseResult> purchasePlan(
    SubscriptionPlan plan,
    String userId,
  ) async {
    final result = await _repository.purchase(plan);
    if (result is PurchaseSuccess) {
      await _syncAccountTier(userId, AccountTier.premium);
    }
    return result;
  }

  Future<PurchaseResult> restorePurchases(String userId) async {
    final result = await _repository.restorePurchases();
    if (result is PurchaseSuccess) {
      await _syncAccountTier(userId, AccountTier.premium);
    }
    return result;
  }

  Future<void> checkAndSyncStatus(String userId) async {
    final status = await _repository.getSubscriptionStatus();
    final tier = status.isActive ? AccountTier.premium : AccountTier.free;
    await _syncAccountTier(userId, tier);
  }

  Future<void> _syncAccountTier(String userId, AccountTier tier) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'accountTier': tier.name,
      });
      if (kDebugMode) {
        debugPrint('[PurchaseService] Synced accountTier=${tier.name} for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseService] Failed to sync accountTier: $e');
      }
    }
  }
}
