library;

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
    state = state.copyWith(isPurchasing: true);
    try {
      final service = ref.read(purchaseServiceProvider);
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        const result = PurchaseError('User not authenticated');
        state = PurchaseActionState(lastResult: result);
        return result;
      }

      final result = await service.purchasePlan(plan, userId);
      state = PurchaseActionState(lastResult: result);
      return result;
    } catch (e) {
      final result = PurchaseError(e.toString());
      state = PurchaseActionState(lastResult: result);
      return result;
    }
  }

  Future<PurchaseResult> restore() async {
    state = state.copyWith(isPurchasing: true);
    try {
      final service = ref.read(purchaseServiceProvider);
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        const result = PurchaseError('User not authenticated');
        state = PurchaseActionState(lastResult: result);
        return result;
      }

      final result = await service.restorePurchases(userId);
      state = PurchaseActionState(lastResult: result);
      return result;
    } catch (e) {
      final result = PurchaseError(e.toString());
      state = PurchaseActionState(lastResult: result);
      return result;
    }
  }
}

final purchaseActionProvider =
    NotifierProvider<PurchaseActionNotifier, PurchaseActionState>(
  PurchaseActionNotifier.new,
);
