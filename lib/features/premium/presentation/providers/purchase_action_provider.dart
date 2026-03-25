library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';

class PurchaseActionState {
  const PurchaseActionState({
    this.isPurchasing = false,
    this.lastResult,
  });

  final bool isPurchasing;
  final PurchaseResult? lastResult;

  PurchaseActionState copyWith({
    bool? isPurchasing,
    PurchaseResult? lastResult,
  }) {
    return PurchaseActionState(
      isPurchasing: isPurchasing ?? this.isPurchasing,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

class PurchaseActionNotifier extends Notifier<PurchaseActionState> {
  @override
  PurchaseActionState build() => const PurchaseActionState();

  Future<PurchaseResult> purchase(SubscriptionPlan plan) async {
    _log(
      'purchase() start: planId=${plan.id}, period=${plan.period.name}, '
      'price=${plan.priceString}, rcPackageIdentifier=${plan.rcPackageIdentifier}',
    );
    state = state.copyWith(isPurchasing: true);
    try {
      final service = ref.read(purchaseServiceProvider);
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        _log('purchase() aborted: user not authenticated');
        const result = PurchaseError('User not authenticated');
        state = const PurchaseActionState(lastResult: result);
        return result;
      }

      final result = await service.purchasePlan(plan, userId);
      _log('purchase() completed for userId=$userId with result=$result');
      state = PurchaseActionState(lastResult: result);
      return result;
    } catch (e) {
      _log('purchase() failed with error=$e');
      final result = PurchaseError(e.toString());
      state = PurchaseActionState(lastResult: result);
      return result;
    }
  }

  Future<PurchaseResult> restore() async {
    _log('restore() start');
    state = state.copyWith(isPurchasing: true);
    try {
      final service = ref.read(purchaseServiceProvider);
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        _log('restore() aborted: user not authenticated');
        const result = PurchaseError('User not authenticated');
        state = const PurchaseActionState(lastResult: result);
        return result;
      }

      final result = await service.restorePurchases(userId);
      _log('restore() completed for userId=$userId with result=$result');
      state = PurchaseActionState(lastResult: result);
      return result;
    } catch (e) {
      _log('restore() failed with error=$e');
      final result = PurchaseError(e.toString());
      state = PurchaseActionState(lastResult: result);
      return result;
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[PurchaseAction] $message');
    }
  }
}

final purchaseActionProvider =
    NotifierProvider<PurchaseActionNotifier, PurchaseActionState>(
  PurchaseActionNotifier.new,
);
