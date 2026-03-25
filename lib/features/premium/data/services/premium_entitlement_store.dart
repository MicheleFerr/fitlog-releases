library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:gymbro_flutter_new/features/premium/domain/entities/premium_entitlement.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

class PremiumEntitlementStore {
  PremiumEntitlementStore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<PremiumEntitlement?> watch(String userId) {
    return _entitlementRef(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return PremiumEntitlement.fromFirestore(snapshot);
    });
  }

  Future<PremiumEntitlement?> get(String userId) async {
    final snapshot = await _entitlementRef(userId).get();
    if (!snapshot.exists) {
      return null;
    }
    return PremiumEntitlement.fromFirestore(snapshot);
  }

  Future<AccountTier> getEffectiveAccountTier(String userId) async {
    try {
      final entitlement = await get(userId);
      if (entitlement != null) {
        return entitlement.accountTier;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PremiumEntitlementStore] Failed entitlement lookup for $userId: $e',
        );
      }
    }

    try {
      final userSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      final rawTier = userSnapshot.data()?['accountTier'];
      if (rawTier == AccountTier.premium.name || rawTier == 'pro') {
        return AccountTier.premium;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[PremiumEntitlementStore] Failed legacy tier lookup for $userId: $e',
        );
      }
    }

    return AccountTier.free;
  }

  DocumentReference<Map<String, dynamic>> _entitlementRef(String userId) {
    return _firestore.collection('user_entitlements').doc(userId);
  }
}
