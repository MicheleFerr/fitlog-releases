library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

enum PremiumPlan { monthly, yearly, lifetime }

class PremiumEntitlement {
  const PremiumEntitlement({
    required this.isActive,
    required this.accountTier,
    this.plan,
    this.expiresAt,
    this.willRenew = false,
    this.isLifetime = false,
    this.productId,
    this.source = 'none',
    this.lastSyncedAt,
  });

  const PremiumEntitlement.free({this.source = 'none'})
    : isActive = false,
      accountTier = AccountTier.free,
      plan = null,
      expiresAt = null,
      willRenew = false,
      isLifetime = false,
      productId = null,
      lastSyncedAt = null;

  factory PremiumEntitlement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final rawTier = data['accountTier'] as String?;
    final isActive =
        data['premiumActive'] == true ||
        rawTier == AccountTier.premium.name ||
        rawTier == 'pro';

    return PremiumEntitlement(
      isActive: isActive,
      accountTier: isActive ? AccountTier.premium : AccountTier.free,
      plan: _parsePlan(data['plan']),
      expiresAt: _parseDateTime(data['expiresAt']),
      willRenew: data['willRenew'] == true,
      isLifetime: data['isLifetime'] == true,
      productId: data['productId'] as String?,
      source: data['source'] as String? ?? 'unknown',
      lastSyncedAt: _parseDateTime(data['lastSyncedAt']),
    );
  }

  final bool isActive;
  final AccountTier accountTier;
  final PremiumPlan? plan;
  final DateTime? expiresAt;
  final bool willRenew;
  final bool isLifetime;
  final String? productId;
  final String source;
  final DateTime? lastSyncedAt;

  static PremiumPlan? _parsePlan(Object? rawPlan) {
    return switch (rawPlan) {
      'monthly' => PremiumPlan.monthly,
      'yearly' => PremiumPlan.yearly,
      'lifetime' => PremiumPlan.lifetime,
      _ => null,
    };
  }

  static DateTime? _parseDateTime(Object? rawValue) {
    if (rawValue is Timestamp) {
      return rawValue.toDate();
    }

    if (rawValue is DateTime) {
      return rawValue;
    }

    if (rawValue is String) {
      return DateTime.tryParse(rawValue);
    }

    return null;
  }
}
